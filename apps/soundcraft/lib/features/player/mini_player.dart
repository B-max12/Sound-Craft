import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/features/player/playback_mappers.dart';

/// Persistent mini-player (§3.7): two-line info, play/pause, next, tap to
/// expand. Hidden when nothing is loaded; never blocks navigation.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playbackStateProvider);
    final state = stateAsync.asData?.value ?? const PlaybackState();
    if (state.stableTrackId == null || state.queueLength == 0) {
      return const SizedBox.shrink();
    }
    final coordinator = ref.read(playerCoordinatorProvider);
    final track = coordinator.currentTrack;
    if (track == null) return const SizedBox.shrink();
    final c = context.scColors;

    return Semantics(
      label: 'Mini player. Currently ${track.title}',
      child: Material(
        elevation: 3,
        borderRadius: Radii.control,
        color: c.backgroundElevated,
        child: InkWell(
          borderRadius: Radii.control,
          onTap: () {
            if (track.provider == SourceProvider.youtube) {
              context.push(
                '/youtube/${track.externalId}',
                extra: {'title': track.title, 'artist': track.artist},
              );
            } else {
              context.push(Routes.player);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accurate low-jank progress: thin indicator only.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: state.progress),
                duration: ScDurations.small,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value.isNaN ? 0 : value.clamp(0.0, 1.0),
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: c.brandPrimary,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 64),
                child: Row(
                  children: [
                    const SizedBox(width: Spacing.m),
                    ArtworkView(track: track, size: 44, radius: Radii.s),
                    const SizedBox(width: Spacing.m),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            track.artist ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // PLY-002: reflects actual engine state.
                    IconButton(
                      tooltip: state.isPlaying ? 'Pause' : 'Play',
                      icon: Icon(
                        state.isBusy
                            ? Icons.hourglass_top_rounded
                            : state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: () => unawaitedToggle(coordinator),
                    ),
                    // Next where queue permits (PLY-003).
                    IconButton(
                      tooltip: 'Next track',
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed:
                          state.queueLength > 1 ||
                              state.repeatMode != RepeatMode.off
                          ? () => coordinator.next()
                          : null,
                    ),
                    IconButton(
                      tooltip: 'Close player',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => coordinator.stopAndDismiss(),
                    ),
                    const SizedBox(width: Spacing.xs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
