import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_sims.dart';
import 'robotic_arm_mission_screen.dart';

class ChallengeArenaScreen extends StatelessWidget {
  const ChallengeArenaScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  Widget build(BuildContext context) {
    final List<EngMission> missions =
        EngMissionCatalog.forMajor(progress.majorId);
    final EngineeringMajor major = EngineeringMajors.byId(progress.majorId);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Challenge Arena',
        icon: Icons.emoji_events_rounded,
        subtitle: major.facility,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: EngCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${major.title} missions',
                    style: const TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Solve interactive engineering problems with real checks. '
                    'Retry anytime — progress is saved.',
                    style: TextStyle(color: EngCosmic.mute, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    EngineeringSims.disclaimer,
                    style: TextStyle(
                      color: EngCosmic.orange.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (missions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: EngCosmic.panelBox(),
                child: const Text(
                  'More missions for this major are coming. Try Mechanical for the full vertical slice.',
                  style: TextStyle(color: EngCosmic.mute),
                ),
              )
            else
              ...missions.map((EngMission m) {
                final bool done = progress.isMissionComplete(m.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openMission(context, m),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: EngCosmic.panelBox(radius: 16),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor:
                                  major.accent.withValues(alpha: 0.25),
                              child: Icon(major.icon, color: major.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    m.title,
                                    style: const TextStyle(
                                      color: EngCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.objective,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: EngCosmic.mute,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: <Widget>[
                                      EngCosmic.pill(m.difficulty),
                                      const SizedBox(width: 6),
                                      EngCosmic.pill(
                                        '+${m.xpReward} XP',
                                        bg: EngCosmic.gold
                                            .withValues(alpha: 0.16),
                                        fg: EngCosmic.gold,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.chevron_right_rounded,
                              color: done
                                  ? EngCosmic.success
                                  : EngCosmic.mute,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _openMission(BuildContext context, EngMission m) {
    if (m.id == EngMissionCatalog.roboticArm.id) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => RoboticArmMissionScreen(progress: progress),
        ),
      );
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EngGenericMissionScreen(progress: progress, mission: m),
      ),
    );
  }
}

/// Interactive mission playable for any major (not just Mechanical).
class EngGenericMissionScreen extends StatefulWidget {
  const EngGenericMissionScreen({
    super.key,
    required this.progress,
    required this.mission,
  });

  final EngineeringCareerProgress progress;
  final EngMission mission;

  @override
  State<EngGenericMissionScreen> createState() =>
      _EngGenericMissionScreenState();
}

class _EngGenericMissionScreenState extends State<EngGenericMissionScreen> {
  String? _feedback;
  bool _passed = false;

  double _bridgeSpan = 20;
  double _bridgeCapacity = 600;
  double _bridgeCost = 95000;
  double _circuitR = 24;
  double _factorySlow = 40;
  double _chemTemp = 340;
  double _aeroWing = 18;
  double _aeroMass = 1200;
  double _vibRpm = 1800;
  double _vibUnbalance = 12;
  double _drainCapacity = 40;
  double _drainPeak = 36;
  double _parallelR = 18;
  double _aeroSpeed = 55;
  double _aeroCda = 0.55;
  double _iePeople = 4;
  double _ieRate = 12;
  int _chemChoice = 0;

  void _run() {
    final String id = widget.mission.id;
    if (id == EngMissionCatalog.bridge.id ||
        id == EngMissionCatalog.civilDrainage.id) {
      if (id == EngMissionCatalog.civilDrainage.id) {
        final bool ok = _drainCapacity >= _drainPeak + 2;
        setState(() {
          _passed = ok;
          _feedback = ok
              ? 'Channel capacity ${_drainCapacity.toStringAsFixed(0)} ≥ peak '
                  '${_drainPeak.toStringAsFixed(0)} with freeboard.'
              : 'Capacity too low vs peak — raise capacity or lower assumed runoff.';
        });
        return;
      }
      final BridgeSimResult r = EngineeringSims.evaluateBridge(
        spanM: _bridgeSpan,
        uniformLoadKNPerM: 8,
        momentCapacityKNm: _bridgeCapacity,
        budgetUsd: 120000,
        costUsd: _bridgeCost,
      );
      setState(() {
        _passed = r.passed;
        _feedback = r.passed
            ? 'Bridge concept meets capacity and budget.'
            : r.issues.join(' ');
      });
    } else if (id == EngMissionCatalog.circuit.id ||
        id == EngMissionCatalog.eeParallel.id) {
      final CircuitSimResult r = EngineeringSims.evaluateSeriesCircuit(
        voltageV: 12,
        resistanceOhm: id == EngMissionCatalog.eeParallel.id
            ? _parallelR
            : _circuitR,
        maxCurrentA: id == EngMissionCatalog.eeParallel.id ? 0.9 : 0.6,
      );
      setState(() {
        _passed = r.passed;
        _feedback =
            'I = ${r.currentA.toStringAsFixed(3)} A · P = ${r.powerW.toStringAsFixed(2)} W. '
            '${r.passed ? 'Within feeder / breaker limit.' : r.issues.join(' ')}';
      });
    } else if (id == EngMissionCatalog.factory.id ||
        id == EngMissionCatalog.ieStaffing.id) {
      if (id == EngMissionCatalog.ieStaffing.id) {
        final double throughput = _iePeople * _ieRate * 8;
        final double overtimeCost = _iePeople > 5 ? (_iePeople - 5) * 180 : 0;
        final bool ok = throughput >= 360 && overtimeCost <= 400;
        setState(() {
          _passed = ok;
          _feedback = ok
              ? 'Throughput ${throughput.toStringAsFixed(0)} units/day · OT \$${overtimeCost.toStringAsFixed(0)}.'
              : 'Need ≥360 units/day and OT ≤ \$400 — adjust people/rate.';
        });
        return;
      }
      final FactorySimResult r = EngineeringSims.evaluateFactoryLine(
        stationUnitsPerHour: <double>[_factorySlow, 55, 48],
        demandPerHour: 36,
        budgetUsd: 10000,
        operatingCostUsd: 8200,
      );
      setState(() {
        _passed = r.passed;
        _feedback =
            'Bottleneck ${r.bottleneckRate.toStringAsFixed(0)} u/h. '
            '${r.passed ? 'Demand met within budget.' : r.issues.join(' ')}';
      });
    } else if (id == EngMissionCatalog.chemYield.id ||
        id == EngMissionCatalog.chemAlarm.id) {
      if (id == EngMissionCatalog.chemAlarm.id) {
        final bool ok = _chemChoice == 1;
        setState(() {
          _passed = ok;
          _feedback = ok
              ? 'Correct: cut energy input first, then re-check pressure.'
              : 'Unsafe order — stabilize temperature / energy before secondary reads.';
        });
        return;
      }
      final bool ok = _chemTemp >= 330 && _chemTemp <= 360;
      setState(() {
        _passed = ok;
        _feedback = ok
            ? 'Yield in target band at ${_chemTemp.toStringAsFixed(0)} K (teaching model).'
            : 'Temperature ${_chemTemp.toStringAsFixed(0)} K is outside the 330–360 K band.';
      });
    } else if (id == EngMissionCatalog.aeroTakeoff.id ||
        id == EngMissionCatalog.aeroDrag.id) {
      if (id == EngMissionCatalog.aeroDrag.id) {
        final double drag = 0.5 * 1.225 * _aeroSpeed * _aeroSpeed * _aeroCda;
        const double thrustLimit = 900;
        final bool ok = drag <= thrustLimit;
        setState(() {
          _passed = ok;
          _feedback = ok
              ? 'Drag ${drag.toStringAsFixed(0)} N ≤ thrust limit $thrustLimit N.'
              : 'Drag ${drag.toStringAsFixed(0)} N exceeds thrust — lower speed or CdA.';
        });
        return;
      }
      const double rho = 1.225;
      const double v = 30;
      const double cl = 1.2;
      final double lift = 0.5 * rho * v * v * _aeroWing * cl;
      final double weight = _aeroMass * 9.81;
      final bool ok = lift + 1e-6 >= weight;
      setState(() {
        _passed = ok;
        _feedback = ok
            ? 'Lift ${lift.toStringAsFixed(0)} N ≥ weight ${weight.toStringAsFixed(0)} N.'
            : 'Lift ${lift.toStringAsFixed(0)} N < weight ${weight.toStringAsFixed(0)} N — raise wing area or cut mass.';
      });
    } else if (id == EngMissionCatalog.mechVibration.id) {
      final double product = _vibRpm * _vibUnbalance;
      final bool ok = product <= 18000;
      setState(() {
        _passed = ok;
        _feedback = ok
            ? 'RPM×unbalance ${product.toStringAsFixed(0)} under 18000 alarm.'
            : 'Product ${product.toStringAsFixed(0)} over limit — cut RPM or unbalance.';
      });
    } else {
      setState(() {
        _passed = false;
        _feedback = 'Unknown mission controls — pick another challenge.';
      });
    }
  }

  Future<void> _submit() async {
    if (!_passed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run a passing check first.')),
      );
      return;
    }
    final bool first = await widget.progress.completeMission(
      widget.mission.id,
      xpGain: widget.mission.xpReward,
      payCents: 500,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          first
              ? 'Mission complete · +${widget.mission.xpReward} XP'
              : 'Already completed.',
        ),
      ),
    );
    setState(() {});
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
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
              value.toStringAsFixed(0),
              style: const TextStyle(color: EngCosmic.electric),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: EngCosmic.electric,
          onChanged: (double v) => setState(() {
            onChanged(v);
            _feedback = null;
            _passed = false;
          }),
        ),
      ],
    );
  }

