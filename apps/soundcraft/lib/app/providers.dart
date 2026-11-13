import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soundcraft/data/import/library_scanner.dart';
import 'package:soundcraft/data/providers/archive/archive_provider.dart';
import 'package:soundcraft/data/providers/audius/audius_provider.dart';
import 'package:soundcraft/data/providers/jamendo/jamendo_provider.dart';
import 'package:soundcraft/data/providers/lastfm/lastfm_service.dart';
import 'package:soundcraft/data/providers/lyrics/lrclib_service.dart';
import 'package:soundcraft/data/providers/radio/radio_provider.dart';
import 'package:soundcraft/data/providers/youtube/youtube_provider.dart';
import 'package:soundcraft/data/repositories/downloads_repository.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/data/repositories/playlist_repository.dart';
import 'package:soundcraft/data/repositories/queue_repository.dart';
import 'package:soundcraft/data/repositories/settings_repository.dart';
import 'package:soundcraft/downloads/download_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show AudioPlayer;
import 'package:path_provider/path_provider.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';
import 'package:soundcraft/domain/models/playback.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';
import 'package:soundcraft/player/audio_platform.dart';
import 'package:soundcraft/player/player_coordinator.dart';

/// Database (single instance, opened once).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('overridden in main bootstrap');
});

// ---------------------------------------------------------------- repositories

final localLibraryRepoProvider = Provider(
  (ref) => LocalLibraryRepository(ref.watch(appDatabaseProvider)),
);

final playlistRepoProvider = Provider(
  (ref) => PlaylistRepository(ref.watch(appDatabaseProvider)),
);

final favoritesRepoProvider = Provider(
  (ref) => FavoritesRepository(ref.watch(appDatabaseProvider)),
);

final historyRepoProvider = Provider((ref) {
  final repo = HistoryRepository(ref.watch(appDatabaseProvider));
  return repo;
});

