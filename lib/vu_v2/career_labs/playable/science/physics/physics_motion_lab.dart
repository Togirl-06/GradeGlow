import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Mass / force / friction / v0 → RUN → readouts + auto graphs.
class PhysicsMotionLab extends StatefulWidget {
  const PhysicsMotionLab({super.key});

  @override
  State<PhysicsMotionLab> createState() => _PhysicsMotionLabState();
}

class _PhysicsMotionLabState extends State<PhysicsMotionLab>
    with SingleTickerProviderStateMixin {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  double _mass = 2;
  double _force = 10;
  double _friction = 2;
  double _v0 = 0;
  bool _ran = false;
  final List<Offset> _xSeries = <Offset>[];
  final List<Offset> _vSeries = <Offset>[];
  final List<Offset> _aSeries = <Offset>[];
  final TextEditingController _explain = TextEditingController();
  String? _feedback;

  double get _accel {
    final double net = _force - _friction;
    return net / _mass;
  }

  double get _vNow => _ran ? _v0 + _accel * 2.0 : _v0;
  double get _xNow => _ran ? _v0 * 2 + 0.5 * _accel * 4 : 0;

  void _run() {
    _xSeries.clear();
    _vSeries.clear();
    _aSeries.clear();
    const double dt = 0.1;
    double v = _v0;
    double x = 0;
    final double a = _accel;
    for (int i = 0; i <= 40; i++) {
      final double time = i * dt;
      _xSeries.add(Offset(time, x));
      _vSeries.add(Offset(time, v));
      _aSeries.add(Offset(time, a));
      v += a * dt;
      x += v * dt;
    }
    setState(() {
      _ran = true;
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    if (!_ran) {
      setState(() => _feedback = 'RUN the cart before explaining.');
      return;
    }
    final String e = _explain.text.toLowerCase();
    if (!(e.contains('force') || e.contains('mass') || e.contains('friction') || e.contains('acceler'))) {
      setState(() => _feedback = 'Use force, mass, friction, or acceleration in your explanation.');
      return;
    }
    await _store.addNote(
      'Motion: m=$_mass F=$_force f=$_friction → a=${_accel.toStringAsFixed(2)}',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Motion logged',
      body: 'a = ${_accel.toStringAsFixed(2)} m/s² with graphs captured.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Motion Track',
      brief: 'Set mass, force, friction, v₀ — RUN — read position/velocity/accel.',
      badgeLabel: 'MOTION',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'SUBMIT EXPLANATION',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          sciencePanel(
            surface: t.surface,
            accent: t.accent,
            child: Text(
              'x≈${_xNow.toStringAsFixed(2)} m · v≈${_vNow.toStringAsFixed(2)} m/s · a=${_accel.toStringAsFixed(2)} m/s²',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          _slider('Mass (kg)', _mass, 0.5, 8, (double v) => setState(() => _mass = v)),
          _slider('Force (N)', _force, 0, 30, (double v) => setState(() => _force = v)),
          _slider('Friction (N)', _friction, 0, 15, (double v) => setState(() => _friction = v)),
          _slider('v₀ (m/s)', _v0, 0, 10, (double v) => setState(() => _v0 = v)),
          OutlinedButton(
            onPressed: _run,
            style: OutlinedButton.styleFrom(foregroundColor: t.accent),
            child: const Text('RUN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_ran) ...<Widget>[
            const SizedBox(height: 10),
            _graph('x–t', _xSeries),
            _graph('v–t', _vSeries),
            _graph('a–t', _aSeries),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _explain,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Explain the motion',
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

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label: ${value.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: t.accent),
      ],
    );
  }

  Widget _graph(String title, List<Offset> pts) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: t.accent, fontWeight: FontWeight.w800, fontSize: 12)),
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(painter: _SeriesPainter(pts, t.accent)),
          ),
        ],
      ),
    );
  }
}

class _SeriesPainter extends CustomPainter {
  _SeriesPainter(this.pts, this.accent);
  final List<Offset> pts;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    double minY = pts.first.dy, maxY = pts.first.dy;
    double maxX = pts.last.dx;
    for (final Offset p in pts) {
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (maxY == minY) maxY = minY + 1;
    if (maxX == 0) maxX = 1;
    final Path path = Path();
    for (int i = 0; i < pts.length; i++) {
      final double x = pts[i].dx / maxX * size.width;
      final double y = size.height - ((pts[i].dy - minY) / (maxY - minY) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SeriesPainter oldDelegate) => true;
}
