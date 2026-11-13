import 'dart:convert';
import 'dart:math';

import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/repositories/settings_repository.dart';
import 'package:dio/dio.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/player/audio_platform.dart';

import 'audius_models.dart';

/// Official Audius REST client (docs: https://docs.audius.co — verified
/// 2026-11-03). Read endpoints are keyless; `app_name` is included for
/// attribution and future developer-plan compliance.
class AudiusApi {
  AudiusApi({
    Dio? dio,
    this.hosts = const [
      'https://discoveryprovider.audius.co',
      'https://discoveryprovider2.audius.co',
      'https://discoveryprovider3.audius.co',
      'https://dn1.monophonic.digital',
      'https://audius-discovery-1.altego.net',
    ],
    this.apiKey = AppIdentity.audiusApiKey,
    this.bearerToken = AppIdentity.audiusBearerToken,
  }) : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              validateStatus: (s) => s != null && s < 500 || s == 503,
            ),
          ) {
    _dio.options.headers['User-Agent'] = 'SoundCraft/0.1 (An Aur Labs Product)';
  }

  /// Discovery hosts; the first reachable one is selected (verified live).
  final List<String> hosts;
  final String? apiKey;
  final String? bearerToken;
  final Dio _dio;
  String? _selectedHost;

  static const String appName = 'SoundCraft';

  String get host => _selectedHost ?? hosts.first;

  /// Selects a reachable discovery host; falls back to first entry.
  Future<String> selectHost() async {
    if (_selectedHost != null) return _selectedHost!;

    // Step 1: Try the Audius discovery API to get live hosts
    try {
      final res = await _dio.getUri<dynamic>(
        Uri.parse('https://api.audius.co'),
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          // No auth headers for the discovery endpoint
          headers: {
            'User-Agent': 'SoundCraft/0.1 (An Aur Labs Product)',
          },
        ),
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data['data'];
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          if (first is String && first.startsWith('http')) {
            _selectedHost = first;
            return _selectedHost!;
          }
        }
      }
    } on Object {
      // Discovery API unavailable — try hardcoded hosts
    }

    // Step 2: Try each hardcoded discovery host
    for (final candidate in hosts) {
      try {
        final res = await _dio.getUri<dynamic>(
          Uri.parse('$candidate/v1/tracks/trending?limit=1&app_name=$appName'),
          options: Options(
            responseType: ResponseType.json,
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        if (res.statusCode == 200) {
          _selectedHost = candidate;
          return _selectedHost!;
        }
      } on Object {
        continue;
      }
    }
    // Fallback safely to primary host instead of hard throwing
    _selectedHost = hosts.first;
    return _selectedHost!;
  }

  Uri _uri(String path, Map<String, dynamic> params) {
    final q = <String, String>{'app_name': appName};
    params.forEach((k, v) {
      if (v != null) q[k] = v.toString();
    });
    return Uri.parse('$host$path').replace(queryParameters: q);
  }

  /// GET with error mapping + Retry-After honouring (SYS-002).
  Future<Response<dynamic>> _get(Uri uri, {CancelToken? cancelToken}) async {
    final Response<dynamic> res;
    try {
      res = await _dio.getUri(uri, cancelToken: cancelToken);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw ProviderException(
          'Request cancelled',
          provider: SourceProvider.audius,
        );
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const ProviderException(
          'Audius is unreachable (network error)',
          provider: SourceProvider.audius,
        );
      }
      rethrow;
    }
    final code = res.statusCode ?? 0;
    if (code == 429) {
      final retryAfter = int.tryParse(res.headers.value('retry-after') ?? '');
      throw ProviderException(
        'Audius rate limit reached',
        provider: SourceProvider.audius,
        statusCode: 429,
        retryAfterSeconds: retryAfter,
      );
    }
    if (code >= 400) {
      throw ProviderException(
        'Audius request failed (HTTP $code)',
        provider: SourceProvider.audius,
        statusCode: code,
      );
    }
    return res;
  }

  Future<List<AudiusTrackDto>> trending({
    int limit = 20,
    int offset = 0,
    String? genre,
    String? time,
    CancelToken? cancelToken,
  }) async {
    await selectHost();
    final res = await _get(
      _uri('/v1/tracks/trending', {
        'limit': limit,
        'offset': offset,
        'genre': genre,
        'time': time,
      }),
      cancelToken: cancelToken,
    );
    return parseAudiusList(res.data)
        .map(_safeParse)
        .whereType<AudiusTrackDto>()
        .toList();
  }

  Future<List<AudiusTrackDto>> underground({
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    await selectHost();
    final res = await _get(
      _uri('/v1/tracks/trending/underground', {'limit': limit}),
      cancelToken: cancelToken,
    );
    return parseAudiusList(res.data)
        .map(_safeParse)
        .whereType<AudiusTrackDto>()
        .toList();
  }

  Future<List<AudiusTrackDto>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    await selectHost();
    final res = await _get(
      _uri('/v1/tracks/search', {
        'query': query,
        'limit': limit,
        'offset': offset,
      }),
      cancelToken: cancelToken,
    );
    return parseAudiusList(res.data)
        .map(_safeParse)
        .whereType<AudiusTrackDto>()
        .toList();
  }

  Future<AudiusTrackDto?> getTrack(
    String id, {
    CancelToken? cancelToken,
  }) async {
    await selectHost();
    final res = await _get(
      _uri('/v1/tracks/$id', {}),
      cancelToken: cancelToken,
    );
    final data = res.data is Map<String, dynamic>
        ? (res.data as Map<String, dynamic>)['data']
        : null;
    if (data is! Map<String, dynamic>) return null;
    return _safeParse(data);
  }

  Future<List<AudiusTrackDto>> tracksByArtist(
    String artistHandleOrId, {
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    await selectHost();
    final res = await _get(
      _uri('/v1/users/$artistHandleOrId/tracks', {'limit': limit}),
      cancelToken: cancelToken,
    );
    return parseAudiusList(res.data)
        .map(_safeParse)
        .whereType<AudiusTrackDto>()
        .toList();
  }

  /// Health probe with latency (diagnostics §3.14).
  Future<ProviderHealth> health() async {
    final sw = Stopwatch()..start();
    try {
      await selectHost();
      final res = await _get(_uri('/v1/tracks/trending', {'limit': 1}));
      sw.stop();
      return ProviderHealth(
        provider: SourceProvider.audius,
        available: res.statusCode == 200,
        latencyMs: sw.elapsedMilliseconds,
        lastCheckedAt: DateTime.now(),
      );
    } on Object catch (e) {
      sw.stop();
      return ProviderHealth(
        provider: SourceProvider.audius,
        available: false,
        detail: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  /// Authorized download URL for tracks the provider marks downloadable
  /// (/v1/tracks/{id}/download). Callers MUST have passed RightsGate first.
  Future<String> resolveDownloadUrl(String trackId) async {
    await selectHost();
    final uri = _uri('/v1/tracks/$trackId/download', {});
    final res = await _dio.getUri(
      uri,
      options: Options(
        followRedirects: false,
        validateStatus: (s) => s != null && s < 400,
      ),
    );
    final code = res.statusCode ?? 0;
    if (code == 302 || code == 301 || code == 307) {
      final location = res.headers.value('location');
      if (location != null && location.isNotEmpty) return location;
    }
    if (code == 200) return uri.toString();
    throw ProviderException(
      'Audius download unavailable (HTTP $code)',
      provider: SourceProvider.audius,
      statusCode: code,
    );
  }

  /// Stream redirect endpoint (GET /v1/tracks/{id}/stream). Returns the final
  /// resolved CDN URL WITHOUT downloading content — resolved per play, never
  /// persisted (§6.3).
  Future<String> resolveStreamUrl(String trackId) async {
    await selectHost();
    final streamUri = _uri('/v1/tracks/$trackId/stream', {});
    final res = await _dio.getUri(
      streamUri,
      options: Options(
        followRedirects: false,
        validateStatus: (s) => s != null && s < 400,
      ),
    );
    final code = res.statusCode ?? 0;
    if (code == 302 || code == 301 || code == 307) {
      final location = res.headers.value('location');
      if (location != null && location.isNotEmpty) return location;
    }
    // Some deployments stream directly (200) — then the endpoint itself is the URL.
    if (code == 200) return streamUri.toString();
    throw ProviderException(
      'Audius stream unavailable (HTTP $code)',
      provider: SourceProvider.audius,
      statusCode: code,
    );
  }

  AudiusTrackDto? _safeParse(Map<String, dynamic> json) {
    try {
      return AudiusTrackDto.fromJson(json);
    } on FormatException {
      return null;
    }
  }
}

/// Audius adapter implementing the provider contract (P05 gate).
class AudiusProvider implements MusicDiscoveryProvider {
  AudiusProvider(
    this._api, {
    this.cache,
    this.cacheTtl = const Duration(minutes: 5),
  });

  final AudiusApi _api;
  final ProviderCacheRepository? cache;
  final Duration cacheTtl;

  @override
  SourceProvider get provider => SourceProvider.audius;

  @override
  String get attribution => 'Trending on Audius';

  @override
  PlaybackCapability capability(Track track) {
    // Streamability never implies download rights; the provider-declared
    // is_downloadable flag is re-checked by RightsGate at enqueue time (R05).
    if (!track.isStreamable) {
      return PlaybackCapability.unavailable(
          'This track is not streamable on Audius.');
    }
    return PlaybackCapability.authorizedAudio(
      canDownload: track.isDownloadable,
      canShare: track.sourceUrl != null,
    );
  }

  @override
  Future<Track?> getTrack(String externalId) async {
    final dto = await _api.getTrack(externalId);
    return dto == null ? null : _toTrack(dto);
  }

  @override
  Future<ProviderHealth> health() => _api.health();

  @override
  Future<bool> isDownloadable(Track track) =>
      Future.value(track.isDownloadable);

  @override
  Future<AudioSourceSpec?> resolvePlayback(Track track) async {
    final url = await _api.resolveStreamUrl(track.externalId);
    return UrlAudioSource(url);
  }

  /// Pass-through to the API for the download manager (rights already checked).
  Future<String> resolveDownloadUrl(String externalId) =>
      _api.resolveDownloadUrl(externalId);

  @override
  Future<Page<Track>> searchTracks(SearchQuery query) async {
    if (query.text.trim().isEmpty) {
      return Page<Track>(items: const [], nextOffset: null);
    }
    final dtos = await _api.searchTracks(
      query.text.trim(),
      limit: query.limit,
      offset: query.offset,
      cancelToken: query.cancelToken as CancelToken?,
    );
    return Page<Track>(
      items: dtos.map(_toTrack).toList(),
      nextOffset: dtos.length < query.limit ? null : query.offset + dtos.length,
    );
  }

  @override
  Future<List<Track>> trending(FeedQuery query) async {
    final key = audiusCacheKey(
      'trending:${query.timeRange ?? 'week'}',
      query: query.genre,
      page: 0,
    );
    final cached = await _readCache(key);
    if (cached != null) return cached;
    final dtos = await _api.trending(
      limit: query.limit,
      genre: query.genre,
      time: query.timeRange,
      cancelToken: query.cancelToken as CancelToken?,
    );
    final tracks = dtos.map(_toTrack).toList();
    await _writeCache(key, tracks);
    return tracks;
  }

  @override
  Future<List<Track>> newest(FeedQuery query) async {
    final key = audiusCacheKey('newest', page: 0);
    final cached = await _readCache(key);
    if (cached != null) return cached;
    final dtos = await _api.underground(
      limit: query.limit,
      cancelToken: query.cancelToken as CancelToken?,
    );
    final tracks = dtos.map(_toTrack).toList();
    await _writeCache(key, tracks);
    return tracks;
  }

  /// Test seam (visibleForTesting): maps a DTO exactly as production does.
  // ignore: avoid_positional_boolean_parameters
  Track mapDtoToTrack(AudiusTrackDto dto) => _toTrack(dto);

  Track _toTrack(AudiusTrackDto dto) {
    return Track(
      stableId: stableTrackId(SourceProvider.audius, dto.id),
      provider: SourceProvider.audius,
      externalId: dto.id,
      title: dto.title,
      artist: dto.artistName,
      artistId: dto.artistId,
      artworkUrl: dto.artwork480 ?? dto.artwork150 ?? dto.artwork1000,
      durationMs: dto.durationSec != null ? dto.durationSec! * 1000 : null,
      genre: dto.genre,
      releaseDate: dto.releaseDate,
      sourceUrl: dto.permalink != null ? '${_api.host}${dto.permalink}' : null,
      isDownloadable: dto.isDownloadable,
      isStreamable: dto.isStreamable && dto.isAvailable && !dto.isDelete,
      playCount: dto.playCount,
      attributedTo: 'Audius',
    );
  }

  Future<List<Track>?> _readCache(String key) async {
    final repo = cache;
    if (repo == null) return null;
    try {
      final json = await repo.getJson(key);
      if (json == null) return null;
      // Cache stores minimal fields re-parsed through DTO for consistency.
      final list = (jsonDecodeList(json))
          .map(_safeDtoFromCache)
          .whereType<AudiusTrackDto>()
          .map(_toTrack)
          .toList();
      return list;
    } on Object {
      return null; // corrupted cache entry -> refetch
    }
  }

  Future<void> _writeCache(String key, List<Track> tracks) async {
    final repo = cache;
    if (repo == null) return;
    try {
      await repo.putJson(
        key,
        encodeTracks(tracks),
        ttlSeconds: cacheTtl.inSeconds,
      );
    } on Object {
      // Cache write failures must never break discovery.
    }
  }

  AudiusTrackDto? _safeDtoFromCache(Map<String, dynamic> json) {
    try {
      return AudiusTrackDto.fromJson(json);
    } on FormatException {
      return null;
    }
  }
}

/// Minimal encode/decode for cached tracks (metadata only, no URLs).
String encodeTracks(List<Track> tracks) {
  return jsonEncode(
    tracks
        .map(
          (t) => {
            'id': t.externalId,
            'title': t.title,
            'user': {'name': t.artist, 'id': t.artistId},
            'duration': t.durationMs == null ? null : t.durationMs! ~/ 1000,
            'is_downloadable': t.isDownloadable,
            'is_streamable': t.isStreamable,
            'is_available': true,
            'is_delete': false,
            'artwork': t.artworkUrl == null
                ? null
                : {
                    '150x150': t.artworkUrl,
                    '480x480': t.artworkUrl,
                    '1000x1000': t.artworkUrl,
                  },
            'genre': t.genre,
            'permalink': null,
          },
        )
        .toList(),
  );
}

List<Map<String, dynamic>> jsonDecodeList(String s) {
  final decoded = jsonDecode(s) as List<dynamic>;
  return decoded.whereType<Map<String, dynamic>>().toList();
}

/// Deterministic backoff used by retry wrappers (SYS-002).
Duration backoffFor(int attempt, {int baseSeconds = 1}) {
  final jitter = attempt <= 0 ? 0 : Random(attempt).nextInt(500);
  return Duration(
    milliseconds: baseSeconds * 1000 * (1 << min(attempt, 4)) + jitter,
  );
}
