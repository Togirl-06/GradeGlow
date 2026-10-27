import 'package:flutter/material.dart';

import '../../education/skills.dart';
import '../../employment/application.dart';
import '../../employment/employers.dart';
import '../../game/life_game.dart';
import '../../services/life_ai_service.dart';
import '../../workplace/job_state.dart';
import '../../workplace/work_task.dart';
import '../../world/interiors.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import 'job_screens.dart';

String stationName(String stationId) {
  for (final List<StationDef> list in kStations.values) {
    for (final StationDef s in list) {
      if (s.id == stationId) return '${s.emoji} ${s.name}';
    }
  }
  return stationId;
}

// ---------------------------------------------------------------------------
// Station: pick today's task assigned to this station
// ---------------------------------------------------------------------------

class WorkStationScreen extends StatelessWidget {
  const WorkStationScreen({super.key, required this.life, required this.stationId});
  final LifeSession life;
  final String stationId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeGame g = life.game;
          final JobRecord? j = g.job;
          final List<WorkScenario> all = g.todaysTasks();
          final List<WorkScenario> here = all.where((WorkScenario s) => s.station == stationId).toList();
          return LifePage(
            title: stationName(stationId),
            subtitle: j == null ? 'You do not work here' : '${j.contract.title} · ${j.employer.name}',
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              if (j == null)
                const Panel(child: Text('You need a job to use this station. Visit the Employment Centre to find one.'))
              else if (!j.checkedIn)
                const Panel(child: Text('Clock in at Reception first — your manager will hand out today\'s tasks.'))
              else if (here.isEmpty)
                Panel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    const Text('Nothing assigned here today.', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    if (all.isEmpty) const Text('You have no tasks today.') else ...<Widget>[
                      const Text('Today\'s tasks are at:'),
                      for (final WorkScenario s in all) Text('• ${stationName(s.station)} — ${s.title}${j.doneScores.containsKey(s.id) ? ' ✅' : ''}'),
                    ],
                  ]),
                )
              else
                for (final WorkScenario s in here)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Panel(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(child: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
                          if (j.doneScores.containsKey(s.id)) Tag('Done ${(j.doneScores[s.id]! * 100).round()}%', color: LifeColors.green) else Tag('${s.minutes} min', color: LifeColors.blue),
                        ]),
                        const SizedBox(height: 6),
                        Text('${s.assignedBy}: "${s.brief}"', style: const TextStyle(fontStyle: FontStyle.italic, color: LifeColors.muted)),
                        const SizedBox(height: 10),
                        BigButton(
                          label: j.doneScores.containsKey(s.id) ? 'Completed' : 'Start task',
                          icon: Icons.play_arrow_rounded,
                          onPressed: g.taskBlock(s) != null
                              ? null
                              : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ScenarioPlayer(life: life, scenario: s))),
                        ),
                        if (g.taskBlock(s) != null && !j.doneScores.containsKey(s.id)) Padding(padding: const EdgeInsets.only(top: 6), child: Text(g.taskBlock(s)!, style: const TextStyle(color: LifeColors.amber, fontSize: 12))),
                      ]),
                    ),
                  ),
            ]),
          );
        },
      );
}

// ---------------------------------------------------------------------------
// Scenario player: renders every stage kind
// ---------------------------------------------------------------------------

class ScenarioPlayer extends StatefulWidget {
  const ScenarioPlayer({super.key, required this.life, required this.scenario});
  final LifeSession life;
  final WorkScenario scenario;
  @override
  State<ScenarioPlayer> createState() => _ScenarioPlayerState();
}

class _ScenarioPlayerState extends State<ScenarioPlayer> {
  late final ScenarioRun _run = ScenarioRun(widget.scenario, judge: AiWorkTextJudge());
  StageResult? _last;
  TaskOutcome? _outcome;
  bool _busy = false;

  int? _choice;
  final Set<int> _multi = <int>{};
  List<int> _order = <int>[];
  final TextEditingController _num = TextEditingController();
  final TextEditingController _text = TextEditingController();
  final Set<String> _inspected = <String>{};

  @override
  void dispose() {
    _num.dispose();
    _text.dispose();
    super.dispose();
  }

  void _resetInputs(WorkStage? s) {
    _choice = null;
    _multi.clear();
    _num.clear();
    _text.clear();
    _inspected.clear();
    _order = s == null ? <int>[] : List<int>.generate(s.options.length, (int i) => i);
  }

  @override
  void initState() {
    super.initState();
    _resetInputs(_run.stage);
  }

