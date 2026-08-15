import 'package:flutter/material.dart';

import '../../data/physics/physics_lab_engine.dart';
import '../../models/physics/physics_lab_models.dart';
import '../../theme/physics_theme.dart';

/// Paints projectile trajectory and lab scene backdrop.
class PhysicsSimulationCanvas extends StatelessWidget {
  const PhysicsSimulationCanvas({
    super.key,
    required this.kind,
    required this.snapshot,
    required this.launched,
    this.sceneLabel,
  });

  final PhysicsSimulationKind kind;
  final PhysicsLabSnapshot snapshot;
  final bool launched;
  final String? sceneLabel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        decoration: BoxDecoration(
          color: PhysicsTheme.consolePanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PhysicsTheme.consoleBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _SimulationPainter(
            kind: kind,
            trajectory: snapshot.trajectory,
            launched: launched,
            statusLevel: snapshot.statusLevel,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                sceneLabel ?? kind.label,
                style: const TextStyle(
                  color: PhysicsTheme.consoleMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimulationPainter extends CustomPainter {
  _SimulationPainter({
    required this.kind,
    required this.trajectory,
    required this.launched,
    required this.statusLevel,
  });

  final PhysicsSimulationKind kind;
  final List<Offset2D> trajectory;
  final bool launched;
  final PhysicsStatusLevel statusLevel;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawGround(canvas, size);

    switch (kind) {
      case PhysicsSimulationKind.circuit:
        _drawCircuit(canvas, size);
      case PhysicsSimulationKind.gravityPlanet:
        _drawPlanet(canvas, size);
      case PhysicsSimulationKind.rocket:
      case PhysicsSimulationKind.forceThrust:
        _drawRocket(canvas, size);
      case PhysicsSimulationKind.optics:
        _drawOptics(canvas, size);
      case PhysicsSimulationKind.motionTracking:
        _drawMotionTrack(canvas, size);
      case PhysicsSimulationKind.acceleration:
        _drawVehicle(canvas, size);
      case PhysicsSimulationKind.energyCoaster:
        _drawCoaster(canvas, size);
      default:
        if (launched && trajectory.isNotEmpty) {
          _drawTrajectory(canvas, size);
        } else {
          _drawLauncher(canvas, size);
        }
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final Rect sky = Rect.fromLTWH(0, 0, size.width, size.height * 0.72);
    final Paint grad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF0F172A), Color(0xFF1E293B)],
      ).createShader(sky);
    canvas.drawRect(sky, grad);
  }

  void _drawGround(Canvas canvas, Size size) {
    final double y = size.height * 0.72;
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, size.height - y),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()..color = PhysicsTheme.consoleAccent..strokeWidth = 1.5);
  }

  void _drawLauncher(Canvas canvas, Size size) {
    final double ground = size.height * 0.72;
    final Offset base = Offset(size.width * 0.12, ground);
    final Path cannon = Path()
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx + 40, base.dy - 8)
      ..lineTo(base.dx + 55, base.dy - 18)
      ..lineTo(base.dx + 10, base.dy - 14)
      ..close();
    canvas.drawPath(cannon, Paint()..color = PhysicsTheme.consoleAccent);
    canvas.drawCircle(Offset(base.dx + 58, base.dy - 18), 4, Paint()..color = const Color(0xFFFBBF24));
  }

  void _drawTrajectory(Canvas canvas, Size size) {
    if (trajectory.isEmpty) return;
    double maxX = trajectory.last.x;
    double maxY = trajectory.map((Offset2D p) => p.y).reduce((double a, double b) => a > b ? a : b);
    maxX = maxX <= 0 ? 1 : maxX;
    maxY = maxY <= 0 ? 1 : maxY;

    final double ground = size.height * 0.72;
    final double scaleX = (size.width * 0.85) / maxX;
    final double scaleY = (ground * 0.85) / maxY;
    final double ox = size.width * 0.08;
    final Path path = Path();
    for (int i = 0; i < trajectory.length; i++) {
      final Offset2D p = trajectory[i];
      final double x = ox + p.x * scaleX;
      final double y = ground - p.y * scaleY;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final Color trail = statusLevel == PhysicsStatusLevel.good
        ? PhysicsTheme.consoleGood
        : statusLevel == PhysicsStatusLevel.danger
            ? PhysicsTheme.consoleBad
            : PhysicsTheme.consoleAccent;
    canvas.drawPath(path, Paint()..color = trail..strokeWidth = 3..style = PaintingStyle.stroke);
    final Offset2D last = trajectory.last;
    canvas.drawCircle(
      Offset(ox + last.x * scaleX, ground - last.y * scaleY),
      7,
      Paint()..color = const Color(0xFFF97316),
    );
  }

  void _drawPlanet(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.45);
    canvas.drawCircle(c, size.width * 0.22, Paint()..color = const Color(0xFF3B82F6));
    canvas.drawCircle(c.translate(-20, -15), size.width * 0.05, Paint()..color = const Color(0xFF60A5FA));
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.72 - 20),
      8,
      Paint()..color = const Color(0xFFFCD34D),
    );
  }

  void _drawCircuit(Canvas canvas, Size size) {
    final double y = size.height * 0.45;
    final Paint wire = Paint()
      ..color = PhysicsTheme.consoleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.15, y), Offset(size.width * 0.35, y), wire);
    canvas.drawLine(Offset(size.width * 0.35, y), Offset(size.width * 0.35, y + 40), wire);
    canvas.drawLine(Offset(size.width * 0.35, y + 40), Offset(size.width * 0.55, y + 40), wire);
    canvas.drawLine(Offset(size.width * 0.55, y + 40), Offset(size.width * 0.55, y), wire);
    canvas.drawLine(Offset(size.width * 0.55, y), Offset(size.width * 0.75, y), wire);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width * 0.45, y + 40), width: 30, height: 18),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(Offset(size.width * 0.65, y), 10, Paint()..color = const Color(0xFF34D399));
  }

  void _drawRocket(Canvas canvas, Size size) {
    final Offset base = Offset(size.width * 0.5, size.height * 0.72);
    final Path rocket = Path()
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx - 12, base.dy)
      ..lineTo(base.dx, base.dy - 70)
      ..lineTo(base.dx + 12, base.dy)
      ..close();
    canvas.drawPath(rocket, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - 8, base.dy)
        ..lineTo(base.dx, base.dy + 25)
        ..lineTo(base.dx + 8, base.dy),
      Paint()..color = const Color(0xFFF97316),
    );
  }

  void _drawOptics(Canvas canvas, Size size) {
    final double y = size.height * 0.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.35, y), width: 18, height: 50),
      Paint()..color = const Color(0xFF93C5FD)..style = PaintingStyle.stroke..strokeWidth = 3,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.65, y), width: 12, height: 30),
      Paint()..color = const Color(0xFF93C5FD)..style = PaintingStyle.stroke..strokeWidth = 3,
    );
    canvas.drawLine(Offset(size.width * 0.1, y), Offset(size.width * 0.9, y - 20), Paint()..color = const Color(0xFFFBBF24)..strokeWidth = 2);
  }

  void _drawMotionTrack(Canvas canvas, Size size) {
    final double ground = size.height * 0.72;
    final double trackY = ground - 6;
    canvas.drawLine(
      Offset(size.width * 0.05, trackY),
      Offset(size.width * 0.95, trackY),
      Paint()..color = PhysicsTheme.consoleAccent..strokeWidth = 4,
    );
    for (double x = size.width * 0.1; x < size.width * 0.9; x += size.width * 0.12) {
      canvas.drawLine(Offset(x, trackY), Offset(x, trackY - 12), Paint()..color = PhysicsTheme.consoleMuted..strokeWidth = 1);
    }
    final double carX = launched && trajectory.isNotEmpty
        ? size.width * (0.08 + trajectory.last.x.clamp(0, 1) * 0.84)
        : size.width * 0.08;
    final RRect car = RRect.fromRectAndRadius(
      Rect.fromLTWH(carX, trackY - 28, 44, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(car, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(carX + 10, trackY - 4), 6, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(carX + 34, trackY - 4), 6, Paint()..color = const Color(0xFF1E293B));
    if (launched) {
      canvas.drawLine(
        Offset(carX + 50, trackY - 18),
        Offset(carX + 90, trackY - 18),
        Paint()..color = PhysicsTheme.consoleGood..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(carX + 90, trackY - 18),
        Offset(carX + 82, trackY - 24),
        Paint()..color = PhysicsTheme.consoleGood..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(carX + 90, trackY - 18),
        Offset(carX + 82, trackY - 12),
        Paint()..color = PhysicsTheme.consoleGood..strokeWidth = 2,
      );
    }
  }

  void _drawVehicle(Canvas canvas, Size size) {
    final double ground = size.height * 0.72;
    final double carX = launched ? size.width * 0.55 : size.width * 0.15;
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(carX, ground - 34, 70, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFF3B82F6));
    canvas.drawCircle(Offset(carX + 16, ground - 6), 8, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(carX + 54, ground - 6), 8, Paint()..color = const Color(0xFF0F172A));
    canvas.drawLine(
      Offset(size.width * 0.05, ground),
      Offset(size.width * 0.95, ground),
      Paint()..color = const Color(0xFF64748B)..strokeWidth = 3,
    );
  }

  void _drawCoaster(Canvas canvas, Size size) {
    final double ground = size.height * 0.72;
    final Path track = Path()
      ..moveTo(size.width * 0.05, ground - 20)
      ..quadraticBezierTo(size.width * 0.25, ground - 120, size.width * 0.45, ground - 30)
      ..quadraticBezierTo(size.width * 0.65, ground - 10, size.width * 0.85, ground - 50);
    canvas.drawPath(
      track,
      Paint()
        ..color = PhysicsTheme.consoleAccent
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
    final double cartX = launched ? size.width * 0.72 : size.width * 0.08;
    final double cartY = launched ? ground - 55 : ground - 35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cartX, cartY, 36, 16), const Radius.circular(4)),
      Paint()..color = const Color(0xFFF97316),
    );
  }

  @override
  bool shouldRepaint(covariant _SimulationPainter old) =>
      old.launched != launched || old.trajectory != trajectory || old.kind != kind;
}

