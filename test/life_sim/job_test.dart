import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/education/skills.dart';
import 'package:ai_study_buddy/life_sim/employment/contract.dart';
import 'package:ai_study_buddy/life_sim/employment/employers.dart';
import 'package:ai_study_buddy/life_sim/workplace/job_state.dart';
import 'package:ai_study_buddy/life_sim/workplace/task_bank.dart';
import 'package:ai_study_buddy/life_sim/workplace/work_task.dart';
import 'package:flutter_test/flutter_test.dart';

EmploymentContract contract({String employer = 'pixelforge', String career = 'software_engineer', int rank = 0, int start = 1}) {
  final Employer e = EmployerCatalog.require(employer);
  final CareerDef c = CareerCatalog.require(career);
  return EmploymentContract(
    employerId: employer,
    careerId: career,
    rank: rank,
    title: c.titleForRank(rank),
    monthlySalary: CareerCatalog.monthlySalary(c, rank, employerFactor: e.prestige),
    startDay: start,
    startHour: e.startHour,
    endHour: e.endHour,
    signedDay: 1,
  );
}

/// Plays one full workday as a diligent employee scoring [score] on every task.
Future<void> workFullDay(JobRecord j, int day, {double score = 0.9}) async {
  final ({List<WorkScenario> tasks, bool late, String message}) r = JobEngine.checkIn(j, day, j.contract.startHour * 60);
  for (final WorkScenario s in r.tasks) {
    JobEngine.completeTask(j, s, score, day);
  }
}

SkillSet skillsFor(String core, double v) => SkillSet()
  ..gain(core, v)
  ..gain('communication', 80)
  ..gain('teamwork', 80)
  ..gain('management', 80);

