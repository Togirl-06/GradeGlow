import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/career_ai.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../engine/pay_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'employment_screens.dart';
import 'money_find_screens.dart';
import 'job_screens.dart';
import 'task_views.dart';
import 'gg_kit.dart';

class WorkplaceScreen extends StatefulWidget {
  const WorkplaceScreen({super.key});

  @override
  State<WorkplaceScreen> createState() => _WorkplaceScreenState();
}

class _WorkplaceScreenState extends State<WorkplaceScreen> {
  int _section = 0;

  static const List<(String, IconData)> sections = <(String, IconData)>[
    ('Dashboard', Icons.dashboard_rounded),
    ('Tasks', Icons.checklist_rounded),
    ('Team', Icons.groups_rounded),
    ('Meetings', Icons.event_rounded),
    ('Performance', Icons.insights_rounded),
    ('Messages', Icons.forum_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Employment? e = p.currentJob;
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workplace')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('You are not employed right now. Apply through the Career Centre.', style: TextStyle(color: GG.ink)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const JobBoardScreen())),
              child: const Text('Find opportunities'),
            ),
            const SizedBox(height: 16),
            EmploymentHistory(employment: p.employment),
          ],
        ),
      );
    }
    final WorkplaceDef? w = store.workplaceOf(e);
    final AssignmentRecord? open = e.open;
    final bool internDone = store.internshipFinished(e);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: <Widget>[
          const Icon(Icons.school_rounded, color: GG.violet),
          const SizedBox(width: 8),
          const Text('GradeGlow', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Expanded(child: Text('|  My Workplace - ${e.employer}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: GG.mute, fontWeight: FontWeight.w600))),
        ]),
        actions: <Widget>[Padding(padding: const EdgeInsets.only(right: 12), child: GGAvatar(name: p.resume.fullName.isEmpty ? e.title : p.resume.fullName, size: 34))],
      ),
      body: GGSidebarLayout(
        keyPrefix: 'wp',
        items: sections,
        selected: _section,
        onSelect: (int i) => setState(() => _section = i),
        child: _section != 0
            ? WorkplaceSection(section: _section, employment: e)
            : ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          WorkplaceOverview(employment: e),
          const SizedBox(height: 14),
          Text(e.title, style: TextStyle(color: GG.ink, fontSize: 22, fontWeight: FontWeight.w900)),
          Text('${e.stage.label} · ${money(e.salary, e.salaryPeriod)} · since day ${e.startDay}', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 6),
          Text(PayRules.notice, key: const ValueKey<String>('workplace_notice'), style: TextStyle(color: GG.mute, fontSize: 11.5)),
          const SizedBox(height: 4),
          Row(children: <Widget>[
            Expanded(child: Text('Today is day ${store.day}', style: TextStyle(color: GG.mute))),
            const NextDayButton(),
          ]),
          const SizedBox(height: 12),
          if (w != null)
            SectionCard(
              title: w.name,
              subtitle: w.environment,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Supervisor: ${w.supervisor}, ${w.supervisorRole}', style: TextStyle(color: GG.ink)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String t in w.tools) StatusChip(t, color: GG.mute)]),
                ],
              ),
            ),
          if (store.onboardingLeft(e).isNotEmpty) OnboardingCard(employment: e),
          SectionCard(
            title: 'Performance',
            trailing: const ValidatedBadge(label: 'Supervisor rubric'),
            child: Column(children: <Widget>[
              LabeledBar(label: 'Average supervisor rating', value: e.performance, detail: '${e.evaluated.length} evaluated assignment(s)'),
              LabeledBar(label: 'On-time delivery', value: (e.onTimeRate * 100).round()),
            ]),
          ),
          SectionCard(
            title: 'Current assignment',
            child: open != null
                ? _OpenAssignment(employment: e, record: open)
                : internDone
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('All internship assignments are complete. Request your final evaluation.', style: TextStyle(color: GG.ink)),
                          const SizedBox(height: 8),
                          BusyButton(
                            key: const ValueKey<String>('final_evaluation'),
                            label: 'Request final evaluation',
                            icon: Icons.assignment_turned_in_rounded,
                            onPressed: () async {
                              final List<Criterion>? c = await runCareerAction<List<Criterion>>(context, store.completeInternship);
                              if (c == null || !context.mounted) return;
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext ctx) => _CriteriaDialog(
                                  title: c.every((Criterion x) => x.met) ? 'Final evaluation passed' : 'Internship complete',
                                  criteria: c,
                                  footer: c.every((Criterion x) => x.met)
                                      ? 'A return offer is waiting in your applications.'
                                      : 'Your internship counts as completed experience. No return offer this time.',
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            e.stage == CareerStage.intern && w != null
                                ? 'Internship progress: ${e.evaluated.length}/${w.internshipLength} assignments.'
                                : 'No open assignment.',
                            style: TextStyle(color: GG.ink),
                          ),
                          const SizedBox(height: 8),
                          BusyButton(
                            key: const ValueKey<String>('request_assignment'),
                            label: 'Get next assignment from supervisor',
                            icon: Icons.inbox_rounded,
                            onPressed: () async {
                              await runCareerAction<AssignmentRecord>(context, store.requestAssignment, success: 'New assignment received.');
                            },
                          ),
                        ],
                      ),
          ),
          SectionCard(
            title: 'Company overview',
            subtitle: CareerCatalog.posting(e.postingId)?.company.industry,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(CareerCatalog.posting(e.postingId)?.company.about ?? e.employer, style: TextStyle(color: GG.ink, height: 1.4)),
              const SizedBox(height: 6),
              Text('Team: ${CareerCatalog.posting(e.postingId)?.company.team ?? ''}', style: TextStyle(color: GG.ink, height: 1.4)),
              const SizedBox(height: 6),
              Text('Responsibilities', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              BulletList(CareerCatalog.posting(e.postingId)?.responsibilities ?? const <String>[]),
            ]),
          ),
          SectionCard(
            title: 'Messages',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              for (final CareerEvent m in p.log.reversed.where((CareerEvent x) => x.kind == 'work' || x.kind == 'milestone').take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Day ${m.day} · ${m.text}', style: TextStyle(color: GG.ink, fontSize: 13)),
                ),
              if (!p.log.any((CareerEvent x) => x.kind == 'work')) Text('No messages yet.', style: TextStyle(color: GG.mute)),
            ]),
          ),
          SectionCard(
            title: 'Earnings',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Virtual balance ${usd(p.balanceCents)} · paid ${PayRules.frequencyLabel(e.payFrequency).toLowerCase()} · next paycheck after ${store.weeksToPayday(e)} more approved week(s)',
                  style: TextStyle(color: GG.ink)),
              TextButton(
                key: const ValueKey<String>('workplace_earnings'),
                onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const MoneyScreen())),
                child: const Text('Open My Earnings'),
              ),
            ]),
          ),
          if (e.reviews.isNotEmpty) ReviewCard(review: e.reviews.last),
          if (e.stage != CareerStage.intern)
            SectionCard(
              title: 'Promotion',
              subtitle: 'Promotions are decided by a review against published criteria.',
              child: BusyButton(
                key: const ValueKey<String>('request_promotion'),
                label: 'Request promotion review',
                icon: Icons.trending_up_rounded,
                tonal: true,
                onPressed: () async {
                  final PromotionReview? r = await runCareerAction<PromotionReview>(context, store.requestPromotion);
                  if (r == null || !context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext ctx) => _CriteriaDialog(
                      title: r.approved ? 'Promoted to ${r.to!.label}' : (r.to == null ? 'Promotion review' : 'Not yet: ${r.to!.label}'),
                      criteria: r.criteria,
                      footer: r.message,
                    ),
                  );
                },
              ),
            ),
          if (open != null && w != null)
            SectionCard(
              title: 'Ask your supervisor',
              child: AiAssistPanel(
                role: CareerAiRole.supervisor,
                contextText: 'Workplace: ${w.name}. Assignment: ${store.specOf(e, open)?.title ?? ''}. ${store.specOf(e, open)?.ticket ?? ''}',
                suggestion: 'How should I approach this assignment?',
              ),
            ),
          SectionCard(
            title: 'Evaluations',
            child: e.evaluated.isEmpty
                ? Text('No evaluations yet.', style: TextStyle(color: GG.mute))
                : Column(children: <Widget>[
                    for (final AssignmentRecord a in e.evaluated.reversed)
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(store.specOf(e, a)?.title ?? a.assignmentId),
                        subtitle: Text('${a.evaluation!.rating} · ${a.evaluation!.overall}/100 · day ${a.submittedDay}'),
                        children: <Widget>[EvaluationCard(evaluation: a.evaluation!)],
                      ),
                  ]),
          ),
          EmploymentHistory(employment: p.employment),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const ValueKey<String>('resign'),
            onPressed: () async {
              final bool? yes = await showDialog<bool>(
                context: context,
                builder: (BuildContext ctx) => AlertDialog(
                  title: const Text('Resign?'),
                  content: Text('You will leave ${e.title} at ${e.employer}. This cannot be undone.'),
                  actions: <Widget>[
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    FilledButton(key: const ValueKey<String>('confirm_resign'), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Resign')),
                  ],
                ),
              );
              if (yes == true && context.mounted) {
                await runCareerAction<void>(context, store.resign, success: 'You have resigned.');
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Resign'),
          ),
        ],
      ),
      ),
    );
  }
}

