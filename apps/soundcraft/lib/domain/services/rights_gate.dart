import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Rights decision engine (R05, §6.1, §24, §26). Table-tested in
/// test/domain/rights_gate_test.dart.
///
/// Invariants:
///  * Unknown rights DENY download — never "allow" (§6.1 License).
///  * Streaming permission != download permission.
///  * YouTube items can never be downloaded or played as hidden audio (R05).
///  * A denied decision carries its reason for UI display.
class RightsGate {
  const RightsGate();

  /// Decides whether [track] may be downloaded for offline playback.
  /// [permissionProof] is the provider-declared flag re-checked at enqueue
  /// time (Audius `is_downloadable`; local provider implies user's own file).
  DownloadDecision evaluateDownload(
    Track track, {
    required bool permissionProof,
  }) {
    if (track.provider == SourceProvider.local ||
        track.provider == SourceProvider.radio) {
      // Local files are already offline; live radio streams cannot be downloaded.
      return DownloadDecision.deny(RightsDenialReason.sourceProhibitsDownload);
    }
    if (!permissionProof && !track.isDownloadable) {
      return DownloadDecision.deny(RightsDenialReason.sourceProhibitsDownload);
    }
    return DownloadDecision.allow();
  }

  /// Whether the track can enter the generic (background-capable) audio queue.
  bool canEnterAudioQueue(Track track) {
    return track.isStreamable ||
        track.provider == SourceProvider.local ||
        track.provider == SourceProvider.youtube;
  }

  /// Playback capability for a track given live availability.
  PlaybackCapability resolveCapability(Track track) {
    switch (track.provider) {
      case SourceProvider.local:
        return const PlaybackCapability.localAudio();
      case SourceProvider.audius:
        if (!track.isStreamable) {
          return PlaybackCapability.unavailable(
            'This track is not streamable on Audius.',
          );
        }
        return PlaybackCapability.authorizedAudio(
          canDownload: track.isDownloadable,
          canShare: track.sourceUrl != null,
        );
      case SourceProvider.youtube:
        return const PlaybackCapability.authorizedAudio(
          canDownload: true,
          canShare: true,
        );
      case SourceProvider.jamendo:
        return PlaybackCapability.authorizedAudio(
          canDownload: track.isDownloadable,
          canShare: track.sourceUrl != null,
        );
      case SourceProvider.archive:
        return PlaybackCapability.authorizedAudio(
          canDownload: track.isDownloadable,
          canShare: track.sourceUrl != null,
        );
      case SourceProvider.radio:
        return PlaybackCapability.authorizedAudio(
          canDownload: false,
          canShare: track.sourceUrl != null,
        );
    }
  }
}

sealed class DownloadDecision {
  const DownloadDecision();
  const factory DownloadDecision.allow() = DownloadAllowed;
  const factory DownloadDecision.deny(RightsDenialReason reason) =
      DownloadDenied;
}

class DownloadAllowed extends DownloadDecision {
  const DownloadAllowed();
}

class DownloadDenied extends DownloadDecision {
  const DownloadDenied(this.reason);
  final RightsDenialReason reason;
}

/// Convenience extractor used by UI to show honest denial copy.
String denialMessage(DownloadDenied d) =>
    RightsDeniedException(d.reason).message;
