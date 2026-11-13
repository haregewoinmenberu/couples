import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final bool shuffle;
  final bool repeat;
  final bool listenTogether;
  final List<Song> queue;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = false,
    this.listenTogether = false,
    this.queue = const [],
  });

  bool get hasTrack => currentSong != null;

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    bool? shuffle,
    bool? repeat,
    bool? listenTogether,
    List<Song>? queue,
    bool clearSong = false,
  }) =>
      PlayerState(
        currentSong: clearSong ? null : (currentSong ?? this.currentSong),
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        shuffle: shuffle ?? this.shuffle,
        repeat: repeat ?? this.repeat,
        listenTogether: listenTogether ?? this.listenTogether,
        queue: queue ?? this.queue,
      );
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(const PlayerState());

  void play(Song song, {List<Song>? queue}) {
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      position: Duration.zero,
      queue: queue ?? [song],
    );
  }

  void togglePlayPause() =>
      state = state.copyWith(isPlaying: !state.isPlaying);

  void seek(Duration position) => state = state.copyWith(position: position);

  void toggleShuffle() => state = state.copyWith(shuffle: !state.shuffle);

  void toggleRepeat() => state = state.copyWith(repeat: !state.repeat);

  void toggleListenTogether() =>
      state = state.copyWith(listenTogether: !state.listenTogether);

  void stop() => state = const PlayerState();

  void next() {
    if (state.queue.isEmpty) return;
    final idx = state.queue.indexWhere((s) => s.id == state.currentSong?.id);
    final nextIdx = (idx + 1) % state.queue.length;
    state = state.copyWith(
      currentSong: state.queue[nextIdx],
      position: Duration.zero,
    );
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final idx = state.queue.indexWhere((s) => s.id == state.currentSong?.id);
    final prevIdx = (idx - 1 + state.queue.length) % state.queue.length;
    state = state.copyWith(
      currentSong: state.queue[prevIdx],
      position: Duration.zero,
    );
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});

// ─── Favorites ───────────────────────────────────────────────────────────────

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({'s1', 's2', 's6', 's9'});

  void toggle(String songId) {
    final updated = Set<String>.from(state);
    if (updated.contains(songId)) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    state = updated;
  }

  bool isFavorite(String songId) => state.contains(songId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
