import 'package:flutter/material.dart';

import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Student plots points and interprets the chart.
class VisualGraphLabScreen extends StatefulWidget {
  const VisualGraphLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualGraphLabScreen> createState() => _VisualGraphLabScreenState();
}

class _VisualGraphLabScreenState extends State<VisualGraphLabScreen> {
  final List<Offset> _points = <Offset>[];
  final TextEditingController _interp = TextEditingController();
  late String _xLabel;
  late String _yLabel;

  VisualLabSpec get spec => widget.spec;
  GraphScenario get scenario =>
      spec.graph ??
      const GraphScenario(
        xLabel: 'X',
        yLabel: 'Y',
        expectedPoints: <Offset>[Offset(0.2, 0.3), Offset(0.5, 0.5), Offset(0.8, 0.75)],
        interpretKeywords: <String>['increase', 'linear'],
      );

  @override
  void initState() {
    super.initState();
    _xLabel = scenario.xLabel;
    _yLabel = scenario.yLabel;
  }

  @override
  void dispose() {
    _interp.dispose();
    super.dispose();
  }

  bool get _pointsOk {
    if (_points.length < scenario.expectedPoints.length) return false;
    // Each expected point must have a nearby student point.
    for (final Offset e in scenario.expectedPoints) {
      bool found = false;
      for (final Offset p in _points) {
        final double dx = (p.dx - e.dx).abs() * 100;
        final double dy = (p.dy - e.dy).abs() * 100;
        if (dx <= scenario.pointTolerance && dy <= scenario.pointTolerance) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final bool textOk = keywordsMatch(_interp.text, scenario.interpretKeywords);
    final bool passed = _pointsOk && textOk;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: passed,
      body: passed
          ? 'Graph and interpretation match the expected trend.'
          : 'Plot closer to the expected data and describe the trend with key terms.',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return VisualLabShell(
      spec: spec,
      badgeLabel: 'GRAPH',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: 'SUBMIT GRAPH',
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _labelField('X axis', _xLabel, (String v) => _xLabel = v),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _labelField('Y axis', _yLabel, (String v) => _yLabel = v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scenario.prompt,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    return GestureDetector(
                      onTapDown: (TapDownDetails d) {
                        setState(() {
                          _points.add(
                            Offset(
                              (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0),
                              (d.localPosition.dy / c.maxHeight).clamp(0.0, 1.0),
                            ),
                          );
                        });
                      },
                      child: CustomPaint(
                        painter: _ChartPainter(
                          points: _points,
                          expected: scenario.expectedPoints,
                          accent: spec.accent,
                          xLabel: _xLabel,
                          yLabel: _yLabel,
                          showGuide: true,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => setState(_points.clear),
                  child: Text('Clear', style: TextStyle(color: spec.accent)),
                ),
                Text(
                  '${_points.length} pts',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                ),
              ],
            ),
            TextField(
              controller: _interp,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Interpret the trend…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelField(String label, String value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
        filled: true,
        fillColor: Colors.black38,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
    required this.expected,
    required this.accent,
    required this.xLabel,
    required this.yLabel,
    this.showGuide = false,
  });

  final List<Offset> points;
  final List<Offset> expected;
  final Color accent;
  final String xLabel;
  final String yLabel;
  final bool showGuide;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.2;
    const double pad = 28;
    canvas.drawLine(Offset(pad, size.height - pad), Offset(size.width - 12, size.height - pad), axis);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad, 12), axis);

    Offset map(Offset n) => Offset(
          pad + n.dx * (size.width - pad - 12),
          pad + n.dy * (size.height - pad - 12),
        );

    if (showGuide && expected.isNotEmpty) {
      final Paint ghost = Paint()
        ..color = accent.withValues(alpha: 0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final Path g = Path();
      for (int i = 0; i < expected.length; i++) {
        final Offset o = map(expected[i]);
        if (i == 0) {
          g.moveTo(o.dx, o.dy);
        } else {
          g.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(g, ghost);
    }

    if (points.length >= 2) {
      final Path line = Path();
      for (int i = 0; i < points.length; i++) {
        final Offset o = map(points[i]);
        if (i == 0) {
          line.moveTo(o.dx, o.dy);
        } else {
          line.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = accent
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );
    }
    for (final Offset p in points) {
      canvas.drawCircle(map(p), 5, Paint()..color = accent);
    }

    final TextPainter xp = TextPainter(
      text: TextSpan(text: xLabel, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    xp.paint(canvas, Offset(size.width / 2 - xp.width / 2, size.height - 18));
    final TextPainter yp = TextPainter(
      text: TextSpan(text: yLabel, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(4, size.height / 2 + yp.width / 2);
    canvas.rotate(-1.5708);
    yp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.xLabel != xLabel;
}
