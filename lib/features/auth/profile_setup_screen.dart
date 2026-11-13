import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../widgets/common/primary_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.pop(),
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 32),
              Text('Set Up Your Profile', style: AppTextStyles.h1()),
              const SizedBox(height: 6),
              Text('This is how your partner will see you.',
                  style:
                      AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              Center(
                child: Stack(
                  children: [
                    AvatarTile(seed: 'profile', size: 90),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppColors.rose, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Username', style: AppTextStyles.caption()),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  hintText: '@your_name',
                  prefixText: '@',
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Continue',
                loading: _loading,
                onTap: () async {
                  setState(() => _loading = true);
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (mounted) context.go('/auth/phone-verify');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
