import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/app/state.dart';

/// SoundCraft root widget: themes from tokens, typed router, RTL-ready,
/// localized delegates wired for future Urdu/ar translations (§1).
class SoundCraftApp extends ConsumerWidget {
  const SoundCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final appearance = ref.watch(appearanceProvider).asData?.value;
    return MaterialApp.router(
      title: 'SoundCraft',
      debugShowCheckedModeBanner: false,
      theme: SoundCraftThemes.light(),
      darkTheme: SoundCraftThemes.dark(),
      themeMode: appearance?.mode ?? ThemeMode.dark,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English UI in V1; Urdu & other locales planned (§1).
        Locale('ur'),
        Locale('ar'),
      ],
      // Accessibility: dynamic text scaling is honored by default; reduced
      // motion affects decorative animations via Durations helpers.
    );
  }
}
