import 'package:flutter/material.dart';
import '../../core/utils/navigation_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../data/mock/mock_people.dart';
import '../../services/local_store.dart';
import '../../state/app_state.dart';
import '../../state/preferences_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final partner = session.partner ?? mockSophia;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.safePop(),
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
              onTap: () => _editPhone(context, ref),
            ),
            _SettingsItem(
              icon: Icons.lock_outline_rounded,
              label: 'Password',
              subtitle: 'Change your password',
              onTap: () => _changePassword(context),
            ),
            _SettingsItem(
              icon: Icons.security_rounded,
              label: 'Account Security',
              subtitle: session.currentUser?.phoneVerified == true
                  ? 'Phone verified'
                  : 'Phone not verified',
              onTap: () => _accountSecurity(context, ref),
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
              subtitle: session.couple != null
                  ? _formatDate(session.couple!.anniversaryDate)
                  : 'Not set',
              onTap: () => _pickAnniversary(context, ref),
            ),
            _SettingsItem(
              icon: Icons.lock_person_rounded,
              label: 'Shared Privacy',
              onTap: () => context.push('/privacy'),
            ),
            _SettingsItem(
              icon: Icons.link_off_rounded,
              label: 'Disconnect Partner',
              textColor: AppColors.error,
              onTap: () => _confirmDisconnect(context, ref),
            ),
          ]),
          _Section(title: 'Notifications', items: [
            for (final s in NotificationSetting.values)
              _NotificationSwitch(setting: s),
          ]),
          _Section(title: 'Appearance', items: [
            _SettingsItem(
              icon: Icons.light_mode_rounded,
              label: 'Theme',
              subtitle: switch (themeMode) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                ThemeMode.system => 'System',
              },
              onTap: () => _chooseTheme(context, ref),
            ),
          ]),
          _Section(title: 'Privacy', items: [
            _SettingsItem(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Privacy & Permissions',
                subtitle: 'Manage what data you share',
                onTap: () => context.push('/privacy')),
            _StoredChoiceItem(
              icon: Icons.visibility_outlined,
              label: 'Profile Visibility',
              storeKey: 'profile_visibility',
              options: const ['Partner only', 'Everyone', 'Nobody'],
              defaultValue: 'Partner only',
            ),
            _StoredToggleItem(
              icon: Icons.photo_outlined,
              label: 'Photo Privacy',
              storeKey: 'photo_privacy',
              subtitle: 'Hide your photos from the admin dashboard',
            ),
            _StoredToggleItem(
              icon: Icons.headphones_outlined,
              label: 'Listening Activity',
              storeKey: 'listening_activity',
              subtitle: 'Let your partner see what you are listening to',
              defaultValue: true,
            ),
            _SettingsItem(
              icon: Icons.block_rounded,
              label: 'Block and Report',
              onTap: () => _blockAndReport(context),
            ),
          ]),
          _Section(title: 'Other', items: [
            _SettingsItem(
                icon: Icons.help_outline_rounded,
                label: 'Help',
                onTap: () => _infoDialog(
                      context,
                      'Help & Support',
                      'Need a hand?\n\n'
                          '• Invite your partner from the connection screen.\n'
                          '• Share songs, moods and memories from the home screen.\n'
                          '• Manage what you share under Privacy & Permissions.\n\n'
                          'Contact: support@oursound.app',
                    )),
            _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: 'About',
                onTap: () => _infoDialog(
                      context,
                      'OurSound',
                      'A shared musical space for two.\n\n'
                          'Version 1.0.0 (1)\n'
                          'Made with love for you and your partner.',
                    )),
            _SettingsItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _infoDialog(
                      context,
                      'Terms of Service',
                      'By using OurSound you agree to use the app respectfully '
                          'and only share content you have the right to share. '
                          'Your shared space is private to you and your partner.\n\n'
                          'You may disconnect your partner or delete your data '
                          'at any time from Settings.',
                    )),
            _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _infoDialog(
                      context,
                      'Privacy Policy',
                      'We only collect data you explicitly allow. Every permission '
                          'in Privacy & Permissions can be turned on or off at any '
                          'time. Screenshots and location are only captured when '
                          'you grant consent, and are never shared without your '
                          'explicit approval.',
                    )),
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

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

  void _editPhone(BuildContext context, WidgetRef ref) {
    final user = ref.read(sessionProvider).currentUser;
    final codeCtrl = TextEditingController(text: user?.countryCode ?? '+1');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Phone Number', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Country code')),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (user == null || phoneCtrl.text.trim().isEmpty) return;
              ref.read(sessionProvider.notifier).updateProfile(
                    user.copyWith(
                      countryCode: codeCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Password', style: AppTextStyles.h3()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Current password')),
              const SizedBox(height: 12),
              TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password')),
              const SizedBox(height: 12),
              TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password')),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: AppTextStyles.caption(color: AppColors.error)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (currentCtrl.text.isEmpty ||
                    newCtrl.text.length < 6 ||
                    newCtrl.text != confirmCtrl.text) {
                  setState(() => error =
                      'Enter your current password and a matching new password (6+ characters).');
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed')),
                );
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _accountSecurity(BuildContext context, WidgetRef ref) {
    final user = ref.read(sessionProvider).currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Account Security', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SecurityRow(
                icon: user?.phoneVerified == true
                    ? Icons.verified_user_rounded
                    : Icons.phone_disabled_rounded,
                label: user?.phoneVerified == true
                    ? 'Phone number verified'
                    : 'Phone number not verified'),
            const SizedBox(height: 10),
            _SecurityRow(
                icon: Icons.lock_outline_rounded,
                label: 'Password is set'),
          ],
        ),
        actions: [
          if (user != null && user.phoneVerified != true)
            TextButton(
              onPressed: () {
                ref.read(sessionProvider.notifier).updateProfile(
                      user.copyWith(phoneVerified: true),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone marked as verified')),
                );
              },
              child: const Text('Verify phone'),
            ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _pickAnniversary(BuildContext context, WidgetRef ref) async {
    final couple = ref.read(sessionProvider).couple;
    final picked = await showDatePicker(
      context: context,
      initialDate: couple?.anniversaryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select your anniversary',
    );
    if (picked == null || !context.mounted) return;
    await ref.read(sessionProvider.notifier).updateAnniversary(picked);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anniversary date updated')),
      );
    }
  }

  void _chooseTheme(BuildContext context, WidgetRef ref) {
    ThemeMode selected = ref.read(themeModeProvider);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Choose Theme', style: AppTextStyles.h3()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  title: Text(switch (mode) {
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                    ThemeMode.system => 'System',
                  }),
                  value: mode,
                  groupValue: selected,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => selected = v);
                    ref.read(themeModeProvider.notifier).set(v);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  void _blockAndReport(BuildContext context) {
    final reportCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Block and Report', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blocked users: None',
                style: AppTextStyles.body(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            Text('Report a problem', style: AppTextStyles.bodyMedium()),
            const SizedBox(height: 6),
            TextField(
              controller: reportCtrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Tell us what happened...'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (reportCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted. Thank you.')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _infoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: AppTextStyles.h3()),
        content: SingleChildScrollView(
          child: Text(body,
              style: AppTextStyles.body(color: AppColors.textSecondary)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SecurityRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.rose),
      const SizedBox(width: 10),
      Text(label, style: AppTextStyles.body()),
    ]);
  }
}

