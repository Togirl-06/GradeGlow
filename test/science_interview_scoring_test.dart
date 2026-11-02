import 'package:ai_study_buddy/vu_v2/science_career/interview_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<String> keys = <String>['400', 'test', 'reproduce', 'null', 'edge'];

  test('long filler answers do not pass (the old scorer passed them)', () {
    final String filler =
        'I am a very motivated and passionate person who loves learning new things every day and working hard with a team. ';
    final InterviewVerdict v = ScienceInterviewScoring.decide(<String>[filler, filler, filler], keys);
    expect(v.passed, isFalse);
    expect(v.scores['Technical correctness'], 1);
  });

  test('short answers do not pass', () {
    final InterviewVerdict v = ScienceInterviewScoring.decide(<String>['I would test it.', 'Null check.', 'Edge cases.'], keys);
    expect(v.passed, isFalse);
  });

  test('specific, reasoned answers pass', () {
    const List<String> answers = <String>[
      'First I would reproduce the 500 with a request that has no email, so that I can see the stack trace. '
          'Then I would check where the null value is read, because the handler assumes the field exists.',
      'I would return a 400 with a clear message instead of crashing, then add a regression test for the missing-email edge case. '
          'Finally I would verify the fix in staging and monitor the error rate.',
      'In review I would check the test covers null and empty strings, because those edge cases caused the original bug.',
    ];
    final InterviewVerdict v = ScienceInterviewScoring.decide(answers, keys);
    expect(v.passed, isTrue, reason: v.scores.toString());
    expect(v.scores.values.every((int x) => x >= 3), isTrue, reason: v.scores.toString());
  });

  test('keyword matching respects word boundaries', () {
    final InterviewAnswerScore s = ScienceInterviewScoring.scoreAnswer('I attested to the contest results.', <String>['test']);
    expect(s.keywordsUsed, isEmpty);
    expect(ScienceInterviewScoring.scoreAnswer('We tested it.', <String>['test']).keywordsUsed, contains('test'));
  });
}
