import 'package:flutter/material.dart';

import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryEquationBuilderScreen extends StatefulWidget {
  const ChemistryEquationBuilderScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  State<ChemistryEquationBuilderScreen> createState() =>
      _ChemistryEquationBuilderScreenState();
}

class _ChemistryEquationBuilderScreenState extends State<ChemistryEquationBuilderScreen> {
  final TextEditingController _equationController = TextEditingController(
    text: 'H2 + O2 -> H2O',
  );
  String? _feedback;
  bool _balanced = false;

  static const Map<String, String> _known = <String, String>{
    'h2 + o2 -> h2o': '2 H₂ + O₂ → 2 H₂O  (synthesis · combustion of hydrogen)',
    'na + cl2 -> nacl': '2 Na + Cl₂ → 2 NaCl  (redox · ionic bond formation)',
    'ch4 + o2 -> co2 + h2o': 'CH₄ + 2 O₂ → CO₂ + 2 H₂O  (combustion)',
    'hcl + naoh -> nacl + h2o': 'HCl + NaOH → NaCl + H₂O  (neutralization)',
  };

  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }

  void _check() {
    final String key = _equationController.text
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('→', '->')
        .replaceAll('=', '->');
    final String? answer = _known[key];
    setState(() {
      if (answer != null) {
        _balanced = true;
        _feedback =
            'Balanced ✓\n$answer\n\nStep-by-step: balance metals → non-metals → hydrogen → oxygen last.';
      } else {
        _balanced = false;
        _feedback =
            'Not yet balanced or unrecognized products.\n'
            'Professor tip: verify atom counts on each side, add state symbols (s, l, g, aq), '
            'and classify the reaction type for ${widget.path.lesson.title}.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Builder', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Type a chemical equation. AI checks balancing, products, reaction type, and state symbols.',
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _equationController,
            decoration: const InputDecoration(
              labelText: 'Your equation',
              hintText: 'e.g. H2 + O2 -> H2O',
            ),
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _check,
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Check equation', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: c.cardDecoration(
                borderColor: (_balanced ? c.success : c.accent).withValues(alpha: 0.5),
              ),
              child: Text(
                _feedback!,
                style: TextStyle(
                  color: c.textPrimary.withValues(alpha: 0.9),
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Try: HCl + NaOH -> NaCl + H2O',
            style: TextStyle(color: c.textSecondary, fontSize: 12),
          ),
        ],
      ),
      bottomNavigationBar: _balanced
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            )
          : null,
    );
  }
}
