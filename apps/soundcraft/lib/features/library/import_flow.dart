import 'package:soundcraft/design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/data/import/library_scanner.dart';
import 'package:soundcraft/data/repositories/local_library_repository.dart';
import 'package:soundcraft/data/app_database.dart';

/// Import flow (LIB-001/002, §3.1): platform-aware pickers, contextual
/// permission handling, live scan progress with cancellation, honest summary.
///
/// Desktop/native: file & folder pickers returning paths.
/// Web: file picker returns bytes; they are stored in the session and played
/// from memory (browser sandbox — surfaced in UI copy, not silently faked).
Future<void> showImportSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ImportSheet(ref: ref),
  );
}

class _ImportSheet extends StatefulWidget {
  const _ImportSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<_ImportSheet> {
  double? _progress;
  int _total = 0;
  bool _running = false;
  bool _cancelled = false;
  late LibraryScanner _scanner;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanner = LibraryScanner();
  }

  @override
  void dispose() {
    _scanner.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.scColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Import music', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Pick single files or a whole folder. SoundCraft indexes the files in place — '
              'your music is never copied or uploaded.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.audio_file_outlined),
                    label: const Text('Pick files'),
                    onPressed: _running ? null : _importFiles,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Pick folder'),
                    onPressed: _running ? null : _importFolder,
                  ),
                ),
              ],
            ),
            if (_running) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _total == 0 ? null : _progress,
                      color: c.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_total files',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  IconButton(
                    tooltip: 'Cancel scan',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      setState(() => _cancelled = true);
                      _scanner.cancel();
                    },
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: c.errorAccent)),
            ],
            const SizedBox(height: 8),
            Text(
              'Supported here: MP3, M4A/AAC, FLAC, OGG, OPUS, WAV. Web imports stay in '
              'this browser session; desktop and mobile import to the app library.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFiles() async {
    setState(() {
      _error = null;
      _running = true;
      _progress = null;
      _total = 0;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'mp3',
          'm4a',
          'aac',
          'flac',
          'ogg',
          'opus',
          'wav',
          'aiff',
        ],
        allowMultiple: true,
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        // User cancelled the picker — not an error.
        return;
      }
      final library = widget.ref.read(localLibraryRepoProvider);
      final scanner = LibraryScanner();
      final paths = result.files
          .map((f) => f.path)
          .whereType<String>()
          .where((p) => p.isNotEmpty)
          .toList();
      final scans = <ScannedTrack>[];
      setState(() => _total = paths.length);

      await for (final event in scanner.scanFiles(paths)) {
        if (_cancelled) break;
        if (event is ScanProgress) {
          if (mounted) {
            setState(() => _progress = event.totalKnown == 0
                ? 0
                : event.filesSeen / event.totalKnown);
          }
        } else if (event is ScanDone) {
          scans.addAll(event.tracks);
          for (final t in event.tracks) {
            await library.upsertScanned([t]);
          }
          if (event.summary.unreadable > 0 && mounted) {
            setState(() => _error =
                '${event.summary.unreadable} file(s) could not be parsed.');
          }
        } else if (event is ScanFailed) {
          if (mounted) {
            setState(() => _error = 'Scan failed: ${event.error}');
          }
        }
      }
      if (mounted) {
        showAppSnackBar(
          context,
          '${scans.length} file(s) imported to your library.',
        );
      }
    } on MediaFileException catch (e) {
      setState(() => _error = e.message);
    } on Object catch (e) {
      setState(() => _error = 'Import failed: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _importFolder() async {
    setState(() {
      _error = null;
      _running = true;
      _progress = null;
      _total = 0;
    });
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose a music folder',
      );
      if (result == null) return; // cancelled
      final library = widget.ref.read(localLibraryRepoProvider);
      final db = widget.ref.read(appDatabaseProvider);
      final overall = ScanSummary();
      await for (final event in _scanner.scanDirectory(result)) {
        switch (event) {
          case ScanProgress(:final filesSeen, :final totalKnown):
            if (mounted) {
              setState(() {
                _total = totalKnown;
                _progress = totalKnown == 0 ? 0 : filesSeen / totalKnown;
              });
            }
          case ScanDone(:final tracks):
            final r = await library.upsertScanned(tracks, folderUri: result);
            overall.added += r.added;
            overall.updated += r.updated;
            overall.skipped += r.skipped;
            overall.unreadable += r.unreadable;
          case ScanFailed(:final error):
            if (mounted) setState(() => _error = 'Scan failed: $error');
        }
      }
      await db
          .into(db.importedFolders)
          .insertOnConflictUpdate(
            ImportedFoldersCompanion.insert(accessUri: result),
          );
      if (mounted) {
        showAppSnackBar(
          context,
          'Scan finished: ${overall.added} added, ${overall.updated} updated, '
          '${overall.skipped} duplicates, ${overall.unreadable} unreadable.',
        );
      }
    } on MediaFileException catch (e) {
      setState(() => _error = e.message);
    } on Object catch (e) {
      setState(() => _error = 'Import failed: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }
}
