import 'patient_profile.dart';

enum ClinicalInstrument { stethoscope, thermometer, bpCuff, pulseOx }

class InstrumentFinding {
  const InstrumentFinding({
    required this.instrument,
    required this.summary,
    required this.abnormal,
    this.audioHint,
  });

  final ClinicalInstrument instrument;
  final String summary;
  final bool abnormal;
  final String? audioHint;
}

class ClinicalAction {
  const ClinicalAction({
    required this.id,
    required this.label,
    required this.safe,
    required this.feedback,
    this.scoreDelta = 0,
  });

  final String id;
  final String label;
  final bool safe;
  final String feedback;
  final int scoreDelta;
}

class ClinicalScenario {
  const ClinicalScenario({
    required this.id,
    required this.courseId,
    required this.title,
    required this.objectives,
    required this.patientId,
    required this.difficulty,
    required this.xpReward,
    required this.interviewKeys,
    required this.findings,
    required this.expectedAbnormals,
    required this.actions,
    required this.correctActionIds,
    required this.criticalErrorIds,
    required this.debrief,
  });

  final String id;
  final String courseId;
  final String title;
  final List<String> objectives;
  final String patientId;
  final String difficulty;
  final int xpReward;
  final List<String> interviewKeys;
  final List<InstrumentFinding> findings;
  final List<ClinicalInstrument> expectedAbnormals;
  final List<ClinicalAction> actions;
  final List<String> correctActionIds;
  final List<String> criticalErrorIds;
  final String debrief;

  PatientProfile get patient => PatientCatalog.byId(patientId);

  InstrumentFinding? findingFor(ClinicalInstrument i) {
    for (final InstrumentFinding f in findings) {
      if (f.instrument == i) return f;
    }
    return null;
  }
}

/// Deterministic evaluation — AI must not override these results.
class ClinicalEvaluation {
  const ClinicalEvaluation({
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.notes,
    required this.criticalFail,
  });

  final int score;
  final int maxScore;
  final bool passed;
  final List<String> notes;
  final bool criticalFail;
}

abstract final class ClinicalScenarioEngine {
  static ClinicalEvaluation evaluate({
    required ClinicalScenario scenario,
    required Set<ClinicalInstrument> measured,
    required Set<ClinicalInstrument> flaggedAbnormal,
    required Set<String> chosenActionIds,
    required Set<String> askedKeys,
  }) {
    final List<String> notes = <String>[];
    int score = 0;
    const int max = 100;
    bool critical = false;

    // Interview coverage
    final int asked = askedKeys.intersection(scenario.interviewKeys.toSet()).length;
    final int interviewPts = ((asked / scenario.interviewKeys.length) * 20).round();
    score += interviewPts;
    notes.add('History questions: $asked/${scenario.interviewKeys.length} (+$interviewPts).');

    // Instruments used
    final int instPts = (measured.length.clamp(0, 4) * 10);
    score += instPts;
    notes.add('Instruments used: ${measured.length}/4 (+$instPts).');

    // Abnormal recognition
    int abnOk = 0;
    for (final ClinicalInstrument i in scenario.expectedAbnormals) {
      if (flaggedAbnormal.contains(i)) abnOk++;
    }
    final int abnPts = scenario.expectedAbnormals.isEmpty
        ? 15
        : ((abnOk / scenario.expectedAbnormals.length) * 25).round();
    score += abnPts;
    notes.add('Abnormal findings flagged: $abnOk/${scenario.expectedAbnormals.length} (+$abnPts).');

    // Actions
    for (final String id in chosenActionIds) {
      if (scenario.criticalErrorIds.contains(id)) {
        critical = true;
        notes.add('Critical unsafe action selected ($id).');
      }
    }
    int actionPts = 0;
    for (final String id in scenario.correctActionIds) {
      if (chosenActionIds.contains(id)) actionPts += 10;
    }
    actionPts = actionPts.clamp(0, 30);
    score += actionPts;
    notes.add('Care actions: +$actionPts.');

    if (critical) {
      score = (score * 0.4).round();
      notes.add('Score reduced for safety-critical error.');
    }

    score = score.clamp(0, max);
    return ClinicalEvaluation(
      score: score,
      maxScore: max,
      passed: !critical && score >= 60,
      notes: notes,
      criticalFail: critical,
    );
  }
}

