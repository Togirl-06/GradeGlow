import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/biology_degree_catalog.dart';
import '../../models/biology_degree.dart';
import '../../models/virtual_lecture.dart';
import '../../services/lecture_voice_controller.dart';
import '../../services/biology_progress_service.dart';
import '../../services/openai_service.dart';
import '../../services/virtual_lecture_service.dart';
import '../../theme/biology_degree_theme.dart';
import '../../widgets/virtual_lecture/lecture_ask_overlay.dart';
import '../../widgets/virtual_lecture/lecture_check_overlay.dart';
import '../../widgets/virtual_lecture/lecture_completion_report.dart';
import '../../widgets/virtual_lecture/lecture_controls_bar.dart';
import '../../widgets/virtual_lecture/lecture_live_header.dart';
import '../../widgets/virtual_lecture/lecture_phase_roadmap.dart';
import '../../widgets/virtual_lecture/lecture_sheets.dart';
import '../../widgets/virtual_lecture/lecture_stage.dart';
import 'biology_practice_screen.dart';

/// Interactive AI biology professor — whiteboard-first medical & research lecture.
class BiologyLectureScreen extends StatefulWidget {
  const BiologyLectureScreen({
    super.key,
    required this.path,
    required this.openAi,
    required this.progress,
  });

  final BiologyLessonPath path;
  final OpenAiService openAi;
  final BiologyProgressService progress;

  @override
  State<BiologyLectureScreen> createState() => _BiologyLectureScreenState();
}

class _BiologyLectureScreenState extends State<BiologyLectureScreen> {
  static const List<double> _speeds = <double>[0.75, 1, 1.25, 1.5, 2];

  VirtualLectureScript? _script;
  LectureMode? _mode;
  bool _finished = false;
  int _segmentIndex = 0;
  int _beatIndex = 0;
  bool _playing = false;
  bool _speaking = false;
  double _speed = 1;
  final List<String> _transcript = <String>[];
  LectureAnalytics _analytics = const LectureAnalytics();
  Timer? _segmentTimer;
  Timer? _studyClock;
  int _sessionSeconds = 0;
  bool _delivering = false;
  int _deliveryEpoch = 0;
  String? _loadError;

  VirtualLectureService? _lectureService;
  final LectureVoiceController _voice = LectureVoiceController();
  bool _startingMode = false;

  // In-stage overlays
  LectureKnowledgeCheck? _activeCheck;
  bool _askingProfessor = false;
  LectureAskMode _askMode = LectureAskMode.ask;
  bool _askBusy = false;
  String? _askAnswer;
  String? _pendingQuestion;
  bool _alive = true;
  bool _immersive = false;

