import 'dart:typed_data';

/// Platform-neutral audio engine facade. The production implementation wraps
/// just_audio; tests inject a fake. The [PlayerCoordinator] depends only on
/// this interface, so playback logic is testable on any host (R13).
///
/// Contract invariants enforced here:
///  * exactly ONE engine instance exists for the app (§24.1 invariant 1),
///  * events are coalesced into typed callbacks — no raw engine types leak.
abstract class AudioPlatform {
  /// High-level playback state transitions from the engine.
  Stream<AudioEngineState> get stateStream;

  /// Position ticks (~200ms) with buffered position; duration when known.
  Stream<AudioEngineTick> get tickStream;

  /// Emitted when the current item finished naturally.
  Stream<void> get completionStream;

  /// Emitted on unrecoverable engine errors for the current item.
  Stream<String> get errorStream;

  /// Loads [source]. Resolves with the real duration when the engine knows it
  /// (null => unknown length; UI must guard seek/progress, §7 case 9).
  Future<int?> load(AudioSourceSpec source);

  Future<void> play();
  Future<void> pause();
  Future<void> seek(int positionMs);
  Future<void> setVolume(double volume); // 0..1
  Future<void> setSpeed(double speed); // 0.5..2.0
  Future<int?> get positionMs;
  Future<void> dispose();
}

enum AudioEngineState {
  idle,
  loading,
  buffering,
  ready,
  playing,
  paused,
  completed,
}

class AudioEngineTick {
  const AudioEngineTick({
    required this.positionMs,
    this.bufferedMs,
    this.durationMs,
  });

  final int positionMs;
  final int? bufferedMs;
  final int? durationMs;
}

/// Where audio bytes come from. Signed/temporary URLs are resolved just-in-time
/// and are NEVER persisted (§6.3).
sealed class AudioSourceSpec {
  const AudioSourceSpec();
}

class UrlAudioSource extends AudioSourceSpec {
  const UrlAudioSource(this.url, {this.headers});
  final String url;
  final Map<String, String>? headers;
}

class FileAudioSource extends AudioSourceSpec {
  const FileAudioSource(this.path);
  final String path;
}

/// In-memory bytes (web-imported files; browser persistence is sandboxed).
class BytesAudioSource extends AudioSourceSpec {
  const BytesAudioSource(this.bytes, {this.mimeType});
  final Uint8List bytes;
  final String? mimeType;
}

/// Thrown by engine impls on unsupported operations on a given platform.
class AudioUnsupportedException implements Exception {
  const AudioUnsupportedException(this.message);
  final String message;
  @override
  String toString() => 'AudioUnsupportedException: $message';
}