abstract final class ClinicalScenarioCatalog {
  static const ClinicalScenario dyspneaWard = ClinicalScenario(
    id: 'nursing_dyspnea_v1',
    courseId: 'nursing',
    title: 'Ward: Acute dyspnea',
    objectives: <String>[
      'Obtain focused respiratory history',
      'Measure vitals with correct instruments',
      'Identify abnormal SpO₂ and fever',
      'Choose safe first nursing actions',
    ],
    patientId: 'pt_maria_lopez',
    difficulty: 'Beginner',
    xpReward: 140,
    interviewKeys: <String>['onset', 'severity', 'sputum', 'fever'],
    findings: <InstrumentFinding>[
      InstrumentFinding(
        instrument: ClinicalInstrument.pulseOx,
        summary: 'SpO₂ 91% on room air',
        abnormal: true,
        audioHint: 'tone_low_sat',
      ),
      InstrumentFinding(
        instrument: ClinicalInstrument.thermometer,
        summary: 'Temp 38.4 °C',
        abnormal: true,
      ),
      InstrumentFinding(
        instrument: ClinicalInstrument.bpCuff,
        summary: 'BP 148/92 mmHg',
        abnormal: true,
      ),
      InstrumentFinding(
        instrument: ClinicalInstrument.stethoscope,
        summary: 'Coarse crackles at right base; HR 104',
        abnormal: true,
        audioHint: 'crackles_rbase',
      ),
    ],
    expectedAbnormals: <ClinicalInstrument>[
      ClinicalInstrument.pulseOx,
      ClinicalInstrument.thermometer,
      ClinicalInstrument.stethoscope,
    ],
    actions: <ClinicalAction>[
      ClinicalAction(
        id: 'raise_hob_o2',
        label: 'Elevate HOB and apply ordered O₂ per protocol',
        safe: true,
        feedback: 'Supports oxygenation while you escalate.',
        scoreDelta: 10,
      ),
      ClinicalAction(
        id: 'notify_provider',
        label: 'Notify provider of SpO₂ 91% and fever',
        safe: true,
        feedback: 'Timely escalation for hypoxic febrile patient.',
        scoreDelta: 10,
      ),
      ClinicalAction(
        id: 'give_penicillin',
        label: 'Give penicillin for presumed pneumonia',
        safe: false,
        feedback: 'Patient has penicillin allergy — critical error.',
        scoreDelta: -40,
      ),
      ClinicalAction(
        id: 'ignore_vitals',
        label: 'Reassure and recheck in 4 hours',
        safe: false,
        feedback: 'Unsafe delay with SpO₂ 91%.',
        scoreDelta: -20,
      ),
      ClinicalAction(
        id: 'document_careplan',
        label: 'Document findings and start respiratory care plan',
        safe: true,
        feedback: 'Clear documentation supports continuity.',
        scoreDelta: 10,
      ),
    ],
    correctActionIds: <String>[
      'raise_hob_o2',
      'notify_provider',
      'document_careplan',
    ],
    criticalErrorIds: <String>['give_penicillin'],
    debrief:
        'Maria presents with febrile hypoxia and crackles. Safe nursing priorities: '
        'support oxygenation, escalate abnormal vitals, avoid allergen drugs, document. '
        'This is educational simulation — not a substitute for supervised clinical practice.',
  );

  static List<ClinicalScenario> forCourse(String courseId) {
    if (courseId == 'nursing' || courseId == 'medicine') {
      return const <ClinicalScenario>[dyspneaWard];
    }
    return const <ClinicalScenario>[dyspneaWard];
  }

  static ClinicalScenario byId(String id) {
    if (id == dyspneaWard.id) return dyspneaWard;
    return dyspneaWard;
  }
}
