// Writes build/hospital_review.json: every hospital case exactly as the app
// runs it (presentation, vitals, deterioration, expected actions, safety
// stops, decision options, scoring). It is the source for the clinician
// review pack, so reviewers check the real content, not a summary of it.
import 'dart:convert';
import 'dart:io';

import 'package:ai_study_buddy/career_sim/engine/text_rubric.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_models.dart';
import 'package:ai_study_buddy/career_sim/hospital/lab_panels.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> vitals(Vitals v) => <String, dynamic>{
      'hr': v.hr, 'sbp': v.sbp, 'dbp': v.dbp, 'rr': v.rr, 'temp': v.temp, 'spo2': v.spo2, 'glucose': v.glucose, 'avpu': v.avpu, 'pain': v.pain,
    };

Map<String, dynamic> effect(Effect e) => <String, dynamic>{
      if (e.change.isNotEmpty) 'change': e.change,
      if (e.drift != null) 'drift': e.drift,
      if (e.avpu != null) 'avpu': e.avpu,
      if (e.line != null) 'line': e.line,
      if (e.flags.isNotEmpty) 'flags': e.flags,
    };

List<Map<String, dynamic>> options(List<ChoiceOption> o) => <Map<String, dynamic>>[
      for (final ChoiceOption x in o) <String, dynamic>{'label': x.label, 'correct': x.correct, 'acceptable': x.acceptable, 'why': x.why},
    ];

void main() {
  test('export hospital content for clinician review', () {
    final Map<String, dynamic> out = <String, dynamic>{
      'weights': PatientSim.weights,
      'passRule': 'Pass = overall 70+ and no critical error. Hints cost 2 points each.',
      'sbarRubric': <String>[for (final Concept c in sbarRubric) c.label],
      'notesRubric': <String>[for (final Concept c in notesRubric) c.label],
      'tests': <Map<String, String>>[for (final TestDef t in testCatalog) <String, String>{'id': t.id, 'label': t.label}],
      'cases': <Map<String, dynamic>>[
        for (final PatientCase c in hospitalCases)
          <String, dynamic>{
            'id': c.id,
            'dept': c.dept.label,
            'level': c.level.label,
            'roles': c.roles.map((ClinicalRole r) => r.name).toList(),
            'patient': '${c.name}, ${c.age}${c.sex}',
            'complaint': c.complaint,
            'arrival': c.arrival,
            'opening': c.opening,
            'triagePriority': c.priority,
            'history': c.history,
            'allergies': c.allergies,
            'medications': c.medications,
            'vitals': vitals(c.vitals),
            'driftPerMinute': c.drift,
            'answers': c.answers,
            'exams': c.exams,
            'tests': <String, dynamic>{
              for (final MapEntry<String, TestResult> t in c.tests.entries)
                t.key: <String, dynamic>{
                  'result': t.value.result,
                  'minutes': t.value.minutes,
                  'abnormal': t.value.abnormal,
                  if (labPanel(c, t.key) case final List<LabRow> rows)
                    'panel': <Map<String, String>>[
                      for (final LabRow r in rows) <String, String>{'name': r.name, 'value': r.shown, 'unit': r.unit, 'range': r.range, 'flag': r.flag},
                    ],
                },
            },
            'ecg': c.ecg,
            'actions': <Map<String, dynamic>>[
              for (final ActionDef a in c.actions)
                <String, dynamic>{
                  'label': a.label,
                  if (a.detail.isNotEmpty) 'detail': a.detail,
                  'scope': a.scope,
                  'indicated': a.indicated,
                  if (a.needs.isNotEmpty) 'needs': a.needs,
                  if (a.harm != null) 'harm': a.harm,
                  if (a.harm != null) 'critical': !a.minor,
                  'effect': effect(a.effect),
                },
            ],
            'deterioration': <Map<String, dynamic>>[
              for (final Rule r in c.rules)
                <String, dynamic>{'afterMinutes': r.after, 'unless': r.unless, 'effect': effect(r.effect), if (r.warning.isNotEmpty) 'warning': r.warning},
            ],
            'requirements': <Map<String, dynamic>>[
              for (final Requirement r in c.requirements)
                <String, dynamic>{
                  'label': r.label,
                  'category': r.category,
                  if (r.by != null) 'byMinute': r.by,
                  'critical': r.critical,
                  if (r.only != null) 'onlyFor': r.only!.name,
                },
            ],
            'diagnosis': options(c.diagnosis),
            'nursingPriority': options(c.nursingPriority),
            'escalateTo': c.escalateTo,
            'ppe': c.ppe,
            'goodOutcome': c.goodOutcome,
            'badOutcome': c.badOutcome,
            'teaching': c.teaching,
          },
      ],
      'triage': <Map<String, dynamic>>[
        for (final TriageArrival a in triageArrivals)
          <String, dynamic>{'name': a.name, 'age': a.age, 'story': a.story, 'vitals': a.vitals, 'priority': a.priority, 'why': a.why},
      ],
      'shift': <String, dynamic>{'title': wardShift.title, 'brief': wardShift.brief, 'cases': wardShift.caseIds, 'handover': <String>[for (final Concept c in wardShift.handoverRubric) c.label]},
    };
    expect((out['cases'] as List<dynamic>).length, hospitalCases.length);
    Directory('build').createSync(recursive: true);
    File('build/hospital_review.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
  });
}
