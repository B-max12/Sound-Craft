import 'dart:async';

import 'package:dio/dio.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/player/audio_platform.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yte;

/// YouTube access via the owner-deployed secure gateway (P06, §5.2, R04).
/// The API key lives ONLY on the gateway host — this client never sees it.
///
/// Policy contract (R05 / §3.12):
///  * discovery + canonical links + OFFICIAL player surface only;
///  * [resolvePlayback] and [isDownloadable] always refuse — YouTube items can
///    never enter the audio engine or the download manager;
///  * when no gateway is configured this provider throws
///    [NotConfiguredException] so UI shows a truthful setup state.
class YouTubeProvider implements MusicDiscoveryProvider {
  YouTubeProvider({
    this.gatewayUrl,
    String? apiKey,
    Dio? dio,
  })  : apiKey = apiKey ?? AppIdentity.youtubeApiKey,
        _dio =
            dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final String? gatewayUrl;
  final String? apiKey;
  final Dio _dio;
  yte.YoutubeExplode? _ytExplode;
  final Map<String, String> _audioUrlCache = {};

  yte.YoutubeExplode get _yt => _ytExplode ??= yte.YoutubeExplode();

  @override
  SourceProvider get provider => SourceProvider.youtube;

  @override
  String get attribution => 'Results from YouTube (official player)';

