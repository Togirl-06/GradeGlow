import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum DrawTool { pen, highlighter, arrow, text, circle, rect, eraser }

class DrawnStroke {
  DrawnStroke({
    required this.tool,
    required this.color,
    required this.width,
    required this.points,
    this.text,
    this.rect,
  });

  final DrawTool tool;
  final Color color;
  final double width;
  final List<Offset> points;
  final String? text;
  final Rect? rect;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tool': tool.name,
        'color': color.toARGB32(),
        'width': width,
        'points': points
            .map((Offset p) => <String, double>{'dx': p.dx, 'dy': p.dy})
            .toList(),
        if (text != null) 'text': text,
        if (rect != null)
          'rect': <String, double>{
            'l': rect!.left,
            't': rect!.top,
            'r': rect!.right,
            'b': rect!.bottom,
          },
      };

  factory DrawnStroke.fromJson(Map<String, dynamic> json) {
    final List<dynamic> pts = json['points'] as List<dynamic>? ?? const <dynamic>[];
    Rect? r;
    final dynamic rawRect = json['rect'];
    if (rawRect is Map) {
      r = Rect.fromLTRB(
        (rawRect['l'] as num).toDouble(),
        (rawRect['t'] as num).toDouble(),
        (rawRect['r'] as num).toDouble(),
        (rawRect['b'] as num).toDouble(),
      );
    }
    return DrawnStroke(
      tool: DrawTool.values.firstWhere(
        (DrawTool t) => t.name == json['tool'],
        orElse: () => DrawTool.pen,
      ),
      color: Color(json['color'] as int? ?? 0xFFFFFFFF),
      width: (json['width'] as num?)?.toDouble() ?? 3,
      points: pts
          .whereType<Map>()
          .map(
            (Map e) => Offset(
              (e['dx'] as num).toDouble(),
              (e['dy'] as num).toDouble(),
            ),
          )
          .toList(),
      text: json['text'] as String?,
      rect: r,
    );
  }
}

/// Full annotation toolkit; transparent overlay can sit on a child diagram.
class ScienceDrawingCanvas extends StatefulWidget {
  const ScienceDrawingCanvas({
    super.key,
    this.child,
    this.accent = const Color(0xFF4ADE80),
    this.initialStrokes = const <DrawnStroke>[],
    this.onSubmit,
    this.height,
  });

  final Widget? child;
  final Color accent;
  final List<DrawnStroke> initialStrokes;
  final void Function(List<DrawnStroke> strokes)? onSubmit;
  final double? height;

  @override
  State<ScienceDrawingCanvas> createState() => ScienceDrawingCanvasState();
}

class ScienceDrawingCanvasState extends State<ScienceDrawingCanvas> {
  final List<DrawnStroke> _strokes = <DrawnStroke>[];
  final List<DrawnStroke> _redo = <DrawnStroke>[];

  DrawTool _tool = DrawTool.pen;
  Color _color = const Color(0xFFE2E8F0);
  double _width = 3;
  DrawnStroke? _active;
  Offset? _shapeOrigin;

  List<DrawnStroke> get strokes => List<DrawnStroke>.unmodifiable(_strokes);