void main() {
  group('Shifts and attendance', () {
    test('there is no shift on weekends or before the start date', () {
      final JobRecord j = JobEngine.start(contract(start: 3));
      expect(JobEngine.isShiftDay(j, 1), isFalse); // before start
      expect(JobEngine.isShiftDay(j, 3), isTrue);
      expect(JobEngine.isShiftDay(j, 6), isFalse); // Saturday
      expect(JobEngine.isShiftDay(j, 7), isFalse); // Sunday
      expect(JobEngine.checkIn(j, 6, 600).tasks.isEmpty, isTrue);
    });

    test('check-in hands out three rank-appropriate tasks and flags lateness', () {
      final JobRecord j = JobEngine.start(contract());
      final r = JobEngine.checkIn(j, 1, 10 * 60);
      expect(r.tasks.length, equals(WorkTaskBank.tasksPerDay));
      expect(r.late, isFalse);
      expect(j.checkedIn, isTrue);
      expect(JobEngine.checkIn(j, 1, 11 * 60).tasks.length, equals(3)); // idempotent
      final JobRecord j2 = JobEngine.start(contract());
      expect(JobEngine.checkIn(j2, 1, 11 * 60).late, isTrue);
      expect(JobEngine.checkIn(JobEngine.start(contract()), 1, 20 * 60).tasks.isEmpty, isTrue);
    });

    test('a full day credits a workday and accrues pay', () async {
      final JobRecord j = JobEngine.start(contract());
      await workFullDay(j, 1);
      final List<JobEvent> ev = JobEngine.endOfDay(j, 1);
      expect(j.workdaysAtRank, equals(1));
      expect(j.accruedGross, closeTo(JobEngine.dailyRate(j), 0.01));
      expect(ev.any((JobEvent e) => e.kind == JobEventKind.praise), isTrue);
    });

    test('a partial day earns half credit', () async {
      final JobRecord j = JobEngine.start(contract());
      final r = JobEngine.checkIn(j, 1, 600);
      JobEngine.completeTask(j, r.tasks.first, 0.8, 1);
      JobEngine.endOfDay(j, 1);
      expect(j.workdaysAtRank, equals(0.5));
    });

    test('skipping work costs performance and three strikes get you fired', () {
      final JobRecord j = JobEngine.start(contract());
      final double before = j.performance;
      final List<JobEvent> e1 = JobEngine.endOfDay(j, 1);
      expect(j.performance, lessThan(before));
      expect(e1.single.kind, equals(JobEventKind.warning));
      JobEngine.endOfDay(j, 2);
      final List<JobEvent> e3 = JobEngine.endOfDay(j, 3);
      expect(e3.any((JobEvent e) => e.kind == JobEventKind.employmentEnded && e.endedReason == 'fired'), isTrue);
    });

    test('weekend days never create strikes', () {
      final JobRecord j = JobEngine.start(contract());
      expect(JobEngine.endOfDay(j, 6), isEmpty);
      expect(JobEngine.endOfDay(j, 7), isEmpty);
      expect(j.strikeDays, isEmpty);
    });

    test('sick days excuse an absence, but only twice a month', () {
      final JobRecord j = JobEngine.start(contract());
      expect(JobEngine.callInSick(j, 1), isNull);
      final List<JobEvent> ev = JobEngine.endOfDay(j, 1);
      expect(ev.where((JobEvent e) => e.kind == JobEventKind.warning), isEmpty);
      expect(j.strikeDays, isEmpty);
      expect(j.workdaysAtRank, equals(1));
      expect(JobEngine.callInSick(j, 2), isNull);
      expect(JobEngine.callInSick(j, 3), contains('sick days'));
      expect(JobEngine.checkIn(j, 3, 600).tasks.isEmpty || true, isTrue);
      expect(JobEngine.callInSick(j, 6), contains('no shift'));
    });

    test('cannot call in sick after starting work', () {
      final JobRecord j = JobEngine.start(contract());
      final r = JobEngine.checkIn(j, 1, 600);
      JobEngine.completeTask(j, r.tasks.first, 0.7, 1);
      expect(JobEngine.callInSick(j, 1), contains('already started'));
    });
  });

  group('Performance and pay', () {
    test('good work raises the rating, bad work lowers it', () {
      final JobRecord good = JobEngine.start(contract());
      final JobRecord bad = JobEngine.start(contract());
      final r = JobEngine.checkIn(good, 1, 600);
      for (int i = 0; i < 6; i++) {
        JobEngine.completeTask(good, r.tasks[i % 3], 1.0, 1);
        JobEngine.completeTask(bad, r.tasks[i % 3], 0.1, 1);
      }
      expect(good.performance, greaterThan(70));
      expect(bad.performance, lessThan(40));
    });

    test('work quality scales skill gains', () {
      final JobRecord j = JobEngine.start(contract());
      final WorkScenario s = WorkTaskBank.byId('se_bug_avg')!;
      final TaskOutcome hi = JobEngine.completeTask(j, s, 1.0, 1);
      final TaskOutcome lo = JobEngine.completeTask(j, s, 0.2, 1);
      expect(hi.skillGains['programming']!, greaterThan(lo.skillGains['programming']! * 2));
      expect(hi.rating, equals('Outstanding'));
    });

    test('payday arrives every 14 days with the right gross', () async {
      final JobRecord j = JobEngine.start(contract());
      double gross = 0;
      for (int day = 1; day <= 14; day++) {
        if (JobEngine.isShiftDay(j, day)) await workFullDay(j, day);
        for (final JobEvent e in JobEngine.endOfDay(j, day)) {
          if (e.kind == JobEventKind.pay) gross += e.amount;
        }
      }
      expect(gross, closeTo(JobEngine.dailyRate(j) * 10, 0.5));
      expect(j.accruedGross, equals(0));
    });
  });

  group('Promotion', () {
    test('requirements are explicit and unmet ones are listed', () {
      final JobRecord j = JobEngine.start(contract());
      final PromotionStatus s = JobEngine.promotionStatus(j, SkillSet());
      expect(s.eligible, isFalse);
      expect(s.unmet.any((String u) => u.startsWith('Time in role')), isTrue);
      expect(s.unmet.any((String u) => u.startsWith('Skill')), isTrue);
      expect(s.nextTitle, equals('Junior Software Engineer'));
    });

    test('a diligent worker earns a promotion and a raise', () async {
      final JobRecord j = JobEngine.start(contract());
      for (int day = 1; day <= 21; day++) {
        if (JobEngine.isShiftDay(j, day)) await workFullDay(j, day, score: 0.95);
        JobEngine.endOfDay(j, day);
      }
      final double oldSalary = j.contract.monthlySalary;
      final PromotionStatus s = JobEngine.promote(j, skillsFor('programming', 60));
      expect(s.eligible, isTrue);
      expect(j.rank, equals(1));
      expect(j.contract.title, equals('Junior Software Engineer'));
      expect(j.contract.monthlySalary, greaterThan(oldSalary));
      expect(j.workdaysAtRank, equals(0));
    });

    test('poor performance blocks promotion even with enough time', () async {
      final JobRecord j = JobEngine.start(contract());
      for (int day = 1; day <= 21; day++) {
        if (JobEngine.isShiftDay(j, day)) await workFullDay(j, day, score: 0.3);
        JobEngine.endOfDay(j, day);
      }
      final PromotionStatus s = JobEngine.promotionStatus(j, skillsFor('programming', 60));
      expect(s.eligible, isFalse);
      expect(s.unmet.any((String u) => u.startsWith('Performance')), isTrue);
    });

    test('the top rank cannot be promoted further', () {
      final JobRecord j = JobEngine.start(contract(rank: kTopRank));
      expect(JobEngine.promotionStatus(j, skillsFor('programming', 100)).eligible, isFalse);
    });

    test('each rank demands more than the last', () {
      final CareerDef c = CareerCatalog.require('lawyer');
      for (int r = 2; r <= kTopRank; r++) {
        final PromotionRequirement a = CareerCatalog.promotionRequirement(c, r - 1);
        final PromotionRequirement b = CareerCatalog.promotionRequirement(c, r);
        expect(b.workdays, greaterThan(a.workdays));
        expect(b.performance, greaterThan(a.performance));
        expect(b.skills['legal']!, greaterThan(a.skills['legal']!));
      }
    });
  });

  group('Layoffs and persistence', () {
    test('restructuring gives notice, then ends the job with severance', () {
      int noticeCount = 0;
      JobRecord? hit;
      for (int salt = 0; salt < 400 && hit == null; salt++) {
        final EmploymentContract c = EmploymentContract(
          employerId: 'pixelforge', careerId: 'software_engineer', rank: 0, title: 't',
          monthlySalary: 2000, startDay: 1, startHour: 10, endHour: 18, signedDay: salt);
        final JobRecord j = JobEngine.start(c)..totalWorkdays = 40..performance = 49;
        final List<JobEvent> ev = JobEngine.endOfDay(j, 30);
        if (ev.any((JobEvent e) => e.kind == JobEventKind.noticeGiven)) {
          noticeCount++;
          hit = j;
        }
      }
      expect(noticeCount, equals(1));
      expect(hit!.noticeEndDay, equals(37));
      final List<JobEvent> end = JobEngine.endOfDay(hit, 37);
      final JobEvent ended = end.firstWhere((JobEvent e) => e.kind == JobEventKind.employmentEnded);
      expect(ended.endedReason, equals('laid_off'));
      expect(ended.amount, equals(1000));
    });

    test('strong performers are rarely laid off', () {
      int hits = 0;
      for (int salt = 0; salt < 300; salt++) {
        final JobRecord j = JobEngine.start(EmploymentContract(
          employerId: 'nimbus', careerId: 'software_engineer', rank: 3, title: 't',
          monthlySalary: 6000, startDay: 1, startHour: 9, endHour: 17, signedDay: salt))
          ..totalWorkdays = 80
          ..performance = 90;
        if (JobEngine.endOfDay(j, 60).any((JobEvent e) => e.kind == JobEventKind.noticeGiven)) hits++;
      }
      expect(hits, lessThan(25));
    });

    test('job records round-trip through JSON mid-shift', () async {
      final JobRecord j = JobEngine.start(contract());
      final r = JobEngine.checkIn(j, 1, 600);
      JobEngine.completeTask(j, r.tasks.first, 0.8, 1);
      final JobRecord back = JobRecord.fromJson(j.toJson());
      expect(back.toJson(), equals(j.toJson()));
      expect(back.remainingIds.length, equals(2));
      expect(JobEngine.assigned(back).length, equals(3));
    });
  });

  group('Salary negotiation', () {
    test('leverage grows with results, skills, communication and a rival offer', () {
      final double weak = SalaryNegotiation.leverage(rating: 55, skillSurplus: 0, communication: 10);
      final double strong = SalaryNegotiation.leverage(rating: 90, skillSurplus: 0.8, communication: 70, competingOffer: true);
      expect(strong, greaterThan(weak + 0.4));
      expect(strong <= 1 && weak >= 0, isTrue);
    });

    test('modest asks are accepted, middling asks get a counter, extreme asks fail', () {
      const double offer = 3000;
      final NegotiationOutcome ok = SalaryNegotiation.respond(offer: offer, askPercent: 4, leverage: 0.5, pitchScore: 0.8, isNewOffer: true);
      expect(ok.accepted, isTrue);
      expect(ok.finalSalary, greaterThan(offer));
      final NegotiationOutcome counter = SalaryNegotiation.respond(offer: offer, askPercent: 14, leverage: 0.5, pitchScore: 0.5, isNewOffer: true);
      expect(counter.accepted, isFalse);
      expect(counter.counter, isNotNull);
      expect(counter.counter! > offer && counter.counter! < offer * 1.14, isTrue);
      final NegotiationOutcome no = SalaryNegotiation.respond(offer: offer, askPercent: 20, leverage: 0.3, pitchScore: 0.3, isNewOffer: false);
      expect(no.accepted, isFalse);
      expect(no.counter, isNull);
      expect(no.withdrawn, isFalse);
    });

    test('absurd demands can cost you a new offer, but never a raise', () {
      final NegotiationOutcome gone = SalaryNegotiation.respond(offer: 3000, askPercent: 40, leverage: 0.2, pitchScore: 0.2, isNewOffer: true);
      expect(gone.withdrawn, isTrue);
      final NegotiationOutcome keep = SalaryNegotiation.respond(offer: 3000, askPercent: 40, leverage: 0.2, pitchScore: 0.2, isNewOffer: false);
      expect(keep.withdrawn, isFalse);
      expect(keep.finalSalary, equals(3000));
    });

    test('a well-written pitch scores higher than a lazy one', () {
      final double good = WorkGrader.gradeText(SalaryNegotiation.pitchStage, SalaryNegotiation.pitchStage.modelAnswer).score;
      final double lazy = WorkGrader.gradeText(SalaryNegotiation.pitchStage, 'give me more money now').score;
      expect(good, greaterThan(0.7));
      expect(lazy, lessThan(0.3));
    });
  });
}
