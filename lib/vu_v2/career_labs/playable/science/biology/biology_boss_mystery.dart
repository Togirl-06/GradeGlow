import 'package:flutter/material.dart';

import '../shared/science_badges.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import 'biology_station_chrome.dart';

/// Boss: Mystery specimen — run tests, eliminate options, identify + explain.
class BiologyBossMystery extends StatefulWidget {
  const BiologyBossMystery({super.key});

  @override
  State<BiologyBossMystery> createState() => _BiologyBossMysteryState();
}

class _BiologyBossMysteryState extends State<BiologyBossMystery> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _nb = ScienceNotebookStore('biology');

  static const String _answerId = 'plant_epidermis';
  static const List<_Suspect> _suspects = <_Suspect>[
    _Suspect('plant_epidermis', 'Onion epidermis (plant tissue)'),
    _Suspect('animal_muscle', 'Skeletal muscle fiber'),
    _Suspect('bacterial_colony', 'Bacterial smear'),
    _Suspect('fungal_hyphae', 'Fungal hyphae'),
    _Suspect('blood_smear', 'Human blood smear'),
  ];

  final Set<String> _testsRun = <String>{};
  final Set<String> _eliminated = <String>{};
  String? _chosen;
  final TextEditingController _explain = TextEditingController();
  String? _feedback;
  final List<String> _clues = <String>[];

  static const Map<String, String> _testClues = <String, String>{
    'microscope':
        'Microscope: rectangular cells with rigid walls; large central vacuoles; green plastids absent in this prep.',
    'stain':
        'Iodine stain: nuclei darken; starch grains react — consistent with plant storage tissue.',
    'genetic':
        'Genetic marker panel: cellulose synthase orthologs present; no myosin heavy-chain animal signature.',
    'reference':
        'Reference atlas: matches Allium epidermis wet-mount plates — brick-like cells in a single layer.',
  };

  void _runTest(String id) {
    if (_testsRun.contains(id)) return;
    setState(() {
      _testsRun.add(id);
      _clues.add(_testClues[id]!);
      // Progressive elimination
      if (id == 'microscope') {
        _eliminated.addAll(<String>['bacterial_colony', 'blood_smear']);
      } else if (id == 'stain') {
        _eliminated.add('fungal_hyphae');
      } else if (id == 'genetic') {
        _eliminated.add('animal_muscle');
      }
      _feedback = null;
    });
  }

  Future<void> _identify() async {
    if (_testsRun.length < 2) {
      setState(() => _feedback = 'Run at least two tests before identifying.');
      return;
    }
    if (_chosen == null) {
      setState(() => _feedback = 'Select a specimen identity.');
      return;
    }
    if (_explain.text.trim().length < 40) {
      setState(() {
        _feedback =
            'Write a scientific explanation citing your clues (≥ 40 characters).';
      });
      return;
    }
    if (_chosen != _answerId) {
      setState(() {
        _feedback =
            'Identification incorrect. Re-read your clues and eliminate remaining options.';
      });
      return;
    }
    final String lower = _explain.text.toLowerCase();
    final bool cites = lower.contains('cell wall') ||
        lower.contains('plant') ||
        lower.contains('epidermis') ||
        lower.contains('iodine') ||
        lower.contains('cellulose');
    if (!cites) {
      setState(() {
        _feedback =
            'Explain using evidence (cell wall, plant/epidermis, stain, or cellulose).';
      });
      return;
    }
    await _nb.addNote(
      'Boss mystery ID: ${_suspects.firstWhere((_Suspect s) => s.id == _chosen).label}. '
      '${_explain.text.trim()}',
    );
    await _nb.addConclusion(_explain.text.trim());
    await _nb.awardXp(80, coins: 25);
    await _nb.unlockBadge(ScienceBadges.molecularDetective);
    await _nb.markComplete('boss_mystery');
    if (!mounted) return;
    await showBioResult(
      context: context,
      passed: true,
      title: 'Mystery solved',
      body:
          'Onion epidermis confirmed. Badge: ${ScienceBadges.labelOf(ScienceBadges.molecularDetective)}.',
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
    return BiologyStationScaffold(
      title: 'Boss · Mystery Specimen',
      brief: 'Test → eliminate → identify → explain.',
      badgeLabel: 'BOSS',
      footer: bioPrimaryButton(label: 'IDENTIFY SPECIMEN', onPressed: _identify),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          bioPanel(
            child: Text(
              'Unknown slide under sealed cover. Choose tests to reveal clues. '
              'Eliminate impossibilities, then identify with a scientific explanation.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('TESTS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <(String, String)>[
              ('microscope', '🔬 Microscope'),
              ('stain', '🧪 Stain'),
              ('genetic', '🧬 Genetic marker'),
              ('reference', '📘 Reference'),
            ].map(((String, String) e) {
              final bool done = _testsRun.contains(e.$1);
              return ActionChip(
                label: Text(e.$2),
                backgroundColor: done ? t.accent.withValues(alpha: 0.25) : t.surface,
                labelStyle: TextStyle(
                  color: done ? t.accent : Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
                onPressed: done ? null : () => _runTest(e.$1),
              );
            }).toList(),
          ),
          if (_clues.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            const Text('CLUES', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
            ..._clues.map(
              (String c) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: bioPanel(
                  child: Text(c, style: const TextStyle(color: Colors.white, height: 1.4)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text('SUSPECTS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ..._suspects.map((_Suspect s) {
            final bool out = _eliminated.contains(s.id);
            final bool sel = _chosen == s.id;
            return Opacity(
              opacity: out ? 0.4 : 1,
              child: ListTile(
                onTap: out
                    ? null
                    : () => setState(() => _chosen = s.id),
                tileColor: sel ? t.accent.withValues(alpha: 0.12) : t.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: sel ? t.accent : t.accent.withValues(alpha: 0.2),
                  ),
                ),
                title: Text(
                  s.label,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: out ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: out
                    ? const Icon(Icons.block, color: Colors.white38)
                    : Icon(
                        sel ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: t.accent,
                      ),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: _explain,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Scientific explanation',
              labelStyle: TextStyle(color: t.accent),
              hintText: 'Cite cell wall, stain, markers…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: t.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }
}

class _Suspect {
  const _Suspect(this.id, this.label);
  final String id;
  final String label;
}
