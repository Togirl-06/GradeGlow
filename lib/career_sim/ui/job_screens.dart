import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/pay_rules.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import '../resume/resume_analysis.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'employment_screens.dart';
import 'resume_screens.dart';
import 'interview_screen.dart';
import 'task_views.dart';
import 'workplace_screen.dart';
import 'gg_kit.dart';

class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Opportunities')), body: const JobBoardBody());
}

/// Job opportunities: filters on the left, job cards in the middle, the
/// student's status and earnings on the right (stacked on phones).
class JobBoardBody extends StatefulWidget {
  const JobBoardBody({super.key});

  @override
  State<JobBoardBody> createState() => _JobBoardBodyState();
}

class _JobBoardBodyState extends State<JobBoardBody> {
  bool _mine = true;
  String _level = '';
  String _mode = '';
  final TextEditingController _q = TextEditingController();

  static const List<String> levels = <String>['Internship', 'Entry-level', 'Junior', 'Mid-level', 'Senior', 'Management'];

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Widget _filters() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        const Text('Filter Jobs', style: TextStyle(color: GG.ink, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey<String>('level_filter'),
          initialValue: _level,
          dropdownColor: GG.panel2,
          decoration: const InputDecoration(isDense: true),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(value: '', child: Text('All Levels')),
            for (final String l in levels) DropdownMenuItem<String>(value: l, child: Text(l)),
          ],
          onChanged: (String? v) => setState(() => _level = v ?? ''),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: const ValueKey<String>('mode_filter'),
          initialValue: _mode,
          dropdownColor: GG.panel2,
          decoration: const InputDecoration(isDense: true),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: '', child: Text('All Locations')),
            DropdownMenuItem<String>(value: 'Remote', child: Text('Remote')),
            DropdownMenuItem<String>(value: 'Hybrid', child: Text('Hybrid')),
            DropdownMenuItem<String>(value: 'On-site', child: Text('On-site')),
          ],
          onChanged: (String? v) => setState(() => _mode = v ?? ''),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: <Widget>[
          ChoiceChip(key: const ValueKey<String>('filter_mine'), label: const Text('My field'), selected: _mine, onSelected: (_) => setState(() => _mine = true)),
          ChoiceChip(key: const ValueKey<String>('filter_all'), label: const Text('All fields'), selected: !_mine, onSelected: (_) => setState(() => _mine = false)),
        ]),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey<String>('jobs_search'),
          controller: _q,
          onSubmitted: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Title, company or skill', isDense: true),
        ),
        const SizedBox(height: 10),
        GGButton(key: const ValueKey<String>('jobs_search_go'), label: 'Search', onPressed: () => setState(() {})),
      ]);

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final String dept = store.profile.deptId;
    final List<String> words = _q.text.toLowerCase().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).toList();
    final List<JobPosting> list = (_mine && dept.isNotEmpty ? CareerCatalog.postingsFor(dept) : CareerCatalog.postings).where((JobPosting j) {
      if (_level.isNotEmpty && j.levelLabel != _level && !(j.type == JobType.graduate && _level == 'Entry-level')) return false;
      if (_mode.isNotEmpty && !j.location.contains(_mode) && j.workMode != _mode) return false;
      final String text = '${j.title} ${j.company.name} ${j.department} ${j.keywords.join(' ')} ${j.location}'.toLowerCase();
      return words.every(text.contains);
    }).toList();
    final List<Widget> cards = <Widget>[
      for (final JobPosting j in list) _PostingCard(job: j),
      if (list.isEmpty) const Text('No jobs match these filters.', style: TextStyle(color: GG.mute)),
      const SizedBox(height: 8),
      const Text(PayRules.notice, style: TextStyle(color: GG.mute, fontSize: 11.5)),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GG.page),
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth < 900) {
          return ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 32), children: <Widget>[
            const _StatusStrip(),
            const SizedBox(height: 10),
            GGPanel(child: _filters()),
            const SizedBox(height: 12),
            ...cards,
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(width: 260, child: Padding(padding: const EdgeInsets.all(16), child: GGPanel(child: _filters()))),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(4, 16, 4, 32), children: cards)),
          const SizedBox(width: 300, child: Padding(padding: EdgeInsets.all(16), child: _StatusColumn())),
        ]);
      }),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  const _StatusColumn();

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final int complete = (CareerRules.resumeCompleteness(store.profile.resume) * 100).round();
    final (String status, String next) = employmentStatus(store);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      GGPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('Your Status', style: TextStyle(color: GG.ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: GG.panel2, borderRadius: BorderRadius.circular(12)),
            child: Row(children: <Widget>[
              Icon(complete >= 70 ? Icons.check_circle_outline_rounded : Icons.pending_outlined, color: complete >= 70 ? GG.green : GG.amber, size: 34),
              const SizedBox(width: 10),
              Expanded(child: Text('Profile ${complete >= 70 ? 'Complete' : 'In progress'}\n($complete%)', style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 10),
          Text(status, style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
          const Text('Next Step:', style: TextStyle(color: GG.mute)),
          Text(next, style: const TextStyle(color: GG.ink)),
        ]),
      ),
      const SizedBox(height: 12),
      GGPanel(
        child: Row(children: <Widget>[
          const Icon(Icons.account_balance_wallet_rounded, color: GG.blue, size: 40),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const Text('Your Earnings', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
            Text(usd(store.profile.balanceCents), style: const TextStyle(color: GG.ink, fontSize: 24, fontWeight: FontWeight.w900)),
          ]),
        ]),
      ),
    ]);
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip();

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final (String status, String next) = employmentStatus(store);
    return GGPanel(
      child: Row(children: <Widget>[
        const Icon(Icons.verified_user_outlined, color: GG.green),
        const SizedBox(width: 8),
        Expanded(child: Text('$status · Next: $next', style: const TextStyle(color: GG.ink))),
        Text(usd(store.profile.balanceCents), style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _PostingCard extends StatelessWidget {
  const _PostingCard({required this.job});
  final JobPosting job;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final int day = store.day;
    final bool open = PostingSchedule.isOpen(job, day);
    final ResumeUpload? cv = store.profile.resumeUpload(store.profile.defaultResumeId);
    final int? match = cv == null ? null : jobMatch(cv.parsed, job, fullText: cv.text).score;
    final JobApplication? app = store.activeApplicationFor(job.id);
    final String pay = job.salaryPeriod == 'year' ? '${usdWhole(job.salaryMin)} / year' : '\$${job.salaryMin} / ${job.salaryPeriod}';
    final String type = job.salaryPeriod == 'hour' ? 'Hourly' : (job.type == JobType.internship ? 'Internship' : 'Full-time');
    final String mode = job.location.split('·').last.trim();
    Future<void> openDetail() => Navigator.of(context).push(ggRoute<void>((_) => JobDetailScreen(postingId: job.id)));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: GG.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: GG.stroke)),
        child: InkWell(
          key: ValueKey<String>('posting_${job.id}'),
          borderRadius: BorderRadius.circular(14),
          onTap: openDetail,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: <Widget>[
              GGLogo(name: job.company.name, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(job.title, style: const TextStyle(color: GG.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('$pay • $type • $mode', style: const TextStyle(color: Color(0xFFA996FF), fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(job.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GG.mute, fontSize: 12.5)),
                  const SizedBox(height: 2),
                  Text('${job.company.name} · ${job.levelLabel} · ${open ? 'Closes day ${PostingSchedule.deadline(job, day)}' : 'Reopens day ${PostingSchedule.reopens(job, day)}'}${match == null ? '' : ' · resume match $match%'}',
                      style: const TextStyle(color: GG.mute, fontSize: 11.5)),
                ]),
              ),
              const SizedBox(width: 10),
              if (app != null)
                StatusChip(app.status.label, color: statusColor(app.status))
              else
                GGButton(
                  key: ValueKey<String>('apply_${job.id}'),
                  label: 'Apply',
                  dense: true,
                  onPressed: !open
                      ? null
                      : () async {
                          final JobApplication? a = await runCareerAction<JobApplication>(context, () => store.startApplication(job.id));
                          if (a != null && context.mounted) await Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: a.id)));
                        },
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.postingId});
  final String postingId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final JobPosting? j = CareerCatalog.posting(postingId);
    final Department? d = j == null ? null : CareerCatalog.department(j.deptId);
    if (j == null || d == null) return const Scaffold(body: Center(child: Text('Posting not found')));
    final CareerProfile p = store.profile;
    final ReadinessReport rr = CareerRules.readiness(p, d, job: j);
    final JobApplication? app = store.activeApplicationFor(j.id);
    final bool open = PostingSchedule.isOpen(j, store.day);
    final JobRequirements req = j.requirements;
    return Scaffold(
      appBar: AppBar(title: Text(j.company.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(j.title, style: TextStyle(color: GG.ink, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${j.company.name} · ${j.company.industry} · ${j.location}', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            StatusChip(j.type.label),
            StatusChip('${money(j.salaryMin, j.salaryPeriod)}${j.salaryMax > j.salaryMin ? ' – ${money(j.salaryMax, j.salaryPeriod)}' : ''}'),
            StatusChip(open ? 'Deadline: day ${PostingSchedule.deadline(j, store.day)}' : 'Closed · reopens day ${PostingSchedule.reopens(j, store.day)}',
                color: open ? null : GG.red),
          ]),
          const SizedBox(height: 12),
          if (j.simulationNote.isNotEmpty)
            Container(
              key: const ValueKey<String>('simulation_note'),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(j.simulationNote, style: TextStyle(color: GG.ink, fontSize: 12.5)),
            ),
          SectionCard(
            title: 'Job details',
            child: Column(children: <Widget>[
              _Row('Company', '${j.company.name} (simulated employer)'),
              if (j.department.isNotEmpty) _Row('Department', j.department),
              _Row('Employment type', j.salaryPeriod == 'hour' ? 'Hourly, ${j.hoursPerWeek} h/week' : 'Full-time'),
              _Row('Experience level', j.levelLabel),
              _Row('Working hours', '${j.hoursPerWeek} hours per week'),
              _Row('Location', j.location),
              _Row('Salary (virtual USD)', '${money(j.salaryMin, j.salaryPeriod)}${j.salaryMax > j.salaryMin ? ' – ${money(j.salaryMax, j.salaryPeriod)}' : ''}'),
              if (j.salaryPeriod != 'year') _Row('Annual equivalent', usdWhole(PayRules.annual(j.salaryMin, j.salaryPeriod, hoursPerWeek: j.hoursPerWeek))),
              _Row('Paid', PayRules.frequencyLabel(j.payFrequency)),
              _Row('Application deadline', 'Day ${PostingSchedule.deadline(j, store.day)}'),
              _Row('Positions available', '${j.positions}'),
              if (j.requiredEducation.isNotEmpty) _Row('Required education', j.requiredEducation),
            ]),
          ),
          SectionCard(title: 'About the role', child: Text(j.description, style: TextStyle(color: GG.ink, height: 1.4))),
          SectionCard(title: 'Responsibilities', child: BulletList(j.responsibilities)),
          if (j.keywords.isNotEmpty) SectionCard(title: 'Required skills', child: Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String k in j.keywords) StatusChip(k)])),
          if (j.preferredKeywords.isNotEmpty || j.preferred.isNotEmpty)
            SectionCard(title: 'Preferred qualifications', child: BulletList(<String>[...j.preferredKeywords, ...j.preferred])),
          SectionCard(title: 'Qualifications', child: BulletList(j.qualifications)),
          ResumeMatchCard(job: j),
          if (j.benefits.isNotEmpty) SectionCard(title: 'Benefits (simulated)', child: BulletList(j.benefits)),
          SectionCard(
            title: 'Requirements',
            subtitle: 'Experience: ${j.experience}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final String m in req.modules)
                  _Check('Training: ${CareerCatalog.module(m)?.title ?? m}', p.completedModules.contains(m)),
                for (final MapEntry<String, int> s in req.skills.entries)
                  _Check('${d.skillLabel(s.key)}: ${CareerRules.levelLabel(s.value)} (you: ${CareerRules.levelLabel(CareerRules.levelOf(p, s.key))})',
                      CareerRules.levelOf(p, s.key) >= s.value),
                if (req.projects > 0) _Check('${req.projects} portfolio project(s) in this field', CareerRules.deptProjects(p, d.id) >= req.projects),
                _Check('Status: ${req.minStage.label} or above', p.stage.atLeast(req.minStage)),
                for (final String c in req.certifications) _Check('Certification: ${CareerCatalog.certification(c)?.title ?? c}', p.hasCertification(c)),
                if (req.completedInternship) _Check('Completed internship in this field', CareerRules.completedInternship(p, d.id)),
              ],
            ),
          ),
          SectionCard(
            title: 'Your readiness for this role: ${rr.score} (${rr.band})',
            trailing: const ValidatedBadge(label: 'Rule-based'),
            child: Column(children: <Widget>[for (final ReadinessItem i in rr.items) LabeledBar(label: i.label, value: i.score, detail: i.advice)]),
          ),
          SectionCard(title: 'About ${j.company.name}', child: Text(j.company.about, style: TextStyle(color: GG.ink, height: 1.4))),
          if (app != null)
            FilledButton.icon(
              key: const ValueKey<String>('open_application'),
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: app.id))),
              icon: const Icon(Icons.description_rounded),
              label: Text('Open application (${app.status.label})'),
            )
          else
            BusyButton(
              key: const ValueKey<String>('start_application'),
              label: 'Start application',
              icon: Icons.edit_document,
              onPressed: open
                  ? () async {
                      final JobApplication? a = await runCareerAction<JobApplication>(context, () => store.startApplication(j.id));
                      if (a != null && context.mounted) {
                        await Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: a.id)));
                      }
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(width: 150, child: Text(label, style: TextStyle(color: GG.mute, fontSize: 13))),
          Expanded(child: Text(value, style: TextStyle(color: GG.ink, fontSize: 13.5, fontWeight: FontWeight.w600))),
        ]),
      );
}

