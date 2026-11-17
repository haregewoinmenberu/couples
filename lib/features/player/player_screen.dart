import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_songs.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/playlist.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart'
    show songsProvider, chatProvider, playlistsProvider;
import '../../state/music_state.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String songId;
  const PlayerScreen({super.key, required this.songId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late String _currentSongId;
  final _conversationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSongId = widget.songId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final all = ref.read(songsProvider).valueOrNull ?? mockSongs;
      final queue = all.isNotEmpty ? all : mockSongs;
      final song = queue.firstWhere((s) => s.id == _currentSongId,
          orElse: () => queue.first);
      // Keep an existing queue if this song is already loaded, so switching
      // songs from a playlist doesn't reset playback order.
      final current = ref.read(playerProvider);
      if (current.currentSong?.id == song.id && current.queue.isNotEmpty) {
        return;
      }
      ref.read(playerProvider.notifier).play(song, queue: queue.cast());
    });
  }

  @override
  void dispose() {
    _conversationCtrl.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.safePop(),
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
              const SizedBox(height: 20),
              // Artwork / embedded YouTube video
              if (song.isYouTube)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: song.youtubeId!,
                      flags: const YoutubePlayerFlags(
                        autoPlay: true,
                        mute: false,
                        controlsVisibleAtStart: true,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.rose,
                  ),
                )
              else
                ArtworkTile(
                  seed: song.artworkSeed,
                  size: 280,
                  borderRadius: 28,
                  icon: Icons.music_note_rounded,
                  iconSize: 80,
                ),
              const SizedBox(height: 20),
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
                _showAddToPlaylist(context);
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
              onTap: () {
                Navigator.pop(context);
                _showQueue(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylist(BuildContext context) {
    final song = ref.read(playerProvider).currentSong;
    if (song == null) return;
    final session = ref.read(sessionProvider);
    final playlists = ref.read(playlistsProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPlayerSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add "${song.title}" to...',
                style: AppTextStyles.h3(color: Colors.white)),
            const SizedBox(height: 12),
            if (playlists.isEmpty)
              Text('No playlists yet. Create one from the Playlists tab.',
                  style: AppTextStyles.body(color: Colors.white54))
            else
              ...playlists.map((pl) => ListTile(
                    leading: const Icon(Icons.playlist_play_rounded,
                        color: Colors.white),
                    title: Text(pl.title,
                        style: AppTextStyles.body(color: Colors.white)),
                    subtitle: Text('${pl.songs.length} songs',
                        style: AppTextStyles.caption(color: Colors.white54)),
                    onTap: () {
                      if (pl.songs.any((e) => e.songId == song.id)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already in playlist')),
                        );
                        return;
                      }
                      ref.read(playlistsProvider.notifier).addSong(
                            pl.id,
                            PlaylistSongEntry(
                              songId: song.id,
                              addedByUserId: session.currentUser?.id ?? '',
                              addedAt: DateTime.now(),
                            ),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to ${pl.title}')),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }

  void _showQueue(BuildContext context) {
    final queue = ref.read(playerProvider).queue;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPlayerSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Up Next', style: AppTextStyles.h3(color: Colors.white)),
            const SizedBox(height: 12),
            if (queue.isEmpty)
              Text('The queue is empty.',
                  style: AppTextStyles.body(color: Colors.white54))
            else
              ...queue.asMap().entries.map((e) {
                final s = e.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('${e.key + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(s.title,
                      style: AppTextStyles.body(color: Colors.white)),
                  subtitle: Text(s.artist,
                      style: AppTextStyles.caption(color: Colors.white54)),
                  onTap: () {
                    ref.read(playerProvider.notifier).play(s, queue: queue);
                    Navigator.pop(context);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showSongConversation(BuildContext context) {
    final player = ref.read(playerProvider);
    final song = player.currentSong;
    if (song == null) return;
    _conversationCtrl.clear();
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _conversationCtrl,
                      style: AppTextStyles.body(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Say something about this song...',
                        hintStyle:
                            AppTextStyles.body(color: Colors.white38),
                        filled: true,
                        fillColor: AppColors.darkPlayerSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () {
                      final text = _conversationCtrl.text.trim();
                      if (text.isEmpty) return;
                      final session = ref.read(sessionProvider);
                      ref.read(chatProvider.notifier).send(
                            ChatMessage(
                              id: 'msg_song_${DateTime.now().millisecondsSinceEpoch}',
                              senderId: session.currentUser?.id ?? '',
                              type: MessageType.song,
                              songId: song.id,
                              text: text,
                              sentAt: DateTime.now(),
                            ),
                            coupleId: session.couple?.id,
                          );
                      _conversationCtrl.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sent to your partner')),
                      );
                    },
                  ),
                ],
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
