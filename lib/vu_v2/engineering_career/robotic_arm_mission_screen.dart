import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_sims.dart';

/// Real-world practice loop: brief → hand calc → design → simulate → sign-off.
class RoboticArmMissionScreen extends StatefulWidget {
  const RoboticArmMissionScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  State<RoboticArmMissionScreen> createState() =>
      _RoboticArmMissionScreenState();
}

class _RoboticArmMissionScreenState extends State<RoboticArmMissionScreen> {
  static const EngMission _mission = EngMissionCatalog.roboticArm;
  static const double _massKg = 5;
  static const double _safety = 1.25;

  int _step = 0; // 0 brief, 1 hand calc, 2 design, 3 sim+signoff
  double _lengthM = 0.8;
  double _motorNm = 40;
  double _jointNm = 50;
  RoboticArmResult? _result;
  bool _busy = false;

  final TextEditingController _handTau = TextEditingController();
  final TextEditingController _handWithSf = TextEditingController();
  bool _unitsChecked = false;
  bool _assumptionsChecked = false;
  bool _sfChecked = false;
  String? _handFeedback;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> d = widget.progress.designFor(_mission.id);
    _lengthM = (d['lengthM'] as num?)?.toDouble() ?? 0.8;
    _motorNm = (d['motorNm'] as num?)?.toDouble() ?? 40;
    _jointNm = (d['jointNm'] as num?)?.toDouble() ?? 50;
    if (widget.progress.activeMissionId == _mission.id) {
      _step = widget.progress.activeMissionStep.clamp(0, 3);
    }
    // Ensure Continue Playing works.
    widget.progress.startMission(_mission.id, step: _step);
  }

  @override
  void dispose() {
    _handTau.dispose();
    _handWithSf.dispose();
    super.dispose();
  }

  double get _trueTau => _massKg * EngineeringSims.g * _lengthM;
  double get _trueWithSf => _trueTau * _safety;

  void _checkHandCalc() {
    final double? tau = double.tryParse(_handTau.text.trim());
    final double? withSf = double.tryParse(_handWithSf.text.trim());
    final bool tauOk = tau != null && (tau - _trueTau).abs() <= 1.5;
    final bool sfOk =
        withSf != null && (withSf - _trueWithSf).abs() <= 2.0;
    setState(() {
      if (tauOk && sfOk) {
        _handFeedback =
            'Hand calc matches the teaching model (τ = m·g·L, then × $_safety). '
            'Proceed to Design Studio.';
      } else {
        _handFeedback =
            'Recheck: τ ≈ ${_trueTau.toStringAsFixed(1)} N·m, '
            'with SF ≈ ${_trueWithSf.toStringAsFixed(1)} N·m. '
            'Show your work: force first (N), then multiply by length (m).';
      }
    });
  }

  Future<void> _runSim() async {
    setState(() {
      _result = EngineeringSims.evaluateRoboticArm(
        massKg: _massKg,
        lengthM: _lengthM,
        motorTorqueNm: _motorNm,
        jointStrengthNm: _jointNm,
        safetyFactor: _safety,
      );
    });
    await widget.progress.saveDesign(_mission.id, <String, dynamic>{
      'lengthM': _lengthM,
      'motorNm': _motorNm,
      'jointNm': _jointNm,
      'passed': _result!.passed,
      'handTau': _handTau.text,
      'handWithSf': _handWithSf.text,
    });
  }

  Future<void> _submit() async {
    if (_result == null) await _runSim();
    if (!mounted) return;
    if (_result == null || !_result!.passed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulation must pass before engineering sign-off.'),
        ),
      );
      return;
    }
    if (!_unitsChecked || !_assumptionsChecked || !_sfChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the sign-off checklist (units, SF, assumptions).'),
        ),
      );
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    final bool first = await widget.progress.completeMission(
      _mission.id,
      xpGain: _mission.xpReward,
      payCents: 800,
      skillTags: const <String>['Torque', 'Statics', 'Safety factors'],
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          first
              ? 'Signed off · +${_mission.xpReward} XP · +\$8.00 · apply at Career Center'
              : 'Already signed off — keep iterating designs anytime.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool done = widget.progress.isMissionComplete(_mission.id);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'MechWorks · Robotic arm',
        icon: Icons.precision_manufacturing_rounded,
        subtitle: 'Practice job',
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            _StepRail(
              step: _step,
              onSelect: (int i) {
                setState(() => _step = i);
                widget.progress.setMissionStep(i);
              },
            ),
            const SizedBox(height: 12),
            if (_step == 0) _buildBrief(done),
            if (_step == 1) _buildHandCalc(),
            if (_step == 2) _buildDesign(),
            if (_step == 3) _buildSimSignoff(done),
          ],
        ),
      ),
    );
  }

  Widget _buildBrief(bool done) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Client brief · Apex Dynamics',
                      style: TextStyle(
                        color: EngCosmic.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (done)
                    EngCosmic.pill(
                      'Signed off',
                      bg: EngCosmic.success.withValues(alpha: 0.18),
                      fg: EngCosmic.success,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Package cell needs a pick-and-place arm that can hold a 5.0 kg '
                'payload at full horizontal reach. Size the joint motor and '
                'structure using SI units and a 1.25 safety factor on torque.',
                style: TextStyle(color: EngCosmic.mute, height: 1.45),
              ),
              const SizedBox(height: 12),
              _SpecRow('Payload', '5.0 kg'),
              _SpecRow('g', '9.81 m/s²'),
              _SpecRow('Reach (you choose)', '0.30 – 1.50 m'),
              _SpecRow('Safety factor', '1.25 on τ'),
              _SpecRow('Model', 'Static tip load · τ = F·L'),
              const SizedBox(height: 10),
              Text(
                EngineeringSims.disclaimer,
                style: TextStyle(
                  color: EngCosmic.orange.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            setState(() => _step = 1);
            widget.progress.setMissionStep(1);
          },
          style: FilledButton.styleFrom(
            backgroundColor: EngCosmic.electric,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text(
            'Start hand calculation',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildHandCalc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Field worksheet · hand calc',
                style: TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Using reach L = ${_lengthM.toStringAsFixed(2)} m (change in Design). '
                '1) F = m·g  2) τ = F·L  3) τ_design = τ × $_safety',
                style: const TextStyle(color: EngCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _handTau,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: const TextStyle(color: EngCosmic.ink),
                decoration: _fieldDeco('Required torque τ (N·m)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _handWithSf,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: const TextStyle(color: EngCosmic.ink),
                decoration: _fieldDeco('With safety factor (N·m)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_mission.hint)),
                  );
                },
                child: const Text('Hint'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _checkHandCalc,
                child: const Text('Check my work'),
              ),
              if (_handFeedback != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  _handFeedback!,
                  style: TextStyle(
                    color: _handFeedback!.startsWith('Hand calc')
                        ? EngCosmic.success
                        : EngCosmic.danger,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Brief'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() => _step = 2),
                style: FilledButton.styleFrom(
                  backgroundColor: EngCosmic.purple,
                ),
                child: const Text('Design Studio'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesign() {
    final double previewLoad = _massKg * EngineeringSims.g;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 140,
          decoration: EngCosmic.panelBox(radius: 16),
          child: CustomPaint(
            painter: _ArmPainter(lengthFrac: (_lengthM / 2.5).clamp(0.2, 1)),
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Design Studio',
                style: TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Payload ${_massKg.toStringAsFixed(1)} kg · '
                'F = ${previewLoad.toStringAsFixed(1)} N · '
                'preview τ ≈ ${_trueTau.toStringAsFixed(1)} N·m',
                style: const TextStyle(color: EngCosmic.mute, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'Arm length',
                valueLabel: '${_lengthM.toStringAsFixed(2)} m',
                value: _lengthM,
                min: 0.3,
                max: 1.5,
                onChanged: (double v) => setState(() {
                  _lengthM = v;
                  _result = null;
                  _handFeedback = null;
                }),
              ),
              _SliderRow(
                label: 'Motor torque',
                valueLabel: '${_motorNm.toStringAsFixed(0)} N·m',
                value: _motorNm,
                min: 10,
                max: 120,
                onChanged: (double v) => setState(() {
                  _motorNm = v;
                  _result = null;
                }),
              ),
              _SliderRow(
                label: 'Joint strength',
                valueLabel: '${_jointNm.toStringAsFixed(0)} N·m',
                value: _jointNm,
                min: 10,
                max: 150,
                onChanged: (double v) => setState(() {
                  _jointNm = v;
                  _result = null;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => setState(() => _step = 3),
          style: FilledButton.styleFrom(
            backgroundColor: EngCosmic.blue,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Run Simulation Lab'),
        ),
      ],
    );
  }

  Widget _buildSimSignoff(bool done) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Simulation Lab · sign-off',
                style: TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _runSim,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run simulation'),
              ),
              if (_result != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _result!.passed
                      ? 'PASS — motor and joint meet τ with SF'
                      : 'FAIL — revise Design Studio parameters',
                  style: TextStyle(
                    color: _result!.passed
                        ? EngCosmic.success
                        : EngCosmic.danger,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Load ${_result!.loadN.toStringAsFixed(1)} N · '
                  'τ ${_result!.requiredTorqueNm.toStringAsFixed(1)} · '
                  'with SF ${_result!.requiredWithSafetyNm.toStringAsFixed(1)} N·m',
                  style: const TextStyle(color: EngCosmic.ink, height: 1.35),
                ),
                ..._result!.issues.map(
                  (String i) => Text(
                    '• $i',
                    style: const TextStyle(color: EngCosmic.mute, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _result!.assumptions,
                  style: const TextStyle(
                    color: EngCosmic.mute,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Text(
                'Engineering sign-off checklist',
                style: TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              CheckboxListTile(
                value: _unitsChecked,
                onChanged: (bool? v) =>
                    setState(() => _unitsChecked = v ?? false),
                activeColor: EngCosmic.electric,
                title: const Text(
                  'SI units used (kg, m, N, N·m)',
                  style: TextStyle(color: EngCosmic.ink, fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _sfChecked,
                onChanged: (bool? v) => setState(() => _sfChecked = v ?? false),
                activeColor: EngCosmic.electric,
                title: const Text(
                  'Safety factor 1.25 applied and documented',
                  style: TextStyle(color: EngCosmic.ink, fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _assumptionsChecked,
                onChanged: (bool? v) =>
                    setState(() => _assumptionsChecked = v ?? false),
                activeColor: EngCosmic.electric,
                title: const Text(
                  'Assumptions reviewed (static tip load; teaching model)',
                  style: TextStyle(color: EngCosmic.ink, fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: EngCosmic.success,
            minimumSize: const Size.fromHeight(50),
          ),
          child: Text(
            done ? 'Resubmit sign-off' : 'Submit engineering sign-off',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: EngCosmic.mute),
        filled: true,
        fillColor: EngCosmic.panelAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EngCosmic.stroke),
        ),
      );
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.step, required this.onSelect});
  final int step;
  final ValueChanged<int> onSelect;

  static const List<String> _labels = <String>[
    'Brief',
    'Hand calc',
    'Design',
    'Simulate',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < _labels.length; i++) ...<Widget>[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= step ? EngCosmic.electric : EngCosmic.stroke,
              ),
            ),
          GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: i == step
                    ? EngCosmic.electric.withValues(alpha: 0.2)
                    : EngCosmic.panel,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: i <= step ? EngCosmic.electric : EngCosmic.stroke,
                ),
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  color: i <= step ? EngCosmic.ink : EngCosmic.mute,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: EngCosmic.panelBox(radius: 18),
      child: child,
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(k, style: const TextStyle(color: EngCosmic.mute)),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: EngCosmic.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(valueLabel, style: const TextStyle(color: EngCosmic.electric)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: EngCosmic.electric,
          inactiveColor: EngCosmic.stroke,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ArmPainter extends CustomPainter {
  _ArmPainter({required this.lengthFrac});
  final double lengthFrac;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = Paint()..color = EngCosmic.steel;
    final Paint arm = Paint()
      ..color = EngCosmic.electric
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final Offset pivot = Offset(size.width * 0.22, size.height * 0.72);
    final double len = size.width * 0.55 * lengthFrac;
    final Offset tip = Offset(pivot.dx + len, pivot.dy - len * 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pivot, width: 36, height: 22),
        const Radius.circular(4),
      ),
      base,
    );
    canvas.drawLine(pivot, tip, arm);
    canvas.drawCircle(tip, 10, Paint()..color = EngCosmic.gold);
  }

  @override
  bool shouldRepaint(covariant _ArmPainter oldDelegate) =>
      oldDelegate.lengthFrac != lengthFrac;
}
