import 'package:flutter/material.dart';

import '../../models/leetcode_problem.dart';
import '../../services/code_judge_service.dart';
import '../../vu_v2/design/vu_v2_theme.dart';
import '../ai/career_ai.dart';
import '../content/catalog.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/tasks.dart';
import 'common.dart';
import 'diagrams.dart';

/// Presents any task and grades it with its rule. [onGraded] persists the result.
class TaskView extends StatelessWidget {
  const TaskView({super.key, required this.spec, required this.onGraded, this.allowRetry = true, this.onText});

  final TaskSpec spec;
  final Future<void> Function(TaskResult result) onGraded;
  final bool allowRetry;

  /// Receives the text of a written answer just before it is graded.
  final void Function(String text)? onText;

  @override
  Widget build(BuildContext context) {
    final TaskSpec s = spec;
    final Widget body;
    if (s is CodeTaskSpec) {
      body = _CodeTaskView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is DecisionTaskSpec) {
      body = _DecisionView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is WorkupTaskSpec) {
      body = _WorkupView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is NumericTaskSpec) {
      body = _NumericView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is LedgerTaskSpec) {
      body = _LedgerView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is ClassifyTaskSpec) {
      body = _ClassifyView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is OrderTaskSpec) {
      body = _OrderView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is WrittenTaskSpec) {
      body = _WrittenView(spec: s, onGraded: onGraded, allowRetry: allowRetry, onText: onText);
    } else if (s is LabelTaskSpec) {
      body = _LabelView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else if (s is CourtroomTaskSpec) {
      body = _CourtView(spec: s, onGraded: onGraded, allowRetry: allowRetry);
    } else {
      body = const Text('Unsupported task type.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            StatusChip(spec.kindLabel),
            const SizedBox(width: 8),
            Text('Pass mark ${spec.passMark}', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Text(spec.title, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 6),
        Text(spec.brief, style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
        const SizedBox(height: 12),
        body,
      ],
    );
  }
}

class ResultPanel extends StatelessWidget {
  const ResultPanel({super.key, required this.result});
  final TaskResult result;

  @override
  Widget build(BuildContext context) {
    final Color c = result.passed ? VuV2Colors.success : VuV2Colors.danger;
    return Container(
      key: const ValueKey<String>('task_result'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(VuV2Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(result.passed ? 'Passed' : 'Not passed', style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(width: 8),
              Text('${result.score}/100', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
              const Spacer(),
              const ValidatedBadge(),
            ],
          ),
          const SizedBox(height: 8),
          BulletList(result.feedback),
          if (result.breakdown.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (final MapEntry<String, int> e in result.breakdown.entries) StatusChip('${e.key}: ${e.value}', color: VuV2Colors.mute),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shared submit/result/retry footer.
mixin _Graded<T extends StatefulWidget> on State<T> {
  TaskResult? graded;

  /// Bumped on retry so form fields rebuild empty.
  int attempt = 0;

  Future<void> Function(TaskResult) get onGradedCb;
  bool get retry;

  Future<void> submitWith(TaskSpec spec, Object answer) async {
    final TaskResult r;
    try {
      r = TaskGrader.grade(spec, answer);
    } on TaskGradingException catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    await onGradedCb(r);
    if (mounted) setState(() => graded = r);
  }

  void resetAnswer();

  Widget footer(Future<void> Function() submit) {
    final TaskResult? r = graded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        if (r == null)
          BusyButton(key: const ValueKey<String>('task_submit'), label: 'Submit for grading', icon: Icons.fact_check_rounded, onPressed: submit)
        else ...<Widget>[
          ResultPanel(result: r),
          if (retry)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                key: const ValueKey<String>('task_retry'),
                onPressed: () => setState(() {
                  graded = null;
                  attempt++;
                  resetAnswer();
                }),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ),
        ],
      ],
    );
  }
}

Widget _facts(List<Fact> facts) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final Fact f in facts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: VuV2Colors.navyElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: VuV2Colors.stroke),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: VuV2Colors.ink, fontSize: 13),
                children: <InlineSpan>[
                  TextSpan(text: '${f.label}: ', style: TextStyle(color: VuV2Colors.mute)),
                  TextSpan(text: f.value, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );

Widget _mono(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
      child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFFE2E8F0), fontSize: 12.5, height: 1.4)),
    );

Widget _exhibit(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VuV2Colors.navyElevated,
        border: Border(left: BorderSide(color: VuV2Colors.orange, width: 4)),
      ),
      child: Text(text, style: TextStyle(color: VuV2Colors.ink, height: 1.45, fontStyle: FontStyle.italic)),
    );

class _Option extends StatelessWidget {
  const _Option({super.key, required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color c = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? c.withValues(alpha: 0.12) : VuV2Colors.navyElevated,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 20, color: selected ? c : VuV2Colors.mute),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: TextStyle(color: VuV2Colors.ink, height: 1.35))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ code

class _CodeTaskView extends StatefulWidget {
  const _CodeTaskView({required this.spec, required this.onGraded, required this.allowRetry});
  final CodeTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_CodeTaskView> createState() => _CodeTaskViewState();
}

class _CodeTaskViewState extends State<_CodeTaskView> {
  late final LeetcodeProblem? _problem = CareerCatalog.problem(widget.spec.problemKey);
  String _lang = 'python3';
  final TextEditingController _code = TextEditingController();
  JudgeResult? _last;
  bool _lastWasSubmit = false;
  TaskResult? _graded;

