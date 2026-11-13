import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/primary_button.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String phone;
  const OTPVerifyScreen({super.key, required this.phone});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final List<TextEditingController> _digits =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  String get _otp => _digits.map((c) => c.text).join();

  void _verify() async {
    if (_otp.length < 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    // Mock: any 6-digit code is valid
    if (_otp == '000000') {
      setState(() {
        _loading = false;
        _error = 'Incorrect code. Please try again.';
      });
      return;
    }
    setState(() => _loading = false);
    context.go('/connection/success');
  }

  @override
  void dispose() {
    for (final c in _digits) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 32),
              Text('Verify Your Number', style: AppTextStyles.h1()),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Enter the 6-digit code sent to ',
                  style:
                      AppTextStyles.body(color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: widget.phone,
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(Hint: enter any code except 000000 to simulate success)',
                style: AppTextStyles.small(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _digits[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.backgroundSecondary,
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: _digits[i].text.isNotEmpty
                                ? AppColors.rose
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                              color: AppColors.rose, width: 1.5),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {});
                        if (v.isNotEmpty && i < 5) {
                          _nodes[i + 1].requestFocus();
                        }
                        if (v.isEmpty && i > 0) {
                          _nodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style:
                        AppTextStyles.caption(color: AppColors.error)),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Verify',
                loading: _loading,
                onTap: _verify,
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text('Resend Code',
                      style: AppTextStyles.bodyMedium(
                          color: AppColors.rose)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
