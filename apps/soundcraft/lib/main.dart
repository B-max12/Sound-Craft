import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soundcraft/app/app.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/connection/connection.dart' as connection;
import 'package:soundcraft/player/audio_handler.dart';
import 'package:soundcraft/player/just_audio_platform.dart';

/// SoundCraft entry point. Bootstrap order (contract §24.1 invariant 3):
/// DB → engine (single instance) → OS media service → queue restore (no
/// autoplay) → app. Failures degrade gracefully; core local playback must
/// never depend on optional services.
Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Windows/Linux audio backend for just_audio (see docs/DECISIONS.md).
      JustAudioMediaKit.ensureInitialized(
        linux: !kIsWeb,
        windows: !kIsWeb,
        macOS: false,
        iOS: false,
        android: false,
      );

      if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }

      final database = AppDatabase(await connection.openPlatformConnection());
      final engine = JustAudioPlatform.create();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          audioEngineProvider.overrideWithValue(engine),
        ],
      );

      await _configureAudioSession(container);
      await _initAudioService(container);
      await container.read(playerCoordinatorProvider).restore();

      // Initialize download directory so downloads work immediately.
      try {
        final dlDir = await container.read(downloadsDirProvider.future);
        await container.read(downloadManagerProvider).setDownloadDirectory(dlDir);
      } on Object catch (e) {
        debugPrint('Download directory init skipped: $e');
      }

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('[crash:flutter] ${details.exception}');
        debugPrint('${details.stack}');
      };

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const SoundCraftApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('[crash:zone] $error');
      debugPrint('$stack');
    },
  );
}

/// Audio focus + interruptions (PLY-012, §7 case 3). Failures are non-fatal.
Future<void> _configureAudioSession(ProviderContainer container) async {
  if (kIsWeb) return;
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    final player = container.read(playerCoordinatorProvider);
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            unawaited(player.handleInterruptionBegin(duck: true));
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            unawaited(player.handleInterruptionBegin(duck: false));
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            unawaited(player.handleInterruptionEnd(shouldResume: false));
          case AudioInterruptionType.pause:
            unawaited(player.handleInterruptionEnd(shouldResume: true));
          case AudioInterruptionType.unknown:
            unawaited(player.handleInterruptionEnd(shouldResume: false));
        }
      }
    });
    session.becomingNoisyEventStream.listen((_) {
      unawaited(player.handleBecomingNoisy());
    });
  } on Object catch (e) {
    debugPrint('audio_session init skipped: $e');
  }
}

/// OS media controls on supported native platforms (§3.6). Non-fatal.
Future<void> _initAudioService(ProviderContainer container) async {
  if (kIsWeb) return;
  try {
    try {
      await Permission.notification.request();
    } catch (_) {}
    final handler = SoundCraftAudioHandler(
      container.read(playerCoordinatorProvider),
    );
    await AudioService.init(
      builder: () => handler,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'dev.aurlabs.soundcraft.playback',
        androidNotificationChannelName: 'SoundCraft Playback',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
    handler.attach();
  } on Object catch (e) {
    debugPrint('audio_service init skipped: $e');
  }
}
