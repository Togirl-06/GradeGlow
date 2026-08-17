import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/university_learning_engine.dart';
import '../university_lab_result.dart';
import '../workplace_immersion.dart';
import 'university_sim_factory.dart';
import 'university_sim_models.dart';

/// Briefing → scenario play → consequence board → supervisor hints → debrief.
abstract final class UniversitySimulationFlow {
  static Future<UniversityLabResult?> open({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
    String courseTitle = '',
    String topicTitle = '',
    int level = 2,
  }) {
    final SimBriefing briefing = UniversitySimFactory.fromLesson(
      link: link,
      subjectId: subjectId,
      courseTitle: courseTitle,
      topicTitle: topicTitle.isEmpty ? link.title : topicTitle,
      level: level,
    );
    return Navigator.of(context).push<UniversityLabResult>(
      MaterialPageRoute<UniversityLabResult>(
        builder: (_) => _SimBriefingScreen(briefing: briefing),
      ),
    );
  }
}

class _SimBriefingScreen extends StatelessWidget {
  const _SimBriefingScreen({required this.briefing});

  final SimBriefing briefing;

  @override
  Widget build(BuildContext context) {
    final WorkplaceSet set = WorkplaceSet.of(briefing.workplace);
    return Scaffold(
      backgroundColor: set.bgBottom,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: <Widget>[
            Text(
              set.placeName.toUpperCase(),
              style: TextStyle(
                color: set.accent,
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              briefing.labTitle,
              style: const TextStyle(
                fontFamily: 'Georgia',
                color: Colors.white,
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              briefing.courseLine,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 6),
            Text(
              UniversitySimLevels.label(briefing.level),
              style: TextStyle(color: set.accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            _fact('Role', briefing.role),
            _fact('Mission', briefing.mission),
            _fact('Difficulty', briefing.difficulty),
            _fact('Estimated time', '${briefing.minutes} minutes'),
            const SizedBox(height: 8),
            _fact('Equipment', briefing.equipment.join(' · ')),
            _fact('Skills practiced', briefing.skills.join(' · ')),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<UniversityLabResult>(
                      builder: (_) => _SimPlayScreen(briefing: briefing),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: set.accent,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text(
                  'ENTER LAB',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Leave station', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fact(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 15)),
        ],
      ),
    );
  }
}

class _SimPlayScreen extends StatefulWidget {
  const _SimPlayScreen({required this.briefing});

  final SimBriefing briefing;

  @override
  State<_SimPlayScreen> createState() => _SimPlayScreenState();
}

class _SimPlayScreenState extends State<_SimPlayScreen> {
  late final SimPlayState play;
  double _measure = 50;
  bool _scenarioGate = true;

  SimBriefing get b => widget.briefing;

  @override
  void initState() {
    super.initState();
    play = SimPlayState(briefing: b, startedAt: DateTime.now());
    if (b.level == 1) play.hintTier = 1;
  }

  WorkplaceSet get set => WorkplaceSet.of(b.workplace);

  String _hintText() {
    final SimStep s = play.step;
    switch (play.hintTier.clamp(0, 4)) {
      case 0:
        return 'Ask the supervisor if you are stuck. Answers are not free.';
      case 1:
        return s.hint1;
      case 2:
        return s.hint2;
      case 3:
        return s.hint3;
      default:
        return s.solution;
    }
  }

  void _askHint() {
    setState(() {
      if (play.hintTier < 4) {
        play.hintTier += 1;
        play.hintsUsed += 1;
      }
    });
  }

  void _resolve(bool ok, {String? extra}) {
    HapticFeedback.selectionClick();
    play.totalActs += 1;
    play.attemptsOnStep += 1;
    if (ok) {
      play.correctActs += 1;
      play.bump(play.step.successMeter, play.step.successDelta);
      play.alert = null;
      play.log.add(extra ?? play.step.successLog);
      play.attemptsOnStep = 0;
      if (play.stepIndex >= b.steps.length - 1) {
        play.complete = true;
      } else {
        play.stepIndex += 1;
        play.hintTier = b.level == 1 ? 1 : 0;
        _measure = 50;
      }
    } else {
      play.mistakes += 1;
      play.bump(play.step.failMeter, play.step.failDelta);
      play.alert = play.step.failAlert;
      play.log.add(play.step.failAlert);
      if (play.attemptsOnStep >= 3) {
        play.log.add('Supervisor overrode after repeated error. Continuing.');
        play.attemptsOnStep = 0;
        if (play.stepIndex >= b.steps.length - 1) {
          play.complete = true;
        } else {
          play.stepIndex += 1;
          play.hintTier = b.level == 1 ? 1 : 0;
          _measure = 50;
        }
      }
    }
    setState(() {});
    if (play.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<UniversityLabResult>(
            builder: (_) => _SimDebriefScreen(
              briefing: b,
              result: play.toResult(),
              log: List<String>.from(play.log),
              meters: List<SimMeter>.from(play.meters),
            ),
          ),
        );
      });
    }
  }

  void _tapSpot(SimHotspot h) => _resolve(h.correct, extra: 'Examined: ${h.label}.');

  void _confirmMeasure() {
    final SimStep s = play.step;
    final bool ok = _measure >= s.measureMin && _measure <= s.measureMax;
    _resolve(ok);
  }

  void _useTool(SimTool t) => _resolve(t.correct, extra: 'Used: ${t.label}.');

  @override
  Widget build(BuildContext context) {
    if (_scenarioGate) {
      return Scaffold(
        backgroundColor: set.bgBottom,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'LAB SUPERVISOR',
                  style: TextStyle(
                    color: set.accent,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  b.scenario,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => setState(() => _scenarioGate = false),
                    style: FilledButton.styleFrom(
                      backgroundColor: set.accent,
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text('BEGIN WORK', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final SimStep step = play.step;
    return Scaffold(
      backgroundColor: set.bgBottom,
      appBar: AppBar(
        backgroundColor: set.bgTop,
        foregroundColor: Colors.white,
        title: Text(set.placeName, style: const TextStyle(fontSize: 15)),
        actions: <Widget>[
          TextButton(
            onPressed: _askHint,
            child: Text('Supervisor', style: TextStyle(color: set.accent)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _meterBar(),
          if (play.alert != null)
            Container(
              width: double.infinity,
              color: const Color(0xFF4A1C1C),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                play.alert!,
                style: const TextStyle(color: Color(0xFFFFC9C9), fontWeight: FontWeight.w600),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                Text(
                  '${step.phase.toUpperCase()}  ·  ${play.stepIndex + 1}/${b.steps.length}',
                  style: TextStyle(
                    color: set.accent,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.objective,
                  style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (step.kind == SimStepKind.locate) _board(step),
                if (step.kind == SimStepKind.measure) _measurePanel(step),
                if (step.kind == SimStepKind.applyTool) _toolRack(step),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  color: set.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'SUPERVISOR',
                        style: TextStyle(
                          color: set.accent,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.level == 1 && play.hintTier == 0
                            ? step.hint1
                            : _hintText(),
                        style: const TextStyle(color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meterBar() {
    return Container(
      width: double.infinity,
      color: set.bgTop,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: play.meters
            .map(
              (SimMeter m) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${m.label} ${m.value.round()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: m.value / 100,
                        minHeight: 4,
                        color: m.value < m.warnBelow || m.value > m.warnAbove
                            ? const Color(0xFFE35D5D)
                            : set.accent,
                        backgroundColor: Colors.white12,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _board(SimStep step) {
    final bool guided = b.level == 1;
    return AspectRatio(
      aspectRatio: 1.35,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          return Container(
            color: set.surface,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(painter: _StationPainter(accent: set.accent)),
                ),
                ...step.hotspots.map((SimHotspot h) {
                  return Positioned(
                    left: h.x * c.maxWidth - 58,
                    top: h.y * c.maxHeight - 18,
                    width: 116,
                    child: OutlinedButton(
                      onPressed: () => _tapSpot(h),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: guided && h.correct ? set.accent : Colors.white38,
                          width: guided && h.correct ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        h.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, height: 1.2),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _measurePanel(SimStep step) {
    return Container(
      color: set.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${step.measureLabel}: ${_measure.round()} ${step.measureUnit}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _measure.clamp(0, 100),
            min: 0,
            max: 100,
            activeColor: set.accent,
            onChanged: (double v) => setState(() => _measure = v),
          ),
          if (b.level == 1)
            Text(
              'Protocol window ${step.measureMin.round()}–${step.measureMax.round()}',
              style: TextStyle(color: set.accent, fontSize: 12),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _confirmMeasure,
              style: FilledButton.styleFrom(
                backgroundColor: set.accent,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('COMMIT READING'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolRack(SimStep step) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: step.tools
          .map(
            (SimTool t) => SizedBox(
              width: 160,
              height: 56,
              child: OutlinedButton(
                onPressed: () => _useTool(t),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(t.label, textAlign: TextAlign.center),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StationPainter extends CustomPainter {
  _StationPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final Paint arc = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.62,
        height: size.height * 0.55,
      ),
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimDebriefScreen extends StatelessWidget {
  const _SimDebriefScreen({
    required this.briefing,
    required this.result,
    required this.log,
    required this.meters,
  });

  final SimBriefing briefing;
  final UniversityLabResult result;
  final List<String> log;
  final List<SimMeter> meters;

  @override
  Widget build(BuildContext context) {
    final WorkplaceSet set = WorkplaceSet.of(briefing.workplace);
    final int accuracy = result.conceptMasteryPercent;
    final int decide = ((result.clinicalReasoningScore) * 100).round();
    final int procedure = (100 - (result.hintsUsed * 8)).clamp(40, 100);
    final int thinking = ((result.clinicalReasoningScore * 0.9 + (result.passed ? 0.1 : 0)) * 100)
        .round()
        .clamp(0, 100);
    final int timeScore = result.secondsElapsed < 180
        ? 88
        : result.secondsElapsed < 420
            ? 76
            : 64;

    final String outcome = result.passed
        ? _winLine(briefing.domain)
        : 'Mission incomplete. The station is still live — repeat after review.';

    return Scaffold(
      backgroundColor: set.bgBottom,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
          children: <Widget>[
            Text(
              result.passed ? 'MISSION COMPLETE' : 'MISSION FAILED',
              style: TextStyle(
                color: set.accent,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              outcome,
              style: const TextStyle(
                fontFamily: 'Georgia',
                color: Colors.white,
                fontSize: 24,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'LAB PERFORMANCE',
              style: TextStyle(color: Colors.white54, letterSpacing: 1.3, fontSize: 11),
            ),
            const SizedBox(height: 8),
            _score('Accuracy', '$accuracy%'),
            _score('Decision-making', '$decide%'),
            _score('Procedure', '$procedure%'),
            _score('Critical thinking', '$thinking%'),
            _score('Time management', '$timeScore%'),
            _score('Hints used', '${result.hintsUsed}'),
            const SizedBox(height: 18),
            const Text('What you did well', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(result.coachingNotes.isNotEmpty ? result.coachingNotes.first : '',
                style: const TextStyle(color: Colors.white70, height: 1.4)),
            const SizedBox(height: 14),
            const Text('Where you struggled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(result.coachingNotes.length > 1 ? result.coachingNotes[1] : '',
                style: const TextStyle(color: Colors.white70, height: 1.4)),
            const SizedBox(height: 14),
            const Text('What you should review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              result.recommendedReview ?? briefing.courseLine,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 14),
            const Text('Professor\'s feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              result.coachingNotes.length > 3
                  ? result.coachingNotes[3]
                  : 'Work the procedure in order. The board punishes skipping.',
              style: const TextStyle(
                fontFamily: 'Georgia',
                color: Colors.white,
                height: 1.45,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 22),
            ...meters.map(
              (SimMeter m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${m.label}: ${m.value.round()}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(result),
                style: FilledButton.styleFrom(
                  backgroundColor: set.accent,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('RETURN TO LECTURE', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _score(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(k, style: const TextStyle(color: Colors.white70))),
          Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static String _winLine(SimDomain d) {
    switch (d) {
      case SimDomain.clinical:
        return 'Patient stabilized.';
      case SimDomain.chemistry:
        return 'Experiment successful. The unknown is identified and contained.';
      case SimDomain.physics:
        return 'Apparatus agrees with the model.';
      case SimDomain.business:
        return 'Company turnaround: the quarter is recoverable.';
      case SimDomain.finance:
        return 'Book survived the shock inside mandate.';
      case SimDomain.accounting:
        return 'Case resolved. The statements foot.';
      case SimDomain.marketing:
        return 'Campaign recovered after the miss.';
      case SimDomain.law:
        return 'Recommendation is on the record.';
      case SimDomain.engineering:
        return 'Site is back inside safety margin.';
      case SimDomain.computing:
        return 'Incident contained. Service restored.';
      case SimDomain.general:
        return 'Station objectives met.';
    }
  }
}
