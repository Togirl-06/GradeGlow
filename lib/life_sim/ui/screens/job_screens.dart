import 'package:flutter/material.dart';

import '../../careers/career_catalog.dart';
import '../../core/life_clock.dart';
import '../../education/skills.dart';
import '../../employment/application.dart';
import '../../employment/contract.dart';
import '../../employment/employers.dart';
import '../../employment/job_listing.dart';
import '../../employment/resume.dart';
import '../../interview/interview_session.dart';
import '../../services/life_ai_service.dart';
import '../../workplace/job_state.dart';
import '../../game/life_game.dart';
import '../../workplace/work_task.dart';
import '../../world/world_model.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import 'interview_screen.dart';

String _eduName(int r) => const <String>['High school', 'Associate degree', "Bachelor's degree", "Master's degree", 'Doctorate'][r.clamp(0, 4)];

// ---------------------------------------------------------------------------
// Job board
// ---------------------------------------------------------------------------

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key, required this.life});
  final LifeSession life;
  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  String? _career;

  @override
  Widget build(BuildContext context) {
    final LifeSession life = widget.life;
    final List<JobListing> jobs = life.game.openJobs(careerId: _career)
      ..sort((JobListing a, JobListing b) => a.rank != b.rank ? a.rank.compareTo(b.rank) : b.monthlySalary.compareTo(a.monthlySalary));
    return ListenableBuilder(
      listenable: life,
      builder: (BuildContext context, _) => LifePage(
        title: 'Job board',
        subtitle: '${jobs.length} openings · Day ${life.game.day}',
        child: Column(children: <Widget>[
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: <Widget>[
                _chip('All', _career == null, () => setState(() => _career = null)),
                for (final CareerDef c in CareerCatalog.all) _chip('${c.emoji} ${c.title}', _career == c.id, () => setState(() => _career = c.id)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext c, int i) => _JobCard(life: life, job: jobs[i]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, bool on, VoidCallback tap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: on, onSelected: (_) => tap(), selectedColor: LifeColors.blue, backgroundColor: LifeColors.panel2),
      );
}

ApplicationAssessment _assess(LifeSession life, JobListing l) {
  final double rs = life.game.reviewResume(target: l).score;
  return ApplicationEngine.assess(q: life.game.qualifications(), listing: l, resumeScore: rs, seedKey: 'preview|${l.id}');
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.life, required this.job});
  final LifeSession life;
  final JobListing job;

  @override
  Widget build(BuildContext context) {
    final Employer e = job.employer;
    final ApplicationAssessment a = _assess(life, job);
    final String? blocked = life.game.whyCannotApply(job);
    final Color mc = a.hardFail ? LifeColors.red : (a.passes ? LifeColors.green : LifeColors.amber);
    return Panel(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobDetailScreen(life: life, job: job))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Color(e.accent).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
          child: Text(job.career.emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(job.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(e.name, style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
              Tag('${money(job.monthlySalary)}/mo', color: LifeColors.green),
              Tag(job.hoursLabel, color: LifeColors.blue),
              Tag(_eduName(job.minEducationRank), color: LifeColors.purple),
              Tag(a.hardFail ? 'Not eligible' : (a.passes ? 'Good match' : 'Stretch'), color: mc),
              if (blocked != null) Tag(blocked.contains('already applied') ? 'Applied' : 'Unavailable', color: LifeColors.muted),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.life, required this.job});
  final LifeSession life;
  final JobListing job;

  @override
  Widget build(BuildContext context) {
    final Employer e = job.employer;
    return ListenableBuilder(
      listenable: life,
      builder: (BuildContext context, _) {
        final ApplicationAssessment a = _assess(life, job);
        final String? blocked = life.game.whyCannotApply(job);
        return LifePage(
          title: job.title,
          subtitle: e.name,
          child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(e.blurb, style: const TextStyle(height: 1.4)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String v in e.values) Tag(v, color: LifeColors.teal)]),
                const SizedBox(height: 6),
                Text('Culture: ${e.culture}', style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
              ]),
            ),
            const SectionTitle('The role'),
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                _kv('Salary', '${money(job.monthlySalary)} per month (before tax)'),
                _kv('Hours', job.hoursLabel),
                _kv('Education', _eduName(job.minEducationRank)),
                _kv('Experience', job.requiredExperienceDays == 0 ? 'None required' : '${job.requiredExperienceDays} workdays in ${job.career.title}'),
                const SizedBox(height: 8),
                const Text('Responsibilities', style: TextStyle(fontWeight: FontWeight.w900)),
                for (final String r in job.responsibilities) Padding(padding: const EdgeInsets.only(top: 4), child: Text('• $r')),
              ]),
            ),
            const SectionTitle('Skills required'),
            Panel(
              child: Column(children: <Widget>[
                if (job.requiredSkills.isEmpty) const Text('No specific skills required.', style: TextStyle(color: LifeColors.muted)),
                for (final MapEntry<String, int> s in job.requiredSkills.entries)
                  NeedBar(
                    label: Skills.nameOf(s.key),
                    value: life.game.skills.level(s.key).clamp(0, 100).toDouble(),
                    emoji: life.game.skills.level(s.key) >= s.value ? '✅' : '⬜',
                    color: life.game.skills.level(s.key) >= s.value ? LifeColors.green : LifeColors.amber,
                  ),
                if (job.requiredSkills.isNotEmpty) const Text('Bars show your level; you need the number shown in the tags below.', style: TextStyle(fontSize: 11, color: LifeColors.muted)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final MapEntry<String, int> s in job.requiredSkills.entries) Tag('${Skills.nameOf(s.key)} ${s.value}', color: LifeColors.purple)]),
              ]),
            ),
            const SectionTitle('Your chances'),
            Panel(
              border: a.hardFail ? LifeColors.red : (a.passes ? LifeColors.green : LifeColors.amber),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Match ${a.score.round()}% (needs about ${a.threshold.round()}%)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                for (final String s in a.strengths) Padding(padding: const EdgeInsets.only(top: 4), child: Text('✅ $s')),
                for (final String g in a.gaps) Padding(padding: const EdgeInsets.only(top: 4), child: Text('⚠️ $g')),
              ]),
            ),
            const SizedBox(height: 14),
            BigButton(
              label: blocked == null ? 'Apply now' : blocked,
              icon: Icons.send_rounded,
              onPressed: blocked != null
                  ? null
                  : () {
                      final ActionResult r = life.game.apply(job);
                      life.report(r);
                      Navigator.of(context).pop();
                    },
            ),
            const SizedBox(height: 10),
            BigButton(
              label: 'Practice interview for this role',
              icon: Icons.mic_rounded,
              color: LifeColors.purple,
              onPressed: () async {
                final InterviewSession s = life.game.startPracticeInterview(job, judge: AiInterviewJudge());
                await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => InterviewScreen(life: life, interview: s)));
              },
            ),
            const SizedBox(height: 24),
          ]),
        );
      },
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(width: 92, child: Text(k, style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w700))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );
}

