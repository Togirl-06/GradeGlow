/// Student-facing maths tools and step views: working editor with a symbol
/// keypad, graph plotter with sliders and tracing, matrix grids, data
/// tables, calculator and a saved whiteboard.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../vu_v2/design/vu_v2_theme.dart';
import '../../model/career_models.dart';
import '../../ui/common.dart';
import '../../ui/task_views.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import '../ui/step_views.dart';
import 'expr.dart';
import 'math_steps.dart';

// ------------------------------------------------------------ keypad

const List<String> _symbols = <String>['^', '√(', 'π', '±', '≤', '≥', '(', ')', '/', '*', '|', 'ln(', 'sin(', 'cos(', 'e'];

/// Inserts maths symbols at the cursor of [controller].
class SymbolKeypad extends StatelessWidget {
  const SymbolKeypad({super.key, required this.controller, this.prefix = 'key'});
  final TextEditingController controller;
  final String prefix;

  void _insert(String s) {
    final TextSelection sel = controller.selection;
    final String t = controller.text;
    final int a = sel.isValid ? sel.start : t.length;
    final int b = sel.isValid ? sel.end : t.length;
    controller.value = TextEditingValue(text: t.replaceRange(a, b, s), selection: TextSelection.collapsed(offset: a + s.length));
  }

  @override
  Widget build(BuildContext context) => Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
        for (int i = 0; i < _symbols.length; i++)
          ActionChip(
            key: ValueKey<String>('${prefix}_$i'),
            visualDensity: VisualDensity.compact,
            label: Text(_symbols[i], style: const TextStyle(fontFamily: 'monospace')),
            onPressed: () => _insert(_symbols[i]),
          ),
      ]);
}

// ------------------------------------------------------------ graph

class PlotCurve {
  const PlotCurve(this.expr, this.color, {this.env = const <String, double>{}, this.label = ''});
  final Expr expr;
  final Color color;
  final Map<String, double> env;
  final String label;
}

/// Plots curves y = f(x), optional points and an optional slope field
/// y' = f(x, y). Drag or tap to trace the first curve.
class GraphPlot extends StatefulWidget {
  const GraphPlot({
    super.key,
    required this.curves,
    required this.window,
    this.points = const <(double, double)>[],
    this.slopeField,
    this.height = 240,
  });
  final List<PlotCurve> curves;
  final (double, double, double, double) window;
  final List<(double, double)> points;
  final Expr? slopeField;
  final double height;

  @override
  State<GraphPlot> createState() => _GraphPlotState();
}

class _GraphPlotState extends State<GraphPlot> {
  double? _trace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      final double w = c.maxWidth.isFinite ? c.maxWidth : 320;
      void trace(Offset p) {
        final (double x0, double x1, double _, double _) = widget.window;
        setState(() => _trace = x0 + (p.dx / w).clamp(0.0, 1.0) * (x1 - x0));
      }

      String? readout;
      if (_trace != null && widget.curves.isNotEmpty) {
        final double y = at(widget.curves.first.expr, 'x', _trace!, widget.curves.first.env);
        readout = 'x = ${_trace!.toStringAsFixed(3)}, y = ${y.isFinite ? y.toStringAsFixed(3) : 'undefined'}';
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        GestureDetector(
          onTapDown: (TapDownDetails d) => trace(d.localPosition),
          onHorizontalDragUpdate: (DragUpdateDetails d) => trace(d.localPosition),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(color: VuV2Colors.card, border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                size: Size(w, widget.height),
                painter: _PlotPainter(widget, _trace, VuV2Colors.mute, VuV2Colors.ink),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(readout ?? 'Tap or drag on the graph to trace the curve.', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        ),
      ]);
    });
  }
}

class _PlotPainter extends CustomPainter {
  _PlotPainter(this.g, this.trace, this.gridColor, this.inkColor);
  final GraphPlot g;
  final double? trace;
  final Color gridColor;
  final Color inkColor;

