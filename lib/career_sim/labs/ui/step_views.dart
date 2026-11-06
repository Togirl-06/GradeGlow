import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../data/science_diagram_catalog.dart';
import '../../../models/science_diagram.dart';
import '../../../services/lab_runner/lab_runner.dart';
import '../../../services/lab_runner/lab_runner_host.dart';
import '../../../widgets/science/anatomy_asset_canvas.dart';
import '../../../widgets/science/science_diagram_canvas.dart';
import '../../model/career_models.dart';
import '../../store/career_sim_store.dart';
import '../../ui/common.dart';
import '../../ui/task_views.dart';
import '../content/accounting_labs.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import '../math/math_steps.dart';
import '../math/math_views.dart';
import '../anatomy3d/anatomy3d.dart';
import '../anatomy3d/anatomy3d_view.dart';
import '../work/drawing_step.dart';
import '../work/drawing_view.dart';
import '../work/work_steps.dart';
import '../work/work_views.dart';
import 'lab_tools.dart';
import '../../ui/gg_kit.dart';

typedef StepGraded = Future<void> Function(TaskResult result);

/// Renders a lab step and grades it with its rule.
class LabStepView extends StatelessWidget {
  const LabStepView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final LabStep step;
  final StepGraded onGraded;

  @override
  Widget build(BuildContext context) {
    final LabStep s = step;
    if (s is TaskStep) return TaskView(spec: s.task, onGraded: onGraded);
    final Widget body = switch (s) {
      ProgramStep() => _ProgramView(lab: lab, step: s, onGraded: onGraded),
      SqlStep() => _SqlView(lab: lab, step: s, onGraded: onGraded),
      SchedulingStep() => _SchedulingView(step: s, onGraded: onGraded),
      PagingStep() => _PagingView(step: s, onGraded: onGraded),
      SearchTraceStep() => _TraceView(step: s, onGraded: onGraded),
      IdentityCheckStep() => _IdentityView(lab: lab, step: s, onGraded: onGraded),
      HistoryStep() => _HistoryView(lab: lab, step: s, onGraded: onGraded),
      VitalsStep() => _VitalsView(lab: lab, step: s, onGraded: onGraded),
      MarStep() => _MarView(lab: lab, step: s, onGraded: onGraded),
      JournalStep() => _JournalView(lab: lab, step: s, onGraded: onGraded),
      ReconciliationStep() => _ReconView(step: s, onGraded: onGraded),
      StatementsStep() => _StatementsView(step: s, onGraded: onGraded),
      AnatomyIdStep() => _AnatomyIdView(step: s, onGraded: onGraded),
      WorkingStep() => WorkingView(lab: lab, step: s, onGraded: onGraded),
      NumericStep() => NumericView(lab: lab, step: s, onGraded: onGraded),
      GraphStep() => GraphStepView(lab: lab, step: s, onGraded: onGraded),
      MatrixStep() => MatrixView(lab: lab, step: s, onGraded: onGraded),
      OdeStep() => OdeView(lab: lab, step: s, onGraded: onGraded),
      TriageStep() => TriageView(lab: lab, step: s, onGraded: onGraded),
      SequenceStep() => SequenceView(lab: lab, step: s, onGraded: onGraded),
      DocumentStep() => DocumentView(lab: lab, step: s, onGraded: onGraded),
      DialogueStep() => DialogueView(lab: lab, step: s, onGraded: onGraded),
      SimulationStep() => SimulationView(lab: lab, step: s, onGraded: onGraded),
      DrawingStep() => DrawingView(lab: lab, step: s, onGraded: onGraded),
      Anatomy3DStep() => Anatomy3DView(lab: lab, step: s, onGraded: onGraded),
      _ => const Text('Unsupported step.'),
    };
    if (s is ProgramStep || s is SqlStep) {
      final Widget desc = GGPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text(s.title, style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w900, fontSize: 22))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF15803D), borderRadius: BorderRadius.circular(8)),
              child: Text(lab.difficulty.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(s.instructions, style: const TextStyle(color: GG.ink, height: 1.5)),
          if (s is ProgramStep && s.cases.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            const Text('Example:', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Input: ${s.cases.first.stdin.replaceAll('\n', ' | ')}\nOutput: ${s.cases.first.expected.replaceAll('\n', ' | ')}', style: const TextStyle(fontFamily: 'monospace', color: GG.ink, fontSize: 13)),
          ],
          const SizedBox(height: 10),
          Text('${s.kind} · pass mark ${s.passMark}', style: const TextStyle(color: GG.mute, fontSize: 12)),
        ]),
      );
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth < 900) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[desc, const SizedBox(height: 10), body]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Expanded(flex: 4, child: desc), const SizedBox(width: 12), Expanded(flex: 5, child: body)]);
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(children: <Widget>[StatusChip(s.kind), const SizedBox(width: 8), Text('Pass mark ${s.passMark}', style: TextStyle(color: GG.mute, fontSize: 12))]),
        const SizedBox(height: 6),
        Text(s.title, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 4),
        Text(s.instructions, style: TextStyle(color: GG.ink, height: 1.4)),
        const SizedBox(height: 10),
        body,
      ],
    );
  }
}

