import 'dart:async';

import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/import/library_scanner.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/services/recommender.dart';
import 'package:soundcraft/features/library/import_flow.dart';
import 'package:soundcraft/features/library/track_row_menu.dart';

enum LibraryTab { tracks, albums, artists, playlists, favorites, history }

/// Sort keys persisted in settings (LIB-003).
enum LibrarySort { title, artist, album, duration, addedAt }

/// Library screen (§3.8): real local records, import/rescan, search, sort.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryTab _tab = LibraryTab.tracks;
  String _query = '';
  LibrarySort _sort = LibrarySort.title;
  bool _ascending = true;
  List<Track>? _tracks;
  List<Track>? _favorites;
  List<HistoryEntry>? _history;
  List<PlaylistSummary>? _playlists;
  bool _loading = true;
  bool _scanning = false;
  double? _scanProgress;

  @override
  void initState() {
    super.initState();
    _restoreSortPref();
    _reload();
  }

  Future<void> _restoreSortPref() async {
    final settings = ref.read(settingsRepoProvider);
    final sort = await settings.getString(PrefKeys.librarySort);
    final dir = await settings.getString(PrefKeys.librarySortDir);
    if (!mounted) return;
    setState(() {
      _sort = LibrarySort.values.firstWhere(
        (s) => s.name == sort,
        orElse: () => LibrarySort.title,
      );
      _ascending = dir != 'desc';
    });
  }

  Future<void> _persistSortPref() async {
    final settings = ref.read(settingsRepoProvider);
    await settings.setString(PrefKeys.librarySort, _sort.name);
    await settings.setString(
      PrefKeys.librarySortDir,
      _ascending ? 'asc' : 'desc',
    );
  }

  Future<void> _reload({bool markMissing = false}) async {
    setState(() => _loading = true);
    final library = ref.read(localLibraryRepoProvider);
    final favorites = ref.read(favoritesRepoProvider);
    final history = ref.read(historyRepoProvider);
    final playlists = ref.read(playlistRepoProvider);
    try {
      if (markMissing) {
        final missing = await library.markMissingFiles();
        if (missing > 0 && mounted) {
          showAppSnackBar(
            context,
            '$missing imported item(s) are no longer reachable on disk.',
          );
        }
      }
      final tracks = await library.search(_query);
      final favIds = await favorites.allIds();
      final favTracks = tracks
          .where((t) => favIds.contains(t.stableId))
          .toList();
      final hist = await history.recent(limit: 50);
      final pls = await playlists.list();
      if (!mounted) return;
      setState(() {
        _tracks = tracks;
        _favorites = favTracks;
        _history = hist;
        _playlists = pls;
        _loading = false;
      });
    } on PersistenceException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppSnackBar(context, 'Database error: ${e.message}');
    }
  }

  List<Track> _sorted(List<Track> input) {
    final list = [...input];
    int compare(Track a, Track b) {
      switch (_sort) {
        case LibrarySort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case LibrarySort.artist:
          return (a.artist ?? '').toLowerCase().compareTo(
            (b.artist ?? '').toLowerCase(),
          );
        case LibrarySort.album:
          return (a.album ?? '').toLowerCase().compareTo(
            (b.album ?? '').toLowerCase(),
          );
        case LibrarySort.duration:
          return (a.durationMs ?? 0).compareTo(b.durationMs ?? 0);
        case LibrarySort.addedAt:
          return a.stableId.compareTo(
            b.stableId,
          ); // import order via id creation
      }
    }

    list.sort(compare);
    if (!_ascending) {
      // Stable tie-safe reverse of the sorted list.
      for (var i = 0, j = list.length - 1; i < j; i++, j--) {
        final tmp = list[i];
        list[i] = list[j];
        list[j] = tmp;
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library'),
          actions: [
            IconButton(
              tooltip: 'Search library',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => context.go('${Routes.search}?from=library'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Sort and manage',
              icon: const Icon(Icons.sort_rounded, semanticLabel: 'Sort'),
              onSelected: (value) async {
                switch (value) {
                  case 'folders':
                    unawaited(context.push(Routes.folders));
                  case 'rescan':
                    await _importFolder(rescan: true);
                  case 'check_missing':
                    await _reload(markMissing: true);
                  default:
                    final newSort = LibrarySort.values.firstWhere(
                      (s) => s.name == value,
                      orElse: () => _sort,
                    );
                    final flip = newSort == _sort;
                    setState(() {
                      _sort = newSort;
                      if (flip) _ascending = !_ascending;
                    });
                    await _persistSortPref();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'title', child: Text('Sort: Title')),
                const PopupMenuItem(
                  value: 'artist',
                  child: Text('Sort: Artist'),
                ),
                const PopupMenuItem(value: 'album', child: Text('Sort: Album')),
                const PopupMenuItem(
                  value: 'duration',
                  child: Text('Sort: Duration'),
                ),
                const PopupMenuItem(
                  value: 'addedAt',
                  child: Text('Sort: Date added'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'rescan',
                  child: Text('Rescan imported folders'),
                ),
                const PopupMenuItem(
                  value: 'check_missing',
                  child: Text('Check for missing files'),
                ),
                const PopupMenuItem(
                  value: 'folders',
                  child: Text('Manage folders'),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Import music',
              icon: const Icon(Icons.library_add_rounded),
              onPressed: () => _showImportSheet(),
            ),
          ],
          bottom: TabBar(
            isScrollable: wide,
            tabAlignment: wide ? TabAlignment.start : TabAlignment.fill,
            onTap: (i) => setState(() => _tab = LibraryTab.values[i]),
            tabs: const [
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Playlists'),
              Tab(text: 'Favorites'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: _loading
            ? _LibrarySkeleton(tab: _tab)
            : switch (_tab) {
                LibraryTab.tracks => _tracksView(),
                LibraryTab.albums => _albumsView(),
                LibraryTab.artists => _artistsView(),
                LibraryTab.playlists => _playlistsView(),
                LibraryTab.favorites => _favoritesView(),
                LibraryTab.history => _historyView(),
              },
        floatingActionButton: _scanning
            ? null
            : FloatingActionButton.extended(
                heroTag: 'library-import',
                tooltip: 'Import audio files or a folder',
                icon: const Icon(Icons.add_rounded),
                label: const Text('Import'),
                onPressed: _showImportSheet,
              ),
      ),
    );
  }

  Future<void> _showImportSheet() async {
    await showImportSheet(context, ref);
    await _reload();
  }

  Future<void> _importFolder({bool rescan = false}) async {
    final folders = await ref.read(importedFoldersProvider.future);
    if (folders.isEmpty) {
      await _showImportSheet();
      return;
    }
    setState(() {
      _scanning = true;
      _scanProgress = null;
    });
    await _scanDirectories(folders);
  }

  Future<void> _scanDirectories(List<String> folders) async {
    final library = ref.read(localLibraryRepoProvider);
    final scanner = LibraryScanner();
    final overall = ScanSummary();
    for (final folder in folders) {
      await for (final event in scanner.scanDirectory(folder)) {
        switch (event) {
          case ScanProgress(:final filesSeen, :final totalKnown):
            if (mounted) {
              setState(
                () => _scanProgress = totalKnown == 0
                    ? 0
                    : filesSeen / totalKnown,
              );
            }
          case ScanDone(:final tracks):
            final result = await library.upsertScanned(
              tracks,
              folderUri: folder,
            );
            overall.added += result.added;
            overall.updated += result.updated;
            overall.skipped += result.skipped;
            overall.unreadable += result.unreadable;
          case ScanFailed(:final error):
            if (mounted) {
              showAppSnackBar(context, 'Scan failed: $error');
            }
        }
      }
      if (overall.cancelled) break;
    }
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _scanProgress = null;
    });
    showAppSnackBar(
      context,
      'Scan finished: ${overall.added} added, ${overall.updated} updated, '
      '${overall.skipped} duplicates, ${overall.unreadable} unreadable.',
    );
    await _reload();
  }

  // ------------------------------------------------------------------ views

  Widget _tracksView() {
    final tracks = _tracks ?? const <Track>[];
    if (_scanning && _scanProgress != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(value: _scanProgress),
          ),
          const Expanded(
            child: Center(child: Text('Scanning imported folders…')),
          ),
        ],
      );
    }
    if (tracks.isEmpty) {
      return EmptyStateView(
        icon: Icons.music_note_outlined,
        title: _query.isEmpty ? 'No music imported yet' : 'No matches',
        message: _query.isEmpty
            ? 'Import audio files (MP3, M4A, FLAC, OGG, WAV) from this device. Everything stays local and works offline.'
            : 'Nothing in your library matches "$_query".',
        actionLabel: _query.isEmpty ? 'Import music' : null,
        onAction: _query.isEmpty ? _showImportSheet : null,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filter tracks, artists, albums…',
              prefixIcon: const Icon(Icons.filter_alt_outlined),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear filter',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        setState(() => _query = '');
                        _reload();
                      },
                    ),
            ),
            onChanged: (v) {
              setState(() => _query = v);
              _reload();
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 160),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = _sorted(tracks)[index];
              return TrackTile(
                track: track,
                onTap: () => _playAllFrom(tracks, index),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatDurationMs(track.durationMs),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    TrackRowMenu(track: track, onChanged: _reload),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _albumsView() {
    final tracks = _tracks ?? const <Track>[];
    final albums = groupByAlbum(tracks);
    if (albums.isEmpty) {
      return const EmptyStateView(
        icon: Icons.album_outlined,
        title: 'No albums yet',
        message:
            'Album grouping appears once files with album tags are imported.',
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    final columns = gridColumnsFor(width);
    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 160),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final entry = albums.entries.elementAt(index);
        final albumTracks = entry.value;
        final first = albumTracks.first;
        return Semantics(
          button: true,
          label: 'Album ${entry.key} with ${albumTracks.length} tracks',
          child: InkWell(
            borderRadius: Radii.card,
            onTap: () => _playAllFrom(albumTracks, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ArtworkView(track: first, size: 400, radius: Radii.m),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${albumTracks.length} tracks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _artistsView() {
    final tracks = _tracks ?? const <Track>[];
    final artists = groupByArtist(tracks);
    if (artists.isEmpty) {
      return const EmptyStateView(
        icon: Icons.people_outline_rounded,
        title: 'No artists yet',
        message:
            'Artist grouping appears once files with artist tags are imported.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final entry = artists.entries.elementAt(index);
        final label = entry.value.first.artist ?? 'Unknown artist';
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person_outline_rounded),
          ),
          title: Text(label),
          subtitle: Text('${entry.value.length} tracks'),
          onTap: () => _playAllFrom(entry.value, 0),
        );
      },
    );
  }

  Widget _playlistsView() {
    final playlists = _playlists ?? const <PlaylistSummary>[];
    return ListView(
      padding: const EdgeInsets.only(bottom: 160),
      children: [
        ListTile(
          leading: const Icon(Icons.add_circle_outline_rounded),
          title: const Text('Create playlist'),
          onTap: () => _createPlaylist(),
        ),
        if (playlists.isEmpty)
          const EmptyStateView(
            icon: Icons.playlist_add_outlined,
            title: 'No playlists',
            message: 'Create a playlist and add tracks from your library.',
          )
        else
          for (final pl in playlists)
            ListTile(
              leading: const Icon(Icons.queue_music_outlined),
              title: Text(pl.title),
              subtitle: Text('${pl.entryCount} tracks'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.playlist(pl.id)),
            ),
      ],
    );
  }

  Future<void> _createPlaylist() async {
    final name = await _promptText(context, 'Create playlist', 'Playlist name');
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(playlistRepoProvider).create(name);
      await _reload();
      if (mounted) showAppSnackBar(context, 'Playlist "$name" created');
    } on PersistenceException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }

  Widget _favoritesView() {
    final favorites = _favorites ?? const <Track>[];
    if (favorites.isEmpty) {
      return const EmptyStateView(
        icon: Icons.favorite_outline_rounded,
        title: 'No favorites yet',
        message: 'Tap the heart on any track to keep it here. Favorites work offline.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final track = favorites[index];
        return TrackTile(
          track: track,
          onTap: () => _playAllFrom(favorites, index),
          trailing: TrackRowMenu(track: track, onChanged: _reload),
        );
      },
    );
  }

  Widget _historyView() {
    final history = _history ?? const <HistoryEntry>[];
    if (history.isEmpty) {
      return const EmptyStateView(
        icon: Icons.history_rounded,
        title: 'No listening history',
        message: 'Recently played tracks appear here. History is stored only on this device and can be cleared in Settings → Privacy.',
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 160),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton(
            onPressed: () => context.push(Routes.history),
            child: const Text('Open full history & privacy controls'),
          ),
        ),
        for (final entry in history)
          FutureBuilder<Track?>(
            future: ref
                .read(localLibraryRepoProvider)
                .getById(entry.stableTrackId),
            builder: (context, snap) {
              final track = snap.data;
              if (track == null) return const SizedBox.shrink();
              return TrackTile(
                track: track,
                onTap: () => _playNow(track),
                subtitle:
                    'Played ${_relative(entry.startedAt)} · ${formatDurationMs(entry.listenedMs)} listened',
              );
            },
          ),
      ],
    );
  }

  // ------------------------------------------------------------ playback/CTX

  Future<void> _playAllFrom(List<Track> tracks, int index) async {
    final player = ref.read(playerCoordinatorProvider);
    try {
      await player.playTracks(tracks, startIndex: index);
    } on PlaybackException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }

  Future<void> _playNow(Track track) async {
    final player = ref.read(playerCoordinatorProvider);
    try {
      await player.playSingle(track);
    } on PlaybackException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }
}

Future<String?> _promptText(
  BuildContext context,
  String title,
  String label, {
  String? initial,
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  return result;
}

String _relative(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}

class _LibrarySkeleton extends StatelessWidget {
  const _LibrarySkeleton({required this.tab});
  final LibraryTab tab;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SkeletonBox(width: 48, height: 48, radius: 8),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(height: 10, width: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exposed for tests and the folders screen.
final importedFoldersProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.select(db.importedFolders).get();
  return rows.map((r) => r.accessUri).toList();
});
