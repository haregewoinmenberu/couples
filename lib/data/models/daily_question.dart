class QuestionAnswer {
  final String userId;
  final String text;
  final String? attachedSongId;
  final int? attachedPhotoSeed;
  final DateTime answeredAt;

  const QuestionAnswer({
    required this.userId,
    required this.text,
    this.attachedSongId,
    this.attachedPhotoSeed,
    required this.answeredAt,
  });
}

class DailyQuestion {
  final String id;
  final String prompt;
  final DateTime date;
  final List<QuestionAnswer> answers;

  const DailyQuestion({
    required this.id,
    required this.prompt,
    required this.date,
    this.answers = const [],
  });

  DailyQuestion copyWith({List<QuestionAnswer>? answers}) {
    return DailyQuestion(
      id: id,
      prompt: prompt,
      date: date,
      answers: answers ?? this.answers,
    );
  }

  bool answeredBy(String userId) => answers.any((a) => a.userId == userId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'date': date.toIso8601String(),
        'answers': answers
            .map((a) => {
                  'userId': a.userId,
                  'text': a.text,
                  'attachedSongId': a.attachedSongId,
                  'attachedPhotoSeed': a.attachedPhotoSeed,
                  'answeredAt': a.answeredAt.toIso8601String(),
                })
            .toList(),
      };

  factory DailyQuestion.fromJson(Map<String, dynamic> j) => DailyQuestion(
        id: j['id'] as String,
        prompt: j['prompt'] as String,
        date: DateTime.parse(j['date'] as String),
        answers: (j['answers'] as List? ?? [])
            .map((a) => QuestionAnswer(
                  userId: a['userId'] as String,
                  text: a['text'] as String? ?? '',
                  attachedSongId: a['attachedSongId'] as String?,
                  attachedPhotoSeed: (a['attachedPhotoSeed'] as num?)?.toInt(),
                  answeredAt: DateTime.parse(a['answeredAt'] as String),
                ))
            .toList(),
      );
}
