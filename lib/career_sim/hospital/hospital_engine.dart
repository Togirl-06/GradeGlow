/// Runs a virtual patient: every action takes simulated minutes, the
/// patient's vital signs change by the case's rules, and the student's
/// decisions are scored against the case's clinical rubric.
///
/// The engine is deterministic: the same actions always give the same
/// patient course and the same score, so a saved action log replays exactly.
library;

import 'dart:math' as math;

import '../engine/text_rubric.dart';
import 'hospital_models.dart';

// ---------------------------------------------------------------- catalogue

/// General conversation topics (case topics are checked first).
const List<Topic> generalTopics = <Topic>[
  Topic('intro', 'Introduce yourself', <String>['my name is', "i'm your", 'i am your', 'i am a', "i'm a", 'i will be looking after', 'hello my name']),
  Topic('identity', 'Confirm name and date of birth', <String>['date of birth', 'full name', 'confirm your name', 'dob', 'what is your name', "what's your name", 'birthday']),
  Topic('consent', 'Ask permission', <String>['is it okay', 'is that okay', 'may i', 'can i examine', 'consent', 'do you mind', 'would it be ok', 'happy for me']),
  Topic('allergies', 'Ask about allergies', <String>['allerg*', 'react* to', 'bad reaction']),
  Topic('meds', 'Ask about medicines', <String>['medication*', 'medicine*', 'tablet*', 'pills', 'take any', 'inhaler*', 'prescri*']),
  Topic('history', 'Ask about medical history', <String>['medical history', 'conditions', 'illness*', 'health problems', 'diagnosed with', 'past history', 'operations', 'surger*']),
  Topic('last_meal', 'When did you last eat?', <String>['eat', 'ate', 'meal', 'food', 'breakfast', 'lunch']),
  Topic('onset', 'When did it start?', <String>['when did', 'start*', 'began', 'begin', 'how long', 'come on', 'sudden*']),
  Topic('character', 'What does it feel like?', <String>['feel like', 'describe', 'kind of pain', 'what is the pain like', 'sharp', 'dull', 'crushing', 'tight*', 'type of pain']),
  Topic('radiation', 'Does it spread anywhere?', <String>['spread*', 'radiat*', 'move anywhere', 'go anywhere', 'into your arm', 'jaw', 'back']),
  Topic('severity', 'How bad is it (0–10)?', <String>['out of 10', 'out of ten', 'scale', 'how bad', 'how severe', 'score']),
  Topic('associated', 'Any other symptoms?', <String>['other symptoms', 'anything else', 'short of breath', 'breathless*', 'sweat*', 'nause*', 'vomit*', 'dizz*', 'fever', 'cough*', 'headache']),
  Topic('social', 'Smoking, alcohol, home', <String>['smoke', 'smoking', 'alcohol', 'drink', 'live alone', 'live with', 'at home', 'work']),
  Topic('family', 'Family history', <String>['family', 'father', 'mother', 'parents', 'relatives']),
  Topic('pain', 'Ask about pain', <String>['pain', 'hurt*', 'sore', 'ache']),
  Topic('understand', 'Check understanding', <String>['understand', 'any questions', 'make sense', 'explain']),
];

class Exam {
  const Exam(this.id, this.label, {this.minutes = 2});
  final String id;
  final String label;
  final int minutes;
}

const List<Exam> exams = <Exam>[
  Exam('wristband', 'Check ID wristband', minutes: 1),
  Exam('general', 'Look: general appearance', minutes: 1),
  Exam('airway', 'Airway'),
  Exam('chest', 'Listen to the chest (stethoscope)'),
  Exam('circulation', 'Circulation: skin, capillary refill'),
  Exam('neuro', 'Disability: consciousness, pupils'),
  Exam('fast', 'FAST stroke check (face, arms, speech)'),
  Exam('abdomen', 'Examine the abdomen'),
  Exam('wound', 'Inspect wound / dressing'),
  Exam('calves', 'Check the calves'),
  Exam('skin', 'Pressure areas and skin'),
  Exam('mobility', 'Assess mobility and gait'),
  Exam('fundus', 'Fundal height and tone, blood loss'),
  Exam('hydration', 'Hydration: mucous membranes, fontanelle, urine'),
];

