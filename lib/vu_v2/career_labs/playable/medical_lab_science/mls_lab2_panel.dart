import 'package:flutter/material.dart';

/// Interpret chemistry panel, flag critical, report.
class MlsLab2PanelScreen extends StatefulWidget {
  const MlsLab2PanelScreen({super.key});

  @override
  State<MlsLab2PanelScreen> createState() => _MlsLab2PanelScreenState();
}

class _MlsLab2PanelScreenState extends State<MlsLab2PanelScreen> {
  static const Color _accent = Color(0xFFC084FC);
  static const Color _bg = Color(0xFF0C0614);
  static const Color _surface = Color(0xFF1A1028);
  static const String _criticalAnalyte = 'k';

  final Set<String> _flagged = <String>{};
  bool _calledFloor = false;
  bool _released = false;
  String? _note;

  static const List<_Analyte> _panel = <_Analyte>[
    _Analyte(id: 'na', name: 'Sodium', value: '138', unit: 'mmol/L', ref: '136–145', critical: false),
    _Analyte(id: 'k', name: 'Potassium', value: '6.4', unit: 'mmol/L', ref: '3.5–5.1', critical: true),
    _Analyte(id: 'cl', name: 'Chloride', value: '104', unit: 'mmol/L', ref: '98–107', critical: false),
    _Analyte(id: 'co2', name: 'CO₂', value: '22', unit: 'mmol/L', ref: '22–29', critical: false),
    _Analyte(id: 'bun', name: 'BUN', value: '28', unit: 'mg/dL', ref: '7–20', critical: false),
    _Analyte(id: 'cr', name: 'Creatinine', value: '1.6', unit: 'mg/dL', ref: '0.6–1.3', critical: false),
    _Analyte(id: 'glu', name: 'Glucose', value: '142', unit: 'mg/dL', ref: '70–99', critical: false),
  ];

  void _toggleFlag(String id) {
    setState(() {
      if (_flagged.contains(id)) {
        _flagged.remove(id);
      } else {
        _flagged.add(id);
      }
    });
  }

  Future<void> _callCritical() async {
    if (!_flagged.contains(_criticalAnalyte)) {
      setState(() {
        _note =
            'Tessa: “You’re calling… what? Flag the critical analyte on the panel first.”';
      });
      return;
    }
    if (_flagged.length > 1 && !_flagged.every((String id) => id == _criticalAnalyte || _isHigh(_panel.firstWhere((_Analyte a) => a.id == id)))) {
      // allow flagging high non-criticals but require K
    }
    setState(() {
      _calledFloor = true;
      _note =
          'Floor RN confirms read-back: K+ 6.4 critical. Time documented.';
    });
  }

  bool _isHigh(_Analyte a) => a.id == 'bun' || a.id == 'cr' || a.id == 'glu';

  Future<void> _release() async {
    if (!_flagged.contains(_criticalAnalyte)) {
      setState(() {
        _note =
            'Hold. Critical potassium not flagged. Releasing blind is a reportable error.';
      });
      return;
    }
    if (!_calledFloor) {
      setState(() {
        _note =
            'Policy: critical values are phoned before chart release. Call the floor.';
      });
      return;
    }
    _released = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Results verified',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Tessa: “You caught K+ 6.4, called it, then released. '
            'That’s the job — interpret, flag, communicate, report.”',
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
              child: const Text('End shift task', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
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
                          'RESULT DESK',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'BMP — R. Cole',
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
            if (_note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  _note!,
                  style: TextStyle(
                    color: _calledFloor ? _accent : const Color(0xFFFBBF24),
                    height: 1.4,
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _panel.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int i) {
                  final _Analyte a = _panel[i];
                  final bool flagged = _flagged.contains(a.id);
                  return InkWell(
                    onTap: () => _toggleFlag(a.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: a.critical
                              ? (flagged
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFF87171).withValues(alpha: 0.45))
                              : (flagged ? _accent : Colors.white12),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  a.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Ref ${a.ref}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${a.value} ${a.unit}',
                            style: TextStyle(
                              color: a.critical
                                  ? const Color(0xFFF87171)
                                  : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            flagged ? Icons.flag : Icons.flag_outlined,
                            color: flagged
                                ? (a.critical
                                    ? const Color(0xFFF87171)
                                    : _accent)
                                : Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _calledFloor ? null : _callCritical,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _calledFloor ? 'Critical called ✓' : 'Call critical',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _released ? null : _release,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Release report',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
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

class _Analyte {
  const _Analyte({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.ref,
    required this.critical,
  });

  final String id;
  final String name;
  final String value;
  final String unit;
  final String ref;
  final bool critical;
}
