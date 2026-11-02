import 'package:flutter/material.dart';

/// Animated professor avatar with speaking pulse — picture-in-picture ready.
class LectureProfessorBadge extends StatefulWidget {
  const LectureProfessorBadge({
    super.key,
    this.size = 88,
    this.speaking = false,
  });

  final double size;
  final bool speaking;

  @override
  State<LectureProfessorBadge> createState() => _LectureProfessorBadgeState();
}

class _LectureProfessorBadgeState extends State<LectureProfessorBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void didUpdateWidget(LectureProfessorBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speaking && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!widget.speaking && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.speaking) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.stop();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        final double ringScale = widget.speaking ? 1 + _pulse.value * 0.14 : 1.0;
        final double ringOpacity =
            widget.speaking ? (1 - _pulse.value) * 0.55 : 0.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (widget.speaking)
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: widget.size + 14,
                  height: widget.size + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.tertiary.withValues(alpha: ringOpacity),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF1E3A5F),
                    Color(0xFF0F2744),
                  ],
                ),
                border: Border.all(
                  color: widget.speaking
                      ? scheme.tertiary
                      : Colors.white.withValues(alpha: 0.9),
                  width: widget.speaking ? 3 : 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: scheme.primary
                        .withValues(alpha: widget.speaking ? 0.5 : 0.22),
                    blurRadius: widget.speaking ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomPaint(
                  painter: _ProfessorFacePainter(
                    speaking: widget.speaking,
                    pulse: _pulse.value,
                  ),
                  size: Size.square(widget.size),
                ),
              ),
            ),
            if (widget.speaking)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: widget.size * 0.28,
                  height: widget.size * 0.28,
                  decoration: BoxDecoration(
                    color: scheme.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: scheme.tertiary.withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    size: widget.size * 0.14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Friendly teacher face — readable at PiP sizes, memorable for demos.
class _ProfessorFacePainter extends CustomPainter {
  _ProfessorFacePainter({required this.speaking, required this.pulse});

  final bool speaking;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Offset center = Offset(s / 2, s / 2);

    // Soft background glow
    canvas.drawCircle(
      center,
      s * 0.48,
      Paint()..color = const Color(0xFF2A4A6F),
    );

    // Hair
    final Paint hair = Paint()..color = const Color(0xFF1A1520);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.34),
        width: s * 0.72,
        height: s * 0.48,
      ),
      hair,
    );

    // Face
    final Paint skin = Paint()..color = const Color(0xFFE8C4A0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.52),
        width: s * 0.58,
        height: s * 0.62,
      ),
      skin,
    );

    // Glasses frames
    final Paint glass = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035;
    canvas.drawCircle(Offset(s * 0.36, s * 0.48), s * 0.11, glass);
    canvas.drawCircle(Offset(s * 0.64, s * 0.48), s * 0.11, glass);
    canvas.drawLine(
      Offset(s * 0.47, s * 0.48),
      Offset(s * 0.53, s * 0.48),
      glass,
    );

    // Eyes
    final Paint pupil = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(s * 0.36, s * 0.48), s * 0.035, pupil);
    canvas.drawCircle(Offset(s * 0.64, s * 0.48), s * 0.035, pupil);

    // Smile — wider when speaking
    final Paint smile = Paint()
      ..color = const Color(0xFF7C4A3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03
      ..strokeCap = StrokeCap.round;
    final double smileW = speaking ? 0.14 + pulse * 0.02 : 0.12;
    final Path mouth = Path()
      ..moveTo(s * (0.5 - smileW), s * 0.66)
      ..quadraticBezierTo(s * 0.5, s * (speaking ? 0.74 : 0.72), s * (0.5 + smileW), s * 0.66);
    canvas.drawPath(mouth, smile);

    // Collar / blazer hint
    final Paint blazer = Paint()..color = const Color(0xFF1E40AF);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.98),
        width: s * 0.85,
        height: s * 0.28,
      ),
      blazer,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfessorFacePainter oldDelegate) {
    return oldDelegate.speaking != speaking ||
        (speaking && (oldDelegate.pulse - pulse).abs() > 0.05);
  }
}
