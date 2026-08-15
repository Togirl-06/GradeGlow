import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

const List<PracticeLabTopicArea> lawTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'criminal_law',
    name: 'Criminal Law',
    emoji: '⚖️',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'evidence_review', name: 'Evidence Review', description: 'Analyze admissibility of evidence before trial.', style: SimulationStyle.courtroom, aiRole: 'Judge'),
      PracticeLabTopic(id: 'witness_questioning', name: 'Witness Questioning', description: 'Cross-examine a hostile witness on the stand.', style: SimulationStyle.courtroom, aiRole: 'Witness', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'trial_strategy', name: 'Trial Strategy', description: 'Develop opening and closing arguments for a complex case.', style: SimulationStyle.courtroom, aiRole: 'Opposing Counsel', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'constitutional_law',
    name: 'Constitutional Law',
    emoji: '📜',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'rights_analysis', name: 'Rights Analysis', description: 'Apply constitutional protections to a contemporary civil rights case.', style: SimulationStyle.courtroom, aiRole: 'Law Professor'),
      PracticeLabTopic(id: 'court_arguments', name: 'Court Arguments', description: 'Orally argue a constitutional issue before an appellate panel.', style: SimulationStyle.courtroom, aiRole: 'Appellate Judge', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'supreme_court', name: 'Supreme Court Simulations', description: 'Present oral arguments on a landmark constitutional question.', style: SimulationStyle.courtroom, aiRole: 'Supreme Court Justice', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'contract_law',
    name: 'Contract Law',
    emoji: '📝',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'contract_review', name: 'Contract Review', description: 'Spot risky clauses in a vendor agreement before signing.', style: SimulationStyle.courtroom, aiRole: 'General Counsel'),
      PracticeLabTopic(id: 'negotiations', name: 'Negotiations', description: 'Negotiate terms with a counterpart who wants one-sided protections.', style: SimulationStyle.customerScenario, aiRole: 'Business Partner', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'business_disputes', name: 'Business Disputes', description: 'Resolve a breach-of-contract dispute without litigation.', style: SimulationStyle.courtroom, aiRole: 'Mediator', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];