/// Grades with [grade]; shows the rule's message for incomplete answers.
Future<TaskResult?> _grade(BuildContext context, TaskResult Function() grade, StepGraded onGraded) async {
  final TaskResult r;
  try {
    r = grade();
  } on LabGradingException catch (e) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  }
  await onGraded(r);
  return r;
}

/// Public entry points for step views defined in other files.
Future<TaskResult?> gradeLabStep(BuildContext context, TaskResult Function() grade, StepGraded onGraded) => _grade(context, grade, onGraded);

Widget labSubmitButton(String key, Future<void> Function() go, {String label = 'Submit for evaluation'}) => _submit(key, go, label: label);

Widget _submit(String key, Future<void> Function() go, {String label = 'Submit for evaluation'}) =>
    BusyButton(key: ValueKey<String>(key), label: label, icon: Icons.fact_check_rounded, onPressed: go);

// ------------------------------------------------------------ program

class _ProgramView extends StatefulWidget {
  const _ProgramView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final ProgramStep step;
  final StepGraded onGraded;

  @override
  State<_ProgramView> createState() => _ProgramViewState();
}

class _ProgramViewState extends State<_ProgramView> {
  String _lang = 'python3';
  late final TextEditingController _code = TextEditingController();
  final TextEditingController _stdin = TextEditingController();
  ProgramOutput? _trial;
  TaskResult? _result;
  List<ProgramOutput> _outputs = <ProgramOutput>[];

  @override
  void initState() {
    super.initState();
    final CareerSimStore store = careerStore(context);
    final String? draft = store.labRun(widget.lab.id)?.drafts[widget.step.id];
    if (draft != null && draft.contains('\u0000')) {
      final int i = draft.indexOf('\u0000');
      _lang = draft.substring(0, i);
      _code.text = draft.substring(i + 1);
    } else {
      _code.text = widget.step.starter[_lang] ?? '';
    }
    _stdin.text = widget.step.cases.first.stdin;
  }