  static double _niceStep(double span) {
    final double raw = span / 8;
    final double p = math.pow(10, (math.log(raw) / math.ln10).floorToDouble()).toDouble();
    for (final double m in <double>[1, 2, 5, 10]) {
      if (raw <= m * p) return m * p;
    }
    return 10 * p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (double x0, double x1, double y0, double y1) = g.window;
    Offset map(double x, double y) => Offset((x - x0) / (x1 - x0) * size.width, size.height - (y - y0) / (y1 - y0) * size.height);
    final Paint grid = Paint()
      ..color = gridColor.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final Paint axis = Paint()
      ..color = gridColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.4;
    final double sx = _niceStep(x1 - x0);
    final double sy = _niceStep(y1 - y0);
    final TextStyle label = TextStyle(color: gridColor, fontSize: 9);
    for (double x = (x0 / sx).ceilToDouble() * sx; x <= x1; x += sx) {
      canvas.drawLine(map(x, y0), map(x, y1), grid);
      final TextPainter tp = TextPainter(text: TextSpan(text: fmtNum(double.parse(x.toStringAsPrecision(6))), style: label), textDirection: TextDirection.ltr)..layout();
      final double ay = (0 >= y0 && 0 <= y1) ? 0 : y0;
      tp.paint(canvas, map(x, ay) + const Offset(2, 1));
    }
    for (double y = (y0 / sy).ceilToDouble() * sy; y <= y1; y += sy) {
      canvas.drawLine(map(x0, y), map(x1, y), grid);
      final TextPainter tp = TextPainter(text: TextSpan(text: fmtNum(double.parse(y.toStringAsPrecision(6))), style: label), textDirection: TextDirection.ltr)..layout();
      final double ax = (0 >= x0 && 0 <= x1) ? 0 : x0;
      tp.paint(canvas, map(ax, y) + const Offset(2, -11));
    }
    if (0 >= y0 && 0 <= y1) canvas.drawLine(map(x0, 0), map(x1, 0), axis);
    if (0 >= x0 && 0 <= x1) canvas.drawLine(map(0, y0), map(0, y1), axis);

    if (g.slopeField != null) {
      final Paint sp = Paint()
        ..color = gridColor.withValues(alpha: 0.6)
        ..strokeWidth = 1;
      const int nx = 16;
      const int ny = 12;
      final double len = math.min(size.width / nx, size.height / ny) * 0.35;
      for (int i = 0; i <= nx; i++) {
        for (int j = 0; j <= ny; j++) {
          final double x = x0 + (x1 - x0) * i / nx;
          final double y = y0 + (y1 - y0) * j / ny;
          double m;
          try {
            m = g.slopeField!.eval(<String, double>{'x': x, 'y': y});
          } on ExprParseException {
            continue;
          }
          if (!m.isFinite) continue;
          // Slope in screen units.
          final double dx = 1 / (x1 - x0) * size.width;
          final double dy = m / (y1 - y0) * size.height;
          final double n = math.sqrt(dx * dx + dy * dy);
          final Offset c = map(x, y);
          final Offset d = Offset(dx / n * len, -dy / n * len);
          canvas.drawLine(c - d, c + d, sp);
        }
      }
    }

    for (final PlotCurve pc in g.curves) {
      final Paint p = Paint()
        ..color = pc.color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      final Path path = Path();
      bool pen = false;
      final int n = math.max(200, size.width.round() * 2);
      double? prevY;
      for (int i = 0; i <= n; i++) {
        final double x = x0 + (x1 - x0) * i / n;
        final double y = at(pc.expr, 'x', x, pc.env);
        final bool jump = prevY != null && (y - prevY).abs() > (y1 - y0) * 3;
        if (!y.isFinite || jump) {
          pen = false;
          prevY = y.isFinite ? y : null;
          continue;
        }
        final Offset o = map(x, y.clamp(y0 - (y1 - y0), y1 + (y1 - y0)));
        if (pen) {
          path.lineTo(o.dx, o.dy);
        } else {
          path.moveTo(o.dx, o.dy);
          pen = true;
        }
        prevY = y;
      }
      canvas.drawPath(path, p);
    }

    final Paint dot = Paint()..color = const Color(0xFFF59E0B);
    for (final (double x, double y) in g.points) {
      canvas.drawCircle(map(x, y), 4.5, dot);
    }
    if (trace != null && g.curves.isNotEmpty) {
      final double y = at(g.curves.first.expr, 'x', trace!, g.curves.first.env);
      canvas.drawLine(map(trace!, y0), map(trace!, y1), Paint()..color = inkColor.withValues(alpha: 0.3));
      if (y.isFinite) canvas.drawCircle(map(trace!, y), 4, Paint()..color = inkColor);
    }
  }

  @override
  bool shouldRepaint(covariant _PlotPainter old) => true;
}

