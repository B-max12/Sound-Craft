import 'dart:async';

import 'package:soundcraft/player/audio_platform.dart';

/// Controllable fake engine for coordinator/widget tests (no real audio).
class FakeAudioPlatform implements AudioPlatform {
  final _stateController = StreamController<AudioEngineState>.broadcast();
  final _tickController = StreamController<AudioEngineTick>.broadcast();
  final _completionController = StreamController<void>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  AudioEngineState state = AudioEngineState.idle;
  int _positionMs = 0;
  int? nextLoadDurationMs = 30000;
  final List<String> loadLog = [];
  final List<String> playPauseLog = [];
  int failLoadCount = 0; // fail the next N loads (sticky for N calls)
  int? loadDelayMs;
  bool disposed = false;
  double volume = 1.0;
  int seekCalls = 0;

  @override
  Stream<AudioEngineState> get stateStream => _stateController.stream;

  @override
  Stream<AudioEngineTick> get tickStream => _tickController.stream;

  @override
  Stream<void> get completionStream => _completionController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  void emitState(AudioEngineState s) {
    state = s;
    _stateController.add(s);
  }

  /// Simulates the passage of playback time.
  void emitTick(int positionMs, {int? durationMs}) {
    _positionMs = positionMs;
    _tickController.add(AudioEngineTick(
      positionMs: positionMs,
      bufferedMs: positionMs,
      durationMs: durationMs ?? nextLoadDurationMs,
    ));
  }

  void emitCompletion() => _completionController.add(null);

  void emitError(String message) => _errorController.add(message);

  @override
  Future<int?> load(AudioSourceSpec source) async {
    if (loadDelayMs != null) {
      await Future<void>.delayed(Duration(milliseconds: loadDelayMs!));
    }
    if (source is UrlAudioSource) loadLog.add('url:${source.url}');
    if (source is FileAudioSource) loadLog.add('file:${source.path}');
    if (source is BytesAudioSource) loadLog.add('bytes:${source.bytes.length}');
    if (failLoadCount > 0) {
      failLoadCount--;
      throw AudioUnsupportedException('load failed');
    }
    _positionMs = 0;
    return nextLoadDurationMs;
  }

  @override
  Future<void> play() async {
    playPauseLog.add('play');
    emitState(AudioEngineState.playing);
  }

  @override
  Future<void> pause() async {
    playPauseLog.add('pause');
    emitState(AudioEngineState.paused);
  }

  @override
  Future<void> seek(int positionMs) async {
    seekCalls++;
    _positionMs = positionMs;
  }

  double speed = 1.0;

  @override
  Future<void> setVolume(double v) async {
    if (v < 0 || v > 1) throw const AudioUnsupportedException('bad volume');
    volume = v;
  }

  @override
  Future<void> setSpeed(double s) async {
    if (s < 0.5 || s > 2.0) throw const AudioUnsupportedException('bad speed');
    speed = s;
  }

  @override
  Future<int?> get positionMs async => _positionMs;

  @override
  Future<void> dispose() async {
    disposed = true;
    await _stateController.close();
    await _tickController.close();
    await _completionController.close();
    await _errorController.close();
  }

  /// Pumps queued microtasks so serialized coordinator commands settle.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));
}
