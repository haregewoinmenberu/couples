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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coverSeed': coverSeed,
        'createdByUserId': createdByUserId,
        'createdAt': createdAt.toIso8601String(),
        'songs': songs
            .map((e) => {
                  'songId': e.songId,
                  'addedByUserId': e.addedByUserId,
                  'addedAt': e.addedAt.toIso8601String(),
                })
            .toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        coverSeed: (j['coverSeed'] as num?)?.toInt() ?? 0,
        createdByUserId: j['createdByUserId'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        songs: (j['songs'] as List? ?? [])
            .map((e) => PlaylistSongEntry(
                  songId: e['songId'] as String,
                  addedByUserId: e['addedByUserId'] as String? ?? '',
                  addedAt: e['addedAt'] != null
                      ? DateTime.parse(e['addedAt'] as String)
                      : DateTime.now(),
                ))
            .toList(),
      );
}
