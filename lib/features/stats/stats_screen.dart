import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../data/mock/mock_songs.dart';
import '../../data/models/song.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../state/music_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final playlists = ref.watch(playlistsProvider);
    final memories = ref.watch(memoriesProvider);
    final favorites = ref.watch(favoritesProvider);
    final moods = ref.watch(moodsProvider);
    final songsAsync = ref.watch(songsProvider);
    final List<Song> allSongs = songsAsync.valueOrNull ?? mockSongs;

    final couple = session.couple ?? mockCouple;

    // Derive artist counts and mood counts from real song/mood data.
    final artistCounts = <String, int>{};
    for (final s in allSongs) {
      artistCounts[s.artist] = (artistCounts[s.artist] ?? 0) + 1;
    }
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxArtist = topArtists.isEmpty ? 1 : topArtists.first.value;

    final topSongs = List<Song>.from(allSongs)
      ..sort((a, b) => b.duration.inSeconds.compareTo(a.duration.inSeconds));

    final moodCounts = <String, int>{};
    for (final m in moods) {
      moodCounts[m.mood] = (moodCounts[m.mood] ?? 0) + 1;
    }
    if (moodCounts.isEmpty) moodCounts['In Love'] = 1;
    final totalMoods = moodCounts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.safePop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Music Statistics', style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                    label: 'Days Together',
                    value: '${couple.daysTogether}',
                    icon: Icons.favorite_rounded,
                    seed: 0),
                _StatCard(
                    label: 'Favorite Songs',
                    value: '${favorites.length}',
                    icon: Icons.favorite_rounded,
                    seed: 1),
                _StatCard(
                    label: 'Playlists',
                    value: '${playlists.length}',
                    icon: Icons.playlist_play_rounded,
                    seed: 2),
                _StatCard(
                    label: 'Memories',
                    value: '${memories.length}',
                    icon: Icons.photo_library_rounded,
                    seed: 3),
              ],
            ),
            const SizedBox(height: 24),
            Text('Top 5 Songs', style: AppTextStyles.h3()),
            const SizedBox(height: 12),
            ...topSongs.take(5).toList().asMap().entries.map((e) {
              final s = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text('${e.key + 1}',
                        style: AppTextStyles.h3(color: AppColors.textSecondary)),
                    const SizedBox(width: 14),
                    ArtworkTile(
                        seed: s.artworkSeed,
                        size: 44,
                        borderRadius: 10,
                        icon: Icons.music_note_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: AppTextStyles.bodyMedium()),
                          Text(s.artist, style: AppTextStyles.caption()),
                        ],
                      ),
                    ),
                    Text(s.durationLabel,
                        style: AppTextStyles.caption()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Text('Top Artists', style: AppTextStyles.h3()),
            const SizedBox(height: 12),
            ...topArtists.take(5).toList().asMap().entries.map((e) {
              final name = e.value.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    AvatarTile(seed: name, size: 40, label: name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.bodyMedium()),
                          SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              value: e.value.value / maxArtist,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.rose),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${e.value.value} songs',
                        style: AppTextStyles.caption()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Text('Mood Distribution', style: AppTextStyles.h3()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moodCounts.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: artworkGradient(
                        e.key.codeUnits.fold(0, (a, b) => a + b) % 8),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${e.key} ${((e.value / totalMoods) * 100).toInt()}%',
                    style: AppTextStyles.small(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final int seed;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ArtworkTile(
              seed: seed, size: 32, borderRadius: 8, icon: icon, iconSize: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h2()),
              Text(label, style: AppTextStyles.small()),
            ],
          ),
        ],
      ),
    );
  }
}
