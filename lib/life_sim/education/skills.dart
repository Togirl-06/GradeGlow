/// Skills, knowledge and credentials.
library;

class SkillDef {
  const SkillDef(this.id, this.name, this.emoji);
  final String id;
  final String name;
  final String emoji;
}

class Skills {
  const Skills._();

  static const List<SkillDef> all = <SkillDef>[
    SkillDef('communication', 'Communication', '🗣️'),
    SkillDef('teamwork', 'Teamwork', '🤝'),
    SkillDef('problem_solving', 'Problem solving', '🧩'),
    SkillDef('programming', 'Programming', '💻'),
    SkillDef('clinical', 'Clinical care', '🩺'),
    SkillDef('medicine', 'Medicine', '⚕️'),
    SkillDef('legal', 'Legal reasoning', '⚖️'),
    SkillDef('accounting', 'Accounting', '🧮'),
    SkillDef('management', 'Management', '📊'),
    SkillDef('finance', 'Finance', '💹'),
  ];

  static SkillDef? byId(String id) {
    for (final SkillDef s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static String nameOf(String id) => byId(id)?.name ?? id;
}

/// Skill levels are points 0..100.
class SkillSet {
  SkillSet({Map<String, double>? points, Set<String>? certifications})
      : points = points ?? <String, double>{},
        certifications = certifications ?? <String>{};

  final Map<String, double> points;
  final Set<String> certifications;

  double level(String id) => points[id] ?? 0;

  void gain(String id, double amount) {
    if (amount <= 0) return;
    points[id] = (level(id) + amount).clamp(0, 100).toDouble();
  }

  bool meets(Map<String, int> required) =>
      required.entries.every((MapEntry<String, int> e) => level(e.key) >= e.value);

  /// Missing requirements as readable lines.
  List<String> gaps(Map<String, int> required) {
    final List<String> out = <String>[];
    required.forEach((String id, int need) {
      final double have = level(id);
      if (have < need) {
        out.add('${Skills.nameOf(id)}: ${have.round()}/$need');
      }
    });
    return out;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'points': points,
        'certifications': certifications.toList(),
      };

  factory SkillSet.fromJson(Map<String, Object?> j) {
    final Object? p = j['points'];
    final Object? c = j['certifications'];
    return SkillSet(
      points: p is Map
          ? p.map((Object? k, Object? v) =>
              MapEntry<String, double>(k.toString(), (v as num?)?.toDouble() ?? 0))
          : <String, double>{},
      certifications: c is List ? c.map((Object? e) => e.toString()).toSet() : <String>{},
    );
  }
}

class Certification {
  const Certification({
    required this.id,
    required this.name,
    required this.cost,
    required this.studyHours,
    required this.skill,
    required this.skillGain,
    this.requires = const <String, int>{},
  });

  final String id;
  final String name;
  final double cost;
  final int studyHours;
  final String skill;
  final double skillGain;
  final Map<String, int> requires;
}

class CertificationCatalog {
  const CertificationCatalog._();

  static const List<Certification> all = <Certification>[
    Certification(
      id: 'cert_cloud',
      name: 'Cloud Fundamentals',
      cost: 100,
      studyHours: 10,
      skill: 'programming',
      skillGain: 12,
    ),
    Certification(
      id: 'cert_bls',
      name: 'Basic Life Support (BLS)',
      cost: 80,
      studyHours: 8,
      skill: 'clinical',
      skillGain: 12,
    ),
    Certification(
      id: 'cert_paralegal',
      name: 'Paralegal Certificate',
      cost: 140,
      studyHours: 12,
      skill: 'legal',
      skillGain: 12,
    ),
    Certification(
      id: 'cert_bookkeeping',
      name: 'Bookkeeping Certificate',
      cost: 90,
      studyHours: 8,
      skill: 'accounting',
      skillGain: 12,
    ),
    Certification(
      id: 'cert_pm',
      name: 'Project Management Basics',
      cost: 120,
      studyHours: 10,
      skill: 'management',
      skillGain: 12,
    ),
    Certification(
      id: 'cert_finance',
      name: 'Financial Markets Basics',
      cost: 120,
      studyHours: 10,
      skill: 'finance',
      skillGain: 12,
    ),
  ];

  static Certification? byId(String id) {
    for (final Certification c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
