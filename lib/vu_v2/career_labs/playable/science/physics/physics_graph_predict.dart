import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Predict v–t shape BEFORE run, then compare.
class PhysicsGraphPredictLab extends StatefulWidget {
  const PhysicsGraphPredictLab({super.key});

  @override
  State<PhysicsGraphPredictLab> createState() => _PhysicsGraphPredictLabState();
}

enum _VtShape { flat, rising, falling, parabola }

class _PhysicsGraphPredictLabState extends State<PhysicsGraphPredictLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  _VtShape? _prediction;
  bool _ran = false;
  late _VtShape _actual;
  double _force = 12;
  double _mass = 3;
  double _friction = 2;
  String? _feedback;

  _VtShape get _computeActual {
    final double a = (_force - _friction) / _mass;
    if (a.abs() < 0.15) return _VtShape.flat;
    if (a > 0) return _VtShape.rising;
    return _VtShape.falling;
  }

  void _run() {
    if (_prediction == null) {
      setState(() => _feedback = 'Select a predicted v–t shape first.');
      return;
    }
    setState(() {
      _actual = _computeActual;
      _ran = true;
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    if (!_ran || _prediction == null) {
      setState(() => _feedback = 'Predict, then RUN, then submit.');
      return;
    }
    final bool match = _prediction == _actual;
    await _store.addNote(
      'Graph predict: predicted $_prediction · actual $_actual · ${match ? 'match' : 'miss'}',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: match,
      title: match ? 'Prediction matched' : 'Shape mismatch',
      body: match
          ? 'Your v–t prediction matched the run. Nice foresight.'
          : 'Actual was $_actual. Adjust force/friction intuition and retry.',
    );
    if (match && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Graph Predict',
      brief: 'Draw/select predicted v–t BEFORE running, then compare.',
      badgeLabel: 'DATA',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'COMPARE',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          const Text('Dial setup', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          Slider(
            value: _force,
            min: 0,
            max: 25,
            onChanged: (double v) => setState(() {
              _force = v;
              _ran = false;
            }),
            activeColor: t.accent,
          ),
          Text('Force ${_force.toStringAsFixed(0)} N', style: const TextStyle(color: Colors.white54)),
          Slider(
            value: _mass,
            min: 1,
            max: 8,
            onChanged: (double v) => setState(() {
              _mass = v;
              _ran = false;
            }),
            activeColor: t.accent,
          ),
          Text('Mass ${_mass.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white54)),
          Slider(
            value: _friction,
            min: 0,
            max: 15,
            onChanged: (double v) => setState(() {
              _friction = v;
              _ran = false;
            }),
            activeColor: t.accent,
          ),
          Text('Friction ${_friction.toStringAsFixed(0)} N', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 8),
          const Text('Predict v–t shape',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _VtShape.values.map((_VtShape s) {
              return ChoiceChip(
                label: Text(_label(s)),
                selected: _prediction == s,
                selectedColor: t.accent.withValues(alpha: 0.4),
                labelStyle: const TextStyle(color: Colors.white),
                onSelected: (_) => setState(() {
                  _prediction = s;
                  _ran = false;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _run,
            style: OutlinedButton.styleFrom(foregroundColor: t.accent),
            child: const Text('RUN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_ran) ...<Widget>[
            const SizedBox(height: 12),
            sciencePanel(
              surface: t.surface,
              accent: t.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Predicted: ${_label(_prediction!)}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Actual: ${_label(_actual)}',
                      style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: CustomPaint(painter: _VtPainter(_actual, t.accent)),
                  ),
                ],
              ),
            ),
          ],
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  String _label(_VtShape s) {
    switch (s) {
      case _VtShape.flat:
        return 'Flat (a≈0)';
      case _VtShape.rising:
        return 'Rising (a>0)';
      case _VtShape.falling:
        return 'Falling (a<0)';
      case _VtShape.parabola:
        return 'Curved';
    }
  }
}

class _VtPainter extends CustomPainter {
  _VtPainter(this.shape, this.accent);
  final _VtShape shape;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final Path path = Path()..moveTo(0, size.height * 0.5);
    switch (shape) {
      case _VtShape.flat:
        path.lineTo(size.width, size.height * 0.5);
      case _VtShape.rising:
        path.lineTo(size.width, size.height * 0.15);
      case _VtShape.falling:
        path.lineTo(size.width, size.height * 0.85);
      case _VtShape.parabola:
        path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.5);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _VtPainter oldDelegate) =>
      oldDelegate.shape != shape;
}
