import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text('OurSound', style: AppTextStyles.h1()),
              const SizedBox(height: 8),
              Text(
                'Welcome back!',
                style: AppTextStyles.h2(),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your journey',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue with Email',
                icon: Icons.email_outlined,
                onTap: () => context.go('/auth/login'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 20),
              const _OrDivider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text('Login',
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: () => context.go('/auth/create'),
                    child: Text('Create Account',
                        style:
                            AppTextStyles.bodyMedium(color: AppColors.rose)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: AppTextStyles.small(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: AppTextStyles.caption()),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