class Equipment {
  const Equipment(this.id, this.label, this.icon, {this.minutes = 2});
  final String id;
  final String label;

  /// Material icon name used by the UI.
  final String icon;
  final int minutes;
}

const List<Equipment> equipment = <Equipment>[
  Equipment('bp', 'Blood pressure monitor', 'bp'),
  Equipment('thermometer', 'Thermometer', 'thermo', minutes: 1),
  Equipment('pulse_ox', 'Pulse oximeter', 'spo2', minutes: 1),
  Equipment('monitor', 'Attach bedside cardiac monitor', 'monitor', minutes: 2),
  Equipment('ecg', '12-lead ECG', 'ecg', minutes: 5),
  Equipment('glucose', 'Glucose meter', 'glucose', minutes: 2),
  Equipment('resp', 'Count respiratory rate', 'resp', minutes: 1),
];

class TestDef {
  const TestDef(this.id, this.label, {this.nurse = false, this.imaging = false});
  final String id;
  final String label;

  /// Nurses may start it under protocol.
  final bool nurse;
  final bool imaging;
}

const List<TestDef> testCatalog = <TestDef>[
  TestDef('cbc', 'Complete blood count'),
  TestDef('bmp', 'Basic metabolic panel (electrolytes, kidney)'),
  TestDef('troponin', 'Troponin'),
  TestDef('lactate', 'Lactate'),
  TestDef('cultures', 'Blood cultures', nurse: true),
  TestDef('ua', 'Urinalysis', nurse: true),
  TestDef('abg', 'Arterial blood gas'),
  TestDef('coag', 'Coagulation screen'),
  TestDef('crp', 'C-reactive protein'),
  TestDef('type_screen', 'Group and screen / crossmatch'),
  TestDef('cxr', 'Chest X-ray', imaging: true),
  TestDef('ct_head', 'CT head', imaging: true),
  TestDef('mri', 'MRI', imaging: true),
  TestDef('us', 'Ultrasound', imaging: true),
];

TestDef? testDef(String id) {
  for (final TestDef t in testCatalog) {
    if (t.id == id) return t;
  }
  return null;
}

/// Interventions available in every room (cases may override by id).
const List<ActionDef> generalActions = <ActionDef>[
  ActionDef(id: 'hand_hygiene', label: 'Hand hygiene', minutes: 1),
  ActionDef(id: 'ppe', label: 'Put on PPE (gloves, gown, mask)', minutes: 1),
  ActionDef(id: 'reassure', label: 'Explain what you are doing and reassure', minutes: 1),
  ActionDef(id: 'sit_up', label: 'Sit the patient upright', minutes: 1),
  ActionDef(id: 'lie_flat', label: 'Lie the patient flat', minutes: 1),
  ActionDef(id: 'oxygen', label: 'Give oxygen', minutes: 2),
  ActionDef(id: 'iv_access', label: 'Insert IV cannula', minutes: 4),
  ActionDef(id: 'call_help', label: 'Call for help (rapid response)', minutes: 1),
  ActionDef(id: 'npo', label: 'Keep nil by mouth', minutes: 1),
  ActionDef(id: 'defib', label: 'Defibrillator (training device)', minutes: 2, harm: 'Defibrillation is only for a patient in cardiac arrest with a shockable rhythm. This patient has a pulse and is talking — shocking them could cause a fatal arrhythmia.'),
];

const List<String> escalationTargets = <String>[
  'Charge nurse',
  'Attending physician',
  'Rapid response team',
  'Pharmacist',
  'Obstetrician on call',
  'Stroke team',
  'Ward physician',
];

