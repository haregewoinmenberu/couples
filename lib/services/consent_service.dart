import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every device feature the user can independently allow or deny.
enum AppPermission {
  phoneNumber,
  gpsLocation,
  screenshotCapture,
  localStorage,
  serverSync,
  adminAccess,
}

extension AppPermissionX on AppPermission {
  String get key => switch (this) {
        AppPermission.phoneNumber => 'phone_number',
        AppPermission.gpsLocation => 'gps_location',
        AppPermission.screenshotCapture => 'screenshot_capture',
        AppPermission.localStorage => 'local_storage',
        AppPermission.serverSync => 'server_sync',
        AppPermission.adminAccess => 'admin_access',
      };

  String get title => switch (this) {
        AppPermission.phoneNumber => 'Phone Number',
        AppPermission.gpsLocation => 'GPS Location',
        AppPermission.screenshotCapture => 'Screenshot Capture',
        AppPermission.localStorage => 'Local Storage',
        AppPermission.serverSync => 'Server Sync',
        AppPermission.adminAccess => 'Admin Access',
      };

  String get description => switch (this) {
        AppPermission.phoneNumber =>
          'Allow the admin to see your phone number in the admin dashboard.',
        AppPermission.gpsLocation =>
          'Allow the app to read your GPS coordinates and upload them every 6 hours.',
        AppPermission.screenshotCapture =>
          'Allow the app to capture a screenshot of your screen every 6 hours and store it locally.',
        AppPermission.localStorage =>
          'Allow captured screenshots to be stored in a hidden folder on this device.',
        AppPermission.serverSync =>
          'Allow locally stored screenshots and location data to be uploaded to the server when a connection is available.',
        AppPermission.adminAccess =>
          'Allow the admin to view your location, screenshots, and consent statuses in the admin dashboard.',
      };
}

typedef ConsentMap = Map<AppPermission, bool>;

class ConsentNotifier extends StateNotifier<ConsentMap> {
  // All features are enabled by default; the user can turn any of them off.
  ConsentNotifier()
      : super({for (final p in AppPermission.values) p: true});

  static const _prefix = 'consent_';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <AppPermission, bool>{};
    for (final p in AppPermission.values) {
      map[p] = prefs.getBool('$_prefix${p.key}') ?? true;
    }
    state = map;
  }

  Future<void> setConsent(AppPermission permission, bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${permission.key}', granted);
    state = {...state, permission: granted};
  }

  bool isGranted(AppPermission permission) => state[permission] ?? true;
}

final consentProvider =
    StateNotifierProvider<ConsentNotifier, ConsentMap>((ref) {
  final notifier = ConsentNotifier();
  notifier.load();
  return notifier;
});
