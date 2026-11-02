import 'package:flutter/material.dart';

import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_sims.dart';

/// Lightweight Simulation Lab with selectable models.
class SimulationLabScreen extends StatefulWidget {
  const SimulationLabScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  State<SimulationLabScreen> createState() => _SimulationLabScreenState();
}

class _SimulationLabScreenState extends State<SimulationLabScreen> {
  String _model = 'arm';
  String _out = '';

  // Arm
  double _mass = 5;
  double _len = 0.8;
  double _motor = 50;
  double _joint = 60;

  // Circuit
  double _v = 12;
  double _r = 20;
  double _imax = 0.75;

  void _run() {
    if (_model == 'arm') {
      final RoboticArmResult r = EngineeringSims.evaluateRoboticArm(
        massKg: _mass,
        lengthM: _len,
        motorTorqueNm: _motor,
        jointStrengthNm: _joint,
      );
      setState(() {
        _out =
            '${r.passed ? 'PASS' : 'FAIL'}\n'
            'Load ${r.loadN.toStringAsFixed(1)} N · '
            'τ ${r.requiredTorqueNm.toStringAsFixed(1)} N·m · '
            'with SF ${r.requiredWithSafetyNm.toStringAsFixed(1)} N·m\n'
            '${r.issues.isEmpty ? 'All constraints satisfied.' : r.issues.join('\n')}\n\n'
            '${r.assumptions}';
      });
    } else if (_model == 'circuit') {
      final CircuitSimResult r = EngineeringSims.evaluateSeriesCircuit(
        voltageV: _v,
        resistanceOhm: _r,
        maxCurrentA: _imax,
      );
      setState(() {
        _out =
            '${r.passed ? 'PASS' : 'FAIL'}\n'
            'I = ${r.currentA.toStringAsFixed(4)} A · '
            'P = ${r.powerW.toStringAsFixed(3)} W\n'
            '${r.issues.isEmpty ? 'Within limit.' : r.issues.join('\n')}\n\n'
            '${r.assumptions}';
      });
    } else {
      final FactorySimResult r = EngineeringSims.evaluateFactoryLine(
        stationUnitsPerHour: const <double>[32, 45, 38],
        demandPerHour: 30,
        budgetUsd: 9000,
        operatingCostUsd: 7500,
      );
      setState(() {
        _out =
            '${r.passed ? 'PASS' : 'FAIL'}\n'
            'Bottleneck ${r.bottleneckRate.toStringAsFixed(1)} u/h\n'
            '${r.issues.isEmpty ? 'Demand met.' : r.issues.join('\n')}\n\n'
            '${r.assumptions}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Simulation Lab',
        icon: Icons.analytics_rounded,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('Robotic arm'),
                  selected: _model == 'arm',
                  onSelected: (_) => setState(() => _model = 'arm'),
                ),
                ChoiceChip(
                  label: const Text('Circuit'),
                  selected: _model == 'circuit',
                  onSelected: (_) => setState(() => _model = 'circuit'),
                ),
                ChoiceChip(
                  label: const Text('Factory'),
                  selected: _model == 'factory',
                  onSelected: (_) => setState(() => _model = 'factory'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 16),
              child: Column(
                children: <Widget>[
                  if (_model == 'arm') ...<Widget>[
                    _s('Mass (kg)', _mass, 1, 20, (double v) => _mass = v),
                    _s('Length (m)', _len, 0.3, 1.5, (double v) => _len = v),
                    _s('Motor (N·m)', _motor, 10, 120, (double v) => _motor = v),
                    _s('Joint (N·m)', _joint, 10, 150, (double v) => _joint = v),
                  ] else if (_model == 'circuit') ...<Widget>[
                    _s('Voltage (V)', _v, 1, 48, (double v) => _v = v),
                    _s('Resistance (Ω)', _r, 1, 100, (double v) => _r = v),
                    _s('Max current (A)', _imax, 0.1, 5, (double v) => _imax = v),
                  ] else
                    const Text(
                      'Uses a fixed three-station demo line. Adjust via Challenge Arena for IE missions.',
                      style: TextStyle(color: EngCosmic.mute),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _run,
                    style: FilledButton.styleFrom(
                      backgroundColor: EngCosmic.blue,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Run model'),
                  ),
                ],
              ),
            ),
            if (_out.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: EngCosmic.panelBox(radius: 14),
                child: Text(
                  _out,
                  style: const TextStyle(
                    color: EngCosmic.ink,
                    height: 1.4,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _s(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> set,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(label, style: const TextStyle(color: EngCosmic.ink)),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(color: EngCosmic.electric),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: EngCosmic.electric,
          onChanged: (double v) => setState(() => set(v)),
        ),
      ],
    );
  }
}
