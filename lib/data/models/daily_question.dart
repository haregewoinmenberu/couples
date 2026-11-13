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
}
