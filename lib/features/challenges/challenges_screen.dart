import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/models/challenge.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);
    final session = ref.watch(sessionProvider);
    final me = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.safePop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Couple Challenges', style: AppTextStyles.h3()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final c = challenges[i];
          final status = c.statusFor(me.id, partner.id);
          return GestureDetector(
            onTap: () => context.push('/challenges/${c.id}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: status == ChallengeStatus.completed
                      ? AppColors.success.withOpacity(0.4)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  ArtworkTile(
                      seed: c.iconSeed,
                      size: 52,
                      borderRadius: 14,
                      icon: Icons.sports_esports_rounded),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: AppTextStyles.bodyMedium()),
                        const SizedBox(height: 2),
                        Text(c.description,
                            style: AppTextStyles.body(
                                color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        _StatusChip(status: status),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ChallengeStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ChallengeStatus.completed => ('Completed ✓', AppColors.success),
      ChallengeStatus.waitingForPartner =>
        ('Waiting for partner', AppColors.warning),
      ChallengeStatus.notStarted => ('Play', AppColors.rose),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.small(color: color)),
    );
  }
}
