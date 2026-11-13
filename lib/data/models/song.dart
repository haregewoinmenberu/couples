class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int artworkSeed;
  final Duration duration;
  final List<String> moods;
  final List<String> genres;
  final bool isEthiopian;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkSeed,
    required this.duration,
    this.moods = const [],
    this.genres = const [],
    this.isEthiopian = false,
  });

  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
