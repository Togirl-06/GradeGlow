import 'package:flutter/material.dart';

/// Patient counseling free-text — timing + missed dose keywords.
class PharmacyLab2CounselScreen extends StatefulWidget {
  const PharmacyLab2CounselScreen({super.key});

  @override
  State<PharmacyLab2CounselScreen> createState() =>
      _PharmacyLab2CounselScreenState();
}

class _PharmacyLab2CounselScreenState extends State<PharmacyLab2CounselScreen> {
  static const Color _accent = Color(0xFF5EEAD4);
  static const Color _bg = Color(0xFF041411);
  static const Color _surface = Color(0xFF0C221E);

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Chat> _log = <_Chat>[
    _Chat(
      fromStudent: false,
      text:
          'Patient: “They switched me to doxycycline. When do I take it? '
          'And what if I forget a dose?”',
    ),
  ];
  final Set<String> _hits = <String>{};
  int _turn = 0;

  static const List<_CounselCue> _cues = <_CounselCue>[
    _CounselCue(
      id: 'when',
      keywords: <String>[
        'morning',
        'evening',
        'twice',
        'two times',
        '12 hour',
        'every 12',
        'with water',
        'full glass',
        'sit upright',
        'food',
        'empty',
      ],
      patientFollow:
          'Patient: “Okay — twice a day with water, upright. Anything about dairy?”',
    ),
    _CounselCue(
      id: 'dairy',
      keywords: <String>[
        'dairy',
        'milk',
        'calcium',
        'antacid',
        'iron',
        'separate',
        'hours apart',
        '2 hour',
        'two hour',
      ],
      patientFollow:
          'Patient: “Got it — separate from milk and antacids. What if I miss a dose?”',
    ),
    _CounselCue(
      id: 'miss',
      keywords: <String>[
        'miss',
        'forget',
        'forgot',
        'skip',
        'as soon as',
        'remember',
        'don\'t double',
        'do not double',
        'never double',
        'next dose',
      ],
      patientFollow:
          'Patient: “So take it when I remember unless it’s almost time for the next — never double. Thanks.”',
    ),
    _CounselCue(
      id: 'sun',
      keywords: <String>[
        'sun',
        'photosens',
        'sunscreen',
        'burn',
        'light',
      ],
      patientFollow:
          'Patient: “I’ll use sunscreen. Anything else I should watch for?”',
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final String raw = _input.text.trim();
    if (raw.isEmpty) return;
    _log.add(_Chat(fromStudent: true, text: raw));
    _input.clear();
    final String lower = raw.toLowerCase();
    _turn++;

    _CounselCue? matched;
    for (final _CounselCue c in _cues) {
      if (_hits.contains(c.id)) continue;
      for (final String k in c.keywords) {
        if (lower.contains(k)) {
          matched = c;
          break;
        }
      }
      if (matched != null) break;
    }

    if (matched != null) {
      _hits.add(matched.id);
      _log.add(_Chat(fromStudent: false, text: matched.patientFollow));
    } else {
      _log.add(
        _Chat(
          fromStudent: false,
          text: _turn < 3
              ? 'Patient: “Can you be more specific? Like what time, and what if I forget?”'
              : 'Patient: “I still need when to take it, dairy/calcium spacing, and missed-dose rules.”',
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
    final bool good =
        _hits.contains('when') && _hits.contains('miss');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: _surface,
          title: Text(
            'Ada Okonkwo',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            good
                ? '“Solid counseling — timing and missed-dose teach-back covered. '
                    'That’s pharmacy practice, not a leaflet.”\n\n'
                    'Topics hit: ${_hits.length}/${_cues.length}'
                : '“Thin counseling. Next time hit dose timing and what to do if they forget. '
                    'Still clearing you forward — review the script.”\n\n'
                    'Topics hit: ${_hits.length}/${_cues.length}',
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
              child: const Text('End counseling', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canFinish = _hits.contains('when') && _hits.contains('miss');
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
                          'COUNSELING BOOTH',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Doxycycline teach-back',
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
                    '${_hits.length} topics',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
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
                        hintText: 'Counsel the patient…',
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
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Say', style: TextStyle(fontWeight: FontWeight.w900)),
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
                        ? 'Finish counseling'
                        : 'Cover timing + missed dose to finish',
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

class _CounselCue {
  const _CounselCue({
    required this.id,
    required this.keywords,
    required this.patientFollow,
  });

  final String id;
  final List<String> keywords;
  final String patientFollow;
}

class _Chat {
  const _Chat({required this.fromStudent, required this.text});
  final bool fromStudent;
  final String text;
}
