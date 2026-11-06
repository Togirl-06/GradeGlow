import '../lab_models.dart';
import 'anatomy3d.dart';

const LabPerson _demonstrator = LabPerson('Dr Amaka Obi', 'Anatomy demonstrator', 'Find it on the body before you name it. Always think in the patient’s left and right.');

const List<String> _both = <String>[];

LabScenario _scenario(String id, String title, LabDifficulty level, String what, List<AnatomyQuestion> qs, {List<String>? systems, List<String> info = _both}) => LabScenario(
      id: id,
      title: title,
      level: level,
      people: const <LabPerson>[_demonstrator],
      briefing: Briefing(
        what: what,
        why: 'Every examination, procedure and image depends on knowing exactly where structures lie.',
        information: <String>[
          'The model faces you: the patient’s left is on your right.',
          'Use the layer switches to hide the skin, skeleton or other systems; drag to rotate, pinch or scroll to zoom.',
          ...info,
        ],
        tools: const <String>['3D body model with layers', 'Structure list', 'Anatomy reference'],
        expected: 'Every structure identified correctly on the body.',
      ),
      steps: <LabStep>[
        Anatomy3DStep(id: '${id}_3d', title: title, instructions: 'Find each structure on the 3D body, select it and confirm.', questions: qs, systems: systems, skills: const <String>['md_anatomy']),
      ],
    );

/// Six 3D identification scenarios: two per level.
final List<LabScenario> anatomy3DScenarios = <LabScenario>[
  _scenario('a3d_organs', '3D body: the major organs', LabDifficulty.foundation, 'Orientation on the 3D body: find the major organs.', const <AnatomyQuestion>[
    AnatomyQuestion('the heart', <String>['heart']),
    AnatomyQuestion('the liver', <String>['liver']),
    AnatomyQuestion('the stomach', <String>['stomach']),
    AnatomyQuestion('either lung', <String>['lung_l', 'lung_r']),
    AnatomyQuestion('either kidney', <String>['kidney_l', 'kidney_r'], explain: 'The kidneys lie at the back of the abdomen — rotate the model.'),
    AnatomyQuestion('the brain', <String>['brain'], explain: 'Hide the skeleton layer to see it inside the skull.'),
  ]),
  _scenario('a3d_skeleton', '3D body: the skeleton', LabDifficulty.foundation, 'Find the main bones on the 3D skeleton.', const <AnatomyQuestion>[
    AnatomyQuestion('the sternum', <String>['sternum']),
    AnatomyQuestion('either clavicle', <String>['clavicle_l', 'clavicle_r']),
    AnatomyQuestion('either femur', <String>['femur_l', 'femur_r']),
    AnatomyQuestion('the pelvis', <String>['pelvis']),
    AnatomyQuestion('the vertebral column', <String>['spine']),
    AnatomyQuestion('either humerus', <String>['humerus_l', 'humerus_r']),
  ], systems: <String>['skeletal']),
  _scenario('a3d_sides', '3D body: sides and positions', LabDifficulty.intermediate, 'Left, right and position matter: a wrong-side error is a never event.', const <AnatomyQuestion>[
    AnatomyQuestion('the LEFT kidney', <String>['kidney_l'], explain: 'The patient’s left is on your right.'),
    AnatomyQuestion('the RIGHT lung (three lobes)', <String>['lung_r']),
    AnatomyQuestion('the spleen', <String>['spleen'], explain: 'Left upper quadrant, under ribs 9–11.'),
    AnatomyQuestion('the appendix', <String>['appendix']),
    AnatomyQuestion('the gallbladder', <String>['gallbladder']),
    AnatomyQuestion('the aorta', <String>['aorta']),
  ]),
  _scenario('a3d_systems', '3D body: tubes and glands', LabDifficulty.intermediate, 'Trace the passages and find the glands.', const <AnatomyQuestion>[
    AnatomyQuestion('the trachea', <String>['trachea']),
    AnatomyQuestion('the oesophagus', <String>['oesophagus'], explain: 'It lies behind the trachea.'),
    AnatomyQuestion('either ureter', <String>['ureter_l', 'ureter_r']),
    AnatomyQuestion('the urinary bladder', <String>['bladder']),
    AnatomyQuestion('the thyroid gland', <String>['thyroid']),
    AnatomyQuestion('either adrenal gland', <String>['adrenal_l', 'adrenal_r'], explain: 'Each caps a kidney.'),
  ]),
  _scenario('a3d_clinical', '3D body: clinical localisation', LabDifficulty.advanced, 'Clinic cases: find the structure each finding points to.', const <AnatomyQuestion>[
    AnatomyQuestion('the organ behind tenderness at McBurney’s point', <String>['appendix']),
    AnatomyQuestion('the organ inflamed when Murphy’s sign is positive', <String>['gallbladder']),
    AnatomyQuestion('the organ most at risk after fractures of the left lower ribs', <String>['spleen']),
    AnatomyQuestion('where an inhaled peanut most often lodges', <String>['bronchus_r'], explain: 'The right main bronchus is wider, shorter and more vertical.'),
    AnatomyQuestion('the nerve irritated in sciatica (either side)', <String>['sciatic_l', 'sciatic_r']),
    AnatomyQuestion('the gland that makes insulin', <String>['pancreas']),
  ]),
  _scenario('a3d_procedures', '3D body: procedures and pulses', LabDifficulty.advanced, 'Before a procedure, know what lies beneath the needle or probe.', const <AnatomyQuestion>[
    AnatomyQuestion('the vessel whose pulse you feel beside the larynx (either side)', <String>['carotid_l', 'carotid_r']),
    AnatomyQuestion('the artery for a femoral pulse or arterial puncture in the groin (either side)', <String>['femoral_a_l', 'femoral_a_r']),
    AnatomyQuestion('the structure a lumbar puncture needle passes between', <String>['spine'], explain: 'The needle enters between lumbar vertebrae, below the end of the spinal cord.'),
    AnatomyQuestion('the vessel where a central venous catheter tip should sit', <String>['svc']),
    AnatomyQuestion('the muscle that contracts and flattens when you breathe in', <String>['diaphragm']),
    AnatomyQuestion('the bone you landmark on for chest compressions', <String>['sternum']),
  ]),
];
