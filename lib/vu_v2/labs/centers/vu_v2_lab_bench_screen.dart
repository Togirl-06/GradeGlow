import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../vu_v2_lab_models.dart';
import '../vu_v2_lab_simulations.dart';
import 'vu_v2_lab_game.dart';
import 'vu_v2_lab_mentor_engine.dart';
import 'vu_v2_lab_progress_store.dart';
import 'vu_v2_school_lab_identity.dart';

/// Playable lab bench: quests, score, combos, stars, scored debrief.
class VuV2LabBenchScreen extends StatefulWidget {
  const VuV2LabBenchScreen({
    super.key,
    required this.school,
    required this.experiment,
    required this.identity,
    required this.progress,
  });

  final VuV2LabSchoolDef school;
  final VuV2LabExperiment experiment;
  final VuV2SchoolLabIdentity identity;
  final VuV2LabProgressStore progress;

  @override
  State<VuV2LabBenchScreen> createState() => _VuV2LabBenchScreenState();
}

class _VuV2LabBenchScreenState extends State<VuV2LabBenchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _notes;
  late final TextEditingController _ask;
  late final AnimationController _scorePulse;
  final List<String> _log = <String>[];
  final List<String> _consoleEvents = <String>[];
  int _resetToken = 0;
  double _progress = 0.12;
  String _console = 'Run the apparatus. Log what changes.';
  int? _quizPick;
  bool _quizDone = false;
  int _interactions = 0;
  int _runScore = 0;
  int _combo = 0;
  int _comboPeak = 0;
  String _floatScore = '';
  DateTime? _started;

  VuV2LabExperiment get exp => widget.experiment;
  Color get accent => widget.identity.accent;
  String get _mission => VuV2LabGame.missionFor(exp);

  @override
  void initState() {
    super.initState();
    _started = DateTime.now();
    _scorePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final String saved = widget.progress.lastNotesByStation[exp.id] ?? '';
    _notes = TextEditingController(
      text: saved.isNotEmpty ? saved : exp.notesSeed,
    );
    _ask = TextEditingController();
    _log.add(exp.professorIntro);
    _log.add('GAME ON: $_mission');
    _log.add(
      'Score points on good apparatus moves. Combos multiply XP on clear. '
      'Stars come from your rubric.',
    );
  }

  @override
  void dispose() {
    _notes.dispose();
    _ask.dispose();
    _scorePulse.dispose();
    super.dispose();
  }

  void _notify(String message, {double? progressBump}) {
    final bool strong = (progressBump ?? 0) >= 0.1;
    final int base = strong ? 40 : 15;
    final int gain = base + (_combo * 8);
    setState(() {
      _console = message;
      _consoleEvents.add(message);
      _interactions++;
      if (strong) {
        _combo = (_combo + 1).clamp(0, 9);
        _comboPeak = _combo > _comboPeak ? _combo : _comboPeak;
      } else {
        _combo = 0;
      }
      _runScore += gain;
      _floatScore = '+$gain';
      _log.add(
        'Apparatus: $message  (+$gain${_combo > 1 ? ' · COMBO x$_combo' : ''})',
      );
      if (progressBump != null) {
        _progress = (_progress + progressBump).clamp(0.0, 1.0);
      }
    });
    _scorePulse.forward(from: 0);
  }

  bool get _quizCorrect =>
      _quizDone &&
      exp.quiz.isNotEmpty &&
      _quizPick == exp.quiz.first.correctIndex;

  Future<void> _submitNotebook() async {
    final String notes = _notes.text.trim();
    if (_interactions < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Need 2+ apparatus moves before clear — keep playing the bench.',
          ),
        ),
      );
      return;
    }
    if (notes.length < 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notebook needs 80+ characters with real observations (numbers help).',
          ),
        ),
      );
      return;
    }
    if (notes == exp.notesSeed.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rewrite the seed — your run log must be original to bank XP.',
          ),
        ),
      );
      return;
    }
    if (!_quizDone && exp.quiz.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clear the competency boss check first.'),
        ),
      );
      return;
    }

    final VuV2LabDebrief debrief = VuV2LabMentorEngine.score(
      notes: notes,
      notesSeed: exp.notesSeed,
      exp: exp,
      identity: widget.identity,
      interactionCount: _interactions,
      quizCorrect: _quizCorrect,
      quizDone: _quizDone,
      consoleLog: _consoleEvents,
    );

    if (debrief.total < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stage failed (${debrief.total}/16). '
            'Add causal notes + another trial.',
          ),
        ),
      );
      setState(() {
        _combo = 0;
        _log.add('Mentor: ${debrief.headline}');
        _log.add(debrief.paragraph);
      });
      return;
    }

    final int stars = VuV2LabGame.starsForRubric(debrief.total);
    final int comboBonus = _comboPeak * 12;
    final int timeBonus = () {
      final DateTime start = _started ?? DateTime.now();
      final int secs = DateTime.now().difference(start).inSeconds;
      if (secs < 90) return 30;
      if (secs < 180) return 15;
      return 0;
    }();
    final int totalXp = debrief.xpAward + comboBonus + timeBonus + (stars * 8);

    final List<String> unlocked = await widget.progress.completeStation(
      exp.id,
      notes: notes,
      xpGain: totalXp,
      rubricTotal: debrief.total,
      runScore: _runScore,
      comboPeak: _comboPeak,
      school: widget.school,
    );
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: VuV2Colors.navyElevated,
          title: Text(
            stars >= 3 ? 'PERFECT CLEAR!' : 'STAGE CLEAR!',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                VuV2LabStars(count: stars, size: 28),
                const SizedBox(height: 8),
                Text(
                  debrief.headline,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Run score $_runScore · Combo peak x$_comboPeak · '
                  'XP +$totalXp (base ${debrief.xpAward}'
                  '${comboBonus > 0 ? ' + combo $comboBonus' : ''}'
                  '${timeBonus > 0 ? ' + speed $timeBonus' : ''}'
                  '${stars > 0 ? ' + stars ${stars * 8}' : ''})',
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _rubricRow('Observation', debrief.observation),
                _rubricRow('Causality', debrief.causality),
                _rubricRow('Judgment', debrief.judgment),
                _rubricRow('Protocol', debrief.protocol),
                if (unlocked.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'BADGES UNLOCKED',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: unlocked
                        .map(
                          (String id) => Chip(
                            label: Text(VuV2LabGame.badgeLabel(id)),
                            backgroundColor: accent.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  debrief.paragraph,
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: const Text('Back to floor map'),
            ),
          ],
        );
      },
    );
  }

  Widget _rubricRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: VuV2Colors.mute,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 4,
                minHeight: 8,
                color: accent,
                backgroundColor: VuV2Colors.stroke,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score/4',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _askMentor() {
    final String q = _ask.text.trim();
    if (q.isEmpty) {
      return;
    }
    final String reply = VuV2LabMentorEngine.reply(
      question: q,
      notes: _notes.text,
      exp: exp,
      identity: widget.identity,
      consoleLog: _consoleEvents,
      interactionCount: _interactions,
    );
    setState(() {
      _log.add('You: $q');
      _log.add('Mentor: $reply');
      _ask.clear();
      _progress = (_progress + 0.04).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 960;
    final int best = widget.progress.highScoreByStation[exp.id] ?? 0;
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: Text('${exp.emoji}  ${exp.title}'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Text(
                'SCORE $_runScore',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (_combo > 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'COMBO x$_combo',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _resetToken++;
                _progress = 0.12;
                _quizPick = null;
                _quizDone = false;
                _interactions = 0;
                _runScore = 0;
                _combo = 0;
                _comboPeak = 0;
                _floatScore = '';
                _consoleEvents.clear();
                _started = DateTime.now();
                _console = 'Bench reset. Fresh run.';
                _log.add('RUN RESET — score wiped for this attempt.');
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            color: accent,
            backgroundColor: VuV2Colors.stroke,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(flex: 3, child: _benchPane(best)),
                          Expanded(flex: 2, child: _sidePane()),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: <Widget>[
                          _benchPane(best),
                          const SizedBox(height: 12),
                          _sidePane(),
                        ],
                      ),
                if (_floatScore.isNotEmpty)
                  Positioned(
                    top: 24,
                    right: 24,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.25, end: 1).animate(
                        CurvedAnimation(
                          parent: _scorePulse,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: Text(
                        _floatScore,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          shadows: <Shadow>[
                            Shadow(
                              color: accent.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benchPane(int best) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        VuV2LabGlass(
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'LIVE QUEST',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if (best > 0)
                    Text(
                      'BEST $best',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _mission,
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exp.blurb,
                style: TextStyle(color: VuV2Colors.mute, height: 1.35),
              ),
              const SizedBox(height: 8),
              Text(
                'Clear rules: ≥2 moves · original notes · competency · rubric ≥6/16 → stars',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VuV2LabGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'PLAYABLE APPARATUS',
                style: TextStyle(
                  color: VuV2Colors.mute,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              VuV2LabSimulationArea(
                kind: exp.simulationKind,
                resetToken: _resetToken,
                onNotify: _notify,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: VuV2Colors.stroke),
                ),
                child: Text(
                  _console,
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VuV2LabGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Run log (graded)',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Write like a speedrun note: change → result → because… Numbers = more stars.',
                style: TextStyle(
                  color: VuV2Colors.mute,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              TextField(
                controller: _notes,
                maxLines: 8,
                style: TextStyle(color: VuV2Colors.ink, height: 1.4),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Observation log…',
                  hintStyle: TextStyle(color: VuV2Colors.mute),
                ),
              ),
              FilledButton.icon(
                onPressed: _submitNotebook,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.emoji_events_outlined),
                label: const Text('Clear stage · bank XP & stars'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sidePane() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        VuV2LabGlass(
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Coach feed',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _log[i],
                        style: TextStyle(
                          color: VuV2Colors.mute,
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _ask,
                      style: TextStyle(color: VuV2Colors.ink),
                      decoration: InputDecoration(
                        hintText: 'Ask coach / hint…',
                        hintStyle: TextStyle(color: VuV2Colors.mute),
                      ),
                      onSubmitted: (_) => _askMentor(),
                    ),
                  ),
                  IconButton(
                    onPressed: _askMentor,
                    icon: Icon(Icons.send, color: accent),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (exp.quiz.isNotEmpty)
          VuV2LabGlass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Boss check',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exp.quiz.first.prompt,
                  style: TextStyle(color: VuV2Colors.mute, height: 1.35),
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < exp.quiz.first.choices.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VuV2LabGlass(
                      accent: _quizPick == i ? accent : null,
                      onTap: () {
                        setState(() {
                          _quizPick = i;
                          _quizDone = true;
                          final bool ok = i == exp.quiz.first.correctIndex;
                          _runScore += ok ? 80 : 20;
                          _floatScore = ok ? '+80' : '+20';
                          _progress = (_progress + 0.15).clamp(0.0, 1.0);
                          _log.add(
                            ok
                                ? 'Boss check CLEARED. ${exp.quiz.first.explain}'
                                : 'Boss check miss — ${exp.quiz.first.explain}',
                          );
                        });
                        _scorePulse.forward(from: 0);
                      },
                      child: Text(
                        exp.quiz.first.choices[i],
                        style: TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        VuV2LabGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How to play',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < exp.instructions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${i + 1}. ${exp.instructions[i]}',
                    style: TextStyle(color: VuV2Colors.mute, height: 1.35),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