/// The dashboard cards: welcome, salary and tasks; performance gauge; earnings chart.
class WorkplaceOverview extends StatelessWidget {
  const WorkplaceOverview({super.key, required this.employment});
  final Employment employment;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final CareerProfile p = store.profile;
    final Employment e = employment;
    final String first = (p.resume.fullName.isEmpty ? 'there' : p.resume.fullName.split(' ').first);
    final int monthlyCents = (PayRules.annual(e.salary, e.salaryPeriod, hoursPerWeek: e.hoursPerWeek) * 100 / 12).round();
    final List<Paycheck> pay = p.paychecks.where((Paycheck c) => c.employmentId == e.id).toList();
    final AssignmentRecord? open = e.open;
    final AssignmentSpec? spec = open == null ? null : store.specOf(e, open);
    final int perf = e.performance;
    final String rating = perf >= 85 ? 'Excellent' : perf >= 70 ? 'Good' : perf > 0 ? 'Needs work' : 'No reviews yet';
    final Widget welcome = GGPanel(
      color: const Color(0xFFF4F6FF),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          GGAvatar(name: p.resume.fullName.isEmpty ? e.title : p.resume.fullName, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Welcome back, $first!', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
              Text(e.title, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('Current salary', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        Row(children: <Widget>[
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('${usd(monthlyCents)} / month', key: const ValueKey<String>('wp_salary'), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 8),
          if (e.reviews.any((PerformanceReview r) => r.raisePercent > 0) || e.promotions.isNotEmpty) const Icon(Icons.trending_up_rounded, color: GG.green),
        ]),
        const SizedBox(height: 8),
        Text('Your Tasks (${open == null ? 0 : 1})', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        if (spec != null && open != null)
          Row(children: <Widget>[
            const Icon(Icons.radio_button_unchecked, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Expanded(child: Text(spec.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13))),
            Text(store.day >= open.dueDay ? (store.day > open.dueDay ? 'Overdue' : 'Due Today') : 'Due day ${open.dueDay}', style: const TextStyle(color: GG.red, fontSize: 12, fontWeight: FontWeight.w700)),
          ])
        else
          const Text('No open task — ask your manager for the next one.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
      ]),
    );
    final Widget gauge = GGPanel(
      color: const Color(0xFFF4F6FF),
      child: Column(children: <Widget>[
        const Text('Performance Rating', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        GGGauge(value: perf, size: 120, textColor: const Color(0xFF0F172A)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
          child: Text(rating, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        ),
      ]),
    );
    final Widget earnings = GGPanel(
      color: const Color(0xFFF4F6FF),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('Recent Earnings', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(pay.isEmpty ? usd(0) : usd(pay.last.grossCents), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 26, fontWeight: FontWeight.w900)),
        Text(pay.isEmpty ? '(no paycheck yet)' : '(last paycheck, gross)', style: const TextStyle(color: Color(0xFF475569), fontSize: 12)),
        const SizedBox(height: 8),
        GGBars(values: <double>[for (final Paycheck c in pay) c.grossCents.toDouble()], height: 70),
      ]),
    );
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      if (c.maxWidth < 700) return Column(children: <Widget>[welcome, const SizedBox(height: 10), Row(children: <Widget>[Expanded(child: gauge), const SizedBox(width: 10), Expanded(child: earnings)])]);
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[Expanded(flex: 5, child: welcome), const SizedBox(width: 12), Expanded(flex: 3, child: gauge), const SizedBox(width: 12), Expanded(flex: 3, child: earnings)]),
      );
    });
  }
}

