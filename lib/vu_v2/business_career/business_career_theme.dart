import 'package:flutter/material.dart';

/// Executive navy + emerald / gold accents for School of Business & Economics.
abstract final class BizCosmic {
  static const Color bg = Color(0xFF0B1020);
  static const Color bgDeep = Color(0xFF070A14);
  static const Color panel = Color(0xFF121A2B);
  static const Color panelAlt = Color(0xFF172033);
  static const Color stroke = Color(0xFF2A3550);
  static const Color ink = Color(0xFFF8FAFC);
  static const Color mute = Color(0xFF94A3B8);
  static const Color emerald = Color(0xFF10B981);
  static const Color royal = Color(0xFF3B82F6);
  static const Color electric = Color(0xFF60A5FA);
  static const Color gold = Color(0xFFFBBF24);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF34D399);

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
        color: bg ?? emerald.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (bg ?? emerald).withValues(alpha: 0.45)),
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
  }) {
    return AppBar(
      backgroundColor: bg.withValues(alpha: 0.92),
      elevation: 0,
      leading: TextButton.icon(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
        label: const Text('Back'),
        style: TextButton.styleFrom(
          foregroundColor: mute,
          padding: const EdgeInsets.only(left: 8),
        ),
      ),
      leadingWidth: 96,
      title: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: gold, size: 22),
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
        ],
      ),
      actions: trailing,
    );
  }
}

class BizStarfield extends StatelessWidget {
  const BizStarfield({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0E1528), Color(0xFF070A14)],
        ),
      ),
      child: CustomPaint(
        painter: _BizGridPainter(),
        child: child,
      ),
    );
  }
}

class _BizGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const double step = 42;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final Paint dot = Paint()..color = Colors.white.withValues(alpha: 0.22);
    const List<Offset> pts = <Offset>[
      Offset(0.12, 0.18),
      Offset(0.35, 0.08),
      Offset(0.62, 0.14),
      Offset(0.84, 0.22),
      Offset(0.28, 0.42),
      Offset(0.71, 0.38),
    ];
    for (final Offset p in pts) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        1.4,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
