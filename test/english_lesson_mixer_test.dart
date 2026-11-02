import 'package:ai_study_buddy/data/english/lessons/present_perfect_lesson.dart';
import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_mixer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const EnglishLessonMixer mixer = EnglishLessonMixer();

  // The mixer keeps the lesson's own order: the warm-up prompt first, then the
  // core steps as written, then bank/challenge/retry extras (kinds varied).
  test('mixer keeps intro first, core steps in order, and every activity', () {
    final List<EnglishActivity> script = presentPerfectLesson.activities;
    final List<EnglishActivity> queue = mixer.buildQueue(script);
    expect(queue.length, script.length);
    expect(queue.map((EnglishActivity a) => a.id).toSet(), script.map((EnglishActivity a) => a.id).toSet());
    expect(queue.first.kind, EnglishActivityKind.microPrompt);
    final List<String> core = script
        .where((EnglishActivity a) => a.kind != EnglishActivityKind.microPrompt || a != script.first)
        .where((EnglishActivity a) => !a.id.startsWith('bank_') && !a.id.startsWith('ch_') && !a.id.contains('_retry'))
        .map((EnglishActivity a) => a.id)
        .toList();
    final List<String> queued = queue.skip(1).take(core.length).map((EnglishActivity a) => a.id).toList();
    expect(queued, core);
  });

  test('micro prompts resolve as easy; explicit difficulty is respected', () {
    final EnglishActivity micro = presentPerfectLesson.activities.firstWhere((EnglishActivity a) => a.isMicroOnly);
    expect(mixer.resolveDifficulty(micro), EnglishActivityDifficulty.easy);
    final EnglishActivity tagged = presentPerfectLesson.activities.firstWhere((EnglishActivity a) => a.difficulty != null);
    expect(mixer.resolveDifficulty(tagged), tagged.difficulty);
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
