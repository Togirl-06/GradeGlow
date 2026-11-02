import 'package:flutter/material.dart';

/// Premium executive command-center palette for Business Lab.
abstract final class VuV2BizColors {
  static const Color deepNavy = Color(0xFF0B1020);
  static const Color midnight = Color(0xFF111827);
  static const Color elevated = Color(0xFF1A2332);
  static const Color glass = Color(0xCC1E293B);
  static const Color ink = Color(0xFFF8FAFC);
  static const Color mute = Color(0xFF94A3B8);
  static const Color stroke = Color(0xFF334155);
  static const Color emerald = Color(0xFF10B981);
  static const Color royal = Color(0xFF3B82F6);
  static const Color gold = Color(0xFFFBBF24);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
}

abstract final class VuV2BizRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
}

class VuV2BizGlassCard extends StatelessWidget {
  const VuV2BizGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final Color border = borderColor ?? VuV2BizColors.stroke;
    final Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: VuV2BizColors.glass,
        borderRadius: BorderRadius.circular(VuV2BizRadii.lg),
        border: Border.all(color: border.withValues(alpha: 0.85)),
        boxShadow: glowColor == null
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            VuV2BizColors.elevated.withValues(alpha: 0.92),
            VuV2BizColors.midnight.withValues(alpha: 0.88),
          ],
        ),
      ),
      child: child,
    );
    if (onTap == null) {
      return body;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VuV2BizRadii.lg),
        child: body,
      ),
    );
  }
}

class VuV2BizKpiCard extends StatelessWidget {
  const VuV2BizKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.deltaLabel,
    required this.accent,
    this.icon = Icons.trending_up,
  });

  final String label;
  final String value;
  final String deltaLabel;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return VuV2BizGlassCard(
      glowColor: accent,
      borderColor: accent.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: VuV2BizColors.mute,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: VuV2BizColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            deltaLabel,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
