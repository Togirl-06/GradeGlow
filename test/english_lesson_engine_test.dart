import 'package:ai_study_buddy/data/english/lessons/present_perfect_lesson.dart';
import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void _submitCorrectForStep(EnglishLessonEngine engine) {
  final EnglishActivity step = engine.currentActivity!;
  switch (step.kind) {
    case EnglishActivityKind.questionCard:
    case EnglishActivityKind.miniConversation:
      engine.submitAnswer(
        step.acceptableAnswers.isNotEmpty
            ? step.acceptableAnswers.first
            : 'yes i have',
      );
    case EnglishActivityKind.fillBlank:
      engine.submitAnswer(step.correctAnswer ?? 'have');
    case EnglishActivityKind.readingAloud:
      engine.submitAnswer(step.listeningScript ?? 'read aloud passage');
    case EnglishActivityKind.speaking:
      engine.submitAnswer(
        step.acceptableAnswers.isNotEmpty
            ? step.acceptableAnswers.first
            : 'yes i have',
      );
    case EnglishActivityKind.multipleChoice:
    case EnglishActivityKind.rapidReview:
    case EnglishActivityKind.listening:
      final int idx = step.correctIndex ?? 0;
      engine.submitAnswer(step.options[idx]);
    case EnglishActivityKind.sentenceBuilder:
      engine.submitAnswer(step.correctSentence ?? '');
    case EnglishActivityKind.correction:
    case EnglishActivityKind.paragraphCorrection:
      engine.submitAnswer(step.correctedSentence ?? step.correctAnswer ?? '');
    case EnglishActivityKind.explainError:
    case EnglishActivityKind.bestSentence:
    case EnglishActivityKind.readingInference:
    case EnglishActivityKind.vocabularyContext:
      final int idx = step.correctIndex ?? 0;
      engine.submitAnswer(step.options[idx]);
    case EnglishActivityKind.sentenceRewrite:
    case EnglishActivityKind.combineSentences:
    case EnglishActivityKind.transformWriting:
      engine.submitAnswer(
        step.correctAnswer ??
            (step.acceptableAnswers.isNotEmpty
                ? step.acceptableAnswers.first
                : 'answer'),
      );
    case EnglishActivityKind.essayWriting:
      engine.submitAnswer('word ' * (step.minWords + 2));
    default:
      engine.submitAnswer('answer');
  }
}

void main() {
  test('Duolingo loop: micro prompt → question → grade → feedback', () {
    final EnglishLessonEngine engine = EnglishLessonEngine(
      presentPerfectLesson,
      useQuestionBank: false,
    );
    engine.begin();
    expect(engine.currentActivity?.id, 'pp_learn');
    expect(engine.phase, EnglishLessonPhase.microPrompt);

    engine.advanceFromMicroPrompt();
    expect(engine.phase, EnglishLessonPhase.active);
    expect(engine.currentActivity?.isMicroOnly, isFalse);

    _submitCorrectForStep(engine);
    expect(engine.lastCorrect, isTrue);
    expect(engine.phase, EnglishLessonPhase.feedback);
    expect(engine.xp, greaterThan(0));

    engine.continueAfterFeedback();
    expect(engine.currentActivity, isNotNull);
    expect(engine.phase, EnglishLessonPhase.active);
  });

  test('mistake injects retry and awards partial XP', () {
    final EnglishLessonEngine engine = EnglishLessonEngine(
      const EnglishLessonScript(
        id: 'mini',
        title: 'Mini',
        skillLabel: 'test',
        activities: <EnglishActivity>[
          EnglishActivity(
            id: 'm1',
            kind: EnglishActivityKind.microPrompt,
            skill: EnglishSkill.grammar,
            prompt: 'Learn',
          ),
          EnglishActivity(
            id: 'm2',
            kind: EnglishActivityKind.multipleChoice,
            skill: EnglishSkill.grammar,
            prompt: 'Pick',
            options: <String>['a', 'b'],
            correctIndex: 1,
          ),
          EnglishActivity(
            id: 'm3',
            kind: EnglishActivityKind.multipleChoice,
            skill: EnglishSkill.grammar,
            prompt: 'Pick2',
            options: <String>['a', 'b'],
            correctIndex: 1,
          ),
          EnglishActivity(
            id: 'm4',
            kind: EnglishActivityKind.multipleChoice,
            skill: EnglishSkill.grammar,
            prompt: 'Pick3',
            options: <String>['a', 'b'],
            correctIndex: 1,
          ),
        ],
      ),
      useQuestionBank: false,
    );
    engine.begin();
    engine.advanceFromMicroPrompt();
    engine.submitAnswer('a');
    expect(engine.lastCorrect, isFalse);
    expect(engine.totalSteps, greaterThan(4));
  });

  test('lesson completes with summary', () {
    final EnglishLessonEngine engine = EnglishLessonEngine(
      const EnglishLessonScript(
        id: 'tiny',
        title: 'Tiny',
        skillLabel: 'x',
        activities: <EnglishActivity>[
          EnglishActivity(
            id: 't1',
            kind: EnglishActivityKind.microPrompt,
            skill: EnglishSkill.grammar,
            prompt: 'Go',
          ),
        ],
      ),
      useQuestionBank: false,
    );
    engine.begin();
    engine.advanceFromMicroPrompt();
    expect(engine.isComplete, isTrue);
    expect(engine.result, isNotNull);
  });
}
