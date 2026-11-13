import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/artwork_generator.dart';
import '../../widgets/common/primary_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  String? _error;

  void _create() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (pw != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.go('/auth/profile');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
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
              _field('Email Address', _emailCtrl,
                  hint: 'sophia@example.com',
                  type: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field('Password', _pwCtrl,
                  hint: '••••••••', obscure: _obscure, onToggleObscure: () {
                setState(() => _obscure = !_obscure);
              }),
              const SizedBox(height: 14),
              _field('Confirm Password', _confirmCtrl,
                  hint: '••••••••', obscure: true),
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
