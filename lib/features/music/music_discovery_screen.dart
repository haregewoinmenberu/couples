import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/mood_matching.dart';
import '../../data/mock/mock_moods.dart';
import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart' show songsProvider, playlistsProvider;
import '../../state/music_state.dart';
import '../../widgets/music/song_card.dart';

class MusicDiscoveryScreen extends ConsumerStatefulWidget {
  const MusicDiscoveryScreen({super.key});

  @override
  ConsumerState<MusicDiscoveryScreen> createState() =>
      _MusicDiscoveryScreenState();
}

class _MusicDiscoveryScreenState extends ConsumerState<MusicDiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedMood;
  String _query = '';
  Timer? _debounce;

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(songsProvider.notifier).load(
            search: value.trim().isEmpty ? null : value.trim(),
            mood: _selectedMood,
          );
    });
  }

  List<Song> _filtered(List<Song> all) {
    var songs = List<Song>.from(all);
    if (_selectedMood != null) {
      songs = songs.where((s) => songMatchesMood(s, _selectedMood!)).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      songs = songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q))
          .toList();
    }
    return songs;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showYouTubeSearch(BuildContext context) {
    final queryCtrl = TextEditingController();
    List<dynamic> results = [];
    bool searching = false;
    String? error;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.youtube_searched_for_rounded,
                  color: Colors.red),
              const SizedBox(width: 8),
              Text('Find on YouTube', style: AppTextStyles.h3()),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: queryCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search songs, artists...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onSubmitted: (_) async {
                    if (queryCtrl.text.trim().isEmpty) return;
                    setState(() {
                      searching = true;
                      error = null;
                    });
                    try {
                      final r =
                          await ApiService.searchYouTube(queryCtrl.text.trim());
                      if (!context.mounted) return;
                      setState(() {
                        results = r;
                        searching = false;
                      });
                    } catch (_) {
                      if (!context.mounted) return;
                      setState(() {
                        searching = false;
                        error = 'Search is unavailable right now.';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (searching)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.rose),
                  )
                else if (error != null)
                  Text(error!,
                      style: AppTextStyles.caption(color: AppColors.error))
                else if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Search for a song and tap a result to add it to your library. It will play inside OurSound — nothing is downloaded.',
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final r = results[i] as Map<String, dynamic>;
                        return ListTile(
                          leading: Image.network(
                            r['thumbnail'] as String? ?? '',
                            width: 56,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.music_note_rounded,
                                color: AppColors.rose),
                          ),
                          title: Text(r['title'] as String? ?? '',
                              style: AppTextStyles.bodyMedium(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(r['artist'] as String? ?? '',
                              style: AppTextStyles.caption()),
                          trailing: const Icon(Icons.add_circle_rounded,
                              color: AppColors.rose),
                          onTap: () {
                            final id = r['id'] as String;
                            ref.read(songsProvider.notifier).add(Song(
                                  id: 'yt_$id',
                                  title: r['title'] as String? ?? id,
                                  artist: r['artist'] as String? ?? 'YouTube',
                                  album: 'YouTube',
                                  artworkSeed: id.hashCode.abs() % 8,
                                  duration: Duration.zero,
                                  youtubeId: id,
                                  thumbnailUrl: r['thumbnail'] as String?,
                                ));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Added — tap it to play')),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: searching || queryCtrl.text.trim().isEmpty
                  ? null
                  : () async {
                      setState(() => searching = true);
                      try {
                        final r = await ApiService.searchYouTube(
                            queryCtrl.text.trim());
                        if (!context.mounted) return;
                        setState(() {
                          results = r;
                          searching = false;
                        });
                      } catch (_) {
                        if (!context.mounted) return;
                        setState(() {
                          searching = false;
                          error = 'Search is unavailable right now.';
                        });
                      }
                    },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToPlaylist(BuildContext context, Song song) {
    final playlists = ref.read(playlistsProvider);
    final me = ref.read(sessionProvider).currentUser;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add "${song.title}" to...', style: AppTextStyles.h3()),
            const SizedBox(height: 12),
            if (playlists.isEmpty)
              Text('No playlists yet. Create one from the Playlists tab.',
                  style: AppTextStyles.body(color: AppColors.textSecondary))
            else
              ...playlists.map((pl) => ListTile(
                    leading: const Icon(Icons.playlist_play_rounded,
                        color: AppColors.rose),
                    title: Text(pl.title, style: AppTextStyles.body()),
                    subtitle: Text('${pl.songs.length} songs',
                        style: AppTextStyles.caption()),
                    onTap: () {
                      if (pl.songs.any((e) => e.songId == song.id)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already in playlist')),
                        );
                        return;
                      }
                      ref.read(playlistsProvider.notifier).addSong(
                            pl.id,
                            PlaylistSongEntry(
                              songId: song.id,
                              addedByUserId: me?.id ?? '',
                              addedAt: DateTime.now(),
                            ),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to ${pl.title}')),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }

  void _showAddSongDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController();
    final albumCtrl = TextEditingController();
    final moodCtrl = TextEditingController();
    bool saving = false;
    String? error;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add a Song', style: AppTextStyles.h3()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title *')),
                const SizedBox(height: 10),
                TextField(
                    controller: artistCtrl,
                    decoration: const InputDecoration(labelText: 'Artist *')),
                const SizedBox(height: 10),
                TextField(
                    controller: albumCtrl,
                    decoration: const InputDecoration(labelText: 'Album')),
                const SizedBox(height: 10),
                TextField(
                  controller: moodCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Mood (optional)',
                      hintText: 'Romantic, Happy...'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: AppTextStyles.caption(color: AppColors.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (titleCtrl.text.trim().isEmpty ||
                          artistCtrl.text.trim().isEmpty) {
                        setState(() => error = 'Title and artist are required.');
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        await ApiService.createSong(
                          title: titleCtrl.text.trim(),
                          artist: artistCtrl.text.trim(),
                          album: albumCtrl.text.trim().isEmpty
                              ? 'Single'
                              : albumCtrl.text.trim(),
                          durationSecs: 210,
                          moods: moodCtrl.text.trim().isEmpty
                              ? const []
                              : [moodCtrl.text.trim()],
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ref.read(songsProvider.notifier).load(
                              search: _query.trim().isEmpty
                                  ? null
                                  : _query.trim(),
                              mood: _selectedMood,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Song added')),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        setState(() {
                          saving = false;
                          error = 'Could not save. Check your connection.';
                        });
                      }
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final genreCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Filter music', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mood', style: AppTextStyles.caption()),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: discoveryMoodFilters.map((m) {
                final sel = _selectedMood == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: sel,
                  onSelected: (_) {
                    setState(() => _selectedMood = sel ? null : m);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: genreCtrl,
              decoration: const InputDecoration(
                  labelText: 'Genre (optional)',
                  hintText: 'e.g. Pop, R&B'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMood = null;
                _query = '';
              });
              _searchCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              final g = genreCtrl.text.trim();
              Navigator.pop(context);
              ref.read(songsProvider.notifier).load(genre: g.isEmpty ? null : g);
              if (g.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Filtering by genre: $g')),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAll(BuildContext context, String title, List<Song> songs) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(title, style: AppTextStyles.h3()),
        ),
        body: songs.isEmpty
            ? Center(
                child: Text('No songs yet.',
                    style: AppTextStyles.body(color: AppColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: songs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => SongCard(song: songs[i],
                        onAddToPlaylist: () => _addToPlaylist(context, songs[i])),
              ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    final allSongs = songsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Text('Discover music.', style: AppTextStyles.h2()),
            actions: [
              IconButton(
                icon: const Icon(Icons.youtube_searched_for_rounded),
                tooltip: 'Find music on YouTube',
                onPressed: () => _showYouTubeSearch(context),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add a song',
                onPressed: () => _showAddSongDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _showFilters(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                              ref.read(songsProvider.notifier).load(
                                    mood: _selectedMood,
                                  );
                            },
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textSecondary),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // Mood filters
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: discoveryMoodFilters.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final m = discoveryMoodFilters[i];
                      final selected = _selectedMood == m;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedMood = selected ? null : m);
                          ref.read(songsProvider.notifier).load(
                                search: _query.trim().isEmpty
                                    ? null
                                    : _query.trim(),
                                mood: selected ? null : m,
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.rose
                                : AppColors.backgroundSecondary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            m,
                            style: AppTextStyles.small(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                if (_query.isNotEmpty || _selectedMood != null) ...[
                  Text(
                    '${_filtered(allSongs).length} result${_filtered(allSongs).length == 1 ? '' : 's'}',
                    style:
                        AppTextStyles.caption(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ..._filtered(allSongs).map((s) => SongCard(song: s, onAddToPlaylist: () => _addToPlaylist(context, s))),
                ] else if (songsAsync.isLoading) ...[
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  )),
                ] else ...[
                  // Recommended
                  _SectionHeader(
                      title: 'Recommended for You',
                      action: 'See all',
                      onAction: () => _showAll(context, 'Recommended for You', allSongs)),
                  const SizedBox(height: 10),
                  ...allSongs.take(4).map((s) => SongCard(song: s, onAddToPlaylist: () => _addToPlaylist(context, s))),
                  const SizedBox(height: 20),

                  // Love songs
                  _SectionHeader(title: 'Love Songs'),
                  const SizedBox(height: 10),
                  ...allSongs
                      .where((s) => songMatchesAnyMood(s, ['Romantic', 'In Love']))
                      .take(4)
                      .map((s) => SongCard(song: s, onAddToPlaylist: () => _addToPlaylist(context, s))),
                  const SizedBox(height: 20),

                  // Ethiopian
                  if (allSongs.any((s) => s.isEthiopian)) ...[
                    _SectionHeader(title: 'Ethiopian Favorites'),
                    const SizedBox(height: 10),
                    ...allSongs.where((s) => s.isEthiopian).map((s) => SongCard(song: s, onAddToPlaylist: () => _addToPlaylist(context, s))),
                    const SizedBox(height: 20),
                  ],

                  // Missing you
                  _SectionHeader(title: 'Missing You'),
                  const SizedBox(height: 10),
                  ...allSongs
                      .where((s) =>
                          songMatchesAnyMood(s, ['Missing You', 'Thinking of You']))
                      .map((s) => SongCard(song: s, onAddToPlaylist: () => _addToPlaylist(context, s))),
                  const SizedBox(height: 20),

                  // Trending
                  _SectionHeader(title: 'Trending Songs'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allSongs.length.clamp(0, 6),
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final s = allSongs[i];
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(playerProvider.notifier)
                                .play(s, queue: allSongs);
                            context.push('/player', extra: s.id);
                          },
                          child: SizedBox(
                            width: 90,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                ArtworkTile(
                                    seed: s.artworkSeed,
                                    size: 80,
                                    borderRadius: 12,
                                    icon: Icons.music_note_rounded),
                                const SizedBox(height: 4),
                                Text(s.title,
                                    style: AppTextStyles.caption(
                                        color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(s.artist,
                                    style: AppTextStyles.small(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h3())),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: AppTextStyles.caption(color: AppColors.rose)),
          ),
      ],
    );
  }
}
