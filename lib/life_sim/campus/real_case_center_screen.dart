import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'real_cases.dart';

/// Real Case Study Center (College of Law & Justice).
///
/// Students read landmark *published* decisions step by step: facts and issue,
/// both sides' arguments, predict the outcome, then the court's decision and
/// reasoning, then comprehension questions. Fictional practice cases live in
/// the Moot Courtroom and are labelled there as fictional.
class RealCaseCenterScreen extends StatefulWidget {
  const RealCaseCenterScreen({super.key});

  @override
  State<RealCaseCenterScreen> createState() => _RealCaseCenterScreenState();
}

const String _prefsKey = 'campus_real_cases_done';
const Color _ink = Color(0xFF0F172A);
const Color _paper = Color(0xFFFFFBF2);
const Color _accent = Color(0xFF9F1239);

class _RealCaseCenterScreenState extends State<RealCaseCenterScreen> {
  Set<String> _done = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _done = (prefs.getStringList(_prefsKey) ?? <String>[]).toSet());
  }

  Future<void> _markDone(String id) async {
    final Set<String> next = <String>{..._done, id};
    setState(() => _done = next);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, next.toList());
  }

  Future<void> _open(RealCase c) async {
    final bool? finished = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => _CaseReader(rc: c)),
    );
    if (finished == true) await _markDone(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: const Text('Real Case Study Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7E5E4))),
            child: Text(
              'These are real, published court decisions (summarised for teaching). '
              'Read the facts, weigh both sides, predict the outcome, then see what the court decided and why.\n\n'
              'Completed: ${_done.length} of ${RealCases.all.length}. Educational only — not legal advice.',
              style: const TextStyle(color: _ink, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),
          for (final RealCase c in RealCases.all)
            Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                onTap: () => _open(c),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: _done.contains(c.id) ? const Color(0xFF16A34A) : _accent,
                  foregroundColor: Colors.white,
                  child: Icon(_done.contains(c.id) ? Icons.check_rounded : Icons.gavel_rounded),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, color: _ink)),
                subtitle: Text('${c.court} · ${c.year}\n${c.area}', style: const TextStyle(color: Color(0xFF57534E))),
                isThreeLine: true,
                trailing: const _RealBadge(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RealBadge extends StatelessWidget {
  const _RealBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(8)),
        child: const Text('REAL CASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _accent)),
      );
}

/// Step-by-step reader for one case. Pops `true` when the student finishes.
class _CaseReader extends StatefulWidget {
  const _CaseReader({required this.rc});
  final RealCase rc;

  @override
  State<_CaseReader> createState() => _CaseReaderState();
}

class _CaseReaderState extends State<_CaseReader> {
  int _step = 0;
  int? _prediction;
  final Map<int, int> _answers = <int, int>{};

  static const List<String> _steps = <String>['Facts', 'Arguments', 'Predict', 'Decision', 'Questions'];

  RealCase get c => widget.rc;

  bool get _canContinue {
    if (_step == 2) return _prediction != null;
    if (_step == 4) return _answers.length == c.questions.length;
    return true;
  }

  int get _score {
    int s = 0;
    for (int i = 0; i < c.questions.length; i++) {
      if (_answers[i] == c.questions[i].answer) s++;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < _steps.length; i++)
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2), color: i <= _step ? _accent : const Color(0xFFE7E5E4)),
                        const SizedBox(height: 4),
                        Text(_steps[i], style: TextStyle(fontSize: 11, fontWeight: i == _step ? FontWeight.w900 : FontWeight.w500, color: _ink)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: _body())),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: <Widget>[
                  if (_step > 0)
                    TextButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    onPressed: !_canContinue
                        ? null
                        : () {
                            if (_step < _steps.length - 1) {
                              setState(() => _step++);
                            } else {
                              Navigator.of(context).pop(true);
                            }
                          },
                    child: Text(_step < _steps.length - 1 ? 'Continue' : 'Finish case ($_score/${c.questions.length})'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _accent, fontSize: 13)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: _ink, height: 1.45, fontSize: 15)),
        ]),
      );

  Widget _choice(String text, bool selected, VoidCallback? onTap, {bool? correct}) {
    Color border = const Color(0xFFE7E5E4);
    Color fill = Colors.white;
    if (correct == true) {
      border = const Color(0xFF16A34A);
      fill = const Color(0xFFDCFCE7);
    } else if (correct == false && selected) {
      border = const Color(0xFFDC2626);
      fill = const Color(0xFFFEE2E2);
    } else if (selected) {
      border = _accent;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: border, width: 1.5)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(12), child: Text(text, style: const TextStyle(color: _ink))),
        ),
      ),
    );
  }

  List<Widget> _body() {
    switch (_step) {
      case 0:
        return <Widget>[
          const Align(alignment: Alignment.centerLeft, child: _RealBadge()),
          const SizedBox(height: 10),
          _section('Case', '${c.name}, ${c.citation} (${c.year})'),
          _section('Court', '${c.court} — ${c.jurisdiction}'),
          _section('Parties', c.parties),
          _section('What happened', c.facts.map((String f) => '• $f').join('\n')),
          _section('Legal question', c.issue),
          _section('Law that applies', c.law),
        ];
      case 1:
        return <Widget>[
          _section('Argument for one side', c.forSide),
          _section('Argument for the other side', c.againstSide),
          const Text('Which argument do you find stronger? Think about it before you predict.', style: TextStyle(color: Color(0xFF57534E))),
        ];
      case 2:
        return <Widget>[
          const Text('What do you think the court decided?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _ink)),
          const SizedBox(height: 10),
          for (int i = 0; i < c.predictOptions.length; i++)
            _choice(c.predictOptions[i], _prediction == i, () => setState(() => _prediction = i)),
        ];
      case 3:
        final bool right = _prediction == c.predictAnswer;
        return <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: right ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: Text(right ? 'Your prediction matched the court.' : 'The court went another way. Read the reasoning to see why.', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
          ),
          const SizedBox(height: 14),
          _section('Decision', c.decision),
          _section('Why the court decided this', c.reasoning),
          _section('Why it still matters', c.significance),
        ];
      default:
        return <Widget>[
          for (int q = 0; q < c.questions.length; q++) ...<Widget>[
            Text('${q + 1}. ${c.questions[q].prompt}', style: const TextStyle(fontWeight: FontWeight.w900, color: _ink, fontSize: 15)),
            const SizedBox(height: 8),
            for (int i = 0; i < c.questions[q].options.length; i++)
              _choice(
                c.questions[q].options[i],
                _answers[q] == i,
                _answers.containsKey(q) ? null : () => setState(() => _answers[q] = i),
                correct: _answers.containsKey(q) ? (i == c.questions[q].answer ? true : (_answers[q] == i ? false : null)) : null,
              ),
            if (_answers.containsKey(q))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(c.questions[q].why, style: const TextStyle(color: Color(0xFF57534E), fontStyle: FontStyle.italic)),
              ),
          ],
        ];
    }
  }
}
