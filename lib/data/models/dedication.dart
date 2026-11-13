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
}