/// Tasks, Team, Meetings, Performance and Messages views of the workplace.
class WorkplaceSection extends StatelessWidget {
  const WorkplaceSection({super.key, required this.section, required this.employment});
  final int section;
  final Employment employment;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Employment e = employment;
    final WorkplaceDef? w = store.workplaceOf(e);
    final JobPosting? job = CareerCatalog.posting(e.postingId);
    final List<Widget> body = switch (section) {
      1 => <Widget>[
          SectionCard(
            title: 'Open task',
            child: e.open == null
                ? const Text('No open task. Get the next one from the Dashboard.', style: TextStyle(color: GG.mute))
                : _OpenAssignment(employment: e, record: e.open!),
          ),
          SectionCard(
            title: 'Completed work',
            child: Column(children: <Widget>[
              if (e.evaluated.isEmpty) const Text('Nothing evaluated yet.', style: TextStyle(color: GG.mute)),
              for (final AssignmentRecord a in e.evaluated.reversed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_rounded, color: GG.green),
                  title: Text(store.specOf(e, a)?.title ?? a.assignmentId),
                  subtitle: Text('${a.evaluation!.rating} · ${a.evaluation!.overall}/100 · day ${a.submittedDay}'),
                ),
            ]),
          ),
        ],
      2 => <Widget>[
          SectionCard(
            title: w?.name ?? e.employer,
            subtitle: job?.company.industry,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              ListTile(contentPadding: EdgeInsets.zero, leading: GGAvatar(name: w?.supervisor ?? 'Manager'), title: Text(w?.supervisor ?? 'Manager'), subtitle: Text('${w?.supervisorRole ?? 'Manager'} · your manager')),
              Text(job?.company.team ?? '', style: const TextStyle(color: GG.ink, height: 1.4)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String t in w?.tools ?? const <String>[]) StatusChip(t, color: GG.mute)]),
            ]),
          ),
        ],
      3 => <Widget>[
          SectionCard(
            title: 'Meetings',
            child: Column(children: <Widget>[
              const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.groups_rounded), title: Text('Daily stand-up'), subtitle: Text('Share what you did, what is next and any blockers.')),
              ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_rounded), title: Text('Weekly 1:1 with ${w?.supervisor ?? 'your manager'}'), subtitle: const Text('Feedback on your last assignment and goals.')),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.grading_rounded),
                title: const Text('Performance review'),
                subtitle: Text('After ${CareerSimStore.reviewEvery - e.evaluated.length % CareerSimStore.reviewEvery} more evaluated assignment(s).'),
              ),
            ]),
          ),
        ],
      4 => <Widget>[
          SectionCard(
            title: 'Performance',
            child: Column(children: <Widget>[
              LabeledBar(label: 'Average supervisor rating', value: e.performance),
              LabeledBar(label: 'On-time delivery', value: (e.onTimeRate * 100).round()),
            ]),
          ),
          for (final PerformanceReview r in e.reviews.reversed) ReviewCard(review: r),
        ],
      _ => <Widget>[
          SectionCard(
            title: 'Messages',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              for (final CareerEvent m in store.profile.log.reversed.where((CareerEvent x) => x.kind == 'work' || x.kind == 'milestone').take(30))
                ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.mail_outline_rounded, size: 18), title: Text(m.text), subtitle: Text('Day ${m.day}')),
            ]),
          ),
        ],
    };
    return DecoratedBox(decoration: const BoxDecoration(gradient: GG.page), child: ListView(padding: const EdgeInsets.all(16), children: body));
  }
}

