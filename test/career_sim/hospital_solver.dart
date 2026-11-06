// Plays a virtual-hospital case the way a careful clinician would: hand
// hygiene first, then every requirement in deadline order, prerequisites
// before actions, a correct working diagnosis and a full note.
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_models.dart';

const String goodSbar = 'I am calling about this patient because I am concerned. Background: known history as on the chart and admitted today. '
    'Assessment: blood pressure, heart rate, oxygen saturation and respiratory rate are abnormal and the early warning score is raised; I think this is urgent. '
    'Recommendation: please come and review the patient urgently.';

const String goodNote = 'Assessed the patient using ABCDE and observed the findings documented above. Vital signs: blood pressure, heart rate, '
    'respiratory rate, oxygen saturation and temperature recorded. I administered the prescribed treatment within my scope and escalated to the team. '
    'Plan: continue monitoring, reassess after treatment and hand over at the end of the shift.';

const Map<String, String> sampleQuestions = <String, String>{
  'intro': 'Hello, my name is Sam and I am the student looking after you today.',
  'identity': 'Can you tell me your full name and date of birth?',
  'consent': 'Is it okay if I examine you?',
};

typedef Act = Future<void> Function(SimAction a);

/// The action that sets [flag], after its prerequisites.
Future<void> satisfy(PatientSim Function() sim, Act act, String flag) async {
  final PatientSim s = sim();
  if (s.has(flag)) return;
  final PatientCase c = s.c;
  final int colon = flag.indexOf(':');
  final String kind = colon < 0 ? flag : flag.substring(0, colon);
  final String id = colon < 0 ? '' : flag.substring(colon + 1);
  switch (kind) {
    case 'do':
      final ActionDef? d = s.intervention(id);
      for (final String n in d?.needs ?? const <String>[]) {
        await satisfy(sim, act, n);
      }
      await act(SimAction('intervene', id));
    case 'measure':
      await act(SimAction('measure', id));
    case 'exam':
      await act(SimAction('exam', id));
    case 'order':
      await act(SimAction('order', id));
    case 'chart':
      await act(SimAction('chart', id));
    case 'ask':
      final Topic t = <Topic>[...c.topics, ...generalTopics].firstWhere((Topic x) => x.id == id);
      await act(SimAction('ask', '', sampleQuestions[id] ?? t.label));
    case 'identity':
      await act(const SimAction('exam', 'wristband'));
    case 'allergies':
      await act(const SimAction('chart', 'allergies'));
    case 'vitals':
      await act(const SimAction('measure', 'monitor'));
    case 'escalated':
      final String target = c.actions.any((ActionDef a) => a.needs.contains('escalate:Stroke team')) ? 'Stroke team' : c.escalateTo;
      await act(SimAction('escalate', target, goodSbar));
    case 'escalate':
      await act(SimAction('escalate', id, goodSbar));
    case 'dx':
      final List<ChoiceOption> opts = s.role == ClinicalRole.medicine ? c.diagnosis : c.nursingPriority;
      await act(SimAction('diagnose', opts.firstWhere((ChoiceOption o) => o.correct).id));
    case 'document':
      await act(const SimAction('document', '', goodNote));
  }
}

Future<void> solveCase(PatientSim Function() sim, Act act, {List<String> first = const <String>[]}) async {
  await satisfy(sim, act, 'do:hand_hygiene');
  for (final String f in first) {
    await satisfy(sim, act, f);
  }
  final List<Requirement> reqs = List<Requirement>.from(sim().requirements)..sort((Requirement a, Requirement b) => (a.by ?? 999).compareTo(b.by ?? 999));
  for (final Requirement r in reqs) {
    if (r.flag == 'document') continue;
    await satisfy(sim, act, r.flag);
  }
  if (sim().c.ppe) await satisfy(sim, act, 'do:ppe');
  await satisfy(sim, act, 'dx');
  await satisfy(sim, act, 'document');
}

Future<PatientSim> solvedLocally(PatientCase c, ClinicalRole role) async {
  final PatientSim s = PatientSim(c, role);
  await solveCase(() => s, (SimAction a) async => s.apply(a));
  return s;
}

const String goodHandover = 'Handover for the next shift. Bed 2 Grace Okoye: hypoglycaemia this morning, glucose treated and rechecked at 112, '
    'insulin plan to be reviewed by the physician; follow up her next glucose before lunch. Bed 4 Linda Park: pain score was 7, analgesia given '
    'with good response, breathing exercises taught; reassess pain at noon. Bed 6 Harold Jensen: high falls risk with a postural drop; falls bundle '
    'in place with low bed and call bell; needs physio review and pressure care. Outstanding: physician review pending for Bed 2.';

/// Plays the ward shift in priority order through [act].
Future<void> solveShift(ShiftSim Function() shift, Future<void> Function(String caseId, SimAction a) act) async {
  PatientSim Function() p(String id) => () => shift().sims[id]!;
  Act on(String id) => (SimAction a) => act(id, a);
  // Most urgent first: low glucose, then fall risk, then pain.
  for (final String id in <String>['ward_diabetes', 'ward_falls', 'ward_postop']) {
    await satisfy(p(id), on(id), 'do:hand_hygiene');
  }
  await satisfy(p('ward_diabetes'), on('ward_diabetes'), 'do:hypo_treat');
  await satisfy(p('ward_falls'), on('ward_falls'), 'do:falls_bundle');
  await satisfy(p('ward_postop'), on('ward_postop'), 'do:analgesia');
  for (final String id in <String>['ward_diabetes', 'ward_postop', 'ward_falls']) {
    await satisfy(p(id), on(id), 'vitals');
  }
  for (final String id in <String>['ward_diabetes', 'ward_postop', 'ward_falls']) {
    await solveCase(p(id), on(id));
  }
}
