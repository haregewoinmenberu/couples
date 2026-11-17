import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/consent_service.dart';
import '../../services/location_service.dart';
import '../../services/snapshot_service.dart';
import '../../state/app_state.dart';

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
                if (val) {
                  // Enabling always requires an explicit, informed opt-in.
                  final agreed = await _confirmEnable(context, p);
                  if (!agreed) return;

                  // Ask the OS for location access only after the user opts in.
                  if (!kIsWeb && p == AppPermission.gpsLocation) {
                    final osGranted = await LocationService.requestPermission();
                    if (!osGranted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Location access was not granted on this device.',
                          ),
                        ),
                      );
                      return;
                    }
                  }
                }
                await notifier.setConsent(p, val);
                await _applyConsentEffects(ref, p, val);
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
                await _applyConsentEffects(ref, p, false);
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Apply the side effects of a consent change: stop collectors, clear local
  /// data on revoke, and mirror the choice to the backend for the admin view.
  Future<void> _applyConsentEffects(
      WidgetRef ref, AppPermission permission, bool granted) async {
    if (kIsWeb) return;
    if (permission == AppPermission.screenshotCapture && !granted) {
      SnapshotService.stop();
    }
    if (permission == AppPermission.localStorage && !granted) {
      await SnapshotService.clearLocalSnapshots();
    }
    if (permission == AppPermission.adminAccess && !granted) {
      SnapshotService.stop();
    }

    final userId = ref.read(sessionProvider).currentUser?.id;
    if (userId != null) {
      await ApiService.setConsent(
        userId: userId,
        permission: permission.key,
        granted: granted,
      );
    }
  }

  /// Every feature starts OFF. Turning one on requires the user to actively
  /// confirm what will be collected, where it goes, and how to stop it.
  Future<bool> _confirmEnable(BuildContext context, AppPermission permission) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardWhite,
            title: Text(
              'Enable ${permission.title}?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    permission.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'This feature is OFF by default. It only runs while the app '
                    'is open, and you can turn it off at any time here — doing '
                    'so stops collection immediately and deletes locally '
                    'stored data.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('I understand — Enable'),
              ),
            ],
          ),
        ) ??
        false;
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
            'Every permission starts OFF. Nothing is collected until you explicitly turn a feature on. Each one is independent and can be switched off at any time — doing so stops collection and deletes locally stored data.',
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
