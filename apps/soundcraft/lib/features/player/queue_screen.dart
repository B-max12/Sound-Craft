import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/domain/models/playback.dart';

/// Queue screen (§3.10): now playing + up next with reorder/remove/clear.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(playerCoordinatorProvider);
    final stateAsync = ref.watch(playbackStateProvider);
    final state = stateAsync.asData?.value ?? const PlaybackState();
    final queue = coordinator.queue;
    final active = state.queueIndex ?? -1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          if (active < queue.length - 1 && active >= 0)
            TextButton(
              onPressed: () async {
                final ok = await confirmDestructive(
                  context,
                  title: 'Clear upcoming?',
                  message:
                      'Removes ${queue.length - active - 1} queued items. History and playlists are not affected.',
                  confirmLabel: 'Clear',
                );
                if (ok) await coordinator.clearUpcoming();
              },
              child: const Text('Clear upcoming'),
            ),
        ],
      ),
      body: queue.isEmpty
          ? const EmptyStateView(
              icon: Icons.queue_music_outlined,
              title: 'Queue is empty',
              message: 'Play an album, playlist or track list to build a queue here.',
            )
          : ReorderableListView.builder(
              buildDefaultDragHandles: true,
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: queue.length,
              onReorderItem: (oldIndex, newIndex) async {
                await coordinator.reorderQueue(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final track = queue[index];
                final isCurrent = index == active;
                final isPast = index < active;
                return Dismissible(
                  key: ValueKey('queue-${track.stableId}-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: context.scColors.errorAccent.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete_outline_rounded),
                  ),
                  confirmDismiss: (_) async {
                    final ok = await confirmDestructive(
                      context,
                      title: 'Remove from queue?',
                      message:
                          '"${track.title}" will be removed from the queue only.',
                      confirmLabel: 'Remove',
                    );
                    if (ok) await coordinator.removeFromQueue(index);
                    return ok;
                  },
                  child: ListTile(
                    key: ValueKey('queue-tile-${track.stableId}-$index'),
                    leading: ArtworkView(track: track, size: 44),
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent
                            ? context.scColors.brandPrimary
                            : isPast
                            ? context.scColors.textTertiary
                            : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Flexible(
                          child: Text(
                            track.artist ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SourceBadge(provider: track.provider, compact: true),
                      ],
                    ),
                    trailing: Text(
                      isCurrent ? 'Now' : formatDurationMs(track.durationMs),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    onTap: () async {
                      await coordinator.playTracks(
                        queue,
                        startIndex: index,
                        autoPlay: true,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
