import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/science_badges.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import 'biology_station_chrome.dart';

/// Ecosystem sliders → animated population graph → keyword conclusion.
class BiologyEcologyLab extends StatefulWidget {
  const BiologyEcologyLab({super.key});

  @override
  State<BiologyEcologyLab> createState() => _BiologyEcologyLabState();
}

class _BiologyEcologyLabState extends State<BiologyEcologyLab>
    with SingleTickerProviderStateMixin {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _nb = ScienceNotebookStore('biology');

  double _temp = 0.5;
  double _water = 0.5;
  double _sun = 0.5;
  double _food = 0.55;
  double _prey = 0.55;
  double _pred = 0.35;

  List<double> _preySeries = <double>[];
  List<double> _predSeries = <double>[];
  bool _ran = false;
  late AnimationController _anim;
  final TextEditingController _conclusion = TextEditingController();
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _anim.dispose();
    _conclusion.dispose();
    super.dispose();
  }

  void _runSim() {
    final List<double> prey = <double>[_prey];
    final List<double> pred = <double>[_pred];
    double p = _prey;
    double d = _pred;
    for (int i = 0; i < 24; i++) {
      final double climate =
          (_temp * 0.25 + _water * 0.25 + _sun * 0.25 + _food * 0.25);
      final double growth = (climate - 0.35) * 0.18 - d * 0.12;
      final double predGrowth = p * 0.1 - (1 - climate) * 0.08 - 0.02;
      p = (p + growth).clamp(0.05, 1.0);
      d = (d + predGrowth).clamp(0.02, 0.95);
      // Heat stress crash
      if (_temp > 0.85 && _water < 0.35) {
        p = (p * 0.92).clamp(0.05, 1);
      }
      prey.add(p);
      pred.add(d);
    }
    setState(() {
      _preySeries = prey;
      _predSeries = pred;
      _ran = true;
      _feedback = null;
    });
    _anim.forward(from: 0);
  }

  Future<void> _submit() async {
    final String c = _conclusion.text.toLowerCase();
    final bool keywords = (c.contains('prey') ||
            c.contains('predator') ||
            c.contains('population')) &&
        (c.contains('temp') ||
            c.contains('water') ||
            c.contains('sun') ||
            c.contains('food') ||
            c.contains('resource') ||
            c.contains('climate'));
    if (!_ran) {
      setState(() => _feedback = 'Run the simulation before writing a conclusion.');
      return;
    }
    if (!keywords || c.length < 28) {
      setState(() {
        _feedback =
            'Conclusion must link climate/resources to prey and predator populations.';
      });
      return;
    }
    await _nb.addConclusion(_conclusion.text.trim());
    await _nb.addGraphMeta(<String, dynamic>{
      'title': 'Ecology population run',
      'prey': _preySeries,
      'predator': _predSeries,
    });
    await _nb.awardXp(40, coins: 12);
    await _nb.unlockBadge(ScienceBadges.ecosystemWatcher);
    await _nb.markComplete('ecology');
    if (!mounted) return;
    await showBioResult(
      context: context,
      passed: true,
      title: 'Ecosystem watcher',
      body: 'Simulation analyzed and conclusion recorded in your notebook.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final int visible = _ran
        ? math.max(2, (_anim.value * _preySeries.length).floor())
        : 0;
    return BiologyStationScaffold(
      title: 'Ecology Tank',
      brief: 'Dial abiotic factors, run the sim, explain the curve.',
      badgeLabel: 'ECO',
      footer: bioPrimaryButton(label: 'SUBMIT CONCLUSION', onPressed: _submit),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          bioPanel(
            child: SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _PopGraphPainter(
                  prey: _ran ? _preySeries.sublist(0, visible) : const <double>[],
                  pred: _ran ? _predSeries.sublist(0, visible) : const <double>[],
                  accent: t.accent,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _runSim,
            style: FilledButton.styleFrom(
              foregroundColor: t.accent,
              backgroundColor: t.accent.withValues(alpha: 0.15),
            ),
            child: const Text('RUN SIMULATION', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          _sl('Temperature', _temp, (double v) => setState(() => _temp = v)),
          _sl('Water', _water, (double v) => setState(() => _water = v)),
          _sl('Sunlight', _sun, (double v) => setState(() => _sun = v)),
          _sl('Food', _food, (double v) => setState(() => _food = v)),
          _sl('Prey population', _prey, (double v) => setState(() => _prey = v)),
          _sl('Predator population', _pred, (double v) => setState(() => _pred = v)),
          TextField(
            controller: _conclusion,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Conclusion',
              labelStyle: TextStyle(color: t.accent),
              hintText: 'How did temperature/water/food shift prey vs predators?',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _sl(String label, double v, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        Slider(value: v, onChanged: on, activeColor: t.accent),
      ],
    );
  }
}

class _PopGraphPainter extends CustomPainter {
  _PopGraphPainter({
    required this.prey,
    required this.pred,
    required this.accent,
  });

  final List<double> prey;
  final List<double> pred;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (prey.length < 2) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: 'Run simulation to plot populations',
          style: TextStyle(color: accent.withValues(alpha: 0.5), fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height / 2 - 8));
      return;
    }
    void drawSeries(List<double> s, Color color) {
      final Path path = Path();
      for (int i = 0; i < s.length; i++) {
        final double x = size.width * i / (s.length - 1);
        final double y = size.height * (1 - s[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    drawSeries(prey, accent);
    drawSeries(pred, const Color(0xFFF87171));
  }

  @override
  bool shouldRepaint(covariant _PopGraphPainter oldDelegate) =>
      oldDelegate.prey != prey || oldDelegate.pred != pred;
}
