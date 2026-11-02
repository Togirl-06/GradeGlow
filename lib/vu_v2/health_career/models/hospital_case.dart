import 'package:flutter/material.dart';

import 'patient_profile.dart';

/// Live vitals that change as the learner treats the patient.
class LiveVitals {
  LiveVitals({
    required this.hr,
    required this.rr,
    required this.systolic,
    required this.diastolic,
    required this.tempC,
    required this.spo2,
    required this.painScore,
  });

  int hr;
  int rr;
  int systolic;
  int diastolic;
  double tempC;
  int spo2;
  int painScore;
  bool onOxygen = false;
  bool hobElevated = false;
  bool ivStarted = false;
  bool medsGiven = false;
  bool providerNotified = false;

  factory LiveVitals.fromPatient(PatientVitals v) => LiveVitals(
        hr: v.hr,
        rr: v.rr,
        systolic: v.systolic,
        diastolic: v.diastolic,
        tempC: v.tempC,
        spo2: v.spo2,
        painScore: v.painScore,
      );

  String get bpLabel => '$systolic/$diastolic';
  String get tempLabel => '${tempC.toStringAsFixed(1)}°C';

  bool get hypoxia => spo2 < 94;
  bool get tachycardic => hr > 100;
  bool get febrile => tempC >= 38.0;
  bool get tachypneic => rr > 20;
  bool get hypertensive => systolic >= 140;
  bool get critical => spo2 < 90 || hr > 130 || rr > 30;

  LiveVitals copy() => LiveVitals(
        hr: hr,
        rr: rr,
        systolic: systolic,
        diastolic: diastolic,
        tempC: tempC,
        spo2: spo2,
        painScore: painScore,
      )
        ..onOxygen = onOxygen
        ..hobElevated = hobElevated
        ..ivStarted = ivStarted
        ..medsGiven = medsGiven
        ..providerNotified = providerNotified;
}

enum TreatmentActionKind {
  elevateHob,
  applyOxygen,
  startIv,
  giveSafeMed,
  giveAllergenMed,
  notifyProvider,
  reassessment,
  educatePatient,
  delayCare,
  cathLab,
}

class TreatmentAction {
  const TreatmentAction({
    required this.id,
    required this.kind,
    required this.label,
    required this.detail,
    required this.safe,
    required this.icon,
  });

  final String id;
  final TreatmentActionKind kind;
  final String label;
  final String detail;
  final bool safe;
  final IconData icon;
}

class HospitalBed {
  const HospitalBed({
    required this.roomId,
    required this.bayLabel,
    required this.patient,
    required this.acuity,
    required this.diagnosisHint,
    required this.unit,
    required this.caseId,
    required this.objectives,
    required this.interviewKeys,
    required this.requiredActions,
    required this.criticalErrorIds,
    required this.xpReward,
    required this.debrief,
    this.route = HospitalRoute.bedside,
  });

  final String roomId;
  final String bayLabel;
  final PatientProfile patient;
  final String acuity; // Stable | Watch | Urgent | Critical
  final String diagnosisHint;
  final String unit; // Med-Surg | ED | ICU step-down
  final String caseId;
  final List<String> objectives;
  final List<String> interviewKeys;
  final List<String> requiredActions;
  final List<String> criticalErrorIds;
  final int xpReward;
  final String debrief;
  final HospitalRoute route;
}

enum HospitalRoute { bedside, nursingCase, medicineConsult }

