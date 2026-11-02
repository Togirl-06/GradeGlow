import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../data/practice_lab_question_bank.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_question.dart';
import '../services/practice_lab_service.dart';
import '../services/subscription_service.dart';
import '../services/tutor_voice_service.dart';
import '../theme/study_theme.dart';
import '../widgets/practice_lab/practice_lab_intro_panel.dart';
import '../utils/network_reachability.dart';
import '../utils/practice_lab_question_runner.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/practice_lab/used_hints_sheet.dart';
import '../widgets/study_surface.dart';
import '../widgets/tutor_markdown_body.dart';

/// Topic practice lab — many questions per difficulty, skip-and-return-later, then grade.
class PracticeLabSessionScreen extends StatefulWidget {
  const PracticeLabSessionScreen({
    super.key,
    required this.category,
    required this.lab,
    this.courseName,
    this.topicAreaName,
    this.topicName,
    this.subjectId,
    this.courseId,
    this.topicId,
    this.requireFullCompletion = false,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final String? courseName;
  final String? topicAreaName;
  final String? topicName;
  final String? subjectId;
  final String? courseId;
  final String? topicId;
  /// When true, only pops `true` after all questions are answered and graded.
  final bool requireFullCompletion;

  @override
  State<PracticeLabSessionScreen> createState() => _PracticeLabSessionScreenState();
}

class _PracticeLabSessionScreenState extends State<PracticeLabSessionScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final TutorVoiceService _voice = TutorVoiceService();
  Timer? _timer;

  SimulationStart? _start;
  SimulationGrade? _grade;
  PracticeLabQuestionRunner? _runner;
  final List<String> _hints = <String>[];
  bool _loading = false;
  String? _error;
  int _liveScore = 0;
  int _hintsUsed = 0;
  bool _voiceReady = false;
  bool _holdingMic = false;
  Duration _elapsed = Duration.zero;
  bool _sessionStarted = false;
  bool _fullyCompleted = false;

  String get _topicLabel => widget.topicName ?? widget.lab.title;

  bool get _isMathQuestionOnly =>
      widget.subjectId == 'mathematics' || widget.lab.id.startsWith('math_');

  @override
  void initState() {
    super.initState();
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _initVoice() async {
    final VoiceCapabilities caps = await _voice.initialize();
    if (mounted) setState(() => _voiceReady = caps.anyReady);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voice.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    if (!mounted) return;
    if (!AppConfig.hasOpenAi) {
      setState(() => _error = 'OpenAI is not configured. Add OPENAI_API_KEY to your .env file.');
      return;
    }
    final PracticeLabService labs = context.read<PracticeLabService>();
    if (!await labs.canStartSimulation()) {
      if (!mounted) return;
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.practiceLabs);
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ensureOpenAiReachable();
      final List<PracticeLabQuestion> questions = await labs.loadPracticeQuestions(
        category: widget.category,
        lab: widget.lab,
        courseName: widget.courseName,
        unitName: widget.topicAreaName,
        topicName: widget.topicName,
        subjectId: widget.subjectId,
        courseId: widget.courseId,
        topicId: widget.topicId,
      );
      if (!mounted) return;

      if (_isMathQuestionOnly) {
        setState(() {
          _start = SimulationStart(
            scenarioTitle: _topicLabel,
            briefing: '',
            aiRole: 'Tutor',
            openingMessage: '',
          );
          _runner = PracticeLabQuestionRunner(questions);
          _loading = false;
          _sessionStarted = true;
        });
        _startTimer();
        return;
      }

      final SimulationStart start = await labs.startSimulation(
        category: widget.category,
        lab: widget.lab,
        topicAreaName: widget.topicAreaName,
        topicName: widget.topicName,
      );
      if (!mounted) return;
      setState(() {
        _start = start;
        _runner = PracticeLabQuestionRunner(questions);
        _loading = false;
        _sessionStarted = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StudyMessenger.clean(error);
      });
    }
  }

  List<SimulationMessage> _historyForGrading(PracticeLabService labs) {
    return labs.historyFromQuestionResponses(
      start: _start!,
      responses: _runner?.responses ?? const <PracticeLabQuestionResponse>[],
    );
  }

  Future<void> _pulseScore() async {
    if (_start == null || _runner == null) return;
    if (_runner!.responses.isEmpty) return;
    try {
      final PracticeLabLiveScore pulse = await context.read<PracticeLabService>().pulseLiveScore(
            category: widget.category,
            lab: widget.lab,
            start: _start!,
            history: _historyForGrading(context.read<PracticeLabService>()),
          );
      if (!mounted) return;
      setState(() => _liveScore = pulse.overall);
    } catch (_) {}
  }

  Future<void> _submitAnswer() async {
    final String text = _input.text.trim();
    if (text.isEmpty || _loading || _start == null || _grade != null || _runner == null) return;
    final PracticeLabQuestion? question = _runner!.current;
    if (question == null) return;

    _input.clear();
    setState(() => _loading = true);
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final String feedback = await labs.feedbackPracticeAnswer(
        category: widget.category,
        topicName: _topicLabel,
        question: question.prompt,
        studentAnswer: text,
        difficulty: widget.lab.difficulty,
      );
      if (!mounted) return;
      setState(() {
        _runner!.answerCurrent(text, feedback: feedback);
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
        }
      });
      if (_runner!.responses.length % 3 == 0) {
        await _pulseScore();
      }
      if (_runner!.isComplete) {
        await _promptGrade(auto: true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  void _skipQuestion() {
    if (_loading || _start == null || _grade != null || _runner == null) return;
    if (_runner!.current == null) return;
    setState(() {
      _runner!.skipCurrent();
      _input.clear();
    });
    StudyMessenger.showInfo(
      context,
      _runner!.isComplete
          ? 'Last question skipped — answer deferred items to finish.'
          : 'Skipped — you\'ll see this question again later.',
    );
    if (_runner!.isComplete && _runner!.responses.isNotEmpty) {
      unawaited(_promptGrade(auto: true));
    }
  }

  Future<void> _requestHint() async {
    if (_start == null || _grade != null || _loading || _hintsUsed >= 3 || _runner == null) return;
    final PracticeLabQuestion? question = _runner!.current;
    if (question == null) return;

    setState(() => _loading = true);
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final List<SimulationMessage> history = labs.historyFromQuestionResponses(
        start: _start!,
        responses: _runner!.responses,
      )..add(SimulationMessage.ai('Question: ${question.prompt}'));

      final String hint = await labs.requestHint(
        category: widget.category,
        lab: widget.lab,
        start: _start!,
        history: history,
      );
      if (!mounted) return;
      setState(() {
        _hintsUsed += 1;
        _hints.add(hint);
        _loading = false;
      });
      if (mounted) showUsedHintsSheet(context, hints: _hints);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _startHoldToSpeak() async {
    if (!await PremiumAccess.checkAndPrompt(context, context.read<SubscriptionService>(), feature: PremiumFeature.voiceTutor)) {
      return;
    }
    setState(() => _holdingMic = true);
    await _voice.startListening(
      onWords: (String words, bool isFinal) {
        if (mounted) setState(() => _input.text = words);
      },
      onListeningState: () {
        if (mounted) setState(() {});
      },
      onListeningStopped: () {
        if (mounted) setState(() => _holdingMic = false);
      },
    );
  }

  Future<void> _stopHoldToSpeak() async {
    await _voice.stopListening();
    if (!mounted) return;
    setState(() => _holdingMic = false);
    if (_input.text.trim().isNotEmpty) await _submitAnswer();
  }

  void _reviewHints() {
    if (_hints.isEmpty) return;
    showUsedHintsSheet(context, hints: _hints);
  }

  Future<void> _promptGrade({bool auto = false}) async {
    if (_start == null || _grade != null || _loading) return;
    if (_runner == null || _runner!.responses.isEmpty) {
      if (!auto) {
        StudyMessenger.showError(context, 'Answer at least one question before grading.');
      }
      return;
    }
    if (!_runner!.isComplete && !auto) {
      if (widget.requireFullCompletion) {
        StudyMessenger.showError(
          context,
          'Answer all ${_runner!.totalCount} questions before submitting.',
        );
        return;
      }
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('End early?'),
          content: Text(
            'You have answered ${_runner!.answeredCount} of ${_runner!.totalCount} questions. '
            'Grade now with partial progress?',
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Grade me')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    } else if (auto && _runner!.isComplete) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('All questions complete!'),
          content: Text('You answered all ${_runner!.totalCount} questions. Ready for your grade?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Review')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Grade me')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _endAndGrade();
  }

  Future<void> _endAndGrade() async {
    if (_start == null || _grade != null || _loading) return;
    _timer?.cancel();
    await _voice.stopSpeaking();
    if (!mounted) return;
    final PracticeLabService labs = context.read<PracticeLabService>();
    setState(() => _loading = true);
    try {
      final SimulationGrade grade = await labs.endAndGrade(
        category: widget.category,
        lab: widget.lab,
        start: _start!,
        history: _historyForGrading(labs),
        hintsUsed: _hintsUsed,
      );
      if (!mounted) return;
      setState(() {
        _grade = grade;
        _liveScore = grade.score;
        _loading = false;
        if (widget.requireFullCompletion) {
          _fullyCompleted = _runner?.isComplete ?? false;
        }
      });
      await labs.refreshUsage();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final SimulationStart? start = _start;
    final SimulationGrade? grade = _grade;
    final PracticeLabQuestionRunner? runner = _runner;
    final PracticeLabQuestion? current = runner?.current;
    final int targetCount = PracticeLabQuestionBank.targetCountForDifficulty(widget.lab.difficulty);

    return PopScope(
      canPop: !widget.requireFullCompletion,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || !widget.requireFullCompletion) return;
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_topicLabel, style: const TextStyle(fontSize: 16)),
            if (widget.topicAreaName != null)
              Text(
                '${widget.topicAreaName} · ${widget.lab.difficulty}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
              ),
          ],
        ),
        actions: <Widget>[
          if (grade == null && start != null) _TimerChip(elapsed: _elapsed),
          if (grade == null && start != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: StudyColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$_liveScore%', style: TextStyle(fontWeight: FontWeight.w800, color: StudyColors.primary, fontSize: 13)),
                ),
              ),
            ),
          if (grade == null && start != null)
            TextButton(onPressed: _loading ? null : () => _promptGrade(), child: const Text('End & Grade')),
        ],
      ),
      body: _error != null
          ? _ErrorBody(message: _error!, onRetry: _boot)
          : grade != null
              ? _ResultsBody(
                  grade: grade,
                  onDone: () => Navigator.pop(
                    context,
                    widget.requireFullCompletion ? _fullyCompleted : null,
                  ),
                )
              : _loading && start == null
                  ? const Center(child: CircularProgressIndicator())
                  : start != null && runner != null && !_sessionStarted && !_isMathQuestionOnly
                      ? PracticeLabIntroPanel(
                          title: start.scenarioTitle.isNotEmpty ? start.scenarioTitle : _topicLabel,
                          subtitle: '${widget.courseName ?? widget.category.name} · ${widget.lab.difficulty}',
                          leadingEmoji: '📚',
                          objectives: widget.lab.studentTasks.take(3).toList(),
                          sessionFacts: <String>[
                            '$targetCount questions',
                            widget.lab.difficulty,
                            'AI tutor feedback',
                            '3 hints',
                          ],
                          onStart: () {
                            setState(() => _sessionStarted = true);
                            _startTimer();
                          },
                        )
                      : Column(
                      children: <Widget>[
                        if (runner != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _ProgressHeader(
                              answered: runner.answeredCount,
                              total: runner.totalCount,
                              target: targetCount,
                              deferred: runner.skippedPendingCount,
                              difficulty: widget.lab.difficulty,
                            ),
                          ),
                        Expanded(
                          child: ListView(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            children: <Widget>[
                              if (start != null &&
                                  start.briefing.isNotEmpty &&
                                  !_isMathQuestionOnly) ...<Widget>[
                                StudySurfaceCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Scenario', style: TextStyle(fontWeight: FontWeight.w800, color: textSecondary, fontSize: 12)),
                                      const SizedBox(height: 6),
                                      TutorMarkdownBody(text: start.briefing),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              ...?runner?.responses.map((PracticeLabQuestionResponse response) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: StudySurfaceCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          response.skipped ? 'Skipped' : 'Answered',
                                          style: TextStyle(fontWeight: FontWeight.w800, color: textSecondary, fontSize: 12),
                                        ),
                                        const SizedBox(height: 6),
                                        TutorMarkdownBody(text: response.question.prompt),
                                        if (!response.skipped && response.answer.isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 8),
                                          Text('Your answer', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 11)),
                                          const SizedBox(height: 4),
                                          Text(response.answer),
                                        ],
                                        if (response.feedback != null && response.feedback!.trim().isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 8),
                                          Text('Tutor feedback', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 11)),
                                          const SizedBox(height: 4),
                                          TutorMarkdownBody(text: response.feedback!),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (current != null)
                                StudySurfaceCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Question ${runner!.answeredCount + 1}',
                                        style: TextStyle(fontWeight: FontWeight.w800, color: textSecondary, fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      TutorMarkdownBody(text: current.prompt),
                                    ],
                                  ),
                                )
                              else if (runner != null && runner.isComplete)
                                StudySurfaceCard(
                                  child: Column(
                                    children: <Widget>[
                                      const Icon(Icons.check_circle_outline, size: 48, color: StudyColors.success),
                                      const SizedBox(height: 8),
                                      Text(
                                        'All ${runner.totalCount} questions answered!',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      FilledButton(onPressed: _loading ? null : () => _promptGrade(auto: true), child: const Text('Get my grade')),
                                    ],
                                  ),
                                ),
                              if (_loading && current != null)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                                ),
                            ],
                          ),
                        ),
                        _QuestionBar(
                          controller: _input,
                          enabled: !_loading && start != null && current != null,
                          holdingMic: _holdingMic,
                          hintsLeft: 3 - _hintsUsed,
                          usedHintsCount: _hints.length,
                          voiceReady: _voiceReady,
                          onSubmit: _submitAnswer,
                          onSkip: _skipQuestion,
                          onHint: _requestHint,
                          onReviewHints: _reviewHints,
                          onHoldStart: _startHoldToSpeak,
                          onHoldEnd: _stopHoldToSpeak,
                        ),
                      ],
                    ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.answered,
    required this.total,
    required this.target,
    required this.deferred,
    required this.difficulty,
  });

  final int answered;
  final int total;
  final int target;
  final int deferred;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : answered / total;
    return StudySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$answered of $total answered · $difficulty',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              if (deferred > 0)
                Text(
                  '$deferred skipped',
                  style: TextStyle(fontSize: 12, color: StudyColors.textSecondary(Theme.of(context).brightness)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          Text(
            '$target-question set · skip anytime and revisit later',
            style: TextStyle(fontSize: 11, color: StudyColors.textSecondary(Theme.of(context).brightness)),
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final int m = elapsed.inMinutes;
    final String s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: Text('$m:$s', style: TextStyle(fontWeight: FontWeight.w700, color: StudyColors.textSecondary(Theme.of(context).brightness))),
      ),
    );
  }
}

