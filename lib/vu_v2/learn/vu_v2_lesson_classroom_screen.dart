import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vu_v2_cs_try_it.dart';
import '../data/vu_v2_cs_w3s_notes.dart';
import '../data/vu_v2_interactive_notes.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_rich_text.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_cs_try_it_panel.dart';

/// Interactive story-mode notes — light slides so the emulator stays alive.
class VuV2LessonClassroomScreen extends StatefulWidget {
  const VuV2LessonClassroomScreen({
    super.key,
    required this.session,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.courseTitle,
    required this.topicTitle,
    this.topicId,
    this.topicSubtitle,
    this.notesOnly = false,
  });

  final VuV2Session session;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final String courseTitle;
  final String topicTitle;
  final String? topicId;
  final String? topicSubtitle;

  /// When true, finishing the notes beats pops `true` (no embedded quiz lab).
  final bool notesOnly;

  @override
  State<VuV2LessonClassroomScreen> createState() =>
      _VuV2LessonClassroomScreenState();
}

class _VuV2LessonClassroomScreenState extends State<VuV2LessonClassroomScreen> {
  VuV2TopicPackage? _pack;
  List<VuV2InteractiveBeat> _beats = const <VuV2InteractiveBeat>[];
  bool _loading = true;
  String? _loadError;

  int _beatIndex = 0;
  int? _pulsePick;
  bool _quizPassed = false;
  bool _showLab = false;
  int _streak = 0;
  static const int _maxHearts = 3;
  int _hearts = _maxHearts;
  bool _outOfHearts = false;


  bool get _isCs =>
      widget.subjectId == 'computer_science' ||
      widget.subjectId == 'software_engineering' ||
      widget.subjectId == 'artificial_intelligence' ||
      widget.subjectId == 'cybersecurity';

  VuV2CsTryItSpec? get _csTryIt {
    if (!_isCs) return null;
    return VuV2CsTryItResolver.resolve(
      topicTitle: widget.topicTitle,
      topicId: widget.topicId,
      trackTitle: widget.trackTitle,
      courseTitle: widget.courseTitle,
    );
  }

  VuV2InteractiveBeat? get _beatOrNull {
    if (_beats.isEmpty) return null;
    final int i = _beatIndex.clamp(0, _beats.length - 1);
    return _beats[i];
  }

  double get _progress =>
      _beats.isEmpty ? 0 : (_beatIndex + 1) / _beats.length;