class _Check extends StatelessWidget {
  const _Check(this.text, this.met);
  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18, color: met ? GG.green : GG.mute),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: TextStyle(color: GG.ink, fontSize: 13.5))),
          ],
        ),
      );
}

class ApplicationsTrackerScreen extends StatelessWidget {
  const ApplicationsTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<JobApplication> apps = store.profile.applications.reversed.toList();
    final List<JobApplication> interviews = apps
        .where((JobApplication a) => a.status == ApplicationStatus.interviewScheduled && a.interviewDay != null)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text('Today is day ${store.day}', style: TextStyle(color: GG.mute))),
            const NextDayButton(),
          ]),
          const SizedBox(height: 8),
          if (interviews.isNotEmpty)
            SectionCard(
              title: 'Interview schedule',
              child: Column(children: <Widget>[
                for (final JobApplication a in interviews)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_rounded),
                    title: Text(CareerCatalog.posting(a.postingId)?.company.name ?? a.postingId),
                    subtitle: Text('Day ${a.interviewDay}${store.interviewAvailable(a) ? ' — today' : ''}'),
                  ),
              ]),
            ),
          if (apps.isEmpty) Text('No applications yet.', style: TextStyle(color: GG.mute)),
          for (final JobApplication a in apps)
            Card(
              child: ListTile(
                key: ValueKey<String>('app_${a.postingId}'),
                title: Text(CareerCatalog.posting(a.postingId)?.title ?? a.postingId),
                subtitle: Text('${CareerCatalog.posting(a.postingId)?.company.name ?? ''} · started day ${a.createdDay}'),
                trailing: StatusChip(a.status.label, color: statusColor(a.status)),
                onTap: () => Navigator.of(context).push(ggRoute<void>((_) => ApplicationScreen(applicationId: a.id))),
              ),
            ),
        ],
      ),
    );
  }
}

