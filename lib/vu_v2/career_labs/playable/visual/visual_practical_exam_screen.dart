import 'package:flutter/material.dart';

import '../shared/playable_cinematic.dart';
import 'visual_lab_catalog.dart';
import 'visual_lab_dispatch.dart';
import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Multi-step practical exam: runs 2–3 embedded visual labs, then scores.
class VisualPracticalExamScreen extends StatefulWidget {
  const VisualPracticalExamScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualPracticalExamScreen> createState() => _VisualPracticalExamScreenState();
}

class _VisualPracticalExamScreenState extends State<VisualPracticalExamScreen> {
  final Map<String, bool> _results = <String, bool>{};
  int _cursor = 0;

  VisualLabSpec get spec => widget.spec;

  List<VisualLabSpec> get _steps {
    final List<VisualLabSpec> out = <VisualLabSpec>[];
    for (final String id in spec.practicalStepIds) {
      final VisualLabSpec? s = VisualLabCatalog.byId(id);
      if (s != null) out.add(s);
    }
    return out;
  }

  int get _passedCount => _results.values.where((bool v) => v).length;

  double get _score {
    final int n = _steps.length;
    if (n == 0) return 0;
    return _passedCount / n;
  }

  Future<void> _runStep(int index) async {
    final List<VisualLabSpec> steps = _steps;
    if (index < 0 || index >= steps.length) return;
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => buildVisualLabScreen(steps[index]),
      ),
    );
    if (!mounted) return;
    setState(() {
      _results[steps[index].id] = ok ?? false;
      if ((ok ?? false) && index == _cursor && _cursor < steps.length - 1) {
        _cursor++;
      }
    });
  }

  Future<void> _finish() async {
    final bool passed = _score >= spec.passThreshold;
    await showPlayableCinematic(
      context: context,
      accent: spec.accent,
      bg: spec.bg,
      surface: spec.surface,
      eyebrow: 'Supervisor score',
      title: passed ? 'Practical passed.' : 'Remediation needed.',
      body: passed
          ? 'You cleared ${(_score * 100).round()}% of stations '
              '($_passedCount / ${_steps.length}). Shift credit awarded.'
          : 'Score ${(_score * 100).round()}% — need '
              '${(spec.passThreshold * 100).round()}%+. Re-run failed stations.',
      cta: passed ? 'CLOCK OUT' : 'BACK TO STATIONS',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final List<VisualLabSpec> steps = _steps;

    return VisualLabShell(
      spec: spec,
      badgeLabel: 'PRACTICAL EXAM',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: _results.length >= steps.length ? 'VIEW SUPERVISOR SCORE' : 'COMPLETE ALL STATIONS',
        onPressed: _results.length >= steps.length ? _finish : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Complete each station in sequence. Pass threshold: '
                '${(spec.passThreshold * 100).round()}%.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: steps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int i) {
                  final VisualLabSpec step = steps[i];
                  final bool? result = _results[step.id];
                  final bool unlocked = i == 0 || (_results[steps[i - 1].id] == true) || i <= _cursor;
                  return InkWell(
                    onTap: unlocked ? () => _runStep(i) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? Colors.black.withValues(alpha: 0.45)
                            : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: result == true
                              ? spec.accent
                              : result == false
                                  ? Colors.redAccent.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: spec.accent.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: spec.accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    color: unlocked ? Colors.white : Colors.white38,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  step.kind.name.toUpperCase(),
                                  style: TextStyle(
                                    color: spec.accent.withValues(alpha: unlocked ? 0.9 : 0.4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            result == true
                                ? Icons.check_circle
                                : result == false
                                    ? Icons.cancel
                                    : unlocked
                                        ? Icons.play_circle_outline
                                        : Icons.lock_outline,
                            color: result == true
                                ? spec.accent
                                : result == false
                                    ? Colors.redAccent
                                    : Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
