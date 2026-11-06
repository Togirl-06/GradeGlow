/// Data for the virtual hospital: departments, patients, what they say, what
/// examinations and tests show, what each intervention does, and the
/// cause-and-effect rules that make a patient improve or deteriorate.
///
/// Everything is fixed scenario data. No model decides medical truth: the
/// engine only applies these rules. Educational simulation, not real care.
library;

import 'package:flutter/painting.dart';

import '../engine/text_rubric.dart';

enum HospitalDept {
  emergency('Emergency Department', 'ED'),
  icu('Intensive Care Unit', 'ICU'),
  ward('General Ward', 'Ward'),
  pediatric('Pediatric Ward', 'Peds'),
  maternity('Maternity & Labor and Delivery', 'L&D'),
  theatre('Operating Theatre', 'OR'),
  medsurg('Medical-Surgical Unit', 'Med-Surg'),
  cardiology('Cardiology', 'Cardio'),
  neurology('Neurology', 'Neuro'),
  oncology('Oncology', 'Onc'),
  pharmacy('Pharmacy', 'Pharm'),
  laboratory('Laboratory', 'Lab'),
  radiology('Radiology and Imaging', 'Imaging'),
  triage('Patient Reception and Triage', 'Triage');

  const HospitalDept(this.label, this.short);
  final String label;
  final String short;
}

/// Who the student is in the scenario.
enum ClinicalRole { nursing, medicine }

enum CaseLevel { beginner, intermediate, advanced, placement }

extension LevelLabel on CaseLevel {
  String get label => switch (this) {
        CaseLevel.beginner => 'Beginner',
        CaseLevel.intermediate => 'Intermediate',
        CaseLevel.advanced => 'Advanced',
        CaseLevel.placement => 'Professional placement',
      };
}

enum HairStyle { short, long, bun, bald, curly }

/// How the patient looks (drawn by the patient painter).
class Appearance {
  const Appearance({required this.skin, required this.hair, this.style = HairStyle.short, this.grey = false, this.child = false, this.gown = const Color(0xFF7FB3D5), this.beard = false});
  final Color skin;
  final Color hair;
  final HairStyle style;
  final bool grey;
  final bool child;
  final Color gown;
  final bool beard;
}

/// Vital signs. Glucose in mg/dL; temperature in °C.
class Vitals {
  const Vitals({required this.hr, required this.sbp, required this.dbp, required this.rr, required this.temp, required this.spo2, this.glucose = 100, this.avpu = 'A', this.pain = 0});
  final double hr;
  final double sbp;
  final double dbp;
  final double rr;
  final double temp;
  final double spo2;
  final double glucose;

  /// Alert, Voice, Pain, Unresponsive (or C for new confusion).
  final String avpu;
  final double pain;

  Vitals copyWith({double? hr, double? sbp, double? dbp, double? rr, double? temp, double? spo2, double? glucose, String? avpu, double? pain}) => Vitals(
        hr: hr ?? this.hr,
        sbp: sbp ?? this.sbp,
        dbp: dbp ?? this.dbp,
        rr: rr ?? this.rr,
        temp: temp ?? this.temp,
        spo2: spo2 ?? this.spo2,
        glucose: glucose ?? this.glucose,
        avpu: avpu ?? this.avpu,
        pain: pain ?? this.pain,
      );

  double get(String k) => switch (k) {
        'hr' => hr,
        'sbp' => sbp,
        'dbp' => dbp,
        'rr' => rr,
        'temp' => temp,
        'spo2' => spo2,
        'glucose' => glucose,
        'pain' => pain,
        _ => 0,
      };

