import 'package:flutter/material.dart';

import '../../data/practice_lab_scene_config.dart';

/// Paints venue-specific cinematic backdrops (hospital room, courtroom, etc.).
class VenueSceneBackdrop extends StatelessWidget {
  const VenueSceneBackdrop({super.key, required this.config});

  final PracticeLabSceneConfig config;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: switch (config.venue) {
        PracticeLabVenue.hospital => _HospitalBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.courtroom => _CourtroomBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.scienceLab => _ScienceLabBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.workshop => _WorkshopBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.boardroom => _BoardroomBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.therapyRoom => _TherapyBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.classroom => _ClassroomBackdropPainter(config.sceneColors, config.accent),
        PracticeLabVenue.general => _GeneralBackdropPainter(config.sceneColors, config.accent, config.sceneIcon),
      },
      child: const SizedBox.expand(),
    );
  }
}

abstract class _VenuePainterBase extends CustomPainter {
  _VenuePainterBase(this.colors, this.accent);

  final List<Color> colors;
  final Color accent;

  void paintBase(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.32),
      size.width * 0.4,
      Paint()
        ..shader = RadialGradient(colors: <Color>[accent.withValues(alpha: 0.2), Colors.transparent])
            .createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.32), radius: size.width * 0.4)),
    );
  }
}

class _HospitalBackdropPainter extends _VenuePainterBase {
  _HospitalBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);

    final RRect bed = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.82), width: size.width * 0.55, height: size.height * 0.14),
      const Radius.circular(8),
    );
    canvas.drawRRect(bed, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.76), width: size.width * 0.5, height: size.height * 0.06),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF8FAFC),
    );

    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.45),
      Offset(size.width * 0.78, size.height * 0.88),
      Paint()..color = Colors.white24..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.48), 8, Paint()..color = accent.withValues(alpha: 0.5));

    final Path ekg = Path()..moveTo(size.width * 0.08, size.height * 0.2);
    for (int i = 0; i < 12; i++) {
      final double x = size.width * (0.08 + i * 0.07);
      ekg.lineTo(x, size.height * 0.2 + (i.isOdd ? -8 : 4));
      if (i == 5) ekg.lineTo(x + 4, size.height * 0.2 - 18);
    }
    canvas.drawPath(
      ekg,
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CourtroomBackdropPainter extends _VenuePainterBase {
  _CourtroomBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.22), width: size.width * 0.5, height: size.height * 0.1),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.62, size.height * 0.72), width: size.width * 0.22, height: size.height * 0.12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF92400E),
    );

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.85, size.height * 0.55),
      Paint()..color = accent.withValues(alpha: 0.35)..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScienceLabBackdropPainter extends _VenuePainterBase {
  _ScienceLabBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * (0.12 + i * 0.18), size.height * 0.55, 16, size.height * 0.22),
          const Radius.circular(3),
        ),
        Paint()..color = Color.lerp(accent, Colors.white, 0.3)!.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WorkshopBackdropPainter extends _VenuePainterBase {
  _WorkshopBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.55, size.height * 0.7), width: size.width * 0.35, height: size.height * 0.2),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoardroomBackdropPainter extends _VenuePainterBase {
  _BoardroomBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.78), width: size.width * 0.7, height: size.height * 0.16),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TherapyBackdropPainter extends _VenuePainterBase {
  _TherapyBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.78), width: size.width * 0.42, height: size.height * 0.14),
        const Radius.circular(16),
      ),
      Paint()..color = accent.withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClassroomBackdropPainter extends _VenuePainterBase {
  _ClassroomBackdropPainter(super.colors, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.12, size.width * 0.8, size.height * 0.28),
      Paint()..color = const Color(0xFF14532D).withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GeneralBackdropPainter extends _VenuePainterBase {
  _GeneralBackdropPainter(super.colors, super.accent, this.icon);

  final IconData icon;

  @override
  void paint(Canvas canvas, Size size) {
    paintBase(canvas, size);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.3,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * 0.5 - tp.width / 2, size.height * 0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Live vitals strip for AI Hospital sessions.
class HospitalVitalsBar extends StatelessWidget {
  const HospitalVitalsBar({super.key, required this.vitals, required this.accent});

  final Map<String, String> vitals;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> display = vitals.isNotEmpty
        ? vitals
        : const <String, String>{'BP': '—', 'HR': '—', 'RR': '—', 'SpO2': '—', 'Temp': '—'};

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.monitor_heart_outlined, size: 16, color: accent),
          const SizedBox(width: 8),
          Text('VITALS', style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: display.entries
                    .map(
                      (MapEntry<String, String> e) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('${e.key} ', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                            Text(e.value, style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Courtroom status strip.
class CourtroomStatusBar extends StatelessWidget {
  const CourtroomStatusBar({super.key, required this.accent, this.caseName});

  final Color accent;
  final String? caseName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.gavel_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Text('IN SESSION', style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          if (caseName != null && caseName!.isNotEmpty) ...<Widget>[
            const SizedBox(width: 12),
            Expanded(
              child: Text(caseName!, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
    );
  }
}
