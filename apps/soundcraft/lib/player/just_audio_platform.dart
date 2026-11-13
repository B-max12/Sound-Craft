import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

import 'audio_platform.dart';

/// Production [AudioPlatform] backed by just_audio (contract §5.1).
/// One instance per app; created in bootstrap and injected via Riverpod.
class JustAudioPlatform implements AudioPlatform {
  JustAudioPlatform._(this._player) {
    _playerStateSub = _player.playerStateStream.listen(_onPlayerState);
    _positionSub = _player.positionStream.listen(_onPosition);
    _sequenceSub = _player.playbackEventStream.listen(
      _onPlaybackEvent,
      onError: (Object error, StackTrace stack) {
        if (!_errorController.isClosed) {
          _errorController.add(error.toString());
        }
      },
    );
    _playerErrorSub = _player.errorStream.listen((e) {
      if (!_errorController.isClosed) {
        _errorController.add(e.message ?? 'Playback error (${e.code})');
      }
    });
  }

  final AudioPlayer _player;
  StreamSubscription<void>? _playerStateSub;
  StreamSubscription<void>? _positionSub;
  StreamSubscription<void>? _sequenceSub;
  StreamSubscription<void>? _playerErrorSub;

  final _stateController = StreamController<AudioEngineState>.broadcast();
  final _tickController = StreamController<AudioEngineTick>.broadcast();
  final _completionController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  @override
  Stream<AudioEngineState> get stateStream => _stateController.stream;

  @override
  Stream<AudioEngineTick> get tickStream => _tickController.stream;

  @override
  Stream<void> get completionStream => _completionController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  factory JustAudioPlatform.create() {
    final player = AudioPlayer();
    return JustAudioPlatform._(player);
  }

  AudioPlayer get raw => _player;

  bool _wasCompleted = false;

  void _onPlayerState(PlayerState s) {
    switch (s.processingState) {
      case ProcessingState.idle:
        _stateController.add(AudioEngineState.idle);
      case ProcessingState.loading:
        _stateController.add(AudioEngineState.loading);
      case ProcessingState.buffering:
        _stateController.add(
          s.playing ? AudioEngineState.buffering : AudioEngineState.loading,
        );
      case ProcessingState.ready:
        if (s.playing) {
          _stateController.add(AudioEngineState.playing);
        } else {
          _stateController.add(AudioEngineState.ready);
        }
      case ProcessingState.completed:
        if (!_wasCompleted) {
          _wasCompleted = true;
          _stateController.add(AudioEngineState.completed);
          _completionController.add(null);
        }
    }
  }

  void _onPosition(Duration position) {
    _tickController.add(
      AudioEngineTick(
        positionMs: position.inMilliseconds,
        bufferedMs: _player.bufferedPosition.inMilliseconds,
        durationMs: _player.duration?.inMilliseconds,
      ),
    );
  }

  void _onPlaybackEvent(PlaybackEvent e) {
    // Duration may arrive before ready; forward ticks with duration info.
    if (e.duration != null) {
      _tickController.add(
        AudioEngineTick(
          positionMs: _player.position.inMilliseconds,
          bufferedMs: _player.bufferedPosition.inMilliseconds,
          durationMs: e.duration!.inMilliseconds,
        ),
      );
    }
  }

  @override
  Future<int?> load(AudioSourceSpec source) async {
    _wasCompleted = false;
    try {
      await _player.stop();
    } catch (_) {}
    final AudioSource provider = switch (source) {
      UrlAudioSource(:final url, :final headers) => AudioSource.uri(
        Uri.parse(url),
        headers: headers ?? const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
      FileAudioSource(:final path) => AudioSource.uri(Uri.file(path)),
      BytesAudioSource(:final bytes, :final mimeType) => _BytesSource(
        bytes,
        mimeType,
      ),
    };
    final duration = await _player.setAudioSource(provider);
    return duration?.inMilliseconds;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(int positionMs) =>
      _player.seek(Duration(milliseconds: positionMs));

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0.0, 1.0));

  @override
  Future<void> setSpeed(double speed) =>
      _player.setSpeed(speed.clamp(0.5, 2.0));

  @override
  Future<int?> get positionMs async => _player.position.inMilliseconds;

  @override
  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _sequenceSub?.cancel();
    await _playerErrorSub?.cancel();
    await _stateController.close();
    await _tickController.close();
    await _completionController.close();
    await _errorController.close();
    await _player.dispose();
  }
}

/// StreamAudioSource for in-memory bytes (web imports; browser storage).
// ignore_for_file: experimental_member_use
class _BytesSource extends StreamAudioSource {
  _BytesSource(this.bytes, this.mimeType);
  final Uint8List bytes;
  final String? mimeType;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      contentType: mimeType ?? 'audio/mpeg',
      contentLength: (end - start).clamp(0, bytes.length - start),
      sourceLength: bytes.length,
      offset: start,
      stream: Stream.value(
        bytes.sublist(start, end.clamp(start, bytes.length)),
      ),
    );
  }
}