/// Applies an intervention and returns a short effect note.
abstract final class TreatmentEngine {
  static String apply(LiveVitals v, TreatmentAction action) {
    switch (action.kind) {
      case TreatmentActionKind.elevateHob:
        if (v.hobElevated) return 'Head of bed already elevated.';
        v.hobElevated = true;
        v.rr = (v.rr - 2).clamp(12, 40);
        v.spo2 = (v.spo2 + 1).clamp(70, 100);
        return 'HOB to 45°. Work of breathing eases slightly.';
      case TreatmentActionKind.applyOxygen:
        if (v.onOxygen) return 'Oxygen already running.';
        v.onOxygen = true;
        v.spo2 = (v.spo2 + 4).clamp(70, 100);
        v.hr = (v.hr - 4).clamp(50, 180);
        v.rr = (v.rr - 2).clamp(12, 40);
        return 'O₂ via nasal cannula 2 L/min. SpO₂ climbing.';
      case TreatmentActionKind.startIv:
        if (v.ivStarted) return 'IV access already obtained.';
        v.ivStarted = true;
        return '20G IV in left forearm. Line flushed and secured.';
      case TreatmentActionKind.giveSafeMed:
        if (v.medsGiven) return 'Ordered meds already administered.';
        v.medsGiven = true;
        v.tempC = (v.tempC - 0.3).clamp(35.0, 42.0);
        v.painScore = (v.painScore - 2).clamp(0, 10);
        v.hr = (v.hr - 3).clamp(50, 180);
        return 'Safe ordered medication given. Pain and fever trending down.';
      case TreatmentActionKind.giveAllergenMed:
        v.hr = (v.hr + 25).clamp(50, 180);
        v.systolic = (v.systolic - 20).clamp(70, 220);
        v.spo2 = (v.spo2 - 5).clamp(70, 100);
        return 'CRITICAL: allergen exposure — patient developing distress.';
      case TreatmentActionKind.notifyProvider:
        if (v.providerNotified) return 'Provider already updated.';
        v.providerNotified = true;
        return 'Provider notified with SBAR. Orders pending.';
      case TreatmentActionKind.reassessment:
        return 'Full reassessment charted. Vitals rechecked at bedside.';
      case TreatmentActionKind.educatePatient:
        v.painScore = (v.painScore - 1).clamp(0, 10);
        return 'Patient coached on positioning and call-light use.';
      case TreatmentActionKind.delayCare:
        v.spo2 = (v.spo2 - 2).clamp(70, 100);
        v.hr = (v.hr + 6).clamp(50, 180);
        return 'Care delayed. Vitals drifting worse.';
      case TreatmentActionKind.cathLab:
        return 'Cath lab activated without ECG gate — unsafe pathway.';
    }
  }

  static void tickUntreated(LiveVitals v) {
    if (v.onOxygen && v.hobElevated) return;
    if (v.hypoxia && !v.onOxygen) {
      v.spo2 = (v.spo2 - 1).clamp(70, 100);
      v.hr = (v.hr + 2).clamp(50, 180);
    }
  }

  static ({int score, bool critical, List<String> notes}) score({
    required HospitalBed bed,
    required Set<String> doneActions,
    required Set<String> askedKeys,
    required LiveVitals vitals,
    required bool measuredVitals,
  }) {
    final List<String> notes = <String>[];
    int score = 0;
    bool critical = false;

    final int asked =
        askedKeys.intersection(bed.interviewKeys.toSet()).length;
    final int histPts = bed.interviewKeys.isEmpty
        ? 15
        : ((asked / bed.interviewKeys.length) * 20).round();
    score += histPts;
    notes.add('History: $asked/${bed.interviewKeys.length} (+$histPts).');

    if (measuredVitals) {
      score += 15;
      notes.add('Bedside vitals obtained (+15).');
    } else {
      notes.add('Missed full vitals check (0).');
    }

    for (final String id in doneActions) {
      if (bed.criticalErrorIds.contains(id)) {
        critical = true;
        notes.add('Critical unsafe action: $id.');
      }
    }

    int carePts = 0;
    for (final String id in bed.requiredActions) {
      if (doneActions.contains(id)) carePts += 12;
    }
    carePts = carePts.clamp(0, 48);
    score += carePts;
    notes.add('Required care steps (+$carePts).');

    if (vitals.spo2 >= 94 && vitals.onOxygen) {
      score += 10;
      notes.add('Oxygenation improved to ≥94% (+10).');
    }
    if (vitals.providerNotified) {
      score += 7;
      notes.add('Provider escalation documented (+7).');
    }

    if (critical) {
      score = (score * 0.35).round();
      notes.add('Score reduced for safety-critical error.');
    }

    return (score: score.clamp(0, 100), critical: critical, notes: notes);
  }
}

