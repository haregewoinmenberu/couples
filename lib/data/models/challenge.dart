enum ChallengeStatus { notStarted, waitingForPartner, completed }

class ChallengeResponse {
  final String userId;
  final String answer;
  final String? songId;
  final DateTime respondedAt;

  const ChallengeResponse({
    required this.userId,
    required this.answer,
    this.songId,
    required this.respondedAt,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String instructions;
  final int iconSeed;
  final List<ChallengeResponse> responses;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    required this.iconSeed,
    this.responses = const [],
  });

  Challenge copyWith({List<ChallengeResponse>? responses}) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      instructions: instructions,
      iconSeed: iconSeed,
      responses: responses ?? this.responses,
    );
  }

  ChallengeStatus statusFor(String userId, String partnerId) {
    final mine = responses.any((r) => r.userId == userId);
    final theirs = responses.any((r) => r.userId == partnerId);
    if (mine && theirs) return ChallengeStatus.completed;
    if (mine && !theirs) return ChallengeStatus.waitingForPartner;
    return ChallengeStatus.notStarted;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'instructions': instructions,
        'iconSeed': iconSeed,
        'responses': responses
            .map((r) => {
                  'userId': r.userId,
                  'answer': r.answer,
                  'songId': r.songId,
                  'respondedAt': r.respondedAt.toIso8601String(),
                })
            .toList(),
      };

  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        instructions: j['instructions'] as String? ?? '',
        iconSeed: (j['iconSeed'] as num?)?.toInt() ?? 0,
        responses: (j['responses'] as List? ?? [])
            .map((r) => ChallengeResponse(
                  userId: r['userId'] as String,
                  answer: r['answer'] as String? ?? '',
                  songId: r['songId'] as String?,
                  respondedAt: DateTime.parse(r['respondedAt'] as String),
                ))
            .toList(),
      );
}
