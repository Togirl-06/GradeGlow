import 'dart:math';

import 'package:flutter/material.dart';

import '../models/anatomy_game.dart';
import '../models/science_diagram.dart';
import '../utils/diagram_question_prompts.dart';
import 'diagram_asset_registry.dart';

/// Organs, hit zones, and quiz rounds for the anatomy diagram game.
class AnatomyGameData {
  AnatomyGameData._();

  static ScienceDiagram get diagram => ScienceDiagram(
        id: 'human_organs',
        title: 'Human Organs',
        subtitle: 'Tap each organ on the anatomical illustration.',
        kind: ScienceDiagramKind.humanOrgans,
        aspectRatio: 0.67,
        assetPath: DiagramAssetRegistry.organs,
        regions: regions
            .map(
              (AnatomyRegion r) => ScienceDiagramRegion(
                id: r.id,
                name: r.name,
                color: r.color,
                center: r.center,
                size: r.size,
                funFact: r.funFact,
              ),
            )
            .toList(),
      );

  static const List<AnatomyRegion> regions = <AnatomyRegion>[
    AnatomyRegion(
      id: 'brain',
      name: 'Brain',
      system: 'Nervous',
      color: Color(0xFFE8B4B8),
      center: Offset(0.5, 0.11),
      size: Size(0.22, 0.14),
      funFact: 'The brain uses about 20% of the body\'s oxygen.',
    ),
    AnatomyRegion(
      id: 'heart',
      name: 'Heart',
      system: 'Cardiovascular',
      color: Color(0xFFC62828),
      center: Offset(0.46, 0.34),
      size: Size(0.16, 0.12),
      funFact: 'The heart beats roughly 100,000 times per day.',
    ),
    AnatomyRegion(
      id: 'lungs',
      name: 'Lungs',
      system: 'Respiratory',
      color: Color(0xFFEF9A9A),
      center: Offset(0.5, 0.36),
      size: Size(0.34, 0.18),
      funFact: 'You take about 20,000 breaths every day.',
    ),
    AnatomyRegion(
      id: 'liver',
      name: 'Liver',
      system: 'Digestive',
      color: Color(0xFF8D6E63),
      center: Offset(0.42, 0.52),
      size: Size(0.2, 0.12),
      funFact: 'The liver performs over 500 vital functions.',
    ),
    AnatomyRegion(
      id: 'stomach',
      name: 'Stomach',
      system: 'Digestive',
      color: Color(0xFFD4A574),
      center: Offset(0.54, 0.5),
      size: Size(0.16, 0.14),
      funFact: 'Stomach acid is strong enough to digest metal — but mucus protects the lining.',
    ),
    AnatomyRegion(
      id: 'kidneys',
      name: 'Kidneys',
      system: 'Urinary',
      color: Color(0xFF7B1FA2),
      center: Offset(0.5, 0.58),
      size: Size(0.24, 0.1),
      funFact: 'Kidneys filter about 50 gallons of blood every day.',
    ),
    AnatomyRegion(
      id: 'intestines',
      name: 'Small Intestine',
      system: 'Digestive',
      color: Color(0xFFFFCC80),
      center: Offset(0.5, 0.68),
      size: Size(0.28, 0.16),
      funFact: 'The small intestine is about 20 feet long — most nutrient absorption happens here.',
    ),
  ];

  static AnatomyRegion? regionById(String id) {
    for (final AnatomyRegion r in regions) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<AnatomyQuestion> buildRoundDeck({required String labId}) {
    final Random random = Random(labId.hashCode);
    final List<AnatomyRegion> pool = List<AnatomyRegion>.from(regions)..shuffle(random);

    final List<AnatomyQuestion> questions = <AnatomyQuestion>[];
    for (final AnatomyRegion target in pool) {
      final ScienceDiagramQuestion generated = DiagramQuestionPrompts.uniqueQuestionForRegion(
        target: ScienceDiagramRegion(
          id: target.id,
          name: target.name,
          color: target.color,
          center: target.center,
          size: target.size,
          funFact: target.funFact,
        ),
        diagram: diagram,
        activePool: regions
            .map(
              (AnatomyRegion r) => ScienceDiagramRegion(
                id: r.id,
                name: r.name,
                color: r.color,
                center: r.center,
                size: r.size,
                funFact: r.funFact,
              ),
            )
            .toList(),
        random: random,
        allowTypeName: false,
        buildOptions: ({
          required String correctName,
          required List<ScienceDiagramRegion> pool,
          required String targetRegionId,
          required Random random,
        }) =>
            _uniqueMcqOptions(
          correctName: correctName,
          pool: regions,
          targetRegionId: targetRegionId,
          random: random,
        ),
      );
      questions.add(
        AnatomyQuestion(
          prompt: generated.prompt,
          targetRegionId: generated.targetRegionId,
          kind: generated.kind == ScienceDiagramQuestionKind.tapTarget
              ? AnatomyQuestionKind.tapTarget
              : AnatomyQuestionKind.pickName,
          options: generated.options,
        ),
      );
    }
    questions.shuffle(random);
    return questions;
  }

  static List<String> _uniqueMcqOptions({
    required String correctName,
    required List<AnatomyRegion> pool,
    required String targetRegionId,
    required Random random,
    int maxOptions = 4,
  }) {
    final List<String> options = <String>[correctName];
    final List<AnatomyRegion> others = pool.where((AnatomyRegion r) => r.id != targetRegionId).toList()
      ..shuffle(random);
    for (final AnatomyRegion region in others) {
      if (options.length >= maxOptions) break;
      if (!options.contains(region.name)) options.add(region.name);
    }
    options.shuffle(random);
    return options;
  }
}
