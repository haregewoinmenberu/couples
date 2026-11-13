enum MessageType { text, song, photo, voice, dedication, playlist, memory, dailyQuestion }

class ChatMessage {
  final String id;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? songId;
  final int? photoSeed;
  final String? playlistId;
  final String? memoryId;
  final Duration? voiceDuration;
  final DateTime sentAt;
  final String? replyToMessageId;
  final List<String> reactions;
  final bool isDeleted;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    this.text,
    this.songId,
    this.photoSeed,
    this.playlistId,
    this.memoryId,
    this.voiceDuration,
    required this.sentAt,
    this.replyToMessageId,
    this.reactions = const [],
    this.isDeleted = false,
  });

  ChatMessage copyWith({
    List<String>? reactions,
    bool? isDeleted,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      type: type,
      text: text,
      songId: songId,
      photoSeed: photoSeed,
      playlistId: playlistId,
      memoryId: memoryId,
      voiceDuration: voiceDuration,
      sentAt: sentAt,
      replyToMessageId: replyToMessageId,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
