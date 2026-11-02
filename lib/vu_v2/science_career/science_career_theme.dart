import 'package:flutter/material.dart';

/// Dark cosmic palette for School of Science career sim (mockup-aligned).
abstract final class SciCosmic {
  static const Color bg = Color(0xFF0A0E21);
  static const Color bgDeep = Color(0xFF070A16);
  static const Color panel = Color(0xFF12182B);
  static const Color panelAlt = Color(0xFF161D33);
  static const Color stroke = Color(0xFF2A3555);
  static const Color ink = Color(0xFFF4F7FF);
  static const Color mute = Color(0xFF9AA6C2);
  static const Color blue = Color(0xFF3B82F6);
  static const Color electric = Color(0xFF60A5FA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDeep = Color(0xFF6D28D9);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);
  static const Color gold = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFF59E0B);
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFF87171);

  static BoxDecoration panelBox({Color? color, double radius = 16}) =>
      BoxDecoration(
        color: color ?? panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: stroke.withValues(alpha: 0.85)),
      );

  static Widget pill(
    String text, {
    Color? bg,
    Color? fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? purple.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (bg ?? purple).withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: fg ?? ink),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg ?? ink,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  static AppBar appBar({
    required BuildContext context,
    required String title,
    IconData? icon,
    List<Widget>? trailing,
    String? subtitle,
  }) {
    return AppBar(
      backgroundColor: bg.withValues(alpha: 0.92),
      elevation: 0,
      leading: TextButton.icon(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
        label: const Text('Campus'),
        style: TextButton.styleFrom(
          foregroundColor: mute,
          padding: const EdgeInsets.only(left: 8),
        ),
      ),
      leadingWidth: 108,
      title: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: purple, size: 22),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(width: 10),
            pill(subtitle, bg: blue.withValues(alpha: 0.2), fg: electric),
          ],
        ],
      ),
      actions: trailing,
    );
  }
}

class SciStarfield extends StatelessWidget {
  const SciStarfield({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0B1028), Color(0xFF070A16)],
        ),
      ),
      child: CustomPaint(
        painter: _StarPainter(),
        child: child,
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..color = Colors.white.withValues(alpha: 0.35);
    const List<Offset> pts = <Offset>[
      Offset(0.08, 0.12),
      Offset(0.22, 0.08),
      Offset(0.41, 0.18),
      Offset(0.63, 0.09),
      Offset(0.81, 0.15),
      Offset(0.92, 0.28),
      Offset(0.15, 0.42),
      Offset(0.35, 0.55),
      Offset(0.55, 0.38),
      Offset(0.72, 0.48),
      Offset(0.88, 0.62),
      Offset(0.12, 0.72),
      Offset(0.48, 0.78),
      Offset(0.68, 0.88),
      Offset(0.28, 0.90),
    ];
    for (int i = 0; i < pts.length; i++) {
      final Offset o = Offset(pts[i].dx * size.width, pts[i].dy * size.height);
      canvas.drawCircle(o, i.isEven ? 1.4 : 0.9, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
