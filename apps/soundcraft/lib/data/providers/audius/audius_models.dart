/// Parsed Audius API track (schema verified live 2026-11-03 against
/// https://api.audius.co /v1/tracks/trending — see docs/PROVIDER_COMPLIANCE.md).
///
/// Parsing is defensive: missing/wrong-typed fields must not crash the app
/// (contract §6.3: tests for null fields and malformed responses).
class AudiusTrackDto {
  const AudiusTrackDto({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistId,
    this.artistHandle,
    this.artistVerified = false,
    this.durationSec,
    this.genre,
    this.mood,
    this.releaseDate,
    this.playCount,
    this.favoriteCount,
    this.artwork150,
    this.artwork480,
    this.artwork1000,
    this.isDownloadable = false,
    this.isStreamable = true,
    this.isAvailable = true,
    this.isDelete = false,
    this.permalink,
  });

  final String id;
  final String title;
  final String artistName;
  final String artistId;
  final String? artistHandle;
  final bool artistVerified;
  final int? durationSec;
  final String? genre;
  final String? mood;
  final DateTime? releaseDate;
  final int? playCount;
  final int? favoriteCount;
  final String? artwork150;
  final String? artwork480;
  final String? artwork1000;
  final bool isDownloadable;
  final bool isStreamable;
  final bool isAvailable;
  final bool isDelete;
  final String? permalink;

  /// Parses one track object. Throws [FormatException] on structurally invalid
  /// input (missing id/title) so callers can skip the entry.
  static AudiusTrackDto fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('audius track missing id');
    }
    if (title is! String) {
      throw const FormatException('audius track missing title');
    }
    final user = json['user'];
    String artistName = 'Unknown artist';
    String artistId = id;
    String? handle;
    bool verified = false;
    if (user is Map<String, dynamic>) {
      artistName = (user['name'] as String?)?.trim().isNotEmpty == true
          ? (user['name'] as String).trim()
          : artistName;
      handle = user['handle'] as String?;
      artistId = (user['id'] as String?) ?? id;
      verified = user['is_verified'] == true;
    }
    final artwork = json['artwork'];
    String? art(String key) {
      if (artwork is! Map<String, dynamic>) return null;
      final v = artwork[key];
      return v is String ? v : null;
    }

    int? asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);

    return AudiusTrackDto(
      id: id,
      title: title,
      artistName: artistName,
      artistId: artistId,
      artistHandle: handle,
      artistVerified: verified,
      durationSec: asInt(json['duration']),
      genre: json['genre'] as String?,
      mood: json['mood'] as String?,
      releaseDate: DateTime.tryParse((json['release_date'] ?? '') as String),
      playCount: asInt(json['play_count']),
      favoriteCount: asInt(json['favorite_count']),
      artwork150: art('150x150'),
      artwork480: art('480x480'),
      artwork1000: art('1000x1000'),
      isDownloadable: json['is_downloadable'] == true,
      isStreamable: json['is_streamable'] != false,
      isAvailable: json['is_available'] != false,
      isDelete: json['is_delete'] == true,
      permalink: json['permalink'] as String?,
    );
  }

  /// Canonical public URL for sharing/attribution.
  String canonicalUrl(String host) =>
      permalink != null ? '$host$permalink' : host;

  /// Maps to the unified domain [Track].
  Map<String, dynamic> toTrackJson() => {
    'id': id,
    'title': title,
    'artist': artistName,
  };
}

/// Parses an Audius list response (`{"data": [...]}`) tolerating malformed
/// entries by skipping them.
List<Map<String, dynamic>> parseAudiusList(Object? body) {
  if (body is! Map<String, dynamic>) return const [];
  final data = body['data'];
  if (data is! List) return const [];
  return data.whereType<Map<String, dynamic>>().toList();
}

/// Provider id helper kept local to audius files to avoid import cycles in DTOs.
const String audiusProviderId = 'audius';

/// Track list cache key builder (provider cache is metadata-only).
String audiusCacheKey(String kind, {String? query, int page = 0}) =>
    'audius:$kind:${query ?? ''}:$page';
