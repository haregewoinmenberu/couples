import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_moods.dart';
import '../../data/mock/mock_people.dart';
import '../../data/models/mood_entry.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../widgets/common/primary_button.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  String? _selected;
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_selected == null) return;
    final session = ref.read(sessionProvider);
    ref.read(moodsProvider.notifier).add(MoodEntry(
          id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
          userId: session.currentUser?.id ?? alexId,
          mood: _selected!,
          message: _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
          createdAt: DateTime.now(),
        ));
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final partner = session.partner ?? mockSophia;
    final partnerMood =
        ref.watch(moodsProvider.notifier).latestFor(partner.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Mood Sharing', style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (partnerMood != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.loveGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('💭',
                        style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${partner.fullName}\'s mood',
                              style: AppTextStyles.caption()),
                          Text(partnerMood.mood,
                              style: AppTextStyles.bodyMedium()),
                          if (partnerMood.message != null)
                            Text(partnerMood.message!,
                                style: AppTextStyles.body(
                                    color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_sent) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.rose, size: 44),
                    const SizedBox(height: 10),
                    Text('Mood shared!',
                        style: AppTextStyles.h3(),
                        textAlign: TextAlign.center),
                    Text(
                      '${partner.fullName} will see your mood.',
                      style: AppTextStyles.body(
                          color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SecondaryButton(
                label: 'Share Another',
                onTap: () => setState(() {
                  _sent = false;
                  _selected = null;
                  _msgCtrl.clear();
                }),
              ),
            ] else ...[
              Text('How are you feeling?', style: AppTextStyles.h3()),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: moodOptions.map((m) {
                  final sel = _selected == m.label;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = m.label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.rose
                            : AppColors.backgroundSecondary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                        border: sel
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(m.label,
                              style: AppTextStyles.body(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Add a message (optional)',
                  style: AppTextStyles.caption()),
              const SizedBox(height: 6),
              TextField(
                controller: _msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tell your partner how you feel...',
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Share Mood',
                onTap: _selected != null ? _send : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
