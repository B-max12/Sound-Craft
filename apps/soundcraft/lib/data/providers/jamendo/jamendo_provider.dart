import 'package:dio/dio.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';
import 'package:soundcraft/player/audio_platform.dart';

/// Jamendo Creative Commons music provider via the SoundCraft Discovery Gateway.
/// Keeps the Jamendo client_id server-side (zero keys in APK).
class JamendoProvider implements MusicDiscoveryProvider {
  JamendoProvider({required String? gatewayUrl, Dio? dio})
      : _gatewayUrl = gatewayUrl?.trim().replaceAll(RegExp(r'/+$'), ''),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final String? _gatewayUrl;
  final Dio _dio;
  final RightsGate _gate = const RightsGate();
  final Map<String, ({String streamUrl, String? downloadUrl})> _urlCache = {};

  bool get isConfigured => _gatewayUrl != null && _gatewayUrl.isNotEmpty;

  @override
  SourceProvider get provider => SourceProvider.jamendo;

  @override
  String get attribution => 'Creative Commons music via Jamendo';

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const NotConfiguredException(
        'Jamendo requires the SoundCraft gateway URL in Settings.',
      );
    }
  }

  @override
  Future<ProviderHealth> health() async {
    if (!isConfigured) {
      return ProviderHealth(
        provider: SourceProvider.jamendo,
        available: false,
        detail: 'Gateway URL not configured',
        lastCheckedAt: DateTime.now(),
      );
    }
    final sw = Stopwatch()..start();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/health',
      );
      sw.stop();
      final configured = res.data?['jamendoConfigured'] == true;
      return ProviderHealth(
        provider: SourceProvider.jamendo,
        available: configured,
        latencyMs: sw.elapsedMilliseconds,
        detail: configured ? 'OK' : 'JAMENDO_CLIENT_ID missing on gateway',
        lastCheckedAt: DateTime.now(),
      );
    } on Object catch (e) {
      return ProviderHealth(
        provider: SourceProvider.jamendo,
        available: false,
        detail: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Page<Track>> searchTracks(SearchQuery query) async {
    _ensureConfigured();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/jamendo/search',
        queryParameters: {
          'q': query.text,
          'limit': query.limit,
          'offset': query.offset,
        },
        cancelToken:
            query.cancelToken is CancelToken ? query.cancelToken as CancelToken : null,
      );
      return _parsePage(res.data);
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Jamendo search failed',
        provider: SourceProvider.jamendo,
        cause: e,
      );
    }
  }

  @override
  Future<List<Track>> trending(FeedQuery query) async {
    _ensureConfigured();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/jamendo/trending',
        queryParameters: {
          'limit': query.limit,
          if (query.genre != null) 'tag': query.genre,
        },
      );
      return _parsePage(res.data).items;
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Jamendo trending failed',
        provider: SourceProvider.jamendo,
        cause: e,
      );
    }
  }

  @override
  Future<List<Track>> newest(FeedQuery query) async {
    _ensureConfigured();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/jamendo/newest',
        queryParameters: {
          'limit': query.limit,
          if (query.genre != null) 'tag': query.genre,
        },
      );
      return _parsePage(res.data).items;
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Jamendo newest failed',
        provider: SourceProvider.jamendo,
        cause: e,
      );
    }
  }

  @override
  Future<Track?> getTrack(String externalId) async {
    _ensureConfigured();
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_gatewayUrl/api/jamendo/tracks/$externalId',
      );
      final raw = res.data?['track'];
      if (raw is! Map<String, dynamic>) return null;
      return _mapItem(raw);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ProviderException(
        e.message ?? 'Jamendo track lookup failed',
        provider: SourceProvider.jamendo,
        cause: e,
      );
    }
  }

  @override
  PlaybackCapability capability(Track track) => _gate.resolveCapability(track);

  @override
  Future<AudioSourceSpec?> resolvePlayback(Track track) async {
    final cached = _urlCache[track.externalId];
    if (cached != null && cached.streamUrl.isNotEmpty) {
      return UrlAudioSource(cached.streamUrl);
    }
    await getTrack(track.externalId);
    final refreshed = _urlCache[track.externalId];
    if (refreshed != null && refreshed.streamUrl.isNotEmpty) {
      return UrlAudioSource(refreshed.streamUrl);
    }
    return null;
  }

  @override
  Future<bool> isDownloadable(Track track) async {
    final cached = _urlCache[track.externalId];
    if (cached != null) return cached.downloadUrl != null;
    final fresh = await getTrack(track.externalId);
    return fresh?.isDownloadable ?? false;
  }

  Future<Uri> resolveDownloadUrl(String externalId) async {
    final cached = _urlCache[externalId];
    if (cached?.downloadUrl != null) {
      return Uri.parse(cached!.downloadUrl!);
    }
    await getTrack(externalId);
    final refreshed = _urlCache[externalId];
    if (refreshed?.downloadUrl != null) {
      return Uri.parse(refreshed!.downloadUrl!);
    }
    if (refreshed?.streamUrl != null) {
      return Uri.parse(refreshed!.streamUrl);
    }
    throw const ProviderException(
      'Jamendo download URL unavailable',
      provider: SourceProvider.jamendo,
    );
  }

  Page<Track> _parsePage(Map<String, dynamic>? data) {
    final rawItems = (data?['items'] as List?) ?? const [];
    final items = <Track>[];
    for (final it in rawItems) {
      if (it is Map<String, dynamic>) {
        items.add(_mapItem(it));
      }
    }
    final next = data?['nextOffset'];
    return Page<Track>(
      items: items,
      nextOffset: next is int ? next : null,
    );
  }

  Track _mapItem(Map<String, dynamic> raw) {
    final id = raw['id']?.toString() ?? '';
    final streamUrl = raw['streamUrl']?.toString() ?? '';
    final downloadUrl = raw['downloadUrl']?.toString();
    if (id.isNotEmpty && streamUrl.isNotEmpty) {
      _urlCache[id] = (streamUrl: streamUrl, downloadUrl: downloadUrl);
    }
    return Track(
      stableId: stableTrackId(SourceProvider.jamendo, id),
      provider: SourceProvider.jamendo,
      externalId: id,
      title: raw['title']?.toString() ?? 'Untitled',
      artist: raw['artist']?.toString(),
      album: raw['album']?.toString(),
      durationMs: raw['durationMs'] is int ? raw['durationMs'] as int : null,
      artworkUrl: raw['artworkUrl']?.toString(),
      sourceUrl: raw['shareUrl']?.toString(),
      isStreamable: streamUrl.isNotEmpty,
      isDownloadable: raw['isDownloadable'] == true,
    );
  }
}