// ---------------------------------------------------------------------------
// Applications
// ---------------------------------------------------------------------------

Color statusColor(ApplicationStatus s) {
  switch (s) {
    case ApplicationStatus.pending:
      return LifeColors.muted;
    case ApplicationStatus.invited:
    case ApplicationStatus.interviewed:
      return LifeColors.blue;
    case ApplicationStatus.offer:
    case ApplicationStatus.hired:
      return LifeColors.green;
    case ApplicationStatus.waitlisted:
    case ApplicationStatus.infoRequested:
      return LifeColors.amber;
    case ApplicationStatus.rejected:
    case ApplicationStatus.declined:
    case ApplicationStatus.expired:
      return LifeColors.red;
  }
}

String statusLabel(ApplicationStatus s) {
  switch (s) {
    case ApplicationStatus.pending:
      return 'Under review';
    case ApplicationStatus.invited:
      return 'Interview invited';
    case ApplicationStatus.infoRequested:
      return 'More info needed';
    case ApplicationStatus.interviewed:
      return 'Interviewed';
    case ApplicationStatus.offer:
      return 'Offer received';
    case ApplicationStatus.waitlisted:
      return 'Waiting list';
    case ApplicationStatus.hired:
      return 'Hired';
    case ApplicationStatus.declined:
      return 'Declined';
    case ApplicationStatus.rejected:
      return 'Not selected';
    case ApplicationStatus.expired:
      return 'Expired';
  }
}

