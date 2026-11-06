import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'department_screens.dart';
import 'employment_screens.dart';
import 'interview_screen.dart';
import 'job_screens.dart';
import 'task_views.dart';

class CareerCentreScreen extends StatelessWidget {
  const CareerCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? d = store.department;
    final CareerProfile p = store.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Career Centre')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          const CareerStatusCard(),
          const CareerSections(),
          const SizedBox(height: 12),
          if (d == null)
            SectionCard(
              title: 'Choose your department',
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DepartmentPickerScreen())),
                child: const Text('Choose department'),
              ),
            )
          else ...<Widget>[
            _ReadinessCard(dept: d),
            if (p.stage == CareerStage.student) _TraineeCard(dept: d),
          ],
          SectionCard(
            title: 'Application materials',
            child: Column(children: <Widget>[
              ListTile(
                key: const ValueKey<String>('materials_resume'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.badge_rounded),
                title: const Text('Resume'),
                subtitle: Text('${(CareerRules.resumeCompleteness(p.resume) * 100).round()}% complete'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ResumeScreen())),
              ),
              ListTile(
                key: const ValueKey<String>('open_cover_letter'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline_rounded),
                title: const Text('Cover letter (general)'),
                subtitle: Text(store.coverLetterFor('') == null ? 'Not written' : 'Saved · ${wordCount(store.coverLetterFor('')!.body)} words'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CoverLetterScreen())),
              ),
            ]),
          ),
          SectionCard(
            title: 'Portfolio',
            subtitle: 'Projects you built and passed. Employers see these when you attach them.',
            child: p.portfolio.isEmpty
                ? Text('No projects yet — complete a department project.', style: TextStyle(color: VuV2Colors.mute))
                : Column(children: <Widget>[
                    for (final PortfolioItem i in p.portfolio)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.folder_special_rounded, color: VuV2Colors.success),
                        title: Text(i.title),
                        subtitle: Text('${CareerCatalog.department(i.deptId)?.title ?? i.deptId} · score ${i.score} · day ${i.day}'),
                      ),
                  ]),
          ),
          if (d != null)
            SectionCard(
              title: 'Interview preparation',
              subtitle: 'A full mock interview with the ${d.title} interview panel. Scored by the same rubric; does not affect applications.',
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const ValueKey<String>('mock_interview'),
                  onPressed: () {
                    final JobPosting? j = CareerCatalog.postingsFor(d.id).isEmpty ? null : CareerCatalog.postingsFor(d.id).first;
                    final InterviewPlan? plan = j == null ? null : CareerCatalog.interviewPlan(j.interviewPlanId);
                    if (j == null || plan == null) return;
                    Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => InterviewScreen(
                        plan: plan,
                        company: j.company,
                        applicationId: 'mock',
                        day: store.day,
                        practice: true,
                        onFinished: (InterviewRecord r) => store.recordPracticeInterview(r),
                      ),
                    ));
                  },
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: Text(p.practiceInterviews.isEmpty ? 'Start mock interview' : 'Mock interview again (best ${p.practiceInterviews.map((InterviewRecord r) => r.overall).reduce((int a, int b) => a > b ? a : b)})'),
                ),
              ),
            ),
          SectionCard(
            title: 'Opportunities and applications',
            child: Column(children: <Widget>[
              ListTile(
                key: const ValueKey<String>('materials_jobs'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.work_rounded),
                title: const Text('Internships, graduate and entry-level roles'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JobBoardScreen())),
              ),
              ListTile(
                key: const ValueKey<String>('materials_tracker'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.track_changes_rounded),
                title: const Text('Application tracker'),
                subtitle: Text('${p.applications.where((JobApplication a) => a.status.isActive).length} active'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ApplicationsTrackerScreen())),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.dept});
  final Department dept;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final ReadinessReport r = CareerRules.readiness(store.profile, dept);
    return SectionCard(
      title: 'Career readiness: ${r.score} · ${r.band}',
      subtitle: 'For ${dept.title}. Computed from graded work only.',
      trailing: const ValidatedBadge(label: 'Rule-based'),
      child: Column(children: <Widget>[for (final ReadinessItem i in r.items) LabeledBar(label: '${i.label} (${i.weight}%)', value: i.score, detail: i.advice)]),
    );
  }
}

