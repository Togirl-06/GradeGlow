import 'package:flutter/material.dart';

/// Canonical science lab badge ids + display metadata.
class ScienceBadges {
  ScienceBadges._();

  static const String masterMicroscopist = 'master_microscopist';
  static const String molecularDetective = 'molecular_detective';
  static const String physicsEngineer = 'physics_engineer';
  static const String cellCartographer = 'cell_cartographer';
  static const String titrationAce = 'titration_ace';
  static const String trajectoryAce = 'trajectory_ace';
  static const String ecosystemWatcher = 'ecosystem_watcher';
  static const String bondBuilder = 'bond_builder';
  static const String forceMapper = 'force_mapper';
  static const String labNotebookPro = 'lab_notebook_pro';
  static const String diagramAnnotator = 'diagram_annotator';
  static const String hypothesisHero = 'hypothesis_hero';

  static const Map<String, String> labels = <String, String>{
    masterMicroscopist: 'Master Microscopist',
    molecularDetective: 'Molecular Detective',
    physicsEngineer: 'Physics Engineer',
    cellCartographer: 'Cell Cartographer',
    titrationAce: 'Titration Ace',
    trajectoryAce: 'Trajectory Ace',
    ecosystemWatcher: 'Ecosystem Watcher',
    bondBuilder: 'Bond Builder',
    forceMapper: 'Force Mapper',
    labNotebookPro: 'Lab Notebook Pro',
    diagramAnnotator: 'Diagram Annotator',
    hypothesisHero: 'Hypothesis Hero',
  };

  static const Map<String, String> glyphs = <String, String>{
    masterMicroscopist: '🔬',
    molecularDetective: '🧬',
    physicsEngineer: '⚙️',
    cellCartographer: '🗺️',
    titrationAce: '🧪',
    trajectoryAce: '🚀',
    ecosystemWatcher: '🌿',
    bondBuilder: '⚗️',
    forceMapper: '↗️',
    labNotebookPro: '📓',
    diagramAnnotator: '✏️',
    hypothesisHero: '💡',
  };

  static String labelOf(String id) => labels[id] ?? id;
  static String glyphOf(String id) => glyphs[id] ?? '🏅';
}

/// Compact badge chip for HUD / notebook strips.
class ScienceBadgeChip extends StatelessWidget {
  const ScienceBadgeChip({
    super.key,
    required this.badgeId,
    required this.accent,
    this.compact = false,
  });

  final String badgeId;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String glyph = ScienceBadges.glyphOf(badgeId);
    final String label = ScienceBadges.labelOf(badgeId);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(glyph, style: TextStyle(fontSize: compact ? 11 : 13)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
