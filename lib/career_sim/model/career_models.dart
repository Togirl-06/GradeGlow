/// Saved state of the GradeGlow career simulator.
///
/// Everything here is plain data with JSON round-tripping. Rules that change
/// this data live in `../engine/` and content (departments, postings,
/// interview plans, workplaces) lives in `../content/`.
library;

import '../labs/lab_models.dart';

/// Professional stages. A student only moves up by being hired or by passing
/// a promotion review, never automatically.
enum CareerStage {
  student,
  trainee,
  intern,
  entryLevel,
  junior,
  experienced,
  senior,
  lead;

  String get label => switch (this) {
        CareerStage.student => 'Student',
        CareerStage.trainee => 'Trainee',
        CareerStage.intern => 'Intern',
        CareerStage.entryLevel => 'Entry-Level',
        CareerStage.junior => 'Junior',
        CareerStage.experienced => 'Experienced',
        CareerStage.senior => 'Senior',
        CareerStage.lead => 'Team Lead / Manager',
      };

  CareerStage? get next =>
      index + 1 < CareerStage.values.length ? CareerStage.values[index + 1] : null;

  bool atLeast(CareerStage other) => index >= other.index;

  static CareerStage parse(Object? raw) {
    for (final CareerStage s in CareerStage.values) {
      if (s.name == raw) return s;
    }
    return CareerStage.student;
  }
}

/// Status of a job application.
enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  shortlisted,
  interviewScheduled,
  interviewCompleted,
  furtherAssessment,
  rejected,
  offerReceived,
  hired,
  offerDeclined,
  withdrawn;

  String get label => switch (this) {
        ApplicationStatus.draft => 'Draft',
        ApplicationStatus.submitted => 'Submitted',
        ApplicationStatus.underReview => 'Under review',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.interviewScheduled => 'Interview scheduled',
        ApplicationStatus.interviewCompleted => 'Interview completed',
        ApplicationStatus.furtherAssessment => 'Further assessment',
        ApplicationStatus.rejected => 'Rejected',
        ApplicationStatus.offerReceived => 'Offer received',
        ApplicationStatus.hired => 'Hired',
        ApplicationStatus.offerDeclined => 'Offer declined',
        ApplicationStatus.withdrawn => 'Withdrawn',
      };

  /// Still moving through the employer's process.
  bool get isActive => !const <ApplicationStatus>{
        ApplicationStatus.rejected,
        ApplicationStatus.hired,
        ApplicationStatus.offerDeclined,
        ApplicationStatus.withdrawn,
      }.contains(this);

  static ApplicationStatus parse(Object? raw) {
    for (final ApplicationStatus s in ApplicationStatus.values) {
      if (s.name == raw) return s;
    }
    return ApplicationStatus.draft;
  }
}

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
double _double(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;
String _str(Object? v, [String fallback = '']) => v is String ? v : fallback;
List<String> _strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : <String>[];
Map<String, dynamic> _map(Object? v) =>
    v is Map ? v.map((Object? k, Object? val) => MapEntry<String, dynamic>('$k', val)) : <String, dynamic>{};
List<Map<String, dynamic>> _mapList(Object? v) =>
    v is List ? v.whereType<Map<dynamic, dynamic>>().map(_map).toList() : <Map<String, dynamic>>[];

/// Outcome of one graded task (practice, project part, assessment, assignment).
class TaskResult {
  const TaskResult({
    required this.taskId,
    required this.score,
    required this.passed,
    this.feedback = const <String>[],
    this.breakdown = const <String, int>{},
    this.day = 0,
    this.verdict,
  });

  factory TaskResult.fromJson(Map<String, dynamic> j) => TaskResult(
        taskId: _str(j['taskId']),
        score: _int(j['score']),
        passed: j['passed'] == true,
        feedback: _strList(j['feedback']),
        breakdown: _map(j['breakdown']).map(
            (String k, dynamic v) => MapEntry<String, int>(k, _int(v))),
        day: _int(j['day']),
        verdict: j['verdict'] as String?,
      );

  final String taskId;

  /// 0–100, computed by a deterministic rule (or by the code judge).
  final int score;
  final bool passed;

  /// Validated feedback produced by the grading rule (not AI).
  final List<String> feedback;
  final Map<String, int> breakdown;
  final int day;

  /// Code judge verdict for code tasks.
  final String? verdict;

  TaskResult copyWith({int? day}) => TaskResult(
        taskId: taskId,
        score: score,
        passed: passed,
        feedback: feedback,
        breakdown: breakdown,
        day: day ?? this.day,
        verdict: verdict,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'taskId': taskId,
        'score': score,
        'passed': passed,
        'feedback': feedback,
        'breakdown': breakdown,
        'day': day,
        if (verdict != null) 'verdict': verdict,
      };
}

/// Something the student built and can show an employer.
class PortfolioItem {
  const PortfolioItem({
    required this.id,
    required this.deptId,
    required this.title,
    required this.summary,
    required this.score,
    required this.skills,
    required this.day,
    this.writeUp = '',
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> j) => PortfolioItem(
        id: _str(j['id']),
        deptId: _str(j['deptId']),
        title: _str(j['title']),
        summary: _str(j['summary']),
        score: _int(j['score']),
        skills: _strList(j['skills']),
        day: _int(j['day']),
        writeUp: _str(j['writeUp']),
      );

  final String id;
  final String deptId;
  final String title;
  final String summary;
  final int score;
  final List<String> skills;
  final int day;
  final String writeUp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'deptId': deptId,
        'title': title,
        'summary': summary,
        'score': score,
        'skills': skills,
        'day': day,
        'writeUp': writeUp,
      };
}

class ResumeEntry {
  const ResumeEntry({required this.heading, required this.detail});

  factory ResumeEntry.fromJson(Map<String, dynamic> j) =>
      ResumeEntry(heading: _str(j['heading']), detail: _str(j['detail']));

  final String heading;
  final String detail;

  Map<String, dynamic> toJson() => <String, dynamic>{'heading': heading, 'detail': detail};
}

class Resume {
  const Resume({
    this.fullName = '',
    this.email = '',
    this.headline = '',
    this.summary = '',
    this.education = const <ResumeEntry>[],
    this.experience = const <ResumeEntry>[],
    this.skills = const <String>[],
    this.projectIds = const <String>[],
    this.updatedDay = 0,
    this.phone = '',
    this.projects = const <ResumeEntry>[],
    this.certifications = const <String>[],
    this.achievements = const <String>[],
  });

  factory Resume.fromJson(Map<String, dynamic> j) => Resume(
        fullName: _str(j['fullName']),
        email: _str(j['email']),
        headline: _str(j['headline']),
        summary: _str(j['summary']),
        education: _mapList(j['education']).map(ResumeEntry.fromJson).toList(),
        experience: _mapList(j['experience']).map(ResumeEntry.fromJson).toList(),
        skills: _strList(j['skills']),
        projectIds: _strList(j['projectIds']),
        updatedDay: _int(j['updatedDay']),
        phone: _str(j['phone']),
        projects: _mapList(j['projects']).map(ResumeEntry.fromJson).toList(),
        certifications: _strList(j['certifications']),
        achievements: _strList(j['achievements']),
      );

  final String fullName;
  final String email;
  final String headline;
  final String summary;
  final List<ResumeEntry> education;
  final List<ResumeEntry> experience;
  final List<String> skills;
  final List<String> projectIds;
  final int updatedDay;
  final String phone;

  /// Projects written on the resume (portfolio projects are [projectIds]).
  final List<ResumeEntry> projects;
  final List<String> certifications;
  final List<String> achievements;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'headline': headline,
        'summary': summary,
        'education': education.map((ResumeEntry e) => e.toJson()).toList(),
        'experience': experience.map((ResumeEntry e) => e.toJson()).toList(),
        'skills': skills,
        'projectIds': projectIds,
        'updatedDay': updatedDay,
        'phone': phone,
        'projects': projects.map((ResumeEntry e) => e.toJson()).toList(),
        'certifications': certifications,
        'achievements': achievements,
      };

  /// Plain text of the resume, as an employer would read it.
  String get asText => <String>[
        fullName,
        headline,
        summary,
        for (final ResumeEntry e in education) '${e.heading} ${e.detail}',
        for (final ResumeEntry e in experience) '${e.heading} ${e.detail}',
        for (final ResumeEntry e in projects) '${e.heading} ${e.detail}',
        skills.join(', '),
        ...certifications,
        ...achievements,
      ].where((String s) => s.trim().isNotEmpty).join('\n');
}

