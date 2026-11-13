import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/design_system/design_system.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube audio-centric player screen that conceals the video stream
/// behind a full Spotify-style album artwork & audio player UI.
class YouTubeViewerScreen extends ConsumerStatefulWidget {
  const YouTubeViewerScreen({
    super.key,
    required this.videoId,
    this.title,
    this.artist,
  });

  final String videoId;
  final String? title;
  final String? artist;

  @override
  ConsumerState<YouTubeViewerScreen> createState() => _YouTubeViewerScreenState();
}

class _YouTubeViewerScreenState extends ConsumerState<YouTubeViewerScreen> {
  late final YoutubePlayerController _controller;
  bool _isPlaying = true;
  double _currentPosition = 0;
  double _totalDuration = 0;
  bool _showVideo = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
      ),
    );

    _controller.loadVideoById(videoId: widget.videoId);

    // Periodic time update for smooth slider progress
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      try {
        final pos = await _controller.currentTime;
        final dur = await _controller.duration;
        if (mounted) {
          setState(() {
            _currentPosition = pos;
            if (dur > 0) _totalDuration = dur;
          });
        }
      } catch (_) {}
    });

    // Listen to playback state
    _controller.listen((event) {
      if (!mounted) return;
      final playerState = event.playerState;
      if (playerState == PlayerState.playing) {
        if (!_isPlaying) setState(() => _isPlaying = true);
      } else if (playerState == PlayerState.paused || playerState == PlayerState.ended) {
        if (_isPlaying) setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.close();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final d = Duration(seconds: seconds.round());
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    final artworkUrl = 'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg';
    final progress = _totalDuration > 0
        ? (_currentPosition / _totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playing from YouTube', style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            tooltip: 'Download audio',
            icon: const Icon(Icons.download_rounded),
            onPressed: () async {
              final manager = ref.read(downloadManagerProvider);
              final track = Track(
                stableId: stableTrackId(SourceProvider.youtube, widget.videoId),
                provider: SourceProvider.youtube,
                externalId: widget.videoId,
                title: widget.title ?? 'YouTube Track',
                artist: widget.artist ?? 'YouTube',
                artworkUrl: 'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg',
                isDownloadable: true,
                isStreamable: true,
              );
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
              } catch (e) {
                if (context.mounted) {
                  showAppSnackBar(context, 'Could not start download: $e');
                }
              }
            },
          ),
          IconButton(
            tooltip: _showVideo ? 'Audio Mode' : 'Watch Video',
            icon: Icon(_showVideo ? Icons.music_note_rounded : Icons.smart_display_outlined),
            onPressed: () => setState(() => _showVideo = !_showVideo),
          ),
          IconButton(
            tooltip: 'Close player',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              unawaited(_controller.pauseVideo());
              context.pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Embedded YouTube iFrame (kept in tree for audio playback)
            Positioned(
              top: _showVideo ? 0 : -9999,
              left: 0,
              right: 0,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

            // Spotify-style Audio Interface
            if (!_showVideo)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Album Artwork View
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.xl),
                          child: Container(
                            width: 280,
                            height: 280,
                            color: c.backgroundSurface,
                            child: Image.network(
                              artworkUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.music_note_rounded,
                                size: 80,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.xl),

                        // Title & Artist
                        Text(
                          widget.title ?? 'YouTube Track',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          widget.artist ?? 'YouTube',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: c.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.l),

                        // Time & Seek Slider
                        Column(
                          children: [
                            Slider(
                              value: progress,
                              onChanged: (v) {
                                final target = v * _totalDuration;
                                unawaited(_controller.seekTo(seconds: target, allowSeekAhead: true));
                                setState(() => _currentPosition = target);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatTime(_currentPosition), style: Theme.of(context).textTheme.labelSmall),
                                  Text(_totalDuration > 0 ? _formatTime(_totalDuration) : '--:--', style: Theme.of(context).textTheme.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.m),

                        // Audio Play/Pause Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.replay_10_rounded),
                              tooltip: 'Rewind 10s',
                              onPressed: () async {
                                final cur = await _controller.currentTime;
                                unawaited(_controller.seekTo(seconds: max(0, cur - 10), allowSeekAhead: true));
                              },
                            ),
                            const SizedBox(width: Spacing.l),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: c.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                iconSize: 42,
                                color: c.backgroundMain,
                                tooltip: _isPlaying ? 'Pause' : 'Play',
                                icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                onPressed: () {
                                  if (_isPlaying) {
                                    unawaited(_controller.pauseVideo());
                                  } else {
                                    unawaited(_controller.playVideo());
                                  }
                                  setState(() => _isPlaying = !_isPlaying);
                                },
                              ),
                            ),
                            const SizedBox(width: Spacing.l),
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.forward_10_rounded),
                              tooltip: 'Forward 10s',
                              onPressed: () async {
                                final cur = await _controller.currentTime;
                                unawaited(_controller.seekTo(seconds: cur + 10, allowSeekAhead: true));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xl),

                        // Pure Audio Mode Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.graphic_eq_rounded, size: 16, color: c.brandPrimary),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              'Pure Audio Mode',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.brandPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
