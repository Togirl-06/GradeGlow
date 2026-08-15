import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Atmospheric room backdrop — silhouettes, light shafts, grain of a workplace.
class PlayableSceneBackdrop extends StatelessWidget {
  const PlayableSceneBackdrop({
    super.key,
    required this.accent,
    required this.bg,
    required this.surface,
    required this.roomId,
    this.intensity = 1,
  });

  final Color accent;
  final Color bg;
  final Color surface;
  final String roomId;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScenePainter(
        accent: accent,
        bg: bg,
        surface: surface,
        seed: roomId.hashCode,
        intensity: intensity,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.accent,
    required this.bg,
    required this.surface,
    required this.seed,
    required this.intensity,
  });

  final Color accent;
  final Color bg;
  final Color surface;
  final int seed;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rng = math.Random(seed);
    final Rect full = Offset.zero & size;

    final Paint base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color.lerp(bg, surface, 0.35)!,
          bg,
          Color.lerp(bg, Colors.black, 0.35)!,
        ],
        stops: const <double>[0, 0.55, 1],
      ).createShader(full);
    canvas.drawRect(full, base);

    // Window / light wash
    final Paint wash = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.55 + rng.nextDouble() * 0.2, -0.7),
        radius: 1.15,
        colors: <Color>[
          accent.withValues(alpha: 0.22 * intensity),
          accent.withValues(alpha: 0.04 * intensity),
          Colors.transparent,
        ],
      ).createShader(full);
    canvas.drawRect(full, wash);

    // Floor plane
    final Path floor = Path()
      ..moveTo(0, size.height * 0.62)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      floor,
      Paint()..color = surface.withValues(alpha: 0.55),
    );

    // Desk / counter block
    final RRect desk = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.58,
        size.width * 0.55,
        size.height * 0.18,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      desk,
      Paint()..color = Color.lerp(surface, Colors.black, 0.25)!,
    );
    canvas.drawRRect(
      desk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: 0.25),
    );

    // Silhouette figures
    _figure(canvas, Offset(size.width * 0.72, size.height * 0.42), size.height * 0.38, accent);
    if (rng.nextBool()) {
      _figure(
        canvas,
        Offset(size.width * 0.84, size.height * 0.48),
        size.height * 0.28,
        accent.withValues(alpha: 0.55),
      );
    }

    // Scanlines / grain
    final Paint grain = Paint()..color = Colors.white.withValues(alpha: 0.015);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), grain);
    }

    // Corner vignette
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: 0.55),
          ],
          stops: const <double>[0.45, 1],
        ).createShader(full),
    );
  }

  void _figure(Canvas canvas, Offset feet, double h, Color color) {
    final Paint p = Paint()..color = color.withValues(alpha: 0.18);
    final double head = h * 0.18;
    canvas.drawCircle(Offset(feet.dx, feet.dy - h + head), head * 0.55, p);
    final Path body = Path()
      ..moveTo(feet.dx - h * 0.12, feet.dy - h * 0.15)
      ..lineTo(feet.dx + h * 0.12, feet.dy - h * 0.15)
      ..lineTo(feet.dx + h * 0.16, feet.dy - h + head * 1.6)
      ..lineTo(feet.dx - h * 0.16, feet.dy - h + head * 1.6)
      ..close();
    canvas.drawPath(body, p);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.accent != accent ||
      oldDelegate.intensity != intensity;
}

/// Pulsing LIVE badge.
class PlayableLiveBadge extends StatefulWidget {
  const PlayableLiveBadge({super.key, required this.accent, this.label = 'LIVE SHIFT'});

  final Color accent;
  final String label;

  @override
  State<PlayableLiveBadge> createState() => _PlayableLiveBadgeState();
}

class _PlayableLiveBadgeState extends State<PlayableLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        final double a = 0.45 + _c.value * 0.55;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.accent.withValues(alpha: 0.45 + _c.value * 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withValues(alpha: a),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.6 * a),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full-screen cinematic hire / briefing — not a system AlertDialog.
Future<void> showPlayableCinematic({
  required BuildContext context,
  required Color accent,
  required Color bg,
  required Color surface,
  required String eyebrow,
  required String title,
  required String body,
  required String cta,
  String? glyph,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (BuildContext ctx, Animation<double> a, Animation<double> b) {
      return FadeTransition(
        opacity: a,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              PlayableSceneBackdrop(
                accent: accent,
                bg: bg,
                surface: surface,
                roomId: title,
                intensity: 1.2,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        eyebrow.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      if (glyph != null)
                        Text(glyph, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 48,
                        height: 3,
                        color: accent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        body,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            cta,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