class CoverLetter {
  const CoverLetter({
    required this.id,
    required this.postingId,
    required this.body,
    required this.day,
  });

  factory CoverLetter.fromJson(Map<String, dynamic> j) => CoverLetter(
        id: _str(j['id']),
        postingId: _str(j['postingId']),
        body: _str(j['body']),
        day: _int(j['day']),
      );

  final String id;

  /// Empty for a general letter.
  final String postingId;
  final String body;
  final int day;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'postingId': postingId, 'body': body, 'day': day};
}

/// One question and the candidate's answer in a recorded interview.
class InterviewTurn {
  const InterviewTurn({
    required this.questionId,
    required this.prompt,
    required this.answer,
    required this.score,
    required this.competency,
    this.notes = const <String>[],
    this.isFollowUp = false,
  });

  factory InterviewTurn.fromJson(Map<String, dynamic> j) => InterviewTurn(
        questionId: _str(j['questionId']),
        prompt: _str(j['prompt']),
        answer: _str(j['answer']),
        score: _int(j['score']),
        competency: _str(j['competency']),
        notes: _strList(j['notes']),
        isFollowUp: j['isFollowUp'] == true,
      );

  final String questionId;
  final String prompt;
  final String answer;
  final int score;
  final String competency;
  final List<String> notes;
  final bool isFollowUp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        'prompt': prompt,
        'answer': answer,
        'score': score,
        'competency': competency,
        'notes': notes,
        'isFollowUp': isFollowUp,
      };
}

/// Scored interview, from the deterministic rubric.
class InterviewRecord {
  const InterviewRecord({
    required this.applicationId,
    required this.day,
    required this.turns,
    required this.communication,
    required this.technical,
    required this.problemSolving,
    required this.readiness,
    required this.candidateQuestions,
    required this.practicalPassed,
    this.practice = false,
    this.feedback = const <String>[],
  });

  factory InterviewRecord.fromJson(Map<String, dynamic> j) => InterviewRecord(
        applicationId: _str(j['applicationId']),
        day: _int(j['day']),
        turns: _mapList(j['turns']).map(InterviewTurn.fromJson).toList(),
        communication: _int(j['communication']),
        technical: _int(j['technical']),
        problemSolving: _int(j['problemSolving']),
        readiness: _int(j['readiness']),
        candidateQuestions: _strList(j['candidateQuestions']),
        practicalPassed: j['practicalPassed'] == true,
        practice: j['practice'] == true,
        feedback: _strList(j['feedback']),
      );

  final String applicationId;
  final int day;
  final List<InterviewTurn> turns;
  final int communication;
  final int technical;
  final int problemSolving;
  final int readiness;
  final List<String> candidateQuestions;
  final bool practicalPassed;

  /// A Career Centre mock interview (does not affect any application).
  final bool practice;
  final List<String> feedback;

  int get overall => ((communication + technical + problemSolving + readiness) / 4).round();

  int get lowest => <int>[communication, technical, problemSolving, readiness]
      .reduce((int a, int b) => a < b ? a : b);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'applicationId': applicationId,
        'day': day,
        'turns': turns.map((InterviewTurn t) => t.toJson()).toList(),
        'communication': communication,
        'technical': technical,
        'problemSolving': problemSolving,
        'readiness': readiness,
        'candidateQuestions': candidateQuestions,
        'practicalPassed': practicalPassed,
        'practice': practice,
        'feedback': feedback,
      };
}

/// The employer's written screening of an application.
class ScreeningReport {
  const ScreeningReport({
    required this.score,
    required this.eligible,
    required this.shortlisted,
    required this.strengths,
    required this.gaps,
    required this.breakdown,
  });

  factory ScreeningReport.fromJson(Map<String, dynamic> j) => ScreeningReport(
        score: _int(j['score']),
        eligible: j['eligible'] == true,
        shortlisted: j['shortlisted'] == true,
        strengths: _strList(j['strengths']),
        gaps: _strList(j['gaps']),
        breakdown: _map(j['breakdown'])
            .map((String k, dynamic v) => MapEntry<String, int>(k, _int(v))),
      );

