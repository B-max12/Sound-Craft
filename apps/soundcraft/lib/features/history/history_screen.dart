import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Full history with privacy controls (§3.13).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<HistoryEntry>? _entries;
  Map<String, Track>? _tracks;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final repo = ref.read(historyRepoProvider);
    final library = ref.read(localLibraryRepoProvider);
    final entries = await repo.recent(limit: 200);
    final tracks = <String, Track>{};
    for (final e in entries) {
      if (e.sourceType == SourceProvider.local) {
        final t = await library.getById(e.stableTrackId);
        if (t != null) tracks[e.stableTrackId] = t;
      }
    }
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _tracks = tracks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final entries = _entries ?? const <HistoryEntry>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            tooltip: 'Clear all history',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await confirmDestructive(
                context,
                title: 'Clear listening history?',
                message: 'Removes every play event from this device. Files, playlists and favorites are kept.',
                confirmLabel: 'Clear',
              );
              if (ok) {
                await ref.read(historyRepoProvider).clearAll();
                await _reload();
                if (context.mounted) showAppSnackBar(context, 'History cleared.');
              }
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyStateView(
              icon: Icons.history_rounded,
              title: 'Nothing played yet',
              message: 'Your listening history appears here. It stays on this device and you can pause or clear it anytime.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                final track = _tracks?[e.stableTrackId];
                if (track == null) {
                  return ListTile(
                    leading: const Icon(Icons.music_off_outlined),
                    title: Text(
                      'Removed library item',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${e.sourceType.displayName} · ${_relative(e.startedAt)}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Forget this entry',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () async {
                        await ref
                            .read(historyRepoProvider)
                            .forgetTrack(e.stableTrackId);
                        await _reload();
                      },
                    ),
                  );
                }
                return TrackTile(
                  track: track,
                  onTap: () async {
                    final player = ref.read(playerCoordinatorProvider);
                    await player.playSingle(track);
                  },
                  subtitle:
                      '${_relative(e.startedAt)} · listened ${formatDurationMs(e.listenedMs)}',
                  trailing: IconButton(
                    tooltip: 'Forget this track',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () async {
                      await ref
                          .read(historyRepoProvider)
                          .forgetTrack(e.stableTrackId);
                      await _reload();
                    },
                  ),
                );
              },
            ),
    );
  }
}

String _relative(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}
