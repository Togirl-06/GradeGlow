import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> lawMajorTopics = majorTopicAreas(
  majorId: 'law',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'criminal',
      name: 'Criminal Law',
      emoji: '⚖️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'evidence', name: 'Evidence Review', description: 'Analyze admissibility of evidence before trial.', style: SimulationStyle.courtroom, aiRole: 'Judge'),
        labTopic(id: 'cross_exam', name: 'Cross-Examination', description: 'Cross-examine a hostile witness on the stand.', style: SimulationStyle.courtroom, aiRole: 'Witness', advanced: true),
        labTopic(id: 'trial_strategy', name: 'Trial Strategy', description: 'Develop opening and closing arguments for a complex case.', style: SimulationStyle.courtroom, aiRole: 'Opposing Counsel', advanced: true),
      ],
    ),
    (
      id: 'constitutional',
      name: 'Constitutional Law',
      emoji: '📜',
      topics: <PracticeLabTopic>[
        labTopic(id: 'rights', name: 'Rights Analysis', description: 'Apply constitutional protections to a civil rights case.', style: SimulationStyle.courtroom, aiRole: 'Law Professor'),
        labTopic(id: 'appellate', name: 'Appellate Arguments', description: 'Orally argue a constitutional issue before an appellate panel.', style: SimulationStyle.courtroom, aiRole: 'Appellate Judge', advanced: true),
      ],
    ),
    (
      id: 'contracts',
      name: 'Contract Law',
      emoji: '📝',
      topics: <PracticeLabTopic>[
        labTopic(id: 'contract_review', name: 'Contract Review', description: 'Spot risky clauses in a vendor agreement before signing.', style: SimulationStyle.courtroom, aiRole: 'General Counsel'),
        labTopic(id: 'negotiation', name: 'Contract Negotiation', description: 'Negotiate terms with a counterpart wanting one-sided protections.', style: SimulationStyle.customerScenario, aiRole: 'Business Partner', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> preLawMajorTopics = majorTopicAreas(
  majorId: 'pre_law',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'legal_foundations',
      name: 'Legal Foundations',
      emoji: '📚',
      topics: <PracticeLabTopic>[
        labTopic(id: 'case_briefing', name: 'Case Briefing', description: 'Brief a landmark case and present the holding to class.', style: SimulationStyle.classroom, aiRole: 'Law Professor'),
        labTopic(id: 'legal_writing', name: 'Legal Writing', description: 'Draft a persuasive memo analyzing a fact pattern.', style: SimulationStyle.classroom, aiRole: 'Writing Instructor'),
        labTopic(id: 'moot_court', name: 'Moot Court Intro', description: 'Deliver your first oral argument before a student panel.', style: SimulationStyle.courtroom, aiRole: 'Student Judge', advanced: true),
      ],
    ),
    (
      id: 'lsat_prep',
      name: 'Law School Prep',
      emoji: '🎓',
      topics: <PracticeLabTopic>[
        labTopic(id: 'logical_reasoning', name: 'Logical Reasoning', description: 'Analyze logical fallacies in a complex argument structure.', style: SimulationStyle.classroom, aiRole: 'LSAT Tutor'),
        labTopic(id: 'ethical_dilemmas', name: 'Ethical Dilemmas', description: 'Discuss professional ethics scenarios for law school applications.', style: SimulationStyle.customerScenario, aiRole: 'Admissions Interviewer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> criminalJusticeMajorTopics = majorTopicAreas(
  majorId: 'criminal_justice',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'policing',
      name: 'Policing & Investigation',
      emoji: '🚔',
      topics: <PracticeLabTopic>[
        labTopic(id: 'crime_scene', name: 'Crime Scene Response', description: 'Secure a scene and prioritize evidence collection.', style: SimulationStyle.diagnosis, aiRole: 'Detective'),
        labTopic(id: 'interrogation', name: 'Interview & Interrogation', description: 'Conduct a witness interview without contaminating testimony.', style: SimulationStyle.courtroom, aiRole: 'Witness'),
        labTopic(id: 'use_of_force', name: 'Use of Force Review', description: 'Evaluate use-of-force incident against policy and law.', style: SimulationStyle.customerScenario, aiRole: 'Internal Affairs', advanced: true),
      ],
    ),
    (
      id: 'corrections',
      name: 'Corrections & Courts',
      emoji: '🏛️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'probation', name: 'Probation Decisions', description: 'Recommend supervision level for a parole hearing.', style: SimulationStyle.courtroom, aiRole: 'Parole Board'),
        labTopic(id: 'juvenile', name: 'Juvenile Justice', description: 'Balance rehabilitation and accountability for a minor offender.', style: SimulationStyle.counseling, aiRole: 'Juvenile Offender', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> criminologyMajorTopics = majorTopicAreas(
  majorId: 'criminology',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'crime_theory',
      name: 'Criminology Theory',
      emoji: '🔍',
      topics: <PracticeLabTopic>[
        labTopic(id: 'theory_application', name: 'Theory Application', description: 'Apply strain theory to explain a neighborhood crime pattern.', style: SimulationStyle.classroom, aiRole: 'Criminology Professor'),
        labTopic(id: 'research_design', name: 'Crime Research Design', description: 'Design a study measuring deterrence effects ethically.', style: SimulationStyle.classroom, aiRole: 'Research Advisor', advanced: true),
      ],
    ),
    (
      id: 'policy',
      name: 'Crime Policy',
      emoji: '📋',
      topics: <PracticeLabTopic>[
        labTopic(id: 'prevention', name: 'Crime Prevention', description: 'Recommend evidence-based prevention for rising property crime.', style: SimulationStyle.customerScenario, aiRole: 'City Council Member'),
        labTopic(id: 'sentencing_reform', name: 'Sentencing Reform', description: 'Debate mandatory minimums with policymakers and advocates.', style: SimulationStyle.customerScenario, aiRole: 'Policy Advocate', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> paralegalMajorTopics = majorTopicAreas(
  majorId: 'paralegal_studies',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'paralegal_practice',
      name: 'Paralegal Practice',
      emoji: '📁',
      topics: <PracticeLabTopic>[
        labTopic(id: 'discovery', name: 'Discovery Management', description: 'Organize discovery documents and privilege log for litigation.', style: SimulationStyle.diagnosis, aiRole: 'Litigation Partner'),
        labTopic(id: 'pleadings', name: 'Pleading Drafting', description: 'Draft a complaint from client intake notes.', style: SimulationStyle.classroom, aiRole: 'Supervising Attorney'),
        labTopic(id: 'client_intake', name: 'Client Intake', description: 'Conduct intake and identify conflicts of interest.', style: SimulationStyle.customerScenario, aiRole: 'Prospective Client', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> homelandSecurityMajorTopics = majorTopicAreas(
  majorId: 'homeland_security',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'threat_assessment',
      name: 'Threat Assessment',
      emoji: '🛡️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'intelligence', name: 'Intelligence Analysis', description: 'Fuse disparate intel reports into a threat briefing.', style: SimulationStyle.diagnosis, aiRole: 'Intelligence Analyst'),
        labTopic(id: 'critical_infra', name: 'Critical Infrastructure', description: 'Prioritize protection for facilities after a credible threat.', style: SimulationStyle.erEmergency, aiRole: 'DHS Coordinator', advanced: true),
      ],
    ),
    (
      id: 'emergency_mgmt',
      name: 'Emergency Management',
      emoji: '🚨',
      topics: <PracticeLabTopic>[
        labTopic(id: 'incident_command', name: 'Incident Command', description: 'Lead unified command during a multi-agency emergency.', style: SimulationStyle.erEmergency, aiRole: 'Incident Commander'),
        labTopic(id: 'border_security', name: 'Border Security Operations', description: 'Coordinate interdiction response to a smuggling network tip.', style: SimulationStyle.customerScenario, aiRole: 'Field Agent', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> forensicScienceMajorTopics = majorTopicAreas(
  majorId: 'forensic_science',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'forensics_lab',
      name: 'Forensic Laboratory',
      emoji: '🧪',
      topics: <PracticeLabTopic>[
        labTopic(id: 'dna_analysis', name: 'DNA Analysis', description: 'Interpret mixed DNA profiles and explain limitations in court.', style: SimulationStyle.courtroom, aiRole: 'Defense Attorney'),
        labTopic(id: 'trace_evidence', name: 'Trace Evidence', description: 'Link trace evidence to crime scene reconstruction.', style: SimulationStyle.diagnosis, aiRole: 'Crime Lab Director'),
        labTopic(id: 'chain_of_custody', name: 'Chain of Custody', description: 'Identify breaks in evidence handling that jeopardize a case.', style: SimulationStyle.diagnosis, aiRole: 'Prosecutor', advanced: true),
      ],
    ),
  ],
);

final Map<String, List<PracticeLabTopicArea>> lawTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'law': lawMajorTopics,
  'pre_law': preLawMajorTopics,
  'criminal_justice': criminalJusticeMajorTopics,
  'criminology': criminologyMajorTopics,
  'paralegal_studies': paralegalMajorTopics,
  'homeland_security': homelandSecurityMajorTopics,
  'forensic_science': forensicScienceMajorTopics,
};
