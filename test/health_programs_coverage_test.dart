import 'package:ai_study_buddy/vu_v2/health_career/health_career_content.dart';
import 'package:ai_study_buddy/vu_v2/health_career/models/clinical_scenario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all eight programs have distinct hub focus tags', () {
    final Set<String> focuses =
        HealthPrograms.all.map((HealthProgram p) => p.hubFocus).toSet();
    expect(focuses.length, greaterThanOrEqualTo(6));
    expect(HealthPrograms.all.length, 8);
  });

  test('dyspnea critical penicillin fails', () {
    final ClinicalEvaluation e = ClinicalScenarioEngine.evaluate(
      scenario: ClinicalScenarioCatalog.dyspneaWard,
      measured: ClinicalInstrument.values.toSet(),
      flaggedAbnormal:
          ClinicalScenarioCatalog.dyspneaWard.expectedAbnormals.toSet(),
      chosenActionIds: const <String>{'give_penicillin'},
      askedKeys: ClinicalScenarioCatalog.dyspneaWard.interviewKeys.toSet(),
    );
    expect(e.criticalFail, isTrue);
  });
}
