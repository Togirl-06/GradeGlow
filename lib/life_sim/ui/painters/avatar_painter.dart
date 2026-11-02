import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../../world/world_model.dart';

/// Everything needed to draw a character.
class AvatarLook {
  const AvatarLook({
    required this.skin,
    required this.hair,
    required this.outfit,
    this.shoes = const Color(0xFF263238),
    this.hairStyle = 'short',
    this.faceShape = 'oval',
    this.eyeStyle = 'round',
    this.accessory = 'none',
    this.feminine = false,
  });

  final Color skin;
  final Color hair;
  final Color outfit;
  final Color shoes;
  final String hairStyle;
  final String faceShape;
  final String eyeStyle;
  final String accessory;
  final bool feminine;

  factory AvatarLook.fromProfile(AvatarProfile p) => AvatarLook(
        skin: Color(p.skinTone),
        hair: Color(p.hairColor),
        outfit: Color(p.outfitColor),
        shoes: Color(p.shoeColor),
        hairStyle: p.hairStyle,
        faceShape: p.faceShape,
        eyeStyle: p.eyeStyle,
        accessory: p.accessory,
        feminine: p.genderPresentation == 'feminine',
      );

  factory AvatarLook.fromNpc(NpcDef n) {
    int tone(int v, List<int> table) => v >= 0 && v < table.length ? table[v] : v;
    final bool f = n.id.hashCode.isEven;
    return AvatarLook(
      skin: Color(tone(n.skinTone, AvatarProfile.skinTones)),
      hair: Color(tone(n.hairColor, AvatarProfile.hairColors)),
      outfit: Color(n.outfitColor),
      hairStyle: f ? 'long' : 'short',
      feminine: f,
      accessory: n.role.toLowerCase().contains('prof') || n.role.toLowerCase().contains('librar') ? 'glasses' : 'none',
    );
  }

  factory AvatarLook.fromPersona(InterviewerLike p) => AvatarLook(
        skin: Color(p.skinTone),
        hair: Color(p.hairColor),
        outfit: Color(p.outfitColor),
        hairStyle: p.hairStyle,
      );

  AvatarLook withOutfit(Color c) => AvatarLook(
        skin: skin,
        hair: hair,
        outfit: c,
        shoes: shoes,
        hairStyle: hairStyle,
        faceShape: faceShape,
        eyeStyle: eyeStyle,
        accessory: accessory,
        feminine: feminine,
      );
}

/// Minimal structural view of an interviewer persona.
class InterviewerLike {
  const InterviewerLike({required this.skinTone, required this.hairColor, required this.outfitColor, this.hairStyle = 'short'});
  final int skinTone;
  final int hairColor;
  final int outfitColor;
  final String hairStyle;
}

/// Draws a character with feet at the bottom-centre of the canvas box.
///
/// Design units: the character is ~100 units tall, then scaled to fit [size].
class AvatarPainter extends CustomPainter {
  AvatarPainter({
    required this.look,
    this.action = AvatarAction.idle,
    this.emotion = AvatarEmotion.neutral,
    this.t = 0,
    this.facingRight = true,
    this.shadow = true,
    this.bust = false,
  });

  final AvatarLook look;
  final AvatarAction action;
  final AvatarEmotion emotion;
  final double t;
  final bool facingRight;
  final bool shadow;

