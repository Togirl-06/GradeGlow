import 'package:flutter/material.dart';

import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import 'biology_station_chrome.dart';

/// DNA complementary strand + Punnett square phenotype percent.
class BiologyGeneticsLab extends StatefulWidget {
  const BiologyGeneticsLab({super.key});

  @override
  State<BiologyGeneticsLab> createState() => _BiologyGeneticsLabState();
}

class _BiologyGeneticsLabState extends State<BiologyGeneticsLab> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _nb = ScienceNotebookStore('biology');

  static const String _template = 'ATGCGCTA';
  final List<String?> _comp = List<String?>.filled(8, null);
  final List<String> _bank = <String>['A', 'T', 'C', 'G', 'A', 'T', 'C', 'G'];

  String? _topLeft;
  String? _topRight;
  String? _sideTop;
  String? _sideBot;
  final TextEditingController _pct = TextEditingController();
  int _phase = 0; // 0 DNA, 1 Punnett
  String? _feedback;

  static String _pair(String b) {
    switch (b) {
      case 'A':
        return 'T';
      case 'T':
        return 'A';
      case 'C':
        return 'G';
      case 'G':
        return 'C';
      default:
        return '?';
    }
  }

  bool get _dnaDone {
    for (int i = 0; i < _template.length; i++) {
      if (_comp[i] != _pair(_template[i])) return false;
    }
    return true;
  }

  List<String> get _square {
    final String a = _topLeft ?? '';
    final String b = _topRight ?? '';
    final String c = _sideTop ?? '';
    final String d = _sideBot ?? '';
    if (a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) {
      return const <String>['', '', '', ''];
    }
    return <String>['$c$a', '$c$b', '$d$a', '$d$b'];
  }

  int get _dominantPct {
    // Dominant phenotype if any allele is uppercase B
    final List<String> cells = _square;
    if (cells.any((String s) => s.isEmpty)) return -1;
    int dom = 0;
    for (final String g in cells) {
      if (g.contains('B')) dom++;
    }
    return (dom * 25);
  }

  Future<void> _advanceDna() async {
    if (!_dnaDone) {
      setState(() => _feedback = 'Complete the complementary strand (A–T, C–G).');
      return;
    }
    await _nb.addNote('DNA strand built: $_template / ${_comp.join()}');
    await _nb.awardXp(20, coins: 5);
    setState(() {
      _phase = 1;
      _feedback = null;
      // Default Bb × Bb
      _topLeft = 'B';
      _topRight = 'b';
      _sideTop = 'B';
      _sideBot = 'b';
    });
  }

  Future<void> _submitPunnett() async {
    if (_dominantPct < 0) {
      setState(() => _feedback = 'Place B/b alleles on top and side.');
      return;
    }
    final int? ans = int.tryParse(_pct.text.trim().replaceAll('%', ''));
    if (ans == null) {
      setState(() => _feedback = 'Enter the % dominant phenotype as a number.');
      return;
    }
    if (ans != _dominantPct) {
      setState(() {
        _feedback =
            'Not quite. Count genotypes with at least one B. Expected $_dominantPct%.';
      });
      return;
    }
    await _nb.addNote(
      'Punnett Bb×Bb → dominant phenotype $_dominantPct%',
    );
    await _nb.awardXp(35, coins: 10);
    await _nb.markComplete('genetics');
    if (!mounted) return;
    await showBioResult(
      context: context,
      passed: true,
      title: 'Genetics cleared',
      body: 'Complementary strand correct and Punnett phenotype $ans% logged.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _pct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BiologyStationScaffold(
      title: 'Genetics Bench',
      brief: _phase == 0
          ? 'Build the complementary DNA strand.'
          : 'Complete the Punnett square and report % dominant.',
      badgeLabel: 'DNA',
      footer: bioPrimaryButton(
        label: _phase == 0 ? 'CONFIRM STRAND' : 'SUBMIT % DOMINANT',
        onPressed: _phase == 0 ? _advanceDna : _submitPunnett,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          if (_phase == 0) ..._dnaUi() else ..._punnettUi(),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  List<Widget> _dnaUi() {
    return <Widget>[
      bioPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Template 5′→3′', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _template.split('').map((String b) {
                return _BaseChip(base: b, accent: t.accent, filled: true);
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Complement 3′→5′ (drag bases)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List<Widget>.generate(_comp.length, (int i) {
                return DragTarget<String>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (DragTargetDetails<String> d) {
                    setState(() => _comp[i] = d.data);
                  },
                  builder: (BuildContext context, List<String?> cand, _) {
                    return _BaseChip(
                      base: _comp[i] ?? '·',
                      accent: cand.isNotEmpty ? t.accent : t.accent.withValues(alpha: 0.5),
                      filled: _comp[i] != null,
                    );
                  },
                );
              }),
            ),
            if (_dnaDone) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Resulting strand: ${_comp.join()}',
                style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _bank.map((String b) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Draggable<String>(
                data: b,
                feedback: Material(
                  color: Colors.transparent,
                  child: _BaseChip(base: b, accent: t.accent, filled: true, big: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _BaseChip(base: b, accent: t.accent, filled: true),
                ),
                child: _BaseChip(base: b, accent: t.accent, filled: true),
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  List<Widget> _punnettUi() {
    final List<String> cells = _square;
    return <Widget>[
      bioPanel(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 48),
                Expanded(child: _alleleDrop('Top B/b', _topLeft, (String v) => setState(() => _topLeft = v))),
                Expanded(child: _alleleDrop('Top B/b', _topRight, (String v) => setState(() => _topRight = v))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  child: _alleleDrop('Side', _sideTop, (String v) => setState(() => _sideTop = v)),
                ),
                Expanded(child: _cellBox(cells[0])),
                Expanded(child: _cellBox(cells[1])),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  child: _alleleDrop('Side', _sideBot, (String v) => setState(() => _sideBot = v)),
                ),
                Expanded(child: _cellBox(cells[2])),
                Expanded(child: _cellBox(cells[3])),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: <String>['B', 'b'].map((String a) {
          return Draggable<String>(
            data: a,
            feedback: Material(
              color: Colors.transparent,
              child: _BaseChip(base: a, accent: t.accent, filled: true, big: true),
            ),
            child: _BaseChip(base: a, accent: t.accent, filled: true),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _pct,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: '% dominant phenotype',
          labelStyle: TextStyle(color: t.accent),
          filled: true,
          fillColor: t.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ];
  }

  Widget _alleleDrop(String hint, String? value, ValueChanged<String> onDrop) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (DragTargetDetails<String> d) =>
          d.data == 'B' || d.data == 'b',
      onAcceptWithDetails: (DragTargetDetails<String> d) => onDrop(d.data),
      builder: (BuildContext context, List<String?> cand, _) {
        return Container(
          margin: const EdgeInsets.all(4),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cand.isNotEmpty ? t.accent : t.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            value ?? hint,
            style: TextStyle(
              color: value == null ? Colors.white38 : t.accent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _cellBox(String g) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        g.isEmpty ? '—' : g,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }
}

class _BaseChip extends StatelessWidget {
  const _BaseChip({
    required this.base,
    required this.accent,
    required this.filled,
    this.big = false,
  });

  final String base;
  final Color accent;
  final bool filled;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: big ? 48 : 40,
      height: big ? 48 : 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? accent.withValues(alpha: 0.2) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Text(
        base,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w900,
          fontSize: big ? 18 : 15,
        ),
      ),
    );
  }
}
