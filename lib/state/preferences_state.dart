import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_store.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final raw = await LocalStore.readString('theme_mode');
    if (raw == null) return;
    state = ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await LocalStore.writeString('theme_mode', mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

// ─── Notification preferences ─────────────────────────────────────────────────

/// Keys map to events that can create an in-app notification.
enum NotificationSetting {
  newSong,
  newMessage,
  dedication,
  newMemory,
  dailyQuestion,
  challenge,
}

extension NotificationSettingX on NotificationSetting {
  String get label => switch (this) {
        NotificationSetting.newSong => 'New song from partner',
        NotificationSetting.newMessage => 'New message',
        NotificationSetting.dedication => 'Music dedications',
        NotificationSetting.newMemory => 'New memory',
        NotificationSetting.dailyQuestion => 'Daily question',
        NotificationSetting.challenge => 'Couple challenges',
      };
}

typedef NotificationSettings = Map<NotificationSetting, bool>;

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier()
      : super({
          NotificationSetting.newSong: true,
          NotificationSetting.newMessage: true,
          NotificationSetting.dedication: true,
          NotificationSetting.newMemory: true,
          NotificationSetting.dailyQuestion: false,
          NotificationSetting.challenge: true,
        }) {
    _load();
  }

  Future<void> _load() async {
    final raw = await LocalStore.readString('notification_settings');
    if (raw == null) return;
    // Simple "key:1,key:0" encoding, robust to missing/new keys.
    final saved = <String, bool>{};
    for (final part in raw.split(',')) {
      final kv = part.split(':');
      if (kv.length == 2) saved[kv[0]] = kv[1] == '1';
    }
    state = {
      for (final s in NotificationSetting.values)
        s: saved[s.name] ?? state[s] ?? true,
    };
  }

  Future<void> set(NotificationSetting key, bool value) async {
    state = {...state, key: value};
    await LocalStore.writeString(
      'notification_settings',
      state.entries.map((e) => '${e.key.name}:${e.value ? 1 : 0}').join(','),
    );
  }

  bool isEnabled(NotificationSetting key) => state[key] ?? true;
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) => NotificationSettingsNotifier());