const List<Concept> sbarRubric = <Concept>[
  Concept('s', 'Situation: who you are, who the patient is, the concern', <String>['calling about', 'i am calling', "i'm calling", 'concerned', 'worried', 'situation']),
  Concept('b', 'Background: relevant history', <String>['history', 'background', 'admitted', 'known', 'post-op', 'diabet*', 'allerg*']),
  Concept('a', 'Assessment: vital signs and what you think', <String>['blood pressure', 'heart rate', 'pulse', 'oxygen', 'saturat*', 'respiratory rate', 'temperature', 'news', 'score', 'i think', 'glucose', 'ecg']),
  Concept('r', 'Recommendation: what you need', <String>['please', 'review', 'come and see', 'urgent*', 'recommend', 'request', 'can you', 'need you']),
];

const List<Concept> notesRubric = <Concept>[
  Concept('assessment', 'What you assessed and found', <String>['assess*', 'observ*', 'found', 'findings', 'examin*', 'complain*', 'reports']),
  Concept('vitals', 'Vital signs', <String>['blood pressure', 'heart rate', 'pulse', 'oxygen', 'saturat*', 'temperature', 'respiratory', 'glucose', 'news']),
  Concept('actions', 'What you did', <String>['gave', 'administered', 'escalat*', 'applied', 'performed', 'inserted', 'called', 'informed', 'started']),
  Concept('plan', 'Plan and follow-up', <String>['plan', 'monitor*', 'review', 'reassess*', 'next', 'handover', 'continue']),
];

/// NEWS2 early warning score (adults).
int news2(Vitals v, {bool onOxygen = false}) {
  int s = 0;
  final double rr = v.rr;
  s += rr <= 8 ? 3 : rr <= 11 ? 1 : rr <= 20 ? 0 : rr <= 24 ? 2 : 3;
  final double o = v.spo2;
  s += o <= 91 ? 3 : o <= 93 ? 2 : o <= 95 ? 1 : 0;
  if (onOxygen) s += 2;
  final double t = v.temp;
  s += t <= 35 ? 3 : t <= 36 ? 1 : t <= 38 ? 0 : t <= 39 ? 1 : 2;
  final double b = v.sbp;
  s += b <= 90 ? 3 : b <= 100 ? 2 : b <= 110 ? 1 : b <= 219 ? 0 : 3;
  final double h = v.hr;
  s += h <= 40 ? 3 : h <= 50 ? 1 : h <= 90 ? 0 : h <= 110 ? 1 : h <= 130 ? 2 : 3;
  if (v.avpu != 'A') s += 3;
  return s;
}

String newsBand(int s) => s >= 7 ? 'High — emergency response' : s >= 5 ? 'Medium — urgent review' : s >= 1 ? 'Low — ward assessment' : 'None';

// ---------------------------------------------------------------- state

class SimAction {
  const SimAction(this.kind, this.id, [this.text = '']);

  factory SimAction.fromJson(Map<String, dynamic> j) => SimAction(j['k'] as String? ?? '', j['id'] as String? ?? '', j['t'] as String? ?? '');

  /// ask, exam, measure, order, intervene, escalate, diagnose, document, chart, hint.
  final String kind;
  final String id;
  final String text;

  Map<String, dynamic> toJson() => <String, dynamic>{'k': kind, 'id': id, if (text.isNotEmpty) 't': text};
}

class LogLine {
  const LogLine(this.minute, this.who, this.text, {this.warning = false});
  final int minute;

  /// 'you', 'patient', 'monitor', 'result', 'system', 'supervisor'.
  final String who;
  final String text;
  final bool warning;
}

class SafetyEvent {
  const SafetyEvent(this.minute, this.action, this.explanation, {this.critical = true});
  final int minute;
  final String action;
  final String explanation;
  final bool critical;
}

class VitalsPoint {
  const VitalsPoint(this.minute, this.v);
  final int minute;
  final Vitals v;
}

class CaseScore {
  const CaseScore({
    required this.overall,
    required this.categories,
    required this.passed,
    required this.critical,
    required this.done,
    required this.missed,
    required this.late,
    required this.unnecessary,
    required this.safety,
    required this.outcome,
    required this.improve,
  });

  final int overall;
  final Map<String, int> categories;
  final bool passed;

  /// A critical safety error (or a missed critical action) happened.
  final bool critical;
  final List<String> done;
  final List<String> missed;
  final List<String> late;
  final List<String> unnecessary;
  final List<SafetyEvent> safety;
  final String outcome;
  final List<String> improve;
}

