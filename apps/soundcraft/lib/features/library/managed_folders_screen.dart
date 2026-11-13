import 'package:soundcraft/design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/data/app_database.dart';
import 'package:soundcraft/data/import/library_scanner.dart';
import 'package:soundcraft/features/library/library_screen.dart'
    show importedFoldersProvider;

/// Managed folders (LIB-008): watched-folder list with add/remove/rescan.
class ManagedFoldersScreen extends ConsumerStatefulWidget {
  const ManagedFoldersScreen({super.key});

  @override
  ConsumerState<ManagedFoldersScreen> createState() =>
      _ManagedFoldersScreenState();
}

class _ManagedFoldersScreenState extends ConsumerState<ManagedFoldersScreen> {
  bool _scanning = false;
  double? _progress;

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(importedFoldersProvider);
    final folders = foldersAsync.asData?.value ?? const <String>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Imported folders')),
      body: Column(
        children: [
          Expanded(
            child: folders.isEmpty
                ? const EmptyStateView(
                    icon: Icons.folder_off_outlined,
                    title: 'No folders imported',
                    message: 'Import a folder to enable one-tap rescans that pick up new and moved files.',
                  )
                : ListView(
                    children: [
                      for (final folder in folders)
                        ListTile(
                          leading: const Icon(Icons.folder_open_rounded),
                          title: Text(
                            folder,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove from watched folders',
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              await _removeFolder(folder);
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          if (_scanning)
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(value: _progress),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add folder'),
                    onPressed: _scanning ? null : _addFolder,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Rescan all'),
                    onPressed: _scanning || folders.isEmpty ? null : _rescanAll,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a music folder',
    );
    if (path == null) return;
    final db = ref.read(appDatabaseProvider);
    await db
        .into(db.importedFolders)
        .insertOnConflictUpdate(
          ImportedFoldersCompanion.insert(accessUri: path),
        );
    ref.invalidate(importedFoldersProvider);
  }

  Future<void> _removeFolder(String folder) async {
    final db = ref.read(appDatabaseProvider);
    await (db.delete(
      db.importedFolders,
    )..where((f) => f.accessUri.equals(folder))).go();
    ref.invalidate(importedFoldersProvider);
    if (mounted) {
      showAppSnackBar(
        context,
        'Removed from the watched list. Existing library entries are kept.',
      );
    }
  }

  Future<void> _rescanAll() async {
    final folders = ref.read(importedFoldersProvider).asData?.value ?? const [];
    final library = ref.read(localLibraryRepoProvider);
    final scanner = LibraryScanner();
    setState(() => _scanning = true);
    var added = 0;
    var unreadable = 0;
    for (final folder in folders) {
      await for (final event in scanner.scanDirectory(folder)) {
        switch (event) {
          case ScanProgress(:final filesSeen, :final totalKnown):
            if (mounted) {
              setState(
                () => _progress = totalKnown == 0 ? 0 : filesSeen / totalKnown,
              );
            }
          case ScanDone(:final tracks):
            final r = await library.upsertScanned(tracks);
            added += r.added;
            unreadable += r.unreadable;
          case ScanFailed(:final error):
            if (mounted) showAppSnackBar(context, 'Scan failed: $error');
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _progress = null;
    });
    showAppSnackBar(
      context,
      'Rescan finished: $added added, $unreadable unreadable.',
    );
    if (mounted) context.go(Routes.library);
  }
}
