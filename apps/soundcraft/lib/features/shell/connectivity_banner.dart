import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';

/// Gentle non-modal connectivity status (§23.4): local audio is never
/// interrupted; only an informational banner when offline.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).asData?.value ?? true;
    if (online) return const SizedBox.shrink();
    final c = context.scColors;
    return Material(
      color: c.backgroundElevated,
      child: InkWell(
        onTap: () {}, // information only
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, size: 14, color: c.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline — your library and downloads still work; online feeds are paused.',
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
