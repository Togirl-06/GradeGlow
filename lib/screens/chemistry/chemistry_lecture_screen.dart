import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/chemistry_degree_catalog.dart';
import '../../models/chemistry_degree.dart';
import '../../models/virtual_lecture.dart';
import '../../services/lecture_voice_controller.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/openai_service.dart';
import '../../services/virtual_lecture_service.dart';
import '../../theme/chemistry_degree_theme.dart';
import '../../widgets/virtual_lecture/lecture_ask_overlay.dart';
import '../../widgets/virtual_lecture/lecture_check_overlay.dart';
import '../../widgets/virtual_lecture/lecture_completion_report.dart';
import '../../widgets/virtual_lecture/lecture_controls_bar.dart';
import '../../widgets/virtual_lecture/lecture_live_header.dart';
import '../../widgets/virtual_lecture/lecture_phase_roadmap.dart';
import '../../widgets/virtual_lecture/lecture_sheets.dart';
import '../../widgets/virtual_lecture/lecture_stage.dart';
import 'chemistry_practice_screen.dart';

/// Interactive AI chemistry professor — whiteboard-first laboratory lecture.
class ChemistryLectureScreen extends StatefulWidget {
  const ChemistryLectureScreen({
    super.key,
    required this.path,
    required this.openAi,
    required this.progress,
  });

  final ChemistryLessonPath path;
  final OpenAiService openAi;
  final ChemistryProgressService progress;

  @override
  State<ChemistryLectureScreen> createState() => _ChemistryLectureScreenState();
}

class _ChemistryLectureScreenState extends State<ChemistryLectureScreen> {
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
  bool _askBusy = false;
  String? _askAnswer;
  String? _pendingQuestion;
  String? _lastAskQuestion;
  bool _alive = true;

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

