import 'package:ai_study_buddy/career_sim/labs/lab_blueprint.g.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_grading.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// The development tracker (tool/lab_tracker.py) must tell the truth about the app.
void main() {
  test('every built lab is in the tracker with its real scenario count', () {
    for (final LabSpec lab in LabCatalog.all) {
      final List<BlueprintLab> rows = blueprintLabs.where((BlueprintLab b) => b.labId == lab.id).toList();
      expect(rows, hasLength(1), reason: '${lab.id} must appear once in tool/lab_tracker.py');
      expect(rows.single.scenarios, lab.scenarios.length, reason: 'update SCENARIOS for ${lab.id} in tool/lab_tracker.py');
      expect(rows.single.majorId, lab.majorId, reason: lab.id);
    }
  });

  test('every tracker lab marked as built exists', () {
    for (final BlueprintLab b in blueprintLabs.where((BlueprintLab b) => b.built)) {
      expect(LabCatalog.lab(b.labId), isNotNull, reason: b.labId);
      expect(b.status, isNot('not_started'));
    }
  });

  test('a lab is only "tested" with 5 scenarios at each level', () {
    for (final BlueprintLab b in blueprintLabs.where((BlueprintLab b) => b.status == 'tested' || b.status == 'verified')) {
      final LabSpec lab = LabCatalog.lab(b.labId)!;
      for (final LabDifficulty level in LabDifficulty.values) {
        expect(lab.atLevel(level).length, greaterThanOrEqualTo(5), reason: '${lab.id} ${level.label}');
      }
    }
  });

  test('step ids are unique within each lab (results are saved by step id)', () {
    for (final LabSpec lab in LabCatalog.all) {
      final List<String> ids = <String>[for (final LabScenario s in lab.scenarios) ...s.steps.map((LabStep st) => st.id)];
      expect(ids.toSet().length, ids.length, reason: lab.id);
      expect(lab.scenarios.map((LabScenario s) => s.id).toSet().length, lab.scenarios.length, reason: lab.id);
    }
  });

  test('levels unlock in order', () {
    for (final LabSpec lab in LabCatalog.all) {
      bool none(String _) => false;
      for (final LabScenario s in lab.scenarios) {
        final bool open = LabGrader.scenarioUnlocked(lab, s, none);
        if (s.level == LabDifficulty.foundation || lab.atLevel(LabDifficulty.values[s.level.index - 1]).isEmpty) {
          expect(open, isTrue, reason: s.id);
        } else {
          expect(open, isFalse, reason: s.id);
        }
      }
      expect(LabGrader.nextScenario(lab, none)?.level, LabDifficulty.foundation, reason: lab.id);
    }
  });
}
