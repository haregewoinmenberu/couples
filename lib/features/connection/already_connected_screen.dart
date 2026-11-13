import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class AlreadyConnectedScreen extends ConsumerWidget {
  const AlreadyConnectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final partner = session.partner;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              ArtworkTile(
                  seed: 1,
                  size: 90,
                  borderRadius: 28,
                  icon: Icons.people_rounded),
              const SizedBox(height: 24),
              Text('Partner Already Connected',
                  style: AppTextStyles.h2(), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'This code has already been used by another person.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Each invitation code can only be used once to keep your connection private.',
                style: AppTextStyles.caption(),
                textAlign: TextAlign.center,
              ),
              if (partner != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      AvatarTile(
                          seed: partner.avatarSeed,
                          size: 48,
                          label: partner.fullName),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(partner.fullName,
                              style: AppTextStyles.bodyMedium()),
                          Text('Connected partner',
                              style: AppTextStyles.caption()),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.rose, size: 20),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'View Current Partner',
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Go Back',
                onTap: () => context.pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