  bool get _canSubmit {
    final WorkStage? s = _run.stage;
    if (s == null || _busy) return false;
    switch (s.kind) {
      case StageKind.choice:
        return _choice != null;
      case StageKind.multi:
        return _multi.isNotEmpty;
      case StageKind.order:
        return true;
      case StageKind.numeric:
        return double.tryParse(_num.text.replaceAll(',', '').trim()) != null;
      case StageKind.text:
        return _text.text.trim().isNotEmpty;
      case StageKind.inspect:
        return true;
    }
  }

  Future<void> _submit() async {
    final WorkStage s = _run.stage!;
    setState(() => _busy = true);
    final StageAnswer a = StageAnswer(
      choice: _choice,
      multi: Set<int>.of(_multi),
      order: List<int>.of(_order),
      number: double.tryParse(_num.text.replaceAll(',', '').trim()),
      text: _text.text,
      inspected: Set<String>.of(_inspected),
    );
    final StageResult r = await _run.submit(a);
    if (!mounted) return;
    setState(() {
      _last = r;
      _busy = false;
    });
    if (_run.finished) {
      final TaskOutcome? o = widget.life.game.completeTask(widget.scenario, _run.score);
      widget.life.changed();
      setState(() => _outcome = o);
    }
    if (s.kind == StageKind.text && _run.finished) {}
  }

