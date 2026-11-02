import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Param sliders drive a live simulation; student records observation.
class VisualObserveLabScreen extends StatefulWidget {
  const VisualObserveLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualObserveLabScreen> createState() => _VisualObserveLabScreenState();
}

class _VisualObserveLabScreenState extends State<VisualObserveLabScreen> {
  late Map<String, double> _values;
  final TextEditingController _note = TextEditingController();
  int? _choice;

  VisualLabSpec get spec => widget.spec;
  ObserveScenario get scenario =>
      spec.observe ??
      const ObserveScenario(
        params: <ObserveParam>[
          ObserveParam(id: 'temp', label: 'Temperature', min: 0, max: 100, initial: 25),
        ],
        prompt: 'What do you observe?',
        keywords: <String>['increase', 'decrease'],
      );

  @override
  void initState() {
    super.initState();
    _values = <String, double>{
      for (final ObserveParam p in scenario.params) p.id: p.initial,
    };
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  double get _simIntensity {
    if (_values.isEmpty) return 0.5;
    final double avg =
        _values.values.reduce((double a, double b) => a + b) / _values.length;
    // Normalize loosely to 0..1 using first param range.
    final ObserveParam p = scenario.params.first;
    return ((avg - p.min) / (p.max - p.min)).clamp(0.0, 1.0);
  }

  Future<void> _submit() async {
    bool passed = false;
    if (scenario.correctChoiceIndex != null && scenario.choices.isNotEmpty) {
      passed = _choice == scenario.correctChoiceIndex;
    } else {
      passed = keywordsMatch(_note.text, scenario.keywords, minHits: 1);
    }
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: passed,
      body: passed
          ? 'Observation accepted. You tracked how the system responded.'
          : 'Observation incomplete. Adjust parameters, watch the panel, then describe what changed.',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return VisualLabShell(
      spec: spec,
      badgeLabel: 'OBSERVE',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: 'SUBMIT OBSERVATION',
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
                ),
                child: CustomPaint(
                  painter: _SimPainter(
                    intensity: _simIntensity,
                    accent: spec.accent,
                    hint: scenario.simulationHint,
                    diagram: spec.diagramTitle,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              scenario.prompt,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            for (final ObserveParam p in scenario.params)
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 88,
                    child: Text(
                      p.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _values[p.id]!.clamp(p.min, p.max),
                      min: p.min,
                      max: p.max,
                      activeColor: spec.accent,
                      onChanged: (double v) => setState(() => _values[p.id] = v),
                    ),
                  ),
                  Text(
                    '${_values[p.id]!.toStringAsFixed(0)}${p.unit}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            if (scenario.choices.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              ...List<Widget>.generate(scenario.choices.length, (int i) {
                final bool selected = _choice == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _choice = i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? spec.accent.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? spec.accent
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        scenario.choices[i],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                );
              }),
            ] else
              TextField(
                controller: _note,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write what you observed…',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: Colors.black38,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimPainter extends CustomPainter {
  _SimPainter({
    required this.intensity,
    required this.accent,
    required this.hint,
    required this.diagram,
  });

  final double intensity;
  final Color accent;
  final String hint;
  final String diagram;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          accent.withValues(alpha: 0.08 + intensity * 0.35),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final String key = diagram.toLowerCase();
    if (key.contains('beaker') || key.contains('flask') || key.contains('reaction')) {
      final Path flask = Path()
        ..moveTo(size.width * 0.35, size.height * 0.15)
        ..lineTo(size.width * 0.35, size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.65, size.height * 0.55)
        ..lineTo(size.width * 0.65, size.height * 0.15);
      canvas.drawPath(flask, Paint()..color = accent.withValues(alpha: 0.15));
      canvas.drawPath(
        flask,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final double level = 0.75 - intensity * 0.35;
      canvas.drawRect(
        Rect.fromLTRB(
          size.width * 0.37,
          size.height * level,
          size.width * 0.63,
          size.height * 0.72,
        ),
        Paint()..color = accent.withValues(alpha: 0.45 + intensity * 0.3),
      );
      // Bubbles
      final math.Random rng = math.Random(7);
      for (int i = 0; i < (intensity * 12).round(); i++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.4 + rng.nextDouble() * 0.2),
            size.height * (level - rng.nextDouble() * 0.2),
          ),
          3 + rng.nextDouble() * 4,
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );
      }
    } else {
      // Force / motion bars
      for (int i = 0; i < 5; i++) {
        final double h = size.height * (0.2 + intensity * 0.5) * (1 - i * 0.08);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * (0.15 + i * 0.15),
              size.height - h - size.height * 0.1,
              size.width * 0.1,
              h,
            ),
            const Radius.circular(6),
          ),
          Paint()..color = accent.withValues(alpha: 0.3 + i * 0.1),
        );
      }
    }

    if (hint.isNotEmpty) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: hint,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - 24);
      tp.paint(canvas, Offset(12, size.height - tp.height - 12));
    }
  }

  @override
  bool shouldRepaint(covariant _SimPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}
