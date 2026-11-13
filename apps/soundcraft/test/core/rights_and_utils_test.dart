import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';

/// Rights decision table (contract §12 unit tests, R05).
void main() {
  const gate = RightsGate();

  Track track(SourceProvider p, {bool downloadable = false, bool streamable = true}) =>
      Track(
        stableId: stableTrackId(p, 'x1'),
        provider: p,
        externalId: 'x1',
        title: 'T',
        isDownloadable: downloadable,
        isStreamable: streamable,
      );

  group('RightsGate.evaluateDownload', () {
    test('YouTube download is allowed via direct stream extraction', () {
      final decision = gate.evaluateDownload(track(SourceProvider.youtube),
          permissionProof: true);
      expect(decision, isA<DownloadAllowed>());
    });

    test('Audius downloadable track is allowed with positive proof', () {
      final decision =
          gate.evaluateDownload(track(SourceProvider.audius, downloadable: true),
              permissionProof: true);
      expect(decision, isA<DownloadAllowed>());
    });

    test('local files: download is a no-op, denied with clear reason', () {
      final decision =
          gate.evaluateDownload(track(SourceProvider.local), permissionProof: true);
      expect(decision, isA<DownloadDenied>());
    });
  });

  group('RightsGate.canEnterAudioQueue', () {
    test('YouTube can enter the audio queue', () {
      expect(gate.canEnterAudioQueue(track(SourceProvider.youtube)), isTrue);
    });

    test('local + audius streamable items can', () {
      expect(gate.canEnterAudioQueue(track(SourceProvider.local)), isTrue);
      expect(
          gate.canEnterAudioQueue(track(SourceProvider.audius, downloadable: true)),
          isTrue);
    });

    test('unstreamable audius items cannot', () {
      expect(
          gate.canEnterAudioQueue(
              track(SourceProvider.audius, streamable: false)),
          isFalse);
    });
  });

  group('RightsGate.resolveCapability', () {
    test('audius downloadable exposes canDownload; streamable-only does not', () {
      final yes = gate.resolveCapability(
          track(SourceProvider.audius, downloadable: true));
      expect(yes.canDownload, isTrue);
      expect(yes.canBackground, isTrue);

      final no = gate.resolveCapability(
          track(SourceProvider.audius, downloadable: false));
      expect(no.canDownload, isFalse);
    });

    test('youtube capability: authorized audio, background, and download enabled', () {
      final cap = gate.resolveCapability(track(SourceProvider.youtube));
      expect(cap.canPlayInApp, isTrue);
      expect(cap.canBackground, isTrue);
      expect(cap.canDownload, isTrue);
    });

    test('unstreamable audius item reports unavailable with reason', () {
      final cap = gate.resolveCapability(
          track(SourceProvider.audius, streamable: false));
      expect(cap.canPlayInApp, isFalse);
      expect(cap.reason, contains('not streamable'));
    });
  });

  group('stable ids', () {
    test('namespaced ids never collide across providers', () {
      final local = stableTrackId(SourceProvider.local, '1');
      final audius = stableTrackId(SourceProvider.audius, '1');
      final youtube = stableTrackId(SourceProvider.youtube, '1');
      expect({local, audius, youtube}.length, 3);
    });

    test('parse roundtrip and malformed rejection', () {
      final parsed = parseStableTrackId('audius:abc123');
      expect(parsed.provider, SourceProvider.audius);
      expect(parsed.externalId, 'abc123');
      expect(() => parseStableTrackId('no-colon'), throwsArgumentError);
      expect(() => parseStableTrackId('weird:x'), throwsArgumentError);
    });
  });

  group('formatters', () {
    test('durations handle null/unknown/huge values', () {
      expect(formatDurationMs(null), '--:--');
      expect(formatDurationMs(-5), '--:--');
      expect(formatDurationMs(0), '0:00');
      expect(formatDurationMs(59000), '0:59');
      expect(formatDurationMs(61000), '1:01');
      expect(formatDurationMs(3661000), '1:01:01');
    });

    test('bytes formatting', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1024), '1.0 KB');
      expect(formatBytes(1536 * 1024), '1.5 MB');
      expect(formatBytes(null), '--');
    });

    test('filename sanitization blocks traversal & invalid names', () {
      final traversal = sanitizeFilename('../../etc/passwd');
      expect(traversal.contains('/'), isFalse); // separators eliminated
      expect(traversal.startsWith('.'), isFalse); // no leading-dot trickery
      expect(sanitizeFilename('a/b\\c:d*e?f"g<h>i|j'), 'a_b_c_d_e_f_g_h_i_j');
      expect(sanitizeFilename('..'), '_');
      expect(sanitizeFilename('CON.mp3'), '_CON.mp3');
      final long = sanitizeFilename('x' * 500);
      expect(long.length, lessThanOrEqualTo(180));
    });
  });

  group('typed errors', () {
    test('RightsDeniedException message is human-readable', () {
      final e = RightsDeniedException(RightsDenialReason.youtubePolicy);
      expect(e.message, contains('YouTube'));
    });

    test('ProviderException flags', () {
      const rateLimited =
          ProviderException('rl', provider: SourceProvider.audius, statusCode: 429);
      expect(rateLimited.isRateLimited, isTrue);
      expect(rateLimited.isNetwork, isFalse);
      const network = ProviderException('net', provider: SourceProvider.audius);
      expect(network.isNetwork, isTrue);
    });
  });
}
