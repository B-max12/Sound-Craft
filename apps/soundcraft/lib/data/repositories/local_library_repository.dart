import 'dart:io';

import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:drift/drift.dart';
import 'package:soundcraft/domain/models/track.dart';

import '../app_database.dart';

/// Data class used by the scanner isolate. Plain, serialisable, no drift types.
class ScannedTrack {
  const ScannedTrack({
    required this.uri,
    required this.uriKind,
    required this.title,
    required this.fingerprint,
    this.artist,
    this.album,
    this.genre,
    this.durationMs,
    this.sizeBytes,
    this.modifiedAt,
    this.artwork,
  });

  final String uri;
  final String uriKind;
  final String title;
  final String fingerprint;
  final String? artist;
  final String? album;
  final String? genre;
  final int? durationMs;
  final int? sizeBytes;
  final DateTime? modifiedAt;
  final Uint8List? artwork;
}

/// Outcome of a scan run, reported to UI (REF-002: added/changed/unavailable).
class ScanSummary {
  ScanSummary({
    this.added = 0,
    this.updated = 0,
    this.skipped = 0,
    this.unreadable = 0,
    this.removed = 0,
  });
  int added;
  int updated;
  int skipped; // duplicates
  int unreadable;
  int removed;
  bool cancelled = false;

  @override
  String toString() =>
      'ScanSummary(added:$added updated:$updated skipped:$skipped unreadable:$unreadable removed:$removed cancelled:$cancelled)';
}

/// Read/write access to the local music library (P02).
class LocalLibraryRepository {
  LocalLibraryRepository(this._db);

  final AppDatabase _db;

  AppDatabase get db => _db;

  /// All local tracks (not-missing first), mapped to the domain [Track].
  Future<List<Track>> getAll() async {
    final rows =
        await (_db.select(_db.localTracks)
              ..where((t) => t.isMissing.equals(false))
              ..orderBy([
                (t) =>
                    OrderingTerm(expression: t.title, mode: OrderingMode.asc),
              ]))
            .get();
    return rows.map(_rowToTrack).toList();
  }

