import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/domain/services/radio_builder.dart' as radio_svc;
import 'package:soundcraft/features/player/lyrics_sheet.dart';
import 'package:soundcraft/features/player/playback_mappers.dart';
import 'package:soundcraft/player/player_coordinator.dart'
    show kSleepTimerChoices;

/// Full-screen Now Playing (§3.6): responsive cover, real seek with
/// screen-reader value, shuffle/repeat, queue access, sleep timer, volume.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  bool _scrubbing = false;
  double _scrubValue = 0;
  final _volumeFocus = FocusNode();

  @override
  void dispose() {
    _volumeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(playbackStateProvider);
    final state = stateAsync.asData?.value ?? const PlaybackState();
    final coordinator = ref.read(playerCoordinatorProvider);
    final track = coordinator.currentTrack;
    final c = context.scColors;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width > 720;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Now Playing')),
        body: const EmptyStateView(
          icon: Icons.music_off_rounded,
          title: 'Nothing is playing',
          message: 'Pick a track from your library or discovery feeds.',
        ),
      );
    }

    if (track.provider == SourceProvider.youtube) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pushReplacement(
            '/youtube/${track.externalId}',
            extra: {'title': track.title, 'artist': track.artist},
          );
        }
      });
    }

    final duration = state.durationMs ?? track.durationMs ?? 0;
    final position = _scrubbing ? _scrubValue : state.positionMs.toDouble();
    final progress = duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close player (playback continues)',
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(switch (track.provider) {
          SourceProvider.local => 'Playing from Library',
          SourceProvider.audius => 'Playing from Audius',
          SourceProvider.youtube => 'Playing from YouTube',
          SourceProvider.jamendo => 'Playing from Jamendo',
          SourceProvider.archive => 'Playing from Internet Archive',
          SourceProvider.radio => 'Playing Live Radio',
        }, style: Theme.of(context).textTheme.bodySmall),
        actions: [
          IconButton(
            tooltip: 'Download song',
            icon: const Icon(Icons.download_rounded),
            onPressed: () async {
              final manager = ref.read(downloadManagerProvider);
              try {
                await manager.enqueue(track);
                if (context.mounted) {
                  showAppSnackBar(
                    context,
                    'Download started — see Downloads tab.',
                    actionLabel: 'Open',
                    onAction: () => context.push(Routes.downloads),
                  );
                }
              } on Object catch (e) {
                if (context.mounted) {
                  showAppSnackBar(context, 'Could not start download: $e');
                }
              }
            },
          ),
          IconButton(
            tooltip: 'Sleep timer',
            icon: Icon(
              state.sleepTimerEndsAt != null
                  ? Icons.nightlight_round
                  : Icons.nightlight_outlined,
              semanticLabel: 'Sleep timer',
            ),
            onPressed: () => _showSleepTimerSheet(context, state, coordinator),
          ),
          if (track.sourceUrl != null)
            IconButton(
              tooltip: 'Open source link',
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: () => _showSourceDialog(context, track.sourceUrl!),
            ),
          IconButton(
            tooltip: 'Cancel and stop playback',
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              await coordinator.stopAndDismiss();
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ArtworkView(
                    track: track,
                    size: wide ? 320 : 260,
                    radius: Radii.xl,
                  ),
                  const SizedBox(height: Spacing.xl),
                  // Long titles: full name available via tooltip + semantics.
                  Semantics(
                    label: '${track.title} by ${track.artist}',
                    child: Text(
                      track.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    track.artist ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Spacing.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SourceBadge(provider: track.provider),
                      if (track.isDownloadable) ...[
                        const SizedBox(width: Spacing.s),
                        IconButton(
                          tooltip: 'Download available',
                          icon: const Icon(Icons.download_for_offline_outlined),
                          onPressed: () => context.push(Routes.downloads),
                        ),
                      ],
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: Spacing.m),
                    Container(
                      padding: const EdgeInsets.all(Spacing.m),
                      decoration: BoxDecoration(
                        color: c.errorAccent.withValues(alpha: 0.12),
                        borderRadius: Radii.control,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: c.errorAccent,
                            size: 18,
                          ),
                          const SizedBox(width: Spacing.s),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          if (track.provider == SourceProvider.youtube) ...[
                            const SizedBox(width: Spacing.s),
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: () {
                                context.push(
                                  '/youtube/${track.externalId}',
                                  extra: {'title': track.title, 'artist': track.artist},
                                );
                              },
                              child: const Text('Pure Audio Mode'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.xl),
                  // PLY-004: seek bar with screen-reader value; disabled
                  // honestly when the source can't seek or duration unknown.
                  if (!state.canSeek || duration <= 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
                      child: Text(
                        'Seeking unavailable for this source',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    )
                  else
                    Semantics(
                      slider: true,
                      label: 'Playback position',
                      value:
                          '${formatDurationMs(position.round())} of ${formatDurationMs(duration)}',
                      enabled: true,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(trackHeight: 4),
                        child: Slider(
                          value: progress,
                          onChangeStart: (v) {
                            setState(() {
                              _scrubbing = true;
                              _scrubValue = v * duration;
                            });
                          },
                          onChanged: (v) {
                            setState(() => _scrubValue = v * duration);
                          },
                          onChangeEnd: (v) async {
                            await coordinator.seekTo((v * duration).round());
                            setState(() => _scrubbing = false);
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDurationMs(position.round()),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          duration > 0
                              ? '-${formatDurationMs(duration - position.round())}'
                              : 'Unknown length',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Shuffle',
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: state.shuffle
                              ? c.brandPrimary
                              : c.textSecondary,
                        ),
                        onPressed: () => coordinator.setShuffle(!state.shuffle),
                      ),
                      IconButton(
                        tooltip: 'Previous track',
                        icon: const Icon(Icons.skip_previous_rounded, size: 36),
                        onPressed: () => coordinator.previous(),
                      ),
                      // Hero play control — always ≥72px target.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: state.isPlaying ? 'Pause' : 'Play',
                          iconSize: 40,
                          color: c.backgroundMain,
                          icon: Icon(
                            state.isBusy
                                ? Icons.hourglass_top_rounded
                                : state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          onPressed: () => unawaitedToggle(coordinator),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next track',
                        icon: const Icon(Icons.skip_next_rounded, size: 36),
                        onPressed: () => coordinator.next(),
                      ),
                      IconButton(
                        tooltip: 'Repeat: ${state.repeatMode.name}',
                        icon: Icon(
                          switch (state.repeatMode) {
                            RepeatMode.off => Icons.repeat_rounded,
                            RepeatMode.all => Icons.repeat_rounded,
                            RepeatMode.one => Icons.repeat_one_rounded,
                          },
                          color: state.repeatMode == RepeatMode.off
                              ? c.textSecondary
                              : c.brandPrimary,
                        ),
                        onPressed: () => coordinator.cycleRepeat(),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.l),
                  Row(
                    children: [
                      IconButton(
                        focusNode: _volumeFocus,
                        tooltip: state.muted ? 'Unmute' : 'Mute',
                        icon: Icon(
                          state.muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                        ),
                        onPressed: () =>
                            coordinator.setVolume(state.muted ? 1.0 : 0.0),
                      ),
                      Expanded(
                        child: Slider(
                          value: state.muted ? 0 : state.volume,
                          label:
                              '${((state.muted ? 0 : state.volume) * 100).round()}%',
                          onChanged: (v) => coordinator.setVolume(v),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(Routes.queue),
                        icon: const Icon(Icons.queue_music_outlined, size: 18),
                        label: Text(
                          'Queue · ${state.queueLength}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.s),
                  Wrap(
                    spacing: Spacing.s,
                    runSpacing: Spacing.xs,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.lyrics_rounded, size: 16),
                        label: const Text('Lyrics'),
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => LyricsSheet(track: track),
                        ),
                      ),
                      if (track.provider != SourceProvider.radio)
                        ActionChip(
                          avatar: const Icon(Icons.radio_rounded, size: 16),
                          label: const Text('Start Radio'),
                          onPressed: () async {
                            showAppSnackBar(
                              context,
                              'Building radio mix from "${track.title}"...',
                            );
                            final radio = radio_svc.RadioBuilder(
                              lastFm: ref.read(lastFmServiceProvider),
                              audius: ref.read(audiusProvider),
                              jamendo: ref.read(jamendoProvider),
                            );
                            final tracks = await radio.buildFromTrack(track);
                            if (tracks.length <= 1) {
                              if (context.mounted) {
                                showAppSnackBar(
                                  context,
                                  'No similar tracks found right now.',
                                );
                              }
                              return;
                            }
                            await coordinator.playTracks(tracks, startIndex: 0);
                            if (context.mounted) {
                              showAppSnackBar(
                                context,
                                'Radio started · ${tracks.length} tracks queued',
                              );
                            }
                          },
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.speed_rounded, size: 16),
                        label: Text('${state.speed.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')}x'),
                        onPressed: () => _showSpeedSheet(context, state, coordinator),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSpeedSheet(
    BuildContext context,
    PlaybackState state,
    coordinator,
  ) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Playback speed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.m),
                Wrap(
                  spacing: Spacing.s,
                  runSpacing: Spacing.s,
                  children: [
                    for (final s in speeds)
                      ChoiceChip(
                        label: Text('${s}x'),
                        selected: (state.speed - s).abs() < 0.01,
                        onSelected: (_) async {
                          await coordinator.setSpeed(s);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSleepTimerSheet(
    BuildContext context,
    PlaybackState state,
    coordinator,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final active = state.sleepTimerEndsAt != null;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sleep timer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.m),
                if (active)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.m),
                    child: Text(
                      'Pauses at ${TimeOfDay.fromDateTime(state.sleepTimerEndsAt!).format(context)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Wrap(
                  spacing: Spacing.s,
                  runSpacing: Spacing.s,
                  children: [
                    for (final minutes in kSleepTimerChoices)
                      ActionChip(
                        label: Text('$minutes min'),
                        onPressed: () async {
                          await coordinator.startSleepTimerMinutes(minutes);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ActionChip(
                      label: const Text('End of track'),
                      onPressed: () async {
                        await coordinator.startSleepTimerEndOfTrack();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.l),
                OutlinedButton(
                  onPressed: () async {
                    await coordinator.cancelSleepTimer();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Cancel timer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSourceDialog(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Source link'),
        content: SelectableText(url),
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
