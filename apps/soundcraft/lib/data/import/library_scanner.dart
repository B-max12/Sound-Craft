import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../repositories/local_library_repository.dart';

/// Extensions we import. WAV included for playback; its metadata (if any)
/// is best-effort — duration may be unknown and that is handled downstream.
const Set<String> kSupportedAudioExtensions = {
  '.mp3',
  '.m4a',
  '.aac',
  '.flac',
  '.ogg',
  '.opus',
  '.webm',
  '.aiff',
  '.aif',
  '.wav',
};

/// Progress event emitted during a scan.
sealed class ScanEvent {
  const ScanEvent();
}

class ScanProgress extends ScanEvent {
  const ScanProgress(this.filesSeen, this.totalKnown);
  final int filesSeen;
  final int totalKnown;
}

class ScanDone extends ScanEvent {
  const ScanDone(this.summary, this.tracks);
  final ScanSummary summary;
  final List<ScannedTrack> tracks;
}

class ScanFailed extends ScanEvent {
  const ScanFailed(this.error);
  final Object error;
}

/// Incremental library scanner (P02, LIB-002, §8).
///
///  * enumerates candidate files on the calling isolate (fast),
///  * parses metadata in batches inside [Isolate.run] so the UI never blocks,
///  * emits [ScanProgress] between batches and supports cancellation,
///  * computes a stable content fingerprint for dedupe (path-spelling-proof),
///  * caps embedded artwork storage for memory safety.
class LibraryScanner {
  LibraryScanner({this.batchSize = 40, this.maxArtworkBytes = 256 * 1024});

  final int batchSize;
  final int maxArtworkBytes;
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  /// Scans an explicit list of file paths directly without treating them as directories.
  Stream<ScanEvent> scanFiles(List<String> paths) async* {
    _cancelled = false;
    final summary = ScanSummary();
    final validFiles = <String>[];
    for (final path in paths) {
      if (isSupportedAudioPath(path) && File(path).existsSync()) {
        validFiles.add(path);
      }
    }
    final total = validFiles.length;
    var seen = 0;
    final results = <ScannedTrack>[];

    for (var i = 0; i < validFiles.length; i += batchSize) {
      if (_cancelled) break;
      final batch = validFiles.sublist(i, (i + batchSize).clamp(0, validFiles.length));
      try {
        final parsed = await Isolate.run(
          () => _parseBatch(batch, maxArtworkBytes),
        );
        for (final t in parsed) {
          if (t == null) {
            summary.unreadable++;
          } else {
            results.add(t);
          }
        }
      } on Object {
        summary.unreadable += batch.length;
      }
      seen += batch.length;
      yield ScanProgress(seen, total);
    }
    summary.cancelled = _cancelled;
    yield ScanDone(summary, results);
  }

  /// Streams scan events for [root]. Recursion boundary is explicit.
  Stream<ScanEvent> scanDirectory(String root, {bool recursive = true}) async* {
    _cancelled = false;
    // If root is actually a file, route to scanFiles directly
    if (await File(root).exists()) {
      yield* scanFiles([root]);
      return;
    }
    final summary = ScanSummary();
    final dir = Directory(root);
    if (!await dir.exists()) {
      yield ScanFailed(MediaFileException('Folder not accessible: $root'));
      return;
    }
    final files = <File>[];
    await for (final entry in dir.list(
      recursive: recursive,
      followLinks: false,
    )) {
      if (_cancelled) break;
      if (entry is File) {
        final ext = entry.path.toLowerCase().substring(
          entry.path.lastIndexOf('.') == -1 ? 0 : entry.path.lastIndexOf('.'),
        );
        if (kSupportedAudioExtensions.contains(ext)) files.add(entry);
      }
    }
    final total = files.length;
    var seen = 0;
    final results = <ScannedTrack>[];

    for (var i = 0; i < files.length; i += batchSize) {
      if (_cancelled) break;
      final batch = files.sublist(i, (i + batchSize).clamp(0, files.length));
      try {
        final parsed = await Isolate.run(
          () => _parseBatch(batch.map((f) => f.path).toList(), maxArtworkBytes),
        );
        for (final t in parsed) {
          if (t == null) {
            summary.unreadable++;
          } else {
            results.add(t);
          }
        }
      } on Object catch (e) {
        // Batch-level failure: count as unreadable rather than failing whole scan.
        summary.unreadable += batch.length;
        if (results.isEmpty &&
            summary.unreadable > files.length / 2 &&
            i == 0) {
          yield ScanFailed(e);
          return;
        }
      }
      seen += batch.length;
      yield ScanProgress(seen, total);
    }
    summary.cancelled = _cancelled;
    yield ScanDone(summary, results);
  }