String _dayHour(int day, int hour) {
  final String h = '${hour % 12 == 0 ? 12 : hour % 12}${hour < 12 ? 'am' : 'pm'}';
  return '${LifeClock.weekdayNames[(day - 1) % 7]} (Day $day) at $h';
}

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key, required this.life});
  final LifeSession life;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final List<ApplicationRecord> apps = life.game.applications;
          return LifePage(
            title: 'My applications',
            subtitle: '${apps.where((ApplicationRecord a) => a.isActive).length} active',
            child: apps.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No applications yet. Visit the Employment Centre job board to apply.', textAlign: TextAlign.center, style: TextStyle(color: LifeColors.muted))))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: apps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext c, int i) => _AppCard(life: life, app: apps[i]),
                  ),
          );
        },
      );
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.life, required this.app});
  final LifeSession life;
  final ApplicationRecord app;

  @override
  Widget build(BuildContext context) {
    final JobListing? l = app.listing;
    if (l == null) return const SizedBox.shrink();
    final String? ib = app.status == ApplicationStatus.invited ? life.game.interviewBlock(app) : null;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Expanded(child: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
          Tag(statusLabel(app.status), color: statusColor(app.status)),
        ]),
        Text(l.employer.name, style: const TextStyle(color: LifeColors.muted)),
        const SizedBox(height: 8),
        if (app.status == ApplicationStatus.pending) Text('Applied on Day ${app.submittedDay}. A reply is expected by Day ${app.respondDay}.'),
        if (app.status == ApplicationStatus.infoRequested) ...<Widget>[
          Text('The recruiter needs more information by Day ${app.infoDeadlineDay}:', style: const TextStyle(fontWeight: FontWeight.w700)),
          for (final String f in app.feedback.take(2)) Text('• $f', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          const Text('Improve your resume, skills or certifications first, then send your update.', style: TextStyle(color: LifeColors.muted, fontSize: 12.5)),
          const SizedBox(height: 8),
          BigButton(
            label: 'Send update',
            icon: Icons.send_rounded,
            onPressed: () => life.report(life.game.sendApplicationUpdate(app)),
          ),
        ],
        if (app.status == ApplicationStatus.invited) ...<Widget>[
          if (app.round >= 2) const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('FINAL INTERVIEW', style: TextStyle(color: LifeColors.purple, fontWeight: FontWeight.w900, letterSpacing: 1))),
          Text('Interview: ${_dayHour(app.interviewDay ?? 0, app.interviewHour ?? 9)} at ${l.employer.name}.', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(ib ?? 'You are in the right place at the right time — you can start now.', style: TextStyle(color: ib == null ? LifeColors.green : LifeColors.amber)),
          const SizedBox(height: 8),
          BigButton(
            label: 'Start interview',
            icon: Icons.record_voice_over_rounded,
            onPressed: ib != null
                ? null
                : () async {
                    final InterviewSession s = life.game.startInterview(app, judge: AiInterviewJudge());
                    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => InterviewScreen(life: life, interview: s, application: app)));
                  },
          ),
        ],
        if (app.status == ApplicationStatus.offer) ...<Widget>[
          Text('Offer: ${money(app.offerSalary ?? l.monthlySalary)} per month', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          BigButton(label: 'Review offer & contract', icon: Icons.description_rounded, color: LifeColors.green, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OfferScreen(life: life, app: app)))),
        ],
        if (app.status == ApplicationStatus.waitlisted) Text('You are on the waiting list. A decision is expected around Day ${app.waitlistResolveDay}.'),
        if (app.status == ApplicationStatus.rejected) ...<Widget>[
          if (app.interviewScore != null) Text('Interview score: ${app.interviewScore!.round()}/100'),
          if (app.feedback.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            const Text('How to improve before reapplying:', style: TextStyle(fontWeight: FontWeight.w800)),
            for (final String f in app.feedback.take(5)) Padding(padding: const EdgeInsets.only(top: 3), child: Text('• $f', style: const TextStyle(fontSize: 13))),
          ],
        ],
        if (app.status == ApplicationStatus.expired) const Text('The interview slot was missed. You can apply again.'),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Offer, contract and negotiation
