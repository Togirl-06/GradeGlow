import 'package:ai_study_buddy/models/english_lesson.dart';
import 'package:ai_study_buddy/services/english_lesson_engine.dart';
import 'package:ai_study_buddy/services/english_writing_grader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final EnglishWritingGrader grader = const EnglishWritingGrader();

  test('formal greeting explains Dear', () {
    final GradeResult r = grader.gradeSync(
      activity: const EnglishActivity(
        id: 't1',
        kind: EnglishActivityKind.shortWriting,
        skill: EnglishSkill.writing,
        prompt: 'How do you greet in a formal letter?',
        writingTone: EnglishWritingTone.formal,
        minWords: 2,
        gradingCriteria: <String>['dear'],
      ),
      answer: 'Dear Sir or Madam,',
      lessonTitle: 'Email',
    );
    expect(r.correct, isTrue);
  });

  test('greet Luke formally', () {
    final GradeResult r = grader.gradeSync(
      activity: const EnglishActivity(
        id: 't2',
        kind: EnglishActivityKind.shortWriting,
        skill: EnglishSkill.writing,
        prompt: 'Greet Luke in a formal letter.',
        writingTone: EnglishWritingTone.formal,
        targetName: 'Luke',
        minWords: 2,
      ),
      answer: 'Dear Luke,',
      lessonTitle: 'Email',
    );
    expect(r.correct, isTrue);
  });

  test('greet Rob informally', () {
    final GradeResult r = grader.gradeSync(
      activity: const EnglishActivity(
        id: 't3',
        kind: EnglishActivityKind.shortWriting,
        skill: EnglishSkill.writing,
        prompt: 'Greet Rob in an informal letter.',
        writingTone: EnglishWritingTone.informal,
        targetName: 'Rob',
        minWords: 2,
      ),
      answer: 'Hey Rob,',
      lessonTitle: 'Email',
    );
    expect(r.correct, isTrue);
  });

  test('rejects Hi Luke for formal Luke greeting', () {
    final GradeResult r = grader.gradeSync(
      activity: const EnglishActivity(
        id: 't4',
        kind: EnglishActivityKind.shortWriting,
        skill: EnglishSkill.writing,
        prompt: 'Greet Luke in a formal letter.',
        writingTone: EnglishWritingTone.formal,
        targetName: 'Luke',
        minWords: 2,
      ),
      answer: 'Hi Luke,',
      lessonTitle: 'Email',
    );
    expect(r.correct, isFalse);
  });
}
