import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lab_mission_celebration.dart';
import '../university_lab_result.dart';
import '../workplace_immersion.dart';
import 'practical_catalog.dart';
import 'practical_mission.dart';

/// Shared university practical runner — case → steps → professional WHY → score.
class UniversityPracticalLabScreen extends StatefulWidget {
  const UniversityPracticalLabScreen({
    super.key,
    required this.mission,
  });

  final UniversityPracticalMission mission;

  static WorkplaceKind workplaceForCourse(String courseId) {
    final String c = courseId.toLowerCase();
    if (c.contains('bio')) return WorkplaceKind.anatomyTheater;
    if (c.contains('chem')) return WorkplaceKind.chemBench;
    if (c.contains('phys')) return WorkplaceKind.physicsBay;
    if (c.contains('computer') || c.contains('cs')) {
      return WorkplaceKind.incidentBridge;
    }
    if (c.contains('law')) return WorkplaceKind.courtroom;
    if (c.contains('engin')) return WorkplaceKind.engSite;
    if (c.contains('nurs')) return WorkplaceKind.emergencyDept;
    if (c.contains('med') && !c.contains('lab')) return WorkplaceKind.hospitalWard;
    if (c.contains('bus')) return WorkplaceKind.warRoom;
    if (c.contains('fin')) return WorkplaceKind.financeDesk;
    if (c.contains('account')) return WorkplaceKind.auditRoom;
    if (c.contains('market')) return WorkplaceKind.marketingStudio;
    if (c.contains('econ')) return WorkplaceKind.policyOffice;
    if (c.contains('pharm')) return WorkplaceKind.pharmacyCounter;
    if (c.contains('mls') || c.contains('lab_science')) return WorkplaceKind.mlsBench;
    if (c.contains('psych')) return WorkplaceKind.researchLab;
    if (c.contains('math')) return WorkplaceKind.mathStudio;
    if (c.contains('cyber')) return WorkplaceKind.soc;
    return WorkplaceKind.warRoom;
  }

  static Future<UniversityLabResult?> open(
    BuildContext context, {
    required UniversityPracticalMission mission,
  }) {
    return openImmersive(context, mission: mission);
  }

  static Future<UniversityLabResult?> openCourse(
    BuildContext context, {
    required String courseId,
  }) {
    final UniversityPracticalMission? m =
        UniversityPracticalCatalog.forCourse(courseId);
    if (m == null) return Future<UniversityLabResult?>.value();
    return openImmersive(context, mission: m);
  }

  /// Entrance gate, then lab that returns a board score.
  static Future<UniversityLabResult?> openImmersive(
    BuildContext context, {
    required UniversityPracticalMission mission,
  }) async {
    final WorkplaceKind kind = workplaceForCourse(mission.courseId);
    final WorkplaceSet set = WorkplaceSet.of(kind);
    final bool? entered = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (BuildContext gateCtx, __, ___) => WorkplaceEntranceGate(
          set: set,
          onEnter: () {
            Navigator.of(gateCtx).pop(true);
          },
        ),
        transitionsBuilder: (_, Animation<double> a, __, Widget child) {
          return FadeTransition(opacity: a, child: child);
        },
      ),
    );
    if (entered != true || !context.mounted) return null;
    return Navigator.of(context).push<UniversityLabResult>(
      MaterialPageRoute<UniversityLabResult>(
        builder: (_) => UniversityPracticalLabScreen(mission: mission),
      ),
    );
  }

  @override
  State<UniversityPracticalLabScreen> createState() =>
      _UniversityPracticalLabScreenState();
}

