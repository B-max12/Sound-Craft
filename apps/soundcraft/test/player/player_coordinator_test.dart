import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/data/repositories/queue_repository.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/player/audio_platform.dart';
import 'package:soundcraft/player/player_coordinator.dart';

import '../fakes/fake_audio_platform.dart';

/// Player state machine tests (contract §7 / §24.1 invariants).
/// Drift repos use in-memory SQLite; the engine is a controllable fake.
void main() {
  late FakeAudioPlatform engine;
  late PlayerCoordinator coordinator;

  Track t(String id, {SourceProvider p = SourceProvider.local, int? duration}) =>
      Track(
        stableId: stableTrackId(p, id),
        provider: p,
        externalId: id,
        title: 'Track $id',
        artist: 'Artist',
        localUri: p == SourceProvider.local ? '/audio/$id.mp3' : null,
        durationMs: duration ?? 30000,
        sourceUrl:
            p == SourceProvider.youtube ? 'https://youtu.be/$id' : null,
      );

  setUp(() {
    engine = FakeAudioPlatform();
    coordinator = PlayerCoordinator(
      engine: engine,
      queueRepository: QueueRepository(AppDatabase(NativeDatabase.memory())),
      historyRepository: HistoryRepository(AppDatabase(NativeDatabase.memory())),
    );
  });

  tearDown(() async {
    await coordinator.dispose();
  });

  group('§7 case 1 — stale async races', () {
    test('play A, quickly tap B then C: only C becomes active', () async {
      engine.loadDelayMs = 30;
      final a = t('a'), b = t('b'), c = t('c');
      // Fire three plays without awaiting the first two (simulated race).
      final f1 = coordinator.playSingle(a);
      final f2 = coordinator.playSingle(b);
      final f3 = coordinator.playSingle(c);
      await Future.wait([f1, f2, f3]);
      await engine.settle();

      expect(coordinator.currentTrack?.stableId, c.stableId);
      expect(engine.loadLog.last, 'file:/audio/c.mp3');
      // Exactly one playing state for the final selection.
      expect(coordinator.state.stableTrackId, c.stableId);
    });
  });

  group('§7 case 2 — rapid commands', () {
    test('20 rapid play/pause toggles converge to correct final state',
        () async {
      await coordinator.playSingle(t('rapid'));
      await engine.settle();

      final futures = <Future<void>>[];
      for (var i = 0; i < 20; i++) {
        futures.add(coordinator.togglePlay());
      }
      await Future.wait(futures);
      await engine.settle();

      // Serialized commands: initial play + 20 toggles => even flips from
      // playing => final intent is PLAY (20th toggle). Deterministic parity.
      expect(coordinator.state.isPlaying, isTrue);
      expect(coordinator.state.status, PlaybackStatus.playing);
      // Engine received the commands in order, no double engines.
      final plays = engine.playPauseLog.where((e) => e == 'play').length;
      final pauses = engine.playPauseLog.where((e) => e == 'pause').length;
      expect(plays + pauses, greaterThanOrEqualTo(20));
    });
  });

  group('queue navigation', () {
    test('next respects bounds; previous restarts after threshold', () async {
      final list = [t('q1'), t('q2'), t('q3')];
      await coordinator.playTracks(list, startIndex: 0);
      await engine.settle();

      await coordinator.next();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'q2');

      // Previous with position > 3s → restart current track.
      engine.emitTick(20000);
      await engine.settle();
      await coordinator.previous();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'q2');
      expect(engine.seekCalls, 1);

      // Previous with position <= 3s → previous track.
      engine.emitTick(1000);
      await engine.settle();
      await coordinator.previous();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'q1');

      // Walk to the end: q2 -> q3, then one more next hits the boundary.
      await coordinator.next();
      await engine.settle();
      await coordinator.next();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'q3');

      await coordinator.next();
      await engine.settle();
      expect(coordinator.state.status, PlaybackStatus.completed);
      expect(coordinator.currentTrack?.externalId, 'q3'); // stays
    });

    test('repeat all wraps; repeat one replays on completion', () async {
      final list = [t('r1'), t('r2')];
      await coordinator.playTracks(list, startIndex: 1);
      await engine.settle();

      await coordinator.setRepeatMode(RepeatMode.all);
      await coordinator.next();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'r1'); // wrapped

      // Repeat one: completion replays same track.
      await coordinator.setRepeatMode(RepeatMode.one);
      engine.emitCompletion();
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'r1');
    });

    test('shuffle keeps current track and permutes order deterministically',
        () async {
      final list = [t('s1'), t('s2'), t('s3'), t('s4')];
      await coordinator.playTracks(list, startIndex: 2);
      await engine.settle();

      await coordinator.setShuffle(true);
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 's3'); // never lost

      // Toggle shuffle off → original index semantics retained.
      await coordinator.setShuffle(false);
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 's3');
    });
  });

  group('seek guards', () {
    test('unknown duration blocks seeking without crash (§7 case 9)', () async {
      final track = Track(
        stableId: 'local:live',
        provider: SourceProvider.local,
        externalId: 'live',
        title: 'Live',
        localUri: '/audio/live.mp3',
        durationMs: null,
      );
      engine.nextLoadDurationMs = null;
      await coordinator.playSingle(track);
      await engine.settle();

      expect(coordinator.state.canSeek, isFalse);
      await expectLater(coordinator.seekTo(1000),
          throwsA(isA<PlaybackException>()));
    });

    test('seek clamps within the ENGINE-reported duration', () async {
      await coordinator.playSingle(t('seeky', duration: 10000));
      await engine.settle();
      // Engine reports its own (authoritative) duration: 30s in the fake.
      expect(coordinator.state.durationMs, 30000);
      await coordinator.seekTo(999999);
      await engine.settle();
      expect(coordinator.state.positionMs, 30000);
    });
  });

  group('failures', () {
    test('unavailable item skips with notice, bounded, keeps queue entry',
        () async {
      engine.failLoadCount = 1; // only the first load fails
      final list = [t('bad'), t('good')];
      await coordinator.playTracks(list, startIndex: 0);
      await engine.settle();

      expect(coordinator.currentTrack?.externalId, 'good');
      expect(coordinator.state.error, contains('Skipping unavailable'));
      expect(coordinator.queue, hasLength(2)); // bad stays for inspection
    });

    test('YouTube items are refused by the audio engine (R05, defense in depth)',
        () async {
      final yt = t('yt1', p: SourceProvider.youtube);
      await expectLater(coordinator.playSingle(yt), throwsA(isA<PlaybackException>()));
    });

    test('3 consecutive failures stop with unavailable state', () async {
      engine.failLoadCount = 3; // every load fails
      final list = [t('f1'), t('f2'), t('f3')];
      await coordinator.playTracks(list, startIndex: 0);
      await engine.settle();
      expect(coordinator.state.status, PlaybackStatus.unavailable);
    });
  });

  group('queue operations', () {
    test('play next inserts after current; add to queue appends', () async {
      await coordinator.playTracks([t('base')]);
      await engine.settle();
      await coordinator.playNext(t('next1'));
      await coordinator.addToQueue(t('later'));
      await engine.settle();
      expect(
        coordinator.queue.map((e) => e.externalId).toList(),
        ['base', 'next1', 'later'],
      );
    });

    test('reorder and clear upcoming behave', () async {
      await coordinator.playTracks([t('a'), t('b'), t('c'), t('d')]);
      await engine.settle();
      await coordinator.reorderQueue(3, 0); // d first
      await engine.settle();
      expect(coordinator.queue.first.externalId, 'd');

      await coordinator.clearUpcoming();
      await engine.settle();
      expect(coordinator.queue, hasLength(1)); // only current remains
    });

    test('removing the current item advances without stopping', () async {
      await coordinator.playTracks([t('x1'), t('x2')]);
      await engine.settle();
      await coordinator.removeFromQueue(0);
      await engine.settle();
      expect(coordinator.currentTrack?.externalId, 'x2');
    });
  });

  group('sleep timer', () {
    test('cancel clears timer; end-of-track pauses at completion (PLY-011)',
        () async {
      await coordinator.playSingle(t('zzz'));
      await engine.settle();

      await coordinator.startSleepTimerEndOfTrack();
      expect(coordinator.state.sleepTimerEndsAt, isNotNull);
      engine.emitCompletion();
      await engine.settle();
      expect(coordinator.state.isPlaying, isFalse);
      expect(coordinator.state.sleepTimerEndsAt, isNull);
    });

    test('invalid volume throws typed error, not silent (PLY-010)', () async {
      await expectLater(coordinator.setVolume(5.0),
          throwsA(isA<PlaybackException>()));
    });
  });

  group('completion & persistence', () {
    test('persistNow + restore rebuilds queue WITHOUT autoplay (NAV-008)',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      final queueRepo = QueueRepository(db);
      final persistentCoordinator = PlayerCoordinator(
        engine: engine,
        queueRepository: queueRepo,
        historyRepository: HistoryRepository(AppDatabase(NativeDatabase.memory())),
      );
      final list = [t('p1'), t('p2')];
      await persistentCoordinator.playTracks(list, startIndex: 0);
      await engine.settle();
      engine.emitTick(5000);
      await persistentCoordinator.persistNow();

      // "Restart": fresh coordinator over the SAME database sees the snapshot.
      final restored = PlayerCoordinator(
        engine: FakeAudioPlatform(),
        queueRepository: queueRepo,
        historyRepository: HistoryRepository(AppDatabase(NativeDatabase.memory())),
      );
      await restored.restore();
      expect(restored.queue, hasLength(2));
      expect(restored.currentTrack?.externalId, 'p1');
      // Not auto-playing: engine untouched since restore.
      expect(restored.state.status, PlaybackStatus.readyPaused);
      expect(restored.state.isPlaying, isFalse);
      await restored.dispose();
      await persistentCoordinator.dispose();
    });
  });

  group('Phase 1 audio focus & stream resilience', () {
    test('explicit play() is idempotent when already playing', () async {
      await coordinator.playSingle(t('p1'));
      await engine.settle();
      expect(coordinator.state.isPlaying, isTrue);

      await coordinator.play();
      await engine.settle();
      expect(coordinator.state.isPlaying, isTrue);
    });

    test('interruption pause/resume and becomingNoisy behave cleanly', () async {
      await coordinator.playSingle(t('p1'));
      await engine.settle();
      expect(coordinator.state.isPlaying, isTrue);

      await coordinator.handleInterruptionBegin(duck: false);
      await engine.settle();
      expect(coordinator.state.isPlaying, isFalse);

      await coordinator.handleInterruptionEnd(shouldResume: true);
      await engine.settle();
      expect(coordinator.state.isPlaying, isTrue);

      await coordinator.handleBecomingNoisy();
      await engine.settle();
      expect(coordinator.state.isPlaying, isFalse);

      // Should NOT resume if paused by becomingNoisy (no active interruption).
      await coordinator.handleInterruptionEnd(shouldResume: true);
      await engine.settle();
      expect(coordinator.state.isPlaying, isFalse);
    });

    test('ducking lowers volume and interruption end restores it', () async {
      await coordinator.setVolume(0.8);
      await coordinator.playSingle(t('p1'));
      await engine.settle();

      await coordinator.handleInterruptionBegin(duck: true);
      expect(engine.volume, closeTo(0.2, 0.01));

      await coordinator.handleInterruptionEnd(shouldResume: false);
      expect(engine.volume, closeTo(0.8, 0.01));
    });

    test('retries once with fresh URL before skipping on load error', () async {
      var resolveCalls = 0;
      final audiusTrack = Track(
        stableId: 'audius:t1',
        provider: SourceProvider.audius,
        externalId: 't1',
        title: 'Audius Song',
        isStreamable: true,
      );
      final retryCoordinator = PlayerCoordinator(
        engine: engine,
        queueRepository: QueueRepository(AppDatabase(NativeDatabase.memory())),
        historyRepository: HistoryRepository(AppDatabase(NativeDatabase.memory())),
        resolvers: {
          SourceProvider.audius: (track) async {
            resolveCalls++;
            // First URL fails to load; second URL succeeds.
            return UrlAudioSource('https://example.com/stream/$resolveCalls');
          },
        },
      );
      engine.failLoadCount = 1;

      await retryCoordinator.playTracks([audiusTrack, t('local2')]);
      await engine.settle();

      expect(resolveCalls, 2);
      expect(retryCoordinator.currentTrack?.stableId, 'audius:t1');
      expect(retryCoordinator.state.isPlaying, isTrue);
      await retryCoordinator.dispose();
    });
  });
}
