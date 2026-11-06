/// Views for the shared professional work tasks.
library;

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../model/career_models.dart';
import '../../ui/common.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import '../math/expr.dart';
import '../math/math_steps.dart';
import '../math/math_views.dart';
import '../ui/step_views.dart';
import 'work_steps.dart';
import '../../ui/gg_kit.dart';

Map<String, TextEditingController> _controllers(List<MathQuestion> qs) => <String, TextEditingController>{for (final MathQuestion q in qs) q.id: TextEditingController()};

// ------------------------------------------------------------ triage

class TriageView extends StatefulWidget {
  const TriageView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final TriageStep step;
  final StepGraded onGraded;
  @override
  State<TriageView> createState() => _TriageViewState();
}

class _TriageViewState extends State<TriageView> {
  final Map<String, Map<String, String>> _d = <String, Map<String, String>>{};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final String? raw = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id];
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((String k, dynamic v) => _d[k] = <String, String>{for (final MapEntry<String, dynamic> e in (v as Map<String, dynamic>).entries) e.key: '${e.value}'});
    } on FormatException {
      _d.clear();
    }
  }

  void _set(String item, String field, String v) {
    setState(() => (_d[item] ??= <String, String>{})[field] = v);
    careerStore(context).saveLabDraft(widget.lab, widget.step.id, jsonEncode(_d));
  }

  @override
  Widget build(BuildContext context) {
    final TriageStep s = widget.step;
    final int decided = s.items.where((TriageItem i) => s.fields.every((TriageField f) => i.answers[f.id] == null || _d[i.id]?[f.id] != null)).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Text('${s.queueName}: $decided of ${s.items.length} handled', style: TextStyle(color: GG.mute, fontSize: 12)),
      for (final TriageItem it in s.items)
        Card(
          key: ValueKey<String>('item_${it.id}'),
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(it.title, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
              if (it.meta.isNotEmpty)
                Wrap(spacing: 6, runSpacing: 4, children: <Widget>[for (final MapEntry<String, String> m in it.meta.entries) StatusChip('${m.key}: ${m.value}', color: GG.mute)]),
              const SizedBox(height: 4),
              Text(it.body, style: TextStyle(color: GG.ink, height: 1.35)),
              const SizedBox(height: 6),
              for (final TriageField f in s.fields)
                if (it.answers[f.id] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(f.label, style: TextStyle(color: GG.mute, fontSize: 12)),
                      Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
                        for (final String o in f.options)
                          ChoiceChip(
                            key: ValueKey<String>('tri_${it.id}_${f.id}_$o'),
                            label: Text(o),
                            selected: _d[it.id]?[f.id] == o,
                            onSelected: (_) => _set(it.id, f.id, o),
                          ),
                      ]),
                    ]),
                  ),
            ]),
          ),
        ),
      const SizedBox(height: 8),
      labSubmitButton('triage_submit', () async {
        await gradeLabStep(context, () => TriageGrader.grade(s, _d), widget.onGraded);
      }),
    ]);
  }
}

// ------------------------------------------------------------ sequence

class SequenceView extends StatefulWidget {
  const SequenceView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final SequenceStep step;
  final StepGraded onGraded;
  @override
  State<SequenceView> createState() => _SequenceViewState();
}

class _SequenceViewState extends State<SequenceView> {
  late List<int> _order = widget.step.startOrder;

  void _move(int i, int d) {
    final int j = i + d;
    if (j < 0 || j >= _order.length) return;
    setState(() {
      final int t = _order[i];
      _order[i] = _order[j];
      _order[j] = t;
      _order = List<int>.of(_order);
    });
  }

