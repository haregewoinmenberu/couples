import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../data/mock/mock_playlists.dart';
import '../../data/mock/mock_songs.dart';
import '../../data/models/song.dart';
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
    final questions = ref.watch(questionsProvider);
    final songsAsync = ref.watch(songsProvider);
    final unread = notifications.where((n) => !n.isRead).length;

    final user = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;
    final couple = session.couple ?? mockCouple;
    final allSongs = songsAsync.valueOrNull ?? mockSongs;
    final dailySong = allSongs.isNotEmpty ? allSongs.first : mockSongs.first;
    final todayQuestion = questions.isNotEmpty ? questions.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header with gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      // Top bar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('OurSound',
                                    style: AppTextStyles.h2(
                                        color: AppColors.primary)),
                                Text('A shared musical world for two.',
                                    style: AppTextStyles.small(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined,
                                    color: AppColors.textPrimary),
                                onPressed: () =>
                                    context.push('/notifications'),
                              ),
                              if (unread > 0)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: AvatarTile(
                                seed: user.avatarSeed,
                                size: 38,
                                label: user.fullName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Couple hero card
                      _HeroCoupleCard(
                        user: user,
                        partner: partner,
                        daysTogether: couple.daysTogether,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _QuickAction(
                      icon: Icons.music_note_rounded,
                      label: 'Send\na Song',
                      seed: 0,
                      onTap: () => context.push('/music'),
                    ),
                    _QuickAction(
                      icon: Icons.photo_camera_rounded,
                      label: 'Share\nPhoto',
                      seed: 2,
                      onTap: () => context.push('/chat'),
                    ),
                    _QuickAction(
                      icon: Icons.playlist_add_rounded,
                      label: 'Create\nPlaylist',
                      seed: 4,
                      onTap: () => context.push('/playlists'),
                    ),
                    _QuickAction(
                      icon: Icons.favorite_rounded,
                      label: 'Add\nMemory',
                      seed: 6,
                      onTap: () => context.push('/memories/add'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Now playing together
                if (player.hasTrack) ...[
                  _SectionHeader(title: 'Now playing together'),
                  const SizedBox(height: 10),
                  _NowPlayingCard(player: player, ref: ref),
                  const SizedBox(height: 20),
                ],

                // Today's song
                _SectionHeader(
                    title: "Today's song for us",
                    action: 'See all',
                    onAction: () => context.push('/music')),
                const SizedBox(height: 10),
                _DailySongCard(song: dailySong, ref: ref, queue: allSongs),
                const SizedBox(height: 24),

                // Shared playlists
                _SectionHeader(
                    title: 'Shared playlists',
                    action: 'See all',
                    onAction: () => context.push('/playlists')),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockPlaylists.length.clamp(0, 5),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final pl = mockPlaylists[i];
                      return GestureDetector(
                        onTap: () => context.push('/playlists/${pl.id}'),
                        child: SizedBox(
                          width: 108,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ArtworkTile(
                                    seed: pl.coverSeed,
                                    size: 90,
                                    borderRadius: 16,
                                    icon: Icons.playlist_play_rounded,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 18),
                                    ),
                                  ),
                                ],
                              ),
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
                const SizedBox(height: 24),

                // Daily question
                _DailyQuestionCard(
                    prompt: todayQuestion?.prompt ??
                        'What song reminds you of our first meeting?'),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

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

class _HeroCoupleCard extends StatelessWidget {
  final dynamic user;
  final dynamic partner;
  final int daysTogether;

  const _HeroCoupleCard({
    required this.user,
    required this.partner,
    required this.daysTogether,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarCircle(seed: user.avatarSeed, name: user.fullName, size: 70),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.primary, size: 28),
              ),
              _AvatarCircle(
                  seed: partner.avatarSeed, name: partner.fullName, size: 70),
            ],
          ),
          const SizedBox(height: 14),
          Text('${user.fullName} & ${partner.fullName}',
              style: AppTextStyles.h3()),
          const SizedBox(height: 4),
          Text('Our private space · Just the two of us ♡',
              style: AppTextStyles.small(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Together for $daysTogether days',
                    style: AppTextStyles.bodyMedium(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String seed;
  final String name;
  final double size;

  const _AvatarCircle(
      {required this.seed, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: artworkGradient(seed.codeUnits.fold(0, (a, b) => a + b) % 8),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DailySongCard extends StatelessWidget {
  final dynamic song;
  final WidgetRef ref;
  final List<Song> queue;

  const _DailySongCard(
      {required this.song, required this.ref, required this.queue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).play(song, queue: queue);
        context.push('/player', extra: song.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: AppTextStyles.bodyMedium(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(song.artist,
                      style: AppTextStyles.caption(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('Sometimes, a song says what words cannot. ♡',
                      style: AppTextStyles.small(color: Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.primary, size: 26),
            ),
          ],
        ),
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
    final progress = song.duration.inSeconds > 0
        ? player.position.inSeconds / song.duration.inSeconds
        : 0.0;
    return GestureDetector(
      onTap: () => context.push('/player', extra: song.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkPlayer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Row(
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
                          style: AppTextStyles.bodyMedium(
                              color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(song.artist,
                          style:
                              AppTextStyles.caption(color: Colors.white60)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: AppColors.accent,
                    size: 38,
                  ),
                  onPressed: () =>
                      ref.read(playerProvider.notifier).togglePlayPause(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppColors.darkPlayerSecondary,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 3,
              ),
            ),
          ],
        ),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: artworkGradient(seed),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: AppTextStyles.small(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
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
        Expanded(
            child: Text(title,
                style: AppTextStyles.h3(color: AppColors.textPrimary))),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: AppTextStyles.caption(color: AppColors.primary)),
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
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
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
  final String prompt;
  const _DailyQuestionCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Today\'s Question',
                  style: AppTextStyles.caption(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Text('"$prompt"', style: AppTextStyles.bodyMedium()),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/questions'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Answer now →',
                  style: AppTextStyles.caption(color: Colors.white)),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ArtworkTile(
                seed: seed,
                size: 36,
                borderRadius: 10,
                icon: icon,
                iconSize: 18),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.caption(
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
