import 'package:flutter/material.dart';

import 'visual_diagram_canvas.dart';
import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Tap next node in the correct sequence; wrong taps flash.
class VisualPathTraceScreen extends StatefulWidget {
  const VisualPathTraceScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualPathTraceScreen> createState() => _VisualPathTraceScreenState();
}

class _VisualPathTraceScreenState extends State<VisualPathTraceScreen>
    with SingleTickerProviderStateMixin {
  int _progress = 0;
  String? _flashWrong;
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..repeat(reverse: true);

  VisualLabSpec get spec => widget.spec;

  List<PathNode> get _nodes {
    if (spec.pathNodes.isNotEmpty) return spec.pathNodes;
    final List<String> order = spec.pathOrder ?? const <String>[];
    return List<PathNode>.generate(order.length, (int i) {
      final double t = order.length <= 1 ? 0.5 : i / (order.length - 1);
      return PathNode(
        id: order[i],
        label: order[i],
        fx: 0.15 + t * 0.7,
        fy: 0.35 + (i.isEven ? -0.1 : 0.15),
      );
    });
  }

  List<String> get _order {
    if (spec.pathOrder != null && spec.pathOrder!.isNotEmpty) {
      return spec.pathOrder!;
    }
    return _nodes.map((PathNode n) => n.id).toList();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onTap(String nodeId) async {
    if (_progress >= _order.length) return;
    final String expected = _order[_progress];
    if (nodeId == expected) {
      setState(() => _progress++);
      if (_progress >= _order.length) {
        await showVisualLabResult(
          context: context,
          spec: spec,
          passed: true,
          body: 'Path traced in the correct order. Sequence complete.',
        );
        if (mounted) Navigator.pop(context, true);
      }
    } else {
      setState(() => _flashWrong = nodeId);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _flashWrong = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PathNode> nodes = _nodes;

    return VisualLabShell(
      spec: spec,
      badgeLabel: 'PATH TRACE',
      footer: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: spec.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            AnimatedBuilder(
              animation: _pulse,
              builder: (BuildContext context, _) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: spec.accent.withValues(alpha: 0.5 + _pulse.value * 0.5),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _progress >= _order.length
                    ? 'Sequence complete'
                    : 'Next: tap ${_order[_progress]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '$_progress / ${_order.length}',
              style: TextStyle(color: spec.accent, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: VisualDiagramCanvas(
                diagramTitle: spec.diagramTitle,
                accent: spec.accent,
                pathNodes: nodes,
                pathProgress: _progress.clamp(0, nodes.isEmpty ? 0 : nodes.length - 1),
                onHotspotTap: (Hotspot h) => _onTap(h.id),
              ),
            ),
            if (_flashWrong != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Wrong node — follow the physiological / logical order.',
                  style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.9), fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
