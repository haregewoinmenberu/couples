import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_people.dart';
import '../../data/mock/mock_songs.dart';
import '../../state/app_state.dart';
import '../../state/music_state.dart';

class ListenTogetherScreen extends ConsumerStatefulWidget {
  const ListenTogetherScreen({super.key});

  @override
  ConsumerState<ListenTogetherScreen> createState() =>
      _ListenTogetherScreenState();
}

class _ListenTogetherScreenState extends ConsumerState<ListenTogetherScreen> {
  final Map<String, int> _reactionCounts = {};
  String? _lastReaction;

  void _react(String emoji) {
    setState(() {
      _reactionCounts[emoji] = (_reactionCounts[emoji] ?? 0) + 1;
      _lastReaction = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final player = ref.watch(playerProvider);
    final me = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;
    final song = player.currentSong ?? mockSongs[0];

    final progress = song.duration.inSeconds > 0
        ? player.position.inSeconds / song.duration.inSeconds
        : 0.2;

    return Scaffold(
      backgroundColor: AppColors.darkPlayer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
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
                  Text('Listen Together',
                      style: AppTextStyles.h3(color: Colors.white)),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 28),
              // Both avatars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      AvatarTile(
                          seed: me.avatarSeed, size: 60, label: me.fullName),
                      const SizedBox(height: 6),
                      Text(me.fullName,
                          style: AppTextStyles.caption(color: Colors.white70)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(Icons.headphones_rounded,
                            color: AppColors.rose, size: 28),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Connected',
                              style: AppTextStyles.small(
                                  color: AppColors.success)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      AvatarTile(
                          seed: partner.avatarSeed,
                          size: 60,
                          label: partner.fullName),
                      const SizedBox(height: 6),
                      Text(partner.fullName,
                          style:
                              AppTextStyles.caption(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Artwork
              ArtworkTile(
                seed: song.artworkSeed,
                size: 220,
                borderRadius: 24,
                icon: Icons.music_note_rounded,
                iconSize: 60,
              ),
              const SizedBox(height: 20),
              Text(song.title,
                  style: AppTextStyles.h2(color: Colors.white),
                  textAlign: TextAlign.center),
              Text(song.artist,
                  style: AppTextStyles.body(color: Colors.white60)),
              const SizedBox(height: 20),
              // Shared progress
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.rose,
                      inactiveTrackColor: AppColors.darkPlayerSecondary,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final pos = Duration(
                            seconds: (v * song.duration.inSeconds).round());
                        ref.read(playerProvider.notifier).seek(pos);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(player.position),
                          style: AppTextStyles.small(color: Colors.white54)),
                      Text(song.durationLabel,
                          style: AppTextStyles.small(color: Colors.white54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white54, size: 28),
                    onPressed: () =>
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
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white54, size: 28),
                    onPressed: () =>
                        ref.read(playerProvider.notifier).next(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Queue & reactions
              if (_lastReaction != null) ...[
                Text('You sent $_lastReaction',
                    style: AppTextStyles.caption(color: Colors.white54)),
                const SizedBox(height: 6),
              ],
              Row(
                children: ['❤️', '🔥', '😍', '🎵', '👏'].map((e) {
                  final count = _reactionCounts[e] ?? 0;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _react(e),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e, style: const TextStyle(fontSize: 22)),
                          if (count > 0)
                            Text('$count',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