  /// Draw only head and shoulders (for portraits / interview).
  final bool bust;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (bust) {
      final double s = math.min(size.width / 70, size.height / 62);
      canvas.translate(size.width / 2, size.height);
      canvas.scale(s, s);
      canvas.translate(0, 36);
      _drawBody(canvas, bustOnly: true);
    } else {
      final double s = math.min(size.width / 56, size.height / 104);
      canvas.translate(size.width / 2, size.height - 2 * s);
      canvas.scale(s, s);
      if (!facingRight) canvas.scale(-1, 1);
      if (shadow) {
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 0), width: 34, height: 9),
          Paint()..color = const Color(0x33000000),
        );
      }
      if (action == AvatarAction.sleep) {
        canvas.translate(0, -8);
        canvas.rotate(-math.pi / 2);
        canvas.translate(-10, 0);
      }
      _drawBody(canvas);
    }
    canvas.restore();
    if (action == AvatarAction.sleep && !bust) _drawZzz(canvas, size);
  }

  double get _breath => math.sin(t * 2.2) * 0.8;

  void _drawBody(Canvas canvas, {bool bustOnly = false}) {
    final bool walking = action == AvatarAction.walk;
    final double swing = walking ? math.sin(t * 11) : 0;
    final bool sitting = action == AvatarAction.sit || action == AvatarAction.useComputer || action == AvatarAction.work || action == AvatarAction.study || action == AvatarAction.eat;
    final double bob = walking ? -(math.sin(t * 22).abs()) * 2.2 : _breath * 0.5;
    final double sitDrop = sitting ? 14 : 0;

    final Paint skin = Paint()..color = look.skin;
    final Paint outfit = Paint()..color = look.outfit;
    final Paint dark = Paint()..color = _shade(look.outfit, -0.22);
    final Paint shoes = Paint()..color = look.shoes;

    canvas.save();
    canvas.translate(0, bob + sitDrop);

    if (!bustOnly) {
      // Legs
      final Paint legs = Paint()..color = _shade(look.outfit, -0.35);
      if (sitting) {
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -26, 16, 8), const Radius.circular(3)), legs);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2, -20, 12, 6), const Radius.circular(3)), shoes);
      } else {
        _leg(canvas, -5, swing * 7, legs, shoes);
        _leg(canvas, 5, -swing * 7, legs, shoes);
      }
    }

    // Torso
    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(-11, -64, 22, 38 + (bustOnly ? 0 : 0)),
      const Radius.circular(8),
    );
    canvas.drawRRect(torso, outfit);
    if (look.feminine) {
      canvas.drawPath(
        Path()
          ..moveTo(-11, -34)
          ..lineTo(-14, -22)
          ..lineTo(14, -22)
          ..lineTo(11, -34)
          ..close(),
        dark,
      );
    }
    // Collar / neck
    canvas.drawRect(const Rect.fromLTWH(-3, -68, 6, 6), skin);
    canvas.drawPath(
      Path()
        ..moveTo(-5, -64)
        ..lineTo(0, -57)
        ..lineTo(5, -64)
        ..close(),
      Paint()..color = _shade(look.outfit, 0.25),
    );
    if (look.accessory == 'scarf') {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -66, 18, 6), const Radius.circular(3)), Paint()..color = const Color(0xFFEF4444));
    }

    // Arms
    _arms(canvas, swing, skin, outfit);

    // Head
    _head(canvas);
    canvas.restore();
  }

  void _leg(Canvas canvas, double x, double swing, Paint legs, Paint shoes) {
    canvas.save();
    canvas.translate(x, -26);
    canvas.rotate(swing * 0.045);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 0, 8, 22), const Radius.circular(3)), legs);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 19, 11, 7), const Radius.circular(3)), shoes);
    canvas.restore();
  }

  void _arms(Canvas canvas, double swing, Paint skin, Paint outfit) {
    final Paint sleeve = Paint()..color = _shade(look.outfit, -0.1);
    void arm(double side, double angle, {double len = 24}) {
      canvas.save();
      canvas.translate(side * 11, -61);
      canvas.rotate(angle);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-3.5, 0, 7, len * 0.62), const Radius.circular(3.5)), sleeve);
      canvas.drawCircle(Offset(0, len * 0.66), 3.6, skin);
      canvas.restore();
    }

    switch (action) {
      case AvatarAction.walk:
        arm(-1, swing * 0.7);
        arm(1, -swing * 0.7);
      case AvatarAction.talk:
        arm(-1, 0.1);
        arm(1, -1.0 + math.sin(t * 8) * 0.35);
      case AvatarAction.useComputer:
      case AvatarAction.work:
        arm(-1, -1.25 + math.sin(t * 14) * 0.06);
        arm(1, -1.25 + math.sin(t * 14 + 1) * 0.06);
      case AvatarAction.study:
        arm(-1, -0.95);
        arm(1, -0.95 + math.sin(t * 3) * 0.05);
      case AvatarAction.eat:
        arm(-1, 0.1);
        arm(1, -2.2 + math.sin(t * 5) * 0.25);
      case AvatarAction.celebrate:
        arm(-1, 2.7 + math.sin(t * 9) * 0.3);
        arm(1, -2.7 - math.sin(t * 9) * 0.3);
      case AvatarAction.frustrated:
        arm(-1, -2.4);
        arm(1, 0.1);
      case AvatarAction.sleep:
        arm(-1, 0.05);
        arm(1, -0.05);
      case AvatarAction.sit:
        arm(-1, -0.35);
        arm(1, 0.35);
      case AvatarAction.idle:
        arm(-1, 0.06 + _breath * 0.02);
        arm(1, -0.06 - _breath * 0.02);
    }
  }

  void _head(Canvas canvas) {
    final Paint skin = Paint()..color = look.skin;
    final Paint hair = Paint()..color = look.hair;
    final double nod = action == AvatarAction.talk ? math.sin(t * 9) * 1.2 : 0;
    final double tilt = action == AvatarAction.frustrated ? 0.12 : (emotion == AvatarEmotion.sad || emotion == AvatarEmotion.tired ? 0.07 : 0);
    canvas.save();
    canvas.translate(0, -78 + nod);
    canvas.rotate(tilt);

    // Back hair (behind face)
    switch (look.hairStyle) {
      case 'long':
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12.5, -10, 25, 34), const Radius.circular(10)), hair);
      case 'afro':
        canvas.drawCircle(const Offset(0, -4), 17, hair);
      case 'curly':
        for (final Offset o in const <Offset>[Offset(-11, -2), Offset(11, -2), Offset(-9, 6), Offset(9, 6), Offset(0, -12)]) {
          canvas.drawCircle(o, 7, hair);
        }
      case 'braids':
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-13, -6, 5, 30), const Radius.circular(3)), hair);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, -6, 5, 30), const Radius.circular(3)), hair);
      case 'bun':
        canvas.drawCircle(const Offset(0, -17), 6.5, hair);
    }

    // Face
    final Rect faceRect = Rect.fromCenter(center: const Offset(0, 0), width: 22, height: 25);
    switch (look.faceShape) {
      case 'round':
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 25, height: 24), skin);
      case 'square':
        canvas.drawRRect(RRect.fromRectAndRadius(faceRect, const Radius.circular(6)), skin);
      case 'heart':
        canvas.drawPath(
          Path()
            ..moveTo(-12, -6)
            ..quadraticBezierTo(-12, -13, 0, -12)
            ..quadraticBezierTo(12, -13, 12, -6)
            ..quadraticBezierTo(11, 6, 0, 13)
            ..quadraticBezierTo(-11, 6, -12, -6)
            ..close(),
          skin,
        );
      default:
        canvas.drawOval(faceRect, skin);
    }

    // Front hair
    switch (look.hairStyle) {
      case 'bald':
        break;
      case 'long':
      case 'braids':
      case 'bun':
        canvas.drawPath(
          Path()
            ..moveTo(-12.5, -3)
            ..quadraticBezierTo(-12, -15, 0, -14)
            ..quadraticBezierTo(12, -15, 12.5, -3)
            ..quadraticBezierTo(4, -9, -4, -8)
            ..quadraticBezierTo(-9, -7, -12.5, -3)
            ..close(),
          hair,
        );
      case 'afro':
      case 'curly':
        canvas.drawPath(
          Path()
            ..moveTo(-12, -3)
            ..quadraticBezierTo(-12, -14, 0, -14)
            ..quadraticBezierTo(12, -14, 12, -3)
            ..quadraticBezierTo(0, -9, -12, -3)
            ..close(),
          hair,
        );
      default:
        canvas.drawPath(
          Path()
            ..moveTo(-12, -2)
            ..quadraticBezierTo(-13, -15, 0, -14.5)
            ..quadraticBezierTo(13, -15, 12, -2)
            ..quadraticBezierTo(8, -8, 0, -8)
            ..quadraticBezierTo(-8, -8, -12, -2)
            ..close(),
          hair,
        );
    }

    _face(canvas);

    // Accessories
    switch (look.accessory) {
      case 'glasses':
        final Paint g = Paint()
          ..color = const Color(0xFF111827)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3;
        canvas.drawCircle(const Offset(-5, -1), 4, g);
        canvas.drawCircle(const Offset(5, -1), 4, g);
        canvas.drawLine(const Offset(-1, -1), const Offset(1, -1), g);
      case 'cap':
        canvas.drawPath(
          Path()
            ..moveTo(-13, -5)
            ..quadraticBezierTo(-12, -19, 0, -18)
            ..quadraticBezierTo(12, -19, 13, -5)
            ..close(),
          Paint()..color = const Color(0xFFDC2626),
        );
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -8, 17, 4), const Radius.circular(2)), Paint()..color = const Color(0xFFB91C1C));
      case 'earrings':
        canvas.drawCircle(const Offset(-12.5, 6), 2, Paint()..color = const Color(0xFFFBBF24));
        canvas.drawCircle(const Offset(12.5, 6), 2, Paint()..color = const Color(0xFFFBBF24));
    }
    canvas.restore();
  }

  void _face(Canvas canvas) {
    final Paint ink = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final Paint fill = Paint()..color = const Color(0xFF1F2937);
    final bool sleeping = action == AvatarAction.sleep;
    final bool blink = (t * 1.1 % 3.4) < 0.1;
    final bool closed = sleeping || blink || emotion == AvatarEmotion.tired && ((t * 0.8) % 4 < 0.3);

    double eyeH;
    double eyeW;
    switch (look.eyeStyle) {
      case 'almond':
        eyeW = 3.4;
        eyeH = 2.0;
      case 'wide':
        eyeW = 3.2;
        eyeH = 3.4;
      case 'sleepy':
        eyeW = 3.0;
        eyeH = 1.6;
      default:
        eyeW = 2.6;
        eyeH = 2.6;
    }
    for (final double x in const <double>[-5, 5]) {
      if (closed) {
        canvas.drawLine(Offset(x - 2.6, -1), Offset(x + 2.6, -1), ink);
      } else {
        canvas.drawOval(Rect.fromCenter(center: Offset(x, -1), width: eyeW * 1.6, height: eyeH * 1.7), fill);
        canvas.drawCircle(Offset(x + 0.7, -1.7), 0.7, Paint()..color = Colors.white);
      }
    }
    // Brows
    final double browLift = emotion == AvatarEmotion.stressed ? 1.5 : (emotion == AvatarEmotion.proud ? -0.5 : 0);
    if (emotion == AvatarEmotion.stressed || action == AvatarAction.frustrated) {
      canvas.drawLine(const Offset(-8, -6), const Offset(-2.5, -4.5), ink);
      canvas.drawLine(const Offset(8, -6), const Offset(2.5, -4.5), ink);
    } else {
      canvas.drawLine(Offset(-8, -5.5 - browLift), Offset(-2.5, -6.2 - browLift), ink);
      canvas.drawLine(Offset(8, -5.5 - browLift), Offset(2.5, -6.2 - browLift), ink);
    }
    if (emotion == AvatarEmotion.tired) {
      final Paint bag = Paint()..color = const Color(0x33000000);
      canvas.drawOval(Rect.fromCenter(center: const Offset(-5, 2.2), width: 6, height: 2.2), bag);
      canvas.drawOval(Rect.fromCenter(center: const Offset(5, 2.2), width: 6, height: 2.2), bag);
    }
    // Mouth
    final Path mouth = Path();
    final bool talking = action == AvatarAction.talk && math.sin(t * 14) > 0;
    if (action == AvatarAction.eat && math.sin(t * 6) > 0) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 7), width: 5, height: 4), fill);
    } else if (talking) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(0, 7), width: 5, height: 3.5), fill);
    } else {
      switch (emotion) {
        case AvatarEmotion.happy:
        case AvatarEmotion.proud:
          mouth
            ..moveTo(-4, 5.5)
            ..quadraticBezierTo(0, 10.5, 4, 5.5);
        case AvatarEmotion.sad:
        case AvatarEmotion.stressed:
          mouth
            ..moveTo(-3.5, 8)
            ..quadraticBezierTo(0, 5, 3.5, 8);
        case AvatarEmotion.tired:
          mouth
            ..moveTo(-3, 7)
            ..lineTo(3, 7);
        case AvatarEmotion.neutral:
          mouth
            ..moveTo(-3, 6.5)
            ..quadraticBezierTo(0, 8, 3, 6.5);
      }
      canvas.drawPath(mouth, ink..style = PaintingStyle.stroke);
    }
    if (emotion == AvatarEmotion.happy || emotion == AvatarEmotion.proud) {
      final Paint blush = Paint()..color = const Color(0x33FF6B81);
      canvas.drawCircle(const Offset(-8, 4), 2.6, blush);
      canvas.drawCircle(const Offset(8, 4), 2.6, blush);
    }
  }

  void _drawZzz(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final double p = (t * 0.6 + i / 3) % 1;
      final TextPainter tp = TextPainter(
        text: TextSpan(text: 'z', style: TextStyle(color: Colors.white.withValues(alpha: 1 - p), fontSize: 10 + i * 3.0, fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width * 0.58 + p * 14 + i * 4, size.height * 0.45 - p * 30));
    }
  }

  static Color _shade(Color c, double amt) {
    final HSLColor h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(AvatarPainter old) =>
      old.t != t || old.action != action || old.emotion != emotion || old.look != look || old.facingRight != facingRight;
}

/// Convenience widget.
class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    required this.look,
    this.action = AvatarAction.idle,
    this.emotion = AvatarEmotion.neutral,
    this.t = 0,
    this.size = 120,
    this.bust = false,
    this.facingRight = true,
  });

  final AvatarLook look;
  final AvatarAction action;
  final AvatarEmotion emotion;
  final double t;
  final double size;
  final bool bust;
  final bool facingRight;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: bust ? size : size * 0.6,
        height: size,
        child: CustomPaint(
          painter: AvatarPainter(look: look, action: action, emotion: emotion, t: t, bust: bust, facingRight: facingRight),
        ),
      );
}
