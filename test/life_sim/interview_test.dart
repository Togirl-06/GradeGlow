import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/education/skills.dart';
import 'package:ai_study_buddy/life_sim/employment/employers.dart';
import 'package:ai_study_buddy/life_sim/employment/job_listing.dart';
import 'package:ai_study_buddy/life_sim/employment/qualifications.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_judge.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_questions.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_session.dart';
import 'package:flutter_test/flutter_test.dart';

const String goodAbout =
    'I recently finished my computer science degree, where I built a scheduling app for my class that '
    '120 students now use every week. I am passionate about writing clean code and learning from a team. '
    'My goal is to grow into a strong software engineer, and this role is a great next step for me.';
const String goodWhy =
    'I admire the team at Pixelforge because you value creativity and learning, and your games reach real players. '
    'I want to contribute my programming skills and learn from experienced engineers, and I would take ownership of my tickets.';
const String goodStrength =
    'My biggest strengths are problem solving and reliability. For example, when our project had a bug two days before '
    'a deadline, I led the debugging, reproduced it, fixed the root cause and added a test, so we shipped on time.';
const String goodTech =
    'First I would reproduce the crash with that customer input, then check the logs and stack trace to isolate it. '
    'Usually it is an edge case such as a null value, so I would fix it, write a regression test, and review it with a teammate.';
const String goodHire =
    'I bring solid programming skills, a record of delivering projects with measurable results, and a real eagerness to learn. '
    'I am reliable, I work well in a team, and I would be a great fit. Thank you for the opportunity.';
const String badSlang = 'idk lol yeah i guess maybe i just wanna job dude';

PlayerQualifications qual({int edu = 2, double pro = 4, List<String> traits = const <String>[]}) {
  final SkillSet s = SkillSet()
    ..gain('programming', 40)
    ..gain('communication', 25);
  return PlayerQualifications(educationRank: edu, skills: s, professionalism: pro, traits: traits);
}

InterviewContext ctx(InterviewQuestion q, String a, {String employer = 'pixelforge'}) {
  return InterviewContext(
    question: q,
    questionText: q.render(employer: 'Pixelforge Studios', role: 'Engineering Intern'),
    answer: a,
    employer: EmployerCatalog.require(employer),
    career: CareerCatalog.require('software_engineer'),
    rank: 0,
  );
}

