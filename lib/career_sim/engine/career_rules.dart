/// Validated, deterministic rules: skills, readiness, screening, hiring,
/// supervisor evaluation and promotion. Nothing here calls AI.
library;

import 'dart:math' as math;

import '../content/catalog.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import 'text_rubric.dart';

class Criterion {
  const Criterion(this.label, this.met, {this.detail = ''});
  final String label;
  final bool met;
  final String detail;
}

class ReadinessItem {
  const ReadinessItem(this.label, this.score, this.weight, this.advice);
  final String label;

  /// 0–100.
  final int score;
  final int weight;
  final String advice;
}

class ReadinessReport {
  const ReadinessReport(this.score, this.items);
  final int score;
  final List<ReadinessItem> items;

  String get band {
    if (score >= 85) return 'Strong';
    if (score >= 70) return 'Ready';
    if (score >= 50) return 'Developing';
    return 'Not ready';
  }
}

class PromotionReview {
  const PromotionReview({required this.to, required this.criteria, this.message = ''});
  final CareerStage? to;
  final List<Criterion> criteria;
  final String message;
  bool get approved => to != null && criteria.isNotEmpty && criteria.every((Criterion c) => c.met);
}

abstract final class CareerRules {
  // ------------------------------------------------------------- skills

  static const int practicePoints = 1;
  static const int projectPoints = 2;
  static const int assignmentPoints = 2;
  static const int certificationPoints = 3;

  static int skillLevel(double points) {
    if (points >= 8) return 3;
    if (points >= 4) return 2;
    if (points >= 1) return 1;
    return 0;
  }

  static String levelLabel(int level) => switch (level) {
        3 => 'Professional',
        2 => 'Practitioner',
        1 => 'Foundation',
        _ => 'Not yet shown',
      };

  static int levelOf(CareerProfile p, String skill) => skillLevel(p.skillPoints[skill] ?? 0);

  // ------------------------------------------------------------- modules

  static bool moduleComplete(CareerProfile p, TrainingModule m) =>
      p.studiedLessons.contains(m.id) &&
      m.practice.every((TaskSpec t) => p.taskResults['${m.id}/${t.id}']?.passed ?? false);

  static int deptProjects(CareerProfile p, String deptId) =>
      p.portfolio.where((PortfolioItem i) => i.deptId == deptId).length;

  // ------------------------------------------------------------- resume

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static List<Criterion> resumeChecklist(Resume r) => <Criterion>[
        Criterion('Full name', r.fullName.trim().length >= 3),
        Criterion('Valid email address', _email.hasMatch(r.email.trim())),
        Criterion('Professional headline', r.headline.trim().length >= 8),
        Criterion('Summary of at least 30 words', TextRubric.words(r.summary).length >= 30),
        Criterion('At least one education entry', r.education.isNotEmpty),
        Criterion('At least three skills', r.skills.length >= 3),
        Criterion('At least one portfolio project', r.projectIds.isNotEmpty),
      ];

  static double resumeCompleteness(Resume r) {
    final List<Criterion> c = resumeChecklist(r);
    return c.where((Criterion x) => x.met).length / c.length;
  }

  // ------------------------------------------------------------- cover letter

  static List<Concept> coverLetterRubric(JobPosting? job) => <Concept>[
        if (job != null) Concept('company', 'Names the employer', <String>[job.company.name]),
        if (job != null)
          Concept('role', 'Names the role', <String>[job.title, ...job.title.split(' ').where((String w) => w.length > 5)]),
        const Concept('evidence', 'Points to a project or task you completed',
            <String>['project', 'portfolio', 'built', 'developed', 'completed', 'designed', 'assignment', 'case', 'placement']),
        const Concept('skill', 'Names a relevant skill',
            <String>['skill*', 'experience in', 'experience with', 'proficien*', 'trained in', 'able to']),
        const Concept('motivation', 'Explains why this employer/role',
            <String>['because', 'interested', 'motivat*', 'excited', 'drawn to', 'admire', 'mission']),
        const Concept('close', 'Professional close',
            <String>['thank*', 'look forward', 'discuss', 'opportunity to']),
      ];

  static TextAssessment coverLetter(String text, JobPosting? job) =>
      TextRubric.assess(text, coverLetterRubric(job), minWords: 120, maxWords: 450);

