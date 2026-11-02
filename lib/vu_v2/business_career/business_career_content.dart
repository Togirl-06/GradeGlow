import 'package:flutter/material.dart';

import 'business_career_theme.dart';

class BusinessMajor {
  const BusinessMajor({
    required this.id,
    required this.title,
    required this.facility,
    required this.blurb,
    required this.careerPath,
    required this.exampleMission,
    required this.skills,
    required this.icon,
    required this.accent,
    this.playable = true,
  });

  final String id;
  final String title;
  final String facility;
  final String blurb;
  final String careerPath;
  final String exampleMission;
  final List<String> skills;
  final IconData icon;
  final Color accent;
  final bool playable;
}

abstract final class BusinessMajors {
  static const List<BusinessMajor> all = <BusinessMajor>[
    BusinessMajor(
      id: 'business_administration',
      title: 'Business Administration',
      facility: 'Corporate Headquarters',
      blurb: 'Strategy, operations, budgeting, and leadership decisions.',
      careerPath: 'Intern → Team Leader → Operations Manager → Executive → CEO',
      exampleMission: 'The Declining Company',
      skills: <String>['Strategy', 'Operations', 'Leadership'],
      icon: Icons.apartment_rounded,
      accent: BizCosmic.royal,
      playable: true,
    ),
    BusinessMajor(
      id: 'accounting',
      title: 'Accounting',
      facility: 'Accounting and Audit Firm',
      blurb: 'Ledgers, reconciliation, audits, and financial reporting.',
      careerPath: 'Intern → Staff Accountant → Senior / Auditor → Controller',
      exampleMission: 'The Missing \$12,000',
      skills: <String>['Reporting', 'Audit', 'Reconciliation'],
      icon: Icons.calculate_rounded,
      accent: BizCosmic.emerald,
    ),
    BusinessMajor(
      id: 'finance',
      title: 'Finance',
      facility: 'Investment and Markets Center',
      blurb: 'Markets, valuation, risk, and portfolio construction.',
      careerPath: 'Intern → Analyst → Senior / PM → Investment Director',
      exampleMission: 'The \$50,000 Portfolio',
      skills: <String>['Valuation', 'Risk', 'Portfolio'],
      icon: Icons.show_chart_rounded,
      accent: BizCosmic.gold,
    ),
    BusinessMajor(
      id: 'economics',
      title: 'Economics',
      facility: 'Economic Policy and Research Center',
      blurb: 'Supply, demand, inflation, and policy trade-offs.',
      careerPath: 'Research Assistant → Analyst → Advisor → Senior Economist',
      exampleMission: 'The Inflation Challenge',
      skills: <String>['Analysis', 'Policy', 'Data'],
      icon: Icons.insights_rounded,
      accent: BizCosmic.purple,
    ),
    BusinessMajor(
      id: 'entrepreneurship',
      title: 'Entrepreneurship',
      facility: 'Startup Incubator',
      blurb: 'Customer discovery, MVPs, cash flow, and investor pitches.',
      careerPath: 'Founder → Operator → Growing Owner → Established',
      exampleMission: 'Launch a Startup',
      skills: <String>['Validation', 'Modeling', 'Finance'],
      icon: Icons.rocket_launch_rounded,
      accent: BizCosmic.warning,
    ),
    BusinessMajor(
      id: 'marketing',
      title: 'Marketing',
      facility: 'Creative and Digital Marketing Agency',
      blurb: 'Brand, channels, creative, and campaign analytics.',
      careerPath: 'Intern → Specialist → Brand Manager → Director',
      exampleMission: 'Launch a Sneaker Brand',
      skills: <String>['Research', 'Brand', 'Analytics'],
      icon: Icons.campaign_rounded,
      accent: Color(0xFFEC4899),
    ),
    BusinessMajor(
      id: 'human_resource_management',
      title: 'Human Resource Management',
      facility: 'People and Culture Office',
      blurb: 'Hiring, retention, culture, and fair people decisions.',
      careerPath: 'Assistant → Specialist → Manager → Chief People Officer',
      exampleMission: 'The Employee Retention Crisis',
      skills: <String>['Recruitment', 'Relations', 'Performance'],
      icon: Icons.groups_rounded,
      accent: Color(0xFF14B8A6),
    ),
    BusinessMajor(
      id: 'international_business',
      title: 'International Business',
      facility: 'Global Trade Center',
      blurb: 'Market entry, tariffs, currency, and cross-border deals.',
      careerPath: 'Intern → Global Analyst → Regional Manager → Director',
      exampleMission: 'Expand Into a New Country',
      skills: <String>['Market entry', 'Trade', 'Negotiation'],
      icon: Icons.public_rounded,
      accent: Color(0xFF6366F1),
    ),
  ];

