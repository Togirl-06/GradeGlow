import 'package:flutter/material.dart';

import '../../data/lecture_visual_sync.dart';
import '../../data/science_diagram_catalog.dart';
import '../../models/science_diagram.dart';
import '../../models/virtual_lecture.dart';
import '../science/science_diagram_canvas.dart';

/// Large center-stage interactive diagram for AI lectures — speech drives highlights.
class LectureInteractiveDiagramPlate extends StatefulWidget {
  const LectureInteractiveDiagramPlate({
    super.key,
    required this.frame,
    this.onRegionIdentified,
    this.forceInteractive = false,
    this.identifyTargetId,
    this.speech = '',
    this.speechProgress = 0,
  });

  final LectureWhiteboardFrame frame;
  final ValueChanged<String>? onRegionIdentified;
  final bool forceInteractive;
  final String? identifyTargetId;
  final String speech;
  final double speechProgress;

  @override
  State<LectureInteractiveDiagramPlate> createState() =>
      _LectureInteractiveDiagramPlateState();
}

class _LectureInteractiveDiagramPlateState extends State<LectureInteractiveDiagramPlate> {
  String? _feedbackId;
  bool? _feedbackCorrect;

  ScienceDiagram? get _diagram {
    final String? id = widget.frame.diagramId?.trim();
    if (id == null || id.isEmpty) return null;
    return ScienceDiagramCatalog.diagramById(id);
  }

  bool get _interactive =>
      widget.forceInteractive || widget.frame.diagramInteractive;

  bool get _quizMode {
    final String mode = widget.frame.diagramTeachingMode ?? '';
    return mode == 'identifyTap' || mode == 'labelDrill';
  }

  LectureSpokenVisual get _spoken {
    if (_quizMode) return LectureSpokenVisual.empty;
    return LectureVisualSync.resolve(
      diagramId: widget.frame.diagramId,
      diagram: _diagram,
      speech: widget.speech,
      progress: widget.speechProgress,
      teachingMode: widget.frame.diagramTeachingMode,
    );
  }

  Set<String> get _highlightSet {
    final LectureSpokenVisual spoken = _spoken;
    if (spoken.isActive) return spoken.regionIds;
    return const <String>{};
  }

  String? get _primaryHighlight {
    final Set<String> ids = _highlightSet;
    if (ids.isEmpty) return null;
    return ids.first;
  }

  Set<String>? get _enabledRegions {
    final ScienceDiagram? d = _diagram;
    if (d == null) return null;
    // Keep every structure on the plate — dim, never hide.
    return d.regions.map((ScienceDiagramRegion r) => r.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram = _diagram;
    if (diagram == null) {
      return const Center(
        child: Text(
          'Diagram loading…',
          style: TextStyle(color: Color(0xFF78716C)),
        ),
      );
    }

    final Set<String> highlights = _highlightSet;
    final LectureSpokenVisual spoken = _spoken;
    final bool showLive = highlights.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ScienceDiagramCanvas(
          diagram: diagram,
          highlightRegionId: _primaryHighlight,
          highlightRegionIds: highlights,
          enabledRegionIds: _enabledRegions,
          showOverlays: showLive || _interactive,
          dimNonHighlighted: showLive,
          feedbackRegionId: _feedbackId,
          feedbackCorrect: _feedbackCorrect,
          pulse: showLive,
          showSpokenLabels: showLive,
          autoFocus: spoken.zoom,
          spokenLabel: spoken.label,
          onRegionTap: (ScienceDiagramRegion region) {
            widget.onRegionIdentified?.call(region.id);
            setState(() {
              _feedbackId = region.id;
              if (widget.identifyTargetId != null) {
                _feedbackCorrect = region.id == widget.identifyTargetId;
              } else {
                _feedbackCorrect = null;
              }
            });
          },
        ),
        if (widget.frame.diagramTeachingMode != null &&
            widget.frame.diagramTeachingMode!.trim().isNotEmpty)
          Positioned(
            left: 12,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _modeChip(widget.frame.diagramTeachingMode!),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        if (!showLive && !_interactive)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Clean plate — labels hidden',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        if (_interactive)
          Positioned(
            right: 8,
            top: 8,
            child: _toolChip(Icons.touch_app_outlined, 'Tap structure'),
          ),
        if (!_interactive)
          Positioned(
            right: 8,
            top: 8,
            child: _toolChip(Icons.zoom_in_map_rounded, 'Pinch zoom'),
          ),
        if (widget.frame.interactiveActivity != null &&
            widget.frame.interactiveActivity!.trim().isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    widget.frame.interactiveActivity == 'anatomy_3d'
                        ? Icons.view_in_ar_rounded
                        : Icons.drag_indicator,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.frame.interactiveActivity == 'label_drag'
                          ? 'Drag-and-drop labeling opens when the professor finishes speaking'
                          : widget.frame.interactiveActivity == 'anatomy_3d'
                              ? '3D rotation lab opens next — drag to orbit the model'
                              : 'Interactive activity next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _toolChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6D3D1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: const Color(0xFF0F766E)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _modeChip(String raw) {
    switch (raw) {
      case 'cleanOverview':
        return 'MODE · CLEAN PLATE';
      case 'regionOverview':
        return 'MODE · REGION';
      case 'partFocus':
        return 'MODE · PART FOCUS';
      case 'relationship':
        return 'MODE · RELATIONSHIP';
      case 'identifyTap':
        return 'MODE · TAP TO FIND';
      case 'labelDrill':
        return 'MODE · LABEL DRILL';
      case 'clinicalApply':
        return 'MODE · CLINICAL';
      default:
        return 'MODE · ${raw.toUpperCase()}';
    }
  }
}
