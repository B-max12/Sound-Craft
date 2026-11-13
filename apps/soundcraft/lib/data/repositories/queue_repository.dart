import 'package:drift/drift.dart';
import 'package:soundcraft/domain/models/playback.dart';

import '../app_database.dart';

/// Persisted queue snapshot so restart restores queue+position without
/// auto-playing (§24.1 invariant 3, NAV-008).
class QueueRepository {
  QueueRepository(this._db);

  final AppDatabase _db;

  Future<void> save({
    required List<QueueTrackRecord> items,
    required int activeIndex,
    required int positionMs,
    required bool shuffle,
    required int? shuffleSeed,
    required RepeatMode repeatMode,
  }) async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      await _db.delete(_db.queueMeta).go();
      await _db
          .into(_db.queueMeta)
          .insert(
            QueueMetaCompanion.insert(
              id: const Value(1),
              activeIndex: Value(activeIndex),
              positionMs: Value(positionMs),
              shuffle: Value(shuffle),
              shuffleSeed: Value(shuffleSeed),
              repeatMode: Value(repeatMode.name),
              savedAt: DateTime.now(),
            ),
          );
      for (var i = 0; i < items.length; i++) {
        await _db
            .into(_db.queueItems)
            .insert(
              QueueItemsCompanion.insert(
                ordinal: i,
                stableTrackId: items[i].stableTrackId,
                sourceType: items[i].sourceType,
                sourceId: items[i].sourceId,
                title: items[i].title,
                artist: Value(items[i].artist),
                artworkUrl: Value(items[i].artworkUrl),
                durationMs: Value(items[i].durationMs),
                localUri: Value(items[i].localUri),
                sourceUrl: Value(items[i].sourceUrl),
              ),
            );
      }
    });
  }

  /// Restores the snapshot; null when nothing was persisted.
  Future<QueueSnapshotRecord?> restore() async {
    final meta = await _db.select(_db.queueMeta).getSingleOrNull();
    if (meta == null) return null;
    final items = await (_db.select(
      _db.queueItems,
    )..orderBy([(i) => OrderingTerm.asc(i.ordinal)])).get();
    return QueueSnapshotRecord(
      items: items
          .map(
            (e) => QueueTrackRecord(
              stableTrackId: e.stableTrackId,
              sourceType: e.sourceType,
              sourceId: e.sourceId,
              title: e.title,
              artist: e.artist,
              artworkUrl: e.artworkUrl,
              durationMs: e.durationMs,
              localUri: e.localUri,
              sourceUrl: e.sourceUrl,
            ),
          )
          .toList(),
      activeIndex: meta.activeIndex,
      positionMs: meta.positionMs,
      shuffle: meta.shuffle,
      shuffleSeed: meta.shuffleSeed,
      repeatMode: RepeatMode.values.firstWhere(
        (r) => r.name == meta.repeatMode,
        orElse: () => RepeatMode.off,
      ),
      savedAt: meta.savedAt,
    );
  }

  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      await _db.delete(_db.queueMeta).go();
    });
  }
}

class QueueTrackRecord {
  const QueueTrackRecord({
    required this.stableTrackId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artist,
    this.artworkUrl,
    this.durationMs,
    this.localUri,
    this.sourceUrl,
  });

  final String stableTrackId;
  final String sourceType;
  final String sourceId;
  final String title;
  final String? artist;
  final String? artworkUrl;
  final int? durationMs;
  final String? localUri;
  final String? sourceUrl;
}

class QueueSnapshotRecord {
  const QueueSnapshotRecord({
    required this.items,
    required this.activeIndex,
    required this.positionMs,
    required this.shuffle,
    required this.shuffleSeed,
    required this.repeatMode,
    required this.savedAt,
  });

  final List<QueueTrackRecord> items;
  final int activeIndex;
  final int positionMs;
  final bool shuffle;
  final int? shuffleSeed;
  final RepeatMode repeatMode;
  final DateTime savedAt;
}
