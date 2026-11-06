/// Recruitment and employment rules for the job marketplace: resume-based
/// screening, employer questions, interviews built from the job and the
/// candidate's own resume, offers, negotiation, contracts, onboarding and
/// performance reviews. Every number is computed from the student's real
/// submissions and the job's written criteria, with reasons.
library;

import 'dart:math' as math;

import '../content/catalog.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import '../resume/resume_analysis.dart';
import 'career_rules.dart';
import 'pay_rules.dart';
import 'text_rubric.dart';

abstract final class MarketRules {
  /// The resume an application was sent with, as parsed fields.
  static (ParsedResume, String) resumeOf(CareerProfile p, JobApplication a) {
    final ResumeUpload? u = a.resumeId.isEmpty ? null : p.resumeUpload(a.resumeId);
    if (u != null) return (u.parsed, u.text);
    return (parsedFromResume(p.resume), '');
  }

  /// Employer application questions: average rubric score (100 when none).
  static (int, List<String>) answers(JobPosting job, JobApplication a) {
    if (job.questions.isEmpty) return (100, const <String>[]);
    int sum = 0;
    final List<String> notes = <String>[];
    for (final ApplicationQuestion q in job.questions) {
      final TextAssessment t = TextRubric.assess(a.answers[q.id] ?? '', q.rubric, minWords: q.minWords, maxWords: 300);
      sum += t.score;
      if (t.misses.isNotEmpty) notes.add('"${q.prompt}" — add: ${t.misses.map((Concept c) => c.label.toLowerCase()).join(', ')}.');
    }
    return ((sum / job.questions.length).round(), notes);
  }

  /// Screening for marketplace roles. The resume is compared with the job's
  /// written requirements, and the student's own work in GradeGlow (labs and
  /// training in this field) counts as evidence. Being a student or having
  /// little paid experience is never on its own a reason to reject.
  static ScreeningReport screen(CareerProfile p, JobPosting job, JobApplication app, int day) {
    final List<String> gaps = <String>[];
    final List<String> strengths = <String>[];
    bool eligible = true;
    final int submitted = app.submittedDay ?? day;
    if (!PostingSchedule.isOpen(job, submitted)) {
      eligible = false;
      gaps.add('Submitted after the application deadline.');
    }
    if (!p.stage.atLeast(job.requirements.minStage)) {
      eligible = false;
      gaps.add('This ${job.levelLabel.toLowerCase()} role needs ${job.requirements.minStage.label} experience first (you are ${p.stage.label}). Grow into it through promotion.');
    }
    final (ParsedResume r, String text) = resumeOf(p, app);
    final JobMatch m = jobMatch(r, job, fullText: text);
    final int quality = resumeQuality(r).score;
    if (m.matched.isNotEmpty) strengths.add('Resume shows ${m.matched.join(', ')}.');
    if (m.missing.isNotEmpty) gaps.add('Resume does not show: ${m.missing.take(5).join(', ')}.');
    if (m.educationOk) {
      strengths.add('Education matches the requirement.');
    } else {
      gaps.add('Education: ${job.requiredEducation}.');
    }

    // Evidence from the student's own GradeGlow work in this field.
    final Set<String> familyLabs = <String>{
      ...?CareerCatalog.workplace(job.workplaceId)?.assignments.map((AssignmentSpec s) => s.task).whereType<LabTaskSpec>().map((LabTaskSpec t) => t.labId),
    };
    final int labsPassed = familyLabs.where(p.labPassed).length;
    final int modules = p.completedModules.where((String id) => CareerCatalog.departmentOfModule(id)?.id == job.deptId).length;
    final double evidence = math.min(1, (labsPassed + modules) / 3);
    if (labsPassed + modules > 0) {
      strengths.add('Practical evidence in GradeGlow: $labsPassed related lab(s) passed, $modules training module(s) completed.');
    } else {
      gaps.add('No related practical labs passed yet — pass one to show hands-on evidence.');
    }

    final TextAssessment letter = CareerRules.coverLetter(app.coverLetter, job);
    if (letter.score >= 70) {
      strengths.add('Cover letter is specific to the role.');
    } else {
      gaps.add('Cover letter: ${letter.misses.map((Concept c) => c.label.toLowerCase()).join(', ')}.');
    }
    final (int answerScore, List<String> answerNotes) = answers(job, app);
    if (answerScore >= 70) {
      strengths.add('Strong answers to the employer\'s questions ($answerScore/100).');
    } else {
      gaps.addAll(answerNotes);
    }
    final double materials = (0.5 * letter.score + 0.5 * answerScore) / 100;
    final double total = 40 * m.score / 100 + 10 * quality / 100 + 25 * materials + 25 * evidence;
    final int score = total.round();
    final bool shortlisted = eligible && score >= job.shortlistMark;
    if (eligible && !shortlisted) gaps.add('Screening score $score is below this employer\'s shortlist mark of ${job.shortlistMark}.');
    return ScreeningReport(
      score: score,
      eligible: eligible,
      shortlisted: shortlisted,
      strengths: strengths,
      gaps: gaps,
      breakdown: <String, int>{
        'resume match': m.score,
        'resume quality': quality,
        'cover letter & answers': (materials * 100).round(),
        'practical evidence': (evidence * 100).round(),
      },
    );
  }