const List<Color> _curveColors = <Color>[Color(0xFF3B82F6), Color(0xFFEF4444), Color(0xFF10B981), Color(0xFF8B5CF6)];

// ------------------------------------------------------------ tools

List<Widget> mathsTools(LabSpec lab) => <Widget>[
      const ExpansionTile(key: ValueKey<String>('tool_calculator'), tilePadding: EdgeInsets.zero, leading: Icon(Icons.calculate_rounded), title: Text('Scientific calculator'), children: <Widget>[CalculatorTool()]),
      const ExpansionTile(key: ValueKey<String>('tool_grapher'), tilePadding: EdgeInsets.zero, leading: Icon(Icons.show_chart_rounded), title: Text('Graphing tool'), children: <Widget>[GrapherTool()]),
      ExpansionTile(key: const ValueKey<String>('tool_whiteboard'), tilePadding: EdgeInsets.zero, leading: const Icon(Icons.draw_rounded), title: const Text('Whiteboard (saved with this lab)'), children: <Widget>[Whiteboard(lab: lab)]),
      const ExpansionTile(
        key: ValueKey<String>('tool_syntax'),
        tilePadding: EdgeInsets.zero,
        leading: Icon(Icons.help_outline_rounded),
        title: Text('How to type maths'),
        children: <Widget>[
          BulletList(<String>[
            'Powers: x^2, e^(2x). Roots: sqrt(x) or √(x). Fractions: (x+1)/(x-2).',
            'Multiplication can be implied: 3x, 2(x+1), (x-1)(x+2). 1/2x means (1/2)·x — use 1/(2x) for the other.',
            'Functions: sin, cos, tan, ln (natural log), log (base 10), exp, abs or |x|. Constants: pi or π, e.',
            'Relations: =, <, >, <= or ≤, >= or ≥, chains like -2 < x <= 5. Several answers: x = 2 or x = -3, or x = ±3.',
            'Start a line with # to write a comment; comments are not marked.',
          ]),
        ],
      ),
    ];

class CalculatorTool extends StatefulWidget {
  const CalculatorTool({super.key});
  @override
  State<CalculatorTool> createState() => _CalculatorToolState();
}

class _CalculatorToolState extends State<CalculatorTool> {
  final TextEditingController _c = TextEditingController();
  final List<String> _history = <String>[];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _eval() {
    String out;
    try {
      final Expr e = parseExpr(_c.text);
      if (e.variables.isNotEmpty) {
        out = '${_c.text} — contains ${e.variables.first}; the calculator needs numbers only';
      } else {
        out = '${_c.text} = ${fmtNum(double.parse(e.eval(const <String, double>{}).toStringAsPrecision(10)))}';
      }
    } on ExprParseException catch (e) {
      out = '${_c.text} — ${e.message}';
    }
    setState(() => _history.insert(0, out));
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Row(children: <Widget>[
          Expanded(
            child: TextField(
              key: const ValueKey<String>('calc_input'),
              controller: _c,
              onSubmitted: (_) => _eval(),
              decoration: const InputDecoration(hintText: 'e.g. (3.2^2 + 1)/sqrt(7)', border: OutlineInputBorder(), isDense: true),
            ),
          ),
          const SizedBox(width: 6),
          FilledButton(key: const ValueKey<String>('calc_go'), onPressed: _eval, child: const Text('=')),
        ]),
        const SizedBox(height: 4),
        SymbolKeypad(controller: _c, prefix: 'calc_key'),
        for (final String h in _history.take(8)) Padding(padding: const EdgeInsets.only(top: 4), child: Text(h, style: const TextStyle(fontFamily: 'monospace'))),
      ]);
}

class GrapherTool extends StatefulWidget {
  const GrapherTool({super.key});
  @override
  State<GrapherTool> createState() => _GrapherToolState();
}

class _GrapherToolState extends State<GrapherTool> {
  final List<TextEditingController> _f = <TextEditingController>[TextEditingController(text: 'x^2 - 2'), TextEditingController(), TextEditingController()];
  final TextEditingController _xr = TextEditingController(text: '-5, 5');
  final TextEditingController _yr = TextEditingController(text: '-5, 5');
  String? _error;

  @override
  void dispose() {
    for (final TextEditingController c in _f) {
      c.dispose();
    }
    _xr.dispose();
    _yr.dispose();
    super.dispose();
  }

