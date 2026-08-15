import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/vu_v2_theme.dart';
import 'vu_v2_lab_models.dart';

typedef LabSimNotify = void Function(String message, {double? progressBump});

/// Interactive simulation workspace for a Virtual Lab experiment.
class VuV2LabSimulationArea extends StatelessWidget {
  const VuV2LabSimulationArea({
    super.key,
    required this.kind,
    required this.resetToken,
    required this.onNotify,
  });

  final VuV2LabSimulationKind kind;
  final int resetToken;
  final LabSimNotify onNotify;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (kind) {
      case VuV2LabSimulationKind.physicsGravity:
        child = _GravitySim(onNotify: onNotify);
      case VuV2LabSimulationKind.physicsCircuit:
        child = _CircuitSim(onNotify: onNotify);
      case VuV2LabSimulationKind.physicsProjectile:
        child = _ProjectileSim(onNotify: onNotify);
      case VuV2LabSimulationKind.chemistryReaction:
        child = _ReactionSim(onNotify: onNotify);
      case VuV2LabSimulationKind.chemistryPh:
        child = _PhSim(onNotify: onNotify);
      case VuV2LabSimulationKind.chemistryMolecule:
        child = _MoleculeSim(onNotify: onNotify);
      case VuV2LabSimulationKind.biologyAnatomy:
        child = _AnatomySim(onNotify: onNotify);
      case VuV2LabSimulationKind.biologyCell:
        child = _CellSim(onNotify: onNotify);
      case VuV2LabSimulationKind.biologyDna:
        child = _DnaSim(onNotify: onNotify);
      case VuV2LabSimulationKind.csEditor:
        child = _CsEditorSim(onNotify: onNotify);
      case VuV2LabSimulationKind.csDebug:
        child = _CsDebugSim(onNotify: onNotify);
      case VuV2LabSimulationKind.csChallenge:
        child = _CsChallengeSim(onNotify: onNotify);
      case VuV2LabSimulationKind.nursingPatient:
        child = _NursingPatientSim(onNotify: onNotify);
      case VuV2LabSimulationKind.nursingScenario:
        child = _NursingScenarioSim(onNotify: onNotify);
      case VuV2LabSimulationKind.nursingEquipment:
        child = _NursingEquipSim(onNotify: onNotify);
      case VuV2LabSimulationKind.businessCompany:
        child = _BizCompanySim(onNotify: onNotify);
      case VuV2LabSimulationKind.businessMarketing:
        child = _BizMarketingSim(onNotify: onNotify);
      case VuV2LabSimulationKind.businessFinance:
        child = _BizFinanceSim(onNotify: onNotify);
      case VuV2LabSimulationKind.psychologyMemory:
        child = _PsychMemorySim(onNotify: onNotify);
      case VuV2LabSimulationKind.psychologyAttention:
        child = _PsychAttentionSim(onNotify: onNotify);
      case VuV2LabSimulationKind.psychologyBias:
        child = _PsychBiasSim(onNotify: onNotify);
      case VuV2LabSimulationKind.mathGraph:
        child = _MathGraphSim(onNotify: onNotify);
      case VuV2LabSimulationKind.mathQuadratic:
        child = _MathQuadraticSim(onNotify: onNotify);
      case VuV2LabSimulationKind.mathProbability:
        child = _MathProbabilitySim(onNotify: onNotify);
      case VuV2LabSimulationKind.physicsWaves:
        child = _WavesSim(onNotify: onNotify);
      case VuV2LabSimulationKind.chemistryTitration:
        child = _TitrationSim(onNotify: onNotify);
      case VuV2LabSimulationKind.biologyEcology:
        child = _EcologySim(onNotify: onNotify);
    }
    return KeyedSubtree(
      key: ValueKey<int>(resetToken),
      child: child,
    );
  }
}

class _SimShell extends StatelessWidget {
  const _SimShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VuV2Colors.stroke),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            VuV2Colors.navyElevated,
            VuV2Colors.orange.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: child,
    );
  }
}

// ─── Physics ───────────────────────────────────────────────────────────────

class _GravitySim extends StatefulWidget {
  const _GravitySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_GravitySim> createState() => _GravitySimState();
}

class _GravitySimState extends State<_GravitySim>
    with SingleTickerProviderStateMixin {
  double _g = 9.8;
  late final AnimationController _ctrl;
  final List<String> _trials = <String>[];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _drop() {
    final int ms = (2200 * (9.8 / _g)).round().clamp(400, 3200);
    _ctrl.duration = Duration(milliseconds: ms);
    _ctrl.forward(from: 0);
    final String line =
        'g=${_g.toStringAsFixed(1)} → ~${(ms / 1000).toStringAsFixed(2)}s';
    setState(() {
      _trials.add(line);
      if (_trials.length > 4) {
        _trials.removeAt(0);
      }
    });
    String compare = '';
    if (_trials.length >= 2) {
      compare = ' Compare trials — which g fell faster, and why?';
    }
    widget.onNotify(
      'Dropped at $line.$compare',
      progressBump: _trials.length >= 2 ? 0.16 : 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Gravity: ${_g.toStringAsFixed(1)} m/s²',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ActionChip(
                label: const Text('Earth 9.8'),
                onPressed: () => setState(() => _g = 9.8),
              ),
              ActionChip(
                label: const Text('Moon 1.6'),
                onPressed: () => setState(() => _g = 1.6),
              ),
              ActionChip(
                label: const Text('Jupiter 24'),
                onPressed: () => setState(() => _g = 24),
              ),
            ],
          ),
          Slider(
            value: _g,
            min: 1.6,
            max: 24,
            onChanged: (double v) => setState(() => _g = v),
          ),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                return CustomPaint(
                  painter: _DropPainter(t: Curves.easeIn.transform(_ctrl.value)),
                );
              },
            ),
          ),
          FilledButton.icon(
            onPressed: _drop,
            icon: const Icon(Icons.arrow_downward_rounded),
            label: const Text('Drop mass'),
          ),
          if (_trials.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Trial log:\n${_trials.map((String e) => '• $e').join('\n')}',
              style: const TextStyle(
                color: VuV2Colors.mute,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DropPainter extends CustomPainter {
  _DropPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ground = Paint()..color = VuV2Colors.stroke;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 8, size.width, 8),
      ground,
    );
    final double y = 12 + (size.height - 40) * t;
    canvas.drawCircle(
      Offset(size.width / 2, y),
      14,
      Paint()..color = VuV2Colors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _DropPainter old) => old.t != t;
}

