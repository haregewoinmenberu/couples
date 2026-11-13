import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_moods.dart';
import '../../data/models/song.dart';
import '../../state/content_state.dart' show songsProvider;
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

  List<Song> _filtered(List<Song> all) {
    var songs = List<Song>.from(all);
    if (_selectedMood != null) {
      songs = songs.where((s) => s.moods.contains(_selectedMood)).toList();
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
    _searchCtrl.dispose();
    super.dispose();
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
                icon: const Icon(Icons.tune_rounded),
                onPressed: () {},
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
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
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
                        onTap: () => setState(() =>
                            _selectedMood = selected ? null : m),
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
                  ..._filtered(allSongs).map((s) => SongCard(song: s)),
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
                      onAction: () {}),
                  const SizedBox(height: 10),
                  ...allSongs.take(4).map((s) => SongCard(song: s)),
                  const SizedBox(height: 20),

                  // Love songs
                  _SectionHeader(title: 'Love Songs'),
                  const SizedBox(height: 10),
                  ...allSongs
                      .where((s) => s.moods.contains('Romantic') ||
                          s.moods.contains('In Love'))
                      .take(4)
                      .map((s) => SongCard(song: s)),
                  const SizedBox(height: 20),

                  // Ethiopian
                  if (allSongs.any((s) => s.isEthiopian)) ...[
                    _SectionHeader(title: 'Ethiopian Favorites'),
                    const SizedBox(height: 10),
                    ...allSongs.where((s) => s.isEthiopian).map((s) => SongCard(song: s)),
                    const SizedBox(height: 20),
                  ],

                  // Missing you
                  _SectionHeader(title: 'Missing You'),
                  const SizedBox(height: 10),
                  ...allSongs
                      .where((s) => s.moods.contains('Missing You') ||
                          s.moods.contains('Thinking of You'))
                      .map((s) => SongCard(song: s)),
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
