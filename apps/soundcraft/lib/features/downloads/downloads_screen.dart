import 'dart:io';

import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/repositories/downloads_repository.dart';
import 'package:soundcraft/downloads/download_manager.dart';

/// Downloads (§3.11): Active / Completed / Failed. Real job reconciliation,
/// pause/resume where supported, delete with file-vs-entry scope clarity.
class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dir = await ref.read(downloadsDirProvider.future);
      await ref.read(downloadManagerProvider).setDownloadDirectory(dir);
      await ref.read(downloadManagerProvider).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(downloadsStreamProvider);
    final jobs = jobsAsync.asData?.value ?? const <DownloadJobView>[];
    final active = jobs
        .where(
          (j) =>
              j.state == DownloadJobState.running ||
              j.state == DownloadJobState.queued ||
              j.state == DownloadJobState.paused,
        )
        .toList();
    final completed = jobs
        .where((j) => j.state == DownloadJobState.completed)
        .toList();
    final failed = jobs
        .where(
          (j) =>
              j.state == DownloadJobState.failed ||
              j.state == DownloadJobState.cancelled,
        )
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloads'),
          actions: [
            IconButton(
              tooltip: 'Reconcile files and jobs (REF-004)',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () async {
                await ref.read(downloadManagerProvider).refresh();
                if (context.mounted) showAppSnackBar(context, 'Downloads reconciled.');
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active (${active.length})'),
              Tab(text: 'Completed (${completed.length})'),
              Tab(text: 'Failed (${failed.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JobList(
              jobs: active,
              empty: const EmptyStateView(
                icon: Icons.download_outlined,
                title: 'No active downloads',
                message: 'Downloads appear only for tracks whose source explicitly permits offline saving (Audius downloadable tracks). YouTube items never download.',
              ),
            ),
            _JobList(
              jobs: completed,
              empty: const EmptyStateView(
                icon: Icons.task_alt_rounded,
                title: 'No completed downloads',
                message: 'Finished files are listed here and playable offline.',
              ),
            ),
            _JobList(
              jobs: failed,
              empty: const EmptyStateView(
                icon: Icons.check_circle_outline_rounded,
                title: 'Nothing failed',
                message:
                    'Failed or cancelled jobs show their error codes here.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobList extends ConsumerWidget {
  const _JobList({required this.jobs, required this.empty});
  final List<DownloadJobView> jobs;
  final Widget empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobs.isEmpty) return empty;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _JobTile(job: job);
      },
    );
  }
}

class _JobTile extends ConsumerWidget {
  const _JobTile({required this.job});
  final DownloadJobView job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.scColors;
    final manager = ref.read(downloadManagerProvider);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.audio_file_outlined),
          title: Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(switch (job.state) {
                DownloadJobState.queued => 'Queued…',
                DownloadJobState.running =>
                  '${formatBytes(job.bytesWritten)} of ${job.bytesTotal == null ? 'unknown size' : formatBytes(job.bytesTotal)}',
                DownloadJobState.paused =>
                  'Paused at ${formatBytes(job.bytesWritten)}',
                DownloadJobState.completed =>
                  'Available offline · ${formatBytes(job.bytesTotal)}',
                DownloadJobState.failed =>
                  'Failed: ${job.errorCode ?? 'unknown error'}',
                DownloadJobState.cancelled => 'Cancelled',
              }),
              if (job.state == DownloadJobState.running)
                LinearProgressIndicator(
                  value: job.progress,
                  minHeight: 3,
                  color: c.brandPrimary,
                ),
            ],
          ),
          trailing: _trailing(context, ref, manager),
        ),
        Divider(color: c.outline, height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget? _trailing(
    BuildContext context,
    WidgetRef ref,
    DownloadManager manager,
  ) {
    switch (job.state) {
      case DownloadJobState.running:
        return IconButton(
          tooltip: 'Pause download',
          icon: const Icon(Icons.pause_circle_outline_rounded),
          onPressed: () => manager.pause(job.id),
        );
      case DownloadJobState.paused:
        return IconButton(
          tooltip: 'Resume download (byte-range supported)',
          icon: const Icon(Icons.play_circle_outline_rounded),
          onPressed: () => manager.resume(job.id),
        );
      case DownloadJobState.queued:
        return IconButton(
          tooltip: 'Cancel download',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => manager.cancel(job.id),
        );
      case DownloadJobState.failed:
      case DownloadJobState.cancelled:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Retry download',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => manager.retry(job.id),
            ),
            IconButton(
              tooltip: 'Clear record',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () =>
                  manager.deleteDownloaded(job.id, deleteFile: false),
            ),
          ],
        );
      case DownloadJobState.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Verify file exists',
              icon: const Icon(Icons.sd_card_outlined),
              onPressed: () async {
                final exists = await File(job.targetPath).exists();
                if (context.mounted) {
                  showAppSnackBar(
                    context,
                    exists ? 'File present at ${job.targetPath}' : 'File is missing — job will be marked failed on next reconcile.',
                  );
                }
              },
            ),
            IconButton(
              tooltip: 'Delete downloaded file (keeps library entry)',
              icon: const Icon(Icons.delete_forever_outlined),
              onPressed: () async {
                final ok = await confirmDestructive(
                  context,
                  title: 'Delete downloaded file?',
                  message: 'Removes the offline copy from app storage. Your library entry and playlists stay untouched.',
                  confirmLabel: 'Delete file',
                );
                if (ok) await manager.deleteDownloaded(job.id);
              },
            ),
          ],
        );
    }
  }
}
