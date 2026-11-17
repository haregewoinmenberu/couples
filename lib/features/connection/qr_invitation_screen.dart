import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/invitation_generator.dart';
import '../../data/models/invitation.dart';
import '../../state/app_state.dart';

class QRInvitationScreen extends ConsumerStatefulWidget {
  const QRInvitationScreen({super.key});

  @override
  ConsumerState<QRInvitationScreen> createState() =>
      _QRInvitationScreenState();
}

class _QRInvitationScreenState extends ConsumerState<QRInvitationScreen> {
  late final String _code;
  late final Invitation _invitation;

  @override
  void initState() {
    super.initState();
    _code = generateInvitationCode();
    final session = ref.read(sessionProvider);
    _invitation = Invitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      code: _code,
      inviterId: session.currentUser?.id ?? 'unknown',
      method: InvitationMethod.qr,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invitationRegistryProvider.notifier).add(_invitation);
    });
  }

  String get _shareText =>
      'Join me on OurSound! Use invitation code $_code '
      '(oursound://invite/$_code).';

  void _share() {
    Clipboard.setData(ClipboardData(text: _shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation message copied — paste it to your partner!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _invitation.expiresAt.difference(DateTime.now());
    final hoursLeft = remaining.inHours;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.safePop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _share,
                    child: const Icon(Icons.share_outlined, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Your Invitation Code', style: AppTextStyles.h2()),
              const SizedBox(height: 6),
              Text(
                'Show this QR code to your partner or share your code with them.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                ),
                child: QrImageView(
                  data: 'oursound://invite/$_code',
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.textPrimary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _OrLine(),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Code', style: AppTextStyles.caption()),
                          const SizedBox(height: 2),
                          Text(_code,
                              style: AppTextStyles.h3()
                                  .copyWith(letterSpacing: 2)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.softPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.copy_rounded,
                            size: 18, color: AppColors.rose),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This code can only be used by one person. Expires in $hoursLeft hours.',
                      style: AppTextStyles.caption(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share Code'),
                ),
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