class _TraineeCard extends StatelessWidget {
  const _TraineeCard({required this.dept});
  final Department dept;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<Criterion> c = CareerRules.traineeCriteria(store.profile, dept);
    return SectionCard(
      title: 'Trainee status',
      subtitle: 'Internships require Trainee status. It is granted when the criteria are met — not automatically.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final Criterion x in c)
            Row(children: <Widget>[
              Icon(x.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18, color: x.met ? VuV2Colors.success : VuV2Colors.mute),
              const SizedBox(width: 6),
              Expanded(child: Text('${x.label}${x.detail.isEmpty ? '' : ' (${x.detail})'}')),
            ]),
          const SizedBox(height: 8),
          BusyButton(
            key: const ValueKey<String>('request_trainee'),
            label: 'Request trainee status',
            icon: Icons.verified_user_rounded,
            onPressed: () async {
              final List<Criterion>? r = await runCareerAction<List<Criterion>>(context, store.requestTraineeStatus);
              if (r == null || !context.mounted) return;
              final bool ok = r.every((Criterion x) => x.met);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Trainee status granted.' : 'Not yet: ${r.where((Criterion x) => !x.met).map((Criterion x) => x.label).join('; ')}'),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _headline = TextEditingController();
  final TextEditingController _summary = TextEditingController();
  final TextEditingController _eduTitle = TextEditingController();
  final TextEditingController _eduDetail = TextEditingController();
  final TextEditingController _skill = TextEditingController();
  List<ResumeEntry> _education = <ResumeEntry>[];
  List<String> _skills = <String>[];
  Set<String> _projects = <String>{};
  bool _init = false;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[_name, _email, _headline, _summary, _eduTitle, _eduDetail, _skill]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Real experience from the student's own (uploaded) resume is kept, and
  /// experience verified by GradeGlow employment is added after it.
  Resume _draft(CareerSimStore store) {
    final Resume cur = store.profile.resume;
    final List<ResumeEntry> verified = store.verifiedExperience();
    return Resume(
      fullName: _name.text,
      email: _email.text,
      headline: _headline.text,
      summary: _summary.text,
      education: _education,
      experience: <ResumeEntry>[
        ...cur.experience.where((ResumeEntry e) => !verified.any((ResumeEntry v) => v.heading == e.heading) && !e.heading.contains(' · ')),
        ...verified,
      ],
      skills: _skills,
      projectIds: _projects.toList(),
      phone: cur.phone,
      projects: cur.projects,
      certifications: cur.certifications,
      achievements: cur.achievements,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    if (!_init) {
      _init = true;
      final Resume r = p.resume;
      _name.text = r.fullName;
      _email.text = r.email;
      _headline.text = r.headline;
      _summary.text = r.summary;
      _education = List<ResumeEntry>.from(r.education);
      _skills = List<String>.from(r.skills);
      _projects = r.projectIds.toSet();
    }
    final Department? d = store.department;
    final List<String> verifiedSkills = <String>[
      if (d != null)
        for (final SkillDef s in d.skills)
          if (CareerRules.levelOf(p, s.id) > 0) '${s.label} (${CareerRules.levelLabel(CareerRules.levelOf(p, s.id))})',
    ];
    final List<Criterion> check = CareerRules.resumeChecklist(_draft(store));
    return Scaffold(
      appBar: AppBar(title: const Text('Resume')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Checklist',
            child: Column(children: <Widget>[
              for (final Criterion c in check)
                Row(children: <Widget>[
                  Icon(c.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18, color: c.met ? VuV2Colors.success : VuV2Colors.mute),
                  const SizedBox(width: 6),
                  Expanded(child: Text(c.label)),
                ]),
            ]),
          ),
          TextField(key: const ValueKey<String>('cv_name'), controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(key: const ValueKey<String>('cv_email'), controller: _email, onChanged: (_) => setState(() {}), keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(key: const ValueKey<String>('cv_headline'), controller: _headline, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Headline (e.g. Computer Science student — backend & algorithms)', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(key: const ValueKey<String>('cv_summary'), controller: _summary, onChanged: (_) => setState(() {}), minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Professional summary (30+ words)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Text('Education', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
          for (int i = 0; i < _education.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_education[i].heading),
              subtitle: Text(_education[i].detail),
              trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => setState(() => _education.removeAt(i))),
            ),
          TextField(key: const ValueKey<String>('cv_edu_title'), controller: _eduTitle, decoration: const InputDecoration(labelText: 'Programme (e.g. BSc Computer Science)', border: OutlineInputBorder())),
          const SizedBox(height: 6),
          TextField(key: const ValueKey<String>('cv_edu_detail'), controller: _eduDetail, decoration: const InputDecoration(labelText: 'Institution and dates', border: OutlineInputBorder())),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey<String>('cv_add_edu'),
              onPressed: () {
                if (_eduTitle.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the programme name.')));
                  return;
                }
                setState(() {
                  _education.add(ResumeEntry(heading: _eduTitle.text.trim(), detail: _eduDetail.text.trim()));
                  _eduTitle.clear();
                  _eduDetail.clear();
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add education'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Skills', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
          if (verifiedSkills.isNotEmpty) ...<Widget>[
            Text('Verified by graded work — tap to add:', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
            Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
              for (final String s in verifiedSkills)
                ActionChip(
                  avatar: const Icon(Icons.verified_rounded, size: 16),
                  label: Text(s),
                  onPressed: _skills.contains(s) ? null : () => setState(() => _skills.add(s)),
                ),
            ]),
          ],
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            for (final String s in _skills) InputChip(label: Text(s), onDeleted: () => setState(() => _skills.remove(s))),
          ]),
          Row(children: <Widget>[
            Expanded(child: TextField(key: const ValueKey<String>('cv_skill'), controller: _skill, decoration: const InputDecoration(labelText: 'Add a skill', isDense: true))),
            IconButton(
              key: const ValueKey<String>('cv_add_skill'),
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: () {
                final String s = _skill.text.trim();
                if (s.isEmpty || _skills.contains(s)) return;
                setState(() {
                  _skills.add(s);
                  _skill.clear();
                });
              },
            ),
          ]),
          const SizedBox(height: 12),
          Text('Projects', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
          if (p.portfolio.isEmpty) Text('Publish a project to list it here.', style: TextStyle(color: VuV2Colors.mute)),
          for (final PortfolioItem i in p.portfolio)
            CheckboxListTile(
              key: ValueKey<String>('cv_project_${i.id}'),
              contentPadding: EdgeInsets.zero,
              value: _projects.contains(i.id),
              title: Text(i.title),
              subtitle: Text('Score ${i.score}'),
              onChanged: (bool? v) => setState(() => v == true ? _projects.add(i.id) : _projects.remove(i.id)),
            ),
          const SizedBox(height: 12),
          Text('Experience (verified from your employment record)', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
          if (store.verifiedExperience().isEmpty) Text('None yet.', style: TextStyle(color: VuV2Colors.mute)),
          for (final ResumeEntry e in store.verifiedExperience())
            ListTile(contentPadding: EdgeInsets.zero, title: Text(e.heading), subtitle: Text(e.detail)),
          const SizedBox(height: 16),
          BusyButton(
            key: const ValueKey<String>('cv_save'),
            label: 'Save resume',
            icon: Icons.save_rounded,
            onPressed: () async {
              await runCareerAction<void>(context, () => store.saveResume(_draft(store)), success: 'Resume saved.');
            },
          ),
        ],
      ),
    );
  }
}

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key, this.postingId = ''});
  final String postingId;

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final TextEditingController _t = TextEditingController();
  bool _init = false;

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    if (!_init) {
      _init = true;
      _t.text = store.coverLetterFor(widget.postingId)?.body ?? '';
    }
    final JobPosting? j = widget.postingId.isEmpty ? null : CareerCatalog.posting(widget.postingId);
    return Scaffold(
      appBar: AppBar(title: Text(j == null ? 'Cover letter' : 'Cover letter · ${j.company.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(
            j == null
                ? 'A general letter is copied into new applications; tailor it to each employer before submitting.'
                : 'Tailored to ${j.title}.',
            style: TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 10),
          WrittenField(
            fieldKey: const ValueKey<String>('cl_text'),
            controller: _t,
            rubric: CareerRules.coverLetterRubric(j),
            minWords: 120,
            label: 'Dear hiring manager…',
          ),
          const SizedBox(height: 12),
          BusyButton(
            key: const ValueKey<String>('cl_save'),
            label: 'Save cover letter',
            icon: Icons.save_rounded,
            onPressed: () async {
              await runCareerAction<CoverLetter>(context, () => store.saveCoverLetter(postingId: widget.postingId, body: _t.text),
                  success: 'Cover letter saved.');
            },
          ),
        ],
      ),
    );
  }
}