  @override
  void initState() {
    super.initState();
    _code.text = _problem?.starterCode[_lang] ?? '';
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _judge(bool submit) async {
    final LeetcodeProblem? p = _problem;
    if (p == null) return;
    final JudgeResult r = await careerStore(context).judge.judge(problem: p, languageId: _lang, code: _code.text, submit: submit);
    if (!mounted) return;
    setState(() {
      _last = r;
      _lastWasSubmit = submit;
    });
    if (submit) {
      final TaskResult? t = TaskGrader.fromJudge(widget.spec, r);
      if (t != null) {
        await widget.onGraded(t);
        if (mounted) setState(() => _graded = t);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final LeetcodeProblem? p = _problem;
    if (p == null) {
      return const Text('This exercise is not available in the problem bank.', style: TextStyle(color: VuV2Colors.danger));
    }
    final JudgeResult? r = _last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final String line in widget.spec.context) Text('• $line', style: TextStyle(color: VuV2Colors.mute)),
        _exhibit(p.description.replaceAll('**', '').replaceAll('`', '')),
        const SizedBox(height: 8),
        for (final LeetcodeExample e in p.examples.take(2))
          Padding(padding: const EdgeInsets.only(bottom: 6), child: _mono('Input: ${e.input}\nOutput: ${e.output}')),
        Row(
          children: <Widget>[
            Text('Language', style: TextStyle(color: VuV2Colors.mute)),
            const SizedBox(width: 10),
            DropdownButton<String>(
              key: const ValueKey<String>('code_lang'),
              value: _lang,
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'python3', child: Text('Python 3')),
                DropdownMenuItem<String>(value: 'javascript', child: Text('JavaScript')),
              ],
              onChanged: (String? v) {
                if (v == null || v == _lang) return;
                setState(() {
                  _lang = v;
                  _code.text = p.starterCode[v] ?? '';
                });
              },
            ),
          ],
        ),
        TextField(
          key: const ValueKey<String>('code_editor'),
          controller: _code,
          minLines: 10,
          maxLines: 24,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Your code'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            BusyButton(key: const ValueKey<String>('code_run'), label: 'Run sample tests', icon: Icons.play_arrow_rounded, tonal: true, onPressed: () => _judge(false)),
            BusyButton(key: const ValueKey<String>('code_submit'), label: 'Submit to judge', icon: Icons.cloud_upload_rounded, onPressed: () => _judge(true)),
          ],
        ),
        if (r != null) ...<Widget>[
          const SizedBox(height: 10),
          Container(
            key: const ValueKey<String>('judge_verdict'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: VuV2Colors.navyElevated, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${_lastWasSubmit ? 'Submit' : 'Run'}: ${r.verdict}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: r.accepted ? VuV2Colors.success : VuV2Colors.ink)),
                if (!r.notGraded) Text('${r.passed}/${r.total} tests passed${r.runtimeMs == null ? '' : ' · ${r.runtimeMs!.toStringAsFixed(0)} ms'}'),
                if (r.message.isNotEmpty) Text(r.message, style: TextStyle(color: VuV2Colors.mute)),
                for (final JudgeCase c in r.cases.where((JudgeCase c) => !c.passed && !c.hidden).take(1))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _mono('Input: ${c.input ?? ''}\nExpected: ${c.expected ?? ''}\nGot: ${c.output ?? c.error ?? ''}'),
                  ),
                if (r.stderr.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: _mono(r.stderr)),
              ],
            ),
          ),
        ],
        if (_graded != null) ResultPanel(result: _graded!),
      ],
    );
  }
}

