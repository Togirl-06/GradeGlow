import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hospital_engine.dart';
import '../hospital_models.dart';

/// Global switch so widget tests can turn off the endless monitor animation.
abstract final class HospitalUi {
  static bool animate = true;
}

/// A patient in bed: skin, hair, age, gown, and visible distress (pallor,
/// cyanosis, sweat, a pained or drowsy face) driven by the live vital signs.
class PatientPainter extends CustomPainter {
  PatientPainter(this.a, this.v, {this.distress = 0});
  final Appearance a;
  final Vitals v;

  /// 0 (comfortable) … 1 (very unwell).
  final double distress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()..isAntiAlias = true;
    // Bed frame and mattress.
    p.color = const Color(0xFF90A4AE);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.55, w * 0.88, h * 0.12), const Radius.circular(6)), p);
    p.color = const Color(0xFF607D8B);
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.67, w * 0.03, h * 0.28), p);
    canvas.drawRect(Rect.fromLTWH(w * 0.89, h * 0.67, w * 0.03, h * 0.28), p);
    // Pillow.
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.38, w * 0.26, h * 0.2), const Radius.circular(14)), p);
    // Body under the blanket.
    p.color = a.gown;
    final double scale = a.child ? 0.7 : 1;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * (0.42 + (1 - scale) * 0.08), w * 0.42 * scale, h * 0.16 * scale), const Radius.circular(18)), p);
    p.color = const Color(0xFFDCE7F0);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.44, w * 0.5, h * 0.16), const Radius.circular(10)), p);
    // Head.
    Color skin = a.skin;
    if (v.spo2 < 88) skin = Color.lerp(skin, const Color(0xFF7986CB), 0.35)!;
    if (v.sbp < 90) skin = Color.lerp(skin, const Color(0xFFE0E0E0), 0.35)!;
    final double r = h * 0.12 * (a.child ? 0.85 : 1);
    final Offset head = Offset(w * 0.2, h * 0.4);
    p.color = skin;
    canvas.drawCircle(head, r, p);
    // Hair.
    final Color hair = a.grey ? Color.lerp(a.hair, const Color(0xFFE0E0E0), 0.7)! : a.hair;
    p.color = hair;
    switch (a.style) {
      case HairStyle.bald:
        break;
      case HairStyle.short:
        canvas.drawArc(Rect.fromCircle(center: head, radius: r * 1.02), math.pi * 1.05, math.pi * 0.9, true, p);
      case HairStyle.long:
        canvas.drawArc(Rect.fromCircle(center: head, radius: r * 1.08), math.pi * 0.85, math.pi * 1.3, true, p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(head.dx - r * 1.1, head.dy - r * 0.2, r * 0.45, r * 1.5), const Radius.circular(8)), p);
      case HairStyle.bun:
        canvas.drawArc(Rect.fromCircle(center: head, radius: r * 1.02), math.pi * 1.05, math.pi * 0.9, true, p);
        canvas.drawCircle(head.translate(-r * 0.9, -r * 0.6), r * 0.38, p);
      case HairStyle.curly:
        for (int i = 0; i < 7; i++) {
          final double t = math.pi * (1.05 + i * 0.15);
          canvas.drawCircle(head + Offset(math.cos(t), math.sin(t)) * r * 0.95, r * 0.3, p);
        }
    }
    if (a.beard) {
      p.color = hair;
      canvas.drawArc(Rect.fromCircle(center: head.translate(0, r * 0.2), radius: r * 0.75), math.pi * 0.15, math.pi * 0.7, false, p..style = PaintingStyle.stroke..strokeWidth = r * 0.25);
      p.style = PaintingStyle.fill;
    }
    // Face: eyes and mouth change with distress and consciousness.
    p.color = const Color(0xFF263238);
    final bool drowsy = v.avpu != 'A';
    if (drowsy) {
      p.strokeWidth = 2;
      canvas.drawLine(head.translate(-r * 0.45, -r * 0.1), head.translate(-r * 0.15, -r * 0.1), p);
      canvas.drawLine(head.translate(r * 0.15, -r * 0.1), head.translate(r * 0.45, -r * 0.1), p);
    } else {
      canvas.drawCircle(head.translate(-r * 0.3, -r * 0.1), r * 0.09, p);
      canvas.drawCircle(head.translate(r * 0.3, -r * 0.1), r * 0.09, p);
    }
    final Paint mouth = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final double curve = distress > 0.4 ? -1 : 1;
    final Path m = Path()
      ..moveTo(head.dx - r * 0.3, head.dy + r * 0.4)
      ..quadraticBezierTo(head.dx, head.dy + r * (0.4 + 0.2 * curve), head.dx + r * 0.3, head.dy + r * 0.4);
    canvas.drawPath(m, mouth);
    // Sweat drops when shocked or in pain.
    if (distress > 0.5) {
      p.color = const Color(0xFF4FC3F7);
      canvas.drawCircle(head.translate(r * 0.85, -r * 0.4), r * 0.1, p);
      canvas.drawCircle(head.translate(r * 0.95, -r * 0.05), r * 0.08, p);
    }
  }

  @override
  bool shouldRepaint(PatientPainter old) => old.v != v || old.distress != distress;
}

