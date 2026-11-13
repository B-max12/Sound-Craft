import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/features/downloads/downloads_screen.dart';
import 'package:soundcraft/features/history/history_screen.dart';
import 'package:soundcraft/features/home/home_screen.dart';
import 'package:soundcraft/features/legal/legal_screen.dart';
import 'package:soundcraft/features/library/artist_screen.dart';
import 'package:soundcraft/features/library/library_screen.dart';
import 'package:soundcraft/features/library/managed_folders_screen.dart';
import 'package:soundcraft/features/player/now_playing_screen.dart';
import 'package:soundcraft/features/player/queue_screen.dart';
import 'package:soundcraft/features/playlist/playlist_screen.dart';
import 'package:soundcraft/features/search/search_screen.dart';
import 'package:soundcraft/features/settings/settings_screen.dart';
import 'package:soundcraft/features/shell/adaptive_shell.dart';
import 'package:soundcraft/features/welcome/welcome_screen.dart';
import 'package:soundcraft/features/youtube/youtube_viewer_screen.dart';

/// Typed route names (§23.1 route inventory). Every route has an explicit
/// page; unknown paths land on [NotFoundScreen] with recovery actions.
class Routes {
  static const home = '/home';
  static const search = '/search';
  static const library = '/library';
  static const downloads = '/downloads';
  static const player = '/player';
  static const queue = '/queue';
  static const history = '/history';
  static const settings = '/settings';
  static const legalPrivacy = '/legal/privacy';
  static const legalTerms = '/legal/terms';
  static const legalLicenses = '/legal/licenses';
  static const diagnostics = '/diagnostics';
  static const welcome = '/welcome';
  static const folders = '/library/folders';

  static String playlist(String id) => '/playlist/$id';
  static String artist(String provider, String id) => '/artist/$provider/$id';
  static String album(String provider, String id) => '/album/$provider/$id';
  static String youtube(String videoId) => '/youtube/$videoId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    errorBuilder: (context, state) => NotFoundScreen(uri: state.uri.toString()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdaptiveShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', redirect: (_, _) => Routes.home),
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (context, state) {
                  final q = state.uri.queryParameters['q'] ?? '';
                  return SearchScreen(initialQuery: q);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (_, _) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'folders',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const ManagedFoldersScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.downloads,
                builder: (_, _) => const DownloadsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.welcome,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.player,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _modalSheetPage(context, state, const NowPlayingScreen()),
      ),
      GoRoute(
        path: Routes.queue,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const QueueScreen(),
      ),
      GoRoute(
        path: Routes.history,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/playlist/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PlaylistScreen(playlistId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/artist/:provider/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ArtistScreen(
          provider: state.pathParameters['provider']!,
          artistId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/album/:provider/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AlbumScreen(
          provider: state.pathParameters['provider']!,
          albumId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/youtube/:videoId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final title = extra is Map ? extra['title'] as String? : null;
          final artist = extra is Map ? extra['artist'] as String? : null;
          return YouTubeViewerScreen(
            videoId: state.pathParameters['videoId']!,
            title: title,
            artist: artist,
          );
        },
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.diagnostics,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: Routes.legalPrivacy,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const LegalScreen.document(LegalDoc.privacy),
      ),
      GoRoute(
        path: Routes.legalTerms,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const LegalScreen.document(LegalDoc.terms),
      ),
      GoRoute(
        path: Routes.legalLicenses,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const LegalScreen.document(LegalDoc.licenses),
      ),
    ],
    observers: [RouteLoggingObserver(ref)],
  );
});

/// Logs route transitions for diagnostics (no PII — route names only).
class RouteLoggingObserver extends NavigatorObserver {
  RouteLoggingObserver(Ref ref);
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    assert(() {
      debugPrint('[route] push ${route.settings.name ?? route.runtimeType}');
      return true;
    }());
  }
}

CustomTransitionPage<void> _modalSheetPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// 404 page with recovery (NAV-007 direct-link fallback).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.uri});
  final String uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'No page lives at',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SelectableText(uri, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
