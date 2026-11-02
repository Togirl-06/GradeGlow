import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/coding_languages.dart';
import '../data/practice_lab_question_bank.dart';
import '../config/app_config.dart';
import '../models/ai_practice_mode.dart';
import '../models/leetcode_problem.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_question.dart';
import '../models/practice_lab_topic.dart';
import '../utils/practice_lab_question_runner.dart';
import '../services/leetcode_debug_judge.dart';
import '../services/practice_lab_service.dart';
import '../services/subscription_service.dart';
import '../services/tutor_voice_service.dart';
import '../theme/leetcode_theme.dart';
import '../utils/network_reachability.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/leetcode/leetcode_problem_panel.dart';
import '../widgets/practice_lab/used_hints_sheet.dart';
import '../widgets/tutor_markdown_body.dart';

/// LeetCode-style coding interview session with AI interviewer, voice, hints, and live scoring.
class LeetcodePracticeSessionScreen extends StatefulWidget {
  const LeetcodePracticeSessionScreen({
    super.key,
    required this.category,
    required this.lab,
    required this.topic,
    required this.area,
    required this.difficulty,
    this.courseName,
    this.subjectId,
    this.courseId,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final PracticeLabTopic topic;
  final PracticeLabTopicArea area;
  final PracticeDifficulty difficulty;
  final String? courseName;
  final String? subjectId;
  final String? courseId;

  @override
  State<LeetcodePracticeSessionScreen> createState() => _LeetcodePracticeSessionScreenState();
}

class _LeetcodePracticeSessionScreenState extends State<LeetcodePracticeSessionScreen> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _answer = TextEditingController();
  final TutorVoiceService _voice = TutorVoiceService();

  SimulationStart? _start;
  SimulationGrade? _grade;
  PracticeLabQuestionRunner? _runner;
  final List<SimulationMessage> _history = <SimulationMessage>[];
  final List<String> _hints = <String>[];
  Map<String, int> _skillScores = <String, int>{};
  bool _loading = false;
  String? _error;
  int _liveScore = 0;
  int _hintsUsed = 0;
  bool _voiceReady = false;
  bool _autoSpeak = true;
  bool _holdingMic = false;
  int _tab = 0;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  CodingLanguage _language = CodingLanguage.defaultLanguage;
  String _starterTemplate = CodingLanguage.defaultLanguage.starter;
  String? _lastFeedback;
  LeetcodeRunResult? _lastRun;

  bool get _leetcodeMode => widget.lab.codeLab;

  @override
  void initState() {
    super.initState();
    _code.text = _starterTemplate;
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _initVoice() async {
    final VoiceCapabilities caps = await _voice.initialize();
    if (mounted) setState(() => _voiceReady = caps.anyReady);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voice.dispose();
    _code.dispose();
    _answer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String _formatElapsed(Duration d) {
    final String m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _boot() async {
    if (!mounted) return;
    if (!AppConfig.hasOpenAi) {
      setState(() => _error = 'OpenAI is not configured.');
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
      final SimulationStart start = _leetcodeMode
          ? SimulationStart(
              scenarioTitle: widget.topic.name,
              briefing: 'Coding problem set for ${widget.topic.name}.',
              aiRole: 'Code Judge',
              openingMessage: '',
            )
          : await labs.startSimulation(
              category: widget.category,
              lab: widget.lab,
              topicAreaName: widget.area.name,
              topicName: widget.topic.name,
            );
      final List<PracticeLabQuestion> questions = await labs.loadPracticeQuestions(
        category: widget.category,
        lab: widget.lab,
        courseName: widget.courseName,
        unitName: widget.area.name,
        topicName: widget.topic.name,
        subjectId: widget.subjectId,
        courseId: widget.courseId,
        topicId: widget.topic.id,
      );
      if (!mounted) return;
      setState(() {
        _start = start;
        _runner = PracticeLabQuestionRunner(questions);
        _history.clear();
        _loading = false;
      });
      _syncStarterForCurrentProblem();
      _startTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StudyMessenger.clean(error);
      });
    }
  }

  Future<void> _speak(String text) async {
    if (!_autoSpeak || !_voice.canSpeak) return;
    if (mounted) setState(() {});
    await _voice.speak(text);
    if (mounted) setState(() {});
  }

  Future<void> _pulseScore() async {
    if (_start == null) return;
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final List<SimulationMessage> history = _runner != null && _runner!.responses.isNotEmpty
          ? labs.historyFromQuestionResponses(start: _start!, responses: _runner!.responses)
          : _history;
      final PracticeLabLiveScore pulse = await labs.pulseLiveScore(
            category: widget.category,
            lab: widget.lab,
            start: _start!,
            history: history,
          );
      if (!mounted) return;
      setState(() {
        _liveScore = pulse.overall;
        if (pulse.criteriaScores.isNotEmpty) _skillScores = pulse.criteriaScores;
      });
    } catch (_) {}
  }

  String _messageWithLanguage(String text) => '[Language: ${_language.label}]\n$text';

  Future<void> _changeLanguage(CodingLanguage language) async {
    if (language.id == _language.id) return;
    final String current = _code.text;
    final bool isEmptyOrTemplate = current.trim().isEmpty || current == _starterTemplate;
    if (!isEmptyOrTemplate) {
      final bool? reset = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          backgroundColor: LeetCodeTheme.surface,
          title: const Text('Change language?', style: TextStyle(color: LeetCodeTheme.textPrimary)),
          content: Text(
            'Switching to ${language.label} will replace your current code with a starter template.',
            style: const TextStyle(color: LeetCodeTheme.textSecondary),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Switch'),
            ),
          ],
        ),
      );
      if (reset != true || !mounted) return;
    }
    setState(() {
      _language = language;
      final LeetcodeProblem? problem = _runner?.current?.leetcode;
      _starterTemplate = problem != null
          ? CodingLanguage.starterForProblem(problem, language)
          : language.starter;
      _code.value = TextEditingValue(
        text: _starterTemplate,
        selection: TextSelection.collapsed(offset: _starterTemplate.length),
      );
      _lastRun = null;
    });
  }

  void _syncStarterForCurrentProblem() {
    final PracticeLabQuestion? question = _runner?.current;
    if (!_hasTestRunner(question)) {
      _lastRun = null;
      if (_tab == 1) _tab = 0;
    }
    final LeetcodeProblem? problem = question?.leetcode;
    if (problem == null) return;
    _starterTemplate = CodingLanguage.starterForProblem(problem, _language);
    _code.text = _starterTemplate;
    _lastRun = null;
  }

  bool _isCodingQuestion(PracticeLabQuestion? question) => question?.needsCodeEditor ?? false;

  bool _hasTestRunner(PracticeLabQuestion? question) => question?.needsTestRunner ?? false;

  Future<void> _submitAnswer() async {
    if (_isCodingQuestion(_runner?.current)) {
      await _submitCoding();
    } else {
      await _submitConceptual();
    }
  }

  Future<void> _submitConceptual() async {
    final String text = _answer.text.trim();
    if (text.isEmpty || _loading || _start == null || _grade != null || _runner == null) return;
    final PracticeLabQuestion? question = _runner!.current;
    if (question == null) return;

    final PracticeLabService labs = context.read<PracticeLabService>();
    setState(() => _loading = true);
    try {
      final String feedback = await labs.feedbackPracticeAnswer(
        category: widget.category,
        topicName: widget.topic.name,
        question: question.prompt,
        studentAnswer: text,
        difficulty: widget.lab.difficulty,
      );
      if (!mounted) return;
      setState(() {
        _runner!.answerCurrent(text, feedback: feedback);
        _lastFeedback = _runner!.isComplete ? feedback : null;
        _answer.clear();
        _loading = false;
      });
      if (_runner!.isComplete) await _speak(feedback);
      if (_runner!.responses.length % 2 == 0) {
        await _pulseScore();
      }
      if (_runner!.isComplete && mounted) {
        StudyMessenger.showInfo(context, 'All questions complete — tap Submit to grade.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _submitCoding() async {
    final String text = _code.text.trim();
    if (text.isEmpty || _loading || _start == null || _grade != null || _runner == null) return;
    final PracticeLabQuestion? question = _runner!.current;
    if (question == null) return;

    final PracticeLabService labs = context.read<PracticeLabService>();
    final LeetcodeProblem? problem = question.leetcode;

    if (problem != null) {
      setState(() => _loading = true);
      try {
        final LeetcodeRunResult result = await labs.runLeetcodeTests(
          problem: problem,
          language: _language.label,
          code: text,
          submit: true,
        );
        if (!mounted) return;
        setState(() {
          _lastRun = result;
          _tab = 1;
          _loading = false;
        });
        if (result.accepted) {
          setState(() {
            _runner!.answerCurrent(text, feedback: result.feedback);
            final bool complete = _runner!.isComplete;
            _lastFeedback = complete ? result.feedback : null;
            if (!complete) {
              _syncStarterForCurrentProblem();
              _tab = 0;
            }
          });
          await _pulseScore();
          if (!mounted) return;
          if (_runner!.isComplete) {
            StudyMessenger.showInfo(context, 'All problems solved — tap Finish to see your score.');
          } else {
            StudyMessenger.showInfo(context, 'Accepted');
          }
        } else if (mounted) {
          StudyMessenger.showInfo(context, 'Wrong Answer — check test results and try again.');
        }
      } catch (error) {
        if (!mounted) return;
        if (problem.isDebug) {
          setState(() {
            _loading = false;
            _lastRun = LeetcodeDebugJudge.offlineFallback(
              problem: problem,
              includeHidden: true,
              accepted: false,
              feedback: 'Could not grade. Fix the bug and try again.',
            );
            _tab = 1;
          });
          StudyMessenger.showInfo(context, 'Graded offline. Keep fixing and submit again.');
        } else {
          setState(() => _loading = false);
          StudyMessenger.showError(context, error);
        }
      }
      return;
    }

    final String payload = _messageWithLanguage('Problem: ${question.prompt}\n\nSolution:\n$text');
    setState(() => _loading = true);
    try {
      final String reply = await labs.sendStudentMessage(
        category: widget.category,
        lab: widget.lab,
        start: _start!,
        history: _history,
        message: payload,
      );
      if (!mounted) return;
      setState(() {
        _history
          ..add(SimulationMessage.student(payload))
          ..add(SimulationMessage.ai(reply));
        _runner!.answerCurrent(text, feedback: reply);
        _lastFeedback = _runner!.isComplete ? reply : null;
        _code.text = _starterTemplate;
        _loading = false;
      });
      if (_runner!.isComplete) await _speak(reply);
      if (_runner!.responses.length % 2 == 0) {
        await _pulseScore();
      }
      if (_runner!.isComplete && mounted) {
        StudyMessenger.showInfo(context, 'All problems complete — tap Submit to grade.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  void _skipProblem() {
    if (_loading || _start == null || _grade != null || _runner == null) return;
    if (_runner!.current == null) return;
    setState(() {
      _runner!.skipCurrent();
      _code.text = _starterTemplate;
      _answer.clear();
      _lastFeedback = null;
      _lastRun = null;
    });
    _syncStarterForCurrentProblem();
    StudyMessenger.showInfo(context, 'Skipped — this problem will return later.');
  }

  void _reviewHints() {
    if (_hints.isEmpty) return;
    showUsedHintsSheet(context, hints: _hints, leetcode: true);
  }

  static const int _maxHints = 4;

  Future<void> _hint() async {
    if (_start == null || _grade != null || _loading || _hintsUsed >= _maxHints) return;
    final LeetcodeProblem? problem = _runner?.current?.leetcode;
    setState(() => _loading = true);
    try {
      final String hint;
      if (_leetcodeMode && problem != null) {
        hint = await context.read<PracticeLabService>().requestLeetcodeHint(
              problem: problem,
              hintLevel: _hintsUsed + 1,
              language: _language.label,
              currentCode: _code.text,
            );
      } else {
        hint = await context.read<PracticeLabService>().requestHint(
              category: widget.category,
              lab: widget.lab,
              start: _start!,
              history: _history,
            );
      }
      if (!mounted) return;
      setState(() {
        _hintsUsed += 1;
        _hints.add('Hint $_hintsUsed: $hint');
        _loading = false;
        _tab = _hasTestRunner(_runner?.current) ? 2 : 1;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _runTests() async {
    final LeetcodeProblem? problem = _runner?.current?.leetcode;
    final bool isDebug = problem?.isDebug ?? false;
    if (_code.text.trim().isEmpty) {
      StudyMessenger.showInfo(context, 'Write your solution before running tests.');
      return;
    }
    if (!isDebug && _code.text.trim() == _starterTemplate.trim()) {
      StudyMessenger.showInfo(context, 'Write your solution before running tests.');
      return;
    }
    if (problem == null) {
      await _submitCoding();
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    try {
      final LeetcodeRunResult result = await context.read<PracticeLabService>().runLeetcodeTests(
            problem: problem,
            language: _language.label,
            code: _code.text.trim(),
            submit: false,
          );
      if (!mounted) return;
      setState(() {
        _lastRun = result;
        _tab = 1;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (isDebug) {
        setState(() {
          _loading = false;
          _lastRun = LeetcodeDebugJudge.offlineFallback(
            problem: problem,
            includeHidden: false,
            accepted: false,
            feedback: 'Could not grade. Fix the bug and try again.',
          );
          _tab = 1;
        });
        StudyMessenger.showInfo(context, 'Graded offline. Keep fixing the bug.');
      } else {
        setState(() => _loading = false);
        StudyMessenger.showError(context, error);
      }
    }
  }

  Future<void> _submitSolution() async {
    if (_start == null || _grade != null) return;
    final PracticeLabService labs = context.read<PracticeLabService>();
    final int answered = _runner?.answeredCount ?? _history.where((SimulationMessage m) => m.isStudent).length;
    final bool hasDraft = _isCodingQuestion(_runner?.current)
        ? _code.text.trim().isNotEmpty && _code.text.trim() != _starterTemplate.trim()
        : _answer.text.trim().isNotEmpty;
    if (answered == 0 && !hasDraft) {
      StudyMessenger.showError(context, 'Answer at least one question before submitting.');
      return;
    }
    if (hasDraft && _runner?.current != null) await _submitAnswer();
    if (!mounted) return;
    final bool allDone = _runner?.isComplete ?? false;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: LeetCodeTheme.surface,
        title: Text(allDone ? 'Submit all problems?' : 'Submit early?', style: const TextStyle(color: LeetCodeTheme.textPrimary)),
        content: Text(
          allDone
              ? 'You completed all ${_runner!.totalCount} problems. Grade your session?'
              : 'You answered $answered of ${_runner?.totalCount ?? answered} problems. Grade now?',
          style: const TextStyle(color: LeetCodeTheme.textSecondary),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _timer?.cancel();
    await _voice.stopSpeaking();
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final List<SimulationMessage> gradeHistory = _runner != null && _runner!.responses.isNotEmpty
          ? labs.historyFromQuestionResponses(start: _start!, responses: _runner!.responses)
          : _history;
      final SimulationGrade grade = await labs.endAndGrade(
            category: widget.category,
            lab: widget.lab,
            start: _start!,
            history: gradeHistory,
            hintsUsed: _hintsUsed,
          );
      if (!mounted) return;
      setState(() {
        _grade = grade;
        _liveScore = grade.score;
        if (grade.criteriaScores.isNotEmpty) _skillScores = grade.criteriaScores;
        _loading = false;
      });
      await labs.refreshUsage();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _startMic() async {
    final SubscriptionService subs = context.read<SubscriptionService>();
    if (!await PremiumAccess.checkAndPrompt(context, subs, feature: PremiumFeature.voiceTutor)) return;
    setState(() => _holdingMic = true);
    final bool coding = _isCodingQuestion(_runner?.current);
    await _voice.startListening(
      onWords: (String words, bool isFinal) {
        if (!mounted) return;
        setState(() {
          if (coding) {
            _code.text = words;
          } else {
            _answer.text = words;
          }
        });
      },
      onListeningState: () {
        if (mounted) setState(() {});
      },
      onListeningStopped: () {
        if (mounted) setState(() => _holdingMic = false);
      },
    );
  }

  Future<void> _stopMic() async {
    await _voice.stopListening();
    if (!mounted) return;
    setState(() => _holdingMic = false);
    final bool coding = _isCodingQuestion(_runner?.current);
    final String draft = coding ? _code.text.trim() : _answer.text.trim();
    if (draft.isNotEmpty) await _submitAnswer();
  }

  @override
  Widget build(BuildContext context) {
    final SimulationStart? start = _start;
    final SimulationGrade? grade = _grade;
    final PracticeLabQuestionRunner? runner = _runner;
    final PracticeLabQuestion? current = runner?.current;
    final Color diffColor = LeetCodeTheme.difficultyColor(widget.lab.difficulty);
    final int targetCount = PracticeLabQuestionBank.targetCountForDifficulty(widget.lab.difficulty);
    final bool coding = _isCodingQuestion(current);
    final bool testRunner = _hasTestRunner(current);
    final LeetcodeProblem? leetcodeProblem = current?.leetcode;

    if (grade != null) {
      return Theme(
        data: LeetCodeTheme.darkTheme(),
        child: Scaffold(
          backgroundColor: LeetCodeTheme.background,
          appBar: AppBar(title: const Text('Submission Result')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: LeetCodeTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: grade.score >= 70 ? LeetCodeTheme.success : LeetCodeTheme.hard),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      grade.score >= 70 ? 'Accepted' : 'Wrong Answer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: grade.score >= 70 ? LeetCodeTheme.success : LeetCodeTheme.hard,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${grade.score}%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: LeetCodeTheme.textPrimary)),
                    const SizedBox(height: 8),
                    TutorMarkdownBody(text: grade.summary),
                  ],
                ),
              ),
              if (grade.criteriaScores.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                const Text('Skill breakdown', style: TextStyle(fontWeight: FontWeight.w800, color: LeetCodeTheme.textPrimary)),
                const SizedBox(height: 8),
                ...grade.criteriaScores.entries.map(
                  (MapEntry<String, int> e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SkillBar(label: e.key, score: e.value),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to problems', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: LeetCodeTheme.darkTheme(),
      child: Scaffold(
        backgroundColor: LeetCodeTheme.background,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  testRunner && leetcodeProblem != null ? leetcodeProblem.title : widget.topic.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (testRunner && leetcodeProblem != null
                          ? LeetCodeTheme.difficultyColor(leetcodeProblem.difficulty)
                          : diffColor)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  testRunner && leetcodeProblem != null
                      ? leetcodeProblem.difficulty
                      : LeetCodeTheme.difficultyLabel(widget.lab.difficulty),
                  style: TextStyle(
                    color: testRunner && leetcodeProblem != null
                        ? LeetCodeTheme.difficultyColor(leetcodeProblem.difficulty)
                        : diffColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (start != null && runner != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    '${runner.answeredCount + (current != null ? 1 : 0)}/${runner.totalCount}',
                    style: const TextStyle(fontSize: 12, color: LeetCodeTheme.textSecondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            if (start != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(child: Text(_formatElapsed(_elapsed), style: const TextStyle(fontSize: 12, color: LeetCodeTheme.textSecondary))),
              ),
            if (!testRunner && start != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Chip(
                  label: Text('$_liveScore%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  backgroundColor: LeetCodeTheme.surfaceElevated,
                  side: const BorderSide(color: LeetCodeTheme.border),
                ),
              ),
            if (!testRunner && _voiceReady)
              IconButton(
                icon: Icon(_autoSpeak ? Icons.volume_up : Icons.volume_off),
                onPressed: () => setState(() => _autoSpeak = !_autoSpeak),
              ),
          ],
        ),
        body: _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: LeetCodeTheme.hard)))
            : _loading && start == null
                ? const Center(child: CircularProgressIndicator(color: LeetCodeTheme.accent))
                : coding
                    ? _CodingSessionBody(
                        start: start,
                        runner: runner,
                        current: current,
                        targetCount: targetCount,
                        topicName: widget.topic.name,
                        topicId: widget.topic.id,
                        showTestRunner: testRunner,
                        tab: _tab,
                        hints: _hints,
                        hintsUsed: _hintsUsed,
                        skillScores: _skillScores,
                        lastFeedback: _lastFeedback,
                        lastRun: _lastRun,
                        code: _code,
                        starterTemplate: _starterTemplate,
                        language: _language,
                        loading: _loading,
                        holdingMic: _holdingMic,
                        voiceReady: _voiceReady,
                        onTab: (int t) => setState(() => _tab = t),
                        onChangeLanguage: _changeLanguage,
                        onSkip: _skipProblem,
                        onHint: _hint,
                        onReviewHints: _reviewHints,
                        onMic: _holdingMic ? _stopMic : _startMic,
                        onRun: _runTests,
                        onSubmit: _submitSolution,
                        onSubmitAnswer: _submitAnswer,
                      )
                    : _ConceptualSessionBody(
                        start: start,
                        runner: runner,
                        current: current,
                        targetCount: targetCount,
                        topicName: widget.topic.name,
                        tab: _tab,
                        hints: _hints,
                        hintsUsed: _hintsUsed,
                        skillScores: _skillScores,
                        lastFeedback: _lastFeedback,
                        answer: _answer,
                        loading: _loading,
                        holdingMic: _holdingMic,
                        voiceReady: _voiceReady,
                        onTab: (int t) => setState(() => _tab = t),
                        onSkip: _skipProblem,
                        onHint: _hint,
                        onReviewHints: _reviewHints,
                        onMic: _holdingMic ? _stopMic : _startMic,
                        onSubmitAnswer: _submitAnswer,
                        onSubmitSession: _submitSolution,
                      ),
      ),
    );
  }
}

class _ProblemHeader extends StatelessWidget {
  const _ProblemHeader({
    required this.start,
    required this.runner,
    required this.current,
    required this.targetCount,
    required this.topicName,
  });

  final SimulationStart? start;
  final PracticeLabQuestionRunner? runner;
  final PracticeLabQuestion? current;
  final int targetCount;
  final String topicName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (runner != null) ...<Widget>[
          Text(
            'Question ${runner!.answeredCount + 1} of ${runner!.totalCount}',
            style: const TextStyle(color: LeetCodeTheme.accent, fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: runner!.totalCount == 0 ? 0 : runner!.answeredCount / runner!.totalCount,
            minHeight: 4,
            backgroundColor: LeetCodeTheme.border,
            color: LeetCodeTheme.accent,
          ),
          const SizedBox(height: 10),
        ],
        Text(start?.scenarioTitle ?? topicName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: LeetCodeTheme.textPrimary)),
        const SizedBox(height: 8),
        TutorMarkdownBody(text: current?.prompt ?? ''),
        const SizedBox(height: 12),
        Text(
          '$targetCount-question set · skip anytime',
          style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _TabPanel extends StatelessWidget {
  const _TabPanel({
    required this.tab,
    required this.hints,
    required this.hintsUsed,
    required this.skillScores,
    required this.onTab,
    required this.child,
    this.showTestRunner = false,
    this.lastRun,
    this.runLoading = false,
  });

  final int tab;
  final List<String> hints;
  final int hintsUsed;
  final Map<String, int> skillScores;
  final ValueChanged<int> onTab;
  final Widget child;
  final bool showTestRunner;
  final LeetcodeRunResult? lastRun;
  final bool runLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: LeetCodeTheme.surface,
          child: Row(
            children: <Widget>[
              _TabButton(label: 'Description', selected: tab == 0, onTap: () => onTab(0)),
              if (showTestRunner)
                _TabButton(label: 'Test Result', selected: tab == 1, onTap: () => onTab(1))
              else
                _TabButton(label: 'Hints (${4 - hintsUsed})', selected: tab == 1, onTap: () => onTab(1)),
              _TabButton(label: showTestRunner ? 'Hints' : 'Skills', selected: tab == 2, onTap: () => onTab(2)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: LeetCodeTheme.surface,
            padding: const EdgeInsets.all(14),
            child: tab == 0
                ? SingleChildScrollView(child: child)
                : tab == 1
                    ? showTestRunner
                        ? LeetcodeTestResultsPanel(result: lastRun, loading: runLoading)
                        : ListView(
                            children: <Widget>[
                              if (hints.isEmpty)
                                const Text('Tap the Hint button for coaching (3 max).', style: TextStyle(color: LeetCodeTheme.textSecondary))
                              else
                                ...hints.map(
                                  (String h) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text('💡 $h', style: const TextStyle(color: LeetCodeTheme.consoleGreen, height: 1.4)),
                                  ),
                                ),
                            ],
                          )
                    : ListView(
                        children: showTestRunner
                            ? (hints.isEmpty
                                ? <Widget>[const Text('Hints appear here after you request them.', style: TextStyle(color: LeetCodeTheme.textSecondary))]
                                : hints
                                    .map(
                                      (String h) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Text('💡 $h', style: const TextStyle(color: LeetCodeTheme.consoleGreen, height: 1.4)),
                                      ),
                                    )
                                    .toList())
                            : (skillScores.isEmpty
                                ? <Widget>[const Text('Skills update as you practice.', style: TextStyle(color: LeetCodeTheme.textSecondary))]
                                : skillScores.entries
                                    .map(
                                      (MapEntry<String, int> e) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: _SkillBar(label: e.key, score: e.value),
                                      ),
                                    )
                                    .toList()),
                      ),
          ),
        ),
      ],
    );
  }
}

class _ConceptualSessionBody extends StatelessWidget {
  const _ConceptualSessionBody({
    required this.start,
    required this.runner,
    required this.current,
    required this.targetCount,
    required this.topicName,
    required this.tab,
    required this.hints,
    required this.hintsUsed,
    required this.skillScores,
    required this.lastFeedback,
    required this.answer,
    required this.loading,
    required this.holdingMic,
    required this.voiceReady,
    required this.onTab,
    required this.onSkip,
    required this.onHint,
    required this.onReviewHints,
    required this.onMic,
    required this.onSubmitAnswer,
    required this.onSubmitSession,
  });

  final SimulationStart? start;
  final PracticeLabQuestionRunner? runner;
  final PracticeLabQuestion? current;
  final int targetCount;
  final String topicName;
  final int tab;
  final List<String> hints;
  final int hintsUsed;
  final Map<String, int> skillScores;
  final String? lastFeedback;
  final TextEditingController answer;
  final bool loading;
  final bool holdingMic;
  final bool voiceReady;
  final ValueChanged<int> onTab;
  final VoidCallback onSkip;
  final VoidCallback onHint;
  final VoidCallback onReviewHints;
  final VoidCallback onMic;
  final VoidCallback onSubmitAnswer;
  final VoidCallback onSubmitSession;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !loading && start != null && current != null;

    return Column(
      children: <Widget>[
        Expanded(
          child: _TabPanel(
            tab: tab,
            hints: hints,
            hintsUsed: hintsUsed,
            skillScores: skillScores,
            onTab: onTab,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProblemHeader(
                  start: start,
                  runner: runner,
                  current: current,
                  targetCount: targetCount,
                  topicName: topicName,
                ),
                if (lastFeedback != null && (runner?.isComplete ?? false)) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text('Feedback', style: TextStyle(color: LeetCodeTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  TutorMarkdownBody(text: lastFeedback!),
                ],
                if (loading && current != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: LeetCodeTheme.accent))),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: LeetCodeTheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      OutlinedButton(onPressed: enabled ? onSkip : null, child: const Text('Skip')),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: loading ? null : onHint, child: Text('Hint (${4 - hintsUsed})')),
                      if (hints.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: loading ? null : onReviewHints, child: Text('Used (${hints.length})')),
                      ],
                      if (voiceReady) ...<Widget>[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: enabled ? onMic : null,
                          icon: Icon(holdingMic ? Icons.mic : Icons.mic_none_outlined, color: holdingMic ? LeetCodeTheme.hard : LeetCodeTheme.textSecondary),
                        ),
                      ],
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: loading ? null : onSubmitSession, child: const Text('End & Grade')),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: answer,
                        enabled: enabled,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: LeetCodeTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Type your answer…',
                          hintStyle: const TextStyle(color: LeetCodeTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: LeetCodeTheme.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: LeetCodeTheme.border)),
                        ),
                        onSubmitted: enabled ? (_) => onSubmitAnswer() : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: enabled ? onSubmitAnswer : null,
                      style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
                      child: const Icon(Icons.check_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CodingSessionBody extends StatelessWidget {
  const _CodingSessionBody({
    required this.start,
    required this.runner,
    required this.current,
    required this.targetCount,
    required this.topicName,
    required this.topicId,
    required this.showTestRunner,
    required this.tab,
    required this.hints,
    required this.hintsUsed,
    required this.skillScores,
    required this.lastFeedback,
    required this.lastRun,
    required this.code,
    required this.starterTemplate,
    required this.language,
    required this.loading,
    required this.holdingMic,
    required this.voiceReady,
    required this.onTab,
    required this.onChangeLanguage,
    required this.onSkip,
    required this.onHint,
    required this.onReviewHints,
    required this.onMic,
    required this.onRun,
    required this.onSubmit,
    required this.onSubmitAnswer,
  });

  final SimulationStart? start;
  final PracticeLabQuestionRunner? runner;
  final PracticeLabQuestion? current;
  final int targetCount;
  final String topicName;
  final String topicId;
  final bool showTestRunner;
  final int tab;
  final List<String> hints;
  final int hintsUsed;
  final Map<String, int> skillScores;
  final String? lastFeedback;
  final LeetcodeRunResult? lastRun;
  final TextEditingController code;
  final String starterTemplate;
  final CodingLanguage language;
  final bool loading;
  final bool holdingMic;
  final bool voiceReady;
  final ValueChanged<int> onTab;
  final ValueChanged<CodingLanguage> onChangeLanguage;
  final VoidCallback onSkip;
  final VoidCallback onHint;
  final VoidCallback onReviewHints;
  final VoidCallback onMic;
  final VoidCallback onRun;
  final VoidCallback onSubmit;
  final VoidCallback onSubmitAnswer;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !loading && start != null && current != null;
    final LeetcodeProblem? problem = current?.leetcode;

    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: _TabPanel(
            tab: tab,
            hints: hints,
            hintsUsed: hintsUsed,
            skillScores: skillScores,
            onTab: onTab,
            showTestRunner: showTestRunner,
            lastRun: lastRun,
            runLoading: loading && tab == 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (runner != null) ...<Widget>[
                  LinearProgressIndicator(
                    value: runner!.totalCount == 0 ? 0 : runner!.answeredCount / runner!.totalCount,
                    minHeight: 4,
                    backgroundColor: LeetCodeTheme.border,
                    color: LeetCodeTheme.accent,
                  ),
                  const SizedBox(height: 12),
                ],
                if (problem != null)
                  LeetcodeProblemPanel(
                    problem: problem,
                    problemIndex: (runner?.answeredCount ?? 0) + 1,
                    totalProblems: runner?.totalCount ?? targetCount,
                    acceptanceRate: LeetCodeTheme.acceptanceRate(problem.slug),
                  )
                else
                  _ProblemHeader(
                    start: start,
                    runner: runner,
                    current: current,
                    targetCount: targetCount,
                    topicName: topicName,
                  ),
                if (lastFeedback != null && (runner?.isComplete ?? false)) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text('Feedback', style: TextStyle(color: LeetCodeTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  TutorMarkdownBody(text: lastFeedback!),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: LeetCodeTheme.border),
        Expanded(
          flex: 3,
          child: Column(
            children: <Widget>[
              Expanded(
                child: LeetcodeCodeEditor(
                  controller: code,
                  language: language,
                  onChangeLanguage: onChangeLanguage,
                  enabled: enabled,
                  onSubmit: enabled ? onSubmitAnswer : null,
                  isDebug: problem?.isDebug ?? false,
                ),
              ),
              if (showTestRunner && lastRun != null)
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF161B22),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          lastRun!.accepted ? Icons.check_circle_outline : Icons.error_outline,
                          size: 16,
                          color: lastRun!.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lastRun!.accepted
                                ? 'All test cases passed'
                                : '${lastRun!.results.where((LeetcodeTestCaseResult r) => r.passed).length} / ${lastRun!.results.length} test cases passed',
                            style: TextStyle(
                              color: lastRun!.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onTab(1),
                          child: const Text('View', style: TextStyle(color: LeetCodeTheme.accent, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            color: LeetCodeTheme.surface,
            child: Row(
              children: <Widget>[
                OutlinedButton(onPressed: enabled ? onSkip : null, child: const Text('Skip')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: loading ? null : onHint, child: Text('Hint (${4 - hintsUsed})')),
                const Spacer(),
                if (showTestRunner) ...<Widget>[
                  OutlinedButton(
                    onPressed: loading ? null : onRun,
                    style: OutlinedButton.styleFrom(foregroundColor: LeetCodeTheme.consoleGreen),
                    child: const Text('Run'),
                  ),
                  const SizedBox(width: 8),
                ],
                FilledButton(
                  onPressed: loading ? null : onSubmitAnswer,
                  style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
                  child: Text(showTestRunner ? 'Submit' : 'Send', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: loading ? null : onSubmit,
                  child: const Text('Finish'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? LeetCodeTheme.accent : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? LeetCodeTheme.textPrimary : LeetCodeTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: const TextStyle(color: LeetCodeTheme.textPrimary, fontSize: 13))),
            Text('$score%', style: const TextStyle(color: LeetCodeTheme.accent, fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: LeetCodeTheme.border,
            color: LeetCodeTheme.accent,
          ),
        ),
      ],
    );
  }
}
