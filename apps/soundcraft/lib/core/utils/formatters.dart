import 'dart:async';

/// Formats a duration in milliseconds as m:ss (or h:mm:ss above one hour).
/// Handles unknown (null) and non-finite values safely (§7 case 9: no NaN).
String formatDurationMs(int? ms) {
  if (ms == null || ms < 0 || ms.isNaN) return '--:--';
  final totalSeconds = ms ~/ 1000;
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Formats seconds (e.g. Audius `duration`) the same way.
String formatDurationSec(int? seconds) => formatDurationSecImpl(
  seconds == null || seconds < 0 ? null : seconds * 1000,
);

String formatDurationSecImpl(int? ms) => formatDurationMs(ms);

/// Human-readable bytes: B, KB, MB, GB.
String formatBytes(int? bytes) {
  if (bytes == null || bytes < 0) return '--';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final str = value >= 100 || unit == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$str ${units[unit]}';
}

/// Debounces rapid calls; trailing edge fires [action] after [duration].
/// Guarantees no duplicate pending call and supports cancellation (SRCH-001).
class Debouncer {
  Debouncer(this.duration);
  final Duration duration;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();
  void dispose() => _timer?.cancel();
}

/// Fires [action] only if no call happened within [duration] (leading edge).
class Throttle {
  Throttle(this.duration);
  final Duration duration;
  DateTime? _last;

  bool get isAllowed {
    final now = DateTime.now();
    if (_last == null || now.difference(_last!) >= duration) {
      _last = now;
      return true;
    }
    return false;
  }
}

/// Sanitizes a filename for safe storage: strips separators, control chars,
/// traversal sequences and reserved names (§3.11 path traversal protection).
String sanitizeFilename(String name) {
  var s = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
  s = s.replaceAll(RegExp(r'^\.+'), '_'); // no leading dots (hidden/traversal)
  if (s.isEmpty || s == '.' || s == '..') s = '_';
  if (s.length > 180) s = s.substring(0, 180);
  const reserved = {
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'LPT1',
    'LPT2',
    'LPT3',
  };
  final stem = s.split('.').first.toUpperCase();
  if (reserved.contains(stem)) s = '_$s';
  return s;
}
