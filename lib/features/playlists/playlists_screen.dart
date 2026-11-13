import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/models/playlist.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final session = ref.watch(sessionProvider);
    final me = session.currentUser ?? mockAlex;

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
            title: Text('Our Playlists', style: AppTextStyles.h2()),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _showCreateDialog(context, ref, me.id),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Filter tabs
                _FilterRow(),
                const SizedBox(height: 16),
                // Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: playlists.map((pl) {
                    final creator =
                        pl.createdByUserId == me.id ? 'You' : 'Sophia';
                    return GestureDetector(
                      onTap: () => context.push('/playlists/${pl.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArtworkTile(
                              seed: pl.coverSeed,
                              size: double.infinity,
                              borderRadius: 12,
                              icon: Icons.playlist_play_rounded,
                              iconSize: 32,
                            ),
                            const Spacer(),
                            Text(pl.title,
                                style: AppTextStyles.bodyMedium(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            Text('${pl.songs.length} songs · $creator',
                                style: AppTextStyles.small()),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, WidgetRef ref, String userId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardWhite,
        title: Text('New Playlist', style: AppTextStyles.h3()),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              ref.read(playlistsProvider.notifier).add(
                    Playlist(
                      id:
                          'pl_${DateTime.now().millisecondsSinceEpoch}',
                      title: ctrl.text.trim(),
                      coverSeed: DateTime.now().second % 8,
                      createdByUserId: userId,
                      createdAt: DateTime.now(),
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatefulWidget {
  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['All', 'Created by Me', 'Created by Partner']
          .asMap()
          .entries
          .map((e) {
        final selected = e.key == _tab;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _tab = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.rose
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(e.value,
                  style: AppTextStyles.small(
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
