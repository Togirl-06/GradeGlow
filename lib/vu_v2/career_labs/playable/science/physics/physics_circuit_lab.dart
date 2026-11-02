import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import '../shared/science_workspace_shell.dart';

/// Drag-connect circuit parts; incomplete warning; light on when correct.
class PhysicsCircuitLab extends StatefulWidget {
  const PhysicsCircuitLab({super.key});

  @override
  State<PhysicsCircuitLab> createState() => _PhysicsCircuitLabState();
}

class _PhysicsCircuitLabState extends State<PhysicsCircuitLab> {
  static const ScienceLabTheme t = ScienceLabTheme.physics;
  final ScienceNotebookStore _store = ScienceNotebookStore('physics');

  final Set<String> _parts = <String>{};
  final Set<String> _links = <String>{}; // "a-b" undirected
  bool _switchOn = false;
  String? _pending;
  String? _feedback;

  static const List<(String, String)> _bank = <(String, String)>[
    ('battery', 'Battery'),
    ('bulb', 'Bulb'),
    ('wire', 'Wire'),
    ('switch', 'Switch'),
    ('resistor', 'Resistor'),
  ];

  bool get _completeParts =>
      _parts.containsAll(<String>['battery', 'bulb', 'wire', 'switch', 'resistor']);

  bool get _wired {
    // Need battery linked into loop with bulb and switch
    bool has(String a, String b) {
      final String k1 = '$a-$b';
      final String k2 = '$b-$a';
      return _links.contains(k1) || _links.contains(k2);
    }

    return has('battery', 'wire') &&
        has('wire', 'switch') &&
        has('switch', 'resistor') &&
        has('resistor', 'bulb') &&
        has('bulb', 'battery');
  }

  bool get _lit => _completeParts && _wired && _switchOn;

  void _togglePart(String id) {
    setState(() {
      if (_parts.contains(id)) {
        _parts.remove(id);
      } else {
        _parts.add(id);
      }
      _feedback = null;
    });
  }

  void _tapNode(String id) {
    if (!_parts.contains(id)) return;
    setState(() {
      if (_pending == null) {
        _pending = id;
      } else if (_pending == id) {
        _pending = null;
      } else {
        _links.add('$_pending-$id');
        _pending = null;
      }
    });
  }

  Future<void> _submit() async {
    if (!_completeParts) {
      setState(() => _feedback = 'Incomplete — place battery, bulb, wire, switch, resistor.');
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Circuit incomplete',
        body: 'Every component must be on the board before the lamp can light.',
      );
      return;
    }
    if (!_wired) {
      setState(() => _feedback = 'Connect components into a closed loop.');
      return;
    }
    if (!_switchOn) {
      setState(() => _feedback = 'Close the switch.');
      return;
    }
    if (!_lit) {
      setState(() => _feedback = 'Bulb still dark — check the loop.');
      return;
    }
    await _store.addNote(
      'Circuit closed · bulb ON',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Lights on',
      body: 'Closed loop with switch closed. Current path verified.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScienceWorkspaceShell(
      theme: t,
      dark: true,
      crumbs: const <String>['Physics Lab', 'Electricity', 'Circuit Builder'],
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'CHECK CIRCUIT',
        onPressed: _submit,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScienceSideCard(
            title: 'COMPONENTS',
            accent: t.accent,
            dark: true,
            child: ListView(
              children: <Widget>[
                ..._bank.map(((String, String) p) {
                  final bool on = _parts.contains(p.$1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilterChip(
                      selected: on,
                      label: Text(p.$2),
                      selectedColor: t.accent.withValues(alpha: 0.4),
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (_) => _togglePart(p.$1),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Tap two placed parts to wire them.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF101828),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Icon(
                      Icons.lightbulb,
                      size: 72,
                      color: _lit ? const Color(0xFFFDE047) : Colors.white24,
                    ),
                    Text(
                      _lit ? 'CIRCUIT COMPLETE' : 'OPEN CIRCUIT',
                      style: TextStyle(
                        color: _lit ? const Color(0xFFFDE047) : Colors.white54,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _parts.map((String id) {
                        return ActionChip(
                          label: Text(id),
                          backgroundColor: _pending == id ? t.accent : t.surface,
                          labelStyle: TextStyle(
                            color: _pending == id ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          onPressed: () => _tapNode(id),
                        );
                      }).toList(),
                    ),
                    SwitchListTile(
                      title: const Text('Switch closed', style: TextStyle(color: Colors.white70)),
                      value: _switchOn,
                      activeThumbColor: t.accent,
                      onChanged: (bool v) => setState(() => _switchOn = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ScienceSideCard(
            title: 'STATUS',
            accent: t.accent,
            dark: true,
            child: ListView(
              children: <Widget>[
                Text(
                  _lit ? 'Current 0.45 A' : 'Current 0.00 A',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text('Voltage 9.00 V', style: TextStyle(color: Colors.white70)),
                const Text('Resistance 20.0 Ω', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text('Wires: ${_links.length}', style: const TextStyle(color: Colors.white54)),
                if (_feedback != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
