/// Career ranks unlocked by lab XP — student feels like a scientist.
class ScienceCareerRank {
  const ScienceCareerRank({
    required this.minXp,
    required this.title,
    required this.level,
  });

  final int minXp;
  final String title;
  final int level;
}

abstract final class ScienceCareerRanks {
  static const List<ScienceCareerRank> biology = <ScienceCareerRank>[
    ScienceCareerRank(minXp: 0, title: 'Biology Student', level: 1),
    ScienceCareerRank(minXp: 200, title: 'Junior Researcher', level: 5),
    ScienceCareerRank(minXp: 500, title: 'Laboratory Assistant', level: 10),
    ScienceCareerRank(minXp: 1200, title: 'Research Specialist', level: 20),
    ScienceCareerRank(minXp: 2500, title: 'Advanced Researcher', level: 30),
  ];

  static const List<ScienceCareerRank> chemistry = <ScienceCareerRank>[
    ScienceCareerRank(minXp: 0, title: 'Chemistry Student', level: 1),
    ScienceCareerRank(minXp: 200, title: 'Laboratory Assistant', level: 5),
    ScienceCareerRank(minXp: 500, title: 'Junior Chemist', level: 10),
    ScienceCareerRank(minXp: 1200, title: 'Laboratory Specialist', level: 20),
    ScienceCareerRank(minXp: 2500, title: 'Senior Chemist', level: 30),
  ];

  static const List<ScienceCareerRank> physics = <ScienceCareerRank>[
    ScienceCareerRank(minXp: 0, title: 'Physics Student', level: 1),
    ScienceCareerRank(minXp: 200, title: 'Physics Laboratory Assistant', level: 5),
    ScienceCareerRank(minXp: 500, title: 'Junior Physicist', level: 10),
    ScienceCareerRank(minXp: 1200, title: 'Research Physicist', level: 20),
    ScienceCareerRank(minXp: 2500, title: 'Senior Physicist', level: 30),
  ];

  static List<ScienceCareerRank> track(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'chemistry':
        return chemistry;
      case 'physics':
        return physics;
      default:
        return biology;
    }
  }

  static ScienceCareerRank forXp(String subjectId, int xp) {
    final List<ScienceCareerRank> ranks = track(subjectId);
    ScienceCareerRank current = ranks.first;
    for (final ScienceCareerRank r in ranks) {
      if (xp >= r.minXp) current = r;
    }
    return current;
  }

  static const Map<String, List<String>> skillTrees = <String, List<String>>{
    'biology': <String>[
      'Microscopy',
      'Genetics',
      'Anatomy',
      'Ecology',
      'Cell Biology',
      'Experimental Design',
      'Data Analysis',
    ],
    'chemistry': <String>[
      'Measurement',
      'Reactions',
      'Molecular Structure',
      'Thermochemistry',
      'Titration',
      'Data Analysis',
      'Laboratory Safety',
    ],
    'physics': <String>[
      'Motion',
      'Forces',
      'Electricity',
      'Waves',
      'Optics',
      'Energy',
      'Mathematical Modeling',
    ],
  };
}
