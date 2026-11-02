import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ScienceHeroKind {
  microscope,
  cell,
  dna,
  heart,
  ecology,
  flasks,
  titration,
  molecules,
  cannon,
  circuit,
  waves,
  optics,
  notebook,
  quest,
}

/// Full-bleed painted lab set for the hub stage.
class ScienceHeroScene extends StatelessWidget {
  const ScienceHeroScene({
    super.key,
    required this.kind,
    required this.accent,
  });

  final ScienceHeroKind kind;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeroPainter(kind: kind, accent: accent),
      child: const SizedBox.expand(),
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter({required this.kind, required this.accent});

  final ScienceHeroKind kind;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    final Paint bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          const Color(0xFF0B1220),
          Color.lerp(const Color(0xFF0B1220), accent, 0.18)!,
          const Color(0xFF05080F),
        ],
      ).createShader(r);
    canvas.drawRect(r, bg);

    // Floor glow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.88),
        width: size.width * 0.7,
        height: size.height * 0.12,
      ),
      Paint()..color = accent.withValues(alpha: 0.12),
    );

    switch (kind) {
      case ScienceHeroKind.microscope:
        _microscope(canvas, size);
      case ScienceHeroKind.cell:
        _cell(canvas, size);
      case ScienceHeroKind.dna:
        _dna(canvas, size);
      case ScienceHeroKind.heart:
        _heart(canvas, size);
      case ScienceHeroKind.ecology:
        _ecology(canvas, size);
      case ScienceHeroKind.flasks:
        _flasks(canvas, size);
      case ScienceHeroKind.titration:
        _titration(canvas, size);
      case ScienceHeroKind.molecules:
        _molecules(canvas, size);
      case ScienceHeroKind.cannon:
        _cannon(canvas, size);
      case ScienceHeroKind.circuit:
        _circuit(canvas, size);
      case ScienceHeroKind.waves:
        _waves(canvas, size);
      case ScienceHeroKind.optics:
        _optics(canvas, size);
      case ScienceHeroKind.notebook:
        _notebook(canvas, size);
      case ScienceHeroKind.quest:
        _quest(canvas, size);
    }
  }

  void _microscope(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.48, size.height * 0.58);
    final Paint metal = Paint()..color = const Color(0xFF94A3B8);
    final Paint dark = Paint()..color = const Color(0xFF1E293B);
    final Paint gold = Paint()..color = accent;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(0, 90), width: 160, height: 28),
        const Radius.circular(8),
      ),
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(-20, 40), width: 36, height: 110),
        const Radius.circular(8),
      ),
      metal,
    );
    // Arm
    final Path arm = Path()
      ..moveTo(c.dx - 10, c.dy + 20)
      ..quadraticBezierTo(c.dx + 70, c.dy - 10, c.dx + 40, c.dy - 90);
    canvas.drawPath(
      arm,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );
    // Eyepiece
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(40, -108), width: 28, height: 46),
        const Radius.circular(6),
      ),
      gold,
    );
    // Stage
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + const Offset(18, -8), width: 90, height: 14),
        const Radius.circular(4),
      ),
      dark,
    );
    canvas.drawCircle(c + const Offset(18, -8), 16, Paint()..color = const Color(0xFFFB7185).withValues(alpha: 0.7));
    // Light
    canvas.drawCircle(
      c + const Offset(18, 28),
      10,
      Paint()..color = const Color(0xFFFDE68A),
    );
  }

  void _cell(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.52);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 260, height: 200),
      Paint()..color = const Color(0xFF166534).withValues(alpha: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 260, height: 200),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawCircle(c + const Offset(-10, -8), 42, Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.7));
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(-70, 30), width: 44, height: 22),
      Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.8),
    );
    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        c + Offset(math.cos(i * .7) * 70, math.sin(i * .9) * 50),
        4,
        Paint()..color = Colors.white70,
      );
    }
  }

  void _dna(Canvas canvas, Size size) {
    final Paint a = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final Paint b = Paint()
      ..color = const Color(0xFF60A5FA)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final Path p1 = Path();
    final Path p2 = Path();
    for (int i = 0; i < 40; i++) {
      final double t = i / 39;
      final double x = size.width * 0.35 + t * size.width * 0.3;
      final double y1 = size.height * 0.2 + math.sin(t * 10) * 40 + t * size.height * 0.55;
      final double y2 = size.height * 0.2 + math.sin(t * 10 + math.pi) * 40 + t * size.height * 0.55;
      if (i == 0) {
        p1.moveTo(x, y1);
        p2.moveTo(x, y2);
      } else {
        p1.lineTo(x, y1);
        p2.lineTo(x, y2);
      }
      if (i % 3 == 0) {
        canvas.drawLine(Offset(x, y1), Offset(x, y2), Paint()..color = Colors.white24..strokeWidth = 2);
      }
    }
    canvas.drawPath(p1, a);
    canvas.drawPath(p2, b);
  }

  void _heart(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.5);
    final Path h = Path()
      ..moveTo(c.dx, c.dy + 70)
      ..cubicTo(c.dx - 140, c.dy + 10, c.dx - 90, c.dy - 90, c.dx, c.dy - 30)
      ..cubicTo(c.dx + 90, c.dy - 90, c.dx + 140, c.dy + 10, c.dx, c.dy + 70);
    canvas.drawPath(h, Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.85));
    canvas.drawPath(
      h,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _ecology(Canvas canvas, Size size) {
    final Paint ground = Paint()..color = const Color(0xFF14532D);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28), ground);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.22), 36, Paint()..color = const Color(0xFFFDE68A));
    for (final double x in <double>[0.2, 0.32, 0.45, 0.58]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * x, size.height * 0.5, 10, size.height * 0.22),
        Paint()..color = const Color(0xFF78350F),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * x + 5, size.height * 0.48),
          width: 54,
          height: 70,
        ),
        Paint()..color = accent.withValues(alpha: 0.85),
      );
    }
  }

  void _flasks(Canvas canvas, Size size) {
    _drawFlask(canvas, Offset(size.width * 0.32, size.height * 0.55), const Color(0xFF38BDF8), 1);
    _drawFlask(canvas, Offset(size.width * 0.52, size.height * 0.5), const Color(0xFFFB7185), 1.15);
    _drawFlask(canvas, Offset(size.width * 0.7, size.height * 0.58), const Color(0xFFA3E635), 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, size.height * 0.78, size.width * 0.64, 18),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF334155),
    );
  }

  void _drawFlask(Canvas canvas, Offset c, Color liquid, double s) {
    final Path p = Path()
      ..moveTo(c.dx - 14 * s, c.dy - 70 * s)
      ..lineTo(c.dx + 14 * s, c.dy - 70 * s)
      ..lineTo(c.dx + 14 * s, c.dy - 20 * s)
      ..lineTo(c.dx + 40 * s, c.dy + 50 * s)
      ..lineTo(c.dx - 40 * s, c.dy + 50 * s)
      ..lineTo(c.dx - 14 * s, c.dy - 20 * s)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white.withValues(alpha: 0.12));
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      Rect.fromLTWH(c.dx - 32 * s, c.dy + 10 * s, 64 * s, 40 * s),
      Paint()..color = liquid.withValues(alpha: 0.7),
    );
  }

  void _titration(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 18, height: 160),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white24,
    );
    canvas.drawRect(
      Rect.fromCenter(center: c + const Offset(0, 20), width: 14, height: 90),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.55),
    );
    _drawFlask(canvas, c + const Offset(0, 120), const Color(0xFFF9A8D4), 0.85);
  }

  void _molecules(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(c, 28, Paint()..color = const Color(0xFF334155));
    _atom(canvas, c, 'C');
    for (int i = 0; i < 4; i++) {
      final double a = i * math.pi / 2 + 0.4;
      final Offset p = c + Offset(math.cos(a) * 70, math.sin(a) * 70);
      canvas.drawLine(c, p, Paint()..color = Colors.white54..strokeWidth = 4);
      canvas.drawCircle(p, 18, Paint()..color = const Color(0xFFE2E8F0));
      _atom(canvas, p, 'H', dark: true);
    }
  }

  void _atom(Canvas canvas, Offset c, String s, {bool dark = false}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: dark ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  void _cannon(Canvas canvas, Size size) {
    final Paint dirt = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28), dirt);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.7), 28, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.16, size.height * 0.52, 90, 22),
      Paint()..color = const Color(0xFF64748B),
    );
    final Path arc = Path();
    for (int i = 0; i < 24; i++) {
      final double t = i / 23;
      final double x = size.width * 0.22 + t * size.width * 0.55;
      final double y = size.height * 0.52 - math.sin(t * math.pi) * size.height * 0.32;
      if (i == 0) {
        arc.moveTo(x, y);
      } else {
        arc.lineTo(x, y);
      }
    }
    canvas.drawPath(
      arc,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.7), 16, Paint()..color = const Color(0xFFF87171));
  }

  void _circuit(Canvas canvas, Size size) {
    final Paint wire = Paint()
      ..color = accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final Rect box = Rect.fromLTWH(size.width * 0.22, size.height * 0.28, size.width * 0.56, size.height * 0.42);
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(8)), wire);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.49), 22, Paint()..color = const Color(0xFFFDE68A));
  }

  void _waves(Canvas canvas, Size size) {
    final Path p = Path();
    for (int i = 0; i < 80; i++) {
      final double t = i / 79;
      final double x = size.width * 0.1 + t * size.width * 0.8;
      final double y = size.height * 0.5 + math.sin(t * 12) * 40;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    canvas.drawPath(
      p,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _optics(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.5), 14, Paint()..color = const Color(0xFFFDE68A));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: 28, height: 90),
      Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.5),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width * 0.78, size.height * 0.5), width: 8, height: 80),
      Paint()..color = Colors.white54,
    );
  }

  void _notebook(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: 180, height: 230),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(size.width * 0.38, size.height * 0.34 + i * 18),
        Offset(size.width * 0.62, size.height * 0.34 + i * 18),
        Paint()..color = Colors.black26..strokeWidth = 1.5,
      );
    }
  }

  void _quest(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), 54, Paint()..color = accent.withValues(alpha: 0.2));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), 40, Paint()..color = accent);
    final TextPainter tp = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 42),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width * 0.5 - tp.width / 2, size.height * 0.48 - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _HeroPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.accent != accent;
}