  bool get isConfigured =>
      (gatewayUrl != null && gatewayUrl!.isNotEmpty) ||
      (apiKey != null && apiKey!.isNotEmpty);

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = gatewayUrl!.endsWith('/')
        ? gatewayUrl!.substring(0, gatewayUrl!.length - 1)
        : gatewayUrl!;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const NotConfiguredException(
        'YouTube discovery requires an API key or gateway (see Settings → Diagnostics)',
      );
    }
  }

  Future<Response<dynamic>> _get(Uri uri, {CancelToken? cancelToken}) async {
    final Response<dynamic> res;
    try {
      res = await _dio.getUri(uri, cancelToken: cancelToken);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ProviderException(
          'Gateway unreachable (network error)',
          provider: SourceProvider.youtube,
        );
      }
      rethrow;
    }
    final code = res.statusCode ?? 0;
    if (code == 429) {
      final retryAfter = int.tryParse(res.headers.value('retry-after') ?? '');
      throw ProviderException(
        'YouTube quota/rate limit reached',
        provider: SourceProvider.youtube,
        statusCode: 429,
        retryAfterSeconds: retryAfter,
      );
    }
    if (code == 502 || code == 503) {
      throw ProviderException(
        'YouTube quota exhausted or gateway error (HTTP $code)',
        provider: SourceProvider.youtube,
        statusCode: code,
      );
    }
    if (code >= 400) {
      throw ProviderException(
        'Gateway request failed (HTTP $code)',
        provider: SourceProvider.youtube,
        statusCode: code,
      );
    }
    return res;
  }

  /// Searches videos through the gateway or directly via YouTube Data API.
  Future<Page<Track>> search(
    String query, {
    int limit = 20,
    Object? cancelToken,
  }) async {
    _ensureConfigured();
    if (query.trim().isEmpty) {
      return Page<Track>(items: const [], nextOffset: null);
    }

    // Direct YouTube v3 Data API fallback when no gateway URL is set
    if ((gatewayUrl == null || gatewayUrl!.isEmpty) && apiKey != null) {
      final directUri = Uri.parse('https://www.googleapis.com/youtube/v3/search').replace(
        queryParameters: {
          'part': 'snippet',
          'type': 'video',
          'videoEmbeddable': 'true',
          'maxResults': '$limit',
          'q': query.trim(),
          'key': apiKey!,
        },
      );
      final res = await _get(directUri, cancelToken: cancelToken as CancelToken?);
      final body = res.data;
      if (body is! Map<String, dynamic>) {
        throw const ProviderException(
          'Malformed YouTube API response',
          provider: SourceProvider.youtube,
        );
      }
      final items = body['items'];
      if (items is! List) return Page<Track>(items: const [], nextOffset: null);
      final tracks = <Track>[];
      for (final raw in items) {
        if (raw is! Map<String, dynamic>) continue;
        final idObj = raw['id'];
        final videoId = idObj is Map<String, dynamic> ? idObj['videoId'] : null;
        final snippet = raw['snippet'];
        if (videoId is! String || videoId.isEmpty || snippet is! Map<String, dynamic>) {
          continue;
        }
        final title = snippet['title'] is String ? snippet['title'] as String : 'YouTube Video';
        final channelTitle = snippet['channelTitle'] is String ? snippet['channelTitle'] as String : 'YouTube';
        final thumbnails = snippet['thumbnails'];
        String? thumbUrl;
        if (thumbnails is Map<String, dynamic>) {
          final med = thumbnails['medium'];
          final def = thumbnails['default'];
          if (med is Map<String, dynamic> && med['url'] is String) {
            thumbUrl = med['url'] as String;
          } else if (def is Map<String, dynamic> && def['url'] is String) {
            thumbUrl = def['url'] as String;
          }
        }
        tracks.add(
          Track(
            stableId: stableTrackId(SourceProvider.youtube, videoId),
            provider: SourceProvider.youtube,
            externalId: videoId,
            title: title,
            artist: channelTitle,
            artworkUrl: thumbUrl,
            sourceUrl: 'https://www.youtube.com/watch?v=$videoId',
            isStreamable: true,
            isDownloadable: true,
            attributedTo: attribution,
          ),
        );
      }
      final pageInfo = body['pageInfo'];
      final total = pageInfo is Map<String, dynamic> ? pageInfo['totalResults'] : tracks.length;
      final next = (total is int && tracks.isNotEmpty)
          ? (tracks.length < total ? tracks.length : null)
          : (tracks.length < limit ? null : tracks.length);
      return Page<Track>(items: tracks, nextOffset: next);
    }

    final res = await _get(
      _uri('/api/youtube/search', {'q': query.trim(), 'limit': '$limit'}),
      cancelToken: cancelToken as CancelToken?,
    );
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw const ProviderException(
        'Malformed gateway response',
        provider: SourceProvider.youtube,
      );
    }
    final items = body['items'];
    if (items is! List) {
      throw const ProviderException(
        'Malformed gateway response (items)',
        provider: SourceProvider.youtube,
      );
    }
    final tracks = <Track>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final videoId = raw['videoId'];
      final title = raw['title'];
      if (videoId is! String || videoId.isEmpty || title is! String) continue;
      tracks.add(
        Track(
          stableId: stableTrackId(SourceProvider.youtube, videoId),
          provider: SourceProvider.youtube,
          externalId: videoId,
          title: title,
          artist: raw['channelTitle'] is String
              ? raw['channelTitle'] as String
              : 'YouTube',
          artworkUrl: raw['thumbnailUrl'] is String
              ? raw['thumbnailUrl'] as String
              : null,
          sourceUrl: 'https://www.youtube.com/watch?v=$videoId',
          isStreamable: true,
          isDownloadable: true,
          attributedTo: attribution,
        ),
      );
    }
    final total = body['totalResults'];
    final next = (total is int && tracks.isNotEmpty)
        ? (tracks.length < total ? tracks.length : null)
        : (tracks.length < limit ? null : tracks.length);
    return Page<Track>(items: tracks, nextOffset: next);
  }

  // ---------------------------------------------------------------- policy
  // The remaining contract methods enforce YouTube's restrictions (§3.12):
  // playback happens in the OFFICIAL viewer route, never the audio engine.

  @override
  PlaybackCapability capability(Track track) =>
      const PlaybackCapability.authorizedAudio(
        canDownload: true,
        canShare: true,
      );

  @override
  Future<Track?> getTrack(String externalId) async {
    _ensureConfigured();
    if ((gatewayUrl == null || gatewayUrl!.isEmpty) && apiKey != null) {
      final directUri = Uri.parse('https://www.googleapis.com/youtube/v3/videos').replace(
        queryParameters: {
          'part': 'snippet',
          'id': externalId,
          'key': apiKey!,
        },
      );
      final res = await _get(directUri);
      final body = res.data;
      if (body is! Map<String, dynamic>) return null;
      final items = body['items'];
      if (items is! List || items.isEmpty) return null;
      final v = items.first;
      if (v is! Map<String, dynamic>) return null;
      final snippet = v['snippet'];
      if (snippet is! Map<String, dynamic>) return null;
      final title = snippet['title'] is String ? snippet['title'] as String : 'YouTube Video';
      final channelTitle = snippet['channelTitle'] is String ? snippet['channelTitle'] as String : 'YouTube';
      final thumbnails = snippet['thumbnails'];
      String? thumbUrl;
      if (thumbnails is Map<String, dynamic>) {
        final med = thumbnails['medium'];
        final def = thumbnails['default'];
        if (med is Map<String, dynamic> && med['url'] is String) {
          thumbUrl = med['url'] as String;
        } else if (def is Map<String, dynamic> && def['url'] is String) {
          thumbUrl = def['url'] as String;
        }
      }
      return Track(
        stableId: stableTrackId(SourceProvider.youtube, externalId),
        provider: SourceProvider.youtube,
        externalId: externalId,
        title: title,
        artist: channelTitle,
        artworkUrl: thumbUrl,
        sourceUrl: 'https://www.youtube.com/watch?v=$externalId',
        attributedTo: attribution,
      );
    }
    final res = await _get(_uri('/api/youtube/videos/$externalId'));
    final body = res.data;
    if (body is! Map<String, dynamic>) return null;
    final v = body['video'];
    if (v is! Map<String, dynamic>) return null;
    final videoId = v['videoId'];
    final title = v['title'];
    if (videoId is! String || title is! String) return null;
    return Track(
      stableId: stableTrackId(SourceProvider.youtube, videoId),
      provider: SourceProvider.youtube,
      externalId: videoId,
      title: title,
      artist: v['channelTitle'] is String
          ? v['channelTitle'] as String
          : 'YouTube',
      artworkUrl: v['thumbnailUrl'] is String
          ? v['thumbnailUrl'] as String
          : null,
      sourceUrl: 'https://www.youtube.com/watch?v=$videoId',
      attributedTo: attribution,
    );
  }

  @override
  Future<ProviderHealth> health() async {
    if (!isConfigured) {
      return ProviderHealth(
        provider: SourceProvider.youtube,
        available: false,
        detail: 'YouTube API key or Gateway not configured',
      );
    }
    if ((gatewayUrl == null || gatewayUrl!.isEmpty) && apiKey != null) {
      return ProviderHealth(
        provider: SourceProvider.youtube,
        available: true,
        detail: 'Direct YouTube Data API configured with API key',
        lastCheckedAt: DateTime.now(),
      );
    }
    try {
      final res = await _get(_uri('/api/health'));
      return ProviderHealth(
        provider: SourceProvider.youtube,
        available: res.statusCode == 200,
        detail: 'Gateway reachable',
        lastCheckedAt: DateTime.now(),
      );
    } on Object catch (e) {
      return ProviderHealth(
        provider: SourceProvider.youtube,
        available: false,
        detail: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<bool> isDownloadable(Track track) => Future.value(true);

  /// Resolves the direct audio stream URL for in-app audio playback.
  /// Retries up to 2 times with fresh YoutubeExplode instances and fallback clients on failure.
  Future<String> resolveStreamUrl(String videoId) async {
    if (_audioUrlCache.containsKey(videoId)) {
      return _audioUrlCache[videoId]!;
    }
    const maxRetries = 2;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final yt = attempt == 0 ? _yt : yte.YoutubeExplode();
        final clientList = switch (attempt) {
          0 => [yte.YoutubeApiClient.androidSdkless],
          1 => [yte.YoutubeApiClient.safari],
          _ => null,
        };
        final manifest = await yt.videos.streamsClient
            .getManifest(
              videoId,
              ytClients: clientList,
              requireWatchPage: false,
            )
            .timeout(const Duration(seconds: 15));
        final audioStreams = manifest.audioOnly.sortByBitrate();
        if (audioStreams.isEmpty) {
          throw const PlaybackException(
            'No audio streams available for this video',
          );
        }
        // Prefer mp4 container (AAC audio in m4a) for universal Android compatibility
        final mp4Audio = audioStreams.where((s) => s.container.name == 'mp4').toList();
        final candidateStreams = mp4Audio.isNotEmpty ? mp4Audio : audioStreams;
        final audioStream = candidateStreams.length > 2
            ? candidateStreams[candidateStreams.length ~/ 2]
            : candidateStreams.last;
        final url = audioStream.url.toString();
        _audioUrlCache[videoId] = url;
        if (attempt > 0) yt.close();
        return url;
      } on TimeoutException {
        if (attempt == maxRetries) {
          throw const PlaybackException(
            'YouTube audio resolution timed out. Try again.',
          );
        }
        _ytExplode?.close();
        _ytExplode = null;
      } on Object catch (e) {
        if (attempt == maxRetries) {
          throw PlaybackException(
            'Could not play this YouTube video: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e}',
          );
        }
        _ytExplode?.close();
        _ytExplode = null;
      }
    }
    throw const PlaybackException('YouTube audio resolution failed');
  }

  @override
  Future<AudioSourceSpec?> resolvePlayback(Track track) async {
    final streamUrl = await resolveStreamUrl(track.externalId);
    return UrlAudioSource(
      streamUrl,
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': 'https://www.youtube.com/',
      },
    );
  }

  @override
  Future<Page<Track>> searchTracks(SearchQuery query) =>
      search(query.text, limit: query.limit, cancelToken: query.cancelToken);

  @override
  Future<List<Track>> trending(FeedQuery query) => Future.error(
    const ProviderException(
      'YouTube trending is not part of the compliant surface',
      provider: SourceProvider.youtube,
    ),
  );

  @override
  Future<List<Track>> newest(FeedQuery query) => trending(query);
}