  /// The interview for an application: a welcome question about the
  /// candidate's own resume, the role's questions, then the department plan.
  static InterviewPlan interviewPlan(CareerProfile p, JobApplication a, JobPosting job, InterviewPlan base) {
    final (ParsedResume r, _) = resumeOf(p, a);
    final String item = r.experience.isNotEmpty ? r.experience.first : (r.projects.isNotEmpty ? r.projects.first : '');
    final String short = item.split(' — ').first;
    final InterviewQuestion fromResume = InterviewQuestion(
      id: 'res_${a.id}',
      prompt: short.isEmpty
          ? 'Welcome, and thanks for coming in. To start, walk me through your background and why you applied for the ${job.title} role.'
          : 'Welcome, and thanks for coming in. I see "$short" on your resume. Walk me through what you did there, how you did it and what the result was.',
      competency: Competency.communication,
      behavioural: true,
      minWords: 40,
      rubric: const <Concept>[
        Concept('own', 'Your own part', <String>['i built', 'i wrote', 'i led', 'i was responsible', 'my role', 'i did', 'i worked', 'i helped', 'i created', 'i managed']),
        Concept('how', 'How you did it', <String>['using', 'by', 'with', 'approach', 'steps', 'first', 'then']),
        Concept('result', 'The result', <String>['result*', 'which led', 'improv*', 'reduc*', 'increas*', 'learned', 'outcome', 'users', 'finished']),
      ],
    );
    return InterviewPlan(
      id: '${base.id}+${job.id}',
      interviewer: job.department.isEmpty ? base.interviewer : (CareerCatalog.workplace(job.workplaceId)?.supervisor ?? base.interviewer),
      interviewerRole: job.department.isEmpty ? base.interviewerRole : '${CareerCatalog.workplace(job.workplaceId)?.supervisorRole ?? base.interviewerRole}, ${job.company.name}',
      opening: 'Hello, I\'m ${CareerCatalog.workplace(job.workplaceId)?.supervisor ?? base.interviewer}. Thanks for applying for ${job.title}. '
          'We\'ll talk about your background and your resume, then some questions about the work and a few situations you would meet here. '
          'At the end you can ask me anything.',
      main: <String>[fromResume.id, for (final InterviewQuestion q in job.roleQuestions) q.id, ...base.main],
      bank: <InterviewQuestion>[fromResume, ...job.roleQuestions, ...base.bank],
      maxQuestions: base.maxQuestions + 1 + job.roleQuestions.length,
    );
  }

  /// A written offer for a successful candidate.
  static JobOffer offer(JobPosting job, String title, int salary, int day) => JobOffer(
        title: title,
        employer: job.company.name,
        salary: salary,
        salaryPeriod: job.salaryPeriod,
        responsibilities: job.responsibilities,
        startDay: day + 1,
        respondByDay: day + 3,
        stage: job.stageOnHire,
        department: job.department,
        employmentType: job.salaryPeriod == 'hour' ? 'Part-time, hourly (${job.hoursPerWeek} h/week)' : 'Full-time (${job.hoursPerWeek} h/week)',
        hoursPerWeek: job.hoursPerWeek,
        payFrequency: job.payFrequency,
        benefits: job.benefits,
        expectations: <String>[
          'Pass the acceptance checks on each assignment (score 70+)',
          'Deliver by the due day',
          'Write a handoff note for every piece of work',
          'Performance review every four assignments',
        ],
      );

