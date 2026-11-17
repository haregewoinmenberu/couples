import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/invitation_generator.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';
import 'connection_payload.dart';

class JoinPartnerScreen extends ConsumerStatefulWidget {
  const JoinPartnerScreen({super.key});

  @override
  ConsumerState<JoinPartnerScreen> createState() => _JoinPartnerScreenState();
}

class _JoinPartnerScreenState extends ConsumerState<JoinPartnerScreen> {
  final _codeCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  void _joinWithCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Please enter an invitation code.');
      return;
    }
    if (!isValidCodeFormat(code)) {
      setState(() =>
          _error = 'Invalid format. Expected e.g. OS-7F3K-9M2Q');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final session = ref.read(sessionProvider);
    final redeemed = ref.read(invitationRegistryProvider.notifier).redeem(
          code: code,
          redeemingUserId: session.currentUser?.id ?? '',
          redeemerAlreadyConnected: session.isConnected,
        );

    setState(() => _loading = false);

    if (redeemed == null) {
      setState(() =>
          _error = 'This code is invalid, expired, or has already been used.');
      return;
    }

    // Both partners use the same device, so no phone/OTP verification is
    // needed — connect straight away using the redeemed inviter.
    if (!mounted) return;
    context.go(
      '/connection/success',
      extra: ConnectionPayload(inviterId: redeemed.inviterId),
    );
  }

  void _scanQr() async {
    // This build has no camera scanner dependency; accept a code pasted from
    // the clipboard (the QR payload is `oursound://invite/<code>`).
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    String? code = data?.text?.trim();
    if (code != null) {
      final uri = Uri.tryParse(code);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        code = uri.pathSegments.last;
      }
    }
    if (!mounted) return;
    if (code == null || code.isEmpty || !isValidCodeFormat(code)) {
      setState(() => _error =
          'No invitation code found on the clipboard. Copy your partner\'s code and try again.');
      return;
    }
    _codeCtrl.text = code.toUpperCase();
    _joinWithCode();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.safePop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Join Your Partner', style: AppTextStyles.h2()),
              const SizedBox(height: 6),
              Text(
                'Scan your partner\'s QR code or enter their invitation code.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Mock QR scanner area
              GestureDetector(
                onTap: _scanQr,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: artworkGradient(5),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 60),
                      const SizedBox(height: 10),
                      Text('Tap to Scan QR Code',
                          style: AppTextStyles.bodyMedium(
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _OrLine(),
              const SizedBox(height: 20),
              Text('Enter Invitation Code', style: AppTextStyles.bodyMedium()),
              const SizedBox(height: 8),
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'e.g. OS-7F3K-9M2Q',
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style:
                        AppTextStyles.caption(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Join Couple',
                loading: _loading,
                onTap: _joinWithCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrLine extends StatelessWidget {
  const _OrLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: AppTextStyles.caption()),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
