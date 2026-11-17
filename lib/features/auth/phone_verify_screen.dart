import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/device_phone_service.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({super.key});

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _detecting = true;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    final user = ref.read(sessionProvider).currentUser;
    // Prefer the number already saved on the profile; otherwise ask the OS.
    String? number = user?.phoneNumber;
    number ??= await DevicePhoneService.detect();
    if (number != null && number.isNotEmpty) {
      // Show the local part only; keep "+1" as the fixed prefix in the UI.
      final match = RegExp(r'^\+1\s*').firstMatch(number);
      _phoneCtrl.text = match != null ? number.substring(match.end) : number;
      _detected = true;
    }
    if (mounted) setState(() => _detecting = false);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty) return;
    final router = GoRouter.of(context);
    setState(() => _loading = true);

    // The stored number always keeps its country code so both devices match.
    final fullNumber = raw.startsWith('+') ? raw : '+1$raw';
    await DevicePhoneService.cache(fullNumber);

    final user = ref.read(sessionProvider).currentUser;
    if (user != null) {
      ref.read(sessionProvider.notifier).updateProfile(
            user.copyWith(
              phoneNumber: fullNumber,
              countryCode: '+1',
              phoneVerified: true,
            ),
          );
    }
    if (!mounted) return;
    setState(() => _loading = false);
    router.go('/connection/invite');
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
                onTap: () => context.safePop(),
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 32),
              Text('Your Phone Number', style: AppTextStyles.h1()),
              const SizedBox(height: 6),
              Text(
                'We detected the number of this device. Confirm it below — '
                'no code is needed. When your partner installs the app, their '
                'number is checked against your invitation automatically.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
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
                    child: Text('+1', style: AppTextStyles.bodyMedium()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '555 0101',
                        suffixIcon: _detecting
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.rose),
                                ),
                              )
                            : _detected
                                ? const Icon(Icons.phonelink_setup_rounded,
                                    color: AppColors.success, size: 20)
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (_detected) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text('Detected from this device',
                        style: AppTextStyles.caption(
                            color: AppColors.success)),
                  ],
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Save & Continue',
                loading: _loading || _detecting,
                onTap: _detecting ? null : _save,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