  // ------------------------------------------------------------- readiness

  /// The labs of the student's major track within a department. A department
  /// can hold several majors (Computer Science also hosts Software Engineering,
  /// AI, Cybersecurity and more), and a student is only expected to complete
  /// the labs of their own track: the major in which they have passed the most
  /// labs, or the department's first major when they have passed none.
  static List<LabSpec> trackLabs(CareerProfile p, String deptId) {
    final List<LabSpec> labs = LabCatalog.forDept(deptId);
    if (labs.isEmpty) return labs;
    final Map<String, int> passed = <String, int>{};
    for (final LabSpec l in labs) {
      passed.putIfAbsent(l.majorId, () => 0);
      if (p.labPassed(l.id)) passed[l.majorId] = passed[l.majorId]! + 1;
    }
    String best = labs.first.majorId;
    for (final MapEntry<String, int> e in passed.entries) {
      if (e.value > passed[best]!) best = e.key;
    }
    return labs.where((LabSpec l) => l.majorId == best).toList();
  }

  static ReadinessReport readiness(CareerProfile p, Department d, {JobPosting? job}) {
    final List<String> wantModules = job?.requirements.modules.isNotEmpty == true
        ? job!.requirements.modules
        : d.modules.map((TrainingModule m) => m.id).toList();
    final int doneModules = wantModules.where(p.completedModules.contains).length;
    final List<LabSpec> labs = trackLabs(p, d.id);
    final int labsPassed = labs.where((LabSpec l) => p.labPassed(l.id)).length;
    final int trainingTotal = wantModules.length + labs.length;
    final double training = trainingTotal == 0 ? 1 : (doneModules + labsPassed) / trainingTotal;

    final Map<String, int> wantSkills = job?.requirements.skills.isNotEmpty == true
        ? job!.requirements.skills
        : <String, int>{for (final SkillDef s in d.skills) s.id: 1};
    double skillSum = 0;
    for (final MapEntry<String, int> e in wantSkills.entries) {
      skillSum += math.min(1, levelOf(p, e.key) / e.value);
    }
    final double skills = wantSkills.isEmpty ? 1 : skillSum / wantSkills.length;

    final int wantProjects = math.max(1, job?.requirements.projects ?? 1);
    final double portfolio = math.min(1, deptProjects(p, d.id) / wantProjects);

    final double resume = resumeCompleteness(p.resume);
    final bool hasLetter = p.coverLetters.any((CoverLetter c) => TextRubric.words(c.body).length >= 120);
    final double materials = 0.6 * resume + (hasLetter ? 0.4 : 0);

    int bestMock = 0;
    for (final InterviewRecord r in p.practiceInterviews) {
      bestMock = math.max(bestMock, r.overall);
    }
    final double interview = bestMock / 100;

    final List<ReadinessItem> items = <ReadinessItem>[
      ReadinessItem('Training and practical labs', (training * 100).round(), 30,
          '$doneModules of ${wantModules.length} modules and $labsPassed of ${labs.length} labs complete.'),
      ReadinessItem('Skills demonstrated', (skills * 100).round(), 25,
          'Skill levels are earned only by passing graded work.'),
      ReadinessItem('Portfolio', (portfolio * 100).round(), 15,
          '${deptProjects(p, d.id)} of $wantProjects project(s) in this field.'),
      ReadinessItem('Resume and cover letter', (materials * 100).round(), 15,
          'Resume ${(resume * 100).round()}% complete${hasLetter ? '' : '; no cover letter yet'}.'),
      ReadinessItem('Interview practice', bestMock, 15,
          bestMock == 0 ? 'No mock interview yet.' : 'Best mock interview $bestMock/100.'),
    ];
    final double total = training * 30 + skills * 25 + portfolio * 15 + materials * 15 + interview * 15;
    return ReadinessReport(total.round(), items);
  }

  // ------------------------------------------------------------- trainee

  static List<Criterion> traineeCriteria(CareerProfile p, Department d) {
    final int done = d.modules.where((TrainingModule m) => p.completedModules.contains(m.id)).length;
    return <Criterion>[
      Criterion('Two training modules completed in ${d.title}', done >= 2, detail: '$done completed'),
      Criterion('Resume started (name, email, headline)',
          p.resume.fullName.trim().isNotEmpty && _email.hasMatch(p.resume.email.trim()) && p.resume.headline.trim().isNotEmpty),
    ];
  }

