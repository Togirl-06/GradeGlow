import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/pay_rules.dart';
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
import 'money_find_screens.dart';
import '../hospital/ui/hospital_screens.dart';
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
  for (final LabSpec l in myLabs(p, d.id)) {
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

/// The career simulator home: a short page with the next step, search,
/// earnings and grouped shortcuts. Details live on their own screens.
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
    final int active = p.applications.where((JobApplication a) => a.status.isActive).length;
    final int openRoles = d == null ? 0 : CareerCatalog.postingsFor(d.id).where((JobPosting j) => PostingSchedule.isOpen(j, p.day)).length;
    final Color accent = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: SingleChildScrollView(
        key: const ValueKey<String>('career_dashboard'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text('Career Simulator', style: TextStyle(color: VuV2Colors.ink, fontSize: 26, fontWeight: FontWeight.w900))),
              Tooltip(
                message: simulatedPayNote,
                child: ActionChip(
                  key: const ValueKey<String>('dash_wallet'),
                  avatar: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                  label: Text(usd(p.balanceCents), style: const TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: () => _push(context, const MoneyScreen()),
                ),
              ),
            ]),
            Text('${p.resume.fullName.isNotEmpty ? p.resume.fullName : studentName} · $majorLabel · ${p.stage.label}',
                style: TextStyle(color: VuV2Colors.mute, fontSize: 13)),
            const SizedBox(height: 12),
            Material(
              color: VuV2Colors.mute.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                key: const ValueKey<String>('dash_search'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => _push(context, const FindScreen()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(children: <Widget>[
                    Icon(Icons.search_rounded, color: VuV2Colors.mute),
                    const SizedBox(width: 10),
                    Text('Find a lab, lesson, job or screen', style: TextStyle(color: VuV2Colors.mute)),
                  ]),
                ),
              ),
            ),
            if (store.syncWarning != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(store.syncWarning!, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12.5)),
              ),
            const SizedBox(height: 12),
            Material(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: Column(children: <Widget>[
                ListTile(
                  key: const ValueKey<String>('next_step'),
                  leading: const Icon(Icons.flag_rounded),
                  title: Text('Next: ${next.title}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(next.detail),
                  trailing: const Icon(Icons.arrow_forward_rounded),
                  onTap: () => next.open(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
                  child: Row(children: <Widget>[
                    Expanded(child: Text('Day ${p.day}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700))),
                    const NextDayButton(),
                  ]),
                ),
              ]),
            ),
            _PracticalTraining(store: store),
            _Group(title: 'Learn', tiles: <_Tile>[
              if (onOpenCourses != null) _Tile('nav_courses', Icons.menu_book_rounded, 'My Courses', 'Your classes', onOpenCourses!),
              _Tile('dash_department', Icons.account_balance_rounded, d?.title ?? 'Departments', d == null ? 'Choose your school' : 'Lessons and projects',
                  () => _push(context, d == null ? const DepartmentPickerScreen() : DepartmentScreen(deptId: d.id))),
              _Tile('nav_labs', Icons.science_rounded, 'Practical Labs', 'Hands-on work · paid', () => _push(context, const PracticalLabsScreen())),
              _Tile('nav_assessments', Icons.fact_check_rounded, 'Assessments', 'Tests and certificates', () => _push(context, const AssessmentsScreen())),
              if (const <String>{'nursing', 'medicine'}.contains(p.deptId) || const <String>{'nursing', 'medicine'}.contains(p.currentJob?.deptId))
                _Tile('nav_hospital', Icons.local_hospital_rounded, 'Virtual Hospital', 'Patients, shifts, triage', () => _push(context, const HospitalScreen())),
            ]),
            _Group(title: 'Get hired', tiles: <_Tile>[
              _Tile('nav_career', Icons.business_center_rounded, 'Career Centre', 'Resume and cover letter', () => _push(context, const CareerCentreScreen())),
              _Tile('dash_all_jobs', Icons.work_outline_rounded, 'Job Board', '$openRoles open in your field', () => _push(context, const JobBoardScreen())),
              _Tile('nav_applications', Icons.track_changes_rounded, 'My Applications', active == 0 ? 'None active' : '$active active', () => _push(context, const ApplicationsTrackerScreen())),
            ]),
            _Group(title: 'Work and earn', tiles: <_Tile>[
              _Tile('nav_workplace', Icons.apartment_rounded, 'My Workplace', job == null ? 'Not employed yet' : '${job.title} · ${job.employer}', () => _push(context, const WorkplaceScreen())),
              _Tile('nav_money', Icons.account_balance_wallet_rounded, 'My Earnings', '${usd(p.balanceCents)} · virtual USD', () => _push(context, const MoneyScreen())),
              _Tile('nav_portfolio', Icons.folder_special_rounded, 'My Portfolio', '${p.portfolio.length} item${p.portfolio.length == 1 ? '' : 's'}', () => _push(context, const PortfolioScreen())),
              _Tile('nav_progress', Icons.insights_rounded, 'Progress', 'Skills and readiness', () => _push(context, const ProgressScreen())),
            ]),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              Text('Recent activity', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(key: const ValueKey<String>('nav_schools'), onPressed: () => _push(context, const DepartmentPickerScreen()), child: const Text('Change school')),
            ]),
            if (p.log.isEmpty) Text('Your record starts when you complete your first task.', style: TextStyle(color: VuV2Colors.mute)),
            for (final CareerEvent e in p.log.reversed.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Day ${e.day} · ${e.text}', style: TextStyle(color: VuV2Colors.ink, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tile {
  const _Tile(this.key, this.icon, this.label, this.caption, this.onTap);
  final String key;
  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;
}

/// A titled group of large shortcut tiles: two per row on phones, four on wide screens.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.tiles});
  final String title;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Text(title, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
          final int cols = c.maxWidth >= 720 ? 4 : 2;
          final double w = (c.maxWidth - 10 * (cols - 1)) / cols;
          return Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
            for (final _Tile t in tiles)
              SizedBox(
                width: w,
                child: Material(
                  color: VuV2Colors.mute.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    key: ValueKey<String>(t.key),
                    borderRadius: BorderRadius.circular(14),
                    onTap: t.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Icon(t.icon, color: VuV2Colors.orange),
                        const SizedBox(height: 6),
                        Text(t.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
                        Text(t.caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]);
        }),
      ]),
    );
  }
}

/// The student's labs, own major first.
List<LabSpec> myLabs(CareerProfile p, String deptId) {
  final List<LabSpec> major = LabCatalog.forMajor(p.majorId);
  final List<LabSpec> dept = LabCatalog.forDept(deptId).where((LabSpec l) => !major.contains(l)).toList();
  return <LabSpec>[...major, ...dept];
}

class _PracticalTraining extends StatelessWidget {
  const _PracticalTraining({required this.store});
  final CareerSimStore store;

  @override
  Widget build(BuildContext context) {
    final CareerProfile p = store.profile;
    final List<LabSpec> mine = myLabs(p, store.department?.id ?? '');
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
      subtitle: mine.isEmpty ? 'Labs for your department are not built yet — all labs are open to you.' : '$passed of ${labs.length} labs passed · each pass earns simulated pay',
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
