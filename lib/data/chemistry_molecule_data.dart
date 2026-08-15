import 'dart:math' as math;

import 'package:flutter/material.dart';

enum MoleculeViewMode {
  ballAndStick('Ball & Stick'),
  spaceFilling('Space Filling'),
  wireframe('Wireframe'),
  lewis('Lewis Structure');

  const MoleculeViewMode(this.label);

  final String label;
}

class MoleculeAtom {
  const MoleculeAtom({
    required this.element,
    required this.x,
    required this.y,
    required this.z,
    this.lonePairs = 0,
    this.charge = 0,
  });

  final String element;
  final double x;
  final double y;
  final double z;
  final int lonePairs;
  final int charge;
}

class MoleculeBond {
  const MoleculeBond({required this.a, required this.b, this.order = 1});

  final int a;
  final int b;
  final int order;
}

class ChemMolecule {
  const ChemMolecule({
    required this.id,
    required this.name,
    required this.formula,
    required this.atoms,
    required this.bonds,
    this.bondAngleDeg,
    this.polarity,
    this.hybridization,
  });

  final String id;
  final String name;
  final String formula;
  final List<MoleculeAtom> atoms;
  final List<MoleculeBond> bonds;
  final String? bondAngleDeg;
  final String? polarity;
  final String? hybridization;
}

class ChemistryMoleculeData {
  ChemistryMoleculeData._();

  static const Map<String, Color> elementColors = <String, Color>{
    'H': Color(0xFFFFFFFF),
    'C': Color(0xFF909090),
    'N': Color(0xFF3050F8),
    'O': Color(0xFFFF0D0D),
    'Cl': Color(0xFF1FF01F),
    'S': Color(0xFFFFFF30),
    'Na': Color(0xFFAB5CF2),
  };

