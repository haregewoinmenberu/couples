import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _base = 'http://107.170.39.158:3401';

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => 'ApiException($status): $message';
}

Future<dynamic> _req(
  String method,
  String path, {
  Map<String, dynamic>? body,
}) async {
  final uri = Uri.parse('$_base$path');
  http.Response res;
  final headers = {'Content-Type': 'application/json'};
  switch (method) {
    case 'GET':
      res = await http.get(uri, headers: headers);
    case 'POST':
      res = await http.post(uri, headers: headers, body: jsonEncode(body));
    case 'PATCH':
      res = await http.patch(uri, headers: headers, body: jsonEncode(body));
    case 'DELETE':
      res = await http.delete(uri, headers: headers);
    default:
      throw ApiException(0, 'Unknown method $method');
  }
  if (res.statusCode >= 400) {
    throw ApiException(res.statusCode, res.body);
  }
  if (res.body.isEmpty) return null;
  return jsonDecode(res.body);
}

// ── Users ─────────────────────────────────────────────────────────────────────

class ApiService {
  static Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    String countryCode = '+1',
  }) async {
    return await _req('POST', '/api/users/register', body: {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
    });
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      return await _req('GET', '/api/users/by-email/$email');
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserByUsername(
      String username) async {
    try {
      return await _req('GET', '/api/users/by-username/$username');
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUser(String id) async {
    return await _req('GET', '/api/users/$id');
  }

  // ── Songs ──────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getSongs() async {
    return await _req('GET', '/api/songs');
  }

  // ── Chat ───────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getMessages(String coupleId) async {
    return await _req('GET', '/api/chat/$coupleId');
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String coupleId,
    required String senderId,
    String? text,
    String? songId,
    String? imageUrl,
    String type = 'text',
  }) async {
    return await _req('POST', '/api/chat', body: {
      'coupleId': coupleId,
      'senderId': senderId,
      'text': text,
      'songId': songId,
      'imageUrl': imageUrl,
      'type': type,
    });
  }

  // ── Memories ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getMemories(String coupleId) async {
    return await _req('GET', '/api/memories?coupleId=$coupleId');
  }

  static Future<Map<String, dynamic>> createMemory({
    required String title,
    required String description,
    required DateTime date,
    required String createdByUserId,
    String? coupleId,
    String? location,
  }) async {
    return await _req('POST', '/api/memories', body: {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'createdByUserId': createdByUserId,
      'coupleId': coupleId,
      'location': location,
    });
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getPlaylists(String coupleId) async {
    return await _req('GET', '/api/playlists?coupleId=$coupleId');
  }

  static Future<Map<String, dynamic>> createPlaylist({
    required String name,
    required String createdById,
    String? coupleId,
    String? description,
  }) async {
    return await _req('POST', '/api/playlists', body: {
      'name': name,
      'createdById': createdById,
      'coupleId': coupleId,
      'description': description,
    });
  }

  // ── Couple ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createCouple({
    required String userAId,
    required String userBId,
    required DateTime anniversaryDate,
  }) async {
    return await _req('POST', '/api/couples', body: {
      'userAId': userAId,
      'userBId': userBId,
      'anniversaryDate': anniversaryDate.toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getCoupleForUser(String userId) async {
    try {
      return await _req('GET', '/api/couples/for-user/$userId');
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  // ── Upload image ───────────────────────────────────────────────────────────

  static Future<String> uploadImage(File file) async {
    final uri = Uri.parse('$_base/api/chat/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('image', file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 400) throw ApiException(res.statusCode, res.body);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return '$_base${data['url']}';
  }
}
