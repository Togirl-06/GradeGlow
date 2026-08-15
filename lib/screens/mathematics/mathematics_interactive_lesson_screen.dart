import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mathematics_degree_catalog.dart';
import '../../models/mathematics_degree.dart';
import '../../theme/mathematics_degree_theme.dart';

class MathematicsInteractiveLessonScreen extends StatefulWidget {
  const MathematicsInteractiveLessonScreen({super.key, required this.path});

  final MathematicsLessonPath path;

  @override
  State<MathematicsInteractiveLessonScreen> createState() =>
      _MathematicsInteractiveLessonScreenState();
}

class _MathematicsInteractiveLessonScreenState
    extends State<MathematicsInteractiveLessonScreen> {
  double _x = 1.0;
  String _reflection = '';

  bool get _isLimits => MathematicsDegreeCatalog.isLimitsLesson(widget.path);
  bool get _isDerivatives =>
      MathematicsDegreeCatalog.isDerivativeLesson(widget.path);

  double get _fx {
    if (_isLimits || _isDerivatives) return _x * _x;
    return math.sin(_x);
  }

  String get _prompt {
    if (_isLimits) {
      return 'What do you notice happens to f(x) = x² as x approaches 2?';
    }
    if (_isDerivatives) {
      return 'As x moves, watch how the slope of the tangent changes on f(x) = x².';
    }
    return 'Explore how ${widget.path.lesson.title} behaves as you change x.';
  }

  String get _observation {
    if (_isLimits) {
      final double near = (2 - _x).abs();
      if (near < 0.05) {
        return 'As x → 2, f(x) → ${(_x * _x).toStringAsFixed(2)}. The limit is 4!';
      }
      if (_x < 2) {
        return 'From the left, values are approaching 4.';
      }
      return 'From the right, values are approaching 4.';
    }
    if (_isDerivatives) {
      final double slope = 2 * _x;
      return 'At x = ${_x.toStringAsFixed(2)}, slope ≈ ${slope.toStringAsFixed(2)} '
          '(since d/dx[x²] = 2x).';
    }
    return 'f(${_x.toStringAsFixed(2)}) = ${_fx.toStringAsFixed(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interactive Lesson',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            widget.path.lesson.title,
            style: TextStyle(
              color: c.primary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _prompt,
            style: TextStyle(
              color: c.textPrimary.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 220,
            padding: const EdgeInsets.all(12),
            decoration: c.cardDecoration(),
            child: CustomPaint(
              painter: _GraphPainter(
                x: _x,
                isLimits: _isLimits,
                target: 2.0,
                primary: c.primary,
                success: c.success,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Move x',
            style: TextStyle(
              color: c.textPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
            ),
          ),
          Slider(
            value: _x,
            min: _isLimits ? 0.5 : -3,
            max: _isLimits ? 3.5 : 3,
            activeColor: c.primary,
            inactiveColor: Colors.white24,
            onChanged: (double v) => setState(() => _x = v),
          ),
          Text(
            'x = ${_x.toStringAsFixed(2)}  ·  f(x) = ${_fx.toStringAsFixed(3)}',
            style: TextStyle(
              color: c.primaryLight,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: c.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              _observation,
              style: TextStyle(
                color: c.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (String v) => setState(() => _reflection = v),
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              labelText: 'Your observation',
              labelStyle: TextStyle(color: c.textPrimary.withValues(alpha: 0.7)),
              hintText: 'Write what you notice…',
              hintStyle: TextStyle(color: c.textPrimary.withValues(alpha: 0.4)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.primary.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: c.primary),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _reflection.trim().length >= 8
                ? () => Navigator.of(context).pop()
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Complete Interactive Lesson',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.x,
    required this.isLimits,
    required this.target,
    required this.primary,
    required this.success,
  });

  final double x;
  final bool isLimits;
  final double target;
  final Color primary;
  final Color success;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1;
    final Paint curve = Paint()
      ..color = primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final Paint dot = Paint()..color = primary;

    final double midY = size.height * 0.55;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axis);
    canvas.drawLine(Offset(size.width * 0.1, 0), Offset(size.width * 0.1, size.height), axis);

    final Path path = Path();
    for (double px = 0; px <= size.width; px += 2) {
      final double t = (px / size.width) * 6 - 1;
      final double fy = t * t;
      final double py = midY - fy * 8;
      if (px == 0) {
        path.moveTo(px + size.width * 0.1, py);
      } else {
        path.lineTo(px + size.width * 0.1, py);
      }
    }
    canvas.drawPath(path, curve);

    final double px = size.width * 0.1 + ((x + 1) / 6) * size.width;
    final double py = midY - (x * x) * 8;
    canvas.drawCircle(Offset(px, py), 7, dot);

    if (isLimits) {
      final double tx = size.width * 0.1 + ((target + 1) / 6) * size.width;
      final Paint targetPaint = Paint()
        ..color = success.withValues(alpha: 0.8)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(tx, midY - 80),
        Offset(tx, midY + 40),
        targetPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.x != x || old.isLimits != isLimits;
}
