import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class InviteMethodScreen extends ConsumerWidget {
  const InviteMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session.isConnected) {
      return const AlreadyConnectedInline();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.safePop(),
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 28),
              ArtworkTile(
                  seed: 0, size: 60, borderRadius: 16, icon: Icons.qr_code_rounded),
              const SizedBox(height: 20),
              Text('Create your shared world', style: AppTextStyles.h1()),
              const SizedBox(height: 8),
              Text(
                'Invite your partner to connect with you through music.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _MethodTile(
                icon: Icons.qr_code_2_rounded,
                title: 'Share Invitation Code',
                subtitle: 'Show QR code to your partner',
                onTap: () => context.push('/connection/invite/qr'),
              ),
              const SizedBox(height: 12),
              _MethodTile(
                icon: Icons.smartphone_rounded,
                title: 'Invite by Phone Number',
                subtitle: 'We match their device number automatically',
                onTap: () => context.push('/connection/invite/phone'),
              ),
              const Spacer(),
              SecondaryButton(
                label: 'Join a Partner Instead',
                onTap: () => context.push('/connection/join'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MethodTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.rose, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.rose, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium()),
                  Text(subtitle,
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class AlreadyConnectedInline extends StatelessWidget {
  const AlreadyConnectedInline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArtworkTile(
                  seed: 1,
                  size: 80,
                  borderRadius: 24,
                  icon: Icons.people_rounded),
              const SizedBox(height: 24),
              Text('Already Connected',
                  style: AppTextStyles.h2(), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'You already have a partner connected to your OurSound account.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'View Current Partner',
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Manage Relationship',
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
