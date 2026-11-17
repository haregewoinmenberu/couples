enum DedicationType { loveYou, missYou, thankYou, thinkingOfYou, specialOccasion, justBecause }

extension DedicationTypeLabel on DedicationType {
  String get label {
    switch (this) {
      case DedicationType.loveYou:
        return 'I Love You';
      case DedicationType.missYou:
        return 'I Miss You';
      case DedicationType.thankYou:
        return 'Thank You';
      case DedicationType.thinkingOfYou:
        return 'Thinking of You';
      case DedicationType.specialOccasion:
        return 'Special Occasion';
      case DedicationType.justBecause:
        return 'Just Because';
    }
  }
}

class Dedication {
  final String id;
  final String fromUserId;
  final String songId;
  final DedicationType type;
  final String message;
  final int? photoSeed;
  final DateTime? scheduledFor;
  final DateTime createdAt;
  bool delivered;

  Dedication({
    required this.id,
    required this.fromUserId,
    required this.songId,
    required this.type,
    required this.message,
    this.photoSeed,
    this.scheduledFor,
    required this.createdAt,
    this.delivered = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'songId': songId,
        'type': type.name,
        'message': message,
        'photoSeed': photoSeed,
        'scheduledFor': scheduledFor?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'delivered': delivered,
      };

  factory Dedication.fromJson(Map<String, dynamic> j) => Dedication(
        id: j['id'] as String,
        fromUserId: j['fromUserId'] as String? ?? '',
        songId: j['songId'] as String? ?? '',
        type: DedicationType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => DedicationType.justBecause,
        ),
        message: j['message'] as String? ?? '',
        photoSeed: (j['photoSeed'] as num?)?.toInt(),
        scheduledFor: j['scheduledFor'] != null
            ? DateTime.parse(j['scheduledFor'] as String)
            : null,
        createdAt: DateTime.parse(j['createdAt'] as String),
        delivered: j['delivered'] as bool? ?? true,
      );
}