/// How unwell the patient looks (0–1), from the early warning score.
double distressOf(PatientSim s) => math.min(1, (s.news() + s.v.pain / 3) / 9);

/// Bedside monitor: ECG and pleth waveforms with live numbers.
class BedsideMonitor extends StatefulWidget {
  const BedsideMonitor({super.key, required this.sim});
  final PatientSim sim;

  @override
  State<BedsideMonitor> createState() => _BedsideMonitorState();
}

class _BedsideMonitorState extends State<BedsideMonitor> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void initState() {
    super.initState();
    if (HospitalUi.animate) _t.repeat();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PatientSim s = widget.sim;
    final bool on = s.monitorOn;
    final Vitals v = s.v;
    final int news = s.news();
    Widget num(String label, String value, Color c, {bool alarm = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            Text(label, style: TextStyle(color: c.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w700)),
            Text(value, style: TextStyle(color: alarm ? const Color(0xFFFF5252) : c, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ]),
        );
    final VitalsPoint? last = s.chart.isEmpty ? null : s.chart.last;
    String show(double Function(Vitals) f, {int digits = 0}) {
      if (on) return f(v).toStringAsFixed(digits);
      if (last == null) return '--';
      return f(last.v).toStringAsFixed(digits);
    }

    return Container(
      key: const ValueKey<String>('bedside_monitor'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF0B1220), borderRadius: BorderRadius.circular(10), border: Border.all(color: news >= 5 && on ? const Color(0xFFFF5252) : const Color(0xFF263238), width: 2)),
      child: Row(children: <Widget>[
        Expanded(
          child: AnimatedBuilder(
            animation: _t,
            builder: (BuildContext context, _) => CustomPaint(
              size: const Size(double.infinity, 110),
              painter: WavePainter(rhythm: on ? s.c.ecg : 'off', hr: v.hr, phase: _t.value, spo2On: on),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 92,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            num('HR', show((Vitals x) => x.hr), const Color(0xFF69F0AE), alarm: on && (v.hr > 130 || v.hr < 50)),
            num('NIBP', on ? '${v.sbp.round()}/${v.dbp.round()}' : (last == null ? '--/--' : '${last.v.sbp.round()}/${last.v.dbp.round()}'), const Color(0xFFFFFFFF), alarm: on && v.sbp < 90),
            num('SpO₂', show((Vitals x) => x.spo2), const Color(0xFF40C4FF), alarm: on && v.spo2 < 92),
            num('RR', show((Vitals x) => x.rr), const Color(0xFFFFFF00), alarm: on && (v.rr > 24 || v.rr < 9)),
            num('TEMP', show((Vitals x) => x.temp, digits: 1), const Color(0xFFFFAB40)),
          ]),
        ),
      ]),
    );
  }
}

/// ECG (top) and pleth (bottom) traces for a rhythm.
class WavePainter extends CustomPainter {
  WavePainter({required this.rhythm, required this.hr, required this.phase, this.spo2On = true});
  final String rhythm;
  final double hr;
  final double phase;
  final bool spo2On;

