import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Playlist detail (§3.9): reorder, rename, delete, export, mixed-source
/// honest handling of unavailable entries.
class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key, required this.playlistId});
  final String playlistId;

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  PlaylistSummary? _summary;
  List<PlaylistEntryView>? _entries;
  Map<String, Track>? _resolved;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final repo = ref.read(playlistRepoProvider);
    final library = ref.read(localLibraryRepoProvider);
    final summary = await repo.getById(widget.playlistId);
    final entries = await repo.entries(widget.playlistId);
    // Resolve local entries to live tracks; provider entries resolve on play.
    final resolved = <String, Track>{};
    for (final e in entries) {
      if (e.sourceType == SourceProvider.local) {
        final t = await library.getById(e.stableTrackId);
        if (t != null) resolved[e.stableTrackId] = t;
      }
    }
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _entries = entries;
      _resolved = resolved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final summary = _summary;
    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyStateView(
          icon: Icons.playlist_remove_rounded,
          title: 'Playlist not found',
          message: 'It may have been deleted on this device.',
        ),
      );
    }
    final entries = _entries ?? const <PlaylistEntryView>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(summary.title),
        actions: [
          IconButton(
            tooltip: 'Rename playlist',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _rename,
          ),
          PopupMenuButton<String>(
            tooltip: 'Playlist actions',
            onSelected: (v) async {
              switch (v) {
                case 'play':
                  await _playFrom(0);
                case 'export':
                  await _export();
                case 'delete':
                  await _delete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'play', child: Text('Play all')),
              PopupMenuItem(value: 'export', child: Text('Export (JSON)')),
              PopupMenuItem(value: 'delete', child: Text('Delete playlist')),
            ],
          ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyStateView(
              icon: Icons.playlist_add_outlined,
              title: 'This playlist is empty',
              message: 'Add tracks from your library via any track\'s ⋮ menu → Add to playlist.',
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: entries.length,
              onReorderItem: (oldIndex, newIndex) async {
                final ids = entries.map((e) => e.id).toList();
                var target = newIndex;
                if (target > oldIndex) target--;
                final id = ids.removeAt(oldIndex);
                ids.insert(target.clamp(0, ids.length), id);
                try {
                  await ref
                      .read(playlistRepoProvider)
                      .reorder(widget.playlistId, ids);
                  await _reload();
                } on PersistenceException catch (e) {
                  if (context.mounted) showAppSnackBar(context, e.message);
                }
              },
              itemBuilder: (context, index) {
                final e = entries[index];
                final track = _resolved?[e.stableTrackId];
                final unavailable =
                    e.sourceType == SourceProvider.local && track == null;
                return ListTile(
                  key: ValueKey('pl-entry-${e.id}'),
                  leading: unavailable
                      ? Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: context.scColors.skeletonBase,
                            borderRadius: Radii.s as BorderRadiusGeometry?,
                          ),
                          child: const Icon(Icons.help_outline_rounded),
                        )
                      : track != null
                      ? ArtworkView(track: track, size: 44)
                      : Icon(_sourceIcon(e.sourceType)),
                  title: Text(
                    e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Flexible(
                        child: Text(
                          unavailable
                              ? 'Missing file — relink or remove'
                              : (e.artist ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SourceBadge(provider: e.sourceType, compact: true),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatDurationMs(e.durationMs),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      IconButton(
                        tooltip: 'Remove from playlist',
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: () async {
                          await ref
                              .read(playlistRepoProvider)
                              .removeEntry(e.id);
                          await _reload();
                        },
                      ),
                    ],
                  ),
                  onTap: unavailable
                      ? () => showAppSnackBar(
                          context,
                          'This item is missing. Re-import the file to restore it, or remove the entry.',
                        )
                      : () => _playFrom(index),
                );
              },
            ),
    );
  }

  IconData _sourceIcon(SourceProvider p) => switch (p) {
    SourceProvider.local => Icons.music_note_outlined,
    SourceProvider.audius => Icons.cloud_queue_rounded,
    SourceProvider.youtube => Icons.ondemand_video_rounded,
    SourceProvider.jamendo => Icons.album_outlined,
    SourceProvider.archive => Icons.inventory_2_outlined,
    SourceProvider.radio => Icons.radio_rounded,
  };

  Future<void> _playFrom(int index) async {
    final entries = _entries ?? const <PlaylistEntryView>[];
    final player = ref.read(playerCoordinatorProvider);
    final library = ref.read(localLibraryRepoProvider);
    final tracks = <Track>[];
    for (final e in entries) {
      if (e.sourceType == SourceProvider.local) {
        final t = await library.getById(e.stableTrackId);
        if (t != null) tracks.add(t);
      } else {
        // Provider track metadata from the snapshot; live resolution at play.
        tracks.add(
          Track(
            stableId: e.stableTrackId,
            provider: e.sourceType,
            externalId: e.sourceId,
            title: e.title,
            artist: e.artist,
            durationMs: e.durationMs,
            sourceUrl: e.sourceType == SourceProvider.youtube
                ? 'https://www.youtube.com/watch?v=${e.sourceId}'
                : null,
          ),
        );
      }
    }
    if (tracks.isEmpty) return;
    final gate = ref.read(rightsGateProvider);
    final playable = tracks
        .where((t) => gate.canEnterAudioQueue(t))
        .toList(growable: false);
    if (playable.isEmpty) {
      if (mounted) {
        showAppSnackBar(
          context,
          'This playlist has no playable audio entries (YouTube items open in their own viewer).',
        );
      }
      return;
    }
    await player.playTracks(
      playable,
      startIndex: index.clamp(0, playable.length - 1),
    );
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _summary?.title);
    final descriptionController = TextEditingController(
      text: _summary?.description,
    );
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              maxLength: 240,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context)
                    .pop((controller.text, descriptionController.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      await ref
          .read(playlistRepoProvider)
          .rename(widget.playlistId, result.$1, description: result.$2);
      await _reload();
    } on PersistenceException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }

  /// PL-005: export real, documented interchange format (JSON backup).
  Future<void> _export() async {
    final entries = _entries ?? const <PlaylistEntryView>[];
    final summary = _summary;
    if (summary == null) return;
    final json = _playlistToJson(summary, entries);
    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export playlist (JSON)'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(child: SelectableText(json)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDestructive(
      context,
      title: 'Delete playlist?',
      message: 'Deletes the playlist and its order. Tracks, files and favorites are kept.',
      confirmLabel: 'Delete playlist',
    );
    if (!ok) return;
    await ref.read(playlistRepoProvider).delete(widget.playlistId);
    if (mounted) {
      context.go(Routes.library);
      showAppSnackBar(context, 'Playlist deleted.');
    }
  }
}

/// Versioned interchange format (§8: export/import with version + conflict
/// note). Import lands in V1.1; export is real and documented here.
String _playlistToJson(
  PlaylistSummary summary,
  List<PlaylistEntryView> entries,
) {
  final buffer = StringBuffer();
  buffer.writeln('{');
  buffer.writeln('  "format": "soundcraft-playlist/1",');
  buffer.writeln('  "title": "${_escape(summary.title)}",');
  buffer.writeln('  "description": "${_escape(summary.description ?? '')}",');
  buffer.writeln('  "exportedAt": "${DateTime.now().toIso8601String()}",');
  buffer.writeln('  "entries": [');
  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    buffer.writeln(
      '    {"source": "${e.sourceType.id}", "id": "${_escape(e.sourceId)}", '
      '"title": "${_escape(e.title)}", "artist": "${_escape(e.artist ?? '')}", '
      '"durationMs": ${e.durationMs ?? 'null'}}${i == entries.length - 1 ? '' : ','}',
    );
  }
  buffer.writeln('  ]');
  buffer.writeln('}');
  return buffer.toString();
}

String _escape(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n');
