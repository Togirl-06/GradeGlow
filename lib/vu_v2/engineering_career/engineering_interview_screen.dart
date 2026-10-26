import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_sims.dart';

class EngineeringInterviewScreen extends StatefulWidget {
  const EngineeringInterviewScreen({
    super.key,
    required this.progress,
    this.forJobId,
  });

  final EngineeringCareerProgress progress;
  final String? forJobId;

  @override
  State<EngineeringInterviewScreen> createState() =>
      _EngineeringInterviewScreenState();
}

class _EngineeringInterviewScreenState
    extends State<EngineeringInterviewScreen> {
  int _step = 0;
  int _score = 0;
  String? _feedback;
  final TextEditingController _typed = TextEditingController();

  static const List<_Q> _qs = <_Q>[
    _Q(
      prompt:
          'Behavioral: Tell me about a time you revised a design after a failed test.',
      kind: _QKind.typed,
      rubricHint: 'Mention failure → diagnosis → change → retest.',
    ),
    _Q(
      prompt:
          'Technical: A 4 kg payload hangs at 0.75 m horizontal reach. '
          'Approx. required joint torque (N·m)? (use g = 9.81)',
      kind: _QKind.calc,
      correct: 29.43, // 4*9.81*0.75
      tolerance: 1.5,
    ),
    _Q(
      prompt:
          'Design scenario: Motor is undersized by 20% vs required torque with SF. Best next step?',
      kind: _QKind.choice,
      choices: <String>[
        'Ignore SF and ship',
        'Shorten reach or upsize motor, then re-simulate',
        'Double the mass to stress-test',
      ],
      correctIndex: 1,
    ),
  ];

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  void _answerChoice(int index) {
    final _Q q = _qs[_step];
    final bool ok = index == q.correctIndex;
    setState(() {
      if (ok) _score++;
      _feedback = ok
          ? 'Correct — iterate design parameters and re-validate.'
          : 'Not quite — safety factors exist for a reason.';
    });
  }

  void _answerCalc() {
    final _Q q = _qs[_step];
    final double? v = double.tryParse(_typed.text.trim());
    final bool ok =
        v != null && (v - (q.correct ?? 0)).abs() <= (q.tolerance ?? 0);
    setState(() {
      if (ok) _score++;
      _feedback = ok
          ? 'Correct. τ ≈ m·g·L = ${(q.correct ?? 0).toStringAsFixed(2)} N·m.'
          : 'Expected ≈ ${(q.correct ?? 0).toStringAsFixed(2)} N·m '
              '(${EngineeringSims.disclaimer})';
    });
  }

  void _answerTyped() {
    final String t = _typed.text.trim().toLowerCase();
    final bool ok = t.length >= 40 &&
        (t.contains('fail') || t.contains('test') || t.contains('revis'));
    setState(() {
      if (ok) _score++;
      _feedback = ok
          ? 'Solid structure — you hit diagnosis and iteration.'
          : 'Add more detail: failure, root cause, change, and retest.';
    });
  }

  Future<void> _next() async {
    if (_feedback == null) return;
    if (_step < _qs.length - 1) {
      setState(() {
        _step++;
        _feedback = null;
        _typed.clear();
      });
      return;
    }
    final bool passed = _score >= 2;
    final String? jobId = widget.forJobId;
    if (jobId != null) {
      await widget.progress.advanceAfterInterview(jobId, passed: passed);
    } else {
      await widget.progress.recordInterview(passed: passed);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        backgroundColor: EngCosmic.panel,
        title: Text(
          passed ? 'Interview passed' : 'Interview needs work',
          style: const TextStyle(color: EngCosmic.ink),
        ),
        content: Text(
          passed
              ? 'Score $_score/${_qs.length}. '
                  '${jobId != null ? 'Check Career Center for your offer.' : 'You can now apply more confidently.'}'
              : 'Score $_score/${_qs.length}. Review torque basics and try again.',
          style: const TextStyle(color: EngCosmic.mute),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _Q q = _qs[_step];
    final EngJob? job =
        widget.forJobId == null ? null : EngJobs.byId(widget.forJobId!);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Interview Center',
        icon: Icons.record_voice_over_rounded,
        subtitle: 'Step ${_step + 1}/${_qs.length}',
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: EngCosmic.panelBox(radius: 16),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: EngCosmic.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Jordan Hale',
                          style: TextStyle(
                            color: EngCosmic.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          job == null
                              ? 'Engineering recruiter · practice loop'
                              : 'Hiring manager · ${job.company}',
                          style: const TextStyle(
                            color: EngCosmic.mute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 16),
              child: Text(
                q.prompt,
                style: const TextStyle(
                  color: EngCosmic.ink,
                  height: 1.4,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (q.kind == _QKind.choice)
              ...List<Widget>.generate(q.choices!.length, (int i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _feedback == null ? () => _answerChoice(i) : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EngCosmic.ink,
                      side: const BorderSide(color: EngCosmic.stroke),
                      minimumSize: const Size.fromHeight(48),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(q.choices![i]),
                  ),
                );
              })
            else ...<Widget>[
              TextField(
                controller: _typed,
                maxLines: q.kind == _QKind.typed ? 4 : 1,
                keyboardType: q.kind == _QKind.calc
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.multiline,
                style: const TextStyle(color: EngCosmic.ink),
                decoration: InputDecoration(
                  hintText: q.kind == _QKind.calc
                      ? 'Enter number (N·m)'
                      : 'Type your answer',
                  hintStyle: const TextStyle(color: EngCosmic.mute),
                  filled: true,
                  fillColor: EngCosmic.panelAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: EngCosmic.stroke),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _feedback == null
                    ? (q.kind == _QKind.calc ? _answerCalc : _answerTyped)
                    : null,
                child: const Text('Submit answer'),
              ),
            ],
            if (_feedback != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _feedback!,
                style: const TextStyle(color: EngCosmic.electric, height: 1.35),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  backgroundColor: EngCosmic.success,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  _step < _qs.length - 1 ? 'Next question' : 'Finish interview',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _QKind { typed, calc, choice }

class _Q {
  const _Q({
    required this.prompt,
    required this.kind,
    this.choices,
    this.correctIndex,
    this.correct,
    this.tolerance,
    this.rubricHint,
  });

  final String prompt;
  final _QKind kind;
  final List<String>? choices;
  final int? correctIndex;
  final double? correct;
  final double? tolerance;
  final String? rubricHint;
}
