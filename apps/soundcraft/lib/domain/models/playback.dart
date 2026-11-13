/// Playback domain enums and the authoritative player state machine (§7, §24.1).
library;

/// Repeat cycle: Off -> All -> One -> Off (PLY-006).
enum RepeatMode { off, all, one }

RepeatMode nextRepeatMode(RepeatMode mode) => switch (mode) {
  RepeatMode.off => RepeatMode.all,
  RepeatMode.all => RepeatMode.one,
  RepeatMode.one => RepeatMode.off,
};

/// Player finite state machine states (§7). Typed failures carried in
/// [PlaybackState.error].
enum PlaybackStatus {
  idle,
  resolving,
  loading,
  buffering,
  readyPaused,
  playing,
  seeking,
  completed,
  interrupted,
  recoverableError,
  unavailable,
  disposed,
}

/// Full immutable snapshot of player state exposed to UI (one source of truth).
class PlaybackState {
  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.stableTrackId,
    this.positionMs = 0,
    this.durationMs,
    this.bufferedMs,
    this.volume = 1.0,
    this.speed = 1.0,
    this.muted = false,
    this.shuffle = false,
    this.repeatMode = RepeatMode.off,
    this.error,
    this.canSeek = true,
    this.queueLength = 0,
    this.queueIndex,
    this.sleepTimerEndsAt,
  });

  final PlaybackStatus status;
  final String? stableTrackId;
  final int positionMs;
  final int? durationMs; // null => unknown length: UI guards seek/progress
  final int? bufferedMs;
  final double volume;
  final double speed;
  final bool muted;
  final bool shuffle;
  final RepeatMode repeatMode;
  final String? error;
  final bool canSeek;
  final int queueLength;
  final int? queueIndex;
  final DateTime? sleepTimerEndsAt;

  /// Clamped 0..1 progress; 0 when duration unknown (no NaN/inf — §7 case 9).
  double get progress {
    final d = durationMs;
    if (d == null || d <= 0) return 0;
    return (positionMs / d).clamp(0.0, 1.0);
  }

  bool get isBusy =>
      status == PlaybackStatus.resolving || status == PlaybackStatus.loading;

  bool get isPlaying => status == PlaybackStatus.playing;

  PlaybackState copyWith({
    PlaybackStatus? status,
    String? stableTrackId,
    int? positionMs,
    int? durationMs,
    int? bufferedMs,
    double? volume,
    double? speed,
    bool? muted,
    bool? shuffle,
    RepeatMode? repeatMode,
    String? error,
    bool? canSeek,
    int? queueLength,
    int? queueIndex,
    DateTime? sleepTimerEndsAt,
    bool clearError = false,
    bool clearSleepTimer = false,
    bool clearQueueIndex = false,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      stableTrackId: stableTrackId ?? this.stableTrackId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      bufferedMs: bufferedMs ?? this.bufferedMs,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      muted: muted ?? this.muted,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      error: clearError ? null : (error ?? this.error),
      canSeek: canSeek ?? this.canSeek,
      queueLength: queueLength ?? this.queueLength,
      queueIndex: clearQueueIndex ? null : (queueIndex ?? this.queueIndex),
      sleepTimerEndsAt: clearSleepTimer
          ? null
          : (sleepTimerEndsAt ?? this.sleepTimerEndsAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackState &&
          other.status == status &&
          other.stableTrackId == stableTrackId &&
          other.positionMs == positionMs &&
          other.durationMs == durationMs &&
          other.shuffle == shuffle &&
          other.repeatMode == repeatMode;

  @override
  int get hashCode => Object.hash(
    status,
    stableTrackId,
    positionMs,
    durationMs,
    shuffle,
    repeatMode,
  );
}
