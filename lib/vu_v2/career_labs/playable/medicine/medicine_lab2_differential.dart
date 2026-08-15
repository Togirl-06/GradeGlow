import 'package:flutter/material.dart';

/// Differential board + resource-limited test ordering.
class MedicineLab2DifferentialScreen extends StatefulWidget {
  const MedicineLab2DifferentialScreen({super.key});

  @override
  State<MedicineLab2DifferentialScreen> createState() =>
      _MedicineLab2DifferentialScreenState();
}

class _MedicineLab2DifferentialScreenState
    extends State<MedicineLab2DifferentialScreen> {
  static const Color _accent = Color(0xFF60A5FA);
  static const Color _bg = Color(0xFF060B14);
  static const Color _surface = Color(0xFF0F1A2C);
  static const String _correctTop = 'hf';
  static const int _timeBudget = 10;

  final List<_Diff> _ranked = List<_Diff>.from(_diffs);
  String? _mostLikely;
  final TextEditingController _explain = TextEditingController();
  final Set<String> _ordered = <String>{};
  int _timeLeft = _timeBudget;
  final Map<String, String> _results = <String, String>{};
  bool _submitted = false;

  @override
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final _Diff item = _ranked.removeAt(oldIndex);
      _ranked.insert(newIndex, item);
    });
  }

  void _orderTest(_Test t) {
    if (_ordered.contains(t.id)) return;
    if (_timeLeft < t.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough time points for ${t.name} (costs ${t.cost}).'),
        ),
      );
      return;
    }
    setState(() {
      _ordered.add(t.id);
      _timeLeft -= t.cost;
      _results[t.id] = t.result;
    });
  }

  Future<void> _submit() async {
    if (_mostLikely == null || _explain.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick most likely and write a short clinical explanation.'),
        ),
      );
      return;
    }
    final bool topOk = _ranked.isNotEmpty && _ranked.first.id == _correctTop;
    final bool pickOk = _mostLikely == _correctTop;
    final bool hasBnpOrCx = _ordered.contains('bnp') || _ordered.contains('cxr');
    final String review = pickOk
        ? (hasBnpOrCx
            ? 'Shah: “Heart failure exacerbation fits — orthopnea, edema, NSAID + missed diuretic. '
                'You ordered high-yield tests. That’s diagnostic judgment.”'
            : 'Shah: “Right top diagnosis, but next time prioritize BNP or CXR before exotic panels.”')
        : 'Shah: “Most likely here is decompensated HF, not ${_label(_mostLikely!)}. '
            'Re-read orthopnea + edema + meds. You can still learn from the board.”';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Attending review',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '$review\n\n'
            'Rank #1 was ${_ranked.first.label}${topOk ? " ✓" : ""}\n'
            'Time remaining: $_timeLeft / $_timeBudget',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Complete consult', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
    _submitted = true;
  }

  String _label(String id) {
    for (final _Diff d in _diffs) {
      if (d.id == id) return d.label;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'WORKROOM',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Differential & orders',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Time: $_timeLeft',
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  Text(
                    'Tap ▲▼ to rank (most likely at top)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List<Widget>.generate(_ranked.length, (int i) {
                    final _Diff d = _ranked[i];
                    return Container(
                      key: ValueKey<String>(d.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _mostLikely == d.id
                              ? _accent
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '#${i + 1}',
                            style: const TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  d.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  d.hint,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _mostLikely = d.id),
                            child: Text(
                              _mostLikely == d.id ? 'Selected' : 'Most likely',
                              style: TextStyle(
                                color: _mostLikely == d.id
                                    ? _accent
                                    : Colors.white54,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: i == 0
                                    ? null
                                    : () => _reorder(i, i - 1),
                                icon: const Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white54,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: i >= _ranked.length - 1
                                    ? null
                                    : () => _reorder(i, i + 2),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _explain,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Why this diagnosis?',
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order tests (each costs time points)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._tests.map((_Test t) {
                    final bool ordered = _ordered.contains(t.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        tileColor: _surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          ordered
                              ? _results[t.id]!
                              : 'Cost: ${t.cost} time · ${t.blurb}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        trailing: ordered
                            ? const Icon(Icons.check, color: _accent)
                            : TextButton(
                                onPressed: () => _orderTest(t),
                                child: const Text('Order'),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: _submitted ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Present to Dr. Shah',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Diff {
  const _Diff({
    required this.id,
    required this.label,
    required this.hint,
  });
  final String id;
  final String label;
  final String hint;
}

class _Test {
  const _Test({
    required this.id,
    required this.name,
    required this.cost,
    required this.blurb,
    required this.result,
  });
  final String id;
  final String name;
  final int cost;
  final String blurb;
  final String result;
}

const List<_Diff> _diffs = <_Diff>[
  _Diff(
    id: 'copd',
    label: 'COPD exacerbation',
    hint: 'Smoking hx — but orthopnea + edema argue against pure COPD',
  ),
  _Diff(
    id: 'hf',
    label: 'Heart failure exacerbation',
    hint: 'Orthopnea, edema, missed diuretic, NSAIDs',
  ),
  _Diff(
    id: 'anemia',
    label: 'Symptomatic anemia',
    hint: 'Fatigue possible — less explanatory for orthopnea',
  ),
  _Diff(
    id: 'pe',
    label: 'Pulmonary embolism',
    hint: 'SOB — weaker fit without pleuritic pain / risk factors named',
  ),
];

const List<_Test> _tests = <_Test>[
  _Test(
    id: 'bnp',
    name: 'BNP / NT-proBNP',
    cost: 2,
    blurb: 'High-yield for HF',
    result: 'BNP 1240 — elevated (supports HF).',
  ),
  _Test(
    id: 'cxr',
    name: 'Chest X-ray',
    cost: 2,
    blurb: 'Congestion vs infiltrate',
    result: 'CXR: mild pulmonary edema, cardiomegaly.',
  ),
  _Test(
    id: 'troponin',
    name: 'Troponin',
    cost: 2,
    blurb: 'Rule out ACS',
    result: 'Troponin negative ×1.',
  ),
  _Test(
    id: 'cbc',
    name: 'CBC',
    cost: 1,
    blurb: 'Anemia screen',
    result: 'Hb 13.1 — not explanatory.',
  ),
  _Test(
    id: 'ctpa',
    name: 'CT pulmonary angiogram',
    cost: 5,
    blurb: 'Expensive PE hunt',
    result: 'CTPA negative for PE. Contrast load used.',
  ),
  _Test(
    id: 'full_panel',
    name: 'Everything panel',
    cost: 6,
    blurb: 'Low-value shotgun',
    result: 'Noise. Shah sighs. Time burned.',
  ),
];
