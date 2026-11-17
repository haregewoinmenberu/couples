class MemoryComment {
  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;

  const MemoryComment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });
}

class Memory {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? location;
  final List<int> photoSeeds;
  final List<String> photoUrls;
  final String? attachedSongId;
  final String createdByUserId;
  final bool isFavorite;
  final List<MemoryComment> comments;
  final List<String> reactions;

  const Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.location,
    this.photoSeeds = const [],
    this.photoUrls = const [],
    this.attachedSongId,
    required this.createdByUserId,
    this.isFavorite = false,
    this.comments = const [],
    this.reactions = const [],
  });

  Memory copyWith({
    String? title,
    String? description,
    DateTime? date,
    String? location,
    List<int>? photoSeeds,
    List<String>? photoUrls,
    String? attachedSongId,
    bool? isFavorite,
    List<MemoryComment>? comments,
    List<String>? reactions,
  }) {
    return Memory(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      photoSeeds: photoSeeds ?? this.photoSeeds,
      photoUrls: photoUrls ?? this.photoUrls,
      attachedSongId: attachedSongId ?? this.attachedSongId,
      createdByUserId: createdByUserId,
      isFavorite: isFavorite ?? this.isFavorite,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
    );
  }

  factory Memory.fromJson(Map<String, dynamic> j) => Memory(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        date: DateTime.parse(j['date'] as String),
        location: j['location'] as String?,
        photoSeeds: (j['photoSeeds'] as List? ?? [])
            .map((e) => (e as num).toInt())
            .toList(),
        photoUrls: j.containsKey('photoUrls')
            ? List<String>.from(j['photoUrls'] as List? ?? [])
            : (j['photos'] as List? ?? [])
                .map((p) => 'http://107.170.39.158:3401${p['url']}')
                .cast<String>()
                .toList(),
        attachedSongId: j.containsKey('attachedSongId')
            ? j['attachedSongId'] as String?
            : (j['songLinks'] as List? ?? []).isNotEmpty
                ? (j['songLinks'][0]['song']?['id'] as String?)
                : null,
        createdByUserId: j['createdByUserId'] as String? ??
            (j['createdBy']?['id'] as String? ?? ''),
        isFavorite: j['isFavorite'] as bool? ?? false,
        reactions: List<String>.from(j['reactions'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'photoSeeds': photoSeeds,
        'photoUrls': photoUrls,
        'attachedSongId': attachedSongId,
        'createdByUserId': createdByUserId,
        'isFavorite': isFavorite,
        'reactions': reactions,
      };
}