  static const List<ChemMolecule> catalog = <ChemMolecule>[
    ChemMolecule(
      id: 'water',
      name: 'Water',
      formula: 'H₂O',
      bondAngleDeg: '104.5°',
      polarity: 'Polar — bent geometry',
      hybridization: 'sp³ on oxygen',
      atoms: <MoleculeAtom>[
        MoleculeAtom(element: 'O', x: 0, y: 0, z: 0, lonePairs: 2),
        MoleculeAtom(element: 'H', x: -0.76, y: 0.59, z: 0),
        MoleculeAtom(element: 'H', x: 0.76, y: 0.59, z: 0),
      ],
      bonds: <MoleculeBond>[MoleculeBond(a: 0, b: 1), MoleculeBond(a: 0, b: 2)],
    ),
    ChemMolecule(
      id: 'methane',
      name: 'Methane',
      formula: 'CH₄',
      bondAngleDeg: '109.5°',
      polarity: 'Nonpolar — tetrahedral',
      hybridization: 'sp³ on carbon',
      atoms: <MoleculeAtom>[
        MoleculeAtom(element: 'C', x: 0, y: 0, z: 0),
        MoleculeAtom(element: 'H', x: 0.63, y: 0.63, z: 0.63),
        MoleculeAtom(element: 'H', x: -0.63, y: -0.63, z: 0.63),
        MoleculeAtom(element: 'H', x: -0.63, y: 0.63, z: -0.63),
        MoleculeAtom(element: 'H', x: 0.63, y: -0.63, z: -0.63),
      ],
      bonds: <MoleculeBond>[
        MoleculeBond(a: 0, b: 1),
        MoleculeBond(a: 0, b: 2),
        MoleculeBond(a: 0, b: 3),
        MoleculeBond(a: 0, b: 4),
      ],
    ),
    ChemMolecule(
      id: 'co2',
      name: 'Carbon Dioxide',
      formula: 'CO₂',
      bondAngleDeg: '180°',
      polarity: 'Nonpolar — linear (dipoles cancel)',
      hybridization: 'sp on carbon',
      atoms: <MoleculeAtom>[
        MoleculeAtom(element: 'C', x: 0, y: 0, z: 0),
        MoleculeAtom(element: 'O', x: -1.16, y: 0, z: 0),
        MoleculeAtom(element: 'O', x: 1.16, y: 0, z: 0),
      ],
      bonds: <MoleculeBond>[
        MoleculeBond(a: 0, b: 1, order: 2),
        MoleculeBond(a: 0, b: 2, order: 2),
      ],
    ),
    ChemMolecule(
      id: 'ammonia',
      name: 'Ammonia',
      formula: 'NH₃',
      bondAngleDeg: '107°',
      polarity: 'Polar — trigonal pyramidal',
      hybridization: 'sp³ on nitrogen',
      atoms: <MoleculeAtom>[
        MoleculeAtom(element: 'N', x: 0, y: 0, z: 0, lonePairs: 1),
        MoleculeAtom(element: 'H', x: 0, y: 0.94, z: 0.27),
        MoleculeAtom(element: 'H', x: -0.81, y: -0.47, z: 0.27),
        MoleculeAtom(element: 'H', x: 0.81, y: -0.47, z: 0.27),
      ],
      bonds: <MoleculeBond>[
        MoleculeBond(a: 0, b: 1),
        MoleculeBond(a: 0, b: 2),
        MoleculeBond(a: 0, b: 3),
      ],
    ),
    ChemMolecule(
      id: 'ethanol',
      name: 'Ethanol',
      formula: 'C₂H₅OH',
      bondAngleDeg: '109.5° (C), 104.5° (O)',
      polarity: 'Polar — hydrogen bonding',
      hybridization: 'sp³',
      atoms: <MoleculeAtom>[
        MoleculeAtom(element: 'C', x: -0.8, y: 0, z: 0),
        MoleculeAtom(element: 'C', x: 0.4, y: 0, z: 0),
        MoleculeAtom(element: 'O', x: 1.0, y: 1.0, z: 0, lonePairs: 2),
        MoleculeAtom(element: 'H', x: 1.8, y: 0.8, z: 0),
        MoleculeAtom(element: 'H', x: -1.2, y: 1.0, z: 0),
        MoleculeAtom(element: 'H', x: -1.2, y: -0.5, z: 0.9),
        MoleculeAtom(element: 'H', x: -1.2, y: -0.5, z: -0.9),
        MoleculeAtom(element: 'H', x: 0.8, y: -0.5, z: 0.9),
        MoleculeAtom(element: 'H', x: 0.8, y: -0.5, z: -0.9),
      ],
      bonds: <MoleculeBond>[
        MoleculeBond(a: 0, b: 1),
        MoleculeBond(a: 1, b: 2),
        MoleculeBond(a: 2, b: 3),
        MoleculeBond(a: 0, b: 4),
        MoleculeBond(a: 0, b: 5),
        MoleculeBond(a: 0, b: 6),
        MoleculeBond(a: 1, b: 7),
        MoleculeBond(a: 1, b: 8),
      ],
    ),
  ];

  static ChemMolecule moleculeForTopic(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('water') || t.contains('acid') || t.contains('base')) {
      return catalog.firstWhere((ChemMolecule m) => m.id == 'water');
    }
    if (t.contains('organic') || t.contains('alcohol') || t.contains('ethanol')) {
      return catalog.firstWhere((ChemMolecule m) => m.id == 'ethanol');
    }
    if (t.contains('ammonia') || t.contains('nitrogen')) {
      return catalog.firstWhere((ChemMolecule m) => m.id == 'ammonia');
    }
    if (t.contains('carbon') || t.contains('gas law') || t.contains('greenhouse')) {
      return catalog.firstWhere((ChemMolecule m) => m.id == 'co2');
    }
    if (t.contains('hydrocarbon') || t.contains('alkane')) {
      return catalog.firstWhere((ChemMolecule m) => m.id == 'methane');
    }
    return catalog.first;
  }

  static Offset project(MoleculeAtom atom, double rotY, double rotX, double scale) {
    final double cosY = math.cos(rotY);
    final double sinY = math.sin(rotY);
    final double x1 = atom.x * cosY + atom.z * sinY;
    final double z1 = -atom.x * sinY + atom.z * cosY;

    final double cosX = math.cos(rotX);
    final double sinX = math.sin(rotX);
    final double y2 = atom.y * cosX - z1 * sinX;
    final double z2 = atom.y * sinX + z1 * cosX;

    final double perspective = 1 / (2.5 + z2);
    return Offset(x1 * scale * perspective, -y2 * scale * perspective);
  }
}
