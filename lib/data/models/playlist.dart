class PlaylistSongEntry {
  final String songId;
  final String addedByUserId;
  final DateTime addedAt;

  const PlaylistSongEntry({
    required this.songId,
    required this.addedByUserId,
    required this.addedAt,
  });
}

class Playlist {
  final String id;
  final String title;
  final String? description;
  final int coverSeed;
  final String createdByUserId;
  final DateTime createdAt;
  final List<PlaylistSongEntry> songs;

  const Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.coverSeed,
    required this.createdByUserId,
    required this.createdAt,
    this.songs = const [],
  });

  Playlist copyWith({
    String? title,
    String? description,
    List<PlaylistSongEntry>? songs,
  }) {
    return Playlist(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverSeed: coverSeed,
      createdByUserId: createdByUserId,
      createdAt: createdAt,
      songs: songs ?? this.songs,
    );
  }
}
