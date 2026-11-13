import 'package:drift/drift.dart';

import '../app_database.dart';

/// Download job record for UI lists.
class DownloadJobView {
  const DownloadJobView({
    required this.id,
    required this.stableTrackId,
    required this.provider,
    required this.title,
    this.artist,
    required this.targetPath,
    required this.tempPath,
    required this.bytesTotal,
    required this.bytesWritten,
    required this.state,
    this.errorCode,
    required this.canResume,
    required this.attemptCount,
  });

  final String id;
  final String stableTrackId;
  final String provider;
  final String title;
  final String? artist;
  final String targetPath;
  final String tempPath;
  final int? bytesTotal;
  final int bytesWritten;
  final DownloadJobState state;
  final String? errorCode;
  final bool canResume;
  final int attemptCount;

  double? get progress => bytesTotal == null || bytesTotal! <= 0
      ? null
      : (bytesWritten / bytesTotal!).clamp(0.0, 1.0);
}

enum DownloadJobState { queued, running, paused, completed, failed, cancelled }

DownloadJobState downloadJobStateFromName(String name) => DownloadJobState
    .values
    .firstWhere((s) => s.name == name, orElse: () => DownloadJobState.failed);

/// Persistence for download jobs (DL-00x, §3.11).
class DownloadsRepository {
  DownloadsRepository(this._db);

  final AppDatabase _db;

  Future<List<DownloadJobView>> all() async {
    final rows = await (_db.select(
      _db.downloadJobs,
    )..orderBy([(j) => OrderingTerm.desc(j.updatedAt)])).get();
    return rows.map(_rowToView).toList();
  }

  Future<DownloadJobView?> byId(String id) async {
    final row = await (_db.select(
      _db.downloadJobs,
    )..where((j) => j.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToView(row);
  }

  /// Job for a track (dedupe: one active job per stable track id).
  Future<DownloadJobView?> activeForTrack(String stableTrackId) async {
    final row =
        await (_db.select(_db.downloadJobs)..where(
              (j) =>
                  j.stableTrackId.equals(stableTrackId) &
                  j.state.isIn(['queued', 'running', 'paused']),
            ))
            .getSingleOrNull();
    return row == null ? null : _rowToView(row);
  }

  Future<String> insert({
    required String id,
    required String stableTrackId,
    required String provider,
    required String title,
    String? artist,
    required String targetPath,
    required String tempPath,
    required String permissionProof,
  }) async {
    await _db
        .into(_db.downloadJobs)
        .insert(
          DownloadJobsCompanion.insert(
            id: id,
            stableTrackId: stableTrackId,
            provider: provider,
            title: title,
            artist: Value(artist),
            targetPath: targetPath,
            tempPath: tempPath,
            state: DownloadJobState.queued.name,
            permissionProof: permissionProof,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> updateState(
    String id,
    DownloadJobState state, {
    String? errorCode,
    int? bytesWritten,
    int? bytesTotal,
    bool? canResume,
  }) async {
    final updates = DownloadJobsCompanion(
      state: Value(state.name),
      errorCode: Value(errorCode),
      bytesWritten: bytesWritten == null
          ? const Value.absent()
          : Value(bytesWritten),
      bytesTotal: bytesTotal == null ? const Value.absent() : Value(bytesTotal),
      canResume: canResume == null ? const Value.absent() : Value(canResume),
      updatedAt: Value(DateTime.now()),
    );
    await (_db.update(
      _db.downloadJobs,
    )..where((j) => j.id.equals(id))).write(updates);
  }

  Future<void> bumpAttempts(String id) async {
    await _db.customUpdate(
      'UPDATE download_jobs SET attempt_count = attempt_count + 1 WHERE id = ?',
      variables: [Variable(id)],
    );
  }

  /// Reconcile DB rows with the real filesystem (REF-004: no fake completion —
  /// a completed job whose file disappeared is demoted to failed).
  Future<int> reconcileFiles(bool Function(String path) exists) async {
    final rows = await _db.select(_db.downloadJobs).get();
    var fixed = 0;
    for (final row in rows) {
      if (row.state == DownloadJobState.completed.name &&
          !exists(row.targetPath)) {
        await (_db.update(
          _db.downloadJobs,
        )..where((j) => j.id.equals(row.id))).write(
          DownloadJobsCompanion(
            state: Value(DownloadJobState.failed.name),
            errorCode: const Value('file_missing'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        fixed++;
      }
    }
    return fixed;
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.downloadJobs)..where((j) => j.id.equals(id))).go();
  }

  Future<int> clearCompleted() async {
    return (_db.delete(
      _db.downloadJobs,
    )..where((j) => j.state.equals(DownloadJobState.completed.name))).go();
  }

  Future<List<DownloadJobView>> completed() async {
    final rows = await (_db.select(
      _db.downloadJobs,
    )..where((j) => j.state.equals(DownloadJobState.completed.name))).get();
    return rows.map(_rowToView).toList();
  }

  DownloadJobView _rowToView(DownloadJob row) => DownloadJobView(
    id: row.id,
    stableTrackId: row.stableTrackId,
    provider: row.provider,
    title: row.title,
    artist: row.artist,
    targetPath: row.targetPath,
    tempPath: row.tempPath,
    bytesTotal: row.bytesTotal,
    bytesWritten: row.bytesWritten,
    state: downloadJobStateFromName(row.state),
    errorCode: row.errorCode,
    canResume: row.canResume,
    attemptCount: row.attemptCount,
  );
}
