import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'visual_lab_models.dart';
import 'visual_lab_shell.dart';

/// Virtual instrument — dial/slider reading vs target tolerance.
class VisualMeasureLabScreen extends StatefulWidget {
  const VisualMeasureLabScreen({super.key, required this.spec});

  final VisualLabSpec spec;

  @override
  State<VisualMeasureLabScreen> createState() => _VisualMeasureLabScreenState();
}

class _VisualMeasureLabScreenState extends State<VisualMeasureLabScreen> {
  late double _needle;
  final TextEditingController _entry = TextEditingController();
  bool _collected = false;

  VisualLabSpec get spec => widget.spec;
  MeasureInstrument get inst =>
      spec.instrument ??
      const MeasureInstrument(
        kind: MeasureInstrumentKind.thermometer,
        targetValue: 37,
        unit: '°C',
        min: 30,
        max: 42,
      );

  @override
  void initState() {
    super.initState();
    _needle = (inst.min + inst.max) / 2;
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  String get _instrumentTitle {
    switch (inst.kind) {
      case MeasureInstrumentKind.thermometer:
        return 'Thermometer';
      case MeasureInstrumentKind.voltmeter:
        return 'Voltmeter';
      case MeasureInstrumentKind.ruler:
        return 'Ruler';
      case MeasureInstrumentKind.scale:
        return 'Scale';
      case MeasureInstrumentKind.stopwatch:
        return 'Stopwatch';
      case MeasureInstrumentKind.spo2:
        return 'SpO₂ Probe';
      case MeasureInstrumentKind.bpCuff:
        return 'BP Cuff';
      case MeasureInstrumentKind.pipette:
        return 'Pipette';
      case MeasureInstrumentKind.spectrometer:
        return 'Spectrometer';
    }
  }

  Future<void> _submit() async {
    final double? entered = double.tryParse(_entry.text.trim());
    if (!_collected || entered == null) {
      await showVisualLabResult(
        context: context,
        spec: spec,
        passed: false,
        body: 'Collect a reading from the instrument, then enter the value.',
      );
      return;
    }
    final bool readingOk = (_needle - inst.targetValue).abs() <= inst.tolerance;
    final bool entryOk = (entered - inst.targetValue).abs() <= inst.tolerance;
    final bool passed = readingOk && entryOk;
    await showVisualLabResult(
      context: context,
      spec: spec,
      passed: passed,
      body: passed
          ? 'Reading ${inst.targetValue.toStringAsFixed(inst.displayPrecision)} '
              '${inst.unit} within ±${inst.tolerance}. Measurement accepted.'
          : 'Target was ${inst.targetValue.toStringAsFixed(inst.displayPrecision)} '
              '${inst.unit} (±${inst.tolerance}). Adjust the instrument and re-enter.',
    );
    if (passed && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return VisualLabShell(
      spec: spec,
      badgeLabel: 'MEASURE',
      footer: visualPrimaryButton(
        accent: spec.accent,
        label: 'SUBMIT READING',
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: spec.accent.withValues(alpha: 0.4)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      _instrumentTitle,
                      style: TextStyle(
                        color: spec.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inst.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 180,
                      child: CustomPaint(
                        painter: _GaugePainter(
                          value: _needle,
                          min: inst.min,
                          max: inst.max,
                          accent: spec.accent,
                          kind: inst.kind,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Text(
                      '${_needle.toStringAsFixed(inst.displayPrecision)} ${inst.unit}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: spec.accent,
                        thumbColor: spec.accent,
                        inactiveTrackColor: Colors.white24,
                      ),
                      child: Slider(
                        value: _needle.clamp(inst.min, inst.max),
                        min: inst.min,
                        max: inst.max,
                        onChanged: (double v) => setState(() {
                          _needle = v;
                          _collected = false;
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => setState(() => _collected = true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: spec.accent,
                        side: BorderSide(color: spec.accent),
                      ),
                      child: Text(
                        _collected ? 'READING LOCKED' : 'COLLECT READING',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _entry,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter observed value (${inst.unit})',
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                        filled: true,
                        fillColor: Colors.black38,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.accent,
    required this.kind,
  });

  final double value;
  final double min;
  final double max;
  final Color accent;
  final MeasureInstrumentKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height * 0.75);
    final double r = size.shortestSide * 0.42;
    final Paint arc = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi,
      math.pi,
      false,
      arc,
    );
    final double t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final Paint lit = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi,
      math.pi * t,
      false,
      lit,
    );
    final double angle = math.pi + math.pi * t;
    final Offset tip = Offset(c.dx + math.cos(angle) * r * 0.85, c.dy + math.sin(angle) * r * 0.85);
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 6, Paint()..color = accent);

    if (kind == MeasureInstrumentKind.thermometer) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.82, size.height * 0.1, 14, size.height * 0.7),
          const Radius.circular(8),
        ),
        Paint()..color = accent.withValues(alpha: 0.2),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.82,
            size.height * (0.8 - 0.7 * t),
            14,
            size.height * 0.7 * t,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value;
}
