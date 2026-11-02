import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Heating / calorimetry mini-station for the Heating home tile.
class ChemistryHeatingLab extends StatefulWidget {
  const ChemistryHeatingLab({super.key});

  @override
  State<ChemistryHeatingLab> createState() => _ChemistryHeatingLabState();
}

class _ChemistryHeatingLabState extends State<ChemistryHeatingLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  bool _flame = false;
  double _temp = 22;
  bool _stirred = false;
  final TextEditingController _explain = TextEditingController();
  String? _feedback;

  void _heat() {
    if (!_flame) {
      setState(() => _feedback = 'Light the burner first.');
      return;
    }
    setState(() {
      _temp = (_temp + 8).clamp(22, 95);
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    if (_temp < 45 || !_stirred) {
      setState(() => _feedback = 'Heat past 45 °C and stir the sample.');
      return;
    }
    final String e = _explain.text.toLowerCase();
    if (!(e.contains('heat') || e.contains('energy') || e.contains('temp'))) {
      setState(() => _feedback = 'Explain using heat / energy / temperature.');
      return;
    }
    await _store.addNote(
      'Heating: final T=${_temp.toStringAsFixed(0)} °C — ${_explain.text.trim()}',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Heating logged',
      body: 'Temperature rise recorded. Energy transfer explained.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScienceLabShell(
      theme: t,
      title: 'Heating Station',
      brief: 'Light burner, heat sample, stir, explain the temperature rise.',
      badgeLabel: 'HEATING',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'LOG HEATING',
        onPressed: _submit,
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
                  '${_temp.toStringAsFixed(0)} °C',
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _flame ? 'Burner ON' : 'Burner OFF',
                  style: TextStyle(
                    color: _flame ? const Color(0xFFFBBF24) : Colors.white54,
                    fontWeight: FontWeight.w800,
                  ),
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
                onPressed: () => setState(() => _flame = !_flame),
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: Text(_flame ? 'EXTINGUISH' : 'LIGHT BURNER'),
              ),
              OutlinedButton(
                onPressed: _heat,
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: const Text('APPLY HEAT'),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _stirred = true),
                style: OutlinedButton.styleFrom(foregroundColor: t.accent),
                child: Text(_stirred ? 'STIRRED ✓' : 'STIR'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _explain,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Why did temperature change?',
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
