import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/consent_service.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consents = ref.watch(consentProvider);
    final notifier = ref.read(consentProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Privacy & Permissions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoBanner(),
          const SizedBox(height: 24),
          const _SectionLabel('What you share'),
          const SizedBox(height: 12),
          ...AppPermission.values.map(
            (p) => _ConsentTile(
              permission: p,
              granted: consents[p] ?? false,
              onChanged: (val) async {
                await notifier.setConsent(p, val);
              },
            ),
          ),
          const SizedBox(height: 32),
          _RevokeAllButton(
            onTap: () async {
              final confirm = await _confirmDialog(context);
              if (!confirm) return;
              for (final p in AppPermission.values) {
                await notifier.setConsent(p, false);
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<bool> _confirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardWhite,
            title: const Text(
              'Revoke all permissions?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text(
              'All active features will stop immediately and no data will be collected.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Revoke All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'You are in control',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'No data is collected without your explicit consent. Each permission is independent — you can enable or disable any feature at any time.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final AppPermission permission;
  final bool granted;
  final ValueChanged<bool> onChanged;

  const _ConsentTile({
    required this.permission,
    required this.granted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: granted
              ? AppColors.primary.withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: granted
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(permission),
                color: granted ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permission.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusChip(granted: granted),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: granted,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AppPermission p) => switch (p) {
        AppPermission.phoneNumber => Icons.phone_outlined,
        AppPermission.gpsLocation => Icons.location_on_outlined,
        AppPermission.screenshotCapture => Icons.screenshot_monitor_outlined,
        AppPermission.localStorage => Icons.storage_outlined,
        AppPermission.serverSync => Icons.cloud_upload_outlined,
        AppPermission.adminAccess => Icons.admin_panel_settings_outlined,
      };
}

class _StatusChip extends StatelessWidget {
  final bool granted;
  const _StatusChip({required this.granted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: granted
            ? Colors.green.withOpacity(0.12)
            : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        granted ? 'Active' : 'Off',
        style: TextStyle(
          color: granted ? Colors.green.shade600 : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RevokeAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RevokeAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.block_outlined, color: Colors.red),
      label: const Text(
        'Revoke All Permissions',
        style: TextStyle(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
