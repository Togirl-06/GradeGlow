/// Retired old Labs registry. Career Games live in [VuCareerWorlds].
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
  static const List<CareerLabDef> all = <CareerLabDef>[];

  static CareerLabDef? byId(String id) => null;

  static const Set<String> scienceLabIds = <String>{};

  static List<CareerLabDef> get scienceLabs => const <CareerLabDef>[];

  static List<CareerLabDef> get simulations => const <CareerLabDef>[];
}
