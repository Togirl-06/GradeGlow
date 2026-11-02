import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/science_badges.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import 'biology_station_chrome.dart';

/// Guided experiment: Q → H → IV/DV/Controls → reorder procedure → obs → data → graph → conclusion.
class BiologyExperimentNotebookFlow extends StatefulWidget {
  const BiologyExperimentNotebookFlow({super.key});

  @override
  State<BiologyExperimentNotebookFlow> createState() =>
      _BiologyExperimentNotebookFlowState();
}

class _BiologyExperimentNotebookFlowState
    extends State<BiologyExperimentNotebookFlow> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;
  final ScienceNotebookStore _nb = ScienceNotebookStore('biology');

  int _step = 0;
  final TextEditingController _q = TextEditingController();
  final TextEditingController _h = TextEditingController();
  final TextEditingController _iv = TextEditingController();
  final TextEditingController _dv = TextEditingController();
  final TextEditingController _ctrl = TextEditingController();
  final TextEditingController _obs = TextEditingController();
  final TextEditingController _data = TextEditingController();
  final TextEditingController _concl = TextEditingController();
  String? _feedback;

  final List<String> _procedure = <String>[
    'Measure dependent variable baseline',
    'Change independent variable in treatment group',
    'Hold controls constant across groups',
    'Record observations at each interval',
    'Graph results and write conclusion',
  ];

  static const List<String> _correctOrder = <String>[
    'Hold controls constant across groups',
    'Measure dependent variable baseline',
    'Change independent variable in treatment group',
    'Record observations at each interval',
    'Graph results and write conclusion',
  ];

  List<double> get _parsedData {
    final Iterable<double> nums = _data.text
        .split(RegExp(r'[,;\s]+'))
        .map((String s) => double.tryParse(s.trim()))
        .whereType<double>();
    return nums.toList();
  }

  Future<void> _next() async {
    switch (_step) {
      case 0:
        if (_q.text.trim().length < 8) {
          setState(() => _feedback = 'Write a clear research question.');
          return;
        }
      case 1:
        if (_h.text.trim().length < 8) {
          setState(() => _feedback = 'State a testable hypothesis.');
          return;
        }
      case 2:
        if (_iv.text.trim().isEmpty ||
            _dv.text.trim().isEmpty ||
            _ctrl.text.trim().isEmpty) {
          setState(() => _feedback = 'Fill IV, DV, and controls.');
          return;
        }
      case 3:
        bool orderOk = true;
        for (int i = 0; i < _correctOrder.length; i++) {
          if (_procedure[i] != _correctOrder[i]) {
            orderOk = false;
            break;
          }
        }
        if (!orderOk) {
          setState(() {
            _feedback =
                'Reorder procedure: controls → baseline → change IV → observe → graph.';
          });
          return;
        }
      case 4:
        if (_obs.text.trim().length < 12) {
          setState(() => _feedback = 'Log richer observations.');
          return;
        }
      case 5:
        if (_parsedData.length < 3) {
          setState(() => _feedback = 'Enter at least 3 numeric data points.');
          return;
        }
      case 6:
        // graph view — just continue
        break;
      case 7:
        if (_concl.text.trim().length < 20) {
          setState(() => _feedback = 'Write a conclusion tied to your data.');
          return;
        }
        await _save();
        return;
    }
    setState(() {
      _feedback = null;
      _step++;
    });
  }

  Future<void> _save() async {
    final ExperimentEntry entry = ExperimentEntry(
      id: 'bio_exp_${DateTime.now().millisecondsSinceEpoch}',
      question: _q.text.trim(),
      hypothesis: _h.text.trim(),
      independent: _iv.text.trim(),
      dependent: _dv.text.trim(),
      controls: _ctrl.text.trim(),
      procedure: _procedure.join(' → '),
      observations: _obs.text.trim(),
      data: _data.text.trim(),
      conclusion: _concl.text.trim(),
    );
    await _nb.addExperiment(entry);
    await _nb.addConclusion(entry.conclusion);
    await _nb.addDataTable(<String, dynamic>{
      'title': entry.question,
      'values': _parsedData,
    });
    await _nb.addGraphMeta(<String, dynamic>{
      'title': 'Experiment graph',
      'values': _parsedData,
    });
    await _nb.awardXp(50, coins: 15);
    await _nb.unlockBadge(ScienceBadges.labNotebookPro);
    await _nb.unlockBadge(ScienceBadges.hypothesisHero);
    await _nb.markComplete('lab_bench');
    if (!mounted) return;
    await showBioResult(
      context: context,
      passed: true,
      title: 'Experiment filed',
      body: 'Full write-up saved to your Biology notebook.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _q.dispose();
    _h.dispose();
    _iv.dispose();
    _dv.dispose();
    _ctrl.dispose();
    _obs.dispose();
    _data.dispose();
    _concl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'Question',
      'Hypothesis',
      'Variables',
      'Procedure',
      'Observations',
      'Data entry',
      'Graph',
      'Conclusion',
    ];
    return BiologyStationScaffold(
      title: 'Lab Bench · Experiment',
      brief: 'Step ${_step + 1}/8 — ${titles[_step]}',
      badgeLabel: 'METHOD',
      footer: bioPrimaryButton(
        label: _step == 7 ? 'SAVE TO NOTEBOOK' : 'NEXT',
        onPressed: _next,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          LinearProgressIndicator(
            value: (_step + 1) / 8,
            color: t.accent,
            backgroundColor: t.accent.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          ..._stepBody(),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  List<Widget> _stepBody() {
    switch (_step) {
      case 0:
        return <Widget>[_field(_q, 'Research question')];
      case 1:
        return <Widget>[_field(_h, 'Hypothesis (If… then…)')];
      case 2:
        return <Widget>[
          _field(_iv, 'Independent variable (IV)'),
          const SizedBox(height: 8),
          _field(_dv, 'Dependent variable (DV)'),
          const SizedBox(height: 8),
          _field(_ctrl, 'Controls'),
        ];
      case 3:
        return <Widget>[
          const Text(
            'Drag to reorder procedure steps:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _procedure.length,
            onReorderItem: (int oldIndex, int newIndex) {
              setState(() {
                final String item = _procedure.removeAt(oldIndex);
                _procedure.insert(newIndex, item);
              });
            },
            itemBuilder: (BuildContext context, int i) {
              return ListTile(
                key: ValueKey<String>(_procedure[i]),
                tileColor: t.surface,
                title: Text(_procedure[i], style: const TextStyle(color: Colors.white)),
                leading: Icon(Icons.drag_handle, color: t.accent),
              );
            },
          ),
        ];
      case 4:
        return <Widget>[_field(_obs, 'Observations', lines: 4)];
      case 5:
        return <Widget>[
          _field(_data, 'Data points (comma-separated numbers)', lines: 2),
        ];
      case 6:
        return <Widget>[
          bioPanel(
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _SimpleBarsPainter(values: _parsedData, accent: t.accent),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simple graph of your data — continue to conclude.',
            style: TextStyle(color: Colors.white70),
          ),
        ];
      default:
        return <Widget>[_field(_concl, 'Conclusion', lines: 4)];
    }
  }

  Widget _field(TextEditingController c, String label, {int lines = 3}) {
    return TextField(
      controller: c,
      maxLines: lines,
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

class _SimpleBarsPainter extends CustomPainter {
  _SimpleBarsPainter({required this.values, required this.accent});

  final List<double> values;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final double maxV = values.reduce(math.max);
    final double barW = size.width / (values.length * 1.4);
    for (int i = 0; i < values.length; i++) {
      final double h = (values[i] / (maxV == 0 ? 1 : maxV)) * (size.height * 0.85);
      final double x = i * barW * 1.4 + barW * 0.2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h),
          const Radius.circular(6),
        ),
        Paint()..color = accent.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleBarsPainter oldDelegate) =>
      oldDelegate.values != values;
}