  static BusinessMajor byId(String id) => all.firstWhere(
        (BusinessMajor m) => m.id == id,
        orElse: () => all.first,
      );

  /// Display tag used by job / case filters (matches BizCareerJobs.majorTag).
  static String majorTagFor(String id) => byId(id).title;
}

class BizNpc {
  const BizNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.personality,
    required this.accent,
  });

  final String id;
  final String name;
  final String role;
  final String personality;
  final Color accent;
}

abstract final class BizHqNpcs {
  static const BizNpc manager = BizNpc(
    id: 'mgr_chen',
    name: 'Morgan Chen',
    role: 'Operations Manager',
    personality: 'Direct, data-driven, expects clear recommendations.',
    accent: BizCosmic.royal,
  );
  static const BizNpc coworker = BizNpc(
    id: 'alex_rivera',
    name: 'Alex Rivera',
    role: 'Customer Success Lead',
    personality: 'Empathetic; knows why clients are leaving.',
    accent: BizCosmic.emerald,
  );
  static const BizNpc finance = BizNpc(
    id: 'priya_nair',
    name: 'Priya Nair',
    role: 'Finance Partner',
    personality: 'Cautious with spend; pushes for ROI clarity.',
    accent: BizCosmic.gold,
  );

  static const List<BizNpc> all = <BizNpc>[manager, coworker, finance];
}

class BizMissionDef {
  const BizMissionDef({
    required this.id,
    required this.majorId,
    required this.title,
    required this.blurb,
    required this.objectives,
    required this.xpReward,
    required this.learningGoals,
  });

  final String id;
  final String majorId;
  final String title;
  final String blurb;
  final List<String> objectives;
  final int xpReward;
  final List<String> learningGoals;
}

abstract final class BizMissionCatalog {
  static const BizMissionDef decliningCompany = BizMissionDef(
    id: 'ba_declining_company_v1',
    majorId: 'business_administration',
    title: 'The Declining Company',
    blurb:
        'Northwind Retail is losing customers while costs climb. Diagnose the '
        'problems, allocate a recovery budget, and present your plan.',
    objectives: <String>[
      'Meet the manager',
      'Review performance data',
      'Gather employee & customer signals',
      'Choose a recovery strategy',
      'Allocate the \$80,000 budget',
      'Present to the manager',
      'Review outcomes & feedback',
    ],
    xpReward: 180,
    learningGoals: <String>[
      'Strategy',
      'Operations',
      'Budgeting',
      'Decision-making',
    ],
  );

  static BizMissionDef? byId(String id) {
    if (id == decliningCompany.id) return decliningCompany;
    return null;
  }

  static List<BizMissionDef> forMajor(String majorId) {
    if (majorId == 'business_administration') {
      return <BizMissionDef>[decliningCompany];
    }
    return const <BizMissionDef>[];
  }
}

/// Starting company KPIs for Declining Company (deterministic).
class CompanyKpis {
  const CompanyKpis({
    required this.customers,
    required this.monthlyRevenue,
    required this.monthlyCost,
    required this.satisfaction,
    required this.productivity,
    required this.cash,
  });

  final int customers;
  final double monthlyRevenue;
  final double monthlyCost;
  final double satisfaction; // 0–1
  final double productivity; // 0–1
  final double cash;

  double get profit => monthlyRevenue - monthlyCost;

  CompanyKpis copyWith({
    int? customers,
    double? monthlyRevenue,
    double? monthlyCost,
    double? satisfaction,
    double? productivity,
    double? cash,
  }) {
    return CompanyKpis(
      customers: customers ?? this.customers,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      satisfaction: satisfaction ?? this.satisfaction,
      productivity: productivity ?? this.productivity,
      cash: cash ?? this.cash,
    );
  }

  static const CompanyKpis decliningBaseline = CompanyKpis(
    customers: 4200,
    monthlyRevenue: 310000,
    monthlyCost: 295000,
    satisfaction: 0.58,
    productivity: 0.62,
    cash: 180000,
  );
}

enum RecoveryStrategy {
  customerRetention,
  costCutting,
  productRefresh,
  balancedTurnaround,
}

extension RecoveryStrategyX on RecoveryStrategy {
  String get label => switch (this) {
        RecoveryStrategy.customerRetention => 'Customer retention push',
        RecoveryStrategy.costCutting => 'Aggressive cost cutting',
        RecoveryStrategy.productRefresh => 'Product & experience refresh',
        RecoveryStrategy.balancedTurnaround => 'Balanced turnaround',
      };

