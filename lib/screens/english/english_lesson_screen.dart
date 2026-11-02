import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/english_lesson.dart';
import '../../services/english_lesson_engine.dart';
import '../../services/english_progress_service.dart';
import '../../services/english_reading_grader.dart';
import '../../services/english_writing_grader.dart';
import '../../services/lecture_voice_controller.dart';
import '../../services/openai_service.dart';
import '../../services/tutor_voice_service.dart';
import '../../services/user_service.dart';
import '../../theme/study_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/english/english_activity_panel.dart';
import '../../widgets/english/english_lesson_summary_view.dart';
import '../../widgets/english/english_session_chrome.dart';
import '../../widgets/study_surface.dart';

class EnglishLessonScreen extends StatefulWidget {
  const EnglishLessonScreen({super.key, required this.script});

  final EnglishLessonScript script;

  @override
  State<EnglishLessonScreen> createState() => _EnglishLessonScreenState();
}

class _EnglishLessonScreenState extends State<EnglishLessonScreen> {
  EnglishLessonEngine? _engine;
  EnglishActivityPanelState? _activePanel;
  final LectureVoiceController _voice = LectureVoiceController();
  final TutorVoiceService _mic = TutorVoiceService();
  bool _canListen = false;
  bool _listening = false;
  bool _speaking = false;
  Timer? _autoTimer;
  Timer? _readingTickTimer;
  DateTime? _readingStartedAt;
  int _readingElapsedSeconds = 0;
  int _readingMinSeconds = kEnglishReadingAloudShortMinSeconds;
  bool _readingSessionActive = false;
  bool _readingMicResuming = false;
  String _readingTranscript = '';
  String _readingPartial = '';
  bool _finishingReading = false;
  bool _saved = false;
  int _phaseTimerForIndex = -1;
  EnglishLessonPhase? _phaseTimerForPhase;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await EnglishProgressService.instance.ensureLoaded();
    final EnglishProgressService progress = EnglishProgressService.instance;
    final double mult = progress.streakMultiplier();
    final EnglishLessonEngine engine = EnglishLessonEngine(
      widget.script,
      streakMultiplier: mult,
      learnerLevel: progress.cefrLevel,
    );
    engine.addListener(_onEngine);
    if (!mounted) {
      engine.dispose();
      return;
    }
    setState(() => _engine = engine);
    unawaited(_initVoice());
    _engine!.begin();
    _schedulePhaseSideEffects();
  }

  Future<void> _initVoice() async {
    await _voice.ensureReady();
    final cap = await _mic.initialize();
    if (mounted) setState(() => _canListen = cap.canListen);
  }

  void _onEngine() {
    if (!mounted || _engine == null) return;
    setState(() {});
    _schedulePhaseSideEffects();
    if (_engine!.isComplete && !_saved) {
      _saved = true;
      _persistResults();
    }
  }

  void _schedulePhaseSideEffects() {
    final EnglishLessonEngine? engine = _engine;
    if (engine == null) return;

    final EnglishActivity? step = engine.currentActivity;
    if (step == null || engine.isComplete) return;

    final int index = engine.currentIndex;
    final EnglishLessonPhase phase = engine.phase;

    if (_phaseTimerForIndex == index && _phaseTimerForPhase == phase) {
      return;
    }

    final int previousIndex = _phaseTimerForIndex;
    _autoTimer?.cancel();
    _phaseTimerForIndex = index;
    _phaseTimerForPhase = phase;
    if (previousIndex != index ||
        phase == EnglishLessonPhase.feedback ||
        phase == EnglishLessonPhase.complete ||
        phase == EnglishLessonPhase.grading) {
      _resetReadingSession();
    }

    if (phase == EnglishLessonPhase.microPrompt) {
      unawaited(_speakShort(step.prompt));
      _autoTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        _engine?.advanceFromMicroPrompt();
      });
      return;
    }

    if (phase == EnglishLessonPhase.active) {
      unawaited(_speakShort(step.prompt));
      if (step.kind == EnglishActivityKind.listening &&
          step.listeningScript != null) {
        unawaited(_speakShort(step.listeningScript!, delayMs: 400));
      }
      return;
    }

    if (phase == EnglishLessonPhase.feedback) {
      _autoTimer = Timer(const Duration(seconds: 12), () {
        if (!mounted) return;
        _continueAfterFeedback();
      });
    }
  }

  void _submitAnswer(dynamic answer) {
    final EnglishActivity? step = _engine?.currentActivity;
    if (step?.kind == EnglishActivityKind.readingAloud) {
      unawaited(_completeReadingAloud(
        manual: true,
        transcriptOverride: answer is String ? answer : '$answer',
      ));
      return;
    }
    if (step != null && _usesAiWritingGrade(step)) {
      unawaited(_gradeWritingAsync(step, answer));
      return;
    }
    _engine?.submitAnswer(answer);
  }

  bool _usesAiWritingGrade(EnglishActivity step) {
    if (step.kind == EnglishActivityKind.essayWriting) return true;
    if (step.kind == EnglishActivityKind.emailWriting && AppConfig.hasOpenAi) {
      return true;
    }
    return false;
  }

  Future<void> _gradeWritingAsync(EnglishActivity step, dynamic answer) async {
    final EnglishLessonEngine? engine = _engine;
    if (engine == null) return;

    engine.beginGrading();
    const EnglishWritingGrader local = EnglishWritingGrader();

    try {
      final EnglishWrittenSubmission submission = answer is EnglishWrittenSubmission
          ? answer
          : EnglishWrittenSubmission(body: answer is String ? answer : '$answer');

      if (AppConfig.hasOpenAi) {
        final OpenAiService openAi = context.read<OpenAiService>();
        final Map<String, dynamic> ai = await openAi.gradeEnglishWriting(
          lessonTitle: widget.script.title,
          prompt: step.prompt,
          studentAnswer: submission.body,
          tone: step.writingTone?.name ?? 'any',
          criteria: step.gradingCriteria,
          expectedAnswer: step.correctAnswer,
          recipient: submission.recipient,
        );
        final bool correct = ai['correct'] == true;
        final String feedback = (ai['feedback'] as String?)?.trim().isNotEmpty == true
            ? (ai['feedback'] as String).trim()
            : (correct
                ? (step.feedbackCorrect ?? 'Well done!')
                : (step.feedbackWrong ?? 'Review the rubric and revise.'));
        engine.applyGradeResult(
          GradeResult(correct: correct, feedback: feedback, note: 'AI writing grade'),
        );
        return;
      }
    } catch (e, st) {
      debugPrint('AI writing grade failed: $e\n$st');
    }

    engine.applyGradeResult(
      local.gradeSync(
        activity: step,
        answer: answer,
        lessonTitle: widget.script.title,
      ),
    );
  }

  Future<void> _gradeReadingAloud(String transcript) async {
    final EnglishLessonEngine? engine = _engine;
    final EnglishActivity? step = engine?.currentActivity;
    if (engine == null || step == null) return;

    engine.beginGrading();
    try {
      final EnglishReadingGrader grader = EnglishReadingGrader(
        openAi: context.read<OpenAiService>(),
      );
      final GradeResult result = await grader.grade(
        activity: step,
        transcript: transcript,
        lessonTitle: widget.script.title,
      );
      engine.applyGradeResult(result);
    } catch (e, st) {
      debugPrint('Reading grade failed: $e\n$st');
      engine.applyGradeResult(
        const GradeResult(
          correct: false,
          feedback: 'Could not grade your reading — tap Next question to continue.',
          note: 'Reading grade error',
        ),
      );
    }
  }

  void _tapSubmit() {
    _activePanel?.submitCurrentAnswer();
  }

  void _onPanelReady(EnglishActivityPanelState panel) {
    _activePanel = panel;
  }

  void _continueAfterFeedback() {
    _autoTimer?.cancel();
    _phaseTimerForIndex = -1;
    _phaseTimerForPhase = null;
    _engine?.continueAfterFeedback();
  }

  Future<void> _speakShort(String text, {int delayMs = 0}) async {
    if (delayMs > 0) await Future<void>.delayed(Duration(milliseconds: delayMs));
    if (!mounted) return;
    setState(() => _speaking = true);
    await _voice.speak(text, 1.02);
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _persistResults() async {
    final EnglishLessonResult? r = _engine?.result;
    if (r == null) return;
    try {
      await context.read<UserService>().addXp(r.xpEarned);
    } catch (_) {}
    await EnglishProgressService.instance.recordLessonComplete(
      xpEarned: r.xpEarned,
      skillId: widget.script.id,
      mastered: r.grammarMastered,
      levelAfter: r.levelAfter,
    );
  }

  void _resetReadingSession() {
    _readingTickTimer?.cancel();
    _readingTickTimer = null;
    _readingStartedAt = null;
    _readingElapsedSeconds = 0;
    _readingMinSeconds = kEnglishReadingAloudShortMinSeconds;
    _readingSessionActive = false;
    _readingMicResuming = false;
    _readingTranscript = '';
    _readingPartial = '';
  }

  int _currentReadingElapsed() {
    if (_readingStartedAt == null) return _readingElapsedSeconds;
    return DateTime.now().difference(_readingStartedAt!).inSeconds;
  }

  void _accumulateReadingWords(String words, bool isFinal) {
    final String trimmed = words.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      if (isFinal) {
        _readingTranscript = '$_readingTranscript $trimmed'.trim();
        _readingPartial = '';
      } else {
        _readingPartial = trimmed;
      }
    });
  }

  String get _readingCombinedTranscript =>
      '$_readingTranscript $_readingPartial'.trim();

  void _startReadingTickTimer() {
    _readingTickTimer?.cancel();
    _readingTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _readingStartedAt == null) return;
      setState(() => _readingElapsedSeconds = _currentReadingElapsed());
    });
  }

  Future<void> _resumeReadingMic() async {
    if (!mounted || !_readingSessionActive || _finishingReading) return;
    if (_currentReadingElapsed() >= _readingMinSeconds) return;
    if (_engine?.isGrading == true) return;
    if (_readingMicResuming || _listening) return;

    _readingMicResuming = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || !_readingSessionActive) return;
      await _attachReadingMic();
    } finally {
      _readingMicResuming = false;
    }
  }

  Future<void> _attachReadingMic() async {
    if (!mounted || !_readingSessionActive) return;

    setState(() => _listening = true);
    final bool ok = await _mic.startListening(
      onWords: (String words, bool isFinal) {
        if (!mounted) return;
        _accumulateReadingWords(words, isFinal);
      },
      onListeningState: () {
        if (mounted) setState(() => _listening = true);
      },
      onListeningStopped: () {
        if (!mounted) return;
        unawaited(_onReadingMicStopped());
      },
      listenFor: Duration(
        seconds: (_readingMinSeconds + 120).clamp(240, 480),
      ),
      pauseFor: const Duration(seconds: 30),
    );

    if (!ok && mounted) {
      setState(() => _listening = false);
      if (_readingSessionActive && _currentReadingElapsed() < _readingMinSeconds) {
        StudyMessenger.showInfo(
          context,
          'Microphone paused — keep reading. It will reconnect automatically.',
        );
      }
    }
  }

  Future<void> _onReadingMicStopped() async {
    if (!mounted || !_readingSessionActive) {
      if (mounted) setState(() => _listening = false);
      return;
    }

    setState(() => _listening = false);

    final int elapsed = _currentReadingElapsed();
    if (elapsed < _readingMinSeconds) {
      await _resumeReadingMic();
    }
  }

  Future<void> _stopReadingRecording() async {
    if (!_readingSessionActive || _finishingReading || _engine?.isGrading == true) {
      return;
    }
    await _completeReadingAloud(manual: true);
  }

  Future<void> _completeReadingAloud({
    required bool manual,
    String? transcriptOverride,
  }) async {
    if (_finishingReading) return;
    _finishingReading = true;
    try {
      final int elapsed = _currentReadingElapsed();
      final String transcript = transcriptOverride ?? _readingCombinedTranscript;

      if (!manual && elapsed < _readingMinSeconds) {
        if (_listening) {
          setState(() => _listening = false);
        }
        if (!_listening && !_readingMicResuming) {
          await _resumeReadingMic();
        }
        return;
      }

      if (_listening) {
        await _mic.stopListening();
      }
      if (!mounted) return;

      setState(() => _listening = false);

      if (transcript.isEmpty) {
        StudyMessenger.showError(
          context,
          'We did not catch your voice — tap the mic and read the passage aloud.',
        );
        _resetReadingSession();
        return;
      }

      final String finalTranscript = transcript;
      _resetReadingSession();
      unawaited(_gradeReadingAloud(finalTranscript));
    } finally {
      _finishingReading = false;
    }
  }

  Future<void> _beginReadingSession(EnglishActivity step) async {
    _resetReadingSession();
    _readingSessionActive = true;
    _readingMinSeconds = readingAloudMinSecondsFor(step);
    _readingStartedAt = DateTime.now();
    _startReadingTickTimer();
    await _attachReadingMic();
  }

  String _formatReadingMin(int seconds) {
    if (seconds <= 0) return '0s';
    if (seconds >= 60) {
      final int m = seconds ~/ 60;
      final int s = seconds % 60;
      if (s == 0) return '$m minute${m == 1 ? '' : 's'}';
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  Future<void> _startListening() async {
    final EnglishLessonEngine? engine = _engine;
    if (engine?.isGrading == true) return;

    final EnglishActivity? step = engine?.currentActivity;
    final bool isReading = step?.kind == EnglishActivityKind.readingAloud;

    if (isReading) {
      if (_readingSessionActive) {
        if (_currentReadingElapsed() < _readingMinSeconds) {
          StudyMessenger.showInfo(
            context,
            'Keep reading — ${_formatReadingMin(_readingMinSeconds - _currentReadingElapsed())} left.',
          );
        }
        if (!_listening) await _resumeReadingMic();
        return;
      }
      await _beginReadingSession(step!);
      return;
    }

    if (_listening) return;

    setState(() => _listening = true);
    final bool ok = await _mic.startListening(
      onWords: (String words, bool isFinal) {
        if (!mounted || !isFinal || words.trim().isEmpty) return;
        _submitAnswer(words.trim());
      },
      onListeningState: () {
        if (mounted) setState(() => _listening = true);
      },
      onListeningStopped: () {
        if (mounted) setState(() => _listening = false);
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 2),
    );
    if (!ok && mounted) setState(() => _listening = false);
  }

  bool _hasTapOptions(EnglishActivity step) {
    return step.options.isNotEmpty &&
        (step.kind == EnglishActivityKind.multipleChoice ||
            step.kind == EnglishActivityKind.rapidReview ||
            step.kind == EnglishActivityKind.listening ||
            step.kind == EnglishActivityKind.explainError ||
            step.kind == EnglishActivityKind.bestSentence ||
            step.kind == EnglishActivityKind.readingInference ||
            step.kind == EnglishActivityKind.vocabularyContext);
  }

  bool _usesExternalSubmit(EnglishActivity step) {
    if (step.kind == EnglishActivityKind.sentenceBuilder ||
        step.kind == EnglishActivityKind.microPrompt ||
        step.kind == EnglishActivityKind.scenarioIntro ||
        step.kind == EnglishActivityKind.speaking ||
        step.kind == EnglishActivityKind.readingAloud) {
      return false;
    }
    if (_hasTapOptions(step)) return false;
    return true;
  }

  String _submitLabel(EnglishActivity step) {
    if (step.kind == EnglishActivityKind.emailWriting) return 'Submit email';
    if (step.kind == EnglishActivityKind.essayWriting) return 'Submit essay';
    return 'Submit answer';
  }

  Widget? _buildBottomBar(
    EnglishLessonEngine engine,
    EnglishActivity? step,
    Brightness brightness,
  ) {
    if (step == null) return null;

    if (engine.phase == EnglishLessonPhase.microPrompt) {
      return Material(
        elevation: 8,
        color: EnglishLessonTheme.surface(brightness),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => engine.advanceFromMicroPrompt(),
                style: EnglishLessonTheme.primaryButton(brightness),
                child: const Text('Continue'),
              ),
            ),
          ),
        ),
      );
    }

    if (engine.phase == EnglishLessonPhase.feedback) {
      return null;
    }

    if (engine.phase == EnglishLessonPhase.grading) {
      return Material(
        elevation: 8,
        color: EnglishLessonTheme.surface(brightness),
        child: const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 12),
                Text('AI is grading your reading…'),
              ],
            ),
          ),
        ),
      );
    }

    if (engine.phase == EnglishLessonPhase.active && _usesExternalSubmit(step)) {
      return Material(
        elevation: 8,
        color: EnglishLessonTheme.surface(brightness),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: engine.isGrading ? null : _tapSubmit,
                style: EnglishLessonTheme.primaryButton(brightness),
                child: Text(_submitLabel(step)),
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _readingTickTimer?.cancel();
    _engine?.removeListener(_onEngine);
    _engine?.dispose();
    _voice.dispose();
    unawaited(_mic.stopListening().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final EnglishLessonEngine? engine = _engine;

    if (engine == null) {
      return Scaffold(
        backgroundColor: EnglishLessonTheme.background(brightness),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (engine.isComplete) {
      return Scaffold(
        backgroundColor: EnglishLessonTheme.background(brightness),
        appBar: AppBar(title: const Text('Session summary')),
        body: EnglishLessonSummaryView(
          result: engine.result!,
          lessonTitle: widget.script.title,
          onDone: () => Navigator.of(context).pop(),
          onRetry: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => EnglishLessonScreen(script: widget.script),
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: engine,
      builder: (BuildContext context, Widget? child) {
        final EnglishActivity? step = engine.currentActivity;
        final int total = engine.totalSteps;
        final int current = engine.currentIndex + 1;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: EnglishLessonTheme.background(brightness),
          bottomNavigationBar: _buildBottomBar(engine, step, brightness),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                EnglishSessionHeader(
                  progress: engine.progress,
                  xp: engine.xp,
                  current: current,
                  total: total,
                ),
                if (engine.streak >= 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Text(
                      '${engine.streak} correct in a row',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: StudyColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          EnglishProfessorChip(
                            speaking: _speaking,
                            stepLabel: step != null ? _stepLabel(step) : null,
                          ),
                          if (engine.currentDifficulty != null &&
                              engine.phase !=
                                  EnglishLessonPhase.microPrompt) ...<Widget>[
                            const SizedBox(width: 8),
                            EnglishDifficultyChip(
                                level: engine.currentDifficulty!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (step != null)
                        _buildLessonStep(context, engine, step, brightness),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _stepLabel(EnglishActivity step) {
    return switch (step.kind) {
      EnglishActivityKind.microPrompt => 'Concept',
      EnglishActivityKind.questionCard => 'Question',
      EnglishActivityKind.multipleChoice => 'Choose',
      EnglishActivityKind.fillBlank => 'Fill in',
      EnglishActivityKind.sentenceBuilder => 'Build',
      EnglishActivityKind.speaking => 'Speaking',
      EnglishActivityKind.readingAloud => 'Read aloud',
      EnglishActivityKind.listening => 'Listening',
      EnglishActivityKind.correction => 'Fix it',
      EnglishActivityKind.miniConversation => 'Chat',
      EnglishActivityKind.rapidReview => 'Choose',
      EnglishActivityKind.emailWriting => 'Email',
      EnglishActivityKind.shortWriting => 'Writing',
      EnglishActivityKind.essayWriting => 'Essay',
      EnglishActivityKind.sentenceRewrite => 'Rewrite',
      EnglishActivityKind.explainError => 'Analyze',
      EnglishActivityKind.paragraphCorrection => 'Edit',
      EnglishActivityKind.bestSentence => 'Choose',
      EnglishActivityKind.combineSentences => 'Combine',
      EnglishActivityKind.transformWriting => 'Transform',
      EnglishActivityKind.readingInference => 'Reading',
      EnglishActivityKind.vocabularyContext => 'Vocabulary',
      EnglishActivityKind.scenarioIntro => 'Scenario',
    };
  }

  Widget _buildLessonStep(
    BuildContext context,
    EnglishLessonEngine engine,
    EnglishActivity step,
    Brightness brightness,
  ) {
    if (engine.phase == EnglishLessonPhase.microPrompt) {
      return StudySurfaceCard(
        padding: const EdgeInsets.all(18),
        child: _buildMicroPromptBody(context, step, brightness),
      );
    }

    return StudySurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Question',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: StudyColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            step.prompt,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (engine.phase == EnglishLessonPhase.feedback)
            EnglishLessonFeedbackBar(
              correct: engine.lastCorrect,
              message: engine.feedback ?? '',
              brightness: brightness,
              onContinue: _continueAfterFeedback,
              embedded: true,
            )
          else if (engine.phase == EnglishLessonPhase.active)
            EnglishActivityPanel(
              key: ValueKey<String>('${step.id}-${engine.currentIndex}'),
              activity: step,
              phase: engine.phase,
              feedback: engine.feedback,
              lastCorrect: engine.lastCorrect,
              onSubmit: _submitAnswer,
              onContinue: _continueAfterFeedback,
              onListen: _startListening,
              onStopReading: _stopReadingRecording,
              onPanelReady: _onPanelReady,
              listening: _listening,
              canListen: _canListen && !engine.isGrading,
              grading: engine.isGrading,
              readingElapsedSeconds: step.kind == EnglishActivityKind.readingAloud
                  ? _readingElapsedSeconds
                  : null,
              readingMinSeconds: step.kind == EnglishActivityKind.readingAloud
                  ? readingAloudMinSecondsFor(step)
                  : kEnglishReadingAloudShortMinSeconds,
              readingSessionActive: _readingSessionActive,
              showSubmitButton: !_usesExternalSubmit(step),
              showFeedback: false,
            ),
        ],
      ),
    );
  }

  Widget _buildMicroPromptBody(
    BuildContext context,
    EnglishActivity step,
    Brightness brightness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          step.prompt,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
        ),
        if (step.microTip != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            step.microTip!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: EnglishLessonTheme.textSecondary(brightness),
                  height: 1.4,
                ),
          ),
        ],
      ],
    );
  }
}
