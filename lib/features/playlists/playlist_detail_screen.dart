import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_songs.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../state/music_state.dart';
import '../../widgets/music/song_card.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final session = ref.watch(sessionProvider);
    final me = session.currentUser ?? mockAlex;

    final playlist = playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => playlists.first,
    );

    final songs = playlist.songs
        .map((e) {
          try {
            return songById(e.songId);
          } catch (_) {
            return null;
          }
        })
        .whereType<dynamic>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 220,
            pinned: true,
            leading: GestureDetector(
              onTap: () => context.safePop(),
              child: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: artworkGradient(playlist.coverSeed),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ArtworkTile(
                            seed: playlist.coverSeed,
                            size: 90,
                            borderRadius: 16,
                            icon: Icons.playlist_play_rounded,
                            iconSize: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(playlist.title,
                                    style: AppTextStyles.h2(
                                        color: Colors.white)),
                                if (playlist.description != null)
                                  Text(playlist.description!,
                                      style: AppTextStyles.body(
                                          color: Colors.white70)),
                                Text(
                                    '${playlist.songs.length} songs',
                                    style: AppTextStyles.caption(
                                        color: Colors.white60)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (playlist.createdByUserId == me.id)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _showEditDialog(context, ref, playlist.id,
                      playlist.title),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) {
                  if (v == 'delete' &&
                      playlist.createdByUserId == me.id) {
                    ref
                        .read(playlistsProvider.notifier)
                        .remove(playlist.id);
                    context.safePop();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'delete', child: Text('Delete Playlist')),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Play Together / Shuffle row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          if (songs.isEmpty) return;
                          ref
                              .read(playerProvider.notifier)
                              .play(songs.first, queue: songs.cast());
                          context.push('/player', extra: songs.first.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text('Play Together',
                                  style: AppTextStyles.bodyMedium(
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (songs.isEmpty) return;
                          ref
                              .read(playerProvider.notifier)
                              .play(songs.last, queue: songs.cast());
                        },
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text('Shuffle'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (songs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text('No songs yet. Add some!',
                          style: AppTextStyles.body(
                              color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...songs.cast<dynamic>().map((s) => SongCard(song: s)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String id,
      String currentTitle) {
    final ctrl = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rename Playlist', style: AppTextStyles.h3()),
        content: TextField(
            controller: ctrl,
            autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final playlists = ref.read(playlistsProvider);
              final pl =
                  playlists.firstWhere((p) => p.id == id);
              ref
                  .read(playlistsProvider.notifier)
                  .update(pl.copyWith(title: ctrl.text.trim()));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
