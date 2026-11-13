import 'package:flutter/foundation.dart';

import 'package:soundcraft/core/constants.dart';

/// Playback capability per item (§6.1). Drives UI button visibility:
/// a control that must not exist is never shown (R03, DL-001, YT-001).
enum PlaybackMode { streamAudio, officialVideo, localFile, offlineCopy }

@immutable
class PlaybackCapability {
  const PlaybackCapability({
    required this.canPlayInApp,
    required this.mode,
    this.canSeek = true,
    this.canBackground = false,
    this.canDownload = false,
    this.canShareLink = false,
    this.reason,
  });

  final bool canPlayInApp;
  final PlaybackMode mode;
  final bool canSeek;
  final bool canBackground;
  final bool canDownload;
  final bool canShareLink;

  /// Why a capability is missing — surfaced in UI instead of fake controls.
  final String? reason;

  static PlaybackCapability unavailable(String reason) => PlaybackCapability(
    canPlayInApp: false,
    mode: PlaybackMode.streamAudio,
    reason: reason,
  );

  const PlaybackCapability.localAudio()
    : this(
        canPlayInApp: true,
        mode: PlaybackMode.localFile,
        canBackground: true,
        canShareLink: false,
      );

  const PlaybackCapability.authorizedAudio({
    required bool canDownload,
    required bool canShare,
  }) : this(
         canPlayInApp: true,
         mode: PlaybackMode.streamAudio,
         canBackground: true,
         canDownload: canDownload,
         canShareLink: canShare,
       );

  /// YouTube: official visible video only. Never background audio, never download.
  const PlaybackCapability.officialVideo()
    : this(
        canPlayInApp: true,
        mode: PlaybackMode.officialVideo,
        canSeek: true,
        canBackground: false,
        canDownload: false,
        canShareLink: true,
        reason: 'Plays via the official YouTube player with visible controls.',
      );

  @override
  bool operator ==(Object other) =>
      other is PlaybackCapability &&
      other.canPlayInApp == canPlayInApp &&
      other.mode == mode &&
      other.canSeek == canSeek &&
      other.canBackground == canBackground &&
      other.canDownload == canDownload &&
      other.canShareLink == canShareLink;

  @override
  int get hashCode => Object.hash(
    canPlayInApp,
    mode,
    canSeek,
    canBackground,
    canDownload,
    canShareLink,
  );
}

/// Unified playable/discoverable track across sources (§6.1 Track).
@immutable
class Track {
  const Track({
    required this.stableId,
    required this.provider,
    required this.externalId,
    required this.title,
    this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.artworkUrl,
    this.localUri,
    this.durationMs,
    this.isExplicit = false,
    this.genre,
    this.releaseDate,
    this.sourceUrl,
    this.isDownloadable = false,
    this.isStreamable = true,
    this.playCount,
    this.attributedTo,
  });

  final String stableId; // namespaced: local:x / audius:y / youtube:z
  final SourceProvider provider;
  final String externalId;
  final String title;
  final String? artist;
  final String? artistId;
  final String? album;
  final String? albumId;
  final String? artworkUrl;
  final String? localUri; // local provider only
  final int? durationMs;
  final bool isExplicit;
  final String? genre;
  final DateTime? releaseDate;
  final String? sourceUrl; // canonical link (YouTube watch URL etc.)
  final bool
  isDownloadable; // provider-declared; gate re-checks at download time
  final bool isStreamable;
  final int? playCount;
  final String? attributedTo; // provider attribution line

  Track copyWith({
    String? artist,
    String? artworkUrl,
    int? durationMs,
    String? album,
    bool? isStreamable,
    bool? isDownloadable,
    String? sourceUrl,
    String? localUri,
  }) {
    return Track(
      stableId: stableId,
      provider: provider,
      externalId: externalId,
      title: title,
      artist: artist ?? this.artist,
      artistId: artistId,
      album: album ?? this.album,
      albumId: albumId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localUri: localUri ?? this.localUri,
      durationMs: durationMs ?? this.durationMs,
      isExplicit: isExplicit,
      genre: genre,
      releaseDate: releaseDate,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isStreamable: isStreamable ?? this.isStreamable,
      playCount: playCount,
      attributedTo: attributedTo,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Track && other.stableId == stableId;

  @override
  int get hashCode => stableId.hashCode;

  @override
  String toString() => 'Track($stableId, $title)';
}