/// The live simulation of one patient.
class PatientSim {
  PatientSim(this.c, this.role)
      : v = c.vitals,
        drift = Map<String, double>.from(c.drift) {
    say(c.opening);
  }

  /// Rebuilds a patient from a saved action log.
  factory PatientSim.replay(PatientCase c, ClinicalRole role, List<SimAction> actions) {
    final PatientSim s = PatientSim(c, role);
    for (final SimAction a in actions) {
      s.apply(a);
    }
    return s;
  }

  final PatientCase c;
  final ClinicalRole role;
  Vitals v;
  Map<String, double> drift;
  int minute = 0;
  final Map<String, int> flags = <String, int>{};
  final List<LogLine> log = <LogLine>[];
  final List<SafetyEvent> safety = <SafetyEvent>[];
  final List<VitalsPoint> chart = <VitalsPoint>[];
  final List<SimAction> actions = <SimAction>[];
  final Map<String, int> orders = <String, int>{};
  final Set<String> fired = <String>{};
  final List<String> unnecessary = <String>[];
  String patientLine = '';
  String? diagnosis;
  String notes = '';
  String sbar = '';
  String escalatedTo = '';
  int hints = 0;
  bool finished = false;

  bool get monitorOn => flags.containsKey('measure:monitor');
  bool get onOxygen => flags.containsKey('do:oxygen');
  bool has(String f) => flags.containsKey(f);
  int news() => news2(v, onOxygen: onOxygen);

  void say(String line) {
    patientLine = line;
    log.add(LogLine(minute, 'patient', line));
  }

  void _flag(String f) => flags.putIfAbsent(f, () => minute);

  void _note(String who, String text, {bool warning = false}) => log.add(LogLine(minute, who, text, warning: warning));

  /// Lets simulated time pass, applying drift and the case's rules.
  void advance(int minutes) {
    for (int i = 0; i < minutes; i++) {
      minute++;
      v = v.add(drift);
      for (final Rule r in c.rules) {
        if (fired.contains(r.id) || minute < r.after) continue;
        if (r.unless.any(has)) continue;
        fired.add(r.id);
        _effect(r.effect);
        if (r.warning.isNotEmpty) _note('system', r.warning, warning: true);
      }
      if (monitorOn && minute % 5 == 0) chart.add(VitalsPoint(minute, v));
    }
    if (monitorOn && news() >= 5) _note('monitor', 'Monitor alarm: early warning score ${news()} (${newsBand(news())}).', warning: true);
  }

  void _effect(Effect e) {
    v = v.add(e.change);
    if (e.avpu != null) v = v.copyWith(avpu: e.avpu);
    if (e.drift != null) drift = Map<String, double>.from(e.drift!);
    for (final String f in e.flags) {
      _flag(f);
    }
    if (e.line != null) say(e.line!);
  }

  /// Every action the student can take in this room.
  List<ActionDef> get interventions {
    final Map<String, ActionDef> all = <String, ActionDef>{for (final ActionDef a in generalActions) a.id: a};
    for (final ActionDef a in c.actions) {
      all[a.id] = a;
    }
    return all.values.toList();
  }