  @override
  void initState() {
    super.initState();
    _lectureService = VirtualLectureService(widget.openAi);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final LectureAnalytics saved =
          await _lectureService!.loadAnalytics(widget.path.lesson.id);
      if (mounted) setState(() => _analytics = saved);
    } catch (e) {
      debugPrint('Lecture analytics load failed: $e');
    }
    if (mounted) {
      await _startMode(LectureMode.comprehensive);
    }
  }

  @override
  void dispose() {
    _alive = false;
    _segmentTimer?.cancel();
    _segmentTimer = null;
    _studyClock?.cancel();
    _studyClock = null;
    _delivering = false;
    _playing = false;
    _speaking = false;
    unawaited(_voice.stop());
    _voice.dispose();
    super.dispose();
  }

  String get _speedLabel {
    final double rounded = (_speed * 100).round() / 100;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()}x';
    }
    return '${rounded}x';
  }

  double get _progress {
    if (_script == null || _script!.segments.isEmpty) return 0;
    return ((_segmentIndex + 1) / _script!.segments.length * 100).clamp(0, 100);
  }

  LectureSegment? get _segment =>
      _script != null && _segmentIndex < _script!.segments.length
          ? _script!.segments[_segmentIndex]
          : null;

  LectureSegment? get _displaySegment {
    final LectureSegment? raw = _segment;
    if (raw == null) return null;
    if (!raw.isInteractive) return raw;
    return raw.viewAtBeat(_beatIndex);
  }

  Future<void> _startMode(LectureMode mode) async {
    if (_startingMode || !mounted) return;
    _startingMode = true;
    if (mounted) setState(() {});

    await Future<void>.delayed(Duration.zero);
    if (!mounted) {
      _startingMode = false;
      return;
    }

    try {
      final double mastery =
          widget.progress.lessonMastery(widget.path.lesson.id) / 100.0;
      final VirtualLectureScript script = await _lectureService!.loadBiologyScript(
        path: widget.path,
        mode: mode,
        masteryHint: mastery,
        weakAreas: _analytics.weakAreas,
      );

      if (!mounted) return;

      if (script.segments.isEmpty) {
        setState(() {
          _mode = mode;
          _script = null;
          _loadError = 'Could not load this lecture.';
        });
        return;
      }

      setState(() {
        _mode = mode;
        _script = script;
        _loadError = null;
        _segmentIndex = 0;
        _beatIndex = 0;
        _transcript.clear();
        _analytics = _analytics.copyWith(mode: mode, lessonId: widget.path.lesson.id);
      });
      _play();
    } catch (e, stack) {
      debugPrint('Lecture mode start failed: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _mode = mode;
        _script = null;
        _loadError = 'Could not start this lecture. Please go back and try again.';
      });
    } finally {
      _startingMode = false;
    }
  }

  void _togglePlay() {
    if (_segment == null || _activeCheck != null || _askingProfessor) return;
    if (_playing) {
      _pause();
    } else {
      _play();
    }
  }

  void _changeSpeed(double speed) {
    if (!mounted) return;
    setState(() => _speed = speed);
    unawaited(_voice.setSpeed(speed));
  }

  void _play() {
    if (_segment == null || _activeCheck != null) return;
    // Soft-paused mid-segment: resume the same utterance immediately.
    if (_delivering) {
      unawaited(_voice.resume());
      setState(() {
        _playing = true;
        _speaking = true;
      });
      _ensureStudyClock();
      return;
    }
    if (_askingProfessor) return;
    setState(() {
      _playing = true;
      _speaking = true;
    });
    _ensureStudyClock();
    final String speech = _displaySegment?.professorSpeech ?? _segment!.professorSpeech;
    if (!_transcript.contains(speech)) {
      _transcript.add(speech);
    }
    unawaited(_deliverSegment());
  }

  void _ensureStudyClock() {
    _studyClock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_alive || !mounted) return;
      if (_playing) {
        setState(() => _sessionSeconds += 1);
      }
    });
  }

  Future<void> _deliverSegment() async {
    if (_delivering || !_playing || _segment == null) return;
    _delivering = true;
    final int epoch = _deliveryEpoch;
    final LectureSegment raw = _segment!;
    final LectureSegment active = _displaySegment ?? raw;
    final String speech = active.professorSpeech;

    while (_alive && mounted && epoch == _deliveryEpoch) {
      if (!_playing) {
        await Future<void>.delayed(const Duration(milliseconds: 32));
        continue;
      }

      try {
        await _voice.speak(speech, _speed);
      } catch (e) {
        debugPrint('Lecture delivery failed: $e');
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }

      if (!_alive || !mounted || epoch != _deliveryEpoch) {
        if (epoch == _deliveryEpoch) _delivering = false;
        return;
      }

      if (!_playing) {
        while (_alive &&
            mounted &&
            epoch == _deliveryEpoch &&
            !_playing) {
          await Future<void>.delayed(const Duration(milliseconds: 32));
        }
        if (!_alive || !mounted || epoch != _deliveryEpoch || !_playing) {
          if (epoch == _deliveryEpoch) _delivering = false;
          return;
        }
      }
      break;
    }

    if (!_alive || !mounted || epoch != _deliveryEpoch || !_playing) {
      if (epoch == _deliveryEpoch) _delivering = false;
      return;
    }

    setState(() => _speaking = false);

    final LectureKnowledgeCheck? check = active.knowledgeCheck;
    if (check != null) {
      _pause(hard: true);
      setState(() => _activeCheck = check);
      _delivering = false;
      return;
    }

    _delivering = false;
    _advanceBeatOrSegment(resumePlayback: true);
  }

  void _advanceBeatOrSegment({bool resumePlayback = false}) {
    final LectureSegment? raw = _segment;
    if (raw == null) return;

    if (raw.isInteractive && _beatIndex < raw.beats.length - 1) {
      setState(() => _beatIndex += 1);
      if (resumePlayback) {
        _delivering = false;
        _play();
      }
      return;
    }

    setState(() => _beatIndex = 0);
    _advanceSegment(resumePlayback: resumePlayback);
  }

  void _onCheckAnswered(bool correct, {String? tappedRegionId}) {
    setState(() {
      _activeCheck = null;
      _analytics = _analytics.copyWith(
        checksTotal: _analytics.checksTotal + 1,
        checksCorrect: _analytics.checksCorrect + (correct ? 1 : 0),
        participationCount: _analytics.participationCount + 1,
        weakAreas: correct
            ? _analytics.weakAreas
            : <String>[..._analytics.weakAreas, _segment!.phase.label],
      );
    });
    _advanceBeatOrSegment(resumePlayback: true);
  }

  /// Soft pause freezes audio in place. [hard] cancels speech (seek / ask / exit).
  void _pause({bool hard = false}) {
    _segmentTimer?.cancel();
    if (hard) {
      _deliveryEpoch++;
      unawaited(_voice.stop());
      _delivering = false;
    } else if (_delivering) {
      unawaited(_voice.pause());
    } else {
      unawaited(_voice.stop());
      _delivering = false;
    }
    if (!_alive || !mounted) return;
    setState(() {
      _playing = false;
      _speaking = false;
    });
  }

  void _restart() {
    _pause(hard: true);
    setState(() {
      _segmentIndex = 0;
      _beatIndex = 0;
      _transcript.clear();
      _activeCheck = null;
      _askingProfessor = false;
      _askAnswer = null;
    });
    _play();
  }

  void _previousSection() {
    if (_segmentIndex <= 0) return;
    _pause(hard: true);
    setState(() {
      _segmentIndex -= 1;
      _beatIndex = 0;
      _activeCheck = null;
    });
    _play();
  }

  void _nextSection() {
    if (_script == null) return;
    _pause(hard: true);
    if (_segmentIndex >= _script!.segments.length - 1) {
      unawaited(_finishLecture());
    } else {
      _advanceSegment(resumePlayback: true);
    }
  }

  /// Pause voice while scrubbing — do not regenerate TTS.
  void _onScrubStart() {
    if (!_playing) return;
    _pause(); // soft pause keeps the current utterance
  }

  /// Scrubber seek — jump only when the section changes; same section seeks voice.
  void _seekToProgress(double progress) {
    if (_script == null || _script!.segments.isEmpty) return;
    final int count = _script!.segments.length;
    final double pos = progress.clamp(0.0, 1.0) * count;
    final int target = pos.floor().clamp(0, count - 1);

    if (target == _segmentIndex) {
      final double fraction = (pos - target).clamp(0.0, 1.0);
      unawaited(_voice.seekUtterance(fraction));
      if (_delivering) {
        unawaited(_voice.resume());
        if (!_playing) {
          setState(() {
            _playing = true;
            _speaking = true;
          });
          _ensureStudyClock();
        }
      } else if (!_playing) {
        _play();
      }
      return;
    }

    _pause(hard: true);
    setState(() {
      _segmentIndex = target;
      _beatIndex = 0;
      _activeCheck = null;
      _askingProfessor = false;
      _askAnswer = null;
    });
    _play();
  }

  void _advanceSegment({bool resumePlayback = false}) {
    if (_script == null) return;
    if (_segmentIndex >= _script!.segments.length - 1) {
      unawaited(_finishLecture());
      return;
    }
    setState(() {
      _segmentIndex += 1;
      _beatIndex = 0;
    });
    if (resumePlayback) {
      _delivering = false;
      _play();
    }
  }

  Future<void> _finishLecture() async {
    _pause(hard: true);
    final int elapsed = _analytics.timeSpentSeconds + _sessionSeconds;
    final double confidence = _analytics.checksTotal == 0
        ? 0.75
        : (_analytics.checksCorrect / _analytics.checksTotal).clamp(0, 1);
    _analytics = _analytics.copyWith(
      completed: true,
      timeSpentSeconds: elapsed,
      confidenceScore: confidence,
    );
    await _lectureService!.saveAnalytics(_analytics).catchError((Object e) {
      debugPrint('Lecture analytics save failed: $e');
    });
    try {
      await widget.progress.completeActivity(
        widget.path.lesson.id,
        BioLessonActivityKind.lecture,
      );
    } catch (e) {
      debugPrint('Lecture progress update failed: $e');
    }
    if (!mounted) return;
    setState(() => _finished = true);
    await _showSummary();
    if (mounted) Navigator.of(context).pop(true);
  }

  BiologyLessonPath? get _nextLesson {
    final List<BiologyLessonPath> all = BiologyDegreeCatalog.allLessonPaths;
    final int i = all.indexWhere(
      (BiologyLessonPath p) => p.lesson.id == widget.path.lesson.id,
    );
    if (i < 0 || i >= all.length - 1) return null;
    return all[i + 1];
  }

  Future<void> _showSummary() async {
    final LectureSummary summary = _script!.summary;
    final BiologyLessonPath? next = _nextLesson;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => LectureCompletionReport(
        topicTitle: widget.path.lesson.title,
        learned: summary.learned,
        homework: summary.homeworkRecommendation,
        timeSpentSeconds: _analytics.timeSpentSeconds,
        checksCorrect: _analytics.checksCorrect,
        checksTotal: _analytics.checksTotal,
        questionsAsked: _analytics.questionsAsked,
        weakAreas: _analytics.weakAreas,
        nextLessonTitle: next?.lesson.title,
        onQuiz: () {
          Navigator.of(ctx).pop();
          unawaited(_openQuiz());
        },
        onNextLesson: next == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => BiologyLectureScreen(
                      path: next,
                      openAi: widget.openAi,
                      progress: widget.progress,
                    ),
                  ),
                );
              },
        onContinue: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _openRaiseHand() {
    _freezeLectureForInterrupt();
    if (_askingProfessor) return;
    setState(() {
      _askingProfessor = true;
      _askMode = LectureAskMode.ask;
      _askAnswer = null;
      _pendingQuestion = null;
      _askBusy = false;
      _playing = false;
      _speaking = false;
    });
  }

  void _onConfused() {
    _freezeLectureForInterrupt();
    if (_askingProfessor) return;
    setState(() {
      _askingProfessor = true;
      _askMode = LectureAskMode.confused;
      _askAnswer = null;
      _pendingQuestion = null;
      _askBusy = false;
      _playing = false;
      _speaking = false;
    });
  }

  void _freezeLectureForInterrupt() {
    _segmentTimer?.cancel();
    _deliveryEpoch++;
    _delivering = false;
    unawaited(_voice.stop());
    if (!_alive || !mounted) return;
    setState(() {
      _playing = false;
      _speaking = false;
    });
  }

  Future<void> _openQuiz() async {
    _pause(hard: true);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BiologyPracticeScreen(
          path: widget.path,
          kind: BioLessonActivityKind.practice,
        ),
      ),
    );
  }

  Future<void> _submitQuestion(String question) async {
    final String trimmed = question.trim();
    if (trimmed.isEmpty || _lectureService == null) return;
    setState(() {
      _askBusy = true;
      _pendingQuestion = trimmed;
      _askAnswer = null;
    });
    final LectureSegment? active = _displaySegment ?? _segment;
    final String slideContext = <String>[
      if (active?.whiteboard.title.trim().isNotEmpty == true)
        'Slide: ${active!.whiteboard.title}',
      if (active != null && active.whiteboard.keyPoints.isNotEmpty)
        'Key points: ${active.whiteboard.keyPoints.take(6).join('; ')}',
      if ((active?.professorSpeech ?? '').trim().isNotEmpty)
        'Professor was saying: ${active!.professorSpeech}',
    ].join('\n');

    String answer;
    try {
      answer = await _lectureService!.askBiologyProfessor(
        path: widget.path,
        currentSpeech: slideContext,
        question: _askMode == LectureAskMode.confused
            ? 'Student is confused and asked: $trimmed\n'
                'Reteach this idea more simply with a new analogy and one fresh example. '
                'Do not repeat the previous explanation word for word. '
                'End with one short check question.'
            : trimmed,
      );
    } catch (e) {
      debugPrint('Ask professor failed: $e');
      answer = '';
    }
    if (!mounted) return;
    if (answer.trim().isEmpty) {
      answer =
          'Let me clarify this biology idea more simply. '
          'Return to the core definition on the slide, then connect it to one concrete example. '
          'Ask again if a specific term or step is still unclear.';
    }
    setState(() {
      _askBusy = false;
      _askAnswer = answer.trim();
      _analytics = _analytics.copyWith(questionsAsked: _analytics.questionsAsked + 1);
      _transcript.add('You: $trimmed');
      _transcript.add('Professor: ${answer.trim()}');
    });
    unawaited(_voice.speak(answer.trim(), _speed));
  }


  void _dismissAsk() {
    unawaited(_voice.stop());
    setState(() {
      _askingProfessor = false;
      _askAnswer = null;
      _askBusy = false;
    });
    // Continue forward — do not re-speak the segment the student already heard.
    if (!_finished && _activeCheck == null) {
      _advanceBeatOrSegment(resumePlayback: true);
    }
  }

  Future<void> _previewSummary() async {
    _pause();
    if (_script == null || !mounted) return;
    final LectureSummary summary = _script!.summary;
    final BiologyLessonPath? next = _nextLesson;
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text(
          'Lesson summary',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.path.lesson.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (summary.learned.isNotEmpty) ...<Widget>[
                  const Text(
                    'What we covered',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  ...summary.learned.map(
                    (String line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $line'),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  'Homework: ${summary.homeworkRecommendation}',
                  style: const TextStyle(height: 1.4),
                ),
                if (next != null) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    'Next lesson: ${next.lesson.title}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          if (next != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => BiologyLectureScreen(
                      path: next,
                      openAi: widget.openAi,
                      progress: widget.progress,
                    ),
                  ),
                );
              },
              child: const Text('Start next lesson'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep learning'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              unawaited(_openQuiz());
            },
            child: const Text('Practice questions'),
          ),
        ],
      ),
    );
  }

  Future<void> _endLesson() async {
    _pause();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('End lesson?'),
        content: const Text(
          'You can finish now and see your report, or keep learning.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep learning'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End lesson'),
          ),
        ],
      ),
    );
    if (confirm == true) await _finishLecture();
  }

  void _openNotes() {
    if (!mounted) return;
    showLectureNotesSheet(
      context,
      notes: _script?.notes ?? const LectureSmartNotes(),
      transcript: _transcript,
    );
  }

  void _pickSpeed() {
    if (!mounted) return;
    showLectureSpeedSheet(
      context,
      speeds: _speeds,
      current: _speed,
      onSelected: _changeSpeed,
    );
  }

  void _pickVoice() {
    if (!mounted) return;
    showLectureVoiceSheet(
      context,
      currentVoiceId: _voice.voiceId,
      onSelected: (String id) async {
        await _voice.setVoice(id);
        await saveLectureVoicePreference(id);
        if (!mounted) return;
        setState(() {});
        if (_playing || _delivering) {
          _pause(hard: true);
          _play();
        }
      },
    );
  }

  void _openStageSettings() {
    if (!mounted) return;
    showLectureSettingsSheet(
      context,
      speedLabel: _speedLabel,
      voiceLabel: _voice.voiceLabel,
      onSpeed: _pickSpeed,
      onVoice: _pickVoice,
      onNotes: _openNotes,
    );
  }

  void _toggleImmersive() {
    if (!mounted) return;
    setState(() => _immersive = !_immersive);
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);

    if (_mode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.path.lesson.title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(color: c.primary),
              const SizedBox(height: 16),
              Text(
                'Your private professor is preparing the whiteboard…',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    if (_script == null || _script!.segments.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lecture')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _loadError ?? 'This lecture could not be loaded.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final LectureSegment segment = _displaySegment ??
        _script!.segments[_segmentIndex.clamp(0, _script!.segments.length - 1)];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        if (_immersive) {
          setState(() => _immersive = false);
          return;
        }
        _pause(hard: true);
        Navigator.of(context).pop(_finished);
      },
      child: _immersive
          ? Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: LectureStage(
                  segment: segment,
                  topicTitle: widget.path.lesson.title,
                  phaseLabel: segment.phase.label,
                  isSpeaking: _speaking &&
                      _activeCheck == null &&
                      !_askingProfessor,
                  segmentProgress: _progress,
                  speed: _speed,
                  playing: _playing,
                  onPlayPause: _togglePlay,
                  onSpeed: _pickSpeed,
                  onSettings: _openStageSettings,
                  onFullscreen: _toggleImmersive,
                  fullscreenActive: true,
                  onSeek: _seekToProgress,
                  onScrubStart: _onScrubStart,
                  speedLabel: _speedLabel,
                  segmentIndex: _segmentIndex,
                  segmentCount: _script?.segments.length ?? 1,
                  utteranceProgress: _voice.utteranceProgress,
                ),
              ),
            )
          : Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              LectureLiveHeader(
                topicTitle: widget.path.lesson.title,
                courseLabel:
                    '${widget.path.course.title} · ${segment.phase.label}',
                elapsedSeconds: _sessionSeconds,
                onEndLesson: () => unawaited(_endLesson()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 5,
                    backgroundColor: c.border.withValues(alpha: 0.35),
                    color: c.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: LecturePhaseRoadmap(current: segment.phase),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      LectureStage(
                        segment: segment,
                        topicTitle: widget.path.lesson.title,
                        phaseLabel: segment.phase.label,
                        isSpeaking: _speaking &&
                            _activeCheck == null &&
                            !_askingProfessor,
                        segmentProgress: _progress,
                        speed: _speed,
                        playing: _playing,
                        onPlayPause: _togglePlay,
                        onSpeed: _pickSpeed,
                        onSettings: _openStageSettings,
                        onFullscreen: _toggleImmersive,
                        fullscreenActive: false,
                        onSeek: _seekToProgress,
                        onScrubStart: _onScrubStart,
                        speedLabel: _speedLabel,
                        segmentIndex: _segmentIndex,
                        segmentCount: _script?.segments.length ?? 1,
                        utteranceProgress: _voice.utteranceProgress,
                      ),
                      if (_activeCheck != null)
                        LectureCheckOverlay(
                          check: _activeCheck!,
                          onAnswered: _onCheckAnswered,
                        ),
                      if (_askingProfessor)
                        LectureAskOverlay(
                          mode: _askMode,
                          busy: _askBusy,
                          answer: _askAnswer,
                          question: _pendingQuestion,
                          topicHint:
                              _displaySegment?.whiteboard.title ?? widget.path.lesson.title,
                          onSubmit: _submitQuestion,
                          onDismiss: _dismissAsk,
                          onAskAgain: () {
                            unawaited(_voice.stop());
                            setState(() => _askAnswer = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (_nextLesson != null && _progress >= 70)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Material(
                    color: c.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      title: Text(
                        'Next: ${_nextLesson!.lesson.title}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text(
                        'Recommended after this lesson',
                      ),
                      trailing: FilledButton(
                        onPressed: () {
                          final BiologyLessonPath next = _nextLesson!;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => BiologyLectureScreen(
                                path: next,
                                openAi: widget.openAi,
                                progress: widget.progress,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                ),
              LectureControlsBar(
                playing: _playing,
                speedLabel: _speedLabel,
                onPlayPause: _togglePlay,
                onRestart: _restart,
                onSpeed: _pickSpeed,
                onNotes: _openNotes,
                onRaiseHand: _openRaiseHand,
                onConfused: _onConfused,
                onQuiz: () => unawaited(_openQuiz()),
                onSummary: () => unawaited(_previewSummary()),
                onPrevious: _previousSection,
                onForward: _nextSection,
                canPrevious: _segmentIndex > 0,
                canForward: _script != null && _script!.segments.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


