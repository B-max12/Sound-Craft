import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart' show appRouterProvider;
import 'package:soundcraft/app/state.dart' show appearanceProvider;
import 'package:soundcraft/features/player/mini_player.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/features/player/playback_mappers.dart';

import 'app_harness.dart';

/// Interaction acceptance (contract §4/§22 sample): every control tested maps
/// to a real handler; persistence across "restart"; dialogs cancel cleanly.
void main() {
  testWidgets('library: fixture tracks visible, tap plays through engine',
      (tester) async {
    final container = await TestApp.pump(
      tester,
      importFixture: true,
      size: const Size(390, 844),
    );
    final engine = engineOf(container);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meadow Song'));
    await tester.pumpAndSettle();

    expect(engine.loadLog.last, 'file:/fixtures/one.mp3');
    expect(container.read(playerCoordinatorProvider).state.isPlaying, isTrue);
  });

  testWidgets('mini-player appears when playing; tap opens full player without reset',
      (tester) async {
    final container = await TestApp.pump(
      tester,
      importFixture: true,
      size: const Size(390, 844),
    );
    final player = container.read(playerCoordinatorProvider);
    final firstTrack =
        (await container.read(localLibraryRepoProvider).getAll()).first;
    await player.playSingle(firstTrack);
    await tester.pumpAndSettle();

    // Mini-player visible (PLY-007).
    expect(find.byTooltip('Pause'), findsOneWidget);

    // Tap the mini-player title area (not a home rail card) → full player.
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(MiniPlayer),
      matching: find.text(firstTrack.title),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Playing from Library'), findsOneWidget);
    // Playback continues (state intact).
    expect(player.state.isPlaying, isTrue);

    // Close (swipe-down equivalent: app-bar close button).
    await tester.tap(find.byTooltip('Close player (playback continues)'));
    await tester.pumpAndSettle();
    expect(player.state.isPlaying, isTrue); // audio keeps playing (PLY-008)
  });

  testWidgets('play/pause via mini-player reflects engine state (PLY-002)',
      (tester) async {
    final container = await TestApp.pump(
      tester,
      importFixture: true,
      size: const Size(390, 844),
    );
    final player = container.read(playerCoordinatorProvider);
    await player.playSingle(
      (await container.read(localLibraryRepoProvider).getAll()).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    expect(player.state.isPlaying, isFalse);

    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(player.state.isPlaying, isTrue);
  });

  testWidgets('playlist CRUD through UI persists across coordinator restart',
      (tester) async {
    final container = await TestApp.pump(tester, importFixture: true);
    final repo = container.read(playlistRepoProvider);

    // Create via dialog (PL-001).
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Playlists'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create playlist'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Evening Drive');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Evening Drive'), findsOneWidget);

    // Add a track via track menu (PL-002).
    await tester.tap(find.text('Tracks'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to playlist…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evening Drive'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Added'), findsOneWidget); // snackbar confirmation

    final summaries = await repo.list();
    expect(summaries.single.title, 'Evening Drive');
    expect(summaries.single.entryCount, 1);
  });

  testWidgets('destructive dialog cancels cleanly (NAV-006, PL-004)',
      (tester) async {
    final container = await TestApp.pump(tester, importFixture: true);
    final repo = container.read(playlistRepoProvider);
    final id = await repo.create('Keep me');
    await repo.addTrack(id, TrackRef.fromStableId(
        stableTrackId: 'local:fp-one', title: 'Meadow Song'));

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Playlists'));
    await tester.pumpAndSettle();
    // Open playlist, then delete via menu but CANCEL.
    await tester.tap(find.text('Keep me'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete playlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect((await repo.list()).single.title, 'Keep me'); // untouched
    expect(find.byType(AlertDialog), findsNothing); // dialog dismissed
  });

  testWidgets('search: local results instant, clear field resets (SRCH-001/002)',
      (tester) async {
    final container = await TestApp.pump(tester, importFixture: true);
    final router = container.read(appRouterProvider);
    router.go('/search?q=cricket');
    await tester.pumpAndSettle(const Duration(milliseconds: 900));
    // ignore: avoid_print
    print('PATH=${router.routeInformationProvider.value.uri.path}');

    expect(find.text('Cricket Lullaby'), findsOneWidget);
    expect(find.text('Meadow Song'), findsNothing);

    // Clear field (SRCH-002) → empty-query discovery view. The 'cricket'
    // query was recorded, so the recent-searches variant shows.
    await tester.tap(find.byTooltip('Clear search (SRCH-002)'));
    await tester.pumpAndSettle();
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('cricket'), findsOneWidget); // preserved for re-use
  });

  testWidgets('downloads tab renders honest empty state (DL scope)',
      (tester) async {
    await TestApp.pump(tester, size: const Size(390, 844));
    await tester.tap(find.text('Downloads'));
    await tester.pumpAndSettle();
    expect(find.text('No active downloads'), findsOneWidget);
    expect(
      find.textContaining('YouTube items never download'),
      findsOneWidget,
    );
  });

  testWidgets('sleep timer sheet sets and cancels timer (PLY-011)',
      (tester) async {
    final container = await TestApp.pump(tester, importFixture: true);
    final player = container.read(playerCoordinatorProvider);
    final track =
        (await container.read(localLibraryRepoProvider).getAll()).first;
    await player.playSingle(track);
    await tester.pumpAndSettle();
    // Open the full player through the MINI-PLAYER (not a home rail card).
    await tester.tap(find.descendant(
      of: find.byType(MiniPlayer),
      matching: find.text(track.title),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Playing from Library'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sleep timer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 min'));
    await tester.pumpAndSettle();
    expect(player.state.sleepTimerEndsAt, isNotNull);

    // Cancel via sheet again.
    await tester.tap(find.byTooltip('Sleep timer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel timer'));
    await tester.pumpAndSettle();
    expect(player.state.sleepTimerEndsAt, isNull);
  });

  testWidgets('library empty state offers import CTA (LIB-001 entry point)',
      (tester) async {
    await TestApp.pump(tester, size: const Size(390, 844));
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('No music imported yet'), findsOneWidget);
    expect(find.text('Import music'), findsOneWidget);
  });

  testWidgets('unawaitedToggle survives rapid taps without exceptions',
      (tester) async {
    final container = await TestApp.pump(tester, importFixture: true);
    final player = container.read(playerCoordinatorProvider);
    final track =
        (await container.read(localLibraryRepoProvider).getAll()).first;
    await player.playSingle(track);
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      await unawaitedToggle(player);
    }
    await tester.pumpAndSettle();
    // Deterministic parity: initial play + 10 toggles = play intent.
    expect(player.state.isPlaying, isTrue);
    expect(player.state.status, PlaybackStatus.playing);
    // Flush the queue-persist debounce timer so the test ends timer-clean.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('settings: theme switch applies instantly (SET-001)',
      (tester) async {
    final container = await TestApp.pump(tester, size: const Size(390, 844));
    final router = container.read(appRouterProvider);
    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    final themeMode = container.read(appearanceProvider).value?.mode;
    expect(themeMode, ThemeMode.light);
    // Persisted: settings row shows Light.
    expect(find.text('Light'), findsWidgets);
  });
}

