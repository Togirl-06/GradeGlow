/// GradeGlow career & hospital look: deep navy, violet-to-blue accents,
/// glassy panels, sidebars, logo tiles, gauges and bar charts.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class GG {
  static const Color bg = Color(0xFF0B1030);
  static const Color bg2 = Color(0xFF12183F);
  static const Color panel = Color(0xFF19204E);
  static const Color panel2 = Color(0xFF222A62);
  static const Color stroke = Color(0xFF2D376F);
  static const Color ink = Color(0xFFF1F3FF);
  static const Color mute = Color(0xFF9EA7D3);
  static const Color violet = Color(0xFF7C5CFF);
  static const Color purple = Color(0xFF6C4CF1);
  static const Color blue = Color(0xFF4F6BFF);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color accent = violet;

  static const LinearGradient primary = LinearGradient(colors: <Color>[Color(0xFF7C5CFF), Color(0xFF4F6BFF)]);
  static const LinearGradient page = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF0E1438), Color(0xFF0A0E2A)]);
}

ThemeData ggTheme(ThemeData base) {
  const ColorScheme cs = ColorScheme.dark(
    primary: GG.violet,
    onPrimary: Colors.white,
    secondary: GG.blue,
    onSecondary: Colors.white,
    surface: GG.panel,
    onSurface: GG.ink,
    error: GG.red,
    outline: GG.stroke,
    surfaceContainerHighest: GG.panel2,
  );
  final OutlinedBorder r10 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: cs,
    scaffoldBackgroundColor: GG.bg,
    canvasColor: GG.bg,
    cardColor: GG.panel,
    dividerColor: GG.stroke,
    appBarTheme: const AppBarTheme(
      backgroundColor: GG.bg2,
      foregroundColor: GG.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: GG.ink, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    cardTheme: CardThemeData(color: GG.panel, elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: GG.stroke))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: GG.violet, foregroundColor: Colors.white, shape: r10, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: GG.violet, foregroundColor: Colors.white, shape: r10)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: GG.ink, side: const BorderSide(color: GG.stroke), shape: r10, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFFA996FF))),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: GG.panel2,
      selectedColor: GG.violet,
      labelStyle: const TextStyle(color: GG.ink, fontWeight: FontWeight.w600),
      side: const BorderSide(color: GG.stroke),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      checkmarkColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GG.panel2,
      labelStyle: const TextStyle(color: GG.mute),
      hintStyle: const TextStyle(color: GG.mute),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GG.stroke)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GG.stroke)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GG.violet, width: 1.5)),
    ),
    listTileTheme: const ListTileThemeData(textColor: GG.ink, iconColor: GG.mute),
    expansionTileTheme: const ExpansionTileThemeData(textColor: GG.ink, collapsedTextColor: GG.ink, iconColor: GG.mute, collapsedIconColor: GG.mute),
    dialogTheme: const DialogThemeData(backgroundColor: GG.panel),
    snackBarTheme: const SnackBarThemeData(backgroundColor: GG.panel2, contentTextStyle: TextStyle(color: GG.ink)),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: GG.violet),
    textTheme: base.textTheme.apply(bodyColor: GG.ink, displayColor: GG.ink),
    iconTheme: const IconThemeData(color: GG.ink),
  );
}

/// Applies the career look to a subtree (every career/hospital route).
class GGTheme extends StatelessWidget {
  const GGTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(data: ggTheme(Theme.of(context)), child: child);
}

/// A route that always shows the career look.
MaterialPageRoute<T> ggRoute<T>(WidgetBuilder builder) => MaterialPageRoute<T>(builder: (BuildContext c) => GGTheme(child: Builder(builder: builder)));

/// Rounded panel with a hairline border, as in the mockups.
class GGPanel extends StatelessWidget {
  const GGPanel({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.color = GG.panel, this.gradient, this.margin = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GG.stroke),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: child,
      );
}

/// Violet → blue gradient button.
class GGButton extends StatelessWidget {
  const GGButton({super.key, required this.label, required this.onPressed, this.icon, this.color, this.dense = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: color == null ? GG.primary : null, color: color, borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onPressed,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: dense ? 14 : 18, vertical: dense ? 8 : 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  if (icon != null) ...<Widget>[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 6)],
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// Square company logo generated from the name (no trademarks used).
class GGLogo extends StatelessWidget {
  const GGLogo({super.key, required this.name, this.size = 54, this.icon});
  final String name;
  final double size;
  final IconData? icon;

  static const List<(Color, IconData)> _styles = <(Color, IconData)>[
    (Color(0xFF3B82F6), Icons.water_drop_rounded),
    (Color(0xFFEF4444), Icons.add_rounded),
    (Color(0xFF8B5CF6), Icons.balance_rounded),
    (Color(0xFF10B981), Icons.eco_rounded),
    (Color(0xFFF59E0B), Icons.bolt_rounded),
    (Color(0xFF06B6D4), Icons.hexagon_rounded),
    (Color(0xFFEC4899), Icons.auto_awesome_rounded),
    (Color(0xFF6366F1), Icons.change_history_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final int h = name.codeUnits.fold<int>(7, (int a, int b) => (a * 31 + b) & 0x7fffffff);
    final (Color c, IconData i) = _styles[h % _styles.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Icon(icon ?? i, color: c, size: size * 0.42),
        if (size >= 50)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(name.split(' ').first, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF1E293B), fontSize: size * 0.17, fontWeight: FontWeight.w800)),
          ),
      ]),
    );
  }
}