abstract final class HospitalWardCatalog {
  static const List<TreatmentAction> nursingToolkit = <TreatmentAction>[
    TreatmentAction(
      id: 'raise_hob',
      kind: TreatmentActionKind.elevateHob,
      label: 'Elevate head of bed',
      detail: 'Raise HOB to 30–45° to ease breathing.',
      safe: true,
      icon: Icons.airline_seat_recline_extra,
    ),
    TreatmentAction(
      id: 'apply_o2',
      kind: TreatmentActionKind.applyOxygen,
      label: 'Apply oxygen 2 L NC',
      detail: 'Nasal cannula oxygen per protocol for hypoxia.',
      safe: true,
      icon: Icons.air_rounded,
    ),
    TreatmentAction(
      id: 'start_iv',
      kind: TreatmentActionKind.startIv,
      label: 'Start peripheral IV',
      detail: 'Obtain IV access for labs and meds.',
      safe: true,
      icon: Icons.bloodtype_outlined,
    ),
    TreatmentAction(
      id: 'acetaminophen',
      kind: TreatmentActionKind.giveSafeMed,
      label: 'Give ordered acetaminophen',
      detail: 'Antipyretic / analgesic per order.',
      safe: true,
      icon: Icons.medication_rounded,
    ),
    TreatmentAction(
      id: 'penicillin',
      kind: TreatmentActionKind.giveAllergenMed,
      label: 'Give penicillin IM',
      detail: 'Empiric antibiotic — check allergies first.',
      safe: false,
      icon: Icons.warning_amber_rounded,
    ),
    TreatmentAction(
      id: 'notify_md',
      kind: TreatmentActionKind.notifyProvider,
      label: 'Notify provider (SBAR)',
      detail: 'Escalate abnormal vitals with structured handoff.',
      safe: true,
      icon: Icons.phone_in_talk_rounded,
    ),
    TreatmentAction(
      id: 'reassess',
      kind: TreatmentActionKind.reassessment,
      label: 'Reassess after interventions',
      detail: 'Repeat vitals and symptom check.',
      safe: true,
      icon: Icons.refresh_rounded,
    ),
    TreatmentAction(
      id: 'educate',
      kind: TreatmentActionKind.educatePatient,
      label: 'Patient education',
      detail: 'Explain plan and when to call for help.',
      safe: true,
      icon: Icons.record_voice_over_rounded,
    ),
    TreatmentAction(
      id: 'delay',
      kind: TreatmentActionKind.delayCare,
      label: 'Wait and recheck in 4 hours',
      detail: 'Defer care without addressing hypoxia.',
      safe: false,
      icon: Icons.schedule_rounded,
    ),
  ];

  static const List<TreatmentAction> medicineToolkit = <TreatmentAction>[
    TreatmentAction(
      id: 'ecg_first',
      kind: TreatmentActionKind.reassessment,
      label: 'Obtain 12-lead ECG',
      detail: 'Rule out ischemic changes before invasive pathway.',
      safe: true,
      icon: Icons.monitor_heart_outlined,
    ),
    TreatmentAction(
      id: 'troponin',
      kind: TreatmentActionKind.startIv,
      label: 'Draw troponin + basic labs',
      detail: 'IV access and cardiac markers.',
      safe: true,
      icon: Icons.science_outlined,
    ),
    TreatmentAction(
      id: 'ppi_trial',
      kind: TreatmentActionKind.giveSafeMed,
      label: 'Trial PPI + antacid',
      detail: 'Treat likely GERD while monitoring.',
      safe: true,
      icon: Icons.medication_liquid_rounded,
    ),
    TreatmentAction(
      id: 'notify_md',
      kind: TreatmentActionKind.notifyProvider,
      label: 'Discuss plan with attending',
      detail: 'Shared decision on disposition.',
      safe: true,
      icon: Icons.groups_rounded,
    ),
    TreatmentAction(
      id: 'cath_now',
      kind: TreatmentActionKind.cathLab,
      label: 'Activate cath lab now',
      detail: 'STEMI pathway without ECG confirmation.',
      safe: false,
      icon: Icons.emergency_rounded,
    ),
    TreatmentAction(
      id: 'educate',
      kind: TreatmentActionKind.educatePatient,
      label: 'Diet & symptom education',
      detail: 'Avoid triggers; return precautions.',
      safe: true,
      icon: Icons.menu_book_rounded,
    ),
    TreatmentAction(
      id: 'nsaid_dc',
      kind: TreatmentActionKind.delayCare,
      label: 'Discharge on high-dose NSAID only',
      detail: 'Ignores GERD risk and incomplete workup.',
      safe: false,
      icon: Icons.exit_to_app_rounded,
    ),
  ];