  @override
  void initState() {
    super.initState();
    _strokes.addAll(widget.initialStrokes);
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _redo.clear();
      _active = null;
    });
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redo.add(_strokes.removeLast());
    });
  }

  void redo() {
    if (_redo.isEmpty) return;
    setState(() {
      _strokes.add(_redo.removeLast());
    });
  }

  Future<void> _promptText(Offset at) async {
    final TextEditingController ctrl = TextEditingController();
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text('Annotation text', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Label…',
              hintStyle: TextStyle(color: Colors.white54),
            ),
            onSubmitted: (String v) => Navigator.pop(ctx, v),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: Text('Add', style: TextStyle(color: widget.accent)),
            ),
          ],
        );
      },
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    setState(() {
      _strokes.add(
        DrawnStroke(
          tool: DrawTool.text,
          color: _color,
          width: _width,
          points: <Offset>[at],
          text: text.trim(),
        ),
      );
      _redo.clear();
    });
  }

  void _onPanStart(DragStartDetails d) {
    final Offset p = d.localPosition;
    if (_tool == DrawTool.text) {
      _promptText(p);
      return;
    }
    _shapeOrigin = p;
    _active = DrawnStroke(
      tool: _tool,
      color: _tool == DrawTool.highlighter
          ? _color.withValues(alpha: 0.35)
          : (_tool == DrawTool.eraser ? const Color(0x00000000) : _color),
      width: _tool == DrawTool.highlighter ? _width * 3 : _width,
      points: <Offset>[p],
      rect: _tool == DrawTool.circle || _tool == DrawTool.rect
          ? Rect.fromPoints(p, p)
          : null,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final DrawnStroke? active = _active;
    if (active == null) return;
    final Offset p = d.localPosition;
    setState(() {
      if (active.tool == DrawTool.circle || active.tool == DrawTool.rect) {
        final Offset o = _shapeOrigin ?? p;
        _active = DrawnStroke(
          tool: active.tool,
          color: active.color,
          width: active.width,
          points: <Offset>[o, p],
          rect: Rect.fromPoints(o, p),
        );
      } else if (active.tool == DrawTool.arrow) {
        final Offset o = _shapeOrigin ?? p;
        _active = DrawnStroke(
          tool: active.tool,
          color: active.color,
          width: active.width,
          points: <Offset>[o, p],
        );
      } else {
        active.points.add(p);
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final DrawnStroke? active = _active;
    if (active == null) return;
    setState(() {
      if (active.tool == DrawTool.eraser) {
        _eraseNear(active.points);
      } else {
        _strokes.add(active);
        _redo.clear();
      }
      _active = null;
      _shapeOrigin = null;
    });
  }

  void _eraseNear(List<Offset> path) {
    const double hit = 18;
    _strokes.removeWhere((DrawnStroke s) {
      for (final Offset a in s.points) {
        for (final Offset b in path) {
          if ((a - b).distance <= hit + s.width) return true;
        }
      }
      if (s.rect != null) {
        for (final Offset b in path) {
          if (s.rect!.inflate(hit).contains(b)) return true;
        }
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Toolbar(
          tool: _tool,
          color: _color,
          width: _width,
          accent: widget.accent,
          canUndo: _strokes.isNotEmpty,
          canRedo: _redo.isNotEmpty,
          onTool: (DrawTool t) => setState(() => _tool = t),
          onColor: (Color c) => setState(() => _color = c),
          onWidth: (double w) => setState(() => _width = w),
          onUndo: undo,
          onRedo: redo,
          onClear: clear,
          onSubmit: widget.onSubmit == null
              ? null
              : () => widget.onSubmit!(strokes),
        ),
        Expanded(
          child: SizedBox(
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (widget.child != null) widget.child!,
                  if (widget.child == null)
                    ColoredBox(
                      color: const Color(0xFF020617).withValues(alpha: 0.55),
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _StrokePainter(
                          strokes: <DrawnStroke>[
                            ..._strokes,
                            ?_active,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.tool,
    required this.color,
    required this.width,
    required this.accent,
    required this.canUndo,
    required this.canRedo,
    required this.onTool,
    required this.onColor,
    required this.onWidth,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    this.onSubmit,
  });

  final DrawTool tool;
  final Color color;
  final double width;
  final Color accent;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<DrawTool> onTool;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onWidth;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback? onSubmit;

  static const List<Color> _palette = <Color>[
    Color(0xFFE2E8F0),
    Color(0xFF4ADE80),
    Color(0xFFE879F9),
    Color(0xFFA78BFA),
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    Color(0xFFF87171),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final DrawTool t in DrawTool.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _ToolBtn(
                      selected: tool == t,
                      accent: accent,
                      icon: _icon(t),
                      tip: t.name,
                      onTap: () => onTool(t),
                    ),
                  ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Undo',
                  onPressed: canUndo ? onUndo : null,
                  icon: Icon(Icons.undo, color: canUndo ? accent : Colors.white24),
                ),
                IconButton(
                  tooltip: 'Redo',
                  onPressed: canRedo ? onRedo : null,
                  icon: Icon(Icons.redo, color: canRedo ? accent : Colors.white24),
                ),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                ),
                if (onSubmit != null)
                  TextButton(
                    onPressed: onSubmit,
                    child: Text('Submit', style: TextStyle(color: accent)),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              for (final Color c in _palette)
                GestureDetector(
                  onTap: () => onColor(c),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == c ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Slider(
                  value: width.clamp(1, 16),
                  min: 1,
                  max: 16,
                  activeColor: accent,
                  onChanged: onWidth,
                ),
              ),
              Text(
                '${width.round()}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _icon(DrawTool t) {
    switch (t) {
      case DrawTool.pen:
        return Icons.edit;
      case DrawTool.highlighter:
        return Icons.highlight;
      case DrawTool.arrow:
        return Icons.north_east;
      case DrawTool.text:
        return Icons.text_fields;
      case DrawTool.circle:
        return Icons.circle_outlined;
      case DrawTool.rect:
        return Icons.crop_square;
      case DrawTool.eraser:
        return Icons.auto_fix_off;
    }
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.selected,
    required this.accent,
    required this.icon,
    required this.tip,
    required this.onTap,
  });

  final bool selected;
  final Color accent;
  final IconData icon;
  final String tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accent : Colors.white12,
            ),
          ),
          child: Icon(icon, size: 18, color: selected ? accent : Colors.white70),
        ),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.strokes});

  final List<DrawnStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final DrawnStroke s in strokes) {
      switch (s.tool) {
        case DrawTool.pen:
        case DrawTool.highlighter:
          _paintPath(canvas, s);
        case DrawTool.eraser:
          break;
        case DrawTool.arrow:
          _paintArrow(canvas, s);
        case DrawTool.circle:
          if (s.rect != null) {
            canvas.drawOval(
              s.rect!,
              Paint()
                ..color = s.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = s.width,
            );
          }
        case DrawTool.rect:
          if (s.rect != null) {
            canvas.drawRect(
              s.rect!,
              Paint()
                ..color = s.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = s.width,
            );
          }
        case DrawTool.text:
          if (s.points.isEmpty || s.text == null) break;
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: s.text,
              style: TextStyle(
                color: s.color,
                fontSize: 14 + s.width,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(canvas, s.points.first);
      }
    }
  }

  void _paintPath(Canvas canvas, DrawnStroke s) {
    if (s.points.isEmpty) return;
    final Paint paint = Paint()
      ..color = s.color
      ..strokeWidth = s.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode =
          s.tool == DrawTool.highlighter ? BlendMode.plus : BlendMode.srcOver;
    if (s.points.length == 1) {
      canvas.drawCircle(s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
      return;
    }
    final Path path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
    for (int i = 1; i < s.points.length; i++) {
      path.lineTo(s.points[i].dx, s.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _paintArrow(Canvas canvas, DrawnStroke s) {
    if (s.points.length < 2) return;
    final Offset a = s.points.first;
    final Offset b = s.points.last;
    final Paint paint = Paint()
      ..color = s.color
      ..strokeWidth = s.width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, paint);
    final Offset dir = b - a;
    final double len = dir.distance;
    if (len < 1) return;
    final Offset u = dir / len;
    final Offset n = Offset(-u.dy, u.dx);
    final double head = math.max(10, s.width * 3);
    final Offset p1 = b - u * head + n * (head * 0.45);
    final Offset p2 = b - u * head - n * (head * 0.45);
    canvas.drawLine(b, p1, paint);
    canvas.drawLine(b, p2, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