  final int score;
  final bool eligible;
  final bool shortlisted;
  final List<String> strengths;
  final List<String> gaps;
  final Map<String, int> breakdown;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'score': score,
        'eligible': eligible,
        'shortlisted': shortlisted,
        'strengths': strengths,
        'gaps': gaps,
        'breakdown': breakdown,
      };
}

enum HiringOutcome { offer, furtherAssessment, reject }

class HiringDecision {
  const HiringDecision({
    required this.outcome,
    required this.overall,
    required this.reasons,
  });

  factory HiringDecision.fromJson(Map<String, dynamic> j) => HiringDecision(
        outcome: HiringOutcome.values.firstWhere(
            (HiringOutcome o) => o.name == j['outcome'],
            orElse: () => HiringOutcome.reject),
        overall: _int(j['overall']),
        reasons: _strList(j['reasons']),
      );

  final HiringOutcome outcome;
  final int overall;
  final List<String> reasons;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'outcome': outcome.name, 'overall': overall, 'reasons': reasons};
}

class JobOffer {
  const JobOffer({
    required this.title,
    required this.employer,
    required this.salary,
    required this.salaryPeriod,
    required this.responsibilities,
    required this.startDay,
    required this.respondByDay,
    required this.stage,
    this.department = '',
    this.employmentType = '',
    this.hoursPerWeek = 40,
    this.payFrequency = 'biweekly',
    this.benefits = const <String>[],
    this.expectations = const <String>[],
  });

  factory JobOffer.fromJson(Map<String, dynamic> j) => JobOffer(
        title: _str(j['title']),
        employer: _str(j['employer']),
        salary: _int(j['salary']),
        salaryPeriod: _str(j['salaryPeriod'], 'year'),
        responsibilities: _strList(j['responsibilities']),
        startDay: _int(j['startDay']),
        respondByDay: _int(j['respondByDay']),
        stage: CareerStage.parse(j['stage']),
        department: _str(j['department']),
        employmentType: _str(j['employmentType']),
        hoursPerWeek: _int(j['hoursPerWeek'], 40),
        payFrequency: _str(j['payFrequency'], 'biweekly'),
        benefits: _strList(j['benefits']),
        expectations: _strList(j['expectations']),
      );

  final String department;
  final String employmentType;
  final int hoursPerWeek;

  /// weekly, biweekly or monthly.
  final String payFrequency;
  final List<String> benefits;
  final List<String> expectations;

  JobOffer withSalary(int s) => JobOffer(
        title: title,
        employer: employer,
        salary: s,
        salaryPeriod: salaryPeriod,
        responsibilities: responsibilities,
        startDay: startDay,
        respondByDay: respondByDay,
        stage: stage,
        department: department,
        employmentType: employmentType,
        hoursPerWeek: hoursPerWeek,
        payFrequency: payFrequency,
        benefits: benefits,
        expectations: expectations,
      );

  final String title;
  final String employer;
  final int salary;
  final String salaryPeriod;
  final List<String> responsibilities;
  final int startDay;
  final int respondByDay;
  final CareerStage stage;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'employer': employer,
        'salary': salary,
        'salaryPeriod': salaryPeriod,
        'responsibilities': responsibilities,
        'startDay': startDay,
        'respondByDay': respondByDay,
        'stage': stage.name,
        'department': department,
        'employmentType': employmentType,
        'hoursPerWeek': hoursPerWeek,
        'payFrequency': payFrequency,
        'benefits': benefits,
        'expectations': expectations,
      };
}

class StatusChange {
  const StatusChange({required this.status, required this.day, this.note = ''});

  factory StatusChange.fromJson(Map<String, dynamic> j) => StatusChange(
        status: ApplicationStatus.parse(j['status']),
        day: _int(j['day']),
        note: _str(j['note']),
      );

  final ApplicationStatus status;
  final int day;
  final String note;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'status': status.name, 'day': day, 'note': note};
}

class JobApplication {
  JobApplication({
    required this.id,
    required this.postingId,
    required this.status,
    required this.createdDay,
    this.coverLetter = '',
    this.portfolioIds = const <String>[],
    this.submittedDay,
    this.screening,
    this.interviewDay,
    this.interviewSlots = const <int>[],
    this.interview,
    this.assessment,
    this.decision,
    this.offer,
    List<StatusChange>? history,
    this.resumeId = '',
    Map<String, String>? answers,
    this.negotiation,
  })  : history = history ?? <StatusChange>[],
        answers = answers ?? <String, String>{};

  factory JobApplication.fromJson(Map<String, dynamic> j) => JobApplication(
        id: _str(j['id']),
        postingId: _str(j['postingId']),
        status: ApplicationStatus.parse(j['status']),
        createdDay: _int(j['createdDay']),
        coverLetter: _str(j['coverLetter']),
        portfolioIds: _strList(j['portfolioIds']),
        submittedDay: j['submittedDay'] is num ? _int(j['submittedDay']) : null,
        screening: j['screening'] is Map ? ScreeningReport.fromJson(_map(j['screening'])) : null,
        interviewDay: j['interviewDay'] is num ? _int(j['interviewDay']) : null,
        interviewSlots: (j['interviewSlots'] is List)
            ? (j['interviewSlots'] as List<dynamic>).whereType<num>().map((num n) => n.toInt()).toList()
            : <int>[],
        interview: j['interview'] is Map ? InterviewRecord.fromJson(_map(j['interview'])) : null,
        assessment: j['assessment'] is Map ? TaskResult.fromJson(_map(j['assessment'])) : null,
        decision: j['decision'] is Map ? HiringDecision.fromJson(_map(j['decision'])) : null,
        offer: j['offer'] is Map ? JobOffer.fromJson(_map(j['offer'])) : null,
        history: _mapList(j['history']).map(StatusChange.fromJson).toList(),
        resumeId: _str(j['resumeId']),
        answers: <String, String>{for (final MapEntry<String, dynamic> e in _map(j['answers']).entries) e.key: _str(e.value)},
        negotiation: j['negotiation'] is Map ? OfferNegotiation.fromJson(_map(j['negotiation'])) : null,
      );

  /// Uploaded resume sent with the application; empty = the built resume.
  String resumeId;

  /// Employer application question id → answer.
  final Map<String, String> answers;
  OfferNegotiation? negotiation;