/// Round avatar with initials.
class GGAvatar extends StatelessWidget {
  const GGAvatar({super.key, required this.name, this.size = 40});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = name.trim().split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    final String init = parts.isEmpty ? '?' : (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: GG.primary),
      child: Text(init, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.38)),
    );
  }
}

/// Left navigation used by the workplace and patient records (top chips on phones).
class GGSidebarLayout extends StatelessWidget {
  const GGSidebarLayout({super.key, required this.items, required this.selected, required this.onSelect, required this.child, this.keyPrefix = 'side'});
  final List<(String, IconData)> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final Widget child;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      if (c.maxWidth < 760) {
        return Column(children: <Widget>[
          SizedBox(
            height: 48,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(key: ValueKey<String>('${keyPrefix}_$i'), avatar: Icon(items[i].$2, size: 16), label: Text(items[i].$1), selected: selected == i, onSelected: (_) => onSelect(i)),
                ),
            ]),
          ),
          Expanded(child: child),
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Container(
          width: 200,
          color: GG.bg2,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: selected == i ? GG.violet : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    key: ValueKey<String>('${keyPrefix}_$i'),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      child: Row(children: <Widget>[
                        Icon(items[i].$2, size: 18, color: selected == i ? Colors.white : GG.mute),
                        const SizedBox(width: 10),
                        Expanded(child: Text(items[i].$1, style: TextStyle(color: selected == i ? Colors.white : GG.ink, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        Expanded(child: child),
      ]);
    });
  }
}

/// Circular score gauge (e.g. performance 92%).
class GGGauge extends StatelessWidget {
  const GGGauge({super.key, required this.value, this.size = 120, this.label, this.textColor = GG.ink});
  final int value;
  final Color textColor;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GaugePainter(value / 100),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text('$value%', style: TextStyle(color: textColor, fontSize: size * 0.22, fontWeight: FontWeight.w900)),
              if (label != null) Text(label!, style: TextStyle(color: GG.mute, fontSize: size * 0.09)),
            ]),
          ),
        ),
      );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.f);
  final double f;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawArc(r, 0, math.pi * 2, false, Paint()..color = GG.panel2..style = PaintingStyle.stroke..strokeWidth = 12);
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * f.clamp(0, 1),
      false,
      Paint()
        ..shader = const SweepGradient(colors: <Color>[Color(0xFF22C55E), Color(0xFF22D3EE), Color(0xFF7C5CFF), Color(0xFFF59E0B), Color(0xFF22C55E)]).createShader(r)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.f != f;
}

/// Simple bar chart (e.g. paychecks).
class GGBars extends StatelessWidget {
  const GGBars({super.key, required this.values, this.height = 90});
  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _BarsPainter(values)));
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.v);
  final List<double> v;

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> vals = v.isEmpty ? <double>[0] : v;
    final double mx = vals.reduce(math.max) <= 0 ? 1 : vals.reduce(math.max);
    final int n = math.max(vals.length, 6);
    final double w = size.width / n;
    for (int i = 0; i < n; i++) {
      final double val = i < n - vals.length ? 0 : vals[i - (n - vals.length)];
      final double h = math.max(4, val / mx * (size.height - 4));
      final Rect r = Rect.fromLTWH(i * w + w * 0.18, size.height - h, w * 0.64, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()..shader = const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: <Color>[Color(0xFF4F6BFF), Color(0xFF7C9BFF)]).createShader(r),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.v != v;
}

