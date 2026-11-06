import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/work/work_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/work/drawing_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('design scenarios use a different worked case at each level', () {
    // Group hand calculations by design problem: ids look like prefix_key_level_calc.
    final Map<String, Map<String, List<double>>> byProblem = <String, Map<String, List<double>>>{};
    for (final LabSpec l in LabCatalog.all) {
      for (final LabScenario s in l.scenarios) {
        final bool design = s.steps.any((LabStep st) => st is SimulationStep);
        for (final LabStep st in s.steps) {
          if (!design || st is! NumericStep || !st.id.endsWith('_calc')) continue;
          final List<String> parts = st.id.split('_');
          final String key = '${l.id}/${parts.sublist(0, parts.length - 2).join('_')}';
          (byProblem[key] ??= <String, List<double>>{})[parts[parts.length - 2]] = <double>[
            for (final MathQuestion q in st.questions)
              if (q is NumberQuestion) q.answer,
          ];
        }
      }
    }
    expect(byProblem.length, greaterThan(100));
    int varied = 0;
    final List<String> same = <String>[];
    for (final MapEntry<String, Map<String, List<double>>> e in byProblem.entries) {
      final List<List<double>> levels = e.value.values.toList();
      final Set<String> distinct = <String>{for (final List<double> a in levels) a.map((double v) => v.toStringAsPrecision(8)).join(',')};
      if (distinct.length == levels.length) {
        varied++;
      } else {
        same.add(e.key);
      }
      for (final List<double> a in levels) {
        for (final double v in a) {
          expect(v.isFinite, isTrue, reason: '${e.key}: hand-calculation answer must be finite');
        }
      }
    }
    expect(varied / byProblem.length, greaterThan(0.9), reason: 'Problems repeating a worked case: ${same.join(', ')}');
  });

  test('no scenario repeats another scenario of the same task step for step', () {
    String sig(LabStep st) => switch (st) {
          TriageStep() => 'triage:${st.items.map((TriageItem i) => i.body).join('/')}',
          NumericStep() => 'numeric:${st.questions.map((MathQuestion q) => '${q.prompt}${q is NumberQuestion ? '=${q.answer}' : ''}').join('/')}',
          SimulationStep() => 'sim:${st.inputs.map((SimInput i) => i.name).join()}:${st.constraints.map((SimConstraint c) => '${c.output}${c.op}${c.value}').join(',')}',
          DrawingStep() => 'draw:${st.title}:${st.spec.requireDimensions}:${st.spec.holes.map((HoleSpec h) => h.tol).join(',')}',
          _ => '${st.runtimeType}:${st.title}:${st.instructions}',
        };
    final List<String> dup = <String>[];
    for (final LabSpec l in LabCatalog.all) {
      final Map<String, String> seen = <String, String>{};
      for (final LabScenario s in l.scenarios) {
        final String key = s.steps.map(sig).join(' | ');
        final String? other = seen[key];
        if (other != null) dup.add('${l.id}: ${s.id} repeats $other');
        seen[key] = s.id;
      }
    }
    expect(dup, isEmpty, reason: dup.take(20).join('\n'));
  });
}
