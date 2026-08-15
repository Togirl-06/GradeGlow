import 'package:flutter/material.dart';

import '../../data/engineering/engineering_lab_engine.dart';
import '../../models/engineering/engineering_program.dart';
import '../../theme/engineering_theme.dart';

/// Mission-control workspace that teaches while you tweak real engineering variables.
class EngineeringWorkspaceScreen extends StatefulWidget {
  const EngineeringWorkspaceScreen({
    super.key,
    required this.major,
    required this.course,
    required this.mode,
  });

  final EngineeringMajor major;
  final EngineeringCourse course;
  final EngineeringLearningMode mode;

  @override
  State<EngineeringWorkspaceScreen> createState() => _EngineeringWorkspaceScreenState();
}

class _EngineeringWorkspaceScreenState extends State<EngineeringWorkspaceScreen> {
  late final Map<String, double> _values;
  bool _running = false;
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    _values = <String, double>{
      for (final EngineeringControlSpec c in widget.course.conceptControls) c.id: c.initial,
    };
    final EngineeringLabSnapshot snap = _snap;
    _log.addAll(<String>[
      'Ready · ${widget.mode.label}',
      if (snap.goal != null) snap.goal!,
      'Tip: ${snap.whatToTry}',
    ]);
  }

  EngineeringLabSnapshot get _snap => EngineeringLabEngine.evaluate(
        major: widget.major,
        course: widget.course,
        mode: widget.mode,
        values: _values,
      );

  Color _levelColor(EngineeringStatusLevel level) => switch (level) {
        EngineeringStatusLevel.good => EngineeringTheme.consoleGood,
        EngineeringStatusLevel.caution => EngineeringTheme.warning,
        EngineeringStatusLevel.danger => EngineeringTheme.consoleBad,
        EngineeringStatusLevel.idle => EngineeringTheme.consoleMuted,
      };

  EngineeringControlSpec? _spec(String id) {
    for (final EngineeringControlSpec c in widget.course.conceptControls) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _setValue(String id, double value) {
    final EngineeringControlSpec? spec = _spec(id);
    setState(() {
      _values[id] = value;
      if (_running) {
        final String unit = spec?.unit ?? '';
        final int decimals = spec != null && spec.step < 1 ? 1 : 0;
        _log.add('${spec?.label ?? id} → ${value.toStringAsFixed(decimals)} $unit'.trim());
        final EngineeringLabSnapshot s = _snap;
        if (s.statusLevel == EngineeringStatusLevel.danger) {
          _log.add('⚠ ${s.status}');
        }
        if (_log.length > 50) _log.removeRange(0, _log.length - 50);
      }
    });
  }

  void _toggleRun() {
    setState(() {
      _running = !_running;
      _log.add(_running ? '▶ Running — change controls and watch consequences' : '■ Paused');
    });
  }

  void _reset() {
    setState(() {
      for (final EngineeringControlSpec c in widget.course.conceptControls) {
        _values[c.id] = c.initial;
      }
      _running = false;
      _log
        ..clear()
        ..add('Reset to baseline')
        ..add(_snap.whatToTry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final EngineeringLabSnapshot snap = _snap;
    final Color statusColor = _levelColor(snap.statusLevel);
    final String title = switch (widget.mode) {
      EngineeringLearningMode.concepts => 'Interactive Concepts',
      EngineeringLearningMode.virtualLab => widget.course.labTitle,
      EngineeringLearningMode.simulator => widget.course.simulatorTitle,
      _ => widget.mode.label,
    };

    return Scaffold(
      backgroundColor: EngineeringTheme.consoleBg,
      appBar: AppBar(
        backgroundColor: EngineeringTheme.consolePanel,
        foregroundColor: EngineeringTheme.consoleText,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        actions: <Widget>[
          TextButton(onPressed: _reset, child: const Text('Reset', style: TextStyle(color: EngineeringTheme.consoleMuted))),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 720;
          final Widget viz = _VisualizationPane(
            snap: snap,
            statusColor: statusColor,
            mode: widget.mode,
            course: widget.course,
            log: _log,
          );
          final Widget controls = _ControlsPane(
            course: widget.course,
            values: _values,
            running: _running,
            onChanged: _setValue,
            onToggleRun: _toggleRun,
            coachTip: snap.coachTip,
            whatToTry: snap.whatToTry,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(flex: 5, child: viz),
                Container(width: 1, color: EngineeringTheme.consoleBorder),
                Expanded(flex: 4, child: controls),
              ],
            );
          }
          return Column(
            children: <Widget>[
              Expanded(flex: 3, child: viz),
              Container(height: 1, color: EngineeringTheme.consoleBorder),
              Expanded(flex: 2, child: controls),
            ],
          );
        },
      ),
    );
  }
}

class _VisualizationPane extends StatelessWidget {
  const _VisualizationPane({
    required this.snap,
    required this.statusColor,
    required this.mode,
    required this.course,
    required this.log,
  });

  final EngineeringLabSnapshot snap;
  final Color statusColor;
  final EngineeringLearningMode mode;
  final EngineeringCourse course;
  final List<String> log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (snap.goal != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(snap.goal!, style: const TextStyle(color: EngineeringTheme.consoleAccent, fontWeight: FontWeight.w700, height: 1.35)),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: EngineeringTheme.consolePanel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EngineeringTheme.consoleBorder),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.55)),
                    ),
                    child: Text(snap.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  Text(snap.plainEnglish, style: const TextStyle(color: EngineeringTheme.consoleText, height: 1.45, fontSize: 13)),
                  const SizedBox(height: 14),
                  const Text('LIVE METRICS', style: TextStyle(color: EngineeringTheme.consoleMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: snap.metrics.map((EngineeringMetric m) {
                      final bool bad = (m.goodMax != null && m.value > m.goodMax!) ||
                          (m.goodMin != null && m.value < m.goodMin!);
                      final Color c = bad ? EngineeringTheme.consoleBad : EngineeringTheme.consoleAccent;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: EngineeringTheme.consoleBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bad ? c.withValues(alpha: 0.6) : EngineeringTheme.consoleBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(m.label, style: const TextStyle(color: EngineeringTheme.consoleMuted, fontSize: 10)),
                            Text(
                              '${m.display}${m.unit.isEmpty ? '' : ' ${m.unit}'}',
                              style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 17, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 72,
                    child: CustomPaint(
                      painter: _MetricBarsPainter(
                        metrics: snap.metrics,
                        accent: EngineeringTheme.primary,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: Container(
              decoration: BoxDecoration(
                color: EngineeringTheme.consolePanel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EngineeringTheme.consoleBorder),
              ),
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: log.reversed
                    .map(
                      (String line) => Text(
                        line,
                        style: const TextStyle(color: EngineeringTheme.consoleMuted, fontFamily: 'monospace', fontSize: 11, height: 1.35),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsPane extends StatelessWidget {
  const _ControlsPane({
    required this.course,
    required this.values,
    required this.running,
    required this.onChanged,
    required this.onToggleRun,
    required this.coachTip,
    required this.whatToTry,
  });

  final EngineeringCourse course;
  final Map<String, double> values;
  final bool running;
  final void Function(String id, double value) onChanged;
  final VoidCallback onToggleRun;
  final String coachTip;
  final String whatToTry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EngineeringTheme.consolePanel,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('CONTROLS', style: TextStyle(color: EngineeringTheme.consoleMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EngineeringTheme.consoleBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: EngineeringTheme.consoleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Coach: $coachTip', style: const TextStyle(color: EngineeringTheme.consoleText, fontSize: 12, height: 1.35)),
                const SizedBox(height: 6),
                Text('Try: $whatToTry', style: const TextStyle(color: EngineeringTheme.consoleAccent, fontSize: 12, height: 1.35, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: course.conceptControls.map((EngineeringControlSpec c) {
                final double value = values[c.id] ?? c.initial;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(c.label, style: const TextStyle(color: EngineeringTheme.consoleText, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          Text(
                            '${value.toStringAsFixed(c.step < 1 ? 1 : 0)} ${c.unit}',
                            style: const TextStyle(color: EngineeringTheme.consoleAccent, fontFamily: 'monospace', fontSize: 12),
                          ),
                        ],
                      ),
                      Slider(
                        value: value.clamp(c.min, c.max),
                        min: c.min,
                        max: c.max,
                        divisions: ((c.max - c.min) / c.step).round().clamp(1, 100),
                        activeColor: EngineeringTheme.primary,
                        onChanged: (double v) => onChanged(c.id, v),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          FilledButton.icon(
            onPressed: onToggleRun,
            style: FilledButton.styleFrom(
              backgroundColor: running ? EngineeringTheme.consoleBad : EngineeringTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
            label: Text(running ? 'Pause' : 'Run / observe', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _MetricBarsPainter extends CustomPainter {
  _MetricBarsPainter({required this.metrics, required this.accent});

  final List<EngineeringMetric> metrics;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) return;
    final List<double> values = metrics.map((EngineeringMetric m) => m.value.abs()).toList();
    final double maxV = values.reduce((double a, double b) => a > b ? a : b).clamp(1, double.infinity);
    final double barW = size.width / (values.length * 1.6);
    final Paint paint = Paint()..color = accent.withValues(alpha: 0.85);
    for (int i = 0; i < values.length; i++) {
      final double h = (values[i] / maxV) * (size.height - 8);
      final double x = i * (barW * 1.6) + 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - h, barW, h), const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MetricBarsPainter oldDelegate) => oldDelegate.metrics != metrics;
}