  final String id;
  final String postingId;
  ApplicationStatus status;
  final int createdDay;
  String coverLetter;
  List<String> portfolioIds;
  int? submittedDay;
  ScreeningReport? screening;
  int? interviewDay;
  List<int> interviewSlots;
  InterviewRecord? interview;
  TaskResult? assessment;
  HiringDecision? decision;
  JobOffer? offer;
  final List<StatusChange> history;

  void move(ApplicationStatus to, int day, [String note = '']) {
    status = to;
    history.add(StatusChange(status: to, day: day, note: note));
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'postingId': postingId,
        'status': status.name,
        'createdDay': createdDay,
        'coverLetter': coverLetter,
        'portfolioIds': portfolioIds,
        if (submittedDay != null) 'submittedDay': submittedDay,
        if (screening != null) 'screening': screening!.toJson(),
        if (interviewDay != null) 'interviewDay': interviewDay,
        'interviewSlots': interviewSlots,
        if (interview != null) 'interview': interview!.toJson(),
        if (assessment != null) 'assessment': assessment!.toJson(),
        if (decision != null) 'decision': decision!.toJson(),
        if (offer != null) 'offer': offer!.toJson(),
        'history': history.map((StatusChange s) => s.toJson()).toList(),
        'resumeId': resumeId,
        'answers': answers,
        if (negotiation != null) 'negotiation': negotiation!.toJson(),
      };
}

/// A workplace assignment that was issued to the student.
class AssignmentRecord {
  AssignmentRecord({
    required this.assignmentId,
    required this.issuedDay,
    required this.dueDay,
    this.submittedDay,
    this.result,
    this.handoffNote = '',
    this.evaluation,
  });

  factory AssignmentRecord.fromJson(Map<String, dynamic> j) => AssignmentRecord(
        assignmentId: _str(j['assignmentId']),
        issuedDay: _int(j['issuedDay']),
        dueDay: _int(j['dueDay']),
        submittedDay: j['submittedDay'] is num ? _int(j['submittedDay']) : null,
        result: j['result'] is Map ? TaskResult.fromJson(_map(j['result'])) : null,
        handoffNote: _str(j['handoffNote']),
        evaluation: j['evaluation'] is Map
            ? SupervisorEvaluation.fromJson(_map(j['evaluation']))
            : null,
      );

  final String assignmentId;
  final int issuedDay;
  final int dueDay;
  int? submittedDay;
  TaskResult? result;
  String handoffNote;
  SupervisorEvaluation? evaluation;

  bool get submitted => submittedDay != null;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'assignmentId': assignmentId,
        'issuedDay': issuedDay,
        'dueDay': dueDay,
        if (submittedDay != null) 'submittedDay': submittedDay,
        if (result != null) 'result': result!.toJson(),
        'handoffNote': handoffNote,
        if (evaluation != null) 'evaluation': evaluation!.toJson(),
      };
}

class SupervisorEvaluation {
  const SupervisorEvaluation({
    required this.quality,
    required this.timeliness,
    required this.communication,
    required this.overall,
    required this.rating,
    required this.comments,
  });

  factory SupervisorEvaluation.fromJson(Map<String, dynamic> j) => SupervisorEvaluation(
        quality: _int(j['quality']),
        timeliness: _int(j['timeliness']),
        communication: _int(j['communication']),
        overall: _int(j['overall']),
        rating: _str(j['rating']),
        comments: _strList(j['comments']),
      );

  final int quality;
  final int timeliness;
  final int communication;
  final int overall;

  /// Exceeds expectations / Meets expectations / Needs improvement / Unsatisfactory.
  final String rating;
  final List<String> comments;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'quality': quality,
        'timeliness': timeliness,
        'communication': communication,
        'overall': overall,
        'rating': rating,
        'comments': comments,
      };
}

class PromotionRecord {
  const PromotionRecord({
    required this.from,
    required this.to,
    required this.day,
    required this.title,
    required this.salary,
  });

  factory PromotionRecord.fromJson(Map<String, dynamic> j) => PromotionRecord(
        from: CareerStage.parse(j['from']),
        to: CareerStage.parse(j['to']),
        day: _int(j['day']),
        title: _str(j['title']),
        salary: _int(j['salary']),
      );

  final CareerStage from;
  final CareerStage to;
  final int day;
  final String title;
  final int salary;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from.name,
        'to': to.name,
        'day': day,
        'title': title,
        'salary': salary,
      };
}

class Employment {
  Employment({
    required this.id,
    required this.postingId,
    required this.deptId,
    required this.workplaceId,
    required this.employer,
    required this.title,
    required this.stage,
    required this.salary,
    required this.salaryPeriod,
    required this.startDay,
    this.endDay,
    this.endReason = '',
    List<AssignmentRecord>? assignments,
    List<PromotionRecord>? promotions,
    this.finalReview,
    this.payFrequency = 'biweekly',
    this.hoursPerWeek = 40,
    this.contract,
    Set<String>? onboarding,
    List<PerformanceReview>? reviews,
    this.unpaidWeeks = 0,
  })  : assignments = assignments ?? <AssignmentRecord>[],
        promotions = promotions ?? <PromotionRecord>[],
        onboarding = onboarding ?? <String>{},
        reviews = reviews ?? <PerformanceReview>[];

  factory Employment.fromJson(Map<String, dynamic> j) => Employment(
        id: _str(j['id']),
        postingId: _str(j['postingId']),
        deptId: _str(j['deptId']),
        workplaceId: _str(j['workplaceId']),
        employer: _str(j['employer']),
        title: _str(j['title']),
        stage: CareerStage.parse(j['stage']),
        salary: _int(j['salary']),
        salaryPeriod: _str(j['salaryPeriod'], 'year'),
        startDay: _int(j['startDay']),
        endDay: j['endDay'] is num ? _int(j['endDay']) : null,
        endReason: _str(j['endReason']),
        assignments: _mapList(j['assignments']).map(AssignmentRecord.fromJson).toList(),
        promotions: _mapList(j['promotions']).map(PromotionRecord.fromJson).toList(),
        finalReview: j['finalReview'] as String?,
        payFrequency: _str(j['payFrequency'], 'biweekly'),
        hoursPerWeek: _int(j['hoursPerWeek'], 40),
        contract: j['contract'] is Map ? EmploymentContract.fromJson(_map(j['contract'])) : null,
        onboarding: _strList(j['onboarding']).toSet(),
        reviews: _mapList(j['reviews']).map(PerformanceReview.fromJson).toList(),
        unpaidWeeks: _int(j['unpaidWeeks']),
      );