// ------------------------------------------------------------------ decision

class _DecisionView extends StatefulWidget {
  const _DecisionView({required this.spec, required this.onGraded, required this.allowRetry});
  final DecisionTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_DecisionView> createState() => _DecisionViewState();
}

class _DecisionViewState extends State<_DecisionView> with _Graded<_DecisionView> {
  late List<int> _choices = List<int>.filled(widget.spec.steps.length, -1);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() => _choices = List<int>.filled(widget.spec.steps.length, -1);

  int get _revealed {
    int i = 0;
    while (i < _choices.length && _choices[i] >= 0) {
      i++;
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    final int shown = (_revealed + 1).clamp(1, widget.spec.steps.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _exhibit(widget.spec.setting),
        const SizedBox(height: 8),
        _facts(widget.spec.facts),
        const SizedBox(height: 12),
        for (int s = 0; s < shown; s++) ...<Widget>[
          if (widget.spec.steps[s].update.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: <Widget>[
                const Icon(Icons.update_rounded, size: 16, color: Color(0xFF3B82F6)),
                const SizedBox(width: 6),
                Expanded(child: Text(widget.spec.steps[s].update, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600))),
              ]),
            ),
          Text('Step ${s + 1}. ${widget.spec.steps[s].prompt}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (int o = 0; o < widget.spec.steps[s].options.length; o++)
            _Option(
              key: ValueKey<String>('opt_${s}_$o'),
              text: widget.spec.steps[s].options[o].text,
              selected: _choices[s] == o,
              onTap: graded != null ? null : () => setState(() => _choices[s] = o),
            ),
          const SizedBox(height: 8),
        ],
        footer(() => submitWith(widget.spec, DecisionAnswer(List<int>.from(_choices)))),
      ],
    );
  }
}

// ------------------------------------------------------------------ workup

class _WorkupView extends StatefulWidget {
  const _WorkupView({required this.spec, required this.onGraded, required this.allowRetry});
  final WorkupTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_WorkupView> createState() => _WorkupViewState();
}

class _WorkupViewState extends State<_WorkupView> with _Graded<_WorkupView> {
  final Set<int> _picked = <int>{};
  bool _ordered = false;
  int _dx = -1;
  late List<int> _mgmt = List<int>.filled(widget.spec.management.length, -1);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() {
    _picked.clear();
    _ordered = false;
    _dx = -1;
    _mgmt = List<int>.filled(widget.spec.management.length, -1);
  }

