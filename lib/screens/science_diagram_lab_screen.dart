import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/science_diagram_catalog.dart';
import '../models/anatomy_game.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_topic.dart';
import '../models/science_diagram.dart';
import '../models/visual_learning_lab.dart';
import '../services/practice_lab_service.dart';
import '../theme/study_theme.dart';
import '../widgets/practice_lab/practice_lab_intro_panel.dart';
import '../utils/diagram_question_runner.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/anatomy/anatomy_game_hud.dart';
import '../widgets/science/science_diagram_canvas.dart';
import '../widgets/study_surface.dart';

/// Diagram labeling lab — tap structures, match names, earn XP.
class ScienceDiagramLabScreen extends StatefulWidget {
  const ScienceDiagramLabScreen({
    super.key,
    required this.category,
    required this.lab,
    required this.subjectId,
    required this.courseId,
    required this.topic,
    this.diagramId,
    this.useTypeEntry = false,
    this.scoreCategories = const <VisualLabScoreCategory>[
      VisualLabScoreCategory.accuracy,
      VisualLabScoreCategory.speed,
    ],
    this.environmentConfig,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final String subjectId;
  final String courseId;
  final PracticeLabTopic topic;
  final String? diagramId;
  final bool useTypeEntry;
  final List<VisualLabScoreCategory> scoreCategories;
  final VisualLabEnvironmentConfig? environmentConfig;

  @override
  State<ScienceDiagramLabScreen> createState() => _ScienceDiagramLabScreenState();
}

class _ScienceDiagramLabScreenState extends State<ScienceDiagramLabScreen> {
  late final ScienceDiagram _diagram;
  late final DiagramQuestionRunner<ScienceDiagramQuestion> _runner;
  int _score = 0;
  int _streak = 0;
  int _lives = 3;
  int _xp = 0;
  bool _booting = true;
  bool _showFeedback = false;
  bool? _lastCorrect;
  String? _feedbackRegionId;
  String? _selectedOption;
  String? _bootError;
  bool _awaitingTypeEntry = false;
  String? _aiMistakeNote;
  final TextEditingController _typeController = TextEditingController();
  final DateTime _startedAt = DateTime.now();
  bool _finished = false;
  int _finalScore = 0;
  int _finalAccuracy = 0;
  int _finalSpeed = 0;
  bool _sessionStarted = false;
  bool _pendingAdvance = false;
  Timer? _advanceTimer;
  final List<String> _missedLabels = <String>[];

  ScienceDiagramQuestion get _question => _runner.current!;

  AnatomyGameProgress get _hudProgress => AnatomyGameProgress(
        round: _runner.answeredCount + 1,
        totalRounds: _runner.totalCount,
        score: _score,
        streak: _streak,
        lives: _lives,
        xp: _xp,
      );

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _typeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.diagramId != null) {
      _diagram = ScienceDiagramCatalog.diagramById(widget.diagramId!) ??
          ScienceDiagramCatalog.resolveForTopic(
            subjectId: widget.subjectId,
            courseId: widget.courseId,
            topicId: widget.topic.id,
            topicName: widget.topic.name,
          );
    } else {
      _diagram = ScienceDiagramCatalog.resolveForTopic(
        subjectId: widget.subjectId,
        courseId: widget.courseId,
        topicId: widget.topic.id,
        topicName: widget.topic.name,
      );
    }
    _runner = DiagramQuestionRunner<ScienceDiagramQuestion>(
      ScienceDiagramCatalog.buildRoundDeck(
        diagram: _diagram,
        seed: widget.lab.id,
        preferTypeEntry: widget.useTypeEntry,
        difficultyLabel: widget.lab.difficulty,
        topicId: widget.topic.id,
        topicName: widget.topic.name,
        subjectId: widget.subjectId,
        courseId: widget.courseId,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final PracticeLabService labs = context.read<PracticeLabService>();
    if (!await labs.canStartSimulation()) {
      if (!mounted) return;
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.practiceLabs);
      if (mounted) Navigator.pop(context);
      return;
    }
    try {
      await labs.consumeSimulationSlot();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bootError = StudyMessenger.clean(error);
        _booting = false;
      });
      return;
    }
    if (mounted) setState(() => _booting = false);
  }

  void _answerTap(ScienceDiagramRegion region) {
    if (_showFeedback) return;
    if (_question.kind == ScienceDiagramQuestionKind.tapTarget) {
      _resolve(region.id == _question.targetRegionId, region.id);
      return;
    }
    if (_question.kind == ScienceDiagramQuestionKind.typeName) {
      if (region.id != _question.targetRegionId) {
        _resolve(false, region.id);
        return;
      }
      setState(() {
        _awaitingTypeEntry = true;
        _feedbackRegionId = region.id;
      });
    }
  }

  void _submitTypedName() {
    if (_showFeedback || _question.kind != ScienceDiagramQuestionKind.typeName) return;
    final ScienceDiagramRegion? target = ScienceDiagramCatalog.regionById(_diagram, _question.targetRegionId);
    if (target == null) return;
    final bool correct = _namesMatch(_typeController.text, target.name);
    _resolve(correct, _question.targetRegionId);
  }

  bool _namesMatch(String typed, String expected) {
    final String a = typed.trim().toLowerCase();
    final String b = expected.trim().toLowerCase();
    if (a == b) return true;
    if (a.isEmpty) return false;
    return b.contains(a) || a.contains(b.split(' ').first);
  }

  void _answerChoice(String name) {
    if (_showFeedback || _question.kind != ScienceDiagramQuestionKind.pickName) return;
    final ScienceDiagramRegion? target = ScienceDiagramCatalog.regionById(_diagram, _question.targetRegionId);
    _resolve(target?.name == name, _question.targetRegionId);
  }

  void _resolve(bool correct, String regionId) {
    final ScienceDiagramRegion? target = ScienceDiagramCatalog.regionById(_diagram, _question.targetRegionId);
    final ScienceDiagramRegion? picked = ScienceDiagramCatalog.regionById(_diagram, regionId);

    setState(() {
      _showFeedback = true;
      _lastCorrect = correct;
      _feedbackRegionId = regionId;
      _aiMistakeNote = null;
      _pendingAdvance = true;
      if (correct) {
        _score += 1;
        _streak += 1;
        _xp += 15 + (_streak * 5);
      } else {
        _streak = 0;
        _lives = (_lives - 1).clamp(0, 3);
        final ScienceDiagramRegion? target = ScienceDiagramCatalog.regionById(_diagram, _question.targetRegionId);
        if (target != null && !_missedLabels.contains(target.name)) {
          _missedLabels.add(target.name);
        }
      }
    });

    if (!correct && target != null) {
      final String wrongLabel = picked?.name ?? _selectedOption ?? _typeController.text;
      context.read<PracticeLabService>().explainLabelingMistake(
            diagramTitle: _diagram.title,
            correctLabel: target.name,
            studentChoice: wrongLabel.isEmpty ? 'unknown structure' : wrongLabel,
            subjectName: widget.category.name,
          ).then((String note) {
        if (mounted && _showFeedback && _lastCorrect == false) {
          setState(() => _aiMistakeNote = note);
        }
      });
    }
    _scheduleAutoAdvance();
  }

  void _skipQuestion() {
    if (_showFeedback || _pendingAdvance) return;
    _advanceTimer?.cancel();
    setState(() {
      _runner.skipCurrent();
      _showFeedback = false;
      _lastCorrect = null;
      _feedbackRegionId = null;
      _selectedOption = null;
      _awaitingTypeEntry = false;
      _typeController.clear();
      _aiMistakeNote = null;
      _pendingAdvance = false;
    });
    if (_runner.isComplete) {
      unawaited(_finish());
    }
  }

  void _resetQuestionUi() {
    _showFeedback = false;
    _lastCorrect = null;
    _feedbackRegionId = null;
    _selectedOption = null;
    _awaitingTypeEntry = false;
    _typeController.clear();
    _aiMistakeNote = null;
    _pendingAdvance = false;
  }

  void _scheduleAutoAdvance() {
    _advanceTimer?.cancel();
    final int delayMs = _lastCorrect == true
        ? 850
        : (_lives <= 0 || _runner.isComplete ? 2000 : 1600);
    _advanceTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && _pendingAdvance) _continueToNext();
    });
  }

  void _continueToNext() {
    _advanceTimer?.cancel();
    if (!_pendingAdvance) return;
    _runner.answerCurrent();
    _pendingAdvance = false;
    if (_lives <= 0 || _runner.isComplete) {
      unawaited(_finish());
      return;
    }
    setState(_resetQuestionUi);
  }

  Future<void> _finish() async {
    final VisualLabScoreBreakdown scores = VisualLabScoreBreakdown.fromSession(
      correct: _score,
      total: _runner.answeredCount,
      elapsed: DateTime.now().difference(_startedAt),
      categories: widget.scoreCategories,
      bonusPoints: _streak > 2 ? 5 : 0,
    );
    final PracticeLabService labs = context.read<PracticeLabService>();
    await labs.saveVisualLabResult(
      category: widget.category,
      lab: widget.lab,
      activityTitle: _diagram.title,
      activityType: VisualLabActivityType.labeling,
      scoreBreakdown: scores,
      summary: 'Labeled $_score of ${_runner.answeredCount} structures on ${_diagram.title}.',
      roundsPlayed: _runner.answeredCount,
      xpEarned: _xp,
    );
    if (!mounted) return;
    setState(() {
      _finished = true;
      _finalScore = scores.overall;
      _finalAccuracy = scores.accuracy;
      _finalSpeed = scores.speed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_bootError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.name)),
        body: Center(child: Text(_bootError!, textAlign: TextAlign.center)),
      );
    }

    if (_finished) {
      final String headline = _finalScore >= 85
          ? 'Excellent work!'
          : _finalScore >= 70
              ? 'Solid session'
              : 'Keep practicing';
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _finalScore >= 70 ? Icons.emoji_events_rounded : Icons.biotech_rounded,
                  size: 64,
                  color: _finalScore >= 70 ? StudyColors.success : StudyColors.primary,
                ),
                const SizedBox(height: 12),
                Text(headline, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  '$_finalScore%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: StudyColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accuracy $_finalAccuracy% · Speed $_finalSpeed%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_score / ${_runner.answeredCount} labels · ${_diagram.title} · $_xp XP',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_missedLabels.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    'Review: ${_missedLabels.take(4).join(', ')}${_missedLabels.length > 4 ? '…' : ''}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Back to activities', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_sessionStarted) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.name)),
        body: PracticeLabIntroPanel(
          title: _diagram.title,
          subtitle: '${widget.topic.name} · ${widget.lab.difficulty} diagram labeling',
          leadingEmoji: '🔬',
          objectives: <String>[
            'Identify structures on the ${_diagram.title.toLowerCase()}',
            'Use precise anatomical and scientific terminology',
            'Build accuracy with instant AI feedback on mistakes',
          ],
          sessionFacts: <String>[
            '${_runner.totalCount} unique labels',
            'Skip to revisit later',
            widget.lab.difficulty,
            '3 lives',
            'Zoom & pan',
          ],
          onStart: () => setState(() => _sessionStarted = true),
        ),
      );
    }

    if (_runner.current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ScienceDiagramQuestion q = _question;
    final ScienceDiagramRegion? feedbackRegion =
        _feedbackRegionId == null ? null : ScienceDiagramCatalog.regionById(_diagram, _feedbackRegionId!);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.topic.name, style: const TextStyle(fontSize: 16)),
            Text(_diagram.title, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _showFeedback || _pendingAdvance ? null : _skipQuestion,
            icon: const Icon(Icons.skip_next_rounded, size: 18),
            label: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: <Widget>[
                  if (widget.environmentConfig != null) ...<Widget>[
                    _EnvironmentBanner(config: widget.environmentConfig!),
                    const SizedBox(height: 10),
                  ],
                  AnatomyGameHud(progress: _hudProgress),
                  const SizedBox(height: 12),
                  Text(
                    q.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (_diagram.usesAnatomyAsset) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Pinch to zoom · tap the correct structure',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 280,
                    child: ScienceDiagramCanvas(
                      diagram: _diagram,
                      highlightRegionId: q.kind == ScienceDiagramQuestionKind.pickName || q.kind == ScienceDiagramQuestionKind.typeName
                          ? q.targetRegionId
                          : null,
                      feedbackRegionId: _feedbackRegionId,
                      feedbackCorrect: _lastCorrect,
                      pulse: (q.kind == ScienceDiagramQuestionKind.tapTarget || q.kind == ScienceDiagramQuestionKind.typeName) &&
                          !_showFeedback,
                      onRegionTap: _answerTap,
                    ),
                  ),
                  if (q.kind == ScienceDiagramQuestionKind.typeName && _awaitingTypeEntry && !_showFeedback) ...<Widget>[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _typeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type the structure name…',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          onPressed: _submitTypedName,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitTypedName(),
                    ),
                  ],
                  if (_showFeedback && _lastCorrect != null) ...<Widget>[
                    const SizedBox(height: 12),
                    StudySurfaceCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            _lastCorrect! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: _lastCorrect! ? StudyColors.success : StudyColors.danger,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _lastCorrect!
                                  ? feedbackRegion?.funFact ?? 'Correct!'
                                  : _aiMistakeNote ??
                                      'Not quite — the correct label is ${ScienceDiagramCatalog.regionById(_diagram, _question.targetRegionId)?.name ?? 'shown above'}.',
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (q.kind == ScienceDiagramQuestionKind.pickName)
              _PickNameOptions(
                options: q.options,
                selectedOption: _selectedOption,
                showFeedback: _showFeedback,
                lastCorrect: _lastCorrect,
                correctName: ScienceDiagramCatalog.regionById(_diagram, q.targetRegionId)?.name,
                onPick: (String option) {
                  setState(() => _selectedOption = option);
                  _answerChoice(option);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PickNameOptions extends StatelessWidget {
  const _PickNameOptions({
    required this.options,
    required this.selectedOption,
    required this.showFeedback,
    required this.lastCorrect,
    required this.correctName,
    required this.onPick,
  });

  final List<String> options;
  final String? selectedOption;
  final bool showFeedback;
  final bool? lastCorrect;
  final String? correctName;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'SELECT THE CORRECT LABEL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((String option) {
            final bool selected = selectedOption == option;
            final bool showResult = showFeedback && option == correctName;
            final bool showWrong = showFeedback && selected && lastCorrect == false;
            Color border = Colors.white24;
            Color bg = Colors.white.withValues(alpha: 0.08);
            if (showResult) {
              border = StudyColors.success;
              bg = StudyColors.success.withValues(alpha: 0.25);
            } else if (showWrong) {
              border = StudyColors.danger;
              bg = StudyColors.danger.withValues(alpha: 0.25);
            } else if (selected) {
              border = StudyColors.primary;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: showFeedback ? null : () => onPick(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EnvironmentBanner extends StatelessWidget {
  const _EnvironmentBanner({required this.config});

  final VisualLabEnvironmentConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: config.gradient),
        border: Border.all(color: config.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Text(config.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(config.title, style: TextStyle(color: config.accent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                Text(config.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
