import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/content/cs_content.dart';
import 'package:ai_study_buddy/career_sim/content/nursing_content.dart';
import 'package:ai_study_buddy/career_sim/engine/career_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/interview_engine.dart';
import 'package:ai_study_buddy/career_sim/engine/text_rubric.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:flutter_test/flutter_test.dart';

T _task<T extends TaskSpec>(String moduleId, String taskId) =>
    CareerCatalog.module(moduleId)!.practice.firstWhere((TaskSpec t) => t.id == taskId) as T;

void main() {
  group('written rubric', () {
    const List<Concept> rubric = <Concept>[
      Concept('a', 'Reproduce', <String>['reproduce']),
      Concept('b', 'Regression test', <String>['regression test*']),
    ];

    test('a keyword list does not score', () {
      final TextAssessment t = TextRubric.assess('reproduce regression tests reproduce', rubric, minWords: 10);
      expect(t.hits, isEmpty);
      expect(t.score, lessThan(30));
    });

    test('concepts count inside real sentences', () {
      final TextAssessment t = TextRubric.assess(
        'First I would reproduce the failure on my own machine. Then I would add regression tests so it never returns.',
        rubric,
        minWords: 10,
      );
      expect(t.hits.length, 2);
      expect(t.score, greaterThanOrEqualTo(95));
    });

    test('stems match word endings', () {
      expect(TextRubric.mentions('we prioritised the sickest', const Concept('p', 'p', <String>['prioriti*'])), isTrue);
      expect(TextRubric.mentions('priority', const Concept('p', 'p', <String>['prioriti*'])), isFalse);
    });
  });

  group('task grading', () {
    test('decision: a critical safety error fails regardless of score', () {
      final DecisionTaskSpec s = _task<DecisionTaskSpec>('nu_m1', 'high_bp');
      final TaskResult good = TaskGrader.grade(s, const DecisionAnswer(<int>[0, 0, 0, 0]));
      expect(good.score, 100);
      expect(good.passed, isTrue);
      final TaskResult unsafe = TaskGrader.grade(s, const DecisionAnswer(<int>[1, 0, 0, 0]));
      expect(unsafe.passed, isFalse);
      expect(unsafe.feedback.first, contains('critical'));
    });

    test('decision: incomplete answers are refused, not graded', () {
      final DecisionTaskSpec s = _task<DecisionTaskSpec>('nu_m1', 'high_bp');
      expect(() => TaskGrader.grade(s, const DecisionAnswer(<int>[0, 0])), throwsA(isA<TaskGradingException>()));
      expect(() => TaskGrader.grade(s, const DecisionAnswer(<int>[0, 0, -1, 0])), throwsA(isA<TaskGradingException>()));
    });

    test('numeric: tolerance and missing values', () {
      final NumericTaskSpec s = _task<NumericTaskSpec>('nu_m2', 'dosage');
      expect(TaskGrader.grade(s, const NumericAnswer(<double?>[3, 330, 125])).score, 100);
      final TaskResult wrong = TaskGrader.grade(s, const NumericAnswer(<double?>[30, 330, 125]));
      expect(wrong.score, 67);
      expect(wrong.passed, isFalse);
      expect(wrong.feedback.single, contains('Method'));
      expect(wrong.feedback.single, isNot(contains('3 mL')));
      expect(() => TaskGrader.grade(s, const NumericAnswer(<double?>[3, null, 125])), throwsA(isA<TaskGradingException>()));
    });

    test('ledger: debit, credit and amount are each checked', () {
      final LedgerTaskSpec s = _task<LedgerTaskSpec>('bz_m_acct', 'ledger');
      final List<LedgerLineInput> right = s.transactions
          .map((LedgerTransaction t) => LedgerLineInput(debit: t.debit, credit: t.credit, amount: t.amount))
          .toList();
      expect(TaskGrader.grade(s, LedgerAnswer(right)).score, 100);
      final List<LedgerLineInput> swapped = s.transactions
          .map((LedgerTransaction t) => LedgerLineInput(debit: t.credit, credit: t.debit, amount: t.amount))
          .toList();
      expect(TaskGrader.grade(s, LedgerAnswer(swapped)).score, 33);
    });

    test('order: pairwise ordering', () {
      final OrderTaskSpec s = _task<OrderTaskSpec>('cs_m3', 'debug_loop');
      expect(TaskGrader.grade(s, const OrderAnswer(<int>[0, 1, 2, 3, 4, 5])).score, 100);
      expect(TaskGrader.grade(s, const OrderAnswer(<int>[5, 4, 3, 2, 1, 0])).score, 0);
      expect(() => TaskGrader.grade(s, const OrderAnswer(<int>[0, 0, 1, 2, 3, 4])), throwsA(isA<TaskGradingException>()));
    });

    test('courtroom: needless objections are wrong too', () {
      final CourtroomTaskSpec s = _task<CourtroomTaskSpec>('law_m3', 'hale_trial');
      final List<String?> right = s.transcript.map((TranscriptLine l) => l.objection).toList();
      expect(TaskGrader.grade(s, CourtroomAnswer(right)).score, 100);
      final List<String?> objectAll = s.transcript.map((TranscriptLine l) => 'Leading').toList();
      expect(TaskGrader.grade(s, CourtroomAnswer(objectAll)).passed, isFalse);
    });

    test('work-up: wrong diagnosis fails even with good tests', () {
      final WorkupTaskSpec s = _task<WorkupTaskSpec>('md_m2', 'chest_pain');
      final Set<int> relevant = <int>{
        for (int i = 0; i < s.investigations.length; i++)
          if (s.investigations[i].relevant) i,
      };
      final TaskResult ok = TaskGrader.grade(s, WorkupAnswer(ordered: relevant, diagnosis: 0, management: const <int>[0, 0]));
      expect(ok.passed, isTrue);
      final TaskResult bad = TaskGrader.grade(s, WorkupAnswer(ordered: relevant, diagnosis: 1, management: const <int>[0, 0]));
      expect(bad.passed, isFalse);
    });

    test('label and classify', () {
      final LabelTaskSpec heart = _task<LabelTaskSpec>('md_m3', 'heart_label');
      expect(TaskGrader.grade(heart, LabelAnswer(heart.hotspots.map((Hotspot h) => h.answer).toList())).score, 100);
      final ClassifyTaskSpec c = _task<ClassifyTaskSpec>('cs_m1', 'complexity');
      expect(TaskGrader.grade(c, ClassifyAnswer(c.items.map((ClassifyItem i) => i.category).toList())).score, 100);
    });
  });

  group('readiness, screening and hiring', () {
    final Department cs = CareerCatalog.department('cs')!;
    final JobPosting intern = CareerCatalog.posting('cs_intern_northwind')!;

    CareerProfile ready() {
      final CareerProfile p = CareerProfile(deptId: 'cs', stage: CareerStage.trainee, day: 5);
      p.completedModules.addAll(<String>['cs_m1', 'cs_m2', 'cs_m3']);
      p.skillPoints.addAll(<String, double>{'cs_prog': 2, 'cs_ds': 2, 'cs_debug': 2});
      p.portfolio.add(const PortfolioItem(id: 'cs_p1', deptId: 'cs', title: 'Booking', summary: '', score: 95, skills: <String>[], day: 3));
      p.resume = const Resume(
        fullName: 'Ada Student',
        email: 'ada@example.com',
        headline: 'Computer Science student',
        summary: 'I am a computer science student who enjoys building reliable backend services and debugging hard problems. '
            'I have shipped two projects with hidden tests passing in the judge and I write clear pull requests.',
        education: <ResumeEntry>[ResumeEntry(heading: 'BSc Computer Science', detail: 'GradeGlow University')],
        skills: <String>['Python', 'Hash maps', 'Debugging'],
        projectIds: <String>['cs_p1'],
      );
      return p;
    }

    const String letter =
        'Dear hiring manager, I am applying for the Software Engineering Intern role at Northwind Pay because I am excited '
        'by your mission to make payments simple for small businesses. During my training I completed modules on hash maps, '
        'stacks and debugging, and I built a booking service project for my portfolio that passed every hidden test. I '
        'developed skills in Python and data structures, and I am able to write clear pull request descriptions and '
        'regression tests. I am interested in the Payments Platform squad because reliable software matters to the people who '
        'depend on it. Thank you for considering my application, and I look forward to the opportunity to discuss it.';

    test('readiness counts the labs of the student\'s own major track', () {
      final CareerProfile p = CareerProfile(deptId: 'cs');
      expect(CareerRules.trackLabs(p, 'cs').every((LabSpec l) => l.majorId == 'computer_science'), isTrue);
      p.labCompletions.add(const LabCompletion(labId: 'se_lab_git', scenarioId: 'sgc_feature_1', score: 90, passed: true, day: 3));
      final List<LabSpec> track = CareerRules.trackLabs(p, 'cs');
      expect(track.map((LabSpec l) => l.majorId).toSet(), <String>{'software_engineering'});
      expect(track.length, 6);
    });

    test('readiness only counts graded evidence', () {
      final CareerProfile empty = CareerProfile(deptId: 'cs');
      expect(CareerRules.readiness(empty, cs).score, 0);
      expect(CareerRules.readiness(ready(), cs, job: intern).score, greaterThanOrEqualTo(60));
    });

    test('a qualified candidate is shortlisted with reasons', () {
      final CareerProfile p = ready();
      final JobApplication a = JobApplication(
        id: 'a', postingId: intern.id, status: ApplicationStatus.underReview, createdDay: 5,
        coverLetter: letter, portfolioIds: <String>['cs_p1'], submittedDay: 5,
      );
      final ScreeningReport r = CareerRules.screen(p, cs, intern, a, 7);
      expect(r.eligible, isTrue);
      expect(r.shortlisted, isTrue);
      expect(r.strengths, isNotEmpty);
    });

    test('students without trainee status are not eligible', () {
      final CareerProfile p = ready()..stage = CareerStage.student;
      final JobApplication a = JobApplication(
        id: 'a', postingId: intern.id, status: ApplicationStatus.underReview, createdDay: 5,
        coverLetter: letter, portfolioIds: <String>['cs_p1'], submittedDay: 5,
      );
      final ScreeningReport r = CareerRules.screen(p, cs, intern, a, 7);
      expect(r.eligible, isFalse);
      expect(r.gaps.first, contains('Trainee'));
    });

    test('hiring needs the practical and every competency ≥ 50', () {
      InterviewRecord rec({required int all, required bool practical}) => InterviewRecord(
            applicationId: 'a', day: 8, turns: const <InterviewTurn>[], communication: all, technical: all,
            problemSolving: all, readiness: all, candidateQuestions: const <String>[], practicalPassed: practical,
          );
      const ScreeningReport s = ScreeningReport(
          score: 80, eligible: true, shortlisted: true, strengths: <String>[], gaps: <String>[], breakdown: <String, int>{});
      final JobApplication a = JobApplication(id: 'a', postingId: intern.id, status: ApplicationStatus.interviewCompleted, createdDay: 1)
        ..screening = s
        ..interview = rec(all: 90, practical: true);
      expect(CareerRules.decide(intern, a).outcome, HiringOutcome.offer);
      a.interview = rec(all: 90, practical: false);
      expect(CareerRules.decide(intern, a).outcome, isNot(HiringOutcome.offer));
      a.interview = rec(all: 30, practical: true);
      expect(CareerRules.decide(intern, a).outcome, HiringOutcome.reject);
    });

    test('offer salary scales within the posted range', () {
      expect(CareerRules.offerSalary(intern, 70), intern.salaryMin);
      expect(CareerRules.offerSalary(intern, 100), intern.salaryMax);
    });
  });

  group('adaptive interview', () {
    test('a weak answer is probed; a strong answer is stretched', () {
      final InterviewSession s = InterviewSession(plan: csInterview, company: csPostings.first.company, applicationId: 'x', day: 1);
      expect(s.current!.id, 'cs_b1');
      s.answerOpen('I did a project.');
      expect(s.current!.id, 'cs_b1p');
      s.answerOpen('I wrote the sorting function myself and verified it with tests that passed in the judge every time.');
      expect(s.current!.id, 'cs_t1');
      s.answerChoice(0);
      expect(s.current!.id, 'cs_t1s');
      expect(s.turns.where((InterviewTurn t) => t.isFollowUp).length, 1);
    });

    test('candidate questions are answered from the company profile', () {
      final InterviewSession s = InterviewSession(plan: nursingInterview, company: nursingPostings.first.company, applicationId: 'x', day: 1);
      final CandidateAnswer a = s.ask('What training and mentoring do new nurses get?');
      expect(a.topic, 'training');
      expect(a.reply, nursingPostings.first.company.training);
    });
  });

  group('workplace', () {
    test('supervisor evaluation weighs quality, timeliness and the handoff note', () {
      final AssignmentRecord r = AssignmentRecord(assignmentId: 'x', issuedDay: 1, dueDay: 2, submittedDay: 4);
      const TaskResult pass = TaskResult(taskId: 't', score: 100, passed: true);
      final SupervisorEvaluation late = CareerRules.evaluate(r, pass, 'Done.');
      expect(late.timeliness, 50);
      expect(late.communication, lessThan(40));
      const TaskResult fail = TaskResult(taskId: 't', score: 55, passed: false);
      expect(CareerRules.evaluate(r..submittedDay = 2, fail, 'x').overall, lessThanOrEqualTo(59));
    });

    test('promotion is refused until every criterion is met', () {
      final CareerProfile p = CareerProfile(deptId: 'cs', day: 30);
      final Employment e = Employment(
        id: 'e', postingId: 'cs_entry_northwind', deptId: 'cs', workplaceId: 'cs_northwind', employer: 'Northwind Pay',
        title: 'Associate Software Engineer', stage: CareerStage.entryLevel, salary: 52000, salaryPeriod: 'year', startDay: 1,
      );
      final Department cs = CareerCatalog.department('cs')!;
      expect(CareerRules.promotion(p, cs, e, 30).approved, isFalse);
      for (int i = 0; i < 3; i++) {
        e.assignments.add(AssignmentRecord(assignmentId: 'cs_a$i', issuedDay: i, dueDay: i + 2, submittedDay: i + 1)
          ..evaluation = const SupervisorEvaluation(
              quality: 90, timeliness: 100, communication: 80, overall: 90, rating: 'Exceeds expectations', comments: <String>[]));
      }
      expect(CareerRules.promotion(p, cs, e, 30).approved, isTrue);
      expect(CareerRules.promotion(p, cs, e, 30).to, CareerStage.junior);
    });
  });

  test('postings reopen so a missed deadline is not a dead end', () {
    final JobPosting j = CareerCatalog.posting('cs_intern_northwind')!;
    expect(PostingSchedule.isOpen(j, 1), isTrue);
    expect(PostingSchedule.isOpen(j, j.deadlineDay + 1), isFalse);
    expect(PostingSchedule.reopens(j, j.deadlineDay + 1), j.openDay + PostingSchedule.cycle);
    expect(PostingSchedule.isOpen(j, j.openDay + PostingSchedule.cycle), isTrue);
  });

  test('profile JSON round-trips', () {
    final CareerProfile p = CareerProfile(deptId: 'cs', day: 9, stage: CareerStage.intern);
    p.taskResults['cs_m1/pair_sum'] = const TaskResult(taskId: 'pair_sum', score: 100, passed: true, verdict: 'Accepted');
    p.applications.add(JobApplication(id: 'a', postingId: 'cs_intern_northwind', status: ApplicationStatus.hired, createdDay: 2)
      ..move(ApplicationStatus.hired, 6, 'ok'));
    p.writings['k'] = 'text';
    final CareerProfile q = CareerProfile.fromJson(p.toJson());
    expect(q.toJson(), p.toJson());
  });
}
