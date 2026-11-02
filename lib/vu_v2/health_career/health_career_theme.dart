import 'package:flutter/material.dart';

/// Clinical navy + purple / teal accents for School of Health and Medicine.
abstract final class MedCosmic {
  static const Color bg = Color(0xFF0B1020);
  static const Color bgDeep = Color(0xFF070A14);
  static const Color panel = Color(0xFF121A2B);
  static const Color panelAlt = Color(0xFF172033);
  static const Color stroke = Color(0xFF2A3550);
  static const Color ink = Color(0xFFF8FAFC);
  static const Color mute = Color(0xFF94A3B8);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color electric = Color(0xFFA78BFA);
  static const Color teal = Color(0xFF14B8A6);
  static const Color clinical = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFFBBF24);
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFF87171);
  static const Color warning = Color(0xFFF97316);

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
            Icon(icon, color: clinical, size: 22),
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

class MedStarfield extends StatelessWidget {
  const MedStarfield({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF10182C), Color(0xFF070A14)],
        ),
      ),
      child: CustomPaint(
        painter: _MedGridPainter(),
        child: child,
      ),
    );
  }
}

class _MedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
