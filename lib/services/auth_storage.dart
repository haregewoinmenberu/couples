import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _keyUserId = 'auth_user_id';
const _keyUserJson = 'auth_user_json';
const _keyCoupleJson = 'auth_couple_json';
const _keyPartnerJson = 'auth_partner_json';

class AuthStorage {
  static Future<void> save({
    required Map<String, dynamic> user,
    Map<String, dynamic>? couple,
    Map<String, dynamic>? partner,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user['id'] as String);
    await prefs.setString(_keyUserJson, jsonEncode(user));
    if (couple != null) {
      await prefs.setString(_keyCoupleJson, jsonEncode(couple));
    }
    if (partner != null) {
      await prefs.setString(_keyPartnerJson, jsonEncode(partner));
    }
  }

  static Future<StoredSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUserJson);
    if (userJson == null) return null;
    final coupleJson = prefs.getString(_keyCoupleJson);
    final partnerJson = prefs.getString(_keyPartnerJson);
    return StoredSession(
      user: jsonDecode(userJson) as Map<String, dynamic>,
      couple: coupleJson != null
          ? jsonDecode(coupleJson) as Map<String, dynamic>
          : null,
      partner: partnerJson != null
          ? jsonDecode(partnerJson) as Map<String, dynamic>
          : null,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserJson);
    await prefs.remove(_keyCoupleJson);
    await prefs.remove(_keyPartnerJson);
  }
}

class StoredSession {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? couple;
  final Map<String, dynamic>? partner;
  const StoredSession({required this.user, this.couple, this.partner});
}