  (double, double)? _range(String t) {
    final List<double?> v = t.split(',').map((String s) => parseNumeric(s.trim())).toList();
    if (v.length != 2 || v.contains(null) || v[0]! >= v[1]!) return null;
    return (v[0]!, v[1]!);
  }

  @override
  Widget build(BuildContext context) {
    final List<PlotCurve> curves = <PlotCurve>[];
    _error = null;
    for (int i = 0; i < _f.length; i++) {
      if (_f[i].text.trim().isEmpty) continue;
      try {
        final Expr e = parseExpr(_f[i].text);
        final Set<String> extra = e.variables.difference(<String>{'x'});
        if (extra.isNotEmpty) {
          _error = 'f${i + 1}: use x as the variable (found ${extra.first}).';
          continue;
        }
        curves.add(PlotCurve(e, _curveColors[i]));
      } on ExprParseException catch (e) {
        _error = 'f${i + 1}: ${e.message}';
      }
    }
    final (double, double) xr = _range(_xr.text) ?? (-5, 5);
    final (double, double) yr = _range(_yr.text) ?? (-5, 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      for (int i = 0; i < _f.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TextField(
            key: ValueKey<String>('graph_f$i'),
            controller: _f[i],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(prefixText: 'f${i + 1}(x) = ', border: const OutlineInputBorder(), isDense: true, prefixStyle: TextStyle(color: _curveColors[i])),
          ),
        ),
      Row(children: <Widget>[
        Expanded(child: TextField(key: const ValueKey<String>('graph_xr'), controller: _xr, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'x from, to', border: OutlineInputBorder(), isDense: true))),
        const SizedBox(width: 6),
        Expanded(child: TextField(key: const ValueKey<String>('graph_yr'), controller: _yr, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'y from, to', border: OutlineInputBorder(), isDense: true))),
      ]),
      if (_error != null) Text(_error!, style: TextStyle(color: VuV2Colors.danger, fontSize: 12)),
      const SizedBox(height: 6),
      GraphPlot(curves: curves, window: (xr.$1, xr.$2, yr.$1, yr.$2)),
    ]);
  }
}

/// Freehand whiteboard; strokes are saved with the lab run.
class Whiteboard extends StatefulWidget {
  const Whiteboard({super.key, required this.lab});
  final LabSpec lab;
  @override
  State<Whiteboard> createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboard> {
  static const String draftKey = '_whiteboard';
  List<List<Offset>> _strokes = <List<Offset>>[];
  bool _loaded = false;

  void _load() {
    if (_loaded) return;
    _loaded = true;
    final String? raw = careerStore(context).labRun(widget.lab.id)?.drafts[draftKey];
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      _strokes = <List<Offset>>[
        for (final dynamic s in data)
          <Offset>[
            for (int i = 0; i + 1 < (s as List<dynamic>).length; i += 2) Offset((s[i] as num).toDouble(), (s[i + 1] as num).toDouble()),
          ],
      ];
    } on FormatException {
      _strokes = <List<Offset>>[];
    }
  }

  Future<void> _save() async {
    final String data = jsonEncode(<List<double>>[
      for (final List<Offset> s in _strokes) <double>[for (final Offset o in s) ...<double>[o.dx.roundToDouble(), o.dy.roundToDouble()]],
    ]);
    await careerStore(context).saveLabDraft(widget.lab, draftKey, data);
  }

  @override
  Widget build(BuildContext context) {
    _load();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      GestureDetector(
        onPanStart: (DragStartDetails d) => setState(() => _strokes.add(<Offset>[d.localPosition])),
        onPanUpdate: (DragUpdateDetails d) => setState(() => _strokes.last.add(d.localPosition)),
        onPanEnd: (_) => _save(),
        child: Container(
          key: const ValueKey<String>('whiteboard_canvas'),
          height: 260,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(8)),
          child: CustomPaint(painter: _InkPainter(_strokes), size: Size.infinite),
        ),
      ),
      Row(children: <Widget>[
        Text('${_strokes.length} stroke${_strokes.length == 1 ? '' : 's'} · saved automatically', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        const Spacer(),
        TextButton(
          key: const ValueKey<String>('whiteboard_undo'),
          onPressed: _strokes.isEmpty
              ? null
              : () {
                  setState(() => _strokes.removeLast());
                  _save();
                },
          child: const Text('Undo'),
        ),
        TextButton(
          key: const ValueKey<String>('whiteboard_clear'),
          onPressed: _strokes.isEmpty
              ? null
              : () {
                  setState(() => _strokes.clear());
                  _save();
                },
          child: const Text('Clear'),
        ),
      ]),
    ]);
  }
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final List<Offset> s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 1.2, p);
        continue;
      }
      final Path path = Path()..moveTo(s.first.dx, s.first.dy);
      for (final Offset o in s.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _InkPainter old) => true;
}