  @override
  Widget build(BuildContext context) {
    final WorkupTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _exhibit(s.presentation),
        const SizedBox(height: 8),
        _facts(s.facts),
        const SizedBox(height: 12),
        Text('1. Order investigations (up to ${s.maxInvestigations})', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
        for (int i = 0; i < s.investigations.length; i++)
          CheckboxListTile(
            key: ValueKey<String>('inv_$i'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _picked.contains(i),
            title: Text(s.investigations[i].name),
            subtitle: _ordered && _picked.contains(i)
                ? Text('Result: ${s.investigations[i].result}', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600))
                : null,
            onChanged: _ordered
                ? null
                : (bool? v) => setState(() {
                      if (v == true) {
                        if (_picked.length < s.maxInvestigations) _picked.add(i);
                      } else {
                        _picked.remove(i);
                      }
                    }),
          ),
        if (!_ordered)
          FilledButton.tonal(
            key: const ValueKey<String>('order_tests'),
            onPressed: _picked.isEmpty ? null : () => setState(() => _ordered = true),
            child: const Text('Order and view results'),
          ),
        if (_ordered) ...<Widget>[
          const SizedBox(height: 12),
          Text('2. Working diagnosis', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
          for (int d = 0; d < s.diagnoses.length; d++)
            _Option(key: ValueKey<String>('dx_$d'), text: s.diagnoses[d], selected: _dx == d, onTap: graded != null ? null : () => setState(() => _dx = d)),
          const SizedBox(height: 8),
          Text('3. Management', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
          for (int m = 0; m < s.management.length; m++) ...<Widget>[
            Text(s.management[m].prompt, style: TextStyle(color: VuV2Colors.ink)),
            for (int o = 0; o < s.management[m].options.length; o++)
              _Option(
                key: ValueKey<String>('mg_${m}_$o'),
                text: s.management[m].options[o].text,
                selected: _mgmt[m] == o,
                onTap: graded != null ? null : () => setState(() => _mgmt[m] = o),
              ),
          ],
          footer(() async {
            if (_dx < 0) {
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Choose a working diagnosis.')));
              return;
            }
            await submitWith(s, WorkupAnswer(ordered: Set<int>.from(_picked), diagnosis: _dx, management: List<int>.from(_mgmt)));
          }),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------ numeric

double? parseNumber(String raw) {
  final String t = raw.trim().replaceAll(',', '').replaceAll('£', '').replaceAll('%', '');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

class _NumericView extends StatefulWidget {
  const _NumericView({required this.spec, required this.onGraded, required this.allowRetry});
  final NumericTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_NumericView> createState() => _NumericViewState();
}

class _NumericViewState extends State<_NumericView> with _Graded<_NumericView> {
  late final List<TextEditingController> _c =
      List<TextEditingController>.generate(widget.spec.parts.length, (_) => TextEditingController());

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() {
    for (final TextEditingController c in _c) {
      c.clear();
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NumericTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _facts(s.givens),
        if (TechDiagram.known.contains(s.diagram)) ...<Widget>[const SizedBox(height: 10), TechDiagram(id: s.diagram)],
        const SizedBox(height: 12),
        for (int i = 0; i < s.parts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              key: ValueKey<String>('num_$i'),
              controller: _c[i],
              enabled: graded == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '(${String.fromCharCode(97 + i)}) ${s.parts[i].prompt}',
                suffixText: s.parts[i].unit,
              ),
            ),
          ),
        footer(() async {
          final List<double?> values = _c.map((TextEditingController c) => parseNumber(c.text)).toList();
          await submitWith(s, NumericAnswer(values));
        }),
      ],
    );
  }
}

// ------------------------------------------------------------------ ledger

class _LedgerView extends StatefulWidget {
  const _LedgerView({required this.spec, required this.onGraded, required this.allowRetry});
  final LedgerTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<_LedgerView> with _Graded<_LedgerView> {
  late List<String?> _dr = List<String?>.filled(widget.spec.transactions.length, null);
  late List<String?> _cr = List<String?>.filled(widget.spec.transactions.length, null);
  late final List<TextEditingController> _amt =
      List<TextEditingController>.generate(widget.spec.transactions.length, (_) => TextEditingController());

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() {
    _dr = List<String?>.filled(widget.spec.transactions.length, null);
    _cr = List<String?>.filled(widget.spec.transactions.length, null);
    for (final TextEditingController c in _amt) {
      c.clear();
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _amt) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _acct(String key, String label, String? value, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        key: ValueKey<String>(attempt == 0 ? key : '${key}_r$attempt'),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        items: <DropdownMenuItem<String>>[
          for (final String a in widget.spec.accounts) DropdownMenuItem<String>(value: a, child: Text(a, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: graded == null ? onChanged : null,
      );

  @override
  Widget build(BuildContext context) {
    final LedgerTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < s.transactions.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('${i + 1}. ${s.transactions[i].description}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _acct('dr_$i', 'Debit', _dr[i], (String? v) => setState(() => _dr[i] = v)),
                const SizedBox(height: 8),
                _acct('cr_$i', 'Credit', _cr[i], (String? v) => setState(() => _cr[i] = v)),
                const SizedBox(height: 8),
                TextField(
                  key: ValueKey<String>('amt_$i'),
                  controller: _amt[i],
                  enabled: graded == null,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '£ ', border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
          ),
        footer(() => submitWith(
              s,
              LedgerAnswer(<LedgerLineInput>[
                for (int i = 0; i < s.transactions.length; i++)
                  LedgerLineInput(debit: _dr[i], credit: _cr[i], amount: parseNumber(_amt[i].text)),
              ]),
            )),
      ],
    );
  }
}

// ------------------------------------------------------------------ classify

class _ClassifyView extends StatefulWidget {
  const _ClassifyView({required this.spec, required this.onGraded, required this.allowRetry});
  final ClassifyTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_ClassifyView> createState() => _ClassifyViewState();
}

class _ClassifyViewState extends State<_ClassifyView> with _Graded<_ClassifyView> {
  late List<String?> _picks = List<String?>.filled(widget.spec.items.length, null);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() => _picks = List<String?>.filled(widget.spec.items.length, null);

  @override
  Widget build(BuildContext context) {
    final ClassifyTaskSpec s = widget.spec;
    final bool code = s.style == ClassifyStyle.codeReview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (s.exhibit.isNotEmpty) ...<Widget>[code ? _mono(s.exhibit) : _exhibit(s.exhibit), const SizedBox(height: 10)],
        for (int i = 0; i < s.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Item ${i + 1}', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
                const SizedBox(height: 4),
                if (code) _mono(s.items[i].text) else Text(s.items[i].text, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (int c = 0; c < s.categories.length; c++)
                      ChoiceChip(
                        key: ValueKey<String>('cls_${i}_$c'),
                        label: Text(s.categories[c]),
                        selected: _picks[i] == s.categories[c],
                        onSelected: graded != null ? null : (_) => setState(() => _picks[i] = s.categories[c]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        footer(() => submitWith(s, ClassifyAnswer(List<String?>.from(_picks)))),
      ],
    );
  }
}

// ------------------------------------------------------------------ order

/// Deterministic starting order that is never already correct.
List<int> scrambledOrder(int n) {
  if (n < 2) return List<int>.generate(n, (int i) => i);
  return <int>[for (int i = 1; i < n; i += 2) i, for (int i = 0; i < n; i += 2) i];
}

class _OrderView extends StatefulWidget {
  const _OrderView({required this.spec, required this.onGraded, required this.allowRetry});
  final OrderTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<_OrderView> with _Graded<_OrderView> {
  late List<int> _order = scrambledOrder(widget.spec.steps.length);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() => _order = scrambledOrder(widget.spec.steps.length);

  void _move(int pos, int delta) {
    final int to = pos + delta;
    if (to < 0 || to >= _order.length) return;
    setState(() {
      final int t = _order[pos];
      _order[pos] = _order[to];
      _order[to] = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrderTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int p = 0; p < _order.length; p++)
          Container(
            key: ValueKey<String>('ord_row_$p'),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: VuV2Colors.navyElevated, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: <Widget>[
                Text('${p + 1}.', style: TextStyle(color: VuV2Colors.mute, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: Text(s.steps[_order[p]], style: TextStyle(color: VuV2Colors.ink))),
                IconButton(
                  key: ValueKey<String>('ord_up_$p'),
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  onPressed: graded != null || p == 0 ? null : () => _move(p, -1),
                ),
                IconButton(
                  key: ValueKey<String>('ord_down_$p'),
                  tooltip: 'Move down',
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  onPressed: graded != null || p == _order.length - 1 ? null : () => _move(p, 1),
                ),
              ],
            ),
          ),
        footer(() => submitWith(s, OrderAnswer(List<int>.from(_order)))),
      ],
    );
  }
}

// ------------------------------------------------------------------ written

class WrittenField extends StatelessWidget {
  const WrittenField({super.key, required this.controller, required this.rubric, this.minWords = 0, this.enabled = true, this.label = 'Your answer', this.fieldKey});

  final TextEditingController controller;
  final List<Concept> rubric;
  final int minWords;
  final bool enabled;
  final String label;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          key: fieldKey,
          controller: controller,
          enabled: enabled,
          minLines: 6,
          maxLines: 16,
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label, alignLabelWithHint: true),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue v, _) {
            final int n = TextRubric.words(v.text).length;
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('$n words${minWords > 0 ? ' (minimum $minWords)' : ''}',
                  style: TextStyle(color: n < minWords ? VuV2Colors.danger : VuV2Colors.mute, fontSize: 12)),
            );
          },
        ),
        if (rubric.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text('The rubric checks that you address:', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          BulletList(rubric.map((Concept c) => c.label).toList(), icon: Icons.check_box_outline_blank_rounded),
        ],
      ],
    );
  }
}

class _WrittenView extends StatefulWidget {
  const _WrittenView({required this.spec, required this.onGraded, required this.allowRetry, this.onText});
  final void Function(String text)? onText;
  final WrittenTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_WrittenView> createState() => _WrittenViewState();
}

class _WrittenViewState extends State<_WrittenView> with _Graded<_WrittenView> {
  final TextEditingController _t = TextEditingController();

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() {}

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WrittenTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (s.exhibit.isNotEmpty) ...<Widget>[_exhibit(s.exhibit), const SizedBox(height: 10)],
        WrittenField(
          fieldKey: const ValueKey<String>('written_answer'),
          controller: _t,
          rubric: s.rubric,
          minWords: s.minWords,
          enabled: graded == null,
        ),
        footer(() async {
          widget.onText?.call(_t.text);
          await submitWith(s, WrittenAnswer(_t.text));
        }),
      ],
    );
  }
}

// ------------------------------------------------------------------ label

class _LabelView extends StatefulWidget {
  const _LabelView({required this.spec, required this.onGraded, required this.allowRetry});
  final LabelTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_LabelView> createState() => _LabelViewState();
}

class _LabelViewState extends State<_LabelView> with _Graded<_LabelView> {
  late List<String?> _labels = List<String?>.filled(widget.spec.hotspots.length, null);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() => _labels = List<String?>.filled(widget.spec.hotspots.length, null);

