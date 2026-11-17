import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim().replaceAll('@', '');
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || username.isEmpty || phone.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _error = null; _loading = true; });
    try {
      await ref.read(sessionProvider.notifier).register(
        fullName: name,
        username: username,
        email: email,
        phoneNumber: phone,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString().contains('Unique')
          ? 'Email or username already taken.'
          : 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 32),
              Text('Create Account', style: AppTextStyles.h1()),
              const SizedBox(height: 6),
              Text('Join OurSound today',
                  style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              Center(
                child: Stack(
                  children: [
                    AvatarTile(seed: 'new', size: 80),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                            color: AppColors.rose, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _field('Full Name', _nameCtrl, hint: 'Sophia'),
              const SizedBox(height: 14),
              _field('Username', _usernameCtrl, hint: 'sophiachen'),
              const SizedBox(height: 14),
              _field('Email Address', _emailCtrl,
                  hint: 'sophia@example.com',
                  type: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field('Phone Number', _phoneCtrl,
                  hint: '+1 555 0100',
                  type: TextInputType.phone),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: AppTextStyles.caption(color: AppColors.error)),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                  label: 'Create Account',
                  loading: _loading,
                  onTap: _create),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.body(
                          color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: AppTextStyles.bodyMedium(
                              color: AppColors.rose),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    TextInputType? type,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: const Icon(Icons.visibility_outlined,
                        size: 20, color: AppColors.textSecondary),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
