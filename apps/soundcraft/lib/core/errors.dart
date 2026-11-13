/// Typed exceptions for SoundCraft. Silent catches are forbidden (R02/R13);
/// failures surface as one of these and drive UI error states (§3.15).
library;

import 'package:soundcraft/core/constants.dart';

/// Base class for all SoundCraft domain errors.
sealed class SoundCraftException implements Exception {
  const SoundCraftException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// A provider operation failed for a known reason (network, 4xx, 5xx…).
class ProviderException extends SoundCraftException {
  const ProviderException(
    super.message, {
    required this.provider,
    this.statusCode,
    this.retryAfterSeconds,
    super.cause,
  });

  final SourceProvider provider;
  final int? statusCode;
  final int? retryAfterSeconds;

  bool get isRateLimited => statusCode == 429;
  bool get isAuthDenied => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetwork => statusCode == null;
}

/// Playback could not be resolved or failed mid-stream.
class PlaybackException extends SoundCraftException {
  const PlaybackException(
    super.message, {
    this.recoverable = false,
    super.cause,
  });
  final bool recoverable;
}

/// A file/media operation failed (missing file, unsupported codec, corrupt data).
class MediaFileException extends SoundCraftException {
  const MediaFileException(super.message, {super.cause});
}

/// Rights gate refused an operation (download, offline, background…).
class RightsDeniedException extends SoundCraftException {
  RightsDeniedException(this.reason)
    : super('Operation denied by rights policy: ${reason.reason}');
  final RightsDenialReason reason;
}

enum RightsDenialReason {
  unknownRights('rights for this item are unknown'),
  sourceProhibitsDownload('the source does not permit downloads'),
  youtubePolicy('YouTube content cannot be downloaded or played as audio'),
  expired('the download authorization has expired'),
  territory('not available in your region');

  const RightsDenialReason(this.reason);
  final String reason;
}

/// Storage ran out or the OS refused the write.
class StorageException extends SoundCraftException {
  const StorageException(super.message, {super.cause});
}

/// Database persistence failure.
class PersistenceException extends SoundCraftException {
  const PersistenceException(super.message, {super.cause});
}

/// A user-facing feature is not configured (e.g. gateway URL missing).
class NotConfiguredException extends SoundCraftException {
  const NotConfiguredException(super.message);
}