  Vitals add(Map<String, double> d, [double f = 1]) => Vitals(
        hr: (hr + (d['hr'] ?? 0) * f).clamp(20, 220).toDouble(),
        sbp: (sbp + (d['sbp'] ?? 0) * f).clamp(40, 240).toDouble(),
        dbp: (dbp + (d['dbp'] ?? 0) * f).clamp(20, 140).toDouble(),
        rr: (rr + (d['rr'] ?? 0) * f).clamp(4, 60).toDouble(),
        temp: (temp + (d['temp'] ?? 0) * f).clamp(33, 42).toDouble(),
        spo2: (spo2 + (d['spo2'] ?? 0) * f).clamp(60, 100).toDouble(),
        glucose: (glucose + (d['glucose'] ?? 0) * f).clamp(20, 600).toDouble(),
        avpu: avpu,
        pain: (pain + (d['pain'] ?? 0) * f).clamp(0, 10).toDouble(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'hr': hr, 'sbp': sbp, 'dbp': dbp, 'rr': rr, 'temp': temp, 'spo2': spo2, 'glucose': glucose, 'avpu': avpu, 'pain': pain};
}

/// A conversation topic the patient can be asked about.
class Topic {
  const Topic(this.id, this.label, this.keywords);
  final String id;

  /// Shown as a suggested question (never reveals the answer).
  final String label;

  /// Phrases that identify the question (`*` = any ending).
  final List<String> keywords;
}

/// A change caused by an action or a rule.
class Effect {
  const Effect({this.change = const <String, double>{}, this.drift, this.avpu, this.line, this.flags = const <String>[]});

  /// Immediate change to vitals.
  final Map<String, double> change;

  /// Replaces the per-minute drift (null = unchanged).
  final Map<String, double>? drift;
  final String? avpu;

  /// What the patient says afterwards.
  final String? line;

  /// Extra flags set (e.g. 'stabilised').
  final List<String> flags;
}

/// An action in a room. [kind] is one of ask, exam, measure, order,
/// intervene, escalate, diagnose, document.
class ActionDef {
  const ActionDef({
    required this.id,
    required this.label,
    this.detail = '',
    this.minutes = 2,
    this.scope = 'both',
    this.effect = const Effect(),
    this.harm,
    this.minor = false,
    this.needs = const <String>[],
    this.indicated = true,
    this.result = '',
  });

  /// What the student sees or measures after doing it.
  final String result;

  final String id;
  final String label;
  final String detail;
  final int minutes;

  /// 'nurse', 'doctor' or 'both'.
  final String scope;
  final Effect effect;

  /// If set, the action is unsafe here: it is not carried out and this
  /// explanation is shown. Critical unless [minor].
  final String? harm;
  final bool minor;

  /// Flags that must be set first (e.g. allergies checked before a medicine).
  final List<String> needs;

  /// False = not needed here (counted as unnecessary, not unsafe).
  final bool indicated;
}

/// A test result tied to this patient.
class TestResult {
  const TestResult(this.id, this.result, {this.minutes = 30, this.abnormal = false, this.image});
  final String id;
  final String result;

  /// Turnaround time in simulated minutes.
  final int minutes;
  final bool abnormal;

  /// Kind of picture for the imaging viewer: 'cxr_rll', 'cxr_normal', 'ct_head_normal', 'ct_head_bleed'.
  final String? image;
}

/// Something the student must do, optionally by a deadline.
class Requirement {
  const Requirement(this.flag, this.label, this.category, {this.by, this.critical = false, this.hint = '', this.only});

  /// Only required in this role (null = both).
  final ClinicalRole? only;

  /// Flag the action sets: 'ask:onset', 'measure:ecg', 'order:troponin',
  /// 'do:aspirin', 'escalated', 'hand_hygiene', 'dx', 'document' …
  final String flag;
  final String label;

  /// assessment, recognition, reasoning, safety, escalation, communication, documentation, infection.
  final String category;

  /// Deadline in simulated minutes from arrival.
  final int? by;

  /// Missing a critical requirement fails the case.
  final bool critical;

