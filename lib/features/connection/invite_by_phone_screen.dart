import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/invitation_generator.dart';
import '../../data/models/invitation.dart';
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
  String _country = '+1';
  bool _loading = false;
  bool _sent = false;
  String? _sentCode;

  final _countries = const ['+1', '+44', '+251', '+49', '+33', '+81', '+86'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _sendInvitation() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final code = generateInvitationCode();
    final session = ref.read(sessionProvider);
    final inv = Invitation(
      id: 'inv_phone_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      inviterId: session.currentUser?.id ?? '',
      method: InvitationMethod.phone,
      inviteePhone: '$_country ${_phoneCtrl.text.trim()}',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    ref.read(invitationRegistryProvider.notifier).add(inv);

    setState(() {
      _loading = false;
      _sent = true;
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
                child:
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(height: 28),
              Text('Invite by Phone Number', style: AppTextStyles.h2()),
              const SizedBox(height: 6),
              Text('Send invitation via phone number',
                  style: AppTextStyles.body(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              if (!_sent) ...[
                Text('Country', style: AppTextStyles.caption()),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    value: _country,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _countries
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: AppTextStyles.body())))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _country = v ?? _country),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Phone Number', style: AppTextStyles.caption()),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(hintText: '555 0101'),
                ),
                const SizedBox(height: 10),
                Text(
                  'An invitation with a secure link will be sent to this number.',
                  style: AppTextStyles.caption(),
                ),
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
                    borderRadius:
                        BorderRadius.circular(AppRadius.lg),
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
                        'An invitation was sent to $_country ${_phoneCtrl.text}.',
                        style: AppTextStyles.body(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text('Invitation Code',
                          style: AppTextStyles.caption()),
                      Text(_sentCode ?? '',
                          style: AppTextStyles.h3()
                              .copyWith(letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text('Expires in 24 hours.',
                          style: AppTextStyles.small()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _sent = false),
                        child: const Text('Resend'),
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
