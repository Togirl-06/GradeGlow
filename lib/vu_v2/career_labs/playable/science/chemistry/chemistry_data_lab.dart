import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Enter measurements → table → graph type → conclusion.
class ChemistryDataLab extends StatefulWidget {
  const ChemistryDataLab({super.key});

  @override
  State<ChemistryDataLab> createState() => _ChemistryDataLabState();
}

class _ChemistryDataLabState extends State<ChemistryDataLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  final List<TextEditingController> _x = List<TextEditingController>.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _y = List<TextEditingController>.generate(
    4,
    (_) => TextEditingController(),
  );
  String _graph = 'line';
  final TextEditingController _conclusion = TextEditingController();
  String? _feedback;

  List<(double, double)> get _points {
    final List<(double, double)> out = <(double, double)>[];
    for (int i = 0; i < 4; i++) {
      final double? a = double.tryParse(_x[i].text.trim());
      final double? b = double.tryParse(_y[i].text.trim());
      if (a != null && b != null) out.add((a, b));
    }
    return out;
  }

  Future<void> _submit() async {
    final List<(double, double)> pts = _points;
    if (pts.length < 3) {
      setState(() => _feedback = 'Enter at least 3 (x, y) measurement pairs.');
      return;
    }
    if (_conclusion.text.trim().length < 12) {
      setState(() => _feedback = 'Write a conclusion about the trend.');
      return;
    }
    final String c = _conclusion.text.toLowerCase();
    final bool trendWord = c.contains('increas') ||
        c.contains('decreas') ||
        c.contains('linear') ||
        c.contains('propor') ||
        c.contains('trend');
    if (!trendWord) {
      setState(() => _feedback = 'Mention the trend (increase / decrease / linear…).');
      return;
    }
    await _store.addNote(
      'Data lab: ${pts.length} points, $_graph graph — ${_conclusion.text.trim()}',
    );
    await _store.addDataTable(<String, dynamic>{
      'title': 'Chemistry measurements',
      'points': pts.map(((double, double) p) => <double>[p.$1, p.$2]).toList(),
    });
    await _store.addGraphMeta(<String, dynamic>{
      'title': '$_graph graph',
      'kind': _graph,
    });
    await _store.addConclusion(_conclusion.text.trim());
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Data accepted',
      body: 'Table + $_graph graph + conclusion filed in the notebook.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    for (final TextEditingController c in _x) {
      c.dispose();
    }
    for (final TextEditingController c in _y) {
      c.dispose();
    }
    _conclusion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Data Bench',
      brief: 'Enter measurements, choose a graph, write a conclusion.',
      badgeLabel: 'DATA',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'SUBMIT DATA',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          const Text('Measurements (time / volume vs reading)',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...List<Widget>.generate(4, (int i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(child: _num(_x[i], 'x${i + 1}')),
                  const SizedBox(width: 8),
                  Expanded(child: _num(_y[i], 'y${i + 1}')),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text('Graph type',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: <String>['line', 'bar', 'scatter'].map((String g) {
              return ChoiceChip(
                label: Text(g),
                selected: _graph == g,
                selectedColor: t.accent.withValues(alpha: 0.4),
                labelStyle: const TextStyle(color: Colors.white),
                onSelected: (_) => setState(() => _graph = g),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.6,
            child: sciencePanel(
              surface: t.surface,
              accent: t.accent,
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                painter: _MiniGraphPainter(
                  points: _points,
                  accent: t.accent,
                  kind: _graph,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conclusion,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Conclusion',
              labelStyle: TextStyle(color: t.accent),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _num(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: t.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }
}

class _MiniGraphPainter extends CustomPainter {
  _MiniGraphPainter({required this.points, required this.accent, required this.kind});
  final List<(double, double)> points;
  final Color accent;
  final String kind;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(24, size.height - 16), Offset(size.width - 8, size.height - 16), axis);
    canvas.drawLine(Offset(24, 8), Offset(24, size.height - 16), axis);
    if (points.isEmpty) return;

    double minX = points.first.$1, maxX = points.first.$1;
    double minY = points.first.$2, maxY = points.first.$2;
    for (final (double x, double y) in points) {
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    if (maxX == minX) maxX = minX + 1;
    if (maxY == minY) maxY = minY + 1;

    Offset map((double x, double y) p) {
      final double nx = (p.$1 - minX) / (maxX - minX);
      final double ny = (p.$2 - minY) / (maxY - minY);
      return Offset(24 + nx * (size.width - 40), size.height - 16 - ny * (size.height - 32));
    }

    final Paint p = Paint()
      ..color = accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final List<Offset> pts = points.map(map).toList();
    if (kind == 'bar') {
      for (final Offset o in pts) {
        canvas.drawLine(Offset(o.dx, size.height - 16), o, p..strokeWidth = 8);
      }
    } else {
      if (kind == 'line' && pts.length >= 2) {
        for (int i = 0; i < pts.length - 1; i++) {
          canvas.drawLine(pts[i], pts[i + 1], p);
        }
      }
      for (final Offset o in pts) {
        canvas.drawCircle(o, 4, Paint()..color = accent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGraphPainter oldDelegate) => true;
}
