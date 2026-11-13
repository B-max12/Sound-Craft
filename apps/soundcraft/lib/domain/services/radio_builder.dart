import 'package:soundcraft/data/providers/audius/audius_provider.dart';
import 'package:soundcraft/data/providers/jamendo/jamendo_provider.dart';
import 'package:soundcraft/data/providers/lastfm/lastfm_service.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';

/// Builds a "Song Radio" queue from a seed track using Last.fm similarity
/// matched against Audius & Jamendo playable catalogs, falling back to
/// artist/title discovery on Audius & Jamendo if Last.fm is unconfigured.
class RadioBuilder {
  const RadioBuilder({
    required this.lastFm,
    required this.audius,
    required this.jamendo,
  });

  final LastFmService lastFm;
  final AudiusProvider audius;
  final JamendoProvider jamendo;

  Future<List<Track>> buildFromTrack(Track seed, {int targetCount = 12}) async {
    final seenIds = <String>{seed.stableId};
    final out = <Track>[seed];

    if (lastFm.isConfigured && seed.artist != null && seed.artist!.isNotEmpty) {
      final similar = await lastFm.similarTracks(
        artist: seed.artist!,
        title: seed.title,
        limit: 10,
      );
      for (final ref in similar.take(6)) {
        if (out.length >= targetCount) break;
        final match = await _findPlayable('${ref.artist} ${ref.title}');
        if (match != null && seenIds.add(match.stableId)) {
          out.add(match);
        }
      }
    }

    // Fill remaining slots with Audius + Jamendo discovery on artist/genre/title.
    if (out.length < targetCount) {
      final queryText = (seed.artist != null && seed.artist!.isNotEmpty)
          ? seed.artist!
          : seed.title;
      try {
        final audiusPage = await audius.searchTracks(
          SearchQuery(text: queryText, limit: 10),
        );
        for (final t in audiusPage.items) {
          if (out.length >= targetCount) break;
          if (t.isStreamable && seenIds.add(t.stableId)) {
            out.add(t);
          }
        }
      } catch (_) {}
    }

    if (out.length < targetCount && jamendo.isConfigured) {
      final queryText = seed.genre ?? seed.artist ?? seed.title;
      try {
        final jamendoPage = await jamendo.searchTracks(
          SearchQuery(text: queryText, limit: 10),
        );
        for (final t in jamendoPage.items) {
          if (out.length >= targetCount) break;
          if (t.isStreamable && seenIds.add(t.stableId)) {
            out.add(t);
          }
        }
      } catch (_) {}
    }

    return out;
  }

  Future<Track?> _findPlayable(String query) async {
    try {
      final a = await audius.searchTracks(SearchQuery(text: query, limit: 3));
      for (final t in a.items) {
        if (t.isStreamable) return t;
      }
    } catch (_) {}
    if (jamendo.isConfigured) {
      try {
        final j = await jamendo.searchTracks(SearchQuery(text: query, limit: 3));
        for (final t in j.items) {
          if (t.isStreamable) return t;
        }
      } catch (_) {}
    }
    return null;
  }
}
