import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'visual_lab_models.dart';

/// Zoomable diagram with silhouette + hotspot markers.
class VisualDiagramCanvas extends StatelessWidget {
  const VisualDiagramCanvas({
    super.key,
    required this.diagramTitle,
    required this.accent,
    this.hotspots = const <Hotspot>[],
    this.selectedHotspotId,
    this.placedLabels = const <String, String>{},
    this.flashWrongId,
    this.onHotspotTap,
    this.pathNodes = const <PathNode>[],
    this.pathProgress = 0,
    this.showLabels = true,
  });

  final String diagramTitle;
  final Color accent;
  final List<Hotspot> hotspots;
  final String? selectedHotspotId;
  final Map<String, String> placedLabels;
  final String? flashWrongId;
  final void Function(Hotspot hotspot)? onHotspotTap;
  final List<PathNode> pathNodes;
  final int pathProgress;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 3.5,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final Size size = Size(c.maxWidth, c.maxHeight);
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CustomPaint(
                    size: size,
                    painter: DiagramSilhouettePainter(
                      title: diagramTitle,
                      accent: accent,
                    ),
                  ),
                  if (pathNodes.length >= 2)
                    CustomPaint(
                      size: size,
                      painter: _PathPainter(
                        nodes: pathNodes,
                        progress: pathProgress,
                        accent: accent,
                      ),
                    ),
                  for (final Hotspot h in hotspots)
                    _HotspotMarker(
                      hotspot: h,
                      accent: accent,
                      selected: selectedHotspotId == h.id,
                      label: showLabels ? placedLabels[h.id] : null,
                      wrong: flashWrongId == h.id,
                      onTap: onHotspotTap == null ? null : () => onHotspotTap!(h),
                    ),
                  for (final PathNode n in pathNodes)
                    _PathNodeMarker(
                      node: n,
                      accent: accent,
                      active: pathNodes.indexOf(n) == pathProgress,
                      done: pathNodes.indexOf(n) < pathProgress,
                      onTap: onHotspotTap == null
                          ? null
                          : () => onHotspotTap!(
                                Hotspot(
                                  id: n.id,
                                  correctLabel: n.label,
                                  fx: n.fx,
                                  fy: n.fy,
                                ),
                              ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HotspotMarker extends StatelessWidget {
  const _HotspotMarker({
    required this.hotspot,
    required this.accent,
    required this.selected,
    required this.wrong,
    this.label,
    this.onTap,
  });

  final Hotspot hotspot;
  final Color accent;
  final bool selected;
  final bool wrong;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(hotspot.fx * 2 - 1, hotspot.fy * 2 - 1),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: wrong
                ? Colors.redAccent.withValues(alpha: 0.45)
                : selected
                    ? accent.withValues(alpha: 0.45)
                    : accent.withValues(alpha: 0.18),
            border: Border.all(
              color: wrong
                  ? Colors.redAccent
                  : selected
                      ? accent
                      : accent.withValues(alpha: 0.7),
              width: selected || wrong ? 2.5 : 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (wrong ? Colors.redAccent : accent).withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: label == null
              ? Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PathNodeMarker extends StatelessWidget {
  const _PathNodeMarker({
    required this.node,
    required this.accent,
    required this.active,
    required this.done,
    this.onTap,
  });

  final PathNode node;
  final Color accent;
  final bool active;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(node.fx * 2 - 1, node.fy * 2 - 1),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? accent
                    : active
                        ? accent.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: active ? Colors.white : accent.withValues(alpha: 0.6),
                  width: active ? 2.5 : 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                node.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.nodes,
    required this.progress,
    required this.accent,
  });

  final List<PathNode> nodes;
  final int progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;
    final Paint trail = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint done = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path full = Path();
    for (int i = 0; i < nodes.length; i++) {
      final Offset o = Offset(nodes[i].fx * size.width, nodes[i].fy * size.height);
      if (i == 0) {
        full.moveTo(o.dx, o.dy);
      } else {
        full.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(full, trail);

    if (progress > 0) {
      final Path lit = Path();
      for (int i = 0; i <= progress.clamp(0, nodes.length - 1); i++) {
        final Offset o = Offset(nodes[i].fx * size.width, nodes[i].fy * size.height);
        if (i == 0) {
          lit.moveTo(o.dx, o.dy);
        } else {
          lit.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(lit, done);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.nodes != nodes;
}

/// Keyword-based silhouette painter for common diagram themes.
class DiagramSilhouettePainter extends CustomPainter {
  DiagramSilhouettePainter({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = accent.withValues(alpha: 0.12);
    final Paint stroke = Paint()
      ..color = accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final String key = title.toLowerCase();
    if (key.contains('heart')) {
      _heart(canvas, size, fill, stroke);
    } else if (key.contains('cell') || key.contains('neuron')) {
      _cell(canvas, size, fill, stroke);
    } else if (key.contains('circuit')) {
      _circuit(canvas, size, fill, stroke);
    } else if (key.contains('brain')) {
      _brain(canvas, size, fill, stroke);
    } else if (key.contains('beaker') || key.contains('flask')) {
      _beaker(canvas, size, fill, stroke);
    } else if (key.contains('bridge')) {
      _bridge(canvas, size, fill, stroke);
    } else if (key.contains('network') || key.contains('graph')) {
      _network(canvas, size, fill, stroke);
    } else if (key.contains('dna')) {
      _dna(canvas, size, fill, stroke);
    } else {
      _body(canvas, size, fill, stroke);
    }

    // Grid faint
    final Paint grid = Paint()..color = Colors.white.withValues(alpha: 0.03);
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  void _heart(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Path p = Path();
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.42;
    final double s = size.shortestSide * 0.28;
    p.moveTo(cx, cy + s * 0.85);
    p.cubicTo(cx + s * 1.2, cy - s * 0.1, cx + s * 0.85, cy - s * 1.1, cx, cy - s * 0.35);
    p.cubicTo(cx - s * 0.85, cy - s * 1.1, cx - s * 1.2, cy - s * 0.1, cx, cy + s * 0.85);
    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);
  }

  void _cell(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.48);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: size.width * 0.55, height: size.height * 0.5),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: size.width * 0.55, height: size.height * 0.5),
      stroke,
    );
    canvas.drawCircle(c, size.shortestSide * 0.08, fill);
    canvas.drawCircle(c, size.shortestSide * 0.08, stroke);
  }

  void _circuit(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Path p = Path()
      ..moveTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.3)
      ..lineTo(size.width * 0.55, size.height * 0.3)
      ..lineTo(size.width * 0.55, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..lineTo(size.width * 0.88, size.height * 0.5);
    canvas.drawPath(p, stroke);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.5),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      fill,
    );
  }

  void _brain(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.45);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: size.width * 0.5, height: size.height * 0.42),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: size.width * 0.5, height: size.height * 0.42),
      stroke,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - size.height * 0.18),
      Offset(c.dx, c.dy + size.height * 0.18),
      stroke,
    );
  }

  void _beaker(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Path p = Path()
      ..moveTo(size.width * 0.32, size.height * 0.2)
      ..lineTo(size.width * 0.32, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.88,
        size.width * 0.68,
        size.height * 0.72,
      )
      ..lineTo(size.width * 0.68, size.height * 0.2);
    canvas.drawPath(p, fill);
    canvas.drawPath(p, stroke);
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.55),
      Offset(size.width * 0.66, size.height * 0.55),
      stroke..strokeWidth = 1.5,
    );
  }

  void _bridge(Canvas canvas, Size size, Paint fill, Paint stroke) {
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.65),
      Offset(size.width * 0.9, size.height * 0.65),
      stroke,
    );
    final Path arch = Path()
      ..moveTo(size.width * 0.2, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.25,
        size.width * 0.8,
        size.height * 0.65,
      );
    canvas.drawPath(arch, stroke);
    for (final double x in <double>[0.3, 0.5, 0.7]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.65),
        Offset(size.width * x, size.height * (0.65 - 0.25 * math.sin(x * math.pi))),
        stroke,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.65, size.width * 0.7, size.height * 0.04),
      fill,
    );
  }

  void _network(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final List<Offset> nodes = <Offset>[
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.55),
      Offset(size.width * 0.4, size.height * 0.78),
      Offset(size.width * 0.65, size.height * 0.78),
    ];
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        canvas.drawLine(nodes[i], nodes[j], stroke..strokeWidth = 1.2);
      }
    }
    for (final Offset n in nodes) {
      canvas.drawCircle(n, 10, fill);
      canvas.drawCircle(n, 10, stroke);
    }
  }

  void _dna(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final Path a = Path();
    final Path b = Path();
    for (double t = 0; t <= 1; t += 0.02) {
      final double y = size.height * (0.15 + t * 0.7);
      final double x1 = size.width * 0.5 + math.sin(t * math.pi * 4) * size.width * 0.18;
      final double x2 = size.width * 0.5 - math.sin(t * math.pi * 4) * size.width * 0.18;
      if (t == 0) {
        a.moveTo(x1, y);
        b.moveTo(x2, y);
      } else {
        a.lineTo(x1, y);
        b.lineTo(x2, y);
      }
      if ((t * 20).round() % 2 == 0) {
        canvas.drawLine(Offset(x1, y), Offset(x2, y), stroke..strokeWidth = 1);
      }
    }
    canvas.drawPath(a, stroke);
    canvas.drawPath(b, stroke);
  }

  void _body(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final double cx = size.width * 0.5;
    canvas.drawCircle(Offset(cx, size.height * 0.22), size.shortestSide * 0.07, fill);
    canvas.drawCircle(Offset(cx, size.height * 0.22), size.shortestSide * 0.07, stroke);
    final Path torso = Path()
      ..moveTo(cx - size.width * 0.12, size.height * 0.32)
      ..lineTo(cx + size.width * 0.12, size.height * 0.32)
      ..lineTo(cx + size.width * 0.1, size.height * 0.62)
      ..lineTo(cx - size.width * 0.1, size.height * 0.62)
      ..close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, stroke);
    canvas.drawLine(
      Offset(cx - size.width * 0.12, size.height * 0.38),
      Offset(cx - size.width * 0.28, size.height * 0.55),
      stroke,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.12, size.height * 0.38),
      Offset(cx + size.width * 0.28, size.height * 0.55),
      stroke,
    );
    canvas.drawLine(
      Offset(cx - size.width * 0.06, size.height * 0.62),
      Offset(cx - size.width * 0.1, size.height * 0.85),
      stroke,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.06, size.height * 0.62),
      Offset(cx + size.width * 0.1, size.height * 0.85),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant DiagramSilhouettePainter oldDelegate) =>
      oldDelegate.title != title || oldDelegate.accent != accent;
}
