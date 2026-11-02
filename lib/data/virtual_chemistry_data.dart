import 'package:flutter/material.dart';

/// Virtual chemistry lab reagents and reactions.
class VirtualChemistryData {
  VirtualChemistryData._();

  static const List<ChemReagent> reagents = <ChemReagent>[
    ChemReagent(id: 'water', name: 'Water (H₂O)', ph: 7.0, color: Color(0xFFB3E5FC)),
    ChemReagent(id: 'hcl', name: 'Hydrochloric Acid', ph: 1.5, color: Color(0xFFFFF9C4)),
    ChemReagent(id: 'naoh', name: 'Sodium Hydroxide', ph: 13.0, color: Color(0xFFE1F5FE)),
    ChemReagent(id: 'vinegar', name: 'Vinegar (Acetic Acid)', ph: 3.0, color: Color(0xFFFFF8E1)),
    ChemReagent(id: 'baking_soda', name: 'Baking Soda Solution', ph: 9.0, color: Color(0xFFF3E5F5)),
    ChemReagent(id: 'phenolphthalein', name: 'Phenolphthalein Indicator', ph: 7.0, color: Color(0xFFFCE4EC)),
  ];

  static ChemReaction mix(ChemReagent a, ChemReagent b) {
    final String key = '${a.id}|${b.id}';
    final String keyRev = '${b.id}|${a.id}';
    return _reactions[key] ??
        _reactions[keyRev] ??
        ChemReaction(
          outcome: 'The mixture is observed with no dramatic visible change.',
          ph: ((a.ph + b.ph) / 2).clamp(0, 14),
          color: Color.lerp(a.color, b.color, 0.5) ?? a.color,
          safe: true,
        );
  }

  static const Map<String, ChemReaction> _reactions = <String, ChemReaction>{
    'hcl|naoh': ChemReaction(
      outcome: 'Acid + base neutralization produces salt water. Heat may be released.',
      ph: 7.0,
      color: Color(0xFFE0F7FA),
      safe: true,
    ),
    'hcl|baking_soda': ChemReaction(
      outcome: 'CO₂ gas bubbles form — an acid-base reaction with sodium bicarbonate.',
      ph: 6.5,
      color: Color(0xFFFFFDE7),
      safe: true,
    ),
    'vinegar|baking_soda': ChemReaction(
      outcome: 'Classic fizzing reaction — carbon dioxide gas is released.',
      ph: 7.0,
      color: Color(0xFFE8F5E9),
      safe: true,
    ),
    'naoh|phenolphthalein': ChemReaction(
      outcome: 'Phenolphthalein turns pink in basic solution (pH > 8.2).',
      ph: 12.5,
      color: Color(0xFFF48FB1),
      safe: true,
    ),
    'hcl|phenolphthalein': ChemReaction(
      outcome: 'Phenolphthalein stays colorless in acidic solution.',
      ph: 2.0,
      color: Color(0xFFFFF9C4),
      safe: true,
    ),
    'water|hcl': ChemReaction(
      outcome: 'Diluting acid lowers concentration — always add acid to water, not reverse.',
      ph: 2.5,
      color: Color(0xFFFFF9C4),
      safe: true,
    ),
  };
}

class ChemReagent {
  const ChemReagent({required this.id, required this.name, required this.ph, required this.color});

  final String id;
  final String name;
  final double ph;
  final Color color;
}

class ChemReaction {
  const ChemReaction({required this.outcome, required this.ph, required this.color, required this.safe});

  final String outcome;
  final double ph;
  final Color color;
  final bool safe;
}
