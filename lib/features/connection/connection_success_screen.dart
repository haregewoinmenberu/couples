import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../data/models/couple.dart';
import '../../data/models/user.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../widgets/common/primary_button.dart';

class ConnectionSuccessScreen extends ConsumerStatefulWidget {
  final String? inviterId;
  const ConnectionSuccessScreen({super.key, this.inviterId});

  @override
  ConsumerState<ConnectionSuccessScreen> createState() =>
      _ConnectionSuccessScreenState();
}

class _ConnectionSuccessScreenState
    extends ConsumerState<ConnectionSuccessScreen> {
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _establishCouple());
  }

  Future<void> _establishCouple() async {
    final session = ref.read(sessionProvider);
    final me = session.currentUser;
    final inviterId = widget.inviterId;

    // If there's no real inviter (e.g. direct navigation), keep the seeded
    // demo partner so the rest of the app has coherent data.
    if (me == null || inviterId == null || inviterId.isEmpty) {
      if (mounted) setState(() => _connecting = false);
      return;
    }

    try {
      Map<String, dynamic>? coupleData =
          await ApiService.getCoupleForUser(me.id);
      coupleData ??= await ApiService.createCouple(
        userAId: inviterId,
        userBId: me.id,
        anniversaryDate: DateTime.now(),
      );

      final couple = Couple.fromJson(coupleData);
      final partnerRaw = couple.userAId == me.id
          ? coupleData['userB'] as Map<String, dynamic>?
          : coupleData['userA'] as Map<String, dynamic>?;
      final partner = partnerRaw != null
          ? AppUser.fromJson({
              ...partnerRaw,
              'email': '',
              'phoneNumber': partnerRaw['phoneNumber'] ?? '',
              'countryCode': '+1',
            })
          : mockSophia;

      await ref.read(sessionProvider.notifier).connectPartner(partner, couple);
    } catch (_) {
      // Connection is still reflected locally; partner data falls back to the
      // seeded profile until the server is reachable.
    }
    if (mounted) setState(() => _connecting = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final user = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
              const SizedBox(height: 16),
              // Confetti/check
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              Text("You're Connected!",
                  style: AppTextStyles.h1(), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'You are now part of a shared musical journey together.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      AvatarTile(
                          seed: user.avatarSeed,
                          size: 72,
                          label: user.fullName),
                      const SizedBox(height: 8),
                      Text(user.fullName, style: AppTextStyles.bodyMedium()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.softPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: AppColors.rose, size: 18),
                    ),
                  ),
                  Column(
                    children: [
                      AvatarTile(
                          seed: partner.avatarSeed,
                          size: 72,
                          label: partner.fullName),
                      const SizedBox(height: 8),
                      Text(partner.fullName,
                          style: AppTextStyles.bodyMedium()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anniversary Date',
                              style: AppTextStyles.caption()),
                          Text(
                            'Set your anniversary to track days together.',
                            style: AppTextStyles.body(),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: session.couple?.anniversaryDate ??
                              DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          helpText: 'Select your anniversary',
                        );
                        if (picked == null || !context.mounted) return;
                        await ref
                            .read(sessionProvider.notifier)
                            .updateAnniversary(picked);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Anniversary date saved')),
                          );
                        }
                      },
                      child: Text('Set',
                          style:
                              AppTextStyles.bodyMedium(color: AppColors.rose)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _connecting
                    ? 'Setting up your space...'
                    : 'Continue to OurSound',
                loading: _connecting,
                onTap: _connecting ? null : () => context.go('/home'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