  void _next() {
    setState(() {
      _last = null;
      _resetInputs(_run.stage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final WorkScenario sc = widget.scenario;
    return LifePage(
      title: sc.title,
      subtitle: stationName(sc.station),
      child: _run.finished && _last == null ? _summary(sc) : ListView(padding: const EdgeInsets.all(14), children: _body(sc)),
    );
  }

  List<Widget> _body(WorkScenario sc) {
    final WorkStage? s = _run.stage;
    final StageResult? r = _last;
    if (r != null) {
      final int idx = _run.results.length - 1;
      final WorkStage done = sc.stages[idx];
      return <Widget>[
        Panel(
          border: r.score >= 0.75 ? LifeColors.green : (r.score >= 0.4 ? LifeColors.amber : LifeColors.red),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(r.score >= 0.75 ? 'Well done' : (r.score >= 0.4 ? 'Partly right' : 'Not quite'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 4),
            Text('${(r.score * 100).round()}%', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(r.feedback, style: const TextStyle(height: 1.4)),
            for (final String d in r.details) Padding(padding: const EdgeInsets.only(top: 4), child: Text('• $d', style: const TextStyle(fontSize: 13))),
            if (done.explanation.isNotEmpty) ...<Widget>[const Divider(height: 22), Text(done.explanation, style: const TextStyle(height: 1.4, color: LifeColors.muted))],
          ]),
        ),
        const SizedBox(height: 14),
        BigButton(label: _run.finished ? 'See results' : 'Next', icon: Icons.arrow_forward_rounded, onPressed: _run.finished ? () => setState(() => _last = null) : _next),
      ];
    }
    if (s == null) return <Widget>[];
    return <Widget>[
      if (_run.index == 0)
        Panel(
          color: LifeColors.panel,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('${sc.assignedBy} says:', style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(sc.brief, style: const TextStyle(fontSize: 15, height: 1.4)),
            if (sc.educationalNote != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('ℹ️ ${sc.educationalNote}', style: const TextStyle(fontSize: 12, color: LifeColors.amber))),
          ]),
        ),
      const SizedBox(height: 10),
      Text('Step ${_run.index + 1} of ${sc.stages.length}', style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w800, fontSize: 12)),
      const SizedBox(height: 6),
      if (s.speaker != null) Text(s.speaker!, style: const TextStyle(color: LifeColors.muted, fontStyle: FontStyle.italic)),
      Text(s.prompt, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.35)),
      if (s.code != null) ...<Widget>[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF020617), borderRadius: BorderRadius.circular(12), border: Border.all(color: LifeColors.line)),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(s.code!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.4, color: Color(0xFFA7F3D0)))),
        ),
      ],
      if (s.table != null) ...<Widget>[const SizedBox(height: 10), _table(s.table!)],
      if (s.hint != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('💡 ${s.hint}', style: const TextStyle(color: LifeColors.amber, fontSize: 13))),
      const SizedBox(height: 12),
      ..._input(s),
      const SizedBox(height: 16),
      BigButton(label: _busy ? 'Marking…' : 'Submit', icon: Icons.check_rounded, onPressed: _canSubmit ? _submit : null),
      const SizedBox(height: 20),
    ];
  }

  Widget _table(List<List<String>> rows) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: LifeColors.line),
          children: <TableRow>[
            for (int i = 0; i < rows.length; i++)
              TableRow(
                decoration: BoxDecoration(color: i == 0 ? LifeColors.panel : null),
                children: <Widget>[for (final String c in rows[i]) Padding(padding: const EdgeInsets.all(8), child: Text(c, style: TextStyle(fontWeight: i == 0 ? FontWeight.w900 : FontWeight.w600, fontSize: 13)))],
              ),
          ],
        ),
      );

  List<Widget> _input(WorkStage s) {
    switch (s.kind) {
      case StageKind.choice:
        return <Widget>[
          for (int i = 0; i < s.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                color: _choice == i ? LifeColors.blue.withValues(alpha: 0.25) : null,
                border: _choice == i ? LifeColors.blue : null,
                onTap: () => setState(() => _choice = i),
                child: Row(children: <Widget>[
                  Icon(_choice == i ? Icons.radio_button_checked : Icons.radio_button_off, color: LifeColors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.options[i])),
                ]),
              ),
            ),
        ];
      case StageKind.multi:
        return <Widget>[
          const Text('Select all that apply', style: TextStyle(color: LifeColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          for (int i = 0; i < s.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                color: _multi.contains(i) ? LifeColors.blue.withValues(alpha: 0.25) : null,
                border: _multi.contains(i) ? LifeColors.blue : null,
                onTap: () => setState(() => _multi.contains(i) ? _multi.remove(i) : _multi.add(i)),
                child: Row(children: <Widget>[
                  Icon(_multi.contains(i) ? Icons.check_box : Icons.check_box_outline_blank, color: LifeColors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.options[i])),
                ]),
              ),
            ),
        ];
      case StageKind.order:
        return <Widget>[
          const Text('Drag to put the steps in the correct order', style: TextStyle(color: LifeColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorderItem: (int a, int b) => setState(() {
              final int v = _order.removeAt(a);
              _order.insert(b, v);
            }),
            children: <Widget>[
              for (int k = 0; k < _order.length; k++)
                Padding(
                  key: ValueKey<int>(_order[k]),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Panel(child: Row(children: <Widget>[
                    CircleAvatar(radius: 13, backgroundColor: LifeColors.blue, child: Text('${k + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.options[_order[k]])),
                    const Icon(Icons.drag_handle_rounded, color: LifeColors.muted),
                  ])),
                ),
            ],
          ),
        ];
      case StageKind.numeric:
        return <Widget>[
          TextField(
            controller: _num,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(hintText: 'Your answer', suffixText: s.unit),
            onChanged: (_) => setState(() {}),
          ),
        ];
      case StageKind.text:
        return <Widget>[
          TextField(controller: _text, minLines: 4, maxLines: 10, decoration: InputDecoration(hintText: 'Write your answer (at least ${s.minWords} words)…'), onChanged: (_) => setState(() {})),
        ];
      case StageKind.inspect:
        return <Widget>[
          const Text('Tap to check items. Only gather what you really need.', style: TextStyle(color: LifeColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          for (final InspectItem it in s.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                color: _inspected.contains(it.id) ? LifeColors.teal.withValues(alpha: 0.2) : null,
                border: _inspected.contains(it.id) ? LifeColors.teal : null,
                onTap: () => setState(() => _inspected.contains(it.id) ? _inspected.remove(it.id) : _inspected.add(it.id)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(children: <Widget>[
                    Icon(_inspected.contains(it.id) ? Icons.visibility : Icons.visibility_off_outlined, color: LifeColors.teal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(it.label, style: const TextStyle(fontWeight: FontWeight.w800))),
                    Text('${it.minutes} min', style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
                  ]),
                  if (_inspected.contains(it.id)) Padding(padding: const EdgeInsets.only(top: 6), child: Text(it.reveal, style: const TextStyle(fontSize: 13, height: 1.35))),
                ]),
              ),
            ),
        ];
    }
  }

  Widget _summary(WorkScenario sc) {
    final TaskOutcome? o = _outcome;
    final double score = _run.score;
    return ListView(padding: const EdgeInsets.all(16), children: <Widget>[
      Panel(
        border: score >= 0.75 ? LifeColors.green : (score >= 0.4 ? LifeColors.amber : LifeColors.red),
        child: Column(children: <Widget>[
          Text(o?.rating ?? _run.ratingLabel, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text('${(score * 100).round()}%', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
          if (o != null) Text('Performance rating ${o.performanceDelta >= 0 ? '+' : ''}${o.performanceDelta.toStringAsFixed(1)}', style: const TextStyle(color: LifeColors.muted)),
          if (o != null && o.skillGains.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: <Widget>[for (final MapEntry<String, double> e in o.skillGains.entries) Tag('${Skills.nameOf(e.key)} +${e.value.toStringAsFixed(1)}', color: LifeColors.green)]),
          ],
        ]),
      ),
      const SectionTitle('Stage results'),
      for (int i = 0; i < _run.results.length; i++)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Panel(child: Row(children: <Widget>[Expanded(child: Text(sc.stages[i].prompt, maxLines: 2, overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), Text('${(_run.results[i].score * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900))]))),
      if (sc.educationalNote != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('ℹ️ ${sc.educationalNote}', style: const TextStyle(color: LifeColors.amber, fontSize: 12))),
      const SizedBox(height: 14),
      BigButton(label: 'Back to work', icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop()),
    ]);
  }
}

// ---------------------------------------------------------------------------
// HR desk: career status, promotion, sick leave, resign, interviews/offers
// ---------------------------------------------------------------------------

class HrDeskScreen extends StatelessWidget {
  const HrDeskScreen({super.key, required this.life, required this.employerId});
  final LifeSession life;
  final String employerId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeGame g = life.game;
          final Employer e = EmployerCatalog.require(employerId);
          final JobRecord? j = g.job;
          final bool mine = j != null && j.contract.employerId == employerId;
          final List<ApplicationRecord> here = g.applications.where((ApplicationRecord a) => a.listing?.employerId == employerId && (a.status == ApplicationStatus.invited || a.status == ApplicationStatus.offer || a.status == ApplicationStatus.waitlisted)).toList();
          return LifePage(
            title: '${e.name} · HR',
            subtitle: '${e.interviewer.name}, ${e.interviewer.title}',
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              if (mine) ..._myJob(context, g, j) else Panel(child: Text(j == null ? 'You are not employed. Apply for openings at ${e.name} through the job board.' : 'You work for ${j.employer.name}.')),
              if (here.isNotEmpty) ...<Widget>[
                const SectionTitle('Your applications here'),
                for (final ApplicationRecord a in here) Padding(padding: const EdgeInsets.only(bottom: 8), child: Panel(child: _appRow(context, a))),
              ],
              const SizedBox(height: 14),
              BigButton(label: 'Open job board', icon: Icons.work_rounded, color: LifeColors.purple, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => JobBoardScreen(life: life)))),
              const SizedBox(height: 8),
              BigButton(label: 'My applications', icon: Icons.assignment_rounded, color: LifeColors.teal, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationsScreen(life: life)))),
            ]),
          );
        },
      );

  Widget _appRow(BuildContext context, ApplicationRecord a) => Row(children: <Widget>[
        Expanded(child: Text('${a.listing!.title} — ${statusLabel(a.status)}', style: const TextStyle(fontWeight: FontWeight.w800))),
        TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ApplicationsScreen(life: life))), child: const Text('Open')),
      ]);

  List<Widget> _myJob(BuildContext context, LifeGame g, JobRecord j) {
    final PromotionStatus? ps = g.promotionStatus();
    return <Widget>[
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(j.contract.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          Text('${money(j.contract.monthlySalary)} / month · ${j.career.title}', style: const TextStyle(color: LifeColors.muted)),
          const SizedBox(height: 8),
          NeedBar(label: 'Performance', value: j.performance, emoji: '📈'),
          Text('Workdays at this rank: ${j.workdaysAtRank.toStringAsFixed(1)} · Total ${j.totalWorkdays.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12.5)),
          if (j.strikeDays.isNotEmpty) Text('⚠️ Absence strikes: ${j.strikeDays.length}/${JobEngine.strikesToFire}', style: const TextStyle(color: LifeColors.amber)),
          if (j.onNotice) Text('🚨 Your role ends on Day ${j.noticeEndDay}. Start applying elsewhere!', style: const TextStyle(color: LifeColors.red, fontWeight: FontWeight.w800)),
          if (j.inProbation) const Text('You are still in your probation period.', style: TextStyle(color: LifeColors.muted, fontSize: 12.5)),
        ]),
      ),
      const SectionTitle('Promotion'),
      Panel(
        child: ps == null
            ? const SizedBox.shrink()
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                if (ps.eligible) ...<Widget>[
                  Text('You qualify for ${ps.nextTitle}!', style: const TextStyle(color: LifeColors.green, fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('New salary: ${money(ps.newSalary ?? 0)} / month'),
                  const SizedBox(height: 8),
                  BigButton(label: 'Request promotion', icon: Icons.trending_up_rounded, color: LifeColors.green, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PromotionScreen(life: life, status: ps)))),
                ] else ...<Widget>[
                  const Text('Still to do:', style: TextStyle(fontWeight: FontWeight.w900)),
                  for (final String u in ps.unmet) Padding(padding: const EdgeInsets.only(top: 3), child: Text('• $u', style: const TextStyle(fontSize: 13))),
                ],
              ]),
      ),
      const SectionTitle('Other'),
      Row(children: <Widget>[
        Expanded(child: BigButton(label: 'Call in sick', icon: Icons.sick_rounded, color: LifeColors.amber, onPressed: () => life.report(g.callInSick()))),
        const SizedBox(width: 8),
        Expanded(
          child: BigButton(
            label: 'Resign',
            icon: Icons.logout_rounded,
            color: LifeColors.red,
            onPressed: () async {
              final bool? ok = await showDialog<bool>(
                context: context,
                builder: (BuildContext c) => AlertDialog(
                  title: const Text('Resign?'),
                  content: const Text('You will leave this job immediately. You can apply for other jobs afterwards.'),
                  actions: <Widget>[TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Resign'))],
                ),
              );
              if (ok == true) life.report(g.resign());
            },
          ),
        ),
      ]),
    ];
  }
}

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key, required this.life, required this.status});
  final LifeSession life;
  final PromotionStatus status;
  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  double _ask = 5;
  final TextEditingController _pitch = TextEditingController();
  String? _msg;
  double? _final;
  double? _counter;
  bool _tried = false;

  @override
  void dispose() {
    _pitch.dispose();
    super.dispose();
  }

  Future<void> _negotiate() async {
    final LifeSession life = widget.life;
    final String t = _pitch.text.trim();
    final WorkScenario dummy = WorkScenario(id: 'raise', careerId: '', title: 'Raise', station: 'hr', brief: '', assignedBy: 'HR', stages: <WorkStage>[SalaryNegotiation.pitchStage]);
    final StageResult pr = t.isEmpty ? const StageResult(score: 0, feedback: 'No pitch given.') : await AiWorkTextJudge().gradeText(scenario: dummy, stage: SalaryNegotiation.pitchStage, text: t);
    final NegotiationOutcome o = life.game.negotiate(offer: widget.status.newSalary ?? 0, askPercent: _ask, pitchScore: pr.score, isNewOffer: false);
    setState(() {
      _tried = true;
      _msg = '${o.message}\n\nPitch: ${(pr.score * 100).round()}% — ${pr.feedback}';
      if (o.accepted) {
        _final = o.finalSalary;
      } else if (o.counter != null) {
        _counter = o.counter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LifeSession life = widget.life;
    final double base = widget.status.newSalary ?? 0;
    return LifePage(
      title: 'Promotion to ${widget.status.nextTitle}',
      child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
        Panel(border: LifeColors.green, child: Column(children: <Widget>[
          const Text('🎉 You earned this promotion', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text('${money(_final ?? base)} / month', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: LifeColors.green)),
        ])),
        const SectionTitle('Negotiate your new salary (optional, one attempt)'),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Ask for +${_ask.round()}% → ${money(base * (1 + _ask / 100))}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(value: _ask, min: 0, max: 25, divisions: 25, onChanged: _tried ? null : (double v) => setState(() => _ask = v)),
          TextField(controller: _pitch, enabled: !_tried, minLines: 3, maxLines: 6, decoration: const InputDecoration(hintText: 'Cite your results, market rates, and thank them…')),
          const SizedBox(height: 10),
          BigButton(label: 'Make your case', icon: Icons.handshake_rounded, color: LifeColors.amber, onPressed: _tried ? null : _negotiate),
          if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_msg!)),
          if (_counter != null && _final == null) Row(children: <Widget>[
            Expanded(child: BigButton(label: 'Accept ${money(_counter!)}', onPressed: () => setState(() {
                  _final = _counter;
                  _counter = null;
                }))),
            const SizedBox(width: 8),
            Expanded(child: BigButton(label: 'Keep ${money(base)}', color: LifeColors.panel2, onPressed: () => setState(() => _counter = null))),
          ]),
        ])),
        const SizedBox(height: 14),
        BigButton(
          label: 'Accept promotion',
          icon: Icons.check_rounded,
          color: LifeColors.green,
          onPressed: () {
            life.report(life.game.promote(salary: _final));
            Navigator.of(context).pop();
          },
        ),
      ]),
    );
  }
}
