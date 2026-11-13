enum MessageType { text, song, photo, voice, dedication, playlist, memory, dailyQuestion }

extension MessageTypeX on MessageType {
  static MessageType fromString(String s) => switch (s) {
        'song' => MessageType.song,
        'photo' || 'image' => MessageType.photo,
        'voice' => MessageType.voice,
        'dedication' => MessageType.dedication,
        'playlist' => MessageType.playlist,
        'memory' => MessageType.memory,
        _ => MessageType.text,
      };
}

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

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        type: MessageTypeX.fromString(j['type'] as String? ?? 'text'),
        text: j['text'] as String?,
        songId: j['songId'] as String?,
        // imageUrl stored in text field for photo type
        sentAt: DateTime.parse(j['createdAt'] as String),
        reactions: const [],
        isDeleted: false,
      );

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
