import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../data/science_diagram_catalog.dart';
import '../../../../../models/science_diagram.dart';
import '../../../../../widgets/science/anatomy_asset_canvas.dart';
import '../shared/science_lab_theme.dart';
import 'biology_anatomy_3d_lab.dart';
import 'clinical_viva_cases.dart';

/// Free-roam 3D anatomy viewers + launch into Clinical Viva Practical.
class Anatomy3dViewerHubScreen extends StatelessWidget {
  const Anatomy3dViewerHubScreen({super.key});

  static const ScienceLabTheme t = ScienceLabTheme.biology;

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Anatomy3dViewerHubScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121C2E),
        foregroundColor: Colors.white,
        title: const Text('3D Anatomy Viewers'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            'Rotate · tap · diagnose',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore real anatomy in 3D, then run a Clinical Viva — '
            'patient case → required view → structure → clinical WHY score.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 18),
          _ViewerCard(
            emoji: '🦴',
            title: 'Human Skeleton · 3D',
            blurb: 'Orbit anterior / lateral / posterior. Tap bones to inspect.',
            onExplore: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Anatomy3dFreeViewer(
                  diagramId: 'skeleton',
                  title: 'Skeleton 3D Viewer',
                ),
              ),
            ),
            onClinical: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const BiologyAnatomy3dLab(
                  caseId: 'shoulder_scapula',
                  missionMode: true,
                ),
              ),
            ),
            clinicalLabel: 'Clinical Viva · shoulder',
          ),
          const SizedBox(height: 12),
          _ViewerCard(
            emoji: '❤️',
            title: 'Heart Anatomy · 3D',
            blurb: 'Rotate chambers and great vessels. Tap to highlight.',
            onExplore: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Anatomy3dFreeViewer(
                  diagramId: 'heart_detail',
                  title: 'Heart 3D Viewer',
                ),
              ),
            ),
            onClinical: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const BiologyAnatomy3dLab(
                  caseId: 'lv_pump',
                  missionMode: true,
                ),
              ),
            ),
            clinicalLabel: 'Clinical Viva · LV failure',
          ),
          const SizedBox(height: 12),
          _ViewerCard(
            emoji: '🩹',
            title: 'FOOSH forearm case',
            blurb: 'Distal radius trauma on the skeleton model — classic board trap.',
            onExplore: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Anatomy3dFreeViewer(
                  diagramId: 'skeleton',
                  title: 'Skeleton 3D Viewer',
                  focusRegionIds: <String>['radius', 'ulna', 'humerus'],
                ),
              ),
            ),
            onClinical: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const BiologyAnatomy3dLab(
                  caseId: 'forearm_fall',
                  missionMode: true,
                ),
              ),
            ),
            clinicalLabel: 'Clinical Viva · FOOSH',
          ),
          const SizedBox(height: 22),
          Text(
            'All clinical cases',
            style: TextStyle(
              color: t.accent,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...ClinicalVivaCatalog.all.map(
            (ClinicalVivaCase c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                tileColor: const Color(0xFF0E1624),
                leading: Text(
                  c.diagramId == 'heart_detail' ? '❤️' : '🦴',
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(
                  c.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${c.requiredViewLabel} view · diagnose ${c.diagnoseTargetId}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white70),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => BiologyAnatomy3dLab(
                      caseId: c.id,
                      missionMode: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerCard extends StatelessWidget {
  const _ViewerCard({
    required this.emoji,
    required this.title,
    required this.blurb,
    required this.onExplore,
    required this.onClinical,
    required this.clinicalLabel,
  });

  final String emoji;
  final String title;
  final String blurb;
  final VoidCallback onExplore;
  final VoidCallback onClinical;
  final String clinicalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1624),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Anatomy3dViewerHubScreen.t.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(blurb, style: const TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onExplore,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Open 3D viewer'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onClinical,
                  style: FilledButton.styleFrom(
                    backgroundColor: Anatomy3dViewerHubScreen.t.accent,
                    foregroundColor: const Color(0xFF04110C),
                  ),
                  child: Text(
                    clinicalLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Free exploration 3D viewer (no mission gate).
class Anatomy3dFreeViewer extends StatefulWidget {
  const Anatomy3dFreeViewer({
    super.key,
    required this.diagramId,
    required this.title,
    this.focusRegionIds,
  });

  final String diagramId;
  final String title;
  final List<String>? focusRegionIds;

  @override
  State<Anatomy3dFreeViewer> createState() => _Anatomy3dFreeViewerState();
}

class _Anatomy3dFreeViewerState extends State<Anatomy3dFreeViewer> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  double _yawRadians = 0;
  double _pitchRadians = 0;
  String? _highlightId;
  String? _selectedName;
  String? _funFact;

  String get _viewLabel {
    final double deg = (_yawRadians * 180 / math.pi) % 360;
    final double a = deg < 0 ? deg + 360 : deg;
    if (a < 45 || a >= 315) return 'Anterior view';
    if (a < 135) return 'Lateral view (right)';
    if (a < 225) return 'Posterior view';
    return 'Lateral view (left)';
  }

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram =
        ScienceDiagramCatalog.diagramById(widget.diagramId);
    if (diagram == null) {
      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Diagram not found')),
      );
    }

    final Set<String>? enabled = widget.focusRegionIds?.toSet();

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121C2E),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final ClinicalVivaCase? c =
                  ClinicalVivaCatalog.forDiagram(widget.diagramId).isEmpty
                      ? null
                      : ClinicalVivaCatalog.forDiagram(widget.diagramId).first;
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => BiologyAnatomy3dLab(
                    caseId: c?.id,
                    diagramId: widget.diagramId,
                    missionMode: true,
                  ),
                ),
              );
            },
            child: Text('Clinical Viva', style: TextStyle(color: t.accent)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: <Widget>[
                Icon(Icons.threed_rotation, color: t.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag to orbit · tap a structure',
                    style: TextStyle(color: t.accent, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _viewLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_selectedName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1624),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.accent.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _selectedName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (_funFact != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        _funFact!,
                        style: const TextStyle(color: Colors.white70, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1624),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.accent.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GestureDetector(
                    onPanUpdate: (DragUpdateDetails d) {
                      setState(() {
                        _yawRadians += d.delta.dx * 0.012;
                        _pitchRadians =
                            (_pitchRadians + d.delta.dy * 0.008).clamp(-0.45, 0.45);
                      });
                    },
                    child: InteractiveViewer(
                      minScale: 0.6,
                      maxScale: 4,
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(_yawRadians)
                            ..rotateX(_pitchRadians),
                          child: AspectRatio(
                            aspectRatio: 1 / diagram.aspectRatio,
                            child: AnatomyAssetCanvas(
                              diagram: diagram,
                              highlightRegionId: _highlightId,
                              enabledRegionIds: enabled,
                              showOverlays: _highlightId != null,
                              dimNonHighlighted: _highlightId != null,
                              onRegionTap: (ScienceDiagramRegion r) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _highlightId = r.id;
                                  _selectedName = r.name;
                                  _funFact = r.funFact;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
