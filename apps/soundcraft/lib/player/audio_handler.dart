import 'package:audio_service/audio_service.dart' as audsrv;
import 'package:soundcraft/domain/models/playback.dart' as domain;
import 'package:soundcraft/domain/models/track.dart';

import 'player_coordinator.dart';

/// audio_service integration (§5.1): exposes the coordinator to OS media
/// controls (lock screen / notification / media keys) on supported native
/// platforms. One handler for the whole app (§24.1 invariant 1). YouTube items
/// must never appear here (R05) — guarded at enqueue time and here.
class SoundCraftAudioHandler extends audsrv.BaseAudioHandler
    with audsrv.QueueHandler, audsrv.SeekHandler {
  SoundCraftAudioHandler(this._player);

  final PlayerCoordinator _player;

  /// Called by bootstrap after AudioService.init.
  void attach() {
    var lastQueueSignature = '';
    _player.stateStream.listen((state) {
      final track = _player.currentTrack;
      playbackState.add(_audioServiceState(state, playing: state.isPlaying));
      if (track != null) {
        final effectiveDurationMs = state.durationMs ?? track.durationMs;
        final currentItem = mediaItem.value;
        if (currentItem?.id != state.stableTrackId ||
            (effectiveDurationMs != null &&
                currentItem?.duration?.inMilliseconds != effectiveDurationMs)) {
          mediaItem.add(
            _mapMediaItem(track, durationMsOverride: effectiveDurationMs),
          );
        }
      }
      final q = _player.queue;
      final sig = q.map((t) => t.stableId).join('|');
      if (sig != lastQueueSignature) {
        lastQueueSignature = sig;
        queue.add(q.map((t) => _mapMediaItem(t)).toList(growable: false));
      }
    });
  }

  audsrv.PlaybackState _audioServiceState(
    domain.PlaybackState s, {
    required bool playing,
  }) {
    return audsrv.PlaybackState(
      controls: [
        audsrv.MediaControl.skipToPrevious,
        if (playing) audsrv.MediaControl.pause else audsrv.MediaControl.play,
        audsrv.MediaControl.skipToNext,
        audsrv.MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      systemActions: const {
        audsrv.MediaAction.seek,
        audsrv.MediaAction.seekForward,
        audsrv.MediaAction.seekBackward,
      },
      processingState: switch (s.status) {
        domain.PlaybackStatus.buffering ||
        domain.PlaybackStatus.loading ||
        domain.PlaybackStatus.resolving =>
          audsrv.AudioProcessingState.buffering,
        domain.PlaybackStatus.completed =>
          audsrv.AudioProcessingState.completed,
        domain.PlaybackStatus.unavailable ||
        domain.PlaybackStatus.recoverableError =>
          audsrv.AudioProcessingState.error,
        _ => audsrv.AudioProcessingState.ready,
      },
      playing: playing,
      updatePosition: Duration(milliseconds: s.positionMs),
      bufferedPosition: Duration(milliseconds: s.bufferedMs ?? s.positionMs),
      speed: s.speed,
      queueIndex: s.queueIndex,
    );
  }

  audsrv.MediaItem _mapMediaItem(Track t, {int? durationMsOverride}) {
    final durMs = durationMsOverride ?? t.durationMs;
    return audsrv.MediaItem(
      id: t.stableId,
      title: t.title,
      artist: t.artist,
      album: t.album,
      artUri: t.artworkUrl != null ? Uri.tryParse(t.artworkUrl!) : null,
      duration: durMs != null ? Duration(milliseconds: durMs) : null,
    );
  }

  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> skipToNext() async => _player.next();

  @override
  Future<void> skipToPrevious() async => _player.previous();

  @override
  Future<void> skipToQueueItem(int index) async {
    final q = _player.queue;
    if (index >= 0 && index < q.length) {
      await _player.playTracks(q, startIndex: index);
    }
  }

  @override
  Future<void> seek(Duration position) async =>
      _player.seekTo(position.inMilliseconds);

  @override
  Future<void> stop() async {
    await _player.stopAndDismiss();
    await super.stop();
  }
}
