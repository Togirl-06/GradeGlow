import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../labs/workplace.dart';
import '../labs/ui/lab_screens.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'career_centre.dart';
import 'common.dart';
import 'department_screens.dart';
import 'job_screens.dart';
import 'workplace_screen.dart';
import 'gg_kit.dart';

/// The ten main sections, available from the top of the Career dashboard.
class GradeGlowNav extends StatelessWidget {
  const GradeGlowNav({super.key, this.onOpenCourses});

  /// Switches the app to the courses tab.
  final VoidCallback? onOpenCourses;

  @override
  Widget build(BuildContext context) {
    void push(Widget w) => Navigator.of(context).push(ggRoute<void>((_) => w));
    final List<(String, IconData, String, VoidCallback?)> items = <(String, IconData, String, VoidCallback?)>[
      ('nav_courses', Icons.menu_book_rounded, 'My Courses', onOpenCourses),
      ('nav_schools', Icons.account_balance_rounded, 'Schools', () => push(const DepartmentPickerScreen())),
      ('nav_labs', Icons.science_rounded, 'Practical Labs', () => push(const PracticalLabsScreen())),
      ('nav_assessments', Icons.fact_check_rounded, 'Assessments', () => push(const AssessmentsScreen())),
      ('nav_career', Icons.business_center_rounded, 'Career Centre', () => push(const CareerCentreScreen())),
      ('nav_applications', Icons.track_changes_rounded, 'My Applications', () => push(const ApplicationsTrackerScreen())),
      ('nav_workplace', Icons.apartment_rounded, 'My Workplace', () => push(const WorkplaceScreen())),
      ('nav_portfolio', Icons.folder_special_rounded, 'My Portfolio', () => push(const PortfolioScreen())),
      ('nav_progress', Icons.insights_rounded, 'Progress', () => push(const ProgressScreen())),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final (String key, IconData icon, String label, VoidCallback? onTap) in items)
          if (onTap != null)
            ActionChip(key: ValueKey<String>(key), avatar: Icon(icon, size: 18), label: Text(label), onPressed: onTap),
      ],
    );
  }
}

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Department? d = store.department;
    return Scaffold(
      appBar: AppBar(title: const Text('Assessments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Practical lab evaluations',
            child: Column(children: <Widget>[
              for (final LabSpec l in d == null || LabCatalog.forDept(d.id).isEmpty ? LabCatalog.all : LabCatalog.forDept(d.id))
                ListTile(
                  key: ValueKey<String>('assess_lab_${l.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.title),
                  subtitle: Text(labStatus(p, l)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(ggRoute<void>((_) => LabIntroScreen(labId: l.id))),
                ),
            ]),
          ),
          if (d != null)
            SectionCard(
              title: 'Certification exams · ${d.title}',
              child: Column(children: <Widget>[
                for (final Certification c in d.certifications)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.title),
                    subtitle: Text(p.hasCertification(c.id) ? 'Passed' : 'Not yet taken or not passed'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(ggRoute<void>((_) => CertificationScreen(deptId: d.id, certId: c.id))),
                  ),
              ]),
            ),
          if (d != null)
            SectionCard(
              title: 'Projects',
              child: Column(children: <Widget>[
                for (final ProjectSpec pr in d.projects)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(pr.title),
                    subtitle: Text(store.projectPublished(pr.id) ? 'In portfolio' : 'Not finished'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(ggRoute<void>((_) => ProjectScreen(deptId: d.id, projectId: pr.id))),
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerProfile p = context.watch<CareerSimStore>().profile;
    final List<LabCompletion> passedLabs = <LabCompletion>[
      for (final LabSpec l in LabCatalog.all)
        if (p.labPassed(l.id)) p.bestLab(l.id)!,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('My Portfolio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Projects',
            child: p.portfolio.isEmpty
                ? Text('No projects yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final PortfolioItem i in p.portfolio)
                      ExpansionTile(
                        key: ValueKey<String>('portfolio_${i.id}'),
                        tilePadding: EdgeInsets.zero,
                        title: Text(i.title),
                        subtitle: Text('Score ${i.score} · day ${i.day}'),
                        children: <Widget>[
                          Align(alignment: Alignment.centerLeft, child: Text(i.summary)),
                          if (i.writeUp.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(i.writeUp)),
                        ],
                      ),
                  ]),
          ),
          SectionCard(
            title: 'Certificates',
            child: p.certifications.isEmpty
                ? Text('No certificates yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final CertificationRecord c in p.certifications)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.workspace_premium_rounded),
                        title: Text(CareerCatalog.certification(c.id)?.title ?? c.id),
                        subtitle: Text('${CareerCatalog.certification(c.id)?.issuer ?? ''} · score ${c.score} · day ${c.day}'),
                      ),
                  ]),
          ),
          SectionCard(
            key: const ValueKey<String>('work_log'),
            title: 'Work experience log',
            subtitle: 'Shifts completed and signed off by a supervisor in the practical labs.',
            child: passedLabs.isEmpty
                ? Text('No signed-off shifts yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final LabCompletion c in passedLabs)
                      if (LabCatalog.lab(c.labId) case final LabSpec l)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.work_history_rounded),
                          title: Text('${workplaceFor(l).role} · ${workplaceFor(l).employer}'),
                          subtitle: Text('${l.title} · ${performanceRating(c.score, c.passed)} · ${p.labCompletions.where((LabCompletion x) => x.labId == l.id && x.passed).length * shiftHours(l)} h'),
                        ),
                  ]),
          ),
          SectionCard(
            title: 'Completed practical labs',
            child: passedLabs.isEmpty
                ? Text('No labs passed yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final LabCompletion c in passedLabs)
                      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.science_rounded), title: Text(LabCatalog.lab(c.labId)?.title ?? c.labId), subtitle: Text('${c.score}/100 · day ${c.day}')),
                  ]),
          ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Department? d = store.department;
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Stage: ${p.stage.label}',
            child: BulletList(<String>[
              '${p.completedModules.length} training modules completed',
              '${LabCatalog.all.where((LabSpec l) => p.labPassed(l.id)).length} practical labs passed',
              '${p.portfolio.length} portfolio items · ${p.certifications.length} certificates',
              '${p.employment.length} job(s) held · ${p.employment.fold<int>(0, (int a, Employment e) => a + e.evaluated.length)} evaluated assignments',
            ]),
          ),
          if (d != null) ...<Widget>[
            SectionCard(
              title: 'Skills · ${d.title}',
              subtitle: 'Earned only by passing graded work.',
              child: Column(children: <Widget>[
                for (final SkillDef s in d.skills)
                  LabeledBar(label: s.label, value: ((p.skillPoints[s.id] ?? 0) / 8 * 100).round().clamp(0, 100), detail: CareerRules.levelLabel(CareerRules.levelOf(p, s.id))),
              ]),
            ),
            SectionCard(
              title: 'Career readiness: ${CareerRules.readiness(p, d).score}',
              child: Column(children: <Widget>[
                for (final ReadinessItem i in CareerRules.readiness(p, d).items) LabeledBar(label: i.label, value: i.score, detail: i.advice),
              ]),
            ),
          ],
          SectionCard(
            title: 'Missing skills',
            child: d == null
                ? const Text('Choose a department.')
                : BulletList(<String>[
                    for (final SkillDef s in d.skills)
                      if (CareerRules.levelOf(p, s.id) == 0) s.label,
                  ].isEmpty
                    ? <String>['None — every skill has been demonstrated at least once.']
                    : <String>[
                        for (final SkillDef s in d.skills)
                          if (CareerRules.levelOf(p, s.id) == 0) s.label,
                      ]),
          ),
        ],
      ),
    );
  }
}
