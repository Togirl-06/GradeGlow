import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Forgeworks — Junior Engineer under Mina Park.
Widget engineeringPlayableScreen() => const EngineeringPlayableScreen();

class EngineeringPlayableScreen extends StatelessWidget {
  const EngineeringPlayableScreen({super.key});

  static const Color accent = Color(0xFFFBBF24);
  static const Color bg = Color(0xFF12100A);
  static const Color surface = Color(0xFF1F1A10);

  static const PlayableCareer career = PlayableCareer(
    id: 'engineering',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Forgeworks',
    clockLine: 'Monday — 8:30 AM',
    roleTitle: 'Junior Engineer',
    supervisorName: 'Mina Park',
    supervisorRole: 'Lead Design Engineer',
    hireTagline: 'Design, test, redesign. Failure is data.',
    supervisorBrief:
        '“Bridge must carry 10,000 kg. Pick materials, dimensions, structure, and stay near budget.\n\n'
        'Test will find weak spots. Then redesign under tighter constraints.”',
    enterCta: 'ENTER FORGEWORKS',
    startCta: 'OPEN DESIGN BAY',
    startLocationId: 'cad',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Studio Lobby',
        icon: '🏭',
        blurb: 'Prototype frames and weld smell.',
        atmosphere: 'Forgeworks. Spec boards list live loads in red.',
      ),
      PlayableRoom(
        id: 'cad',
        name: 'CAD Bay',
        icon: '🖥️',
        blurb: 'Parametric models.',
        atmosphere: 'Bridge span template waits. Spec: 10,000 kg live load.',
      ),
      PlayableRoom(
        id: 'test',
        name: 'Load Test Rig',
        icon: '🧱',
        blurb: 'Hydraulic presses.',
        atmosphere: 'First designs often fail at the support beam.',
      ),
      PlayableRoom(
        id: 'review',
        name: 'Constraint Review',
        icon: '📐',
        blurb: 'Budget + safety gates.',
        atmosphere: 'Mina cuts cost without cutting safety factors.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'cad',
        bannerTitle: 'BRIDGE DESIGN',
        bannerBody: 'Material, dimensions, structure, cost → TEST. May fail at support beam.',
        cta: 'Design the bridge',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'review',
        bannerTitle: 'CONSTRAINED REDESIGN',
        bannerBody: 'Rebuild under budget and safety constraints.',
        cta: 'Redesign under constraints',
        unlockKey: 'lab2',
        requiresKey: 'lab1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return PlayableWorkplaceScreen(
      career: augmentCareerWithVisualLabs(career),
      onOpenStage: (BuildContext ctx, PlayableStage stage) async {
        final bool? visual = await tryRunVisualStage(ctx, stage);
        if (visual != null) return visual;
        if (!ctx.mounted) return false;
        if (stage.id == 'lab1') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _EngLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _EngLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _EngLab1Screen extends StatefulWidget {
  const _EngLab1Screen();

  @override
  State<_EngLab1Screen> createState() => _EngLab1ScreenState();
}

class _EngLab1ScreenState extends State<_EngLab1Screen> {
  String? _material;
  double _beam = 0.4;
  String? _structure;
  bool _tested = false;
  bool _failed = false;
  bool _reinforced = false;
  String? _feedback;

  int get _cost {
    int c = 40;
    if (_material == 'steel') c += 25;
    if (_material == 'composite') c += 40;
    if (_material == 'timber') c += 10;
    c += (_beam * 40).round();
    if (_structure == 'truss') c += 15;
    if (_structure == 'arch') c += 20;
    if (_reinforced) c += 18;
    return c;
  }

  bool get _passes {
    if (_material == null || _structure == null) return false;
    if (_material == 'timber' && _beam < 0.7) return false;
    if (!_reinforced && _structure == 'beam') return false;
    return _beam >= 0.45 && (_material == 'steel' || _material == 'composite' || _beam >= 0.7);
  }

  void _test() {
    if (_material == null || _structure == null) {
      setState(() => _feedback = 'Set material and structure first.');
      return;
    }
    setState(() {
      _tested = true;
      _failed = !_passes;
      _feedback = _failed
          ? 'TEST FAIL · support beam buckled under 10,000 kg. Reinforce and retest.'
          : 'TEST PASS · bridge holds 10,000 kg.';
    });
  }

  void _submit() {
    if (!_tested || _failed) {
      setState(() => _feedback = 'You need a passing load test.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: EngineeringPlayableScreen.surface,
          title: const Text(
            'Mina Park — Prototype accepted',
            style: TextStyle(color: EngineeringPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '“Load test green. Cost \$$_cost k. Next: redesign under budget and safety locks.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: EngineeringPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: EngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Bridge · 10,000 kg', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text('Est. cost: \$$_cost k', style: const TextStyle(color: EngineeringPlayableScreen.accent, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('MATERIAL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('timber', 'Timber'),
            ('steel', 'Steel'),
            ('composite', 'Composite'),
          ].map(((String, String) o) {
            final bool on = _material == o.$1;
            return ListTile(
              tileColor: EngineeringPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: EngineeringPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() {
                _material = o.$1;
                _tested = false;
              }),
            );
          }),
          const Text('Beam depth', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _beam,
            onChanged: (double v) => setState(() {
              _beam = v;
              _tested = false;
            }),
            activeColor: EngineeringPlayableScreen.accent,
          ),
          const Text('STRUCTURE', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('beam', 'Simple beam'),
            ('truss', 'Truss'),
            ('arch', 'Arch'),
          ].map(((String, String) o) {
            final bool on = _structure == o.$1;
            return ListTile(
              tileColor: EngineeringPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: EngineeringPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() {
                _structure = o.$1;
                _tested = false;
              }),
            );
          }),
          SwitchListTile(
            value: _reinforced,
            activeThumbColor: EngineeringPlayableScreen.accent,
            title: const Text('Reinforce support beam', style: TextStyle(color: Colors.white)),
            onChanged: (bool v) => setState(() {
              _reinforced = v;
              _tested = false;
            }),
          ),
          OutlinedButton(
            onPressed: _test,
            style: OutlinedButton.styleFrom(foregroundColor: EngineeringPlayableScreen.accent),
            child: const Text('RUN LOAD TEST', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _feedback!,
              style: TextStyle(
                color: _failed ? const Color(0xFFF87171) : const Color(0xFF34D399),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: EngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SUBMIT DESIGN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _EngLab2Screen extends StatefulWidget {
  const _EngLab2Screen();

  @override
  State<_EngLab2Screen> createState() => _EngLab2ScreenState();
}

class _EngLab2ScreenState extends State<_EngLab2Screen> {
  double _safety = 0.5;
  double _costCut = 0.3;
  bool _keepReinforce = true;
  String? _feedback;

  int get _budgetLeft => (100 - _costCut * 55 - (_keepReinforce ? 18 : 0) - _safety * 20).round();
  int get _safetyScore => ((_safety * 70) + (_keepReinforce ? 25 : 0) - (_costCut > 0.7 ? 20 : 0)).round().clamp(0, 100);

  void _submit() {
    if (_budgetLeft < 20) {
      setState(() => _feedback = 'Mina: “Over budget. Cut without gutting safety.”');
      return;
    }
    if (_safetyScore < 55) {
      setState(() => _feedback = 'Safety factor too low for public span.');
      return;
    }
    if (!_keepReinforce) {
      setState(() => _feedback = 'Support reinforcement is non-negotiable after Lab 1 failure mode.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: EngineeringPlayableScreen.surface,
          title: const Text(
            'Mina Park — Redesign locked',
            style: TextStyle(color: EngineeringPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Budget and safety both clear. Ship the drawing pack.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: EngineeringPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: EngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Constrained redesign', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text('Budget remaining: \$$_budgetLeft k', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Text('Safety score: $_safetyScore', style: const TextStyle(color: EngineeringPlayableScreen.accent, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const Text('Safety factor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _safety,
            onChanged: (double v) => setState(() => _safety = v),
            activeColor: EngineeringPlayableScreen.accent,
          ),
          const Text('Cost reduction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _costCut,
            onChanged: (double v) => setState(() => _costCut = v),
            activeColor: EngineeringPlayableScreen.accent,
          ),
          SwitchListTile(
            value: _keepReinforce,
            activeThumbColor: EngineeringPlayableScreen.accent,
            title: const Text('Keep support beam reinforcement', style: TextStyle(color: Colors.white)),
            onChanged: (bool v) => setState(() => _keepReinforce = v),
          ),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: EngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('LOCK REDESIGN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
