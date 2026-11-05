import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../labs/ui/lab_screens.dart';
import 'career_centre.dart';
import 'hub_screens.dart';
import 'common.dart';
import 'department_screens.dart';
import 'job_screens.dart';
import 'workplace_screen.dart';

/// The next thing the student should do, derived from their record.
class NextStep {
  const NextStep(this.title, this.detail, this.open);
  final String title;
  final String detail;
  final void Function(BuildContext context) open;
}

NextStep nextStep(CareerSimStore store) {
  final CareerProfile p = store.profile;
  final Department? d = store.department;
  void push(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => w));
  if (d == null) {
    return NextStep('Choose your department', 'Pick the school you are training in.', (BuildContext c) => push(c, const DepartmentPickerScreen()));
  }
  final Employment? job = p.currentJob;
  if (job != null) {
    if (job.open != null) return NextStep('Finish your assignment', 'Your supervisor is waiting for it.', (BuildContext c) => push(c, const AssignmentScreen()));
    if (store.internshipFinished(job)) {
      return NextStep('Request your final evaluation', 'All internship assignments are evaluated.', (BuildContext c) => push(c, const WorkplaceScreen()));
    }
    return NextStep('Go to work', 'Get your next assignment from ${store.workplaceOf(job)?.supervisor ?? 'your supervisor'}.',
        (BuildContext c) => push(c, const WorkplaceScreen()));
  }
  for (final JobApplication a in p.applications.reversed) {
    final JobPosting? j = CareerCatalog.posting(a.postingId);
    if (j == null) continue;
    void open(BuildContext c) => push(c, ApplicationScreen(applicationId: a.id));
    switch (a.status) {
      case ApplicationStatus.offerReceived:
        return NextStep('Review your offer', '${j.company.name}: ${a.offer?.title ?? j.title}', open);
      case ApplicationStatus.shortlisted:
        return NextStep('Book your interview', '${j.company.name} shortlisted you.', open);
      case ApplicationStatus.interviewScheduled:
        return NextStep(store.interviewAvailable(a) ? 'Attend your interview today' : 'Interview on day ${a.interviewDay}',
            '${j.company.name} · ${j.title}', open);
      case ApplicationStatus.furtherAssessment:
        if (a.assessment == null) return NextStep('Complete the further assessment', j.company.name, open);
      case ApplicationStatus.draft:
        return NextStep('Finish your application', '${j.title} at ${j.company.name}', open);
      default:
        break;
    }
  }
  for (final LabSpec l in LabCatalog.all) {
    final LabRun? run = p.labRuns[l.id];
    if (run != null && !run.done) {
      return NextStep('Continue lab: ${l.title}', labStatus(p, l), (BuildContext c) => push(c, LabIntroScreen(labId: l.id)));
    }
  }
  for (final LabSpec l in LabCatalog.forDept(d.id)) {
    if (!p.labPassed(l.id)) {
      return NextStep('Practical lab: ${l.title}', l.environment.label, (BuildContext c) => push(c, LabIntroScreen(labId: l.id)));
    }
  }
  for (final TrainingModule m in d.modules) {
    if (!p.completedModules.contains(m.id)) {
      return NextStep(p.studiedLessons.contains(m.id) ? 'Practise: ${m.title}' : 'Learn: ${m.title}', 'Training module in ${d.title}',
          (BuildContext c) => push(c, ModuleScreen(deptId: d.id, moduleId: m.id)));
    }
    if (p.stage == CareerStage.student && CareerRules.traineeCriteria(p, d).every((Criterion x) => x.met)) {
      return NextStep('Request trainee status', 'You meet the criteria.', (BuildContext c) => push(c, const CareerCentreScreen()));
    }
  }
  for (final ProjectSpec pr in d.projects) {
    if (!store.projectPublished(pr.id) && store.projectBlockers(pr).isEmpty) {
      return NextStep('Build a portfolio project', pr.title, (BuildContext c) => push(c, ProjectScreen(deptId: d.id, projectId: pr.id)));
    }
  }
  return NextStep('Visit the Career Centre', 'Polish your resume and apply for roles.', (BuildContext c) => push(c, const CareerCentreScreen()));
}

/// The career simulator home (the Labs tab).
class CareerSimDashboard extends StatelessWidget {
  const CareerSimDashboard({super.key, required this.studentName, required this.majorLabel, this.onOpenCourses});

  final String studentName;
  final String majorLabel;

  /// Switches to the courses tab (provided by the campus shell).
  final VoidCallback? onOpenCourses;

  void _push(BuildContext c, Widget w) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    if (!store.loaded) return const Center(child: CircularProgressIndicator());
    final CareerProfile p = store.profile;
    final Department? d = store.department;
    final NextStep next = nextStep(store);
    final Employment? job = p.currentJob;
    final List<TrainingModule> modules = d?.modules ?? const <TrainingModule>[];
    final int doneModules = modules.where((TrainingModule m) => p.completedModules.contains(m.id)).length;
    final int passedTasks = p.taskResults.values.where((TaskResult r) => r.passed).length;
    final List<JobApplication> active = p.applications.where((JobApplication a) => a.status.isActive).toList();
    final List<JobPosting> openRoles = d == null
        ? const <JobPosting>[]
        : CareerCatalog.postingsFor(d.id).where((JobPosting j) => PostingSchedule.isOpen(j, p.day)).toList();