  /// One heartbeat of the ECG shape at x in [0,1).
  static double beat(double x, String rhythm) {
    double y = 0;
    double g(double c, double w, double a) => a * math.exp(-math.pow((x - c) / w, 2));
    if (rhythm != 'af') y += g(0.15, 0.03, 0.12); // P wave
    y += g(0.3, 0.008, -0.15) + g(0.32, 0.012, 1.0) + g(0.34, 0.01, -0.3); // QRS
    final double st = rhythm == 'stemi' ? 0.25 : 0;
    if (x > 0.36 && x < 0.5) y += st;
    final double tAmp = rhythm == 'peaked_t' ? 0.75 : 0.25;
    y += g(0.55, rhythm == 'peaked_t' ? 0.025 : 0.05, tAmp);
    if (rhythm == 'af') y += 0.04 * math.sin(x * 90);
    return y;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()..color = const Color(0xFF12301F);
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    final double ecgMid = size.height * 0.35;
    final Paint ecg = Paint()
      ..color = const Color(0xFF69F0AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    if (rhythm == 'off') {
      canvas.drawLine(Offset(0, ecgMid), Offset(size.width, ecgMid), ecg..color = const Color(0xFF37474F));
      final TextPainter tp = TextPainter(text: const TextSpan(text: 'Monitor not attached', style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(8, size.height * 0.75));
      return;
    }
    final double beatsVisible = math.max(1.5, hr / 60 * 4);
    final Path pe = Path();
    final Path pp = Path();
    final math.Random rnd = math.Random(7);
    final List<double> jitter = <double>[for (int i = 0; i < 40; i++) rhythm == 'af' ? 0.6 + rnd.nextDouble() * 0.8 : 1];
    for (int i = 0; i <= size.width; i++) {
      final double t = i / size.width * beatsVisible + phase * beatsVisible;
      final int k = t.floor();
      final double x = (t - k) / jitter[k % jitter.length] % 1;
      final double y = ecgMid - beat(x, rhythm) * size.height * 0.28;
      final double py = size.height * 0.85 - math.max(0, math.sin((x - 0.35) * math.pi * 1.6)) * size.height * 0.16;
      if (i == 0) {
        pe.moveTo(0, y);
        pp.moveTo(0, py);
      } else {
        pe.lineTo(i.toDouble(), y);
        pp.lineTo(i.toDouble(), py);
      }
    }
    canvas.drawPath(pe, ecg);
    if (spo2On) {
      canvas.drawPath(
          pp,
          Paint()
            ..color = const Color(0xFF40C4FF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(WavePainter old) => old.phase != phase || old.rhythm != rhythm || old.hr != hr;
}

/// A static 12-lead style strip for the ECG result.
class EcgStrip extends StatelessWidget {
  const EcgStrip({super.key, required this.rhythm, required this.hr});
  final String rhythm;
  final double hr;

  @override
  Widget build(BuildContext context) => Container(
        height: 70,
        decoration: BoxDecoration(color: const Color(0xFFFFF3F3), border: Border.all(color: const Color(0xFFFFCDD2))),
        child: CustomPaint(painter: _StripPainter(rhythm, hr), size: const Size(double.infinity, 70)),
      );
}

class _StripPainter extends CustomPainter {
  _StripPainter(this.rhythm, this.hr);
  final String rhythm;
  final double hr;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()..color = const Color(0xFFFFCDD2);
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final Path p = Path();
    final double beats = math.max(2, hr / 60 * 5);
    final math.Random rnd = math.Random(3);
    final List<double> j = <double>[for (int i = 0; i < 20; i++) rhythm == 'af' ? 0.6 + rnd.nextDouble() * 0.8 : 1];
    for (int i = 0; i <= size.width; i++) {
      final double t = i / size.width * beats;
      final int k = t.floor();
      final double x = (t - k) / j[k % j.length] % 1;
      final double y = size.height * 0.6 - WavePainter.beat(x, rhythm) * size.height * 0.45;
      i == 0 ? p.moveTo(0, y) : p.lineTo(i.toDouble(), y);
    }
    canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFF212121)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3);
  }

  @override
  bool shouldRepaint(_StripPainter old) => false;
}

/// A simplified X-ray or CT image for an imaging result.
class ImagingPainter extends CustomPainter {
  ImagingPainter(this.kind);
  final String kind;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);
    final double w = size.width;
    final double h = size.height;
    final Paint soft = Paint()..color = const Color(0xFF616161);
    final Paint bone = Paint()..color = const Color(0xFFE0E0E0);
    final Paint lung = Paint()..color = const Color(0xFF1C1C1C);
    if (kind.startsWith('cxr')) {
      canvas.drawOval(Rect.fromLTWH(w * 0.12, h * 0.08, w * 0.76, h * 0.86), soft);
      canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.15, w * 0.28, h * 0.65), lung);
      canvas.drawOval(Rect.fromLTWH(w * 0.54, h * 0.15, w * 0.28, h * 0.65), lung);
      canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.45, w * 0.24, h * 0.32), soft);
      for (int i = 0; i < 6; i++) {
        canvas.drawArc(Rect.fromLTWH(w * 0.16, h * (0.18 + i * 0.1), w * 0.68, h * 0.2), math.pi, math.pi, false, bone..style = PaintingStyle.stroke..strokeWidth = 2);
      }
      bone.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(w * 0.48, h * 0.05, w * 0.04, h * 0.85), bone);
      if (kind == 'cxr_rll') {
        canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.22, h * 0.2), Paint()..color = const Color(0xFFBDBDBD).withValues(alpha: 0.7));
      }
    } else {
      canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.08, w * 0.7, h * 0.84), bone);
      canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.11, w * 0.64, h * 0.78), soft);
      canvas.drawLine(Offset(w * 0.5, h * 0.14), Offset(w * 0.5, h * 0.86), Paint()..color = const Color(0xFF424242)..strokeWidth = 2);
      canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.38, w * 0.06, h * 0.18), lung);
      canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.38, w * 0.06, h * 0.18), lung);
      if (kind == 'ct_head_bleed') canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.15, h * 0.15), Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(ImagingPainter old) => old.kind != kind;
}