class _UniversityPracticalLabScreenState
    extends State<UniversityPracticalLabScreen> {
  bool _accepted = false;
  int _stepIndex = 0;
  bool _onViva = false;
  int _correct = 0;
  bool _vivaCorrect = false;
  bool _itemDone = false;
  int? _choice;
  String? _coach;
  final Stopwatch _clock = Stopwatch();

  UniversityPracticalMission get m => widget.mission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBriefing());
  }

  Future<void> _showBriefing() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${m.briefingTitle} · ${m.emoji}',
                style: TextStyle(
                  color: m.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                m.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Role: ${m.role}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                m.briefingBody,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                m.uniqueHook,
                style: TextStyle(
                  color: m.accent,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: m.accent,
                  foregroundColor: const Color(0xFF04110C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ACCEPT CASE · ENTER PRACTICAL',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted) {
      setState(() => _accepted = true);
      _clock.start();
    }
  }

  void _answer(int choice) {
    if (_itemDone) return;
    HapticFeedback.selectionClick();
    if (_onViva) {
      final bool ok = choice == m.vivaCorrectIndex;
      setState(() {
        _choice = choice;
        _itemDone = true;
        _vivaCorrect = ok;
        if (ok) _correct += 1;
        _coach = ok
            ? 'Professional reasoning locked.'
            : 'Not board-ready — re-read the case tradeoffs.';
      });
      return;
    }

    final PracticalStep step = m.steps[_stepIndex];
    final bool ok = choice == step.correctIndex;
    setState(() {
      _choice = choice;
      _itemDone = true;
      if (ok) _correct += 1;
      _coach = ok ? step.coachCorrect : step.coachWrong;
    });
  }

  void _next() {
    if (_onViva) {
      _finish();
      return;
    }
    if (_stepIndex < m.steps.length - 1) {
      setState(() {
        _stepIndex += 1;
        _itemDone = false;
        _choice = null;
        _coach = null;
      });
      return;
    }
    setState(() {
      _onViva = true;
      _itemDone = false;
      _choice = null;
      _coach = null;
    });
  }

  Future<void> _finish() async {
    _clock.stop();
    final int total = m.steps.length + 1;
    final double accuracy = (_correct / total).clamp(0.0, 1.0);
    final double clinical =
        _vivaCorrect ? 1.0 : (_correct / total).clamp(0.0, 0.6);
    final UniversityLabResult result = UniversityLabResult(
      accuracy: (accuracy * 0.65) + (clinical * 0.35),
      identifyCorrect: _correct,
      identifyAttempts: total,
      viewsVisited: 3,
      labelDrillComplete: true,
      coachingNotes: <String>[
        _vivaCorrect
            ? 'Professional viva passed — you defended the WHY.'
            : 'Viva incomplete — competitors stop at quizzes; you must defend reasoning.',
        'Score $_correct/$total decisions correct.',
      ],
      xpEarned: accuracy >= 0.85
          ? 200
          : accuracy >= 0.7
              ? 150
              : 90,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: accuracy >= 0.8 ? m.badgeId : null,
      clinicalSolved: _vivaCorrect,
      clinicalReasoningScore: clinical,
    );
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'PRACTICAL PASSED'
          : (result.passed ? 'PRACTICAL COMPLETE' : 'PRACTICAL NEEDS RETRY'),
      accentLabel: m.role,
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    if (!_accepted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E14),
        body: Center(child: CircularProgressIndicator(color: m.accent)),
      );
    }

    final String phase = _onViva
        ? 'PROFESSIONAL VIVA'
        : m.steps[_stepIndex].phaseLabel;
    final String prompt =
        _onViva ? m.vivaPrompt : m.steps[_stepIndex].prompt;
    final List<String> options =
        _onViva ? m.vivaOptions : m.steps[_stepIndex].options;
    final int correct =
        _onViva ? m.vivaCorrectIndex : m.steps[_stepIndex].correctIndex;
    final int progressIndex = _onViva ? m.steps.length : _stepIndex;
    final int progressTotal = m.steps.length + 1;

    final WorkplaceSet set = WorkplaceSet.of(
      UniversityPracticalLabScreen.workplaceForCourse(m.courseId),
    );

    return WorkplaceImmersionShell(
      set: set,
      titleOverride: '${m.emoji} ${m.title}',
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LinearProgressIndicator(
            value: (progressIndex + (_itemDone ? 1 : 0)) / progressTotal,
            backgroundColor: Colors.white12,
            color: m.accent,
            minHeight: 4,
          ),
          const SizedBox(height: 10),
          Text(
            'Role: ${m.role}',
            style: TextStyle(
              color: set.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            m.briefingBody,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
              fontSize: 13,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: <Widget>[
                Text(
                  phase,
                  style: TextStyle(
                    color: m.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ...List<Widget>.generate(options.length, (int i) {
                  Color border = Colors.white24;
                  if (_itemDone && i == correct) border = m.accent;
                  if (_itemDone && _choice == i && i != correct) {
                    border = Colors.redAccent;
                  }
                  if (!_itemDone && _choice == i) border = m.accent;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: _itemDone ? null : () => _answer(i),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: border),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(14),
                      ),
                      child: Text(options[i]),
                    ),
                  );
                }),
                if (_coach != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    _coach!,
                    style: TextStyle(
                      color: m.accent.withValues(alpha: 0.95),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_itemDone)
            FilledButton(
              onPressed: _next,
              style: FilledButton.styleFrom(
                backgroundColor: m.accent,
                foregroundColor: const Color(0xFF04110C),
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                _onViva ? 'SUBMIT BOARD SCORE' : 'CONTINUE',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
