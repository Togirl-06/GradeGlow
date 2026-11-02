import 'package:flutter/material.dart';

import '../shared/playable_cinematic.dart';
import 'law_case_data.dart';

/// Conference-room client interview — portrait, transcript, fact radar.
class LawInterviewScreen extends StatefulWidget {
  const LawInterviewScreen({super.key});

  @override
  State<LawInterviewScreen> createState() => _LawInterviewScreenState();
}

class _LawInterviewScreenState extends State<LawInterviewScreen> {
  static const Color _accent = Color(0xFFD4A574);
  static const Color _bg = Color(0xFF0C0A08);
  static const Color _surface = Color(0xFF1A1510);

  final LawClientInterviewEngine _engine = LawClientInterviewEngine();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _wrappingUp = false;

  final TextEditingController _facts = TextEditingController();
  final TextEditingController _timeline = TextEditingController();
  final TextEditingController _people = TextEditingController();
  final TextEditingController _issues = TextEditingController();
  final TextEditingController _missing = TextEditingController();

  @override
  void initState() {
    super.initState();
    _engine.start();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _facts.dispose();
    _timeline.dispose();
    _people.dispose();
    _issues.dispose();
    _missing.dispose();
    super.dispose();
  }

  void _ask() {
    final String q = _input.text;
    if (q.trim().isEmpty) return;
    _engine.ask(q);
    _input.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _askChip(String q) {
    _input.text = q;
    _ask();
  }

  Future<void> _submitIntake() async {
    final int score = _engine.scoreIntake(
      factsText: _facts.text,
      timelineText: _timeline.text,
      peopleText: _people.text,
      issuesText: _issues.text,
      missingText: _missing.text,
    );
    final String review = _engine.mayaReview(score);
    await showPlayableCinematic(
      context: context,
      accent: _accent,
      bg: _bg,
      surface: _surface,
      eyebrow: 'Maya Chen · review',
      title: 'Intake score\n$score / 100',
      body:
          '$review\n\nCritical facts unlocked: '
          '${_engine.criticalRevealed}/${_engine.criticalTotal}',
      cta: 'CONTINUE TO CASE FILE',
      glyph: '⚖️',
    );
    if (mounted) Navigator.pop(context, score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PlayableSceneBackdrop(
            accent: _accent,
            bg: _bg,
            surface: _surface,
            roomId: 'conference',
          ),
          SafeArea(
            child: _wrappingUp ? _buildIntake() : _buildInterview(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterview() {
    return Column(
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
                      'CONFERENCE ROOM',
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Client interview',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              PlayableLiveBadge(accent: _accent, label: 'RECORDING'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        _accent.withValues(alpha: 0.35),
                        _surface,
                      ],
                    ),
                    border: Border.all(color: _accent.withValues(alpha: 0.5)),
                  ),
                  child: const Text('😟', style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Jordan Hale',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Nervous · holding back details until you ask well',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FactRadar(
                        accent: _accent,
                        revealed: _engine.revealedFactIds,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            itemCount: _engine.transcript.length,
            itemBuilder: (BuildContext context, int i) {
              final LawChatLine line = _engine.transcript[i];
              final bool mine = line.fromStudent;
              return Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: mine
                        ? _accent.withValues(alpha: 0.16)
                        : Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: mine
                          ? _accent.withValues(alpha: 0.4)
                          : Colors.white10,
                    ),
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
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: <String>[
              'What happened?',
              'When did this happen?',
              'Where exactly?',
              'Were you injured?',
              'Any witnesses?',
              'Did they warn you?',
            ].map((String q) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(q, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _askChip(q),
                  backgroundColor: _surface,
                  labelStyle: const TextStyle(color: Colors.white70),
                  side: BorderSide(color: _accent.withValues(alpha: 0.35)),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _input,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _ask(),
                  decoration: InputDecoration(
                    hintText: 'Ask your own question…',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _accent.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _accent.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _ask,
                style: IconButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton(
            onPressed: () => setState(() => _wrappingUp = true),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: const BorderSide(color: _accent),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'END INTERVIEW — WRITE INTAKE',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntake() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        const Text(
          'CASE INTAKE SHEET',
          style: TextStyle(
            color: _accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This is the work product Maya grades — not a quiz answer.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 14),
        _field('Facts', _facts),
        _field('Timeline', _timeline),
        _field('People involved', _people),
        _field('Possible legal issues', _issues),
        _field('Missing information', _missing),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _submitIntake,
          style: FilledButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text(
            'SUBMIT TO MAYA',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _wrappingUp = false),
          child: const Text('Back to interview'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        minLines: 2,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _accent),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accent.withValues(alpha: 0.25)),
          ),
        ),
      ),
    );
  }
}

class _FactRadar extends StatelessWidget {
  const _FactRadar({required this.accent, required this.revealed});

  final Color accent;
  final Set<String> revealed;

  @override
  Widget build(BuildContext context) {
    final List<LawFact> facts = LawClientInterviewEngine.facts;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: facts.map((LawFact f) {
        final bool on = revealed.contains(f.id);
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? accent : Colors.white12,
            border: Border.all(
              color: on ? accent : Colors.white24,
            ),
          ),
        );
      }).toList(),
    );
  }
}
