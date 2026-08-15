import 'package:flutter/material.dart';

import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../theme/study_theme.dart';
import 'practice_labs_catalog.dart';

/// Scenario templates and roleplay guides for AI Practice Mode.
class AiPracticeCatalog {
  AiPracticeCatalog._();

  static const PracticeScenarioTemplate aiGenerated = PracticeScenarioTemplate(
    id: 'ai_generated',
    title: 'AI-Generated Scenario',
    description: 'A fresh, unique scenario tailored to your major and difficulty level.',
    avatarRole: AvatarRole.client,
    aiRoleLabel: 'Role varies',
    studentTasks: <String>['Respond professionally', 'Apply your field knowledge', 'Make sound decisions'],
    evaluationCriteria: <String>['Communication', 'Critical thinking', 'Domain knowledge'],
    roleplayGuide:
        'Create a realistic professional scenario. Stay in character. '
        'React naturally to the student\'s decisions. Do not reveal answers or grade until the end.',
    isAiGenerated: true,
  );

  /// Scenarios keyed by subject group id, with major-specific overrides.
  static List<PracticeScenarioTemplate> scenariosFor(PracticeLabCategory major) {
    final List<PracticeScenarioTemplate>? specific = _majorScenarios[major.id];
    if (specific != null && specific.isNotEmpty) return specific;

    final String? groupId = major.groupId;
    if (groupId != null) {
      final List<PracticeScenarioTemplate>? group = _groupScenarios[groupId];
      if (group != null && group.isNotEmpty) return group;
    }

    return _defaultScenarios(major.name);
  }

  static String roleplayGuideFor(PracticeScenarioTemplate scenario) => scenario.roleplayGuide;

  static String difficultyPrompt(PracticeDifficulty difficulty) {
    return switch (difficulty) {
      PracticeDifficulty.beginner =>
        'Difficulty: Beginner. Keep the scenario straightforward. '
        'Give the student clear cues. Patient/client is cooperative. Lower stakes.',
      PracticeDifficulty.intermediate =>
        'Difficulty: Intermediate. Realistic complexity. Some ambiguity. '
        'Moderate time pressure or competing priorities.',
      PracticeDifficulty.advanced =>
        'Difficulty: Advanced. High stakes, nuanced trade-offs, incomplete information. '
        'Challenge the student\'s judgment. Multiple valid approaches exist.',
    };
  }

  static String evaluationPrompt(List<String> criteria) {
    return 'Evaluate on: ${criteria.join(', ')}. '
        'Include criteriaScores as an object mapping each criterion to 0-100.';
  }