  /// weekly, biweekly or monthly.
  final String payFrequency;
  final int hoursPerWeek;
  EmploymentContract? contract;

  /// Completed onboarding checklist item ids.
  final Set<String> onboarding;
  final List<PerformanceReview> reviews;

  /// Approved work weeks not yet paid.
  int unpaidWeeks;

  final String id;
  final String postingId;
  final String deptId;
  final String workplaceId;
  final String employer;
  String title;
  CareerStage stage;
  int salary;
  final String salaryPeriod;
  final int startDay;
  int? endDay;
  String endReason;
  final List<AssignmentRecord> assignments;
  final List<PromotionRecord> promotions;

  /// Written summary of an internship's final evaluation.
  String? finalReview;

  bool get active => endDay == null;

  List<AssignmentRecord> get evaluated =>
      assignments.where((AssignmentRecord a) => a.evaluation != null).toList();

  AssignmentRecord? get open {
    for (final AssignmentRecord a in assignments) {
      if (!a.submitted) return a;
    }
    return null;
  }

  /// Average supervisor overall score, 0 when nothing has been evaluated.
  int get performance {
    final List<AssignmentRecord> done = evaluated;
    if (done.isEmpty) return 0;
    final int sum = done.fold<int>(0, (int s, AssignmentRecord a) => s + a.evaluation!.overall);
    return (sum / done.length).round();
  }

  double get onTimeRate {
    final List<AssignmentRecord> done = evaluated;
    if (done.isEmpty) return 0;
    final int onTime = done
        .where((AssignmentRecord a) => (a.submittedDay ?? 1 << 30) <= a.dueDay)
        .length;
    return onTime / done.length;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'postingId': postingId,
        'deptId': deptId,
        'workplaceId': workplaceId,
        'employer': employer,
        'title': title,
        'stage': stage.name,
        'salary': salary,
        'salaryPeriod': salaryPeriod,
        'startDay': startDay,
        if (endDay != null) 'endDay': endDay,
        'endReason': endReason,
        'assignments': assignments.map((AssignmentRecord a) => a.toJson()).toList(),
        'promotions': promotions.map((PromotionRecord p) => p.toJson()).toList(),
        if (finalReview != null) 'finalReview': finalReview,
        'payFrequency': payFrequency,
        'hoursPerWeek': hoursPerWeek,
        if (contract != null) 'contract': contract!.toJson(),
        'onboarding': onboarding.toList(),
        'reviews': reviews.map((PerformanceReview r) => r.toJson()).toList(),
        'unpaidWeeks': unpaidWeeks,
      };
}

class CertificationRecord {
  const CertificationRecord({required this.id, required this.score, required this.day});

  factory CertificationRecord.fromJson(Map<String, dynamic> j) =>
      CertificationRecord(id: _str(j['id']), score: _int(j['score']), day: _int(j['day']));

  final String id;
  final int score;
  final int day;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'score': score, 'day': day};
}

/// A dated line in the student's activity log.
class CareerEvent {
  const CareerEvent({required this.day, required this.text, this.kind = 'info'});

  factory CareerEvent.fromJson(Map<String, dynamic> j) =>
      CareerEvent(day: _int(j['day']), text: _str(j['text']), kind: _str(j['kind'], 'info'));

  final int day;
  final String text;
  final String kind;

  Map<String, dynamic> toJson() => <String, dynamic>{'day': day, 'text': text, 'kind': kind};
}

/// One line in the virtual earnings ledger (virtual USD, not real money).
class MoneyEntry {
  const MoneyEntry({required this.day, required this.cents, required this.text, this.kind = 'pay', this.paycheckId = ''});

  factory MoneyEntry.fromJson(Map<String, dynamic> j) => MoneyEntry(
        day: _int(j['day']),
        cents: _int(j['cents']),
        text: _str(j['text']),
        kind: _str(j['kind'], 'pay'),
        paycheckId: _str(j['paycheckId']),
      );

  final int day;

  /// Virtual US cents (net); positive is money in.
  final int cents;
  final String text;

  /// 'lab' (training stipend), 'salary' (net paycheck) or 'bonus'.
  final String kind;
  final String paycheckId;

  Map<String, dynamic> toJson() => <String, dynamic>{'day': day, 'cents': cents, 'text': text, 'kind': kind, if (paycheckId.isNotEmpty) 'paycheckId': paycheckId};
}

/// A processed virtual paycheck. Its id is unique per employment and pay
/// period, so the same period can never be paid twice.
class Paycheck {
  const Paycheck({
    required this.id,
    required this.employmentId,
    required this.employer,
    required this.title,
    required this.period,
    required this.weeks,
    required this.hours,
    required this.grossCents,
    required this.deductionCents,
    required this.day,
    required this.frequency,
  });

  factory Paycheck.fromJson(Map<String, dynamic> j) => Paycheck(
        id: _str(j['id']),
        employmentId: _str(j['employmentId']),
        employer: _str(j['employer']),
        title: _str(j['title']),
        period: _int(j['period']),
        weeks: _int(j['weeks']),
        hours: _int(j['hours']),
        grossCents: _int(j['gross']),
        deductionCents: _int(j['deductions']),
        day: _int(j['day']),
        frequency: _str(j['frequency'], 'biweekly'),
      );

  final String id;
  final String employmentId;
  final String employer;
  final String title;

  /// 1-based pay period of this employment.
  final int period;
  final int weeks;
  final int hours;
  final int grossCents;
  final int deductionCents;
  final int day;
  final String frequency;

  int get netCents => grossCents - deductionCents;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'employmentId': employmentId,
        'employer': employer,
        'title': title,
        'period': period,
        'weeks': weeks,
        'hours': hours,
        'gross': grossCents,
        'deductions': deductionCents,
        'day': day,
        'frequency': frequency,
      };
}

/// End-of-cycle performance review.
class PerformanceReview {
  const PerformanceReview({
    required this.cycle,
    required this.day,
    required this.scores,
    required this.overall,
    required this.outcome,
    required this.raisePercent,
    required this.oldSalary,
    required this.newSalary,
    required this.comments,
    this.promotionEligible = false,
  });

