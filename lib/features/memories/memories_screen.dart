import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/memory.dart';
import '../../state/content_state.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, innerScrolled) => [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Text('Our Memories', style: AppTextStyles.h2()),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => context.push('/memories/add'),
              ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: AppColors.rose,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.rose,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border,
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Photos'),
                Tab(text: 'Albums'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _TimelineTab(memories: memories),
            _PhotosTab(memories: memories),
            _AlbumsTab(memories: memories),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rose,
        onPressed: () => context.push('/memories/add'),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final List<Memory> memories;
  const _TimelineTab({required this.memories});

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return Center(
        child: Text('No memories yet. Create your first one!',
            style: AppTextStyles.body(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: memories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _MemoryCard(memory: memories[i]),
    );
  }
}

class _MemoryCard extends ConsumerWidget {
  final Memory memory;
  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/memories/${memory.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memory.photoSeeds.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg)),
                child: ArtworkTile(
                  seed: memory.photoSeeds.first,
                  size: double.infinity,
                  borderRadius: 0,
                  icon: Icons.photo_rounded,
                  iconSize: 32,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(memory.title,
                              style: AppTextStyles.bodyMedium())),
                      if (memory.isFavorite)
                        const Icon(Icons.favorite_rounded,
                            color: AppColors.rose, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(memory.description,
                      style: AppTextStyles.body(
                          color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(formatDate(memory.date),
                          style: AppTextStyles.small()),
                      if (memory.location != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(memory.location!,
                              style: AppTextStyles.small(),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      const Spacer(),
                      if (memory.reactions.isNotEmpty)
                        Text(memory.reactions.join(),
                            style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosTab extends StatelessWidget {
  final List<Memory> memories;
  const _PhotosTab({required this.memories});

  @override
  Widget build(BuildContext context) {
    final allSeeds = memories.expand((m) => m.photoSeeds).toList();
    if (allSeeds.isEmpty) {
      return Center(
        child: Text('No photos yet.',
            style: AppTextStyles.body(color: AppColors.textSecondary)),
      );
    }
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: allSeeds.map((s) {
        return ArtworkTile(
            seed: s, size: double.infinity, borderRadius: 6, icon: Icons.photo_rounded);
      }).toList(),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final List<Memory> memories;
  const _AlbumsTab({required this.memories});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: memories.map((m) {
        return GestureDetector(
          onTap: () => context.push('/memories/${m.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ArtworkTile(
                    seed: m.photoSeeds.isNotEmpty
                        ? m.photoSeeds.first
                        : m.id.codeUnits.fold(0, (a, b) => a + b) % 8,
                    size: double.infinity,
                    borderRadius: AppRadius.lg,
                    icon: Icons.photo_library_rounded,
                    iconSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.title,
                          style: AppTextStyles.bodyMedium(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(formatShortDate(m.date),
                          style: AppTextStyles.small()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
