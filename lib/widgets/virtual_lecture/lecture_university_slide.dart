import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/lecture_visual_sync.dart';
import '../../data/science_diagram_catalog.dart';
import '../../models/virtual_lecture.dart';
import '../../services/lecture_diagram_service.dart';
import 'lecture_interactive_diagram_plate.dart';

/// Cream textbook concept slide with a **real** organ/diagram plate (not line art).
class LectureUniversitySlide extends StatelessWidget {
  const LectureUniversitySlide({
    super.key,
    required this.frame,
    this.khanStyle = false,
    this.speechProgress = 1,
    this.isSpeaking = false,
    this.phaseLabel,
    this.forceDiagramInteractive = false,
    this.identifyTargetId,
    this.onRegionIdentified,
    this.professorSpeech = '',
  });

  final LectureWhiteboardFrame frame;
  final bool khanStyle;
  final double speechProgress;
  final bool isSpeaking;
  final String? phaseLabel;
  final bool forceDiagramInteractive;
  final String? identifyTargetId;
  final ValueChanged<String>? onRegionIdentified;
  final String professorSpeech;

  static const Color _paper = Color(0xFFF7F1E8);
  static const Color _ink = Color(0xFF1C1917);
  static const Color _mute = Color(0xFF57534E);
  static const Color _teal = Color(0xFF0F766E);
  static const Color _rust = Color(0xFF9A3412);

