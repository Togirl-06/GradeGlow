import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../data/biology_practice_question_bank.dart';
import '../models/biology_degree.dart';
import '../models/math_practice_question.dart';
import 'biology_progress_service.dart';
import 'openai_service.dart';

class BiologyQuestionService {
  BiologyQuestionService(this._openAi, this._progress);

  final OpenAiService _openAi;
  final BiologyProgressService _progress;

  static const int quizQuestionCount = BiologyPracticeQuestionBank.quizQuestionCount;
  static const int examQuestionCount = BiologyPracticeQuestionBank.examQuestionCount;
  static const int examPassThreshold = BiologyPracticeQuestionBank.examPassThreshold;

  Future<List<MathPracticeQuestion>> loadForActivity({
    required BiologyLessonPath path,
    required BioLessonActivityKind kind,
    int attemptSeed = 0,
  }) async {
    final String tier = kind == BioLessonActivityKind.exam ? 'exam' : 'practice';
    final int target = BiologyPracticeQuestionBank.questionCountFor(tier);
    final Set<String> exclude = _progress.usedQuestionHashes(path.lesson.id);

    List<MathPracticeQuestion> questions = const <MathPracticeQuestion>[];

    if (AppConfig.hasOpenAi) {
      try {
        final List<String> prompts = await _openAi.generatePracticeQuestions(
          categoryName: 'Biology',
          courseName: path.course.title,
          unitName: path.module.title,
          topicName: path.lesson.title,
          difficulty: tier == 'exam' ? 'advanced' : 'intermediate',
          count: target,
          premium: true,
          subjectId: 'biology',
          courseId: path.course.id,
        );
        for (var i = 0; i < prompts.length; i++) {
          final String prompt = prompts[i].trim();
          if (prompt.isEmpty || exclude.contains(prompt.toLowerCase())) continue;
          questions = <MathPracticeQuestion>[
            ...questions,
            MathPracticeQuestion(
              id: '${path.lesson.id}_ai_$i',
              prompt: prompt,
              kind: MathPracticeQuestionKind.freeResponse,
              difficulty: tier == 'exam'
                  ? MathPracticeDifficulty.advanced
                  : MathPracticeDifficulty.intermediate,
            ),
          ];
        }
      } catch (e) {
        debugPrint('Biology AI questions failed: $e');
      }
    }

    if (questions.length < target) {
      final List<MathPracticeQuestion> local = BiologyPracticeQuestionBank.build(
        lessonId: path.lesson.id,
        topicName: path.lesson.title,
        courseName: path.course.title,
        sessionTier: tier,
        excludeHashes: <String>{
          ...exclude,
          ...questions.map((MathPracticeQuestion q) => q.hashKey),
        },
        seed: attemptSeed,
      );
      questions = <MathPracticeQuestion>[...questions, ...local];
    }

    final Set<String> seen = <String>{...exclude};
    questions = questions.where((MathPracticeQuestion q) => seen.add(q.hashKey)).toList();
    return questions.take(target).toList();
  }

  Future<void> recordSession({
    required String lessonId,
    required List<MathPracticeQuestion> questions,
  }) async {
    await _progress.recordUsedQuestions(
      lessonId,
      questions.map((MathPracticeQuestion q) => q.hashKey),
    );
  }

  Future<bool> gradeAnswer({
    required MathPracticeQuestion question,
    required String answer,
    required String topicName,
  }) async {
    if (question.isMultipleChoice && question.correctOptionIndex != null) {
      final int? selected = int.tryParse(answer);
      return selected == question.correctOptionIndex;
    }
    if (!AppConfig.hasOpenAi) {
      return answer.trim().length >= 8;
    }
    return _openAi.gradeMathAnswerCorrect(
      topicName: topicName,
      question: question.prompt,
      studentAnswer: answer,
      kind: question.kind.name,
      difficulty: question.difficulty.label,
    );
  }
}
