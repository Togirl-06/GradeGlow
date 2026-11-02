import 'package:flutter/material.dart';

/// Free-text patient interview — fact unlock (fatigue + SOB / heart failure case).
class MedicineLab1InterviewScreen extends StatefulWidget {
  const MedicineLab1InterviewScreen({super.key});

  @override
  State<MedicineLab1InterviewScreen> createState() =>
      _MedicineLab1InterviewScreenState();
}

class _MedicineLab1InterviewScreenState
    extends State<MedicineLab1InterviewScreen> {
  static const Color _accent = Color(0xFF60A5FA);
  static const Color _bg = Color(0xFF060B14);
  static const Color _surface = Color(0xFF0F1A2C);

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Chat> _log = <_Chat>[
    _Chat(
      fromStudent: false,
      text:
          'Avery Kim: “Hi… Dr. Shah said you’d take my history. I’ve been exhausted '
          'and short of breath. Where do you want me to start?”',
    ),
  ];
  final Set<String> _unlocked = <String>{};
  int _misses = 0;

  static const List<_Fact> _facts = <_Fact>[
    _Fact(
      id: 'onset',
      topic: 'Onset',
      keywords: <String>['when', 'start', 'onset', 'begin', 'how long', 'week'],
      reveal:
          '“It crept up over about three weeks. Worse this past weekend.”',
      critical: true,
    ),
    _Fact(
      id: 'orthopnea',
      topic: 'Orthopnea',
      keywords: <String>[
        'orthopnea',
        'lie flat',
        'pillow',
        'lying',
        'sleep',
        'night',
        'flat',
      ],
      reveal:
          '“I need two pillows now. If I lie flat I feel like I’m drowning.”',
      critical: true,
    ),
    _Fact(
      id: 'swelling',
      topic: 'Edema',
      keywords: <String>[
        'swell',
        'edema',
        'ankle',
        'leg',
        'puff',
        'fluid',
        'socks',
      ],
      reveal:
          '“My ankles are puffy by evening. Socks leave deep marks.”',
      critical: true,
    ),
    _Fact(
      id: 'exertion',
      topic: 'Exertional SOB',
      keywords: <String>[
        'stairs',
        'walk',
        'exert',
        'activity',
        'exercise',
        'breath',
        'sob',
        'short',
      ],
      reveal:
          '“One flight of stairs and I have to stop. Used to do three no problem.”',
      critical: true,
    ),
    _Fact(
      id: 'smoking',
      topic: 'Smoking',
      keywords: <String>['smok', 'cigarette', 'tobacco', 'pack', 'vape'],
      reveal:
          '“I smoked a pack a day for fifteen years. Quit two years ago.”',
      critical: true,
    ),
    _Fact(
      id: 'chest',
      topic: 'Chest pain',
      keywords: <String>['chest', 'pain', 'pressure', 'angina', 'crush'],
      reveal:
          '“No crushing pain. Just heaviness when I’m winded.”',
      critical: false,
    ),
    _Fact(
      id: 'meds',
      topic: 'Medications',
      keywords: <String>['med', 'pill', 'drug', 'prescription', 'ibuprofen'],
      reveal:
          '“Lisinopril and a water pill… I ran out of the water pill last week. '
          'Been taking ibuprofen for a bad knee.”',
      critical: true,
    ),
  ];

  int get _criticalTotal =>
      _facts.where((_Fact f) => f.critical).length;

  int get _criticalUnlocked => _facts
      .where((_Fact f) => f.critical && _unlocked.contains(f.id))
      .length;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _ask() {
    final String q = _input.text.trim();
    if (q.isEmpty) return;
    _log.add(_Chat(fromStudent: true, text: q));
    _input.clear();
    final String lower = q.toLowerCase();

    _Fact? hit;
    for (final _Fact f in _facts) {
      if (_unlocked.contains(f.id)) continue;
      for (final String k in f.keywords) {
        if (lower.contains(k)) {
          hit = f;
          break;
        }
      }
      if (hit != null) break;
    }

    if (hit != null) {
      _unlocked.add(hit.id);
      _log.add(_Chat(fromStudent: false, text: 'Avery: ${hit.reveal}'));
    } else {
      _misses++;
      _log.add(
        _Chat(
          fromStudent: false,
          text: _misses > 2
              ? 'Avery: “I’m not sure that helps. The breathing and the swelling worry me most.”'
              : 'Avery: “Hmm. Maybe ask about how this started, or nights, or my legs?”',
        ),
      );
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _finish() async {
    final bool enough = _criticalUnlocked >= 4;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Dr. Anika Shah',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            enough
                ? '“You unlocked the story: subacute onset, orthopnea, edema, meds. '
                    'Head to the workroom — build a differential before you spray tests.”\n\n'
                    'Critical facts: $_criticalUnlocked / $_criticalTotal'
                : '“Thin history. You still have enough to start — but next time dig for '
                    'orthopnea, edema, and meds. Workroom.”\n\n'
                    'Critical facts: $_criticalUnlocked / $_criticalTotal',
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
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canFinish = _criticalUnlocked >= 3;
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
                          'CLINIC BAY 2',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'History — Avery Kim',
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
                    '$_criticalUnlocked/$_criticalTotal facts',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_unlocked.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _facts
                      .where((_Fact f) => _unlocked.contains(f.id))
                      .map(
                        (_Fact f) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            backgroundColor: _accent.withValues(alpha: 0.2),
                            label: Text(
                              f.topic,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _log.length,
                itemBuilder: (BuildContext context, int i) {
                  final _Chat c = _log[i];
                  return Align(
                    alignment: c.fromStudent
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                      ),
                      decoration: BoxDecoration(
                        color: c.fromStudent
                            ? _accent.withValues(alpha: 0.2)
                            : _surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        c.text,
                        style: const TextStyle(color: Colors.white, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask a clinical question…',
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
                      onSubmitted: (_) => _ask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _ask,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Ask', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: canFinish ? _finish : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: BorderSide(color: _accent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    canFinish
                        ? 'End interview → differential'
                        : 'Unlock more history (need 3+ critical)',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact {
  const _Fact({
    required this.id,
    required this.topic,
    required this.keywords,
    required this.reveal,
    required this.critical,
  });

  final String id;
  final String topic;
  final List<String> keywords;
  final String reveal;
  final bool critical;
}

class _Chat {
  const _Chat({required this.fromStudent, required this.text});
  final bool fromStudent;
  final String text;
}
