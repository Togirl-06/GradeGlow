import 'package:flutter/material.dart';

import '../shared/science_badges.dart';
import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Limited tests → eliminate → identify unknown + reasoning. Badge molecular_detective.
class ChemistryBossUnknown extends StatefulWidget {
  const ChemistryBossUnknown({super.key});

  @override
  State<ChemistryBossUnknown> createState() => _ChemistryBossUnknownState();
}

class _ChemistryBossUnknownState extends State<ChemistryBossUnknown> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  static const List<String> _suspects = <String>[
    'NaCl',
    'NaHCO₃',
    'CaCO₃',
    'NH₄Cl',
    'Glucose',
  ];

  // True unknown is NaHCO₃
  static const String _unknown = 'NaHCO₃';

  int _testsLeft = 3;
  final Set<String> _eliminated = <String>{};
  final Set<String> _ran = <String>{};
  String? _idChoice;
  final TextEditingController _reason = TextEditingController();
  String? _feedback;
  String? _lastResult;

  void _runTest(String id, String label, Set<String> eliminates, String result) {
    if (_testsLeft <= 0) {
      setState(() => _feedback = 'No tests left — identify from what you know.');
      return;
    }
    if (_ran.contains(id)) {
      setState(() => _feedback = 'Already ran that test.');
      return;
    }
    setState(() {
      _ran.add(id);
      _testsLeft--;
      _eliminated.addAll(eliminates);
      _lastResult = '$label → $result';
      _feedback = null;
    });
  }

  Future<void> _identify() async {
    if (_idChoice == null) {
      setState(() => _feedback = 'Choose an identity.');
      return;
    }
    if (_reason.text.trim().length < 20) {
      setState(() => _feedback = 'Write reasoning (≥20 chars) citing your tests.');
      return;
    }
    final bool ok = _idChoice == _unknown;
    if (!ok) {
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Wrong identity',
        body: 'Eliminate carefully. Re-check which solids survive your tests.',
      );
      return;
    }
    await _store.unlockBadge(ScienceBadges.molecularDetective);
    await _store.addNote(
      'BOSS: Identified $_unknown — ${_reason.text.trim()} [badge: molecular_detective]',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Unknown identified',
      body: 'NaHCO₃ confirmed. Badge unlocked: molecular_detective.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Boss · Unknown',
      brief: 'Limited tests. Eliminate possibilities. Identify + reason.',
      badgeLabel: 'BOSS',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'IDENTIFY UNKNOWN',
        onPressed: _identify,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          sciencePanel(
            surface: t.surface,
            accent: t.accent,
            child: Text(
              'Tests remaining: $_testsLeft\n${_lastResult ?? 'White powder unknown. Choose wisely.'}',
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Available tests',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900)),
          _testTile(
            'flame',
            'Flame test',
            'Yellow / no vivid metal color',
            <String>{}, // doesn't eliminate much uniquely
          ),
          _testTile(
            'acid',
            'Add dilute acid',
            'Fizzes — CO₂ evolved',
            <String>{'NaCl', 'NH₄Cl', 'Glucose'}, // carbonates/bicarb remain
          ),
          _testTile(
            'heat',
            'Gentle heat',
            'Soft crackle, releases CO₂/H₂O feel',
            <String>{'NaCl', 'CaCO₃', 'Glucose'}, // favors bicarb over CaCO3 slightly - eliminate CaCO3+others
          ),
          _testTile(
            'ag',
            'AgNO₃ drop',
            'No heavy white AgCl crash',
            <String>{'NaCl', 'NH₄Cl'},
          ),
          const SizedBox(height: 12),
          const Text('Suspects',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900)),
          ..._suspects.map((String s) {
            final bool out = _eliminated.contains(s);
            return ListTile(
              enabled: !out,
              tileColor: t.surface,
              leading: Icon(
                out
                    ? Icons.cancel
                    : (_idChoice == s ? Icons.radio_button_checked : Icons.radio_button_off),
                color: out ? Colors.white24 : t.accent,
              ),
              title: Text(
                s + (out ? '  (eliminated)' : ''),
                style: TextStyle(
                  color: out ? Colors.white24 : Colors.white,
                  decoration: out ? TextDecoration.lineThrough : null,
                ),
              ),
              onTap: out ? null : () => setState(() => _idChoice = s),
            );
          }),
          const SizedBox(height: 8),
          TextField(
            controller: _reason,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Reasoning',
              labelStyle: TextStyle(color: t.accent),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _testTile(String id, String title, String result, Set<String> elim) {
    return ListTile(
      tileColor: t.surface,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        _ran.contains(id) ? result : 'Cost: 1 test',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
      trailing: Icon(
        _ran.contains(id) ? Icons.check : Icons.science,
        color: t.accent,
      ),
      onTap: () => _runTest(id, title, elim, result),
    );
  }
}
