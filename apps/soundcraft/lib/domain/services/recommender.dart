import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Deterministic local recommendation MVP (§25.2). No cloud ML; weights are
/// illustrative and unit-tested for cold start, all-skips, sparse history,
/// identical scores and deterministic ordering.
///
/// score = 0.35*artistAffinity + 0.25*genreAffinity + 0.15*listeningAffinity
///       + 0.10*freshness + 0.10*novelty + 0.05*diversity
class Recommender {
  const Recommender();

  static const double wArtist = 0.35;
  static const double wGenre = 0.25;
  static const double wListening = 0.15;
  static const double wFreshness = 0.10;
  static const double wNovelty = 0.10;
  static const double wDiversity = 0.05;

  /// Ranks local library tracks by affinity signals derived ONLY from
  /// device-local history. Returns a new ordered list (never mutates input).
  List<Track> rankLocal({
    required List<Track> candidates,
    required Map<String, int> playCounts,
    required Set<String> skipped,
    required Set<String> favoriteIds,
  }) {
    if (candidates.isEmpty) return const [];

    final artistCounts = <String, int>{};
    final genreCounts = <String, int>{};
    for (final t in candidates) {
      final plays = playCounts[t.stableId] ?? 0;

      if (t.artist != null && t.artist!.isNotEmpty) {
        artistCounts[t.artist!.toLowerCase()] =
            (artistCounts[t.artist!.toLowerCase()] ?? 0) + plays;
      }
      if (t.genre != null && t.genre!.isNotEmpty) {
        genreCounts[t.genre!.toLowerCase()] =
            (genreCounts[t.genre!.toLowerCase()] ?? 0) + plays;
      }
    }
    final maxArtist = artistCounts.values.fold<int>(0, math.max);
    final maxGenre = genreCounts.values.fold<int>(0, math.max);
    final maxPlays = playCounts.values.fold<int>(0, math.max);

    final scored = <({Track track, double score})>[];
    for (var i = 0; i < candidates.length; i++) {
      final t = candidates[i];
      final artistAffinity = _norm(
        artistCounts[t.artist?.toLowerCase() ?? ''] ?? 0,
        maxArtist,
      );
      final genreAffinity = _norm(
        genreCounts[t.genre?.toLowerCase() ?? ''] ?? 0,
        maxGenre,
      );
      final listening = _norm(playCounts[t.stableId] ?? 0, maxPlays);
      // Freshness: slight bias toward items never heard or rarely heard.
      final freshness = _norm(
        math.max(0, 10 - (playCounts[t.stableId] ?? 0)),
        10,
      );
      // Novelty: unknown artists get a nudge; skipped items are penalised.
      final novelty = playCounts.containsKey(t.stableId) ? 0.3 : 0.8;
      final diversity = (i % 2 == 0) ? 1.0 : 0.6;

      var score =
          wArtist * artistAffinity +
          wGenre * genreAffinity +
          wListening * listening +
          wFreshness * freshness +
          wNovelty * novelty +
          wDiversity * diversity;

      if (skipped.contains(t.stableId)) score -= 0.25; // negative skip signal
      if (favoriteIds.contains(t.stableId)) score += 0.15; // liked boost

      scored.add((track: t, score: score));
    }

    // Deterministic: sort by score desc, then stable id for ties.
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.track.stableId.compareTo(b.track.stableId);
    });
    return scored.map((s) => s.track).toList();
  }

  double _norm(int value, int max) {
    if (max <= 0) return 0;
    return (value / max).clamp(0.0, 1.0);
  }
}

/// Small extension to keep candidate source-scoping explicit at call sites.
extension CandidateFilter on List<Track> {
  List<Track> playableLocally() =>
      where((t) => t.provider == SourceProvider.local).toList();
}

/// Used by tests; exposes the weight constant table for tuning assertions.
const Map<String, double> kRecommenderWeights = {
  'artist': Recommender.wArtist,
  'genre': Recommender.wGenre,
  'listening': Recommender.wListening,
  'freshness': Recommender.wFreshness,
  'novelty': Recommender.wNovelty,
  'diversity': Recommender.wDiversity,
};

/// Convenience: group tracks by lowercased artist name (Library "Artists" tab).
Map<String, List<Track>> groupByArtist(Iterable<Track> tracks) =>
    groupBy(tracks, (Track t) => (t.artist ?? 'Unknown artist').toLowerCase());

/// Convenience: group by album (Library "Albums" tab).
Map<String, List<Track>> groupByAlbum(Iterable<Track> tracks) =>
    groupBy(tracks, (Track t) => (t.album ?? 'Unknown album').toLowerCase());