  @override
  Widget build(BuildContext context) {
    final SequenceStep s = widget.step;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Text('Use the arrows to put the steps in the order you would carry them out.', style: TextStyle(color: GG.mute, fontSize: 12)),
      for (int i = 0; i < _order.length; i++)
        Card(
          key: ValueKey<String>('seq_pos_$i'),
          margin: const EdgeInsets.only(top: 6),
          child: Row(children: <Widget>[
            Padding(padding: const EdgeInsets.all(10), child: Text('${i + 1}', style: TextStyle(color: GG.accent, fontWeight: FontWeight.w900))),
            Expanded(child: Text(s.correctOrder[_order[i]], style: TextStyle(color: GG.ink))),
            IconButton(key: ValueKey<String>('seq_up_$i'), onPressed: i == 0 ? null : () => _move(i, -1), icon: const Icon(Icons.arrow_upward_rounded)),
            IconButton(key: ValueKey<String>('seq_down_$i'), onPressed: i == _order.length - 1 ? null : () => _move(i, 1), icon: const Icon(Icons.arrow_downward_rounded)),
          ]),
        ),
      const SizedBox(height: 8),
      labSubmitButton('sequence_submit', () async {
        await gradeLabStep(context, () => SequenceGrader.grade(s, _order), widget.onGraded);
      }),
    ]);
  }
}

// ------------------------------------------------------------ documents

class DocumentView extends StatefulWidget {
  const DocumentView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final DocumentStep step;
  final StepGraded onGraded;
  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  late final Map<String, TextEditingController> _c = <String, TextEditingController>{
    for (final DocSection sec in widget.step.sections) sec.id: TextEditingController(),
  };
  bool _loaded = false;

  String _key(String sec) => '${widget.step.id}/$sec';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final Map<String, String> drafts = careerStore(context).labRun(widget.lab.id)?.drafts ?? const <String, String>{};
    for (final MapEntry<String, TextEditingController> e in _c.entries) {
      e.value.text = drafts[_key(e.key)] ?? '';
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DocumentStep s = widget.step;
    final int total = _c.values.fold<int>(0, (int a, TextEditingController c) => a + DocumentGrader.words(c.text));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      if (s.sources.isNotEmpty)
        ExpansionTile(
          key: const ValueKey<String>('doc_sources'),
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: true,
          leading: const Icon(Icons.folder_open_rounded),
          title: const Text('File and sources'),
          children: <Widget>[BulletList(s.sources, icon: Icons.description_outlined)],
        ),
      Text('${s.docType} · $total words · saved as you type', style: TextStyle(color: GG.mute, fontSize: 12)),
      for (final DocSection sec in s.sections)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            Text(sec.heading, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
            if (sec.guidance.isNotEmpty) Text(sec.guidance, style: TextStyle(color: GG.mute, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              key: ValueKey<String>('doc_${sec.id}'),
              controller: _c[sec.id],
              minLines: 3,
              maxLines: 12,
              onChanged: (String v) {
                setState(() {});
                careerStore(context).saveLabDraft(widget.lab, _key(sec.id), v);
              },
              decoration: InputDecoration(border: const OutlineInputBorder(), helperText: '${DocumentGrader.words(_c[sec.id]!.text)} / ${sec.minWords}+ words'),
            ),
          ]),
        ),
      const SizedBox(height: 8),
      ExpansionTile(
        key: const ValueKey<String>('doc_rubric'),
        tilePadding: EdgeInsets.zero,
        title: const Text('Marking rubric'),
        children: <Widget>[
          BulletList(<String>[
            for (final DocSection sec in s.sections) ...<String>[
              '${sec.heading}: at least ${sec.minWords} words',
              for (final RubricItem r in sec.rubric) '${sec.heading}: ${r.label}',
            ],
            if (s.allowedCitations.isNotEmpty) 'Cite only authorities from the file (unverified citations fail the document)',
            for (final RubricItem f in s.forbidden) 'Must not: ${f.label}',
          ]),
        ],
      ),
      labSubmitButton('document_submit', () async {
        await gradeLabStep(context, () => DocumentGrader.grade(s, <String, String>{for (final MapEntry<String, TextEditingController> e in _c.entries) e.key: e.value.text}), widget.onGraded);
      }, label: 'Submit document'),
    ]);
  }
}

// ------------------------------------------------------------ dialogue

class DialogueView extends StatefulWidget {
  const DialogueView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final DialogueStep step;
  final StepGraded onGraded;
  @override
  State<DialogueView> createState() => _DialogueViewState();
}

