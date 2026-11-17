import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _avatarSeed;

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img == null || !mounted) return;
    setState(() => _avatarSeed = img.name.hashCode.toString());
  }

  void _continue() async {
    final username = _usernameCtrl.text.trim().replaceAll('@', '');
    if (username.isEmpty) {
      setState(() => _error = 'Please choose a username.');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    final user = ref.read(sessionProvider).currentUser;
    if (user != null) {
      ref.read(sessionProvider.notifier).updateProfile(
            user.copyWith(
              username: username,
              avatarSeed: _avatarSeed ?? user.avatarSeed,
            ),
          );
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) context.go('/auth/phone-verify');
  }

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
                onTap: () => context.safePop(),
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
                    AvatarTile(seed: _avatarSeed ?? 'profile', size: 90),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: AppColors.rose, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 15),
                        ),
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
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: AppTextStyles.caption(color: AppColors.error)),
              ],
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Continue',
                loading: _loading,
                onTap: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
