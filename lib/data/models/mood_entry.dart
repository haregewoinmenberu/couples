class MoodEntry {
  final String id;
  final String userId;
  final String mood;
  final String? songId;
  final String? message;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    this.songId,
    this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'mood': mood,
        'songId': songId,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'] as String,
        userId: j['userId'] as String,
        mood: j['mood'] as String,
        songId: j['songId'] as String?,
        message: j['message'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
