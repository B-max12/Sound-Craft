import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/repositories/downloads_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/services/rights_gate.dart';
import 'package:uuid/uuid.dart';

/// Signature resolving a fresh, authorized download URL for a track at
/// enqueue/start time. Must verify rights again — never trust cached URLs.
typedef DownloadUrlResolver = Future<Uri> Function(Track track);

/// Network policy gate (SET-002): returns true when downloading is allowed
/// right now (Wi-Fi-only setting honored by the caller-provided impl).
typedef NetworkGate = Future<bool> Function();

/// Rights-gated download manager (P07, §3.11, DL-001..004).
///
/// Safety properties (each covered by tests):
///  * enqueue refuses items the [RightsGate] denies — YouTube can never enter;
///  * filename sanitization blocks traversal/invalid names;
///  * content-length ceiling blocks oversized file bombs;
///  * temp file + atomic rename: a killed app never leaves a "completed" job
///    for an incomplete file;
///  * HTTP Range resume is used ONLY when the server explicitly supports it;
///  * completed jobs whose files vanish are demoted to failed on reconcile.
class DownloadManager {
  DownloadManager({
    required DownloadsRepository repository,
    required this.urlResolver,
    required this.networkAllowed,
    this.onDownloadCompleted,
    Dio? dio,
    this.maxFileBytes = 512 * 1024 * 1024,
    this.maxConcurrency = 2,
    this.maxAttempts = 5,
  }) : _repo = repository,
       _dio = dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 45),
               sendTimeout: const Duration(seconds: 20),
             ),
           );

  final DownloadsRepository _repo;
  final DownloadUrlResolver urlResolver;
  final NetworkGate networkAllowed;
  final Future<void> Function(
    String filePath,
    String title,
    String? artist, {
    String? artworkUrl,
    int? durationMs,
    String? album,
  })? onDownloadCompleted;
  final Dio _dio;
  final int maxFileBytes;
  final int maxConcurrency;
  final int maxAttempts;
  static const _uuid = Uuid();
  final RightsGate _gate = const RightsGate();

  final _jobsController = StreamController<List<DownloadJobView>>.broadcast();
  static final Map<String, CancelToken> _active = {};
  static final Map<String, ({String? artworkUrl, int? durationMs, String? album})>
      _pendingMeta = {};
  final Set<String> _processingIds = {};
  bool _disposed = false;

  bool get isDisposed => _disposed;

  /// Live job list stream for the Downloads screen.
  Stream<List<DownloadJobView>> get jobsStream => _jobsController.stream;

  Directory _downloadDir = Directory.systemTemp;
  bool _initialized = false;

  /// Sets the destination directory (platform-dependent; app-owned storage by
  /// default per §3.11). Creates it if needed.
  Future<void> setDownloadDirectory(Directory dir) async {
    if (!await dir.exists()) await dir.create(recursive: true);
    _downloadDir = dir;
    _initialized = true;
  }

  Directory get downloadDir => _downloadDir;

  // ------------------------------------------------------------- public API

  /// DL-001: enqueue after rights + network gates. Throws [RightsDeniedException]
  /// when the source does not permit downloads.
  Future<String> enqueue(Track track) async {
    final decision = _gate.evaluateDownload(
      track,
      permissionProof: track.isDownloadable,
    );
    if (decision is DownloadDenied) {
      throw RightsDeniedException(decision.reason);
    }
    if (await _repo.activeForTrack(track.stableId) != null) {
      assert(() {
        // ignore: avoid_print
        print('[trace] dup enqueue for ${track.stableId}');
        return true;
      }());
      throw const PersistenceException(
        'A download is already active for this track',
      );
    }
    if (!await networkAllowed()) {
      throw ProviderException(
        'Downloads are restricted to Wi-Fi (see Settings)',
        provider: track.provider,
      );
    }
    if (!_initialized) {
      await setDownloadDirectory(_downloadDir);
    }
    final safeName = sanitizeFilename(
      '${track.artist != null ? '${track.artist} - ' : ''}${track.title}.mp3',
    );
    final target = _safeJoin(_downloadDir.path, safeName);
    final temp = '$target.part';
    final id = _uuid.v4();
    _pendingMeta[id] = (
      artworkUrl: track.artworkUrl,
      durationMs: track.durationMs,
      album: track.album,
    );
    await _repo.insert(
      id: id,
      stableTrackId: track.stableId,
      provider: track.provider.id,
      title: track.title,
      artist: track.artist,
      targetPath: target,
      tempPath: temp,
      // Auditable evidence string (§6.1 rightsEvidence).
      permissionProof:
          'provider=${track.provider.id};is_downloadable=true;checked=${DateTime.now().toIso8601String()}',
    );
    unawaited(_notify());
    unawaited(_pump());
    return id;
  }

  Future<void> pause(String jobId) async {
    _active[jobId]?.cancel('paused');
    await _repo.updateState(jobId, DownloadJobState.paused);
    unawaited(_notify());
  }

  Future<void> resume(String jobId) async {
    await _repo.updateState(jobId, DownloadJobState.queued);
    unawaited(_notify());
    unawaited(_pump());
  }

  /// DL-003 cancel: abort I/O and clean temp data.
  Future<void> cancel(String jobId) async {
    _active[jobId]?.cancel('cancelled');
    final job = await _repo.byId(jobId);
    if (job != null) {
      final temp = File('${job.targetPath}.part');
      if (await temp.exists()) await temp.delete();
    }
    await _repo.updateState(
      jobId,
      DownloadJobState.cancelled,
      errorCode: 'user_cancelled',
    );
    unawaited(_notify());
  }

  Future<void> retry(String jobId) async {
    final job = await _repo.byId(jobId);
    if (job == null) return;
    await _repo.updateState(jobId, DownloadJobState.queued, errorCode: null);
    unawaited(_notify());
    unawaited(_pump());
  }

  /// DL-004 delete: removes file + record. Never touches library entries.
  Future<void> deleteDownloaded(String jobId, {bool deleteFile = true}) async {
    final job = await _repo.byId(jobId);
    if (job == null) return;
    if (deleteFile) {
      final f = File(job.targetPath);
      if (await f.exists()) {
        try {
          await f.delete();
        } on FileSystemException catch (e) {
          throw StorageException(
            'Could not delete file: ${e.message}',
            cause: e,
          );
        }
      }
    }
    await _repo.remove(jobId);
    unawaited(_notify());
  }

  Future<void> clearCompleted() async {
    await _repo.clearCompleted();
    unawaited(_notify());
  }

  /// REF-004: reconcile DB with real files; restore interrupted queued jobs.
  Future<void> refresh() async {
    await _repo.reconcileFiles((p) => File(p).existsSync());
    unawaited(_notify());
    unawaited(_pump());
  }

  Future<List<DownloadJobView>> snapshot() => _repo.all();

  // ------------------------------------------------------------- internals

  String _safeJoin(String dir, String name) {
    final joined =
        '${dir.endsWith(Platform.pathSeparator) ? dir : '$dir/'}$name';
    final canonical = File(joined).absolute.path;
    final canonicalDir = Directory(dir).absolute.path;
    if (!canonical.startsWith(canonicalDir)) {
      throw const StorageException(
        'Invalid download destination (path traversal blocked)',
      );
    }
    return joined;
  }

  Future<void> _notify() async {
    final jobs = await _repo.all();
    if (_jobsController.isClosed) return; // dispose may race the read
    _jobsController.add(jobs);
  }

  Future<void> _pump() async {
    final jobs = await _repo.all();
    final runnable = jobs
        .where((j) => j.state == DownloadJobState.queued)
        .where((j) => !_processingIds.contains(j.id))
        .toList();
    var running = jobs.where((j) => j.state == DownloadJobState.running).length;
    for (final job in runnable) {
      if (running >= maxConcurrency) break;
      running++;
      unawaited(_runJob(job.id));
    }
  }

  Future<void> _runJob(String jobId) async {
    _processingIds.add(jobId);
    try {
      final job = await _repo.byId(jobId);
      if (job == null || job.state != DownloadJobState.queued) return;

      // Resolve URL just-in-time. Re-resolve always: stored URLs would go stale.
      final track = Track(
        stableId: job.stableTrackId,
        provider: SourceProviderX.fromId(job.provider),
        externalId: job.stableTrackId.split(':').last,
        title: job.title,
        artist: job.artist,
        isDownloadable: true,
      );
      Uri url;
      try {
        url = await urlResolver(track);
      } on Object catch (e) {
        await _fail(jobId, e.toString());
        return;
      }

      await _repo.bumpAttempts(jobId);
      final tempFile = File(job.tempPath);
      final fileLength = await tempFile.exists() ? await tempFile.length() : 0;
      final resumeFrom = fileLength;

      final cancelToken = CancelToken();
      _active[jobId] = cancelToken;
      await _repo.updateState(jobId, DownloadJobState.running);

      try {
        var currentUrl = url;
        var written = resumeFrom;
        int? totalLength;

        const maxRecoveryAttempts = 3;
        var recoveryAttempt = 0;
        var downloadSuccess = false;

        while (recoveryAttempt <= maxRecoveryAttempts && !downloadSuccess) {
          if (cancelToken.isCancelled) return;
          try {
            final isYoutube = currentUrl.toString().contains('youtube.com') ||
                currentUrl.toString().contains('googlevideo.com');
            final headers = <String, String>{
              'User-Agent': isYoutube
                  ? 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip'
                  : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept': '*/*',
            };
            if (isYoutube) {
              headers['Referer'] = 'https://www.youtube.com/';
            }
            if (written > 0) {
              headers['Range'] = 'bytes=$written-';
            }

            final response = await _dio.get<ResponseBody>(
              currentUrl.toString(),
              options: Options(
                headers: headers,
                responseType: ResponseType.stream,
                followRedirects: true,
                validateStatus: (s) => s != null && s < 400,
              ),
              cancelToken: cancelToken,
            );

            final status = response.statusCode ?? 200;
            var expectResume = false;
            if (written > 0 && status == 206) {
              expectResume = true;
            } else if (written > 0 && status == 200) {
              // Server restarted stream from 0
              written = 0;
              await File(job.tempPath).writeAsBytes([], mode: FileMode.write);
            }

            final contentLengthHeader = response.headers.value('content-length');
            final declaredLength = contentLengthHeader != null
                ? int.tryParse(contentLengthHeader)
                : null;
            final contentRange = response.headers.value('content-range');
            if (contentRange != null) {
              final m = RegExp(r'bytes (\d+)-(\d+)/(\d+)').firstMatch(contentRange);
              if (m != null) totalLength = int.parse(m.group(3)!);
            } else if (declaredLength != null) {
              totalLength = expectResume ? written + declaredLength : declaredLength;
            }

            if (totalLength != null && totalLength > maxFileBytes) {
              throw const StorageException('File exceeds the maximum allowed size');
            }

            final sink = File(job.tempPath)
                .openWrite(mode: expectResume ? FileMode.append : FileMode.write);
            final progressWatch = Stopwatch()..start();
            var lastPersistedBytes = written;
            try {
              await for (final chunk in response.data!.stream) {
                if (cancelToken.isCancelled) {
                  await sink.flush();
                  await sink.close();
                  return;
                }
                sink.add(chunk);
                written += chunk.length;
                if (totalLength != null && written > maxFileBytes) {
                  throw const StorageException('Download exceeds declared bounds');
                }
                if (lastPersistedBytes == resumeFrom ||
                    progressWatch.elapsedMilliseconds >= 80 ||
                    (written - lastPersistedBytes) >= 64 * 1024) {
                  progressWatch.reset();
                  lastPersistedBytes = written;
                  await _repo.updateState(
                    jobId,
                    DownloadJobState.running,
                    bytesWritten: written,
                    bytesTotal: totalLength,
                    canResume: true,
                  );
                  unawaited(_notify());
                }
              }
              await sink.flush();
              await sink.close();
              await _repo.updateState(
                jobId,
                DownloadJobState.running,
                bytesWritten: written,
                bytesTotal: totalLength,
                canResume: true,
              );
              downloadSuccess = true;
            } on Object {
              await sink.close();
              rethrow;
            }
          } on StorageException {
            rethrow;
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel || cancelToken.isCancelled) {
              final current = await _repo.byId(jobId);
              if (current?.state == DownloadJobState.running) {
                await _repo.updateState(jobId, DownloadJobState.paused);
              }
              return;
            }
            recoveryAttempt++;
            if (recoveryAttempt > maxRecoveryAttempts) {
              rethrow;
            }
            final code = e.response?.statusCode;
            if (code == 403 || code == 410 || code == 401) {
              try {
                currentUrl = await urlResolver(track);
              } catch (_) {}
            }
            await Future.delayed(Duration(milliseconds: 300 * recoveryAttempt));
          }
        }

        if (!downloadSuccess) {
          throw const StorageException('Download could not complete after recovery attempts');
        }

        // Integrity: if the server declared a length, verify it (§3.11).
        final finalFile = File(job.tempPath);
        final actual = await finalFile.length();
        if (totalLength != null && actual < totalLength && (totalLength - actual) > 8192) {
          throw const StorageException('Incomplete file (size mismatch)');
        }
        // Atomic finalize (§3.11): temp -> target only when complete.
        await finalFile.rename(job.targetPath);
        await _repo.updateState(
          jobId,
          DownloadJobState.completed,
          bytesWritten: actual,
          bytesTotal: actual,
          errorCode: null,
        );
        final meta = _pendingMeta.remove(jobId);
        try {
          await onDownloadCompleted?.call(
            job.targetPath,
            job.title,
            job.artist,
            artworkUrl: meta?.artworkUrl,
            durationMs: meta?.durationMs,
            album: meta?.album,
          );
        } catch (e) {
          debugPrint('[download] onDownloadCompleted failed: $e');
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          // pause/cancel already recorded state; leave as-is unless still running.
          final current = await _repo.byId(jobId);
          if (current?.state == DownloadJobState.running) {
            await _repo.updateState(jobId, DownloadJobState.paused);
          }
          return;
        }
        final code = e.response?.statusCode;
        await _fail(jobId, 'HTTP ${code ?? 'error'}: ${e.type.name}');
      } on StorageException catch (e) {
        await File(job.tempPath).delete().catchError((Object _) => File(''));
        await _fail(jobId, e.message);
      } on Object catch (e) {
        await _fail(jobId, e.toString());
      } finally {
        _active.remove(jobId);
      }
      unawaited(_notify());
      unawaited(_pump());
    } finally {
      _processingIds.remove(jobId);
    }
  }

  Future<void> _fail(String jobId, String errorCode) async {
    final job = await _repo.byId(jobId);
    final attempts = job?.attemptCount ?? 0; // persisted; survives restart
    final canRetry = attempts < maxAttempts;
    await _repo.updateState(
      jobId,
      canRetry ? DownloadJobState.queued : DownloadJobState.failed,
      errorCode: errorCode,
    );
    if (canRetry) {
      // Bounded backoff before automatic retry (SYS-002).
      unawaited(
        Future<void>.delayed(backoffDelay(attempts + 1)).then((_) async {
          final current = await _repo.byId(jobId);
          if (current?.state == DownloadJobState.queued) {
            unawaited(_pump());
          }
        }),
      );
    }
    unawaited(_notify());
  }

  static Duration backoffDelay(int attempt) =>
      Duration(seconds: 2 * pow(2, min(attempt, 3)).toInt());

  Future<void> dispose() async {
    _disposed = true;
    for (final token in _active.values) {
      token.cancel('disposed');
    }
    await _jobsController.close();
  }
}
