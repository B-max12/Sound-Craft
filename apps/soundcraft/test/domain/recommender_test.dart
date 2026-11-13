import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/services/recommender.dart';

/// Deterministic recommender tests (§25.2): cold start, all-skips, sparse
/// history, identical scores, negative skip signals, source scoping.
void main() {
  Track t(String id, {String? artist, String? genre}) => Track(
        stableId: 'local:$id',
        provider: SourceProvider.local,
        externalId: id,
        title: 'T $id',
        artist: artist,
        genre: genre,
      );

  test('cold start (no history): still returns a deterministic order', () {
    final candidates = [t('a'), t('b'), t('c')];
    final r1 = const Recommender().rankLocal(
        candidates: candidates, playCounts: {}, skipped: {}, favoriteIds: {});
    final r2 = const Recommender().rankLocal(
        candidates: candidates, playCounts: {}, skipped: {}, favoriteIds: {});
    expect(r1, hasLength(3));
    expect(r1.map((t) => t.externalId).toList(), r2.map((t) => t.externalId).toList());
  });

  test('empty input returns empty, never throws', () {
    expect(
      const Recommender().rankLocal(
          candidates: [], playCounts: {}, skipped: {}, favoriteIds: {}),
      isEmpty,
    );
  });

  test('play counts boost ranking (listening affinity)', () {
    final a = t('a'), b = t('b');
    final ranked = const Recommender().rankLocal(
      candidates: [a, b],
      playCounts: {'local:a': 10, 'local:b': 0},
      skipped: {},
      favoriteIds: {},
    );
    expect(ranked.first.externalId, 'a');
  });

  test('favorite boost applies on top of plays', () {
    final a = t('a'), b = t('b');
    final ranked = const Recommender().rankLocal(
      candidates: [a, b],
      playCounts: {'local:a': 1, 'local:b': 1},
      skipped: {},
      favoriteIds: {'local:b'},
    );
    expect(ranked.first.externalId, 'b');
  });

  test('skipped tracks sink below otherwise-equal peers (negative signal)',
      () {
    final a = t('a'), b = t('b');
    final ranked = const Recommender().rankLocal(
      candidates: [a, b],
      playCounts: {'local:a': 2, 'local:b': 2},
      skipped: {'local:b'},
      favoriteIds: {},
    );
    expect(ranked.first.externalId, 'a');
  });

  test('all-skips history: still returns candidates (never empty-walls)', () {
    final candidates = [t('x'), t('y')];
    final ranked = const Recommender().rankLocal(
      candidates: candidates,
      playCounts: {'local:x': 1, 'local:y': 1},
      skipped: {'local:x', 'local:y'},
      favoriteIds: {},
    );
    expect(ranked, hasLength(2));
  });

  test('cold-start ranking is fully deterministic for a fixed input', () {
    // With no history, novelty/diversity terms dominate; the SAME input list
    // must ALWAYS produce the SAME order (contract: deterministic MVP).
    final candidates = [t('z'), t('a'), t('m')];
    final run1 = const Recommender().rankLocal(
        candidates: candidates, playCounts: {}, skipped: {}, favoriteIds: {});
    final run2 = const Recommender().rankLocal(
        candidates: candidates, playCounts: {}, skipped: {}, favoriteIds: {});
    expect(run1.map((t) => t.externalId).toList(), ['m', 'z', 'a']);
    expect(run2.map((t) => t.externalId).toList(), run1.map((t) => t.externalId).toList());
  });

  test('input list is never mutated', () {
    final candidates = [t('b'), t('a')];
    final copy = [...candidates];
    const Recommender().rankLocal(
      candidates: candidates,
      playCounts: {'local:a': 5},
      skipped: {},
      favoriteIds: {},
    );
    expect(candidates.map((t) => t.externalId), copy.map((t) => t.externalId));
  });

  test('weight table sums to 1.0 (sanity, §25.2 formula)', () {
    final sum = kRecommenderWeights.values.reduce((a, b) => a + b);
    expect(sum, closeTo(1.0, 0.0001));
  });

  test('artist grouping helpers keep case-insensitive grouping', () {
    final tracks = [
      t('1', artist: 'Aurora'),
      t('2', artist: 'aurora'),
      t('3', artist: 'Nord'),
    ];
    final groups = groupByArtist(tracks);
    expect(groups.length, 2);
    expect(groups['aurora'], hasLength(2));
  });
}
