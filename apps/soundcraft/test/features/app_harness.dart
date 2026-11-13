import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/app/app.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';

import '../fakes/fake_audio_platform.dart';

/// Shared harness for widget tests: real app (router + themes) over an
/// in-memory database and a fake audio engine. No network in these tests —
/// provider sections show their honest offline state.
class TestApp {
  static Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1.0,
    bool importFixture = false,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    final engine = FakeAudioPlatform();

    if (importFixture) {
      final repo = LocalLibraryRepository(db);
      await repo.upsertScanned([
        ScannedTrack(
          uri: '/fixtures/one.mp3',
          uriKind: 'file',
          title: 'Meadow Song',
          artist: 'Fern & The Petals',
          album: 'Spring Tapes',
          durationMs: 152000,
          fingerprint: 'fp-one',
        ),
        ScannedTrack(
          uri: '/fixtures/two.mp3',
          uriKind: 'file',
          title: 'Riverside Walk',
          artist: 'Fern & The Petals',
          album: 'Spring Tapes',
          durationMs: 203000,
          fingerprint: 'fp-two',
        ),
        ScannedTrack(
          uri: '/fixtures/three.mp3',
          uriKind: 'file',
          title: 'Cricket Lullaby',
          artist: 'Moss Choir',
          album: 'Evening Green',
          durationMs: 97000,
          fingerprint: 'fp-three',
        ),
      ]);
    }

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        audioEngineProvider.overrideWithValue(engine),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(playerCoordinatorProvider).restore();

    tester.view.physicalSize = size * tester.view.devicePixelRatio;
    tester.view.devicePixelRatio = 3.0;
    tester.view.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SoundCraftApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    return container;
  }
}

/// Exposes the fake engine used in a pumped app (for interaction assertions).
FakeAudioPlatform engineOf(ProviderContainer container) =>
    container.read(audioEngineProvider) as FakeAudioPlatform;
