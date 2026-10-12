/// Future hook for AI-driven NPC dialogue (patient, professor, supervisor).
abstract class VuGameAiDialogueService {
  Future<String> reply({
    required String npcRole,
    required String scenarioContext,
    required String studentMessage,
  });
}

/// Structured dialogue until AI is wired — game works offline.
class VuGameScriptedDialogue {
  VuGameScriptedDialogue(this.nodes);

  final Map<String, VuGameDialogueNodeData> nodes;

  VuGameDialogueNodeData? node(String id) => nodes[id];
}

class VuGameDialogueNodeData {
  const VuGameDialogueNodeData({
    required this.id,
    required this.speaker,
    required this.text,
    this.choices = const <VuGameDialogueChoiceData>[],
  });

  final String id;
  final String speaker;
  final String text;
  final List<VuGameDialogueChoiceData> choices;
}

class VuGameDialogueChoiceData {
  const VuGameDialogueChoiceData({
    required this.id,
    required this.label,
    this.nextNodeId,
    this.actionId,
  });

  final String id;
  final String label;
  final String? nextNodeId;
  final String? actionId;
}

VuGameScriptedDialogue nursingClinicalDialogue() {
  return VuGameScriptedDialogue(<String, VuGameDialogueNodeData>{
    'diaz_root': const VuGameDialogueNodeData(
      id: 'diaz_root',
      speaker: 'Charge Nurse Diaz',
      text:
          'Good morning. You\'re scheduled for your first clinical today. '
          'Mr. Cole is in Room 103 — shortness of breath. Assess before you act.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(
          id: 'start',
          label: 'Start clinical',
          actionId: 'mission_start',
          nextNodeId: 'diaz_brief',
        ),
        VuGameDialogueChoiceData(
          id: 'patient',
          label: 'Ask about the patient',
          nextNodeId: 'diaz_patient',
        ),
        VuGameDialogueChoiceData(
          id: 'help',
          label: 'Ask for help',
          nextNodeId: 'diaz_help',
        ),
        VuGameDialogueChoiceData(
          id: 'instructions',
          label: 'Review instructions',
          nextNodeId: 'diaz_instructions',
        ),
      ],
    ),
    'diaz_brief': const VuGameDialogueNodeData(
      id: 'diaz_brief',
      speaker: 'Charge Nurse Diaz',
      text:
          'Walk to Room 103. Talk to Mr. Cole, check vitals, review his chart, '
          'then escalate if something doesn\'t look right. Document at the workstation.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'On my way', nextNodeId: null),
      ],
    ),
    'diaz_patient': const VuGameDialogueNodeData(
      id: 'diaz_patient',
      speaker: 'Charge Nurse Diaz',
      text:
          'COPD history, recent CHF flare. SpO₂ was soft overnight. '
          'He\'s anxious — stay calm, assess systematically.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Got it', nextNodeId: 'diaz_root'),
      ],
    ),
    'diaz_help': const VuGameDialogueNodeData(
      id: 'diaz_help',
      speaker: 'Charge Nurse Diaz',
      text:
          'Use the monitor and BP cuff before guessing. '
          'If breathing worsens, notify me or Dr. Park immediately.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Thank you', nextNodeId: 'diaz_root'),
      ],
    ),
    'diaz_instructions': const VuGameDialogueNodeData(
      id: 'diaz_instructions',
      speaker: 'Charge Nurse Diaz',
      text:
          'Nursing process: assess → document → escalate. '
          'Never pull meds from the cabinet without orders and two identifiers.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Understood', nextNodeId: 'diaz_root'),
      ],
    ),
    'patient_root': const VuGameDialogueNodeData(
      id: 'patient_root',
      speaker: 'Mr. Cole',
      text: 'I\'m having trouble breathing… feels tight in my chest.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(
          id: 'hurt',
          label: '"Where does it hurt?"',
          nextNodeId: 'patient_pain',
          actionId: 'talk_patient',
        ),
        VuGameDialogueChoiceData(
          id: 'when',
          label: '"When did this start?"',
          nextNodeId: 'patient_when',
          actionId: 'talk_patient',
        ),
        VuGameDialogueChoiceData(
          id: 'help',
          label: '"I\'m here to help — let me check you."',
          nextNodeId: 'patient_help',
          actionId: 'talk_patient',
        ),
      ],
    ),
    'patient_pain': const VuGameDialogueNodeData(
      id: 'patient_pain',
      speaker: 'Mr. Cole',
      text:
          'Mostly my chest… and my left arm feels heavy too. '
          'It\'s worse when I lie flat.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(
          id: 'concern',
          label: 'Recognize red-flag symptoms',
          actionId: 'identify_concern',
          nextNodeId: null,
        ),
      ],
    ),
    'patient_when': const VuGameDialogueNodeData(
      id: 'patient_when',
      speaker: 'Mr. Cole',
      text: 'About an hour ago. I couldn\'t sleep — had to sit up.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Continue assessment', nextNodeId: 'patient_root'),
      ],
    ),
    'patient_help': const VuGameDialogueNodeData(
      id: 'patient_help',
      speaker: 'Mr. Cole',
      text: 'Please… just help me breathe. I\'m scared.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Stay with patient', nextNodeId: 'patient_root'),
      ],
    ),
    'doctor_root': const VuGameDialogueNodeData(
      id: 'doctor_root',
      speaker: 'Dr. Park',
      text: 'What do you have for me on Cole?',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(
          id: 'escalate',
          label: 'Give SBAR-style handoff',
          actionId: 'notify_doctor',
          nextNodeId: 'doctor_ack',
        ),
        VuGameDialogueChoiceData(
          id: 'unsure',
          label: '"Still assessing…"',
          nextNodeId: 'doctor_wait',
        ),
      ],
    ),
    'doctor_ack': const VuGameDialogueNodeData(
      id: 'doctor_ack',
      speaker: 'Dr. Park',
      text:
          'Good catch. I\'ll see him now — keep monitoring and update Diaz.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Return to room', nextNodeId: null),
      ],
    ),
    'doctor_wait': const VuGameDialogueNodeData(
      id: 'doctor_wait',
      speaker: 'Dr. Park',
      text: 'Don\'t wait too long if vitals are trending wrong.',
      choices: <VuGameDialogueChoiceData>[
        VuGameDialogueChoiceData(id: 'ok', label: 'Understood', nextNodeId: null),
      ],
    ),
  });
}
