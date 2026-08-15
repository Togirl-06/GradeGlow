import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Harbor University Behavioral Lab — Dr. Naomi Brook.
Widget psychologyPlayableScreen() => const PsychologyPlayableScreen();

class PsychologyPlayableScreen extends StatelessWidget {
  const PsychologyPlayableScreen({super.key});

  static const Color accent = Color(0xFFE879F9);
  static const Color bg = Color(0xFF120816);
  static const Color surface = Color(0xFF1E1024);

  static const PlayableCareer career = PlayableCareer(
    id: 'psychology',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Harbor University · Behavioral Lab',
    clockLine: 'Monday — 10:30 AM',
    roleTitle: 'Research Assistant',
    supervisorName: 'Dr. Naomi Brook',
    supervisorRole: 'Principal Investigator',
    hireTagline: 'Listen carefully. Design carefully. Data over vibes.',
    supervisorBrief:
        '“Run a structured interview with our AI participant.\n\n'
        'Then design a mini experiment — hypothesis, IV, DV, control, procedure — and run it.”',
    enterCta: 'ENTER BEHAVIORAL LAB',
    startCta: 'OPEN INTERVIEW ROOM',
    startLocationId: 'interview',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Lab Lobby',
        icon: '🧠',
        blurb: 'Consent forms and quiet signs.',
        atmosphere: 'Harbor Behavioral Lab. Soft lighting. Strict protocols.',
      ),
      PlayableRoom(
        id: 'interview',
        name: 'Interview Room',
        icon: '🎙️',
        blurb: 'Structured protocol.',
        atmosphere: 'AI participant waiting. Stick to the scripted probes.',
      ),
      PlayableRoom(
        id: 'design',
        name: 'Design Studio',
        icon: '📐',
        blurb: 'Hypotheses on glass.',
        atmosphere: 'IV, DV, control — write them before you click run.',
        lockedUntilStageId: 'lab1',
      ),
      PlayableRoom(
        id: 'data',
        name: 'Data Bay',
        icon: '📈',
        blurb: 'Summaries and plots.',
        atmosphere: 'Results land here after the run.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'interview',
        bannerTitle: 'STRUCTURED INTERVIEW',
        bannerBody: 'Interview the AI participant with free-text probes.',
        cta: 'Start interview',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'design',
        bannerTitle: 'EXPERIMENT DESIGN',
        bannerBody: 'Hypothesis / IV / DV / control / procedure → run → data summary.',
        cta: 'Design & run',
        unlockKey: 'lab2',
        requiresKey: 'lab1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return PlayableWorkplaceScreen(
      career: augmentCareerWithVisualLabs(career),
      onOpenStage: (BuildContext ctx, PlayableStage stage) async {
        final bool? visual = await tryRunVisualStage(ctx, stage);
        if (visual != null) return visual;
        if (!ctx.mounted) return false;
        if (stage.id == 'lab1') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _PsychLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _PsychLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _PsychLab1Screen extends StatefulWidget {
  const _PsychLab1Screen();

  @override
  State<_PsychLab1Screen> createState() => _PsychLab1ScreenState();
}

class _PsychLab1ScreenState extends State<_PsychLab1Screen> {
  int _q = 0;
  final TextEditingController _answer = TextEditingController();
  final List<String> _notes = <String>[];
  String? _feedback;

  static const List<(String, String)> _prompts = <(String, String)>[
    (
      'Participant: “I sleep about five hours on weeknights.”',
      'Probe sleep timing, quality, or daytime effects…',
    ),
    (
      'Participant: “Deadlines make my focus worse, not better.”',
      'Ask about stress cues or coping strategies…',
    ),
    (
      'Participant: “I skip meals when the lab runs late.”',
      'Explore routine, hunger, or mood links…',
    ),
  ];

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _next() {
    final String t = _answer.text.trim();
    if (t.length < 12) {
      setState(() => _feedback = 'Brook: “Probe with a full question — free text.”');
      return;
    }
    setState(() {
      _notes.add(t);
      _answer.clear();
      _feedback = null;
      if (_q < _prompts.length - 1) {
        _q++;
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              backgroundColor: PsychologyPlayableScreen.surface,
              title: const Text(
                'Dr. Brook — Interview logged',
                style: TextStyle(color: PsychologyPlayableScreen.accent, fontWeight: FontWeight.w800),
              ),
              content: const Text(
                '“Structured probes captured. Design studio is open.”',
                style: TextStyle(color: Colors.white, height: 1.45),
              ),
              actions: <Widget>[
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: PsychologyPlayableScreen.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PsychologyPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: PsychologyPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: Text(
          'Interview ${_q + 1}/${_prompts.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PsychologyPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _prompts[_q].$1,
              style: const TextStyle(color: Colors.white, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answer,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: _prompts[_q].$2,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: PsychologyPlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: PsychologyPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _q < _prompts.length - 1 ? 'NEXT PROBE' : 'END INTERVIEW',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PsychLab2Screen extends StatefulWidget {
  const _PsychLab2Screen();

  @override
  State<_PsychLab2Screen> createState() => _PsychLab2ScreenState();
}

class _PsychLab2ScreenState extends State<_PsychLab2Screen> {
  final TextEditingController _hypothesis = TextEditingController();
  String? _iv;
  String? _dv;
  String? _control;
  final Set<String> _procedure = <String>{};
  bool _ran = false;
  String? _summary;
  String? _feedback;

  @override
  void dispose() {
    _hypothesis.dispose();
    super.dispose();
  }

  void _run() {
    final String h = _hypothesis.text.toLowerCase();
    if (h.length < 15 || _iv == null || _dv == null || _control == null || _procedure.length < 3) {
      setState(() => _feedback = 'Complete hypothesis, IV, DV, control, and procedure steps.');
      return;
    }
    setState(() {
      _ran = true;
      _feedback = null;
      _summary =
          'n=24 · ${_iv!} vs control\n'
          'DV: ${_dv!} mean Δ = +0.42 SD\n'
          'Control held: ${_control!}\n'
          'Interpretation: effect in predicted direction; check power next.';
    });
  }

  void _submit() {
    if (!_ran || _summary == null) {
      setState(() => _feedback = 'Run the experiment to see the data summary.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: PsychologyPlayableScreen.surface,
          title: const Text(
            'Dr. Brook — Design accepted',
            style: TextStyle(color: PsychologyPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“You defined the pieces and faced the data. That’s the job.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: PsychologyPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PsychologyPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: PsychologyPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Experiment design', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          TextField(
            controller: _hypothesis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Hypothesis',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: PsychologyPlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Independent variable', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('noise', 'Background noise level'),
            ('sleep', 'Prior-night sleep duration'),
            ('caffeine', 'Caffeine dose'),
          ].map(((String, String) o) {
            final bool on = _iv == o.$1;
            return ListTile(
              tileColor: PsychologyPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: PsychologyPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _iv = o.$1),
            );
          }),
          const Text('Dependent variable', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('rt', 'Reaction time'),
            ('accuracy', 'Task accuracy'),
            ('stress', 'Self-reported stress'),
          ].map(((String, String) o) {
            final bool on = _dv == o.$1;
            return ListTile(
              tileColor: PsychologyPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: PsychologyPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _dv = o.$1),
            );
          }),
          const Text('Control', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('quiet', 'Quiet room / no noise'),
            ('placebo', 'Placebo / matched routine'),
            ('baseline', 'Baseline session first'),
          ].map(((String, String) o) {
            final bool on = _control == o.$1;
            return ListTile(
              tileColor: PsychologyPlayableScreen.surface,
              leading: Icon(on ? Icons.radio_button_checked : Icons.radio_button_off, color: PsychologyPlayableScreen.accent),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _control = o.$1),
            );
          }),
          const Text('Procedure', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('consent', 'Consent & demos'),
            ('randomize', 'Randomize condition order'),
            ('measure', 'Measure DV'),
            ('debrief', 'Debrief'),
          ].map(((String, String) o) {
            final bool on = _procedure.contains(o.$1);
            return CheckboxListTile(
              value: on,
              activeColor: PsychologyPlayableScreen.accent,
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onChanged: (bool? v) {
                setState(() {
                  if (v == true) {
                    _procedure.add(o.$1);
                  } else {
                    _procedure.remove(o.$1);
                  }
                });
              },
            );
          }),
          OutlinedButton(
            onPressed: _run,
            style: OutlinedButton.styleFrom(foregroundColor: PsychologyPlayableScreen.accent),
            child: const Text('RUN EXPERIMENT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_summary != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PsychologyPlayableScreen.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_summary!, style: const TextStyle(color: Colors.white, height: 1.45)),
            ),
          ],
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: PsychologyPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SUBMIT TO BROOK', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
