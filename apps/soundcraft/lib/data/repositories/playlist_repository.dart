import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

/// Playlist aggregate returned to the domain/UI layer.
class PlaylistSummary {
  PlaylistSummary({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.entryCount,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int entryCount;
}

/// A playlist entry joined with its snapshot metadata (works even if the
/// referenced track later disappears — §3.9 referential integrity).
class PlaylistEntryView {
  PlaylistEntryView({
    required this.id,
    required this.ordinal,
    required this.stableTrackId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artist,
    this.durationMs,
    required this.trackAvailable,
  });

  final String id;
  final int ordinal;
  final String stableTrackId;
  final SourceProvider sourceType;
  final String sourceId;
  final String title;
  final String? artist;
  final int? durationMs;
  final bool trackAvailable;
}

/// Playlists CRUD (P04 / PL-001..PL-005). All writes are transactional.
class PlaylistRepository {
  PlaylistRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<List<PlaylistSummary>> list() async {
    final countExpr = _db.playlistEntries.id.count();
    final query =
        _db.select(_db.playlists).join([
            leftOuterJoin(
              _db.playlistEntries,
              _db.playlistEntries.playlistId.equalsExp(_db.playlists.id),
            ),
          ])
          ..addColumns([countExpr])
          ..groupBy([_db.playlists.id])
          ..orderBy([OrderingTerm.desc(_db.playlists.updatedAt)]);
    final rows = await query.map((row) {
      final pl = row.readTable(_db.playlists);
      final count = row.read(countExpr) ?? 0;
      return PlaylistSummary(
        id: pl.id,
        title: pl.title,
        description: pl.description,
        createdAt: pl.createdAt,
        updatedAt: pl.updatedAt,
        entryCount: count,
      );
    }).get();
    return rows;
  }

  Future<PlaylistSummary?> getById(String id) async {
    final row = await (_db.select(
      _db.playlists,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final countExpr = _db.playlistEntries.id.count();
    final q = _db.selectOnly(_db.playlistEntries)
      ..addColumns([countExpr])
      ..where(_db.playlistEntries.playlistId.equals(id));
    final count = await q.getSingle().then((r) => r.read(countExpr) ?? 0);
    return PlaylistSummary(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      entryCount: count,
    );
  }

  /// Creates a playlist. Duplicate names are allowed but validated non-empty.
  Future<String> create(String title, {String? description}) async {
    final name = title.trim();
    if (name.isEmpty) {
      throw const PersistenceException('Playlist name cannot be empty');
    }
    if (name.length > 120) {
      throw const PersistenceException('Playlist name is too long (max 120)');
    }
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db
        .into(_db.playlists)
        .insert(
          PlaylistsCompanion.insert(
            id: id,
            title: name,
            description: Value(description?.trim()),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> rename(String id, String title, {String? description}) async {
    if (title.trim().isEmpty) {
      throw const PersistenceException('Playlist name cannot be empty');
    }
    final updated =
        await (_db.update(_db.playlists)..where((p) => p.id.equals(id))).write(
          PlaylistsCompanion(
            title: Value(title.trim()),
            description: Value(description?.trim()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    if (updated == 0) throw PersistenceException('Playlist not found: $id');
  }

  /// Appends a track (snapshot metadata recorded). Duplicate policy: the same
  /// stable id may appear once per playlist (PL-002).
  Future<void> addTrack(String playlistId, TrackRef ref) async {
    await _db.transaction(() async {
      final existing =
          await (_db.select(_db.playlistEntries)..where(
                (e) =>
                    e.playlistId.equals(playlistId) &
                    e.stableTrackId.equals(ref.stableTrackId),
              ))
              .getSingleOrNull();
      if (existing != null) return;
      final ordinalExpr = _db.playlistEntries.ordinal.max();
      final q = _db.selectOnly(_db.playlistEntries)
        ..addColumns([ordinalExpr])
        ..where(_db.playlistEntries.playlistId.equals(playlistId));
      final maxOrdinal = (await q.getSingle()).read(ordinalExpr) ?? -1;
      await _db
          .into(_db.playlistEntries)
          .insert(
            PlaylistEntriesCompanion.insert(
              id: _uuid.v4(),
              playlistId: playlistId,
              stableTrackId: ref.stableTrackId,
              sourceType: ref.sourceType.id,
              sourceId: ref.sourceId,
              ordinal: maxOrdinal + 1,
              addedAt: DateTime.now(),
              fallbackTitle: ref.fallbackTitle,
              fallbackArtist: Value(ref.fallbackArtist),
              fallbackDurationMs: Value(ref.fallbackDurationMs),
            ),
          );
      await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId)))
          .write(PlaylistsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  Future<void> removeEntry(String entryId) async {
    final entry = await (_db.select(
      _db.playlistEntries,
    )..where((e) => e.id.equals(entryId))).getSingleOrNull();
    if (entry == null) return;
    await _db.transaction(() async {
      await (_db.delete(
        _db.playlistEntries,
      )..where((e) => e.id.equals(entryId))).go();
      await _resequence(entry.playlistId);
    });
  }

  /// Reorders by dragging [orderedEntryIds]; validates completeness.
  Future<void> reorder(String playlistId, List<String> orderedEntryIds) async {
    await _db.transaction(() async {
      final entries = await (_db.select(
        _db.playlistEntries,
      )..where((e) => e.playlistId.equals(playlistId))).get();
      final currentIds = entries.map((e) => e.id).toSet();
      if (currentIds.length != orderedEntryIds.length ||
          !orderedEntryIds.every(currentIds.contains)) {
        throw const PersistenceException(
          'Reorder list does not match playlist entries',
        );
      }
      for (var i = 0; i < orderedEntryIds.length; i++) {
        await (_db.update(_db.playlistEntries)
              ..where((e) => e.id.equals(orderedEntryIds[i])))
            .write(PlaylistEntriesCompanion(ordinal: Value(i)));
      }
      await (_db.update(_db.playlists)..where((p) => p.id.equals(playlistId)))
          .write(PlaylistsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  /// Deletes the playlist only — audio files are never touched (PL-004).
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.playlistEntries,
      )..where((e) => e.playlistId.equals(id))).go();
      await (_db.delete(_db.playlists)..where((p) => p.id.equals(id))).go();
    });
  }

  /// Entries joined with availability info from the local table when present.
  Future<List<PlaylistEntryView>> entries(String playlistId) async {
    final rows =
        await (_db.select(_db.playlistEntries).join([
                leftOuterJoin(
                  _db.localTracks,
                  _db.localTracks.id.equalsExp(
                        _db.playlistEntries.stableTrackId,
                      ) |
                      _db.localTracks.id.equalsExp(
                        _db.playlistEntries.sourceId,
                      ),
                ),
              ])
              ..where(_db.playlistEntries.playlistId.equals(playlistId))
              ..orderBy([OrderingTerm.asc(_db.playlistEntries.ordinal)]))
            .get();
    return rows.map((row) {
      final e = row.readTable(_db.playlistEntries);
      final local = row.readTableOrNull(_db.localTracks);
      final available = e.sourceType == 'local'
          ? local != null && !local.isMissing
          : true;
      return PlaylistEntryView(
        id: e.id,
        ordinal: e.ordinal,
        stableTrackId: e.stableTrackId,
        sourceType: SourceProviderX.fromId(e.sourceType),
        sourceId: e.sourceId,
        title: e.fallbackTitle,
        artist: e.fallbackArtist,
        durationMs: e.fallbackDurationMs,
        trackAvailable: available,
      );
    }).toList();
  }

  Future<void> _resequence(String playlistId) async {
    final entries =
        await (_db.select(_db.playlistEntries)
              ..where((e) => e.playlistId.equals(playlistId))
              ..orderBy([(e) => OrderingTerm.asc(e.ordinal)]))
            .get();
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].ordinal != i) {
        await (_db.update(_db.playlistEntries)
              ..where((e) => e.id.equals(entries[i].id)))
            .write(PlaylistEntriesCompanion(ordinal: Value(i)));
      }
    }
  }
}

/// Value object describing a track reference to store in a playlist.
class TrackRef {
  const TrackRef({
    required this.stableTrackId,
    required this.sourceType,
    required this.sourceId,
    required this.fallbackTitle,
    this.fallbackArtist,
    this.fallbackDurationMs,
  });

  final String stableTrackId;
  final SourceProvider sourceType;
  final String sourceId;
  final String fallbackTitle;
  final String? fallbackArtist;
  final int? fallbackDurationMs;

  static TrackRef fromStableId({
    required String stableTrackId,
    required String title,
    String? artist,
    int? durationMs,
  }) {
    final parsed = parseStableTrackId(stableTrackId);
    return TrackRef(
      stableTrackId: stableTrackId,
      sourceType: parsed.provider,
      sourceId: parsed.externalId,
      fallbackTitle: title,
      fallbackArtist: artist,
      fallbackDurationMs: durationMs,
    );
  }
}

/// Favorites (Liked Songs). Offline-first; optimistic UI rolls back on failure.
class FavoritesRepository {
  FavoritesRepository(this._db);

  final AppDatabase _db;

  Future<bool> isFavorite(String stableTrackId) async {
    final row = await (_db.select(
      _db.favorites,
    )..where((f) => f.id.equals(stableTrackId))).getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> allIds() async =>
      (await _db.select(_db.favorites).get()).map((e) => e.id).toSet();

  Future<void> add(TrackRef ref) async {
    await _db
        .into(_db.favorites)
        .insertOnConflictUpdate(
          FavoritesCompanion.insert(
            id: ref.stableTrackId,
            addedAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(String stableTrackId) async {
    await (_db.delete(
      _db.favorites,
    )..where((f) => f.id.equals(stableTrackId))).go();
  }

  /// Toggle; returns the new state.
  Future<bool> toggle(TrackRef ref) async {
    if (await isFavorite(ref.stableTrackId)) {
      await remove(ref.stableTrackId);
      return false;
    }
    await add(ref);
    return true;
  }

  /// All favorite entries as playlist-like views (Liked Songs is a real list).
  Future<List<TrackRef>> all() async {
    final rows = await (_db.select(
      _db.favorites,
    )..orderBy([(f) => OrderingTerm.desc(f.addedAt)])).get();
    return rows
        .map(
          (r) => TrackRef.fromStableId(
            stableTrackId: r.id,
            title: r.id, // title resolved by caller from live sources
          ),
        )
        .toList();
  }
}
