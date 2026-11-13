import 'package:dio/dio.dart';

class LyricLine {
  const LyricLine({required this.timeMs, required this.text});
  final int timeMs;
  final String text;
}

class LyricsResult {
  const LyricsResult({
    this.synced = const [],
    this.plainText,
  });

  final List<LyricLine> synced;
  final String? plainText;

  bool get isEmpty => synced.isEmpty && (plainText == null || plainText!.trim().isEmpty);
}

/// Free synced lyrics lookup via LRCLIB (https://lrclib.net). No API key needed.
class LrclibService {
  LrclibService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://lrclib.net/api',
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 10),
                headers: const {'User-Agent': 'SoundCraft/0.1 (Aur Labs)'},
              ),
            );

  final Dio _dio;
  final Map<String, LyricsResult> _cache = {};

  Future<LyricsResult> fetch({
    required String title,
    String? artist,
    int? durationMs,
  }) async {
    final key = '${artist ?? ''}|$title';
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/get',
        queryParameters: {
          'track_name': title,
          if (artist != null && artist.isNotEmpty) 'artist_name': artist,
          if (durationMs != null && durationMs > 0)
            'duration': (durationMs / 1000).round(),
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (res.statusCode == 200 && res.data != null) {
        final result = _parsePayload(res.data!);
        if (!result.isEmpty) {
          _cache[key] = result;
          return result;
        }
      }
      // Fallback to search endpoint when exact match misses.
      final searchRes = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': [?artist, title].join(' '),
        },
      );
      final list = searchRes.data ?? const [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final parsed = _parsePayload(item);
          if (!parsed.isEmpty) {
            _cache[key] = parsed;
            return parsed;
          }
        }
      }
    } catch (_) {}
    return const LyricsResult();
  }

  LyricsResult _parsePayload(Map<String, dynamic> data) {
    final syncedRaw = data['syncedLyrics']?.toString();
    final plainRaw = data['plainLyrics']?.toString();
    final synced = syncedRaw != null && syncedRaw.isNotEmpty
        ? parseLrc(syncedRaw)
        : const <LyricLine>[];
    return LyricsResult(synced: synced, plainText: plainRaw);
  }

  static List<LyricLine> parseLrc(String lrc) {
    final lines = <LyricLine>[];
    final re = RegExp(r'^\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]\s*(.*)$');
    for (final rawLine in lrc.split('\n')) {
      final m = re.firstMatch(rawLine.trim());
      if (m == null) continue;
      final min = int.tryParse(m.group(1) ?? '0') ?? 0;
      final sec = int.tryParse(m.group(2) ?? '0') ?? 0;
      final fracRaw = m.group(3) ?? '0';
      final ms = fracRaw.length == 3
          ? (int.tryParse(fracRaw) ?? 0)
          : (int.tryParse(fracRaw.padRight(2, '0')) ?? 0) * 10;
      final text = (m.group(4) ?? '').trim();
      if (text.isEmpty) continue;
      lines.add(LyricLine(timeMs: (min * 60 + sec) * 1000 + ms, text: text));
    }
    lines.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    return lines;
  }
}
