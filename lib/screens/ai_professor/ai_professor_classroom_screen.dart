import 'dart:async';

import 'package:flutter/material.dart';

import '../../vu_v2/campus/vu_v2_adaptive_review_drill_screen.dart';
import '../../vu_v2/data/vu_v2_progress_store.dart';
import '../../vu_v2/data/vu_v2_scope.dart';
import '../../data/diagram_misconception_catalog.dart';
import '../../data/diagram_misconception_store.dart';
import '../../data/university_learning_engine.dart';
import '../../data/virtual_lecture_outline.dart';
import '../../services/lecture_diagram_service.dart';
import '../../models/virtual_lecture.dart';
import '../../services/lecture_voice_controller.dart';
import '../../services/openai_service.dart';
import '../../services/virtual_lecture_service.dart';
import '../../utils/lecture_slide_notes_synthesizer.dart';
import '../../widgets/virtual_lecture/lecture_diagram_label_activity.dart';
import '../../widgets/virtual_lecture/lecture_ask_overlay.dart';
import '../../widgets/virtual_lecture/lecture_check_overlay.dart';
import '../../widgets/virtual_lecture/lecture_cinematic_shell.dart';
import '../../widgets/virtual_lecture/lecture_completion_report.dart';
import '../../widgets/virtual_lecture/lecture_controls_bar.dart';
import '../../widgets/virtual_lecture/lecture_sheets.dart';
import '../../widgets/virtual_lecture/lecture_stage.dart';

