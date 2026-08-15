import 'dart:math';

import '../models/science_diagram.dart';

/// Varied labeling prompts — one challenge style per structure per session.
class DiagramQuestionPrompts {
  DiagramQuestionPrompts._();

  static const List<String> _tapTemplates = <String>[
    'Locate the {name} on the illustration',
    'Tap the {name} on the diagram',
    'Where is the {name}? Select it on the image',
    'Find the {name} in this diagram',
    'Point to the {name}',
  ];

  static const List<String> _pickTemplates = <String>[
    'What is the highlighted structure called?',
    'Name the part indicated on the diagram',
    'Which label matches the highlighted region?',
    'Identify the structure marked on the image',
    'Select the correct name for the highlighted part',
  ];

  static const List<String> _typeTemplates = <String>[
    'Tap the {name}, then type its name',
    'Select the {name} and spell the label',
    'Find the {name} and enter its scientific name',
  ];

  static ScienceDiagramQuestion uniqueQuestionForRegion({
    required ScienceDiagramRegion target,
    required ScienceDiagram diagram,
    required List<ScienceDiagramRegion> activePool,
    required Random random,
    required bool allowTypeName,
    required List<String> Function({
      required String correctName,
      required List<ScienceDiagramRegion> pool,
      required String targetRegionId,
      required Random random,
    }) buildOptions,
  }) {
    final List<ScienceDiagramQuestionKind> kinds = <ScienceDiagramQuestionKind>[
      ScienceDiagramQuestionKind.tapTarget,
      ScienceDiagramQuestionKind.pickName,
      if (allowTypeName) ScienceDiagramQuestionKind.typeName,
    ];
    final ScienceDiagramQuestionKind kind = kinds[random.nextInt(kinds.length)];
    final String name = target.name.toLowerCase();

    switch (kind) {
      case ScienceDiagramQuestionKind.tapTarget:
        final String template = _tapTemplates[random.nextInt(_tapTemplates.length)];
        return ScienceDiagramQuestion(
          prompt: template.replaceAll('{name}', name),
          targetRegionId: target.id,
          kind: kind,
        );
      case ScienceDiagramQuestionKind.pickName:
        return ScienceDiagramQuestion(
          prompt: _pickTemplates[random.nextInt(_pickTemplates.length)],
          targetRegionId: target.id,
          kind: kind,
          options: buildOptions(
            correctName: target.name,
            pool: activePool,
            targetRegionId: target.id,
            random: random,
          ),
        );
      case ScienceDiagramQuestionKind.typeName:
        final String template = _typeTemplates[random.nextInt(_typeTemplates.length)];
        return ScienceDiagramQuestion(
          prompt: template.replaceAll('{name}', name),
          targetRegionId: target.id,
          kind: kind,
        );
    }
  }
}
