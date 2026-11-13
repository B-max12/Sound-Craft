import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/app/providers.dart';

/// Appearance controller (SET-001/006): theme mode + reduced motion, persisted.
class AppearanceController extends AsyncNotifier<AppearanceSettings> {
  @override
  Future<AppearanceSettings> build() async {
    final settings = ref.watch(settingsRepoProvider);
    final mode = await settings.getString(PrefKeys.themeMode);
    final reduced = await settings.getBool(PrefKeys.reducedMotion);
    return AppearanceSettings(
      mode: ThemeMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => ThemeMode.dark,
      ),
      reducedMotion: reduced,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    final current = state.value ?? const AppearanceSettings();
    state = AsyncData(current.copyWith(mode: mode));
    await ref
        .read(settingsRepoProvider)
        .setString(PrefKeys.themeMode, mode.name);
  }

  Future<void> setReducedMotion(bool value) async {
    final current = state.value ?? const AppearanceSettings();
    state = AsyncData(current.copyWith(reducedMotion: value));
    await ref.read(settingsRepoProvider).setBool(PrefKeys.reducedMotion, value);
  }
}

class AppearanceSettings {
  const AppearanceSettings({
    this.mode = ThemeMode.dark,
    this.reducedMotion = false,
  });

  final ThemeMode mode;
  final bool reducedMotion;

  AppearanceSettings copyWith({ThemeMode? mode, bool? reducedMotion}) =>
      AppearanceSettings(
        mode: mode ?? this.mode,
        reducedMotion: reducedMotion ?? this.reducedMotion,
      );
}

final appearanceProvider =
    AsyncNotifierProvider<AppearanceController, AppearanceSettings>(
      AppearanceController.new,
    );

/// Privacy controller (SET-004, §3.13): history/search-history toggles.
class PrivacyController extends AsyncNotifier<PrivacySettings> {
  @override
  Future<PrivacySettings> build() async {
    final settings = ref.watch(settingsRepoProvider);
    final history = await settings.getBool(
      PrefKeys.historyEnabled,
      fallback: true,
    );
    final searchHistory = await settings.getBool(
      PrefKeys.searchHistoryEnabled,
      fallback: true,
    );
    final personalization = await settings.getBool(
      PrefKeys.personalizationEnabled,
      fallback: true,
    );
    final repo = ref.read(historyRepoProvider);
    repo.enabled = history;
    return PrivacySettings(
      historyEnabled: history,
      searchHistoryEnabled: searchHistory,
      personalizationEnabled: personalization,
    );
  }

  Future<void> setHistoryEnabled(bool value) async {
    final current = state.value ?? const PrivacySettings();
    state = AsyncData(current.copyWith(historyEnabled: value));
    await ref
        .read(settingsRepoProvider)
        .setBool(PrefKeys.historyEnabled, value);
    ref.read(historyRepoProvider).enabled = value;
  }

  Future<void> setSearchHistoryEnabled(bool value) async {
    final current = state.value ?? const PrivacySettings();
    state = AsyncData(current.copyWith(searchHistoryEnabled: value));
    await ref
        .read(settingsRepoProvider)
        .setBool(PrefKeys.searchHistoryEnabled, value);
  }

  Future<void> setPersonalizationEnabled(bool value) async {
    final current = state.value ?? const PrivacySettings();
    state = AsyncData(current.copyWith(personalizationEnabled: value));
    await ref
        .read(settingsRepoProvider)
        .setBool(PrefKeys.personalizationEnabled, value);
  }
}

class PrivacySettings {
  const PrivacySettings({
    this.historyEnabled = true,
    this.searchHistoryEnabled = true,
    this.personalizationEnabled = true,
  });

  final bool historyEnabled;
  final bool searchHistoryEnabled;
  final bool personalizationEnabled;

  PrivacySettings copyWith({
    bool? historyEnabled,
    bool? searchHistoryEnabled,
    bool? personalizationEnabled,
  }) => PrivacySettings(
    historyEnabled: historyEnabled ?? this.historyEnabled,
    searchHistoryEnabled: searchHistoryEnabled ?? this.searchHistoryEnabled,
    personalizationEnabled:
        personalizationEnabled ?? this.personalizationEnabled,
  );
}

final privacyProvider =
    AsyncNotifierProvider<PrivacyController, PrivacySettings>(
      PrivacyController.new,
    );

/// Downloads data-usage controller (SET-002).
final wifiOnlyDownloadsProvider = FutureProvider<bool>((ref) async {
  return ref
      .watch(settingsRepoProvider)
      .getBool(PrefKeys.downloadsWifiOnly, fallback: true);
});