  factory PerformanceReview.fromJson(Map<String, dynamic> j) => PerformanceReview(
        cycle: _int(j['cycle']),
        day: _int(j['day']),
        scores: <String, int>{for (final MapEntry<String, dynamic> e in _map(j['scores']).entries) e.key: _int(e.value)},
        overall: _int(j['overall']),
        outcome: _str(j['outcome']),
        raisePercent: _int(j['raisePercent']),
        oldSalary: _int(j['oldSalary']),
        newSalary: _int(j['newSalary']),
        comments: _strList(j['comments']),
        promotionEligible: j['promotionEligible'] == true,
      );

  final int cycle;
  final int day;
  final Map<String, int> scores;
  final int overall;

  /// Excellent performance, Meets expectations, Needs improvement or Performance warning.
  final String outcome;
  final int raisePercent;
  final int oldSalary;
  final int newSalary;
  final List<String> comments;
  final bool promotionEligible;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cycle': cycle,
        'day': day,
        'scores': scores,
        'overall': overall,
        'outcome': outcome,
        'raisePercent': raisePercent,
        'oldSalary': oldSalary,
        'newSalary': newSalary,
        'comments': comments,
        'promotionEligible': promotionEligible,
      };
}

/// The signed (simulated) employment contract.
class EmploymentContract {
  const EmploymentContract({required this.signedName, required this.signedDay, required this.terms});

  factory EmploymentContract.fromJson(Map<String, dynamic> j) =>
      EmploymentContract(signedName: _str(j['signedName']), signedDay: _int(j['signedDay']), terms: _strList(j['terms']));

  final String signedName;
  final int signedDay;
  final List<String> terms;

  Map<String, dynamic> toJson() => <String, dynamic>{'signedName': signedName, 'signedDay': signedDay, 'terms': terms};
}

/// A salary negotiation on an offer.
class OfferNegotiation {
  const OfferNegotiation({required this.message, required this.score, required this.accepted, required this.reply, required this.day});

  factory OfferNegotiation.fromJson(Map<String, dynamic> j) => OfferNegotiation(
        message: _str(j['message']),
        score: _int(j['score']),
        accepted: j['accepted'] == true,
        reply: _str(j['reply']),
        day: _int(j['day']),
      );

  final String message;
  final int score;
  final bool accepted;
  final String reply;
  final int day;

  Map<String, dynamic> toJson() => <String, dynamic>{'message': message, 'score': score, 'accepted': accepted, 'reply': reply, 'day': day};
}

/// Profile fields read from an uploaded resume. Every value comes from the
/// file's text; nothing is added. The student can correct them.
class ParsedResume {
  const ParsedResume({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.headline = '',
    this.summary = '',
    this.education = const <String>[],
    this.experience = const <String>[],
    this.skills = const <String>[],
    this.projects = const <String>[],
    this.certifications = const <String>[],
    this.achievements = const <String>[],
    this.links = const <String>[],
  });

  factory ParsedResume.fromJson(Map<String, dynamic> j) => ParsedResume(
        name: _str(j['name']),
        email: _str(j['email']),
        phone: _str(j['phone']),
        headline: _str(j['headline']),
        summary: _str(j['summary']),
        education: _strList(j['education']),
        experience: _strList(j['experience']),
        skills: _strList(j['skills']),
        projects: _strList(j['projects']),
        certifications: _strList(j['certifications']),
        achievements: _strList(j['achievements']),
        links: _strList(j['links']),
      );

  final String name;
  final String email;
  final String phone;
  final String headline;
  final String summary;

  /// One entry per line: "heading — detail" for education, experience, projects.
  final List<String> education;
  final List<String> experience;
  final List<String> skills;
  final List<String> projects;
  final List<String> certifications;
  final List<String> achievements;
  final List<String> links;

  ParsedResume copyWith({
    String? name,
    String? email,
    String? phone,
    String? headline,
    String? summary,
    List<String>? education,
    List<String>? experience,
    List<String>? skills,
    List<String>? projects,
    List<String>? certifications,
    List<String>? achievements,
  }) =>
      ParsedResume(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        headline: headline ?? this.headline,
        summary: summary ?? this.summary,
        education: education ?? this.education,
        experience: experience ?? this.experience,
        skills: skills ?? this.skills,
        projects: projects ?? this.projects,
        certifications: certifications ?? this.certifications,
        achievements: achievements ?? this.achievements,
        links: links,
      );

  /// The text an employer reads, rebuilt from the (possibly corrected) fields.
  String get asText => <String>[
        name,
        headline,
        summary,
        ...education,
        ...experience,
        ...projects,
        skills.join(', '),
        ...certifications,
        ...achievements,
      ].where((String s) => s.trim().isNotEmpty).join('\n');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'headline': headline,
        'summary': summary,
        'education': education,
        'experience': experience,
        'skills': skills,
        'projects': projects,
        'certifications': certifications,
        'achievements': achievements,
        'links': links,
      };
}

/// A resume file the student uploaded (PDF or DOCX).
class ResumeUpload {
  ResumeUpload({
    required this.id,
    required this.fileName,
    required this.format,
    required this.sizeBytes,
    required this.uploadedDay,
    required this.text,
    required this.parsed,
    this.storagePath = '',
    this.reviewed = false,
  });

  factory ResumeUpload.fromJson(Map<String, dynamic> j) => ResumeUpload(
        id: _str(j['id']),
        fileName: _str(j['fileName']),
        format: _str(j['format']),
        sizeBytes: _int(j['sizeBytes']),
        uploadedDay: _int(j['uploadedDay']),
        text: _str(j['text']),
        parsed: ParsedResume.fromJson(_map(j['parsed'])),
        storagePath: _str(j['storagePath']),
        reviewed: j['reviewed'] == true,
      );

  final String id;
  final String fileName;

  /// 'pdf' or 'docx'.
  final String format;
  final int sizeBytes;
  final int uploadedDay;

  /// Extracted text (capped) used for evaluation.
  final String text;
  ParsedResume parsed;

  /// Firebase Storage path; empty when the file was not stored (offline/tests).
  final String storagePath;

