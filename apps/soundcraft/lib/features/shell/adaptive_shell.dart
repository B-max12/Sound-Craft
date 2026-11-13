import 'package:soundcraft/design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/features/player/mini_player.dart';
import 'package:soundcraft/features/shell/connectivity_banner.dart';

/// Adaptive navigation shell (§23.2): bottom bar <600, rail 600–1023,
/// persistent sidebar >=1024. Mini-player is always reachable above nav
/// (contract §3.7) and never overlaps scrolling content.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Dest(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: '/home',
    ),
    _Dest(
      label: 'Search',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search_rounded,
      route: '/search',
    ),
    _Dest(
      label: 'Library',
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music_rounded,
      route: '/library',
    ),
    _Dest(
      label: 'Downloads',
      icon: Icons.download_outlined,
      selectedIcon: Icons.download_rounded,
      route: '/downloads',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = ds.Breakpoints.isCompact(width);
    final expanded = ds.Breakpoints.isExpanded(width);
    final sc = context.scColors;

    final miniPlayer = const MiniPlayer();

    Widget content;
    if (compact) {
      content = Scaffold(
        body: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: navigationShell),
                  Positioned(
                    left: ds.Spacing.s,
                    right: ds.Spacing.s,
                    bottom: ds.Spacing.s,
                    child: miniPlayer,
                  ),
                ],
              ),
            ),
            NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              height: 68,
              onDestinationSelected: (i) => _goBranch(i),
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon, semanticLabel: d.label),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                    tooltip: d.label,
                  ),
              ],
            ),
          ],
        ),
      );
    } else if (expanded) {
      content = Scaffold(
        body: Row(
          children: [
            _Sidebar(
              destinations: _destinations,
              currentIndex: navigationShell.currentIndex,
              onSelect: _goBranch,
            ),
            VerticalDivider(width: 1, color: sc.outline),
            Expanded(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(child: navigationShell),
                        Positioned(
                          left: ds.Spacing.xl,
                          right: ds.Spacing.xl,
                          bottom: ds.Spacing.xl,
                          child: miniPlayer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Medium: navigation rail.
      content = Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelType: NavigationRailLabelType.all,
              minWidth: 72,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: ds.Spacing.l),
                child: ds.BrandMark(size: 32),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon, semanticLabel: d.label),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: sc.outline),
            Expanded(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(child: navigationShell),
                        Positioned(
                          left: ds.Spacing.l,
                          right: ds.Spacing.l,
                          bottom: ds.Spacing.l,
                          child: miniPlayer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return content;
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _Dest {
  const _Dest({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

/// Persistent sidebar for expanded layouts (>=1024).
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<_Dest> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final sc = context.scColors;
    return SizedBox(
      width: 232,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(ds.Spacing.xl),
            child: Row(
              children: [
                ds.BrandMark(size: 34),
                const SizedBox(width: ds.Spacing.m),
                Expanded(
                  child: Text(
                    AppIdentity.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ds.Spacing.s,
                vertical: 2,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: ds.Radii.control),
                  selected: i == currentIndex,
                  selectedColor: sc.brandPrimary,
                  iconColor: sc.textSecondary,
                  leading: Icon(
                    i == currentIndex
                        ? destinations[i].selectedIcon
                        : destinations[i].icon,
                    semanticLabel: destinations[i].label,
                  ),
                  title: Text(destinations[i].label),
                  onTap: () => onSelect(i),
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(ds.Spacing.l),
            child: TextButton.icon(
              onPressed: () => context.push('/queue'),
              icon: const Icon(Icons.queue_music_outlined),
              label: const Text('Queue'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ds.Spacing.l),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppIdentity.brandCredit,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