/// Vital-signs chart over simulated time.
class VitalsChartPainter extends CustomPainter {
  VitalsChartPainter(this.points);
  final List<VitalsPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()..color = const Color(0xFFB0BEC5);
    canvas.drawLine(Offset(0, size.height - 1), Offset(size.width, size.height - 1), axis);
    if (points.length < 2) return;
    final int maxM = math.max(points.last.minute, 1);
    void line(double Function(Vitals) f, double lo, double hi, Color c) {
      final Path p = Path();
      for (int i = 0; i < points.length; i++) {
        final double x = points[i].minute / maxM * size.width;
        final double y = size.height - ((f(points[i].v) - lo) / (hi - lo)).clamp(0, 1) * size.height;
        i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }

    line((Vitals v) => v.hr, 30, 180, const Color(0xFF43A047));
    line((Vitals v) => v.sbp, 50, 200, const Color(0xFFE53935));
    line((Vitals v) => v.spo2, 70, 100, const Color(0xFF1E88E5));
    line((Vitals v) => v.rr, 0, 60, const Color(0xFFFDD835));
  }

  @override
  bool shouldRepaint(VitalsChartPainter old) => old.points.length != points.length;
}

/// A hospital room with the patient sitting up in bed, drawn large: wall,
/// window, curtain, IV pole and a detailed patient whose skin, eyes and
/// expression follow their condition.
class RoomScenePainter extends CustomPainter {
  RoomScenePainter(this.a, this.v, {this.distress = 0});
  final Appearance a;
  final Vitals v;
  final double distress;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect all = Offset.zero & size;
    // Wall and floor.
    canvas.drawRect(all, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF9FB4C8), Color(0xFF7D93AB)]).createShader(all));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = const Color(0xFF5B6B7E));
    // Window with blinds.
    final Rect win = Rect.fromLTWH(w * 0.04, h * 0.08, w * 0.22, h * 0.36);
    canvas.drawRect(win, Paint()..color = const Color(0xFFDCEBF7));
    for (double y = win.top; y < win.bottom; y += 8) {
      canvas.drawLine(Offset(win.left, y), Offset(win.right, y), Paint()..color = const Color(0xFFB8CAD9)..strokeWidth = 2);
    }
    canvas.drawRect(win, Paint()..color = const Color(0xFF55657A)..style = PaintingStyle.stroke..strokeWidth = 4);
    // Wall panel with gas outlets.
    final Rect panel = Rect.fromLTWH(w * 0.3, h * 0.1, w * 0.4, h * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(panel, const Radius.circular(6)), Paint()..color = const Color(0xFFE7EEF5));
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(panel.left + panel.width * (0.12 + i * 0.19), panel.center.dy), 7, Paint()..color = <Color>[const Color(0xFF22C55E), const Color(0xFF3B82F6), const Color(0xFFEAB308), const Color(0xFF94A3B8), const Color(0xFFEF4444)][i]);
    }
    // IV pole and bag.
    final Paint pole = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 4;
    canvas.drawLine(Offset(w * 0.86, h * 0.1), Offset(w * 0.86, h * 0.82), pole);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.83, h * 0.12, w * 0.06, h * 0.13), const Radius.circular(6)), Paint()..color = const Color(0xCCE0F2FE));
    // Bed.
    final Paint frame = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.66, w * 0.76, h * 0.08), const Radius.circular(8)), frame);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.74, w * 0.02, h * 0.12), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h * 0.74, w * 0.02, h * 0.12), Paint()..color = const Color(0xFF64748B));
    // Raised back rest + pillow.
    final Path back = Path()..moveTo(w * 0.1, h * 0.66)..lineTo(w * 0.16, h * 0.3)..lineTo(w * 0.3, h * 0.3)..lineTo(w * 0.3, h * 0.66)..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.14, h * 0.26, w * 0.2, h * 0.24), const Radius.circular(24)), Paint()..color = Colors.white);
    // Legs under the blanket.
    final Rect blanket = Rect.fromLTWH(w * 0.28, h * 0.5, w * 0.56, h * 0.18);
    canvas.drawRRect(RRect.fromRectAndRadius(blanket, const Radius.circular(22)), Paint()..shader = const LinearGradient(colors: <Color>[Color(0xFF8FB7E8), Color(0xFF6E9AD6)]).createShader(blanket));
    // Torso in gown.
    final double s = a.child ? 0.75 : 1;
    final Offset head = Offset(w * 0.25, h * 0.28 + (1 - s) * h * 0.08);
    final double r = h * 0.11 * s;
    final Rect torso = Rect.fromCenter(center: Offset(head.dx + r * 0.6, head.dy + r * 2.3), width: r * 3.0, height: r * 2.6);
    canvas.drawRRect(RRect.fromRectAndRadius(torso, Radius.circular(r * 0.9)), Paint()..color = a.gown);
    for (double x = torso.left + 10; x < torso.right - 6; x += 14) {
      for (double y = torso.top + 10; y < torso.bottom - 6; y += 14) {
        canvas.drawCircle(Offset(x, y), 1.6, Paint()..color = Colors.white.withValues(alpha: 0.5));
      }
    }
    // Skin tone follows oxygenation and perfusion.
    Color skin = a.skin;
    if (v.spo2 < 88) skin = Color.lerp(skin, const Color(0xFF7986CB), 0.35)!;
    if (v.sbp < 90) skin = Color.lerp(skin, const Color(0xFFE0E0E0), 0.35)!;
    final Paint sk = Paint()..color = skin;
    // Neck, ears and head.
    canvas.drawRect(Rect.fromCenter(center: head.translate(0, r * 1.05), width: r * 0.8, height: r * 0.7), sk);
    canvas.drawOval(Rect.fromCenter(center: head.translate(-r * 0.92, r * 0.05), width: r * 0.3, height: r * 0.45), sk);
    canvas.drawOval(Rect.fromCenter(center: head.translate(r * 0.92, r * 0.05), width: r * 0.3, height: r * 0.45), sk);
    canvas.drawOval(Rect.fromCenter(center: head, width: r * 1.9, height: r * 2.25), sk);
    // Hair.
    final Color hair = a.grey ? Color.lerp(a.hair, const Color(0xFFE5E7EB), 0.7)! : a.hair;
    final Paint hp = Paint()..color = hair;
    switch (a.style) {
      case HairStyle.bald:
        canvas.drawArc(Rect.fromCenter(center: head, width: r * 1.95, height: r * 2.3), math.pi * 0.95, math.pi * 0.25, false, hp..style = PaintingStyle.stroke..strokeWidth = r * 0.18);
        hp.style = PaintingStyle.fill;
      case HairStyle.short:
        canvas.drawArc(Rect.fromCenter(center: head.translate(0, -r * 0.1), width: r * 2.05, height: r * 2.2), math.pi * 1.0, math.pi, true, hp);
      case HairStyle.long:
        canvas.drawArc(Rect.fromCenter(center: head.translate(0, -r * 0.1), width: r * 2.2, height: r * 2.3), math.pi * 0.95, math.pi * 1.1, true, hp);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(head.dx - r * 1.15, head.dy - r * 0.2, r * 0.4, r * 1.9), Radius.circular(r * 0.2)), hp);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(head.dx + r * 0.75, head.dy - r * 0.2, r * 0.4, r * 1.9), Radius.circular(r * 0.2)), hp);
      case HairStyle.bun:
        canvas.drawArc(Rect.fromCenter(center: head.translate(0, -r * 0.1), width: r * 2.05, height: r * 2.2), math.pi * 1.0, math.pi, true, hp);
        canvas.drawCircle(head.translate(0, -r * 1.25), r * 0.45, hp);
      case HairStyle.curly:
        for (int i = 0; i < 11; i++) {
          final double t = math.pi * (0.95 + i * 0.11);
          canvas.drawCircle(head + Offset(math.cos(t) * r * 0.95, math.sin(t) * r * 1.1), r * 0.32, hp);
        }
    }
    // Face.
    final bool drowsy = v.avpu != 'A';
    final Paint white = Paint()..color = Colors.white;
    final Paint iris = Paint()..color = const Color(0xFF3E2723);
    final Paint line = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, r * 0.05)
      ..strokeCap = StrokeCap.round;
    for (final double sx in <double>[-0.38, 0.38]) {
      final Offset e = head.translate(r * sx, -r * 0.1);
      if (drowsy) {
        canvas.drawArc(Rect.fromCenter(center: e, width: r * 0.4, height: r * 0.2), 0, math.pi, false, line);
      } else {
        canvas.drawOval(Rect.fromCenter(center: e, width: r * 0.42, height: r * 0.26), white);
        canvas.drawCircle(e, r * 0.1, iris);
      }
      // Eyebrows: raised and pinched when in distress.
      final double tilt = distress > 0.4 ? (sx < 0 ? 0.08 : -0.08) : 0;
      canvas.drawLine(e.translate(-r * 0.2, -r * (0.27 + tilt)), e.translate(r * 0.2, -r * (0.27 - tilt)), line);
    }
    canvas.drawLine(head.translate(0, -r * 0.02), head.translate(-r * 0.08, r * 0.3), line);
    final double curve = distress > 0.4 ? -1 : 1;
    canvas.drawPath(
      Path()
        ..moveTo(head.dx - r * 0.3, head.dy + r * 0.55)
        ..quadraticBezierTo(head.dx, head.dy + r * (0.55 + 0.18 * curve), head.dx + r * 0.3, head.dy + r * 0.55),
      line..color = const Color(0xFF8D4A3A),
    );
    if (a.beard) {
      canvas.drawArc(Rect.fromCenter(center: head.translate(0, r * 0.35), width: r * 1.6, height: r * 1.5), math.pi * 0.1, math.pi * 0.8, false, Paint()..color = hair..style = PaintingStyle.stroke..strokeWidth = r * 0.22);
    }
    // Sweat when shocked, febrile or in pain.
    if (distress > 0.5 || v.temp > 38.5) {
      final Paint drop = Paint()..color = const Color(0xFF7DD3FC);
      canvas.drawCircle(head.translate(r * 0.75, -r * 0.55), r * 0.08, drop);
      canvas.drawCircle(head.translate(-r * 0.7, -r * 0.4), r * 0.07, drop);
    }
    // Pulse-oximeter on the finger once monitored.
    final Offset hand = Offset(torso.right + r * 0.2, torso.bottom - r * 0.4);
    canvas.drawCircle(hand, r * 0.22, sk);
  }

  @override
  bool shouldRepaint(RoomScenePainter old) => old.v != v || old.distress != distress;
}