// ------------------------------------------------------------ shared bits

class _Hints extends StatefulWidget {
  const _Hints({required this.hints, required this.onReveal});
  final List<String> hints;
  final ValueChanged<int> onReveal;
  @override
  State<_Hints> createState() => _HintsState();
}

class _HintsState extends State<_Hints> {
  int _shown = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.hints.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      for (int i = 0; i < _shown; i++)
        Padding(padding: const EdgeInsets.only(top: 4), child: Text('Hint ${i + 1}: ${widget.hints[i]}', style: TextStyle(color: VuV2Colors.ink, fontStyle: FontStyle.italic))),
      if (_shown < widget.hints.length)
        TextButton.icon(
          key: const ValueKey<String>('show_hint'),
          onPressed: () {
            setState(() => _shown++);
            widget.onReveal(_shown);
          },
          icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
          label: Text('Show hint ${_shown + 1} of ${widget.hints.length}'),
        ),
    ]);
  }
}

Widget _resultWithRetry(TaskResult r, VoidCallback retry, {List<String> model = const <String>[]}) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      ResultPanel(result: r),
      if (model.isNotEmpty)
        ExpansionTile(
          key: const ValueKey<String>('model_solution'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Model solution'),
          children: <Widget>[for (final String l in model) Align(alignment: Alignment.centerLeft, child: Text(l, style: const TextStyle(fontFamily: 'monospace')))],
        ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(key: const ValueKey<String>('revise'), onPressed: retry, icon: const Icon(Icons.edit_rounded, size: 18), label: const Text('Revise and resubmit')),
      ),
    ]);

// ------------------------------------------------------------ working view

class WorkingView extends StatefulWidget {
  const WorkingView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final WorkingStep step;
  final StepGraded onGraded;
  @override
  State<WorkingView> createState() => _WorkingViewState();
}

class _WorkingViewState extends State<WorkingView> {
  late final TextEditingController _c = TextEditingController();
  bool _loaded = false;
  int _hints = 0;
  TaskResult? _result;
  List<LineCheck> _checks = <LineCheck>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _c.text = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id] ?? '';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<String> get _lines => _c.text.split('\n');

  @override
  Widget build(BuildContext context) {
    final WorkingStep s = widget.step;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: VuV2Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Text(s.given, key: const ValueKey<String>('working_given'), style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      const SizedBox(height: 6),
      Text('One step per line. The last line is your final answer (${s.finalForm.label}).', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
      const SizedBox(height: 6),
      TextField(
        key: const ValueKey<String>('working_input'),
        controller: _c,
        enabled: _result == null,
        minLines: 5,
        maxLines: 14,
        style: const TextStyle(fontFamily: 'monospace'),
        onChanged: (String v) => careerStore(context).saveLabDraft(widget.lab, s.id, v),
        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g.\n3x - 6 = 2x + 5\nx - 6 = 5\nx = 11'),
      ),
      const SizedBox(height: 4),
      if (_result == null) SymbolKeypad(controller: _c, prefix: 'working_key'),
      _Hints(hints: s.hints, onReveal: (int n) => _hints = n),
      const SizedBox(height: 6),
      if (_result == null)
        Wrap(spacing: 8, runSpacing: 6, alignment: WrapAlignment.spaceBetween, children: <Widget>[
          OutlinedButton(
            key: const ValueKey<String>('working_check'),
            onPressed: () => setState(() => _checks = WorkingChecker.check(s, _lines)),
            child: const Text('Check how my lines are read'),
          ),
          labSubmitButton('working_submit', () async {
            final TaskResult? r = await gradeLabStep(context, () => WorkingChecker.grade(s, _lines, hintsUsed: _hints), widget.onGraded);
            if (mounted && r != null) setState(() => _result = r);
          }),
        ]),
      if (_result == null && _checks.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Preview — not submitted. Only whether each line can be read is shown here.', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
            for (final LineCheck c in _checks)
              Text(_readAs(c.text), style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
          ]),
        ),
      if (_result != null) _resultWithRetry(_result!, () => setState(() => _result = null), model: s.model),
    ]);
  }

  String _readAs(String line) {
    if (WorkingChecker.isNote(line)) return '# comment';
    final String t = WorkingChecker.clean(line);
    try {
      return '$t  →  ${parseStatement(t).show()}';
    } on ExprParseException catch (e) {
      return '$t  →  cannot read: ${e.message}';
    }
  }
}