/// Moves the simulated calendar forward and reports what employers did.
class NextDayButton extends StatelessWidget {
  const NextDayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    return BusyButton(
      key: const ValueKey<String>('next_day'),
      label: 'Next working day',
      icon: Icons.today_rounded,
      tonal: true,
      onPressed: () async {
        final List<String>? news = await runCareerAction<List<String>>(context, store.advanceDay);
        if (news == null || !context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(news.isEmpty ? 'Day ${store.day}: no new updates.' : 'Day ${store.day}: ${news.join(' ')}'),
        ));
      },
    );
  }
}

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key, required this.applicationId});
  final String applicationId;

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final TextEditingController _letter = TextEditingController();
  final Map<String, TextEditingController> _answers = <String, TextEditingController>{};
  final TextEditingController _negotiation = TextEditingController();
  Set<String> _portfolio = <String>{};
  String _resumeId = '';
  bool _init = false;

  @override
  void dispose() {
    _letter.dispose();
    _negotiation.dispose();
    for (final TextEditingController c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _answerMap => <String, String>{for (final MapEntry<String, TextEditingController> e in _answers.entries) e.key: e.value.text};

  Future<void> _save(CareerSimStore store, JobApplication a) =>
      store.saveDraft(a.id, coverLetter: _letter.text, portfolioIds: _portfolio.toList(), resumeId: _resumeId, answers: _answerMap);

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final JobApplication? a = store.profile.application(widget.applicationId);
    final JobPosting? j = a == null ? null : CareerCatalog.posting(a.postingId);
    if (a == null || j == null) return const Scaffold(body: Center(child: Text('Application not found')));
    if (!_init) {
      _init = true;
      _letter.text = a.coverLetter;
      _portfolio = a.portfolioIds.toSet();
      _resumeId = a.resumeId;
      for (final ApplicationQuestion q in j.questions) {
        _answers[q.id] = TextEditingController(text: a.answers[q.id] ?? '');
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(j.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text(j.company.name, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800, fontSize: 18))),
            StatusChip(a.status.label, color: statusColor(a.status)),
          ]),
          const SizedBox(height: 4),
          Text('Day ${store.day}', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 12),
          ..._stage(context, store, a, j),
          if (a.screening != null) _ScreeningCard(report: a.screening!),
          if (a.interview != null) InterviewReportCard(record: a.interview!),
          if (a.assessment != null) SectionCard(title: 'Further assessment', child: ResultPanel(result: a.assessment!)),
          if (a.decision != null) _DecisionCard(decision: a.decision!),
          SectionCard(
            title: 'Timeline',
            child: Column(children: <Widget>[
              for (final StatusChange c in a.history.reversed)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, size: 10, color: statusColor(c.status)),
                  title: Text(c.status.label),
                  subtitle: Text('Day ${c.day}${c.note.isEmpty ? '' : ' · ${c.note}'}'),
                ),
            ]),
          ),
          if (a.status.isActive && a.status != ApplicationStatus.offerReceived)
            TextButton.icon(
              key: const ValueKey<String>('withdraw'),
              onPressed: () => runCareerAction<void>(context, () => store.withdraw(a.id), success: 'Application withdrawn.'),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Withdraw application'),
            ),
        ],
      ),
    );
  }

  List<Widget> _stage(BuildContext context, CareerSimStore store, JobApplication a, JobPosting j) {
    switch (a.status) {
      case ApplicationStatus.draft:
        final List<PortfolioItem> items = store.profile.portfolio;
        final double resume = CareerRules.resumeCompleteness(store.profile.resume);
        final ResumeUpload? chosen = store.profile.resumeUpload(_resumeId);
        final JobMatch match = chosen != null ? jobMatch(chosen.parsed, j, fullText: chosen.text) : jobMatch(parsedFromResume(store.profile.resume), j);
        return <Widget>[
          SectionCard(
            title: '1. Resume',
            subtitle: 'Choose the resume to send. Employers compare it with the job requirements.',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              for (final ResumeUpload u in store.profile.resumeUploads)
                RadioListTile<String>(
                  key: ValueKey<String>('pick_resume_${u.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: u.id,
                  groupValue: _resumeId,
                  onChanged: (String? v) => setState(() => _resumeId = v ?? ''),
                  title: Text(u.fileName),
                  subtitle: Text('Uploaded day ${u.uploadedDay}${u.reviewed ? ' · checked' : ' · not yet checked'}'),
                ),
              RadioListTile<String>(
                key: const ValueKey<String>('pick_resume_profile'),
                contentPadding: EdgeInsets.zero,
                value: '',
                groupValue: _resumeId,
                onChanged: (String? v) => setState(() => _resumeId = ''),
                title: const Text('My GradeGlow profile resume'),
                subtitle: Text('${(resume * 100).round()}% complete'),
              ),
              TextButton.icon(
                key: const ValueKey<String>('app_upload_resume'),
                onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const ResumeHubScreen())),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload or manage resumes'),
              ),
              LabeledBar(label: 'Match with this job', value: match.score, detail: match.missing.isEmpty ? 'All listed skills found.' : 'Missing: ${match.missing.take(5).join(', ')}'),
            ]),
          ),
          if (resume < 0.7 && chosen == null)
            SectionCard(
              title: 'Resume ${(resume * 100).round()}% complete',
              subtitle: 'Employers reject incomplete resumes at screening. Finish it in the Career Centre.',
              child: BulletList(CareerRules.resumeChecklist(store.profile.resume)
                  .where((Criterion c) => !c.met)
                  .map((Criterion c) => c.label)
                  .toList()),
            ),
          SectionCard(
            title: '2. Cover letter',
            subtitle: 'At least 80 words to submit; 120+ to meet the screening rubric.',
            child: WrittenField(
              fieldKey: const ValueKey<String>('cover_letter_field'),
              controller: _letter,
              rubric: CareerRules.coverLetterRubric(j),
              minWords: 80,
              label: 'Dear hiring manager…',
            ),
          ),
          if (j.questions.isNotEmpty)
            SectionCard(
              title: '3. Employer questions',
              subtitle: 'Answer in your own words (at least 20 words each; specific examples score higher).',
              child: Column(children: <Widget>[
                for (final ApplicationQuestion q in j.questions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WrittenField(
                      fieldKey: ValueKey<String>('answer_${q.id}'),
                      controller: _answers[q.id]!,
                      rubric: q.rubric,
                      minWords: 20,
                      label: q.prompt,
                    ),
                  ),
              ]),
            ),
          SectionCard(
            title: 'Attach portfolio',
            child: items.isEmpty
                ? Text('No portfolio projects yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final PortfolioItem i in items)
                      CheckboxListTile(
                        key: ValueKey<String>('attach_${i.id}'),
                        contentPadding: EdgeInsets.zero,
                        value: _portfolio.contains(i.id),
                        title: Text(i.title),
                        subtitle: Text('Score ${i.score} · ${CareerCatalog.department(i.deptId)?.title ?? i.deptId}'),
                        onChanged: (bool? v) => setState(() => v == true ? _portfolio.add(i.id) : _portfolio.remove(i.id)),
                      ),
                  ]),
          ),
          SectionCard(
            title: 'Review before you submit',
            child: Column(children: <Widget>[
              _Row('Resume', chosen?.fileName ?? 'GradeGlow profile resume'),
              _Row('Resume match', '${match.score}%'),
              _Row('Cover letter', '${wordCount(_letter.text)} words'),
              _Row('Employer questions', '${_answerMap.values.where((String t) => wordCount(t) >= 20).length} of ${j.questions.length} answered'),
              _Row('Portfolio attached', '${_portfolio.length} item(s)'),
            ]),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            BusyButton(
              key: const ValueKey<String>('save_draft'),
              label: 'Save draft',
              icon: Icons.save_rounded,
              outlined: true,
              onPressed: () async {
                await runCareerAction<void>(context, () => _save(store, a), success: 'Draft saved.');
              },
            ),
            BusyButton(
              key: const ValueKey<String>('submit_application'),
              label: 'Submit application',
              icon: Icons.send_rounded,
              onPressed: () async {
                final bool? ok = await runCareerAction<bool>(context, () async {
                  await _save(store, a);
                  await store.submitApplication(a.id);
                  return true;
                }, success: 'Application submitted to ${j.company.name}.');
                if (ok == true && mounted) setState(() {});
              },
            ),
          ]),
          const SizedBox(height: 12),
        ];
      case ApplicationStatus.submitted:
      case ApplicationStatus.underReview:
        final int due = (a.submittedDay ?? store.day) + 2;
        return <Widget>[
          SectionCard(
            title: a.status == ApplicationStatus.submitted ? 'Application received' : 'Employer review in progress',
            subtitle: 'The employer screens your resume against the job requirements, your cover letter and answers, and your practical work. Decision on day $due.',
            child: const Align(alignment: Alignment.centerLeft, child: NextDayButton()),
          ),
        ];
      case ApplicationStatus.shortlisted:
        return <Widget>[
          SectionCard(
            title: 'Interview invitation',
            subtitle: '${j.company.name} invites you to interview. Choose a slot.',
            child: Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              for (final int s in a.interviewSlots)
                BusyButton(
                  key: ValueKey<String>('slot_$s'),
                  label: 'Day $s',
                  icon: Icons.event_available_rounded,
                  tonal: true,
                  onPressed: () async {
                    await runCareerAction<void>(context, () => store.scheduleInterview(a.id, s), success: 'Interview booked for day $s.');
                  },
                ),
            ]),
          ),
        ];
      case ApplicationStatus.interviewScheduled:
        final bool today = store.interviewAvailable(a);
        final InterviewPlan? plan = store.interviewPlanFor(a);
        return <Widget>[
          SectionCard(
            title: today ? 'Your interview is today' : 'Interview on day ${a.interviewDay}',
            subtitle: plan == null ? null : 'With ${plan.interviewer}, ${plan.interviewerRole}.',
            child: today && plan != null
                ? FilledButton.icon(
                    key: const ValueKey<String>('start_interview'),
                    onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => InterviewScreen(
                        plan: plan,
                        company: j.company,
                        applicationId: a.id,
                        day: store.day,
                        onFinished: (InterviewRecord r) => store.recordInterview(a.id, r),
                      ),
                    )),
                    icon: const Icon(Icons.record_voice_over_rounded),
                    label: const Text('Start interview'),
                  )
                : const Align(alignment: Alignment.centerLeft, child: NextDayButton()),
          ),
        ];
      case ApplicationStatus.interviewCompleted:
        return <Widget>[
          SectionCard(
            title: 'Awaiting the hiring decision',
            subtitle: 'Decided by the published hiring rule on day ${(a.interview?.day ?? store.day) + 1}.',
            child: const Align(alignment: Alignment.centerLeft, child: NextDayButton()),
          ),
        ];
      case ApplicationStatus.furtherAssessment:
        final TaskSpec t = CareerSimStore.furtherAssessmentTask(j);
        return <Widget>[
          SectionCard(
            title: 'Further assessment',
            subtitle: a.assessment == null
                ? 'The employer wants one more piece of evidence. You have one attempt.'
                : 'Submitted. Decision on day ${a.assessment!.day + 1}.',
            child: a.assessment == null
                ? TaskView(
                    spec: t,
                    allowRetry: false,
                    onGraded: (TaskResult r) async {
                      await runCareerAction<void>(context, () => store.recordAssessment(a.id, r), success: 'Assessment submitted.');
                    },
                  )
                : const Align(alignment: Alignment.centerLeft, child: NextDayButton()),
          ),
        ];
      case ApplicationStatus.offerReceived:
        final JobOffer? o = a.offer;
        if (o == null) return <Widget>[];
        return <Widget>[
          SectionCard(
            title: 'Offer: ${o.title}',
            subtitle: '${o.employer} · respond by day ${o.respondByDay}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(money(o.salary, o.salaryPeriod), key: const ValueKey<String>('offer_salary'), style: TextStyle(color: GG.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                OfferDetails(offer: o),
                const SizedBox(height: 8),
                Text('Responsibilities', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                BulletList(o.responsibilities),
                if (o.benefits.isNotEmpty) ...<Widget>[
                  Text('Benefits (simulated)', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                  BulletList(o.benefits),
                ],
                if (o.expectations.isNotEmpty) ...<Widget>[
                  Text('Performance expectations', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                  BulletList(o.expectations),
                ],
                const SizedBox(height: 8),
                if (a.negotiation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Employer reply: ${a.negotiation!.reply}', key: const ValueKey<String>('negotiation_reply'), style: TextStyle(color: GG.ink)),
                  )
                else
                  ExpansionTile(
                    key: const ValueKey<String>('negotiate_open'),
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Request a (simulated) negotiation'),
                    children: <Widget>[
                      TextField(
                        key: const ValueKey<String>('negotiate_field'),
                        controller: _negotiation,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Thank them, give evidence of your value and market research, and make a specific request.',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BusyButton(
                          key: const ValueKey<String>('negotiate'),
                          label: 'Send request',
                          icon: Icons.forum_rounded,
                          tonal: true,
                          onPressed: () async {
                            await runCareerAction<OfferNegotiation>(context, () => store.negotiateOffer(a.id, _negotiation.text));
                          },
                        ),
                      ),
                    ],
                  ),
                Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                  BusyButton(
                    key: const ValueKey<String>('accept_offer'),
                    label: 'Accept and sign contract',
                    icon: Icons.handshake_rounded,
                    onPressed: () async {
                      await Navigator.of(context).push(ggRoute<void>((_) => ContractScreen(applicationId: a.id)));
                    },
                  ),
                  BusyButton(
                    key: const ValueKey<String>('decline_offer'),
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    outlined: true,
                    onPressed: () async {
                      await runCareerAction<void>(context, () => store.declineOffer(a.id), success: 'Offer declined.');
                    },
                  ),
                ]),
              ],
            ),
          ),
        ];
      case ApplicationStatus.hired:
        return <Widget>[
          SectionCard(
            title: 'Hired',
            child: FilledButton.icon(
              key: const ValueKey<String>('go_workplace'),
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const WorkplaceScreen())),
              icon: const Icon(Icons.apartment_rounded),
              label: const Text('Go to the workplace'),
            ),
          ),
        ];
      case ApplicationStatus.rejected:
        return <Widget>[
          SectionCard(
            title: 'Not successful this time',
            subtitle: 'Use the feedback below, strengthen your resume and practical evidence, and apply again when the role reopens.',
            child: Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              FilledButton.tonalIcon(
                key: const ValueKey<String>('improve_resume'),
                onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const ResumeHubScreen())),
                icon: const Icon(Icons.description_rounded),
                label: const Text('Improve my resume'),
              ),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('similar_jobs'),
                onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const JobBoardScreen())),
                icon: const Icon(Icons.work_outline_rounded),
                label: const Text('See other jobs'),
              ),
            ]),
          ),
        ];
      case ApplicationStatus.offerDeclined:
      case ApplicationStatus.withdrawn:
        return <Widget>[];
    }
  }
}

