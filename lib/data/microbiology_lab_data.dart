import 'dart:math';

import '../models/microbiology_specimen.dart';

/// Illustrated microbiology specimens for image identification labs.
class MicrobiologyLabData {
  MicrobiologyLabData._();

  static List<MicrobiologySpecimen> deckFor(MicrobiologyCategory category, String seed, {int count = 6}) {
    final List<MicrobiologySpecimen> pool = allForCategory(category);
    pool.shuffle(Random(seed.hashCode));
    return pool.take(min(count, pool.length)).toList();
  }

  static List<MicrobiologySpecimen> allForCategory(MicrobiologyCategory category) =>
      _all.where((MicrobiologySpecimen s) => s.category == category).toList();

  static const List<MicrobiologySpecimen> _all = <MicrobiologySpecimen>[
    MicrobiologySpecimen(id: 'cocci', category: MicrobiologyCategory.bacteria, name: 'Cocci (spherical)', shape: MicrobeShape.cocci, hint: 'Round bacteria that cluster or chain — e.g. Staphylococcus.'),
    MicrobiologySpecimen(id: 'bacilli', category: MicrobiologyCategory.bacteria, name: 'Bacilli (rod-shaped)', shape: MicrobeShape.bacilli, hint: 'Rod-shaped bacteria like E. coli.'),
    MicrobiologySpecimen(id: 'spirilla', category: MicrobiologyCategory.bacteria, name: 'Spirilla (spiral)', shape: MicrobeShape.spirilla, hint: 'Spiral-shaped bacteria with flagella at ends.'),
    MicrobiologySpecimen(id: 'icosahedral', category: MicrobiologyCategory.virus, name: 'Icosahedral virus', shape: MicrobeShape.icosahedral, hint: 'Many viruses like poliovirus have icosahedral capsids.'),
    MicrobiologySpecimen(id: 'helical_virus', category: MicrobiologyCategory.virus, name: 'Helical virus', shape: MicrobeShape.helical, hint: 'Tobacco mosaic virus has a helical capsid around RNA.'),
    MicrobiologySpecimen(id: 'bacteriophage', category: MicrobiologyCategory.virus, name: 'Bacteriophage', shape: MicrobeShape.bacteriophage, hint: 'Viruses that infect bacteria — iconic head-and-tail structure.'),
    MicrobiologySpecimen(id: 'hyphae', category: MicrobiologyCategory.fungi, name: 'Hyphae', shape: MicrobeShape.hyphae, hint: 'Thread-like filaments that make up fungal mycelium.'),
    MicrobiologySpecimen(id: 'yeast', category: MicrobiologyCategory.fungi, name: 'Yeast (budding)', shape: MicrobeShape.yeast, hint: 'Unicellular fungi that reproduce by budding.'),
    MicrobiologySpecimen(id: 'mushroom_spore', category: MicrobiologyCategory.fungi, name: 'Spore-producing fungus', shape: MicrobeShape.spore, hint: 'Fungi release spores from fruiting structures.'),
  ];
}