final queueRepoProvider = Provider(
  (ref) => QueueRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepoProvider = Provider(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final downloadsRepoProvider = Provider(
  (ref) => DownloadsRepository(ref.watch(appDatabaseProvider)),
);

final providerCacheRepoProvider = Provider(
  (ref) => ProviderCacheRepository(ref.watch(appDatabaseProvider)),
);

// ---------------------------------------------------------------- audio engine

/// Production engine; tests override with a fake (audio_platform.dart).
final audioEngineProvider = Provider<AudioPlatform>((ref) {
  throw UnimplementedError('overridden in main bootstrap');
});

// ---------------------------------------------------------------- providers

final audiusApiProvider = Provider<AudiusApi>((ref) {
  return AudiusApi();
});

final audiusProvider = Provider<AudiusProvider>((ref) {
  return AudiusProvider(
    ref.watch(audiusApiProvider),
    cache: ref.watch(providerCacheRepoProvider),
  );
});

/// Gateway URL: uses compile-time `SOUNDCRAFT_GATEWAY_URL` or a user-saved
/// Cloudflare Worker URL from Settings (`PrefKeys.gatewayUrl`).
class GatewayUrlNotifier extends Notifier<String?> {
  @override
  String? build() {
    const envUrl = String.fromEnvironment('SOUNDCRAFT_GATEWAY_URL');
    Future.microtask(_loadSaved);
    return envUrl.isNotEmpty ? envUrl : null;
  }

  Future<void> _loadSaved() async {
    try {
      final saved = await ref.read(settingsRepoProvider).getString(PrefKeys.gatewayUrl);
      if (saved != null && saved.trim().isNotEmpty) {
        state = saved.trim();
      }
    } catch (_) {}
  }

  Future<void> setUrl(String? url) async {
    final cleaned = url?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      await ref.read(settingsRepoProvider).setString(PrefKeys.gatewayUrl, '');
      const envUrl = String.fromEnvironment('SOUNDCRAFT_GATEWAY_URL');
      state = envUrl.isNotEmpty ? envUrl : null;
    } else {
      await ref.read(settingsRepoProvider).setString(PrefKeys.gatewayUrl, cleaned);
      state = cleaned;
    }
  }
}

final gatewayUrlNotifierProvider =
    NotifierProvider<GatewayUrlNotifier, String?>(GatewayUrlNotifier.new);

final gatewayUrlProvider = Provider<String?>((ref) {
  return ref.watch(gatewayUrlNotifierProvider);
});

final youtubeProvider = Provider<YouTubeProvider>((ref) {
  return YouTubeProvider(gatewayUrl: ref.watch(gatewayUrlProvider));
});

final jamendoProvider = Provider<JamendoProvider>((ref) {
  return JamendoProvider(gatewayUrl: ref.watch(gatewayUrlProvider));
});

final archiveProvider = Provider<InternetArchiveProvider>((ref) {
  return InternetArchiveProvider();
});

final radioProvider = Provider<RadioBrowserProvider>((ref) {
  return RadioBrowserProvider();
});

final lrclibServiceProvider = Provider<LrclibService>((ref) {
  return LrclibService();
});

final lastFmServiceProvider = Provider<LastFmService>((ref) {
  return LastFmService(gatewayUrl: ref.watch(gatewayUrlProvider));
});

final discoveryProvidersProvider = Provider<List<MusicDiscoveryProvider>>((
  ref,
) {
  return [
    ref.watch(audiusProvider),
    ref.watch(jamendoProvider),
    ref.watch(archiveProvider),
    ref.watch(radioProvider),
    ref.watch(youtubeProvider),
  ];
});

// ---------------------------------------------------------------- player

final playbackResolversProvider =
    Provider<Map<SourceProvider, PlaybackResolver>>((ref) {
      final audius = ref.watch(audiusProvider);
      final jamendo = ref.watch(jamendoProvider);
      final archive = ref.watch(archiveProvider);
      final radio = ref.watch(radioProvider);
      final youtube = ref.watch(youtubeProvider);
      return {
        SourceProvider.audius: (track) async {
          final spec = await audius.resolvePlayback(track);
          if (spec == null) {
            throw const PlaybackException('Stream could not be resolved');
          }
          return spec;
        },
        SourceProvider.jamendo: (track) async {
          final spec = await jamendo.resolvePlayback(track);
          if (spec == null) {
            throw const PlaybackException('Jamendo stream could not be resolved');
          }
          return spec;
        },
        SourceProvider.archive: (track) async {
          final spec = await archive.resolvePlayback(track);
          if (spec == null) {
            throw const PlaybackException('Archive stream could not be resolved');
          }
          return spec;
        },
        SourceProvider.radio: (track) async {
          final spec = await radio.resolvePlayback(track);
          if (spec == null) {
            throw const PlaybackException('Radio stream could not be resolved');
          }
          return spec;
        },
        SourceProvider.youtube: (track) async {
          final spec = await youtube.resolvePlayback(track);
          if (spec == null) {
            throw const PlaybackException('YouTube stream could not be resolved');
          }
          return spec;
        },
      };
    });

final playerCoordinatorProvider = Provider<PlayerCoordinator>((ref) {
  final coordinator = PlayerCoordinator(
    engine: ref.watch(audioEngineProvider),
    queueRepository: ref.watch(queueRepoProvider),
    historyRepository: ref.watch(historyRepoProvider),
    resolvers: ref.watch(playbackResolversProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  return ref.watch(playerCoordinatorProvider).stateStream;
});

// ---------------------------------------------------------------- downloads

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final libraryRepo = ref.watch(localLibraryRepoProvider);
  final manager = DownloadManager(
    repository: ref.watch(downloadsRepoProvider),
    urlResolver: (track) async {
      if (track.provider == SourceProvider.youtube) {
        final yt = ref.read(youtubeProvider);
        final url = await yt.resolveStreamUrl(track.externalId);
        return Uri.parse(url);
      }
      if (track.provider == SourceProvider.jamendo) {
        final jamendo = ref.read(jamendoProvider);
        return jamendo.resolveDownloadUrl(track.externalId);
      }
      if (track.provider == SourceProvider.archive) {
        final archive = ref.read(archiveProvider);
        return archive.resolveDownloadUrl(track.externalId);
      }
      final audius = ref.read(audiusProvider);
      try {
        final url = await audius.resolveDownloadUrl(track.externalId);
        return Uri.parse(url);
      } catch (_) {
        // If track is not flagged as officially downloadable, fall back to streaming audio URL
        final streamUrl = await audius.resolvePlayback(track);
        if (streamUrl is UrlAudioSource) {
          return Uri.parse(streamUrl.url);
        }
        rethrow;
      }
    },
    onDownloadCompleted: (
      filePath,
      title,
      artist, {
      String? artworkUrl,
      int? durationMs,
      String? album,
    }) async {
      try {
        final file = File(filePath);
        if (!await file.exists()) return;
        final bytes = await file.length();
        if (bytes == 0) return;
        final hash = sha256.convert(utf8.encode(filePath)).toString();

        int? resolvedDurationMs = durationMs;
        Uint8List? artwork;
        String? resolvedAlbum = album;
        try {
          final scanner = LibraryScanner();
          await for (final event in scanner.scanFiles([filePath])) {
            if (event is ScanDone && event.tracks.isNotEmpty) {
              final t = event.tracks.first;
              resolvedDurationMs = t.durationMs ?? resolvedDurationMs;
              artwork = t.artwork;
              resolvedAlbum = t.album ?? resolvedAlbum;
            }
          }
        } catch (_) {}

        if (artwork == null && artworkUrl != null && artworkUrl.isNotEmpty) {
          try {
            final res = await Dio().get<List<int>>(
              artworkUrl,
              options: Options(
                responseType: ResponseType.bytes,
                receiveTimeout: const Duration(seconds: 10),
              ),
            );
            final data = res.data;
            if (data != null && data.isNotEmpty && data.length <= 256 * 1024) {
              artwork = Uint8List.fromList(data);
            }
          } catch (_) {}
        }

        final scanned = ScannedTrack(
          uri: filePath,
          uriKind: 'file',
          title: title,
          fingerprint: hash,
          artist: artist,
          album: resolvedAlbum,
          durationMs: resolvedDurationMs,
          artwork: artwork,
          sizeBytes: bytes,
          modifiedAt: DateTime.now(),
        );
        await libraryRepo.upsertScanned([scanned]);
      } catch (e) {
        debugPrint('[download] Auto-import to library failed: $e');
      }
    },
    networkAllowed: () => _networkAllowedForDownloads(ref),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

Future<bool> _networkAllowedForDownloads(Ref ref) async {
  final settings = ref.read(settingsRepoProvider);
  final wifiOnly = await settings.getBool(
    PrefKeys.downloadsWifiOnly,
    fallback: false,
  );
  if (!wifiOnly) return true;
  final connectivity = Connectivity();
  final results = await connectivity.checkConnectivity();
  return !results.contains(ConnectivityResult.mobile);
}

final downloadsStreamProvider = StreamProvider<List<DownloadJobView>>((ref) {
  return ref.watch(downloadManagerProvider).jobsStream;
});

// ---------------------------------------------------------------- rights

final rightsGateProvider = Provider<RightsGate>((ref) => const RightsGate());

// ---------------------------------------------------------------- connectivity

final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  Future<bool> current() async {
    try {
      final results = await Connectivity().checkConnectivity();
      // On Android / modern platforms, connectivity can report mobile, wifi, ethernet, vpn, or other.
      // If none of those or if explicitly only contains none, treat carefully.
      return results.any((r) => r != ConnectivityResult.none);
    } on Object {
      // Plugin unavailable (e.g. tests, exotic hosts): assume online;
      // actual requests surface their own typed errors when offline.
      return true;
    }
  }

  current().then(controller.add);
  final sub = Connectivity().onConnectivityChanged.listen(
    (results) => controller.add(results.any((r) => r != ConnectivityResult.none)),
    onError: (Object _) => controller.add(true),
  );
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Downloads directory (app-owned storage; §3.11).
final downloadsDirProvider = FutureProvider<Directory>((ref) async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}/SoundCraft Downloads');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
});

/// Tracks imported via the web file picker live in memory; this provider holds
/// the per-session bytes map keyed by local track id (browser sandbox limits).
final webImportedBytesProvider = Provider<Map<String, List<int>>>((ref) => {});

/// Exposed for tests and diagnostics: whether the app runs in a browser.
final isWebPlatform = bool.fromEnvironment('dart.library.js_util');

/// Ignored import guard so analyzer keeps AudioPlayer symbol for platform
/// integration notes.
// ignore: unused_element
const AudioPlayer? _audioPlayerDocRef = null;
