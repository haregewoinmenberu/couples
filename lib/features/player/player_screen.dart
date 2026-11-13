import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_songs.dart';
import '../../state/music_state.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String songId;
  const PlayerScreen({super.key, required this.songId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late String _currentSongId;

  @override
  void initState() {
    super.initState();
    _currentSongId = widget.songId;
    final song = mockSongs.firstWhere((s) => s.id == _currentSongId,
        orElse: () => mockSongs[0]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).play(song, queue: mockSongs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final favorites = ref.watch(favoritesProvider);
    final song = player.currentSong ??
        mockSongs.firstWhere((s) => s.id == _currentSongId,
            orElse: () => mockSongs[0]);

    final progress = song.duration.inSeconds > 0
        ? player.position.inSeconds / song.duration.inSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.darkPlayer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.darkPlayerSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text('Now Playing',
                          style: AppTextStyles.small(
                              color: Colors.white54)),
                      Text('OurSound',
                          style: AppTextStyles.caption(
                              color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showMoreMenu(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.darkPlayerSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.more_horiz_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Artwork
              ArtworkTile(
                seed: song.artworkSeed,
                size: 280,
                borderRadius: 28,
                icon: Icons.music_note_rounded,
                iconSize: 80,
              ),
              const Spacer(),
              // Song info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            style: AppTextStyles.h2(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(song.artist,
                            style: AppTextStyles.body(
                                color: Colors.white60)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(favoritesProvider.notifier).toggle(song.id),
                    child: Icon(
                      favorites.contains(song.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorites.contains(song.id)
                          ? AppColors.rose
                          : Colors.white54,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Progress bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.rose,
                      inactiveTrackColor: AppColors.darkPlayerSecondary,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final pos = Duration(
                            seconds:
                                (v * song.duration.inSeconds).round());
                        ref.read(playerProvider.notifier).seek(pos);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(player.position),
                          style: AppTextStyles.small(
                              color: Colors.white54)),
                      Text(song.durationLabel,
                          style: AppTextStyles.small(
                              color: Colors.white54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CtrlBtn(
                    icon: Icons.shuffle_rounded,
                    active: player.shuffle,
                    onTap: () =>
                        ref.read(playerProvider.notifier).toggleShuffle(),
                  ),
                  _CtrlBtn(
                    icon: Icons.skip_previous_rounded,
                    size: 32,
                    onTap: () =>
                        ref.read(playerProvider.notifier).previous(),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(playerProvider.notifier).togglePlayPause(),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.darkPlayer,
                        size: 36,
                      ),
                    ),
                  ),
                  _CtrlBtn(
                    icon: Icons.skip_next_rounded,
                    size: 32,
                    onTap: () =>
                        ref.read(playerProvider.notifier).next(),
                  ),
                  _CtrlBtn(
                    icon: Icons.repeat_rounded,
                    active: player.repeat,
                    onTap: () =>
                        ref.read(playerProvider.notifier).toggleRepeat(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Couple actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/listen-together'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.darkPlayerSecondary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.headphones_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text('Listen Together',
                                style: AppTextStyles.caption(
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/dedication'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text('Dedicate',
                                style: AppTextStyles.caption(
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showSongConversation(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.darkPlayerSecondary, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          color: Colors.white54, size: 18),
                      const SizedBox(width: 6),
                      Text('Song Conversation',
                          style: AppTextStyles.caption(
                              color: Colors.white54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPlayerSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded,
                  color: Colors.white),
              title: Text('Add to Playlist',
                  style: AppTextStyles.body(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/playlists');
              },
            ),
            ListTile(
              leading: const Icon(Icons.send_rounded, color: Colors.white),
              title: Text('Send to Partner',
                  style: AppTextStyles.body(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                context.push('/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded,
                  color: Colors.white),
              title: Text('View Queue',
                  style: AppTextStyles.body(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSongConversation(BuildContext context) {
    final player = ref.read(playerProvider);
    final song = player.currentSong;
    if (song == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPlayer,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Song Conversation',
                        style: AppTextStyles.h3(color: Colors.white)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('"${song.title}" by ${song.artist}',
                  style: AppTextStyles.caption()),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Text(
                    'Start a conversation about this song.\nWhat does it make you feel?',
                    style: AppTextStyles.body(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool active;
  final VoidCallback onTap;

  const _CtrlBtn({
    required this.icon,
    this.size = 24,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: size,
        color: active ? AppColors.rose : Colors.white54,
      ),
    );
  }
}