  /// The student has checked and confirmed the extracted fields.
  bool reviewed;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fileName': fileName,
        'format': format,
        'sizeBytes': sizeBytes,
        'uploadedDay': uploadedDay,
        'text': text,
        'parsed': parsed.toJson(),
        'storagePath': storagePath,
        'reviewed': reviewed,
      };
}

/// A virtual-hospital case, shift or triage board in progress or finished.
/// Only the student's actions are saved; the deterministic engine replays them.
class HospitalRun {
  HospitalRun({required this.id, required this.kind, required this.role, required this.startedDay, List<Map<String, dynamic>>? actions, this.done = false})
      : actions = actions ?? <Map<String, dynamic>>[];

  factory HospitalRun.fromJson(Map<String, dynamic> j) => HospitalRun(
        id: _str(j['id']),
        kind: _str(j['kind'], 'case'),
        role: _str(j['role'], 'nursing'),
        startedDay: _int(j['startedDay']),
        actions: _mapList(j['actions']),
        done: j['done'] == true,
      );

  /// Case id, shift id or 'triage'.
  final String id;

  /// case, shift or triage.
  final String kind;

  /// nursing or medicine.
  final String role;
  final int startedDay;
  final List<Map<String, dynamic>> actions;
  bool done;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'kind': kind, 'role': role, 'startedDay': startedDay, 'actions': actions, 'done': done};
}

class HospitalResult {
  const HospitalResult({
    required this.id,
    required this.kind,
    required this.role,
    required this.day,
    required this.score,
    required this.passed,
    required this.critical,
    this.categories = const <String, int>{},
    this.outcome = '',
    this.notes = const <String>[],
  });

  factory HospitalResult.fromJson(Map<String, dynamic> j) => HospitalResult(
        id: _str(j['id']),
        kind: _str(j['kind'], 'case'),
        role: _str(j['role'], 'nursing'),
        day: _int(j['day']),
        score: _int(j['score']),
        passed: j['passed'] == true,
        critical: j['critical'] == true,
        categories: <String, int>{for (final MapEntry<String, dynamic> e in _map(j['categories']).entries) e.key: _int(e.value)},
        outcome: _str(j['outcome']),
        notes: _strList(j['notes']),
      );

  final String id;
  final String kind;
  final String role;
  final int day;
  final int score;
  final bool passed;

  /// A critical safety error or missed critical action: remediation required.
  final bool critical;
  final Map<String, int> categories;
  final String outcome;
  final List<String> notes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'role': role,
        'day': day,
        'score': score,
        'passed': passed,
        'critical': critical,
        'categories': categories,
        'outcome': outcome,
        'notes': notes,
      };
}

/// Everything the simulator saves for one student.
class CareerProfile {
  CareerProfile({
    this.version = 1,
    this.day = 1,
    this.majorId = '',
    this.deptId = '',
    this.stage = CareerStage.student,
    Map<String, TaskResult>? taskResults,
    Set<String>? completedModules,
    Set<String>? studiedLessons,
    Map<String, double>? skillPoints,
    List<PortfolioItem>? portfolio,
    Resume? resume,
    List<CoverLetter>? coverLetters,
    List<JobApplication>? applications,
    List<InterviewRecord>? practiceInterviews,
    List<Employment>? employment,
    List<CertificationRecord>? certifications,
    List<CareerEvent>? log,
    Map<String, String>? writings,
    Map<String, LabRun>? labRuns,
    List<LabCompletion>? labCompletions,
    List<MoneyEntry>? ledger,
    List<Paycheck>? paychecks,
    List<ResumeUpload>? resumeUploads,
    this.defaultResumeId = '',
    Map<String, HospitalRun>? hospitalRuns,
    List<HospitalResult>? hospitalResults,
    this.updatedAtMs = 0,
  })  : ledger = ledger ?? <MoneyEntry>[],
        hospitalRuns = hospitalRuns ?? <String, HospitalRun>{},
        hospitalResults = hospitalResults ?? <HospitalResult>[],
        paychecks = paychecks ?? <Paycheck>[],
        resumeUploads = resumeUploads ?? <ResumeUpload>[],
        writings = writings ?? <String, String>{},
        labRuns = labRuns ?? <String, LabRun>{},
        labCompletions = labCompletions ?? <LabCompletion>[],
        taskResults = taskResults ?? <String, TaskResult>{},
        completedModules = completedModules ?? <String>{},
        studiedLessons = studiedLessons ?? <String>{},
        skillPoints = skillPoints ?? <String, double>{},
        portfolio = portfolio ?? <PortfolioItem>[],
        resume = resume ?? const Resume(),
        coverLetters = coverLetters ?? <CoverLetter>[],
        applications = applications ?? <JobApplication>[],
        practiceInterviews = practiceInterviews ?? <InterviewRecord>[],
        employment = employment ?? <Employment>[],
        certifications = certifications ?? <CertificationRecord>[],
        log = log ?? <CareerEvent>[];

  factory CareerProfile.fromJson(Map<String, dynamic> j) => CareerProfile(
        version: _int(j['version'], 1),
        day: _int(j['day'], 1),
        majorId: _str(j['majorId']),
        deptId: _str(j['deptId']),
        stage: CareerStage.parse(j['stage']),
        taskResults: _map(j['taskResults']).map((String k, dynamic v) =>
            MapEntry<String, TaskResult>(k, TaskResult.fromJson(_map(v)))),
        completedModules: _strList(j['completedModules']).toSet(),
        studiedLessons: _strList(j['studiedLessons']).toSet(),
        skillPoints: _map(j['skillPoints'])
            .map((String k, dynamic v) => MapEntry<String, double>(k, _double(v))),
        portfolio: _mapList(j['portfolio']).map(PortfolioItem.fromJson).toList(),
        resume: j['resume'] is Map ? Resume.fromJson(_map(j['resume'])) : const Resume(),
        coverLetters: _mapList(j['coverLetters']).map(CoverLetter.fromJson).toList(),
        applications: _mapList(j['applications']).map(JobApplication.fromJson).toList(),
        practiceInterviews:
            _mapList(j['practiceInterviews']).map(InterviewRecord.fromJson).toList(),
        employment: _mapList(j['employment']).map(Employment.fromJson).toList(),
        certifications:
            _mapList(j['certifications']).map(CertificationRecord.fromJson).toList(),
        log: _mapList(j['log']).map(CareerEvent.fromJson).toList(),
        writings: _map(j['writings']).map((String k, dynamic v) => MapEntry<String, String>(k, '$v')),
        labRuns: _map(j['labRuns']).map((String k, dynamic v) => MapEntry<String, LabRun>(k, LabRun.fromJson(_map(v)))),
        labCompletions: _mapList(j['labCompletions']).map(LabCompletion.fromJson).toList(),
        ledger: _mapList(j['ledger']).map(MoneyEntry.fromJson).toList(),
        paychecks: _mapList(j['paychecks']).map(Paycheck.fromJson).toList(),
        resumeUploads: _mapList(j['resumeUploads']).map(ResumeUpload.fromJson).toList(),
        defaultResumeId: _str(j['defaultResumeId']),
        hospitalRuns: <String, HospitalRun>{
          for (final MapEntry<String, dynamic> e in _map(j['hospitalRuns']).entries)
            if (e.value is Map) e.key: HospitalRun.fromJson(_map(e.value)),
        },
        hospitalResults: _mapList(j['hospitalResults']).map(HospitalResult.fromJson).toList(),
        updatedAtMs: _int(j['updatedAtMs']),
      );

