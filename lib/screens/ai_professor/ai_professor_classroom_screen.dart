import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/virtual_lecture_outline.dart';
import '../../models/virtual_lecture.dart';
import '../../services/lecture_voice_controller.dart';
import '../../services/openai_service.dart';
import '../../services/virtual_lecture_service.dart';
import '../../widgets/virtual_lecture/lecture_ask_overlay.dart';
import '../../widgets/virtual_lecture/lecture_check_overlay.dart';
import '../../widgets/virtual_lecture/lecture_cinematic_shell.dart';
import '../../widgets/virtual_lecture/lecture_completion_report.dart';
import '../../widgets/virtual_lecture/lecture_sheets.dart';
import '../../widgets/virtual_lecture/lecture_stage.dart';
import '../../theme/study_theme.dart';

/// Khan Academy–style AI video lesson — every course uses this classroom.
///
/// Blackboard + voice teaching (no human teacher video). Play / pause, ask,
/// confused, summary, practice, and next-lesson recommendation.
class AiProfessorClassroomScreen extends StatefulWidget {
  const AiProfessorClassroomScreen({
    super.key,
    required this.openAi,
    required this.lessonId,
    required this.lessonTitle,
    required this.courseId,
    required this.courseTitle,
    required this.moduleTitle,
    required this.faculty,
    this.nextLessonTitle,
    this.onStartNextLesson,
    this.onPractice,
    this.onCompleted,
    this.masteryHint = 0,
  });

  final OpenAiService openAi;
  final String lessonId;
  final String lessonTitle;
  final String courseId;
  final String courseTitle;
  final String moduleTitle;
  final String faculty;
  final String? nextLessonTitle;
  final VoidCallback? onStartNextLesson;
  final Future<void> Function()? onPractice;
  final Future<void> Function()? onCompleted;
  final double masteryHint;

  @override
  State<AiProfessorClassroomScreen> createState() =>
      _AiProfessorClassroomScreenState();
}