class _DialogueViewState extends State<DialogueView> {
  List<String> _asked = <String>[];
  late final Map<String, TextEditingController> _c = _controllers(widget.step.conclusions);
  final Map<String, int?> _choices = <String, int?>{};
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final String? raw = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id];
    if (raw != null && raw.isNotEmpty) _asked = raw.split(',').where((String id) => widget.step.options.any((DialogueOption o) => o.id == id)).toList();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ask(DialogueOption o) {
    setState(() => _asked = <String>[..._asked, o.id]);
    careerStore(context).saveLabDraft(widget.lab, widget.step.id, _asked.join(','));
  }

  @override
  Widget build(BuildContext context) {
    final DialogueStep s = widget.step;
    final bool out = _asked.length >= s.maxTurns;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Container(
        key: const ValueKey<String>('dialogue_transcript'),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: GG.panel, border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          _Bubble(who: s.person, text: s.opening, mine: false),
          for (final String id in _asked)
            if (s.options.where((DialogueOption o) => o.id == id).firstOrNull case final DialogueOption o) ...<Widget>[
              _Bubble(who: 'You', text: o.say, mine: true),
              _Bubble(who: s.person, text: o.reply, mine: false),
            ],
        ]),
      ),
      const SizedBox(height: 6),
      Text('${_asked.length} of ${s.maxTurns} turns used${out ? ' — time is up for questions.' : '. Choose what to say or do next:'}', style: TextStyle(color: GG.mute, fontSize: 12)),
      if (!out)
        Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
          for (final DialogueOption o in s.options)
            if (!_asked.contains(o.id)) ActionChip(key: ValueKey<String>('say_${o.id}'), label: Text(o.say), onPressed: () => _ask(o)),
        ]),
      if (s.conclusions.isNotEmpty) ...<Widget>[
        const SizedBox(height: 10),
        Text('Your conclusions', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        QuestionFields(questions: s.conclusions, controllers: _c, choices: _choices, enabled: true, onChoice: (String id, int i) => setState(() => _choices[id] = i)),
      ],
      Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: <Widget>[
        TextButton(
          key: const ValueKey<String>('dialogue_restart'),
          onPressed: _asked.isEmpty
              ? null
              : () {
                  setState(() => _asked = <String>[]);
                  careerStore(context).saveLabDraft(widget.lab, widget.step.id, '');
                },
          child: const Text('Start the conversation again'),
        ),
        labSubmitButton('dialogue_submit', () async {
          await gradeLabStep(context, () => DialogueGrader.grade(s, _asked, questionAnswers(s.conclusions, _c, _choices)), widget.onGraded);
        }),
      ]),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.who, required this.text, required this.mine});
  final String who;
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) => Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(color: (mine ? GG.accent : GG.mute).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(who, style: TextStyle(color: GG.mute, fontSize: 11, fontWeight: FontWeight.w700)),
            Text(text, style: TextStyle(color: GG.ink, height: 1.35)),
          ]),
        ),
      );
}

// ------------------------------------------------------------ simulation

