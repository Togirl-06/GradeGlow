const Map<String, List<String>> businessCourseTopics = <String, List<String>>{
  'business|accounting': <String>[
    'Journal Entries', 'Financial Statements', 'Ratio Analysis', 'Budgeting',
    'Cost Behavior', 'Internal Controls', 'Cash Flow', 'Break-Even Analysis',
    'Accrual vs Cash', 'Inventory Valuation', 'Depreciation Methods', 'Audit Trail',
    'Variance Analysis', 'Working Capital', 'Tax Basics for Business', 'Exam Review',
  ],
  'business|finance': <String>[
    'Time Value of Money', 'Capital Budgeting', 'Risk & Return', 'Valuation',
    'Cost of Capital', 'Dividend Policy', 'Working Capital', 'Financial Planning',
    'NPV & IRR', 'Bond Pricing', 'Stock Valuation', 'Portfolio Theory',
    'Leverage', 'Financial Ratios', 'Forecasting', 'Exam Review',
  ],
  'business|marketing': <String>[
    'Campaign Strategy', 'Consumer Research', 'Brand Positioning', 'Go-to-Market Plan',
    'Segmentation', 'Pricing Strategy', 'Digital Ads', 'Customer Journey',
    'SWOT Analysis', 'Product Lifecycle', 'Marketing Mix', 'Competitive Analysis',
    'Retention Strategy', 'Market Research', 'Sales Funnels', 'Exam Review',
  ],
  'business|management': <String>[
    'Leadership Styles', 'Team Building', 'Strategic Planning', 'Change Management',
    'Performance Reviews', 'Conflict Management', 'Organizational Culture', 'Decision Making',
    'Delegation', 'Motivation Theories', 'Operations Management', 'Stakeholder Management',
    'Remote Teams', 'Ethics in Management', 'KPIs & Metrics', 'Exam Review',
  ],
  'business|entrepreneurship': <String>[
    'Business Model Canvas', 'Pitch Decks', 'Market Validation', 'Funding Options',
    'MVP Development', 'Customer Discovery', 'Scaling Operations', 'Exit Strategy',
    'Lean Startup', 'Competitive Moat', 'Unit Economics', 'Partnership Agreements',
    'Bootstrapping', 'Venture Capital', 'Franchising', 'Exam Review',
  ],
  'business|business_law': <String>[
    'Contracts', 'Employment Law', 'Intellectual Property', 'Business Entities',
    'Liability & Risk', 'Regulatory Compliance', 'Negotiation', 'Dispute Resolution',
    'LLC vs Corporation', 'Non-Disclosure Agreements', 'Consumer Protection', 'Antitrust Basics',
    'Bankruptcy Basics', 'International Trade Law', 'Ethics & Compliance', 'Exam Review',
  ],
};

const Map<String, List<String>> economicsCourseTopics = <String, List<String>>{
  'economics|microeconomics': <String>[
    'Supply & Demand', 'Elasticity', 'Market Structures', 'Consumer Choice',
    'Production Costs', 'Game Theory', 'Externalities', 'Labor Markets',
    'Marginal Analysis', 'Price Ceilings & Floors', 'Monopoly & Oligopoly', 'Utility Theory',
    'Public Goods', 'Tax Incidence', 'Welfare Economics', 'Exam Review',
  ],
  'economics|macroeconomics': <String>[
    'GDP & Growth', 'Inflation', 'Unemployment', 'Fiscal Policy',
    'Monetary Policy', 'International Trade', 'Business Cycles', 'Exchange Rates',
    'Aggregate Demand', 'Phillips Curve', 'Central Banking', 'Balance of Payments',
    'Government Debt', 'Stagflation', 'Development Economics', 'Exam Review',
  ],
  'economics|econometrics': <String>[
    'Regression Analysis', 'Hypothesis Testing', 'Time Series', 'Panel Data',
    'Instrumental Variables', 'Model Specification', 'Forecasting', 'Causal Inference',
    'Heteroskedasticity', 'Multicollinearity', 'ARIMA Models', 'Logit & Probit',
    'Endogeneity', 'Difference-in-Differences', 'R-squared Interpretation', 'Exam Review',
  ],
};

