import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';

class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  State<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  final _phoneCtrl = TextEditingController();
  String _country = '+1';
  bool _loading = false;

  final _countries = const ['+1', '+44', '+251', '+49', '+33', '+81', '+86'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
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
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.pop(),
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 32),
              Text('Verify Your Number', style: AppTextStyles.h1()),
              const SizedBox(height: 6),
              Text('We\'ll send a one-time code to verify your phone.',
                  style:
                      AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 36),
              Text('Phone Number', style: AppTextStyles.caption()),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButton<String>(
                      value: _country,
                      underline: const SizedBox(),
                      isDense: true,
                      items: _countries
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: AppTextStyles.body())))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _country = v ?? _country),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          hintText: '555 0101'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Send Code',
                loading: _loading,
                onTap: () async {
                  if (_phoneCtrl.text.isEmpty) return;
                  setState(() => _loading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (!mounted) return;
                  setState(() => _loading = false);
                  final phone = '$_country ${_phoneCtrl.text}';
                  context.push('/connection/otp', extra: phone);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
