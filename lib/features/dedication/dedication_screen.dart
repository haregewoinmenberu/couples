import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_songs.dart';
import '../../data/mock/mock_people.dart';
import '../../data/models/dedication.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common/primary_button.dart';

class DedicationScreen extends ConsumerStatefulWidget {
  const DedicationScreen({super.key});

  @override
  ConsumerState<DedicationScreen> createState() => _DedicationScreenState();
}

class _DedicationScreenState extends ConsumerState<DedicationScreen> {
  int _step = 0;
  String? _selectedSongId;
  DedicationType? _selectedType;
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_selectedSongId == null || _selectedType == null) return;
    final session = ref.read(sessionProvider);
    final dedication = Dedication(
      id: 'ded_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: session.currentUser?.id ?? alexId,
      songId: _selectedSongId!,
      type: _selectedType!,
      message: _msgCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    ref.read(dedicationsProvider.notifier).add(dedication);
    try {
      await ApiService.createDedication(
        fromUserId: dedication.fromUserId,
        songId: dedication.songId,
        coupleId: session.couple?.id,
        type: dedication.type.name,
        message: dedication.message,
      );
    } catch (_) {
      // Dedication is still saved locally and shown to the partner in-app.
    }
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Music Dedication', style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: _sent ? _buildSent(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Row(
          children: List.generate(4, (i) {
            final done = i < _step;
            final current = i == _step;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 4,
                decoration: BoxDecoration(
                  color: done || current ? AppColors.rose : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        if (_step == 0) ...[
          Text('Step 1: Select a song', style: AppTextStyles.h3()),
          const SizedBox(height: 14),
          ...mockSongs.take(8).map((s) {
            final sel = _selectedSongId == s.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedSongId = s.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.softPink : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: sel ? AppColors.rose : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
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
                    if (sel)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.rose, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Next',
            onTap: _selectedSongId != null
                ? () => setState(() => _step = 1)
                : null,
          ),
        ] else if (_step == 1) ...[
          Text('Step 2: Dedication type', style: AppTextStyles.h3()),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: DedicationType.values.map((t) {
              final sel = _selectedType == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        sel ? AppColors.rose : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(t.label,
                      style: AppTextStyles.body(
                          color: sel ? Colors.white : AppColors.textPrimary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 0),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedType != null
                      ? () => setState(() => _step = 2)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ] else if (_step == 2) ...[
          Text('Step 3: Write a message', style: AppTextStyles.h3()),
          const SizedBox(height: 14),
          TextField(
            controller: _msgCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'What do you want to say with this song?',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 3),
                  child: const Text('Preview'),
                ),
              ),
            ],
          ),
        ] else ...[
          Text('Step 4: Preview', style: AppTextStyles.h3()),
          const SizedBox(height: 14),
          Builder(builder: (_) {
            final song = mockSongs.firstWhere(
              (s) => s.id == _selectedSongId,
              orElse: () => mockSongs.first,
            );
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedType?.label ?? '',
                      style: AppTextStyles.caption(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ArtworkTile(
                          seed: song.artworkSeed,
                          size: 56,
                          borderRadius: 12,
                          icon: Icons.music_note_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.title,
                                style: AppTextStyles.bodyMedium(
                                    color: Colors.white)),
                            Text(song.artist,
                                style:
                                    AppTextStyles.caption(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_msgCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_msgCtrl.text,
                        style: AppTextStyles.body(color: Colors.white)),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _send(),
                  child: const Text('Send ❤️'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
              color: AppColors.rose, shape: BoxShape.circle),
          child:
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 20),
        Text('Dedication Sent! ❤️',
            style: AppTextStyles.h2(), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          'Your partner will receive your music dedication.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