  @override
  Widget build(BuildContext context) {
    final LabelTaskSpec s = widget.spec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TechDiagram(
          id: s.diagram,
          markers: s.hotspots.map((Hotspot h) => Offset(h.x, h.y)).toList(),
          labels: _labels,
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < s.hotspots.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DropdownButtonFormField<String>(
              key: ValueKey<String>(attempt == 0 ? 'lbl_$i' : 'lbl_${i}_r$attempt'),
              initialValue: _labels[i],
              isExpanded: true,
              decoration: InputDecoration(labelText: 'Marker ${i + 1}', border: const OutlineInputBorder(), isDense: true),
              items: <DropdownMenuItem<String>>[
                for (final String l in s.labelBank) DropdownMenuItem<String>(value: l, child: Text(l)),
              ],
              onChanged: graded == null ? (String? v) => setState(() => _labels[i] = v) : null,
            ),
          ),
        footer(() => submitWith(s, LabelAnswer(List<String?>.from(_labels)))),
      ],
    );
  }
}

// ------------------------------------------------------------------ courtroom

class _CourtView extends StatefulWidget {
  const _CourtView({required this.spec, required this.onGraded, required this.allowRetry});
  final CourtroomTaskSpec spec;
  final Future<void> Function(TaskResult) onGraded;
  final bool allowRetry;

