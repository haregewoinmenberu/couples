import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class ConnectionSuccessScreen extends ConsumerWidget {
  const ConnectionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              // Confetti/check
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              Text("You're Connected!",
                  style: AppTextStyles.h1(), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'You are now part of a shared musical journey together.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      AvatarTile(
                          seed: user.avatarSeed,
                          size: 72,
                          label: user.fullName),
                      const SizedBox(height: 8),
                      Text(user.fullName, style: AppTextStyles.bodyMedium()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.softPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: AppColors.rose, size: 18),
                    ),
                  ),
                  Column(
                    children: [
                      AvatarTile(
                          seed: partner.avatarSeed,
                          size: 72,
                          label: partner.fullName),
                      const SizedBox(height: 8),
                      Text(partner.fullName,
                          style: AppTextStyles.bodyMedium()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anniversary Date',
                              style: AppTextStyles.caption()),
                          Text(
                            'Set your anniversary to track days together.',
                            style: AppTextStyles.body(),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('Set',
                          style:
                              AppTextStyles.bodyMedium(color: AppColors.rose)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue to OurSound',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
