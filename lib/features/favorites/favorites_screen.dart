import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/song.dart';
import '../../data/models/playlist.dart';
import '../../state/music_state.dart';
import '../../state/content_state.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoritesProvider);
    final playlists = ref.watch(playlistsProvider);
    final songsAsync = ref.watch(songsProvider);
    final List<Song> allSongs = songsAsync.valueOrNull ?? const [];
    final favoriteSongs =
        allSongs.where((s) => favoriteIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favorites', style: AppTextStyles.h3()),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.rose,
          labelColor: AppColors.rose,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SongsTab(songs: favoriteSongs),
          _PlaylistsTab(playlists: playlists),
        ],
      ),
    );
  }
}

class _SongsTab extends ConsumerWidget {
  final List<Song> songs;
  const _SongsTab({required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded,
                size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 14),
            Text('No favorite songs yet',
                style: AppTextStyles.h3(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('Heart songs while listening to save them here.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final song = songs[i];
        return GestureDetector(
          onTap: () {
            ref.read(playerProvider.notifier).play(song, queue: songs.cast());
            context.push('/player', extra: song.id);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ArtworkTile(
                  seed: song.artworkSeed,
                  size: 48,
                  borderRadius: 10,
                  icon: Icons.music_note_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: AppTextStyles.bodyMedium()),
                      Text(song.artist, style: AppTextStyles.caption()),
                      Text(formatDuration(song.duration),
                          style: AppTextStyles.small()),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded,
                      color: AppColors.rose, size: 20),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(song.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  final List<Playlist> playlists;
  const _PlaylistsTab({required this.playlists});

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_play_rounded,
                size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 14),
            Text('No playlists yet',
                style: AppTextStyles.h3(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: playlists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final playlist = playlists[i];
        return GestureDetector(
          onTap: () => context.push('/playlists/${playlist.id}'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ArtworkTile(
                  seed: playlist.coverSeed,
                  size: 52,
                  borderRadius: 10,
                  icon: Icons.playlist_play_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playlist.title, style: AppTextStyles.bodyMedium()),
                      Text('${playlist.songs.length} songs',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
