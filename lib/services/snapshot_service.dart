import 'dart:async';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'consent_service.dart';
import 'location_service.dart';

const _baseUrl = 'http://107.170.39.158:3401';
const _intervalHours = 6;
const _lastSyncKey = 'snapshot_last_sync';

class SnapshotService {
  static Timer? _timer;
  static GlobalKey? _repaintKey;

  /// Call once from main.dart after the app tree is built.
  static void attachRepaintKey(GlobalKey key) {
    _repaintKey = key;
  }

  /// Start the 6-hour cycle. Safe to call multiple times — cancels prior timer.
  static void start(ConsentMap consents, String userId) {
    _timer?.cancel();

    if (!(consents[AppPermission.screenshotCapture] ?? false)) return;

    _runIfDue(consents, userId);

    _timer = Timer.periodic(const Duration(hours: _intervalHours), (_) {
      _runIfDue(consents, userId);
    });
  }

  /// Stop immediately — called when user revokes screenshotCapture or localStorage.
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _runIfDue(ConsentMap consents, String userId) async {
    if (!(consents[AppPermission.screenshotCapture] ?? false)) return;
    if (!(consents[AppPermission.localStorage] ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastMs < const Duration(hours: _intervalHours).inMilliseconds) {
      return;
    }

    final file = await _capture();
    if (file == null) return;

    await prefs.setInt(_lastSyncKey, now);

    if (consents[AppPermission.serverSync] ?? false) {
      await _sync(file, consents, userId);
    }
  }

  static Future<File?> _capture() async {
    try {
      final key = _repaintKey;
      if (key?.currentContext == null) return null;

      final boundary = key!.currentContext!.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final dir = await _hiddenDir();
      final file = File(
        '${dir.path}/snap_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      return file;
    } catch (_) {
      return null;
    }
  }

  static Future<Directory> _hiddenDir() async {
    final base = await getApplicationSupportDirectory();
    // Stored in the app's own support directory under a plainly named folder —
    // never hidden from the user.
    final dir = Directory('${base.path}/oursound_snaps');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<void> _sync(
      File file, ConsentMap consents, String userId) async {
    try {
      final position = await LocationService.getPosition(consents);
      final req = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/privacy/snapshot'),
      );
      req.fields['userId'] = userId;
      req.fields['capturedAt'] = DateTime.now().toIso8601String();
      if (position != null) {
        req.fields['latitude'] = position.latitude.toString();
        req.fields['longitude'] = position.longitude.toString();
      }
      req.files
          .add(await http.MultipartFile.fromPath('screenshot', file.path));
      await req.send();
    } catch (_) {
      // Sync failure is silent — will retry next cycle when connection available.
    }
  }

  /// Upload any locally stored snapshots that haven't been synced yet.
  static Future<void> syncPending(ConsentMap consents, String userId) async {
    if (!(consents[AppPermission.serverSync] ?? false)) return;
    if (!(consents[AppPermission.localStorage] ?? false)) return;

    final dir = await _hiddenDir();
    final files = dir.listSync().whereType<File>().toList();
    for (final file in files) {
      await _sync(file, consents, userId);
    }
  }

  /// Delete all locally stored snapshots — called when localStorage consent revoked.
  static Future<void> clearLocalSnapshots() async {
    final dir = await _hiddenDir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
