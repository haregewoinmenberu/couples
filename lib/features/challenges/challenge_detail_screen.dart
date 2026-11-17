import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/models/challenge.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../widgets/common/primary_button.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final String challengeId;
  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState
    extends ConsumerState<ChallengeDetailScreen> {
  final _answerCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengesProvider);
    final challenge = challenges.firstWhere(
      (c) => c.id == widget.challengeId,
      orElse: () => challenges.first,
    );
    final session = ref.watch(sessionProvider);
    final me = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;
    final status = challenge.statusFor(me.id, partner.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.safePop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(challenge.title, style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ArtworkTile(
                  seed: challenge.iconSeed,
                  size: 90,
                  borderRadius: 24,
                  icon: Icons.sports_esports_rounded,
                  iconSize: 44),
            ),
            const SizedBox(height: 20),
            Text(challenge.description,
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softLavender,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How to play',
                      style: AppTextStyles.bodyMedium(
                          color: AppColors.lavender)),
                  const SizedBox(height: 6),
                  Text(challenge.instructions,
                      style: AppTextStyles.body(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (status == ChallengeStatus.completed) ...[
              const _CompletedBanner(),
              const SizedBox(height: 20),
              ...challenge.responses.map((r) {
                final isMe = r.userId == me.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMe ? 'Your answer' : '${partner.fullName}\'s answer',
                          style: AppTextStyles.bodyMedium()),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(r.answer,
                            style: AppTextStyles.body(
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                );
              }),
              PrimaryButton(
                label: 'Play Again',
                onTap: () => setState(() => _submitted = false),
              ),
            ] else if (_submitted || status == ChallengeStatus.waitingForPartner) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded,
                        color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Waiting for ${partner.fullName}\'s response...',
                        style: AppTextStyles.body(color: AppColors.rose),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('Your response', style: AppTextStyles.bodyMedium()),
              const SizedBox(height: 8),
              TextField(
                controller: _answerCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your answer...',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Submit Answer',
                onTap: () {
                  if (_answerCtrl.text.trim().isEmpty) return;
                  ref.read(challengesProvider.notifier).respond(
                        challenge.id,
                        ChallengeResponse(
                          userId: me.id,
                          answer: _answerCtrl.text.trim(),
                          respondedAt: DateTime.now(),
                        ),
                      );
                  setState(() => _submitted = true);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Challenge completed! Both of you answered.',
              style: AppTextStyles.body(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
