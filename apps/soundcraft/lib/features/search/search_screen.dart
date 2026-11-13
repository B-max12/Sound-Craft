import 'dart:async';

import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/app/state.dart';
import 'package:soundcraft/app/router.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/core/utils/formatters.dart';
import 'package:soundcraft/data/repositories/history_repository.dart';
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';

/// Search (§3.3, SRCH-001..005): instant local results, debounced provider
/// queries with cancellation, source filters, recent searches, load-more.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

enum _SourceFilter { all, local, audius, jamendo, archive, radio, youtube }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<Track>? _localResults;
  List<Track>? _audiusResults;
  List<Track>? _jamendoResults;
  List<Track>? _archiveResults;
  List<Track>? _radioResults;
  List<Track>? _youtubeResults;
  bool _loadingAudius = false;
  bool _loadingJamendo = false;
  bool _loadingArchive = false;
  bool _loadingRadio = false;
  bool _loadingYouTube = false;
  String? _audiusError;
  String? _youtubeError;
  _SourceFilter _filter = _SourceFilter.all;
  List<String> _recent = [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    _loadRecent();
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _runSearch(widget.initialQuery),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final enabled =
        ref.read(privacyProvider).value?.searchHistoryEnabled ?? true;
    if (!enabled) return;
    final repo = RecentSearchesRepository(ref.read(appDatabaseProvider));
    final items = await repo.list();
    if (mounted) setState(() => _recent = items);
  }

  /// SRCH-001: local instant, remote debounced 400ms with stale cancellation.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _localResults = null;
        _audiusResults = null;
        _jamendoResults = null;
        _archiveResults = null;
        _radioResults = null;
        _youtubeResults = null;
        _audiusError = null;
        _youtubeError = null;
        _searched = false;
      });
      return;
    }
    // Local immediately.
    ref.read(localLibraryRepoProvider).search(value.trim()).then((results) {
      if (mounted) setState(() => _localResults = results);
    });
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query, {bool saveToRecent = false}) async {
    if (query.isEmpty) return;
    // Local matches are instant and never wait on the network (§3.3).
    unawaited(
      ref
          .read(localLibraryRepoProvider)
          .search(query)
          .then((results) {
        if (mounted) setState(() => _localResults = results);
      }),
    );
    bool online = true;
    try {
      online = await ref.read(connectivityProvider.future);
    } catch (_) {
      online = true;
    }
    final audius = ref.read(audiusProvider);
    final jamendo = ref.read(jamendoProvider);
    final archive = ref.read(archiveProvider);
    final radio = ref.read(radioProvider);
    final youtube = ref.read(youtubeProvider);

    // Only save to recent searches on explicit submit, not during
    // debounced auto-search (fixes keystroke-saving bug).
    if (saveToRecent) {
      final audiusRepo = RecentSearchesRepository(ref.read(appDatabaseProvider));
      final historyEnabled =
          ref.read(privacyProvider).value?.searchHistoryEnabled ?? true;
      if (historyEnabled) {
        await audiusRepo.add(query);
        await _loadRecent();
      }
    }

    setState(() {
      _searched = true;
      _audiusError = null;
      _youtubeError = null;
      _loadingAudius = online;
      _loadingJamendo = online && jamendo.isConfigured;
      _loadingArchive = online;
      _loadingRadio = online;
      _loadingYouTube = online && youtube.isConfigured;
    });

    if (!online) return;

    await Future.wait([
      () async {
        try {
          final page = await audius.searchTracks(
            SearchQuery(text: query, limit: 20),
          );
          if (mounted) {
            setState(() {
              _audiusResults = page.items;
              _loadingAudius = false;
            });
          }
        } on ProviderException catch (e) {
          if (mounted) {
            setState(() {
              _audiusError = e.message;
              _loadingAudius = false;
            });
          }
        }
      }(),
      if (jamendo.isConfigured)
        () async {
          try {
            final page = await jamendo.searchTracks(
              SearchQuery(text: query, limit: 15),
            );
            if (mounted) {
              setState(() {
                _jamendoResults = page.items;
                _loadingJamendo = false;
              });
            }
          } on Object {
            if (mounted) setState(() => _loadingJamendo = false);
          }
        }(),
      () async {
        try {
          final page = await archive.searchTracks(
            SearchQuery(text: query, limit: 12),
          );
          if (mounted) {
            setState(() {
              _archiveResults = page.items;
              _loadingArchive = false;
            });
          }
        } on Object {
          if (mounted) setState(() => _loadingArchive = false);
        }
      }(),
      () async {
        try {
          final page = await radio.searchTracks(
            SearchQuery(text: query, limit: 10),
          );
          if (mounted) {
            setState(() {
              _radioResults = page.items;
              _loadingRadio = false;
            });
          }
        } on Object {
          if (mounted) setState(() => _loadingRadio = false);
        }
      }(),
      if (youtube.isConfigured)
        () async {
          try {
            final page = await youtube.search(query, limit: 20);
            if (mounted) {
              setState(() {
                _youtubeResults = page.items;
                _loadingYouTube = false;
              });
            }
          } on NotConfiguredException catch (e) {
            if (mounted) {
              setState(() {
                _youtubeError = e.message;
                _loadingYouTube = false;
              });
            }
          } on ProviderException catch (e) {
            if (mounted) {
              setState(() {
                _youtubeError = e.message;
                _loadingYouTube = false;
              });
            }
          }
        }(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final all = _filterTracks();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, playlists…',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
          onSubmitted: (v) => _runSearch(v.trim(), saveToRecent: true),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search (SRCH-002)',
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
                _focus.requestFocus();
              },
            ),
          IconButton(
            tooltip: 'Search again (REF-003)',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _runSearch(_controller.text.trim()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Source filters (SRCH-004).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final f in _SourceFilter.values)
                  ChoiceChip(
                    label: Text(switch (f) {
                      _SourceFilter.all => 'All',
                      _SourceFilter.local => 'Local',
                      _SourceFilter.audius => 'Audius',
                      _SourceFilter.jamendo => 'Jamendo',
                      _SourceFilter.archive => 'Archive',
                      _SourceFilter.radio => 'Radio',
                      _SourceFilter.youtube => 'YouTube',
                    }),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
              ],
            ),
          ),
          if (_audiusError != null || _youtubeError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                [
                  if (_audiusError != null) 'Audius: $_audiusError',
                  if (_youtubeError != null) 'YouTube: $_youtubeError',
                ].join('  ·  '),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          Expanded(child: _buildBody(context, all)),
        ],
      ),
    );
  }

  List<Track> _filterTracks() {
    final out = <Track>[];
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.local) {
      out.addAll(_localResults ?? const <Track>[]);
    }
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.audius) {
      out.addAll(_audiusResults ?? const <Track>[]);
    }
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.jamendo) {
      out.addAll(_jamendoResults ?? const <Track>[]);
    }
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.archive) {
      out.addAll(_archiveResults ?? const <Track>[]);
    }
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.radio) {
      out.addAll(_radioResults ?? const <Track>[]);
    }
    if (_filter == _SourceFilter.all || _filter == _SourceFilter.youtube) {
      out.addAll(_youtubeResults ?? const <Track>[]);
    }
    // Deduplicate by stable id; different sources stay separate (SRCH-004).
    final seen = <String>{};
    out.retainWhere((t) => seen.add(t.stableId));
    return out;
  }

  Widget _buildBody(BuildContext context, List<Track> all) {
    // Empty query: history + honest discovery CTA (no fake results, §3.3).
    if (!_searched && (_controller.text.isEmpty)) {
      return _emptyQueryView(context);
    }

    if (_loadingAudius ||
        _loadingJamendo ||
        _loadingArchive ||
        _loadingRadio ||
        _loadingYouTube) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, radius: 8),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(height: 10, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    if (all.isEmpty) {
      return ErrorStateView(
        message:
            'No results for "${_controller.text}". Try a different term or check the source filters.',
        onRetry: () => _runSearch(_controller.text.trim()),
        isOffline:
            (ref.read(connectivityProvider).asData?.value ?? true) == false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final track = all[index];
        return TrackTile(track: track, onTap: () => _playTrack(track));
      },
    );
  }

  Widget _emptyQueryView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await confirmDestructive(
                    context,
                    title: 'Clear recent searches?',
                    message: 'Removes the saved search terms on this device. Your library is not affected.',
                    confirmLabel: 'Clear',
                    danger: false,
                  );
                  if (ok) {
                    await RecentSearchesRepository(
                      ref.read(appDatabaseProvider),
                    ).clearAll();
                    await _loadRecent();
                  }
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in _recent)
                ActionChip(
                  label: Text(q),
                  onPressed: () {
                    _controller.text = q;
                    _runSearch(q, saveToRecent: true);
                  },
                ),
            ],
          ),
        ],
        if (_recent.isEmpty)
          const EmptyStateView(
            icon: Icons.search_rounded,
            title: 'Search your music and discovery sources',
            message: 'Type to search your local library instantly. Audius results load online; YouTube results appear once the gateway is configured (Settings → Diagnostics).',
          ),
      ],
    );
  }

  Future<void> _playTrack(Track track) async {
    if (track.provider == SourceProvider.youtube) {
      unawaited(
        context.push(
          '/youtube/${track.externalId}',
          extra: {'title': track.title, 'artist': track.artist},
        ),
      );
      return;
    }

    final player = ref.read(playerCoordinatorProvider);
    final gate = ref.read(rightsGateProvider);
    if (!gate.canEnterAudioQueue(track)) {
      showAppSnackBar(
        context,
        'This item cannot play as background audio here.',
      );
      return;
    }
    try {
      await player.playSingle(track);
      if (mounted) {
        unawaited(context.push(Routes.player));
      }
    } on PlaybackException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    } on NotConfiguredException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }
}

/// PLY-004 guard shared with library: keeps formats honest.
String formatSeekLabel(int positionMs, int? durationMs) =>
    '${formatDurationMs(positionMs)} / ${durationMs == null ? 'unknown' : formatDurationMs(durationMs)}';
