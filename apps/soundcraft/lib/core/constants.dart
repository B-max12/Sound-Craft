/// SoundCraft application-wide constants.
///
/// Brand identity per master contract §1: SoundCraft by Aur Labs.
library;

class AppIdentity {
  static const String appName = 'SoundCraft';
  static const String publisher = 'Aur Labs';
  static const String brandCredit = 'An Aur Labs Product';
  static const String slogan = 'Your Music. Your Rhythm.';
  static const String appVersion = '0.1.0+1';
  static const String supportContact =
      'support@aurlabs.example'; // Owner action queue #9.

  /// Audius API credentials
  static const String audiusApiKey = '0x58756719711297aac666e36ddefb91d57c1b5205';
  static const String audiusBearerToken =
      'aZajkrnCVHbfN0o303CbW_OP0dj4WHh1rqbMNk8wnkU=';

  /// YouTube Data API credentials
  static const String youtubeApiKey =
      'AIzaSyASOQ6048Z0LnbHizsogQPCo5d2oJTZK9M';
}

/// Storage keys for persisted preferences. Centralised to avoid typos.
class PrefKeys {
  static const themeMode = 'theme.mode'; // system|dark|light
  static const reducedMotion = 'accessibility.reducedMotion';
  static const searchHistoryEnabled = 'privacy.searchHistory.enabled';
  static const historyEnabled = 'privacy.history.enabled';
  static const personalizationEnabled = 'privacy.personalization.enabled';
  static const downloadsWifiOnly = 'downloads.wifiOnly';
  static const librarySort = 'library.sort'; // field
  static const librarySortDir = 'library.sortDir'; // asc|desc
  static const onboardingDone = 'onboarding.done';
  static const interests = 'onboarding.interests'; // JSON list
  static const sleepTimerMinutes = 'player.sleepTimerMinutes';
  static const gatewayUrl = 'network.gatewayUrl';
}

/// Namespaced provider identifiers (contract §24.1 invariant 2).
enum SourceProvider { local, audius, youtube, jamendo, archive, radio }

extension SourceProviderX on SourceProvider {
  String get id => switch (this) {
    SourceProvider.local => 'local',
    SourceProvider.audius => 'audius',
    SourceProvider.youtube => 'youtube',
    SourceProvider.jamendo => 'jamendo',
    SourceProvider.archive => 'archive',
    SourceProvider.radio => 'radio',
  };

  String get displayName => switch (this) {
    SourceProvider.local => 'Local',
    SourceProvider.audius => 'Audius',
    SourceProvider.youtube => 'YouTube',
    SourceProvider.jamendo => 'Jamendo',
    SourceProvider.archive => 'Internet Archive',
    SourceProvider.radio => 'Radio',
  };

  static SourceProvider fromId(String id) => switch (id) {
    'local' => SourceProvider.local,
    'audius' => SourceProvider.audius,
    'youtube' => SourceProvider.youtube,
    'jamendo' => SourceProvider.jamendo,
    'archive' => SourceProvider.archive,
    'radio' => SourceProvider.radio,
    _ => throw ArgumentError.value(id, 'id', 'Unknown provider'),
  };
}

/// Stable, namespaced track identifier: `local:<id>`, `audius:<id>`, `youtube:<id>`.
/// Same title from a different source is NEVER the same track (§24.1 invariant 2).
String stableTrackId(SourceProvider provider, String externalId) =>
    '${provider.id}:$externalId';

/// Parses a stable id back to (provider, externalId). Throws on malformed input.
({SourceProvider provider, String externalId}) parseStableTrackId(String id) {
  final i = id.indexOf(':');
  if (i <= 0) throw ArgumentError('Malformed stable id: $id');
  return (
    provider: SourceProviderX.fromId(id.substring(0, i)),
    externalId: id.substring(i + 1),
  );
}