  int version;

  /// Simulated working day. Employers respond and deadlines fall on days.
  int day;
  String majorId;

  /// Department the student is currently training in.
  String deptId;
  CareerStage stage;

  /// Best result per task id.
  final Map<String, TaskResult> taskResults;
  final Set<String> completedModules;
  final Set<String> studiedLessons;
  final Map<String, double> skillPoints;
  final List<PortfolioItem> portfolio;
  Resume resume;
  final List<CoverLetter> coverLetters;
  final List<JobApplication> applications;
  final List<InterviewRecord> practiceInterviews;
  final List<Employment> employment;
  final List<CertificationRecord> certifications;
  final List<CareerEvent> log;

  /// Saved written work (project write-ups) by task key.
  final Map<String, String> writings;

  /// The current (or last) run of each practical lab, saved after every step.
  final Map<String, LabRun> labRuns;
  final List<LabCompletion> labCompletions;

  /// Virtual earnings (net, in US cents) from paychecks and training stipends.
  final List<MoneyEntry> ledger;

  /// Every processed virtual paycheck.
  final List<Paycheck> paychecks;

  /// Uploaded resume files (at most three are kept).
  final List<ResumeUpload> resumeUploads;

  /// The upload used by default when applying; empty = the built resume.
  String defaultResumeId;

  /// Virtual hospital runs (by case, shift or 'triage') and results.
  final Map<String, HospitalRun> hospitalRuns;
  final List<HospitalResult> hospitalResults;

  bool hospitalPassed(String id) => hospitalResults.any((HospitalResult r) => r.id == id && r.passed);
  int updatedAtMs;

  /// Current virtual balance in US cents.
  int get balanceCents => ledger.fold<int>(0, (int a, MoneyEntry e) => a + e.cents);

  /// Virtual money earned in the last [days] simulated days, in cents.
  int earnedInLast(int days) => ledger.where((MoneyEntry e) => e.cents > 0 && e.day > day - days).fold<int>(0, (int a, MoneyEntry e) => a + e.cents);

  ResumeUpload? resumeUpload(String id) {
    for (final ResumeUpload u in resumeUploads) {
      if (u.id == id) return u;
    }
    return null;
  }

  LabCompletion? bestLab(String labId) {
    LabCompletion? best;
    for (final LabCompletion c in labCompletions) {
      if (c.labId == labId && (best == null || c.score > best.score)) best = c;
    }
    return best;
  }

  bool labPassed(String labId) => labCompletions.any((LabCompletion c) => c.labId == labId && c.passed);

  bool labScenarioPassed(String labId, String scenarioId) =>
      labCompletions.any((LabCompletion c) => c.labId == labId && c.scenarioId == scenarioId && c.passed);

  LabCompletion? bestLabScenario(String labId, String scenarioId) {
    LabCompletion? best;
    for (final LabCompletion c in labCompletions) {
      if (c.labId == labId && c.scenarioId == scenarioId && (best == null || c.score > best.score)) best = c;
    }
    return best;
  }

  Employment? get currentJob {
    for (final Employment e in employment.reversed) {
      if (e.active) return e;
    }
    return null;
  }

  bool hasCertification(String id) =>
      certifications.any((CertificationRecord c) => c.id == id);

  JobApplication? application(String id) {
    for (final JobApplication a in applications) {
      if (a.id == id) return a;
    }
    return null;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'day': day,
        'majorId': majorId,
        'deptId': deptId,
        'stage': stage.name,
        'taskResults': taskResults.map(
            (String k, TaskResult v) => MapEntry<String, dynamic>(k, v.toJson())),
        'completedModules': completedModules.toList()..sort(),
        'studiedLessons': studiedLessons.toList()..sort(),
        'skillPoints': skillPoints,
        'portfolio': portfolio.map((PortfolioItem p) => p.toJson()).toList(),
        'resume': resume.toJson(),
        'coverLetters': coverLetters.map((CoverLetter c) => c.toJson()).toList(),
        'applications': applications.map((JobApplication a) => a.toJson()).toList(),
        'practiceInterviews':
            practiceInterviews.map((InterviewRecord r) => r.toJson()).toList(),
        'employment': employment.map((Employment e) => e.toJson()).toList(),
        'certifications':
            certifications.map((CertificationRecord c) => c.toJson()).toList(),
        'log': log.map((CareerEvent e) => e.toJson()).toList(),
        'writings': writings,
        'labRuns': labRuns.map((String k, LabRun v) => MapEntry<String, dynamic>(k, v.toJson())),
        'labCompletions': labCompletions.map((LabCompletion c) => c.toJson()).toList(),
        'ledger': ledger.map((MoneyEntry e) => e.toJson()).toList(),
        'paychecks': paychecks.map((Paycheck e) => e.toJson()).toList(),
        'resumeUploads': resumeUploads.map((ResumeUpload e) => e.toJson()).toList(),
        'defaultResumeId': defaultResumeId,
        'hospitalRuns': <String, dynamic>{for (final MapEntry<String, HospitalRun> e in hospitalRuns.entries) e.key: e.value.toJson()},
        'hospitalResults': hospitalResults.map((HospitalResult r) => r.toJson()).toList(),
        'updatedAtMs': updatedAtMs,
      };
}
