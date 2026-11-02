/// Career ranks for professional simulations.
class ProRank {
  const ProRank({
    required this.minXp,
    required this.level,
    required this.title,
  });

  final int minXp;
  final int level;
  final String title;
}

abstract final class ProCareerRanks {
  static const Map<String, List<ProRank>> tracks = <String, List<ProRank>>{
    'business': <ProRank>[
      ProRank(minXp: 0, level: 1, title: 'Business Intern'),
      ProRank(minXp: 200, level: 5, title: 'Junior Business Analyst'),
      ProRank(minXp: 600, level: 10, title: 'Business Strategist'),
      ProRank(minXp: 1400, level: 20, title: 'Acting Manager'),
    ],
    'finance': <ProRank>[
      ProRank(minXp: 0, level: 1, title: 'Finance Intern'),
      ProRank(minXp: 200, level: 5, title: 'Junior Financial Analyst'),
      ProRank(minXp: 600, level: 10, title: 'Portfolio Analyst'),
      ProRank(minXp: 1400, level: 20, title: 'Investment Strategist'),
    ],
    'accounting': <ProRank>[
      ProRank(minXp: 0, level: 1, title: 'Accounting Trainee'),
      ProRank(minXp: 200, level: 5, title: 'Junior Accountant'),
      ProRank(minXp: 600, level: 10, title: 'Accountant'),
      ProRank(minXp: 1400, level: 20, title: 'Audit Associate'),
    ],
    'marketing': <ProRank>[
      ProRank(minXp: 0, level: 1, title: 'Marketing Assistant'),
      ProRank(minXp: 200, level: 5, title: 'Junior Marketing Strategist'),
      ProRank(minXp: 600, level: 10, title: 'Campaign Manager'),
      ProRank(minXp: 1400, level: 20, title: 'Account Lead'),
    ],
    'economics': <ProRank>[
      ProRank(minXp: 0, level: 1, title: 'Research Assistant'),
      ProRank(minXp: 200, level: 5, title: 'Policy Analyst'),
      ProRank(minXp: 600, level: 10, title: 'Senior Analyst'),
      ProRank(minXp: 1400, level: 20, title: 'Economic Advisor'),
    ],
  };

  static const Map<String, List<String>> skills = <String, List<String>>{
    'business': <String>[
      'Problem Solving',
      'Strategy',
      'Data Analysis',
      'Decision Making',
      'Leadership',
    ],
    'finance': <String>[
      'Financial Analysis',
      'Risk Management',
      'Portfolio Strategy',
      'Decision Making',
    ],
    'accounting': <String>[
      'Accuracy',
      'Financial Reasoning',
      'Attention to Detail',
      'Audit Skills',
    ],
    'marketing': <String>[
      'Customer Understanding',
      'Creativity',
      'Strategy',
      'Analytics',
      'Communication',
    ],
    'economics': <String>[
      'Economic Analysis',
      'Policy Reasoning',
      'Data Interpretation',
      'Critical Thinking',
      'Decision Making',
    ],
  };

  static ProRank forXp(String careerId, int xp) {
    final List<ProRank> list = tracks[careerId] ?? tracks['business']!;
    ProRank current = list.first;
    for (final ProRank r in list) {
      if (xp >= r.minXp) current = r;
    }
    return current;
  }
}
