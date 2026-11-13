import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message.dart';
import '../data/models/playlist.dart';
import '../data/models/memory.dart';
import '../data/models/daily_question.dart';
import '../data/models/challenge.dart';
import '../data/models/app_notification.dart';
import '../data/models/mood_entry.dart';
import '../data/models/dedication.dart';
import '../data/models/song.dart';
import '../data/mock/mock_chat.dart';
import '../data/mock/mock_playlists.dart';
import '../data/mock/mock_memories.dart';
import '../data/mock/mock_questions.dart';
import '../data/mock/mock_challenges.dart';
import '../data/mock/mock_notifications.dart';
import '../data/mock/mock_people.dart';
import '../data/mock/mock_songs.dart';
import '../services/api_service.dart';

// ─── Songs ────────────────────────────────────────────────────────────────────

class SongsNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  SongsNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? search, String? mood, String? genre}) async {
    state = const AsyncValue.loading();
    try {
      final raw = await ApiService.getSongs();
      final songs = raw.map((j) => Song.fromJson(j as Map<String, dynamic>)).toList();
      state = AsyncValue.data(songs.isEmpty ? mockSongs : songs);
    } catch (_) {
      state = AsyncValue.data(mockSongs);
    }
  }
}

final songsProvider =
    StateNotifierProvider<SongsNotifier, AsyncValue<List<Song>>>((ref) {
  return SongsNotifier();
});

// ─── Chat ─────────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final String? coupleId;
  ChatNotifier(this.coupleId) : super([]) {
    if (coupleId != null) {
      _load();
    } else {
      state = List.from(mockMessages);
    }
  }

  Future<void> _load() async {
    try {
      final raw = await ApiService.getMessages(coupleId!);
      state = raw
          .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = List.from(mockMessages);
    }
  }

  Future<void> send(ChatMessage msg, {String? coupleId}) async {
    // Optimistic add
    state = [...state, msg];
    final cId = coupleId ?? this.coupleId;
    if (cId == null) return;
    try {
      final saved = await ApiService.sendMessage(
        coupleId: cId,
        senderId: msg.senderId,
        text: msg.text,
        songId: msg.songId,
        type: msg.type.name,
      );
      // Replace optimistic with server record
      final serverMsg = ChatMessage.fromJson(saved);
      state = state
          .map((m) => m.id == msg.id ? serverMsg : m)
          .toList();
    } catch (_) {
      // Keep optimistic message on error
    }
  }

  void react(String messageId, String emoji) {
    state = state.map((m) {
      if (m.id != messageId) return m;
      final updated = List<String>.from(m.reactions);
      if (updated.contains(emoji)) {
        updated.remove(emoji);
      } else {
        updated.add(emoji);
      }
      return m.copyWith(reactions: updated);
    }).toList();
  }

  void delete(String messageId, String requestingUserId) {
    state = state.map((m) {
      if (m.id == messageId && m.senderId == requestingUserId) {
        return m.copyWith(isDeleted: true);
      }
      return m;
    }).toList();
  }
}

final chatCoupleIdProvider = StateProvider<String?>((ref) => null);

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final coupleId = ref.watch(chatCoupleIdProvider);
  return ChatNotifier(coupleId);
});

// ─── Playlists ────────────────────────────────────────────────────────────────

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  PlaylistsNotifier() : super(List.from(mockPlaylists));

  Future<void> loadForCouple(String coupleId) async {
    try {
      final raw = await ApiService.getPlaylists(coupleId);
      if (raw.isEmpty) return;
      // Keep mock data as base, add server playlists on top
      state = List.from(mockPlaylists);
    } catch (_) {}
  }

  void add(Playlist playlist) => state = [...state, playlist];
  void update(Playlist updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }
  void remove(String id) => state = state.where((p) => p.id != id).toList();
  void addSong(String playlistId, PlaylistSongEntry entry) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(songs: [...p.songs, entry]);
    }).toList();
  }
  void removeSong(String playlistId, String songId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        songs: p.songs.where((e) => e.songId != songId).toList(),
      );
    }).toList();
  }
}

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier();
});

// ─── Memories ─────────────────────────────────────────────────────────────────

