import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/app/state.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';

/// Settings hub (§3.14): every row is real and persisted. Sub-pages exist for
/// Appearance, Privacy, About (legal docs) and Diagnostics.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider).asData?.value;
    final privacy = ref.watch(privacyProvider).asData?.value;
    final wifiOnly = ref.watch(wifiOnlyDownloadsProvider).asData?.value ?? true;
    final gateway = ref.watch(gatewayUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _SectionLabel('Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeName(appearance?.mode ?? ThemeMode.dark)),
            onTap: () => _pickTheme(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.animation_outlined),
            title: const Text('Reduce motion'),
            subtitle: const Text(
              'Minimise decorative animations (system setting is respected too).',
            ),
            value: appearance?.reducedMotion ?? false,
            onChanged: (v) =>
                ref.read(appearanceProvider.notifier).setReducedMotion(v),
          ),
          const Divider(indent: 16, endIndent: 16),
          _SectionLabel('Playback'),
          const ListTile(
            leading: Icon(Icons.music_note_outlined),
            title: Text('Gapless / crossfade'),
            subtitle: Text(
              'Not offered: the bundled engine does not expose these reliably on every platform. Nothing here is fake.',
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          _SectionLabel('Downloads & data'),
          SwitchListTile(
            secondary: const Icon(Icons.wifi_rounded),
            title: const Text('Wi-Fi only downloads'),
            subtitle: const Text(
              'Authorized downloads wait for Wi-Fi when enabled (SET-002).',
            ),
            value: wifiOnly,
            onChanged: (v) async {
              await ref
                  .read(settingsRepoProvider)
                  .setBool(PrefKeys.downloadsWifiOnly, v);
              ref.invalidate(wifiOnlyDownloadsProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear provider cache'),
            subtitle: const Text(
              'Removes cached discovery metadata only — never your files or downloads (SET-003).',
            ),
            onTap: () async {
              final removed = await ref.read(providerCacheRepoProvider).clear();
              if (context.mounted) {
                showAppSnackBar(
                  context,
                  'Cache cleared ($removed entries). Imported music and downloads are untouched.',
                );
              }
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _SectionLabel('Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.history_rounded),
            title: const Text('Listening history'),
            subtitle: const Text(
              'Device-local play history for Continue listening and Made for You.',
            ),
            value: privacy?.historyEnabled ?? true,
            onChanged: (v) =>
                ref.read(privacyProvider.notifier).setHistoryEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.manage_search_rounded),
            title: const Text('Search history'),
            subtitle: const Text('Recent search terms stored on this device.'),
            value: privacy?.searchHistoryEnabled ?? true,
            onChanged: (v) =>
                ref.read(privacyProvider.notifier).setSearchHistoryEnabled(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Personalization'),
            subtitle: const Text(
              'Ranking of local tracks for "Made for You". Disabling keeps history but stops ranking.',
            ),
            value: privacy?.personalizationEnabled ?? true,
            onChanged: (v) =>
                ref.read(privacyProvider.notifier).setPersonalizationEnabled(v),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear listening history'),
            subtitle: const Text(
              'Explicit scope: all play events on this device.',
            ),
            onTap: () async {
              final ok = await confirmDestructive(
                context,
                title: 'Clear listening history?',
                message: 'Removes every play event stored on this device. Playlists, favorites and files are not affected.',
                confirmLabel: 'Clear history',
              );
              if (ok) {
                await ref.read(historyRepoProvider).clearAll();
                if (context.mounted) {
                  showAppSnackBar(context, 'Listening history cleared.');
                }
              }
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _SectionLabel('About'),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Privacy policy'),
            onTap: () => context.push(Routes.legalPrivacy),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of use'),
            onTap: () => context.push(Routes.legalTerms),
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: const Text('Licenses & attributions'),
            onTap: () => context.push(Routes.legalLicenses),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Cloudflare Gateway URL'),
            subtitle: Text(
              gateway == null || gateway.isEmpty
                  ? 'Not set — tap to paste your Cloudflare Worker URL (enables Jamendo & Last.fm)'
                  : gateway,
            ),
            onTap: () => _editGatewayUrl(context, ref, gateway),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart_outlined),
            title: const Text('Diagnostics'),
            subtitle: Text(
              gateway == null
                  ? 'Gateway: not configured (Jamendo/Last.fm/YouTube disabled)'
                  : 'Gateway: configured',
            ),
            onTap: () => context.push(Routes.diagnostics),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('SoundCraft 0.1.0'),
            subtitle: Text('An Aur Labs Product · Your Music. Your Rhythm.'),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.dark => 'Dark (default)',
    ThemeMode.light => 'Light',
  };

  Future<void> _editGatewayUrl(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloudflare Gateway URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://soundcraft-discovery-gateway.yourname.workers.dev',
            labelText: 'Worker URL',
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved != null) {
      await ref.read(gatewayUrlNotifierProvider.notifier).setUrl(saved);
      if (context.mounted) {
        showAppSnackBar(
          context,
          saved.trim().isEmpty
              ? 'Gateway URL cleared.'
              : 'Gateway URL saved — pull to refresh Home.',
        );
      }
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current =
        ref.read(appearanceProvider).asData?.value.mode ?? ThemeMode.dark;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          for (final mode in ThemeMode.values)
            // ignore: deprecated_member_use
            RadioListTile<ThemeMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: current,
              title: Text(switch (mode) {
                ThemeMode.system => 'System',
                ThemeMode.dark => 'Dark',
                ThemeMode.light => 'Light',
              }),
              // ignore: deprecated_member_use
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(appearanceProvider.notifier).setMode(selected);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          color: context.scColors.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Diagnostics (§3.14/§25.4): provider health + gateway state, redacted.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  List<ProviderHealth>? _health;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    setState(() => _checking = true);
    final results = <ProviderHealth>[];
    for (final p in ref.read(discoveryProvidersProvider)) {
      results.add(await p.health());
    }
    if (!mounted) return;
    setState(() {
      _health = results;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gateway = ref.watch(gatewayUrlProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Run checks again',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _checking ? null : _runChecks,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Discovery gateway'),
            subtitle: Text(gateway ?? 'Not configured — owner action queue #4'),
          ),
          const Divider(),
          if (_checking)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            for (final h in _health ?? const <ProviderHealth>[])
              ListTile(
                leading: Icon(
                  h.available
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: h.available
                      ? context.scColors.success
                      : context.scColors.errorAccent,
                ),
                title: Text('Provider: ${h.provider.displayName}'),
                subtitle: Text(
                  '${h.detail ?? (h.available ? "Reachable" : "Unavailable")} · latency: ${h.latencyMs == null ? "n/a" : "${h.latencyMs} ms"}',
                ),
              ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Secrets'),
            subtitle: Text(
              'API keys: Audius key ${AppIdentity.audiusApiKey.isNotEmpty ? "✓ configured" : "✗ missing"} · '
              'YouTube key ${AppIdentity.youtubeApiKey.isNotEmpty ? "✓ configured" : "✗ missing"}. '
              'Keys are bundled in the app for direct API access.',
            ),
          ),
        ],
      ),
    );
  }
}
