import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';

/// First-run onboarding (§3.1): 2 purposeful screens, everything skippable,
/// no account barrier, permissions requested only contextually later.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsRepoProvider).setBool(PrefKeys.onboardingDone, true);
    if (mounted) {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _IntroPage(
                    art: BrandMark(size: 160),
                    title: AppIdentity.appName,
                    body:
                        'Your music. Your rhythm. An offline-first player where '
                        'your library stays on your device — with optional, '
                        'clearly-labeled discovery from Audius and YouTube.',
                  ),
                  _IntroPage(
                    art: const Icon(Icons.offline_pin_rounded, size: 140),
                    title: 'Local-first, always',
                    body:
                        'Import your files and everything works with no account, '
                        'no API key and no network. Online feeds appear only when '
                        'you ask for them — and permissions are requested only '
                        'when you start importing.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 2; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? context.scColors.brandPrimary
                                : context.scColors.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(onPressed: _finish, child: const Text('Skip')),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (_page == 0) {
                            _controller.nextPage(
                              duration: ScDurations.transition,
                              curve: Curves.easeOutCubic,
                            );
                          } else {
                            _finish();
                          }
                        },
                        child: Text(_page == 0 ? 'Next' : 'Get started'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.art,
    required this.title,
    required this.body,
  });
  final Widget art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          art,
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
