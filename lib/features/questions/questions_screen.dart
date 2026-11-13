import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/mock/mock_people.dart';
import '../../data/models/daily_question.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../widgets/common/primary_button.dart';

class QuestionsScreen extends ConsumerStatefulWidget {
  const QuestionsScreen({super.key});

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  final _answerCtrl = TextEditingController();

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);
    final session = ref.watch(sessionProvider);
    final me = session.currentUser ?? mockAlex;
    final partner = session.partner ?? mockSophia;

    final today = questions.firstWhere(
      (q) => q.id == 'q_today',
      orElse: () => questions.first,
    );

    final alreadyAnswered = today.answeredBy(me.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text('Daily Questions', style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's question
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Question',
                      style: AppTextStyles.caption(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(today.prompt,
                      style: AppTextStyles.h3(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!alreadyAnswered) ...[
              Text('Your answer', style: AppTextStyles.bodyMedium()),
              const SizedBox(height: 8),
              TextField(
                controller: _answerCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your answer...',
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Submit Answer',
                onTap: () {
                  if (_answerCtrl.text.trim().isEmpty) return;
                  ref.read(questionsProvider.notifier).answer(
                        today.id,
                        QuestionAnswer(
                          userId: me.id,
                          text: _answerCtrl.text.trim(),
                          answeredAt: DateTime.now(),
                        ),
                      );
                  _answerCtrl.clear();
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.rose),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You\'ve answered today\'s question!',
                        style: AppTextStyles.body(color: AppColors.rose),
                      ),
                    ),
                  ],
                ),
              ),
              // Show partner's answer if available
              ...today.answers.where((a) => a.userId == partner.id).map((a) {
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${partner.fullName}\'s answer',
                          style: AppTextStyles.bodyMedium()),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(a.text,
                            style: AppTextStyles.body(
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 28),
            Text('Previous Questions', style: AppTextStyles.h3()),
            const SizedBox(height: 14),
            ...questions
                .where((q) => q.id != 'q_today')
                .map((q) => _PastQuestion(question: q, me: me, partner: partner)),
          ],
        ),
      ),
    );
  }
}

class _PastQuestion extends StatelessWidget {
  final DailyQuestion question;
  final dynamic me;
  final dynamic partner;

  const _PastQuestion(
      {required this.question, required this.me, required this.partner});

  @override
  Widget build(BuildContext context) {
    final myAnswer =
        question.answers.where((a) => a.userId == me.id).firstOrNull;
    final partnerAnswer =
        question.answers.where((a) => a.userId == partner.id).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatDate(question.date), style: AppTextStyles.small()),
          const SizedBox(height: 4),
          Text(question.prompt, style: AppTextStyles.bodyMedium()),
          if (myAnswer != null) ...[
            const SizedBox(height: 10),
            _AnswerChip(label: 'You', text: myAnswer.text),
          ],
          if (partnerAnswer != null) ...[
            const SizedBox(height: 6),
            _AnswerChip(
                label: partner.fullName, text: partnerAnswer.text),
          ],
          if (myAnswer == null && partnerAnswer == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Not answered yet',
                  style: AppTextStyles.small()),
            ),
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final String text;
  const _AnswerChip({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.small(color: AppColors.rose)),
        const SizedBox(height: 2),
        Text(text,
            style: AppTextStyles.body(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
