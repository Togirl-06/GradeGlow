import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../services/code_judge_service.dart';
import '../../services/lab_runner/lab_runner.dart';
import '../ai/career_ai.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_grading.dart';
import '../labs/lab_models.dart';
import '../model/tasks.dart';
import 'career_repository.dart';

/// A request the rules refused. The message is shown to the student.
class CareerActionException implements Exception {
  CareerActionException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Holds the student's career profile and applies every rule-checked change.
/// Each change is saved to the device, and to Firestore when signed in.
class CareerSimStore extends ChangeNotifier {
  CareerSimStore({CareerRepository? repository, int Function()? clock, CodeJudgeService? judge, LabRunner? runner, this.ai})
      : _repo = repository ?? DefaultCareerRepository(),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch),
        _judge = judge,
        _runner = runner;

  final CareerRepository _repo;
  final int Function() _clock;
  CodeJudgeService? _judge;

  /// Server code judge (created on first use so tests can inject one).
  CodeJudgeService get judge => _judge ??= CodeJudgeService();

  LabRunner? _runner;

  /// Runs and grades code: on the student's device on web and phones, on the
  /// server elsewhere.
  LabRunner get runner => _runner ??= LabRunner.create(fallback: judge);

  /// Optional AI for the lecturer / interviewer / supervisor roles.
  CareerAi? ai;

  CareerProfile profile = CareerProfile();
  bool loaded = false;
  String? _uid;

  /// Null when the last save fully succeeded.
  String? syncWarning;

  int get day => profile.day;

  Department? get department => CareerCatalog.department(profile.deptId);

  // ------------------------------------------------------------ persistence

  Future<void> ensureLoaded({String? userId, String? majorId, String? displayName}) async {
    if (loaded && _uid == userId) {
      if (majorId != null) await syncMajor(majorId);
      return;
    }
    _uid = userId;
    CareerProfile? local;
    CareerProfile? remote;
    try {
      final Map<String, dynamic>? j = await _repo.loadLocal(userId);
      if (j != null) local = CareerProfile.fromJson(j);
    } catch (_) {
      local = null;
    }
    if (userId != null && userId.isNotEmpty) {
      try {
        final Map<String, dynamic>? j = await _repo.loadRemote(userId);
        if (j != null) remote = CareerProfile.fromJson(j);
      } catch (_) {
        syncWarning = 'Could not reach cloud save; using this device\'s copy.';
      }
    }
    if (local != null && remote != null) {
      profile = remote.updatedAtMs > local.updatedAtMs ? remote : local;
    } else {
      profile = remote ?? local ?? CareerProfile();
    }
    if (profile.resume.fullName.isEmpty && displayName != null && displayName.trim().isNotEmpty &&
        displayName != 'Student') {
      profile.resume = Resume.fromJson(<String, dynamic>{...profile.resume.toJson(), 'fullName': displayName.trim()});
    }
    loaded = true;
    if (majorId != null) {
      await syncMajor(majorId);
    } else {
      notifyListeners();
    }
  }