class _AiProfessorClassroomScreenState
    extends State<AiProfessorClassroomScreen> {
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

  LectureKnowledgeCheck? _activeCheck;
  bool _askingProfessor = false;
  bool _askBusy = false;
  String? _askAnswer;
  String? _pendingQuestion;
  String? _lastAskQuestion;
  bool _alive = true;
  int _activeChapter = 0;
  List<LectureOutlineChapter> _chapters = const <LectureOutlineChapter>[];

  @override
  void initState() {
    super.initState();
    _lectureService = VirtualLectureService(widget.openAi);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    // Start the lecture immediately — don't block on analytics I/O.
    unawaited(_loadAnalytics());
    if (mounted) {
      await _startMode(LectureMode.comprehensive);
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final LectureAnalytics saved =
          await _lectureService!.loadAnalytics(widget.lessonId);
      if (mounted) setState(() => _analytics = saved);
    } catch (e) {
      debugPrint('Lecture analytics load failed: $e');
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

  void _safeSetState(VoidCallback fn) {
    if (!_alive || !mounted) return;
    setState(fn);
  }

  int _textSegmentSeconds(LectureSegment? segment) {
    final String speech = segment?.professorSpeech ?? '';
    final int words =
        speech.trim().isEmpty ? 0 : speech.trim().split(RegExp(r'\s+')).length;
    final int fromWords = (words / 2.2 / _speed).round();
    final int authored = segment?.durationSeconds ?? 90;
    final int fromMeta = (authored / _speed).round();
    final int base = fromWords > fromMeta ? fromWords : fromMeta;
    return base.clamp(70, 420);
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
      // Start instantly with offline board content — no network wait.
      final VirtualLectureScript offline =
          _lectureService!.loadOfflineLessonScript(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
        moduleTitle: widget.moduleTitle,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        mode: mode,
        faculty: widget.faculty,
      );

      if (!mounted) return;

      if (offline.segments.isEmpty) {
        setState(() {
          _mode = mode;
          _script = null;
          _loadError = 'Could not load this lesson.';
          _startingMode = false;
        });
        return;
      }

      setState(() {
        _mode = mode;
        _script = offline;
        _loadError = null;
        _segmentIndex = 0;
        _beatIndex = 0;
        _transcript.clear();
        _chapters = VirtualLectureOutline.build(script: offline);
        _activeChapter = 0;
        _startingMode = false;
        _analytics =
            _analytics.copyWith(mode: mode, lessonId: widget.lessonId);
      });
      _play();

      // Upgrade to richer AI script in the background if still early in the lesson.
      unawaited(_upgradeScriptInBackground(mode));
    } catch (e, stack) {
      debugPrint('AI Professor start failed: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _mode = mode;
        _script = null;
        _startingMode = false;
        _loadError =
            'Could not start this AI video lesson. Please go back and try again.';
      });
    }
  }

  Future<void> _upgradeScriptInBackground(LectureMode mode) async {
    try {
      final VirtualLectureScript? ai =
          await _lectureService!.tryLoadAiLessonScript(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
        moduleTitle: widget.moduleTitle,
        mode: mode,
        masteryHint: widget.masteryHint,
        weakAreas: _analytics.weakAreas,
        faculty: widget.faculty,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );
      if (!mounted || ai == null || ai.segments.isEmpty || _finished) return;
      final VirtualLectureScript? current = _script;
      if (current == null || current.segments.isEmpty) return;

      // Never rewind or re-speak. Keep everything through the playhead; attach
      // richer AI segments only for what has not been taught yet.
      final int keepCount = (_segmentIndex + 1).clamp(1, current.segments.length);
      final List<LectureSegment> kept =
          current.segments.sublist(0, keepCount);
      final List<LectureSegment> upcoming = ai.segments.length > keepCount
          ? ai.segments.sublist(keepCount)
          : const <LectureSegment>[];
      final VirtualLectureScript merged = ai.copyWith(
        segments: <LectureSegment>[...kept, ...upcoming],
      );
      if (!mounted || _finished) return;
      setState(() {
        _script = merged;
        _chapters = VirtualLectureOutline.build(script: merged);
        if (_segmentIndex >= merged.segments.length) {
          _segmentIndex = merged.segments.length - 1;
        }
      });
    } catch (e) {
      debugPrint('Background AI lecture upgrade skipped: $e');
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
    // Restart the current section so speed is baked into fresh TTS audio.
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
    final String speech =
        _displaySegment?.professorSpeech ?? _segment!.professorSpeech;
    if (!_transcript.contains(speech)) {
      _transcript.add(speech);
    }
    unawaited(_deliverSegment());
  }

  void _ensureStudyClock() {
    _studyClock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_alive || !mounted) return;
      if (_playing) {
        _safeSetState(() => _sessionSeconds += 1);
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
        // Soft-paused: keep delivery alive until unpause or hard stop.
        await Future<void>.delayed(const Duration(milliseconds: 32));
        continue;
      }

      try {
        await _voice.speak(speech, _speed);
      } catch (e) {
        debugPrint('Lecture delivery failed: $e');
        await Future<void>.delayed(
          Duration(seconds: _textSegmentSeconds(active)),
        );
      }

      if (!_alive || !mounted || epoch != _deliveryEpoch) {
        if (epoch == _deliveryEpoch) _delivering = false;
        return;
      }

      // Speak returned while soft-paused (platform aborted audio) — wait and retry
      // from the cached buffer instead of advancing.
      if (!_playing) continue;
      break;
    }

    if (!_alive || !mounted || epoch != _deliveryEpoch || !_playing) {
      if (epoch == _deliveryEpoch) _delivering = false;
      return;
    }

    _safeSetState(() => _speaking = false);

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
    final int seconds =
        (_textSegmentSeconds(segment) / 3).round().clamp(5, 18);
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

  /// Instant lecture freeze for Ask / Confused — fully stop lecture voice.
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
    const String prompt =
        "I'm confused about this part of the lecture. "
        'Reteach the SAME idea a DIFFERENT way: simpler language, a new analogy, '
        'and a fresh example. Do not repeat the previous explanation. '
        'Then check I understood with one short question.';
    setState(() {
      _askingProfessor = true;
      _askAnswer = null;
      _pendingQuestion = prompt;
      _playing = false;
      _speaking = false;
    });
    unawaited(_submitQuestion(prompt));
  }

  void _restart() {
    _pause(hard: true);
    setState(() {
      _segmentIndex = 0;
      _beatIndex = 0;
      _activeChapter = 0;
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
    _syncActiveChapter();
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
    _syncActiveChapter();
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
      await widget.onCompleted?.call();
    } catch (e) {
      debugPrint('Lecture progress update failed: $e');
    }
    if (!mounted) return;
    setState(() => _finished = true);
    await _showSummary();
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _showSummary() async {
    final LectureSummary summary = _script!.summary;
    final String? next = widget.nextLessonTitle;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => LectureCompletionReport(
        topicTitle: widget.lessonTitle,
        learned: summary.learned,
        homework: summary.homeworkRecommendation,
        timeSpentSeconds: _analytics.timeSpentSeconds,
        checksCorrect: _analytics.checksCorrect,
        checksTotal: _analytics.checksTotal,
        questionsAsked: _analytics.questionsAsked,
        weakAreas: _analytics.weakAreas,
        nextLessonTitle: next,
        onQuiz: () {
          Navigator.of(ctx).pop();
          unawaited(_openQuiz());
        },
        onNextLesson: next == null || widget.onStartNextLesson == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                widget.onStartNextLesson!();
              },
        onContinue: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _openQuiz() async {
    _pause(hard: true);
    if (!mounted) return;
    if (widget.onPractice != null) {
      await widget.onPractice!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Practice questions will open from your lesson hub.'),
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
      final String answer = await _lectureService!.askProfessorForLesson(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
        currentSpeech: _segment?.professorSpeech ?? '',
        question: question,
      );
      if (!mounted) return;
      setState(() {
        _askBusy = false;
        _askAnswer = answer;
        _analytics = _analytics.copyWith(
          questionsAsked: _analytics.questionsAsked + 1,
        );
        _transcript.add('You: $question');
        _transcript.add('Professor: $answer');
      });
      // Show the answer on screen only — do not start a second/device TTS voice
      // over the lecture. Continue uses the same professor voice afterward.
    } catch (e) {
      debugPrint('Ask professor failed: $e');
      if (!mounted) return;
      setState(() => _askBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not reach the professor right now.'),
        ),
      );
    }
  }

  Future<void> _expandLectureFromAsk() async {
    if (_lectureService == null ||
        _script == null ||
        _lastAskQuestion == null) {
      _dismissAsk();
      return;
    }
    setState(() => _askBusy = true);
    try {
      final LectureSegment? extra =
          await _lectureService!.expandLectureForLesson(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
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
        _analytics = _analytics.copyWith(
          questionsAsked: _analytics.questionsAsked + 1,
        );
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
    final String? next = widget.nextLessonTitle;
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
                  widget.lessonTitle,
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
                    'Next lesson: $next',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: <Widget>[
          if (next != null && widget.onStartNextLesson != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onStartNextLesson!();
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

  void _syncActiveChapter() {
    if (_chapters.isEmpty) return;
    final int seg = _segmentIndex;
    int found = 0;
    for (int i = 0; i < _chapters.length; i++) {
      if (_chapters[i].segmentIndices.contains(seg)) {
        found = i;
        break;
      }
      if (_chapters[i].firstSegmentIndex <= seg) found = i;
    }
    if (found != _activeChapter && mounted) {
      setState(() => _activeChapter = found);
    }
  }

  void _jumpToChapter(int chapterIndex) {
    if (_script == null || chapterIndex < 0 || chapterIndex >= _chapters.length) {
      return;
    }
    final LectureOutlineChapter chapter = _chapters[chapterIndex];
    final int target = chapter.firstSegmentIndex.clamp(0, _script!.segments.length - 1);
    _pause(hard: true);
    setState(() {
      _activeChapter = chapterIndex;
      _segmentIndex = target;
      _beatIndex = 0;
      _activeCheck = null;
      _askingProfessor = false;
    });
    _play();
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

    // Stayed in the same lecture section — resume the paused voice (no re-TTS).
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

    // New section only — one clean hard stop, then speak that segment once.
    _pause(hard: true);
    setState(() {
      _segmentIndex = target;
      _beatIndex = 0;
      _activeCheck = null;
      _askingProfessor = false;
      _askAnswer = null;
    });
    _syncActiveChapter();
    _play();
  }

  String get _elapsedLabel {
    final int m = _sessionSeconds ~/ 60;
    final int s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool preparing = _mode == null || _startingMode;

    if (_mode != null && (_script == null || _script!.segments.isEmpty)) {
      return Scaffold(
        backgroundColor: LectureCinematicShell.cream,
        appBar: AppBar(
          backgroundColor: LectureCinematicShell.cream,
          foregroundColor: LectureCinematicShell.ink,
          title: const Text('AI Professor'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _loadError ?? 'This lesson could not be loaded.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: LectureCinematicShell.ink),
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

    final VirtualLectureScript? script = _script;
    final LectureSegment? segment = preparing
        ? null
        : (_displaySegment ??
            script!.segments[_segmentIndex.clamp(0, script.segments.length - 1)]);

    final List<LectureOutlineChapter> displayChapters = preparing
        ? <LectureOutlineChapter>[
            LectureOutlineChapter(
              id: 'intro',
              label: 'Why ${widget.lessonTitle} Matters',
              kind: LectureOutlineKind.introduction,
              icon: IconDataRef.book,
              accent: LectureOutlineAccent.blue,
              segmentIndices: const <int>[0],
            ),
            LectureOutlineChapter(
              id: 'history',
              label: 'The Evolution of ${widget.lessonTitle}',
              kind: LectureOutlineKind.history,
              icon: IconDataRef.history,
              accent: LectureOutlineAccent.amber,
              segmentIndices: const <int>[0],
            ),
            LectureOutlineChapter(
              id: 'theory',
              label: widget.lessonTitle,
              kind: LectureOutlineKind.theory,
              icon: IconDataRef.theory,
              accent: LectureOutlineAccent.purple,
              segmentIndices: const <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'visual',
              label: 'Visualizing the Concept',
              kind: LectureOutlineKind.visual,
              icon: IconDataRef.visual,
              accent: LectureOutlineAccent.orange,
              segmentIndices: <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'formulas',
              label: 'Formulas & Every Symbol',
              kind: LectureOutlineKind.formulas,
              icon: IconDataRef.formula,
              accent: LectureOutlineAccent.slate,
              segmentIndices: <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'apps',
              label: 'Real-World Applications',
              kind: LectureOutlineKind.applications,
              icon: IconDataRef.world,
              accent: LectureOutlineAccent.green,
              segmentIndices: <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'check',
              label: 'Self-Check',
              kind: LectureOutlineKind.selfCheck,
              icon: IconDataRef.check,
              accent: LectureOutlineAccent.blue,
              segmentIndices: <int>[0],
            ),
            LectureOutlineChapter(
              id: 'compare',
              label: '${widget.lessonTitle} vs Prior Lessons',
              kind: LectureOutlineKind.compare,
              icon: IconDataRef.compare,
              accent: LectureOutlineAccent.amber,
              segmentIndices: const <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'practice',
              label: 'Practice Problems',
              kind: LectureOutlineKind.practice,
              icon: IconDataRef.practice,
              accent: LectureOutlineAccent.orange,
              segmentIndices: <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'homework',
              label: 'Take-Home Assignment',
              kind: LectureOutlineKind.homework,
              icon: IconDataRef.homework,
              accent: LectureOutlineAccent.purple,
              segmentIndices: <int>[0],
            ),
            const LectureOutlineChapter(
              id: 'reading',
              label: 'Further Exploration',
              kind: LectureOutlineKind.reading,
              icon: IconDataRef.reading,
              accent: LectureOutlineAccent.green,
              segmentIndices: <int>[0],
            ),
          ]
        : (_chapters.isEmpty && script != null
            ? VirtualLectureOutline.build(script: script)
            : _chapters);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _pause(hard: true);
        Navigator.of(context).pop(_finished);
      },
      child: LectureCinematicShell(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
        moduleTitle: widget.moduleTitle,
        faculty: widget.faculty,
        preparing: preparing,
        chapters: displayChapters,
        activeChapterIndex: _activeChapter.clamp(0, displayChapters.length - 1),
        onSelectChapter: preparing ? (_) {} : _jumpToChapter,
        onBack: () {
          _pause(hard: true);
          Navigator.of(context).pop(_finished);
        },
        onEndLesson: () => unawaited(_endLesson()),
        elapsedLabel: _elapsedLabel,
        blurb: script == null
            ? 'This lecture provides a rigorous foundation for ${widget.lessonTitle}.'
            : VirtualLectureOutline.lectureBlurb(script),
        prerequisites: VirtualLectureOutline.prerequisites(widget.faculty),
        stage: segment == null
            ? const SizedBox.expand()
            : LectureStage(
                segment: segment,
                topicTitle: widget.lessonTitle,
                phaseLabel: segment.phase.label,
                isSpeaking:
                    _speaking && _activeCheck == null && !_askingProfessor,
                segmentProgress: _progress,
                speed: _speed,
                playing: _playing,
                onPlayPause: _togglePlay,
                onSpeed: _pickSpeed,
                onSeek: _seekToProgress,
                onScrubStart: _onScrubStart,
                speedLabel: _speedLabel,
                segmentIndex: _segmentIndex,
                segmentCount: script?.segments.length ?? 1,
              ),
        controls: _KhanTeachingActions(
          onConfused: _onConfused,
          onAsk: _openRaiseHand,
          onNotes: _openNotes,
          onQuiz: () => unawaited(_openQuiz()),
          onSummary: () => unawaited(_previewSummary()),
          onPrevious: _previousSection,
          onNext: _nextSection,
          onRestart: _restart,
          canPrevious: _segmentIndex > 0,
          canNext: _script != null && _script!.segments.isNotEmpty,
        ),
        askOverlay: _askingProfessor
            ? LectureAskOverlay(
                busy: _askBusy,
                answer: _askAnswer,
                question: _pendingQuestion,
                onSubmit: _submitQuestion,
                onDismiss: _dismissAsk,
                onExpandLecture:
                    _askAnswer != null ? _expandLectureFromAsk : null,
              )
            : null,
        checkOverlay: _activeCheck != null
            ? LectureCheckOverlay(
                check: _activeCheck!,
                onAnswered: _onCheckAnswered,
              )
            : null,
        belowStage: widget.nextLessonTitle != null &&
                widget.onStartNextLesson != null &&
                _progress >= 70
            ? Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text(
                    'Next: ${widget.nextLessonTitle}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: LectureCinematicShell.ink,
                    ),
                  ),
                  subtitle: const Text('Recommended after this lecture'),
                  trailing: FilledButton(
                    onPressed: widget.onStartNextLesson,
                    child: const Text('Start'),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _KhanTeachingActions extends StatelessWidget {
  const _KhanTeachingActions({
    required this.onConfused,
    required this.onAsk,
    required this.onNotes,
    required this.onQuiz,
    required this.onSummary,
    required this.onPrevious,
    required this.onNext,
    required this.onRestart,
    required this.canPrevious,
    required this.canNext,
  });

  final VoidCallback onConfused;
  final VoidCallback onAsk;
  final VoidCallback onNotes;
  final VoidCallback onQuiz;
  final VoidCallback onSummary;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final bool canPrevious;
  final bool canNext;

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: onConfused,
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text("I'm Confused"),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onAsk,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Ask Question'),
                style: FilledButton.styleFrom(
                  backgroundColor: LectureCinematicShell.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _ActionChip(icon: Icons.replay_rounded, label: 'Restart', onTap: onRestart),
            _ActionChip(
              icon: Icons.skip_previous_rounded,
              label: 'Back',
              onTap: canPrevious ? onPrevious : null,
            ),
            _ActionChip(
              icon: Icons.skip_next_rounded,
              label: 'Next',
              onTap: canNext ? onNext : null,
            ),
            _ActionChip(icon: Icons.note_alt_outlined, label: 'Notes', onTap: onNotes),
            _ActionChip(icon: Icons.quiz_outlined, label: 'Practice', onTap: onQuiz),
            _ActionChip(icon: Icons.summarize_outlined, label: 'Summary', onTap: onSummary),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool on = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: on ? LectureCinematicShell.ink : LectureCinematicShell.mute,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: on ? LectureCinematicShell.mute : LectureCinematicShell.mute.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
