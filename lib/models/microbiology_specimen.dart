
enum MicrobiologyCategory { bacteria, virus, fungi }

enum MicrobeShape { cocci, bacilli, spirilla, icosahedral, helical, bacteriophage, hyphae, yeast, spore }

class MicrobiologySpecimen {
  const MicrobiologySpecimen({
    required this.id,
    required this.category,
    required this.name,
    required this.shape,
    required this.hint,
  });

  final String id;
  final MicrobiologyCategory category;
  final String name;
  final MicrobeShape shape;
  final String hint;
}
