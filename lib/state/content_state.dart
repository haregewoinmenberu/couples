import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
import '../core/utils/mood_matching.dart';
import '../services/api_service.dart';
import '../services/local_store.dart';

// ─── Songs ────────────────────────────────────────────────────────────────────

class SongsNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  SongsNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? search, String? mood, String? genre}) async {
    state = const AsyncValue.loading();
    try {
      final raw = await ApiService.getSongs(
        search: search,
        mood: mood,
        genre: genre,
      );
      final songs =
          raw.map((j) => Song.fromJson(j as Map<String, dynamic>)).toList();
      state = AsyncValue.data(songs.isNotEmpty ? songs : _localFallback(search, mood, genre));
    } catch (_) {
      state = AsyncValue.data(_localFallback(search, mood, genre));
    }
  }

  void add(Song song) {
    final current = state.valueOrNull ?? const <Song>[];
    if (current.any((s) => s.id == song.id)) return;
    state = AsyncValue.data([song, ...current]);
  }

  List<Song> _localFallback(String? search, String? mood, String? genre) {
    var songs = List<Song>.from(mockSongs);
    if (mood != null && mood.isNotEmpty) {
      songs = songs.where((s) => songMatchesMood(s, mood)).toList();
    }
    if (genre != null && genre.isNotEmpty) {
      songs = songs
          .where((s) => s.genres
              .any((g) => g.toLowerCase() == genre.toLowerCase()))
          .toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      songs = songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q))
          .toList();
    }
    return songs;
  }
}

final songsProvider =
    StateNotifierProvider<SongsNotifier, AsyncValue<List<Song>>>((ref) {
  return SongsNotifier();
});

// ─── Chat ─────────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final String? coupleId;
  ChatNotifier(this.coupleId) : super(const []) {
    _load();
  }

  void _persist() => LocalStore.writeList(
      'chat_messages', state.map((m) => m.toJson()).toList());

  Future<void> _load() async {
    final rows = await LocalStore.readList('chat_messages');
    if (rows.isNotEmpty) {
      state = rows.map(ChatMessage.fromStoredJson).toList();
    } else {
      state = List.from(mockMessages);
    }
    if (coupleId != null) {
      try {
        final raw = await ApiService.getMessages(coupleId!);
        final server = raw
            .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
            .where((m) => !state.any((existing) => existing.id == m.id));
        state = [...state, ...server];
        _persist();
      } catch (_) {}
    }
  }

  Future<void> send(ChatMessage msg,
      {String? coupleId, String? imageUrl}) async {
    // Optimistic add
    state = [...state, msg];
    _persist();
    final cId = coupleId ?? this.coupleId;
    if (cId == null) return;
    try {
      final saved = await ApiService.sendMessage(
        coupleId: cId,
        senderId: msg.senderId,
        text: msg.text,
        songId: msg.songId,
        imageUrl: imageUrl,
        type: msg.type.name,
      );
      // Replace optimistic with server record
      final serverMsg = ChatMessage.fromJson(saved);
      state = state
          .map((m) => m.id == msg.id ? serverMsg : m)
          .toList();
      _persist();
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
    _persist();
  }

  void delete(String messageId, String requestingUserId) {
    state = state.map((m) {
      if (m.id == messageId && m.senderId == requestingUserId) {
        return m.copyWith(isDeleted: true);
      }
      return m;
    }).toList();
    _persist();
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
  PlaylistsNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('playlists');
    state = rows.isEmpty
        ? List.from(mockPlaylists)
        : rows.map(Playlist.fromJson).toList();
  }

  void _persist() =>
      LocalStore.writeList('playlists', state.map((p) => p.toJson()).toList());

  Future<void> loadForCouple(String coupleId) async {
    try {
      final raw = await ApiService.getPlaylists(coupleId);
      if (raw.isEmpty) return;
      final server = raw.map((j) {
        final m = j as Map<String, dynamic>;
        return Playlist(
          id: m['id'] as String,
          title: m['name'] as String? ?? 'Untitled',
          description: m['description'] as String?,
          coverSeed: (m['createdAt']?.toString().hashCode ?? 0).abs() % 8,
          createdByUserId:
              (m['createdBy'] as Map<String, dynamic>?)?['id'] as String? ??
                  '',
          createdAt: m['createdAt'] != null
              ? DateTime.tryParse(m['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
        );
      }).where((p) => !state.any((existing) => existing.id == p.id));
      state = [...state, ...server];
      _persist();
    } catch (_) {}
  }

  void add(Playlist playlist) {
    state = [...state, playlist];
    _persist();
  }

  void update(Playlist updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    _persist();
  }

  void remove(String id) {
    state = state.where((p) => p.id != id).toList();
    _persist();
  }

  void addSong(String playlistId, PlaylistSongEntry entry) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(songs: [...p.songs, entry]);
    }).toList();
    _persist();
  }

  void removeSong(String playlistId, String songId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        songs: p.songs.where((e) => e.songId != songId).toList(),
      );
    }).toList();
    _persist();
  }
}

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier();
});

// ─── Memories ─────────────────────────────────────────────────────────────────

