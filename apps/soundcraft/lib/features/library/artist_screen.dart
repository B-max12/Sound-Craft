import 'package:soundcraft/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundcraft/app/providers.dart';
import 'package:soundcraft/core/constants.dart';
import 'package:soundcraft/core/errors.dart';
import 'package:soundcraft/domain/models/track.dart';

/// Artist detail (§3.5) — implemented for Audius (real artist catalog via
/// /v1/users/{id}/tracks). Local artists group from tags (Library tab);
/// YouTube artists are channel references to the official player only.
class ArtistScreen extends ConsumerStatefulWidget {
  const ArtistScreen({
    super.key,
    required this.provider,
    required this.artistId,
  });
  final String provider;
  final String artistId;

  @override
  ConsumerState<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends ConsumerState<ArtistScreen> {
  List<Track>? _topTracks;
  String? _name;
  bool _verified = false;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.provider != SourceProvider.audius.id) {
      if (!mounted) return;
      setState(() {
        _error = 'Artist pages are available for Audius catalog items.';
        _loading = false;
      });
      return;
    }
    try {
      final api = ref.read(audiusApiProvider);
      final dtos = await api.tracksByArtist(widget.artistId, limit: 30);
      String name = 'Artist';
      bool verified = false;
      if (dtos.isNotEmpty) {
        name = dtos.first.artistName;
        verified = dtos.first.artistVerified;
      }
      if (!mounted) return;
      setState(() {
        _name = name;
        _verified = verified;
        _topTracks = dtos
            .map(
              (dto) => Track(
                stableId: stableTrackId(SourceProvider.audius, dto.id),
                provider: SourceProvider.audius,
                externalId: dto.id,
                title: dto.title,
                artist: dto.artistName,
                artistId: dto.artistId,
                artworkUrl: dto.artwork480 ?? dto.artwork150,
                durationMs: dto.durationSec == null
                    ? null
                    : dto.durationSec! * 1000,
                isDownloadable: dto.isDownloadable,
                isStreamable:
                    dto.isStreamable && dto.isAvailable && !dto.isDelete,
                attributedTo: 'Audius',
              ),
            )
            .toList();
        _loading = false;
      });
    } on ProviderException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name ?? 'Artist'),
        actions: [
          if (_topTracks != null && _topTracks!.isNotEmpty)
            TextButton(
              onPressed: () => _playAll(),
              child: const Text('Play top songs'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorStateView(message: _error!, onRetry: _load)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(Icons.person_outline_rounded, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _name ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ),
                                if (_verified) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: context.scColors.brandPrimary,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Audius catalog',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _topTracks?.length ?? 0,
                    itemBuilder: (context, index) {
                      final track = _topTracks![index];
                      return TrackTile(
                        track: track,
                        onTap: () => _playFrom(index),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _playAll() => _playFrom(0);

  Future<void> _playFrom(int index) async {
    final player = ref.read(playerCoordinatorProvider);
    final tracks = _topTracks ?? const <Track>[];
    try {
      await player.playTracks(tracks, startIndex: index);
    } on PlaybackException catch (e) {
      if (mounted) showAppSnackBar(context, e.message);
    }
  }
}

/// Album detail (§3.4). Audius does not expose first-class album entities for
/// all tracks; local albums group from tags (Library → Albums plays through
/// there). This screen handles direct deep links with an intelligible default
/// (NAV-007) and honest capability messaging instead of guessed pages.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key, required this.provider, required this.albumId});
  final String provider;
  final String albumId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: EmptyStateView(
        icon: Icons.album_outlined,
        title: 'Album pages are source-dependent',
        message: provider == SourceProvider.audius.id
            ? 'Audius exposes most releases as playlists or artist catalogs; use Search or the artist page. Album deep links land here until a release resolves.'
            : 'This source does not provide album entities in V1. Local albums are grouped in Library → Albums.',
      ),
    );
  }
}
