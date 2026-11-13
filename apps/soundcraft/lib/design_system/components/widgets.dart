import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/design_system/tokens.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Branded album-artwork fallback (SYS-005): a cricket-spring placeholder, never
/// a random copyrighted cover. Used when artwork is missing or fails to load.
class ArtworkFallback extends StatelessWidget {
  const ArtworkFallback({
    super.key,
    this.size = 48,
    this.iconSize,
    this.radius,
  });
  final double size;
  final double? iconSize;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.brandDeep, c.backgroundElevated],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: c.brandPrimary.withValues(alpha: 0.85),
        size: iconSize ?? size * 0.42,
      ),
    );
  }
}

/// Artwork view with caching, graceful fallback and fixed square ratio
/// (no layout shift — SYS-005). Local tracks use the branded fallback.
class ArtworkView extends StatelessWidget {
  const ArtworkView({
    super.key,
    required this.track,
    this.size = 48,
    this.radius,
  });
  final Track track;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? Radii.s;
    final url = track.artworkUrl;
    Widget child;
    if (url == null || url.isEmpty) {
      child = ArtworkFallback(size: size, radius: r);
    } else {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          errorWidget: (_, _, _) => ArtworkFallback(size: size),
          placeholder: (_, _) => Container(
            width: size,
            height: size,
            color: context.scColors.skeletonBase,
          ),
          httpHeaders: const {},
          memCacheWidth: 480,
        ),
      );
    }
    if (url == null || url.isEmpty) return child;
    return SizedBox(width: size, height: size, child: child);
  }
}

/// Source badge so users always know where content comes from (SRCH-004,
/// Appendix A "truthful labeling").
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.provider, this.compact = false});
  final SourceProvider provider;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    final (bg, fg, label) = switch (provider) {
      SourceProvider.local => (c.badgeLocalBg, c.textPrimary, 'Local'),
      SourceProvider.audius => (c.badgeAudiusBg, c.textPrimary, 'Audius'),
      SourceProvider.youtube => (c.badgeYoutubeBg, c.textPrimary, 'YouTube'),
      SourceProvider.jamendo => (c.badgeAudiusBg, c.textPrimary, 'Jamendo'),
      SourceProvider.archive => (c.badgeLocalBg, c.textPrimary, 'Archive'),
      SourceProvider.radio => (c.badgeYoutubeBg, c.textPrimary, 'Radio'),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.circular),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Reusable track row with source badge, duration and trailing actions.
/// Every icon button has a semantic label (SYS-006).
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.isPlaying = false,
    this.leading,
    this.trailing,
    this.subtitle,
  });

  final Track track;
  final VoidCallback onTap;
  final bool isPlaying;
  final Widget? leading;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return Semantics(
      button: true,
      label:
          'Play ${track.title} by ${track.artist ?? 'unknown artist'} '
          'from ${track.provider.displayName}',
      child: ListTile(
        key: ValueKey('track-${track.stableId}'),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: 2,
        ),
        minLeadingWidth: 0,
        leading: leading ?? ArtworkView(track: track, size: 48),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPlaying ? c.brandPrimary : c.textPrimary,
            fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Flexible(
              child: Text(
                subtitle ?? track.artist ?? 'Unknown artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Badges scale down instead of overflowing at 200% text scale on
            // narrow screens (dynamic-type requirement, §23.2).
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: Spacing.s),
                    SourceBadge(provider: track.provider, compact: true),
                    if (track.isDownloadable) ...[
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Icons.download_rounded,
                        size: 14,
                        color: c.textTertiary,
                        semanticLabel: 'Download available',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing:
            trailing ??
            Text(
              formatDurationMs(track.durationMs),
              style: TextStyle(color: c.textTertiary, fontSize: 12),
            ),
        onTap: onTap,
      ),
    );
  }
}

/// Section header with optional action (Home feed, Library).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.subtitle,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.l,
        Spacing.xl,
        Spacing.l,
        Spacing.m,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Empty state with honest explanation + CTA (§3.15).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: c.textTertiary),
            const SizedBox(height: Spacing.l),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Typed error state with retry (§3.15 "recoverable retry").
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.isOffline = false,
    this.isRateLimited = false,
    this.retryAfterSeconds,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isOffline;
  final bool isRateLimited;
  final int? retryAfterSeconds;

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    final headline = isOffline
        ? "You're offline"
        : isRateLimited
        ? 'Slow down a moment'
        : 'Something went wrong';
    final detail = isRateLimited && retryAfterSeconds != null
        ? '$message Try again in $retryAfterSeconds s.'
        : message;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline
                  ? Icons.cloud_off_rounded
                  : isRateLimited
                  ? Icons.hourglass_top_rounded
                  : Icons.error_outline_rounded,
              size: 44,
              color: isOffline ? c.textTertiary : c.errorAccent,
            ),
            const SizedBox(height: Spacing.l),
            Text(headline, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Spacing.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shimmer placeholders (§2.3). Reduced-motion aware via [animate].
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = Radii.s,
    this.animate = true,
  });

  final double? width;
  final double height;
  final double radius;
  final bool animate;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant SkeletonBox old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = widget.animate ? _controller.value : 0.0;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(0 + 2 * t, 0),
              colors: [c.skeletonBase, c.skeletonHighlight, c.skeletonBase],
            ),
          ),
        );
      },
    );
  }
}

/// Confirmation dialog for destructive actions (LIB-007, SET-003/004…).
/// Returns true when confirmed; Esc/outside tap/Back all cancel (NAV-006).
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = true,
}) async {
  final c = context.scColors;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: c.errorAccent)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Accessible snackbar with optional action (§3.15).
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
}

/// Horizontal rail of album/track cards used by Home.
class TrackCardRail extends StatelessWidget {
  const TrackCardRail({
    super.key,
    required this.tracks,
    required this.onTrackTap,
    this.badge,
  });

  final List<Track> tracks;
  final void Function(Track) onTrackTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
        itemCount: tracks.length,
        separatorBuilder: (context, index) => const SizedBox(width: Spacing.m),
        itemBuilder: (context, i) {
          final t = tracks[i];
          return Semantics(
            button: true,
            label: 'Play ${t.title}',
            child: SizedBox(
              width: 148,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ArtworkView(track: t, size: 148, radius: Radii.m),
                      if (badge != null)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: Radii.circular,
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.s),
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    t.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