  /// Scans the app-owned downloads directory file type only (no-op logic here,
  /// downloads are registered by the manager).
  static bool isSupportedAudioPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return false;
    return kSupportedAudioExtensions.contains(
      path.substring(dot).toLowerCase(),
    );
  }
}

/// Runs inside an isolate. Returns null for unreadable/unsupported files.
List<ScannedTrack?> _parseBatch(List<String> paths, int maxArtworkBytes) {
  final out = <ScannedTrack?>[];
  for (final path in paths) {
    out.add(_parseOne(path, maxArtworkBytes));
  }
  return out;
}

ScannedTrack? _parseOne(String path, int maxArtworkBytes) {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    final stat = file.statSync();
    if (stat.size <= 0) return null;

    Uint8List? artwork;
    String? title;
    String? artist;
    String? album;
    String? genre;
    int? durationMs;

    try {
      final meta = readMetadata(file, getImage: true);
      title = (meta.title != null && meta.title!.trim().isNotEmpty)
          ? meta.title!.trim()
          : null;
      artist = meta.artist?.trim();
      album = meta.album?.trim();
      final genres = meta.genres;
      genre = genres.isNotEmpty ? genres.first : null;
      final d = meta.duration;
      if (d != null && d.inMilliseconds > 0) durationMs = d.inMilliseconds;
      for (final pic in meta.pictures) {
        if (pic.bytes.isNotEmpty && pic.bytes.length <= maxArtworkBytes) {
          artwork = pic.bytes;
          break; // store at most one cover for memory safety
        }
      }
    } on Object {
      // Malformed/absent tags: fall back to filename metadata below.
    }

    final stem = path.split(Platform.pathSeparator).last;
    final dot = stem.lastIndexOf('.');
    title ??= dot > 0 ? stem.substring(0, dot) : stem;
    if (artist == null || artist.isEmpty) artist = null;
    if (album == null || album.isEmpty) album = null;

    final fingerprint = _fingerprint(file, stat.size);
    return ScannedTrack(
      uri: path,
      uriKind: 'file',
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      durationMs: durationMs,
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
      fingerprint: fingerprint,
      artwork: artwork,
    );
  } on Object {
    return null;
  }
}

/// Stable fingerprint: hash(size || head64KB || tail64KB). Avoids reading huge
/// files fully while remaining collision-resistant enough for library dedupe.
String _fingerprint(File file, int size) {
  final h = crypto.md5;
  final output = _DigestSink();
  final sink = h.startChunkedConversion(output);
  sink.add(size.toString().codeUnits);
  final raf = file.openSync();
  try {
    final headLen = size < 65536 ? size : 65536;
    final head = raf.readSync(headLen);
    sink.add(head);
    if (size > 65536) {
      final tailStart = size - 65536;
      raf.setPositionSync(tailStart);
      final tail = raf.readSync(65536);
      sink.add(tail);
    }
  } finally {
    raf.closeSync();
  }
  sink.close();
  return output.digest.toString();
}

class _DigestSink implements Sink<crypto.Digest> {
  crypto.Digest digest = crypto.Digest(Uint8List(0));
  @override
  void add(crypto.Digest data) => digest = data;
  @override
  void close() {}
}