/// The campus hero: a modern glass university building at dusk.
class CampusPainter extends CustomPainter {
  const CampusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect all = Offset.zero & size;
    canvas.drawRect(all, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF1B2A6B), Color(0xFF5B4BB7), Color(0xFFE59A7A)], stops: <double>[0, 0.6, 1]).createShader(all));
    final math.Random rnd = math.Random(4);
    final Paint star = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.35), rnd.nextDouble() * 1.2, star);
    }
    // Buildings.
    void block(double x, double y, double bw, double bh, Color c) {
      final Rect r = Rect.fromLTWH(x, y, bw, bh);
      canvas.drawRect(r, Paint()..color = c);
      final Paint lit = Paint()..color = const Color(0xFFFFD58A);
      final Paint dark = Paint()..color = const Color(0xFF2B3470);
      for (double yy = y + 8; yy < y + bh - 10; yy += 14) {
        for (double xx = x + 6; xx < x + bw - 10; xx += 12) {
          canvas.drawRect(Rect.fromLTWH(xx, yy, 7, 8), rnd.nextDouble() > 0.35 ? lit : dark);
        }
      }
    }

    block(w * 0.38, h * 0.32, w * 0.16, h * 0.5, const Color(0xFF384189));
    block(w * 0.56, h * 0.22, w * 0.2, h * 0.6, const Color(0xFF3F4A9C));
    block(w * 0.78, h * 0.36, w * 0.18, h * 0.46, const Color(0xFF353E86));
    // Glass rotunda.
    final Rect dome = Rect.fromLTWH(w * 0.5, h * 0.3, w * 0.22, h * 0.32);
    canvas.drawOval(dome, Paint()..shader = const LinearGradient(colors: <Color>[Color(0xFF9BD8FF), Color(0xFF5C7CE0)]).createShader(dome));
    final Paint mullion = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      final double x = dome.left + dome.width * i / 8;
      canvas.drawLine(Offset(x, dome.top + 6), Offset(x, dome.bottom - 6), mullion);
    }
    // Ground, path and trees.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.8, w, h * 0.2), Paint()..color = const Color(0xFF1C2A3F));
    canvas.drawPath(Path()..moveTo(w * 0.55, h * 0.8)..lineTo(w * 0.62, h * 0.8)..lineTo(w * 0.7, h)..lineTo(w * 0.47, h)..close(), Paint()..color = const Color(0xFF3C4A66));
    final Paint tree = Paint()..color = const Color(0xFF14301F);
    for (final double x in <double>[0.33, 0.4, 0.84, 0.92, 0.98]) {
      canvas.drawCircle(Offset(w * x, h * 0.74), h * 0.08, tree);
      canvas.drawRect(Rect.fromLTWH(w * x - 2, h * 0.76, 4, h * 0.06), tree);
    }
    // Readability gradient on the left for the title.
    canvas.drawRect(all, Paint()..shader = const LinearGradient(colors: <Color>[Color(0xE60B1030), Color(0x660B1030), Color(0x000B1030)], stops: <double>[0, 0.45, 0.75]).createShader(all));
  }

  @override
  bool shouldRepaint(CampusPainter old) => false;
}


/// A coloured button that shows a spinner while its async action runs.
class GGAsyncButton extends StatefulWidget {
  const GGAsyncButton({super.key, required this.label, required this.onPressed, this.icon, this.color = GG.blue, this.expand = false});
  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final Color color;
  final bool expand;

  @override
  State<GGAsyncButton> createState() => _GGAsyncButtonState();
}

class _GGAsyncButtonState extends State<GGAsyncButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final Future<void> Function()? go = widget.onPressed;
    final Widget b = Material(
      color: widget.color.withValues(alpha: go == null ? 0.4 : 1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: go == null || _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await go();
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            if (_busy)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else if (widget.icon != null)
              Icon(widget.icon, color: Colors.white, size: 20),
            if (_busy || widget.icon != null) const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
        ),
      ),
    );
    return widget.expand ? SizedBox(width: double.infinity, child: b) : b;
  }
}

/// Code editor look: dark panel with a line-number gutter.
class GGCodeEditor extends StatelessWidget {
  const GGCodeEditor({super.key, required this.controller, required this.fieldKey, this.onChanged, this.header, this.minLines = 12});
  final TextEditingController controller;
  final Key fieldKey;
  final ValueChanged<String>? onChanged;
  final Widget? header;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF0C1230), borderRadius: BorderRadius.circular(12), border: Border.all(color: GG.stroke)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        if (header != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: GG.stroke))),
            child: header,
          ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue v, _) {
            final int lines = '\n'.allMatches(v.text).length + 1;
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Container(
                width: 40,
                padding: const EdgeInsets.only(top: 12, right: 8),
                child: Text(
                  List<String>.generate(lines < minLines ? minLines : lines, (int i) => '${i + 1}').join('\n'),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5, color: Color(0xFF5B6694)),
                ),
              ),
              Expanded(
                child: TextField(
                  key: fieldKey,
                  controller: controller,
                  minLines: minLines,
                  maxLines: null,
                  onChanged: onChanged,
                  cursorColor: GG.violet,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5, color: Color(0xFFE6E9FF)),
                  decoration: const InputDecoration(filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.fromLTRB(4, 12, 12, 12)),
                ),
              ),
            ]);
          },
        ),
      ]),
    );
  }
}
