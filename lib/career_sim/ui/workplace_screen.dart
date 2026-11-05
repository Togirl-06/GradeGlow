import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../vu_v2/design/vu_v2_theme.dart';
import '../ai/career_ai.dart';
import '../content/catalog.dart';
import '../engine/career_rules.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'job_screens.dart';
import 'task_views.dart';

class WorkplaceScreen extends StatelessWidget {
  const WorkplaceScreen({super.key});

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
            Text('You are not employed right now. Apply through the Career Centre.', style: TextStyle(color: VuV2Colors.ink)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JobBoardScreen())),
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
      appBar: AppBar(title: Text(e.employer)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(e.title, style: TextStyle(color: VuV2Colors.ink, fontSize: 22, fontWeight: FontWeight.w900)),
          Text('${e.stage.label} · ${money(e.salary, e.salaryPeriod)} · since day ${e.startDay}', style: TextStyle(color: VuV2Colors.mute)),
          const SizedBox(height: 4),
          Row(children: <Widget>[
            Expanded(child: Text('Today is day ${store.day}', style: TextStyle(color: VuV2Colors.mute))),
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
                  Text('Supervisor: ${w.supervisor}, ${w.supervisorRole}', style: TextStyle(color: VuV2Colors.ink)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final String t in w.tools) StatusChip(t, color: VuV2Colors.mute)]),
                ],
              ),
            ),
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
                          Text('All internship assignments are complete. Request your final evaluation.', style: TextStyle(color: VuV2Colors.ink)),
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
                            style: TextStyle(color: VuV2Colors.ink),
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
                ? Text('No evaluations yet.', style: TextStyle(color: VuV2Colors.mute))
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
    );
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
                    Icon(c.met ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: c.met ? VuV2Colors.success : VuV2Colors.danger),
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
      leading: Icon(Icons.assignment_rounded, color: overdue ? VuV2Colors.danger : null),
      title: Text(s.title),
      subtitle: Text('Issued day ${record.issuedDay} · due day ${record.dueDay}${overdue ? ' · OVERDUE' : ''}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AssignmentScreen())),
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
                Text(s.ticket, style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
                const SizedBox(height: 8),
                Text('Acceptance criteria', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
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
              child: Text('Complete and grade the work first.', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
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
        decoration: BoxDecoration(border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text(evaluation.rating, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w900, fontSize: 16))),
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
            ? Text('No employment yet.', style: TextStyle(color: VuV2Colors.mute))
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