  static List<PracticeScenarioTemplate> _defaultScenarios(String majorName) {
    return <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'default_professional',
        title: 'Professional Challenge',
        description: 'A realistic workplace scenario for $majorName students.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Supervisor',
        studentTasks: <String>[
          'Analyze the situation',
          'Communicate your reasoning',
          'Recommend next steps',
        ],
        evaluationCriteria: <String>['Communication', 'Critical thinking', 'Decision making'],
        roleplayGuide:
            'You are a professional supervisor in a $majorName context. '
            'Present a realistic challenge. React to the student\'s analysis and recommendations.',
      ),
    ];
  }

  static final Map<String, List<PracticeScenarioTemplate>> _groupScenarios =
      <String, List<PracticeScenarioTemplate>>{
    'health_medical': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'chest_pain_triage',
        title: 'Chest Pain Assessment',
        description: 'A patient arrives with chest pain. Assess urgency and recommend next actions.',
        avatarRole: AvatarRole.patient,
        aiRoleLabel: 'Patient',
        studentTasks: <String>[
          'Ask assessment questions',
          'Determine urgency',
          'Recommend next actions',
        ],
        evaluationCriteria: <String>['Communication', 'Safety', 'Clinical judgment'],
        roleplayGuide:
            'You are a patient with chest pain in a clinical simulation. '
            'Answer questions about symptoms, history, and vitals when asked. '
            'Do not diagnose yourself or tell them the correct treatment.',
      ),
      PracticeScenarioTemplate(
        id: 'medication_counseling',
        title: 'Medication Counseling',
        description: 'Counsel a patient starting a new medication about side effects and adherence.',
        avatarRole: AvatarRole.patient,
        aiRoleLabel: 'Patient',
        studentTasks: <String>[
          'Explain the medication clearly',
          'Address patient concerns',
          'Verify understanding',
        ],
        evaluationCriteria: <String>['Communication', 'Patient education', 'Safety'],
        roleplayGuide:
            'You are a patient nervous about a new prescription. Ask realistic questions. '
            'React to how well the student explains risks, benefits, and instructions.',
      ),
      PracticeScenarioTemplate(
        id: 'outbreak_investigation',
        title: 'Outbreak Investigation',
        description: 'Investigate a suspected disease outbreak in a community.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Health Director',
        studentTasks: <String>[
          'Gather epidemiological data',
          'Identify transmission patterns',
          'Recommend control measures',
        ],
        evaluationCriteria: <String>['Analytical thinking', 'Public health reasoning', 'Communication'],
        roleplayGuide:
            'You are a health department director briefing a public health student. '
            'Provide data when asked. Challenge weak reasoning about containment strategies.',
      ),
    ],
    'computer_technology': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'technical_interview',
        title: 'Technical Interview',
        description: 'Face a technical interview with algorithms, coding, and trade-off discussions.',
        avatarRole: AvatarRole.interviewer,
        aiRoleLabel: 'Interviewer',
        studentTasks: <String>[
          'Explain algorithms clearly',
          'Solve coding problems',
          'Discuss tradeoffs',
        ],
        evaluationCriteria: <String>['Problem solving', 'Communication', 'Technical knowledge'],
        roleplayGuide:
            'You are a senior software engineer conducting a technical interview. '
            'Give problems, ask follow-ups about time/space complexity, edge cases, and trade-offs. '
            'Stay professional and realistic.',
      ),
      PracticeScenarioTemplate(
        id: 'system_design',
        title: 'System Design Challenge',
        description: 'Design a scalable system for a real-world product requirement.',
        avatarRole: AvatarRole.interviewer,
        aiRoleLabel: 'System Design Interviewer',
        studentTasks: <String>[
          'Clarify requirements',
          'Propose architecture',
          'Discuss scaling and reliability',
        ],
        evaluationCriteria: <String>['System design', 'Trade-off analysis', 'Communication'],
        roleplayGuide:
            'You are a system design interviewer at a top tech company. '
            'Present a design prompt, ask scaling, reliability, and trade-off follow-ups.',
      ),
      PracticeScenarioTemplate(
        id: 'security_incident',
        title: 'Security Incident Response',
        description: 'Respond to a suspected cybersecurity breach in an organization.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'CISO',
        studentTasks: <String>[
          'Assess the threat',
          'Prioritize containment steps',
          'Communicate with stakeholders',
        ],
        evaluationCriteria: <String>['Incident response', 'Technical knowledge', 'Decision making'],
        roleplayGuide:
            'You are a CISO briefing a security analyst on an active incident. '
            'Provide logs and alerts when asked. React to containment and communication decisions.',
      ),
    ],
    'business': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'declining_sales',
        title: 'Declining Sales Crisis',
        description: 'Company sales are declining. Analyze the issue and present a strategy.',
        avatarRole: AvatarRole.ceo,
        aiRoleLabel: 'CEO',
        studentTasks: <String>[
          'Analyze the issue',
          'Recommend solutions',
          'Present a strategy',
        ],
        evaluationCriteria: <String>['Critical thinking', 'Business reasoning', 'Decision making'],
        roleplayGuide:
            'You are a CEO concerned about declining sales. Push back on weak analysis. '
            'Ask for data-driven recommendations and a clear action plan.',
      ),
      PracticeScenarioTemplate(
        id: 'marketing_campaign',
        title: 'Campaign Strategy Pitch',
        description: 'Pitch a marketing campaign to a skeptical client.',
        avatarRole: AvatarRole.customer,
        aiRoleLabel: 'Client',
        studentTasks: <String>[
          'Define target audience',
          'Propose campaign channels',
          'Justify budget allocation',
        ],
        evaluationCriteria: <String>['Marketing strategy', 'Persuasion', 'Analytical thinking'],
        roleplayGuide:
            'You are a budget-conscious client evaluating a marketing pitch. '
            'Ask tough questions about ROI, audience targeting, and metrics.',
      ),
      PracticeScenarioTemplate(
        id: 'audit_case',
        title: 'Audit Finding Review',
        description: 'Review financial records and address an audit finding.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Audit Partner',
        studentTasks: <String>[
          'Analyze financial data',
          'Identify discrepancies',
          'Recommend corrective actions',
        ],
        evaluationCriteria: <String>['Accounting knowledge', 'Attention to detail', 'Professional judgment'],
        roleplayGuide:
            'You are a senior audit partner presenting a case with financial irregularities. '
            'Provide documents when requested. Challenge the student\'s conclusions.',
      ),
    ],
    'law_criminal_justice': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'mock_trial',
        title: 'Mock Legal Argument',
        description: 'Argue a case before a judge with opposing counsel pushing back.',
        avatarRole: AvatarRole.lawyer,
        aiRoleLabel: 'Judge',
        studentTasks: <String>[
          'Present legal arguments',
          'Respond to objections',
          'Cite relevant precedents',
        ],
        evaluationCriteria: <String>['Legal reasoning', 'Persuasion', 'Case analysis'],
        roleplayGuide:
            'You are a judge in a mock trial. Listen to arguments, raise objections, '
            'and ask clarifying questions. Stay impartial but rigorous.',
      ),
      PracticeScenarioTemplate(
        id: 'crime_investigation',
        title: 'Crime Scene Investigation',
        description: 'Investigate a crime scene and build a case theory.',
        avatarRole: AvatarRole.witness,
        aiRoleLabel: 'Witness',
        studentTasks: <String>[
          'Collect and analyze evidence',
          'Interview witnesses',
          'Develop a theory of the case',
        ],
        evaluationCriteria: <String>['Investigative reasoning', 'Attention to detail', 'Ethics'],
        roleplayGuide:
            'You are a witness with partial knowledge of a crime. '
            'Answer questions realistically. Some details may be unreliable or incomplete.',
      ),
    ],
    'engineering': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'infrastructure_failure',
        title: 'Infrastructure Failure',
        description: 'A bridge shows structural concerns. Recommend engineering solutions.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'City Engineer',
        studentTasks: <String>[
          'Assess structural risks',
          'Propose remediation options',
          'Consider cost and safety trade-offs',
        ],
        evaluationCriteria: <String>['Engineering analysis', 'Safety', 'Decision making'],
        roleplayGuide:
            'You are a city engineer briefing a civil engineering student on a failing structure. '
            'Provide technical data when asked. Challenge unsafe or impractical proposals.',
      ),
      PracticeScenarioTemplate(
        id: 'circuit_troubleshoot',
        title: 'Circuit Troubleshooting',
        description: 'Diagnose and fix a malfunctioning electrical system.',
        avatarRole: AvatarRole.client,
        aiRoleLabel: 'Facility Manager',
        studentTasks: <String>[
          'Diagnose the fault',
          'Explain root cause',
          'Recommend a fix',
        ],
        evaluationCriteria: <String>['Technical knowledge', 'Problem solving', 'Communication'],
        roleplayGuide:
            'You are a facility manager reporting electrical issues. '
            'Describe symptoms when asked. React to diagnostic approaches and solutions.',
      ),
    ],
    'psychology_social_sciences': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'therapy_intake',
        title: 'Therapy Intake Session',
        description: 'Conduct an initial therapy session with a client in distress.',
        avatarRole: AvatarRole.client,
        aiRoleLabel: 'Client',
        studentTasks: <String>[
          'Build rapport',
          'Assess presenting concerns',
          'Demonstrate active listening',
        ],
        evaluationCriteria: <String>['Empathy', 'Clinical technique', 'Professional boundaries'],
        roleplayGuide:
            'You are a client in a therapy simulation with realistic emotional responses. '
            'Do not break character. Respond to empathy, boundaries, and technique.',
      ),
      PracticeScenarioTemplate(
        id: 'social_work_case',
        title: 'Client Intervention',
        description: 'Help a family facing housing instability and access community resources.',
        avatarRole: AvatarRole.client,
        aiRoleLabel: 'Client',
        studentTasks: <String>[
          'Assess needs holistically',
          'Connect to resources',
          'Develop an action plan',
        ],
        evaluationCriteria: <String>['Assessment', 'Resource knowledge', 'Cultural sensitivity'],
        roleplayGuide:
            'You are a client facing complex social challenges. Be realistic about barriers, '
            'distrust, and emotional state. Respond to how the student advocates for you.',
      ),
    ],
    'science': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'lab_investigation',
        title: 'Virtual Lab Investigation',
        description: 'Design and interpret experiments to solve a scientific mystery.',
        avatarRole: AvatarRole.teacher,
        aiRoleLabel: 'Lab Instructor',
        studentTasks: <String>[
          'Form hypotheses',
          'Design experiments',
          'Interpret results',
        ],
        evaluationCriteria: <String>['Scientific method', 'Data analysis', 'Critical thinking'],
        roleplayGuide:
            'You are a lab instructor guiding a student through an investigation. '
            'Provide experimental results when they propose valid methods. Challenge flawed designs.',
      ),
      PracticeScenarioTemplate(
        id: 'environmental_crisis',
        title: 'Environmental Crisis Response',
        description: 'Manage an environmental contamination event.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'EPA Official',
        studentTasks: <String>[
          'Assess environmental impact',
          'Prioritize remediation',
          'Communicate with stakeholders',
        ],
        evaluationCriteria: <String>['Scientific reasoning', 'Risk assessment', 'Communication'],
        roleplayGuide:
            'You are an EPA official briefing an environmental science student on a contamination event. '
            'Provide data on pollutant levels and affected areas when asked.',
      ),
    ],
    'arts_creative': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'design_critique',
        title: 'Design Critique Session',
        description: 'Present and defend a design concept to a demanding client.',
        avatarRole: AvatarRole.customer,
        aiRoleLabel: 'Client',
        studentTasks: <String>[
          'Present design rationale',
          'Respond to feedback',
          'Iterate on the concept',
        ],
        evaluationCriteria: <String>['Design thinking', 'Communication', 'Creativity'],
        roleplayGuide:
            'You are a design client with specific brand requirements and strong opinions. '
            'Give constructive but challenging feedback on the student\'s design choices.',
      ),
    ],
    'communications_media': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'breaking_news',
        title: 'Breaking News Coverage',
        description: 'Cover a developing news story with accuracy and ethical judgment.',
        avatarRole: AvatarRole.witness,
        aiRoleLabel: 'Source',
        studentTasks: <String>[
          'Verify facts',
          'Conduct interviews',
          'Write balanced coverage',
        ],
        evaluationCriteria: <String>['Journalistic ethics', 'Research', 'Writing clarity'],
        roleplayGuide:
            'You are a news source with partial information about a developing story. '
            'Some details may be uncertain. React to how the student verifies and reports.',
      ),
    ],
    'architecture_design': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'client_design_review',
        title: 'Client Design Review',
        description: 'Present a building design to a demanding client with strict requirements.',
        avatarRole: AvatarRole.customer,
        aiRoleLabel: 'Client',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Present design rationale',
          'Address client concerns',
          'Propose revisions',
        ],
        evaluationCriteria: <String>['Design thinking', 'Communication', 'Problem solving'],
        roleplayGuide:
            'You are a design client with budget and aesthetic constraints. '
            'Challenge the student\'s design choices and ask about feasibility.',
      ),
    ],
    'humanities': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'literary_debate',
        title: 'Literary Analysis Debate',
        description: 'Defend your interpretation of a text in an academic discussion.',
        avatarRole: AvatarRole.teacher,
        aiRoleLabel: 'Professor',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Construct a thesis',
          'Support with evidence',
          'Respond to counterarguments',
        ],
        evaluationCriteria: <String>['Critical thinking', 'Argumentation', 'Communication'],
        roleplayGuide:
            'You are a humanities professor challenging a student\'s literary interpretation. '
            'Ask probing questions and present alternative readings.',
      ),
    ],
    'hospitality_tourism': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'guest_complaint',
        title: 'Upset Hotel Guest',
        description: 'Resolve a complaint from a VIP guest during a busy weekend.',
        avatarRole: AvatarRole.customer,
        aiRoleLabel: 'Guest',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'De-escalate the situation',
          'Offer appropriate remedies',
          'Maintain brand standards',
        ],
        evaluationCriteria: <String>['Customer service', 'Problem solving', 'Communication'],
        roleplayGuide:
            'You are an upset hotel guest whose reservation was mishandled. '
            'React to how the student resolves your complaint.',
      ),
      PracticeScenarioTemplate(
        id: 'event_crisis',
        title: 'Event Day Crisis',
        description: 'Manage a last-minute vendor cancellation for a large corporate event.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Event Client',
        defaultDifficulty: PracticeDifficulty.advanced,
        studentTasks: <String>[
          'Assess impact',
          'Propose backup plans',
          'Communicate with stakeholders',
        ],
        evaluationCriteria: <String>['Crisis management', 'Planning', 'Communication'],
        roleplayGuide:
            'You are a corporate client whose event is at risk. Push for fast, realistic solutions.',
      ),
    ],
    'agriculture_environment': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'crop_disease_outbreak',
        title: 'Crop Disease Outbreak',
        description: 'Diagnose and recommend treatment for a spreading crop disease on a farm.',
        avatarRole: AvatarRole.client,
        aiRoleLabel: 'Farm Owner',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Assess the outbreak',
          'Recommend treatment options',
          'Advise on prevention',
        ],
        evaluationCriteria: <String>['Technical knowledge', 'Decision making', 'Communication'],
        roleplayGuide:
            'You are a farm owner worried about crop losses. Provide symptoms when asked. '
            'React to the student\'s recommendations.',
      ),
    ],
    'public_safety_government': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'disaster_response',
        title: 'Disaster Response Briefing',
        description: 'Coordinate an emergency response to a natural disaster in your jurisdiction.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Emergency Director',
        defaultDifficulty: PracticeDifficulty.advanced,
        studentTasks: <String>[
          'Prioritize resources',
          'Coordinate agencies',
          'Communicate with the public',
        ],
        evaluationCriteria: <String>['Crisis leadership', 'Decision making', 'Communication'],
        roleplayGuide:
            'You are an emergency management director briefing a student on an active disaster. '
            'Provide evolving conditions and challenge weak prioritization.',
      ),
      PracticeScenarioTemplate(
        id: 'policy_briefing',
        title: 'Policy Briefing',
        description: 'Brief elected officials on a controversial public policy proposal.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'City Council Member',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Present policy analysis',
          'Address political concerns',
          'Recommend a path forward',
        ],
        evaluationCriteria: <String>['Policy analysis', 'Communication', 'Critical thinking'],
        roleplayGuide:
            'You are a skeptical city council member evaluating a policy proposal. '
            'Ask tough questions about cost, equity, and political feasibility.',
      ),
    ],
  };

  static final Map<String, List<PracticeScenarioTemplate>> _majorScenarios =
      <String, List<PracticeScenarioTemplate>>{
    'nursing': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'nursing_chest_pain',
        title: 'Chest Pain in the ER',
        description: 'A 58-year-old male presents with chest pain. Assess urgency and recommend next actions.',
        avatarRole: AvatarRole.patient,
        aiRoleLabel: 'Patient',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Ask assessment questions',
          'Determine urgency',
          'Recommend nursing interventions',
        ],
        evaluationCriteria: <String>['Communication', 'Safety', 'Clinical judgment'],
        roleplayGuide:
            'You are a realistic 58-year-old male patient with chest pain in the ER. '
            'Provide symptoms and history when asked. Show anxiety. Do not self-diagnose.',
      ),
      PracticeScenarioTemplate(
        id: 'nursing_post_op',
        title: 'Post-Op Complication',
        description: 'A post-surgical patient reports shortness of breath. Identify and respond to complications.',
        avatarRole: AvatarRole.patient,
        aiRoleLabel: 'Patient',
        defaultDifficulty: PracticeDifficulty.advanced,
        studentTasks: <String>[
          'Assess respiratory status',
          'Identify warning signs',
          'Escalate care appropriately',
        ],
        evaluationCriteria: <String>['Clinical judgment', 'Safety', 'Communication'],
        roleplayGuide:
            'You are a post-operative patient with worsening shortness of breath. '
            'Answer assessment questions realistically. Symptoms may worsen if mismanaged.',
      ),
      PracticeScenarioTemplate(
        id: 'nursing_pediatric_fever',
        title: 'Pediatric Fever',
        description: 'A parent brings in a 6-year-old with high fever. Triage and educate the caregiver.',
        avatarRole: AvatarRole.client,
        aiRoleLabel: 'Parent',
        defaultDifficulty: PracticeDifficulty.beginner,
        studentTasks: <String>[
          'Take a focused history',
          'Assess red-flag symptoms',
          'Provide clear caregiver education',
        ],
        evaluationCriteria: <String>['Communication', 'Assessment', 'Patient education'],
        roleplayGuide:
            'You are an anxious parent of a 6-year-old with fever. Answer questions about the child\'s symptoms. '
            'React to how well the nurse explains next steps.',
      ),
      PracticeScenarioTemplate(
        id: 'nursing_shift_handoff',
        title: 'Shift Handoff Report',
        description: 'Give a structured handoff report for a complex patient.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Charge Nurse',
        defaultDifficulty: PracticeDifficulty.intermediate,
        studentTasks: <String>[
          'Deliver SBAR handoff',
          'Highlight critical changes',
          'Anticipate questions',
        ],
        evaluationCriteria: <String>['Communication', 'Clinical knowledge', 'Patient safety'],
        roleplayGuide:
            'You are a charge nurse receiving shift report. Ask clarifying questions. '
            'Flag gaps in the handoff related to patient safety.',
      ),
    ],
    'computer_science': _groupScenarios['computer_technology']!,
    'software_engineering': _groupScenarios['computer_technology']!,
    'web_development': _groupScenarios['computer_technology']!,
    'game_development': _groupScenarios['computer_technology']!,
    'cybersecurity': _groupScenarios['computer_technology']!,
    'data_science': <PracticeScenarioTemplate>[
      PracticeScenarioTemplate(
        id: 'data_analysis_project',
        title: 'Data Analysis Project',
        description: 'Analyze a dataset and present insights to stakeholders.',
        avatarRole: AvatarRole.manager,
        aiRoleLabel: 'Product Manager',
        studentTasks: <String>[
          'Explore and clean data',
          'Choose appropriate methods',
          'Present actionable insights',
        ],
        evaluationCriteria: <String>['Analytical thinking', 'Statistical reasoning', 'Communication'],
        roleplayGuide:
            'You are a product manager who needs data-driven decisions. '
            'Ask about methodology, limitations, and business impact of findings.',
      ),
    ],
  };

  static List<PracticeLabSubjectGroup> get subjectGroups => PracticeLabsCatalog.groups;

  static List<PracticeLabCategory> get allMajors =>
      subjectGroups.expand((PracticeLabSubjectGroup g) => g.subjects).toList();

  /// Featured majors shown in the home grid (matches common programs).
  static const List<({String id, String label})> featuredMajorEntries = <({String id, String label})>[
    (id: 'nursing', label: 'Nursing'),
    (id: 'pre_med', label: 'Pre-Med'),
    (id: 'business_administration', label: 'Business'),
    (id: 'computer_science', label: 'Computer Science'),
    (id: 'mechanical_engineering', label: 'Engineering'),
    (id: 'psychology', label: 'Psychology'),
    (id: 'law', label: 'Law'),
  ];

  static List<({PracticeLabCategory major, String label})> get featuredMajors {
    final List<({PracticeLabCategory major, String label})> result = <({PracticeLabCategory major, String label})>[];
    for (final ({String id, String label}) entry in featuredMajorEntries) {
      final PracticeLabCategory? major = majorById(entry.id);
      if (major != null) result.add((major: major, label: entry.label));
    }
    return result;
  }

  static PracticeLabCategory? majorById(String id) => PracticeLabsCatalog.categoryById(id);

  static Color difficultyColor(PracticeDifficulty difficulty) {
    return switch (difficulty) {
      PracticeDifficulty.beginner => StudyColors.success,
      PracticeDifficulty.intermediate => StudyColors.warning,
      PracticeDifficulty.advanced => StudyColors.danger,
    };
  }
}
