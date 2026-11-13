import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_people.dart';
import '../../data/mock/mock_playlists.dart';
import '../../data/mock/mock_songs.dart';
import '../../state/app_state.dart';
import '../../state/music_state.dart';
import '../../state/content_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final player = ref.watch(playerProvider);
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.where((n) => !n.isRead).length;

    final user = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;
    final couple = session.couple ?? mockCouple;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            titleSpacing: 20,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, ${user.fullName}.',
                    style: AppTextStyles.h3()),
                Text('Your shared musical world.',
                    style: AppTextStyles.caption()),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.rose, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: AvatarTile(
                      seed: user.avatarSeed, size: 36, label: user.fullName),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Couple card
                _CoupleCard(
                  user: user,
                  partner: partner,
                  daysTogether: couple.daysTogether,
                  anniversary: couple.anniversaryDate,
                ),
                const SizedBox(height: 20),

                // Daily song
                _SectionHeader(title: "Today's song for us",
                    action: 'See all',
                    onAction: () => context.push('/music')),
                const SizedBox(height: 10),
                _DailySongCard(song: mockSongs[0], ref: ref),
                const SizedBox(height: 20),

                // Now playing together
                if (player.hasTrack) ...[
                  _SectionHeader(title: 'Now playing together'),
                  const SizedBox(height: 10),
                  _NowPlayingCard(player: player, ref: ref),
                  const SizedBox(height: 20),
                ],

                // Quick actions
                _SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickAction(
                        icon: Icons.music_note_rounded,
                        label: 'Send a Song',
                        seed: 0,
                        onTap: () => context.push('/music')),
                    _QuickAction(
                        icon: Icons.photo_camera_rounded,
                        label: 'Share a Photo',
                        seed: 2,
                        onTap: () => context.push('/chat')),
                    _QuickAction(
                        icon: Icons.playlist_add_rounded,
                        label: 'Create Playlist',
                        seed: 4,
                        onTap: () => context.push('/playlists')),
                    _QuickAction(
                        icon: Icons.add_photo_alternate_rounded,
                        label: 'Add Memory',
                        seed: 6,
                        onTap: () => context.push('/memories/add')),
                  ],
                ),
                const SizedBox(height: 20),

                // Playlists
                _SectionHeader(
                    title: 'Shared playlists',
                    action: 'See all',
                    onAction: () => context.push('/playlists')),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockPlaylists.length.clamp(0, 4),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final pl = mockPlaylists[i];
                      return GestureDetector(
                        onTap: () => context.push('/playlists/${pl.id}'),
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ArtworkTile(
                                  seed: pl.coverSeed,
                                  size: 80,
                                  borderRadius: 14,
                                  icon: Icons.playlist_play_rounded),
                              const SizedBox(height: 6),
                              Text(pl.title,
                                  style: AppTextStyles.caption(
                                      color: AppColors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Daily question
                _SectionHeader(
                    title: "Daily question",
                    action: 'Answer',
                    onAction: () => context.push('/questions')),
                const SizedBox(height: 10),
                _DailyQuestionCard(),

                const SizedBox(height: 20),

                // Recent activity
                _SectionHeader(title: 'Recent activity'),
                const SizedBox(height: 10),
                _ActivityItem(
                  icon: Icons.music_note_rounded,
                  text: '${partner.fullName} added "All of Me" to Our Love Songs',
                  time: '2h ago',
                ),
                _ActivityItem(
                  icon: Icons.favorite_rounded,
                  text: 'You received a music dedication from ${partner.fullName}',
                  time: '8h ago',
                ),
                _ActivityItem(
                  icon: Icons.photo_library_rounded,
                  text: '${partner.fullName} added a new memory',
                  time: '1d ago',
                ),
                _ActivityItem(
                  icon: Icons.thumb_up_rounded,
                  text: '${partner.fullName} reacted ❤️ to "Yellow"',
                  time: '2d ago',
                ),

                const SizedBox(height: 20),

                // Feature shortcuts
                Row(
                  children: [
                    Expanded(
                      child: _FeatureShortcut(
                        icon: Icons.emoji_emotions_rounded,
                        label: 'Mood',
                        seed: 1,
                        onTap: () => context.push('/mood'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FeatureShortcut(
                        icon: Icons.sports_esports_rounded,
                        label: 'Challenges',
                        seed: 3,
                        onTap: () => context.push('/challenges'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FeatureShortcut(
                        icon: Icons.bar_chart_rounded,
                        label: 'Stats',
                        seed: 5,
                        onTap: () => context.push('/stats'),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoupleCard extends StatelessWidget {
  final dynamic user;
  final dynamic partner;
  final int daysTogether;
  final DateTime anniversary;

  const _CoupleCard({
    required this.user,
    required this.partner,
    required this.daysTogether,
    required this.anniversary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.loveGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              AvatarTile(
                  seed: user.avatarSeed, size: 54, label: user.fullName),
              Positioned(
                bottom: 0,
                right: -8,
                child: AvatarTile(
                    seed: partner.avatarSeed,
                    size: 46,
                    label: partner.fullName),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.fullName} & ${partner.fullName}',
                    style: AppTextStyles.bodyMedium()),
                Text(formatAnniversary(anniversary),
                    style: AppTextStyles.caption()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.rose.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$daysTogether days together',
                          style: AppTextStyles.small(
                              color: AppColors.rose)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite_rounded,
              color: AppColors.rose, size: 20),
        ],
      ),
    );
  }
}

class _DailySongCard extends StatelessWidget {
  final dynamic song;
  final WidgetRef ref;

  const _DailySongCard({required this.song, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ArtworkTile(
              seed: song.artworkSeed,
              size: 60,
              borderRadius: 12,
              icon: Icons.music_note_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, style: AppTextStyles.bodyMedium()),
                Text(song.artist, style: AppTextStyles.caption()),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(playerProvider.notifier).play(song);
              context.push('/player', extra: song.id);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  color: AppColors.rose, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () =>
                ref.read(favoritesProvider.notifier).toggle(song.id),
            child: const Icon(Icons.favorite_border_rounded,
                color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  final dynamic player;
  final WidgetRef ref;

  const _NowPlayingCard({required this.player, required this.ref});

  @override
  Widget build(BuildContext context) {
    final song = player.currentSong!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkPlayer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          ArtworkTile(
              seed: song.artworkSeed,
              size: 52,
              borderRadius: 10,
              icon: Icons.music_note_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: AppTextStyles.bodyMedium(color: Colors.white)),
                Text(song.artist,
                    style: AppTextStyles.caption(
                        color: Colors.white60)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              player.isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: AppColors.rose,
              size: 36,
            ),
            onPressed: () =>
                ref.read(playerProvider.notifier).togglePlayPause(),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final int seed;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.seed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: artworkGradient(seed),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.small(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
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

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _ActivityItem(
      {required this.icon, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.rose, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppTextStyles.body()),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.small()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.loveGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded,
                  size: 16, color: AppColors.rose),
              const SizedBox(width: 6),
              Text('Today\'s Question',
                  style: AppTextStyles.caption(color: AppColors.rose)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"What song reminds you of our first meeting?"',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.push('/questions'),
            child: Text('Answer now →',
                style: AppTextStyles.caption(color: AppColors.rose)),
          ),
        ],
      ),
    );
  }
}

class _FeatureShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final int seed;
  final VoidCallback onTap;

  const _FeatureShortcut({
    required this.icon,
    required this.label,
    required this.seed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            ArtworkTile(
                seed: seed,
                size: 36,
                borderRadius: 10,
                icon: icon,
                iconSize: 18),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.caption(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
