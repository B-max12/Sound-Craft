import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/player/audio_platform.dart';

/// Search/feed query envelope with paging.
class SearchQuery {
  const SearchQuery({
    required this.text,
    this.limit = 20,
    this.offset = 0,
    this.cancelToken,
  });

  final String text;
  final int limit;
  final int offset;
  final Object? cancelToken; // provider-internal (e.g. Dio CancelToken)
}

class FeedQuery {
  const FeedQuery({
    this.limit = 20,
    this.genre,
    this.timeRange,
    this.cancelToken,
  });
  final int limit;
  final String? genre;
  final String? timeRange; // week | month | year | all
  final Object? cancelToken;
}

class Page<T> {
  const Page({required this.items, this.nextOffset});
  final List<T> items;

  /// null when the provider indicates no more pages.
  final int? nextOffset;
  bool get hasMore => nextOffset != null;
}

/// Provider health snapshot for the diagnostics screen (§3.14).
class ProviderHealth {
  const ProviderHealth({
    required this.provider,
    required this.available,
    this.latencyMs,
    this.detail,
    this.lastCheckedAt,
  });

  final SourceProvider provider;
  final bool available;
  final int? latencyMs;
  final String? detail;
  final DateTime? lastCheckedAt;
}

/// Provider adapter contract (§6.3). Unsupported operations throw typed
/// errors — never zero-filled fake data (R02).
abstract interface class MusicDiscoveryProvider {
  SourceProvider get provider;

  /// One-line attribution shown wherever this provider's content appears.
  String get attribution;

  Future<ProviderHealth> health();
  Future<Page<Track>> searchTracks(SearchQuery query);
  Future<List<Track>> trending(FeedQuery query);
  Future<List<Track>> newest(FeedQuery query);
  Future<Track?> getTrack(String externalId);

  /// Capability snapshot; drives which buttons exist in UI (R03).
  PlaybackCapability capability(Track track);

  /// Just-in-time playable source or null if unresolvable. Signed/temporary
  /// URLs must not be persisted by callers (§6.3).
  Future<AudioSourceSpec?> resolvePlayback(Track track);

  /// Auditable download-permission check (Audius `is_downloadable`; YouTube
  /// always denies). Implementations must NOT infer download rights from
  /// streamability.
  Future<bool> isDownloadable(Track track);
}

/// Shared helpers for provider adapters.
extension ProviderErrorMapper on Object {
  ProviderException toProviderException(SourceProvider provider) {
    final self = this;
    if (self is ProviderException) return self;
    return ProviderException(toString(), provider: provider, cause: this);
  }
}