  static bool completedInternship(CareerProfile p, String deptId) => p.employment.any((Employment e) =>
      e.deptId == deptId && e.stage == CareerStage.intern && !e.active && e.endReason == 'Internship completed');

  // ------------------------------------------------------------- screening

  static ScreeningReport screen(CareerProfile p, Department d, JobPosting job, JobApplication app, int day) {
    final List<String> gaps = <String>[];
    final List<String> strengths = <String>[];
    bool eligible = true;
    final JobRequirements req = job.requirements;

    final int submitted = app.submittedDay ?? day;
    if (!PostingSchedule.isOpen(job, submitted)) {
      eligible = false;
      gaps.add('Submitted while the posting was closed.');
    }
    if (!p.stage.atLeast(req.minStage)) {
      eligible = false;
      gaps.add('Requires ${req.minStage.label} status or above (you are ${p.stage.label}).');
    }
    for (final String c in req.certifications) {
      if (!p.hasCertification(c)) {
        eligible = false;
        gaps.add('Required certification missing.');
      }
    }
    if (req.completedInternship && !completedInternship(p, job.deptId)) {
      eligible = false;
      gaps.add('Requires a completed internship in this field.');
    }
    final double resume = resumeCompleteness(p.resume);
    if (resume < 0.7) {
      eligible = false;
      gaps.add('Resume is incomplete (${(resume * 100).round()}%).');
    }

    final int doneModules = req.modules.where(p.completedModules.contains).length;
    final double modules = req.modules.isEmpty ? 1 : doneModules / req.modules.length;
    if (req.modules.isNotEmpty) {
      if (doneModules == req.modules.length) {
        strengths.add('All ${req.modules.length} expected training modules completed.');
      } else {
        gaps.add('${req.modules.length - doneModules} expected training module(s) not completed.');
      }
    }

    double skillSum = 0;
    for (final MapEntry<String, int> e in req.skills.entries) {
      final int lvl = levelOf(p, e.key);
      skillSum += math.min(1, lvl / e.value);
      if (lvl >= e.value) {
        strengths.add('${d.skillLabel(e.key)}: ${levelLabel(lvl)}.');
      } else {
        gaps.add('${d.skillLabel(e.key)} below ${levelLabel(e.value)} level.');
      }
    }
    final double skills = req.skills.isEmpty ? 1 : skillSum / req.skills.length;

    final int attached = app.portfolioIds
        .where((String id) => p.portfolio.any((PortfolioItem i) => i.id == id && i.deptId == job.deptId))
        .length;
    final double projects = req.projects == 0 ? (attached > 0 ? 1 : 0.5) : math.min(1, attached / req.projects);
    if (attached > 0) {
      strengths.add('$attached relevant portfolio project(s) attached.');
    } else {
      gaps.add('No relevant portfolio project attached.');
    }

    final TextAssessment letter = coverLetter(app.coverLetter, job);
    if (letter.score >= 70) {
      strengths.add('Cover letter is specific to the role.');
    } else {
      gaps.add('Cover letter: ${letter.misses.map((Concept c) => c.label.toLowerCase()).join(', ')}${letter.notes.isEmpty ? '' : ' — ${letter.notes.first}'}');
    }
    final double materials = 0.6 * (letter.score / 100) + 0.4 * resume;

    final double total = 35 * modules + 30 * skills + 15 * projects + 20 * materials;
    final int score = total.round();
    final bool shortlisted = eligible && score >= job.shortlistMark;
    if (eligible && !shortlisted) {
      gaps.add('Screening score $score is below this employer\'s shortlist mark of ${job.shortlistMark}.');
    }
    return ScreeningReport(
      score: score,
      eligible: eligible,
      shortlisted: shortlisted,
      strengths: strengths,
      gaps: gaps,
      breakdown: <String, int>{
        'training': (modules * 100).round(),
        'skills': (skills * 100).round(),
        'portfolio': (projects * 100).round(),
        'materials': (materials * 100).round(),
      },
    );
  }

