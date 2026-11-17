import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/song.dart';
import '../services/local_store.dart';

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
  final ap.AudioPlayer _audio = ap.AudioPlayer();
  Timer? _ticker;
  StreamSubscription<Duration>? _positionSub;

  PlayerNotifier() : super(const PlayerState()) {
    // Real playback position from the audio engine keeps the UI in sync.
    _positionSub = _audio.onPositionChanged.listen((pos) {
      if (!state.hasTrack) return;
      state = state.copyWith(position: pos);
    });
  }

  Future<void> _startAudio(Song song) async {
    if (song.isYouTube) return; // playback is handled by the embedded player
    try {
      await _audio.setSourceUrl(song.playableUrl);
      await _audio.resume();
    } catch (_) {
      // Browsers can block autoplay without a user gesture; the play button
      // still works and the simulated position keeps the UI usable.
    }
  }

  void play(Song song, {List<Song>? queue}) {
    final changed = state.currentSong?.id != song.id;
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      position: Duration.zero,
      queue: queue ?? [song],
    );
    if (changed || _audio.state != ap.PlayerState.playing) _startAudio(song);
    if (!song.isYouTube) _startTicker();
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
    if (state.isPlaying) {
      if (state.currentSong != null) _startAudio(state.currentSong!);
      if (state.currentSong?.isYouTube != true) _startTicker();
    } else {
      _audio.pause();
      _stopTicker();
    }
  }

  void seek(Duration position) {
    state = state.copyWith(position: position);
    _audio.seek(position);
  }

  void toggleShuffle() => state = state.copyWith(shuffle: !state.shuffle);

  void toggleRepeat() => state = state.copyWith(repeat: !state.repeat);

  void toggleListenTogether() =>
      state = state.copyWith(listenTogether: !state.listenTogether);

  void stop() {
    _audio.stop();
    _stopTicker();
    state = const PlayerState();
  }

  void next() {
    if (state.queue.isEmpty) return;
    final idx = state.queue.indexWhere((s) => s.id == state.currentSong?.id);
    final nextIdx =
        state.shuffle ? (idx + 1 + state.queue.length ~/ 2) % state.queue.length
                      : (idx + 1) % state.queue.length;
    final song = state.queue[nextIdx];
    state = state.copyWith(
      currentSong: song,
      position: Duration.zero,
      isPlaying: true,
    );
    _startAudio(song);
    if (!song.isYouTube) _startTicker();
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final idx = state.queue.indexWhere((s) => s.id == state.currentSong?.id);
    final prevIdx = (idx - 1 + state.queue.length) % state.queue.length;
    final song = state.queue[prevIdx];
    state = state.copyWith(
      currentSong: song,
      position: Duration.zero,
      isPlaying: true,
    );
    _startAudio(song);
    if (!song.isYouTube) _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying || state.currentSong == null) return;
      final newPos = state.position + const Duration(seconds: 1);
      final duration = state.currentSong!.duration;
      if (newPos >= duration) {
        if (state.repeat) {
          state = state.copyWith(position: Duration.zero);
          _audio.seek(Duration.zero);
        } else {
          next();
        }
      } else {
        state = state.copyWith(position: newPos);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    _positionSub?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({'s1', 's2', 's6', 's9'}) {
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final raw = await LocalStore.readString('favorites');
    if (raw == null) return;
    state = raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  void _persist() => LocalStore.writeString('favorites', state.join(','));

  void toggle(String songId) {
    final updated = Set<String>.from(state);
    if (updated.contains(songId)) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    state = updated;
    _persist();
  }

  bool isFavorite(String songId) => state.contains(songId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
