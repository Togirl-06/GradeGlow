import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'interview_screen.dart';
import 'task_views.dart';
import 'workplace_screen.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  bool _mine = true;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final String dept = store.profile.deptId;
    final List<JobPosting> list = _mine && dept.isNotEmpty ? CareerCatalog.postingsFor(dept) : CareerCatalog.postings;
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunities')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Wrap(
            spacing: 8,
            children: <Widget>[
              ChoiceChip(key: const ValueKey<String>('filter_mine'), label: const Text('My field'), selected: _mine, onSelected: (_) => setState(() => _mine = true)),
              ChoiceChip(key: const ValueKey<String>('filter_all'), label: const Text('All fields'), selected: !_mine, onSelected: (_) => setState(() => _mine = false)),
            ],
          ),
          const SizedBox(height: 12),
          for (final JobPosting j in list) _PostingCard(job: j),
          if (list.isEmpty) Text('No postings.', style: TextStyle(color: VuV2Colors.mute)),
        ],
      ),
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
    final Department? d = CareerCatalog.department(job.deptId);
    final int readiness = d == null ? 0 : CareerRules.readiness(store.profile, d, job: job).score;
    final JobApplication? app = store.activeApplicationFor(job.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        key: ValueKey<String>('posting_${job.id}'),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${job.company.name} · ${job.type.label} · ${job.location}\n'
            '${money(job.salaryMin, job.salaryPeriod)}${job.salaryMax > job.salaryMin ? ' – ${money(job.salaryMax, job.salaryPeriod)}' : ''}\n'
            '${open ? 'Closes day ${PostingSchedule.deadline(job, day)}' : 'Closed · reopens day ${PostingSchedule.reopens(job, day)}'} · your readiness $readiness'),
        isThreeLine: true,
        trailing: app == null ? const Icon(Icons.chevron_right_rounded) : StatusChip(app.status.label, color: statusColor(app.status)),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobDetailScreen(postingId: job.id))),
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
          Text(j.title, style: TextStyle(color: VuV2Colors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${j.company.name} · ${j.company.industry} · ${j.location}', style: TextStyle(color: VuV2Colors.mute)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            StatusChip(j.type.label),
            StatusChip('${money(j.salaryMin, j.salaryPeriod)}${j.salaryMax > j.salaryMin ? ' – ${money(j.salaryMax, j.salaryPeriod)}' : ''}'),
            StatusChip(open ? 'Deadline: day ${PostingSchedule.deadline(j, store.day)}' : 'Closed · reopens day ${PostingSchedule.reopens(j, store.day)}',
                color: open ? null : VuV2Colors.danger),
          ]),
          const SizedBox(height: 12),
          SectionCard(title: 'About the role', child: Text(j.description, style: TextStyle(color: VuV2Colors.ink, height: 1.4))),
          SectionCard(title: 'Responsibilities', child: BulletList(j.responsibilities)),
          SectionCard(title: 'Qualifications', child: BulletList(j.qualifications)),
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
          SectionCard(title: 'About ${j.company.name}', child: Text(j.company.about, style: TextStyle(color: VuV2Colors.ink, height: 1.4))),
          if (app != null)
            FilledButton.icon(
              key: const ValueKey<String>('open_application'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationScreen(applicationId: app.id))),
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
                        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationScreen(applicationId: a.id)));
                      }
                    }
                  : null,
            ),
        ],
      ),
    );
  }
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
            Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, size: 18, color: met ? VuV2Colors.success : VuV2Colors.mute),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: TextStyle(color: VuV2Colors.ink, fontSize: 13.5))),
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
            Expanded(child: Text('Today is day ${store.day}', style: TextStyle(color: VuV2Colors.mute))),
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
          if (apps.isEmpty) Text('No applications yet.', style: TextStyle(color: VuV2Colors.mute)),
          for (final JobApplication a in apps)
            Card(
              child: ListTile(
                key: ValueKey<String>('app_${a.postingId}'),
                title: Text(CareerCatalog.posting(a.postingId)?.title ?? a.postingId),
                subtitle: Text('${CareerCatalog.posting(a.postingId)?.company.name ?? ''} · started day ${a.createdDay}'),
                trailing: StatusChip(a.status.label, color: statusColor(a.status)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationScreen(applicationId: a.id))),
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
  Set<String> _portfolio = <String>{};
  bool _init = false;

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

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
    }
    return Scaffold(
      appBar: AppBar(title: Text(j.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text(j.company.name, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 18))),
            StatusChip(a.status.label, color: statusColor(a.status)),
          ]),
          const SizedBox(height: 4),
          Text('Day ${store.day}', style: TextStyle(color: VuV2Colors.mute)),
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
        return <Widget>[
          if (resume < 0.7)
            SectionCard(
              title: 'Resume ${(resume * 100).round()}% complete',
              subtitle: 'Employers reject incomplete resumes at screening. Finish it in the Career Centre.',
              child: BulletList(CareerRules.resumeChecklist(store.profile.resume)
                  .where((Criterion c) => !c.met)
                  .map((Criterion c) => c.label)
                  .toList()),
            ),
          SectionCard(
            title: 'Cover letter',
            subtitle: 'At least 80 words to submit; 120+ to meet the screening rubric.',
            child: WrittenField(
              fieldKey: const ValueKey<String>('cover_letter_field'),
              controller: _letter,
              rubric: CareerRules.coverLetterRubric(j),
              minWords: 80,
              label: 'Dear hiring manager…',
            ),
          ),
          SectionCard(
            title: 'Attach portfolio',
            child: items.isEmpty
                ? Text('No portfolio projects yet.', style: TextStyle(color: VuV2Colors.mute))
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
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            BusyButton(
              key: const ValueKey<String>('save_draft'),
              label: 'Save draft',
              icon: Icons.save_rounded,
              outlined: true,
              onPressed: () async {
                await runCareerAction<void>(context, () => store.saveDraft(a.id, coverLetter: _letter.text, portfolioIds: _portfolio.toList()),
                    success: 'Draft saved.');
              },
            ),
            BusyButton(
              key: const ValueKey<String>('submit_application'),
              label: 'Submit application',
              icon: Icons.send_rounded,
              onPressed: () async {
                final bool? ok = await runCareerAction<bool>(context, () async {
                  await store.saveDraft(a.id, coverLetter: _letter.text, portfolioIds: _portfolio.toList());
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
            subtitle: 'The employer screens your training, skills, portfolio, resume and cover letter. Decision on day $due.',
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
        final InterviewPlan? plan = CareerCatalog.interviewPlan(j.interviewPlanId);
        return <Widget>[
          SectionCard(
            title: today ? 'Your interview is today' : 'Interview on day ${a.interviewDay}',
            subtitle: plan == null ? null : 'With ${plan.interviewer}, ${plan.interviewerRole}.',
            child: today && plan != null
                ? FilledButton.icon(
                    key: const ValueKey<String>('start_interview'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => InterviewScreen(
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
                Text(money(o.salary, o.salaryPeriod), style: TextStyle(color: VuV2Colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Stage: ${o.stage.label} · start day ${o.startDay}', style: TextStyle(color: VuV2Colors.mute)),
                const SizedBox(height: 8),
                Text('Responsibilities', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
                BulletList(o.responsibilities),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                  BusyButton(
                    key: const ValueKey<String>('accept_offer'),
                    label: 'Accept offer',
                    icon: Icons.handshake_rounded,
                    onPressed: () async {
                      final Employment? e = await runCareerAction<Employment>(context, () => store.acceptOffer(a.id), success: 'Welcome to ${o.employer}!');
                      if (e != null && context.mounted) {
                        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkplaceScreen()));
                      }
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
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkplaceScreen())),
              icon: const Icon(Icons.apartment_rounded),
              label: const Text('Go to the workplace'),
            ),
          ),
        ];
      case ApplicationStatus.rejected:
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
              Text('Strengths', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
              BulletList(report.strengths, icon: Icons.add_circle_outline_rounded, color: VuV2Colors.success),
            ],
            if (report.gaps.isNotEmpty) ...<Widget>[
              Text('Gaps', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
              BulletList(report.gaps, icon: Icons.remove_circle_outline_rounded, color: VuV2Colors.danger),
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