// ------------------------------------------------------------ numeric / data

class _QuestionFields extends StatelessWidget {
  const _QuestionFields({required this.questions, required this.controllers, required this.choices, required this.enabled, required this.onChoice});
  final List<MathQuestion> questions;
  final Map<String, TextEditingController> controllers;
  final Map<String, int?> choices;
  final bool enabled;
  final void Function(String id, int i) onChoice;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        for (final MathQuestion q in questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: switch (q) {
              NumberQuestion() => TextField(
                  key: ValueKey<String>('q_${q.id}'),
                  controller: controllers[q.id],
                  enabled: enabled,
                  decoration: InputDecoration(labelText: q.prompt, suffixText: q.unit.isEmpty ? null : q.unit, border: const OutlineInputBorder(), isDense: true),
                ),
              ChoiceQuestion() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(q.prompt, style: TextStyle(color: VuV2Colors.ink)),
                  Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
                    for (int i = 0; i < q.options.length; i++)
                      ChoiceChip(key: ValueKey<String>('q_${q.id}_$i'), label: Text(q.options[i]), selected: choices[q.id] == i, onSelected: enabled ? (_) => onChoice(q.id, i) : null),
                  ]),
                ]),
            },
          ),
      ]);
}

Map<String, String> _answers(List<MathQuestion> qs, Map<String, TextEditingController> c, Map<String, int?> choices) => <String, String>{
      for (final MathQuestion q in qs) q.id: switch (q) { NumberQuestion() => c[q.id]!.text, ChoiceQuestion() => choices[q.id]?.toString() ?? '' },
    };

class DataTableView extends StatelessWidget {
  const DataTableView({super.key, required this.data});
  final DataTableSpec data;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        if (data.caption.isNotEmpty) Text(data.caption, style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            key: const ValueKey<String>('data_table'),
            headingRowHeight: 32,
            dataRowMinHeight: 26,
            dataRowMaxHeight: 30,
            columns: <DataColumn>[for (final String c in data.columns) DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w800)))],
            rows: <DataRow>[
              for (final List<Object> r in data.rows) DataRow(cells: <DataCell>[for (final Object v in r) DataCell(Text(v is double ? fmtNum(v) : '$v'))]),
            ],
          ),
        ),
        Text('${data.rows.length} rows', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
      ]);
}

class NumericView extends StatefulWidget {
  const NumericView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final NumericStep step;
  final StepGraded onGraded;
  @override
  State<NumericView> createState() => _NumericViewState();
}

class _NumericViewState extends State<NumericView> {
  late final Map<String, TextEditingController> _c = <String, TextEditingController>{
    for (final MathQuestion q in widget.step.questions) q.id: TextEditingController(),
  };
  final Map<String, int?> _choices = <String, int?>{};
  TaskResult? _result;

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NumericStep s = widget.step;
    final List<PlotCurve> curves = <PlotCurve>[
      for (int i = 0; i < s.curves.length; i++) PlotCurve(parseExpr(s.curves[i]), _curveColors[i % _curveColors.length]),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      if (s.data != null) DataTableView(data: s.data!),
      if (curves.isNotEmpty) GraphPlot(curves: curves, window: s.window ?? (-5, 5, -5, 5)),
      const SizedBox(height: 8),
      _QuestionFields(questions: s.questions, controllers: _c, choices: _choices, enabled: _result == null, onChoice: (String id, int i) => setState(() => _choices[id] = i)),
      _Hints(hints: s.hints, onReveal: (_) {}),
      if (_result == null)
        labSubmitButton('numeric_submit', () async {
          final TaskResult? r = await gradeLabStep(context, () => NumericGrader.grade(s, _answers(s.questions, _c, _choices)), widget.onGraded);
          if (mounted && r != null) setState(() => _result = r);
        })
      else
        _resultWithRetry(_result!, () => setState(() => _result = null)),
    ]);
  }
}

// ------------------------------------------------------------ graph step