  ActionDef? intervention(String id) {
    for (final ActionDef a in interventions) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// The patient's reply to a free-text question.
  String reply(String question) {
    final String q = question.toLowerCase();
    for (final Topic t in <Topic>[...c.topics, ...generalTopics]) {
      if (t.keywords.any((String k) => TextRubric.mentions(q, Concept('t', 't', <String>[k])))) {
        return topicAnswer(t.id);
      }
    }
    return "I'm sorry, I'm not sure what you mean.";
  }

  String topicAnswer(String id) {
    final String? a = c.answers[id];
    if (a != null) return a;
    return switch (id) {
      'intro' => 'Hello.',
      'identity' => "I'm ${c.name}.",
      'consent' => 'Yes, that\'s fine.',
      'allergies' => c.allergies.isEmpty ? 'No allergies that I know of.' : 'Yes — ${c.allergies.join(', ')}.',
      'meds' => c.medications.isEmpty ? "I don't take anything regularly." : 'I take ${c.medications.join(', ')}.',
      'history' => c.history.isEmpty ? 'Nothing major.' : c.history.join('; '),
      'understand' => 'Yes, I understand. Thank you for explaining.',
      _ => 'No, nothing like that.',
    };
  }

  /// Every topic a question touches ("Hi, I'm Sam — can I check your name?").
  List<String> topicsOf(String question) {
    final String q = question.toLowerCase();
    return <String>[
      for (final Topic t in <Topic>[...c.topics, ...generalTopics])
        if (t.keywords.any((String k) => TextRubric.mentions(q, Concept('t', 't', <String>[k])))) t.id,
    ];
  }

  /// Every topic this patient can talk about (case-specific first).
  List<Topic> get allTopics => <Topic>[...c.topics, ...generalTopics];

  /// Which topic a question is about (null = not understood).
  String? topicOf(String question) {
    final String q = question.toLowerCase();
    for (final Topic t in <Topic>[...c.topics, ...generalTopics]) {
      if (t.keywords.any((String k) => TextRubric.mentions(q, Concept('t', 't', <String>[k])))) return t.id;
    }
    return null;
  }

  /// Applies one action. Unsafe actions are refused and explained.
  void apply(SimAction a) {
    if (finished) return;
    actions.add(a);
    switch (a.kind) {
      case 'ask':
        _note('you', a.text);
        // `id` carries a topic worked out by AI when the words alone did not
        // match; it is stored with the action so replays give the same result.
        final bool hinted = a.id.isNotEmpty && allTopics.any((Topic t) => t.id == a.id);
        final String? topic = topicOf(a.text) ?? (hinted ? a.id : null);
        final List<String> heard = <String>{...topicsOf(a.text), if (hinted) a.id}.toList();
        for (final String t in heard) {
          _flag('ask:$t');
          if (t == 'identity') _flag('identity');
          if (t == 'allergies') _flag('allergies');
        }
        advance(1);
        final List<String> ts = heard;
        say(topic == null
            ? reply(a.text)
            : (ts.length > 1 && ts.first == 'intro' ? '${topicAnswer('intro')} ${topicAnswer(ts[1])}' : topicAnswer(topic)));
      case 'exam':
        final Exam? e = exams.where((Exam x) => x.id == a.id).firstOrNull;
        _flag('exam:${a.id}');
        if (a.id == 'wristband') _flag('identity');
        _note('you', e?.label ?? a.id);
        advance(e?.minutes ?? 2);
        _note('result', c.exams[a.id] ?? 'Unremarkable.');
      case 'measure':
        _measure(a.id);
      case 'chart':
        _flag('chart:${a.id}');
        if (a.id == 'allergies') _flag('allergies');
      case 'order':
        _order(a.id);
      case 'intervene':
        _intervene(a.id);
      case 'escalate':
        _escalate(a.id, a.text);
      case 'diagnose':
        diagnosis = a.id;
        _flag('dx');
        final List<ChoiceOption> opts = role == ClinicalRole.medicine ? c.diagnosis : c.nursingPriority;
        final ChoiceOption? o = opts.where((ChoiceOption x) => x.id == a.id).firstOrNull;
        if (o != null && o.correct) _flag('dx:correct');
        if (o != null && o.acceptable) _flag('dx:acceptable');
        _note('you', 'Working ${role == ClinicalRole.medicine ? 'diagnosis' : 'nursing priority'}: ${o?.label ?? a.id}');
        advance(1);
      case 'document':
        notes = a.text;
        _flag('document');
        _note('you', 'Documentation completed.');
        advance(5);
      case 'hint':
        hints++;
        _note('supervisor', hint());
      case 'wait':
        advance(int.tryParse(a.id) ?? 5);
    }
  }

  void _measure(String id) {
    final Equipment? eq = equipment.where((Equipment x) => x.id == id).firstOrNull;
    _flag('measure:$id');
    _note('you', eq?.label ?? id);
    advance(eq?.minutes ?? 2);
    String out;
    switch (id) {
      case 'bp':
        out = 'Blood pressure ${v.sbp.round()}/${v.dbp.round()} mmHg.';
      case 'thermometer':
        out = 'Temperature ${v.temp.toStringAsFixed(1)} °C.';
      case 'pulse_ox':
        out = 'SpO₂ ${v.spo2.round()}%, pulse ${v.hr.round()}/min${onOxygen ? ' (on oxygen)' : ' (room air)'}.';
      case 'resp':
        out = 'Respiratory rate ${v.rr.round()}/min.';
      case 'glucose':
        out = 'Capillary glucose ${v.glucose.round()} mg/dL.';
      case 'ecg':
        out = 'ECG: ${c.tests['ecg']?.result ?? 'sinus rhythm, no acute changes.'}';
      case 'monitor':
        out = 'Monitor attached: HR ${v.hr.round()}, BP ${v.sbp.round()}/${v.dbp.round()}, RR ${v.rr.round()}, SpO₂ ${v.spo2.round()}%. Readings now update continuously.';
      default:
        out = 'Done.';
    }
    chart.add(VitalsPoint(minute, v));
    if (<String>{'bp', 'pulse_ox', 'resp', 'thermometer'}.every((String m) => has('measure:$m')) || monitorOn) _flag('vitals');
    _note('result', out);
  }

  void _order(String id) {
    final TestDef? t = testDef(id);
    if (role == ClinicalRole.nursing && t != null && !t.nurse) {
      safety.add(SafetyEvent(minute, 'Ordered ${t.label}', 'Ordering this test is outside nursing scope. Escalate with a recommendation instead.', critical: false));
      _note('supervisor', 'Outside your scope: ask the physician to order ${t.label}.', warning: true);
      return;
    }
    if (orders.containsKey(id)) return;
    _flag('order:$id');
    final TestResult? r = c.tests[id];
    orders[id] = minute + (r?.minutes ?? 30);
    if (r == null) unnecessary.add(t?.label ?? id);
    _note('you', 'Ordered ${t?.label ?? id}.');
    advance(1);
  }

  /// Results that are back, by test id.
  Map<String, String> get results => <String, String>{
        for (final MapEntry<String, int> o in orders.entries)
          if (minute >= o.value) o.key: c.tests[o.key]?.result ?? 'Within normal limits for this patient.',
      };

  void _intervene(String id) {
    final ActionDef? d = intervention(id);
    if (d == null) return;
    _note('you', d.label);
    if (d.harm != null) {
      safety.add(SafetyEvent(minute, d.label, d.harm!, critical: !d.minor));
      _note('supervisor', 'Stopped: ${d.harm}', warning: true);
      _flag('unsafe:$id');
      return;
    }
    if (d.scope == 'doctor' && role == ClinicalRole.nursing) {
      safety.add(SafetyEvent(minute, d.label, 'This needs a prescription or physician decision. Escalate and request it.', critical: false));
      _note('supervisor', 'Outside nursing scope: escalate and request this.', warning: true);
      return;
    }
    final List<String> missing = d.needs.where((String f) => !has(f)).toList();
    if (missing.isNotEmpty) {
      final String what = missing.map((String f) => switch (f) {
            'allergies' => 'check allergies',
            'identity' => 'confirm the patient\'s identity',
            'escalated' => 'get a physician\'s decision',
            _ => f.replaceAll(':', ' '),
          }).join(' and ');
      safety.add(SafetyEvent(minute, d.label, 'Before "${d.label}" you must $what. The action was not carried out.'));
      _note('supervisor', 'Stopped: $what first.', warning: true);
      return;
    }
    if (id == 'oxygen' && !c.actions.any((ActionDef x) => x.id == 'oxygen') && v.spo2 >= 96) {
      unnecessary.add('Oxygen with normal saturation');
    }
    if (!d.indicated) unnecessary.add(d.label);
    _flag('do:$id');
    advance(d.minutes);
    if (d.result.isNotEmpty) _note('result', d.result);
    _effect(d.effect);
  }

  /// The requirements that apply to the student's role.
  List<Requirement> get requirements => <Requirement>[for (final Requirement r in c.requirements) if (r.only == null || r.only == role) r];

  void _escalate(String target, String text) {
    escalatedTo = target;
    sbar = text;
    _flag('escalated');
    _flag('escalate:$target');
    _note('you', 'Escalated to $target: $text');
    advance(2);
    _note('system', '$target: "Thank you — I\'m coming to review now."');
  }

  /// The supervisor's next hint: the category of the first thing still
  /// missing, never the answer itself. Only after an attempt.
  String hint() {
    if (actions.where((SimAction a) => a.kind != 'hint').length < 3) return 'Have a go first: start with an initial look at the patient.';
    for (final Requirement r in requirements) {
      if (!has(r.flag)) return r.hint.isNotEmpty ? r.hint : 'Think about ${r.category}: what have you not done yet?';
    }
    return 'You have covered the key steps. Document your care and finish.';
  }

  String clock(int base) {
    final int m = base + minute;
    return '${(m ~/ 60 % 24).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------- scoring

  static const Map<String, int> weights = <String, int>{
    'assessment': 20,
    'recognition': 15,
    'reasoning': 15,
    'safety': 15,
    'escalation': 10,
    'communication': 10,
    'documentation': 10,
    'infection': 5,
  };

  CaseScore score() {
    final Map<String, List<double>> parts = <String, List<double>>{for (final String k in weights.keys) k: <double>[]};
    final List<String> done = <String>[];
    final List<String> missed = <String>[];
    final List<String> late = <String>[];
    bool critical = safety.any((SafetyEvent e) => e.critical);
    for (final Requirement r in requirements) {
      final int? at = flags[r.flag];
      if (at == null) {
        missed.add(r.label);
        parts[r.category]!.add(0);
        if (r.critical) critical = true;
      } else if (r.by != null && at > r.by!) {
        late.add('${r.label} (at ${at} min, needed by ${r.by} min)');
        parts[r.category]!.add(0.5);
        if (r.critical) critical = true;
      } else {
        done.add(r.label);
        parts[r.category]!.add(1);
      }
    }
    // Clinical reasoning: the working diagnosis / nursing priority.
    parts['reasoning']!.add(has('dx:correct') ? 1 : has('dx:acceptable') ? 0.8 : has('dx') ? 0.2 : 0);
    if (unnecessary.isNotEmpty) parts['reasoning']!.add(math.max(0, 1 - 0.2 * unnecessary.length));
    // Safety.
    final int minors = safety.where((SafetyEvent e) => !e.critical).length;
    parts['safety']!.add(safety.any((SafetyEvent e) => e.critical) ? 0 : math.max(0, 1 - 0.25 * minors));
    // Escalation quality (SBAR).
    if (has('escalated')) parts['escalation']!.add(TextRubric.assess(sbar, sbarRubric, minWords: 25, maxWords: 250).score / 100);
    // Communication.
    parts['communication']!.addAll(<double>[has('ask:intro') ? 1 : 0, has('identity') ? 1 : 0, (has('ask:consent') || has('do:reassure') || has('ask:understand')) ? 1 : 0]);
    // Documentation.
    parts['documentation']!.add(has('document') ? TextRubric.assess(notes, notesRubric, minWords: 30, maxWords: 400).score / 100 : 0);
    // Infection prevention: hand hygiene before touching the patient.
    final int firstTouch = <int>[
      for (final MapEntry<String, int> f in flags.entries)
        if ((f.key.startsWith('exam:') && f.key != 'exam:general' && f.key != 'exam:wristband') ||
            f.key.startsWith('measure:') ||
            (f.key.startsWith('do:') && !<String>{'do:hand_hygiene', 'do:ppe', 'do:reassure', 'do:call_help', 'do:npo'}.contains(f.key)))
          f.value,
    ].fold<int>(1 << 30, math.min);
    final int? hh = flags['do:hand_hygiene'];
    parts['infection']!.add(hh != null && hh <= firstTouch ? 1 : (hh != null ? 0.5 : 0));
    if (c.ppe) parts['infection']!.add(has('do:ppe') ? 1 : 0);

    final Map<String, int> cats = <String, int>{
      for (final MapEntry<String, List<double>> p in parts.entries)
        p.key: p.value.isEmpty ? 100 : (p.value.reduce((double a, double b) => a + b) / p.value.length * 100).round(),
    };
    final double total = weights.entries.fold<double>(0, (double a, MapEntry<String, int> w) => a + w.value * cats[w.key]! / 100);
    final int overall = math.max(0, total.round() - hints * 2);
    final bool passed = overall >= 70 && !critical;
    final List<String> improve = <String>[
      for (final MapEntry<String, int> e in cats.entries)
        if (e.value < 70) _advice(e.key),
      for (final SafetyEvent e in safety) 'Safety: ${e.explanation}',
    ];
    return CaseScore(
      overall: overall,
      categories: cats,
      passed: passed,
      critical: critical,
      done: done,
      missed: missed,
      late: late,
      unnecessary: unnecessary,
      safety: List<SafetyEvent>.from(safety),
      outcome: critical ? c.badOutcome : c.goodOutcome,
      improve: improve,
    );
  }

  String _advice(String k) => switch (k) {
        'assessment' => 'Assessment: work through ABCDE and take a full set of vital signs early.',
        'recognition' => 'Recognition: act on abnormal vital signs and the early warning score.',
        'reasoning' => 'Clinical reasoning: link the findings to your working diagnosis and order only the tests that answer a question.',
        'safety' => 'Patient safety: check identity and allergies before any medicine, and stay within your scope.',
        'escalation' => 'Escalation: call early and use SBAR (situation, background, assessment, recommendation).',
        'communication' => 'Communication: introduce yourself, confirm identity, ask permission and explain.',
        'documentation' => 'Documentation: record what you found, the vital signs, what you did and the plan.',
        _ => 'Infection prevention: hand hygiene before touching the patient; PPE when isolation is needed.',
      };
}

/// A shift: several patients sharing one clock. Time spent with one patient
/// passes for every other patient too, so prioritising matters.
class ShiftSim {
  ShiftSim(this.def, Map<String, PatientCase> cases, this.role)
      : sims = <String, PatientSim>{for (final String id in def.caseIds) id: PatientSim(cases[id]!, role)};

  factory ShiftSim.replay(ShiftDef def, Map<String, PatientCase> cases, ClinicalRole role, List<(String, SimAction)> actions) {
    final ShiftSim s = ShiftSim(def, cases, role);
    for (final (String id, SimAction a) in actions) {
      s.apply(id, a);
    }
    return s;
  }

  final ShiftDef def;
  final ClinicalRole role;
  final Map<String, PatientSim> sims;
  final List<(String, SimAction)> actions = <(String, SimAction)>[];
  String handover = '';

  int get minute => sims.values.isEmpty ? 0 : sims.values.first.minute;

  void apply(String caseId, SimAction a) {
    final PatientSim? s = sims[caseId];
    if (s == null) return;
    actions.add((caseId, a));
    if (a.kind == 'handover') {
      handover = a.text;
      return;
    }
    final int before = s.minute;
    s.apply(a);
    final int dt = s.minute - before;
    for (final MapEntry<String, PatientSim> o in sims.entries) {
      if (o.key != caseId && dt > 0) o.value.advance(dt);
    }
  }

  /// Average of the patients' scores plus the handover; any critical error fails the shift.
  (int, bool, Map<String, CaseScore>, int) score() {
    final Map<String, CaseScore> each = <String, CaseScore>{for (final MapEntry<String, PatientSim> e in sims.entries) e.key: e.value.score()};
    final int hand = TextRubric.assess(handover, def.handoverRubric, minWords: 60, maxWords: 500).score;
    final double avg = each.values.fold<double>(0, (double a, CaseScore s) => a + s.overall) / math.max(1, each.length);
    final int overall = (0.85 * avg + 0.15 * hand).round();
    final bool critical = each.values.any((CaseScore s) => s.critical);
    return (overall, !critical && overall >= 70, each, hand);
  }
}
