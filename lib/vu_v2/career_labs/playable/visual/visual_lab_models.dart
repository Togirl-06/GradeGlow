import 'package:flutter/material.dart';

enum VisualLabKind {
  identify,
  label,
  assemble,
  measure,
  observe,
  graph,
  interpret,
  prioritize,
  pathTrace,
  imagingAnnotate,
}

enum LabelDifficulty { beginner, intermediate, advanced, expert }

enum MeasureInstrumentKind {
  thermometer,
  voltmeter,
  ruler,
  scale,
  stopwatch,
  spo2,
  bpCuff,
  pipette,
  spectrometer,
}

/// Hotspot on a diagram — fx/fy are fractions 0..1 of width/height.
class Hotspot {
  const Hotspot({
    required this.id,
    required this.correctLabel,
    required this.fx,
    required this.fy,
    this.radius = 0.06,
    this.anchor = Alignment.center,
  });

  final String id;
  final String correctLabel;
  final Alignment anchor;
  final double fx;
  final double fy;
  final double radius;
}

class AssembleSlot {
  const AssembleSlot({
    required this.id,
    required this.name,
    required this.correctPartId,
    this.fx = 0.5,
    this.fy = 0.5,
  });

  final String id;
  final String name;
  final String correctPartId;
  final double fx;
  final double fy;
}

class AssemblePart {
  const AssemblePart({
    required this.id,
    required this.label,
    this.glyph = '🧩',
  });

  final String id;
  final String label;
  final String glyph;
}

class MeasureInstrument {
  const MeasureInstrument({
    required this.kind,
    required this.targetValue,
    required this.unit,
    this.min = 0,
    this.max = 100,
    this.tolerance = 2,
    this.label = 'Reading',
    this.displayPrecision = 1,
  });

  final MeasureInstrumentKind kind;
  final double targetValue;
  final String unit;
  final double min;
  final double max;
  final double tolerance;
  final String label;
  final int displayPrecision;
}

class ObserveParam {
  const ObserveParam({
    required this.id,
    required this.label,
    this.min = 0,
    this.max = 100,
    this.initial = 50,
    this.unit = '',
  });

  final String id;
  final String label;
  final double min;
  final double max;
  final double initial;
  final String unit;
}

class ObserveScenario {
  const ObserveScenario({
    required this.params,
    required this.prompt,
    required this.keywords,
    this.choices = const <String>[],
    this.correctChoiceIndex,
    this.simulationHint = '',
  });

  final List<ObserveParam> params;
  final String prompt;
  final List<String> keywords;
  final List<String> choices;
  final int? correctChoiceIndex;
  final String simulationHint;
}

class GraphScenario {
  const GraphScenario({
    required this.xLabel,
    required this.yLabel,
    required this.expectedPoints,
    required this.interpretKeywords,
    this.prompt = 'Plot the data and interpret the trend.',
    this.pointTolerance = 8,
  });

  final String xLabel;
  final String yLabel;
  final List<Offset> expectedPoints; // normalized 0..1 chart space
  final List<String> interpretKeywords;
  final String prompt;
  final double pointTolerance;
}

class InterpretScenario {
  const InterpretScenario({
    required this.visualKind,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    this.freeTextKeywords = const <String>[],
    this.caption = '',
  });

  /// ecg | supply_demand | xray | waveform | chart | network
  final String visualKind;
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final List<String> freeTextKeywords;
  final String caption;
}

class PrioritizeItem {
  const PrioritizeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.correctRank,
    this.acuity = '',
    this.glyph = '●',
  });

  final String id;
  final String title;
  final String subtitle;
  final int correctRank; // 1 = Immediate … 4 = Low
  final String acuity;
  final String glyph;
}

class PathNode {
  const PathNode({
    required this.id,
    required this.label,
    required this.fx,
    required this.fy,
  });

  final String id;
  final String label;
  final double fx;
  final double fy;
}

class VisualLabSpec {
  const VisualLabSpec({
    required this.id,
    required this.careerId,
    required this.kind,
    required this.title,
    required this.brief,
    required this.accent,
    required this.bg,
    this.surface = const Color(0xFF0F1A2C),
    this.difficulty = LabelDifficulty.beginner,
    this.wordBank = const <String>[],
    this.hotspots = const <Hotspot>[],
    this.diagramTitle = 'body',
    this.slots = const <AssembleSlot>[],
    this.parts = const <AssemblePart>[],
    this.instrument,
    this.observe,
    this.graph,
    this.interpret,
    this.prioritizeItems,
    this.pathOrder,
    this.pathNodes = const <PathNode>[],
    this.isPracticalExam = false,
    this.practicalStepIds = const <String>[],
    this.passThreshold = 0.67,
    this.identifyOptions = const <String>[],
    this.correctIdentifyId,
  });

  final String id;
  final String careerId;
  final VisualLabKind kind;
  final String title;
  final String brief;
  final Color accent;
  final Color bg;
  final Color surface;
  final LabelDifficulty difficulty;
  final List<String> wordBank;
  final List<Hotspot> hotspots;
  final String diagramTitle;
  final List<AssembleSlot> slots;
  final List<AssemblePart> parts;
  final MeasureInstrument? instrument;
  final ObserveScenario? observe;
  final GraphScenario? graph;
  final InterpretScenario? interpret;
  final List<PrioritizeItem>? prioritizeItems;
  final List<String>? pathOrder;
  final List<PathNode> pathNodes;
  final bool isPracticalExam;
  final List<String> practicalStepIds;
  final double passThreshold;

  /// For identify: tap the matching hotspot / option.
  final List<String> identifyOptions;
  final String? correctIdentifyId;
}