class _ScreeningCard extends StatelessWidget {
  const _ScreeningCard({required this.report});
  final ScreeningReport report;

  @override
  Widget build(BuildContext context) => SectionCard(
        title: 'Employer screening: ${report.score}/100',
        subtitle: report.shortlisted ? 'Shortlisted' : (report.eligible ? 'Not shortlisted' : 'Not eligible'),
        trailing: const ValidatedBadge(label: 'Rule-based'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final MapEntry<String, int> e in report.breakdown.entries) LabeledBar(label: e.key, value: e.value),
            if (report.strengths.isNotEmpty) ...<Widget>[
              Text('Strengths', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              BulletList(report.strengths, icon: Icons.add_circle_outline_rounded, color: GG.green),
            ],
            if (report.gaps.isNotEmpty) ...<Widget>[
              Text('Gaps', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              BulletList(report.gaps, icon: Icons.remove_circle_outline_rounded, color: GG.red),
            ],
          ],
        ),
      );
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision});
  final HiringDecision decision;

  @override
  Widget build(BuildContext context) => SectionCard(
        title: 'Hiring decision: ${switch (decision.outcome) {
          HiringOutcome.offer => 'Offer',
          HiringOutcome.furtherAssessment => 'Further assessment',
          HiringOutcome.reject => 'Not successful',
        }}',
        trailing: const ValidatedBadge(label: 'Defined criteria'),
        child: BulletList(decision.reasons),
      );
}

