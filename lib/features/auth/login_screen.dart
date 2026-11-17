import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final input = _emailCtrl.text.trim();
    if (input.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await ref.read(sessionProvider.notifier).login(input);
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        setState(() => _error = 'No account found. Please create one first.');
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Check your internet and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
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
              Text('Welcome back!', style: AppTextStyles.h1()),
              const SizedBox(height: 6),
              Text('Enter your email or username to sign in',
                  style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 36),
              Text('Email or Username', style: AppTextStyles.caption()),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'you@example.com or @username'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: AppTextStyles.body(color: AppColors.error)),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(label: 'Sign In', loading: _loading, onTap: _login),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/auth/create'),
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style:
                          AppTextStyles.body(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Create Account',
                          style:
                              AppTextStyles.bodyMedium(color: AppColors.rose),
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
}
