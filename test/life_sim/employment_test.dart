import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/education/skills.dart';
import 'package:ai_study_buddy/life_sim/employment/application.dart';
import 'package:ai_study_buddy/life_sim/employment/employers.dart';
import 'package:ai_study_buddy/life_sim/employment/job_listing.dart';
import 'package:ai_study_buddy/life_sim/employment/phone_inbox.dart';
import 'package:ai_study_buddy/life_sim/employment/qualifications.dart';
import 'package:ai_study_buddy/life_sim/employment/resume.dart';
import 'package:flutter_test/flutter_test.dart';

PlayerQualifications grad({
  String career = 'software_engineer',
  int edu = 2,
  double core = 32,
  double comm = 20,
  int days = 0,
  double pro = 3,
  Set<String> certs = const <String>{},
}) {
  final CareerDef c = CareerCatalog.require(career);
  final SkillSet s = SkillSet(certifications: certs.toSet())
    ..gain(c.coreSkill, core)
    ..gain('communication', comm)
    ..gain('teamwork', 10);
  return PlayerQualifications(
    educationRank: edu,
    skills: s,
    experienceDays: <String, int>{career: days},
    professionalism: pro,
  );
}

Resume goodResume() {
  return Resume(
    fullName: 'Ada Obi',
    email: 'ada.obi@glowmail.app',
    phone: '555-0142',
    summary: 'Recent computer science graduate who loves writing clean, tested code and learning from a team. '
        'I built an API and a scheduling app used by 120 students, and I want to contribute creativity and ownership '
        'to a product team shipping software for real players.',
    education: <EducationEntry>[
      const EducationEntry(degree: 'High school diploma', school: 'Glow City High', level: 'high_school'),
      const EducationEntry(degree: 'BSc Computer Science', school: 'GradeGlow University', level: 'bachelor'),
    ],
    skills: <String>['Programming', 'Communication', 'Teamwork', 'Problem solving'],
    experience: <ExperienceEntry>[
      const ExperienceEntry(
        role: 'Engineering Intern',
        employer: 'Pixelforge Studios',
        workdays: 12,
        bullets: <String>['Closed 14 tickets in 3 weeks'],
      ),
    ],
    projects: <ProjectEntry>[
      const ProjectEntry(
        title: 'Class scheduler',
        description: 'Built a scheduling app in Dart used by 120 students every week, cutting timetable clashes by 40 percent.',
      ),
      const ProjectEntry(
        title: 'Bug tracker',
        description: 'Designed a small bug tracker with tests and code review notes to learn team workflows properly.',
      ),
    ],
    certifications: <String>['Cloud Fundamentals'],
  );
}

