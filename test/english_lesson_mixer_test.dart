import 'package:ai_study_buddy/data/english/lessons/present_perfect_lesson.dart';
import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_mixer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const EnglishLessonMixer mixer = EnglishLessonMixer();

  test('mixer interleaves easy and hard steps', () {
    final List<EnglishActivity> queue =
        mixer.buildQueue(presentPerfectLesson.activities);
    expect(queue.length, presentPerfectLesson.activities.length);

    final List<EnglishActivityDifficulty> levels = queue
        .where((EnglishActivity a) => !a.isMicroOnly)
        .map(mixer.resolveDifficulty)
        .toList();

    expect(levels.contains(EnglishActivityDifficulty.easy), isTrue);
    expect(levels.contains(EnglishActivityDifficulty.hard), isTrue);
    expect(levels.contains(EnglishActivityDifficulty.medium), isTrue);

    // Not grouped all hard at the end.
    final int lastHard = levels.lastIndexWhere(
      (EnglishActivityDifficulty l) => l == EnglishActivityDifficulty.hard,
    );
    final int firstEasy = levels.indexWhere(
      (EnglishActivityDifficulty l) => l == EnglishActivityDifficulty.easy,
    );
    expect(firstEasy, lessThan(lastHard));
  });

  test('rapid review resolves as hard', () {
    const EnglishActivity rapid = EnglishActivity(
      id: 't',
      kind: EnglishActivityKind.rapidReview,
      skill: EnglishSkill.grammar,
      prompt: 'Test',
      options: <String>['a', 'b'],
      correctIndex: 0,
    );
    expect(
      mixer.resolveDifficulty(rapid),
      EnglishActivityDifficulty.hard,
    );
  });
}
