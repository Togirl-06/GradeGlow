/// The CAD drawing sheet: a 1 mm grid, outline and hole tools, a dimension
/// tool that references real features, and a title block.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/common.dart';
import '../lab_models.dart';
import '../ui/step_views.dart';
import 'drawing_step.dart';
import '../../ui/gg_kit.dart';

class DrawingView extends StatefulWidget {
  const DrawingView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final DrawingStep step;
  final StepGraded onGraded;
  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  Drawing _d = const Drawing();
  bool _loaded = false;
  final TextEditingController _w = TextEditingController(), _h = TextEditingController();
  final TextEditingController _hx = TextEditingController(), _hy = TextEditingController(), _hd = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _kind = 'h';
  String? _from, _to;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final String? raw = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id];
    if (raw == null || raw.isEmpty) return;
    try {
      _d = Drawing.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (_d.width != null) _w.text = fmtMm(_d.width!);
      if (_d.height != null) _h.text = fmtMm(_d.height!);
    } on Object {
      _d = const Drawing();
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[_w, _h, _hx, _hy, _hd, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save(Drawing d) {
    setState(() => _d = d);
    careerStore(context).saveLabDraft(widget.lab, widget.step.id, jsonEncode(d.toJson()));
  }

  void _toast(String m) => ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(m)));

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _setOutline() {
    final double? w = _num(_w), h = _num(_h);
    if (w == null || h == null || w <= 0 || h <= 0) return _toast('Enter a positive width and height in mm.');
    if (w > 600 || h > 600) return _toast('The sheet holds parts up to 600 mm.');
    _save(_d.copyWith(width: w, height: h));
  }

  void _addHole() {
    final double? x = _num(_hx), y = _num(_hy), dd = _num(_hd);
    if (x == null || y == null || dd == null || dd <= 0) return _toast('Enter the hole centre (x, y) and a positive diameter.');
    _save(_d.copyWith(circles: <DrawCircle>[..._d.circles, DrawCircle(x, y, dd)]));
    _hx.clear();
    _hy.clear();
  }

  void _removeHole(int i) {
    // Dimensions to a removed hole are removed too; later references shift down.
    String shift(String r) {
      if (!r.startsWith('c')) return r;
      final int j = int.parse(r.substring(1));
      return j > i ? 'c${j - 1}' : r;
    }

    final List<DrawDim> dims = <DrawDim>[
      for (final DrawDim m in _d.dims)
        if (m.from != 'c$i' && m.to != 'c$i') DrawDim(m.kind, shift(m.from), shift(m.to), m.note),
    ];
    _save(_d.copyWith(circles: <DrawCircle>[for (int j = 0; j < _d.circles.length; j++) if (j != i) _d.circles[j]], dims: dims));
  }

  List<String> _refs(String kind) => <String>[
        if (kind == 'h') ...<String>['L', 'R'],
        if (kind == 'v') ...<String>['B', 'T'],
        for (int i = 0; i < _d.circles.length; i++) 'c$i',
      ];

  void _addDim() {
    if (_d.width == null) return _toast('Draw the outline first.');
    final List<String> refs = _refs(_kind);
    final String? a = refs.contains(_from) ? _from : null;
    final String? b = refs.contains(_to) ? _to : null;
    if (a == null || (_kind != 'd' && b == null)) return _toast(_kind == 'd' ? 'Choose the hole to dimension.' : 'Choose the two features to dimension between.');
    if (_kind != 'd' && a == b) return _toast('Choose two different features.');
    _save(_d.copyWith(dims: <DrawDim>[..._d.dims, DrawDim(_kind, a, _kind == 'd' ? '' : b!, _note.text.trim())]));
    _note.clear();
  }

  void _tapSheet(Offset local, Size size) {
    if (_d.width == null || _d.height == null) return;
    final _Frame f = _Frame(size, _d.width!, _d.height!);
    final Offset mm = f.toMm(local);
    _hx.text = fmtMm(mm.dx.roundToDouble());
    _hy.text = fmtMm(mm.dy.roundToDouble());
    setState(() {});
  }

  Widget _field(String key, String label, TextEditingController c, {double width = 84}) => SizedBox(
        width: width,
        child: TextField(
          key: ValueKey<String>(key),
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final DrawingStep s = widget.step;
    final List<String> refs = _refs(_kind);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Text('Units: mm. The datum corner (0, 0) is bottom-left. Tap the sheet to pick a hole centre on the 1 mm grid.', style: TextStyle(color: GG.mute, fontSize: 12)),
      const SizedBox(height: 6),
      LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
        final Size size = Size(c.maxWidth, math.min(320, c.maxWidth * 0.7));
        return GestureDetector(
          key: const ValueKey<String>('cad_sheet'),
          onTapUp: (TapUpDetails t) => _tapSheet(t.localPosition, size),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(6)),
            child: CustomPaint(size: size, painter: _SheetPainter(_d)),
          ),
        );
      }),
      const SizedBox(height: 10),
      _section('1. Outline (rectangle from the datum corner)'),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
        _field('cad_w', 'Width', _w),
        _field('cad_h', 'Height', _h),
        OutlinedButton(key: const ValueKey<String>('cad_outline'), onPressed: _setOutline, child: const Text('Set outline')),
      ]),
      const SizedBox(height: 8),
      _section('2. Holes'),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
        _field('cad_hx', 'Centre x', _hx),
        _field('cad_hy', 'Centre y', _hy),
        _field('cad_hd', 'Ø', _hd, width: 70),
        OutlinedButton(key: const ValueKey<String>('cad_add_hole'), onPressed: _addHole, child: const Text('Add hole')),
      ]),
      for (int i = 0; i < _d.circles.length; i++)
        ListTile(
          dense: true,
          key: ValueKey<String>('cad_hole_$i'),
          title: Text('Hole ${i + 1}: Ø${fmtMm(_d.circles[i].d)} at (${fmtMm(_d.circles[i].x)}, ${fmtMm(_d.circles[i].y)})'),
          trailing: IconButton(key: ValueKey<String>('cad_del_hole_$i'), icon: const Icon(Icons.delete_outline), onPressed: () => _removeHole(i)),
        ),
      const SizedBox(height: 8),
      _section('3. Dimensions'),
      Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
        for (final (String k, String label) in const <(String, String)>[('h', 'Horizontal'), ('v', 'Vertical'), ('d', 'Diameter')])
          ChoiceChip(
            key: ValueKey<String>('cad_kind_$k'),
            label: Text(label),
            selected: _kind == k,
            onSelected: (_) => setState(() {
              _kind = k;
              _from = null;
              _to = null;
            }),
          ),
      ]),
      const SizedBox(height: 6),
      Text(_kind == 'd' ? 'Hole' : 'From', style: TextStyle(color: GG.mute, fontSize: 12)),
      Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
        for (final String r in refs.where((String r) => _kind != 'd' || r.startsWith('c')))
          ChoiceChip(key: ValueKey<String>('cad_from_$r'), label: Text(refLabel(r)), selected: _from == r, onSelected: (_) => setState(() => _from = r)),
      ]),
      if (_kind != 'd') ...<Widget>[
        const SizedBox(height: 4),
        Text('To', style: TextStyle(color: GG.mute, fontSize: 12)),
        Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
          for (final String r in refs) ChoiceChip(key: ValueKey<String>('cad_to_$r'), label: Text(refLabel(r)), selected: _to == r, onSelected: (_) => setState(() => _to = r)),
        ]),
      ],
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
        SizedBox(
          width: 200,
          child: TextField(
            key: const ValueKey<String>('cad_note'),
            controller: _note,
            decoration: const InputDecoration(labelText: 'Note / tolerance (e.g. H7, ±0.05, 4×)', isDense: true, border: OutlineInputBorder()),
          ),
        ),
        OutlinedButton(key: const ValueKey<String>('cad_add_dim'), onPressed: _addDim, child: const Text('Add dimension')),
      ]),
      for (int i = 0; i < _d.dims.length; i++)
        ListTile(
          dense: true,
          key: ValueKey<String>('cad_dim_$i'),
          title: Text(_dimText(_d.dims[i])),
          trailing: IconButton(
            key: ValueKey<String>('cad_del_dim_$i'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _save(_d.copyWith(dims: <DrawDim>[for (int j = 0; j < _d.dims.length; j++) if (j != i) _d.dims[j]])),
          ),
        ),
      const SizedBox(height: 8),
      _section('4. Title block'),
      for (final MapEntry<String, List<String>> f in s.titleOptions.entries)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(spacing: 4, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
            SizedBox(width: 80, child: Text(f.key, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w600))),
            for (final String o in f.value)
              ChoiceChip(
                key: ValueKey<String>('cad_title_${f.key}_$o'),
                label: Text(o),
                selected: _d.title[f.key] == o,
                onSelected: (_) => _save(_d.copyWith(title: <String, String>{..._d.title, f.key: o})),
              ),
          ]),
        ),
      const SizedBox(height: 10),
      labSubmitButton('cad_submit', () async {
        await gradeLabStep(context, () => DrawingGrader.grade(s, _d), widget.onGraded);
      }, label: 'Submit drawing for checking'),
    ]);
  }

  String _dimText(DrawDim m) {
    final double? v = _d.value(m);
    final String val = v == null ? '?' : fmtMm(v);
    final String note = m.note.isEmpty ? '' : ' (${m.note})';
    return m.kind == 'd' ? 'Ø$val — ${refLabel(m.from)}$note' : '${m.kind == 'h' ? 'Horizontal' : 'Vertical'} $val: ${refLabel(m.from)} → ${refLabel(m.to)}$note';
  }

  Widget _section(String t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(t, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)));
}

