import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Move light / lens / screen until focused image; success when aligned.
class PhysicsOpticsLab extends StatefulWidget {
  const PhysicsOpticsLab({super.key});

  @override
  State<PhysicsOpticsLab> createState() => _PhysicsOpticsLabState();
}

class _PhysicsOpticsLabState extends State<PhysicsOpticsLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  double _lightX = 0.12;
  double _lensX = 0.45;
  double _screenX = 0.85;
  String? _feedback;

  // Thin lens: 1/f = 1/u + 1/v with f fixed in normalized bench units
  static const double _f = 0.18;

  double get _u => (_lensX - _lightX).clamp(0.05, 1.0);
  double get _idealV {
    // 1/v = 1/f - 1/u
    final double inv = (1 / _f) - (1 / _u);
    if (inv <= 0) return 0.9;
    return (1 / inv).clamp(0.08, 0.9);
  }

  double get _actualV => (_screenX - _lensX).clamp(0.05, 1.0);

  bool get _focused => (_actualV - _idealV).abs() < 0.045 && _u > _f;

  Future<void> _submit() async {
    if (!_focused) {
      setState(() => _feedback = 'Move light, lens, and screen until the image sharpens.');
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Not focused',
        body: 'Align so screen distance matches the lens equation for this object distance.',
      );
      return;
    }
    await _store.addNote(
      'Optics: focused u=${_u.toStringAsFixed(2)} v=${_actualV.toStringAsFixed(2)} f=$_f',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Image focused',
      body: 'Sharp image on the screen. Lens equation satisfied.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Optics Bench',
      brief: 'Slide light, lens, and screen until the image focuses.',
      badgeLabel: 'OPTICS',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: _focused ? 'LOCK FOCUS' : 'CHECK FOCUS',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.8,
            child: sciencePanel(
              surface: t.surface,
              accent: t.accent,
              padding: EdgeInsets.zero,
              child: CustomPaint(
                painter: _OpticsPainter(
                  lightX: _lightX,
                  lensX: _lensX,
                  screenX: _screenX,
                  focused: _focused,
                  accent: t.accent,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Text(
            _focused ? 'FOCUSED' : 'Blurry — keep aligning',
            style: TextStyle(
              color: _focused ? const Color(0xFF34D399) : Colors.white54,
              fontWeight: FontWeight.w900,
            ),
          ),
          _slide('Light', _lightX, (double v) => setState(() => _lightX = v.clamp(0.05, _lensX - 0.08))),
          _slide('Lens', _lensX, (double v) => setState(() {
                _lensX = v.clamp(_lightX + 0.08, _screenX - 0.08);
              })),
          _slide('Screen', _screenX, (double v) => setState(() => _screenX = v.clamp(_lensX + 0.08, 0.95))),
          if (_feedback != null)
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
        ],
      ),
    );
  }

  Widget _slide(String label, double value, ValueChanged<double> onC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        Slider(value: value, min: 0.05, max: 0.95, onChanged: onC, activeColor: t.accent),
      ],
    );
  }
}

class _OpticsPainter extends CustomPainter {
  _OpticsPainter({
    required this.lightX,
    required this.lensX,
    required this.screenX,
    required this.focused,
    required this.accent,
  });

  final double lightX;
  final double lensX;
  final double screenX;
  final bool focused;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height * 0.55;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1,
    );

    final Offset light = Offset(lightX * size.width, y);
    final Offset lens = Offset(lensX * size.width, y);
    final Offset screen = Offset(screenX * size.width, y);

    canvas.drawCircle(light, 10, Paint()..color = const Color(0xFFFDE047));
    canvas.drawLine(
      Offset(lens.dx, y - 40),
      Offset(lens.dx, y + 40),
      Paint()
        ..color = accent
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(screen.dx, y - 36),
      Offset(screen.dx, y + 36),
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 2,
    );

    final Paint ray = Paint()
      ..color = focused ? const Color(0xFF34D399) : accent.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(light, lens, ray);
    canvas.drawLine(lens, Offset(screen.dx, y + (focused ? 0 : 18)), ray);
    canvas.drawLine(lens, Offset(screen.dx, y - (focused ? 0 : 18)), ray);

    if (focused) {
      canvas.drawCircle(screen, 6, Paint()..color = const Color(0xFF34D399));
    }
  }

  @override
  bool shouldRepaint(covariant _OpticsPainter oldDelegate) => true;
}
