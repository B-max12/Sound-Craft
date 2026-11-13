import 'dart:io';

import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Local tracks imported by the user (§24.2 LocalTrack).
class LocalTracks extends Table {
  TextColumn get id => text()(); // stable id: local:<fingerprint[:12]>
  TextColumn get uri => text()(); // file path / content URI
  TextColumn get uriKind => text()(); // 'file' | 'content' | 'bytes'
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get fingerprint => text()(); // content hash for dedupe
  BlobColumn get artworkBlob => blob().nullable()(); // capped thumbnail
  DateTimeColumn get modifiedAt => dateTime().nullable()();
  BoolColumn get isMissing => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {fingerprint},
  ];
}

/// User-created playlists (§6.1 Playlist).
class Playlists extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Playlist entries with snapshot metadata so lists survive missing files
/// (§3.9, §24.1 invariant 8). Deletion of a track never cascades here.
class PlaylistEntries extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get playlistId =>
      text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get stableTrackId => text()();
  TextColumn get sourceType => text()(); // provider id
  TextColumn get sourceId => text()();
  IntColumn get ordinal => integer()();
  DateTimeColumn get addedAt => dateTime()();
  TextColumn get fallbackTitle => text()();
  TextColumn get fallbackArtist => text().nullable()();
  IntColumn get fallbackDurationMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Favorites extends Table {
  TextColumn get id => text()(); // stable track id
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Per-track local listening events (§3.13). Device-local by default.
class ListeningHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stableTrackId => text()();
  TextColumn get sourceType => text()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get lastPositionMs => integer().nullable()();
  IntColumn get listenedMs => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get deviceLocal => boolean().withDefault(const Constant(true))();
}

class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  DateTimeColumn get at => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {query},
  ];
}

/// Download jobs — URLs are resolved just-in-time and never persisted here
/// (§6.1/§6.3: signed/temporary URLs stay out of the DB).
class DownloadJobs extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get stableTrackId => text()();
  TextColumn get provider => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get targetPath => text()();
  TextColumn get tempPath => text()();
  IntColumn get bytesTotal => integer().nullable()();
  IntColumn get bytesWritten => integer().withDefault(const Constant(0))();
  TextColumn get state =>
      text()(); // queued|running|paused|completed|failed|cancelled
  TextColumn get errorCode => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  BoolColumn get canResume => boolean().withDefault(const Constant(false))();
  TextColumn get permissionProof => text()(); // auditable evidence string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Persisted queue (§6.1 QueueSnapshot). Meta row id is always 1.
class QueueMeta extends Table {
  IntColumn get id => integer()();
  IntColumn get activeIndex => integer().withDefault(const Constant(0))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get shuffle => boolean().withDefault(const Constant(false))();
  IntColumn get shuffleSeed => integer().nullable()();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class QueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ordinal => integer()();
  TextColumn get stableTrackId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get artworkUrl => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get localUri => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get jsonValue => text()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get modifiedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Watched/imported folder registrations (desktop + SAF fallback metadata).
class ImportedFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accessUri => text().unique()();
  BoolColumn get recursive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScanAt => dateTime().nullable()();
}

/// Provider discovery cache with TTL metadata (§6.2 provider_cache_metadata).
/// Never stores signed stream URLs — only metadata permitted for caching.
class ProviderCache extends Table {
  TextColumn get key => text()();
  TextColumn get json => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  IntColumn get ttlSeconds => integer().withDefault(const Constant(300))();

  @override
  Set<Column> get primaryKey => {key};
}

/// Validates that [dir] exists (used by desktop import flows).
bool ensureDirectoryExists(String path) => Directory(path).existsSync();

/// SoundCraft local database (contract §24.2).
///
/// Migration policy:
///  * `schemaVersion` moves forward only.
///  * Every version bump adds a `MigrationStep` in [AppDatabase._migrations]
///    with a plain-Dart transformation; steps are individually tested.
///  * `onCreate` builds the latest schema; `onUpgrade` replays steps.
///  * Web uses [WasmDatabase]; native uses a background [NativeDatabase].
@DriftDatabase(
  tables: [
    LocalTracks,
    Playlists,
    PlaylistEntries,
    Favorites,
    ListeningHistory,
    RecentSearches,
    DownloadJobs,
    QueueMeta,
    QueueItems,
    Settings,
    ImportedFolders,
    ProviderCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      for (var v = from; v < to; v++) {
        final step = _migrations[v];
        if (step != null) await step(this, m);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  /// v1 → v2: provider discovery cache added (indexed), history indexes.
  static final Map<int, Future<void> Function(AppDatabase db, Migrator m)>
  _migrations = {
    1: (db, m) async {
      await m.createTable(db.providerCache);
      await db.customStatement(
        'CREATE INDEX IF NOT EXISTS listening_history_track_idx ON listening_history (stable_track_id)',
      );
    },
  };
}
