import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_songs.dart';
import '../../state/content_state.dart';

class MemoryDetailScreen extends ConsumerWidget {
  final String memoryId;
  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);
    final memory = memories.firstWhere(
      (m) => m.id == memoryId,
      orElse: () => memories.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 260,
            pinned: true,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  memory.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: memory.isFavorite ? AppColors.rose : null,
                ),
                onPressed: () => ref
                    .read(memoriesProvider.notifier)
                    .toggleFavorite(memory.id),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') {
                    ref.read(memoriesProvider.notifier).remove(memory.id);
                    context.pop();
                  } else if (v == 'edit') {
                    context.push('/memories/add');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: memory.photoSeeds.isNotEmpty
                  ? ArtworkTile(
                      seed: memory.photoSeeds.first,
                      size: double.infinity,
                      borderRadius: 0,
                      icon: Icons.photo_rounded,
                      iconSize: 60,
                    )
                  : Container(
                      color: AppColors.softPink,
                      child: const Icon(Icons.photo_library_rounded,
                          size: 60, color: AppColors.rose),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(memory.title, style: AppTextStyles.h2()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(formatDate(memory.date),
                        style: AppTextStyles.caption()),
                    if (memory.location != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(memory.location!,
                            style: AppTextStyles.caption()),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text(memory.description,
                    style: AppTextStyles.bodyLarge(
                        color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                // Photo gallery
                if (memory.photoSeeds.length > 1) ...[
                  Text('Photos', style: AppTextStyles.h3()),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: memory.photoSeeds.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) => ArtworkTile(
                        seed: memory.photoSeeds[i],
                        size: 90,
                        borderRadius: 10,
                        icon: Icons.photo_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Attached song
                if (memory.attachedSongId != null) ...[
                  Text('Soundtrack', style: AppTextStyles.h3()),
                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    try {
                      final song = songById(memory.attachedSongId!);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ArtworkTile(
                                seed: song.artworkSeed,
                                size: 48,
                                borderRadius: 10,
                                icon: Icons.music_note_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(song.title,
                                      style: AppTextStyles.bodyMedium()),
                                  Text(song.artist,
                                      style: AppTextStyles.caption()),
                                ],
                              ),
                            ),
                            const Icon(Icons.play_circle_filled_rounded,
                                color: AppColors.rose, size: 32),
                          ],
                        ),
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  }),
                  const SizedBox(height: 20),
                ],
                // Reactions
                if (memory.reactions.isNotEmpty) ...[
                  Row(
                    children: [
                      Text('Reactions', style: AppTextStyles.h3()),
                      const SizedBox(width: 10),
                      Text(memory.reactions.join(' '),
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                // Reaction buttons
                Row(
                  children: ['❤️', '😍', '🥹', '😂', '🎉'].map((e) {
                    return GestureDetector(
                      onTap: () {
                        final existing = List<String>.from(memory.reactions);
                        if (!existing.contains(e)) existing.add(e);
                        ref.read(memoriesProvider.notifier).update(
                              memory.copyWith(reactions: existing),
                            );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(e,
                            style: const TextStyle(fontSize: 20)),
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
}
