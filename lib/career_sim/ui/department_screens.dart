import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../ai/career_ai.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import '../store/career_sim_store.dart';
import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../labs/ui/lab_screens.dart';
import 'common.dart';
import 'job_screens.dart';
import 'task_views.dart';

/// Opens a department, entering it first so the dashboard follows.
Future<void> openDepartment(BuildContext context, String deptId) async {
  final CareerSimStore store = careerStore(context);
  if (store.profile.deptId != deptId) {
    final bool? ok = await runCareerAction<bool>(context, () async {
      await store.chooseDepartment(deptId);
      return true;
    });
    if (ok != true) return;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DepartmentScreen(deptId: deptId)));
}

class DepartmentPickerScreen extends StatelessWidget {
  const DepartmentPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final Department d in CareerCatalog.departments)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                key: ValueKey<String>('dept_${d.id}'),
                leading: Text(d.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${d.school}\n${d.summary}'),
                isThreeLine: true,
                trailing: store.profile.deptId == d.id ? const StatusChip('Current') : const Icon(Icons.chevron_right_rounded),
                onTap: () => openDepartment(context, d.id),
              ),
            ),
        ],
      ),
    );
  }
}

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key, required this.deptId});
  final String deptId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? d = CareerCatalog.department(deptId);
    if (d == null) return const Scaffold(body: Center(child: Text('Department not found')));
    final CareerProfile p = store.profile;
    return Scaffold(
      appBar: AppBar(title: Text('${d.emoji} ${d.title}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(d.school, style: TextStyle(color: VuV2Colors.mute)),
          const SizedBox(height: 4),
          Text(d.summary, style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
          const SizedBox(height: 16),
          for (final DeptUnit u in d.units)
            SectionCard(
              title: '${u.emoji} ${u.title}',
              subtitle: u.setting,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final TrainingModule m in u.modules) _ModuleTile(dept: d, module: m, profile: p),
                  for (final ProjectSpec pr in u.projects)
                    ListTile(
                      key: ValueKey<String>('project_${pr.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(store.projectPublished(pr.id) ? Icons.folder_special_rounded : Icons.work_outline_rounded,
                          color: store.projectPublished(pr.id) ? VuV2Colors.success : null),
                      title: Text('Project: ${pr.title}'),
                      subtitle: Text(store.projectPublished(pr.id) ? 'In your portfolio' : 'Practical project'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => ProjectScreen(deptId: d.id, projectId: pr.id))),
                    ),
                ],
              ),
            ),
          if (LabCatalog.forDept(d.id).isNotEmpty)
            SectionCard(
              title: 'Practical labs',
              subtitle: 'Professional environments with working tools, graded tasks and saved progress.',
              child: Column(children: <Widget>[
                for (final LabSpec l in LabCatalog.forDept(d.id))
                  ListTile(
                    key: ValueKey<String>('dept_lab_${l.id}'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(environmentIcon(l.environment)),
                    title: Text('Lab ${l.number}: ${l.title}'),
                    subtitle: Text(labStatus(p, l)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LabIntroScreen(labId: l.id))),
                  ),
              ]),
            ),
          if (d.certifications.isNotEmpty)
            SectionCard(
              title: 'Professional certifications',
              subtitle: 'Exams graded by the same rules as practice; required for some roles and promotions.',
              child: Column(
                children: <Widget>[
                  for (final Certification c in d.certifications)
                    ListTile(
                      key: ValueKey<String>('cert_${c.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(p.hasCertification(c.id) ? Icons.workspace_premium_rounded : Icons.school_outlined,
                          color: p.hasCertification(c.id) ? VuV2Colors.success : null),
                      title: Text(c.title),
                      subtitle: Text(p.hasCertification(c.id) ? 'Held' : c.issuer),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => CertificationScreen(deptId: d.id, certId: c.id))),
                    ),
                ],
              ),
            ),
          SectionCard(
            title: 'Career pathway',
            subtitle: 'Roles in this field. Employers screen on your training, skills and portfolio.',
            child: Column(
              children: <Widget>[
                for (final JobPosting j in CareerCatalog.postingsFor(d.id))
                  ListTile(
                    key: ValueKey<String>('dept_job_${j.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(j.title),
                    subtitle: Text('${j.company.name} · ${j.type.label}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobDetailScreen(postingId: j.id))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.dept, required this.module, required this.profile});
  final Department dept;
  final TrainingModule module;
  final CareerProfile profile;

  @override
  Widget build(BuildContext context) {
    final bool done = profile.completedModules.contains(module.id);
    final int passed = module.practice
        .where((TaskSpec t) => profile.taskResults[CareerSimStore.moduleTaskKey(module, t)]?.passed ?? false)
        .length;
    return ListTile(
      key: ValueKey<String>('module_${module.id}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(done ? Icons.check_circle_rounded : Icons.menu_book_rounded, color: done ? VuV2Colors.success : null),
      title: Text(module.title),
      subtitle: Text(done
          ? 'Completed'
          : '${profile.studiedLessons.contains(module.id) ? 'Lesson studied' : 'Lesson not studied'} · $passed/${module.practice.length} tasks passed'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => ModuleScreen(deptId: dept.id, moduleId: module.id))),
    );
  }
}

class ModuleScreen extends StatelessWidget {
  const ModuleScreen({super.key, required this.deptId, required this.moduleId});
  final String deptId;
  final String moduleId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? d = CareerCatalog.department(deptId);
    final TrainingModule? m = CareerCatalog.module(moduleId);
    if (d == null || m == null) return const Scaffold(body: Center(child: Text('Module not found')));
    final bool studied = store.profile.studiedLessons.contains(m.id);
    final bool done = store.profile.completedModules.contains(m.id);
    final String lecture = m.lesson.map((LessonSection s) => '${s.heading}: ${s.body}').join('\n');
    return Scaffold(
      appBar: AppBar(title: Text(m.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          if (done) const Padding(padding: EdgeInsets.only(bottom: 8), child: StatusChip('Module completed', color: VuV2Colors.success)),
          Text(m.summary, style: TextStyle(color: VuV2Colors.mute, height: 1.4)),
          const SizedBox(height: 4),
          Text('Skills: ${m.skills.map(d.skillLabel).join(', ')} · about ${m.minutes} min',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          const SizedBox(height: 12),
          SectionCard(
            title: '1 · Learn the concept',
            subtitle: 'Lecture notes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final LessonSection s in m.lesson) ...<Widget>[
                  Text(s.heading, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(s.body, style: TextStyle(color: VuV2Colors.ink, height: 1.45)),
                  if (s.example.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                      child: SelectableText(s.example,
                          style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFE2E8F0), fontSize: 12.5)),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
                if (studied)
                  const Row(children: <Widget>[
                    Icon(Icons.check_rounded, color: VuV2Colors.success),
                    SizedBox(width: 6),
                    Text('Lesson studied'),
                  ])
                else
                  BusyButton(
                    key: const ValueKey<String>('mark_studied'),
                    label: 'I have studied this lesson',
                    icon: Icons.done_rounded,
                    onPressed: () async {
                      await runCareerAction<void>(context, () => store.markLessonStudied(m), success: 'Lesson recorded.');
                    },
                  ),
                const SizedBox(height: 12),
                ExpansionTile(
                  key: const ValueKey<String>('ask_lecturer_module'),
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Ask the AI lecturer'),
                  children: <Widget>[AiAssistPanel(role: CareerAiRole.lecturer, contextText: 'Lecture: ${m.title}\n$lecture')],
                ),
              ],
            ),
          ),
          SectionCard(
            title: '2 · Practise',
            subtitle: 'Graded by published rules. Pass every task to complete the module.',
            child: Column(
              children: <Widget>[
                for (final TaskSpec t in m.practice)
                  _TaskTile(
                    tileKey: 'practice_${t.id}',
                    spec: t,
                    result: store.result(CareerSimStore.moduleTaskKey(m, t)),
                    open: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => TaskRunnerScreen(
                        spec: t,
                        contextLabel: m.title,
                        lecturerContext: 'Lecture: ${m.title}\n$lecture',
                        onGraded: (TaskResult r) async {
                          await runCareerAction<TaskResult>(
                              context, () => store.recordTask(CareerSimStore.moduleTaskKey(m, t), t, r, fallbackSkills: m.skills));
                        },
                      ),
                    )),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.tileKey, required this.spec, required this.result, required this.open});
  final String tileKey;
  final TaskSpec spec;
  final TaskResult? result;
  final VoidCallback open;

  @override
  Widget build(BuildContext context) {
    final TaskResult? r = result;
    return ListTile(
      key: ValueKey<String>(tileKey),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        r == null ? Icons.radio_button_unchecked : (r.passed ? Icons.check_circle_rounded : Icons.cancel_rounded),
        color: r == null ? null : (r.passed ? VuV2Colors.success : VuV2Colors.danger),
      ),
      title: Text(spec.title),
      subtitle: Text('${spec.kindLabel}${r == null ? '' : ' · best ${r.score}/100'}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: open,
    );
  }
}

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key, required this.deptId, required this.projectId});
  final String deptId;
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? d = CareerCatalog.department(deptId);
    final ProjectSpec? p = CareerCatalog.project(projectId);
    if (d == null || p == null) return const Scaffold(body: Center(child: Text('Project not found')));
    final List<String> blockers = store.projectBlockers(p);
    final bool published = store.projectPublished(p.id);
    final List<TaskSpec> parts = <TaskSpec>[...p.deliverables, p.writeUp];
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(p.brief, style: TextStyle(color: VuV2Colors.ink, height: 1.45)),
          const SizedBox(height: 8),
          Text('Skills: ${p.skills.map(d.skillLabel).join(', ')}', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          const SizedBox(height: 12),
          if (blockers.isNotEmpty)
            SectionCard(title: 'Before you start', child: BulletList(blockers, icon: Icons.lock_outline_rounded)),
          SectionCard(
            title: 'Deliverables',
            child: Column(
              children: <Widget>[
                for (final TaskSpec t in parts)
                  _TaskTile(
                    tileKey: 'deliverable_${t.id}',
                    spec: t,
                    result: store.result(CareerSimStore.projectTaskKey(p, t)),
                    open: () {
                      if (blockers.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(blockers.first)));
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) {
                          String? text;
                          return TaskRunnerScreen(
                            spec: t,
                            contextLabel: p.title,
                            onText: (String s) => text = s,
                            onGraded: (TaskResult r) async {
                              await runCareerAction<TaskResult>(context,
                                  () => store.recordTask(CareerSimStore.projectTaskKey(p, t), t, r, fallbackSkills: p.skills, text: text));
                            },
                          );
                        },
                      ));
                    },
                  ),
              ],
            ),
          ),
          if (published)
            const StatusChip('Published to your portfolio', color: VuV2Colors.success)
          else
            BusyButton(
              key: const ValueKey<String>('publish_project'),
              label: 'Publish to portfolio',
              icon: Icons.folder_special_rounded,
              onPressed: () async {
                await runCareerAction<PortfolioItem>(context, () => store.publishProject(d, p), success: 'Added to your portfolio.');
              },
            ),
        ],
      ),
    );
  }
}