void main() {
  const HeuristicInterviewJudge judge = HeuristicInterviewJudge();

  group('HeuristicInterviewJudge', () {
    test('empty answer scores zero everywhere', () {
      final AnswerEvaluation e = judge.score(ctx(InterviewQuestionBank.about, '   '));
      expect(e.overall, equals(0));
      for (final String d in InterviewDims.all) {
        expect(e.scores[d], equals(0));
      }
    });

    test('strong answers score well, weak ones poorly', () {
      final double good = judge.score(ctx(InterviewQuestionBank.about, goodAbout)).overall;
      final double bad = judge.score(ctx(InterviewQuestionBank.about, badSlang)).overall;
      expect(good, greaterThan(65));
      expect(bad, lessThan(35));
      expect(good - bad, greaterThan(30));
    });

    test('technical answer with the right concepts beats a vague one', () {
      final InterviewQuestion q = InterviewQuestionBank.byCareer['software_engineer']![0];
      final double good = judge.score(ctx(q, goodTech)).overall;
      final double vague = judge.score(ctx(q, 'I would look at the code and try to fix it somehow.')).overall;
      expect(good, greaterThan(vague + 20));
    });

    test('slang, hedging and profanity hurt professionalism and confidence', () {
      final AnswerEvaluation e = judge.score(ctx(InterviewQuestionBank.strengths, 'Dude idk, maybe I am kinda good at stuff lol. my old boss was stupid, damn.'));
      expect(e.scores[InterviewDims.professionalism]!, lessThan(4));
      expect(e.scores[InterviewDims.confidence]!, lessThan(5));
    });

    test('examples dimension rewards concrete evidence', () {
      final double withEx = judge.score(ctx(InterviewQuestionBank.strengths, goodStrength)).scores[InterviewDims.examples]!;
      final double without = judge.score(ctx(InterviewQuestionBank.strengths, 'I am a hard worker and I like working with people and I learn things quickly in every situation.')).scores[InterviewDims.examples]!;
      expect(withEx, greaterThan(without + 3));
    });

    test('short vague answers trigger a follow-up; polished ones do not', () {
      final AnswerEvaluation shortA = judge.score(ctx(InterviewQuestionBank.challenge, 'It was hard but I managed.'));
      expect(shortA.followUp, isNotNull);
      final AnswerEvaluation longA = judge.score(ctx(InterviewQuestionBank.challenge, goodStrength));
      expect(longA.followUp, isNull);
    });

    test('all scores stay within 0..10', () {
      for (final String a in <String>[goodAbout, badSlang, 'a', 'A' * 800, goodTech * 6]) {
        final AnswerEvaluation e = judge.score(ctx(InterviewQuestionBank.why, a));
        for (final double v in e.scores.values) {
          expect(v >= 0 && v <= 10, isTrue);
        }
      }
    });
  });

  group('InterviewQuestionBank', () {
    test('every career has role-specific questions and the six classics exist', () {
      for (final CareerDef c in CareerCatalog.all) {
        expect(InterviewQuestionBank.byCareer[c.id]!.length, equals(3));
      }
      final List<InterviewQuestion> rank2 = InterviewQuestionBank.forRole('nurse', 2);
      final String joined = rank2.map((InterviewQuestion q) => q.text).join('|').toLowerCase();
      for (final String s in <String>['tell me about yourself', 'why do you want', 'strengths', 'challenge', 'conflict', 'why should we hire']) {
        expect(joined.contains(s), isTrue, reason: s);
      }
    });

    test('interviews get longer with seniority', () {
      expect(InterviewQuestionBank.forRole('lawyer', 0).length, lessThan(InterviewQuestionBank.forRole('lawyer', 2).length));
    });
  });

  group('InterviewSession', () {
    JobListing listing = JobBoard.byId('pixelforge:software_engineer:0')!;

    test('asks one question at a time and reaches a decision', () async {
      final InterviewSession s = InterviewSession.start(
        listing: listing,
        qualifications: qual(),
        judge: judge,
        matchScore: 80,
        seed: 't1',
      );
      expect(s.greeting.isNotEmpty, isTrue);
      final List<String> answers = <String>[goodAbout, goodWhy, goodStrength, goodTech, goodHire];
      int i = 0;
      while (!s.finished) {
        expect(s.currentPrompt.isNotEmpty, isTrue);
        await s.submit(i < answers.length ? answers[i] : goodStrength);
        i++;
      }
      expect(s.turns.length, greaterThanOrEqualTo(5));
      final InterviewResult r = s.result(applicationId: 'a1');
      expect(r.decision, equals(HireDecision.offer));
      expect(r.offerSalary, isNotNull);
      expect(r.interviewScore, greaterThan(65));
      expect(r.strengths.isNotEmpty, isTrue);
    });

    test('poor interview is rejected with actionable feedback', () async {
      final InterviewSession s = InterviewSession.start(
        listing: listing,
        qualifications: qual(pro: 0),
        judge: judge,
        matchScore: 60,
        seed: 't2',
      );
      while (!s.finished) {
        await s.submit(badSlang);
      }
      final InterviewResult r = s.result(applicationId: 'a2');
      expect(r.decision, equals(HireDecision.reject));
      expect(r.improvements.isNotEmpty, isTrue);
      expect(r.offerSalary, isNull);
    });

    test('follow-ups are capped and do not stall the interview', () async {
      final InterviewSession s = InterviewSession.start(
        listing: JobBoard.byId('nimbus:software_engineer:2')!,
        qualifications: qual(),
        judge: judge,
        matchScore: 70,
      );
      int guard = 0;
      while (!s.finished && guard++ < 40) {
        await s.submit('It was fine.');
      }
      expect(s.finished, isTrue);
      expect(s.turns.where((InterviewTurn t) => t.isFollowUp).length, lessThanOrEqualTo(InterviewSession.maxFollowUps));
    });

    test('selective employers need a higher hiring score', () {
      final JobListing easy = JobBoard.byId('pixelforge:software_engineer:1')!;
      final JobListing hard = JobBoard.byId('nimbus:software_engineer:1')!;
      final InterviewSession a = InterviewSession.start(listing: easy, qualifications: qual(), judge: judge);
      final InterviewSession b = InterviewSession.start(listing: hard, qualifications: qual(), judge: judge);
      expect(a.employer.hiringBar, lessThan(b.employer.hiringBar));
    });

    test('results require at least one answer', () {
      final InterviewSession s = InterviewSession.start(listing: listing, qualifications: qual(), judge: judge);
      expect(() => s.result(), throwsStateError);
    });
  });
}
