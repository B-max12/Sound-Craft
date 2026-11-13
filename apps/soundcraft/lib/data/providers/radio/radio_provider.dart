import 'package:dio/dio.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';
import 'package:soundcraft/player/audio_platform.dart';

/// Live internet radio stations via the public Radio Browser directory
/// (https://api.radio-browser.info). Zero API keys required.
class RadioBrowserProvider implements MusicDiscoveryProvider {
  RadioBrowserProvider({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://de1.api.radio-browser.info/json',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 12),
                headers: const {'User-Agent': 'SoundCraft/0.1 (Aur Labs)'},
              ),
            );

  final Dio _dio;
  final RightsGate _gate = const RightsGate();
  final Map<String, String> _streamCache = {};

  @override
  SourceProvider get provider => SourceProvider.radio;

  @override
  String get attribution => 'Live radio stations via Radio Browser';

  @override
  Future<ProviderHealth> health() async {
    final sw = Stopwatch()..start();
    try {
      await _dio.get<List<dynamic>>(
        '/stations/topclick/1',
        queryParameters: const {'hidebroken': 'true'},
      );
      sw.stop();
      return ProviderHealth(
        provider: SourceProvider.radio,
        available: true,
        latencyMs: sw.elapsedMilliseconds,
        detail: 'OK',
        lastCheckedAt: DateTime.now(),
      );
    } on Object catch (e) {
      return ProviderHealth(
        provider: SourceProvider.radio,
        available: false,
        detail: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Page<Track>> searchTracks(SearchQuery query) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/stations/search',
        queryParameters: {
          'name': query.text,
          'limit': query.limit.clamp(1, 40),
          'offset': query.offset,
          'hidebroken': 'true',
          'order': 'clickcount',
          'reverse': 'true',
        },
        cancelToken:
            query.cancelToken is CancelToken ? query.cancelToken as CancelToken : null,
      );
      final items = _mapList(res.data ?? const []);
      return Page<Track>(
        items: items,
        nextOffset: items.length >= query.limit ? query.offset + items.length : null,
      );
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Radio search failed',
        provider: SourceProvider.radio,
        cause: e,
      );
    }
  }

  @override
  Future<List<Track>> trending(FeedQuery query) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/stations/topvote/${query.limit.clamp(1, 30)}',
        queryParameters: const {'hidebroken': 'true'},
      );
      return _mapList(res.data ?? const []);
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Radio trending failed',
        provider: SourceProvider.radio,
        cause: e,
      );
    }
  }

  @override
  Future<List<Track>> newest(FeedQuery query) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/stations/lastchange/${query.limit.clamp(1, 30)}',
        queryParameters: const {'hidebroken': 'true'},
      );
      return _mapList(res.data ?? const []);
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Radio newest failed',
        provider: SourceProvider.radio,
        cause: e,
      );
    }
  }

  @override
  Future<Track?> getTrack(String externalId) async {
    try {
      final res = await _dio.get<List<dynamic>>('/stations/byuuid/$externalId');
      final list = _mapList(res.data ?? const []);
      return list.isEmpty ? null : list.first;
    } on Object {
      return null;
    }
  }

  @override
  PlaybackCapability capability(Track track) => _gate.resolveCapability(track);

  @override
  Future<AudioSourceSpec?> resolvePlayback(Track track) async {
    final cached = _streamCache[track.externalId] ?? track.sourceUrl;
    if (cached != null && cached.isNotEmpty) {
      return UrlAudioSource(cached);
    }
    final fresh = await getTrack(track.externalId);
    final url = _streamCache[track.externalId] ?? fresh?.sourceUrl;
    if (url == null || url.isEmpty) return null;
    return UrlAudioSource(url);
  }

  @override
  Future<bool> isDownloadable(Track track) async => false;

  List<Track> _mapList(List<dynamic> raw) {
    final out = <Track>[];
    for (final it in raw) {
      if (it is! Map<String, dynamic>) continue;
      final uuid = it['stationuuid']?.toString() ?? '';
      final streamUrl =
          it['url_resolved']?.toString() ?? it['url']?.toString() ?? '';
      if (uuid.isEmpty || streamUrl.isEmpty) continue;
      _streamCache[uuid] = streamUrl;
      final country = it['countrycode']?.toString();
      final tags = it['tags']?.toString();
      final subtitle = [
        if (country != null && country.isNotEmpty) country,
        if (tags != null && tags.isNotEmpty)
          tags.split(',').take(2).join(' · '),
      ].join(' · ');
      out.add(
        Track(
          stableId: stableTrackId(SourceProvider.radio, uuid),
          provider: SourceProvider.radio,
          externalId: uuid,
          title: (it['name']?.toString() ?? 'Live Radio').trim(),
          artist: subtitle.isEmpty ? 'Live Radio' : subtitle,
          artworkUrl: (it['favicon']?.toString() ?? '').isNotEmpty
              ? it['favicon']?.toString()
              : null,
          sourceUrl: streamUrl,
          isStreamable: true,
          isDownloadable: false,
        ),
      );
    }
    return out;
  }
}