class CertificationScreen extends StatelessWidget {
  const CertificationScreen({super.key, required this.deptId, required this.certId});
  final String deptId;
  final String certId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? d = CareerCatalog.department(deptId);
    final Certification? c = CareerCatalog.certification(certId);
    if (d == null || c == null) return const Scaffold(body: Center(child: Text('Certification not found')));
    final List<String> blockers = store.certificationBlockers(c);
    final bool held = store.profile.hasCertification(c.id);
    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('Issued by ${c.issuer}. Pass every exam task and average at least ${c.passMark}.',
              style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
          const SizedBox(height: 12),
          if (blockers.isNotEmpty) SectionCard(title: 'Eligibility', child: BulletList(blockers, icon: Icons.lock_outline_rounded)),
          SectionCard(
            title: 'Exam',
            child: Column(
              children: <Widget>[
                for (final TaskSpec t in c.tasks)
                  _TaskTile(
                    tileKey: 'exam_${t.id}',
                    spec: t,
                    result: store.result(CareerSimStore.certTaskKey(c, t)),
                    open: () {
                      if (blockers.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(blockers.first)));
                        return;
                      }
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => TaskRunnerScreen(
                          spec: t,
                          contextLabel: c.title,
                          onGraded: (TaskResult r) async {
                            await runCareerAction<TaskResult>(context, () => store.recordTask(CareerSimStore.certTaskKey(c, t), t, r));
                          },
                        ),
                      ));
                    },
                  ),
              ],
            ),
          ),
          if (held)
            const StatusChip('Certification held', color: VuV2Colors.success)
          else
            BusyButton(
              key: const ValueKey<String>('claim_cert'),
              label: 'Request certification',
              icon: Icons.workspace_premium_rounded,
              onPressed: () async {
                await runCareerAction<CertificationRecord>(context, () => store.claimCertification(d, c), success: 'Certification awarded.');
              },
            ),
          const SizedBox(height: 8),
          Text('Skill levels: ${d.skills.map((SkillDef s) => '${s.label} ${CareerRules.levelLabel(CareerRules.levelOf(store.profile, s.id))}').join(' · ')}',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        ],
      ),
    );
  }
}