/// Maps millimetres on the part to pixels on the sheet.
class _Frame {
  _Frame(this.size, double w, double h) {
    const double margin = 46;
    scale = math.min((size.width - 2 * margin) / w, (size.height - 2 * margin) / h);
    origin = Offset(margin, size.height - margin);
  }
  final Size size;
  late final double scale;
  late final Offset origin;
  Offset toPx(double x, double y) => Offset(origin.dx + x * scale, origin.dy - y * scale);
  Offset toMm(Offset p) => Offset((p.dx - origin.dx) / scale, (origin.dy - p.dy) / scale);
}

class _SheetPainter extends CustomPainter {
  _SheetPainter(this.d);
  final Drawing d;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()..color = const Color(0xFFE8EEF4);
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (d.width == null || d.height == null) {
      _text(canvas, 'Set the outline to start drawing', Offset(size.width / 2, size.height / 2), const Color(0xFF6B7785), center: true);
      return;
    }
    final _Frame f = _Frame(size, d.width!, d.height!);
    final Paint line = Paint()
      ..color = const Color(0xFF1B2733)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromPoints(f.toPx(0, 0), f.toPx(d.width!, d.height!)), line);
    final Paint centre = Paint()
      ..color = const Color(0xFF8A96A3)
      ..strokeWidth = 0.8;
    for (int i = 0; i < d.circles.length; i++) {
      final DrawCircle c = d.circles[i];
      final Offset p = f.toPx(c.x, c.y);
      canvas.drawCircle(p, c.d / 2 * f.scale, line);
      final double r = c.d / 2 * f.scale + 4;
      canvas.drawLine(p - Offset(r, 0), p + Offset(r, 0), centre);
      canvas.drawLine(p - Offset(0, r), p + Offset(0, r), centre);
      _text(canvas, '${i + 1}', p + Offset(r, -r), const Color(0xFF6B7785));
    }
    final Paint dim = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 1;
    int hRow = 0, vRow = 0;
    for (final DrawDim m in d.dims) {
      final double? v = d.value(m);
      if (v == null) continue;
      final String label = '${m.kind == 'd' ? 'Ø' : ''}${fmtMm(v)}${m.note.isEmpty ? '' : ' ${m.note}'}';
      if (m.kind == 'd') {
        final DrawCircle c = d.circles[int.parse(m.from.substring(1))];
        final Offset p = f.toPx(c.x, c.y);
        final Offset q = p + Offset(c.d / 2 * f.scale * 0.7, -c.d / 2 * f.scale * 0.7);
        canvas.drawLine(q, q + const Offset(18, -18), dim);
        _text(canvas, label, q + const Offset(20, -30), const Color(0xFF1565C0));
      } else if (m.kind == 'h') {
        final double a = d.coord(m.from, 'x')!, b = d.coord(m.to, 'x')!;
        final double y = f.origin.dy + 14 + 12 * hRow++;
        final Offset p1 = Offset(f.toPx(a, 0).dx, y), p2 = Offset(f.toPx(b, 0).dx, y);
        canvas.drawLine(p1, p2, dim);
        _arrow(canvas, p1, p2, dim);
        _text(canvas, label, Offset((p1.dx + p2.dx) / 2, y - 11), const Color(0xFF1565C0), center: true);
      } else {
        final double a = d.coord(m.from, 'y')!, b = d.coord(m.to, 'y')!;
        final double x = f.origin.dx - 14 - 12 * vRow++;
        final Offset p1 = Offset(x, f.toPx(0, a).dy), p2 = Offset(x, f.toPx(0, b).dy);
        canvas.drawLine(p1, p2, dim);
        _arrow(canvas, p1, p2, dim);
        _text(canvas, label, Offset(x - 2, (p1.dy + p2.dy) / 2 - 6), const Color(0xFF1565C0), right: true);
      }
    }
  }

  void _arrow(Canvas c, Offset a, Offset b, Paint p) {
    for (final (Offset tip, Offset from) in <(Offset, Offset)>[(a, b), (b, a)]) {
      final Offset dir = from - tip;
      final double len = dir.distance;
      if (len < 1) continue;
      final Offset u = dir / len;
      final Offset n = Offset(-u.dy, u.dx);
      c.drawLine(tip, tip + u * 6 + n * 3, p);
      c.drawLine(tip, tip + u * 6 - n * 3, p);
    }
  }

  void _text(Canvas c, String t, Offset at, Color color, {bool center = false, bool right = false}) {
    final TextPainter tp = TextPainter(text: TextSpan(text: t, style: TextStyle(color: color, fontSize: 10)), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(center ? at.dx - tp.width / 2 : right ? at.dx - tp.width : at.dx, at.dy));
  }

  @override
  bool shouldRepaint(_SheetPainter old) => old.d != d;
}
