import 'package:ai_study_buddy/data/english/english_question_bank.dart';
import 'package:ai_study_buddy/data/english/lessons/present_perfect_lesson.dart';
import 'package:ai_study_buddy/data/english/lessons/prepositions_lesson.dart';
import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question bank adds topic-only extras to a session', () {
    final expanded =
        englishQuestionBank.expandLesson(presentPerfectLesson);
    expect(expanded.length, greaterThan(presentPerfectLesson.activities.length));
    expect(expanded.length, lessThanOrEqualTo(32));
  });

  test('extras never come from a different lesson topic', () {
    final expanded = englishQuestionBank.expandLesson(prepositionsLesson);
    final Set<String> coreIds =
        prepositionsLesson.activities.map((a) => a.id).toSet();
    final Iterable<String> extraIds = expanded
        .map((a) => a.id)
        .where((String id) => !coreIds.contains(id));

    for (final String id in extraIds) {
      expect(
        id.contains('prepositions_1'),
        isTrue,
        reason: 'Off-topic activity id: $id',
      );
    }
  });

  test('present perfect extras stay on present perfect topic', () {
    final expanded = englishQuestionBank.expandLesson(presentPerfectLesson);
    final Set<String> coreIds =
        presentPerfectLesson.activities.map((a) => a.id).toSet();
    for (final String id in expanded.map((a) => a.id)) {
      if (coreIds.contains(id)) continue;
      expect(id.contains('present_perfect_1'), isTrue);
    }
  });

  test('engine session uses topic bank only', () {
    final EnglishLessonEngine engine = EnglishLessonEngine(presentPerfectLesson);
    engine.begin();
    expect(engine.totalSteps, greaterThan(presentPerfectLesson.activities.length));
  });

  test('each lesson has topic supplements in the bank', () {
    expect(englishQuestionBank.bankSizeForLesson('passive_voice_1'), greaterThan(10));
    expect(englishQuestionBank.bankSizeForLesson('articles_1'), greaterThan(5));
  });

  test('extras prefer challenge-level questions', () {
    final expanded = englishQuestionBank.expandLesson(presentPerfectLesson);
    final Set<String> coreIds =
        presentPerfectLesson.activities.map((a) => a.id).toSet();
    final List<EnglishActivity> extras = expanded
        .where((a) => !coreIds.contains(a.id))
        .toList();

    int hardCount = 0;
    for (final EnglishActivity a in extras) {
      final bool hard = a.difficulty == EnglishActivityDifficulty.hard ||
          a.kind == EnglishActivityKind.correction ||
          a.kind == EnglishActivityKind.rapidReview;
      if (hard) hardCount++;
    }
    expect(hardCount, greaterThanOrEqualTo(6));
  });
}