class _QuestionBar extends StatelessWidget {
  const _QuestionBar({
    required this.controller,
    required this.enabled,
    required this.holdingMic,
    required this.hintsLeft,
    required this.usedHintsCount,
    required this.voiceReady,
    required this.onSubmit,
    required this.onSkip,
    required this.onHint,
    required this.onReviewHints,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool holdingMic;
  final int hintsLeft;
  final int usedHintsCount;
  final bool voiceReady;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;
  final VoidCallback onHint;
  final VoidCallback onReviewHints;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: enabled ? onSkip : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Skip'),
                ),
                TextButton.icon(
                  onPressed: enabled && hintsLeft > 0 ? onHint : null,
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: Text('Hint ($hintsLeft)'),
                ),
                if (usedHintsCount > 0)
                  TextButton.icon(
                    onPressed: enabled ? onReviewHints : null,
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: Text('Used ($usedHintsCount)'),
                  ),
                if (voiceReady)
                  GestureDetector(
                    onLongPressStart: enabled ? (_) => onHoldStart() : null,
                    onLongPressEnd: enabled ? (_) => onHoldEnd() : null,
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(holdingMic ? Icons.mic : Icons.mic_none_outlined, color: holdingMic ? StudyColors.danger : null),
                    ),
                  ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your answer…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onSubmitted: enabled ? (_) => onSubmit() : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: enabled ? onSubmit : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.grade, required this.onDone});

  final SimulationGrade grade;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final bool passed = grade.score >= 70;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StudySurfaceCard(
          child: Column(
            children: <Widget>[
              Icon(passed ? Icons.emoji_events_rounded : Icons.school_rounded, size: 52, color: passed ? StudyColors.success : StudyColors.primary),
              const SizedBox(height: 12),
              Text('${grade.score}%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              TutorMarkdownBody(text: grade.summary),
              if (grade.hintsUsed > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Hints used: ${grade.hintsUsed}', style: TextStyle(color: textSecondary, fontSize: 12)),
                ),
            ],
          ),
        ),
        if (grade.criteriaScores.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Skill tracking', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...grade.criteriaScores.entries.map(
            (MapEntry<String, int> e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(e.key)),
                      Text('${e.value}%', style: TextStyle(fontWeight: FontWeight.w800, color: StudyColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: e.value / 100, minHeight: 6, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
          ),
        ],
        if (grade.strengths.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Strengths', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...grade.strengths.map(
            (String s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.check_circle_outline, size: 18, color: StudyColors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s)),
                ],
              ),
            ),
          ),
        ],
        if (grade.improvements.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Improve', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...grade.improvements.map(
            (String s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.arrow_circle_up_outlined, size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s)),
                ],
              ),
            ),
          ),
        ],
        if (grade.studyTopics.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Recommended study topics', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grade.studyTopics
                .map(
                  (String topic) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: StudyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(topic, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: StudyColors.primary)),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Improvement plan', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        StudySurfaceCard(child: TutorMarkdownBody(text: grade.improvementPlan)),
        const SizedBox(height: 20),
        FilledButton(onPressed: onDone, child: const Text('Done')),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StudySurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
