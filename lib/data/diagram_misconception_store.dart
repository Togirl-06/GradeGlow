import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/virtual_lecture.dart';
import 'diagram_misconception_catalog.dart';
import 'lecture_diagram_progression.dart';

/// Persists diagram confusion counts and builds adaptive review lecture segments.
class DiagramMisconceptionStore {
  DiagramMisconceptionStore._();
  static final DiagramMisconceptionStore instance = DiagramMisconceptionStore._();

  static const String _key = 'diagram_misconceptions_v1';
  static const int reviewThreshold = 2;

  final Map<String, int> _counts = <String, int>{};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      _counts
        ..clear()
        ..addAll(
          data.map(
            (String k, dynamic v) => MapEntry(k, (v as num).toInt()),
          ),
        );
    } catch (_) {
      _counts.clear();
    }
  }

  Future<void> recordConfusion({
    required String diagramId,
    required String tappedRegionId,
    required String targetRegionId,
  }) async {
    await ensureLoaded();
    final DiagramMisconceptionDef? def = DiagramMisconceptionCatalog.resolve(
      diagramId: diagramId,
      tappedRegionId: tappedRegionId,
      targetRegionId: targetRegionId,
    );
    if (def == null) return;
    _counts[def.id] = (_counts[def.id] ?? 0) + 1;
    await _persist();
  }

  int countFor(String misconceptionId) => _counts[misconceptionId] ?? 0;

  Map<String, int> exportCounts() => Map<String, int>.from(_counts);

  List<DiagramMisconceptionDef> get needsReview {
    return DiagramMisconceptionCatalog.all
        .where((DiagramMisconceptionDef d) => (_counts[d.id] ?? 0) >= reviewThreshold)
        .toList(growable: false);
  }

  Future<void> markReviewed(String misconceptionId) async {
    await ensureLoaded();
    _counts.remove(misconceptionId);
    await _persist();
  }

  /// Seeds radius/ulna confusion so judges see adaptive review instantly.
  Future<void> seedDemoConfusions() async {
    await ensureLoaded();
    _counts['radius_ulna'] = reviewThreshold;
    _counts['scapula_clavicle'] = 1;
    await _persist();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_counts));
  }

  /// Inject adaptive professor review segments before the main lecture.
  Future<List<LectureSegment>> adaptivePrefaceSegments() async {
    await ensureLoaded();
    final List<LectureSegment> out = <LectureSegment>[];
    for (final DiagramMisconceptionDef d in needsReview) {
      out.add(
        LectureSegment(
          phase: LecturePhase.knowledgeCheck,
          professorSpeech: d.reviewSpeech,
          caption: 'Adaptive review — ${d.labelA} vs ${d.labelB}',
          durationSeconds: 75,
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.diagram,
            title: 'ADAPTIVE REVIEW',
            subtitle: '${d.labelA} vs ${d.labelB}',
            slideType: LectureSlideType.diagram,
            diagramId: d.diagramId,
            highlightRegionIds: <String>[d.regionA, d.regionB],
            keyPoints: d.keyPoints,
            diagramTeachingMode: DiagramLectureMode.partFocus.name,
          ),
          knowledgeCheck: LectureKnowledgeCheck(
            prompt: 'Which is ${d.labelA}? Tap it on the diagram.',
            kind: KnowledgeCheckKind.graphIdentify,
            diagramId: d.diagramId,
            targetRegionId: d.regionA,
            correctAnswer: d.regionA,
            explanation: 'Correct. ${d.keyPoints.first}',
            timeLimitSeconds: 25,
          ),
        ),
      );
    }
    return out;
  }
}

abstract final class AdaptiveDiagramReview {
  /// Only replay a prior mix-up when this lecture uses the same diagram.
  /// Otherwise a skeleton drill would play over chemistry, law, etc.
  static Future<List<LectureSegment>> prefaceIfNeeded({String? diagramId}) async {
    final List<LectureSegment> all =
        await DiagramMisconceptionStore.instance.adaptivePrefaceSegments();
    final String? id = diagramId?.trim();
    if (id == null || id.isEmpty) return const <LectureSegment>[];
    return all
        .where((LectureSegment s) => s.whiteboard.diagramId == id)
        .toList(growable: false);
  }
}
