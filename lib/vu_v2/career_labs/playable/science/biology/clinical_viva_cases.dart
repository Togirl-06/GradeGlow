/// Clinical Viva case bank — patient chart → required view → bone/structure → WHY.
/// Competitors ship quizzes + 3D toys; this grades clinical reasoning on the model.
enum ClinicalRequiredView { anterior, posterior, lateral }

class ClinicalVivaCase {
  const ClinicalVivaCase({
    required this.id,
    required this.diagramId,
    required this.title,
    required this.patientLine,
    required this.chartBody,
    required this.requiredView,
    required this.diagnoseTargetId,
    required this.identifyTargets,
    required this.vivaPrompt,
    required this.vivaOptions,
    required this.correctVivaIndex,
    required this.coachOnWrongBone,
    required this.coachOnPass,
  });

  final String id;
  final String diagramId;
  final String title;
  final String patientLine;
  final String chartBody;
  final ClinicalRequiredView requiredView;
  final String diagnoseTargetId;
  final List<String> identifyTargets;
  final String vivaPrompt;
  final List<String> vivaOptions;
  final int correctVivaIndex;
  final String coachOnWrongBone;
  final String coachOnPass;

  String get requiredViewLabel {
    switch (requiredView) {
      case ClinicalRequiredView.anterior:
        return 'Anterior';
      case ClinicalRequiredView.posterior:
        return 'Posterior';
      case ClinicalRequiredView.lateral:
        return 'Lateral';
    }
  }
}

class ClinicalVivaCatalog {
  ClinicalVivaCatalog._();

  static const ClinicalVivaCase shoulderScapula = ClinicalVivaCase(
    id: 'shoulder_scapula',
    diagramId: 'skeleton',
    title: 'Posterior shoulder trauma',
    patientLine: '22yo · fall onto posterior shoulder · pain with abduction',
    chartBody:
        'Pain with abduction. Point tenderness over the shoulder blade. '
        'Your job is not memorization — reason like a clinician on a 3D model.',
    requiredView: ClinicalRequiredView.posterior,
    diagnoseTargetId: 'scapula',
    identifyTargets: <String>['scapula', 'radius', 'ulna'],
    vivaPrompt: 'VIVA — Why does scapula location matter?',
    vivaOptions: <String>[
      'Ignore diagrams — memorize lists only',
      'Posterior pain after fall implicates scapula / clavicle / humerus',
      'Only the femur matters for shoulder trauma',
      'Skip the model and guess radius',
    ],
    correctVivaIndex: 1,
    coachOnWrongBone:
        'Not the primary structure for posterior shoulder impact. Try again.',
    coachOnPass: 'Clinical reasoning locked — anatomy drives the differential.',
  );

  static const ClinicalVivaCase forearmFall = ClinicalVivaCase(
    id: 'forearm_fall',
    diagramId: 'skeleton',
    title: 'FOOSH — distal forearm',
    patientLine: '19yo · fall on outstretched hand · wrist pain, thumb-side tender',
    chartBody:
        'FOOSH injury. Distal wrist pain, swelling on the thumb side. '
        'Identify the bone most commonly fractured, then defend your reasoning.',
    requiredView: ClinicalRequiredView.anterior,
    diagnoseTargetId: 'radius',
    identifyTargets: <String>['radius', 'ulna', 'humerus'],
    vivaPrompt: 'VIVA — Why is the radius at higher fracture risk in FOOSH?',
    vivaOptions: <String>[
      'Because it is medial and forms the elbow point',
      'It is the thumb-side (lateral) bone that takes force through the wrist',
      'Because the femur is longer',
      'Scapula always fractures first in any fall',
    ],
    correctVivaIndex: 1,
    coachOnWrongBone: 'Think thumb-side forearm — not pinky-side or upper arm.',
    coachOnPass: 'FOOSH → distal radius. That is clinical spatial reasoning.',
  );

  static const ClinicalVivaCase heartFailure = ClinicalVivaCase(
    id: 'lv_pump',
    diagramId: 'heart_detail',
    title: 'Pump failure · left ventricle',
    patientLine: '68yo · dyspnea · pulmonary edema · weak systemic pulse',
    chartBody:
        'Signs of left-sided pump failure. On the 3D heart plate, find the chamber '
        'that ejects blood to the body — then explain why it matters clinically.',
    requiredView: ClinicalRequiredView.anterior,
    diagnoseTargetId: 'left_ventricle',
    identifyTargets: <String>['left_ventricle', 'right_ventricle', 'aorta'],
    vivaPrompt: 'VIVA — Why does LV failure cause pulmonary edema?',
    vivaOptions: <String>[
      'The LV fails → blood backs into pulmonary veins/lungs',
      'The femur cannot pump oxygen',
      'Only the right atrium matters for systemic circulation',
      'Valves are irrelevant to forward flow',
    ],
    correctVivaIndex: 0,
    coachOnWrongBone: 'Systemic output comes from the left ventricle — try again.',
    coachOnPass: 'LV failure → backup into lungs. Clinical anatomy, not flashcards.',
  );

  static const List<ClinicalVivaCase> all = <ClinicalVivaCase>[
    shoulderScapula,
    forearmFall,
    heartFailure,
  ];

  static ClinicalVivaCase byId(String? id) {
    if (id == null || id.isEmpty) return shoulderScapula;
    for (final ClinicalVivaCase c in all) {
      if (c.id == id) return c;
    }
    return shoulderScapula;
  }

  static List<ClinicalVivaCase> forDiagram(String diagramId) =>
      all.where((ClinicalVivaCase c) => c.diagramId == diagramId).toList();
}
