import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Pick reactants → combine → observe color/temp/gas/precipitate → CER.
class ChemistryReactionLab extends StatefulWidget {
  const ChemistryReactionLab({super.key});

  @override
  State<ChemistryReactionLab> createState() => _ChemistryReactionLabState();
}

class _ChemistryReactionLabState extends State<ChemistryReactionLab> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  final Set<String> _picked = <String>{};
  bool _combined = false;
  final TextEditingController _obs = TextEditingController();
  final TextEditingController _evi = TextEditingController();
  final TextEditingController _con = TextEditingController();
  String? _feedback;

  static const Map<String, String> _bank = <String, String>{
    'hcl': 'HCl (aq)',
    'naoh': 'NaOH (aq)',
    'mg': 'Mg ribbon',
    'agno3': 'AgNO₃ (aq)',
    'nacl': 'NaCl (aq)',
    'cu': 'CuSO₄ (aq)',
  };

  _Outcome get _outcome {
    if (_picked.contains('hcl') && _picked.contains('naoh')) {
      return const _Outcome('Warm clear solution', '+ΔT', false, false, Color(0xFF67E8F9));
    }
    if (_picked.contains('hcl') && _picked.contains('mg')) {
      return const _Outcome('Bubbling, metal shrinks', 'cool mist', true, false, Color(0xFFA5F3FC));
    }
    if (_picked.contains('agno3') && _picked.contains('nacl')) {
      return const _Outcome('White solid forms', 'ambient', false, true, Color(0xFFF5F5F4));
    }
    if (_picked.contains('cu') && _picked.contains('mg')) {
      return const _Outcome('Blue fades, brown deposit', 'slight warm', false, true, Color(0xFF60A5FA));
    }
    return const _Outcome('No clear reaction', '—', false, false, Color(0xFF6B7280));
  }

  void _combine() {
    if (_picked.length < 2) {
      setState(() => _feedback = 'Select at least two reactants.');
      return;
    }
    setState(() {
      _combined = true;
      _feedback = null;
    });
  }

  Future<void> _submit() async {
    if (!_combined) {
      setState(() => _feedback = 'Combine reactants and observe first.');
      return;
    }
    final String o = _obs.text.toLowerCase();
    final String e = _evi.text.toLowerCase();
    final String c = _con.text.toLowerCase();
    if (o.length < 8 || e.length < 8 || c.length < 8) {
      setState(() => _feedback = 'Fill observation, evidence, and conclusion.');
      return;
    }
    final _Outcome out = _outcome;
    final bool mentions = (out.gas && (o.contains('gas') || o.contains('bubbl'))) ||
        (out.precipitate && (o.contains('precip') || o.contains('solid') || o.contains('cloud'))) ||
        (o.contains('warm') || o.contains('color') || o.contains('clear') || o.contains('blue'));
    if (!mentions && o.length < 20) {
      setState(() => _feedback = 'Tie your observation to what you saw (color, gas, heat, solid).');
      return;
    }
    await _store.addNote(
      'Reaction ${_picked.join('+')}: ${out.colorDesc}; CER logged',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'Observation accepted',
      body: 'Evidence-backed conclusion filed. Ross stamps the hood sheet.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _obs.dispose();
    _evi.dispose();
    _con.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Outcome out = _outcome;
    return ScienceLabShell(
      theme: t,
      title: 'Reaction Hood',
      brief: 'Pick reactants, combine, watch signs of change, then write CER.',
      badgeLabel: 'REACTIONS',
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'SUBMIT CER',
        onPressed: _submit,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bank.entries.map((MapEntry<String, String> e) {
              final bool on = _picked.contains(e.key);
              return FilterChip(
                selected: on,
                label: Text(e.value),
                selectedColor: t.accent.withValues(alpha: 0.35),
                checkmarkColor: t.accent,
                labelStyle: const TextStyle(color: Colors.white),
                backgroundColor: t.surface,
                onSelected: (bool v) => setState(() {
                  _combined = false;
                  if (v) {
                    _picked.add(e.key);
                  } else {
                    _picked.remove(e.key);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _combine,
            style: OutlinedButton.styleFrom(foregroundColor: t.accent),
            child: const Text('COMBINE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_combined) ...<Widget>[
            const SizedBox(height: 12),
            sciencePanel(
              surface: t.surface,
              accent: t.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: out.swatch,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(out.colorDesc,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Temp: ${out.temp}', style: const TextStyle(color: Colors.white70)),
                  Text('Gas: ${out.gas ? 'yes' : 'no'} · Precipitate: ${out.precipitate ? 'yes' : 'no'}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _field(_obs, 'Observation'),
            const SizedBox(height: 8),
            _field(_evi, 'Evidence'),
            const SizedBox(height: 8),
            _field(_con, 'Conclusion'),
          ],
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      maxLines: 2,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: t.accent),
        filled: true,
        fillColor: t.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _Outcome {
  const _Outcome(this.colorDesc, this.temp, this.gas, this.precipitate, this.swatch);
  final String colorDesc;
  final String temp;
  final bool gas;
  final bool precipitate;
  final Color swatch;
}
