import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_store.dart';

/// Reads (or caches) the phone number of the device the app is installed on.
///
/// On Android we ask the OS via a small platform channel. Some modern Android
/// versions hide the number from apps; in that case the user can confirm or
/// type it once on the phone screen and we remember it locally.
class DevicePhoneService {
  static const _channel = MethodChannel('oursound/device_phone');
  static const _cacheKey = 'device_phone_number';

  /// Returns the stored/confirmed device number without touching the platform.
  static Future<String?> cached() => LocalStore.readString(_cacheKey);

  static Future<void> cache(String number) =>
      LocalStore.writeString(_cacheKey, normalize(number));

  /// Best-effort detection of the device's own phone number.
  static Future<String?> detect() async {
    final cachedNumber = await cached();
    if (cachedNumber != null && cachedNumber.isNotEmpty) return cachedNumber;
    // `dart:io` Platform getters throw on Flutter web — always short-circuit.
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final status = await Permission.phone.status;
      final granted = status.isGranted ||
          (await Permission.phone.request()).isGranted;
      if (!granted) return null;

      final value = await _channel.invokeMethod<String>('getPhoneNumber');
      if (value != null && value.trim().isNotEmpty) {
        await cache(value);
        return normalize(value);
      }
    } catch (_) {
      // Missing plugin / permission — fall back to manual confirmation.
    }
    return null;
  }

  /// Normalise numbers so the inviter and invitee always match:
  /// keep a leading `+` and digits only, e.g. "+1 555-0101" -> "+15550101".
  static String normalize(String phone) {
    final trimmed = phone.trim();
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }
}