  // ------------------------------------------------------------- hiring

  static HiringDecision decide(JobPosting job, JobApplication app) {
    final ScreeningReport s = app.screening!;
    final InterviewRecord i = app.interview!;
    final TaskResult? a = app.assessment;
    final int overall = a == null
        ? (0.3 * s.score + 0.7 * i.overall).round()
        : (0.25 * s.score + 0.5 * i.overall + 0.25 * a.score).round();
    final List<String> reasons = <String>[
      'Screening ${s.score}, interview ${i.overall}${a == null ? '' : ', further assessment ${a.score}'} → overall $overall.',
    ];
    final bool practicalOk = !job.practicalRequired || i.practicalPassed;
    if (!practicalOk) reasons.add('The practical part of the interview was not passed.');
    if (i.lowest < 50) reasons.add('At least one competency scored below 50 (${i.lowest}).');
    if (a != null && !a.passed) reasons.add('The further assessment was not passed.');

    if (overall >= 70 && i.lowest >= 50 && practicalOk && (a == null || a.passed)) {
      reasons.add('Meets the hiring bar: overall ≥ 70, every competency ≥ 50, practical passed.');
      return HiringDecision(outcome: HiringOutcome.offer, overall: overall, reasons: reasons);
    }
    if (a == null && overall >= 58 && i.lowest >= 40) {
      reasons.add('Close to the bar (58–69 or a practical gap): one further assessment is offered.');
      return HiringDecision(outcome: HiringOutcome.furtherAssessment, overall: overall, reasons: reasons);
    }
    reasons.add('Below the hiring bar.');
    return HiringDecision(outcome: HiringOutcome.reject, overall: overall, reasons: reasons);
  }

  static int offerSalary(JobPosting job, int overall) {
    final double t = ((overall - 70) / 30).clamp(0, 1).toDouble();
    final double raw = job.salaryMin + (job.salaryMax - job.salaryMin) * t;
    final int step = job.salaryPeriod == 'year' ? 500 : 10;
    return (raw / step).round() * step;
  }

  // ------------------------------------------------------------- supervisor

  static const List<Concept> handoffRubric = <Concept>[
    Concept('what', 'What you did or changed', <String>[
      'implemented', 'fixed', 'changed', 'completed', 'prepared', 'assessed', 'reviewed',
      'calculated', 'drafted', 'updated', 'administered', 'documented', 'recorded', 'analysed',
      'analyzed', 'identified', 'built', 'added', 'resolved', 'designed', 'posted', 'reconciled', 'wrote',
    ]),
    Concept('verify', 'How you checked it', <String>[
      'test*', 'verified', 'checked', 'validated', 'reconciled', 'confirmed', 'double checked',
      'cross checked', 'compared', 'reassessed', 'reviewed against',
    ]),
    Concept('next', 'Risks, follow-ups or handover', <String>[
      'next', 'follow up', 'risk*', 'monitor*', 'escalat*', 'handover', 'remaining', 'to do',
      'recommend*', 'pending', 'outstanding', 'watch', 'should',
    ]),
  ];

  static SupervisorEvaluation evaluate(AssignmentRecord a, TaskResult result, String handoff) {
    final int quality = result.score;
    final int late = math.max(0, (a.submittedDay ?? a.dueDay) - a.dueDay);
    final int timeliness = math.max(0, 100 - 25 * late);
    final TextAssessment note = TextRubric.assess(handoff, handoffRubric, minWords: 25, maxWords: 250);
    final int communication = note.score;
    int overall = (0.6 * quality + 0.2 * timeliness + 0.2 * communication).round();
    if (!result.passed) overall = math.min(overall, 59);
    final String rating = overall >= 85
        ? 'Exceeds expectations'
        : overall >= 70
            ? 'Meets expectations'
            : overall >= 50
                ? 'Needs improvement'
                : 'Unsatisfactory';
    return SupervisorEvaluation(
      quality: quality,
      timeliness: timeliness,
      communication: communication,
      overall: overall,
      rating: rating,
      comments: <String>[
        result.passed
            ? 'Work meets the acceptance criteria (quality $quality/100).'
            : 'Work does not meet the acceptance criteria yet (quality $quality/100).',
        late == 0 ? 'Delivered on time.' : 'Delivered $late day(s) late.',
        if (note.misses.isNotEmpty)
          'Handoff note is missing: ${note.misses.map((Concept c) => c.label.toLowerCase()).join(', ')}.'
        else
          'Clear handoff note.',
        ...result.feedback.take(2),
      ],
    );
  }

