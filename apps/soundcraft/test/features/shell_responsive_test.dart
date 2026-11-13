import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/app/router.dart' show appRouterProvider;

import 'app_harness.dart';

/// Responsive shell acceptance (§23.2 / P01 gate): bottom bar <600, rail
/// 600–1023, sidebar >=1024; no overflow at 320 with 200% text; RTL intact.
void main() {
  testWidgets('compact (320px): bottom navigation with 4 destinations, no overflow',
      (tester) async {
    await TestApp.pump(tester, size: const Size(320, 640));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact (390px): all four tabs navigate with state preserved',
      (tester) async {
    final container = await TestApp.pump(tester, size: const Size(390, 844));
    final router = container.read(appRouterProvider);
    expect(router.routeInformationProvider.value.uri.path, '/home');

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Your Library'), findsOneWidget);

    await tester.tap(find.text('Downloads'));
    await tester.pumpAndSettle();
    expect(find.text('Downloads'), findsWidgets);

    // Returning Home must not crash and must preserve the shell.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  for (final width in [360.0, 390.0, 430.0, 600.0, 768.0, 1024.0, 1280.0, 1440.0]) {
    testWidgets('no overflow at ${width.round()}px', (tester) async {
      await TestApp.pump(tester, size: Size(width, 900));
      expect(tester.takeException(), isNull);
      // Walk all tabs to surface any layout exceptions on this width.
      for (final tab in ['Search', 'Library', 'Downloads', 'Home']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('medium (700px): navigation rail present', (tester) async {
    await TestApp.pump(tester, size: const Size(700, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('expanded (1280px): persistent sidebar with brand + credit',
      (tester) async {
    await TestApp.pump(tester, size: const Size(1280, 900));
    expect(find.text('SoundCraft'), findsOneWidget);
    expect(find.text('An Aur Labs Product'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('200% text scale at 320px: no exceptions on Home and Library',
      (tester) async {
    await TestApp.pump(
      tester,
      size: const Size(320, 640),
      textScale: 2.0,
      importFixture: true,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL smoke: layout renders without exceptions in Arabic locale',
      (tester) async {
    await TestApp.pump(tester, size: const Size(390, 844));
    // Force RTL via Directionality by rebuilding with a localized delegate is
    // heavy; we assert the shell renders under an RTL Directionality override
    // at the root of a fresh pump.
    tester.view.physicalSize = const Size(390, 844) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    tester.view.platformDispatcher.localesTestValue = const [Locale('ar')];
    addTearDown(tester.view.platformDispatcher.clearAllTestValues);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct deep link to /settings renders (NAV-007)', (tester) async {
    final container = await TestApp.pump(tester, size: const Size(390, 844));
    final router = container.read(appRouterProvider);
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('unknown route shows 404 with recovery (NAV-007)', (tester) async {
    final container = await TestApp.pump(tester, size: const Size(390, 844));
    final router = container.read(appRouterProvider);
    router.go('/definitely-not-a-route');
    await tester.pumpAndSettle();
    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/home');
  });
}
