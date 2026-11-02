import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

const List<PracticeLabTopicArea> businessTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'marketing',
    name: 'Marketing',
    emoji: '📣',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'market_research', name: 'Market Research', description: 'Design a research plan to validate a new product concept.', style: SimulationStyle.customerScenario, aiRole: 'Marketing Director'),
      PracticeLabTopic(id: 'customer_personas', name: 'Customer Personas', description: 'Build personas and pitch them to a skeptical product team.', style: SimulationStyle.customerScenario, aiRole: 'Product Manager'),
      PracticeLabTopic(id: 'campaign_planning', name: 'Campaign Planning', description: 'Plan a multi-channel launch campaign on a tight budget.', style: SimulationStyle.customerScenario, aiRole: 'CMO', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'brand_crisis', name: 'Brand Crisis Management', description: 'Manage a viral backlash threatening brand reputation.', style: SimulationStyle.customerScenario, aiRole: 'CEO', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'finance',
    name: 'Finance',
    emoji: '💰',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'budgeting', name: 'Budgeting', description: 'Build a departmental budget and defend cuts to leadership.', style: SimulationStyle.customerScenario, aiRole: 'CFO'),
      PracticeLabTopic(id: 'investments', name: 'Investments', description: 'Recommend a portfolio allocation for a risk-averse client.', style: SimulationStyle.customerScenario, aiRole: 'Client', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'financial_analysis', name: 'Financial Analysis', description: 'Analyze financial statements and identify red flags.', style: SimulationStyle.diagnosis, aiRole: 'Investment Analyst', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'corporate_finance', name: 'Corporate Finance', description: 'Evaluate an acquisition target and structure the deal.', style: SimulationStyle.customerScenario, aiRole: 'Board Member', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'accounting',
    name: 'Accounting',
    emoji: '🧮',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'journal_entries', name: 'Journal Entries', description: 'Record complex transactions and explain GAAP treatment.', style: SimulationStyle.classroom, aiRole: 'Senior Accountant'),
      PracticeLabTopic(id: 'payroll', name: 'Payroll', description: 'Resolve a payroll discrepancy flagged during an internal audit.', style: SimulationStyle.diagnosis, aiRole: 'Controller', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'auditing', name: 'Auditing', description: 'Plan audit procedures and respond to a material misstatement.', style: SimulationStyle.customerScenario, aiRole: 'Audit Partner', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'tax_strategy', name: 'Tax Strategy', description: 'Advise a business owner on tax-efficient restructuring.', style: SimulationStyle.customerScenario, aiRole: 'Business Owner', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'management',
    name: 'Management',
    emoji: '👔',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'team_leadership', name: 'Team Leadership', description: 'Motivate a disengaged team after a failed project.', style: SimulationStyle.customerScenario, aiRole: 'Team Lead'),
      PracticeLabTopic(id: 'conflict_resolution', name: 'Conflict Resolution', description: 'Mediate a conflict between two high-performing team members.', style: SimulationStyle.customerScenario, aiRole: 'Employee', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'hiring_decisions', name: 'Hiring Decisions', description: 'Conduct a final-round interview and make a hiring recommendation.', style: SimulationStyle.customerScenario, aiRole: 'Candidate', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'org_restructuring', name: 'Organizational Restructuring', description: 'Lead a reorg announcement to worried department heads.', style: SimulationStyle.customerScenario, aiRole: 'Department Head', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];
