import 'dart:async';

import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Context menu for every track row (LIB-005/006/007, PL-002, DL-001, §4
/// "More menu: only shipped, valid actions").
class TrackRowMenu extends ConsumerWidget {
  const TrackRowMenu({super.key, required this.track, this.onChanged});

  final Track track;
  final Future<void> Function()? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(rightsGateProvider);
    final capability = gate.resolveCapability(track);

    return PopupMenuButton<String>(
      tooltip: 'More actions for ${track.title}',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) => _handle(context, ref, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'play_next',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.playlist_add_rounded),
            title: Text('Play next'),
          ),
        ),
        const PopupMenuItem(
          value: 'add_queue',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.queue_rounded),
            title: Text('Add to queue'),
          ),
        ),
        PopupMenuItem(
          value: 'favorite',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.favorite_outline_rounded),
            title: Text(
              track.provider == SourceProvider.local ? 'Favorite' : 'Like',
            ),
          ),
        ),
        if (track.provider != SourceProvider.youtube)
          const PopupMenuItem(
            value: 'add_playlist',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.playlist_add_circle_outlined),
              title: Text('Add to playlist…'),
            ),
          ),
        if (capability.canDownload)
          const PopupMenuItem(
            value: 'download',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.download_outlined),
              title: Text('Download'),
            ),
          ),
        if (track.provider == SourceProvider.youtube)
          PopupMenuItem(
            value: 'open_youtube',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.ondemand_video_rounded),
              title: Text(
                track.sourceUrl != null
                    ? 'Watch on YouTube'
                    : 'Open in official player',
              ),
            ),
          ),
        if (track.provider == SourceProvider.local) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'relink',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.link_outlined),
              title: Text('Relink file…'),
            ),
          ),
          const PopupMenuItem(
            value: 'remove_entry',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.playlist_remove_outlined),
              title: Text('Remove from library'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final player = ref.read(playerCoordinatorProvider);
    final favorites = ref.read(favoritesRepoProvider);
    switch (value) {
      case 'play_next':
        await player.playNext(track);
        if (context.mounted) {
          showAppSnackBar(context, '"${track.title}" plays next.');
        }
      case 'add_queue':
        await player.addToQueue(track);
        if (context.mounted) {
          showAppSnackBar(context, 'Added "${track.title}" to the queue.');
        }
      case 'favorite':
        final added = await favorites.toggle(
          TrackRef.fromStableId(
            stableTrackId: track.stableId,
            title: track.title,
            artist: track.artist,
            durationMs: track.durationMs,
          ),
        );
        if (context.mounted) {
          showAppSnackBar(
            context,
            added ? 'Added to favorites.' : 'Removed from favorites.',
          );
        }
        await onChanged?.call();
      case 'add_playlist':
        await _addToPlaylist(context, ref);
      case 'download':
        await _download(context, ref);
      case 'open_youtube':
        if (track.sourceUrl != null && context.mounted) {
          unawaited(context.push(Routes.youtube(track.externalId)));
        }
      case 'relink':
        showAppSnackBar(
          context,
          'Re-link the file by re-importing it from its new location.',
        );
        await onChanged?.call();
      case 'remove_entry':
        final ok = await confirmDestructive(
          context,
          title: 'Remove from library?',
          message:
              '"${track.title}" disappears from your library and playlists. The audio file on disk is NOT deleted.',
          confirmLabel: 'Remove entry',
        );
        if (ok) {
          await ref.read(localLibraryRepoProvider).removeEntry(track.stableId);
          await onChanged?.call();
        }
    }
  }

  Future<void> _addToPlaylist(BuildContext context, WidgetRef ref) async {
    final playlists = ref.read(playlistRepoProvider);
    final list = await playlists.list();
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded),
              title: const Text('New playlist'),
              onTap: () => Navigator.of(context).pop('__new__'),
            ),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No playlists yet — create your first one.'),
              )
            else
              for (final pl in list)
                ListTile(
                  leading: const Icon(Icons.queue_music_outlined),
                  title: Text(pl.title),
                  subtitle: Text('${pl.entryCount} tracks'),
                  onTap: () => Navigator.of(context).pop(pl.id),
                ),
          ],
        ),
      ),
    );
    if (selected == null) return; // cancelled — no side effects (NAV-006)
    var playlistId = selected;
    if (playlistId == '__new__') {
      if (!context.mounted) return;
      final name = await _promptForPlaylistName(context);
      if (name == null || name.trim().isEmpty) return;
      playlistId = await playlists.create(name);
    }
    try {
      await playlists.addTrack(
        playlistId,
        TrackRef.fromStableId(
          stableTrackId: track.stableId,
          title: track.title,
          artist: track.artist,
          durationMs: track.durationMs,
        ),
      );
      if (context.mounted) {
        showAppSnackBar(context, 'Added "${track.title}" to the playlist.');
      }
    } on PersistenceException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    }
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final manager = ref.read(downloadManagerProvider);
    try {
      await manager.enqueue(track);
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Download started — see the Downloads tab.',
          actionLabel: 'Open',
          onAction: () => context.go('/downloads'),
        );
      }
    } on RightsDeniedException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } on ProviderException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    } on PersistenceException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message);
    }
  }
}

Future<String?> _promptForPlaylistName(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        decoration: const InputDecoration(labelText: 'Playlist name'),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Create'),
        ),
      ],
    ),
  );
  return result;
}
