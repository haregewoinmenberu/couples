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
          'Allow the app to capture a screenshot of the app screen every 6 hours while it is open.',
        AppPermission.localStorage =>
          'Allow captured screenshots to be kept in a folder inside this app\'s own storage.',
        AppPermission.serverSync =>
          'Allow locally stored screenshots and location data to be uploaded to the server when a connection is available.',
        AppPermission.adminAccess =>
          'Allow the admin to view your location, screenshots, and consent statuses in the admin dashboard.',
      };
}

typedef ConsentMap = Map<AppPermission, bool>;

class ConsentNotifier extends StateNotifier<ConsentMap> {
  // Nothing is collected until the user explicitly opts in.
  ConsentNotifier()
      : super({for (final p in AppPermission.values) p: false});

  static const _prefix = 'consent_';
  static const _optInMigrationKey = 'consent_opt_in_v2';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Older builds stored every permission as ON by default. Reset those once
    // so existing installs are actually asked before anything is collected.
    if (!(prefs.getBool(_optInMigrationKey) ?? false)) {
      for (final p in AppPermission.values) {
        await prefs.remove('$_prefix${p.key}');
      }
      await prefs.setBool(_optInMigrationKey, true);
    }

    final map = <AppPermission, bool>{};
    for (final p in AppPermission.values) {
      // Opt-in only: a missing value means the user has never granted it.
      map[p] = prefs.getBool('$_prefix${p.key}') ?? false;
    }
    state = map;
  }

  Future<void> setConsent(AppPermission permission, bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix${permission.key}', granted);
    state = {...state, permission: granted};
  }

  bool isGranted(AppPermission permission) => state[permission] ?? false;
}

final consentProvider =
    StateNotifierProvider<ConsentNotifier, ConsentMap>((ref) {
  final notifier = ConsentNotifier();
  notifier.load();
  return notifier;
});