  @override
  void dispose() {
    _code.dispose();
    _stdin.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() => careerStore(context).saveLabDraft(widget.lab, widget.step.id, '$_lang\u0000${_code.text}');

  @override
  Widget build(BuildContext context) {
    final LabRunner runner = careerStore(context).runner;
    final ProgramOutput? t = _trial;
    final bool allPassed = _result?.passed ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GGCodeEditor(
          controller: _code,
          fieldKey: const ValueKey<String>('program_code'),
          onChanged: (_) => _saveDraft(),
          header: Row(children: <Widget>[
            DropdownButton<String>(
              key: const ValueKey<String>('program_lang'),
              value: _lang,
              underline: const SizedBox.shrink(),
              dropdownColor: GG.panel2,
              style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w700),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'python3', child: Text('Python')),
                DropdownMenuItem<String>(value: 'javascript', child: Text('JavaScript')),
              ],
              onChanged: (String? v) {
                if (v == null || v == _lang) return;
                setState(() {
                  _lang = v;
                  _code.text = widget.step.starter[v] ?? '';
                });
              },
            ),
            const Spacer(),
            Text(runner.where, style: const TextStyle(color: GG.mute, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 8),
        Text('Custom input ${widget.step.cases.first.stdin.isEmpty ? '(none)' : ''}', style: const TextStyle(color: GG.mute, fontSize: 12)),
        TextField(key: const ValueKey<String>('program_stdin'), controller: _stdin, style: const TextStyle(fontFamily: 'monospace'), decoration: const InputDecoration(isDense: true)),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(
            child: GGAsyncButton(
              key: const ValueKey<String>('program_run'),
              label: 'Run Code',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF4F5BEA),
              expand: true,
              onPressed: () async {
                await _saveDraft();
                final ProgramOutput o = await runner.runProgram(_lang, _code.text, stdin: _stdin.text);
                if (mounted) setState(() => _trial = o);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GGAsyncButton(
              key: const ValueKey<String>('program_submit'),
              label: 'Submit',
              icon: Icons.check_rounded,
              color: const Color(0xFF22B573),
              expand: true,
              onPressed: () async {
                await _saveDraft();
                final List<ProgramOutput> outs = <ProgramOutput>[];
                for (final ProgramCase c in widget.step.cases) {
                  outs.add(await runner.runProgram(_lang, _code.text, stdin: c.stdin));
                }
                if (!mounted) return;
                setState(() => _outputs = outs);
                final TaskResult? r = await _grade(context, () => LabGrader.program(widget.step, outs), widget.onGraded);
                if (mounted && r != null) setState(() => _result = r);
              },
            ),
          ),
        ]),
        LabRunnerHost(runner: runner),
        if (t != null) ...<Widget>[
          const SizedBox(height: 8),
          if (t.unavailable != null) Text(t.unavailable!, style: const TextStyle(color: GG.red)),
          const Text('Output', style: TextStyle(color: GG.mute, fontSize: 12)),
          codeBox(t.stdout, key: const ValueKey<String>('program_output')),
          if (t.stderr.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: codeBox(t.stderr, color: const Color(0xFFFCA5A5))),
        ],
        if (_outputs.isNotEmpty && _result != null) ...<Widget>[
          const SizedBox(height: 10),
          Row(children: <Widget>[
            Icon(allPassed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: allPassed ? GG.green : GG.red, size: 26),
            const SizedBox(width: 8),
            Text(allPassed ? 'Correct! Well done!' : 'Not yet — some tests failed.', style: TextStyle(color: allPassed ? GG.green : GG.red, fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
          const SizedBox(height: 4),
          for (int i = 0; i < _outputs.length; i++)
            Text(
              'Test ${i + 1}: ${ProgramStep.normalize(_outputs[i].stdout) == ProgramStep.normalize(widget.step.cases[i].expected) ? 'passed' : 'failed'}'
              '${i == 0 ? ' — input "${widget.step.cases[0].stdin}"' : ''}',
              style: const TextStyle(color: GG.ink),
            ),
          ResultPanel(result: _result!),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ SQL

class _SqlView extends StatefulWidget {
  const _SqlView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final SqlStep step;
  final StepGraded onGraded;

  @override
  State<_SqlView> createState() => _SqlViewState();
}

class _SqlViewState extends State<_SqlView> {
  late final TextEditingController _sql = TextEditingController(
      text: careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id] ?? widget.step.starter);
  SqlOutput? _out;
  TaskResult? _result;

  @override
  void dispose() {
    _sql.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LabRunner runner = careerStore(context).runner;
    final SqlOutput? o = _out;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Tables: ${widget.lab.databaseTables.join(' · ')}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey<String>('sql_editor'),
          controller: _sql,
          minLines: 4,
          maxLines: 12,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'SQL'),
          onChanged: (String v) => careerStore(context).saveLabDraft(widget.lab, widget.step.id, v),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
          BusyButton(
            key: const ValueKey<String>('sql_run'),
            label: 'Run',
            icon: Icons.play_arrow_rounded,
            tonal: true,
            onPressed: () async {
              final SqlOutput r = await runner.runSql(setup: widget.lab.database, statements: _sql.text);
              if (mounted) setState(() => _out = r);
            },
          ),
          _submit('sql_submit', () async {
            final SqlOutput r = await runner.runSql(setup: widget.lab.database, statements: _sql.text, check: widget.step.check);
            if (!mounted) return;
            setState(() => _out = r);
            final TaskResult? g = await _grade(context, () => LabGrader.sql(widget.step, r), widget.onGraded);
            if (mounted && g != null) setState(() => _result = g);
          }),
          LabRunnerHost(runner: runner),
        ]),
        if (o != null) ...<Widget>[
          const SizedBox(height: 8),
          if (o.unavailable != null)
            Text(o.unavailable!, style: const TextStyle(color: GG.red))
          else if (!o.ok)
            Text('Error: ${o.error}', key: const ValueKey<String>('sql_error'), style: const TextStyle(color: GG.red))
          else ...<Widget>[
            Text('${o.result.rows.length} row(s)${o.changes > 0 ? ' · ${o.changes} changed' : ''}', style: TextStyle(color: GG.mute, fontSize: 12)),
            SqlTableView(key: const ValueKey<String>('sql_result'), table: o.result),
          ],
        ],
        if (_result != null) ResultPanel(result: _result!),
      ],
    );
  }
}

// ------------------------------------------------------------ OS

class _SchedulingView extends StatefulWidget {
  const _SchedulingView({required this.step, required this.onGraded});
  final SchedulingStep step;
  final StepGraded onGraded;

  @override
  State<_SchedulingView> createState() => _SchedulingViewState();
}

class _SchedulingViewState extends State<_SchedulingView> {
  final List<String> _order = <String>[];
  final TextEditingController _avg = TextEditingController();
  TaskResult? _result;

  @override
  void dispose() {
    _avg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SchedulingStep s = widget.step;
    int t = 0;
    final List<Widget> gantt = <Widget>[];
    for (final String n in _order) {
      final SchedProcess p = s.processes.firstWhere((SchedProcess x) => x.name == n);
      if (t < p.arrival) t = p.arrival;
      gantt.add(Container(
        width: 26.0 * p.burst,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.primaries[s.processes.indexOf(p) % Colors.primaries.length].withValues(alpha: 0.7), border: Border.all(color: Colors.black26)),
        child: Text('$n\n$t–${t + p.burst}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
      ));
      t += p.burst;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DataTable(
          dataRowMinHeight: 26,
          dataRowMaxHeight: 30,
          columns: const <DataColumn>[DataColumn(label: Text('Process')), DataColumn(label: Text('Arrival')), DataColumn(label: Text('Burst'))],
          rows: <DataRow>[for (final SchedProcess p in s.processes) DataRow(cells: <DataCell>[DataCell(Text(p.name)), DataCell(Text('${p.arrival}')), DataCell(Text('${p.burst}'))])],
        ),
        Text('Dispatch next:', style: TextStyle(color: GG.mute)),
        Wrap(spacing: 6, children: <Widget>[
          for (final SchedProcess p in s.processes)
            OutlinedButton(
              key: ValueKey<String>('dispatch_${p.name}'),
              onPressed: _result != null || _order.contains(p.name) ? null : () => setState(() => _order.add(p.name)),
              child: Text(p.name),
            ),
          TextButton(key: const ValueKey<String>('gantt_clear'), onPressed: _result != null ? null : () => setState(_order.clear), child: const Text('Clear')),
        ]),
        const SizedBox(height: 6),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: gantt.isEmpty ? <Widget>[Text('Gantt chart is empty.', style: TextStyle(color: GG.mute))] : gantt)),
        const SizedBox(height: 8),
        TextField(key: const ValueKey<String>('avg_wait'), controller: _avg, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Average waiting time', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 8),
        if (_result == null)
          _submit('sched_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.scheduling(s, List<String>.from(_order), parseNumber(_avg.text)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          })
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

class _PagingView extends StatefulWidget {
  const _PagingView({required this.step, required this.onGraded});
  final PagingStep step;
  final StepGraded onGraded;

  @override
  State<_PagingView> createState() => _PagingViewState();
}

class _PagingViewState extends State<_PagingView> {
  final List<int?> _decisions = <int?>[];
  final List<int> _frames = <int>[];
  TaskResult? _result;

  void _decide(int? evict) {
    final int r = widget.step.references[_decisions.length];
    setState(() {
      _decisions.add(evict);
      if (evict == null) {
        if (!_frames.contains(r)) {
          // Said "hit" for a page that is not resident: memory still has to load it.
          if (_frames.length < widget.step.frames) {
            _frames.add(r);
          } else {
            _frames[0] = r;
          }
        }
        return;
      }
      if (evict >= 0 && _frames.contains(evict)) {
        _frames[_frames.indexOf(evict)] = r;
      } else if (!_frames.contains(r)) {
        if (_frames.length < widget.step.frames) {
          _frames.add(r);
        } else {
          _frames[0] = r;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PagingStep s = widget.step;
    final bool done = _decisions.length >= s.references.length;
    final int? current = done ? null : s.references[_decisions.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${s.algorithm == PagingAlgorithm.fifo ? 'FIFO' : 'LRU'} · ${s.frames} frames', style: TextStyle(color: GG.mute)),
        const SizedBox(height: 6),
        Wrap(spacing: 4, children: <Widget>[
          for (int i = 0; i < s.references.length; i++)
            Container(
              width: 30,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: i == _decisions.length ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25) : null,
                border: Border.all(color: GG.stroke),
              ),
              child: Text('${s.references[i]}\n${i < _decisions.length ? (_decisions[i] == null ? 'H' : 'F') : ''}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace')),
            ),
        ]),
        const SizedBox(height: 8),
        Row(children: <Widget>[
          Text('Frames: ', style: TextStyle(color: GG.ink)),
          for (int f = 0; f < s.frames; f++)
            Container(
              key: ValueKey<String>('frame_$f'),
              width: 40,
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: GG.ink)),
              child: Text(f < _frames.length ? '${_frames[f]}' : '–', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800)),
            ),
        ]),
        const SizedBox(height: 8),
        if (current != null) ...<Widget>[
          Text('Reference ${_decisions.length + 1}: page $current', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            OutlinedButton(key: const ValueKey<String>('page_hit'), onPressed: () => _decide(null), child: const Text('Hit')),
            if (_frames.length < s.frames)
              OutlinedButton(key: const ValueKey<String>('page_fault_free'), onPressed: () => _decide(-1), child: const Text('Fault — load into a free frame')),
            if (_frames.length >= s.frames)
              for (final int p in _frames)
                OutlinedButton(key: ValueKey<String>('page_evict_$p'), onPressed: () => _decide(p), child: Text('Fault — evict $p')),
          ]),
        ],
        if (done && _result == null)
          _submit('paging_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.paging(s, List<int?>.from(_decisions)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }),
        if (_result != null) ResultPanel(result: _result!),
      ],
    );
  }
}

class _TraceView extends StatefulWidget {
  const _TraceView({required this.step, required this.onGraded});
  final SearchTraceStep step;
  final StepGraded onGraded;

  @override
  State<_TraceView> createState() => _TraceViewState();
}

class _TraceViewState extends State<_TraceView> {
  int _lo = 0;
  late int _hi = widget.step.values.length - 1;
  final List<int> _mids = <int>[];
  bool _found = false;
  TaskResult? _result;

  void _probe(int i) {
    final SearchTraceStep s = widget.step;
    setState(() {
      _mids.add(i);
      // The array responds to the correct algorithm so the student can continue.
      final int mid = (_lo + _hi) ~/ 2;
      if (s.values[mid] == s.target) {
        _found = true;
      } else if (s.values[mid] < s.target) {
        _lo = mid + 1;
      } else {
        _hi = mid - 1;
      }
      if (_lo > _hi) _found = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchTraceStep s = widget.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Target: ${s.target} · lo = $_lo · hi = $_hi', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
          for (int i = 0; i < s.values.length; i++)
            InkWell(
              key: ValueKey<String>('cell_$i'),
              onTap: _found || _result != null || i < _lo || i > _hi ? null : () => _probe(i),
              child: Container(
                width: 38,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: i < _lo || i > _hi ? GG.stroke : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  border: Border.all(color: _mids.contains(i) ? GG.accent : GG.stroke, width: _mids.contains(i) ? 2 : 1),
                ),
                child: Text('$i\n${s.values[i]}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        Text(_found ? 'Search finished after ${_mids.length} probe(s).' : 'Tap the index binary search probes next.', style: TextStyle(color: GG.mute)),
        const SizedBox(height: 8),
        if (_found && _result == null)
          _submit('trace_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.searchTrace(s, List<int>.from(_mids)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }),
        if (_result != null) ResultPanel(result: _result!),
      ],
    );
  }
}

// ------------------------------------------------------------ clinical

class _IdentityView extends StatefulWidget {
  const _IdentityView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final IdentityCheckStep step;
  final StepGraded onGraded;

  @override
  State<_IdentityView> createState() => _IdentityViewState();
}

class _IdentityViewState extends State<_IdentityView> {
  final Set<String> _mismatch = <String>{};
  bool _asked = false;
  bool _band = false;
  TaskResult? _result;

  @override
  Widget build(BuildContext context) {
    final IdentityCheckStep s = widget.step;
    final Patient p = widget.lab.patient(s.patientId)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PatientChartView(patient: p),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: <Widget>[
          OutlinedButton.icon(key: const ValueKey<String>('check_wristband'), onPressed: () => setState(() => _band = true), icon: const Icon(Icons.watch_rounded), label: const Text('Read the wristband')),
          OutlinedButton.icon(key: const ValueKey<String>('ask_identity'), onPressed: () => setState(() => _asked = true), icon: const Icon(Icons.record_voice_over_rounded), label: const Text('Ask her name and date of birth')),
        ]),
        if (_band) Text('Wristband: ${IdentityCheckStep.fields.map((String f) => '$f ${s.wristband[f]}').join(' · ')}', key: const ValueKey<String>('wristband_text')),
        if (_asked) Text('Patient: "My name is ${s.stated['Name']}, born ${s.stated['Date of birth']}."'),
        const SizedBox(height: 8),
        Text('Identifiers that do not match the record:', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
        for (final String f in IdentityCheckStep.fields)
          CheckboxListTile(
            key: ValueKey<String>('mismatch_$f'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _mismatch.contains(f),
            title: Text(f),
            onChanged: _result != null ? null : (bool? v) => setState(() => v == true ? _mismatch.add(f) : _mismatch.remove(f)),
          ),
        if (_result == null)
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            _submit('identity_proceed', () => _go(true), label: 'Identity confirmed — continue care'),
            _submit('identity_stop', () => _go(false), label: 'Stop — resolve the identity first'),
          ])
        else
          ResultPanel(result: _result!),
      ],
    );
  }

  Future<void> _go(bool proceed) async {
    if (!_band || !_asked) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Check the wristband and ask the patient before deciding.')));
      return;
    }
    final Patient p = widget.lab.patient(widget.step.patientId)!;
    final TaskResult? r = await _grade(context, () => LabGrader.identity(widget.step, p, Set<String>.from(_mismatch), proceed), widget.onGraded);
    if (mounted && r != null) setState(() => _result = r);
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final HistoryStep step;
  final StepGraded onGraded;

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final List<int> _asked = <int>[];
  final TextEditingController _note = TextEditingController();
  TaskResult? _result;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HistoryStep s = widget.step;
    final Patient p = widget.lab.patient(s.patientId)!;
    final bool full = _asked.length >= s.maxQuestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('${p.name}, ${p.age}: ${p.presenting}', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
        Text('Questions asked: ${_asked.length} of ${s.maxQuestions}', style: TextStyle(color: GG.mute, fontSize: 12)),
        const SizedBox(height: 6),
        for (final int i in _asked) ...<Widget>[
          Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)), child: Text(s.questions[i].question))),
          Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: GG.panel2, borderRadius: BorderRadius.circular(10)), child: Text('${p.name.split(' ').first}: ${s.questions[i].answer}'))),
        ],
        if (_result == null)
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            for (int i = 0; i < s.questions.length; i++)
              if (!_asked.contains(i))
                ActionChip(key: ValueKey<String>('ask_$i'), label: Text(s.questions[i].question), onPressed: full ? null : () => setState(() => _asked.add(i))),
          ]),
        const SizedBox(height: 10),
        WrittenField(fieldKey: const ValueKey<String>('history_note'), controller: _note, rubric: s.noteRubric, minWords: 40, label: 'Documentation', enabled: _result == null),
        const SizedBox(height: 8),
        if (_result == null)
          _submit('history_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.history(s, List<int>.from(_asked), _note.text), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          })
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

class _VitalsView extends StatefulWidget {
  const _VitalsView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final VitalsStep step;
  final StepGraded onGraded;

  @override
  State<_VitalsView> createState() => _VitalsViewState();
}

class _VitalsViewState extends State<_VitalsView> {
  int _round = 0;
  final List<(int?, int?)> _answers = <(int?, int?)>[];
  final TextEditingController _score = TextEditingController();
  int? _response;
  TaskResult? _result;

  @override
  void dispose() {
    _score.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Patient p = widget.lab.patient(widget.step.patientId)!;
    final bool done = _round >= p.vitals.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!done) ...<Widget>[
          Text('Round ${_round + 1} of ${p.vitals.length}', style: TextStyle(color: GG.mute)),
          BedsideMonitor(vitals: p.vitals[_round]),
          const SizedBox(height: 8),
          TextField(key: const ValueKey<String>('news_total'), controller: _score, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'NEWS2 total', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 6),
          for (int i = 0; i < News2.responses.length; i++)
            ListTile(
              key: ValueKey<String>('news_resp_$i'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(_response == i ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              title: Text(News2.responses[i]),
              onTap: () => setState(() => _response = i),
            ),
          FilledButton(
            key: const ValueKey<String>('news_record'),
            onPressed: () {
              final int? total = int.tryParse(_score.text.trim());
              if (total == null || _response == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the NEWS2 total and choose a response.')));
                return;
              }
              setState(() {
                _answers.add((total, _response));
                _round++;
                _score.clear();
                _response = null;
              });
            },
            child: const Text('Record and continue'),
          ),
        ],
        if (done && _result == null)
          _submit('vitals_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.vitals(widget.step, p, List<(int?, int?)>.from(_answers)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }),
        if (_result != null) ResultPanel(result: _result!),
      ],
    );
  }
}

class _MarView extends StatefulWidget {
  const _MarView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final MarStep step;
  final StepGraded onGraded;

  @override
  State<_MarView> createState() => _MarViewState();
}

class _MarViewState extends State<_MarView> {
  late final List<MedDecision?> _d = List<MedDecision?>.filled(widget.step.correct.length, null);
  TaskResult? _result;

  @override
  Widget build(BuildContext context) {
    final Patient p = widget.lab.patient(widget.step.patientId)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PatientChartView(patient: p),
        if (p.vitals.isNotEmpty) ...<Widget>[const SizedBox(height: 6), BedsideMonitor(vitals: p.vitals.last)],
        const SizedBox(height: 8),
        for (int i = 0; i < p.medications.length && i < _d.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('${p.medications[i].drug} ${p.medications[i].dose} ${p.medications[i].route} — due ${p.medications[i].due}', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              if (p.medications[i].notes.isNotEmpty) Text(p.medications[i].notes, style: TextStyle(color: GG.mute)),
              Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
                for (final MedDecision m in MedDecision.values)
                  ChoiceChip(
                    key: ValueKey<String>('mar_${i}_${m.name}'),
                    label: Text(m.label),
                    selected: _d[i] == m,
                    onSelected: _result != null ? null : (_) => setState(() => _d[i] = m),
                  ),
              ]),
            ]),
          ),
        if (_result == null)
          _submit('mar_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.mar(widget.step, List<MedDecision?>.from(_d)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }, label: 'Sign the round')
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

// ------------------------------------------------------------ accounting

String _money(double v) => '£${v.toStringAsFixed(2)}';

class _JournalView extends StatefulWidget {
  const _JournalView({required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final JournalStep step;
  final StepGraded onGraded;

  @override
  State<_JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<_JournalView> {
  late List<List<EntryLine>> _entries;
  int _doc = 0;
  String? _acct;
  bool _debit = true;
  final TextEditingController _amt = TextEditingController();
  TaskResult? _result;

  @override
  void initState() {
    super.initState();
    _entries = List<List<EntryLine>>.generate(widget.step.documents.length, (_) => <EntryLine>[]);
    final String? draft = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id];
    if (draft != null) {
      try {
        final List<dynamic> j = jsonDecode(draft) as List<dynamic>;
        for (int i = 0; i < j.length && i < _entries.length; i++) {
          _entries[i] = (j[i] as List<dynamic>).map((dynamic l) => EntryLine.fromJson(Map<String, dynamic>.from(l as Map<dynamic, dynamic>))).toList();
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _amt.dispose();
    super.dispose();
  }

  void _save() => careerStore(context).saveLabDraft(
      widget.lab, widget.step.id, jsonEncode(_entries.map((List<EntryLine> e) => e.map((EntryLine l) => l.toJson()).toList()).toList()));

  Map<String, double> _balances() {
    final Map<String, double> b = <String, double>{};
    for (final List<EntryLine> e in _entries) {
      for (final EntryLine l in e) {
        final bool normalDebit = bakeryNormalDebit[l.account] ?? true;
        b[l.account] = (b[l.account] ?? 0) + (l.debit == normalDebit ? l.amount : -l.amount);
      }
    }
    return b;
  }

  @override
  Widget build(BuildContext context) {
    final JournalStep s = widget.step;
    final SourceDocument doc = s.documents[_doc];
    final List<EntryLine> lines = _entries[_doc];
    final double dr = lines.where((EntryLine l) => l.debit).fold<double>(0, (double a, EntryLine l) => a + l.amount);
    final double cr = lines.where((EntryLine l) => !l.debit).fold<double>(0, (double a, EntryLine l) => a + l.amount);
    final Map<String, double> bal = _balances();
    double tbDr = 0;
    double tbCr = 0;
    bal.forEach((String a, double v) {
      final bool nd = bakeryNormalDebit[a] ?? true;
      if ((nd && v >= 0) || (!nd && v < 0)) {
        tbDr += v.abs();
      } else {
        tbCr += v.abs();
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
          for (int i = 0; i < s.documents.length; i++)
            ChoiceChip(
              key: ValueKey<String>('doc_$i'),
              avatar: _entries[i].isEmpty ? null : const Icon(Icons.check_rounded, size: 16),
              label: Text(s.documents[i].ref),
              selected: _doc == i,
              onSelected: (_) => setState(() => _doc = i),
            ),
        ]),
        const SizedBox(height: 8),
        Container(
          key: const ValueKey<String>('source_document'),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), border: Border.all(color: const Color(0xFFF59E0B))),
          child: Text('${doc.ref} · ${doc.date}\n${doc.text}', style: const TextStyle(color: Color(0xFF1F2937), height: 1.4)),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < lines.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('${lines[i].debit ? 'Dr' : '      Cr'} ${lines[i].account}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(_money(lines[i].amount)),
              IconButton(
                key: ValueKey<String>('del_line_$i'),
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: _result != null ? null : () => setState(() {
                  lines.removeAt(i);
                  _save();
                }),
              ),
            ]),
          ),
        Text('Debits ${_money(dr)} · Credits ${_money(cr)}${(dr - cr).abs() < 0.005 && lines.isNotEmpty ? ' · balanced' : ''}',
            style: TextStyle(color: (dr - cr).abs() < 0.005 ? GG.green : GG.red, fontWeight: FontWeight.w700)),
        if (_result == null) ...<Widget>[
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey<String>('acct_$_doc'),
            initialValue: _acct,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder(), isDense: true),
            items: <DropdownMenuItem<String>>[for (final String a in s.accounts) DropdownMenuItem<String>(value: a, child: Text(a))],
            onChanged: (String? v) => setState(() => _acct = v),
          ),
          const SizedBox(height: 6),
          Row(children: <Widget>[
            ChoiceChip(key: const ValueKey<String>('side_dr'), label: const Text('Debit'), selected: _debit, onSelected: (_) => setState(() => _debit = true)),
            const SizedBox(width: 6),
            ChoiceChip(key: const ValueKey<String>('side_cr'), label: const Text('Credit'), selected: !_debit, onSelected: (_) => setState(() => _debit = false)),
            const SizedBox(width: 8),
            Expanded(child: TextField(key: const ValueKey<String>('line_amount'), controller: _amt, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixText: '£ ', isDense: true, border: OutlineInputBorder()))),
            IconButton(
              key: const ValueKey<String>('add_line'),
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: () {
                final double? m = parseNumber(_amt.text);
                if (_acct == null || m == null || m <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose an account and enter a positive amount.')));
                  return;
                }
                setState(() {
                  lines.add(EntryLine(_acct!, _debit, m));
                  _amt.clear();
                  _save();
                });
              },
            ),
          ]),
        ],
        const SizedBox(height: 10),
        ExpansionTile(
          key: const ValueKey<String>('ledger_tb'),
          tilePadding: EdgeInsets.zero,
          title: Text('Ledger and trial balance (from your entries) — Dr ${_money(tbDr)} / Cr ${_money(tbCr)}'),
          children: <Widget>[
            for (final MapEntry<String, double> e in bal.entries)
              ListTile(dense: true, title: Text(e.key), trailing: Text('${_money(e.value.abs())} ${(e.value >= 0) == (bakeryNormalDebit[e.key] ?? true) ? 'Dr' : 'Cr'}')),
          ],
        ),
        if (_result == null)
          _submit('journal_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.journal(s, _entries), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }, label: 'Post the journal for review')
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

class _ReconView extends StatefulWidget {
  const _ReconView({required this.step, required this.onGraded});
  final ReconciliationStep step;
  final StepGraded onGraded;

  @override
  State<_ReconView> createState() => _ReconViewState();
}

class _ReconViewState extends State<_ReconView> {
  late final List<ReconItem?> _p = List<ReconItem?>.filled(widget.step.lines.length, null);
  final TextEditingController _adj = TextEditingController();
  TaskResult? _result;

  @override
  void dispose() {
    _adj.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReconciliationStep s = widget.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Cash book balance ${_money(s.cashBookBalance)} · Bank statement balance ${_money(s.bankBalance)}', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (int i = 0; i < s.lines.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('${s.lines[i].source}: ${s.lines[i].description}  ${s.lines[i].amount >= 0 ? '+' : '−'}${_money(s.lines[i].amount.abs())}', style: TextStyle(color: GG.ink)),
              Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
                for (final ReconItem it in ReconItem.values)
                  ChoiceChip(key: ValueKey<String>('recon_${i}_${it.name}'), label: Text(it.label), selected: _p[i] == it, onSelected: _result != null ? null : (_) => setState(() => _p[i] = it)),
              ]),
            ]),
          ),
        TextField(key: const ValueKey<String>('recon_adjusted'), controller: _adj, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Adjusted cash book balance', prefixText: '£ ', border: OutlineInputBorder(), isDense: true)),
        const SizedBox(height: 8),
        if (_result == null)
          _submit('recon_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.reconciliation(s, List<ReconItem?>.from(_p), parseNumber(_adj.text)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          })
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

class _StatementsView extends StatefulWidget {
  const _StatementsView({required this.step, required this.onGraded});
  final StatementsStep step;
  final StepGraded onGraded;

  @override
  State<_StatementsView> createState() => _StatementsViewState();
}

class _StatementsViewState extends State<_StatementsView> {
  final Map<String, StatementLine?> _m = <String, StatementLine?>{};
  final TextEditingController _ni = TextEditingController();
  final TextEditingController _ta = TextEditingController();
  TaskResult? _result;

  @override
  void dispose() {
    _ni.dispose();
    _ta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StatementsStep s = widget.step;
    final double liabilities = s.sum(StatementLine.liability, _m);
    final double equity = s.sum(StatementLine.equity, _m) + s.netIncome(_m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < s.trialBalance.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: <Widget>[
              Expanded(child: Text('${s.trialBalance[i].name}  ${_money(s.trialBalance[i].balance)} ${s.trialBalance[i].debit ? 'Dr' : 'Cr'}', style: TextStyle(color: GG.ink))),
              SizedBox(
                width: 230,
                child: DropdownButtonFormField<StatementLine>(
                  key: ValueKey<String>('stmt_$i'),
                  initialValue: _m[s.trialBalance[i].name],
                  isExpanded: true,
                  decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                  items: <DropdownMenuItem<StatementLine>>[for (final StatementLine l in StatementLine.values) DropdownMenuItem<StatementLine>(value: l, child: Text(l.label, overflow: TextOverflow.ellipsis))],
                  onChanged: _result != null ? null : (StatementLine? v) => setState(() => _m[s.trialBalance[i].name] = v),
                ),
              ),
            ]),
          ),
        Container(
          key: const ValueKey<String>('stmt_preview'),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(8)),
          child: Text(
            'Income statement (from your choices): revenue ${_money(s.sum(StatementLine.revenue, _m))} − expenses ${_money(s.sum(StatementLine.expense, _m))}\n'
            'Balance sheet: assets ${_money(s.sum(StatementLine.asset, _m))} · liabilities ${_money(liabilities)} · equity incl. profit ${_money(equity)}',
            style: TextStyle(color: GG.ink, height: 1.4),
          ),
        ),
        const SizedBox(height: 8),
        TextField(key: const ValueKey<String>('stmt_ni'), controller: _ni, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'Net income for the year', prefixText: '£ ', isDense: true, border: OutlineInputBorder())),
        const SizedBox(height: 6),
        TextField(key: const ValueKey<String>('stmt_ta'), controller: _ta, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total assets', prefixText: '£ ', isDense: true, border: OutlineInputBorder())),
        const SizedBox(height: 8),
        if (_result == null)
          _submit('stmt_submit', () async {
            final TaskResult? r = await _grade(context, () => LabGrader.statements(s, Map<String, StatementLine?>.from(_m), parseNumber(_ni.text), parseNumber(_ta.text)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          })
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}

// ------------------------------------------------------------ anatomy

class _AnatomyIdView extends StatefulWidget {
  const _AnatomyIdView({required this.step, required this.onGraded});
  final AnatomyIdStep step;
  final StepGraded onGraded;

  @override
  State<_AnatomyIdView> createState() => _AnatomyIdViewState();
}

class _AnatomyIdViewState extends State<_AnatomyIdView> {
  int _i = 0;
  final Map<String, String?> _names = <String, String?>{};
  TaskResult? _result;

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? d = ScienceDiagramCatalog.diagramById(widget.step.diagramId);
    if (d == null) return const Text('Diagram not found.');
    final Map<String, String> correct = <String, String>{
      for (final ScienceDiagramRegion r in d.regions)
        if (widget.step.regionIds.contains(r.id)) r.id: r.name,
    };
    final List<String> bank = d.regions.map((ScienceDiagramRegion r) => r.name).toSet().toList()..sort();
    final String id = widget.step.regionIds[_i];
    final Widget canvas = d.usesAnatomyAsset
        ? AnatomyAssetCanvas(diagram: d, highlightRegionId: id, showOverlays: false, onRegionTap: (_) {})
        : ScienceDiagramCanvas(diagram: d, highlightRegionId: id, showOverlays: false, onRegionTap: (_) {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 280, child: canvas),
        Text('Structure ${_i + 1} of ${widget.step.regionIds.length}', style: TextStyle(color: GG.mute)),
        Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
          for (final String n in bank)
            ChoiceChip(
              key: ValueKey<String>('anat_${n.toLowerCase().replaceAll(' ', '_')}'),
              label: Text(n),
              selected: _names[id] == n,
              onSelected: _result != null
                  ? null
                  : (_) => setState(() {
                        _names[id] = n;
                        if (_i < widget.step.regionIds.length - 1) _i++;
                      }),
            ),
        ]),
        Row(children: <Widget>[
          TextButton(onPressed: _i == 0 ? null : () => setState(() => _i--), child: const Text('Previous')),
          TextButton(onPressed: _i >= widget.step.regionIds.length - 1 ? null : () => setState(() => _i++), child: const Text('Next')),
        ]),
        if (_result == null)
          _submit('anat_submit', () async {
            final TaskResult? r = await _grade(context, () => AnatomyGrader.grade(widget.step, correct, Map<String, String?>.from(_names)), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          })
        else
          ResultPanel(result: _result!),
      ],
    );
  }
}
