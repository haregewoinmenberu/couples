import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../state/music_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final favorites = ref.watch(favoritesProvider);
    final playlists = ref.watch(playlistsProvider);
    final memories = ref.watch(memoriesProvider);

    final me = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;
    final couple = session.couple ?? mockCouple;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: artworkGradient(
                      me.avatarSeed.codeUnits.fold(0, (a, b) => a + b) % 8),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          AvatarTile(
                              seed: me.avatarSeed,
                              size: 80,
                              label: me.fullName),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                  color: AppColors.rose,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(me.fullName,
                          style: AppTextStyles.h2(color: Colors.white)),
                      Text('@${me.username}',
                          style: AppTextStyles.body(color: Colors.white70)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                Row(
                  children: [
                    Expanded(
                        child: _StatItem(
                            value: '${couple.daysTogether}',
                            label: 'Days')),
                    _Divider(),
                    Expanded(
                        child: _StatItem(
                            value: '${favorites.length}',
                            label: 'Songs')),
                    _Divider(),
                    Expanded(
                        child: _StatItem(
                            value: '${memories.length}',
                            label: 'Memories')),
                  ],
                ),
                const SizedBox(height: 20),
                // Partner card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.loveGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      AvatarTile(
                          seed: partner.avatarSeed,
                          size: 48,
                          label: partner.fullName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(partner.fullName,
                                style: AppTextStyles.bodyMedium()),
                            Text(formatAnniversary(couple.anniversaryDate),
                                style: AppTextStyles.caption()),
                          ],
                        ),
                      ),
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.rose, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _ProfileListItem(
                  icon: Icons.playlist_play_rounded,
                  label: 'My Playlists',
                  badge: '${playlists.where((p) => p.createdByUserId == me.id).length}',
                  onTap: () => context.push('/playlists'),
                ),
                _ProfileListItem(
                  icon: Icons.photo_library_rounded,
                  label: 'My Memories',
                  badge: '${memories.length}',
                  onTap: () => context.push('/memories'),
                ),
                _ProfileListItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Music Stats',
                  onTap: () => context.push('/stats'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2()),
        Text(label, style: AppTextStyles.small()),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: AppColors.border);
  }
}

class _ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _ProfileListItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.rose, size: 22),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label, style: AppTextStyles.body())),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!,
                    style: AppTextStyles.small(color: AppColors.rose)),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