/// Simple line chart for height/time and velocity/time.
class PhysicsMiniChart extends StatelessWidget {
  const PhysicsMiniChart({super.key, required this.series});

  final PhysicsGraphSeries series;

  @override
  Widget build(BuildContext context) {
    if (series.points.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: PhysicsTheme.consolePanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PhysicsTheme.consoleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(series.label, style: const TextStyle(color: PhysicsTheme.consoleText, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Text('${series.xLabel} → ${series.yLabel}', style: const TextStyle(color: PhysicsTheme.consoleMuted, fontSize: 10)),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(series: series),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.series});

  final PhysicsGraphSeries series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.points.isEmpty) return;
    final double maxX = series.points.last.t <= 0 ? 1 : series.points.last.t;
    double maxY = series.points.map((PhysicsGraphPoint p) => p.y).reduce((double a, double b) => a > b ? a : b);
    double minY = series.points.map((PhysicsGraphPoint p) => p.y).reduce((double a, double b) => a < b ? a : b);
    if ((maxY - minY).abs() < 0.01) {
      maxY += 1;
      minY -= 1;
    }

    final Path path = Path();
    for (int i = 0; i < series.points.length; i++) {
      final PhysicsGraphPoint p = series.points[i];
      final double x = (p.t / maxX) * (size.width - 8) + 4;
      final double y = size.height - 4 - ((p.y - minY) / (maxY - minY)) * (size.height - 8);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = PhysicsTheme.consoleAccent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.series != series;
}
