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
      attachedSongId: attachedSongId ?? this.attachedSongId,
      createdByUserId: createdByUserId,
      isFavorite: isFavorite ?? this.isFavorite,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
    );
  }
}
