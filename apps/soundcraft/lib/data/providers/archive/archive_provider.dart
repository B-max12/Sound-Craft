import 'package:dio/dio.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';
import 'package:soundcraft/player/audio_platform.dart';

/// Internet Archive (archive.org) public-domain & Creative Commons audio
/// catalog. Requires zero API keys.
class InternetArchiveProvider implements MusicDiscoveryProvider {
  InternetArchiveProvider({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://archive.org',
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {'User-Agent': 'SoundCraft/0.1 (Aur Labs)'},
              ),
            );

  final Dio _dio;
  final RightsGate _gate = const RightsGate();
  final Map<String, String> _resolvedAudioUrl = {};

  @override
  SourceProvider get provider => SourceProvider.archive;

  @override
  String get attribution => 'Public domain & CC audio via Internet Archive';

  @override
  Future<ProviderHealth> health() async {
    final sw = Stopwatch()..start();
    try {
      await _dio.get<Map<String, dynamic>>(
        '/advancedsearch.php',
        queryParameters: {
          'q': 'mediatype:audio AND collection:opensource_audio',
          'rows': 1,
          'output': 'json',
        },
      );
      sw.stop();
      return ProviderHealth(
        provider: SourceProvider.archive,
        available: true,
        latencyMs: sw.elapsedMilliseconds,
        detail: 'OK',
        lastCheckedAt: DateTime.now(),
      );
    } on Object catch (e) {
      return ProviderHealth(
        provider: SourceProvider.archive,
        available: false,
        detail: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Page<Track>> searchTracks(SearchQuery query) async {
    final page = (query.offset ~/ query.limit.clamp(1, 50)) + 1;
    final cleanQ = query.text.replaceAll('"', '');
    return _search(
      'mediatype:audio AND ($cleanQ) AND (format:MP3 OR format:"VBR MP3")',
      rows: query.limit,
      page: page,
      sort: 'downloads desc',
      cancelToken:
          query.cancelToken is CancelToken ? query.cancelToken as CancelToken : null,
    );
  }

  @override
  Future<List<Track>> trending(FeedQuery query) async {
    final page = await _search(
      'mediatype:audio AND (collection:audio_music OR collection:etree OR collection:netlabels) AND (format:"VBR MP3" OR format:MP3)',
      rows: query.limit,
      page: 1,
      sort: 'week desc',
    );
    return page.items;
  }

  @override
  Future<List<Track>> newest(FeedQuery query) async {
    final page = await _search(
      'mediatype:audio AND (collection:audio_music OR collection:netlabels) AND (format:"VBR MP3" OR format:MP3)',
      rows: query.limit,
      page: 1,
      sort: 'addeddate desc',
    );
    return page.items;
  }

  Future<Page<Track>> _search(
    String q, {
    required int rows,
    required int page,
    required String sort,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/advancedsearch.php',
        queryParameters: {
          'q': q,
          'fl[]': ['identifier', 'title', 'creator', 'licenseurl'],
          'rows': rows.clamp(1, 30),
          'page': page,
          'sort[]': sort,
          'output': 'json',
        },
        cancelToken: cancelToken,
      );
      final docs =
          (res.data?['response']?['docs'] as List?) ?? const [];
      final items = <Track>[];
      for (final d in docs) {
        if (d is! Map<String, dynamic>) continue;
        final id = d['identifier']?.toString();
        if (id == null || id.isEmpty) continue;
        final creator = d['creator'];
        final artist = creator is List
            ? creator.map((e) => e.toString()).join(', ')
            : creator?.toString();
        items.add(
          Track(
            stableId: stableTrackId(SourceProvider.archive, id),
            provider: SourceProvider.archive,
            externalId: id,
            title: d['title']?.toString() ?? id,
            artist: artist ?? 'Internet Archive',
            artworkUrl: 'https://archive.org/services/img/$id',
            sourceUrl: 'https://archive.org/details/$id',
            isStreamable: true,
            isDownloadable: true,
          ),
        );
      }
      final numFound = res.data?['response']?['numFound'] as int? ?? 0;
      final loadedSoFar = (page - 1) * rows + items.length;
      return Page<Track>(
        items: items,
        nextOffset: loadedSoFar < numFound && items.isNotEmpty ? loadedSoFar : null,
      );
    } on DioException catch (e) {
      throw ProviderException(
        e.message ?? 'Internet Archive search failed',
        provider: SourceProvider.archive,
        cause: e,
      );
    }
  }

  @override
  Future<Track?> getTrack(String externalId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/metadata/$externalId');
      final meta = res.data?['metadata'];
      if (meta is! Map<String, dynamic>) return null;
      return Track(
        stableId: stableTrackId(SourceProvider.archive, externalId),
        provider: SourceProvider.archive,
        externalId: externalId,
        title: meta['title']?.toString() ?? externalId,
        artist: meta['creator']?.toString() ?? 'Internet Archive',
        artworkUrl: 'https://archive.org/services/img/$externalId',
        sourceUrl: 'https://archive.org/details/$externalId',
        isStreamable: true,
        isDownloadable: true,
      );
    } on Object {
      return null;
    }
  }

  @override
  PlaybackCapability capability(Track track) => _gate.resolveCapability(track);

  @override
  Future<AudioSourceSpec?> resolvePlayback(Track track) async {
    final url = await _resolveMp3Url(track.externalId);
    if (url == null) return null;
    return UrlAudioSource(url);
  }

  @override
  Future<bool> isDownloadable(Track track) async => true;

  Future<Uri> resolveDownloadUrl(String externalId) async {
    final url = await _resolveMp3Url(externalId);
    if (url == null) {
      throw const ProviderException(
        'No playable MP3 file found in Internet Archive item',
        provider: SourceProvider.archive,
      );
    }
    return Uri.parse(url);
  }

  Future<String?> _resolveMp3Url(String identifier) async {
    final cached = _resolvedAudioUrl[identifier];
    if (cached != null) return cached;
    try {
      final res = await _dio.get<Map<String, dynamic>>('/metadata/$identifier');
      final files = (res.data?['files'] as List?) ?? const [];
      String? bestName;
      for (final f in files) {
        if (f is! Map<String, dynamic>) continue;
        final name = f['name']?.toString() ?? '';
        final lower = name.toLowerCase();
        if (lower.endsWith('.mp3') || lower.endsWith('.m4a') || lower.endsWith('.ogg')) {
          bestName = name;
          // Prefer non-sample, standard MP3 if found.
          if (lower.endsWith('.mp3') && !lower.contains('_64kb')) break;
        }
      }
      if (bestName == null) return null;
      final url =
          'https://archive.org/download/$identifier/${Uri.encodeComponent(bestName)}';
      _resolvedAudioUrl[identifier] = url;
      return url;
    } on Object {
      return null;
    }
  }
}
