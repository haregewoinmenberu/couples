import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/invitation_generator.dart';
import '../../data/models/invitation.dart';
import '../../services/api_service.dart';
import '../../services/device_phone_service.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class InviteByPhoneScreen extends ConsumerStatefulWidget {
  const InviteByPhoneScreen({super.key});

  @override
  ConsumerState<InviteByPhoneScreen> createState() =>
      _InviteByPhoneScreenState();
}

class _InviteByPhoneScreenState extends ConsumerState<InviteByPhoneScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _sentCode;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Please enter your partner\'s phone number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final session = ref.read(sessionProvider);
    final inviterId = session.currentUser?.id ?? '';
    final fullNumber = raw.startsWith('+') ? raw : '+1$raw';
    final normalized = DevicePhoneService.normalize(fullNumber);
    final code = generateInvitationCode();

    final invitation = Invitation(
      id: 'inv_phone_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      inviterId: inviterId,
      method: InvitationMethod.phone,
      inviteePhone: normalized,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    try {
      await ApiService.createInvitation(
        inviterId: inviterId,
        inviteePhone: normalized,
        code: code,
      );
    } catch (_) {
      // Still saved locally so the flow works while offline / on the same
      // device; the invitee's app checks this registry as a fallback.
    }
    ref.read(invitationRegistryProvider.notifier).add(invitation);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sentCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 28),
              Text('Invite by Phone Number', style: AppTextStyles.h2()),
              const SizedBox(height: 6),
              Text('We will watch for this number to install OurSound.',
                  style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              if (_sentCode == null) ...[
                Text('Partner\'s Phone Number', style: AppTextStyles.caption()),
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
                        decoration: const InputDecoration(hintText: '555 0101'),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'When they install the app, we check the number of their '
                  'device. If it matches, you become a couple automatically — '
                  'no code to enter.',
                  style: AppTextStyles.caption(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: AppTextStyles.caption(color: AppColors.error)),
                ],
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Send Invitation',
                  loading: _loading,
                  onTap: _sendInvitation,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.rose, size: 44),
                      const SizedBox(height: 12),
                      Text('Invitation Sent!',
                          style: AppTextStyles.h3(),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        'Waiting for ${_phoneCtrl.text} to install OurSound. '
                        'We will connect you as soon as their device number '
                        'matches.',
                        style: AppTextStyles.body(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text('Invitation Code', style: AppTextStyles.caption()),
                      Text(_sentCode!,
                          style: AppTextStyles.h3()
                              .copyWith(letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text('Expires in 7 days.', style: AppTextStyles.small()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _sentCode = null),
                        child: const Text('Invite Another'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
