import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Virtual balance: place → tare → add substance → read → notebook.
class ChemistryMeasurementLab extends StatefulWidget {
  const ChemistryMeasurementLab({super.key});

  @override
  State<ChemistryMeasurementLab> createState() => _ChemistryMeasurementLabState();
}

class _ChemistryMeasurementLabState extends State<ChemistryMeasurementLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');
  final TextEditingController _entry = TextEditingController();

  bool _container = false;
  bool _tared = false;
  double _substanceG = 0;
  static const double _target = 2.50;
  String? _feedback;

  double get _display {
    if (!_container) return 0;
    if (!_tared) return 12.84; // boat mass
    return _substanceG;
  }

  void _place() => setState(() {
        _container = true;
        _feedback = null;
      });

  void _tare() {
    if (!_container) {
      setState(() => _feedback = 'Place the weighing boat first.');
      return;
    }
    setState(() {
      _tared = true;
      _feedback = 'Tared. Add NaCl.';
    });
  }

  void _add() {
    if (!_tared) {
      setState(() => _feedback = 'Tare before adding substance.');
      return;
    }
    setState(() {
      _substanceG = (_substanceG + 0.25).clamp(0, 5);
      _feedback = null;
    });
  }

  Future<void> _log() async {
    final double? v = double.tryParse(_entry.text.trim());
    if (!_tared || _substanceG < 0.5) {
      setState(() => _feedback = 'Place, tare, and add substance first.');
      return;
    }
    if (v == null) {
      setState(() => _feedback = 'Enter the mass reading.');
      return;
    }
    final bool ok = (v - _display).abs() <= 0.05 && (_display - _target).abs() <= 0.3;
    if (!ok) {
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Check reading',
        body:
            'Aim near ${_target.toStringAsFixed(2)} g and enter what the balance shows (±0.05).',
      );
      return;
    }
    await _store.addNote(
      'Balance: ${_display.toStringAsFixed(2)} g NaCl (tared boat)',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Mass logged',
      body: 'Notebook updated with ${_display.toStringAsFixed(2)} g. Good technique.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Analytical Balance',
      brief: 'Place container → tare → add substance → read → enter notebook.',
      badgeLabel: 'BALANCE',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'ENTER NOTEBOOK',
        onPressed: _log,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          sciencePanel(
            surface: t.surface,
            accent: t.accent,
            child: Column(
              children: <Widget>[
                Text(
                  _display.toStringAsFixed(2),
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
                const Text('g', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                Text(
                  !_container
                      ? 'Pan empty'
                      : (!_tared ? 'Boat on pan — tare me' : 'Net mass of substance'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: _place,
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: const Text('PLACE CONTAINER'),
              ),
              OutlinedButton(
                onPressed: _tare,
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: const Text('TARE'),
              ),
              OutlinedButton(
                onPressed: _add,
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: const Text('ADD NaCl (+0.25 g)'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Target ≈ ${_target.toStringAsFixed(2)} g',
            style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _entry,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Enter reading (g)',
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
}