class _NotificationSwitch extends ConsumerWidget {
  final NotificationSetting setting;
  const _NotificationSwitch({required this.setting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
              child: Text(setting.label, style: AppTextStyles.body())),
          Switch(
            value: settings[setting] ?? true,
            activeColor: AppColors.rose,
            onChanged: (v) =>
                ref.read(notificationSettingsProvider.notifier).set(setting, v),
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
              style: AppTextStyles.small().copyWith(letterSpacing: 1)),
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
          border: Border(bottom: BorderSide(color: AppColors.border)),
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
                          color: textColor ?? AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.caption()),
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

/// A settings row backed by a persisted single-choice string preference.
class _StoredChoiceItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String storeKey;
  final List<String> options;
  final String defaultValue;
  const _StoredChoiceItem({
    required this.icon,
    required this.label,
    required this.storeKey,
    required this.options,
    required this.defaultValue,
  });

  @override
  State<_StoredChoiceItem> createState() => _StoredChoiceItemState();
}

class _StoredChoiceItemState extends State<_StoredChoiceItem> {
  late String _value = widget.defaultValue;

  @override
  void initState() {
    super.initState();
    LocalStore.readString(widget.storeKey).then((v) {
      if (v != null && mounted) setState(() => _value = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsItem(
      icon: widget.icon,
      label: widget.label,
      subtitle: _value,
      onTap: () async {
        final picked = await showDialog<String>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(widget.label, style: AppTextStyles.h3()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options
                  .map((o) => RadioListTile<String>(
                        title: Text(o),
                        value: o,
                        groupValue: _value,
                        onChanged: (v) {
                          if (v != null) Navigator.pop(context, v);
                        },
                      ))
                  .toList(),
            ),
          ),
        );
        if (picked != null) {
          setState(() => _value = picked);
          await LocalStore.writeString(widget.storeKey, picked);
        }
      },
    );
  }
}

/// A settings row backed by a persisted boolean preference.
class _StoredToggleItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String storeKey;
  final String? subtitle;
  final bool defaultValue;
  const _StoredToggleItem({
    required this.icon,
    required this.label,
    required this.storeKey,
    this.subtitle,
    this.defaultValue = false,
  });

  @override
  State<_StoredToggleItem> createState() => _StoredToggleItemState();
}

class _StoredToggleItemState extends State<_StoredToggleItem> {
  late bool _value = widget.defaultValue;

  @override
  void initState() {
    super.initState();
    LocalStore.readString(widget.storeKey).then((v) {
      if (v != null && mounted) setState(() => _value = v == '1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: AppColors.rose),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: AppTextStyles.body()),
                if (widget.subtitle != null)
                  Text(widget.subtitle!, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Switch(
            value: _value,
            activeColor: AppColors.rose,
            onChanged: (v) {
              setState(() => _value = v);
              LocalStore.writeString(widget.storeKey, v ? '1' : '0');
            },
          ),
        ],
      ),
    );
  }
}
