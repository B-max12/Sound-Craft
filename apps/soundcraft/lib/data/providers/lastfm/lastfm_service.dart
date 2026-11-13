import 'package:dio/dio.dart';

class LastFmTrackRef {
  const LastFmTrackRef({
    required this.title,
    required this.artist,
    this.match,
  });

  final String title;
  final String artist;
  final double? match;
}

/// Last.fm similarity, charts & mood-tag discovery via the SoundCraft Gateway.
class LastFmService {
  LastFmService({required String? gatewayUrl, Dio? dio})
      : _gatewayUrl = gatewayUrl?.trim().replaceAll(RegExp(r'/+$'), ''),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 12),
              ),
            );

  final String? _gatewayUrl;
  final Dio _dio;

  bool get isConfigured => _gatewayUrl != null && _gatewayUrl.isNotEmpty;

  Future<List<LastFmTrackRef>> similarTracks({
    required String artist,
    required String title,
    int limit = 15,
  }) async {
    if (!isConfigured) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/lastfm/similar',
        queryParameters: {'artist': artist, 'track': title, 'limit': limit},
      );
      return _parseItems(res.data);
    } catch (_) {
      return const [];
    }
  }

  Future<List<LastFmTrackRef>> topCharts({int limit = 20}) async {
    if (!isConfigured) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/lastfm/charts',
        queryParameters: {'limit': limit},
      );
      return _parseItems(res.data);
    } catch (_) {
      return const [];
    }
  }

  Future<List<LastFmTrackRef>> tagTopTracks(String tag, {int limit = 20}) async {
    if (!isConfigured) return const [];
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/lastfm/tag',
        queryParameters: {'tag': tag, 'limit': limit},
      );
      return _parseItems(res.data);
    } catch (_) {
      return const [];
    }
  }

  List<LastFmTrackRef> _parseItems(Map<String, dynamic>? data) {
    final raw = (data?['items'] as List?) ?? const [];
    final out = <LastFmTrackRef>[];
    for (final it in raw) {
      if (it is! Map<String, dynamic>) continue;
      final title = it['title']?.toString();
      final artist = it['artist']?.toString();
      if (title == null || artist == null || title.isEmpty || artist.isEmpty) {
        continue;
      }
      final match = it['match'];
      out.add(
        LastFmTrackRef(
          title: title,
          artist: artist,
          match: match is num ? match.toDouble() : null,
        ),
      );
    }
    return out;
  }
}