// ---------------------------------------------------------------------------

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key, required this.life, required this.app});
  final LifeSession life;
  final ApplicationRecord app;
  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  double _ask = 8;
  final TextEditingController _pitch = TextEditingController();
  double? _agreed;
  double? _counter;
  String? _msg;
  bool _withdrawn = false;

  LifeSession get life => widget.life;
  ApplicationRecord get app => widget.app;
  JobListing get l => app.listing!;

  @override
  void dispose() {
    _pitch.dispose();
    super.dispose();
  }

  double get _salary => _agreed ?? app.offerSalary ?? l.monthlySalary;

  Future<void> _negotiate() async {
    final String text = _pitch.text.trim();
    final StageResult pr = text.isEmpty ? const StageResult(score: 0, feedback: 'No pitch given.') : await AiWorkTextJudge().gradeText(scenario: _dummy, stage: SalaryNegotiation.pitchStage, text: text);
    final NegotiationOutcome o = life.game.negotiate(
      offer: app.offerSalary ?? l.monthlySalary,
      askPercent: _ask,
      pitchScore: pr.score,
      isNewOffer: true,
      rating: app.interviewScore,
      careerId: l.careerId,
    );
    life.game.negotiatedOffers.add(app.id);
    setState(() {
      _msg = '${o.message}\n\nYour pitch: ${(pr.score * 100).round()}% — ${pr.feedback}';
      if (o.withdrawn) {
        _withdrawn = true;
        app.status = ApplicationStatus.declined;
      } else if (o.accepted) {
        _agreed = o.finalSalary;
      } else if (o.counter != null) {
        _counter = o.counter;
      }
    });
    life.changed();
  }

  static final WorkScenario _dummy = WorkScenario(
    id: 'negotiation',
    careerId: '',
    title: 'Salary negotiation',
    station: 'hr',
    brief: 'Make your case.',
    assignedBy: 'HR',
    stages: <WorkStage>[SalaryNegotiation.pitchStage],
  );

  @override
  Widget build(BuildContext context) {
    final Employer e = l.employer;
    final bool negotiated = life.game.negotiatedOffers.contains(app.id) || _msg != null;
    final EmploymentContract preview = EmploymentContract(
      employerId: e.id,
      careerId: l.careerId,
      rank: l.rank,
      title: l.title,
      monthlySalary: _salary,
      startDay: life.game.nextWorkdayAfter(life.game.day),
      startHour: e.startHour,
      endHour: e.endHour,
      signedDay: life.game.day,
    );
    return LifePage(
      title: 'Job offer',
      subtitle: '${l.title} · ${e.name}',
      child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
        Panel(
          border: LifeColors.green,
          child: Column(children: <Widget>[
            const Text('🎉 Congratulations!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${money(_salary)} / month', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: LifeColors.green)),
            Text('${e.name} · ${l.hoursLabel}', style: const TextStyle(color: LifeColors.muted)),
          ]),
        ),
        if (_withdrawn)
          const Padding(padding: EdgeInsets.all(14), child: Text('The employer withdrew the offer. Negotiate respectfully next time — ask for a realistic amount and justify it.', style: TextStyle(color: LifeColors.red)))
        else ...<Widget>[
          const SectionTitle('Negotiate your salary (optional, one attempt)'),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Ask for +${_ask.round()}% → ${money((app.offerSalary ?? l.monthlySalary) * (1 + _ask / 100))}', style: const TextStyle(fontWeight: FontWeight.w800)),
              Slider(value: _ask, min: 0, max: 30, divisions: 30, label: '+${_ask.round()}%', onChanged: negotiated ? null : (double v) => setState(() => _ask = v)),
              TextField(controller: _pitch, enabled: !negotiated, minLines: 3, maxLines: 6, decoration: const InputDecoration(hintText: 'Explain why you deserve it: results, market rates, flexibility, thanks…')),
              const SizedBox(height: 10),
              BigButton(label: 'Submit counter-offer', icon: Icons.handshake_rounded, color: LifeColors.amber, onPressed: negotiated ? null : _negotiate),
              if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!, style: const TextStyle(height: 1.4))),
              if (_counter != null && _agreed == null) ...<Widget>[
                const SizedBox(height: 8),
                Row(children: <Widget>[
                  Expanded(child: BigButton(label: 'Accept ${money(_counter!)}', onPressed: () => setState(() {
                        _agreed = _counter;
                        _counter = null;
                      }))),
                  const SizedBox(width: 8),
                  Expanded(child: BigButton(label: 'Keep original', color: LifeColors.panel2, onPressed: () => setState(() => _counter = null))),
                ]),
              ],
            ]),
          ),
          const SectionTitle('Employment contract'),
          Panel(child: Text(preview.legalText(), style: const TextStyle(fontSize: 13, height: 1.45))),
          if (life.game.job != null)
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('Signing will end your current job with a resignation.', style: TextStyle(color: LifeColors.amber))),
          const SizedBox(height: 12),
          BigButton(
            label: 'Sign contract',
            icon: Icons.edit_rounded,
            color: LifeColors.green,
            onPressed: () {
              final ActionResult r = life.game.acceptOffer(app, salary: _salary);
              life.report(r);
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          BigButton(
            label: 'Decline offer',
            color: LifeColors.red,
            icon: Icons.close_rounded,
            onPressed: () {
              life.report(life.game.declineOffer(app));
              Navigator.of(context).pop();
            },
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Resume builder + AI career assistant
// ---------------------------------------------------------------------------

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key, required this.life});
  final LifeSession life;
  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  late final TextEditingController _summary;
  final TextEditingController _skill = TextEditingController();
  final TextEditingController _projTitle = TextEditingController();
  final TextEditingController _projDesc = TextEditingController();
  final TextEditingController _ask = TextEditingController();
  String? _career;
  final List<String> _chat = <String>[];
  bool _busy = false;

  Resume get r => widget.life.game.syncedResume();

  @override
  void initState() {
    super.initState();
    _summary = TextEditingController(text: widget.life.game.resume.summary);
  }

  @override
  void dispose() {
    _summary.dispose();
    _skill.dispose();
    _projTitle.dispose();
    _projDesc.dispose();
    _ask.dispose();
    super.dispose();
  }

  Future<void> _askAssistant() async {
    final String q = _ask.text.trim();
    if (q.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _chat.add('You: $q');
      _ask.clear();
    });
    const NpcDef assistant = NpcDef(
      id: 'career_assistant',
      name: 'Career Assistant',
      role: 'AI career assistant',
      x: 0,
      y: 0,
      persona: 'A warm, practical career assistant who reviews resumes and explains what employers expect. Be concrete and brief.',
      lines: <String>['Quantify achievements: numbers make your impact believable.', 'Tailor your summary to the role you want.', 'Keep it to one page and lead with your strongest evidence.'],
    );
    final ResumeReview review = widget.life.game.reviewResume(careerId: _career);
    final String reply = await widget.life.npcChat.reply(assistant, q, context: 'Resume score ${review.score.round()}/100. Improvements: ${review.improvements.take(3).join('; ')}');
    if (!mounted) return;
    setState(() {
      _chat.add('Assistant: $reply');
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LifeSession life = widget.life;
    final Resume res = r;
    final ResumeReview review = life.game.reviewResume(careerId: _career);
    return LifePage(
      title: 'Resume builder',
      subtitle: 'AI career assistant',
      child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
        Panel(
          child: Row(children: <Widget>[
            SizedBox(
              width: 76,
              height: 76,
              child: Stack(alignment: Alignment.center, children: <Widget>[
                CircularProgressIndicator(value: review.score / 100, strokeWidth: 8, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(review.score >= 70 ? LifeColors.green : (review.score >= 50 ? LifeColors.amber : LifeColors.red))),
                Text(review.score.round().toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(review.grade, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 6),
                DropdownButton<String?>(
                  value: _career,
                  isExpanded: true,
                  dropdownColor: LifeColors.panel,
                  hint: const Text('Review for a career…'),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(value: null, child: Text('General review')),
                    for (final CareerDef c in CareerCatalog.all) DropdownMenuItem<String?>(value: c.id, child: Text('${c.emoji} ${c.title}')),
                  ],
                  onChanged: (String? v) => setState(() => _career = v),
                ),
              ]),
            ),
          ]),
        ),
        const SectionTitle('Assistant feedback'),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            for (final String s in review.strengths) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('✅ $s')),
            for (final String s in review.improvements) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('💡 $s')),
            if (review.expectations.isNotEmpty) ...<Widget>[
              const Divider(),
              const Text('What employers in this field expect', style: TextStyle(fontWeight: FontWeight.w900)),
              for (final String s in review.expectations) Padding(padding: const EdgeInsets.only(top: 4), child: Text('• $s', style: const TextStyle(fontSize: 13))),
            ],
          ]),
        ),
        const SectionTitle('Personal summary'),
        TextField(
          controller: _summary,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(hintText: 'Two or three sentences about who you are, your strengths and your goal.'),
          onChanged: (String v) {
            life.game.resume.summary = v;
            life.changed();
          },
        ),
        const SectionTitle('Education, experience & certificates (automatic)'),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            for (final EducationEntry e in res.education) Text('🎓 ${e.degree} — ${e.school}'),
            for (final ExperienceEntry e in res.experience) Text('💼 ${e.role} at ${e.employer} (${e.workdays} workdays)'),
            for (final String c in res.certifications) Text('🏅 $c'),
            if (res.experience.isEmpty) const Text('No work experience yet — internships are the way in.', style: TextStyle(color: LifeColors.muted)),
          ]),
        ),
        const SectionTitle('Skills'),
        Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
          for (final String s in res.skills)
            InputChip(label: Text(s), onDeleted: () {
              life.game.resume.skills.remove(s);
              life.changed();
              setState(() {});
            }),
        ]),
        Row(children: <Widget>[
          Expanded(child: TextField(controller: _skill, decoration: const InputDecoration(hintText: 'Add a skill'))),
          IconButton(
            onPressed: () {
              final String v = _skill.text.trim();
              if (v.isEmpty) return;
              life.game.resume.skills.add(v);
              _skill.clear();
              life.changed();
              setState(() {});
            },
            icon: const Icon(Icons.add_circle_rounded, color: LifeColors.blue),
          ),
        ]),
        const SectionTitle('Projects'),
        for (final ProjectEntry p in res.projects)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Panel(child: Row(children: <Widget>[
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(p.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text(p.description)])),
              IconButton(onPressed: () {
                life.game.resume.projects.remove(p);
                life.changed();
                setState(() {});
              }, icon: const Icon(Icons.delete_outline_rounded)),
            ])),
          ),
        TextField(controller: _projTitle, decoration: const InputDecoration(hintText: 'Project title')),
        const SizedBox(height: 6),
        TextField(controller: _projDesc, minLines: 2, maxLines: 4, decoration: const InputDecoration(hintText: 'What you did and the result (use numbers!)')),
        const SizedBox(height: 6),
        BigButton(
          label: 'Add project',
          icon: Icons.add_rounded,
          color: LifeColors.teal,
          onPressed: () {
            if (_projTitle.text.trim().isEmpty) return;
            life.game.resume.projects.add(ProjectEntry(title: _projTitle.text.trim(), description: _projDesc.text.trim()));
            _projTitle.clear();
            _projDesc.clear();
            life.changed();
            setState(() {});
          },
        ),
        const SectionTitle('Ask the career assistant'),
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            if (_chat.isEmpty) const Text('Ask about resume tips, what a role expects, or how to prepare for interviews.', style: TextStyle(color: LifeColors.muted)),
            for (final String m in _chat) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(m)),
            Row(children: <Widget>[
              Expanded(child: TextField(controller: _ask, decoration: const InputDecoration(hintText: 'e.g. How do I improve my summary?'), onSubmitted: (_) => _askAssistant())),
              IconButton(onPressed: _busy ? null : _askAssistant, icon: const Icon(Icons.send_rounded)),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
