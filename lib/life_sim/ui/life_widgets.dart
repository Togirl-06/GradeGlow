import 'package:flutter/material.dart';

abstract final class LifeColors {
  static const Color ink = Color(0xFF0B1220);
  static const Color panel = Color(0xFF111B33);
  static const Color panel2 = Color(0xFF18264A);
  static const Color line = Color(0xFF2A3A66);
  static const Color text = Color(0xFFEAF0FF);
  static const Color muted = Color(0xFF9FB0D6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);
}

ThemeData lifeTheme() => ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: LifeColors.ink,
      colorScheme: const ColorScheme.dark(
        primary: LifeColors.blue,
        secondary: LifeColors.teal,
        surface: LifeColors.panel,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LifeColors.panel,
        foregroundColor: LifeColors.text,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LifeColors.text),
      ),
      cardTheme: CardThemeData(
        color: LifeColors.panel2,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: LifeColors.line)),
      ),
      textTheme: const TextTheme().apply(bodyColor: LifeColors.text, displayColor: LifeColors.text),
      dividerColor: LifeColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LifeColors.panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LifeColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LifeColors.line)),
        hintStyle: const TextStyle(color: LifeColors.muted),
      ),
    );

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.color, this.onTap, this.border});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) => Material(
        color: color ?? LifeColors.panel2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: border ?? LifeColors.line)),
            child: child,
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
        child: Row(children: <Widget>[
          Expanded(child: Text(text.toUpperCase(), style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1))),
          if (trailing != null) trailing!,
        ]),
      );
}

class NeedBar extends StatelessWidget {
  const NeedBar({super.key, required this.label, required this.value, required this.emoji, this.color, this.compact = false});
  final String label;
  final double value;
  final String emoji;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double v = (value / 100).clamp(0.0, 1.0);
    final Color c = color ?? (v < 0.25 ? LifeColors.red : (v < 0.5 ? LifeColors.amber : LifeColors.green));
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
      child: Row(children: <Widget>[
        Text(emoji, style: TextStyle(fontSize: compact ? 13 : 16)),
        const SizedBox(width: 6),
        if (!compact) SizedBox(width: 78, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LifeColors.muted))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: v, minHeight: compact ? 6 : 9, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(c)),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(width: 28, child: Text(value.round().toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
      ]),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({super.key, required this.label, required this.onPressed, this.icon, this.color, this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Widget b = FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color ?? LifeColors.blue,
        disabledBackgroundColor: Colors.white12,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon ?? Icons.check_rounded, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
    return expand ? SizedBox(width: double.infinity, child: b) : b;
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: (color ?? LifeColors.blue).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: (color ?? LifeColors.blue).withValues(alpha: 0.5))),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color ?? LifeColors.blue)),
      );
}

String money(double v) {
  final bool neg = v < 0;
  final String s = v.abs().toStringAsFixed(v.abs() >= 1000 ? 0 : 2);
  final List<String> parts = s.split('.');
  final String whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => ',');
  return '${neg ? '-' : ''}\$$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
}

String clockLabel(int minuteOfDay) {
  final int h = minuteOfDay ~/ 60;
  final int m = minuteOfDay % 60;
  final String ap = h >= 12 ? 'PM' : 'AM';
  final int hh = h % 12 == 0 ? 12 : h % 12;
  return '$hh:${m.toString().padLeft(2, '0')} $ap';
}

Future<T?> showLifeSheet<T>(BuildContext context, {required Widget Function(BuildContext) builder, bool full = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LifeColors.panel,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    constraints: BoxConstraints(maxWidth: 720, maxHeight: MediaQuery.of(context).size.height * (full ? 0.94 : 0.7)),
    builder: builder,
  );
}

/// Scaffold used by every full-screen life-sim page.
class LifePage extends StatelessWidget {
  const LifePage({super.key, required this.title, required this.child, this.actions, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Theme(
        data: lifeTheme(),
        child: Scaffold(
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(title),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 11, color: LifeColors.muted, fontWeight: FontWeight.w600)),
            ]),
            actions: actions,
          ),
          body: SafeArea(
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: child)),
          ),
        ),
      );
}
