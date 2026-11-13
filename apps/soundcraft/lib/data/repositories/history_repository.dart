import 'package:soundcraft/core/constants.dart';
import 'package:drift/drift.dart';

import '../app_database.dart';

/// A history row exposed to UI/recommender.
class HistoryEntry {
  HistoryEntry({
    required this.stableTrackId,
    required this.sourceType,
    required this.startedAt,
    this.lastPositionMs,
    required this.listenedMs,
    required this.completed,
  });

  final String stableTrackId;
  final SourceProvider sourceType;
  final DateTime startedAt;
  final int? lastPositionMs;
  final int listenedMs;
  final bool completed;
}

/// Listening history + recent searches with privacy controls (§3.13).
/// History is device-local by default and can be paused or cleared.
class HistoryRepository {
  HistoryRepository(this._db, {this.enabled = true});

  final AppDatabase _db;
  bool enabled;

  /// Records a play event. No-ops when history is paused (privacy opt-out).
  Future<void> recordStart({
    required String stableTrackId,
    required SourceProvider sourceType,
  }) async {
    if (!enabled) return;
    await _db
        .into(_db.listeningHistory)
        .insert(
          ListeningHistoryCompanion.insert(
            stableTrackId: stableTrackId,
            sourceType: sourceType.id,
            startedAt: DateTime.now(),
            deviceLocal: const Value(true),
          ),
        );
  }

  /// Updates the latest event for a track with listened duration/position.
  Future<void> recordProgress({
    required String stableTrackId,
    required int listenedMs,
    int? lastPositionMs,
    required bool completed,
  }) async {
    if (!enabled) return;
    final latest =
        await (_db.select(_db.listeningHistory)
              ..where((h) => h.stableTrackId.equals(stableTrackId))
              ..orderBy([(h) => OrderingTerm.desc(h.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (latest == null) return;
    await (_db.update(
      _db.listeningHistory,
    )..where((h) => h.id.equals(latest.id))).write(
      ListeningHistoryCompanion(
        listenedMs: Value(latest.listenedMs + listenedMs),
        lastPositionMs: Value(lastPositionMs),
        completed: Value(completed),
      ),
    );
  }

  /// Most recent distinct tracks for "Continue listening" (REF to §3.2).
  Future<List<HistoryEntry>> recent({int limit = 20}) async {
    final rows =
        await (_db.select(_db.listeningHistory)
              ..orderBy([
                (h) => OrderingTerm.desc(h.startedAt),
                (h) => OrderingTerm.desc(h.id), // tie-break within same second
              ])
              ..limit(limit * 4))
            .get();
    final seen = <String>{};
    final out = <HistoryEntry>[];
    for (final r in rows) {
      if (seen.add(r.stableTrackId)) {
        out.add(
          HistoryEntry(
            stableTrackId: r.stableTrackId,
            sourceType: SourceProviderX.fromId(r.sourceType),
            startedAt: r.startedAt,
            lastPositionMs: r.lastPositionMs,
            listenedMs: r.listenedMs,
            completed: r.completed,
          ),
        );
      }
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Per-track play counts for the recommender (deterministic, local only).
  Future<Map<String, int>> playCounts() async {
    final countExpr = _db.listeningHistory.id.count();
    final q = _db.selectOnly(_db.listeningHistory)
      ..addColumns([_db.listeningHistory.stableTrackId, countExpr])
      ..groupBy([_db.listeningHistory.stableTrackId]);
    final rows = await q.get();
    return {
      for (final r in rows)
        r.read(_db.listeningHistory.stableTrackId)!: r.read(countExpr) ?? 0,
    };
  }

  /// Skips (events with tiny listened duration) for negative signal.
  Future<Set<String>> skippedTrackIds({int withinMs = 8000}) async {
    final q = _db.select(_db.listeningHistory)
      ..where(
        (h) =>
            h.listenedMs.isSmallerThanValue(withinMs) &
            h.completed.equals(false),
      )
      ..limit(500);
    return (await q.get()).map((e) => e.stableTrackId).toSet();
  }

  /// Forgets one track (§3.13 "forget individual track").
  Future<void> forgetTrack(String stableTrackId) async {
    await (_db.delete(
      _db.listeningHistory,
    )..where((h) => h.stableTrackId.equals(stableTrackId))).go();
  }

  /// Clears ALL history after confirmation (SET-004; explicit scope).
  Future<int> clearAll() async {
    return _db.delete(_db.listeningHistory).go();
  }
}

/// Recent search terms with per-item and bulk clear (SRCH-002/003).
class RecentSearchesRepository {
  RecentSearchesRepository(this._db);

  final AppDatabase _db;

  Future<List<String>> list({int limit = 10}) async {
    final rows =
        await (_db.select(_db.recentSearches)
              ..orderBy([(s) => OrderingTerm.desc(s.at)])
              ..limit(limit))
            .get();
    return rows.map((r) => r.query).toList();
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty || q.length > 200) return;
    await _db
        .into(_db.recentSearches)
        .insertOnConflictUpdate(
          RecentSearchesCompanion.insert(query: q, at: DateTime.now()),
        );
  }

  Future<void> remove(String query) async {
    await (_db.delete(
      _db.recentSearches,
    )..where((s) => s.query.equals(query))).go();
  }

  Future<int> clearAll() async {
    return _db.delete(_db.recentSearches).go();
  }
}
