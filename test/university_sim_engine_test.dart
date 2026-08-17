import 'package:ai_study_buddy/data/university_learning_engine.dart';
import 'package:ai_study_buddy/vu_v2/labs/simulation/university_sim_factory.dart';
import 'package:ai_study_buddy/vu_v2/labs/simulation/university_sim_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const UniversityLabLink link = UniversityLabLink(
    labId: 'biology',
    stationId: 'practical',
    title: 'Cardiac emergency',
    purpose: 'Identify the implicated structure and stabilize circulation.',
    objectives: <String>['Identify', 'Intervene'],
    estimatedMinutes: 30,
    difficulty: 'Intermediate',
  );

  test('factory builds a lecture-linked mission, not a quiz bank', () {
    final SimBriefing brief = UniversitySimFactory.fromLesson(
      link: link,
      subjectId: 'biology',
      courseTitle: 'Human Anatomy',
      topicTitle: 'The heart and circulation',
      level: 2,
    );
    expect(brief.mission.toLowerCase(), contains('heart'));
    expect(brief.scenario, isNot(contains('Question 1')));
    expect(brief.steps.length, greaterThanOrEqualTo(3));
    expect(brief.steps.any((SimStep s) => s.kind == SimStepKind.locate), isTrue);
    expect(brief.steps.any((SimStep s) => s.kind == SimStepKind.measure), isTrue);
    expect(brief.steps.any((SimStep s) => s.kind == SimStepKind.applyTool), isTrue);
    expect(brief.equipment, isNotEmpty);
    expect(brief.role, isNotEmpty);
  });

  test('higher levels add a live complication', () {
    final SimBriefing guided = UniversitySimFactory.fromLesson(
      link: link,
      subjectId: 'biology',
      courseTitle: 'Anatomy',
      topicTitle: 'Skeletal system',
      level: 1,
    );
    final SimBriefing hard = UniversitySimFactory.fromLesson(
      link: link,
      subjectId: 'biology',
      courseTitle: 'Anatomy',
      topicTitle: 'Skeletal system',
      level: 5,
    );
    expect(guided.steps.length, lessThan(hard.steps.length));
    expect(hard.difficulty, 'Professional');
    expect(UniversitySimLevels.fromLessonCount(0), 1);
    expect(UniversitySimLevels.fromLessonCount(8), 5);
  });

  test('wrong actions move the board', () {
    final SimBriefing brief = UniversitySimFactory.fromLesson(
      link: link,
      subjectId: 'nursing',
      courseTitle: 'Adult Health',
      topicTitle: 'Airway management',
      level: 3,
    );
    final SimPlayState play = SimPlayState(
      briefing: brief,
      startedAt: DateTime.now(),
    );
    final double before = play.meter(brief.steps.first.failMeter);
    play.bump(brief.steps.first.failMeter, brief.steps.first.failDelta);
    expect(play.meter(brief.steps.first.failMeter), lessThan(before));
  });

  test('law and finance use different stations', () {
    final SimBriefing law = UniversitySimFactory.fromLesson(
      link: const UniversityLabLink(
        labId: 'law_firm',
        stationId: 'practical',
        title: 'Hearing',
        purpose: 'Issue-spot',
        objectives: <String>['Evidence'],
      ),
      subjectId: 'law',
      courseTitle: 'Torts',
      topicTitle: 'Negligence',
      level: 3,
    );
    final SimBriefing fin = UniversitySimFactory.fromLesson(
      link: const UniversityLabLink(
        labId: 'finance',
        stationId: 'practical',
        title: 'Desk',
        purpose: 'Risk',
        objectives: <String>['Size'],
      ),
      subjectId: 'finance',
      courseTitle: 'Investments',
      topicTitle: 'Duration risk',
      level: 3,
    );
    expect(law.domain, SimDomain.law);
    expect(fin.domain, SimDomain.finance);
    expect(law.boardTitle, isNot(equals(fin.boardTitle)));
  });
}
