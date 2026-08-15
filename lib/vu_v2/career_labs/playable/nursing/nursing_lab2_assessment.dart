import 'package:flutter/material.dart';

/// Room 103 bedside assessment — CARE + MONITOR + ESCALATE (not diagnose).
class NursingLab2AssessmentScreen extends StatefulWidget {
  const NursingLab2AssessmentScreen({super.key});

  @override
  State<NursingLab2AssessmentScreen> createState() =>
      _NursingLab2AssessmentScreenState();
}

class _NursingLab2AssessmentScreenState
    extends State<NursingLab2AssessmentScreen> {
  static const Color _accent = Color(0xFF2DD4A8);
  static const Color _bg = Color(0xFF061412);
  static const Color _surface = Color(0xFF0F2420);

  final TextEditingController _speak = TextEditingController();
  final List<_Line> _log = <_Line>[
    _Line(
      fromNurse: false,
      text: 'Jordan Lee (Room 103): “I don’t feel right… hard to catch my breath.”',
    ),
  ];

  bool _spoke = false;
  bool _history = false;
  bool _vitals = false;
  bool _documented = false;
  bool _escalated = false;
  int _talkOnlyTicks = 0;
  int _spo2 = 91;
  int _rr = 28;
  int _hr = 112;

  @override
  void dispose() {
    _speak.dispose();
    super.dispose();
  }

  void _add(String text, {required bool fromNurse}) {
    setState(() => _log.add(_Line(fromNurse: fromNurse, text: text)));
  }

  void _worsenIfTalkOnly() {
    _talkOnlyTicks++;
    if (_talkOnlyTicks >= 2 && !_vitals) {
      _spo2 = (_spo2 - 2).clamp(84, 100);
      _rr = (_rr + 2).clamp(12, 40);
      _hr = (_hr + 4).clamp(60, 150);
      _add(
        'Monitor trend: SpO₂ $_spo2% · RR $_rr · HR $_hr — still talking, not assessing.',
        fromNurse: false,
      );
    }
  }

  void _doSpeak() {
    final String q = _speak.text.trim();
    if (q.isEmpty) return;
    _add('You: $q', fromNurse: true);
    _speak.clear();
    _spoke = true;
    final String lower = q.toLowerCase();
    String reply;
    if (lower.contains('pain') || lower.contains('hurt')) {
      reply =
          '“Chest feels tight… not sharp pain, more like I can’t get air in.”';
    } else if (lower.contains('when') || lower.contains('start')) {
      reply = '“Got worse over the last hour. Worse when I lie flat.”';
    } else if (lower.contains('oxygen') || lower.contains('o2') || lower.contains('help')) {
      reply = '“Please… just help me breathe. I’m scared.”';
    } else if (lower.contains('med') || lower.contains('inhaler')) {
      reply = '“I used my inhaler twice. Didn’t do much.”';
    } else {
      reply =
          '“I just… don’t feel right. Something’s off. Can you check me?”';
    }
    _add('Jordan: $reply', fromNurse: false);
    _worsenIfTalkOnly();
    setState(() {});
  }

  void _reviewHistory() {
    if (_history) return;
    _history = true;
    _add(
      'Chart: COPD + HFrEF. Night SpO₂ 88% on 2L NC. Lasix held overnight for low BP. '
      'Allergies: sulfa. Code status: Full.',
      fromNurse: false,
    );
    setState(() {});
  }

  void _checkVitals() {
    _vitals = true;
    _talkOnlyTicks = 0;
    _spo2 = 86;
    _rr = 32;
    _hr = 118;
    _add(
      'Vitals NOW: SpO₂ 86% on 2L · RR 32 · HR 118 · BP 98/62 · Temp 37.1°C. '
      'Patient using accessory muscles. This is a change — escalate.',
      fromNurse: false,
    );
    setState(() {});
  }

  void _document() {
    if (!_vitals) {
      _add(
        'Diaz (radio): “Document after you have real vitals — not vibes.”',
        fromNurse: false,
      );
      setState(() {});
      return;
    }
    _documented = true;
    _add(
      'You document: acute respiratory distress, SpO₂ drop to 86% on 2L, '
      'accessory muscle use, patient reports orthopnea. Notified charge.',
      fromNurse: true,
    );
    setState(() {});
  }

  Future<void> _escalate() async {
    if (!_vitals || !_documented) {
      _add(
        'Diaz: “Escalate with data. Check vitals and document the change first.”',
        fromNurse: false,
      );
      setState(() {});
      return;
    }
    _escalated = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: const Text(
            'Rapid response notified',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Diaz: “That’s nursing. You assessed, monitored the trend, documented, '
            'and escalated — you did not play doctor. Room 103 is safer because of you.”',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.45,
            ),
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
              child: const Text('End assessment', style: TextStyle(fontWeight: FontWeight.w900)),
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
                          'ROOM 103',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Bedside assessment — Jordan Lee',
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _VitalChip(label: 'SpO₂', value: '$_spo2%'),
                  _VitalChip(label: 'RR', value: '$_rr'),
                  _VitalChip(label: 'HR', value: '$_hr'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _log.length,
                itemBuilder: (BuildContext context, int i) {
                  final _Line line = _log[i];
                  return Align(
                    alignment: line.fromNurse
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                      ),
                      decoration: BoxDecoration(
                        color: line.fromNurse
                            ? _accent.withValues(alpha: 0.18)
                            : _surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        line.text,
                        style: const TextStyle(color: Colors.white, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  _ToolChip(
                    label: 'Review history',
                    done: _history,
                    onTap: _reviewHistory,
                  ),
                  _ToolChip(
                    label: 'Check vitals',
                    done: _vitals,
                    onTap: _checkVitals,
                  ),
                  _ToolChip(
                    label: 'Document',
                    done: _documented,
                    onTap: _document,
                  ),
                  _ToolChip(
                    label: 'Escalate',
                    done: _escalated,
                    onTap: _escalate,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _speak,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Speak to patient…',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _doSpeak(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _doSpeak,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _spoke ? 'Send' : 'Speak',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

class _Line {
  const _Line({required this.fromNurse, required this.text});
  final bool fromNurse;
  final String text;
}

class _VitalChip extends StatelessWidget {
  const _VitalChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2DD4A8),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.label,
    required this.done,
    required this.onTap,
  });

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        backgroundColor: done
            ? const Color(0xFF2DD4A8).withValues(alpha: 0.25)
            : const Color(0xFF0F2420),
        label: Text(
          done ? '$label ✓' : label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