  // ------------------------------------------------------------- promotion

  static int roleStartDay(Employment e) =>
      e.promotions.isEmpty ? e.startDay : e.promotions.last.day;

  static PromotionReview promotion(CareerProfile p, Department d, Employment e, int day) {
    if (e.stage == CareerStage.intern) {
      return const PromotionReview(
          to: null,
          criteria: <Criterion>[],
          message: 'Interns are not promoted. Complete the internship to receive a final evaluation.');
    }
    final CareerStage? to = e.stage.next;
    if (to == null) {
      return const PromotionReview(to: null, criteria: <Criterion>[], message: 'You hold the highest stage.');
    }
    final int inRole = day - roleStartDay(e);
    final int done = e.evaluated.length;
    final int perf = e.performance;
    final double onTime = e.onTimeRate;
    final int deptCerts = d.certifications.where((Certification c) => p.hasCertification(c.id)).length;
    final List<Criterion> c;
    switch (to) {
      case CareerStage.junior:
        c = <Criterion>[
          Criterion('3 evaluated assignments', done >= 3, detail: '$done'),
          Criterion('Performance ≥ 75', perf >= 75, detail: '$perf'),
          Criterion('On time ≥ 66%', onTime >= 0.66, detail: '${(onTime * 100).round()}%'),
          Criterion('10 days in role', inRole >= 10, detail: '$inRole'),
        ];
      case CareerStage.experienced:
        c = <Criterion>[
          Criterion('5 evaluated assignments', done >= 5, detail: '$done'),
          Criterion('Performance ≥ 78', perf >= 78, detail: '$perf'),
          Criterion('On time ≥ 75%', onTime >= 0.75, detail: '${(onTime * 100).round()}%'),
          Criterion('20 days in role', inRole >= 20, detail: '$inRole'),
          Criterion('1 professional certification in ${d.title}', deptCerts >= 1, detail: '$deptCerts'),
        ];
      case CareerStage.senior:
        final int need = math.min(2, d.certifications.length);
        c = <Criterion>[
          Criterion('7 evaluated assignments', done >= 7, detail: '$done'),
          Criterion('Performance ≥ 82', perf >= 82, detail: '$perf'),
          Criterion('On time ≥ 80%', onTime >= 0.8, detail: '${(onTime * 100).round()}%'),
          Criterion('30 days in role', inRole >= 30, detail: '$inRole'),
          Criterion('$need certification(s) in ${d.title}', deptCerts >= need, detail: '$deptCerts'),
        ];
      case CareerStage.lead:
        final WorkplaceDef? w = CareerCatalog.workplace(e.workplaceId);
        final bool led = e.evaluated.any((AssignmentRecord a) =>
            (a.assignmentId.contains('lead') || (w != null && (CareerCatalog.assignment(w, a.assignmentId)?.leadership ?? false))) &&
            a.evaluation!.overall >= 75);
        c = <Criterion>[
          Criterion('8 evaluated assignments', done >= 8, detail: '$done'),
          Criterion('Performance ≥ 85', perf >= 85, detail: '$perf'),
          Criterion('On time ≥ 85%', onTime >= 0.85, detail: '${(onTime * 100).round()}%'),
          Criterion('40 days in role', inRole >= 40, detail: '$inRole'),
          Criterion('Leadership assignment rated ≥ 75', led),
        ];
      default:
        c = <Criterion>[];
    }
    return PromotionReview(to: to, criteria: c);
  }

  static List<Criterion> internshipCriteria(Employment e, WorkplaceDef w) => <Criterion>[
        Criterion('${w.internshipLength} assignments evaluated', e.evaluated.length >= w.internshipLength,
            detail: '${e.evaluated.length}'),
        Criterion('Performance ≥ 75', e.performance >= 75, detail: '${e.performance}'),
        Criterion('On time ≥ 66%', e.onTimeRate >= 0.66, detail: '${(e.onTimeRate * 100).round()}%'),
      ];
}
