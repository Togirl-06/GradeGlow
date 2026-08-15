import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/ai_practice_mode.dart';

/// Polished 2D animated avatar for live AI practice characters.
class AiPracticeAvatar extends StatefulWidget {
  const AiPracticeAvatar({
    super.key,
    required this.role,
    required this.isSpeaking,
    this.emotion = AvatarEmotion.neutral,
    this.size = 120,
    this.showGlow = true,
  });

  final AvatarRole role;
  final bool isSpeaking;
  final AvatarEmotion emotion;
  final double size;
  final bool showGlow;

  @override
  State<AiPracticeAvatar> createState() => _AiPracticeAvatarState();
}

class _AiPracticeAvatarState extends State<AiPracticeAvatar> with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _blinkController;
  late final AnimationController _mouthController;
  late final AnimationController _idleController;
  late final AnimationController _ringController;
  late final Animation<double> _bounce;
  late final Animation<double> _idleSway;
  bool _eyesOpen = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _bounce = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _idleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _idleSway = Tween<double>(begin: -0.018, end: 0.018).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();

    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 120))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          setState(() => _eyesOpen = true);
          _blinkController.reset();
          _scheduleBlink(2200 + (DateTime.now().millisecond % 2800));
        }
      });

    _mouthController = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));

    _scheduleBlink(1200);
    if (widget.isSpeaking) {
      _bounceController.repeat(reverse: true);
      _mouthController.repeat(reverse: true);
    }
  }

  void _scheduleBlink(int delayMs) {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: delayMs), _blink);
  }

  void _blink() {
    if (!mounted) return;
    setState(() => _eyesOpen = false);
    _blinkController.forward();
    _scheduleBlink(2600 + (DateTime.now().millisecond % 2200));
  }

  @override
  void didUpdateWidget(AiPracticeAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _bounceController.repeat(reverse: true);
      _mouthController.repeat(reverse: true);
    } else if (!widget.isSpeaking && oldWidget.isSpeaking) {
      _bounceController.stop();
      _bounceController.reset();
      _mouthController.stop();
      _mouthController.reset();
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _bounceController.dispose();
    _blinkController.dispose();
    _mouthController.dispose();
    _idleController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    final Color accent = widget.role.accentColor;
    final Color skinTone = _skinToneForRole(widget.role);
    final Color skinShadow = Color.lerp(skinTone, const Color(0xFF8B5E3C), 0.28)!;
    final Color bodyColor = _outfitColorForRole(widget.role);

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_bounce, _mouthController, _idleSway, _ringController]),
      builder: (BuildContext context, Widget? child) {
        final double mouthOpen = widget.isSpeaking ? _mouthController.value : 0;
        final double ringPulse = 0.55 + _ringController.value * 0.45;

        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: Transform.rotate(
            angle: _idleSway.value,
            child: SizedBox(
              width: s * 1.15,
              height: s * 1.28,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (widget.showGlow)
                    Positioned(
                      bottom: s * 0.08,
                      child: Container(
                        width: s * 0.72,
                        height: s * 0.14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: accent.withValues(alpha: widget.isSpeaking ? 0.42 : 0.22),
                              blurRadius: widget.isSpeaking ? 22 : 14,
                              spreadRadius: widget.isSpeaking ? 2 : 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.isSpeaking && widget.showGlow)
                    Positioned(
                      child: Container(
                        width: s * (0.92 + ringPulse * 0.06),
                        height: s * (0.92 + ringPulse * 0.06),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.22 * (1 - _ringController.value)),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  CustomPaint(
                    size: Size(s, s * 1.2),
                    painter: _AvatarPainter(
                      skinTone: skinTone,
                      skinShadow: skinShadow,
                      bodyColor: bodyColor,
                      accent: accent,
                      eyesOpen: _eyesOpen,
                      mouthOpen: mouthOpen,
                      emotion: widget.emotion,
                      role: widget.role,
                    ),
                  ),
                  Positioned(
                    right: s * 0.02,
                    top: s * 0.04,
                    child: _RoleBadge(role: widget.role, size: s * 0.26),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _skinToneForRole(AvatarRole role) {
    return switch (role) {
      AvatarRole.patient => const Color(0xFFF4CDB5),
      AvatarRole.teacher => const Color(0xFFE8C4A8),
      AvatarRole.ceo => const Color(0xFFD4A574),
      AvatarRole.customer => const Color(0xFFF0C9A6),
      AvatarRole.lawyer => const Color(0xFFE0B896),
      AvatarRole.interviewer => const Color(0xFFD9B08C),
      AvatarRole.manager => const Color(0xFFE5C4A0),
      AvatarRole.client => const Color(0xFFF2D4B8),
      AvatarRole.witness => const Color(0xFFDDB896),
    };
  }

  Color _outfitColorForRole(AvatarRole role) {
    return switch (role) {
      AvatarRole.patient => const Color(0xFF5BA4E6),
      AvatarRole.teacher => const Color(0xFF7C5CBF),
      AvatarRole.ceo => const Color(0xFF2F3B4A),
      AvatarRole.customer => const Color(0xFFE85D75),
      AvatarRole.lawyer => const Color(0xFF3D4F6B),
      AvatarRole.interviewer => const Color(0xFF2E9B8F),
      AvatarRole.manager => const Color(0xFF5A6B7C),
      AvatarRole.client => const Color(0xFF6B9E5A),
      AvatarRole.witness => const Color(0xFF7A6550),
    };
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.size});

  final AvatarRole role;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[role.accentColor, Color.lerp(role.accentColor, Colors.black, 0.22)!],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(color: role.accentColor.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(role.icon, size: size * 0.52, color: Colors.white),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({
    required this.skinTone,
    required this.skinShadow,
    required this.bodyColor,
    required this.accent,
    required this.eyesOpen,
    required this.mouthOpen,
    required this.emotion,
    required this.role,
  });

  final Color skinTone;
  final Color skinShadow;
  final Color bodyColor;
  final Color accent;
  final bool eyesOpen;
  final double mouthOpen;
  final AvatarEmotion emotion;
  final AvatarRole role;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double headRadius = w * 0.36;
    final Offset headCenter = Offset(w / 2, headRadius + 10);

    _drawBody(canvas, w, h, headCenter, headRadius);
    _drawNeck(canvas, headCenter, headRadius);
    _drawHead(canvas, headCenter, headRadius);
    _drawHairOrHat(canvas, headCenter, headRadius);
    _drawRoleAccessories(canvas, headCenter, headRadius, w, h);

    final double eyeY = headCenter.dy - headRadius * 0.08;
    final double eyeSpacing = headRadius * 0.36;
    _drawEye(canvas, Offset(headCenter.dx - eyeSpacing, eyeY), headRadius * 0.135, emotion == AvatarEmotion.surprised);
    _drawEye(canvas, Offset(headCenter.dx + eyeSpacing, eyeY), headRadius * 0.135, emotion == AvatarEmotion.surprised);
    _drawEyebrows(canvas, headCenter, headRadius, eyeY, eyeSpacing);
    _drawNose(canvas, headCenter, headRadius);
    _drawMouth(canvas, headCenter, headRadius);

    if (emotion == AvatarEmotion.happy) {
      _drawBlush(canvas, headCenter, headRadius);
    }
  }

  void _drawBody(Canvas canvas, double w, double h, Offset headCenter, double headRadius) {
    final Offset bodyCenter = Offset(w / 2, h - w * 0.2);
    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: bodyCenter, width: w * 0.62, height: h * 0.4),
      Radius.circular(w * 0.16),
    );

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(bodyColor, Colors.white, 0.12)!,
          Color.lerp(bodyColor, Colors.black, 0.18)!,
        ],
      ).createShader(torso.outerRect);
    canvas.drawRRect(torso, bodyPaint);

    // Shoulders
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, bodyCenter.dy - h * 0.14), width: w * 0.7, height: h * 0.12),
      Paint()..color = Color.lerp(bodyColor, Colors.white, 0.08)!,
    );

    _drawOutfitDetails(canvas, w, h, headCenter, headRadius, bodyCenter);
  }

  void _drawOutfitDetails(Canvas canvas, double w, double h, Offset headCenter, double headRadius, Offset bodyCenter) {
    switch (role) {
      case AvatarRole.patient:
        canvas.drawPath(
          Path()
            ..moveTo(bodyCenter.dx - w * 0.12, bodyCenter.dy - h * 0.06)
            ..lineTo(bodyCenter.dx, bodyCenter.dy + h * 0.04)
            ..lineTo(bodyCenter.dx + w * 0.12, bodyCenter.dy - h * 0.06),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
      case AvatarRole.ceo:
      case AvatarRole.lawyer:
        final Paint lapel = Paint()
          ..color = Color.lerp(bodyColor, Colors.white, 0.2)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(bodyCenter.dx - w * 0.1, bodyCenter.dy - h * 0.08),
          Offset(bodyCenter.dx, bodyCenter.dy + h * 0.02),
          lapel,
        );
        canvas.drawLine(
          Offset(bodyCenter.dx + w * 0.1, bodyCenter.dy - h * 0.08),
          Offset(bodyCenter.dx, bodyCenter.dy + h * 0.02),
          lapel,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(bodyCenter.dx, bodyCenter.dy - h * 0.02), width: w * 0.06, height: h * 0.1),
          Paint()..color = accent,
        );
      case AvatarRole.teacher:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(bodyCenter.dx, bodyCenter.dy - h * 0.01), width: w * 0.34, height: h * 0.06),
            const Radius.circular(4),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
      case AvatarRole.interviewer:
        canvas.drawArc(
          Rect.fromCenter(center: Offset(headCenter.dx - headRadius * 0.95, headCenter.dy + 2), width: 14, height: 22),
          1.2,
          4.8,
          false,
          Paint()
            ..color = const Color(0xFF1E293B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(Offset(headCenter.dx - headRadius * 1.02, headCenter.dy + 14), 5, Paint()..color = const Color(0xFF1E293B));
      default:
        break;
    }
  }

  void _drawNeck(Canvas canvas, Offset headCenter, double headRadius) {
    final Rect neck = Rect.fromCenter(
      center: Offset(headCenter.dx, headCenter.dy + headRadius * 0.82),
      width: headRadius * 0.42,
      height: headRadius * 0.38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(neck, const Radius.circular(6)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[skinTone, skinShadow],
        ).createShader(neck),
    );
  }

  void _drawHead(Canvas canvas, Offset center, double radius) {
    final Rect headRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          radius: 1.1,
          colors: <Color>[
            Color.lerp(skinTone, Colors.white, 0.18)!,
            skinTone,
            skinShadow,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(headRect),
    );

    // Ears
    for (final double side in <double>[-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + side * radius * 0.92, center.dy + radius * 0.05),
          width: radius * 0.22,
          height: radius * 0.3,
        ),
        Paint()..color = skinShadow.withValues(alpha: 0.85),
      );
    }
  }

  void _drawHairOrHat(Canvas canvas, Offset center, double radius) {
    final Color hairDark = Color.lerp(accent, const Color(0xFF2C1810), 0.55)!;
    final Color hairLight = Color.lerp(accent, const Color(0xFFFFF8F0), 0.25)!;
    final Paint hairPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[hairLight, hairDark],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    switch (role) {
      case AvatarRole.patient:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.98),
          math.pi * 1.02,
          math.pi * 0.96,
          false,
          hairPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.32..strokeCap = StrokeCap.round,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.92), width: radius * 1.1, height: radius * 0.22),
            const Radius.circular(6),
          ),
          Paint()..color = const Color(0xFFE8F4FC),
        );
      case AvatarRole.ceo:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.95),
          math.pi * 1.05,
          math.pi * 0.9,
          false,
          hairPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.22..strokeCap = StrokeCap.round,
        );
        final Rect hat = Rect.fromCenter(
          center: Offset(center.dx, center.dy - radius * 0.88),
          width: radius * 1.2,
          height: radius * 0.34,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(hat, const Radius.circular(5)),
          Paint()
            ..shader = LinearGradient(
              colors: <Color>[const Color(0xFF1E293B), const Color(0xFF0F172A)],
            ).createShader(hat),
        );
        canvas.drawRect(
          Rect.fromLTWH(center.dx - radius * 0.72, center.dy - radius * 0.72, radius * 1.44, radius * 0.1),
          Paint()..color = const Color(0xFF0F172A),
        );
      case AvatarRole.teacher:
        canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.52), radius * 0.58, hairPaint..style = PaintingStyle.fill);
        canvas.drawCircle(
          Offset(center.dx, center.dy - radius * 1.02),
          radius * 0.12,
          Paint()..color = const Color(0xFF1E293B),
        );
      case AvatarRole.lawyer:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.94),
          math.pi,
          math.pi,
          false,
          hairPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.2..strokeCap = StrokeCap.round,
        );
        canvas.drawRect(
          Rect.fromLTWH(center.dx - radius * 0.95, center.dy - radius * 1.05, radius * 1.9, radius * 0.22),
          Paint()..color = const Color(0xFF1E293B),
        );
      case AvatarRole.customer:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - radius * 0.85, center.dy - radius * 0.2)
            ..quadraticBezierTo(center.dx, center.dy - radius * 1.15, center.dx + radius * 0.85, center.dy - radius * 0.2)
            ..lineTo(center.dx + radius * 0.7, center.dy + radius * 0.1)
            ..quadraticBezierTo(center.dx, center.dy - radius * 0.35, center.dx - radius * 0.7, center.dy + radius * 0.1)
            ..close(),
          hairPaint..style = PaintingStyle.fill,
        );
      default:
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.96),
          math.pi * 1.1,
          math.pi * 0.85,
          false,
          hairPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.26..strokeCap = StrokeCap.round,
        );
    }
  }

  void _drawRoleAccessories(Canvas canvas, Offset headCenter, double headRadius, double w, double h) {
    if (role == AvatarRole.teacher) {
      final Paint frame = Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(headCenter.dx - headRadius * 0.28, headCenter.dy - headRadius * 0.06),
            width: headRadius * 0.42,
            height: headRadius * 0.3,
          ),
          const Radius.circular(5),
        ),
        frame,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(headCenter.dx + headRadius * 0.28, headCenter.dy - headRadius * 0.06),
            width: headRadius * 0.42,
            height: headRadius * 0.3,
          ),
          const Radius.circular(5),
        ),
        frame,
      );
      canvas.drawLine(
        Offset(headCenter.dx - headRadius * 0.07, headCenter.dy - headRadius * 0.06),
        Offset(headCenter.dx + headRadius * 0.07, headCenter.dy - headRadius * 0.06),
        frame,
      );
    }
  }

  void _drawEye(Canvas canvas, Offset center, double radius, bool wide) {
    final double r = wide ? radius * 1.18 : radius;
    if (eyesOpen) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 2.1, height: r * 1.55),
        Paint()..color = Colors.white,
      );
      final Color iris = Color.lerp(accent, const Color(0xFF3D2B1F), 0.35)!;
      canvas.drawCircle(center + Offset(0, r * 0.12), r * 0.62, Paint()..color = iris);
      canvas.drawCircle(center + Offset(0, r * 0.18), r * 0.34, Paint()..color = const Color(0xFF1A120D));
      canvas.drawCircle(center + Offset(r * 0.22, -r * 0.12), r * 0.16, Paint()..color = Colors.white.withValues(alpha: 0.95));
      canvas.drawArc(
        Rect.fromCenter(center: center, width: r * 2.1, height: r * 1.55),
        math.pi * 1.05,
        math.pi * 0.9,
        false,
        Paint()
          ..color = const Color(0xFF5C4033).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: r * 1.8, height: r * 0.9),
        0,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF5C4033)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawEyebrows(Canvas canvas, Offset headCenter, double headRadius, double eyeY, double eyeSpacing) {
    final Paint brow = Paint()
      ..color = const Color(0xFF4A3428)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final double browY = eyeY - headRadius * 0.2;
    switch (emotion) {
      case AvatarEmotion.concerned:
        canvas.drawLine(Offset(headCenter.dx - eyeSpacing - 9, browY + 4), Offset(headCenter.dx - eyeSpacing + 9, browY - 2), brow);
        canvas.drawLine(Offset(headCenter.dx + eyeSpacing - 9, browY - 2), Offset(headCenter.dx + eyeSpacing + 9, browY + 4), brow);
      case AvatarEmotion.surprised:
        canvas.drawLine(Offset(headCenter.dx - eyeSpacing - 8, browY - 5), Offset(headCenter.dx - eyeSpacing + 8, browY - 5), brow);
        canvas.drawLine(Offset(headCenter.dx + eyeSpacing - 8, browY - 5), Offset(headCenter.dx + eyeSpacing + 8, browY - 5), brow);
      case AvatarEmotion.thinking:
        canvas.drawLine(Offset(headCenter.dx - eyeSpacing - 7, browY + 1), Offset(headCenter.dx - eyeSpacing + 7, browY - 3), brow);
        canvas.drawLine(Offset(headCenter.dx + eyeSpacing - 7, browY), Offset(headCenter.dx + eyeSpacing + 7, browY), brow);
      case AvatarEmotion.happy:
        canvas.drawArc(
          Rect.fromCenter(center: Offset(headCenter.dx - eyeSpacing, browY), width: 16, height: 8),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          brow..strokeWidth = 2.4,
        );
        canvas.drawArc(
          Rect.fromCenter(center: Offset(headCenter.dx + eyeSpacing, browY), width: 16, height: 8),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          brow,
        );
      default:
        canvas.drawLine(Offset(headCenter.dx - eyeSpacing - 8, browY), Offset(headCenter.dx - eyeSpacing + 8, browY), brow);
        canvas.drawLine(Offset(headCenter.dx + eyeSpacing - 8, browY), Offset(headCenter.dx + eyeSpacing + 8, browY), brow);
    }
  }

  void _drawNose(Canvas canvas, Offset headCenter, double headRadius) {
    final Offset tip = Offset(headCenter.dx, headCenter.dy + headRadius * 0.18);
    canvas.drawOval(
      Rect.fromCenter(center: tip, width: headRadius * 0.14, height: headRadius * 0.1),
      Paint()..color = skinShadow.withValues(alpha: 0.35),
    );
  }

  void _drawMouth(Canvas canvas, Offset headCenter, double headRadius) {
    final Offset mouthCenter = Offset(headCenter.dx, headCenter.dy + headRadius * 0.38);
    final Paint lip = Paint()..color = const Color(0xFFD4846F);

    if (mouthOpen > 0.25) {
      final double openH = 5 + mouthOpen * 14;
      final RRect mouth = RRect.fromRectAndRadius(
        Rect.fromCenter(center: mouthCenter, width: 16 + mouthOpen * 10, height: openH),
        Radius.circular(openH / 2),
      );
      canvas.drawRRect(mouth, lip);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: mouthCenter + Offset(0, openH * 0.15), width: 12, height: 5),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF8B3A3A),
      );
      canvas.drawOval(
        Rect.fromCenter(center: mouthCenter + Offset(0, -openH * 0.15), width: 14, height: 4),
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
    } else {
      switch (emotion) {
        case AvatarEmotion.happy:
          canvas.drawArc(
            Rect.fromCenter(center: mouthCenter, width: 20, height: 13),
            0.15,
            math.pi - 0.3,
            false,
            lip..style = PaintingStyle.stroke..strokeWidth = 2.8..strokeCap = StrokeCap.round,
          );
        case AvatarEmotion.concerned:
          canvas.drawArc(
            Rect.fromCenter(center: mouthCenter + const Offset(0, 5), width: 15, height: 9),
            math.pi + 0.2,
            math.pi - 0.4,
            false,
            lip..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round,
          );
        case AvatarEmotion.surprised:
          canvas.drawOval(
            Rect.fromCenter(center: mouthCenter, width: 10, height: 12),
            lip,
          );
        case AvatarEmotion.thinking:
          canvas.drawLine(
            mouthCenter - const Offset(5, 2),
            mouthCenter + const Offset(8, -1),
            lip..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round,
          );
        default:
          canvas.drawArc(
            Rect.fromCenter(center: mouthCenter, width: 16, height: 7),
            0.1,
            math.pi - 0.2,
            false,
            lip..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round,
          );
      }
    }
  }

  void _drawBlush(Canvas canvas, Offset headCenter, double headRadius) {
    final Paint blush = Paint()..color = const Color(0x45F4728A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - headRadius * 0.48, headCenter.dy + headRadius * 0.14),
        width: 14,
        height: 9,
      ),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx + headRadius * 0.48, headCenter.dy + headRadius * 0.14),
        width: 14,
        height: 9,
      ),
      blush,
    );
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) =>
      oldDelegate.eyesOpen != eyesOpen ||
      oldDelegate.mouthOpen != mouthOpen ||
      oldDelegate.emotion != emotion ||
      oldDelegate.role != role;
}

/// Infer avatar emotion from AI message text.
AvatarEmotion inferEmotionFromText(String text) {
  final String lower = text.toLowerCase();
  if (RegExp(r'\b(worried|anxious|pain|scared|urgent|concerned|afraid)\b').hasMatch(lower)) {
    return AvatarEmotion.concerned;
  }
  if (RegExp(r'\b(great|thank|wonderful|excellent|happy|glad)\b').hasMatch(lower)) {
    return AvatarEmotion.happy;
  }
  if (RegExp(r'\b(hmm|let me think|consider|perhaps|interesting)\b').hasMatch(lower)) {
    return AvatarEmotion.thinking;
  }
  if (RegExp(r'\b(what\?!|really\?!|surprised|unexpected|wow)\b').hasMatch(lower)) {
    return AvatarEmotion.surprised;
  }
  return AvatarEmotion.neutral;
}
