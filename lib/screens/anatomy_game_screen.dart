import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/anatomy_game_data.dart';
import '../models/anatomy_game.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../services/practice_lab_service.dart';
import '../theme/study_theme.dart';
import '../utils/diagram_question_runner.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/anatomy/anatomy_body_diagram.dart';
import '../widgets/anatomy/anatomy_game_hud.dart';
import '../widgets/ai_practice/ai_practice_avatar.dart';
import '../widgets/study_surface.dart';

/// Game-style anatomy lab: tap organs on a realistic diagram, earn XP, keep lives.
class AnatomyGameScreen extends StatefulWidget {
  const AnatomyGameScreen({super.key, required this.category, required this.lab});

  final PracticeLabCategory category;
  final PracticeLabType lab;

  @override
  State<AnatomyGameScreen> createState() => _AnatomyGameScreenState();
}

class _AnatomyGameScreenState extends State<AnatomyGameScreen> {
  late final DiagramQuestionRunner<AnatomyQuestion> _runner;
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
  bool _finished = false;
  int _finalScore = 0;

  AnatomyQuestion get _question => _runner.current!;

  AnatomyGameProgress get _progress => AnatomyGameProgress(
        round: _runner.answeredCount + 1,
        totalRounds: _runner.totalCount,
        score: _score,
        streak: _streak,
        lives: _lives,
        xp: _xp,
      );

  @override
  void initState() {
    super.initState();
    _runner = DiagramQuestionRunner<AnatomyQuestion>(
      AnatomyGameData.buildRoundDeck(labId: widget.lab.id),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    super.dispose();
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

  void _answerTap(AnatomyRegion region) {
    if (_showFeedback || _question.kind != AnatomyQuestionKind.tapTarget) return;
    _resolve(region.id == _question.targetRegionId, region.id);
  }

  void _answerChoice(String name) {
    if (_showFeedback || _question.kind != AnatomyQuestionKind.pickName) return;
    final AnatomyRegion? target = AnatomyGameData.regionById(_question.targetRegionId);
    _resolve(target?.name == name, _question.targetRegionId);
  }

  void _skipQuestion() {
    if (_showFeedback) return;
    setState(() {
      _runner.skipCurrent();
      _showFeedback = false;
      _lastCorrect = null;
      _feedbackRegionId = null;
      _selectedOption = null;
    });
    if (_runner.isComplete) {
      unawaited(_finishGame());
    }
  }

  void _resolve(bool correct, String regionId) {
    setState(() {
      _showFeedback = true;
      _lastCorrect = correct;
      _feedbackRegionId = regionId;
      if (correct) {
        _score += 1;
        _streak += 1;
        _xp += 15 + (_streak * 5);
      } else {
        _streak = 0;
        _lives = (_lives - 1).clamp(0, 3);
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _runner.answerCurrent();
      if (_lives <= 0 || _runner.isComplete) {
        unawaited(_finishGame());
        return;
      }
      setState(() {
        _showFeedback = false;
        _lastCorrect = null;
        _feedbackRegionId = null;
        _selectedOption = null;
      });
    });
  }

  Future<void> _finishGame() async {
    final int answered = _runner.answeredCount;
    final int percent = answered <= 0 ? 0 : ((_score / answered) * 100).round();
    final PracticeLabService labs = context.read<PracticeLabService>();
    await labs.saveAnatomyGameResult(
      category: widget.category,
      lab: widget.lab,
      score: percent,
      summary: 'Identified $_score of $answered structures correctly.',
      roundsPlayed: answered,
      xpEarned: _xp,
    );

    if (!mounted) return;
    setState(() {
      _finished = true;
      _finalScore = percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1F33),
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(widget.lab.title)),
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_bootError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lab.title)),
        body: Center(child: Text(_bootError!, textAlign: TextAlign.center)),
      );
    }

    if (_finished) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1F33),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _finalScore >= 70 ? Icons.emoji_events_rounded : Icons.science_rounded,
                  size: 64,
                  color: _finalScore >= 70 ? StudyColors.accent : StudyColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '$_finalScore%',
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / ${_runner.answeredCount} organs · $_xp XP earned',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                ),
                if (_lives > 0)
                  Text('Lives remaining: $_lives', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final AnatomyQuestion q = _question;
    final String coachLine = _showFeedback && _lastCorrect != null
        ? (_lastCorrect!
            ? 'Excellent! ${AnatomyGameData.regionById(_feedbackRegionId ?? '')?.funFact ?? 'You nailed that structure.'}'
            : 'Not quite — look at the highlighted region and try the next one.')
        : 'Tap the correct organ on the diagram. I\'m here if you need a hint!';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1F33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.lab.title),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _showFeedback ? null : _skipQuestion,
            icon: const Icon(Icons.skip_next_rounded, size: 18),
            label: const Text('Skip'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AvatarRole.teacher.accentColor.withValues(alpha: 0.42),
                  const Color(0xFF1A2F4A),
                ],
              ),
              border: Border.all(color: AvatarRole.teacher.accentColor.withValues(alpha: 0.35)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AvatarRole.teacher.accentColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                AiPracticeAvatar(
                  role: AvatarRole.teacher,
                  isSpeaking: _showFeedback,
                  emotion: _lastCorrect == true
                      ? AvatarEmotion.happy
                      : _lastCorrect == false
                          ? AvatarEmotion.concerned
                          : AvatarEmotion.neutral,
                  size: 88,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Dr. Atlas · Anatomy Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(height: 10),
                Text(
                  coachLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.4, fontSize: 13.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnatomyGameHud(progress: _progress),
          const SizedBox(height: 16),
          Text(
            q.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 340,
            child: AnatomyBodyDiagram(
              highlightRegionId: q.kind == AnatomyQuestionKind.pickName ? q.targetRegionId : null,
              feedbackRegionId: _feedbackRegionId,
              feedbackCorrect: _lastCorrect,
              pulse: q.kind == AnatomyQuestionKind.tapTarget && !_showFeedback,
              onRegionTap: _answerTap,
            ),
          ),
          if (q.kind == AnatomyQuestionKind.pickName) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: q.options.map((String option) {
                final bool selected = _selectedOption == option;
                final AnatomyRegion? target = AnatomyGameData.regionById(q.targetRegionId);
                final bool showResult = _showFeedback && option == target?.name;
                final bool showWrong = _showFeedback && selected && _lastCorrect == false;
                Color? bg;
                if (showResult) bg = StudyColors.success;
                if (showWrong) bg = StudyColors.danger;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: _showFeedback
                      ? null
                      : (bool _) {
                          setState(() => _selectedOption = option);
                          _answerChoice(option);
                        },
                  backgroundColor: bg ?? Colors.white.withValues(alpha: 0.08),
                  labelStyle: TextStyle(color: bg != null ? Colors.white : Colors.white, fontWeight: FontWeight.w700),
                );
              }).toList(),
            ),
          ],
          if (_showFeedback && _lastCorrect != null) ...<Widget>[
            const SizedBox(height: 16),
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
                          ? AnatomyGameData.regionById(_feedbackRegionId ?? '')?.funFact ?? 'Correct!'
                          : 'Not quite — study this region and try the next round.',
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
