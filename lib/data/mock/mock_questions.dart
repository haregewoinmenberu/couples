import '../models/daily_question.dart';
import 'mock_people.dart';

final DateTime _today = DateTime.now();

final List<DailyQuestion> mockQuestions = [
  DailyQuestion(
    id: 'q_today',
    prompt: 'What song reminds you of our first meeting?',
    date: DateTime(_today.year, _today.month, _today.day),
  ),
  DailyQuestion(
    id: 'q1',
    prompt: 'What is your favorite memory together?',
    date: _today.subtract(const Duration(days: 1)),
    answers: [
      QuestionAnswer(
        userId: alexId,
        text: 'Our first trip to the coast. I still think about that sunset.',
        answeredAt: _today.subtract(const Duration(days: 1, hours: 2)),
      ),
      QuestionAnswer(
        userId: sophiaId,
        text: 'Dancing in the kitchen at 2am for no reason at all.',
        answeredAt: _today.subtract(const Duration(days: 1, hours: 1)),
      ),
    ],
  ),
  DailyQuestion(
    id: 'q2',
    prompt: 'What makes you feel loved?',
    date: _today.subtract(const Duration(days: 2)),
    answers: [
      QuestionAnswer(
        userId: sophiaId,
        text: 'When you remember little things I mentioned once.',
        answeredAt: _today.subtract(const Duration(days: 2, hours: 3)),
      ),
    ],
  ),
  DailyQuestion(
    id: 'q3',
    prompt: 'Which place should we visit together?',
    date: _today.subtract(const Duration(days: 3)),
    answers: [
      QuestionAnswer(
        userId: alexId,
        text: 'Kyoto in the spring, I want to see the blossoms with you.',
        answeredAt: _today.subtract(const Duration(days: 3, hours: 5)),
      ),
      QuestionAnswer(
        userId: sophiaId,
        text: 'Lalibela — I\'ve always wanted to go with you.',
        answeredAt: _today.subtract(const Duration(days: 3, hours: 4)),
      ),
    ],
  ),
  DailyQuestion(
    id: 'q4',
    prompt: 'What song describes our relationship?',
    date: _today.subtract(const Duration(days: 4)),
    answers: [
      QuestionAnswer(
        userId: alexId,
        text: 'Perfect by Ed Sheeran, no contest.',
        attachedSongId: 's1',
        answeredAt: _today.subtract(const Duration(days: 4, hours: 6)),
      ),
    ],
  ),
  DailyQuestion(
    id: 'q5',
    prompt: 'What do you miss most when we are apart?',
    date: _today.subtract(const Duration(days: 5)),
    answers: [],
  ),
];