class _CriteriaDialog extends StatelessWidget {
  const _CriteriaDialog({required this.title, required this.criteria, this.footer = ''});
  final String title;
  final List<Criterion> criteria;
  final String footer;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final Criterion c in criteria)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: <Widget>[
                    Icon(c.met ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: c.met ? GG.green : GG.red),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${c.label}${c.detail.isEmpty ? '' : ' — ${c.detail}'}')),
                  ]),
                ),
              if (footer.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(footer)),
            ],
          ),
        ),
        actions: <Widget>[TextButton(key: const ValueKey<String>('dialog_ok'), onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      );
}

class _OpenAssignment extends StatelessWidget {
  const _OpenAssignment({required this.employment, required this.record});
  final Employment employment;
  final AssignmentRecord record;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final AssignmentSpec? s = store.specOf(employment, record);
    if (s == null) return const Text('Assignment not found.');
    final bool overdue = store.day > record.dueDay;
    return ListTile(
      key: const ValueKey<String>('open_assignment'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.assignment_rounded, color: overdue ? GG.red : null),
      title: Text(s.title),
      subtitle: Text('${const <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][record.issuedDay % 5]} (day ${record.issuedDay}) · due day ${record.dueDay}${overdue ? ' · OVERDUE' : ''}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(ggRoute<void>((_) => const AssignmentScreen())),
    );
  }
}

