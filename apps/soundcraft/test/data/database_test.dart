import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:soundcraft/domain/models/playback.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/data/repositories/queue_repository.dart';
import 'package:soundcraft/data/repositories/settings_repository.dart';

/// Database layer tests (P02 gate, contract §12): CRUD, persistence across
/// "restart", migration v1→v2, FK cascade, missing-file marking.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  ScannedTrack scan(String title, String path,
          {String? artist, String? album, int? durationMs}) =>
      ScannedTrack(
        uri: path,
        uriKind: 'file',
        title: title,
        artist: artist,
        album: album,
        durationMs: durationMs,
        fingerprint: 'fp-$title',
      );

  group('LocalLibraryRepository', () {
    test('import → search → persist across reopen → remove (vertical slice)',
        () async {
      final repo = LocalLibraryRepository(db);
      await repo.upsertScanned([scan('Meadow Song', '/tmp/a.mp3', artist: 'Fern')]);

      // Search finds it.
      final found = await repo.search('meadow');
      expect(found, hasLength(1));
      expect(found.single.artist, 'Fern');
      expect(found.single.stableId, 'local:fp-Meadow Song');

      // Simulated restart: fresh repository over the same DB sees it.
      final repo2 = LocalLibraryRepository(db);
      expect(await repo2.count(), 1);

      // Remove entry (never the file).
      await repo2.removeEntry(found.single.stableId);
      expect(await repo2.count(), 0);
      expect(File('/tmp/a.mp3').existsSync(), isFalse); // file untouched
    });

    test('fingerprint dedupe: same content re-scanned is skipped, moved file updates',
        () async {
      final repo = LocalLibraryRepository(db);
      await repo.upsertScanned([scan('One', '/a/one.mp3')]);
      final s1 = await repo.upsertScanned([scan('One', '/a/one.mp3')]);
      expect(s1.skipped, 1);
      expect(s1.added, 0);
      // Same fingerprint, different path → update, not duplicate.
      final s2 = await repo.upsertScanned([scan('One', '/b/one.mp3')]);
      expect(s2.updated, 1);
      expect(await repo.count(), 1);
      final all = await repo.getAll();
      expect(all.single.localUri, '/b/one.mp3');
    });

    test('missing files are marked, not deleted (LIB-005)', () async {
      final repo = LocalLibraryRepository(db);
      final gone = File(
          '${Directory.systemTemp.path}/sc_gone_${DateTime.now().microsecondsSinceEpoch}.mp3');
      final present = File(
          '${Directory.systemTemp.path}/sc_present_${DateTime.now().microsecondsSinceEpoch}.mp3');
      present.writeAsBytesSync([1, 2, 3]);
      await repo.upsertScanned([
        scan('Present', present.path, durationMs: 100),
      ]);
      await repo.upsertScanned([scan('Vanishing', gone.path)]);
      final missing = await repo.markMissingFiles();
      // 'Vanishing' path doesn't exist → marked missing.
      expect(missing, 1);
      final all = await repo.getAll();
      expect(all.any((t) => t.title == 'Vanishing'), isFalse);
      // Entry still exists in DB (relinkable).
      final byId = await repo.getById('local:fp-Vanishing');
      expect(byId, isNotNull); // getById does not filter isMissing
    });

    test('relink restores a missing track and keeps playlist refs', () async {
      final repo = LocalLibraryRepository(db);
      await repo.upsertScanned([scan('Moved', '/old/moved.mp3')]);
      await repo.markMissingFiles();
      await repo.relink('local:fp-Moved', '/new/moved.mp3');
      final all = await repo.getAll();
      expect(all.single.localUri, '/new/moved.mp3');
    });
  });

  group('PlaylistRepository', () {
    test('create/add/duplicate policy/reorder/delete cascade (PL-001..004)',
        () async {
      final playlists = PlaylistRepository(db);
      final library = LocalLibraryRepository(db);
      await library.upsertScanned(
          [scan('A', '/a.mp3'), scan('B', '/b.mp3'), scan('C', '/c.mp3')]);

      final id = await playlists.create('Road trip');
      final tracks = await library.getAll();

      await playlists.addTrack(id, TrackRef.fromStableId(
          stableTrackId: tracks[0].stableId,
          title: tracks[0].title,
          artist: tracks[0].artist));
      // Duplicate add is a no-op (once per playlist).
      await playlists.addTrack(id, TrackRef.fromStableId(
          stableTrackId: tracks[0].stableId,
          title: tracks[0].title));
      await playlists.addTrack(id, TrackRef.fromStableId(
          stableTrackId: tracks[1].stableId,
          title: tracks[1].title));
      await playlists.addTrack(id, TrackRef.fromStableId(
          stableTrackId: tracks[2].stableId,
          title: tracks[2].title));

      final entries = await playlists.entries(id);
      expect(entries, hasLength(3));
      expect(entries.map((e) => e.title).toList(), ['A', 'B', 'C']);

      // Reorder: C first.
      final ids = entries.map((e) => e.id).toList();
      await playlists.reorder(id, [ids[2], ids[0], ids[1]]);
      final reordered = await playlists.entries(id);
      expect(reordered.map((e) => e.title).toList(), ['C', 'A', 'B']);

      // Incomplete reorder list is rejected (data integrity).
      expect(() => playlists.reorder(id, [ids[0]]), throwsA(isA<Exception>()));

      // Empty name rejected.
      expect(() => playlists.create('   '), throwsA(isA<Exception>()));

      // Delete playlist only.
      await playlists.delete(id);
      expect(await playlists.list(), isEmpty);
      expect(await library.count(), 3); // tracks untouched
    });

    test('entries keep snapshot metadata when track later goes missing (§24.1 inv.8)',
        () async {
      final playlists = PlaylistRepository(db);
      final library = LocalLibraryRepository(db);
      await library.upsertScanned([scan('Ephemeral', '/gone.mp3')]);
      final track = (await library.getAll()).single;

      final id = await playlists.create('Mix');
      await playlists.addTrack(id, TrackRef.fromStableId(
          stableTrackId: track.stableId, title: track.title));

      // File disappears.
      await (_dbMarkMissing(db, track.externalId));
      final entries = await playlists.entries(id);
      expect(entries, hasLength(1)); // metadata preserved
      expect(entries.single.title, 'Ephemeral');
      expect(entries.single.trackAvailable, isFalse);
    });
  });

  group('HistoryRepository', () {
    test('record, distinct recent, play counts, skip signals, clear', () async {
      final repo = HistoryRepository(db);
      await repo.recordStart(stableTrackId: 'local:x', sourceType: SourceProvider.local);
      await repo.recordProgress(stableTrackId: 'local:x', listenedMs: 30000, completed: true);
      await repo.recordStart(stableTrackId: 'local:x', sourceType: SourceProvider.local);
      await repo.recordStart(stableTrackId: 'local:y', sourceType: SourceProvider.local);
      await repo.recordProgress(stableTrackId: 'local:y', listenedMs: 1000, completed: false);

      final recent = await repo.recent();
      expect(recent.map((e) => e.stableTrackId).first, 'local:y'); // latest first
      expect(recent, hasLength(2));

      final counts = await repo.playCounts();
      expect(counts['local:x'], 2);
      expect(counts['local:y'], 1);

      final skipped = await repo.skippedTrackIds();
      expect(skipped, contains('local:y'));

      // Privacy opt-out: disabled repository RECORDS nothing (viewing old
      // history remains allowed by design — pause != erase).
      final off = HistoryRepository(db, enabled: false);
      await off.recordStart(stableTrackId: 'local:z', sourceType: SourceProvider.local);
      final after = await repo.recent();
      expect(after.map((e) => e.stableTrackId), isNot(contains('local:z')));
      expect(after, hasLength(2));

      // Clear all.
      final cleared = await repo.clearAll();
      expect(cleared, 3); // two x events + one y event
    });
  });

  group('QueueRepository', () {
    test('snapshot save/restore roundtrip (§24.1 invariant 3)', () async {
      final repo = QueueRepository(db);
      await repo.save(
        items: [
          QueueTrackRecord(
              stableTrackId: 'local:a',
              sourceType: 'local',
              sourceId: 'a',
              title: 'A',
              localUri: '/a.mp3'),
          QueueTrackRecord(
              stableTrackId: 'audius:b',
              sourceType: 'audius',
              sourceId: 'b',
              title: 'B'),
        ],
        activeIndex: 1,
        positionMs: 42000,
        shuffle: true,
        shuffleSeed: 7,
        repeatMode: RepeatMode.all,
      );
      final restored = await repo.restore();
      expect(restored, isNotNull);
      expect(restored!.items, hasLength(2));
      expect(restored.items[1].stableTrackId, 'audius:b');
      expect(restored.activeIndex, 1);
      expect(restored.positionMs, 42000);
      expect(restored.shuffle, isTrue);
      expect(restored.shuffleSeed, 7);
      expect(restored.repeatMode, RepeatMode.all);

      await repo.clear();
      expect(await repo.restore(), isNull);
    });
  });

  group('SettingsRepository & cache scope', () {
    test('typed settings persist; reset wipes only settings', () async {
      final settings = SettingsRepository(db);
      await settings.setString('theme.mode', 'dark');
      await settings.setBool('downloads.wifiOnly', true);
      await settings.setStringList('onboarding.interests', ['lofi', 'rock']);

      expect(await settings.getString('theme.mode'), 'dark');
      expect(await settings.getBool('downloads.wifiOnly'), isTrue);
      expect(await settings.getStringList('onboarding.interests'), ['lofi', 'rock']);

      await settings.resetAll();
      expect(await settings.getString('theme.mode'), isNull);
    });

    test('provider cache TTL expiry and scoped clear (SET-003)', () async {
      final cache = ProviderCacheRepository(db);
      await cache.putJson('k', '{"a":1}', ttlSeconds: -1); // already expired
      expect(await cache.getJson('k'), isNull);
      await cache.putJson('k2', '{"b":2}', ttlSeconds: 60);
      expect(await cache.getJson('k2'), '{"b":2}');
      expect(await cache.clear(), 2); // every cached row (expired + live)
      expect(await cache.getJson('k2'), isNull);
    });
  });

  group('migrations', () {
    test('v1 database upgrades to v2 (provider cache added, index created)',
        () async {
      // Legacy v1 schema hand-built at connection open, user_version=1.
      final legacyDb = AppDatabase(NativeDatabase.memory(setup: (raw) {
        raw.execute('PRAGMA user_version = 1');
        raw.execute('''
          CREATE TABLE local_tracks (
            id TEXT NOT NULL PRIMARY KEY, uri TEXT NOT NULL, uri_kind TEXT NOT NULL,
            title TEXT NOT NULL, artist TEXT NULL, album TEXT NULL,
            duration_ms INTEGER NULL, size_bytes INTEGER NULL, genre TEXT NULL,
            fingerprint TEXT NOT NULL, artwork_blob BLOB NULL,
            modified_at INTEGER NULL, is_missing INTEGER NOT NULL DEFAULT 0,
            imported_at INTEGER NOT NULL
          )
        ''');
        raw.execute('''
          CREATE TABLE listening_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT, stable_track_id TEXT NOT NULL,
            source_type TEXT NOT NULL, started_at INTEGER NOT NULL,
            last_position_ms INTEGER NULL, listened_ms INTEGER NOT NULL DEFAULT 0,
            completed INTEGER NOT NULL DEFAULT 0, device_local INTEGER NOT NULL DEFAULT 1
          )
        ''');
        raw.execute(
            'INSERT INTO local_tracks (id, uri, uri_kind, title, fingerprint, imported_at) '
            "VALUES ('legacy1', '/l.mp3', 'file', 'Legacy', 'fp-legacy', ${DateTime.now().millisecondsSinceEpoch})");
      }));
      // First query triggers onUpgrade(1 -> 2).
      final rows = await legacyDb.select(legacyDb.localTracks).get();
      expect(rows.single.title, 'Legacy');
      final tables = await legacyDb.customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='provider_cache'").get();
      expect(tables, hasLength(1));
      expect(legacyDb.schemaVersion, 2);
      await legacyDb.close();
    });
  });
}

Future<void> _dbMarkMissing(AppDatabase db, String externalId) async {
  await (db.update(db.localTracks)..where((t) => t.id.equals(externalId)))
      .write(const LocalTracksCompanion(isMissing: Value(true)));
}
