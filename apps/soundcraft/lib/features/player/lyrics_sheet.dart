import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/data/providers/lyrics/lrclib_service.dart';
import 'package:soundcraft/design_system/design_system.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Modal bottom sheet displaying synced or plain lyrics from LRCLIB.
class LyricsSheet extends ConsumerStatefulWidget {
  const LyricsSheet({super.key, required this.track});

  final Track track;

  @override
  ConsumerState<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends ConsumerState<LyricsSheet> {
  LyricsResult? _result;
  bool _loading = true;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await ref.read(lrclibServiceProvider).fetch(
          title: widget.track.title,
          artist: widget.track.artist,
          durationMs: widget.track.durationMs,
        );
    if (!mounted) return;
    setState(() {
      _result = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(playbackStateProvider).asData?.value ?? const PlaybackState();
    final coordinator = ref.read(playerCoordinatorProvider);
    final c = context.scColors;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: c.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Lyrics · ${widget.track.title}',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.track.artist != null)
                Text(
                  widget.track.artist!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_result == null || _result!.isEmpty)
                        ? const EmptyStateView(
                            icon: Icons.lyrics_outlined,
                            title: 'No lyrics found',
                            message:
                                'Synced lyrics are provided by LRCLIB and may not exist for every track.',
                          )
                        : _result!.synced.isNotEmpty
                            ? _buildSynced(
                                _result!.synced,
                                state.positionMs,
                                coordinator.seekTo,
                                scrollController,
                                c,
                              )
                            : SingleChildScrollView(
                                controller: scrollController,
                                child: Text(
                                  _result!.plainText ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(height: 1.6),
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSynced(
    List<LyricLine> lines,
    int positionMs,
    Future<void> Function(int) onSeek,
    ScrollController controller,
    SoundCraftColors c,
  ) {
    var activeIdx = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].timeMs <= positionMs) {
        activeIdx = i;
      } else {
        break;
      }
    }
    return ListView.builder(
      controller: controller,
      itemCount: lines.length,
      itemBuilder: (context, i) {
        final line = lines[i];
        final active = i == activeIdx;
        return InkWell(
          onTap: () => onSeek(line.timeMs),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Text(
              line.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: active ? c.brandPrimary : c.textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ),
        );
      },
    );
  }
}