  String get detail => switch (this) {
        RecoveryStrategy.customerRetention =>
          'Invest in support, loyalty offers, and win-back campaigns.',
        RecoveryStrategy.costCutting =>
          'Slash discretionary spend and freeze hiring to protect cash.',
        RecoveryStrategy.productRefresh =>
          'Fix quality issues and relaunch a clearer value proposition.',
        RecoveryStrategy.balancedTurnaround =>
          'Split spend across retention, ops efficiency, and product fixes.',
      };
}

/// Deterministic outcome model for Declining Company.
abstract final class DecliningCompanyEngine {
  static CompanyKpis simulate({
    required RecoveryStrategy strategy,
    required int retentionSpend,
    required int opsSpend,
    required int productSpend,
  }) {
    CompanyKpis k = CompanyKpis.decliningBaseline;
    final int spent =
        (retentionSpend + opsSpend + productSpend).clamp(0, 80000);
    double sat = k.satisfaction;
    double prod = k.productivity;
    double rev = k.monthlyRevenue;
    double cost = k.monthlyCost;
    int customers = k.customers;
    double cash = k.cash - spent;

    switch (strategy) {
      case RecoveryStrategy.customerRetention:
        sat += 0.08 + retentionSpend / 800000;
        customers += (120 + retentionSpend / 400).round();
        rev += retentionSpend * 0.55;
        cost += retentionSpend * 0.12;
        if (opsSpend < 10000) prod -= 0.03;
      case RecoveryStrategy.costCutting:
        cost -= 18000 + opsSpend * 0.35;
        sat -= 0.06;
        prod += 0.02;
        customers -= 180;
        rev -= 22000;
        if (productSpend < 8000) sat -= 0.03;
      case RecoveryStrategy.productRefresh:
        sat += 0.05 + productSpend / 900000;
        prod += 0.04;
        customers += (80 + productSpend / 500).round();
        rev += productSpend * 0.48;
        cost += productSpend * 0.18 + 6000;
      case RecoveryStrategy.balancedTurnaround:
        sat += 0.05 + retentionSpend / 1000000;
        prod += 0.05 + opsSpend / 1000000;
        customers += (90 + (retentionSpend + productSpend) / 700).round();
        rev += (retentionSpend + productSpend) * 0.42 + opsSpend * 0.15;
        cost += retentionSpend * 0.1 + productSpend * 0.12 - opsSpend * 0.2;
    }

    sat = sat.clamp(0.2, 0.98);
    prod = prod.clamp(0.2, 0.98);
    return CompanyKpis(
      customers: customers.clamp(2000, 9000),
      monthlyRevenue: rev.clamp(150000, 600000),
      monthlyCost: cost.clamp(120000, 550000),
      satisfaction: sat,
      productivity: prod,
      cash: cash,
    );
  }

  static String feedback({
    required RecoveryStrategy strategy,
    required CompanyKpis before,
    required CompanyKpis after,
  }) {
    final double profitDelta = after.profit - before.profit;
    final int custDelta = after.customers - before.customers;
    final String profitLine = profitDelta >= 0
        ? 'Monthly profit improved by \$${profitDelta.round()}.'
        : 'Monthly profit fell by \$${(-profitDelta).round()}.';
    final String custLine = custDelta >= 0
        ? 'Customer base grew by $custDelta.'
        : 'Customer base shrank by ${-custDelta}.';

    final String strategyNote = switch (strategy) {
      RecoveryStrategy.customerRetention =>
        'Retention spend lifted satisfaction, but ops neglect can still hurt delivery.',
      RecoveryStrategy.costCutting =>
        'Cash protected in the short run, but satisfaction and revenue often take a hit.',
      RecoveryStrategy.productRefresh =>
        'Fixing the offer helps long-term loyalty if you fund support alongside it.',
      RecoveryStrategy.balancedTurnaround =>
        'Spreading budget across retention, ops, and product usually stabilizes KPIs fastest.',
    };

    return '$profitLine $custLine $strategyNote '
        'Satisfaction ${(before.satisfaction * 100).round()}% → '
        '${(after.satisfaction * 100).round()}%. '
        'Productivity ${(before.productivity * 100).round()}% → '
        '${(after.productivity * 100).round()}%.';
  }

  static int score({
    required CompanyKpis before,
    required CompanyKpis after,
  }) {
    int s = 40;
    if (after.profit > before.profit) s += 20;
    if (after.customers >= before.customers) s += 15;
    if (after.satisfaction >= before.satisfaction + 0.04) s += 15;
    if (after.productivity >= before.productivity) s += 10;
    return s.clamp(0, 100);
  }
}
