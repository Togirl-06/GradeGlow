import 'package:flutter/foundation.dart';

import '../models/quiz_question.dart';
import '../utils/premium_access.dart';
import 'openai_service.dart';
import 'subscription_service.dart';

class PracticeExamResult {
  const PracticeExamResult({
    required this.subject,
    required this.difficulty,
    required this.questions,
  });

  final String subject;
  final String difficulty;
  final List<QuizQuestion> questions;
}

class PracticeExamService extends ChangeNotifier {
  PracticeExamService(this._openAi, this._subscription);

  final OpenAiService _openAi;
  final SubscriptionService _subscription;
  bool _generating = false;
  bool get isGenerating => _generating;

  Future<PracticeExamResult> generate({
    required String subject,
    required String difficulty,
    required int questionCount,
  }) async {
    PremiumAccess.requirePremium(_subscription.plan, feature: PremiumFeature.practiceExams);

    _generating = true;
    notifyListeners();
    try {
      final List<QuizQuestion> questions = await _openAi.generatePracticeExam(
        subject: subject,
        difficulty: difficulty,
        questionCount: questionCount,
      );
      return PracticeExamResult(
        subject: subject,
        difficulty: difficulty,
        questions: questions,
      );
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  int scoreAnswers(List<QuizQuestion> questions, List<int?> selected) {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selected.length > i && selected[i] == questions[i].correctIndex) {
        correct++;
      }
    }
    return correct;
  }
}