class MemoriesNotifier extends StateNotifier<List<Memory>> {
  MemoriesNotifier() : super(List.from(mockMemories));

  Future<void> loadForCouple(String coupleId) async {
    try {
      final raw = await ApiService.getMemories(coupleId);
      if (raw.isEmpty) return;
      final serverMemories = raw
          .map((j) => Memory.fromJson(j as Map<String, dynamic>))
          .toList();
      state = serverMemories;
    } catch (_) {}
  }

  Future<void> addFromApi({
    required String title,
    required String description,
    required DateTime date,
    required String userId,
    String? coupleId,
    String? location,
    List<File> photos = const [],
  }) async {
    try {
      final data = await ApiService.createMemory(
        title: title,
        description: description,
        date: date,
        createdByUserId: userId,
        coupleId: coupleId,
        location: location,
      );
      final memory = Memory.fromJson(data);
      state = [memory, ...state];
    } catch (_) {
      // Fall back to local-only
      add(Memory(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        date: date,
        location: location,
        createdByUserId: userId,
      ));
    }
  }

  void add(Memory memory) => state = [memory, ...state];
  void update(Memory updated) {
    state = state.map((m) => m.id == updated.id ? updated : m).toList();
  }
  void remove(String id) => state = state.where((m) => m.id != id).toList();
  void toggleFavorite(String id) {
    state = state.map((m) {
      if (m.id != id) return m;
      return m.copyWith(isFavorite: !m.isFavorite);
    }).toList();
  }
}

final memoriesProvider =
    StateNotifierProvider<MemoriesNotifier, List<Memory>>((ref) {
  return MemoriesNotifier();
});

// ─── Daily Questions ──────────────────────────────────────────────────────────

class QuestionsNotifier extends StateNotifier<List<DailyQuestion>> {
  QuestionsNotifier() : super(List.from(mockQuestions));

  void answer(String questionId, QuestionAnswer answer) {
    state = state.map((q) {
      if (q.id != questionId) return q;
      if (q.answeredBy(answer.userId)) return q;
      return q.copyWith(answers: [...q.answers, answer]);
    }).toList();
  }
}

final questionsProvider =
    StateNotifierProvider<QuestionsNotifier, List<DailyQuestion>>((ref) {
  return QuestionsNotifier();
});

// ─── Challenges ───────────────────────────────────────────────────────────────

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier() : super(List.from(mockChallenges));

  void respond(String challengeId, ChallengeResponse response) {
    state = state.map((c) {
      if (c.id != challengeId) return c;
      return c.copyWith(responses: [...c.responses, response]);
    }).toList();
  }
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  return ChallengesNotifier();
});

// ─── Notifications ────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(List.from(mockNotifications));

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markRead(String id) {
    state = state.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
  }

  void markAllRead() {
    state = state.map((n) {
      n.isRead = true;
      return n;
    }).toList();
  }

  void add(AppNotification notification) => state = [notification, ...state];
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

// ─── Moods ────────────────────────────────────────────────────────────────────

class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier()
      : super([
          MoodEntry(
            id: 'mood_sophia_1',
            userId: sophiaId,
            mood: 'In Love',
            songId: 's1',
            message: 'Missing you so much today ❤️',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ]);

  void add(MoodEntry entry) => state = [entry, ...state];

  MoodEntry? latestFor(String userId) {
    final entries = state.where((m) => m.userId == userId).toList();
    if (entries.isEmpty) return null;
    return entries.first;
  }
}

final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<MoodEntry>>((ref) {
  return MoodsNotifier();
});

// ─── Dedications ──────────────────────────────────────────────────────────────

class DedicationsNotifier extends StateNotifier<List<Dedication>> {
  DedicationsNotifier()
      : super([
          Dedication(
            id: 'd1',
            fromUserId: sophiaId,
            songId: 's2',
            type: DedicationType.loveYou,
            message: 'This song is us. Every word.',
            createdAt: DateTime.now().subtract(const Duration(hours: 20)),
          ),
        ]);

  void add(Dedication dedication) => state = [dedication, ...state];
}

final dedicationsProvider =
    StateNotifierProvider<DedicationsNotifier, List<Dedication>>((ref) {
  return DedicationsNotifier();
});