class SimulationView extends StatefulWidget {
  const SimulationView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final SimulationStep step;
  final StepGraded onGraded;
  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  late final Map<String, double> _v = widget.step.initialValues;
  late final Map<String, TextEditingController> _c = _controllers(widget.step.questions);
  final Map<String, int?> _choices = <String, int?>{};

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SimulationStep s = widget.step;
    final Map<String, double> env = s.evaluate(_v);
    Widget? chart;
    if (s.plot case (final String out, final String inp)) {
      final SimOutput? o = s.outputs.where((SimOutput o) => o.name == out).firstOrNull;
      final SimInput? i = s.inputs.where((SimInput i) => i.name == inp).firstOrNull;
      if (o != null && i != null) {
        // Plot the output as a function of one input (others fixed), by substitution.
        final List<double> ys = <double>[
          for (int k = 0; k <= 40; k++) s.evaluate(<String, double>{..._v, inp: i.min + (i.max - i.min) * k / 40})[out] ?? double.nan,
        ].where((double y) => y.isFinite).toList();
        if (ys.isNotEmpty) {
          final double lo = ys.reduce((double a, double b) => a < b ? a : b);
          final double hi = ys.reduce((double a, double b) => a > b ? a : b);
          final double pad = (hi - lo).abs() * 0.1 + 1e-6;
          chart = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('${o.label} against ${i.label} (other settings fixed):', style: TextStyle(color: GG.mute, fontSize: 12)),
            GraphPlot(
              curves: <PlotCurve>[PlotCurve(_SimExpr(s, _v, inp, out), const Color(0xFF3B82F6))],
              window: (i.min, i.max, lo - pad, hi + pad),
              points: <(double, double)>[((_v[inp] ?? i.min), env[out] ?? 0)],
              height: 200,
            ),
          ]);
        }
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      for (final SimInput i in s.inputs)
        Row(children: <Widget>[
          SizedBox(width: 150, child: Text('${i.label}: ${fmtNum(_v[i.name]!)}${i.unit.isEmpty ? '' : ' ${i.unit}'}', style: TextStyle(color: GG.ink))),
          Expanded(
            child: Slider(
              key: ValueKey<String>('sim_${i.name}'),
              value: _v[i.name]!.clamp(i.min, i.max),
              min: i.min,
              max: i.max,
              divisions: ((i.max - i.min) / i.step).round().clamp(1, 1000),
              onChanged: (double v) => setState(() => _v[i.name] = double.parse((((v - i.min) / i.step).round() * i.step + i.min).toStringAsFixed(6))),
            ),
          ),
        ]),
      const SizedBox(height: 6),
      Container(
        key: const ValueKey<String>('sim_outputs'),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: GG.panel, border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          for (final SimOutput o in s.outputs)
            Text(
              '${o.label}: ${(env[o.name] ?? double.nan).isFinite ? env[o.name]!.toStringAsFixed(o.decimals) : 'undefined'}${o.unit.isEmpty ? '' : ' ${o.unit}'}',
              key: ValueKey<String>('out_${o.name}'),
              style: TextStyle(color: GG.ink, fontFamily: 'monospace'),
            ),
          const Divider(),
          for (final SimConstraint c in s.constraints)
            Row(children: <Widget>[
              Icon(c.met(env[c.output] ?? double.nan) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 16, color: c.met(env[c.output] ?? double.nan) ? GG.green : GG.mute),
              const SizedBox(width: 6),
              Expanded(child: Text(c.label, style: TextStyle(color: GG.ink, fontSize: 12.5))),
            ]),
        ]),
      ),
      if (chart != null) Padding(padding: const EdgeInsets.only(top: 8), child: chart),
      if (s.questions.isNotEmpty) ...<Widget>[
        const SizedBox(height: 8),
        QuestionFields(questions: s.questions, controllers: _c, choices: _choices, enabled: true, onChoice: (String id, int i) => setState(() => _choices[id] = i)),
      ],
      const SizedBox(height: 6),
      labSubmitButton('sim_submit', () async {
        await gradeLabStep(context, () => SimulationGrader.grade(s, Map<String, double>.of(_v), questionAnswers(s.questions, _c, _choices)), widget.onGraded);
      }, label: 'Submit design'),
    ]);
  }
}

/// An [Expr] that evaluates a simulation output while one input varies.
class _SimExpr extends Expr {
  const _SimExpr(this.step, this.values, this.input, this.output);
  final SimulationStep step;
  final Map<String, double> values;
  final String input;
  final String output;

  @override
  double eval(Map<String, double> env) => step.evaluate(<String, double>{...values, input: env['x'] ?? 0})[output] ?? double.nan;

  @override
  Set<String> get variables => const <String>{'x'};

  @override
  String show() => output;
}

/// For tests: grade a work step from a plain answer.
TaskResult gradeWorkStep(LabStep s, Object answer) => switch (s) {
      TriageStep() => TriageGrader.grade(s, answer as Map<String, Map<String, String>>),
      SequenceStep() => SequenceGrader.grade(s, answer as List<int>),
      DocumentStep() => DocumentGrader.grade(s, answer as Map<String, String>),
      DialogueStep() => DialogueGrader.grade(s, (answer as (List<String>, Map<String, String>)).$1, answer.$2),
      SimulationStep() => SimulationGrader.grade(s, (answer as (Map<String, double>, Map<String, String>)).$1, answer.$2),
      _ => throw LabGradingException('Not a work step.'),
    };
