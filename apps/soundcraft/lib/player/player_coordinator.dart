import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/data/repositories/queue_repository.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/domain/models/track.dart';

import 'audio_platform.dart';

/// Resolves a track into a concrete audio source just-in-time. Audius URLs are
/// short-lived/resolvable per play; local files map to file paths. YouTube NEVER
/// reaches this layer (R05) — the coordinator refuses it defensively too.
typedef PlaybackResolver = Future<AudioSourceSpec> Function(Track track);

/// Sleep timer options (§3.6): 5..60 minutes, end-of-track, off.
const List<int> kSleepTimerChoices = [5, 10, 15, 30, 45, 60];

/// The single owner of active playback state (§5.4, §24.1 invariant 1).
/// Exactly one instance exists; UI, media handler and notifications all read
/// from its [stateStream]. Commands are serialized and stale async races are
/// discarded with request ids (§7 cases 1–2).
class PlayerCoordinator {
  PlayerCoordinator({
    required AudioPlatform engine,
    required this._queueRepository,
    required this._historyRepository,
    this._resolvers = const {},
    this.previousThresholdMs = 3000,
    this.maxConsecutiveFailures = 3,
  }) : _engine = engine {
    _engineSub = engine.stateStream.listen(_onEngineState);
    _tickSub = engine.tickStream.listen(_onTick);
    _completionSub = engine.completionStream.listen((_) => _onCompleted());
    _errorSub = engine.errorStream.listen(_onEngineError);
  }

  final AudioPlatform _engine;
  final QueueRepository _queueRepository;
  final HistoryRepository _historyRepository;
  final Map<SourceProvider, PlaybackResolver> _resolvers;
  final int previousThresholdMs;
  final int maxConsecutiveFailures;

  StreamSubscription<void>? _engineSub;
  StreamSubscription<void>? _tickSub;
  StreamSubscription<void>? _completionSub;
  StreamSubscription<void>? _errorSub;

  final _stateController = StreamController<PlaybackState>.broadcast(
    sync: false,
  );
  PlaybackState _state = const PlaybackState();

  /// Current immutable playback snapshot.
  PlaybackState get state => _state;
  Stream<PlaybackState> get stateStream => _stateController.stream;

  final List<Track> _queue = <Track>[];
  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _state.queueIndex ?? -1;
  Track? get currentTrack {
    final i = currentIndex;
    return (i >= 0 && i < _queue.length) ? _queue[i] : null;
  }

  /// Play order when shuffle is ON (indices into _queue, current first).
  List<int> _shuffleOrder = <int>[];
  int? _shuffleSeed;
  int _requestId = 0;

  /// Command/event sequence accounting: the Nth play command owns the Nth
  /// 'playing' event; anything else is stale and dropped (§7 case 1/2).
  int _playCommands = 0;
  int _playEventsSeen = 0;
  int _consecutiveFailures = 0;
  int _listenedSinceLastEventMs = 0;
  int? _lastTickPositionMs;
  Timer? _sleepTimer;
  Timer? _persistDebounce;
  bool _stopAfterCurrentTrack = false;
  bool _pausedByInterruption = false;
  double? _volumeBeforeDuck;
  final Map<String, ({AudioSourceSpec spec, DateTime fetchedAt})>
      _preloadedSpecs = {};
  final Set<String> _retriedTrackIds = {};
  Future<void> _commandChain = Future.value();

  // ---------------------------------------------------------------- public API