void main() {
  group('Careers & job board', () {
    test('six careers with seven-rung ladders', () {
      expect(CareerCatalog.all.length, equals(6));
      for (final CareerDef c in CareerCatalog.all) {
        expect(c.rankTitles.length, equals(kTopRank + 1));
        expect(c.titleForRank(0).isNotEmpty, isTrue);
      }
      expect(CareerCatalog.require('software_engineer').titleForRank(6), contains('Director'));
    });

    test('salaries rise with rank and doctors earn more than nurses', () {
      final CareerDef nurse = CareerCatalog.require('nurse');
      final CareerDef doctor = CareerCatalog.require('doctor');
      for (int r = 1; r <= kTopRank; r++) {
        expect(CareerCatalog.monthlySalary(nurse, r), greaterThan(CareerCatalog.monthlySalary(nurse, r - 1)));
      }
      expect(CareerCatalog.monthlySalary(doctor, 2), greaterThan(CareerCatalog.monthlySalary(nurse, 2)));
    });

    test('every employer has an interviewer and a listing per rank', () {
      int expected = 0;
      for (final Employer e in EmployerCatalog.all) {
        expect(e.interviewer.name.isNotEmpty, isTrue);
        expected += e.hires.length * (JobBoard.maxExternalRank + 1);
      }
      expect(JobBoard.everything.length, equals(expected));
      expect(EmployerCatalog.hiringFor('doctor').length, equals(2));
    });

    test('listings carry title, salary, requirements, hours and duties', () {
      final JobListing l = JobBoard.byId('st_gabriel:nurse:2')!;
      expect(l.title, equals('Registered Nurse'));
      expect(l.monthlySalary, greaterThan(0));
      expect(l.requiredSkills.containsKey('clinical'), isTrue);
      expect(l.hoursLabel, contains('7am'));
      expect(l.responsibilities.isNotEmpty, isTrue);
      expect(l.minEducationRank, equals(2));
    });

    test('entry roles are always open; senior postings rotate', () {
      final JobListing intern = JobBoard.byId('nimbus:software_engineer:0')!;
      for (int d = 1; d < 60; d += 3) {
        expect(JobBoard.isOpen(intern, d), isTrue);
      }
      final JobListing senior = JobBoard.byId('nimbus:software_engineer:3')!;
      final Set<bool> seen = <bool>{for (int w = 0; w < 12; w++) JobBoard.isOpen(senior, 1 + w * 7)};
      expect(seen.length, equals(2));
    });
  });

  group('Resume coach', () {
    test('an empty resume scores low and says what to add', () {
      final ResumeReview rev = ResumeCoach.review(Resume(), careerId: 'software_engineer');
      expect(rev.score, lessThan(25));
      expect(rev.improvements.length, greaterThan(3));
      expect(rev.expectations.isNotEmpty, isTrue);
    });

    test('a complete, tailored resume scores high', () {
      final JobListing l = JobBoard.byId('pixelforge:software_engineer:0')!;
      final ResumeReview rev = ResumeCoach.review(goodResume(), target: l);
      expect(rev.score, greaterThan(75));
      expect(rev.strengths.isNotEmpty, isTrue);
      expect(rev.sections['Projects']!, greaterThan(0.8));
    });

    test('tailoring to the employer raises the score', () {
      final Resume plain = goodResume()
        ..certifications = <String>[]
        ..projects = <ProjectEntry>[]
        ..summary = 'Recent computer science graduate who loves writing clean, tested code and working with a team. '
            'I built an API and a scheduling app used by 120 students and enjoy solving bugs in software projects.';
      final Resume tailored = goodResume()
        ..certifications = <String>[]
        ..projects = <ProjectEntry>[];
      final JobListing l = JobBoard.byId('pixelforge:software_engineer:0')!;
      expect(ResumeCoach.review(tailored, target: l).score, greaterThan(ResumeCoach.review(plain, target: l).score));
    });

    test('shouting is flagged', () {
      final Resume r = goodResume()..summary = 'I AM THE BEST ENGINEER YOU WILL EVER MEET!!! HIRE ME NOW';
      final ResumeReview rev = ResumeCoach.review(r, careerId: 'software_engineer');
      expect(rev.improvements.any((String s) => s.contains('CAPS')), isTrue);
    });

    test('syncFacts pulls education, jobs and certifications from the player record', () {
      final Resume r = Resume();
      r.syncFacts(
        avatar: AvatarProfile(name: 'Ada Obi'),
        q: grad(certs: <String>{'cert_cloud'}, core: 30),
        degrees: <EducationEntry>[const EducationEntry(degree: 'BSc CS', school: 'GradeGlow University', level: 'bachelor')],
        jobs: <ExperienceEntry>[const ExperienceEntry(role: 'Intern', employer: 'Pixelforge', workdays: 9)],
      );
      expect(r.fullName, equals('Ada Obi'));
      expect(r.email, contains('ada.obi'));
      expect(r.education.length, equals(2));
      expect(r.certifications, contains('Cloud Fundamentals'));
      expect(r.skills, contains('Programming'));
      final Resume r2 = Resume.fromJson(r.toJson());
      expect(r2.toJson(), equals(r.toJson()));
    });
  });

  group('Applications', () {
    final JobListing intern = JobBoard.byId('pixelforge:software_engineer:0')!;
    final JobListing midRole = JobBoard.byId('pixelforge:software_engineer:2')!;

    test('a qualified graduate clears an entry role', () {
      final ApplicationAssessment a = ApplicationEngine.assess(
        q: grad(), listing: intern, resumeScore: 70, seedKey: 's');
      expect(a.passes, isTrue);
      expect(a.strengths.isNotEmpty, isTrue);
    });

    test('lack of experience blocks mid-level roles with a clear reason', () {
      final ApplicationAssessment a = ApplicationEngine.assess(
        q: grad(), listing: midRole, resumeScore: 70, seedKey: 's');
      expect(a.passes, isFalse);
      expect(a.gaps.any((String g) => g.startsWith('Experience')), isTrue);
    });

    test('experience unlocks the same role', () {
      final ApplicationAssessment a = ApplicationEngine.assess(
        q: grad(days: 30, core: 45, comm: 30), listing: midRole, resumeScore: 78, seedKey: 's');
      expect(a.passes, isTrue);
    });

    test('high school education is a hard fail for professional roles', () {
      final ApplicationAssessment a = ApplicationEngine.assess(
        q: grad(edu: 0), listing: JobBoard.byId('ledger_co:accountant:2')!, resumeScore: 90, seedKey: 's');
      expect(a.hardFail, isTrue);
      expect(a.passes, isFalse);
    });

    test('selective employers are harder than friendly ones', () {
      final PlayerQualifications q = grad(core: 28, comm: 14);
      final double easy = ApplicationEngine.assess(
        q: q, listing: JobBoard.byId('pixelforge:software_engineer:1')!, resumeScore: 60, seedKey: 'k').score;
      final double hard = ApplicationEngine.assess(
        q: q, listing: JobBoard.byId('nimbus:software_engineer:1')!, resumeScore: 60, seedKey: 'k').score;
      expect(easy, greaterThan(hard));
    });

    test('responses arrive only after the delay, as phone messages', () {
      final PhoneInbox inbox = PhoneInbox();
      final ApplicationRecord a = ApplicationEngine.submit(
        id: 'a1', q: grad(), listing: intern, resumeScore: 72, today: 5);
      expect(a.respondDay, greaterThan(5));
      expect(a.status, equals(ApplicationStatus.pending));

      expect(ApplicationEngine.processResponses(
        applications: <ApplicationRecord>[a], inbox: inbox, today: 5, minuteOfDay: 600).isEmpty, isTrue);

      final List<PhoneMessage> msgs = ApplicationEngine.processResponses(
        applications: <ApplicationRecord>[a], inbox: inbox, today: a.respondDay, minuteOfDay: 600);
      expect(msgs.length, equals(1));
      expect(a.status, equals(ApplicationStatus.invited));
      expect(msgs.first.subject, contains('Interview invitation'));
      expect(msgs.first.action!['type'], equals('interview'));
      // Interview slot: weekday, inside employer hours.
      expect(((a.interviewDay! - 1) % 7) < 5, isTrue);
      expect(a.interviewHour! >= intern.startHour && a.interviewHour! < intern.endHour, isTrue);
      expect(inbox.unreadCount, equals(1));
    });

    test('rejections explain what to improve; reapplying has a cooldown', () {
      final PhoneInbox inbox = PhoneInbox();
      final ApplicationRecord a = ApplicationEngine.submit(
        id: 'a2', q: grad(), listing: midRole, resumeScore: 40, today: 10);
      expect(a.willInvite, isFalse);
      ApplicationEngine.processResponses(
        applications: <ApplicationRecord>[a], inbox: inbox, today: a.respondDay, minuteOfDay: 700);
      expect(a.status, equals(ApplicationStatus.rejected));
      expect(inbox.messages.first.body, contains('What would strengthen'));

      expect(ApplicationEngine.blockReason(<ApplicationRecord>[a], midRole, a.respondDay), isNotNull);
      expect(ApplicationEngine.blockReason(<ApplicationRecord>[a], midRole,
          a.respondDay + ApplicationEngine.cooldownAfterRejectionDays), isNull);
    });

    test('duplicate and over-limit applications are blocked', () {
      final ApplicationRecord a = ApplicationEngine.submit(
        id: 'a3', q: grad(), listing: intern, resumeScore: 72, today: 1);
      expect(ApplicationEngine.blockReason(<ApplicationRecord>[a], intern, 1), contains('already applied'));
      final List<ApplicationRecord> many = <ApplicationRecord>[
        for (int i = 0; i < ApplicationEngine.maxActive; i++)
          ApplicationEngine.submit(id: 'm$i', q: grad(), listing: JobBoard.everything[i], resumeScore: 70, today: 1),
      ];
      expect(ApplicationEngine.blockReason(many, JobBoard.byId('ledger_co:accountant:0')!, 1), contains('active applications'));
    });

    test('missing the interview slot closes the application', () {
      final PhoneInbox inbox = PhoneInbox();
      final ApplicationRecord a = ApplicationEngine.submit(
        id: 'a4', q: grad(), listing: intern, resumeScore: 72, today: 1);
      ApplicationEngine.processResponses(applications: <ApplicationRecord>[a], inbox: inbox, today: a.respondDay, minuteOfDay: 500);
      expect(a.status, equals(ApplicationStatus.invited));
      ApplicationEngine.processResponses(applications: <ApplicationRecord>[a], inbox: inbox, today: a.interviewDay! + 1, minuteOfDay: 500);
      expect(a.status, equals(ApplicationStatus.expired));
      expect(inbox.messages.first.subject, contains('Missed interview'));
    });

    test('waiting-list outcomes resolve into an offer or a rejection', () {
      final PhoneInbox inbox = PhoneInbox();
      final ApplicationRecord yes = ApplicationRecord(
        id: 'w1', listingId: intern.id, submittedDay: 1, respondDay: 2, matchScore: 70, resumeScore: 70,
        willInvite: true, status: ApplicationStatus.waitlisted, waitlistResolveDay: 6, waitlistWillOffer: true);
      final ApplicationRecord no = ApplicationRecord(
        id: 'w2', listingId: intern.id, submittedDay: 1, respondDay: 2, matchScore: 70, resumeScore: 70,
        willInvite: true, status: ApplicationStatus.waitlisted, waitlistResolveDay: 6);
      ApplicationEngine.processResponses(applications: <ApplicationRecord>[yes, no], inbox: inbox, today: 5, minuteOfDay: 0);
      expect(yes.status, equals(ApplicationStatus.waitlisted));
      ApplicationEngine.processResponses(applications: <ApplicationRecord>[yes, no], inbox: inbox, today: 6, minuteOfDay: 0);
      expect(yes.status, equals(ApplicationStatus.offer));
      expect(no.status, equals(ApplicationStatus.rejected));
    });

    test('records and inbox survive JSON round-trips', () {
      final ApplicationRecord a = ApplicationEngine.submit(
        id: 'j1', q: grad(), listing: intern, resumeScore: 72, today: 3);
      expect(ApplicationRecord.fromJson(a.toJson()).toJson(), equals(a.toJson()));
      final PhoneInbox inbox = PhoneInbox();
      inbox.add(kind: MessageKind.sms, from: 'Mum', subject: 'Hi', body: 'Good luck!', day: 1, minuteOfDay: 90);
      final PhoneInbox back = PhoneInbox.fromJson(inbox.toJson());
      expect(back.messages.single.body, equals('Good luck!'));
      expect(back.unreadCount, equals(1));
    });
  });
}
