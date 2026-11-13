import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../state/app_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final partner = session.partner ?? mockSophia;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Settings', style: AppTextStyles.h3()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        children: [
          _Section(title: 'Account', items: [
            _SettingsItem(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              onTap: () => context.push('/auth/profile'),
            ),
            _SettingsItem(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              subtitle: session.currentUser?.phoneNumber ?? '',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.lock_outline_rounded,
              label: 'Password',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.security_rounded,
              label: 'Account Security',
              onTap: () {},
            ),
          ]),
          _Section(title: 'Couple', items: [
            _SettingsItem(
              icon: Icons.favorite_border_rounded,
              label: 'Partner',
              subtitle: partner.fullName,
              trailing: AvatarTile(
                  seed: partner.avatarSeed, size: 28, label: partner.fullName),
              onTap: () => context.go('/profile'),
            ),
            _SettingsItem(
              icon: Icons.calendar_today_rounded,
              label: 'Anniversary Date',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.lock_person_rounded,
              label: 'Shared Privacy',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.link_off_rounded,
              label: 'Disconnect Partner',
              textColor: AppColors.error,
              onTap: () => _confirmDisconnect(context, ref),
            ),
          ]),
          _Section(title: 'Notifications', items: [
            _SwitchItem(label: 'New song from partner', value: true),
            _SwitchItem(label: 'New message', value: true),
            _SwitchItem(label: 'Music dedications', value: true),
            _SwitchItem(label: 'New memory', value: true),
            _SwitchItem(label: 'Daily question', value: false),
            _SwitchItem(label: 'Couple challenges', value: true),
          ]),
          _Section(title: 'Appearance', items: [
            _SettingsItem(
              icon: Icons.light_mode_rounded,
              label: 'Theme',
              subtitle: 'Light',
              onTap: () {},
            ),
          ]),
          _Section(title: 'Privacy', items: [
            _SettingsItem(
                icon: Icons.visibility_outlined,
                label: 'Profile Visibility',
                onTap: () {}),
            _SettingsItem(
                icon: Icons.photo_outlined,
                label: 'Photo Privacy',
                onTap: () {}),
            _SettingsItem(
                icon: Icons.headphones_outlined,
                label: 'Listening Activity',
                onTap: () {}),
            _SettingsItem(
                icon: Icons.block_rounded,
                label: 'Block and Report',
                onTap: () {}),
          ]),
          _Section(title: 'Other', items: [
            _SettingsItem(
                icon: Icons.help_outline_rounded, label: 'Help', onTap: () {}),
            _SettingsItem(
                icon: Icons.info_outline_rounded, label: 'About', onTap: () {}),
            _SettingsItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {}),
            _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {}),
            _SettingsItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              textColor: AppColors.error,
              onTap: () {
                ref.read(sessionProvider.notifier).logout();
                context.go('/welcome');
              },
            ),
          ]),
        ],
      ),
    );
  }

  void _confirmDisconnect(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Disconnect Partner?', style: AppTextStyles.h3()),
        content: Text(
          'This will disconnect your shared space. This action cannot be undone.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(sessionProvider.notifier).disconnectPartner();
              Navigator.pop(context);
              context.go('/connection/invite');
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.small()
                  .copyWith(letterSpacing: 1)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.textColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textColor ?? AppColors.rose),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body(
                          color:
                              textColor ?? AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTextStyles.caption()),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SwitchItem extends StatefulWidget {
  final String label;
  final bool value;
  const _SwitchItem({required this.label, required this.value});

  @override
  State<_SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<_SwitchItem> {
  late bool _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(widget.label, style: AppTextStyles.body())),
          Switch(
            value: _val,
            activeColor: AppColors.rose,
            onChanged: (v) => setState(() => _val = v),
          ),
        ],
      ),
    );
  }
}
