import 'package:flutter/material.dart';

/// Sample arrival — identify specimen + ordered prep pipeline.
class MlsLab1PipelineScreen extends StatefulWidget {
  const MlsLab1PipelineScreen({super.key});

  @override
  State<MlsLab1PipelineScreen> createState() => _MlsLab1PipelineScreenState();
}

class _MlsLab1PipelineScreenState extends State<MlsLab1PipelineScreen> {
  static const Color _accent = Color(0xFFC084FC);
  static const Color _bg = Color(0xFF0C0614);
  static const Color _surface = Color(0xFF1A1028);

  static const String _correctSpecimen = 'serum_gold';
  static const List<String> _correctOrder = <String>[
    'receive',
    'label',
    'prepare',
    'select',
    'run',
    'analyze',
    'report',
  ];

  String? _specimen;
  final List<String> _pickedSteps = <String>[];
  String? _failureStory;
  bool _passed = false;

  static const List<_Specimen> _specimens = <_Specimen>[
    _Specimen(
      id: 'serum_gold',
      label: 'Gold-top SST — serum chemistry',
      detail: 'Patient: R. Cole · Order: BMP STAT · Drawn 06:32',
    ),
    _Specimen(
      id: 'edta',
      label: 'Lavender EDTA — CBC',
      detail: 'Wrong tube for this BMP order.',
    ),
    _Specimen(
      id: 'urine',
      label: 'Urine cup — UA',
      detail: 'Not a blood chemistry specimen.',
    ),
    _Specimen(
      id: 'blood_culture',
      label: 'Blood culture bottles',
      detail: 'Micro — not chemistry bench.',
    ),
  ];

  static const List<_Step> _steps = <_Step>[
    _Step(id: 'receive', title: 'Receive', blurb: 'Accept into LIS / accession'),
    _Step(id: 'label', title: 'Label', blurb: 'Verify identity vs order'),
    _Step(id: 'prepare', title: 'Prepare', blurb: 'Centrifuge / aliquot serum'),
    _Step(id: 'select', title: 'Select test', blurb: 'Load BMP assay menu'),
    _Step(id: 'run', title: 'Run', blurb: 'Start analyzer'),
    _Step(id: 'analyze', title: 'Analyze', blurb: 'Review flags / QC'),
    _Step(id: 'report', title: 'Report', blurb: 'Release to chart / call path'),
  ];

  void _toggleStep(String id) {
    if (_passed || _failureStory != null) return;
    setState(() {
      if (_pickedSteps.contains(id)) {
        _pickedSteps.remove(id);
      } else {
        _pickedSteps.add(id);
      }
    });
  }

  Future<void> _submit() async {
    if (_specimen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identify the specimen type first.')),
      );
      return;
    }
    if (_specimen != _correctSpecimen) {
      setState(() {
        _failureStory =
            'Wrong tube for a STAT BMP. You nearly ran EDTA plasma as serum chemistry. '
            'Tessa stops you: “Identity first. Always.” Restart the order sequence.';
        _pickedSteps.clear();
      });
      return;
    }
    if (_pickedSteps.length != _correctOrder.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select every step, in order.')),
      );
      return;
    }
    bool ok = true;
    for (int i = 0; i < _correctOrder.length; i++) {
      if (_pickedSteps[i] != _correctOrder[i]) {
        ok = false;
        break;
      }
    }
    if (!ok) {
      setState(() {
        _failureStory =
            'Order broken. You ${ _storyForBadOrder() }. '
            'Specimen integrity / turnaround compromised. Reset and try again.';
        _pickedSteps.clear();
      });
      return;
    }
    setState(() {
      _failureStory = null;
      _passed = true;
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Tessa Adebayo',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Gold-top identified. Pipeline clean: Receive → Label → Prepare → '
            'Select → Run → Analyze → Report. Analyzer’s spinning — meet me at the result desk.”',
            style: TextStyle(color: Colors.white, height: 1.45),
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
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  String _storyForBadOrder() {
    if (_pickedSteps.isEmpty) return 'skipped the bench';
    if (_pickedSteps.first != 'receive') {
      return 'touched the tube before receiving it into the LIS';
    }
    if (_pickedSteps.contains('run') &&
        _pickedSteps.indexOf('run') < _pickedSteps.indexOf('label')) {
      return 'ran an unlabeled specimen — nightmare scenario';
    }
    if (_pickedSteps.contains('report') &&
        _pickedSteps.indexOf('report') < _pickedSteps.indexOf('analyze')) {
      return 'reported before analyzing flags';
    }
    return 'scrambled the chemistry pipeline';
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
                          'RECEIVING',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'STAT specimen pipeline',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_failureStory != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF87171)),
                ),
                child: Text(
                  _failureStory!,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  Text(
                    '1. What specimen is this?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._specimens.map((_Specimen s) {
                    final bool sel = _specimen == s.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() {
                          _specimen = s.id;
                          _failureStory = null;
                        }),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? _accent : Colors.white12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                s.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                s.detail,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    '2. Tap steps in order (sequence shown below)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_pickedSteps.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _pickedSteps
                            .map((String id) {
                              return _steps
                                  .firstWhere((_Step s) => s.id == id)
                                  .title;
                            })
                            .join(' → '),
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ..._steps.map((_Step s) {
                    final int idx = _pickedSteps.indexOf(s.id);
                    final bool on = idx >= 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _toggleStep(s.id),
                        tileColor: _surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: on ? _accent : Colors.transparent,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: on
                              ? _accent
                              : Colors.white12,
                          foregroundColor: Colors.black,
                          child: Text(
                            on ? '${idx + 1}' : '·',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: on ? Colors.black : Colors.white54,
                            ),
                          ),
                        ),
                        title: Text(
                          s.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          s.blurb,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
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
              child: Row(
                children: <Widget>[
                  if (_pickedSteps.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() {
                        _pickedSteps.clear();
                        _failureStory = null;
                      }),
                      child: const Text('Reset steps'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Run pipeline',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Specimen {
  const _Specimen({
    required this.id,
    required this.label,
    required this.detail,
  });
  final String id;
  final String label;
  final String detail;
}

class _Step {
  const _Step({
    required this.id,
    required this.title,
    required this.blurb,
  });
  final String id;
  final String title;
  final String blurb;
}