  @override
  void initState() {
    super.initState();
    // Build heavy content after first frame so the route can open safely.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final VuV2TopicPackage pack = VuV2TopicContent.forLesson(
        subjectId: widget.subjectId,
        facultyTitle: widget.facultyTitle,
        facultyEmoji: widget.facultyEmoji,
        trackTitle: widget.trackTitle,
        courseTitle: widget.courseTitle,
        topicTitle: widget.topicTitle,
        topicSubtitle: widget.topicSubtitle,
        interactive: true,
      );
      final List<VuV2InteractiveBeat> beats = _isCs
          ? VuV2CsW3sNotes.build(
              topicTitle: widget.topicTitle,
              courseTitle: widget.courseTitle,
              trackTitle: widget.trackTitle,
              topicId: widget.topicId,
            )
          : VuV2InteractiveNotes.build(pack);
      if (!mounted) return;
      setState(() {
        _pack = pack;
        _beats = beats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = '$e';
        _loading = false;
        _beats = <VuV2InteractiveBeat>[
          VuV2InteractiveBeat(
            kind: VuV2BeatKind.teach,
            emoji: '⚠️',
            eyebrow: '1/1',
            title: widget.topicTitle,
            body:
                'Could not load the full lesson.\n\n'
                'Continue to the quiz if available.\n\n$e',
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLab) return _finishScaffold();

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topicTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(color: VuV2Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Loading your live lesson…',
                style: TextStyle(color: VuV2Colors.mute),
              ),
            ],
          ),
        ),
      );
    }

    final VuV2InteractiveBeat? beat = _beatOrNull;
    if (beat == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topicTitle)),
        body: VuV2EmptyState(
          title: 'No lesson beats',
          subtitle: _loadError ?? 'Try another topic.',
          actionLabel: 'Close',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicTitle),
        actions: <Widget>[
          if (_isCs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: _HeartsRow(hearts: _hearts, max: _maxHearts)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '🔥 $_streak',
                style: TextStyle(
                  color: VuV2Colors.orange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _outOfHearts
          ? _outOfHeartsBody()
          : Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_beatIndex + 1}/${_beats.length}',
                    style: const TextStyle(
                      color: VuV2Colors.mute,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                VuV2ProgressBar(value: _progress, height: 8),
              ],
            ),
          ),
          Expanded(
            child: _BeatCard(
              key: ValueKey<int>(_beatIndex),
              beat: beat,
              pulsePick: _pulsePick,
              allowRetry: _isCs,
              onPulse: (int i) {
                if (i < 0 || i >= beat.pulseChoices.length) return;
                final bool alreadyCorrect = _pulsePick != null &&
                    beat.pulseChoices[_pulsePick!].correct;
                if (alreadyCorrect) return;
                try {
                  HapticFeedback.selectionClick();
                } catch (_) {}
                final bool ok = beat.pulseChoices[i].correct;
                setState(() {
                  _pulsePick = i;
                  if (ok) {
                    _streak += 2;
                  } else if (_isCs) {
                    _hearts = (_hearts - 1).clamp(0, _maxHearts);
                    if (_hearts <= 0) _outOfHearts = true;
                  } else {
                    _streak += 0;
                  }
                });
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: <Widget>[
                  if (_beatIndex > 0)
                    IconButton.filledTonal(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  if (_beatIndex > 0) const SizedBox(width: 8),
                  Expanded(
                    child: VuV2PrimaryButton(
                      label: _primaryLabel(beat),
                      icon: _beatIndex >= _beats.length - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _canAdvance(beat) ? _advance : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outOfHeartsBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: VuV2Surface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('💔', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 12),
              const Text(
                'Out of hearts',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No worries — refill and try the tricky questions again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: VuV2Colors.mute, height: 1.4),
              ),
              const SizedBox(height: 16),
              VuV2PrimaryButton(
                label: 'Refill hearts ❤️',
                icon: Icons.favorite_rounded,
                onPressed: () {
                  setState(() {
                    _hearts = _maxHearts;
                    _outOfHearts = false;
                    _pulsePick = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _hearts = _maxHearts;
                  _outOfHearts = false;
                  _beatIndex = 0;
                  _pulsePick = null;
                  _streak = 0;
                }),
                child: const Text('Restart lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _primaryLabel(VuV2InteractiveBeat beat) {
    if (beat.kind == VuV2BeatKind.pulse) {
      if (_pulsePick == null) return 'Pick an answer first';
      if (_isCs && !beat.pulseChoices[_pulsePick!].correct) {
        return 'Try again';
      }
    }
    if (_beatIndex >= _beats.length - 1) {
      return widget.notesOnly ? 'Finish notes' : 'Finish → quiz';
    }
    return 'Next';
  }

  bool _canAdvance(VuV2InteractiveBeat beat) {
    if (beat.kind == VuV2BeatKind.pulse) {
      if (_pulsePick == null) return false;
      if (_isCs) return beat.pulseChoices[_pulsePick!].correct;
      return true;
    }
    return true;
  }

  void _back() {
    if (_beatIndex <= 0) return;
    setState(() {
      _beatIndex--;
      _pulsePick = null;
    });
  }

  void _advance() {
    final VuV2InteractiveBeat? beat = _beatOrNull;
    if (beat == null) return;

    if (_beatIndex >= _beats.length - 1) {
      if (widget.notesOnly) {
        Navigator.pop(context, true);
        return;
      }
      setState(() => _showLab = true);
      return;
    }

    setState(() {
      _beatIndex++;
      _pulsePick = null;
      _streak++;
    });
  }

  Widget _finishScaffold() {
    final VuV2TopicPackage? pack = _pack;
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VuV2Colors.orange,
        foregroundColor: Colors.white,
        onPressed: pack == null ? null : _openQuiz,
        icon: Icon(Icons.quiz_outlined),
        label: Text(_quizPassed ? 'Retake quiz' : 'Topic quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: <Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOU MADE IT',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCs
                      ? 'W3Schools-style lesson done · streak $_streak'
                      : 'Interactive notes done · streak $_streak',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCs
                      ? 'Nice work on ${widget.topicTitle}. Try the code yourself, then take the quiz.'
                      : 'Nice work on ${widget.topicTitle}. Take the quiz when you\'re ready.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _showLab = false;
                          _beatIndex = 0;
                          _pulsePick = null;
                          _hearts = _maxHearts;
                          _outOfHearts = false;
                        }),
                        child: Text('Replay'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VuV2PrimaryButton(
                        label: _quizPassed ? 'Quiz ✓' : 'Take quiz',
                        onPressed: pack == null ? null : _openQuiz,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_csTryIt != null) ...<Widget>[
            const SizedBox(height: 18),
            const VuV2SectionTitle('Try It Yourself'),
            const SizedBox(height: 8),
            VuV2CsTryItPanel(spec: _csTryIt!),
          ],
          if (_quizPassed) ...<Widget>[
            const SizedBox(height: 16),
            VuV2PrimaryButton(
              label: 'Mark topic complete',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openQuiz() async {
    final VuV2TopicPackage? pack = _pack;
    if (pack == null) return;
    final bool? passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VuV2AssessmentScreen(
          title: widget.topicTitle,
          subtitle: '${widget.courseTitle} · end-of-topic quiz · pass ≥70%',
          questions: pack.topicQuiz,
          passPercent: 70,
        ),
      ),
    );
    if (!mounted) return;
    if (passed == true) {
      setState(() {
        _quizPassed = true;
        _showLab = true;
      });
      await widget.session.setContinue(
        title: widget.topicTitle,
        subtitle: '${widget.facultyTitle} · quiz passed',
        progress: 0.55,
      );
    }
  }
}

class _BeatCard extends StatelessWidget {
  const _BeatCard({
    super.key,
    required this.beat,
    required this.pulsePick,
    required this.onPulse,
    this.allowRetry = false,
  });

  final VuV2InteractiveBeat beat;
  final int? pulsePick;
  final ValueChanged<int> onPulse;
  final bool allowRetry;

  Color get _accent {
    return switch (beat.kind) {
      VuV2BeatKind.teach => const Color(0xFF38BDF8),
      VuV2BeatKind.pulse => const Color(0xFFA78BFA),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: VuV2Colors.navyElevated,
            borderRadius: BorderRadius.circular(VuV2Radii.xl),
            border: Border.all(color: _accent.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(beat.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      beat.eyebrow,
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                beat.title,
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              VuV2RichTeachBody(text: beat.body, accent: _accent),
              if (beat.kind == VuV2BeatKind.teach &&
                  beat.moreBody != null &&
                  beat.moreBody!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VuV2Colors.yellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(VuV2Radii.md),
                    border: Border.all(
                      color: VuV2Colors.yellow.withValues(alpha: 0.3),
                    ),
                  ),
                  child: VuV2RichTeachBody(
                    text: beat.moreBody!,
                    accent: VuV2Colors.yellow,
                  ),
                ),
              ],
              if (beat.kind == VuV2BeatKind.pulse) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  beat.pulsePrompt ?? '',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ...List<Widget>.generate(beat.pulseChoices.length, (int i) {
                  final VuV2PulseChoice c = beat.pulseChoices[i];
                  final bool selected = pulsePick == i;
                  final bool lockedCorrect = pulsePick != null &&
                      beat.pulseChoices[pulsePick!].correct;
                  Color border = VuV2Colors.stroke;
                  if (pulsePick != null) {
                    if (c.correct && (selected || lockedCorrect)) {
                      border = VuV2Colors.success;
                    }
                    if (selected && !c.correct) border = VuV2Colors.danger;
                  } else if (selected) {
                    border = VuV2Colors.orange;
                  }
                  final bool canTap = !lockedCorrect &&
                      (pulsePick == null || allowRetry);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? _accent.withValues(alpha: 0.14)
                          : Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(VuV2Radii.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(VuV2Radii.md),
                        onTap: canTap ? () => onPulse(i) : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(VuV2Radii.md),
                            border: Border.all(color: border),
                          ),
                          child: Text(
                            c.label,
                            style: const TextStyle(
                              color: VuV2Colors.ink,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (pulsePick != null &&
                    pulsePick! >= 0 &&
                    pulsePick! < beat.pulseChoices.length) ...<Widget>[
                  const SizedBox(height: 6),
                  _Bubble(text: beat.pulseChoices[pulsePick!].reaction),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeartsRow extends StatelessWidget {
  const _HeartsRow({required this.hearts, required this.max});

  final int hearts;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(max, (int i) {
        final bool on = i < hearts;
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: on ? const Color(0xFFF43F5E) : VuV2Colors.mute,
          ),
        );
      }),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(VuV2Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🎓', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: VuV2Colors.ink,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
