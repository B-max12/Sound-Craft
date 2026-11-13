import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/app.dart';
import 'package:soundcraft/app/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';

/// Visual regression baselines (§27.1): the mandated width matrix, dark/light
/// themes, 200% text scale and an RTL smoke, for the primary shell surfaces.
///
/// Regenerate intentionally with:
///   flutter test --update-goldens test/goldens/goldens_test.dart
void main() {
  // light/dark + text scale matrix per contract §27.1.
  const widths = [320.0, 360.0, 390.0, 430.0, 600.0, 768.0, 1024.0, 1280.0, 1440.0];

  Future<ProviderContainer> pumpGolden(
    WidgetTester tester, {
    required Size size,
    ThemeMode mode = ThemeMode.dark,
    double textScale = 1.0,
    bool rtl = false,
    String initialLocation = '/home',
    bool importFixture = true,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    if (importFixture) {
      final repo = LocalLibraryRepository(db);
      await repo.upsertScanned([
        ScannedTrack(
          uri: '/f/1.mp3', uriKind: 'file', title: 'Meadow Song',
          artist: 'Fern & The Petals', album: 'Spring Tapes',
          durationMs: 152000, fingerprint: 'g1',
        ),
        ScannedTrack(
          uri: '/f/2.mp3', uriKind: 'file', title: 'Riverside Walk',
          artist: 'Fern & The Petals', album: 'Spring Tapes',
          durationMs: 203000, fingerprint: 'g2',
        ),
      ]);
    }
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        connectivityProvider.overrideWith((ref) => Stream.value(false)),
      ],
    );
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size * 1.0;
    tester.view.platformDispatcher.textScaleFactorTestValue = textScale;
    if (rtl) {
      tester.view.platformDispatcher.localesTestValue = const [Locale('ar')];
    }
    container.read(appRouterProvider).go(initialLocation);

    // Drive the appearance controller BEFORE first pump for determinism.
    if (mode == ThemeMode.light) {
      unawaited(container.read(appearanceProvider.notifier).setMode(ThemeMode.light));
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SoundCraftApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    return container;
  }

  void goldenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
    });
  }

  for (final width in widths) {
    for (final mode in [ThemeMode.dark, ThemeMode.light]) {
      goldenTest('shell home ${width.round()}px ${mode.name}', (tester) async {
        final container = await pumpGolden(
          tester,
          size: Size(width, 1000),
          mode: mode,
        );
        addTearDown(container.dispose);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/home_${width.round()}_${mode.name}.png'),
        );
      });
    }
  }

  goldenTest('library dark 390px', (tester) async {
    final container =
        await pumpGolden(tester, size: const Size(390, 1000), initialLocation: '/library');
    addTearDown(container.dispose);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_390_dark.png'),
    );
  });

  goldenTest('library dark 390px 200% text scale', (tester) async {
    final container = await pumpGolden(
      tester,
      size: const Size(390, 1000),
      textScale: 2.0,
      initialLocation: '/library',
    );
    addTearDown(container.dispose);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_390_dark_200scale.png'),
    );
  });

  goldenTest('library RTL smoke 390px dark', (tester) async {
    final container = await pumpGolden(
      tester,
      size: const Size(390, 1000),
      rtl: true,
      initialLocation: '/library',
    );
    addTearDown(container.dispose);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_390_rtl.png'),
    );
  });
}