  Widget _controls() {
    final String id = widget.mission.id;
    final List<Widget> kids = <Widget>[];
    if (id == EngMissionCatalog.bridge.id) {
      kids.addAll(<Widget>[
        _slider('Span (m)', _bridgeSpan, 10, 40, (double v) => _bridgeSpan = v),
        _slider(
          'Moment capacity (kN·m)',
          _bridgeCapacity,
          200,
          900,
          (double v) => _bridgeCapacity = v,
        ),
        _slider('Cost (USD)', _bridgeCost, 40000, 150000, (double v) => _bridgeCost = v),
      ]);
    } else if (id == EngMissionCatalog.civilDrainage.id) {
      kids.addAll(<Widget>[
        _slider(
          'Channel capacity',
          _drainCapacity,
          20,
          80,
          (double v) => _drainCapacity = v,
        ),
        _slider(
          'Peak runoff',
          _drainPeak,
          10,
          70,
          (double v) => _drainPeak = v,
        ),
      ]);
    } else if (id == EngMissionCatalog.circuit.id) {
      kids.add(
        _slider('Resistance (ohm)', _circuitR, 5, 80, (double v) => _circuitR = v),
      );
    } else if (id == EngMissionCatalog.eeParallel.id) {
      kids.add(
        _slider(
          'Branch resistance (ohm)',
          _parallelR,
          5,
          60,
          (double v) => _parallelR = v,
        ),
      );
    } else if (id == EngMissionCatalog.factory.id) {
      kids.add(
        _slider(
          'Slowest station (u/h)',
          _factorySlow,
          20,
          60,
          (double v) => _factorySlow = v,
        ),
      );
    } else if (id == EngMissionCatalog.ieStaffing.id) {
      kids.addAll(<Widget>[
        _slider('People on line', _iePeople, 2, 8, (double v) => _iePeople = v),
        _slider(
          'Units / person / hour',
          _ieRate,
          6,
          20,
          (double v) => _ieRate = v,
        ),
      ]);
    } else if (id == EngMissionCatalog.chemYield.id) {
      kids.add(
        _slider('Reactor temp (K)', _chemTemp, 300, 400, (double v) => _chemTemp = v),
      );
    } else if (id == EngMissionCatalog.chemAlarm.id) {
      kids.add(
        Wrap(
          spacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: const Text('Ignore alarms'),
              selected: _chemChoice == 0,
              onSelected: (_) => setState(() {
                _chemChoice = 0;
                _passed = false;
                _feedback = null;
              }),
            ),
            ChoiceChip(
              label: const Text('Cut energy input first'),
              selected: _chemChoice == 1,
              onSelected: (_) => setState(() {
                _chemChoice = 1;
                _passed = false;
                _feedback = null;
              }),
            ),
            ChoiceChip(
              label: const Text('Max feed rate'),
              selected: _chemChoice == 2,
              onSelected: (_) => setState(() {
                _chemChoice = 2;
                _passed = false;
                _feedback = null;
              }),
            ),
          ],
        ),
      );
    } else if (id == EngMissionCatalog.aeroTakeoff.id) {
      kids.addAll(<Widget>[
        _slider('Wing area (m2)', _aeroWing, 8, 40, (double v) => _aeroWing = v),
        _slider('Mass (kg)', _aeroMass, 600, 2000, (double v) => _aeroMass = v),
      ]);
    } else if (id == EngMissionCatalog.aeroDrag.id) {
      kids.addAll(<Widget>[
        _slider('Speed (m/s)', _aeroSpeed, 30, 90, (double v) => _aeroSpeed = v),
        _slider('CdA', _aeroCda, 0.2, 1.2, (double v) => _aeroCda = v),
      ]);
    } else if (id == EngMissionCatalog.mechVibration.id) {
      kids.addAll(<Widget>[
        _slider('RPM', _vibRpm, 800, 2800, (double v) => _vibRpm = v),
        _slider(
          'Unbalance (g)',
          _vibUnbalance,
          2,
          30,
          (double v) => _vibUnbalance = v,
        ),
      ]);
    }
    if (kids.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: EngCosmic.panelBox(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: kids,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: widget.mission.title,
        icon: Icons.science_rounded,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              widget.mission.objective,
              style: const TextStyle(color: EngCosmic.mute, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              widget.mission.hint,
              style: const TextStyle(color: EngCosmic.electric, height: 1.35),
            ),
            const SizedBox(height: 16),
            _controls(),
            const SizedBox(height: 12),
            FilledButton(onPressed: _run, child: const Text('Run check')),
            if (_feedback != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _feedback!,
                style: TextStyle(
                  color: _passed ? EngCosmic.success : EngCosmic.danger,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(backgroundColor: EngCosmic.success),
                child: const Text('Submit mission'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
