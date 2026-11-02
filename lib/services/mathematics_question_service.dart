import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../data/mathematics_practice_question_bank.dart';
import '../models/math_practice_question.dart';
import '../models/mathematics_degree.dart';
import 'mathematics_progress_service.dart';
import 'openai_service.dart';

class MathematicsQuestionService {
  MathematicsQuestionService(this._openAi, this._progress);

  final OpenAiService _openAi;
  final MathematicsProgressService _progress;

  static const int quizQuestionCount = MathematicsPracticeQuestionBank.quizQuestionCount;
  static const int examQuestionCount = MathematicsPracticeQuestionBank.examQuestionCount;
  static const int examPassThreshold = 18;

  Future<List<MathPracticeQuestion>> loadForActivity({
    required MathematicsLessonPath path,
    required MathLessonActivityKind kind,
    int attemptSeed = 0,
  }) async {
    final String tier = kind.name;
    final int target = MathematicsPracticeQuestionBank.questionCountFor(tier);
    final Set<String> exclude = _progress.usedQuestionHashes(path.lesson.id);

    List<MathPracticeQuestion> questions = const <MathPracticeQuestion>[];

    if (AppConfig.hasOpenAi) {
      try {
        questions = await _loadFromAi(
          path: path,
          tier: tier,
          target: target,
          exclude: exclude,
        );
      } catch (e) {
        debugPrint('Math AI questions failed: $e');
      }
    }

    if (questions.length < target) {
      final List<MathPracticeQuestion> local =
          MathematicsPracticeQuestionBank.build(
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

  Future<List<MathPracticeQuestion>> _loadFromAi({
    required MathematicsLessonPath path,
    required String tier,
    required int target,
    required Set<String> exclude,
  }) async {
    final List<Map<String, dynamic>> raw = await _openAi.generateMathPracticeQuestionsRaw(
      topicName: path.lesson.title,
      courseName: path.course.title,
      unitName: path.module.title,
      sessionTier: tier,
      count: target,
      excludePrompts: exclude.toList(),
      premium: true,
    );

    final List<MathPracticeQuestion> out = <MathPracticeQuestion>[];
    for (var i = 0; i < raw.length; i++) {
      final Map<String, dynamic> item = raw[i];
      final String prompt = (item['prompt'] as String? ?? '').trim();
      if (prompt.isEmpty || exclude.contains(prompt.toLowerCase())) continue;

      final String kindStr = (item['kind'] as String? ?? 'freeResponse').toLowerCase();
      final MathPracticeQuestionKind kind = switch (kindStr) {
        'multiplechoice' || 'multiple_choice' || 'mcq' => MathPracticeQuestionKind.multipleChoice,
        'graph' => MathPracticeQuestionKind.graph,
        _ => MathPracticeQuestionKind.freeResponse,
      };

      final String diffStr = (item['difficulty'] as String? ?? 'intermediate').toLowerCase();
      final MathPracticeDifficulty difficulty = switch (diffStr) {
        'easy' || 'beginner' => MathPracticeDifficulty.easy,
        'advanced' || 'hard' => MathPracticeDifficulty.advanced,
        _ => MathPracticeDifficulty.intermediate,
      };

      final List<String> options =
          (item['options'] as List<dynamic>?)?.map((dynamic e) => e.toString()).toList() ??
              const <String>[];
      final int? correctIndex = (item['correctIndex'] as num?)?.toInt();

      out.add(
        MathPracticeQuestion(
          id: '${tier}_ai_$i',
          prompt: prompt,
          kind: kind,
          difficulty: difficulty,
          options: options,
          correctOptionIndex: correctIndex,
          graphNote: item['graphNote'] as String?,
        ),
      );
    }
    return out;
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
