import 'package:flutter/material.dart';

/// Dark navy + electric blue / purple accents for School of Engineering.
abstract final class EngCosmic {
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
  static const Color teal = Color(0xFF14B8A6);
  static const Color gold = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFF59E0B);
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFF87171);
  static const Color steel = Color(0xFF94A3B8);

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
            Icon(icon, color: electric, size: 22),
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
    );
  }
}

class EngStarfield extends StatelessWidget {
  const EngStarfield({super.key, required this.child});

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
        painter: _GridPainter(),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final Paint dot = Paint()..color = Colors.white.withValues(alpha: 0.28);
    const List<Offset> pts = <Offset>[
      Offset(0.1, 0.15),
      Offset(0.35, 0.08),
      Offset(0.7, 0.2),
      Offset(0.9, 0.4),
      Offset(0.2, 0.6),
      Offset(0.55, 0.75),
      Offset(0.8, 0.85),
    ];
    for (final Offset p in pts) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        1.2,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