  /// The supervisor's hint (points the way, does not give the answer).
  final String hint;
}

/// A deterioration (or recovery) rule: from [after] minutes, unless any of
/// [unless] flags has been set, apply [effect] once.
class Rule {
  const Rule({required this.id, required this.after, required this.effect, this.unless = const <String>[], this.warning = ''});
  final String id;
  final int after;
  final List<String> unless;
  final Effect effect;

  /// What the student notices (new warning sign).
  final String warning;
}

class ChoiceOption {
  const ChoiceOption(this.id, this.label, {this.correct = false, this.acceptable = false, this.why = ''});
  final String id;
  final String label;
  final bool correct;

  /// Reasonable alternative reasoning (partial credit).
  final bool acceptable;
  final String why;
}

/// One virtual patient and everything the scenario knows about them.
class PatientCase {
  const PatientCase({
    required this.id,
    required this.dept,
    required this.level,
    required this.roles,
    required this.name,
    required this.age,
    required this.sex,
    required this.mrn,
    required this.appearance,
    required this.complaint,
    required this.opening,
    required this.arrival,
    required this.priority,
    required this.history,
    required this.allergies,
    required this.medications,
    required this.vitals,
    required this.drift,
    required this.answers,
    required this.exams,
    required this.tests,
    required this.actions,
    required this.rules,
    required this.requirements,
    required this.diagnosis,
    required this.nursingPriority,
    required this.goodOutcome,
    required this.badOutcome,
    this.ecg = 'sinus',
    this.topics = const <Topic>[],
    this.notes = const <String>[],
    this.ppe = false,
    this.escalateTo = 'Attending physician',
    this.teaching = const <String>[],
  });

  final String id;
  final HospitalDept dept;
  final CaseLevel level;
  final List<ClinicalRole> roles;
  final String name;
  final int age;
  final String sex;
  final String mrn;
  final Appearance appearance;
  final String complaint;

  /// What the patient says when the student walks in.
  final String opening;
  final String arrival;

  /// The correct triage priority (1 = immediate … 5 = non-urgent).
  final int priority;
  final List<String> history;
  final List<String> allergies;
  final List<String> medications;
  final Vitals vitals;

  /// Per-minute change while untreated.
  final Map<String, double> drift;

  /// Topic id → what the patient says (only revealed when asked).
  final Map<String, String> answers;

  /// Case-specific topics, checked before the general ones.
  final List<Topic> topics;

  /// Examination id → finding (others are unremarkable).
  final Map<String, String> exams;

  /// Test id → result.
  final Map<String, TestResult> tests;

  /// Case interventions and medicines on the chart.
  final List<ActionDef> actions;
  final List<Rule> rules;
  final List<Requirement> requirements;

  /// Working diagnosis (medicine) and nursing priority (nursing) choices.
  final List<ChoiceOption> diagnosis;
  final List<ChoiceOption> nursingPriority;
  final String goodOutcome;
  final String badOutcome;

  /// sinus, tachy, af, stemi, peaked_t, brady.
  final String ecg;

  /// Earlier progress notes in the chart.
  final List<String> notes;

  /// Isolation/PPE is required (infection prevention).
  final bool ppe;
  final String escalateTo;

  /// Key learning points for the debrief.
  final List<String> teaching;

  bool get child => age < 16;
}

/// A nursing shift: several patients sharing one clock.
class ShiftDef {
  const ShiftDef({required this.id, required this.title, required this.start, required this.caseIds, required this.brief, required this.handoverRubric});
  final String id;
  final String title;

  /// Clock time the shift starts (e.g. 7:00 = 420).
  final int start;
  final List<String> caseIds;
  final String brief;
  final List<Concept> handoverRubric;
}

/// Reception and triage: several arrivals to prioritise.
class TriageArrival {
  const TriageArrival(this.id, this.name, this.age, this.story, this.vitals, this.priority, this.why);
  final String id;
  final String name;
  final int age;
  final String story;
  final String vitals;

  /// ESI-style level 1 (immediate) to 5 (non-urgent).
  final int priority;
  final String why;
}
