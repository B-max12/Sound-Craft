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
import 'package:soundcraft/domain/models/track.dart';
import 'package:soundcraft/domain/providers/music_discovery_provider.dart';
import 'package:soundcraft/domain/services/recommender.dart';

/// Home feed assembly (§25.1): only auditable real data. Sections:
///  * Continue listening (local history)
///  * Recently added locally
///  * Made for You (deterministic local ranking; honest empty state)
///  * Trending on Audius (live provider data, attributed)
///  * Fresh on Audius (underground feed)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Track>? _continueListening;
  List<Track>? _recentlyAdded;
  List<Track>? _trending;
  List<Track>? _fresh;
  List<Track>? _jamendoTrending;
  List<Track>? _radioStations;
  List<Track>? _archivePicks;
  List<Track>? _youtubePicks;
  List<Track>? _madeForYou;
  String? _trendingError;
  String? _freshError;
  String? _jamendoError;
  String? _radioError;
  String? _archiveError;
  String? _youtubeError;
  bool _loadingTrending = false;
  bool _loadingFresh = false;
  bool _loadingJamendo = false;
  bool _loadingRadio = false;
  bool _loadingArchive = false;
  bool _loadingYoutube = false;
  DateTime? _lastRefresh;
  int _localCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll({bool providerRefresh = false}) async {
    final library = ref.read(localLibraryRepoProvider);
    final history = ref.read(historyRepoProvider);
    final favorites = ref.read(favoritesRepoProvider);
    bool online = true;
    try {
      online = await ref.read(connectivityProvider.future);
    } catch (_) {
      online = true;
    }

    // Local sections always available offline (SYS-001).
    final local = await library.getAll();
    final recentHistory = await history.recent(limit: 12);
    final counts = await history.playCounts();
    final skipped = await history.skippedTrackIds();
    final favIds = await favorites.allIds();

    final continueTracks = <Track>[];
    for (final entry in recentHistory) {
      if (entry.sourceType == SourceProvider.local) {
        final t = await library.getById(entry.stableTrackId);
        if (t != null) continueTracks.add(t);
      }
    }
    final recentlyAdded = local.length > 12 ? local.sublist(0, 12) : local;

    final personalization =
        ref.read(privacyProvider).value?.personalizationEnabled ?? true;
    List<Track>? madeForYou;
    if (local.length >= 3 && personalization) {
      final ranker = const Recommender().rankLocal(
        candidates: local,
        playCounts: counts,
        skipped: skipped,
        favoriteIds: favIds,
      );
      madeForYou = ranker.take(12).toList();
    }

    if (!mounted) return;
    setState(() {
      _continueListening = continueTracks;
      _recentlyAdded = recentlyAdded;
      _madeForYou = madeForYou;
      _localCount = local.length;
    });

    // Provider sections: load independently in parallel so one slow/failing
    // source never blocks or blanks the others.
    if (online) {
      await Future.wait([
        _loadTrendingSection(),
        _loadFreshSection(),
        _loadJamendoSection(),
        _loadRadioSection(),
        _loadArchiveSection(),
        _loadYoutubeSection(),
      ]);
      if (mounted) {
        setState(() => _lastRefresh = DateTime.now());
      }
    } else {
      if (mounted) {
        setState(() {
          _trendingError = 'Online discovery needs a connection.';
          _freshError = 'Online discovery needs a connection.';
          _jamendoError = null;
          _radioError = 'Online discovery needs a connection.';
          _archiveError = 'Online discovery needs a connection.';
          _youtubeError = null;
        });
      }
    }
  }

  Future<void> _loadTrendingSection() async {
    final audius = ref.read(audiusProvider);
    if (mounted) {
      setState(() {
        _loadingTrending = true;
        _trendingError = null;
      });
    }
    try {
      final trending = await audius.trending(const FeedQuery(limit: 16));
      if (mounted) setState(() => _trending = trending);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _trendingError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _trendingError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTrending = false);
    }
  }

  Future<void> _loadFreshSection() async {
    final audius = ref.read(audiusProvider);
    if (mounted) {
      setState(() {
        _loadingFresh = true;
        _freshError = null;
      });
    }
    try {
      final fresh = await audius.newest(const FeedQuery(limit: 16));
      if (mounted) setState(() => _fresh = fresh);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _freshError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _freshError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingFresh = false);
    }
  }

  Future<void> _loadJamendoSection() async {
    final jamendo = ref.read(jamendoProvider);
    if (!jamendo.isConfigured) return;
    if (mounted) {
      setState(() {
        _loadingJamendo = true;
        _jamendoError = null;
      });
    }
    try {
      final list = await jamendo.trending(const FeedQuery(limit: 16));
      if (mounted) setState(() => _jamendoTrending = list);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _jamendoError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _jamendoError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingJamendo = false);
    }
  }

  Future<void> _loadRadioSection() async {
    final radio = ref.read(radioProvider);
    if (mounted) {
      setState(() {
        _loadingRadio = true;
        _radioError = null;
      });
    }
    try {
      final list = await radio.trending(const FeedQuery(limit: 12));
      if (mounted) setState(() => _radioStations = list);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _radioError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _radioError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingRadio = false);
    }
  }

  Future<void> _loadArchiveSection() async {
    final archive = ref.read(archiveProvider);
    if (mounted) {
      setState(() {
        _loadingArchive = true;
        _archiveError = null;
      });
    }
    try {
      final list = await archive.trending(const FeedQuery(limit: 12));
      if (mounted) setState(() => _archivePicks = list);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _archiveError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _archiveError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingArchive = false);
    }
  }

  Future<void> _playMoodMix(String mood) async {
    showAppSnackBar(context, 'Loading $mood mix...');
    final results = <Track>[];
    try {
      final a = await ref
          .read(audiusProvider)
          .searchTracks(SearchQuery(text: mood, limit: 10));
      results.addAll(a.items.where((t) => t.isStreamable));
    } catch (_) {}
    final jamendo = ref.read(jamendoProvider);
    if (jamendo.isConfigured) {
      try {
        final j = await jamendo.searchTracks(SearchQuery(text: mood, limit: 10));
        results.addAll(j.items.where((t) => t.isStreamable));
      } catch (_) {}
    }
    if (!mounted) return;
    if (results.isEmpty) {
      showAppSnackBar(context, 'No $mood tracks found right now.');
      return;
    }
    await _playNow(results, 0);
  }

  Future<void> _loadYoutubeSection() async {
    final yt = ref.read(youtubeProvider);
    if (!yt.isConfigured) return;
    if (mounted) {
      setState(() {
        _loadingYoutube = true;
        _youtubeError = null;
      });
    }
    try {
      final ytPage = await yt.search('top songs new music trending hits', limit: 12);
      if (mounted) setState(() => _youtubePicks = ytPage.items);
    } on ProviderException catch (e) {
      if (mounted) setState(() => _youtubeError = e.message);
    } on Object catch (e) {
      if (mounted) setState(() => _youtubeError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingYoutube = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    return Scaffold(
      appBar: AppBar(
        title: Text(greeting),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              await _loadAll(providerRefresh: true);
              if (context.mounted) {
                showAppSnackBar(
                  context,
                  _lastRefresh == null
                      ? 'Refreshed local data'
                      : 'Refreshed · last update ${TimeOfDay.fromDateTime(_lastRefresh!).format(context)}',
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAll(providerRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 160),
          children: [
            // Mood & Genre quick-mix chips.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  for (final mood in const [
                    'Lo-Fi',
                    'Electronic',
                    'Hip-Hop',
                    'Chill',
                    'Jazz',
                    'Rock',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.bolt_rounded, size: 16),
                        label: Text(mood),
                        onPressed: () => _playMoodMix(mood),
                      ),
                    ),
                ],
              ),
            ),
            // Local library teaser / import CTA.
            if (_localCount == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your music lives here',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Import audio files from this device — SoundCraft plays them fully offline, no account needed.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.go(Routes.library),
                          icon: const Icon(Icons.library_add_rounded),
                          label: const Text('Import local music'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_continueListening != null &&
                _continueListening!.isNotEmpty) ...[
              SectionHeader(
                title: 'Continue listening',
                subtitle: 'From your device-local history',
              ),
              TrackCardRail(
                tracks: _continueListening!,
                onTrackTap: (t) => _playNow([t], 0),
              ),
            ],
            if (_madeForYou != null && _madeForYou!.isNotEmpty) ...[
              SectionHeader(
                title: 'Made for You',
                subtitle: 'Ranked from your local listening — stored only on this device',
                actionLabel: 'Play all',
                onAction: () => _playNow(_madeForYou!, 0),
              ),
              TrackCardRail(
                tracks: _madeForYou!,
                onTrackTap: (t) =>
                    _playNow(_madeForYou!, _madeForYou!.indexOf(t)),
              ),
            ],
            if (_recentlyAdded != null && _recentlyAdded!.isNotEmpty) ...[
              SectionHeader(
                title: 'Recently added locally',
                actionLabel: 'Open library',
                onAction: () => context.go(Routes.library),
              ),
              TrackCardRail(
                tracks: _recentlyAdded!,
                onTrackTap: (t) =>
                    _playNow(_recentlyAdded!, _recentlyAdded!.indexOf(t)),
              ),
            ],
            // Audius sections: attributed honestly (Appendix A).
            _providerSection(
              title: 'Trending on Audius',
              subtitle: 'Live popularity from the Audius public API',
              badge: 'Audius',
              tracks: _trending,
              error: _trendingError,
              loading: _loadingTrending,
              onRetry: _loadTrendingSection,
            ),
            _providerSection(
              title: 'Fresh on Audius',
              subtitle: 'Underground picks from the Audius public API',
              badge: 'Audius',
              tracks: _fresh,
              error: _freshError,
              loading: _loadingFresh,
              onRetry: _loadFreshSection,
            ),
            _providerSection(
              title: 'Popular on Jamendo',
              subtitle: 'Creative Commons tracks — free to stream & download',
              badge: 'Jamendo',
              tracks: _jamendoTrending,
              error: _jamendoError,
              loading: _loadingJamendo,
              onRetry: _loadJamendoSection,
            ),
            _providerSection(
              title: 'Live Radio Stations',
              subtitle: '40,000+ stations via Radio Browser',
              badge: 'Radio',
              tracks: _radioStations,
              error: _radioError,
              loading: _loadingRadio,
              onRetry: _loadRadioSection,
            ),
            _providerSection(
              title: 'Internet Archive Picks',
              subtitle: 'Live concerts & public-domain audio',
              badge: 'Archive',
              tracks: _archivePicks,
              error: _archiveError,
              loading: _loadingArchive,
              onRetry: _loadArchiveSection,
            ),
            _providerSection(
              title: 'Trending on YouTube',
              subtitle: 'Popular music hits from YouTube',
              badge: 'YouTube',
              tracks: _youtubePicks,
              error: _youtubeError,
              loading: _loadingYoutube,
              onRetry: _loadYoutubeSection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerSection({
    required String title,
    required String subtitle,
    required String badge,
    required List<Track>? tracks,
    required String? error,
    required bool loading,
    required VoidCallback onRetry,
  }) {
    if (loading && tracks == null && error == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          SizedBox(
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(6, (_) => const _SkeletonCard()),
            ),
          ),
        ],
      );
    }
    if (error != null && (tracks == null || tracks.isEmpty)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (tracks == null || tracks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          actionLabel: 'Play all',
          onAction: () => _playNow(tracks, 0),
        ),
        TrackCardRail(
          tracks: tracks,
          onTrackTap: (t) => _playNow(tracks, tracks.indexOf(t)),
          badge: badge,
        ),
      ],
    );
  }

  Future<void> _playNow(List<Track> tracks, int index) async {
    final selectedTrack = index >= 0 && index < tracks.length ? tracks[index] : null;
    if (selectedTrack != null && selectedTrack.provider == SourceProvider.youtube) {
      unawaited(
        context.push(
          '/youtube/${selectedTrack.externalId}',
          extra: {'title': selectedTrack.title, 'artist': selectedTrack.artist},
        ),
      );
      return;
    }

    final player = ref.read(playerCoordinatorProvider);
    final gate = ref.read(rightsGateProvider);
    final playable = tracks
        .where((t) => gate.canEnterAudioQueue(t))
        .toList(growable: false);
    if (playable.isEmpty) {
      showAppSnackBar(context, 'Nothing in this list can play as audio here.');
      return;
    }
    final targetIndex = selectedTrack != null ? playable.indexOf(selectedTrack) : index;
    final startIndex = (targetIndex >= 0 ? targetIndex : 0).clamp(0, playable.length - 1);
    try {
      await player.playTracks(playable, startIndex: startIndex);
      if (mounted) {
        unawaited(context.push(Routes.player));
      }
    } on PlaybackException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 148, height: 148, radius: 12),
          SizedBox(height: 8),
          SkeletonBox(width: 120, height: 12),
          SizedBox(height: 4),
          SkeletonBox(width: 80, height: 10),
        ],
      ),
    );
  }
}