  static List<HospitalBed> get beds => <HospitalBed>[
        HospitalBed(
          roomId: '103-A',
          bayLabel: 'Bed A',
          patient: PatientCatalog.mariaLopez,
          acuity: 'Urgent',
          diagnosisHint: 'Suspected community pneumonia / hypoxic respiratory distress',
          unit: 'Med-Surg Ward',
          caseId: 'bedside_maria_v1',
          objectives: <String>[
            'Take focused history at the bedside',
            'Measure and interpret live vitals',
            'Support oxygenation safely',
            'Escalate and document without allergen errors',
          ],
          interviewKeys: <String>['onset', 'severity', 'sputum', 'fever'],
          requiredActions: <String>[
            'raise_hob',
            'apply_o2',
            'notify_md',
            'reassess',
          ],
          criticalErrorIds: <String>['penicillin'],
          xpReward: 160,
          debrief:
              'Maria needed oxygenation support, escalation for SpO₂ 91%, and '
              'strict allergy safety. Educational simulation only.',
          route: HospitalRoute.bedside,
        ),
        HospitalBed(
          roomId: '105-B',
          bayLabel: 'Bed B',
          patient: PatientCatalog.jamalReed,
          acuity: 'Watch',
          diagnosisHint: 'Epigastric pain — GERD vs ACS trap',
          unit: 'ED Fast Track',
          caseId: 'bedside_jamal_v1',
          objectives: <String>[
            'Clarify cardiac vs GI features',
            'Order gated workup before cath',
            'Treat most likely diagnosis safely',
          ],
          interviewKeys: <String>['onset', 'radiation', 'relieving'],
          requiredActions: <String>[
            'ecg_first',
            'troponin',
            'ppi_trial',
            'educate',
          ],
          criticalErrorIds: <String>['cath_now'],
          xpReward: 150,
          debrief:
              'Jamal’s story favored GERD/gastritis. ECG/troponin first; avoid '
              'premature cath activation. Educational simulation only.',
          route: HospitalRoute.bedside,
        ),
        HospitalBed(
          roomId: '110-A',
          bayLabel: 'Bed A',
          patient: PatientCatalog.elenaPark,
          acuity: 'Critical',
          diagnosisHint: 'Post-op day 1 — hypotension + bleeding concern',
          unit: 'Surgical Step-down',
          caseId: 'bedside_elena_v1',
          objectives: <String>[
            'Recognize hypovolemic shock signs',
            'Support ABCs and notify rapidly',
            'Avoid delaying care',
          ],
          interviewKeys: <String>['onset', 'pain', 'dizziness'],
          requiredActions: <String>[
            'raise_hob',
            'start_iv',
            'notify_md',
            'reassess',
          ],
          criticalErrorIds: <String>['delay'],
          xpReward: 180,
          debrief:
              'Elena needed rapid IV access, positioning support, and immediate '
              'provider notification for post-op instability.',
          route: HospitalRoute.bedside,
        ),
        HospitalBed(
          roomId: '118-C',
          bayLabel: 'Bed C',
          patient: PatientCatalog.devonBlake,
          acuity: 'Stable',
          diagnosisHint: 'New diabetic teaching — hyperglycemia education',
          unit: 'Med-Surg Ward',
          caseId: 'bedside_devon_v1',
          objectives: <String>[
            'Assess symptoms and meds',
            'Educate on glucose monitoring',
            'Notify if persistent hyperglycemia',
          ],
          interviewKeys: <String>['onset', 'thirst', 'meds'],
          requiredActions: <String>[
            'educate',
            'reassess',
            'notify_md',
          ],
          criticalErrorIds: <String>['penicillin'],
          xpReward: 120,
          debrief:
              'Devon needed education and escalation planning, not invasive '
              'respiratory interventions. Match care to acuity.',
          route: HospitalRoute.bedside,
        ),
      ];

  static List<TreatmentAction> toolkitFor(HospitalBed bed) {
    if (bed.patient.id == PatientCatalog.jamalReed.id) {
      return medicineToolkit;
    }
    return nursingToolkit;
  }

  static HospitalBed byCaseId(String id) =>
      beds.firstWhere((HospitalBed b) => b.caseId == id, orElse: () => beds.first);
}