class _CircuitSim extends StatefulWidget {
  const _CircuitSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_CircuitSim> createState() => _CircuitSimState();
}

class _CircuitSimState extends State<_CircuitSim> {
  bool _a = false;
  bool _b = false;

  bool get _lit => _a && _b;

  void _toggle(String which) {
    setState(() {
      if (which == 'a') _a = !_a;
      if (which == 'b') _b = !_b;
    });
    widget.onNotify(
      _lit
          ? 'Closed loop — bulb is ON. Nice work.'
          : 'Circuit still open. Both switches must be closed.',
      progressBump: _lit ? 0.2 : 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _lit
                  ? VuV2Colors.yellow.withValues(alpha: 0.35)
                  : VuV2Colors.stroke,
              boxShadow: _lit
                  ? <BoxShadow>[
                      BoxShadow(
                        color: VuV2Colors.yellow.withValues(alpha: 0.45),
                        blurRadius: 24,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 48,
              color: _lit ? VuV2Colors.yellow : VuV2Colors.mute,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _toggle('a'),
                  child: Text(_a ? 'Switch A: CLOSED' : 'Switch A: OPEN'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _toggle('b'),
                  child: Text(_b ? 'Switch B: CLOSED' : 'Switch B: OPEN'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectileSim extends StatefulWidget {
  const _ProjectileSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_ProjectileSim> createState() => _ProjectileSimState();
}

class _ProjectileSimState extends State<_ProjectileSim>
    with SingleTickerProviderStateMixin {
  double _angle = 45;
  double _speed = 18;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _launch() {
    _ctrl.forward(from: 0);
    final double rad = _angle * math.pi / 180;
    final double range = (_speed * _speed * math.sin(2 * rad)) / 9.8;
    widget.onNotify(
      'Launched @ ${_angle.round()}° · v=${_speed.round()}. Ideal range ≈ ${range.toStringAsFixed(1)} units.',
      progressBump: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Angle ${_angle.round()}° · Speed ${_speed.round()}',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
          Slider(
            value: _angle,
            min: 10,
            max: 80,
            onChanged: (double v) => setState(() => _angle = v),
          ),
          Slider(
            value: _speed,
            min: 8,
            max: 30,
            onChanged: (double v) => setState(() => _speed = v),
          ),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                return CustomPaint(
                  painter: _ArcPainter(
                    t: _ctrl.value,
                    angleDeg: _angle,
                  ),
                );
              },
            ),
          ),
          FilledButton.icon(
            onPressed: _launch,
            icon: const Icon(Icons.sports_baseball_rounded),
            label: const Text('Launch'),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.t, required this.angleDeg});
  final double t;
  final double angleDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ground = Paint()..color = VuV2Colors.stroke;
    canvas.drawRect(Rect.fromLTWH(0, size.height - 6, size.width, 6), ground);
    final double rad = angleDeg * math.pi / 180;
    final Path path = Path();
    for (int i = 0; i <= 40; i++) {
      final double u = i / 40;
      final double x = u * size.width * 0.92;
      final double y = size.height -
          10 -
          math.sin(rad) * size.height * 0.75 * math.sin(math.pi * u);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = VuV2Colors.mute
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final double x = t * size.width * 0.92;
    final double y = size.height -
        10 -
        math.sin(rad) * size.height * 0.75 * math.sin(math.pi * t);
    canvas.drawCircle(Offset(x, y), 8, Paint()..color = VuV2Colors.orange);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.t != t || old.angleDeg != angleDeg;
}

// ─── Chemistry ─────────────────────────────────────────────────────────────

class _ReactionSim extends StatefulWidget {
  const _ReactionSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_ReactionSim> createState() => _ReactionSimState();
}

class _ReactionSimState extends State<_ReactionSim> {
  int _a = 0;
  int _b = 0;

  @override
  Widget build(BuildContext context) {
    final bool reacted = _a > 0 && _b > 0;
    final Color brew = Color.lerp(
          const Color(0xFF38BDF8),
          const Color(0xFFA855F7),
          ((_a + _b) / 10).clamp(0.0, 1.0),
        ) ??
        VuV2Colors.orange;

    return _SimShell(
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: 120,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              border: Border.all(color: VuV2Colors.ink.withValues(alpha: 0.4)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  brew.withValues(alpha: reacted ? 0.85 : 0.25),
                  brew.withValues(alpha: reacted ? 1 : 0.45),
                ],
              ),
            ),
            child: reacted
                ? const Center(child: Text('🫧', style: TextStyle(fontSize: 28)))
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() => _a++);
                    widget.onNotify(
                      'Added Reagent A (total $_a).',
                      progressBump: 0.08,
                    );
                  },
                  child: Text('Add A ($_a)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() => _b++);
                    widget.onNotify(
                      'Added Reagent B (total $_b).${reacted || _a > 0 ? ' Reaction underway.' : ''}',
                      progressBump: 0.08,
                    );
                  },
                  child: Text('Add B ($_b)'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhSim extends StatefulWidget {
  const _PhSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_PhSim> createState() => _PhSimState();
}

class _PhSimState extends State<_PhSim> {
  double _ph = 7;

  Color get _color {
    if (_ph < 4) return const Color(0xFFEF4444);
    if (_ph < 6) return const Color(0xFFF97316);
    if (_ph < 8) return const Color(0xFF22C55E);
    if (_ph < 10) return const Color(0xFF38BDF8);
    return const Color(0xFF6366F1);
  }

  String get _label {
    if (_ph < 7) return 'Acidic';
    if (_ph > 7) return 'Basic';
    return 'Neutral';
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _color.withValues(alpha: 0.45),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'pH ${_ph.toStringAsFixed(1)} · $_label',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _ph,
            min: 0,
            max: 14,
            divisions: 28,
            onChanged: (double v) {
              setState(() => _ph = v);
              widget.onNotify('Indicator reads pH ${v.toStringAsFixed(1)} ($_label).');
            },
            onChangeEnd: (_) => widget.onNotify(
              'Logged pH ${_ph.toStringAsFixed(1)}.',
              progressBump: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoleculeSim extends StatefulWidget {
  const _MoleculeSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_MoleculeSim> createState() => _MoleculeSimState();
}

class _MoleculeSimState extends State<_MoleculeSim> {
  int _h = 0;
  int _o = 0;

  bool get _matched => _h == 2 && _o == 1;

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Target: H₂O',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Built: H$_h O$_o ${_matched ? '✓' : ''}',
            style: TextStyle(
              color: _matched ? VuV2Colors.success : VuV2Colors.mute,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: <Widget>[
              FilledButton(
                onPressed: () {
                  setState(() => _h++);
                  widget.onNotify(
                    'Added H. Count H=$_h O=$_o',
                    progressBump: _matched ? 0.25 : 0.06,
                  );
                },
                child: const Text('+ H'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() => _o++);
                  widget.onNotify(
                    'Added O. Count H=$_h O=$_o',
                    progressBump: _matched ? 0.25 : 0.06,
                  );
                },
                child: const Text('+ O'),
              ),
            ],
          ),
          if (_matched)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Water assembled. Excellent stoichiometry.',
                style: TextStyle(color: VuV2Colors.orange, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Biology ───────────────────────────────────────────────────────────────

class _AnatomySim extends StatefulWidget {
  const _AnatomySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_AnatomySim> createState() => _AnatomySimState();
}

class _AnatomySimState extends State<_AnatomySim> {
  String? _selected;

  static const List<String> _organIds = <String>[
    'heart',
    'lungs',
    'brain',
    'liver',
  ];
  static const List<String> _organLabels = <String>[
    'Heart',
    'Lungs',
    'Brain',
    'Liver',
  ];
  static const List<String> _organRoles = <String>[
    'Pumps blood through the body',
    'Gas exchange (O2 / CO2)',
    'Controls thought and body systems',
    'Metabolism and detoxification',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[];
    for (int i = 0; i < _organIds.length; i++) {
      final String id = _organIds[i];
      final String label = _organLabels[i];
      final String role = _organRoles[i];
      final bool on = _selected == id;
      chips.add(
        ChoiceChip(
          label: Text(label),
          selected: on,
          onSelected: (_) {
            setState(() => _selected = id);
            widget.onNotify('$label: $role', progressBump: 0.12);
          },
        ),
      );
    }

    String? roleText;
    if (_selected != null) {
      for (int i = 0; i < _organIds.length; i++) {
        if (_organIds[i] == _selected) {
          roleText = _organRoles[i];
          break;
        }
      }
    }

    return _SimShell(
      child: Column(
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
          if (roleText != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              roleText,
              style: const TextStyle(color: VuV2Colors.ink, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _CellSim extends StatefulWidget {
  const _CellSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_CellSim> createState() => _CellSimState();
}

class _CellSimState extends State<_CellSim> {
  String? _focus;

  static const Map<String, String> _roles = <String, String>{
    'Nucleus': 'Stores DNA and directs cell activity',
    'Mitochondria': 'Produces ATP energy',
    'Membrane': 'Controls what enters and leaves',
    'Ribosome': 'Builds proteins',
  };

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roles.keys.map((String k) {
              return ActionChip(
                label: Text(k),
                onPressed: () {
                  setState(() => _focus = k);
                  widget.onNotify('$k — ${_roles[k]}', progressBump: 0.12);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _focus == null ? 'Tap an organelle to inspect.' : _roles[_focus]!,
            style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DnaSim extends StatefulWidget {
  const _DnaSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_DnaSim> createState() => _DnaSimState();
}

class _DnaSimState extends State<_DnaSim> {
  static const List<String> _template = <String>['A', 'C', 'G', 'T', 'A'];
  final List<String?> _built = List<String?>.filled(5, null);

  String _pair(String b) {
    if (b == 'A') return 'T';
    if (b == 'T') return 'A';
    if (b == 'C') return 'G';
    if (b == 'G') return 'C';
    return '?';
  }

  void _pick(int i, String base) {
    setState(() => _built[i] = base);
    final bool ok = base == _pair(_template[i]);
    int done = 0;
    for (int j = 0; j < _built.length; j++) {
      if (_built[j] == _pair(_template[j])) {
        done++;
      }
    }
    widget.onNotify(
      ok ? 'Correct pair at position ${i + 1}.' : 'Check base-pairing rules.',
      progressBump: ok ? 0.12 : 0.02,
    );
    if (done == _template.length) {
      widget.onNotify('Full complementary strand complete!', progressBump: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Template: ${_template.join(' · ')}',
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(_template.length, (int i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    child: Text(
                      _template[i],
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Text('→ ', style: TextStyle(color: VuV2Colors.mute)),
                  Wrap(
                    spacing: 6,
                    children: <String>['A', 'T', 'C', 'G'].map((String b) {
                      final bool selected = _built[i] == b;
                      return ChoiceChip(
                        label: Text(b),
                        selected: selected,
                        onSelected: (_) => _pick(i, b),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── CS ────────────────────────────────────────────────────────────────────

class _CsEditorSim extends StatefulWidget {
  const _CsEditorSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_CsEditorSim> createState() => _CsEditorSimState();
}

class _CsEditorSimState extends State<_CsEditorSim> {
  late final TextEditingController _code;
  String _out = '';

  static const String _starter =
      'print("Hello, Virtual Lab")\nprint(2 + 2)';

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: _starter);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _run() {
    final String src = _code.text;
    final List<String> lines = <String>[];
    for (final String raw in src.split('\n')) {
      final String line = raw.trim();
      final RegExp printStr = RegExp(r'print\("([^"]*)"\)');
      final RegExp printAdd = RegExp(r'print\((\d+)\s*\+\s*(\d+)\)');
      final Match? m1 = printStr.firstMatch(line);
      final Match? m2 = printAdd.firstMatch(line);
      if (m1 != null) {
        lines.add(m1.group(1)!);
      } else if (m2 != null) {
        lines.add(
          '${int.parse(m2.group(1)!) + int.parse(m2.group(2)!)}',
        );
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        lines.add('(demo runtime skipped: $line)');
      }
    }
    setState(() => _out = lines.isEmpty ? '(no output)' : lines.join('\n'));
    widget.onNotify('Program ran. Review output below.', progressBump: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _code,
            maxLines: 5,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: VuV2Colors.ink,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: VuV2Colors.navy,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Run'),
          ),
          if (_out.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _out,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: VuV2Colors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CsDebugSim extends StatefulWidget {
  const _CsDebugSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_CsDebugSim> createState() => _CsDebugSimState();
}

class _CsDebugSimState extends State<_CsDebugSim> {
  int? _choice;

  static const String _bug =
      'for i in range(1, 5):\n  # supposed to print 1..5\n  print(i)';

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Buggy snippet',
            style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            _bug,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: VuV2Colors.ink,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'What fix prints 1 through 5?',
            style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
          ),
          ...List<Widget>.generate(3, (int i) {
            final List<String> opts = <String>[
              'range(1, 6)',
              'range(0, 5)',
              'range(5)',
            ];
            final bool selected = _choice == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: VuV2Colors.navy,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _choice = i);
                    final bool ok = i == 0;
                    widget.onNotify(
                      ok
                          ? 'Yes — range(1, 6) yields 1..5.'
                          : 'Not quite — dry-run the loop bounds.',
                      progressBump: ok ? 0.25 : 0.05,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? VuV2Colors.orange : VuV2Colors.stroke,
                      ),
                    ),
                    child: Text(
                      opts[i],
                      style: const TextStyle(color: VuV2Colors.ink),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CsChallengeSim extends StatefulWidget {
  const _CsChallengeSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_CsChallengeSim> createState() => _CsChallengeSimState();
}

class _CsChallengeSimState extends State<_CsChallengeSim> {
  final TextEditingController _ans = TextEditingController();
  String? _feedback;

  @override
  void dispose() {
    _ans.dispose();
    super.dispose();
  }

  void _submit() {
    final String t = _ans.text.trim();
    final bool ok = t == '15' || t.toLowerCase() == 'sum=15';
    setState(() => _feedback = ok ? 'Correct — 1+2+…+5 = 15.' : 'Try again.');
    widget.onNotify(
      _feedback!,
      progressBump: ok ? 0.3 : 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Challenge: What is the sum of integers from 1 to 5?',
            style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ans,
            style: const TextStyle(color: VuV2Colors.ink),
            decoration: const InputDecoration(
              hintText: 'Your answer',
              hintStyle: TextStyle(color: VuV2Colors.mute),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(onPressed: _submit, child: const Text('Submit')),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: TextStyle(color: VuV2Colors.orange)),
          ],
        ],
      ),
    );
  }
}

// ─── Nursing ───────────────────────────────────────────────────────────────

class _NursingPatientSim extends StatefulWidget {
  const _NursingPatientSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_NursingPatientSim> createState() => _NursingPatientSimState();
}

class _NursingPatientSimState extends State<_NursingPatientSim> {
  int _step = 0;
  int _hr = 118;
  int _spo2 = 89;
  int _rr = 28;
  String _status = 'Anxious · sitting upright · using accessory muscles';
  String? _path;
  final List<String> _timeline = <String>[];

  void _choose(String label, void Function() apply) {
    setState(() {
      _timeline.add(label);
      apply();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _step >= 3
                ? 'Virtual patient · case complete'
                : 'Virtual patient · Step ${_step + 1}/3',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'HR $_hr · SpO₂ $_spo2% · RR $_rr · $_status',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          if (_step == 0) ..._stepAssess(),
          if (_step == 1) ..._stepAct(),
          if (_step == 2) ..._stepReassess(),
          if (_step >= 3) ...<Widget>[
            Text(
              (_spo2 >= 92 && _path != 'unsafe')
                  ? 'Case closed safely. Write the vitals trend in your notebook.'
                  : 'Stabilized only after escalation. Write what you would do differently on Day 1.',
              style: TextStyle(
                color: VuV2Colors.orange,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
          if (_timeline.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Timeline: ${_timeline.join(' → ')}',
              style: const TextStyle(color: VuV2Colors.mute, fontSize: 12, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _stepAssess() {
    return <Widget>[
      const Text(
        'Priority assessment — what do you do first?',
        style: TextStyle(color: VuV2Colors.mute),
      ),
      const SizedBox(height: 8),
      _btn('ABC focus: airway/breathing + SpO₂ check', () {
        _choose('ABC/SpO₂ first', () {
          _path = 'safe';
          _step = 1;
          widget.onNotify(
            'Correct priority — oxygenation before charting.',
            progressBump: 0.12,
          );
        });
      }),
      _btn('Finish unrelated charting, then reassess later', () {
        _choose('Delayed for charting', () {
          _path = 'delay';
          _hr = 126;
          _spo2 = 86;
          _rr = 32;
          _status = 'Worsening · more distressed';
          _step = 1;
          widget.onNotify(
            'Delay hurt the patient. Vitals worsened. Recover with action.',
            progressBump: 0.04,
          );
        });
      }),
      _btn('Encourage hallway ambulation to “calm nerves”', () {
        _choose('Unsafe ambulation', () {
          _path = 'unsafe';
          _hr = 132;
          _spo2 = 84;
          _rr = 34;
          _status = 'Unsafe exertion · near syncope risk';
          _step = 1;
          widget.onNotify(
            'Harmful plan. Hypoxemic patients do not ambulate for anxiety.',
            progressBump: 0.02,
          );
        });
      }),
    ];
  }

  List<Widget> _stepAct() {
    return <Widget>[
      const Text(
        'Intervention — choose the next clinical move.',
        style: TextStyle(color: VuV2Colors.mute),
      ),
      const SizedBox(height: 8),
      _btn('Apply O₂ per protocol, elevate HOB, stay & reassess', () {
        _choose('O₂ + elevate + stay', () {
          _spo2 = (_spo2 + 6).clamp(88, 98);
          _rr = (_rr - 4).clamp(16, 40);
          _hr = (_hr - 8).clamp(70, 140);
          _status = 'Improving · less accessory use';
          _step = 2;
          widget.onNotify(
            'Intervention applied. Reassess loop unlocked.',
            progressBump: 0.18,
          );
        });
      }),
      _btn('Increase activity and leave the room to grab coffee', () {
        _choose('Left without support', () {
          _spo2 = (_spo2 - 5).clamp(70, 98);
          _rr += 3;
          _hr += 6;
          _status = 'Alone · desaturating';
          _step = 2;
          widget.onNotify(
            'Abandonment + no support = preventable harm.',
            progressBump: 0.03,
          );
        });
      }),
    ];
  }

  List<Widget> _stepReassess() {
    final bool recovered = _spo2 >= 92 && _path != 'unsafe';
    return <Widget>[
      Text(
        recovered
            ? 'Reassessment: SpO₂ recovering. Document response and notify provider as indicated.'
            : 'Reassessment: still unstable. Escalate — rapid response / provider now.',
        style: const TextStyle(color: VuV2Colors.mute, height: 1.35),
      ),
      const SizedBox(height: 8),
      _btn(
        recovered
            ? 'Document response + continue monitoring'
            : 'Call rapid response / escalate now',
        () {
          _choose(recovered ? 'Documented & monitoring' : 'Escalated', () {
            widget.onNotify(
              recovered
                  ? 'Clean clinical loop: assess → act → reassess → document.'
                  : 'Escalation after failed trajectory — still credit for closing the loop.',
              progressBump: recovered ? 0.22 : 0.14,
            );
            _step = 3;
          });
        },
      ),
    ];
  }

  Widget _btn(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }
}

class _NursingScenarioSim extends StatefulWidget {
  const _NursingScenarioSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_NursingScenarioSim> createState() => _NursingScenarioSimState();
}

class _NursingScenarioSimState extends State<_NursingScenarioSim> {
  int _node = 0;
  int _score = 50;
  String _story =
      'Post-op day 1. Patient reports sudden chest pain and dizziness. '
      'BP 88/54 · HR 128 · pale · diaphoretic.';
  final List<String> _trail = <String>[];

  void _go(String choice, int next, int delta, String consequence) {
    setState(() {
      _trail.add(choice);
      _score = (_score + delta).clamp(0, 100);
      _node = next;
      _story = consequence;
    });
    widget.onNotify(
      'Branch: $choice · clinical score $_score/100',
      progressBump: delta > 0 ? 0.14 : 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Scenario ward · judgment score $_score/100',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _story,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (_node == 0) ...<Widget>[
            _opt(
              'Call rapid response, stay at bedside, get vitals & O₂ sat',
              () => _go(
                'Rapid response',
                1,
                20,
                'Team inbound. You stay. SpO₂ 91% on room air. Pain 8/10, pressure-like.',
              ),
            ),
            _opt(
              'Wait 20 minutes — “maybe gas pain”',
              () => _go(
                'Waited',
                2,
                -25,
                '20 minutes later: BP 78/48, barely arousable. You lost the golden window.',
              ),
            ),
            _opt(
              'Send patient to bathroom alone to “settle”',
              () => _go(
                'Sent alone',
                2,
                -30,
                'Patient found on floor near bathroom. Syncope + possible PE/bleed emergency.',
              ),
            ),
          ],
          if (_node == 1) ...<Widget>[
            _opt(
              'Keep NPO, monitor, prepare for possible PE workup / orders',
              () => _go(
                'Monitor + prepare',
                3,
                18,
                'Strong. You anticipate orders, keep patient safe, reassess every few minutes.',
              ),
            ),
            _opt(
              'Give water and encourage deep ambulation now',
              () => _go(
                'Ambulate unstable pt',
                3,
                -15,
                'Ambulation under hypotension was reckless. Score damaged — document the miss.',
              ),
            ),
          ],
          if (_node == 2) ...<Widget>[
            _opt(
              'Escalate NOW: rapid response + crash cart readiness',
              () => _go(
                'Late escalate',
                3,
                10,
                'Late but correct recovery. Survival improved — reflection required in notebook.',
              ),
            ),
          ],
          if (_node == 3) ...<Widget>[
            Text(
              _score >= 70
                  ? 'Debrief ready: you protected the patient under uncertainty.'
                  : 'Debrief ready: survival depended on recovery moves — write the failure mode.',
              style: TextStyle(
                color: VuV2Colors.orange,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${_trail.join(' → ')}',
              style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _opt(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }
}

class _NursingEquipSim extends StatefulWidget {
  const _NursingEquipSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_NursingEquipSim> createState() => _NursingEquipSimState();
}

class _NursingEquipSimState extends State<_NursingEquipSim> {
  @override
  Widget build(BuildContext context) {
    const List<String> names = <String>[
      'Pulse oximeter',
      'BP cuff',
      'IV pump',
    ];
    const List<String> uses = <String>[
      'Estimates SpO2 and pulse',
      'Measures blood pressure',
      'Delivers controlled infusions',
    ];
    final List<Widget> tiles = <Widget>[];
    for (int i = 0; i < names.length; i++) {
      final String name = names[i];
      final String use = uses[i];
      tiles.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.medical_services_outlined,
            color: VuV2Colors.orange,
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(use, style: const TextStyle(color: VuV2Colors.mute)),
          onTap: () => widget.onNotify('$name: $use', progressBump: 0.1),
        ),
      );
    }
    return _SimShell(
      child: Column(children: tiles),
    );
  }
}

// ─── Business ──────────────────────────────────────────────────────────────

class _BizCompanySim extends StatefulWidget {
  const _BizCompanySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_BizCompanySim> createState() => _BizCompanySimState();
}

class _BizCompanySimState extends State<_BizCompanySim> {
  double _hire = 40;
  double _mkt = 30;
  double _rd = 30;
  double _revenue = 100;
  double _morale = 70;

  void _sim() {
    setState(() {
      _revenue = 80 + _mkt * 0.9 + _rd * 0.5 + _hire * 0.35;
      _morale = (55 + _hire * 0.4 - (_mkt + _rd - 60).abs() * 0.15)
          .clamp(20, 100);
    });
    widget.onNotify(
      'Quarter result — revenue ${_revenue.round()}, morale ${_morale.round()}.',
      progressBump: 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hiring ${_hire.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _hire, min: 0, max: 100, onChanged: (v) => setState(() => _hire = v)),
          Text('Marketing ${_mkt.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _mkt, min: 0, max: 100, onChanged: (v) => setState(() => _mkt = v)),
          Text('R&D ${_rd.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _rd, min: 0, max: 100, onChanged: (v) => setState(() => _rd = v)),
          Text(
            'KPIs · Revenue ${_revenue.round()} · Morale ${_morale.round()}',
            style: TextStyle(color: VuV2Colors.orange, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _sim, child: const Text('Simulate quarter')),
        ],
      ),
    );
  }
}

class _BizMarketingSim extends StatefulWidget {
  const _BizMarketingSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_BizMarketingSim> createState() => _BizMarketingSimState();
}

class _BizMarketingSimState extends State<_BizMarketingSim> {
  double _social = 40;
  double _search = 40;
  double _email = 20;
  String _result = '';

  void _launch() {
    final double reach = _social * 1.2 + _search * 1.0 + _email * 0.6;
    final double conv = _email * 1.4 + _search * 0.9 + _social * 0.5;
    setState(() {
      _result = 'Reach ${reach.round()} · Conversions ${conv.round()}';
    });
    widget.onNotify(_result, progressBump: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Social ${_social.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _social, min: 0, max: 100, onChanged: (v) => setState(() => _social = v)),
          Text('Search ${_search.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _search, min: 0, max: 100, onChanged: (v) => setState(() => _search = v)),
          Text('Email ${_email.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _email, min: 0, max: 100, onChanged: (v) => setState(() => _email = v)),
          FilledButton(onPressed: _launch, child: const Text('Launch campaign')),
          if (_result.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(_result, style: TextStyle(color: VuV2Colors.orange, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class _BizFinanceSim extends StatefulWidget {
  const _BizFinanceSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_BizFinanceSim> createState() => _BizFinanceSimState();
}

class _BizFinanceSimState extends State<_BizFinanceSim> {
  double _safe = 50;
  double _growth = 30;
  double _spec = 20;
  String _proj = '';

  void _project() {
    final double expected = _safe * 1.04 + _growth * 1.12 + _spec * 1.25;
    final double risk = _spec * 1.5 + _growth * 0.7;
    setState(() {
      _proj =
          'Expected value ${expected.round()} · Risk index ${risk.round()}';
    });
    widget.onNotify(_proj, progressBump: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Safe ${_safe.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _safe, min: 0, max: 100, onChanged: (v) => setState(() => _safe = v)),
          Text('Growth ${_growth.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _growth, min: 0, max: 100, onChanged: (v) => setState(() => _growth = v)),
          Text('Speculative ${_spec.round()}', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(value: _spec, min: 0, max: 100, onChanged: (v) => setState(() => _spec = v)),
          FilledButton(onPressed: _project, child: const Text('Project year')),
          if (_proj.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(_proj, style: TextStyle(color: VuV2Colors.orange, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

// ─── Psych / Math ──────────────────────────────────────────────────────────

class _PsychMemorySim extends StatefulWidget {
  const _PsychMemorySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_PsychMemorySim> createState() => _PsychMemorySimState();
}

class _PsychMemorySimState extends State<_PsychMemorySim> {
  static const List<String> _seq = <String>['7', '2', '9', '4', '1'];
  bool _show = true;
  final TextEditingController _recall = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  void dispose() {
    _recall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _show ? 'Memorize: ${_seq.join(' · ')}' : 'Sequence hidden — recall it.',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          if (!_show) ...<Widget>[
            TextField(
              controller: _recall,
              style: const TextStyle(color: VuV2Colors.ink),
              decoration: const InputDecoration(
                hintText: 'e.g. 7 2 9 4 1',
                hintStyle: TextStyle(color: VuV2Colors.mute),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                final String cleaned =
                    _recall.text.replaceAll(RegExp(r'[^0-9]'), '');
                final bool ok = cleaned == _seq.join();
                widget.onNotify(
                  ok ? 'Strong recall!' : 'Not exact — try chunking next time.',
                  progressBump: ok ? 0.3 : 0.08,
                );
              },
              child: const Text('Check recall'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MathGraphSim extends StatefulWidget {
  const _MathGraphSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_MathGraphSim> createState() => _MathGraphSimState();
}

class _MathGraphSimState extends State<_MathGraphSim> {
  double _m = 1;
  double _b = 0;

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'y = ${_m.toStringAsFixed(1)}x + ${_b.toStringAsFixed(1)}',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text('Slope m', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _m,
            min: -3,
            max: 3,
            onChanged: (double v) {
              setState(() => _m = v);
              widget.onNotify('Updated slope to ${v.toStringAsFixed(1)}');
            },
            onChangeEnd: (_) => widget.onNotify('Slope locked.', progressBump: 0.08),
          ),
          Text('Intercept b', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _b,
            min: -4,
            max: 4,
            onChanged: (double v) {
              setState(() => _b = v);
              widget.onNotify('Updated intercept to ${v.toStringAsFixed(1)}');
            },
            onChangeEnd: (_) =>
                widget.onNotify('Intercept locked.', progressBump: 0.08),
          ),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _LinePainter(m: _m, b: _b),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.m, required this.b});
  final double m;
  final double b;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = VuV2Colors.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axis,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      axis,
    );
    final Path path = Path();
    for (int i = 0; i <= 40; i++) {
      final double nx = i / 40;
      final double x = (nx - 0.5) * 8;
      final double y = m * x + b;
      final double px = nx * size.width;
      final double py = size.height / 2 - y * (size.height / 10);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = VuV2Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.m != m || old.b != b;
}

class _PsychAttentionSim extends StatefulWidget {
  const _PsychAttentionSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_PsychAttentionSim> createState() => _PsychAttentionSimState();
}

class _PsychAttentionSimState extends State<_PsychAttentionSim> {
  int _hits = 0;
  int _falseAlarms = 0;
  bool _targetUp = false;
  int _round = 0;

  void _flash() {
    setState(() {
      _round++;
      _targetUp = math.Random().nextDouble() < 0.35;
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _targetUp = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Sustained attention · Tap only when the TARGET appears',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hits $_hits · False alarms $_falseAlarms · Rounds $_round',
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 14),
          Container(
            height: 110,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _targetUp
                  ? VuV2Colors.orange.withValues(alpha: 0.35)
                  : VuV2Colors.navy,
              border: Border.all(color: VuV2Colors.stroke),
            ),
            child: Text(
              _targetUp ? 'TARGET' : '— wait —',
              style: TextStyle(
                color: _targetUp ? VuV2Colors.orange : VuV2Colors.mute,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              FilledButton(
                onPressed: _flash,
                child: const Text('Next flash'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  if (_targetUp) {
                    setState(() => _hits++);
                    widget.onNotify('Hit! Signal detected.', progressBump: 0.12);
                  } else {
                    setState(() => _falseAlarms++);
                    widget.onNotify(
                      'False alarm — restraint is part of attention.',
                      progressBump: 0.04,
                    );
                  }
                },
                child: const Text('Respond'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PsychBiasSim extends StatefulWidget {
  const _PsychBiasSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_PsychBiasSim> createState() => _PsychBiasSimState();
}

class _PsychBiasSimState extends State<_PsychBiasSim> {
  int? _pick;

  static const List<String> _options = <String>[
    'Trust the vivid anecdote over the base rate',
    'Update your belief using the base rate + evidence',
    'Ignore all data and go with gut forever',
  ];

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Bias desk · Base-rate neglect',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A clinic test for a rare disease (1 in 1000) is 99% accurate. '
            'A patient tests positive. What should a careful analyst do?',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: _pick == i
                    ? VuV2Colors.orange.withValues(alpha: 0.2)
                    : VuV2Colors.navy,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _pick = i);
                    final bool good = i == 1;
                    widget.onNotify(
                      good
                          ? 'Strong scientific habit — combine base rate with likelihood.'
                          : 'That choice leans into a classic cognitive bias.',
                      progressBump: good ? 0.28 : 0.08,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _options[i],
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MathQuadraticSim extends StatefulWidget {
  const _MathQuadraticSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_MathQuadraticSim> createState() => _MathQuadraticSimState();
}

class _MathQuadraticSimState extends State<_MathQuadraticSim> {
  double _a = 1;
  double _b = 0;
  double _c = 0;

  @override
  Widget build(BuildContext context) {
    final double disc = _b * _b - 4 * _a * _c;
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'y = ${_a.toStringAsFixed(1)}x² + ${_b.toStringAsFixed(1)}x + ${_c.toStringAsFixed(1)}',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text(
            'Discriminant Δ = ${disc.toStringAsFixed(1)}'
            '${disc > 0 ? ' · two roots' : disc == 0 ? ' · one root' : ' · no real roots'}',
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 6),
          Text('a (opens up/down)', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _a,
            min: -2,
            max: 2,
            onChanged: (double v) {
              if (v.abs() < 0.05) v = 0.05;
              setState(() => _a = v);
            },
            onChangeEnd: (_) =>
                widget.onNotify('Parabola a updated.', progressBump: 0.08),
          ),
          Text('b', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _b,
            min: -4,
            max: 4,
            onChanged: (double v) => setState(() => _b = v),
            onChangeEnd: (_) =>
                widget.onNotify('Linear term b updated.', progressBump: 0.06),
          ),
          Text('c', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _c,
            min: -4,
            max: 4,
            onChanged: (double v) => setState(() => _c = v),
            onChangeEnd: (_) =>
                widget.onNotify('Constant c updated.', progressBump: 0.06),
          ),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _QuadPainter(a: _a, b: _b, c: _c),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuadPainter extends CustomPainter {
  _QuadPainter({required this.a, required this.b, required this.c});
  final double a;
  final double b;
  final double c;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axis = Paint()
      ..color = VuV2Colors.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axis,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      axis,
    );
    final Path path = Path();
    for (int i = 0; i <= 50; i++) {
      final double nx = i / 50;
      final double x = (nx - 0.5) * 8;
      final double y = a * x * x + b * x + c;
      final double px = nx * size.width;
      final double py = size.height / 2 - y * (size.height / 14);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF818CF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _QuadPainter old) =>
      old.a != a || old.b != b || old.c != c;
}

class _MathProbabilitySim extends StatefulWidget {
  const _MathProbabilitySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_MathProbabilitySim> createState() => _MathProbabilitySimState();
}

class _MathProbabilitySimState extends State<_MathProbabilitySim> {
  int _trials = 0;
  int _heads = 0;

  @override
  Widget build(BuildContext context) {
    final double p = _trials == 0 ? 0 : _heads / _trials;
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Fair coin · Law of large numbers',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trials $_trials · Heads $_heads · Empirical p = ${p.toStringAsFixed(3)}',
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: p.clamp(0.0, 1.0),
              minHeight: 10,
              color: VuV2Colors.orange,
              backgroundColor: VuV2Colors.stroke,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: () {
                  setState(() {
                    _trials++;
                    if (math.Random().nextBool()) _heads++;
                  });
                  widget.onNotify('Flip recorded.', progressBump: 0.04);
                },
                child: const Text('Flip once'),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < 50; i++) {
                      _trials++;
                      if (math.Random().nextBool()) _heads++;
                    }
                  });
                  widget.onNotify(
                    '50 flips — empirical rate drifts toward 0.5.',
                    progressBump: 0.15,
                  );
                },
                child: const Text('Flip ×50'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _trials = 0;
                    _heads = 0;
                  });
                  widget.onNotify('Reset coin desk.');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavesSim extends StatefulWidget {
  const _WavesSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_WavesSim> createState() => _WavesSimState();
}

class _WavesSimState extends State<_WavesSim> {
  double _amp = 1.2;
  double _freq = 1.5;

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Wave desk · A=${_amp.toStringAsFixed(1)}  f=${_freq.toStringAsFixed(1)}',
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text('Amplitude', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _amp,
            min: 0.3,
            max: 2.5,
            onChanged: (double v) => setState(() => _amp = v),
            onChangeEnd: (_) =>
                widget.onNotify('Amplitude locked.', progressBump: 0.08),
          ),
          Text('Frequency', style: const TextStyle(color: VuV2Colors.mute)),
          Slider(
            value: _freq,
            min: 0.5,
            max: 4,
            onChanged: (double v) => setState(() => _freq = v),
            onChangeEnd: (_) =>
                widget.onNotify('Frequency locked.', progressBump: 0.08),
          ),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _WavePainter(amp: _amp, freq: _freq),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.amp, required this.freq});
  final double amp;
  final double freq;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    for (int i = 0; i <= 80; i++) {
      final double nx = i / 80;
      final double y =
          math.sin(nx * math.pi * 2 * freq) * amp * (size.height / 4);
      final Offset p = Offset(nx * size.width, size.height / 2 - y);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.amp != amp || old.freq != freq;
}

class _TitrationSim extends StatefulWidget {
  const _TitrationSim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_TitrationSim> createState() => _TitrationSimState();
}

class _TitrationSimState extends State<_TitrationSim> {
  double _ml = 0;
  static const double _end = 25;

  @override
  Widget build(BuildContext context) {
    final double ratio = (_ml / _end).clamp(0.0, 1.4);
    Color color;
    String label;
    if (ratio < 0.85) {
      color = const Color(0xFFFBBF24);
      label = 'Acidic · indicator yellow';
    } else if (ratio < 1.05) {
      color = const Color(0xFF34D399);
      label = 'Near endpoint · green flash';
    } else {
      color = const Color(0xFFA78BFA);
      label = 'Past endpoint · basic purple';
    }
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Titration bench · add base to acid',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_ml.toStringAsFixed(1)} mL base added · target ~$_end mL',
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 10),
          Container(
            height: 90,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withValues(alpha: 0.45),
              border: Border.all(color: color),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          Slider(
            value: _ml,
            min: 0,
            max: 40,
            onChanged: (double v) => setState(() => _ml = v),
            onChangeEnd: (double v) {
              final bool near = (v - _end).abs() < 1.5;
              widget.onNotify(
                near
                    ? 'Endpoint captured — record volume in notebook.'
                    : 'Keep titrating carefully toward ~$_end mL.',
                progressBump: near ? 0.25 : 0.06,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EcologySim extends StatefulWidget {
  const _EcologySim({required this.onNotify});
  final LabSimNotify onNotify;

  @override
  State<_EcologySim> createState() => _EcologySimState();
}

class _EcologySimState extends State<_EcologySim> {
  int _prey = 40;
  int _pred = 12;

  void _step() {
    setState(() {
      final int births = (_prey * 0.25).round();
      final int eaten = math.min(_prey, (_pred * 1.4).round());
      _prey = (_prey + births - eaten).clamp(5, 120);
      final int predChange = (eaten / 3).round() - (_pred * 0.15).round();
      _pred = (_pred + predChange).clamp(2, 60);
    });
    widget.onNotify(
      'Season advanced · prey $_prey · predators $_pred',
      progressBump: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SimShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Ecology bay · predator–prey balance',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text('Prey $_prey', style: const TextStyle(color: VuV2Colors.mute)),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _prey / 120,
              minHeight: 8,
              color: const Color(0xFF34D399),
              backgroundColor: VuV2Colors.stroke,
            ),
          ),
          const SizedBox(height: 10),
          Text('Predators $_pred', style: const TextStyle(color: VuV2Colors.mute)),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _pred / 60,
              minHeight: 8,
              color: const Color(0xFFFB7185),
              backgroundColor: VuV2Colors.stroke,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _step,
            child: const Text('Advance one season'),
          ),
        ],
      ),
    );
  }
}
