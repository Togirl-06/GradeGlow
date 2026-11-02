import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> accountingMajorTopics = majorTopicAreas(
  majorId: 'accounting',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'financial_accounting',
      name: 'Financial Accounting',
      emoji: '📒',
      topics: <PracticeLabTopic>[
        labTopic(id: 'journal_entries', name: 'Journal Entries', description: 'Record complex transactions and explain GAAP treatment.', style: SimulationStyle.classroom, aiRole: 'Senior Accountant'),
        labTopic(id: 'financial_statements', name: 'Financial Statements', description: 'Prepare and interpret balance sheet, income statement, and cash flow.', style: SimulationStyle.diagnosis, aiRole: 'Controller'),
        labTopic(id: 'revenue_recognition', name: 'Revenue Recognition', description: 'Apply ASC 606 to a multi-element software contract.', style: SimulationStyle.diagnosis, aiRole: 'Audit Manager', advanced: true),
      ],
    ),
    (
      id: 'audit_tax',
      name: 'Audit & Tax',
      emoji: '🧾',
      topics: <PracticeLabTopic>[
        labTopic(id: 'auditing', name: 'Auditing Procedures', description: 'Plan audit procedures and respond to a material misstatement.', style: SimulationStyle.customerScenario, aiRole: 'Audit Partner'),
        labTopic(id: 'tax_strategy', name: 'Tax Strategy', description: 'Advise a business owner on tax-efficient restructuring.', style: SimulationStyle.customerScenario, aiRole: 'Business Owner', advanced: true),
        labTopic(id: 'payroll', name: 'Payroll & Compliance', description: 'Resolve payroll discrepancies flagged during an internal audit.', style: SimulationStyle.diagnosis, aiRole: 'Payroll Manager'),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> financeMajorTopics = majorTopicAreas(
  majorId: 'finance',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'corporate_finance',
      name: 'Corporate Finance',
      emoji: '🏦',
      topics: <PracticeLabTopic>[
        labTopic(id: 'valuation', name: 'Company Valuation', description: 'Value a private company using DCF and comparables for an acquisition.', style: SimulationStyle.customerScenario, aiRole: 'Investment Banker'),
        labTopic(id: 'capital_structure', name: 'Capital Structure', description: 'Recommend debt vs equity financing for a growth-stage firm.', style: SimulationStyle.customerScenario, aiRole: 'CFO', advanced: true),
        labTopic(id: 'm_and_a', name: 'Mergers & Acquisitions', description: 'Evaluate synergies and structure a merger deal.', style: SimulationStyle.customerScenario, aiRole: 'Board Member', advanced: true),
      ],
    ),
    (
      id: 'investments',
      name: 'Investments & Markets',
      emoji: '📈',
      topics: <PracticeLabTopic>[
        labTopic(id: 'portfolio', name: 'Portfolio Management', description: 'Recommend allocation for a risk-averse retiree client.', style: SimulationStyle.customerScenario, aiRole: 'Wealth Client'),
        labTopic(id: 'financial_analysis', name: 'Financial Analysis', description: 'Analyze statements and identify red flags before lending.', style: SimulationStyle.diagnosis, aiRole: 'Credit Analyst'),
        labTopic(id: 'derivatives', name: 'Derivatives & Hedging', description: 'Design a hedge for currency exposure in international operations.', style: SimulationStyle.systemDesign, aiRole: 'Treasury Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> marketingMajorTopics = majorTopicAreas(
  majorId: 'marketing',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'market_research',
      name: 'Market Research',
      emoji: '🔎',
      topics: <PracticeLabTopic>[
        labTopic(id: 'consumer_insights', name: 'Consumer Insights', description: 'Design a research plan to validate a new product concept.', style: SimulationStyle.customerScenario, aiRole: 'Marketing Director'),
        labTopic(id: 'personas', name: 'Customer Personas', description: 'Build personas and pitch them to a skeptical product team.', style: SimulationStyle.customerScenario, aiRole: 'Product Manager'),
        labTopic(id: 'competitive_analysis', name: 'Competitive Analysis', description: 'Position against entrenched competitors in a crowded market.', style: SimulationStyle.customerScenario, aiRole: 'CMO', advanced: true),
      ],
    ),
    (
      id: 'campaigns',
      name: 'Campaigns & Brand',
      emoji: '📣',
      topics: <PracticeLabTopic>[
        labTopic(id: 'campaign_planning', name: 'Campaign Planning', description: 'Plan a multi-channel launch on a tight budget.', style: SimulationStyle.customerScenario, aiRole: 'Brand Manager'),
        labTopic(id: 'digital_marketing', name: 'Digital Marketing', description: 'Optimize ad spend across channels with declining ROAS.', style: SimulationStyle.diagnosis, aiRole: 'Growth Lead'),
        labTopic(id: 'brand_crisis', name: 'Brand Crisis', description: 'Manage viral backlash threatening brand reputation.', style: SimulationStyle.customerScenario, aiRole: 'CEO', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> managementMajorTopics = majorTopicAreas(
  majorId: 'management',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'leadership',
      name: 'Leadership',
      emoji: '👔',
      topics: <PracticeLabTopic>[
        labTopic(id: 'team_leadership', name: 'Team Leadership', description: 'Motivate a disengaged team after a failed project.', style: SimulationStyle.customerScenario, aiRole: 'Team Lead'),
        labTopic(id: 'conflict_resolution', name: 'Conflict Resolution', description: 'Mediate conflict between two high-performing team members.', style: SimulationStyle.customerScenario, aiRole: 'Employee'),
        labTopic(id: 'org_restructuring', name: 'Organizational Change', description: 'Lead a reorg announcement to worried department heads.', style: SimulationStyle.customerScenario, aiRole: 'Department Head', advanced: true),
      ],
    ),
    (
      id: 'operations',
      name: 'Operations Management',
      emoji: '⚙️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'process_improvement', name: 'Process Improvement', description: 'Apply Lean principles to reduce waste in a service operation.', style: SimulationStyle.diagnosis, aiRole: 'Operations VP'),
        labTopic(id: 'kpi_management', name: 'KPI Management', description: 'Set measurable goals and hold managers accountable.', style: SimulationStyle.customerScenario, aiRole: 'Regional Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> businessAdministrationMajorTopics = majorTopicAreas(
  majorId: 'business_administration',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'strategy',
      name: 'Business Strategy',
      emoji: '🎯',
      topics: <PracticeLabTopic>[
        labTopic(id: 'swot', name: 'Strategic Analysis', description: 'Conduct SWOT analysis and recommend a 3-year growth strategy.', style: SimulationStyle.customerScenario, aiRole: 'Board Advisor'),
        labTopic(id: 'competitive_strategy', name: 'Competitive Strategy', description: 'Defend market position against a disruptive entrant.', style: SimulationStyle.customerScenario, aiRole: 'Strategy Consultant', advanced: true),
      ],
    ),
    (
      id: 'general_management',
      name: 'General Management',
      emoji: '🏢',
      topics: <PracticeLabTopic>[
        labTopic(id: 'cross_functional', name: 'Cross-Functional Leadership', description: 'Align marketing, finance, and ops on a company-wide initiative.', style: SimulationStyle.customerScenario, aiRole: 'Division President'),
        labTopic(id: 'stakeholder_mgmt', name: 'Stakeholder Management', description: 'Balance investor, employee, and customer demands during a pivot.', style: SimulationStyle.customerScenario, aiRole: 'CEO', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> economicsMajorTopics = majorTopicAreas(
  majorId: 'economics',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'microeconomics',
      name: 'Microeconomics',
      emoji: '📉',
      topics: <PracticeLabTopic>[
        labTopic(id: 'supply_demand', name: 'Supply & Demand', description: 'Predict price effects of a supply shock and advise policymakers.', style: SimulationStyle.classroom, aiRole: 'Policy Advisor'),
        labTopic(id: 'market_structures', name: 'Market Structures', description: 'Analyze monopoly vs oligopoly behavior in a regulated industry.', style: SimulationStyle.classroom, aiRole: 'Economics Professor', advanced: true),
      ],
    ),
    (
      id: 'macroeconomics',
      name: 'Macroeconomics',
      emoji: '🌍',
      topics: <PracticeLabTopic>[
        labTopic(id: 'fiscal_policy', name: 'Fiscal Policy', description: 'Debate stimulus trade-offs during a recession.', style: SimulationStyle.customerScenario, aiRole: 'Treasury Official'),
        labTopic(id: 'monetary_policy', name: 'Monetary Policy', description: 'Explain interest rate decisions to anxious business leaders.', style: SimulationStyle.customerScenario, aiRole: 'Central Bank Analyst', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> entrepreneurshipMajorTopics = majorTopicAreas(
  majorId: 'entrepreneurship',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'startup',
      name: 'Startup Fundamentals',
      emoji: '🚀',
      topics: <PracticeLabTopic>[
        labTopic(id: 'pitch', name: 'Investor Pitch', description: 'Pitch your startup to skeptical VCs in a 10-minute session.', style: SimulationStyle.customerScenario, aiRole: 'Venture Partner'),
        labTopic(id: 'mvp', name: 'MVP Validation', description: 'Decide what to build first with limited runway.', style: SimulationStyle.customerScenario, aiRole: 'Co-Founder'),
        labTopic(id: 'pivot', name: 'Pivot Decisions', description: 'Evaluate whether to pivot based on traction data.', style: SimulationStyle.customerScenario, aiRole: 'Accelerator Mentor', advanced: true),
      ],
    ),
    (
      id: 'growth',
      name: 'Growth & Scaling',
      emoji: '📊',
      topics: <PracticeLabTopic>[
        labTopic(id: 'unit_economics', name: 'Unit Economics', description: 'Fix CAC/LTV before scaling paid acquisition.', style: SimulationStyle.diagnosis, aiRole: 'Growth Advisor'),
        labTopic(id: 'fundraising', name: 'Fundraising Strategy', description: 'Choose seed vs Series A timing and term sheet trade-offs.', style: SimulationStyle.customerScenario, aiRole: 'Angel Investor', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> humanResourcesMajorTopics = majorTopicAreas(
  majorId: 'human_resources',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'talent',
      name: 'Talent Management',
      emoji: '👥',
      topics: <PracticeLabTopic>[
        labTopic(id: 'hiring', name: 'Hiring & Selection', description: 'Conduct final-round interviews and make a hiring recommendation.', style: SimulationStyle.customerScenario, aiRole: 'Candidate'),
        labTopic(id: 'onboarding', name: 'Onboarding Programs', description: 'Design onboarding that reduces 90-day attrition.', style: SimulationStyle.customerScenario, aiRole: 'New Hire'),
        labTopic(id: 'performance', name: 'Performance Reviews', description: 'Deliver difficult performance feedback to a defensive employee.', style: SimulationStyle.customerScenario, aiRole: 'Employee', advanced: true),
      ],
    ),
    (
      id: 'hr_compliance',
      name: 'HR Compliance',
      emoji: '⚖️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'workplace_investigation', name: 'Workplace Investigations', description: 'Investigate harassment allegations while protecting all parties.', style: SimulationStyle.customerScenario, aiRole: 'Complainant'),
        labTopic(id: 'compensation', name: 'Compensation Planning', description: 'Design equitable pay bands amid budget constraints.', style: SimulationStyle.customerScenario, aiRole: 'Finance Partner', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> supplyChainMajorTopics = majorTopicAreas(
  majorId: 'supply_chain_management',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'logistics',
      name: 'Logistics & Distribution',
      emoji: '🚚',
      topics: <PracticeLabTopic>[
        labTopic(id: 'inventory', name: 'Inventory Management', description: 'Balance stockouts vs carrying costs during demand surge.', style: SimulationStyle.diagnosis, aiRole: 'Warehouse Director'),
        labTopic(id: 'routing', name: 'Route Optimization', description: 'Redesign last-mile delivery after carrier failures.', style: SimulationStyle.systemDesign, aiRole: 'Logistics Manager'),
      ],
    ),
    (
      id: 'procurement',
      name: 'Procurement',
      emoji: '📦',
      topics: <PracticeLabTopic>[
        labTopic(id: 'supplier_negotiation', name: 'Supplier Negotiation', description: 'Renegotiate contracts during a supply shortage.', style: SimulationStyle.customerScenario, aiRole: 'Supplier VP'),
        labTopic(id: 'risk_mitigation', name: 'Supply Risk', description: 'Diversify suppliers after a geopolitical disruption.', style: SimulationStyle.customerScenario, aiRole: 'Chief Supply Officer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> internationalBusinessMajorTopics = majorTopicAreas(
  majorId: 'international_business',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'global_markets',
      name: 'Global Markets',
      emoji: '🌐',
      topics: <PracticeLabTopic>[
        labTopic(id: 'market_entry', name: 'Market Entry Strategy', description: 'Choose market entry mode for expansion into Southeast Asia.', style: SimulationStyle.customerScenario, aiRole: 'Regional Director'),
        labTopic(id: 'trade_compliance', name: 'Trade Compliance', description: 'Navigate tariffs and export controls for a new product line.', style: SimulationStyle.diagnosis, aiRole: 'Trade Compliance Officer', advanced: true),
      ],
    ),
    (
      id: 'cross_cultural',
      name: 'Cross-Cultural Management',
      emoji: '🤝',
      topics: <PracticeLabTopic>[
        labTopic(id: 'global_teams', name: 'Global Team Leadership', description: 'Align distributed teams across time zones and cultures.', style: SimulationStyle.customerScenario, aiRole: 'Country Manager'),
        labTopic(id: 'fx_risk', name: 'Currency & FX Risk', description: 'Hedge foreign exchange exposure for multinational operations.', style: SimulationStyle.customerScenario, aiRole: 'Treasury Analyst', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> businessAnalyticsMajorTopics = majorTopicAreas(
  majorId: 'business_analytics',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'analytics',
      name: 'Business Analytics',
      emoji: '📊',
      topics: <PracticeLabTopic>[
        labTopic(id: 'kpi_design', name: 'KPI Design', description: 'Define metrics that align teams without gaming behavior.', style: SimulationStyle.customerScenario, aiRole: 'COO'),
        labTopic(id: 'dashboards', name: 'Executive Dashboards', description: 'Build dashboards that drive decisions for C-suite.', style: SimulationStyle.customerScenario, aiRole: 'CEO'),
        labTopic(id: 'predictive_biz', name: 'Predictive Analytics', description: 'Forecast churn and recommend retention interventions.', style: SimulationStyle.diagnosis, aiRole: 'VP Analytics', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> realEstateMajorTopics = majorTopicAreas(
  majorId: 'real_estate',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'transactions',
      name: 'Real Estate Transactions',
      emoji: '🏠',
      topics: <PracticeLabTopic>[
        labTopic(id: 'property_valuation', name: 'Property Valuation', description: 'Appraise a commercial property with mixed-use complications.', style: SimulationStyle.diagnosis, aiRole: 'Appraiser'),
        labTopic(id: 'negotiation', name: 'Deal Negotiation', description: 'Negotiate purchase terms in a competitive bidding war.', style: SimulationStyle.customerScenario, aiRole: 'Seller Agent'),
        labTopic(id: 'due_diligence', name: 'Due Diligence', description: 'Uncover environmental liens before closing a development deal.', style: SimulationStyle.diagnosis, aiRole: 'Real Estate Attorney', advanced: true),
      ],
    ),
    (
      id: 'development',
      name: 'Property Development',
      emoji: '🏗️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'zoning', name: 'Zoning & Permits', description: 'Navigate zoning hearings for a controversial mixed-use project.', style: SimulationStyle.customerScenario, aiRole: 'City Planner'),
        labTopic(id: 'pro_forma', name: 'Development Pro Forma', description: 'Model ROI for a multifamily development with rising rates.', style: SimulationStyle.diagnosis, aiRole: 'Development Partner', advanced: true),
      ],
    ),
  ],
);

final Map<String, List<PracticeLabTopicArea>> businessTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'accounting': accountingMajorTopics,
  'finance': financeMajorTopics,
  'marketing': marketingMajorTopics,
  'management': managementMajorTopics,
  'business_administration': businessAdministrationMajorTopics,
  'economics': economicsMajorTopics,
  'entrepreneurship': entrepreneurshipMajorTopics,
  'human_resources': humanResourcesMajorTopics,
  'supply_chain_management': supplyChainMajorTopics,
  'international_business': internationalBusinessMajorTopics,
  'business_analytics': businessAnalyticsMajorTopics,
  'real_estate': realEstateMajorTopics,
};
