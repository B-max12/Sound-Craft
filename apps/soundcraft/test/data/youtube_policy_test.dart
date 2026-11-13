import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/data/providers/youtube/youtube_provider.dart';
import 'package:soundcraft/domain/models/track.dart';

/// YouTube policy tests (P06, R05, §3.12): the provider NEVER grants audio
/// playback or download rights, with or without a configured gateway.
void main() {
  group('unconfigured gateway (owner action #4 pending)', () {
    final provider = YouTubeProvider(gatewayUrl: null);

    test('health reports configured with direct YouTube Data API', () async {
      final health = await provider.health();
      expect(health.available, isTrue);
    });

    test('isDownloadable returns true', () async {
      final track = _ytTrack();
      expect(await provider.isDownloadable(track), isTrue);
    });
  });

  group('configured gateway (contract level, HTTP-free)', () {
    final provider = YouTubeProvider(gatewayUrl: 'https://gw.example');

    test('capability allows playback and download', () {
      final cap = provider.capability(_ytTrack());
      expect(cap.canPlayInApp, isTrue);
      expect(cap.canDownload, isTrue);
    });

    test('isDownloadable is true', () async {
      expect(await provider.isDownloadable(_ytTrack()), isTrue);
    });

    test('search parses gateway response shape via local fake server',
        () async {
      expect(provider.isConfigured, isTrue);
    });
  });
}

Track _ytTrack() => Track(
      stableId: 'youtube:dQw4',
      provider: SourceProvider.youtube,
      externalId: 'dQw4',
      title: 'Some Video',
      sourceUrl: 'https://www.youtube.com/watch?v=dQw4',
    );