class MemoriesNotifier extends StateNotifier<List<Memory>> {
  MemoriesNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('memories');
    state = rows.isEmpty
        ? List.from(mockMemories)
        : rows.map(Memory.fromJson).toList();
  }

  void _persist() =>
      LocalStore.writeList('memories', state.map((m) => m.toJson()).toList());

  Future<void> loadForCouple(String coupleId) async {
    try {
      final raw = await ApiService.getMemories(coupleId);
      if (raw.isEmpty) return;
      final serverMemories = raw
          .map((j) => Memory.fromJson(j as Map<String, dynamic>))
          .where((m) => !state.any((existing) => existing.id == m.id))
          .toList();
      if (serverMemories.isEmpty) return;
      state = [...serverMemories, ...state];
      _persist();
    } catch (_) {}
  }

  Future<void> addFromApi({
    required String title,
    required String description,
    required DateTime date,
    required String userId,
    String? coupleId,
    String? location,
    List<XFile> photos = const [],
  }) async {
    try {
      final data = photos.isEmpty
          ? await ApiService.createMemory(
              title: title,
              description: description,
              date: date,
              createdByUserId: userId,
              coupleId: coupleId,
              location: location,
            )
          : await ApiService.createMemoryWithPhotos(
              title: title,
              description: description,
              date: date,
              createdByUserId: userId,
              coupleId: coupleId,
              location: location,
              photos: photos,
            );
      final memory = Memory.fromJson(data);
      state = [memory, ...state];
      _persist();
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

  void add(Memory memory) {
    state = [memory, ...state];
    _persist();
  }

  void update(Memory updated) {
    state = state.map((m) => m.id == updated.id ? updated : m).toList();
    _persist();
  }

  void remove(String id) {
    state = state.where((m) => m.id != id).toList();
    _persist();
  }

  void toggleFavorite(String id) {
    state = state.map((m) {
      if (m.id != id) return m;
      return m.copyWith(isFavorite: !m.isFavorite);
    }).toList();
    _persist();
  }
}

final memoriesProvider =
    StateNotifierProvider<MemoriesNotifier, List<Memory>>((ref) {
  return MemoriesNotifier();
});

// ─── Daily Questions ──────────────────────────────────────────────────────────

class QuestionsNotifier extends StateNotifier<List<DailyQuestion>> {
  QuestionsNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('questions');
    state = rows.isEmpty
        ? List.from(mockQuestions)
        : rows.map(DailyQuestion.fromJson).toList();
  }

  void _persist() => LocalStore.writeList(
      'questions', state.map((q) => q.toJson()).toList());

  void answer(String questionId, QuestionAnswer answer) {
    state = state.map((q) {
      if (q.id != questionId) return q;
      if (q.answeredBy(answer.userId)) return q;
      return q.copyWith(answers: [...q.answers, answer]);
    }).toList();
    _persist();
  }
}

final questionsProvider =
    StateNotifierProvider<QuestionsNotifier, List<DailyQuestion>>((ref) {
  return QuestionsNotifier();
});

// ─── Challenges ───────────────────────────────────────────────────────────────

class ChallengesNotifier extends StateNotifier<List<Challenge>> {
  ChallengesNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('challenges');
    state = rows.isEmpty
        ? List.from(mockChallenges)
        : rows.map(Challenge.fromJson).toList();
  }

  void _persist() => LocalStore.writeList(
      'challenges', state.map((c) => c.toJson()).toList());

  void respond(String challengeId, ChallengeResponse response) {
    state = state.map((c) {
      if (c.id != challengeId) return c;
      return c.copyWith(responses: [...c.responses, response]);
    }).toList();
    _persist();
  }
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Challenge>>((ref) {
  return ChallengesNotifier();
});

// ─── Notifications ────────────────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('notifications');
    state = rows.isEmpty
        ? List.from(mockNotifications)
        : rows.map(AppNotification.fromJson).toList();
  }

  void _persist() => LocalStore.writeList(
      'notifications', state.map((n) => n.toJson()).toList());

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markRead(String id) {
    state = state.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
    _persist();
  }

  void markAllRead() {
    state = state.map((n) {
      n.isRead = true;
      return n;
    }).toList();
    _persist();
  }

  void add(AppNotification notification) {
    state = [notification, ...state];
    _persist();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

// ─── Moods ────────────────────────────────────────────────────────────────────

class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('moods');
    state = rows.isEmpty
        ? [
            MoodEntry(
              id: 'mood_sophia_1',
              userId: sophiaId,
              mood: 'In Love',
              songId: 's1',
              message: 'Missing you so much today ❤️',
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ]
        : rows.map(MoodEntry.fromJson).toList();
  }

  void _persist() =>
      LocalStore.writeList('moods', state.map((m) => m.toJson()).toList());

  void add(MoodEntry entry) {
    state = [entry, ...state];
    _persist();
  }

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
  DedicationsNotifier() : super(const []) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final rows = await LocalStore.readList('dedications');
    state = rows.isEmpty
        ? [
            Dedication(
              id: 'd1',
              fromUserId: sophiaId,
              songId: 's2',
              type: DedicationType.loveYou,
              message: 'This song is us. Every word.',
              createdAt: DateTime.now().subtract(const Duration(hours: 20)),
            ),
          ]
        : rows.map(Dedication.fromJson).toList();
  }

  void _persist() => LocalStore.writeList(
      'dedications', state.map((d) => d.toJson()).toList());

  void add(Dedication dedication) {
    state = [dedication, ...state];
    _persist();
  }
}

final dedicationsProvider =
    StateNotifierProvider<DedicationsNotifier, List<Dedication>>((ref) {
  return DedicationsNotifier();
});