    return SafeArea(
      child: ListView(
        key: const ValueKey<String>('career_dashboard'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          Text('Career Simulator', style: TextStyle(color: VuV2Colors.ink, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text('Learn → practise → build experience → apply → interview → work → progress',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12.5)),
          const SizedBox(height: 10),
          GradeGlowNav(onOpenCourses: onOpenCourses),
          if (store.syncWarning != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(store.syncWarning!, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12.5)),
            ),
          const SizedBox(height: 12),
          SectionCard(
            title: p.resume.fullName.isNotEmpty ? p.resume.fullName : studentName,
            subtitle: '$majorLabel${d == null ? '' : ' · ${d.title}'}',
            trailing: StatusChip(p.stage.label),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child: Text('Day ${p.day}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700))),
                  const NextDayButton(),
                ]),
                const SizedBox(height: 10),
                Material(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    key: const ValueKey<String>('next_step'),
                    leading: const Icon(Icons.flag_rounded),
                    title: Text(next.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(next.detail),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => next.open(context),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                  OutlinedButton.icon(
                    key: const ValueKey<String>('dash_department'),
                    onPressed: () => d == null ? _push(context, const DepartmentPickerScreen()) : _push(context, DepartmentScreen(deptId: d.id)),
                    icon: const Icon(Icons.account_balance_rounded),
                    label: Text(d == null ? 'Departments' : d.title),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('dash_career_centre'),
                    onPressed: () => _push(context, const CareerCentreScreen()),
                    icon: const Icon(Icons.business_center_rounded),
                    label: const Text('Career Centre'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('dash_workplace'),
                    onPressed: () => _push(context, const WorkplaceScreen()),
                    icon: const Icon(Icons.apartment_rounded),
                    label: const Text('Workplace'),
                  ),
                  TextButton(
                    key: const ValueKey<String>('dash_change_department'),
                    onPressed: () => _push(context, const DepartmentPickerScreen()),
                    child: const Text('Change department'),
                  ),
                ]),
              ],
            ),
          ),
          _PracticalTraining(deptId: d?.id ?? ''),
          if (d != null) ...<Widget>[
            SectionCard(
              title: 'Academic progress',
              child: Column(children: <Widget>[
                LabeledBar(
                  label: 'Training modules completed',
                  value: modules.isEmpty ? 0 : (doneModules * 100 / modules.length).round(),
                  detail: '$doneModules of ${modules.length} · ${p.studiedLessons.length} lessons studied · $passedTasks graded tasks passed',
                ),
              ]),
            ),
            SectionCard(
              title: 'Training modules',
              child: Column(children: <Widget>[
                for (final TrainingModule m in modules)
                  ListTile(
                    key: ValueKey<String>('dash_module_${m.id}'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(p.completedModules.contains(m.id) ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                        color: p.completedModules.contains(m.id) ? VuV2Colors.success : null),
                    title: Text(m.title),
                    onTap: () => _push(context, ModuleScreen(deptId: d.id, moduleId: m.id)),
                  ),
              ]),
            ),
            SectionCard(
              title: 'Skills',
              subtitle: 'Levels rise only when you pass graded work.',
              child: Column(children: <Widget>[
                for (final SkillDef s in d.skills)
                  LabeledBar(
                    label: s.label,
                    value: ((p.skillPoints[s.id] ?? 0) / 8 * 100).round().clamp(0, 100),
                    detail: CareerRules.levelLabel(CareerRules.levelOf(p, s.id)),
                  ),
              ]),
            ),
            SectionCard(
              title: 'Career readiness: ${CareerRules.readiness(p, d).score}',
              subtitle: CareerRules.readiness(p, d).band,
              trailing: TextButton(onPressed: () => _push(context, const CareerCentreScreen()), child: const Text('Details')),
              child: LabeledBar(label: 'Readiness for ${d.title} roles', value: CareerRules.readiness(p, d).score),
            ),
          ],
          SectionCard(
            title: 'Projects, assessments and qualifications',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (p.portfolio.isEmpty && p.certifications.isEmpty && !p.employment.any((Employment e) => !e.active))
                  Text('Nothing yet.', style: TextStyle(color: VuV2Colors.mute)),
                for (final PortfolioItem i in p.portfolio)
                  ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.folder_special_rounded), title: Text(i.title), subtitle: Text('Project · score ${i.score}')),
                for (final CertificationRecord c in p.certifications)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.workspace_premium_rounded),
                    title: Text(CareerCatalog.certification(c.id)?.title ?? c.id),
                    subtitle: Text('Certification · ${c.score} · day ${c.day}'),
                  ),
                for (final Employment e in p.employment.where((Employment e) => e.stage == CareerStage.intern && !e.active))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_rounded),
                    title: Text('Internship · ${e.employer}'),
                    subtitle: Text(e.finalReview ?? e.endReason),
                  ),
              ],
            ),
          ),
          SectionCard(
            title: 'Opportunities',
            trailing: TextButton(key: const ValueKey<String>('dash_all_jobs'), onPressed: () => _push(context, const JobBoardScreen()), child: const Text('All')),
            child: Column(children: <Widget>[
              if (openRoles.isEmpty) Text('No open roles in your field right now.', style: TextStyle(color: VuV2Colors.mute)),
              for (final JobPosting j in openRoles.take(3))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(j.title),
                  subtitle: Text('${j.company.name} · ${j.type.label} · closes day ${PostingSchedule.deadline(j, p.day)}'),
                  onTap: () => _push(context, JobDetailScreen(postingId: j.id)),
                ),
            ]),
          ),
          SectionCard(
            title: 'Applications and interviews',
            trailing: TextButton(key: const ValueKey<String>('dash_tracker'), onPressed: () => _push(context, const ApplicationsTrackerScreen()), child: const Text('Tracker')),
            child: Column(children: <Widget>[
              if (active.isEmpty) Text('No active applications.', style: TextStyle(color: VuV2Colors.mute)),
              for (final JobApplication a in active)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(CareerCatalog.posting(a.postingId)?.title ?? a.postingId),
                  subtitle: Text('${CareerCatalog.posting(a.postingId)?.company.name ?? ''}'
                      '${a.status == ApplicationStatus.interviewScheduled ? ' · interview day ${a.interviewDay}' : ''}'),
                  trailing: StatusChip(a.status.label, color: statusColor(a.status)),
                  onTap: () => _push(context, ApplicationScreen(applicationId: a.id)),
                ),
            ]),
          ),
          SectionCard(
            title: 'Employment',
            child: job == null
                ? Text(p.employment.isEmpty ? 'Not employed yet.' : 'Not currently employed.', style: TextStyle(color: VuV2Colors.mute))
                : ListTile(
                    key: const ValueKey<String>('dash_current_job'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.work_rounded),
                    title: Text('${job.title} · ${job.employer}'),
                    subtitle: Text('${money(job.salary, job.salaryPeriod)} · performance ${job.performance} · ${job.evaluated.length} evaluated'),
                    onTap: () => _push(context, const WorkplaceScreen()),
                  ),
          ),
          if (p.employment.isNotEmpty) EmploymentHistory(employment: p.employment),
          SectionCard(
            title: 'Activity',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (p.log.isEmpty) Text('Your record starts when you complete your first task.', style: TextStyle(color: VuV2Colors.mute)),
                for (final CareerEvent e in p.log.reversed.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('Day ${e.day} · ${e.text}', style: TextStyle(color: VuV2Colors.ink, fontSize: 13)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticalTraining extends StatelessWidget {
  const _PracticalTraining({required this.deptId});
  final String deptId;

  @override
  Widget build(BuildContext context) {
    final CareerProfile p = context.watch<CareerSimStore>().profile;
    final List<LabSpec> mine = LabCatalog.forDept(deptId);
    final List<LabSpec> labs = mine.isEmpty ? LabCatalog.all : mine;
    final List<LabSpec> inProgress = <LabSpec>[
      for (final LabSpec l in LabCatalog.all)
        if (p.labRuns[l.id] != null && !p.labRuns[l.id]!.done) l,
    ];
    LabSpec? next;
    for (final LabSpec l in labs) {
      if (!p.labPassed(l.id)) {
        next = l;
        break;
      }
    }
    final int passed = labs.where((LabSpec l) => p.labPassed(l.id)).length;
    void open(String id) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LabIntroScreen(labId: id)));
    return SectionCard(
      title: 'Practical training',
      subtitle: mine.isEmpty ? 'Labs for your department are not built yet — all labs are open to you.' : '$passed of ${labs.length} labs passed',
      trailing: TextButton(
        key: const ValueKey<String>('dash_all_labs'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PracticalLabsScreen())),
        child: const Text('All labs'),
      ),
      child: Column(children: <Widget>[
        for (final LabSpec l in inProgress)
          ListTile(
            key: ValueKey<String>('dash_continue_${l.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(environmentIcon(l.environment)),
            title: Text('Continue: ${l.title}'),
            subtitle: Text(labStatus(p, l)),
            trailing: const Icon(Icons.play_arrow_rounded),
            onTap: () => open(l.id),
          ),
        if (next != null && !inProgress.contains(next))
          ListTile(
            key: const ValueKey<String>('dash_next_lab'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(environmentIcon(next.environment)),
            title: Text('Next lab: ${next.title}'),
            subtitle: Text('${next.environment.label} · ${next.minutes} min'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(next!.id),
          ),
      ]),
    );
  }
}