class GraphStepView extends StatefulWidget {
  const GraphStepView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final GraphStep step;
  final StepGraded onGraded;
  @override
  State<GraphStepView> createState() => _GraphStepViewState();
}

class _GraphStepViewState extends State<GraphStepView> {
  late final Map<String, double> _p = <String, double>{for (final GraphParam g in widget.step.params) g.name: g.initial};
  late final Map<String, TextEditingController> _c = <String, TextEditingController>{
    for (final MathQuestion q in widget.step.questions) q.id: TextEditingController(),
  };
  final Map<String, int?> _choices = <String, int?>{};
  TaskResult? _result;

  @override
  void dispose() {
    for (final TextEditingController c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GraphStep s = widget.step;
    final Expr e = parseExpr(s.curve);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Text('y = ${s.curve}', style: TextStyle(color: VuV2Colors.ink, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      GraphPlot(
        curves: <PlotCurve>[
          PlotCurve(e, _curveColors[0], env: Map<String, double>.of(_p)),
          for (int i = 0; i < s.fixedCurves.length; i++) PlotCurve(parseExpr(s.fixedCurves[i]), _curveColors[1 + i % 3]),
        ],
        window: s.window,
        points: s.targets,
      ),
      for (final GraphParam g in s.params)
        Row(children: <Widget>[
          SizedBox(width: 92, child: Text('${g.label.isEmpty ? g.name : g.label} = ${fmtNum(_p[g.name]!)}', style: TextStyle(color: VuV2Colors.ink, fontFamily: 'monospace'))),
          Expanded(
            child: Slider(
              key: ValueKey<String>('param_${g.name}'),
              value: _p[g.name]!.clamp(g.min, g.max),
              min: g.min,
              max: g.max,
              divisions: ((g.max - g.min) / g.step).round(),
              onChanged: _result != null ? null : (double v) => setState(() => _p[g.name] = double.parse(v.toStringAsFixed(6))),
            ),
          ),
        ]),
      if (s.questions.isNotEmpty) ...<Widget>[
        const SizedBox(height: 6),
        _QuestionFields(questions: s.questions, controllers: _c, choices: _choices, enabled: _result == null, onChoice: (String id, int i) => setState(() => _choices[id] = i)),
      ],
      if (_result == null)
        labSubmitButton('graph_submit', () async {
          final TaskResult? r = await gradeLabStep(context, () => GraphGrader.grade(s, Map<String, double>.of(_p), _answers(s.questions, _c, _choices)), widget.onGraded);
          if (mounted && r != null) setState(() => _result = r);
        })
      else
        _resultWithRetry(_result!, () => setState(() => _result = null)),
    ]);
  }
}

// ------------------------------------------------------------ matrices

String _cell(double v) => fmtNum(double.parse(v.toStringAsPrecision(6)));

class MatrixDisplay extends StatelessWidget {
  const MatrixDisplay({super.key, required this.name, required this.m});
  final String name;
  final List<List<double>> m;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text('$name = ', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: VuV2Colors.ink, width: 2), right: BorderSide(color: VuV2Colors.ink, width: 2))),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            for (final List<double> row in m)
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                for (final double v in row) SizedBox(width: 44, child: Text(_cell(v), textAlign: TextAlign.center, style: TextStyle(color: VuV2Colors.ink, fontFamily: 'monospace'))),
              ]),
          ]),
        ),
      ]);
}

class MatrixView extends StatefulWidget {
  const MatrixView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final MatrixStep step;
  final StepGraded onGraded;
  @override
  State<MatrixView> createState() => _MatrixViewState();
}

class _MatrixViewState extends State<MatrixView> {
  late final List<List<TextEditingController>> _c = <List<TextEditingController>>[
    for (final List<double> row in widget.step.answer) <TextEditingController>[for (final double _ in row) TextEditingController()],
  ];
  TaskResult? _result;