  @override
  Widget build(BuildContext context) {
    final List<String> bullets = frame.keyPoints.isNotEmpty
        ? frame.keyPoints
        : frame.lines.where((String e) => e.trim().isNotEmpty).toList();
    final List<String> steps = frame.processSteps
        .where((String e) => e.trim().isNotEmpty)
        .toList();
    final bool showImage = frame.wantsRealDiagram ||
        frame.slideType == LectureSlideType.diagram ||
        frame.slideType == LectureSlideType.clinicalCase ||
        frame.slideType == LectureSlideType.label ||
        (frame.diagramId != null && frame.diagramId!.trim().isNotEmpty) ||
        (frame.diagramQuery != null && frame.diagramQuery!.trim().isNotEmpty) ||
        (frame.imageUrl != null && frame.imageUrl!.trim().isNotEmpty);
    final LectureSpokenVisual spoken = LectureVisualSync.resolve(
      diagramId: frame.diagramId,
      speech: professorSpeech,
      progress: speechProgress,
      teachingMode: frame.diagramTeachingMode,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _paper,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '${_typeLabel(frame.slideType)} · ${(phaseLabel ?? 'LECTURE').toUpperCase()}',
                  style: const TextStyle(
                    color: _teal,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                if (frame.diagramTeachingMode != null &&
                    frame.diagramTeachingMode!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: _teal.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      _teachingModeLabel(frame.diagramTeachingMode!),
                      style: const TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (frame.diagramId != null && frame.diagramId!.trim().isNotEmpty)
                  Text(
                    frame.diagramId!.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: _rust,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.4,
                      fontFamily: 'serif',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              frame.title.trim().isEmpty ? 'Lecture slide' : frame.title.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                height: 1.15,
                fontFamily: 'serif',
              ),
            ),
            if (frame.subtitle != null && frame.subtitle!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                frame.subtitle!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _mute,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: showImage
                  ? LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints c) {
                        final bool wide = c.maxWidth >= 420;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: _DiagramPlate(
                                  frame: frame,
                                  forceInteractive: forceDiagramInteractive,
                                  identifyTargetId: identifyTargetId,
                                  onRegionIdentified: onRegionIdentified,
                                  speech: professorSpeech,
                                  speechProgress: speechProgress,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 5,
                                child: _PointsColumn(
                                  bullets: bullets,
                                  steps: steps,
                                  dataColumns: frame.dataColumns,
                                  dataRows: frame.dataRows,
                                  speechProgress: speechProgress,
                                  activeLabel: spoken.label,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: _DiagramPlate(
                                frame: frame,
                                forceInteractive: forceDiagramInteractive,
                                identifyTargetId: identifyTargetId,
                                onRegionIdentified: onRegionIdentified,
                                speech: professorSpeech,
                                speechProgress: speechProgress,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              flex: 4,
                              child: _PointsColumn(
                                bullets: bullets,
                                steps: steps,
                                dataColumns: frame.dataColumns,
                                dataRows: frame.dataRows,
                                speechProgress: speechProgress,
                                activeLabel: spoken.label,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : _PointsColumn(
                      bullets: bullets,
                      steps: steps,
                      dataColumns: frame.dataColumns,
                      dataRows: frame.dataRows,
                      speechProgress: speechProgress,
                      activeLabel: spoken.label,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(LectureSlideType type) => switch (type) {
        LectureSlideType.concept => 'CONCEPT SLIDE',
        LectureSlideType.clinicalCase => 'CLINICAL CASE',
        LectureSlideType.data => 'DATA SLIDE',
        LectureSlideType.diagram => 'DIAGRAM SLIDE',
        LectureSlideType.label => 'LABEL SLIDE',
        LectureSlideType.question => 'QUESTION SLIDE',
        LectureSlideType.challenge => 'CHALLENGE SLIDE',
        LectureSlideType.simulation => 'SIMULATION',
        LectureSlideType.caseStudy => 'CASE STUDY',
        LectureSlideType.summary => 'SUMMARY',
      };

  static String _teachingModeLabel(String raw) {
    switch (raw) {
      case 'cleanOverview':
        return 'CLEAN PLATE';
      case 'regionOverview':
        return 'REGION OVERVIEW';
      case 'partFocus':
        return 'PART FOCUS';
      case 'relationship':
        return 'RELATIONSHIP';
      case 'identifyTap':
        return 'TAP TO FIND';
      case 'labelDrill':
        return 'LABEL DRILL';
      case 'clinicalApply':
        return 'CLINICAL APPLY';
      default:
        return raw.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (Match m) => ' ${m[1]}',
        ).trim().toUpperCase();
    }
  }
}

class _DiagramPlate extends StatelessWidget {
  const _DiagramPlate({
    required this.frame,
    this.forceInteractive = false,
    this.identifyTargetId,
    this.onRegionIdentified,
    this.speech = '',
    this.speechProgress = 0,
  });

  final LectureWhiteboardFrame frame;
  final bool forceInteractive;
  final String? identifyTargetId;
  final ValueChanged<String>? onRegionIdentified;
  final String speech;
  final double speechProgress;

  @override
  Widget build(BuildContext context) {
    final String? id = frame.diagramId?.trim();
    if (id != null &&
        id.isNotEmpty &&
        ScienceDiagramCatalog.diagramById(id) != null) {
      return LectureInteractiveDiagramPlate(
        frame: frame,
        forceInteractive: forceInteractive,
        identifyTargetId: identifyTargetId,
        onRegionIdentified: onRegionIdentified,
        speech: speech,
        speechProgress: speechProgress,
      );
    }
    return _RealAnatomyPlate(frame: frame);
  }
}

class _RealAnatomyPlate extends StatefulWidget {
  const _RealAnatomyPlate({required this.frame});

  final LectureWhiteboardFrame frame;

  @override
  State<_RealAnatomyPlate> createState() => _RealAnatomyPlateState();
}

class _RealAnatomyPlateState extends State<_RealAnatomyPlate> {
  LectureDiagramRef? _ref;
  bool _loading = true;
  Object? _key;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RealAnatomyPlate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frame.diagramId != widget.frame.diagramId ||
        oldWidget.frame.diagramQuery != widget.frame.diagramQuery ||
        oldWidget.frame.imageUrl != widget.frame.imageUrl ||
        oldWidget.frame.title != widget.frame.title) {
      _load();
    }
  }

  Future<void> _load() async {
    final Object key = Object();
    _key = key;
    setState(() => _loading = true);
    final LectureDiagramRef? ref = await LectureDiagramService.instance.resolve(
      imageUrl: widget.frame.imageUrl,
      diagramId: widget.frame.diagramId,
      diagramQuery: widget.frame.diagramQuery ??
          '${widget.frame.title} ${widget.frame.subtitle ?? ''} anatomy organ',
      title: widget.frame.title,
      lines: <String>[
        ...widget.frame.keyPoints,
        ...widget.frame.lines,
      ],
      topicName: widget.frame.title,
    );
    if (!mounted || !identical(_key, key)) return;
    setState(() {
      _ref = ref;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6D3D1)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            )
          : _ref == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Loading anatomical plate…',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF78716C)),
                    ),
                  ),
                )
              : _buildImage(_ref!),
    );
  }

  Widget _buildImage(LectureDiagramRef ref) {
    if (ref.isNetwork) {
      return Image.network(
        ref.networkUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const Center(
          child: Text('Image unavailable', style: TextStyle(color: Color(0xFF78716C))),
        ),
      );
    }
    final String path = ref.assetPath!;
    if (path.toLowerCase().endsWith('.svg')) {
      // Prefer real PNG plates — if an SVG slips through, still show it.
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const Center(
        child: Text('Image unavailable', style: TextStyle(color: Color(0xFF78716C))),
      ),
    );
  }
}

class _PointsColumn extends StatelessWidget {
  const _PointsColumn({
    required this.bullets,
    required this.steps,
    required this.dataColumns,
    required this.dataRows,
    this.speechProgress = 1,
    this.activeLabel,
  });

  final List<String> bullets;
  final List<String> steps;
  final List<String> dataColumns;
  final List<List<String>> dataRows;
  final double speechProgress;
  final String? activeLabel;

  @override
  Widget build(BuildContext context) {
    final int visibleBullets = bullets.isEmpty
        ? 0
        : (1 + (speechProgress.clamp(0.0, 1.0) * (bullets.length - 1)))
            .ceil()
            .clamp(1, bullets.length);
    final List<String> shown = bullets.take(visibleBullets).toList();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (steps.isNotEmpty) ...<Widget>[
            for (int i = 0; i < steps.length; i++) ...<Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD6D3D1)),
                ),
                child: Text(
                  steps[i].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1C1917),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (i < steps.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Icon(Icons.arrow_downward_rounded, size: 16, color: Color(0xFF0F766E)),
                ),
            ],
            const SizedBox(height: 10),
          ],
          if (dataRows.isNotEmpty) ...<Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6D3D1)),
              ),
              child: Column(
                children: <Widget>[
                  if (dataColumns.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                      child: Row(
                        children: dataColumns
                            .map(
                              (String h) => Expanded(
                                child: Text(
                                  h,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  for (final List<String> row in dataRows)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: row
                            .map(
                              (String cell) => Expanded(
                                child: Text(cell, style: const TextStyle(fontSize: 12)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (int i = 0; i < shown.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SpokenBulletRow(
                index: i + 1,
                text: shown[i],
                active: _bulletMatches(shown[i], activeLabel),
              ),
            ),
          if (shown.length < bullets.length)
            Text(
              '+${bullets.length - shown.length} more as the professor continues…',
              style: const TextStyle(
                color: Color(0xFF78716C),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  static bool _bulletMatches(String bullet, String? label) {
    if (label == null || label.trim().isEmpty) return false;
    final String hay = bullet.toLowerCase();
    final String needle = label.trim().toLowerCase();
    if (hay.contains(needle)) return true;
    final String compact = needle.replaceAll(RegExp(r'\s+'), '');
    return hay.replaceAll(RegExp(r'\s+'), '').contains(compact);
  }
}

class _SpokenBulletRow extends StatelessWidget {
  const _SpokenBulletRow({
    required this.index,
    required this.text,
    required this.active,
  });

  final int index;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0F766E).withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFF0F766E).withValues(alpha: 0.55) : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF0F766E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF0F766E),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF1C1917),
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                height: 1.35,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
