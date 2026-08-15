import 'package:flutter/material.dart';

import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Read a visual summary (ECG, curves, imaging) and interpret.
class VisualInterpretLabScreen extends StatefulWidget {
  const VisualInterpretLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualInterpretLabScreen> createState() => _VisualInterpretLabScreenState();
}

class _VisualInterpretLabScreenState extends State<VisualInterpretLabScreen> {
  int? _choice;
  final TextEditingController _free = TextEditingController();

  VisualLabSpec get spec => widget.spec;
  InterpretScenario get scenario =>
      spec.interpret ??
      const InterpretScenario(
        visualKind: 'ecg',
        prompt: 'What does this tracing show?',
        choices: <String>['Normal sinus', 'Atrial fibrillation', 'STEMI'],
        correctIndex: 0,
      );

  @override
  void dispose() {
    _free.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bool choiceOk = _choice == scenario.correctIndex;
    final bool textOk = scenario.freeTextKeywords.isEmpty ||
        keywordsMatch(_free.text, scenario.freeTextKeywords);
    final bool passed = choiceOk && textOk;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: passed,
      body: passed
          ? 'Interpretation matches the clinical / analytical read.'
          : 'Re-examine the visual and select the best interpretation.',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return VisualLabShell(
      spec: spec,
      badgeLabel: 'INTERPRET',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: 'SUBMIT INTERPRETATION',
        onPressed: _choice == null ? null : _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
                ),
                child: CustomPaint(
                  painter: _InterpretPainter(
                    kind: scenario.visualKind,
                    accent: spec.accent,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        scenario.caption,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              scenario.prompt,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ...List<Widget>.generate(scenario.choices.length, (int i) {
                    final bool selected = _choice == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _choice = i),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? spec.accent.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? spec.accent
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            scenario.choices[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (scenario.freeTextKeywords.isNotEmpty)
                    TextField(
                      controller: _free,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Optional: justify your read…',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: Colors.black38,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterpretPainter extends CustomPainter {
  _InterpretPainter({required this.kind, required this.accent});

  final String kind;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final String k = kind.toLowerCase();
    if (k.contains('ecg') || k.contains('waveform')) {
      _ecg(canvas, size);
    } else if (k.contains('supply') || k.contains('demand')) {
      _supplyDemand(canvas, size);
    } else if (k.contains('xray') || k.contains('imaging')) {
      _xray(canvas, size);
    } else if (k.contains('network')) {
      _network(canvas, size);
    } else {
      _ecg(canvas, size);
    }
  }

  void _ecg(Canvas canvas, Size size) {
    final Paint grid = Paint()..color = const Color(0x33FF6666);
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final Path p = Path();
    final double mid = size.height * 0.55;
    p.moveTo(0, mid);
    for (double x = 0; x < size.width; x += 2) {
      final double t = x / size.width;
      double y = mid;
      final double beat = (t * 8) % 1.0;
      if (beat > 0.35 && beat < 0.42) {
        y = mid - size.height * 0.35; // R
      } else if (beat > 0.42 && beat < 0.48) {
        y = mid + size.height * 0.12; // S
      } else if (beat > 0.2 && beat < 0.28) {
        y = mid - size.height * 0.06; // P
      } else if (beat > 0.55 && beat < 0.7) {
        y = mid - size.height * 0.08; // T
      }
      p.lineTo(x, y);
    }
    canvas.drawPath(
      p,
      Paint()
        ..color = accent
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
  }

  void _supplyDemand(Canvas canvas, Size size) {
    const double pad = 24;
    final Paint axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(pad, size.height - pad), Offset(size.width - 12, size.height - pad), axis);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad, 12), axis);
    final Path supply = Path()
      ..moveTo(pad, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.25);
    final Path demand = Path()
      ..moveTo(pad, size.height * 0.25)
      ..lineTo(size.width * 0.85, size.height * 0.75);
    canvas.drawPath(supply, Paint()..color = accent..strokeWidth = 2.5..style = PaintingStyle.stroke);
    canvas.drawPath(
      demand,
      Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.5), 6, Paint()..color = Colors.white);
  }

  void _xray(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1A1F28),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.48),
        width: size.width * 0.55,
        height: size.height * 0.65,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.45),
        width: size.width * 0.18,
        height: size.height * 0.28,
      ),
      Paint()..color = accent.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.4),
      18,
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _network(Canvas canvas, Size size) {
    final List<Offset> nodes = <Offset>[
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.8),
    ];
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        canvas.drawLine(
          nodes[i],
          nodes[j],
          Paint()
            ..color = accent.withValues(alpha: 0.4)
            ..strokeWidth = 1.5,
        );
      }
    }
    for (final Offset n in nodes) {
      canvas.drawCircle(n, 12, Paint()..color = accent.withValues(alpha: 0.3));
      canvas.drawCircle(n, 12, Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _InterpretPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
