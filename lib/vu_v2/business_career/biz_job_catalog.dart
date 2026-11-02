/// Business career job board — typed listings with hourly wages in cents.
class BizJobListing {
  const BizJobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLetter,
    required this.mode,
    required this.level,
    required this.payLabel,
    required this.blurb,
    required this.skills,
    required this.majorTag,
    required this.hourlyWageCents,
  });

  final String id;
  final String title;
  final String company;
  final String companyLetter;
  final String mode;
  final String level;
  final String payLabel;
  final String blurb;
  final List<String> skills;
  final String majorTag;
  final int hourlyWageCents;
}

abstract final class BizCareerJobs {
  static const String flagshipJobId = 'apex_commerce_associate';

  static const List<BizJobListing> all = <BizJobListing>[
    // —— Business Administration ——
    BizJobListing(
      id: flagshipJobId,
      title: 'Business Associate',
      company: 'Apex Commerce',
      companyLetter: 'A',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$26.00 / hour',
      blurb:
          'Apex Commerce runs multi-channel retail operations. You will support '
          'store performance reviews, vendor follow-ups, and weekly ops rituals '
          'with a mentoring manager.',
      skills: <String>['Operations', 'Excel', 'Stakeholder updates', 'Prioritization'],
      majorTag: 'Business Administration',
      hourlyWageCents: 2600,
    ),
    BizJobListing(
      id: 'harbor_ops_coordinator',
      title: 'Operations Coordinator',
      company: 'Harbor Goods',
      companyLetter: 'H',
      mode: 'Office',
      level: 'Intern',
      payLabel: '\$18.00 / hour',
      blurb:
          'Harbor Goods needs a coordinator to track SLAs, prep standups, and '
          'keep inventory exceptions from becoming customer issues.',
      skills: <String>['Process', 'Scheduling', 'Documentation', 'Communication'],
      majorTag: 'Business Administration',
      hourlyWageCents: 1800,
    ),
    BizJobListing(
      id: 'lumen_project_analyst',
      title: 'Project Analyst',
      company: 'Lumen Retail Group',
      companyLetter: 'L',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$24.00 / hour',
      blurb:
          'Join cross-functional launches: timelines, risk logs, and crisp status '
          'for store and e-comm leaders.',
      skills: <String>['Project tracking', 'Risk logs', 'Writing', 'Analytics basics'],
      majorTag: 'Business Administration',
      hourlyWageCents: 2400,
    ),
    BizJobListing(
      id: 'summit_business_intern',
      title: 'Business Operations Intern',
      company: 'Summit Collective',
      companyLetter: 'S',
      mode: 'Hybrid',
      level: 'Intern',
      payLabel: '\$17.50 / hour',
      blurb:
          'Support process mapping and KPI dashboards for a growing services firm.',
      skills: <String>['KPIs', 'SOPs', 'Sheets', 'Curiosity'],
      majorTag: 'Business Administration',
      hourlyWageCents: 1750,
    ),

    // —— Accounting ——
    BizJobListing(
      id: 'ledgerline_staff',
      title: 'Staff Accountant',
      company: 'LedgerLine Partners',
      companyLetter: 'L',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$27.00 / hour',
      blurb:
          'Own month-end reconciliations, AP/AR support, and clean workpapers for '
          'review by seniors.',
      skills: <String>['Reconciliation', 'GAAP basics', 'Excel', 'Attention to detail'],
      majorTag: 'Accounting',
      hourlyWageCents: 2700,
    ),
    BizJobListing(
      id: 'clearaudit_intern',
      title: 'Audit Intern',
      company: 'ClearAudit LLP',
      companyLetter: 'C',
      mode: 'Office',
      level: 'Intern',
      payLabel: '\$20.00 / hour',
      blurb:
          'Assist walkthroughs, sampling, and documentation on mid-market audits.',
      skills: <String>['Sampling', 'Controls', 'Workpapers', 'Professional skepticism'],
      majorTag: 'Accounting',
      hourlyWageCents: 2000,
    ),
    BizJobListing(
      id: 'northbook_ap',
      title: 'Accounts Payable Specialist',
      company: 'Northbook Finance',
      companyLetter: 'N',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$22.50 / hour',
      blurb:
          'Process invoices, catch duplicates, and keep vendor aging healthy.',
      skills: <String>['AP', 'Vendor management', 'ERP basics', 'Accuracy'],
      majorTag: 'Accounting',
      hourlyWageCents: 2250,
    ),

    // —— Finance ——
    BizJobListing(
      id: 'pinnacle_analyst',
      title: 'Junior Financial Analyst',
      company: 'Pinnacle Capital',
      companyLetter: 'P',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$28.00 / hour',
      blurb:
          'Build models, track KPIs, and prep investment committee one-pagers.',
      skills: <String>['Modeling', 'Valuation basics', 'Excel', 'Writing'],
      majorTag: 'Finance',
      hourlyWageCents: 2800,
    ),
    BizJobListing(
      id: 'riverbank_treasury',
      title: 'Treasury Intern',
      company: 'Riverbank Holdings',
      companyLetter: 'R',
      mode: 'Office',
      level: 'Intern',
      payLabel: '\$19.00 / hour',
      blurb:
          'Support cash forecasting, bank reconciliations, and liquidity reports.',
      skills: <String>['Cash flow', 'Forecasting', 'Controls', 'Excel'],
      majorTag: 'Finance',
      hourlyWageCents: 1900,
    ),
    BizJobListing(
      id: 'orbit_fpna',
      title: 'FP&A Associate',
      company: 'Orbit Consumer Co.',
      companyLetter: 'O',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$26.50 / hour',
      blurb:
          'Partner with brand leads on budgets, variance analysis, and forecasts.',
      skills: <String>['FP&A', 'Variance analysis', 'Storytelling', 'SQL basics'],
      majorTag: 'Finance',
      hourlyWageCents: 2650,
    ),

    // —— Economics ——
    BizJobListing(
      id: 'policymap_ra',
      title: 'Research Assistant',
      company: 'PolicyMap Institute',
      companyLetter: 'P',
      mode: 'Hybrid',
      level: 'Intern',
      payLabel: '\$18.50 / hour',
      blurb:
          'Clean datasets, chart trends, and draft briefs on inflation and labor markets.',
      skills: <String>['Data cleaning', 'Charts', 'Writing', 'Statistics basics'],
      majorTag: 'Economics',
      hourlyWageCents: 1850,
    ),
    BizJobListing(
      id: 'metro_econ_analyst',
      title: 'Economic Analyst',
      company: 'Metro Analytics',
      companyLetter: 'M',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$25.00 / hour',
      blurb:
          'Model demand scenarios and explain trade-offs for municipal clients.',
      skills: <String>['Elasticities', 'Regression basics', 'Briefing', 'R/Python'],
      majorTag: 'Economics',
      hourlyWageCents: 2500,
    ),
    BizJobListing(
      id: 'grainbelt_market',
      title: 'Market Research Associate',
      company: 'Grainbelt Insights',
      companyLetter: 'G',
      mode: 'Office',
      level: 'Junior',
      payLabel: '\$23.00 / hour',
      blurb:
          'Track commodity and consumer indicators; publish weekly signal notes.',
      skills: <String>['Indicators', 'Research', 'Excel', 'Communication'],
      majorTag: 'Economics',
      hourlyWageCents: 2300,
    ),

    // —— Entrepreneurship ——
    BizJobListing(
      id: 'foundry_ops',
      title: 'Startup Operations Associate',
      company: 'Foundry Incubator',
      companyLetter: 'F',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$22.00 / hour',
      blurb:
          'Help portfolio founders with metrics, runway tracking, and pilot ops.',
      skills: <String>['Metrics', 'Scrappiness', 'Customer discovery', 'Sheets'],
      majorTag: 'Entrepreneurship',
      hourlyWageCents: 2200,
    ),
    BizJobListing(
      id: 'sparklane_gm',
      title: 'Junior Generalist',
      company: 'Sparklane Ventures',
      companyLetter: 'S',
      mode: 'Office',
      level: 'Intern',
      payLabel: '\$17.00 / hour',
      blurb:
          'Wear many hats: research competitors, draft decks, and chase early users.',
      skills: <String>['Research', 'Decks', 'Outreach', 'Prioritization'],
      majorTag: 'Entrepreneurship',
      hourlyWageCents: 1700,
    ),
    BizJobListing(
      id: 'bootstrap_growth',
      title: 'Growth Associate',
      company: 'Bootstrap Studio',
      companyLetter: 'B',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$24.00 / hour',
      blurb:
          'Run pricing and channel experiments for early-stage SaaS products.',
      skills: <String>['Experiments', 'Pricing', 'Analytics', 'Copy'],
      majorTag: 'Entrepreneurship',
      hourlyWageCents: 2400,
    ),

    // —— Marketing ——
    BizJobListing(
      id: 'brightpulse_coord',
      title: 'Marketing Coordinator',
      company: 'BrightPulse Agency',
      companyLetter: 'B',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$23.50 / hour',
      blurb:
          'Coordinate campaigns, asset checklists, and performance readouts for DTC brands.',
      skills: <String>['Campaign ops', 'Creative briefs', 'Analytics', 'Deadlines'],
      majorTag: 'Marketing',
      hourlyWageCents: 2350,
    ),
    BizJobListing(
      id: 'neonpath_social',
      title: 'Social Content Intern',
      company: 'NeonPath Media',
      companyLetter: 'N',
      mode: 'Remote',
      level: 'Intern',
      payLabel: '\$16.50 / hour',
      blurb:
          'Draft posts, pull engagement stats, and support creator seeding calendars.',
      skills: <String>['Social', 'Copy', 'Scheduling', 'Basic analytics'],
      majorTag: 'Marketing',
      hourlyWageCents: 1650,
    ),
    BizJobListing(
      id: 'canvas_brand',
      title: 'Brand Analyst',
      company: 'Canvas Collective',
      companyLetter: 'C',
      mode: 'Office',
      level: 'Junior',
      payLabel: '\$25.50 / hour',
      blurb:
          'Turn research into positioning options and measurable creative tests.',
      skills: <String>['Positioning', 'Research', 'A/B tests', 'Storytelling'],
      majorTag: 'Marketing',
      hourlyWageCents: 2550,
    ),

    // —— Human Resource Management ——
    BizJobListing(
      id: 'peoplefirst_coord',
      title: 'People Operations Coordinator',
      company: 'PeopleFirst Co.',
      companyLetter: 'P',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$22.00 / hour',
      blurb:
          'Support onboarding, HRIS hygiene, and manager toolkits for a 200-person org.',
      skills: <String>['HRIS', 'Onboarding', 'Communication', 'Confidentiality'],
      majorTag: 'Human Resource Management',
      hourlyWageCents: 2200,
    ),
    BizJobListing(
      id: 'fairhire_recruiter',
      title: 'Recruiting Intern',
      company: 'FairHire Partners',
      companyLetter: 'F',
      mode: 'Remote',
      level: 'Intern',
      payLabel: '\$18.00 / hour',
      blurb:
          'Source candidates, schedule loops, and keep structured interview kits tidy.',
      skills: <String>['Sourcing', 'Scheduling', 'Writing', 'Organization'],
      majorTag: 'Human Resource Management',
      hourlyWageCents: 1800,
    ),
    BizJobListing(
      id: 'civic_hr_specialist',
      title: 'HR Specialist',
      company: 'Civic Works',
      companyLetter: 'C',
      mode: 'Office',
      level: 'Junior',
      payLabel: '\$24.50 / hour',
      blurb:
          'Partner on employee relations cases, policy FAQs, and retention dashboards.',
      skills: <String>['ER basics', 'Policy', 'Empathy', 'Documentation'],
      majorTag: 'Human Resource Management',
      hourlyWageCents: 2450,
    ),

    // —— International Business ——
    BizJobListing(
      id: 'globalspan_analyst',
      title: 'Global Markets Analyst',
      company: 'GlobalSpan Trade',
      companyLetter: 'G',
      mode: 'Hybrid',
      level: 'Junior',
      payLabel: '\$26.00 / hour',
      blurb:
          'Assess market-entry options, tariff impacts, and partner shortlists.',
      skills: <String>['Market entry', 'Trade basics', 'Research', 'Briefing'],
      majorTag: 'International Business',
      hourlyWageCents: 2600,
    ),
    BizJobListing(
      id: 'pacific_import',
      title: 'Import Operations Intern',
      company: 'Pacific Rim Logistics',
      companyLetter: 'P',
      mode: 'Office',
      level: 'Intern',
      payLabel: '\$17.50 / hour',
      blurb:
          'Track shipments, duties, and docs for cross-border retail freights.',
      skills: <String>['Logistics', 'Documentation', 'Landed cost', 'Follow-through'],
      majorTag: 'International Business',
      hourlyWageCents: 1750,
    ),
    BizJobListing(
      id: 'atlas_fx_coord',
      title: 'Cross-Border Coordinator',
      company: 'Atlas Meridian',
      companyLetter: 'A',
      mode: 'Remote',
      level: 'Junior',
      payLabel: '\$23.00 / hour',
      blurb:
          'Coordinate contracts across time zones and flag FX/compliance risks early.',
      skills: <String>['Coordination', 'FX awareness', 'Negotiation support', 'CRM'],
      majorTag: 'International Business',
      hourlyWageCents: 2300,
    ),
  ];

  static BizJobListing? byId(String id) {
    for (final BizJobListing j in all) {
      if (j.id == id) return j;
    }
    return null;
  }

  static bool isFlagshipJob(String id) =>
      id == flagshipJobId || id == 'apex_commerce_junior';
}
