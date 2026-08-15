import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Harbor University EE Lab — Prof. Hannah Cho.
Widget electricalEngineeringPlayableScreen() =>
    const ElectricalEngineeringPlayableScreen();

class ElectricalEngineeringPlayableScreen extends StatelessWidget {
  const ElectricalEngineeringPlayableScreen({super.key});

  static const Color accent = Color(0xFFFDE047);
  static const Color bg = Color(0xFF0C0C08);
  static const Color surface = Color(0xFF1A1A12);

  static const PlayableCareer career = PlayableCareer(
    id: 'electrical_engineering',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Harbor University · EE Lab',
    clockLine: 'Friday — 2:15 PM',
    roleTitle: 'EE Student',
    supervisorName: 'Prof. Hannah Cho',
    supervisorRole: 'Lab Director',
    hireTagline: 'Build first. Then hunt faults with instruments — not guesses.',
    supervisorBrief:
        '“Assemble the assigned circuit from the parts bin.\n\n'
        'When FAULT DETECTED hits, use instruments, explain why, and fix it.”',
    enterCta: 'ENTER EE LAB',
    startCta: 'OPEN PARTS BIN',
    startLocationId: 'bench',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'bench',
        name: 'Circuit Bench',
        icon: '🔌',
        blurb: 'Breadboards and rails.',
        atmosphere: 'Cho wants a working loop before any instrumentation drama.',
      ),
      PlayableRoom(
        id: 'parts',
        name: 'Parts Bin',
        icon: '📦',
        blurb: 'Resistors, caps, ICs.',
        atmosphere: 'Labeled drawers. Don’t invent values.',
      ),
      PlayableRoom(
        id: 'instruments',
        name: 'Instrument Rack',
        icon: '📟',
        blurb: 'DMM, scope, supply.',
        atmosphere: 'FAULT DETECTED drills live here.',
        lockedUntilStageId: 'lab1',
      ),
      PlayableRoom(
        id: 'cho',
        name: 'Prof. Cho Desk',
        icon: '📝',
        blurb: 'Schematic reviews.',
        atmosphere: 'Explain the fault path in plain language.',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'bench',
        bannerTitle: 'BUILD CIRCUIT',
        bannerBody: 'Place components and close a working loop.',
        cta: 'Build the circuit',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'instruments',
        bannerTitle: 'FAULT DETECTED',
        bannerBody: 'Use instruments to locate the fault, explain why, and fix it.',
        cta: 'Troubleshoot fault',
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
            MaterialPageRoute<bool>(builder: (_) => const _EeLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _EeLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _EeLab1Screen extends StatefulWidget {
  const _EeLab1Screen();

  @override
  State<_EeLab1Screen> createState() => _EeLab1ScreenState();
}

class _EeLab1ScreenState extends State<_EeLab1Screen> {
  final Set<String> _placed = <String>{};
  String? _feedback;

  static const List<(String, String)> _parts = <(String, String)>[
    ('vcc', '5V supply rail'),
    ('r1', '1kΩ resistor'),
    ('led', 'LED'),
    ('gnd', 'Ground return'),
  ];

  void _submit() {
    if (!_placed.containsAll(<String>['vcc', 'r1', 'led', 'gnd'])) {
      setState(() => _feedback = 'Place supply, resistor, LED, and ground.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: ElectricalEngineeringPlayableScreen.surface,
          title: const Text(
            'Prof. Cho — Circuit live',
            style: TextStyle(
              color: ElectricalEngineeringPlayableScreen.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '“LED forward path is correct. Instrument rack unlocked — fault drill next.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: ElectricalEngineeringPlayableScreen.accent,
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
      backgroundColor: ElectricalEngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: ElectricalEngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Build circuit', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Placed ${_placed.length} / ${_parts.length}',
            style: const TextStyle(
              color: ElectricalEngineeringPlayableScreen.accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ..._parts.map(((String, String) o) {
            final bool on = _placed.contains(o.$1);
            return ListTile(
              tileColor: ElectricalEngineeringPlayableScreen.surface,
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              trailing: Icon(
                on ? Icons.check_circle : Icons.add_circle_outline,
                color: ElectricalEngineeringPlayableScreen.accent,
              ),
              onTap: () => setState(() => _placed.add(o.$1)),
            );
          }),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: ElectricalEngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('POWER ON', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _EeLab2Screen extends StatefulWidget {
  const _EeLab2Screen();

  @override
  State<_EeLab2Screen> createState() => _EeLab2ScreenState();
}

class _EeLab2ScreenState extends State<_EeLab2Screen> {
  final Set<String> _instruments = <String>{};
  String? _faultLoc;
  final TextEditingController _why = TextEditingController();
  bool _fixed = false;
  String? _feedback;

  @override
  void dispose() {
    _why.dispose();
    super.dispose();
  }

  void _submit() {
    final String t = _why.text.toLowerCase();
    if (!_instruments.containsAll(<String>['dmm', 'scope'])) {
      setState(() => _feedback = 'Use DMM and scope before you declare a location.');
      return;
    }
    if (_faultLoc != 'r1_open') {
      setState(() => _feedback = 'Cho: “Wrong node. Voltage drops at the resistor.”');
      return;
    }
    if (!(t.contains('open') || t.contains('resistor') || t.contains('break'))) {
      setState(() => _feedback = 'Explain why — open resistor / broken path keywords.');
      return;
    }
    if (!_fixed) {
      setState(() => _feedback = 'Apply the fix (replace R1).');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: ElectricalEngineeringPlayableScreen.surface,
          title: const Text(
            'Prof. Cho — Fault cleared',
            style: TextStyle(
              color: ElectricalEngineeringPlayableScreen.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '“Open resistor found with instruments, explained, replaced. That’s EE.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: ElectricalEngineeringPlayableScreen.accent,
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
      backgroundColor: ElectricalEngineeringPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: ElectricalEngineeringPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('FAULT DETECTED', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ElectricalEngineeringPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.55)),
            ),
            child: const Text(
              'LED dark · supply OK · FAULT DETECTED',
              style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 12),
          const Text('INSTRUMENTS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('dmm', 'DMM — voltage at nodes'),
            ('scope', 'Scope — rail noise check'),
            ('supply', 'Supply current limit'),
          ].map(((String, String) o) {
            final bool on = _instruments.contains(o.$1);
            return ListTile(
              tileColor: ElectricalEngineeringPlayableScreen.surface,
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              trailing: Icon(
                on ? Icons.check : Icons.play_arrow,
                color: ElectricalEngineeringPlayableScreen.accent,
              ),
              onTap: () => setState(() => _instruments.add(o.$1)),
            );
          }),
          const SizedBox(height: 8),
          const Text('FAULT LOCATION', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('led', 'LED reversed'),
            ('r1_open', 'R1 open / broken'),
            ('gnd', 'Ground disconnected at rail'),
          ].map(((String, String) o) {
            final bool on = _faultLoc == o.$1;
            return ListTile(
              tileColor: ElectricalEngineeringPlayableScreen.surface,
              leading: Icon(
                on ? Icons.radio_button_checked : Icons.radio_button_off,
                color: ElectricalEngineeringPlayableScreen.accent,
              ),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _faultLoc = o.$1),
            );
          }),
          TextField(
            controller: _why,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Explain why this is the fault…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: ElectricalEngineeringPlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SwitchListTile(
            value: _fixed,
            activeThumbColor: ElectricalEngineeringPlayableScreen.accent,
            title: const Text('Replace R1 (apply fix)', style: TextStyle(color: Colors.white)),
            onChanged: (bool v) => setState(() => _fixed = v),
          ),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: ElectricalEngineeringPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('CLEAR FAULT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