  /// Local substring search over title/artist/album (LIB search; instant).
  Future<List<Track>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return getAll();
    final pattern = '%$q%';
    final rows =
        await (_db.select(_db.localTracks)
              ..where(
                (t) =>
                    t.isMissing.equals(false) &
                    (t.title.like(pattern) |
                        t.artist.like(pattern) |
                        t.album.like(pattern)),
              )
              ..orderBy([(t) => OrderingTerm(expression: t.title)]))
            .get();
    return rows.map(_rowToTrack).toList();
  }

  /// Fetch one track by stable id; null when absent.
  Future<Track?> getById(String stableId) async {
    final external = stableId.startsWith('local:')
        ? stableId.substring(6)
        : stableId;
    final row = await (_db.select(
      _db.localTracks,
    )..where((t) => t.id.equals(external))).getSingleOrNull();
    return row == null ? null : _rowToTrack(row);
  }

  Future<List<Track>> getManyByIds(Iterable<String> stableIds) async {
    final externals = stableIds
        .where((id) => id.startsWith('local:'))
        .map((id) => id.substring(6))
        .toList();
    if (externals.isEmpty) return [];
    final rows = await (_db.select(
      _db.localTracks,
    )..where((t) => t.id.isIn(externals))).get();
    return rows.map(_rowToTrack).toList();
  }

  /// Upserts scanned entries with dedupe by content fingerprint (§8).
  /// Does NOT delete original files; [removeMissing] only marks rows.
  Future<ScanSummary> upsertScanned(
    List<ScannedTrack> scans, {
    String? folderUri,
  }) async {
    final summary = ScanSummary();
    if (folderUri != null) {
      await _db
          .into(_db.importedFolders)
          .insertOnConflictUpdate(
            ImportedFoldersCompanion.insert(
              accessUri: folderUri,
              lastScanAt: Value(DateTime.now()),
            ),
          );
    }
    for (final scan in scans) {
      if (summary.cancelled) break;
      final localId = scan.fingerprint.length >= 16
          ? scan.fingerprint.substring(0, 16)
          : scan.fingerprint;
      final existing =
          await (_db.select(_db.localTracks)..where(
                (t) =>
                    t.id.equals(localId) |
                    t.fingerprint.equals(scan.fingerprint),
              ))
              .getSingleOrNull();
      if (existing != null) {
        if (existing.uri != scan.uri) {
          await (_db.update(
            _db.localTracks,
          )..where((t) => t.id.equals(existing.id))).write(
            LocalTracksCompanion(
              uri: Value(scan.uri),
              modifiedAt: Value(scan.modifiedAt),
              isMissing: const Value(false),
            ),
          );
          summary.updated++;
        } else {
          summary.skipped++;
        }
        continue;
      }
      await _db
          .into(_db.localTracks)
          .insert(
            LocalTracksCompanion.insert(
              id: localId,
              uri: scan.uri,
              uriKind: scan.uriKind,
              title: scan.title,
              artist: Value(scan.artist),
              album: Value(scan.album),
              genre: Value(scan.genre),
              durationMs: Value(scan.durationMs),
              sizeBytes: Value(scan.sizeBytes),
              fingerprint: scan.fingerprint,
              artworkBlob: Value(scan.artwork),
              modifiedAt: Value(scan.modifiedAt),
              importedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrAbort,
          );
      summary.added++;
    }
    return summary;
  }

  /// Marks rows whose file no longer exists (LIB-005 detection; never deletes
  /// user files and never silently drops playlist entries).
  Future<int> markMissingFiles() async {
    final rows = await _db.select(_db.localTracks).get();
    var missing = 0;
    for (final row in rows) {
      if (row.uriKind != 'file' && row.uriKind != 'content') continue;
      final exists = row.uriKind == 'file' ? File(row.uri).existsSync() : true;
      if (!exists && !row.isMissing) {
        await (_db.update(_db.localTracks)..where((t) => t.id.equals(row.id)))
            .write(const LocalTracksCompanion(isMissing: Value(true)));
        missing++;
      } else if (exists && row.isMissing) {
        await (_db.update(_db.localTracks)..where((t) => t.id.equals(row.id)))
            .write(const LocalTracksCompanion(isMissing: Value(false)));
      }
    }
    return missing;
  }

  /// Relink a missing track to a new location, keeping playlist entries
  /// (LIB-005 "relink"; §8 handle moved/renamed files).
  Future<void> relink(String stableId, String newUri) async {
    final external = stableId.startsWith('local:')
        ? stableId.substring(6)
        : stableId;
    final updated =
        await (_db.update(
          _db.localTracks,
        )..where((t) => t.id.equals(external))).write(
          LocalTracksCompanion(
            uri: Value(newUri),
            isMissing: const Value(false),
          ),
        );
    if (updated == 0) {
      throw MediaFileException('No library entry to relink: $stableId');
    }
  }

  /// Removes the library entry only — the file on disk is untouched (LIB-006).
  Future<void> removeEntry(String stableId) async {
    final external = stableId.startsWith('local:')
        ? stableId.substring(6)
        : stableId;
    await (_db.delete(
      _db.localTracks,
    )..where((t) => t.id.equals(external))).go();
  }

  /// Whole-library count for home summary.
  Future<int> count() async {
    final expr = _db.localTracks.id.count(
      filter: _db.localTracks.isMissing.equals(false),
    );
    final query = _db.selectOnly(_db.localTracks)..addColumns([expr]);
    final row = await query.getSingle();
    return row.read(expr) ?? 0;
  }

  Track _rowToTrack(LocalTrack row) {
    return Track(
      stableId: stableTrackId(SourceProvider.local, row.id),
      provider: SourceProvider.local,
      externalId: row.id,
      title: row.title,
      artist: row.artist ?? 'Unknown artist',
      album: row.album,
      artworkUrl: null,
      localUri: row.uri,
      durationMs: row.durationMs,
      genre: row.genre,
      isStreamable: !row.isMissing,
    );
  }
}