  static const List<Concept> negotiationRubric = <Concept>[
    Concept('thanks', 'Thanks and enthusiasm', <String>['thank*', 'excited', 'delighted', 'pleased', 'look forward']),
    Concept('value', 'Evidence of your value', <String>['experience', 'skill*', 'project*', 'certif*', 'result*', 'interview', 'placement']),
    Concept('market', 'Market evidence', <String>['market', 'similar roles', 'research*', 'range', 'average', 'benchmark']),
    Concept('ask', 'A specific, reasonable ask', <String>['salary of', 'would you consider', 'could you', 'request', 'per year', 'per hour']),
  ];

  /// Evaluates a salary negotiation. A well-argued request from a strong
  /// interview earns up to 5% (capped at the posted maximum); otherwise the
  /// employer holds the offer and says why. The offer is never withdrawn.
  static (OfferNegotiation, int) negotiate(JobPosting job, JobApplication a, String message, int day) {
    final TextAssessment t = TextRubric.assess(message, negotiationRubric, minWords: 40, maxWords: 250);
    final JobOffer o = a.offer!;
    final int interview = a.interview?.overall ?? 0;
    final bool ok = t.score >= 60 && interview >= 75 && o.salary < job.salaryMax;
    final int newSalary = ok ? math.min(job.salaryMax, PayRules.raised(o.salary, o.salaryPeriod, 1.05)) : o.salary;
    final String reply = ok
        ? 'Thank you for the thoughtful note. Given your interview, we can increase the offer to ${o.salaryPeriod == 'hour' ? '\$$newSalary per hour' : usdWhole(newSalary)}.'
        : o.salary >= job.salaryMax
            ? 'Thank you. The offer is already at the top of the band for this role, so we can\'t move on salary.'
            : t.score < 60
                ? 'Thank you. Without specific reasons (your results, market research and a clear figure) we will keep the offer as it is.'
                : 'Thank you. Based on the interview results we will keep the offer as it is; strong reviews lead to raises later.';
    return (OfferNegotiation(message: message.trim(), score: t.score, accepted: ok, reply: reply, day: day), newSalary);
  }

  static List<String> contractTerms(JobOffer o, String deptLabel) => <String>[
        'Employer: ${o.employer} $deptLabel(simulated employer).',
        'Position: ${o.title}${o.department.isEmpty ? '' : ', ${o.department}'}.',
        'Employment type: ${o.employmentType.isEmpty ? 'Full-time' : o.employmentType}.',
        'Pay: ${o.salaryPeriod == 'hour' ? '\$${o.salary} per hour' : '${usdWhole(o.salary)} per ${o.salaryPeriod}'} in virtual USD, paid ${PayRules.frequencyLabel(o.payFrequency).toLowerCase()}.',
        'Simulated deductions of ${(PayRules.deductionRate * 100).round()}% (tax and benefits) are taken from each paycheck.',
        'Working hours: ${o.hoursPerWeek} per week. Each evaluated assignment counts as one approved work week.',
        'Start: day ${o.startDay}. Performance reviews every four assignments; raises follow published criteria.',
        'Confidentiality: client and patient information stays inside the workplace.',
        'This is an educational simulation. It is not real employment and no real money is paid.',
      ];

  /// The onboarding checklist for a workplace.
  static List<(String, String, String)> onboarding(Employment e) {
    final WorkplaceDef? w = CareerCatalog.workplace(e.workplaceId);
    final bool clinical = e.deptId == 'nursing' || e.deptId == 'medicine';
    return <(String, String, String)>[
      ('handbook', 'Read the employee handbook', 'Working hours, how assignments, handoff notes and reviews work, and who to ask for help.'),
      ('policy', clinical ? 'Complete patient-privacy and safety training' : 'Complete confidentiality and data-protection training',
          clinical ? 'Patient information is shared only with the care team. Escalate any safety concern immediately. You never act outside your scope.' : 'Client data stays inside company systems. Never share passwords or confidential files.'),
      ('tools', 'Set up your workstation', 'Your tools: ${w?.tools.join(', ') ?? 'company systems'}.'),
      ('manager', 'Meet your manager', '${w?.supervisor ?? 'Your manager'} (${w?.supervisorRole ?? 'manager'}) will set your assignments and review your work.'),
      ('goals', 'Agree your first-month goals', 'Pass each assignment\'s checks, deliver on time, write clear handoff notes.'),
    ];
  }