/// University AI video lesson — every course uses this classroom.
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
    this.linkedLabTitle,
    this.onEnterLab,
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
  final String? linkedLabTitle;
  final Future<void> Function()? onEnterLab;

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
  LectureAskMode _askMode = LectureAskMode.ask;
  bool _askBusy = false;
  String? _askAnswer;
  String? _pendingQuestion;
  bool _alive = true;
  bool _immersive = false;
  int _activeChapter = 0;
  List<LectureOutlineChapter> _chapters = const <LectureOutlineChapter>[];

  String get _professorLabel =>
      UniversityProfessorStyle.forSubject(widget.faculty).title;

  int get _masteryPercent {
    final double hint = widget.masteryHint.clamp(0.0, 1.0);
    if (_analytics.checksTotal > 0) {
      final double fromChecks =
          _analytics.checksCorrect / _analytics.checksTotal;
      // Checks dominate — no fake 72% baseline.
      final double blended = (fromChecks * 0.82) + (hint * 0.08) + 0.10;
      return (blended * 100).round().clamp(35, 100);
    }
    // Finished lecture with no checks: score from engagement, not a fake constant.
    final double fromProgress = _progress.clamp(0.0, 1.0);
    final double blended = (fromProgress * 0.55) + (hint * 0.25) + 0.20;
    return (blended * 100).round().clamp(40, 88);
  }

  @override
  void initState() {
    super.initState();
    _lectureService = VirtualLectureService(widget.openAi);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    // Start the lecture immediately — don't block on analytics I/O.
    unawaited(_loadAnalytics());
    unawaited(_loadVoicePreference());
    if (mounted) {
      await _startMode(LectureMode.comprehensive);
    }
  }

  Future<void> _loadVoicePreference() async {
    try {
      await _voice.ensureReady();
      final String id = await loadLectureVoicePreference();
      await _voice.setVoice(id);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Lecture voice pref load failed: $e');
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
      unawaited(_voice.stop());
      // Start instantly with offline board content for THIS lesson only.
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

      final String? lectureDiagramId = LectureDiagramService.preferredDiagramId(
        topic: widget.lessonTitle,
        faculty: widget.faculty,
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );
      final List<LectureSegment> adaptive =
          await AdaptiveDiagramReview.prefaceIfNeeded(
        diagramId: lectureDiagramId,
      );
      final VirtualLectureScript scriptWithReview = adaptive.isEmpty
          ? offline
          : offline.copyWith(
              segments: <LectureSegment>[...adaptive, ...offline.segments],
            );

      if (!mounted) return;

      setState(() {
        _mode = mode;
        _script = scriptWithReview;
        _loadError = null;
        _segmentIndex = 0;
        _beatIndex = 0;
        _transcript.clear();
        _chapters = VirtualLectureOutline.build(script: scriptWithReview);
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

      // Never discard adaptive review or rich offline diagram walkthrough.
      if (_hasRichDiagramTeaching(current) || _hasAdaptivePreface(current)) {
        debugPrint('Keeping offline diagram lecture — skipping thin AI upgrade.');
        return;
      }

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

  bool _hasRichDiagramTeaching(VirtualLectureScript script) {
    final List<LectureSegment> visuals = script.segments
        .where(
          (LectureSegment s) =>
              s.phase == LecturePhase.visualDemonstration ||
              s.whiteboard.slideType == LectureSlideType.diagram ||
              s.whiteboard.interactiveActivity != null,
        )
        .toList();
    if (visuals.length >= 2) return true;
    return visuals.any(
      (LectureSegment s) => s.whiteboard.keyPoints.length >= 5,
    );
  }

  bool _hasAdaptivePreface(VirtualLectureScript script) {
    return script.segments.any(
      (LectureSegment s) =>
          s.whiteboard.title == 'ADAPTIVE REVIEW' ||
          (s.caption.contains('Adaptive review')),
    );
  }

  int _adaptiveReviewSegmentCount() {
    final VirtualLectureScript? script = _script;
    if (script == null) return 0;
    return script.segments
        .where(
          (LectureSegment s) =>
              s.whiteboard.title == 'ADAPTIVE REVIEW' ||
              (s.caption.contains('Adaptive review')),
        )
        .length;
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
    // Instant player-rate change — do not hard-stop / re-synthesize.
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
        // Prefetch next beat/segment while this one plays to kill dead air.
        final String? upcoming = _upcomingSpeech();
        if (upcoming != null && upcoming.trim().isNotEmpty) {
          unawaited(_voice.prefetch(upcoming));
        }
        await _voice.speak(speech, _speed);
      } catch (e) {
        debugPrint('Lecture delivery failed: $e');
        // Never sit in silence for the full authored duration on failure.
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }

      if (!_alive || !mounted || epoch != _deliveryEpoch) {
        if (epoch == _deliveryEpoch) _delivering = false;
        return;
      }

      // Speak returned while soft-paused — wait for unpause, then advance only
      // if playback is live again. Do not force a full re-synthesis loop.
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
        // Unpaused after speak already finished — continue to next beat/segment.
      }
      break;
    }

    if (!_alive || !mounted || epoch != _deliveryEpoch || !_playing) {
      if (epoch == _deliveryEpoch) _delivering = false;
      return;
    }

    _safeSetState(() => _speaking = false);

    final String? interactive = active.whiteboard.interactiveActivity?.trim();
    if (interactive != null && interactive.isNotEmpty) {
      _delivering = false;
      await _launchInteractiveActivity(active.whiteboard);
      if (!_alive || !mounted || epoch != _deliveryEpoch || !_playing) {
        return;
      }
    }

    final LectureKnowledgeCheck? check = active.knowledgeCheck;
    if (check != null) {
      _pause(hard: true);
      setState(() => _activeCheck = check);
      _delivering = false;
      return;
    }

    // Always continue immediately after speech — no post-talk silence timer.
    // (Older builds waited 5–18s after "Examples", which felt like broken audio.)
    _delivering = false;
    _advanceBeatOrSegment(resumePlayback: true);
  }

  /// Next spoken line after the current beat/segment (for TTS prefetch).
  String? _upcomingSpeech() {
    final VirtualLectureScript? script = _script;
    final LectureSegment? raw = _segment;
    if (script == null || raw == null) return null;
    if (raw.isInteractive && _beatIndex < raw.beats.length - 1) {
      return raw.viewAtBeat(_beatIndex + 1).professorSpeech;
    }
    final int nextIndex = _segmentIndex + 1;
    if (nextIndex >= script.segments.length) return null;
    final LectureSegment next = script.segments[nextIndex];
    if (next.isInteractive && next.beats.isNotEmpty) {
      return next.viewAtBeat(0).professorSpeech;
    }
    return next.professorSpeech;
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

  Future<void> _launchInteractiveActivity(LectureWhiteboardFrame board) async {
    final String? act = board.interactiveActivity?.trim();
    if (act == null || act.isEmpty) return;
    _pause(hard: true);

    final String diagramId = board.diagramId ?? 'skeleton';
    final List<String>? regions =
        board.activityRegionIds.isEmpty ? null : board.activityRegionIds;

    switch (act) {
      case 'label_drag':
        await LectureDiagramLabelActivity.open(
          context,
          diagramId: diagramId,
          regionIds: regions,
          title: board.title,
        );
      case 'anatomy_3d':
        await LectureAnatomy3dActivity.open(
          context,
          diagramId: diagramId,
          focusRegionIds: regions,
        );
      default:
        debugPrint('Unknown interactiveActivity: $act');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Activity unavailable: $act')),
          );
        }
    }

    if (!mounted) return;
    setState(() {
      _playing = true;
      _speaking = false;
    });
  }

  Future<void> _onCheckAnswered(bool correct, {String? tappedRegionId}) async {
    final LectureKnowledgeCheck? check = _activeCheck;
    final List<String> weakAreas = List<String>.from(_analytics.weakAreas);

    if (!correct &&
        check != null &&
        check.kind == KnowledgeCheckKind.graphIdentify &&
        check.diagramId != null &&
        check.targetRegionId != null &&
        tappedRegionId != null) {
      final VuV2ProgressStore? progress = VuV2Scope.maybeOf(context)?.progress;
      if (progress != null) {
        await progress.recordDiagramConfusion(
          diagramId: check.diagramId!,
          tappedRegionId: tappedRegionId,
          targetRegionId: check.targetRegionId!,
        );
      } else {
        await DiagramMisconceptionStore.instance.recordConfusion(
          diagramId: check.diagramId!,
          tappedRegionId: tappedRegionId,
          targetRegionId: check.targetRegionId!,
        );
      }
      final DiagramMisconceptionDef? def = DiagramMisconceptionCatalog.resolve(
        diagramId: check.diagramId!,
        tappedRegionId: tappedRegionId,
        targetRegionId: check.targetRegionId!,
      );
      if (def != null &&
          DiagramMisconceptionStore.instance.countFor(def.id) >=
              DiagramMisconceptionStore.reviewThreshold) {
        weakAreas.add('${def.labelA}/${def.labelB}');
      }
    } else if (correct &&
        check != null &&
        check.kind == KnowledgeCheckKind.graphIdentify &&
        check.diagramId != null &&
        check.targetRegionId != null) {
      DiagramMisconceptionDef? cleared;
      for (final DiagramMisconceptionDef d in DiagramMisconceptionCatalog.all) {
        if (d.diagramId == check.diagramId! &&
            (d.regionA == check.targetRegionId || d.regionB == check.targetRegionId)) {
          cleared = d;
          break;
        }
      }
      if (cleared != null) {
        final VuV2ProgressStore? progress = VuV2Scope.maybeOf(context)?.progress;
        if (progress != null) {
          unawaited(progress.recordMisconceptionCleared(cleared.id));
        } else {
          unawaited(DiagramMisconceptionStore.instance.markReviewed(cleared.id));
        }
      }
    }

    if (!correct && _segment != null) {
      weakAreas.add(_segment!.phase.label);
    }

    setState(() {
      _activeCheck = null;
      _analytics = _analytics.copyWith(
        checksTotal: _analytics.checksTotal + 1,
        checksCorrect: _analytics.checksCorrect + (correct ? 1 : 0),
        participationCount: _analytics.participationCount + 1,
        weakAreas: weakAreas,
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
    if (mounted) {
      await VuV2Scope.maybeOf(context)?.progress.syncDiagramMisconceptions();
    }
    if (!mounted) return;
    setState(() => _finished = true);
    await _showSummary();
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _showSummary() async {
    final LectureSummary summary = _script!.summary;
    final String? next = widget.nextLessonTitle;
    final bool demoPath = widget.lessonId.contains('hackathon_demo');
    bool enteredLab = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => LectureCompletionReport(
        topicTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
        courseCode: widget.courseId,
        professorLabel: _professorLabel,
        masteryPercent: _masteryPercent,
        learned: summary.learned,
        homework: summary.homeworkRecommendation,
        timeSpentSeconds: _analytics.timeSpentSeconds,
        checksCorrect: _analytics.checksCorrect,
        checksTotal: _analytics.checksTotal,
        questionsAsked: _analytics.questionsAsked,
        weakAreas: _analytics.weakAreas,
        adaptiveReviewSegments: _adaptiveReviewSegmentCount(),
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
        labTitle: widget.linkedLabTitle,
        clinicalCaseTitle: demoPath
            ? 'Posterior shoulder trauma · Clinical Viva'
            : (widget.onEnterLab != null ? widget.linkedLabTitle : null),
        onLab: widget.onEnterLab == null
            ? null
            : () {
                enteredLab = true;
                Navigator.of(ctx).pop();
              },
        preferLabCta: demoPath,
        onFixMisconceptions: () {
          final VuV2ProgressStore? progress =
              VuV2Scope.maybeOf(context)?.progress;
          if (progress == null || !mounted) return;
          unawaited(
            VuV2AdaptiveReviewDrillScreen.open(context, progress: progress),
          );
        },
      ),
    );
    if (enteredLab && widget.onEnterLab != null && mounted) {
      await widget.onEnterLab!();
    }
    // Demo spine: lecture → Clinical Viva without a dead end on Campus.
    if (!enteredLab &&
        demoPath &&
        widget.onEnterLab != null &&
        mounted) {
      await widget.onEnterLab!();
    }
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
      if (active?.whiteboard.subtitle?.trim().isNotEmpty == true)
        'Subtitle: ${active!.whiteboard.subtitle}',
      if (active != null && active.whiteboard.keyPoints.isNotEmpty)
        'Key points: ${active.whiteboard.keyPoints.take(6).join('; ')}',
      if ((active?.professorSpeech ?? '').trim().isNotEmpty)
        'Professor was saying: ${active!.professorSpeech}',
    ].join('\n');

    String answer;
    try {
      answer = await _lectureService!.askProfessorForLesson(
        lessonTitle: widget.lessonTitle,
        courseTitle: widget.courseTitle,
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
          'Let me clarify ${widget.lessonTitle}. '
          'Start from the core idea on this slide, then connect it to one concrete example. '
          'If it still feels unclear, ask again and name the exact part that confuses you.';
    }

    setState(() {
      _askBusy = false;
      _askAnswer = answer.trim();
      _analytics = _analytics.copyWith(
        questionsAsked: _analytics.questionsAsked + 1,
      );
      _transcript.add('You: $trimmed');
      _transcript.add('Professor: ${answer.trim()}');
    });
    // Speak the answer so the student hears the professor respond.
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

  LectureSlideNotes _currentSlideNotes() {
    final LectureSegment? seg = _displaySegment ?? _segment;
    return LectureSlideNotesSynthesizer.fromSegment(
      segment: seg ??
          LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech: '',
            caption: widget.lessonTitle,
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: widget.lessonTitle,
            ),
          ),
      lessonNotes: _script?.notes,
    );
  }

  void _openNotes() {
    if (!mounted) return;
    final LectureSegment? seg = _displaySegment ?? _segment;
    final LectureSlideNotes slideNotes = _currentSlideNotes();
    showLectureNotesSheet(
      context,
      notes: _script?.notes ?? const LectureSmartNotes(),
      transcript: _transcript,
      slideNotes: slideNotes,
      slideTitle: seg?.whiteboard.title ?? widget.lessonTitle,
      onSaveNotes: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slide notes saved for this lesson')),
        );
      },
      onGenerateQuiz: () => unawaited(_openQuiz()),
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
        // Soft-restart current section with the new voice (cache miss once).
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

  /// Scrubber seek — jump only when the section changes; same section seeks voice.
  void _seekToProgress(double progress) {
    if (_script == null || _script!.segments.isEmpty) return;
    final int count = _script!.segments.length;
    final double pos = progress.clamp(0.0, 1.0) * count;
    final int target = pos.floor().clamp(0, count - 1);

    // Same section — seek within the utterance so board + voice stay aligned.
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
        if (_immersive) {
          setState(() => _immersive = false);
          return;
        }
        _pause(hard: true);
        Navigator.of(context).pop(_finished);
      },
      child: _immersive && segment != null
          ? Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: LectureStage(
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
                  onSettings: _openStageSettings,
                  onFullscreen: _toggleImmersive,
                  fullscreenActive: true,
                  onSeek: _seekToProgress,
                  onScrubStart: _onScrubStart,
                  speedLabel: _speedLabel,
                  segmentIndex: _segmentIndex,
                  segmentCount: script?.segments.length ?? 1,
                  utteranceProgress: _voice.utteranceProgress,
                  forceDiagramInteractive:
                      _activeCheck?.kind == KnowledgeCheckKind.graphIdentify ||
                          segment.whiteboard.diagramInteractive,
                  identifyTargetId: _activeCheck?.kind ==
                          KnowledgeCheckKind.graphIdentify
                      ? _activeCheck?.targetRegionId
                      : null,
                  onRegionIdentified: (String regionId) {
                    final LectureKnowledgeCheck? check = _activeCheck;
                    if (check == null ||
                        check.kind != KnowledgeCheckKind.graphIdentify) {
                      return;
                    }
                    final bool ok = regionId == check.targetRegionId;
                    unawaited(
                      _onCheckAnswered(ok, tappedRegionId: regionId),
                    );
                  },
                ),
              ),
            )
          : LectureCinematicShell(
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
                onSettings: _openStageSettings,
                onFullscreen: _toggleImmersive,
                fullscreenActive: false,
                onSeek: _seekToProgress,
                onScrubStart: _onScrubStart,
                speedLabel: _speedLabel,
                segmentIndex: _segmentIndex,
                segmentCount: script?.segments.length ?? 1,
                utteranceProgress: _voice.utteranceProgress,
                forceDiagramInteractive:
                    _activeCheck?.kind == KnowledgeCheckKind.graphIdentify ||
                        segment.whiteboard.diagramInteractive,
                identifyTargetId: _activeCheck?.kind ==
                        KnowledgeCheckKind.graphIdentify
                    ? _activeCheck?.targetRegionId
                    : null,
                onRegionIdentified: (String regionId) {
                  final LectureKnowledgeCheck? check = _activeCheck;
                  if (check == null ||
                      check.kind != KnowledgeCheckKind.graphIdentify) {
                    return;
                  }
                  final bool ok = regionId == check.targetRegionId;
                  unawaited(
                    _onCheckAnswered(ok, tappedRegionId: regionId),
                  );
                },
              ),
        controls: LectureControlsBar(
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
        askOverlay: _askingProfessor
            ? LectureAskOverlay(
                mode: _askMode,
                busy: _askBusy,
                answer: _askAnswer,
                question: _pendingQuestion,
                topicHint: _displaySegment?.whiteboard.title ?? widget.lessonTitle,
                onSubmit: _submitQuestion,
                onDismiss: _dismissAsk,
                onAskAgain: () {
                  unawaited(_voice.stop());
                  setState(() => _askAnswer = null);
                },
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
