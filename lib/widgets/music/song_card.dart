import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/models/song.dart';
import '../../state/music_state.dart';

class SongCard extends ConsumerWidget {
  final Song song;
  final bool showDuration;
  final bool compact;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onSendToPartner;

  const SongCard({
    super.key,
    required this.song,
    this.showDuration = true,
    this.compact = false,
    this.onAddToPlaylist,
    this.onSendToPartner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isPlaying = player.currentSong?.id == song.id && player.isPlaying;
    final isFav = favorites.contains(song.id);

    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).play(song);
        context.push('/player', extra: song.id);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: compact ? 8 : 10),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.softPink
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ArtworkTile(
                  seed: song.artworkSeed,
                  size: compact ? 44 : 52,
                  borderRadius: 10,
                  icon: Icons.music_note_rounded,
                ),
                if (isPlaying)
                  Container(
                    width: compact ? 44 : 52,
                    height: compact ? 44 : 52,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.equalizer_rounded,
                        color: Colors.white, size: 20),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodyMedium(
                      color: isPlaying
                          ? AppColors.rose
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showDuration)
              Text(song.durationLabel,
                  style: AppTextStyles.caption()),
            if (onAddToPlaylist != null)
              IconButton(
                icon: const Icon(Icons.playlist_add_rounded,
                    color: AppColors.rose, size: 20),
                tooltip: 'Add to playlist',
                onPressed: onAddToPlaylist,
              ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(song.id),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.rose : AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