  /// Replaces the queue with [tracks] and starts [startIndex] immediately.
  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    bool autoPlay = true,
  }) {
    _requestId++;
    return _serialize(() async {
      if (tracks.isEmpty) return;
      _queue
        ..clear()
        ..addAll(tracks);
      _applyShuffleOrder(
        seed: _state.shuffle ? DateTime.now().millisecondsSinceEpoch : null,
        keepFirstIndex: startIndex,
      );
      await _loadAndPlay(
        startIndex.clamp(0, _queue.length - 1),
        autoPlay: autoPlay,
      );
    });
  }

  /// Plays a single track (queue = [track]); convenience for PLY-001.
  Future<void> playSingle(Track track) => playTracks([track]);

  /// Inserts [track] to play right after the current one ("Play Next").
  Future<void> playNext(Track track) {
    return _serialize(() async {
      final at = currentIndex < 0 ? 0 : currentIndex + 1;
      _queue.insert(at.clamp(0, _queue.length), track);
      _rebuildShuffleKeepCurrent();
      await _persistSoon();
    });
  }

  /// Appends [track] to the end of the queue ("Add to Queue").
  Future<void> addToQueue(Track track) {
    return _serialize(() async {
      _queue.add(track);
      _rebuildShuffleKeepCurrent();
      await _persistSoon();
    });
  }

  Future<void> removeFromQueue(int index) {
    return _serialize(() async {
      if (index < 0 || index >= _queue.length) return;
      if (index == currentIndex) {
        // Removing the current item: keep it loaded but remove from queue per
        // LIB semantics — skip forward instead to avoid undefined state.
        final wasLast = index == _queue.length - 1;
        _queue.removeAt(index);
        _normalizeQueueIndex();
        if (!wasLast && _queue.isNotEmpty) {
          await _loadAndPlay(
            currentIndex.clamp(0, _queue.length - 1),
            autoPlay: _state.isPlaying,
          );
        }
      } else {
        _queue.removeAt(index);
        _normalizeQueueIndex();
      }
      _rebuildShuffleKeepCurrent();
      await _persistSoon();
    });
  }

  /// Drag-reorder within the queue (§3.10); indices are queue positions.
  Future<void> reorderQueue(int oldIndex, int newIndex) {
    return _serialize(() async {
      if (oldIndex < 0 || oldIndex >= _queue.length) return;
      var target = newIndex;
      if (target > oldIndex) target--;
      final item = _queue.removeAt(oldIndex);
      _queue.insert(target.clamp(0, _queue.length), item);
      _normalizeQueueIndex();
      _rebuildShuffleKeepCurrent();
      await _persistSoon();
    });
  }

  /// Clears everything after the current item (confirm in UI, PL semantics).
  Future<void> clearUpcoming() {
    return _serialize(() async {
      if (currentIndex >= 0 && currentIndex < _queue.length - 1) {
        _queue.removeRange(currentIndex + 1, _queue.length);
        await _persistSoon();
      }
    });
  }

  /// Explicit play (notifications, media keys, interruption resume).
  /// Unlike [togglePlay], this never pauses if already playing.
  Future<void> play() {
    return _serialize(() async {
      switch (_state.status) {
        case PlaybackStatus.playing:
          return;
        case PlaybackStatus.readyPaused:
          _playCommands++;
          _set(
            _state.copyWith(status: PlaybackStatus.playing, clearError: true),
          );
          await _engine.play();
        case PlaybackStatus.idle:
        case PlaybackStatus.completed:
        case PlaybackStatus.recoverableError:
          final i = currentIndex;
          if (i >= 0 && i < _queue.length) {
            await _loadAndPlay(i, autoPlay: true);
          }
        default:
          break;
      }
    });
  }

  /// Explicit pause (interruptions, media session, sleep timer).
  Future<void> pause() => _serialize(_pauseInternal);

  /// Audio-focus interruption started (calls, other media apps, navigation).
  Future<void> handleInterruptionBegin({required bool duck}) {
    return _serialize(() async {
      if (duck) {
        if (_state.isPlaying && _volumeBeforeDuck == null) {
          _volumeBeforeDuck = _state.volume;
          try {
            await _engine.setVolume((_state.volume * 0.25).clamp(0.0, 1.0));
          } catch (_) {}
        }
        return;
      }
      if (_state.status == PlaybackStatus.playing ||
          _state.status == PlaybackStatus.buffering ||
          _state.status == PlaybackStatus.loading) {
        _pausedByInterruption = true;
        await _pauseInternal();
      }
    });
  }

  /// Audio-focus interruption ended; restores ducked volume or resumes if we paused.
  Future<void> handleInterruptionEnd({required bool shouldResume}) {
    return _serialize(() async {
      if (_volumeBeforeDuck != null) {
        final restore = _volumeBeforeDuck!;
        _volumeBeforeDuck = null;
        try {
          await _engine.setVolume(restore);
        } catch (_) {}
      }
      if (shouldResume && _pausedByInterruption) {
        _pausedByInterruption = false;
        if (_state.status == PlaybackStatus.readyPaused) {
          _playCommands++;
          _set(
            _state.copyWith(status: PlaybackStatus.playing, clearError: true),
          );
          await _engine.play();
        }
      } else {
        _pausedByInterruption = false;
      }
    });
  }

  /// Headphones unplugged / Bluetooth disconnected: pause immediately.
  Future<void> handleBecomingNoisy() {
    return _serialize(() async {
      _pausedByInterruption = false;
      if (_state.isPlaying) {
        await _pauseInternal();
      }
    });
  }

  /// Stops playback, pauses the engine, and unloads/clears the current queue.
  Future<void> stopAndDismiss() {
    return _serialize(() async {
      await _pauseInternal();
      _queue.clear();
      _set(
        const PlaybackState(
          status: PlaybackStatus.idle,
          queueLength: 0,
        ),
      );
      await _persistSoon();
    });
  }

  /// PLY-002: toggles play/pause backed by the actual engine state.
  Future<void> togglePlay() {
    return _serialize(() async {
      switch (_state.status) {
        case PlaybackStatus.playing:
          await _pauseInternal();
        case PlaybackStatus.readyPaused:
          // Optimistic intent flip (rapid taps stay deterministic, §7 case 2);
          // the engine confirms via sequence-matched events.
          _playCommands++;
          _set(
            _state.copyWith(status: PlaybackStatus.playing, clearError: true),
          );
          await _engine.play();
        case PlaybackStatus.idle:
        case PlaybackStatus.completed:
          final i = currentIndex;
          if (i >= 0 && i < _queue.length) {
            await _loadAndPlay(i, autoPlay: true);
          }
        case PlaybackStatus.recoverableError:
          final i = currentIndex;
          if (i >= 0 && i < _queue.length) {
            await _loadAndPlay(i, autoPlay: true);
          }
        default:
          // loading/buffering: ignore rapid taps while resolving (§7 case 2)
          break;
      }
    });
  }

  /// PLY-003 next: repeat-aware; at end with repeat off -> completes.
  Future<void> next({bool userInvoked = true}) {
    return _serialize(() async {
      // ignore: avoid_print
      if (const bool.fromEnvironment('SOUNDCRAFT_TRACE')) print('[trace] next() entry idx=$currentIndex q=${_queue.length} repeat=${_state.repeatMode}');
      if (_queue.isEmpty) return;
      final status = _state.status;
      final playing = status == PlaybackStatus.playing;
      final target = _nextQueueIndex();
      // ignore: avoid_print
      if (const bool.fromEnvironment('SOUNDCRAFT_TRACE')) print('[trace] next() target=$target');
      if (target == null) {
        // End of queue, repeat off.
        // ignore: avoid_print
        if (const bool.fromEnvironment('SOUNDCRAFT_TRACE')) print('[trace] next: end-of-queue -> completed path');
        await _pauseInternal();
        _set(_state.copyWith(status: PlaybackStatus.completed));
        return;
      }
      await _loadAndPlay(target, autoPlay: playing || userInvoked);
    });
  }

  /// PLY-003 previous: >threshold => restart track; else previous track.
  Future<void> previous() {
    return _serialize(() async {
      if (_queue.isEmpty) return;
      if (_state.positionMs > previousThresholdMs) {
        await _engine.seek(0);
        _set(_state.copyWith(positionMs: 0));
        return;
      }
      final playing = _state.status == PlaybackStatus.playing;
      final target = _previousQueueIndex();
      if (target == null) {
        await _engine.seek(0);
        _set(_state.copyWith(positionMs: 0));
        return;
      }
      await _loadAndPlay(target, autoPlay: playing);
    });
  }

  /// PLY-004 seek: only when source supports it (state.canSeek) and duration
  /// is known; live/unknown-length streams are guarded (§7 case 9).
  Future<void> seekTo(int positionMs) {
    return _serialize(() async {
      if (!_state.canSeek) {
        throw const PlaybackException(
          'Seeking is not available for this source',
        );
      }
      var target = positionMs;
      final duration = _state.durationMs;
      if (duration != null && duration > 0) {
        target = target.clamp(0, duration);
      } else if (target < 0) {
        target = 0;
      }
      _set(_state.copyWith(status: PlaybackStatus.seeking));
      await _engine.seek(target);
      _set(
        _state.copyWith(
          positionMs: target,
          status: _state.isPlaying
              ? PlaybackStatus.playing
              : PlaybackStatus.readyPaused,
        ),
      );
      _lastTickPositionMs = target;
    });
  }

  /// PLY-005 shuffle: re-permutes play order, keeps the current track (§24.1).
  Future<void> setShuffle(bool enabled) {
    return _serialize(() async {
      _set(_state.copyWith(shuffle: enabled));
      if (enabled) {
        _applyShuffleOrder(seed: DateTime.now().millisecondsSinceEpoch);
      } else {
        _shuffleOrder = <int>[];
        _shuffleSeed = null;
        // The queue list is always stored in original order; the active
        // index keeps pointing at the current track. No state reset needed.
      }
      await _persistSoon();
    });
  }

  /// PLY-006 repeat cycle Off -> All -> One -> Off (persisted).
  Future<void> cycleRepeat() {
    return _serialize(() async {
      final nextMode = nextRepeatMode(_state.repeatMode);
      _set(_state.copyWith(repeatMode: nextMode));
      await _persistSoon();
    });
  }

  Future<void> setRepeatMode(RepeatMode mode) {
    return _serialize(() async {
      _set(_state.copyWith(repeatMode: mode));
      await _persistSoon();
    });
  }

  /// PLY-010 volume: app-level; unsupported on some platforms — engine throws
  /// and we surface the typed error (not an inert slider).
  Future<void> setVolume(double volume) async {
    try {
      await _engine.setVolume(volume);
      _set(_state.copyWith(volume: volume.clamp(0.0, 1.0), muted: volume <= 0));
    } on AudioUnsupportedException catch (e) {
      throw PlaybackException('Volume control unavailable: ${e.message}');
    }
  }

  Future<void> setSpeed(double speed) async {
    final clamped = speed.clamp(0.5, 2.0);
    try {
      await _engine.setSpeed(clamped);
      _set(_state.copyWith(speed: clamped));
    } on AudioUnsupportedException catch (e) {
      throw PlaybackException('Speed control unavailable: ${e.message}');
    }
  }

  /// PLY-011 sleep timer: minutes or end-of-track. Persists via preferences at
  /// call site; countdown lives here so navigation cannot kill it.
  Future<void> startSleepTimerMinutes(int minutes) async {
    _sleepTimer?.cancel();
    _stopAfterCurrentTrack = false;
    final endsAt = DateTime.now().add(Duration(minutes: minutes));
    _set(_state.copyWith(sleepTimerEndsAt: endsAt));
    _sleepTimer = Timer(Duration(minutes: minutes), () async {
      await _pauseInternal();
      _set(
        _state.copyWith(
          clearSleepTimer: true,
          status: PlaybackStatus.readyPaused,
        ),
      );
    });
  }

  /// Pause when the current track completes instead of advancing.
  Future<void> startSleepTimerEndOfTrack() async {
    _sleepTimer?.cancel();
    _stopAfterCurrentTrack = true;
    _set(_state.copyWith(sleepTimerEndsAt: DateTime.now()));
  }

  Future<void> cancelSleepTimer() async {
    _sleepTimer?.cancel();
    _stopAfterCurrentTrack = false;
    _set(_state.copyWith(clearSleepTimer: true));
  }

  /// Restores a persisted queue snapshot WITHOUT auto-playing (§24.1
  /// invariant 3; NAV-008 no spontaneous autoplay on cold start).
  Future<void> restore() async {
    final snapshot = await _queueRepository.restore();
    if (snapshot == null || snapshot.items.isEmpty) return;
    _queue
      ..clear()
      ..addAll(snapshot.items.map(_recordToTrack));
    _set(
      _state.copyWith(
        shuffle: snapshot.shuffle,
        repeatMode: snapshot.repeatMode,
        queueIndex: snapshot.activeIndex.clamp(0, _queue.length - 1),
        positionMs: snapshot.positionMs,
        status: PlaybackStatus.readyPaused,
        queueLength: _queue.length,
      ),
    );
    if (snapshot.shuffle) {
      _shuffleSeed = snapshot.shuffleSeed;
      _applyShuffleOrder(seed: _shuffleSeed ?? 1);
    }
  }

  /// Persists queue+position at safe intervals (called debounced internally).
  Future<void> persistNow() async {
    if (_queue.isEmpty) return;
    await _queueRepository.save(
      items: _queue.map(_trackToRecord).toList(),
      activeIndex: currentIndex < 0 ? 0 : currentIndex,
      positionMs: _state.positionMs,
      shuffle: _state.shuffle,
      shuffleSeed: _shuffleSeed,
      repeatMode: _state.repeatMode,
    );
  }

  Future<void> dispose() async {
    _sleepTimer?.cancel();
    _persistDebounce?.cancel();
    await _engineSub?.cancel();
    await _tickSub?.cancel();
    await _completionSub?.cancel();
    await _errorSub?.cancel();
    await _engine.dispose();
    await _stateController.close();
  }

  // ---------------------------------------------------------------- internals

  /// Serializes commands to keep rapid interactions deterministic (§7 case 2).
  Future<void> _serialize(Future<void> Function() action) {
    final run = _commandChain.then((_) => action());
    _commandChain = run.catchError((Object _, StackTrace _) {});
    return run;
  }

  void _set(PlaybackState next) {
    _state = next.copyWith(queueLength: _queue.length);
    if (!_stateController.isClosed) _stateController.add(_state);
  }

  void _onEngineState(AudioEngineState s) {
    if (const bool.fromEnvironment('SOUNDCRAFT_TRACE')) {
      debugPrint(
        '[trace] engine=$s playCmds=$_playCommands playEvents=$_playEventsSeen status=${_state.status}',
      );
    }
    switch (s) {
      case AudioEngineState.loading:
        _set(_state.copyWith(status: PlaybackStatus.loading));
      case AudioEngineState.buffering:
        _set(_state.copyWith(status: PlaybackStatus.buffering));
      case AudioEngineState.playing:
        _playEventsSeen = _playCommands;
        _set(_state.copyWith(status: PlaybackStatus.playing));
        _consecutiveFailures = 0;
      case AudioEngineState.ready:
      case AudioEngineState.paused:
        if (_state.status == PlaybackStatus.completed ||
            _state.status == PlaybackStatus.unavailable ||
            _state.status == PlaybackStatus.seeking) {
          return;
        }
        _set(_state.copyWith(status: PlaybackStatus.readyPaused));
      case AudioEngineState.idle:
        break;
      case AudioEngineState.completed:
        break; // handled via completionStream
    }
  }

  void _onTick(AudioEngineTick tick) {
    if (_lastTickPositionMs != null && _state.isPlaying) {
      final delta = tick.positionMs - _lastTickPositionMs!;
      if (delta > 0 && delta < 10000) _listenedSinceLastEventMs += delta;
    }
    _lastTickPositionMs = tick.positionMs;
    _set(
      _state.copyWith(
        positionMs: tick.positionMs,
        bufferedMs: tick.bufferedMs,
        durationMs: tick.durationMs,
      ),
    );
  }

  void _onEngineError(String message) {
    final track = currentTrack;
    // Try refreshing the stream URL once at the current position before skipping.
    if (track != null &&
        track.provider != SourceProvider.local &&
        !_retriedTrackIds.contains(track.stableId)) {
      _retriedTrackIds.add(track.stableId);
      _preloadedSpecs.remove(track.stableId);
      final resumePos = _state.positionMs;
      unawaited(
        _serialize(() async {
          final idx = currentIndex;
          if (idx >= 0 &&
              idx < _queue.length &&
              _queue[idx].stableId == track.stableId) {
            await _loadAndPlay(
              idx,
              autoPlay: true,
              initialPositionMs: resumePos > 1000 ? resumePos : null,
            );
          }
        }),
      );
      return;
    }
    _consecutiveFailures++;
    if (_consecutiveFailures >= maxConsecutiveFailures) {
      _set(_state.copyWith(status: PlaybackStatus.unavailable, error: message));
      return;
    }
    _set(
      _state.copyWith(status: PlaybackStatus.recoverableError, error: message),
    );
    // Bounded auto-recovery: try the next queue entry once, then stop.
    unawaited(
      _serialize(() async {
        final target = _nextQueueIndex();
        if (target != null) {
          await _loadAndPlay(target, autoPlay: true);
        }
      }),
    );
  }

  Future<void> _onCompleted() async {
    // Ignore completion events while resolving or loading a new track to prevent double-skipping
    if (_state.status == PlaybackStatus.resolving ||
        _state.status == PlaybackStatus.loading) {
      return;
    }
    _flushListenProgress(completed: true);
    if (_stopAfterCurrentTrack) {
      _stopAfterCurrentTrack = false;
      await cancelSleepTimer();
      await _pauseInternal();
      _set(_state.copyWith(status: PlaybackStatus.completed));
      return;
    }
    if (_state.repeatMode == RepeatMode.one) {
      await _loadAndPlay(currentIndex, autoPlay: true);
      return;
    }
    await next(userInvoked: false);
  }

  /// Loads and plays queue position [index]; discards stale requests (§7 case 1).
  /// [preserveError] keeps the previous notice visible across auto-skips so
  /// the user learns WHY a track was passed over (cleared on user intent).
  Future<void> _loadAndPlay(
    int index, {
    required bool autoPlay,
    bool preserveError = false,
    int? initialPositionMs,
  }) async {
    if (index < 0 || index >= _queue.length) return;
    final track = _queue[index];
    final request = ++_requestId;
    try {
      await _engine.pause();
    } catch (_) {}
    _flushListenProgress(completed: false);
    _set(
      _state.copyWith(
        status: PlaybackStatus.resolving,
        stableTrackId: track.stableId,
        positionMs: initialPositionMs ?? 0,
        durationMs: track.durationMs,
        canSeek: true,
        queueIndex: index,
        clearError: !preserveError,
      ),
    );
    _lastTickPositionMs = initialPositionMs ?? 0;
    _listenedSinceLastEventMs = 0;

    final cached = _consumePreloadedSpec(track.stableId);
    final spec = cached ?? await _resolveSpec(track);
    if (spec == null) {
      if (request != _requestId) return; // stale
      await _handleUnavailable(track);
      return;
    }
    try {
      var duration = await _engine.load(spec);
      if (request != _requestId) return; // stale: another selection won
      if (initialPositionMs != null &&
          initialPositionMs > 0 &&
          duration != null &&
          initialPositionMs < duration) {
        try {
          await _engine.seek(initialPositionMs);
        } catch (_) {}
      }
      // NOTE: error text persists across auto-recovered skips so the user
      // sees WHY a track was passed over; it clears on the next user intent.
      _set(
        _state.copyWith(
          durationMs: duration ?? track.durationMs,
          canSeek: duration != null && duration > 0,
          status: PlaybackStatus.readyPaused,
        ),
      );
      _retriedTrackIds.remove(track.stableId);
      if (autoPlay) {
        _playCommands++;
        _set(
          _state.copyWith(
            status: PlaybackStatus.playing,
          ),
        );
        await _engine.play();
        if (_historyRepository.enabled) {
          unawaited(
            _historyRepository.recordStart(
              stableTrackId: track.stableId,
              sourceType: track.provider,
            ),
          );
        }
      }
      unawaited(_persistSoon());
      unawaited(_preloadNext());
    } on PlaybackException {
      rethrow;
    } on Object catch (e) {
      if (request != _requestId) return;
      // If we used a preloaded/cached URL or haven't retried yet, refresh once.
      if (track.provider != SourceProvider.local &&
          !_retriedTrackIds.contains(track.stableId)) {
        _retriedTrackIds.add(track.stableId);
        _preloadedSpecs.remove(track.stableId);
        final fresh = await _resolveSpec(track);
        if (fresh != null && request == _requestId) {
          try {
            final duration = await _engine.load(fresh);
            if (request != _requestId) return;
            _set(
              _state.copyWith(
                durationMs: duration ?? track.durationMs,
                canSeek: duration != null && duration > 0,
                status: PlaybackStatus.readyPaused,
              ),
            );
            _retriedTrackIds.remove(track.stableId);
            if (autoPlay) {
              _playCommands++;
              _set(_state.copyWith(status: PlaybackStatus.playing));
              await _engine.play();
            }
            unawaited(_persistSoon());
            unawaited(_preloadNext());
            return;
          } on Object {
            if (request != _requestId) return;
          }
        }
      }
      await _handleLoadError(track, e);
    }
  }

  AudioSourceSpec? _consumePreloadedSpec(String stableId) {
    final entry = _preloadedSpecs.remove(stableId);
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt).inMinutes >= 2) return null;
    return entry.spec;
  }

  Future<void> _preloadNext() async {
    final nextIdx = _nextQueueIndex();
    if (nextIdx == null || nextIdx < 0 || nextIdx >= _queue.length) return;
    final nextTrack = _queue[nextIdx];
    if (nextTrack.provider == SourceProvider.local ||
        nextTrack.provider == SourceProvider.youtube) {
      return;
    }
    final existing = _preloadedSpecs[nextTrack.stableId];
    if (existing != null &&
        DateTime.now().difference(existing.fetchedAt).inMinutes < 2) {
      return;
    }
    try {
      final spec = await _resolveSpec(nextTrack);
      if (spec != null) {
        _preloadedSpecs[nextTrack.stableId] = (
          spec: spec,
          fetchedAt: DateTime.now(),
        );
      }
    } catch (_) {}
  }

  /// Resolves the concrete audio source; fetches playback specs from resolvers.
  Future<AudioSourceSpec?> _resolveSpec(Track track) async {
    if (track.provider == SourceProvider.local) {
      if (track.localUri == null) return null;
      return FileAudioSource(track.localUri!);
    }
    final resolver = _resolvers[track.provider];
    if (resolver == null) {
      debugPrint('[player] No resolver registered for ${track.provider}');
      throw const PlaybackException('No resolver registered for provider');
    }
    try {
      return await resolver(track);
    } on NotConfiguredException {
      rethrow;
    } on Object catch (e) {
      debugPrint('[player] Failed to resolve spec for ${track.stableId}: $e');
      return null;
    }
  }

  Future<void> _handleUnavailable(Track track) async {
    _consecutiveFailures++;
    if (_consecutiveFailures >= maxConsecutiveFailures) {
      _set(
        _state.copyWith(
          status: PlaybackStatus.unavailable,
          error: 'Could not play "${track.title}".',
        ),
      );
      return;
    }
    _set(
      _state.copyWith(
        status: PlaybackStatus.recoverableError,
        error: 'Skipping unavailable item "${track.title}".',
      ),
    );
    final target = _nextQueueIndex();
    if (target != null) {
      await _loadAndPlay(target, autoPlay: true, preserveError: true);
    } else {
      _set(_state.copyWith(status: PlaybackStatus.completed));
    }
  }

  Future<void> _handleLoadError(Track track, Object e) async {
    await _handleUnavailable(track);
  }

  Future<void> _pauseInternal() async {
    _flushListenProgress(completed: false);
    _set(_state.copyWith(status: PlaybackStatus.readyPaused));
    await _engine.pause();
    unawaited(_persistSoon());
  }

  void _flushListenProgress({required bool completed}) {
    final track = currentTrack;
    if (track == null || !_historyRepository.enabled) return;
    final listened = _listenedSinceLastEventMs;
    _listenedSinceLastEventMs = 0;
    if (listened <= 0 && !completed) return;
    unawaited(
      _historyRepository.recordProgress(
        stableTrackId: track.stableId,
        listenedMs: listened,
        lastPositionMs: _state.positionMs,
        completed: completed,
      ),
    );
  }

  int? _nextQueueIndex() {
    if (_queue.isEmpty) return null;
    final effective = _state.shuffle && _shuffleOrder.isNotEmpty
        ? _playOrder()
        : List<int>.generate(_queue.length, (i) => i);
    final pos = effective.indexOf(currentIndex);
    if (pos == -1) return effective.first;
    if (pos < effective.length - 1) return effective[pos + 1];
    // At the end of play order:
    if (_state.repeatMode == RepeatMode.all) {
      if (_state.shuffle) {
        _applyShuffleOrder(seed: DateTime.now().millisecondsSinceEpoch);
        return _shuffleOrder.first;
      }
      return 0;
    }
    return null;
  }

  int? _previousQueueIndex() {
    if (_queue.isEmpty) return null;
    final effective = _state.shuffle && _shuffleOrder.isNotEmpty
        ? _playOrder()
        : List<int>.generate(_queue.length, (i) => i);
    final pos = effective.indexOf(currentIndex);
    if (pos > 0) return effective[pos - 1];
    return null;
  }

  List<int> _playOrder() {
    if (_shuffleOrder.isEmpty ||
        _shuffleOrder.length != _queue.length ||
        _shuffleOrder.any((i) => i < 0 || i >= _queue.length)) {
      _applyShuffleOrder(seed: _shuffleSeed);
    }
    return _shuffleOrder;
  }

  void _applyShuffleOrder({int? seed, int? keepFirstIndex}) {
    _shuffleSeed = seed;
    final current = keepFirstIndex ?? currentIndex;
    final order = List<int>.generate(_queue.length, (i) => i);
    order.shuffle(Random(seed));
    // Keep current track first so shuffle never loses it (PLY-005).
    if (current >= 0 && current < _queue.length) {
      order
        ..remove(current)
        ..insert(0, current);
    }
    _shuffleOrder = order;
  }

  void _rebuildShuffleKeepCurrent() {
    if (_state.shuffle) {
      _applyShuffleOrder(
        seed: _shuffleSeed ?? DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  void _normalizeQueueIndex() {
    if (_queue.isEmpty) {
      _set(_state.copyWith(clearQueueIndex: true, queueLength: 0));
      return;
    }
    final i = currentIndex;
    if (i < 0) {
      _set(_state.copyWith(queueIndex: 0));
    } else if (i >= _queue.length) {
      _set(_state.copyWith(queueIndex: _queue.length - 1));
    }
  }

  Future<void> _persistSoon() async {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 800), () {
      unawaited(persistNow());
    });
  }

  QueueTrackRecord _trackToRecord(Track t) => QueueTrackRecord(
    stableTrackId: t.stableId,
    sourceType: t.provider.id,
    sourceId: t.externalId,
    title: t.title,
    artist: t.artist,
    artworkUrl: t.artworkUrl,
    durationMs: t.durationMs,
    localUri: t.localUri,
    sourceUrl: t.sourceUrl,
  );

  Track _recordToTrack(QueueTrackRecord r) => Track(
    stableId: r.stableTrackId,
    provider: SourceProviderX.fromId(r.sourceType),
    externalId: r.sourceId,
    title: r.title,
    artist: r.artist,
    artworkUrl: r.artworkUrl,
    durationMs: r.durationMs,
    localUri: r.localUri,
    sourceUrl: r.sourceUrl,
  );
}