  @override
  void dispose() {
    for (final List<TextEditingController> r in _c) {
      for (final TextEditingController c in r) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MatrixStep s = widget.step;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Wrap(spacing: 16, runSpacing: 8, children: <Widget>[for (final MapEntry<String, List<List<double>>> e in s.given.entries) MatrixDisplay(name: e.key, m: e.value)]),
      const SizedBox(height: 10),
      Text('${s.answerLabel} (fractions like 1/3 are fine):', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      for (int i = 0; i < _c.length; i++)
        Row(children: <Widget>[
          for (int j = 0; j < _c[i].length; j++)
            Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                width: 64,
                child: TextField(
                  key: ValueKey<String>('cell_${i}_$j'),
                  controller: _c[i][j],
                  enabled: _result == null,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
              ),
            ),
        ]),
      _Hints(hints: s.hints, onReveal: (_) {}),
      if (_result == null)
        labSubmitButton('matrix_submit', () async {
          final TaskResult? r = await gradeLabStep(
              context, () => MatrixGrader.grade(s, <List<String>>[for (final List<TextEditingController> row in _c) <String>[for (final TextEditingController c in row) c.text]]), widget.onGraded);
          if (mounted && r != null) setState(() => _result = r);
        })
      else
        _resultWithRetry(_result!, () => setState(() => _result = null)),
    ]);
  }
}

// ------------------------------------------------------------ ODEs

class OdeView extends StatefulWidget {
  const OdeView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final OdeStep step;
  final StepGraded onGraded;
  @override
  State<OdeView> createState() => _OdeViewState();
}

class _OdeViewState extends State<OdeView> {
  final TextEditingController _c = TextEditingController();
  TaskResult? _result;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _c.text = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id] ?? '';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OdeStep s = widget.step;
    Expr? mine;
    try {
      final String t = _c.text.trim().replaceFirst(RegExp(r'^y\s*(\(\s*x\s*\))?\s*='), '');
      if (t.isNotEmpty) mine = parseExpr(t);
    } on ExprParseException {
      mine = null;
    }
    Expr? field;
    if (s.order == 1) {
      try {
        field = parseExpr(s.rhs);
      } on ExprParseException {
        field = null;
      }
    }
    final double span = s.range.$2 - s.range.$1;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: VuV2Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Text(
          '${s.equation}${s.initial == null ? '   (general solution)' : '   with y(${fmtNum(s.initial![0])}) = ${fmtNum(s.initial![1])}${s.initial!.length > 2 ? ', y\'(${fmtNum(s.initial![0])}) = ${fmtNum(s.initial![2])}' : ''}'}',
          style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 6),
      if (field != null) Text('Slope field of the equation${mine != null ? ', with your solution' : ''}${s.general ? ' (constants set to 1)' : ''}:', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
      GraphPlot(
        curves: <PlotCurve>[if (mine != null) PlotCurve(mine, _curveColors[0], env: const <String, double>{'C': 1, 'C1': 1, 'C2': 1})],
        window: (s.range.$1 - span * 0.1, s.range.$2 + span * 0.1, -6, 6),
        slopeField: field,
        points: <(double, double)>[if (s.initial != null) (s.initial![0], s.initial![1])],
      ),
      const SizedBox(height: 6),
      TextField(
        key: const ValueKey<String>('ode_answer'),
        controller: _c,
        enabled: _result == null,
        onChanged: (String v) {
          setState(() {});
          careerStore(context).saveLabDraft(widget.lab, s.id, v);
        },
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(
          labelText: 'y(x) =',
          helperText: s.general ? 'Use ${s.constants.join(' and ')} for the arbitrary constant${s.constants.length > 1 ? 's' : ''}.' : 'No unknown constants: use the initial conditions.',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 4),
      if (_result == null) SymbolKeypad(controller: _c, prefix: 'ode_key'),
      _Hints(hints: s.hints, onReveal: (_) {}),
      if (_result == null)
        labSubmitButton('ode_submit', () async {
          final TaskResult? r = await gradeLabStep(context, () => OdeGrader.grade(s, _c.text), widget.onGraded);
          if (mounted && r != null) setState(() => _result = r);
        })
      else
        _resultWithRetry(_result!, () => setState(() => _result = null), model: s.model.isEmpty ? const <String>[] : <String>['y = ${s.model}']),
    ]);
  }
}

/// For tests: the grader used by each maths step, without widgets.
TaskResult gradeMathStep(LabStep s, Object answer) => switch (s) {
      WorkingStep() => WorkingChecker.grade(s, (answer as String).split('\n')),
      NumericStep() => NumericGrader.grade(s, answer as Map<String, String>),
      MatrixStep() => MatrixGrader.grade(s, answer as List<List<String>>),
      OdeStep() => OdeGrader.grade(s, answer as String),
      GraphStep() => GraphGrader.grade(s, (answer as (Map<String, double>, Map<String, String>)).$1, answer.$2),
      _ => throw LabGradingException('Not a maths step.'),
    };
