import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Amplitude / frequency / wavelength; predict then run; λ vs f question.
class PhysicsWaveLab extends StatefulWidget {
  const PhysicsWaveLab({super.key});

  @override
  State<PhysicsWaveLab> createState() => _PhysicsWaveLabState();
}

class _PhysicsWaveLabState extends State<PhysicsWaveLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  double _amp = 1;
  double _freq = 2;
  static const double _speed = 10; // m/s fixed medium
  String? _lambdaPredict; // 'increase' | 'decrease' | 'same'
  bool _ran = false;
  final TextEditingController _answer = TextEditingController();
  String? _feedback;

  double get _lambda => _speed / _freq;

  void _run() {
    if (_lambdaPredict == null) {
      setState(() => _feedback = 'Predict what happens to wavelength if frequency increases.');
      return;
    }
    setState(() {
      _ran = true;
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    if (!_ran) {
      setState(() => _feedback = 'Predict, then RUN the wave.');
      return;
    }
    final bool predOk = _lambdaPredict == 'decrease';
    final String a = _answer.text.toLowerCase();
    final bool textOk = a.contains('decreas') ||
        a.contains('shorter') ||
        a.contains('inversely') ||
        (a.contains('down') && a.contains('wave'));
    if (!predOk || !textOk) {
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Check λ–f link',
        body: 'In a fixed medium, v = fλ is constant — raising f shortens λ.',
      );
      return;
    }
    await _store.addNote(
      'Wave: A=$_amp f=$_freq → λ=${_lambda.toStringAsFixed(2)} (f↑ ⇒ λ↓)',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Wave relation locked',
      body: 'λ = v/f = ${_lambda.toStringAsFixed(2)} m. Frequency up → wavelength down.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Wave Tank',
      brief: 'Set A & f, predict λ change, run, explain.',
      badgeLabel: 'WAVES',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'SUBMIT',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2,
            child: sciencePanel(
              surface: t.surface,
              accent: t.accent,
              padding: EdgeInsets.zero,
              child: CustomPaint(
                painter: _WavePainter(
                  amp: _amp,
                  freq: _freq,
                  accent: t.accent,
                  running: _ran,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Text(
            'λ ≈ ${_lambda.toStringAsFixed(2)} m (v=$_speed m/s)',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w900),
          ),
          Text('Amplitude ${_amp.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white70)),
          Slider(
            value: _amp,
            min: 0.3,
            max: 2.5,
            onChanged: (double v) => setState(() {
              _amp = v;
              _ran = false;
            }),
            activeColor: t.accent,
          ),
          Text('Frequency ${_freq.toStringAsFixed(1)} Hz',
              style: const TextStyle(color: Colors.white70)),
          Slider(
            value: _freq,
            min: 0.5,
            max: 6,
            onChanged: (double v) => setState(() {
              _freq = v;
              _ran = false;
            }),
            activeColor: t.accent,
          ),
          const SizedBox(height: 8),
          const Text('If frequency increases, wavelength will…',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          Wrap(
            spacing: 8,
            children: <String>['increase', 'decrease', 'same'].map((String s) {
              return ChoiceChip(
                label: Text(s),
                selected: _lambdaPredict == s,
                selectedColor: t.accent.withValues(alpha: 0.4),
                labelStyle: const TextStyle(color: Colors.white),
                onSelected: (_) => setState(() {
                  _lambdaPredict = s;
                  _ran = false;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _run,
            style: OutlinedButton.styleFrom(foregroundColor: t.accent),
            child: const Text('RUN WAVE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answer,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Explain λ when f increases',
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
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.amp,
    required this.freq,
    required this.accent,
    required this.running,
  });

  final double amp;
  final double freq;
  final Color accent;
  final bool running;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = accent.withValues(alpha: running ? 1 : 0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Path path = Path();
    final double mid = size.height / 2;
    final double k = freq * 0.9;
    for (double x = 0; x <= size.width; x += 2) {
      final double y = mid - math.sin(x / size.width * k * math.pi * 2) * amp * 18;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