  /// End-of-cycle performance review, from the cycle's evaluated work only.
  static PerformanceReview review(CareerProfile p, Employment e, Department? d, int day) {
    final List<AssignmentRecord> all = e.evaluated;
    final int cycle = e.reviews.length + 1;
    final List<AssignmentRecord> recent = all.skip(math.max(0, all.length - 4)).toList();
    int avg(Iterable<int> xs) {
      final List<int> l = xs.toList();
      return l.isEmpty ? 0 : (l.reduce((int a, int b) => a + b) / l.length).round();
    }

    final int quality = avg(recent.map((AssignmentRecord a) => a.evaluation!.quality));
    final int accuracy = (recent.where((AssignmentRecord a) => a.result?.passed ?? false).length / math.max(1, recent.length) * 100).round();
    final int communication = avg(recent.map((AssignmentRecord a) => a.evaluation!.communication));
    final int deadlines = avg(recent.map((AssignmentRecord a) => a.evaluation!.timeliness));
    final int reliability = (recent.where((AssignmentRecord a) => (a.submittedDay ?? 1 << 30) <= a.dueDay + 1).length / math.max(1, recent.length) * 100).round();
    final int problem = avg(recent.map((AssignmentRecord a) => a.result?.score ?? 0));
    final int teamwork = avg(recent.map((AssignmentRecord a) =>
        TextRubric.assess(a.handoffNote, const <Concept>[
          Concept('next', 'Next steps for others', <String>['next', 'handover', 'follow up', 'team', 'colleague*', 'manager', 'pending']),
          Concept('risks', 'Risks flagged', <String>['risk*', 'watch', 'monitor*', 'escalat*', 'concern']),
        ], minWords: 15, maxWords: 250).score));
    final Map<String, int> scores = <String, int>{
      'Quality of work': quality,
      'Accuracy (checks passed)': accuracy,
      'Problem-solving': problem,
      'Communication (handoffs)': communication,
      'Teamwork': teamwork,
      'Reliability': reliability,
      'Deadline management': deadlines,
    };
    final int overall = avg(scores.values);
    final String outcome = overall >= 85 && deadlines >= 75
        ? 'Excellent performance'
        : overall >= 70
            ? 'Meets expectations'
            : overall >= 55
                ? 'Needs improvement'
                : 'Performance warning';
    final int raise = PayRules.raiseFor(outcome);
    final int newSalary = raise == 0 ? e.salary : PayRules.raised(e.salary, e.salaryPeriod, 1 + raise / 100);
    final bool eligible = d != null && CareerRules.promotion(p, d, e, day).approved;
    return PerformanceReview(
      cycle: cycle,
      day: day,
      scores: scores,
      overall: overall,
      outcome: outcome,
      raisePercent: raise,
      oldSalary: e.salary,
      newSalary: newSalary,
      promotionEligible: eligible,
      comments: <String>[
        'Based on your last ${recent.length} evaluated assignment(s).',
        if (raise > 0) 'Merit raise of $raise%: ${outcome.toLowerCase()} (rule: 85+ overall with 75+ on deadlines = 5%; 70+ = 2%).'
        else 'No raise this cycle (rule: 70+ overall for 2%, 85+ with 75+ on deadlines for 5%).',
        if (outcome == 'Performance warning') 'Performance warning: pass the next assignments\' checks and hand them in on time.',
        if (eligible) 'You meet the published promotion criteria — request a promotion review.',
        for (final MapEntry<String, int> s in scores.entries)
          if (s.value < 60) 'Improve ${s.key.toLowerCase()} (${s.value}).',
      ],
    );
  }
}