  @override
  State<_CourtView> createState() => _CourtViewState();
}

class _CourtViewState extends State<_CourtView> with _Graded<_CourtView> {
  late List<String?> _rulings = List<String?>.filled(widget.spec.transcript.length, null);
  late List<bool> _decided = List<bool>.filled(widget.spec.transcript.length, false);

  @override
  Future<void> Function(TaskResult) get onGradedCb => widget.onGraded;
  @override
  bool get retry => widget.allowRetry;
  @override
  void resetAnswer() {
    _rulings = List<String?>.filled(widget.spec.transcript.length, null);
    _decided = List<bool>.filled(widget.spec.transcript.length, false);
  }

  int get _current {
    int i = 0;
    while (i < _decided.length && _decided[i]) {
      i++;
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    final CourtroomTaskSpec s = widget.spec;
    final int cur = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF3E2723), borderRadius: BorderRadius.circular(10)),
          child: Text('🏛️  ${s.caseName}\nYou: ${s.role}', style: const TextStyle(color: Color(0xFFFFECB3), fontWeight: FontWeight.w700, height: 1.4)),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < s.transcript.length && i <= cur; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(s.transcript[i].speaker.toUpperCase(), style: TextStyle(color: VuV2Colors.mute, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text('“${s.transcript[i].text}”', style: TextStyle(color: VuV2Colors.ink, fontSize: 15, height: 1.35)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    ChoiceChip(
                      key: ValueKey<String>('court_${i}_none'),
                      label: const Text('No objection'),
                      selected: _decided[i] && _rulings[i] == null,
                      onSelected: graded != null
                          ? null
                          : (_) => setState(() {
                                _rulings[i] = null;
                                _decided[i] = true;
                              }),
                    ),
                    for (int g = 0; g < s.grounds.length; g++)
                      ChoiceChip(
                        key: ValueKey<String>('court_${i}_$g'),
                        label: Text('Objection — ${s.grounds[g]}'),
                        selected: _decided[i] && _rulings[i] == s.grounds[g],
                        onSelected: graded != null
                            ? null
                            : (_) => setState(() {
                                  _rulings[i] = s.grounds[g];
                                  _decided[i] = true;
                                }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        if (cur >= s.transcript.length)
          footer(() => submitWith(s, CourtroomAnswer(List<String?>.from(_rulings))))
        else
          Text('Rule on line ${cur + 1} to continue the examination.', style: TextStyle(color: VuV2Colors.mute)),
      ],
    );
  }
}

/// Full-screen wrapper for a task.
class TaskRunnerScreen extends StatelessWidget {
  const TaskRunnerScreen({super.key, required this.spec, required this.onGraded, this.contextLabel = '', this.lecturerContext, this.onText});

  final void Function(String text)? onText;
  final TaskSpec spec;
  final Future<void> Function(TaskResult result) onGraded;
  final String contextLabel;

  /// When set, an AI lecturer panel is offered (guidance only).
  final String? lecturerContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contextLabel.isEmpty ? spec.title : contextLabel)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: <Widget>[
            TaskView(spec: spec, onGraded: onGraded, onText: onText),
            if (lecturerContext != null) ...<Widget>[
              const SizedBox(height: 20),
              ExpansionTile(
                key: const ValueKey<String>('ask_lecturer'),
                tilePadding: EdgeInsets.zero,
                title: const Text('Ask the AI lecturer for a hint'),
                children: <Widget>[
                  AiAssistPanel(
                    role: CareerAiRole.lecturer,
                    contextText: '${lecturerContext!}\nTask: ${spec.title}. ${spec.brief}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
