import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/diagram_misconception_catalog.dart';
import '../../data/science_diagram_catalog.dart';
import '../../models/science_diagram.dart';
import '../../widgets/science/science_diagram_canvas.dart';
import '../data/vu_v2_progress_store.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// Fast adaptive drill — fix confusion pairs (radius/ulna, etc.) with tap-to-identify.
class VuV2AdaptiveReviewDrillScreen extends StatefulWidget {
  const VuV2AdaptiveReviewDrillScreen({
    super.key,
    required this.progress,
    this.focusMisconceptionId,
  });

  final VuV2ProgressStore progress;
  final String? focusMisconceptionId;

  static Future<void> open(
    BuildContext context, {
    required VuV2ProgressStore progress,
    String? focusMisconceptionId,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VuV2AdaptiveReviewDrillScreen(
          progress: progress,
          focusMisconceptionId: focusMisconceptionId,
        ),
      ),
    );
  }

  @override
  State<VuV2AdaptiveReviewDrillScreen> createState() =>
      _VuV2AdaptiveReviewDrillScreenState();
}

class _VuV2AdaptiveReviewDrillScreenState
    extends State<VuV2AdaptiveReviewDrillScreen> {
  late List<DiagramMisconceptionDef> _queue = <DiagramMisconceptionDef>[];
  bool _ready = false;
  int _index = 0;
  int _correct = 0;
  int _cleared = 0;
  String? _selectedId;
  bool? _answeredOk;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await widget.progress.syncDiagramMisconceptions();
    final List<DiagramMisconceptionDef> due = <DiagramMisconceptionDef>[];
    final String? focus = widget.focusMisconceptionId;
    if (focus != null) {
      final DiagramMisconceptionDef? d = DiagramMisconceptionCatalog.byId(focus);
      if (d != null) due.add(d);
    }
    for (final String id in widget.progress.topDiagramMisconceptions) {
      if (due.any((DiagramMisconceptionDef x) => x.id == id)) continue;
      final DiagramMisconceptionDef? d = DiagramMisconceptionCatalog.byId(id);
      if (d != null) due.add(d);
    }
    if (due.isEmpty) {
      due.addAll(DiagramMisconceptionCatalog.all.take(3));
    }
    if (!mounted) return;
    setState(() {
      _queue = due;
      _ready = true;
    });
  }

  DiagramMisconceptionDef? get _current =>
      _queue.isEmpty || _index >= _queue.length ? null : _queue[_index];

  Future<void> _onTap(String regionId) async {
    final DiagramMisconceptionDef? cur = _current;
    if (cur == null || _answeredOk != null) return;
    final bool ok = regionId == cur.regionA;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedId = regionId;
      _answeredOk = ok;
      if (ok) _correct += 1;
    });
    if (ok) {
      await widget.progress.recordMisconceptionCleared(cur.id);
      _cleared += 1;
    } else {
      await widget.progress.recordDiagramConfusion(
        diagramId: cur.diagramId,
        tappedRegionId: regionId,
        targetRegionId: cur.regionA,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_index >= _queue.length - 1) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _index += 1;
        _selectedId = null;
        _answeredOk = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || (_queue.isEmpty && !_finished)) {
      return const Scaffold(
        backgroundColor: VuV2Colors.navy,
        body: Center(child: CircularProgressIndicator(color: VuV2Colors.mint)),
      );
    }

    if (_finished) {
      return Scaffold(
        backgroundColor: VuV2Colors.navy,
        appBar: AppBar(
          backgroundColor: VuV2Colors.navyElevated,
          foregroundColor: VuV2Colors.ink,
          title: const Text('Review complete'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.emoji_events_outlined, color: VuV2Colors.gold, size: 48),
              const SizedBox(height: 16),
              Text(
                '$_correct / ${_queue.length} correct',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cleared > 0
                    ? 'Cleared $_cleared confusion pair${_cleared == 1 ? '' : 's'}. Mastery streak: ${widget.progress.masteryClearStreak}.'
                    : 'Keep drilling — the AI Professor will re-teach weak pairs next lecture.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
              ),
              const Spacer(),
              VuV2PrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    final DiagramMisconceptionDef cur = _current!;
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(cur.diagramId);

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        backgroundColor: VuV2Colors.navyElevated,
        foregroundColor: VuV2Colors.ink,
        title: Text('Fix: ${cur.labelA} vs ${cur.labelB}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            'Card ${_index + 1} of ${_queue.length}',
            style: const TextStyle(
              color: VuV2Colors.mint,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ${cur.labelA} on the diagram',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cur.keyPoints.join(' · '),
            style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.05,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: const Color(0xFFF7F1E8),
                child: diagram == null
                    ? const Center(child: Text('Diagram unavailable'))
                    : ScienceDiagramCanvas(
                        diagram: diagram,
                        highlightRegionId: _answeredOk == true ? cur.regionA : null,
                        highlightRegionIds: <String>{cur.regionA, cur.regionB},
                        enabledRegionIds: <String>{cur.regionA, cur.regionB},
                        showOverlays: _answeredOk != null,
                        dimNonHighlighted: true,
                        feedbackRegionId: _selectedId,
                        feedbackCorrect: _answeredOk,
                        onRegionTap: (ScienceDiagramRegion r) => _onTap(r.id),
                      ),
              ),
            ),
          ),
          if (_answeredOk != null) ...<Widget>[
            const SizedBox(height: 14),
            VuV2Surface(
              child: Text(
                _answeredOk!
                    ? 'Locked in. ${cur.keyPoints.first}'
                    : cur.reviewSpeech,
                style: const TextStyle(color: VuV2Colors.ink, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
