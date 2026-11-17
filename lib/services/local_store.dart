import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight, typed local persistence used by feature notifiers so that
/// data survives app restarts. All values are stored as JSON strings.
class LocalStore {
  static const _prefix = 'oursound_store_';

  static Future<List<Map<String, dynamic>>> readList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return const [];
      final decoded = jsonDecode(raw) as List;
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> writeList(
      String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', jsonEncode(items));
    } catch (_) {
      // Persistence is best-effort; the in-memory state still works.
    }
  }

  static Future<String?> readString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_prefix$key');
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', value);
    } catch (_) {}
  }
}
