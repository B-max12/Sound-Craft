import 'package:soundcraft/player/player_coordinator.dart';

/// Shared helpers for player UI widgets. Kept separate so screens stay lean.

/// Rapid-tap-safe toggle: errors surface via state stream, not crashes.
Future<void> unawaitedToggle(PlayerCoordinator coordinator) async {
  try {
    await coordinator.togglePlay();
  } on Object {
    // The FSM records the typed error; UI shows it in Now Playing.
  }
}