  int _textSegmentSeconds(LectureSegment? segment) {
    final String speech = segment?.professorSpeech ?? '';
    final int words = speech.trim().isEmpty ? 0 : speech.trim().split(RegExp(r'\s+')).length;
    final int fromWords = (words / 2.2 / _speed).round();
    final int authored = segment?.durationSeconds ?? 90;
    final int fromMeta = (authored / _speed).round();
    final int base = fromWords > fromMeta ? fromWords : fromMeta;
    return base.clamp(30, 180);
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
      final VirtualLectureScript script = await _lectureService!.loadChemistryScript(
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
    final bool restartSpeech = _playing &&
        _segment != null &&
        _activeCheck == null &&
        !_askingProfessor;
    setState(() => _speed = speed);
    unawaited(_voice.setSpeed(speed));
    if (restartSpeech) {
      _pause(hard: true);
      _play();
    }
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
        await Future<void>.delayed(Duration(seconds: _textSegmentSeconds(active)));
      }

      if (!_alive || !mounted || epoch != _deliveryEpoch) {
        if (epoch == _deliveryEpoch) _delivering = false;
        return;
      }

      if (!_playing) continue;
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

    if (!raw.isInteractive && _isInteractivePhase(raw.phase)) {
      _delivering = false;
      _scheduleAutoAdvance(active);
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

  bool _isInteractivePhase(LecturePhase phase) {
    return phase == LecturePhase.studentParticipation ||
        phase == LecturePhase.guidedExamples;
  }

  void _scheduleAutoAdvance(LectureSegment segment) {
    _segmentTimer?.cancel();
    final int seconds = (_textSegmentSeconds(segment) / 3).round().clamp(5, 18);
    _segmentTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted || !_playing) return;
      _advanceSegment(resumePlayback: true);
    });
  }

  void _onCheckAnswered(bool correct) {
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

  /// Scrubber seek — jump only when the section changes; same section resumes audio.
  void _seekToProgress(double progress) {
    if (_script == null || _script!.segments.isEmpty) return;
    final int count = _script!.segments.length;
    final double pos = progress.clamp(0.0, 1.0) * count;
    final int target = pos.floor().clamp(0, count - 1);

    if (target == _segmentIndex) {
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
        ChemLessonActivityKind.lecture,
      );
    } catch (e) {
      debugPrint('Lecture progress update failed: $e');
    }
    if (!mounted) return;
    setState(() => _finished = true);
    await _showSummary();
    if (mounted) Navigator.of(context).pop(true);
  }

  ChemistryLessonPath? get _nextLesson {
    final List<ChemistryLessonPath> all = ChemistryDegreeCatalog.allLessonPaths;
    final int i = all.indexWhere(
      (ChemistryLessonPath p) => p.lesson.id == widget.path.lesson.id,
    );
    if (i < 0 || i >= all.length - 1) return null;
    return all[i + 1];
  }

  Future<void> _showSummary() async {
    final LectureSummary summary = _script!.summary;
    final ChemistryLessonPath? next = _nextLesson;
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
                    builder: (_) => ChemistryLectureScreen(
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
      _askAnswer = null;
      _pendingQuestion = null;
      _playing = false;
      _speaking = false;
    });
  }

  void _onConfused() {
    _freezeLectureForInterrupt();
    if (_askingProfessor) return;
    setState(() {
      _askingProfessor = true;
      _askAnswer = null;
      _pendingQuestion =
          "I'm confused about this part. Please explain it more simply, "
          'use a different analogy, and give another short example.';
      _playing = false;
      _speaking = false;
    });
    unawaited(
      _submitQuestion(
        "I'm confused about this part. Please explain it more simply, "
        'use a different analogy, and give another short example.',
      ),
    );
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
        builder: (_) => ChemistryPracticeScreen(
          path: widget.path,
          kind: ChemLessonActivityKind.quiz,
        ),
      ),
    );
  }

  Future<void> _submitQuestion(String question) async {
    if (_lectureService == null) return;
    setState(() {
      _askBusy = true;
      _pendingQuestion = question;
      _lastAskQuestion = question;
    });
    try {
      final String answer = await _lectureService!.askChemistryProfessor(
        path: widget.path,
        currentSpeech: _segment?.professorSpeech ?? '',
        question: question,
      );
      if (!mounted) return;
      setState(() {
        _askBusy = false;
        _askAnswer = answer;
        _analytics = _analytics.copyWith(questionsAsked: _analytics.questionsAsked + 1);
        _transcript.add('You: $question');
        _transcript.add('Professor: $answer');
      });
      // Text answer only — avoid a second/device TTS voice on interrupt.
    } catch (e) {
      debugPrint('Ask professor failed: $e');
      if (!mounted) return;
      setState(() => _askBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the professor right now.')),
      );
    }
  }

  Future<void> _expandLectureFromAsk() async {
    if (_lectureService == null || _script == null || _lastAskQuestion == null) {
      _dismissAsk();
      return;
    }
    setState(() => _askBusy = true);
    try {
      final LectureSegment? extra = await _lectureService!.expandChemistryLecture(
        path: widget.path,
        currentSpeech: _segment?.professorSpeech ?? '',
        studentRequest: _lastAskQuestion!,
      );
      if (!mounted || extra == null) {
        if (mounted) setState(() => _askBusy = false);
        return;
      }
      setState(() {
        _script = _script!.insertSegmentAfter(_segmentIndex, extra);
        _askBusy = false;
        _askingProfessor = false;
        _askAnswer = null;
        _segmentIndex += 1;
        _beatIndex = 0;
        _analytics = _analytics.copyWith(questionsAsked: _analytics.questionsAsked + 1);
      });
      _play();
    } catch (e) {
      debugPrint('Expand lecture failed: $e');
      if (mounted) setState(() => _askBusy = false);
    }
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
    final ChemistryLessonPath? next = _nextLesson;
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
                    builder: (_) => ChemistryLectureScreen(
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

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

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
        _pause(hard: true);
        Navigator.of(context).pop(_finished);
      },
      child: Scaffold(
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
                        onSeek: _seekToProgress,
                        onScrubStart: _onScrubStart,
                        speedLabel: _speedLabel,
                        segmentIndex: _segmentIndex,
                        segmentCount: _script?.segments.length ?? 1,
                      ),
                      if (_activeCheck != null)
                        LectureCheckOverlay(
                          check: _activeCheck!,
                          onAnswered: _onCheckAnswered,
                        ),
                      if (_askingProfessor)
                        LectureAskOverlay(
                          busy: _askBusy,
                          answer: _askAnswer,
                          question: _pendingQuestion,
                          onSubmit: _submitQuestion,
                          onDismiss: _dismissAsk,
                          onExpandLecture:
                              _askAnswer != null ? _expandLectureFromAsk : null,
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
                          final ChemistryLessonPath next = _nextLesson!;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => ChemistryLectureScreen(
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