/// The open assignment: ticket, the task, a handoff note, and submission.
class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  TaskResult? _result;
  SupervisorEvaluation? _evaluation;
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Employment? e = store.profile.currentJob;
    final SupervisorEvaluation? ev = _evaluation;
    if (ev != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supervisor evaluation')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            EvaluationCard(evaluation: ev),
            const SizedBox(height: 8),
            Text('Approved: 1 work week (${e?.hoursPerWeek ?? 40} hours).', style: TextStyle(color: GG.ink)),
            if (e != null && store.profile.paychecks.isNotEmpty && store.profile.paychecks.last.employmentId == e.id && store.profile.paychecks.last.day == store.day)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Paycheck ${store.profile.paychecks.last.period} processed: gross ${usd(store.profile.paychecks.last.grossCents)}, '
                  'simulated deductions ${usd(store.profile.paychecks.last.deductionCents)}, net ${usd(store.profile.paychecks.last.netCents)} (virtual).',
                  key: const ValueKey<String>('pay_salary'),
                  style: TextStyle(color: GG.green, fontWeight: FontWeight.w700),
                ),
              )
            else if (e != null)
              Text('Next paycheck after ${store.weeksToPayday(e)} more approved week(s).', key: const ValueKey<String>('pay_pending'), style: TextStyle(color: GG.mute)),
            if (e != null && e.reviews.isNotEmpty && e.reviews.last.day == store.day) ReviewCard(review: e.reviews.last),
            const SizedBox(height: 12),
            FilledButton(key: const ValueKey<String>('back_to_work'), onPressed: () => Navigator.of(context).pop(), child: const Text('Back to the workplace')),
          ],
        ),
      );
    }
    final AssignmentRecord? r = e?.open;
    final AssignmentSpec? s = e == null || r == null ? null : store.specOf(e, r);
    if (e == null || r == null || s == null) {
      return Scaffold(appBar: AppBar(title: const Text('Assignment')), body: const Center(child: Text('No open assignment.')));
    }
    final WorkplaceDef? w = store.workplaceOf(e);
    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          SectionCard(
            title: 'Ticket from ${w?.supervisor ?? 'your supervisor'}',
            subtitle: 'Due day ${r.dueDay}${store.day > r.dueDay ? ' — overdue' : ''}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.ticket, style: TextStyle(color: GG.ink, height: 1.4)),
                const SizedBox(height: 8),
                Text('Acceptance criteria', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                BulletList(s.acceptance, icon: Icons.check_box_outline_blank_rounded),
              ],
            ),
          ),
          SectionCard(
            title: 'The work',
            subtitle: 'Non-code work has one graded attempt. Code can be resubmitted to the judge; the last result counts.',
            child: TaskView(
              spec: s.task,
              allowRetry: false,
              onGraded: (TaskResult res) async => setState(() => _result = res),
            ),
          ),
          SectionCard(
            title: 'Handoff note',
            subtitle: 'What you did, how you checked it, and any risks or follow-ups. Your supervisor scores this for communication.',
            child: WrittenField(
              fieldKey: const ValueKey<String>('handoff_note'),
              controller: _note,
              rubric: CareerRules.handoffRubric,
              minWords: 15,
              label: 'Handoff note',
            ),
          ),
          BusyButton(
            key: const ValueKey<String>('submit_assignment'),
            label: 'Submit to supervisor',
            icon: Icons.send_rounded,
            onPressed: _result == null
                ? null
                : () async {
                    final SupervisorEvaluation? out =
                        await runCareerAction<SupervisorEvaluation>(context, () => store.submitAssignment(_result!, _note.text));
                    if (out != null && mounted) setState(() => _evaluation = out);
                  },
          ),
          if (_result == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Complete and grade the work first.', style: TextStyle(color: GG.mute, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class EvaluationCard extends StatelessWidget {
  const EvaluationCard({super.key, required this.evaluation});
  final SupervisorEvaluation evaluation;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey<String>('evaluation_card'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text(evaluation.rating, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w900, fontSize: 16))),
              const ValidatedBadge(label: 'Rubric score'),
            ]),
            const SizedBox(height: 8),
            LabeledBar(label: 'Quality (60%)', value: evaluation.quality),
            LabeledBar(label: 'Timeliness (20%)', value: evaluation.timeliness),
            LabeledBar(label: 'Communication (20%)', value: evaluation.communication),
            LabeledBar(label: 'Overall', value: evaluation.overall),
            BulletList(evaluation.comments),
          ],
        ),
      );
}

class EmploymentHistory extends StatelessWidget {
  const EmploymentHistory({super.key, required this.employment});
  final List<Employment> employment;

  @override
  Widget build(BuildContext context) => SectionCard(
        title: 'Employment history',
        child: employment.isEmpty
            ? Text('No employment yet.', style: TextStyle(color: GG.mute))
            : Column(children: <Widget>[
                for (final Employment e in employment.reversed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(e.active ? Icons.work_rounded : Icons.work_history_rounded),
                    title: Text('${e.title} · ${e.employer}'),
                    subtitle: Text('Day ${e.startDay}${e.active ? ' – present' : ' – ${e.endDay} (${e.endReason})'} · '
                        '${CareerCatalog.department(e.deptId)?.title ?? ''} · performance ${e.performance}'
                        '${e.promotions.isEmpty ? '' : ' · ${e.promotions.length} promotion(s)'}'
                        '${e.finalReview == null ? '' : '\n${e.finalReview}'}'),
                  ),
              ]),
      );
}