  Future<void> _commit() async {
    profile.updatedAtMs = _clock();
    notifyListeners();
    final Map<String, dynamic> json = profile.toJson();
    try {
      await _repo.saveLocal(_uid, json);
    } catch (e) {
      syncWarning = 'Not saved on this device: $e';
      notifyListeners();
      throw CareerActionException('Your progress could not be saved. Try again.');
    }
    final String? uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await _repo.saveRemote(uid, json);
        if (syncWarning != null) {
          syncWarning = null;
          notifyListeners();
        }
      } catch (_) {
        syncWarning = 'Saved on this device. Cloud sync failed and will retry on your next change.';
        notifyListeners();
      }
    }
  }

  void _log(String text, [String kind = 'info']) {
    profile.log.add(CareerEvent(day: profile.day, text: text, kind: kind));
    if (profile.log.length > 300) profile.log.removeRange(0, profile.log.length - 300);
  }

  String _id(String prefix) => '${prefix}_${profile.day}_${_clock()}_${profile.applications.length + profile.employment.length}';

  // ------------------------------------------------------------ setup

  Future<void> syncMajor(String majorId) async {
    if (profile.majorId == majorId && profile.deptId.isNotEmpty) {
      notifyListeners();
      return;
    }
    profile.majorId = majorId;
    if (profile.deptId.isEmpty) {
      profile.deptId = CareerCatalog.forMajor(majorId)?.id ?? '';
    }
    await _commit();
  }

  Future<void> chooseDepartment(String deptId) async {
    final Department? d = CareerCatalog.department(deptId);
    if (d == null) throw CareerActionException('Unknown department.');
    profile.deptId = deptId;
    _log('Entered the ${d.title} department.');
    await _commit();
  }

  // ------------------------------------------------------------ learning

  static String moduleTaskKey(TrainingModule m, TaskSpec t) => '${m.id}/${t.id}';
  static String projectTaskKey(ProjectSpec p, TaskSpec t) => 'project:${p.id}/${t.id}';
  static String certTaskKey(Certification c, TaskSpec t) => 'cert:${c.id}/${t.id}';

  Future<void> markLessonStudied(TrainingModule m) async {
    if (profile.studiedLessons.add(m.id)) {
      _log('Studied the lesson "${m.title}".');
      _checkModule(m);
      await _commit();
    }
  }

  void _award(Iterable<String> skills, int points) {
    for (final String s in skills.toSet()) {
      profile.skillPoints[s] = (profile.skillPoints[s] ?? 0) + points;
    }
  }

  void _checkModule(TrainingModule m) {
    if (!profile.completedModules.contains(m.id) && CareerRules.moduleComplete(profile, m)) {
      profile.completedModules.add(m.id);
      _log('Completed training module "${m.title}".', 'milestone');
    }
  }

  /// Records a graded attempt under [key]. Skill points are earned the first
  /// time the task is passed. The best score is kept.
  Future<TaskResult> recordTask(String key, TaskSpec spec, TaskResult result,
      {List<String> fallbackSkills = const <String>[], String? text}) async {
    if (text != null) profile.writings[key] = text;
    final TaskResult dated = result.copyWith(day: profile.day);
    final TaskResult? before = profile.taskResults[key];
    final bool firstPass = dated.passed && !(before?.passed ?? false);
    if (before == null || dated.score >= before.score || (dated.passed && !before.passed)) {
      profile.taskResults[key] = dated;
    }
    if (firstPass) {
      _award(spec.skills.isNotEmpty ? spec.skills : fallbackSkills, CareerRules.practicePoints);
      _log('Passed "${spec.title}" (${dated.score}/100).');
    }
    final TrainingModule? m = CareerCatalog.module(key.split('/').first);
    if (m != null) _checkModule(m);
    await _commit();
    return dated;
  }

  TaskResult? result(String key) => profile.taskResults[key];

  bool projectPublished(String projectId) => profile.portfolio.any((PortfolioItem i) => i.id == projectId);

  List<String> projectBlockers(ProjectSpec p) => <String>[
        for (final String m in p.requiresModules)
          if (!profile.completedModules.contains(m)) 'Complete the module "${CareerCatalog.module(m)?.title ?? m}" first.',
      ];

  Future<PortfolioItem> publishProject(Department d, ProjectSpec p) async {
    final String writeUp = profile.writings[projectTaskKey(p, p.writeUp)] ?? '';
    if (projectPublished(p.id)) throw CareerActionException('This project is already in your portfolio.');
    final List<String> blockers = projectBlockers(p);
    if (blockers.isNotEmpty) throw CareerActionException(blockers.first);
    for (final TaskSpec t in p.deliverables) {
      if (!(profile.taskResults[projectTaskKey(p, t)]?.passed ?? false)) {
        throw CareerActionException('Deliverable "${t.title}" has not passed yet.');
      }
    }
    final TaskResult? w = profile.taskResults[projectTaskKey(p, p.writeUp)];
    if (w == null || !w.passed) throw CareerActionException('The write-up has not passed its rubric yet.');
    final List<int> scores = <int>[
      for (final TaskSpec t in p.deliverables) profile.taskResults[projectTaskKey(p, t)]!.score,
      w.score,
    ];
    final int score = (scores.reduce((int a, int b) => a + b) / scores.length).round();
    final PortfolioItem item = PortfolioItem(
      id: p.id,
      deptId: d.id,
      title: p.title,
      summary: p.brief,
      score: score,
      skills: p.skills,
      day: profile.day,
      writeUp: writeUp,
    );
    profile.portfolio.add(item);
    _award(p.skills, CareerRules.projectPoints);
    _log('Added "${p.title}" to your portfolio (score $score).', 'milestone');
    await _commit();
    return item;
  }

  List<String> certificationBlockers(Certification c) => <String>[
        for (final String m in c.requiresModules)
          if (!profile.completedModules.contains(m)) 'Complete "${CareerCatalog.module(m)?.title ?? m}" first.',
      ];

  Future<CertificationRecord> claimCertification(Department d, Certification c) async {
    if (profile.hasCertification(c.id)) throw CareerActionException('You already hold this certification.');
    final List<String> blockers = certificationBlockers(c);
    if (blockers.isNotEmpty) throw CareerActionException(blockers.first);
    final List<TaskResult> rs = <TaskResult>[];
    for (final TaskSpec t in c.tasks) {
      final TaskResult? r = profile.taskResults[certTaskKey(c, t)];
      if (r == null || !r.passed) throw CareerActionException('Pass "${t.title}" in the exam first.');
      rs.add(r);
    }
    final int avg = (rs.fold<int>(0, (int s, TaskResult r) => s + r.score) / rs.length).round();
    if (avg < c.passMark) throw CareerActionException('Exam average $avg is below the pass mark of ${c.passMark}.');
    final CertificationRecord rec = CertificationRecord(id: c.id, score: avg, day: profile.day);
    profile.certifications.add(rec);
    _award(<String>[for (final TaskSpec t in c.tasks) ...t.skills], CareerRules.certificationPoints);
    _log('Certified: ${c.title} ($avg).', 'milestone');
    await _commit();
    return rec;
  }

  // ------------------------------------------------------------ practical labs

  LabRun? labRun(String labId) => profile.labRuns[labId];

  /// Starts a lab, or continues the unfinished run unless [restart].
  Future<LabRun> startLab(LabSpec lab, {String? scenarioId, bool restart = false}) async {
    final LabRun? existing = profile.labRuns[lab.id];
    if (existing != null && !existing.done && !restart) return existing;
    final String sid = scenarioId ?? lab.scenarios.first.id;
    if (lab.scenario(sid) == null) throw CareerActionException('Scenario not found.');
    final LabRun run = LabRun(labId: lab.id, scenarioId: sid, startedDay: profile.day);
    profile.labRuns[lab.id] = run;
    _log('Started lab: ${lab.title}.', 'lab');
    await _commit();
    return run;
  }

  LabRun _run(LabSpec lab) {
    final LabRun? r = profile.labRuns[lab.id];
    if (r == null) throw CareerActionException('Start the lab first.');
    return r;
  }

  Future<void> setLabPhase(LabSpec lab, LabPhase phase) async {
    final LabRun r = _run(lab);
    if (r.done) throw CareerActionException('This run is finished. Start the lab again to retake it.');
    if (phase == LabPhase.evaluation || phase == LabPhase.complete) {
      final LabScenario sc = lab.scenario(r.scenarioId)!;
      final List<LabStep> missing = sc.steps.where((LabStep s) => !r.results.containsKey(s.id)).toList();
      if (missing.isNotEmpty) throw CareerActionException('Complete "${missing.first.title}" first.');
    }
    r.phase = phase;
    await _commit();
  }

  Future<void> saveLabDraft(LabSpec lab, String stepId, String draft) async {
    final LabRun? r = profile.labRuns[lab.id];
    if (r == null || r.done) return;
    if (r.drafts[stepId] == draft) return;
    r.drafts[stepId] = draft;
    await _commit();
  }

  /// Records a graded attempt at a step (the latest attempt counts).
  Future<TaskResult> recordLabStep(LabSpec lab, LabStep step, TaskResult result) async {
    final LabRun r = _run(lab);
    if (r.done) throw CareerActionException('This run is finished.');
    final TaskResult dated = result.copyWith(day: profile.day);
    r.results[step.id] = dated;
    final String key = 'lab:${lab.id}/${step.id}';
    final bool firstPass = dated.passed && !(profile.taskResults[key]?.passed ?? false);
    if (profile.taskResults[key] == null || dated.score >= profile.taskResults[key]!.score) profile.taskResults[key] = dated;
    if (firstPass) _award(step.skills.isNotEmpty ? step.skills : lab.skills, CareerRules.practicePoints);
    await _commit();
    return dated;
  }

  Future<void> goToLabStep(LabSpec lab, int index) async {
    final LabRun r = _run(lab);
    final LabScenario sc = lab.scenario(r.scenarioId)!;
    if (index < 0 || index >= sc.steps.length) return;
    r.stepIndex = index;
    r.phase = LabPhase.work;
    await _commit();
  }

  /// Ends the run: records the result, skills, portfolio and readiness.
  Future<LabCompletion> finishLab(LabSpec lab) async {
    final LabRun r = _run(lab);
    if (r.done) throw CareerActionException('This run is already finished.');
    final LabScenario sc = lab.scenario(r.scenarioId)!;
    final List<LabStep> missing = sc.steps.where((LabStep s) => !r.results.containsKey(s.id)).toList();
    if (missing.isNotEmpty) throw CareerActionException('Complete "${missing.first.title}" first.');
    final (int score, bool passed) = LabGrader.scenario(sc, r.results);
    r.score = score;
    r.completedDay = profile.day;
    r.phase = LabPhase.complete;
    final LabCompletion c = LabCompletion(labId: lab.id, scenarioId: sc.id, score: score, passed: passed, day: profile.day);
    final bool firstPass = passed && !profile.labPassed(lab.id);
    profile.labCompletions.add(c);
    if (firstPass) {
      _award(lab.skills, CareerRules.projectPoints);
      if (lab.addsToPortfolio && !profile.portfolio.any((PortfolioItem i) => i.id == lab.id)) {
        profile.portfolio.add(PortfolioItem(
          id: lab.id,
          deptId: lab.deptId,
          title: lab.title,
          summary: lab.summary,
          score: score,
          skills: lab.skills,
          day: profile.day,
        ));
      }
    }
    _log('${passed ? 'Passed' : 'Completed'} lab "${lab.title}" ($score/100).', passed ? 'milestone' : 'lab');
    await _commit();
    return c;
  }

  /// Labs whose prerequisites are not yet passed.
  List<String> labPrerequisitesMissing(LabSpec lab) => <String>[
        for (final String id in lab.prerequisites)
          if (!profile.labPassed(id)) LabCatalog.lab(id)?.title ?? id,
      ];

  // ------------------------------------------------------------ stage

  Future<List<Criterion>> requestTraineeStatus() async {
    final Department? d = department;
    if (d == null) throw CareerActionException('Choose a department first.');
    if (profile.stage != CareerStage.student) throw CareerActionException('You already have ${profile.stage.label} status.');
    final List<Criterion> c = CareerRules.traineeCriteria(profile, d);
    if (c.every((Criterion x) => x.met)) {
      profile.stage = CareerStage.trainee;
      _log('Trainee status granted in ${d.title}.', 'milestone');
      await _commit();
    }
    return c;
  }

  // ------------------------------------------------------------ materials

  Future<void> saveResume(Resume r) async {
    final String email = r.email.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw CareerActionException('Enter a valid email address.');
    }
    if (r.fullName.trim().isEmpty) throw CareerActionException('Enter your full name.');
    for (final String id in r.projectIds) {
      if (!profile.portfolio.any((PortfolioItem i) => i.id == id)) {
        throw CareerActionException('A selected project is not in your portfolio.');
      }
    }
    profile.resume = Resume(
      fullName: r.fullName.trim(),
      email: email,
      headline: r.headline.trim(),
      summary: r.summary.trim(),
      education: r.education,
      experience: r.experience,
      skills: r.skills.map((String s) => s.trim()).where((String s) => s.isNotEmpty).toSet().toList(),
      projectIds: r.projectIds,
      updatedDay: profile.day,
    );
    _log('Updated resume.');
    await _commit();
  }

  /// Experience lines generated from verified employment history.
  List<ResumeEntry> verifiedExperience() => <ResumeEntry>[
        for (final Employment e in profile.employment.reversed)
          ResumeEntry(
            heading: '${e.title} · ${e.employer}',
            detail: 'Day ${e.startDay}${e.endDay == null ? '–present' : '–${e.endDay}'} · '
                '${e.evaluated.length} evaluated assignments · performance ${e.performance}/100',
          ),
      ];

  Future<CoverLetter> saveCoverLetter({required String postingId, required String body}) async {
    if (TextRubric.words(body).length < 40) throw CareerActionException('A cover letter needs at least 40 words.');
    profile.coverLetters.removeWhere((CoverLetter c) => c.postingId == postingId);
    final CoverLetter c = CoverLetter(id: 'cl_${postingId.isEmpty ? 'general' : postingId}', postingId: postingId, body: body.trim(), day: profile.day);
    profile.coverLetters.add(c);
    await _commit();
    return c;
  }

  CoverLetter? coverLetterFor(String postingId) {
    for (final CoverLetter c in profile.coverLetters) {
      if (c.postingId == postingId) return c;
    }
    return null;
  }

  Future<InterviewRecord> recordPracticeInterview(InterviewRecord r) async {
    profile.practiceInterviews.add(r);
    if (profile.practiceInterviews.length > 20) profile.practiceInterviews.removeAt(0);
    _log('Completed a mock interview (${r.overall}/100).');
    await _commit();
    return r;
  }

  // ------------------------------------------------------------ applications

  JobApplication? activeApplicationFor(String postingId) {
    for (final JobApplication a in profile.applications) {
      if (a.postingId == postingId && a.status.isActive) return a;
    }
    return null;
  }

  JobPosting _posting(JobApplication a) {
    final JobPosting? p = CareerCatalog.posting(a.postingId);
    if (p == null) throw CareerActionException('This posting no longer exists.');
    return p;
  }

  JobApplication _app(String id) {
    final JobApplication? a = profile.application(id);
    if (a == null) throw CareerActionException('Application not found.');
    return a;
  }

  Future<JobApplication> startApplication(String postingId) async {
    final JobPosting? p = CareerCatalog.posting(postingId);
    if (p == null) throw CareerActionException('Posting not found.');
    if (!PostingSchedule.isOpen(p, profile.day)) {
      throw CareerActionException('Applications are closed. This posting reopens on day ${PostingSchedule.reopens(p, profile.day)}.');
    }
    final JobApplication? existing = activeApplicationFor(postingId);
    if (existing != null) throw CareerActionException('You already have an active application for this role.');
    final JobApplication a = JobApplication(
      id: _id('app'),
      postingId: postingId,
      status: ApplicationStatus.draft,
      createdDay: profile.day,
      coverLetter: coverLetterFor(postingId)?.body ?? coverLetterFor('')?.body ?? '',
      portfolioIds: profile.portfolio.where((PortfolioItem i) => i.deptId == p.deptId).map((PortfolioItem i) => i.id).toList(),
    );
    a.history.add(StatusChange(status: ApplicationStatus.draft, day: profile.day));
    profile.applications.add(a);
    _log('Started an application: ${p.title} at ${p.company.name}.');
    await _commit();
    return a;
  }

  Future<void> saveDraft(String appId, {required String coverLetter, required List<String> portfolioIds}) async {
    final JobApplication a = _app(appId);
    if (a.status != ApplicationStatus.draft) throw CareerActionException('Only drafts can be edited.');
    for (final String id in portfolioIds) {
      if (!profile.portfolio.any((PortfolioItem i) => i.id == id)) throw CareerActionException('Unknown portfolio item.');
    }
    a.coverLetter = coverLetter;
    a.portfolioIds = List<String>.from(portfolioIds);
    await _commit();
  }

  Future<void> submitApplication(String appId) async {
    final JobApplication a = _app(appId);
    final JobPosting p = _posting(a);
    if (a.status != ApplicationStatus.draft) throw CareerActionException('This application was already submitted.');
    if (!PostingSchedule.isOpen(p, profile.day)) throw CareerActionException('The closing date has passed.');
    if (profile.resume.fullName.trim().isEmpty || profile.resume.email.trim().isEmpty) {
      throw CareerActionException('Add your name and email to your resume before applying.');
    }
    if (TextRubric.words(a.coverLetter).length < 80) {
      throw CareerActionException('Write a cover letter of at least 80 words for this role.');
    }
    a.submittedDay = profile.day;
    a.move(ApplicationStatus.submitted, profile.day);
    _log('Submitted application to ${p.company.name} (${p.title}).');
    await _commit();
  }

  Future<void> withdraw(String appId) async {
    final JobApplication a = _app(appId);
    if (!a.status.isActive) throw CareerActionException('This application is already closed.');
    a.move(ApplicationStatus.withdrawn, profile.day, 'Withdrawn by you');
    await _commit();
  }

  /// Moves the calendar forward. Employers act on the days that follow an
  /// event: review the day after submission, decide two days after, and
  /// make hiring decisions the day after the interview or assessment.
  Future<List<String>> advanceDay() async {
    profile.day += 1;
    final int d = profile.day;
    final List<String> news = <String>[];
    for (final JobApplication a in profile.applications) {
      final JobPosting? p = CareerCatalog.posting(a.postingId);
      if (p == null || !a.status.isActive) continue;
      final Department? dept = CareerCatalog.department(p.deptId);
      if (dept == null) continue;
      final int sub = a.submittedDay ?? d;
      switch (a.status) {
        case ApplicationStatus.submitted:
          if (d >= sub + 1) {
            a.move(ApplicationStatus.underReview, d);
            news.add('${p.company.name} is reviewing your application.');
          }
        case ApplicationStatus.underReview:
          if (d >= sub + 2) {
            final ScreeningReport r = CareerRules.screen(profile, dept, p, a, d);
            a.screening = r;
            if (r.shortlisted) {
              a.move(ApplicationStatus.shortlisted, d, 'Screening score ${r.score}');
              a.interviewSlots = <int>[d + 1, d + 2, d + 3];
              news.add('Shortlisted by ${p.company.name}! Choose an interview slot.');
            } else {
              a.move(ApplicationStatus.rejected, d, r.gaps.isEmpty ? 'Not shortlisted' : r.gaps.first);
              news.add('${p.company.name} did not shortlist you. See the screening report.');
            }
          }
        case ApplicationStatus.interviewCompleted:
          if (a.interview != null && d >= a.interview!.day + 1) {
            _decide(a, p, d, news);
          }
        case ApplicationStatus.furtherAssessment:
          if (a.assessment != null && d >= a.assessment!.day + 1) {
            _decide(a, p, d, news);
          }
        case ApplicationStatus.offerReceived:
          if (a.offer != null && d > a.offer!.respondByDay) {
            a.move(ApplicationStatus.offerDeclined, d, 'Offer expired');
            news.add('The offer from ${p.company.name} expired.');
          }
        default:
          break;
      }
    }
    final Employment? job = profile.currentJob;
    final AssignmentRecord? open = job?.open;
    if (open != null && d == open.dueDay + 1) news.add('Your assignment is now overdue.');
    for (final String n in news) {
      _log(n, 'employer');
    }
    await _commit();
    return news;
  }

  void _decide(JobApplication a, JobPosting p, int d, List<String> news) {
    final HiringDecision h = CareerRules.decide(p, a);
    a.decision = h;
    switch (h.outcome) {
      case HiringOutcome.offer:
        final WorkplaceDef? w = CareerCatalog.workplace(p.workplaceId);
        a.offer = JobOffer(
          title: w?.titleFor(p.stageOnHire, p.title) ?? p.title,
          employer: p.company.name,
          salary: CareerRules.offerSalary(p, h.overall),
          salaryPeriod: p.salaryPeriod,
          responsibilities: p.responsibilities,
          startDay: d + 1,
          respondByDay: d + 3,
          stage: p.stageOnHire,
        );
        a.move(ApplicationStatus.offerReceived, d, 'Overall ${h.overall}');
        news.add('Offer received from ${p.company.name}!');
      case HiringOutcome.furtherAssessment:
        a.move(ApplicationStatus.furtherAssessment, d, 'Overall ${h.overall}');
        news.add('${p.company.name} has asked you to complete a further assessment.');
      case HiringOutcome.reject:
        a.move(ApplicationStatus.rejected, d, 'Overall ${h.overall}');
        news.add('${p.company.name} decided not to proceed. See the decision report.');
    }
  }

  Future<void> scheduleInterview(String appId, int slotDay) async {
    final JobApplication a = _app(appId);
    if (a.status != ApplicationStatus.shortlisted) throw CareerActionException('Only shortlisted applications can book an interview.');
    if (!a.interviewSlots.contains(slotDay)) throw CareerActionException('Choose one of the offered slots.');
    a.interviewDay = slotDay;
    a.move(ApplicationStatus.interviewScheduled, profile.day, 'Interview on day $slotDay');
    _log('Interview booked with ${_posting(a).company.name} for day $slotDay.');
    await _commit();
  }

  bool interviewAvailable(JobApplication a) =>
      a.status == ApplicationStatus.interviewScheduled && a.interviewDay != null && profile.day >= a.interviewDay!;

  Future<void> recordInterview(String appId, InterviewRecord r) async {
    final JobApplication a = _app(appId);
    if (!interviewAvailable(a)) throw CareerActionException('This interview is not scheduled for today.');
    a.interview = InterviewRecord.fromJson(<String, dynamic>{...r.toJson(), 'day': profile.day});
    a.move(ApplicationStatus.interviewCompleted, profile.day, 'Interview score ${r.overall}');
    _log('Interviewed with ${_posting(a).company.name} (${r.overall}/100).');
    await _commit();
  }

  /// The task an employer sets as a further assessment.
  static TaskSpec furtherAssessmentTask(JobPosting p) {
    final Department? d = CareerCatalog.department(p.deptId);
    if (d != null && d.certifications.isNotEmpty) return d.certifications.first.tasks.first;
    return d!.modules.first.practice.first;
  }

  Future<void> recordAssessment(String appId, TaskResult r) async {
    final JobApplication a = _app(appId);
    if (a.status != ApplicationStatus.furtherAssessment) throw CareerActionException('No assessment is pending.');
    if (a.assessment != null) throw CareerActionException('The assessment was already submitted.');
    a.assessment = r.copyWith(day: profile.day);
    a.history.add(StatusChange(status: a.status, day: profile.day, note: 'Assessment submitted (${r.score})'));
    await _commit();
  }

  Future<Employment> acceptOffer(String appId) async {
    final JobApplication a = _app(appId);
    final JobPosting p = _posting(a);
    final JobOffer? o = a.offer;
    if (a.status != ApplicationStatus.offerReceived || o == null) throw CareerActionException('There is no open offer.');
    if (profile.day > o.respondByDay) throw CareerActionException('This offer has expired.');
    if (profile.currentJob != null) throw CareerActionException('Resign from your current role before accepting.');
    final Employment e = Employment(
      id: _id('job'),
      postingId: p.id,
      deptId: p.deptId,
      workplaceId: p.workplaceId,
      employer: o.employer,
      title: o.title,
      stage: o.stage,
      salary: o.salary,
      salaryPeriod: o.salaryPeriod,
      startDay: profile.day,
    );
    profile.employment.add(e);
    if (o.stage.index > profile.stage.index) profile.stage = o.stage;
    a.move(ApplicationStatus.hired, profile.day, 'Offer accepted');
    _log('Hired: ${o.title} at ${o.employer}.', 'milestone');
    await _commit();
    return e;
  }

  Future<void> declineOffer(String appId) async {
    final JobApplication a = _app(appId);
    if (a.status != ApplicationStatus.offerReceived) throw CareerActionException('There is no open offer.');
    a.move(ApplicationStatus.offerDeclined, profile.day, 'Declined by you');
    _log('Declined the offer from ${_posting(a).company.name}.');
    await _commit();
  }

  // ------------------------------------------------------------ workplace

  WorkplaceDef? workplaceOf(Employment e) => CareerCatalog.workplace(e.workplaceId);

  AssignmentSpec? specOf(Employment e, AssignmentRecord r) {
    final WorkplaceDef? w = workplaceOf(e);
    return w == null ? null : CareerCatalog.assignment(w, r.assignmentId);
  }

  bool internshipFinished(Employment e) {
    final WorkplaceDef? w = workplaceOf(e);
    return e.stage == CareerStage.intern && w != null && e.evaluated.length >= w.internshipLength;
  }

  Future<AssignmentRecord> requestAssignment() async {
    final Employment? e = profile.currentJob;
    if (e == null) throw CareerActionException('You are not employed yet.');
    if (e.open != null) throw CareerActionException('Finish your current assignment first.');
    final WorkplaceDef? w = workplaceOf(e);
    if (w == null || w.assignments.isEmpty) throw CareerActionException('This workplace has no assignments.');
    if (internshipFinished(e)) throw CareerActionException('Your internship assignments are complete. Request your final evaluation.');
    final List<AssignmentSpec> pool = e.stage.atLeast(CareerStage.experienced)
        ? w.assignments
        : w.assignments.where((AssignmentSpec s) => !s.leadership).toList();
    final AssignmentSpec s = pool[e.assignments.length % pool.length];
    final AssignmentRecord r = AssignmentRecord(
      assignmentId: s.id,
      issuedDay: profile.day,
      dueDay: profile.day + s.deadlineDays,
    );
    e.assignments.add(r);
    _log('${w.supervisor} assigned: ${s.title} (due day ${r.dueDay}).', 'work');
    await _commit();
    return r;
  }

  Future<SupervisorEvaluation> submitAssignment(TaskResult result, String handoffNote) async {
    final Employment? e = profile.currentJob;
    final AssignmentRecord? r = e?.open;
    if (e == null || r == null) throw CareerActionException('There is no open assignment.');
    if (TextRubric.words(handoffNote).length < 15) {
      throw CareerActionException('Write a handoff note of at least 15 words for your supervisor.');
    }
    final AssignmentSpec? s = specOf(e, r);
    if (s == null) throw CareerActionException('Assignment not found.');
    r.submittedDay = profile.day;
    r.result = result.copyWith(day: profile.day);
    r.handoffNote = handoffNote.trim();
    final SupervisorEvaluation ev = CareerRules.evaluate(r, result, handoffNote);
    r.evaluation = ev;
    if (result.passed) {
      final Department? d = CareerCatalog.department(e.deptId);
      final List<String> skills = s.task.skills.isNotEmpty
          ? s.task.skills
          : (d?.skills.take(2).map((SkillDef x) => x.id).toList() ?? <String>[]);
      _award(skills, CareerRules.assignmentPoints);
    }
    _log('Supervisor evaluation: ${s.title} — ${ev.rating} (${ev.overall}).', 'work');
    await _commit();
    return ev;
  }

  Future<PromotionReview> requestPromotion() async {
    final Employment? e = profile.currentJob;
    if (e == null) throw CareerActionException('You are not employed.');
    final Department? d = CareerCatalog.department(e.deptId);
    if (d == null) throw CareerActionException('Department not found.');
    final PromotionReview review = CareerRules.promotion(profile, d, e, profile.day);
    if (review.approved) {
      final CareerStage to = review.to!;
      final WorkplaceDef? w = workplaceOf(e);
      final int salary = (e.salary * 1.12 / 100).round() * 100;
      final String title = w?.titleFor(to, e.title) ?? e.title;
      e.promotions.add(PromotionRecord(from: e.stage, to: to, day: profile.day, title: title, salary: salary));
      e.stage = to;
      e.title = title;
      e.salary = salary;
      if (to.index > profile.stage.index) profile.stage = to;
      _log('Promoted to $title.', 'milestone');
      await _commit();
    } else if (review.to != null) {
      _log('Promotion review: criteria not yet met.');
      await _commit();
    }
    return review;
  }

  Future<List<Criterion>> completeInternship() async {
    final Employment? e = profile.currentJob;
    if (e == null || e.stage != CareerStage.intern) throw CareerActionException('You are not on an internship.');
    final WorkplaceDef? w = workplaceOf(e);
    if (w == null) throw CareerActionException('Workplace not found.');
    if (!internshipFinished(e)) {
      throw CareerActionException('Complete ${w.internshipLength} evaluated assignments first (${e.evaluated.length} so far).');
    }
    final List<Criterion> c = CareerRules.internshipCriteria(e, w);
    final bool passed = c.every((Criterion x) => x.met);
    e.endDay = profile.day;
    e.endReason = 'Internship completed';
    e.finalReview = passed
        ? 'Final evaluation passed: performance ${e.performance}, on time ${(e.onTimeRate * 100).round()}%.'
        : 'Internship completed without a return offer: performance ${e.performance}, on time ${(e.onTimeRate * 100).round()}%.';
    _log(e.finalReview!, 'milestone');
    final JobPosting? ret = w.returnOfferPostingId == null ? null : CareerCatalog.posting(w.returnOfferPostingId!);
    if (passed && ret != null) {
      final JobApplication a = JobApplication(
        id: _id('app'),
        postingId: ret.id,
        status: ApplicationStatus.offerReceived,
        createdDay: profile.day,
        submittedDay: profile.day,
      );
      a.history.add(StatusChange(status: ApplicationStatus.offerReceived, day: profile.day, note: 'Return offer after internship'));
      a.decision = HiringDecision(
        outcome: HiringOutcome.offer,
        overall: e.performance,
        reasons: <String>['Return offer: internship final evaluation passed (${e.performance}).'],
      );
      a.offer = JobOffer(
        title: w.titleFor(ret.stageOnHire, ret.title),
        employer: ret.company.name,
        salary: CareerRules.offerSalary(ret, math.max(70, e.performance)),
        salaryPeriod: ret.salaryPeriod,
        responsibilities: ret.responsibilities,
        startDay: profile.day + 1,
        respondByDay: profile.day + 5,
        stage: ret.stageOnHire,
      );
      profile.applications.add(a);
      _log('Return offer: ${a.offer!.title} at ${ret.company.name}.', 'employer');
    }
    await _commit();
    return c;
  }

  Future<void> resign() async {
    final Employment? e = profile.currentJob;
    if (e == null) throw CareerActionException('You are not employed.');
    if (e.open != null) throw CareerActionException('Hand in your open assignment before resigning.');
    e.endDay = profile.day;
    e.endReason = 'Resigned';
    _log('Resigned from ${e.title} at ${e.employer}.');
    await _commit();
  }

  /// Starts again from an empty profile (Account → reset simulator).
  Future<void> resetAll() async {
    final String major = profile.majorId;
    profile = CareerProfile(majorId: major, deptId: CareerCatalog.forMajor(major)?.id ?? '');
    await _commit();
  }
}
