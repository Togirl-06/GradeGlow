/// Retired old Labs registry. Career Games live in [VuCareerWorlds].
/// Glow labs (e.g. Budget Boss) are opened via [playableScreens].
library;

class CareerLabDef {
  const CareerLabDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.role,
    required this.available,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String role;
  final bool available;
}

abstract final class CareerLabRegistry {
  static const List<CareerLabDef> all = <CareerLabDef>[
    CareerLabDef(
      id: 'personal_finance',
      title: 'Personal Finance — Budget Boss',
      subtitle: 'Sort needs · spot fees · survive paychecks, cards & a crisis',
      emoji: '💸',
      role: 'Money Rookie',
      available: true,
    ),
  ];

  static CareerLabDef? byId(String id) {
    for (final CareerLabDef d in all) {
      if (d.id == id) return d;
    }
    return null;
  }

  static const Set<String> scienceLabIds = <String>{};

  static List<CareerLabDef> get scienceLabs => const <CareerLabDef>[];

  static List<CareerLabDef> get simulations =>
      all.where((CareerLabDef d) => d.available).toList(growable: false);
}
