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
}
