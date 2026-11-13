import 'package:flutter_test/flutter_test.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/providers/audius/audius_models.dart';
import 'package:soundcraft/data/providers/audius/audius_provider.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Audius contract tests (P05): parsing real schema fixtures (captured live
/// 2026-11-03 from https://api.audius.co/v1/tracks/trending) + malformed
/// responses (contract §12: null fields, invalid artwork, rate limits).
void main() {
  // Shape mirrors the live API (field names verified 2026-11-03).
  final validTrack = {
    'id': 'W08NKdZ',
    'title': 'Post HospitiLL Slapperzzz Mix',
    'genre': 'Electronic',
    'mood': 'Defiant',
    'release_date': '2026-10-24T14:31:47Z',
    'duration': 394,
    'play_count': 2370,
    'favorite_count': 99,
    'is_downloadable': false,
    'is_streamable': true,
    'is_available': true,
    'is_delete': false,
    'permalink': '/illpetill/post-hospitill',
    'artwork': {
      '150x150': 'https://cdn.example/150.jpg',
      '480x480': 'https://cdn.example/480.jpg',
      '1000x1000': 'https://cdn.example/1000.jpg',
    },
    'user': {
      'id': 'user-1',
      'name': 'iLLPeTiLL',
      'handle': '@illpetill',
      'is_verified': true,
    },
  };

  group('AudiusTrackDto.fromJson', () {
    test('parses a live-schema track fully', () {
      final dto = AudiusTrackDto.fromJson(validTrack);
      expect(dto.id, 'W08NKdZ');
      expect(dto.title, contains('Slapperzzz'));
      expect(dto.artistName, 'iLLPeTiLL');
      expect(dto.artistVerified, isTrue);
      expect(dto.durationSec, 394);
      expect(dto.isDownloadable, isFalse); // trending track: NOT downloadable
      expect(dto.artwork480, 'https://cdn.example/480.jpg');
      expect(dto.releaseDate, isNotNull);
    });

    test('missing id or title throws FormatException (entry skipped)', () {
      expect(() => AudiusTrackDto.fromJson({}), throwsFormatException);
      expect(() => AudiusTrackDto.fromJson({'id': 'x'}), throwsFormatException);
      expect(
        () => AudiusTrackDto.fromJson({'id': 'x', 'title': 42}),
        throwsFormatException,
      );
    });

    test('defensive: missing user/artwork/duration do not crash', () {
      final dto = AudiusTrackDto.fromJson({'id': 'y', 'title': 'Bare'});
      expect(dto.artistName, 'Unknown artist');
      expect(dto.durationSec, isNull);
      expect(dto.artwork150, isNull);
      expect(dto.isDownloadable, isFalse); // unknown rights deny by default
    });

    test('wrong-typed optional fields are ignored, not crashing', () {
      final dto = AudiusTrackDto.fromJson({
        'id': 'z',
        'title': 'Odd',
        'duration': 'not-a-number',
        'play_count': 'also-string',
        'artwork': 'not-a-map',
        'user': 'not-a-map',
      });
      expect(dto.durationSec, isNull);
      expect(dto.playCount, isNull);
      expect(dto.artwork150, isNull);
      expect(dto.artistName, 'Unknown artist');
    });
  });

  group('parseAudiusList', () {
    test('skips malformed entries, keeps valid ones', () {
      final body = {
        'data': [
          validTrack,
          {'garbage': true},
          'not-a-map',
          {'id': '', 'title': 'empty id'},
          {'id': 'ok', 'title': 'Fine'},
        ],
      };
      final list = parseAudiusList(body);
      // parseAudiusList filters only by map-ness; DTO parsing filters further.
      expect(list.length, 4);
      final dtos = list
          .map((j) {
            try {
              return AudiusTrackDto.fromJson(j);
            } on FormatException {
              return null;
            }
          })
          .whereType<AudiusTrackDto>()
          .toList();
      expect(dtos.map((d) => d.id), ['W08NKdZ', 'ok']);
    });

    test('non-map or missing data yields empty list, never throws', () {
      expect(parseAudiusList(null), isEmpty);
      expect(parseAudiusList('nope'), isEmpty);
      expect(parseAudiusList({'data': 'wrong'}), isEmpty);
      expect(parseAudiusList({'error': true}), isEmpty);
    });
  });

  group('AudiusProvider capability + mapping', () {
    test('downloadable flag flows to capability; streamable-only cannot download',
        () {
      final provider = AudiusProvider(AudiusApi());
      final dlTrack = provider.buildTrackForTest(
        AudiusTrackDto.fromJson({
          ...validTrack,
          'is_downloadable': true,
        }),
      );
      expect(dlTrack.isDownloadable, isTrue);
      expect(provider.capability(dlTrack).canDownload, isTrue);
      expect(provider.capability(dlTrack).canBackground, isTrue);

      final streamOnly = provider.buildTrackForTest(
        AudiusTrackDto.fromJson(validTrack),
      );
      expect(streamOnly.isDownloadable, isFalse);
      expect(provider.capability(streamOnly).canDownload, isFalse);
    });

    test('deleted/unavailable tracks are not streamable (capability gate)', () {
      final provider = AudiusProvider(AudiusApi());
      final deleted = provider.buildTrackForTest(
        AudiusTrackDto.fromJson({...validTrack, 'is_delete': true}),
      );
      expect(deleted.isStreamable, isFalse);
      final cap = provider.capability(deleted);
      expect(cap.canPlayInApp, isFalse);
    });

    test('stable ids are namespaced and source URLs canonical', () {
      final provider = AudiusProvider(AudiusApi());
      final track = provider.buildTrackForTest(
        AudiusTrackDto.fromJson(validTrack),
      );
      expect(track.stableId, 'audius:W08NKdZ');
      expect(track.provider, SourceProvider.audius);
      expect(track.sourceUrl, isNotNull);
      expect(track.attributedTo, 'Audius');
    });
  });

  group('error mapping helpers', () {
    test('ProviderException flags for 429/5xx/network', () {
      const rl = ProviderException(
        'rate limited',
        provider: SourceProvider.audius,
        statusCode: 429,
        retryAfterSeconds: 30,
      );
      expect(rl.isRateLimited, isTrue);
      expect(rl.retryAfterSeconds, 30);
      expect(rl.isServerError, isFalse);

      const server = ProviderException(
        'boom',
        provider: SourceProvider.audius,
        statusCode: 503,
      );
      expect(server.isServerError, isTrue);

      const offline = ProviderException('no net', provider: SourceProvider.audius);
      expect(offline.isNetwork, isTrue);
    });
  });

  test('backoff is bounded and deterministic', () {
    final a = backoffFor(1);
    final b = backoffFor(1);
    expect(a, b); // deterministic for same attempt
    // Exponential growth is capped at shift 4 (16s base + jitter < 16.5s).
    expect(backoffFor(9).inMilliseconds, lessThanOrEqualTo(17000));
    expect(backoffFor(9).inMilliseconds, greaterThanOrEqualTo(16000));
  });
}

extension on AudiusProvider {
  /// Test seam: maps a DTO through the same path the adapter uses in prod.
  Track buildTrackForTest(AudiusTrackDto dto) => mapDtoToTrack(dto);
}