/// Validated interview scores (rubric-based), shown separately from any AI.
class InterviewReportCard extends StatelessWidget {
  const InterviewReportCard({super.key, required this.record});
  final InterviewRecord record;

  @override
  Widget build(BuildContext context) => SectionCard(
        title: 'Interview report: ${record.overall}/100',
        subtitle: record.practicalPassed ? 'Practical passed' : 'Practical not passed',
        trailing: const ValidatedBadge(label: 'Rubric score'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LabeledBar(label: 'Communication', value: record.communication),
            LabeledBar(label: 'Technical knowledge', value: record.technical),
            LabeledBar(label: 'Problem solving', value: record.problemSolving),
            LabeledBar(label: 'Workplace readiness', value: record.readiness),
            if (record.feedback.isNotEmpty) BulletList(record.feedback),
            if (record.turns.length >= 2) ...<Widget>[
              Builder(builder: (BuildContext context) {
                final List<InterviewTurn> sorted = List<InterviewTurn>.from(record.turns)..sort((InterviewTurn a, InterviewTurn b) => b.score.compareTo(a.score));
                final InterviewTurn best = sorted.first;
                final InterviewTurn worst = sorted.last;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Strongest answer (${best.score})', style: TextStyle(color: GG.green, fontWeight: FontWeight.w700)),
                  Text(best.prompt, style: TextStyle(color: GG.ink, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Weakest answer (${worst.score})', style: TextStyle(color: GG.red, fontWeight: FontWeight.w700)),
                  Text(worst.prompt, style: TextStyle(color: GG.ink, fontSize: 13)),
                  if (worst.notes.isNotEmpty) Text('To improve: ${worst.notes.join(' ')}', style: TextStyle(color: GG.mute, fontSize: 12.5)),
                ]);
              }),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Question by question (${record.turns.length})'),
              children: <Widget>[
                for (final InterviewTurn t in record.turns)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.prompt, maxLines: 3, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${t.score}/100${t.isFollowUp ? ' · follow-up' : ''}${t.notes.isEmpty ? '' : ' · ${t.notes.join(' ')}'}'),
                  ),
              ],
            ),
          ],
        ),
      );
}

/// Word count helper used by the Career Centre.
int wordCount(String s) => TextRubric.words(s).length;