const Map<String, List<String>> financeCourseTopics = <String, List<String>>{
  'finance|investments': <String>[
    'Portfolio Theory', 'Bond Valuation', 'Stock Valuation', 'Asset Allocation',
    'Derivatives', 'Risk Management', 'Market Efficiency', 'Behavioral Finance',
    'CAPM', 'Options Basics', 'Futures', 'Hedge Funds',
    'Mutual Funds & ETFs', 'Technical Analysis', 'Fixed Income Strategies', 'Exam Review',
  ],
  'finance|corporate_finance': <String>[
    'Capital Structure', 'Mergers & Acquisitions', 'Dividend Policy', 'NPV Analysis',
    'Leveraged Buyouts', 'IPO Process', 'Corporate Governance', 'Financial Distress',
    'WACC', 'Free Cash Flow', 'Synergy Valuation', 'Restructuring',
    'Agency Problems', 'Payout Policy', 'Project Finance', 'Exam Review',
  ],
  'finance|financial_analysis': <String>[
    'Ratio Analysis', 'Cash Flow Analysis', 'Credit Analysis', 'Forecasting Models',
    'Valuation Multiples', 'Sensitivity Analysis', 'Industry Benchmarking', 'Investment Memos',
    'DuPont Analysis', 'Working Capital Analysis', 'Pro Forma Statements', 'Scenario Analysis',
    'Equity Research', 'LBO Models', 'DCF Valuation', 'Exam Review',
  ],
};

const Map<String, List<String>> marketingCourseTopics = <String, List<String>>{
  'marketing|digital_marketing': <String>[
    'SEO Strategy', 'Social Media Campaigns', 'Email Marketing', 'PPC Advertising',
    'Content Marketing', 'Analytics & KPIs', 'Conversion Optimization', 'Influencer Marketing',
    'Google Ads', 'Landing Pages', 'A/B Testing', 'Marketing Automation',
    'Retargeting', 'Video Marketing', 'Mobile Marketing', 'Exam Review',
  ],
  'marketing|consumer_behavior': <String>[
    'Buyer Decision Process', 'Brand Loyalty', 'Market Segmentation', 'Psychographics',
    'Attitude Change', 'Packaging & Perception', 'Word of Mouth', 'Customer Retention',
    'Reference Groups', 'Culture & Consumption', 'Perceived Risk', 'Post-Purchase Behavior',
    'Neuromarketing', 'Customer Lifetime Value', 'Brand Communities', 'Exam Review',
  ],
  'marketing|branding': <String>[
    'Brand Identity', 'Positioning Statements', 'Brand Architecture', 'Rebranding',
    'Brand Equity', 'Visual Identity', 'Brand Voice', 'Competitive Differentiation',
    'Brand Storytelling', 'Naming Strategy', 'Brand Extensions', 'Employer Branding',
    'Brand Audits', 'Co-Branding', 'Trademark Basics', 'Exam Review',
  ],
};

const Map<String, List<String>> accountingCourseTopics = <String, List<String>>{
  'accounting|financial_accounting': <String>[
    'Balance Sheet', 'Income Statement', 'Cash Flow Statement', 'Revenue Recognition',
    'Inventory Methods', 'Depreciation', 'Equity Transactions', 'Financial Ratios',
    'GAAP Principles', 'Adjusting Entries', 'Closing Entries', 'Bad Debt',
    'Intangible Assets', 'Contingent Liabilities', 'Earnings Per Share', 'Exam Review',
  ],
  'accounting|managerial_accounting': <String>[
    'Cost-Volume-Profit', 'Activity-Based Costing', 'Budgeting', 'Variance Analysis',
    'Decision Analysis', 'Transfer Pricing', 'Performance Measurement', 'Capital Budgeting',
    'Job Order Costing', 'Process Costing', 'Standard Costs', 'Relevant Costs',
    'Segment Reporting', 'Balanced Scorecard', 'Overhead Allocation', 'Exam Review',
  ],
  'accounting|auditing': <String>[
    'Audit Planning', 'Internal Controls', 'Sampling', 'Audit Evidence',
    'Fraud Detection', 'Audit Reports', 'Ethics in Auditing', 'IT Auditing',
    'Materiality', 'Substantive Testing', 'Analytical Procedures', 'Going Concern',
    'Audit Risk Model', 'SOX Compliance', 'Forensic Accounting', 'Exam Review',
  ],
  'accounting|taxation': <String>[
    'Individual Income Tax', 'Corporate Tax', 'Deductions & Credits', 'Tax Compliance',
    'Capital Gains', 'Estate Tax', 'Tax Planning', 'International Tax',
    'Depreciation for Tax', 'Pass-Through Entities', 'Tax Loss Carryforward', 'AMT',
    'Payroll Taxes', 'Sales & Use Tax', 'Tax Ethics', 'Exam Review',
  ],
};
