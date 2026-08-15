import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../career_labs/playable/cs_career/cs_career_playable.dart';
import '../career_labs/playable/engineering/engineering_playable.dart';
import '../career_labs/playable/law/law_playable.dart';
import 'lab_mission_celebration.dart';
import 'university_lab_result.dart';
import 'university_practical/practical_catalog.dart';
import 'university_practical/university_practical_lab.dart';
import 'workplace_immersion.dart';

/// Career showcases — walk into the real workplace, then run the graded viva.
abstract final class WinningCareerShowcases {
  static Future<void> openCs(BuildContext context) {
    return WorkplaceEntranceGate.openThen(
      context,
      kind: WorkplaceKind.incidentBridge,
      builder: () => const CsIncidentShowcaseLab(),
    );
  }

  static Future<void> openLaw(BuildContext context) {
    return WorkplaceEntranceGate.openThen(
      context,
      kind: WorkplaceKind.courtroom,
      builder: () => const LawCaseShowcaseLab(),
    );
  }

  static Future<void> openEngineering(BuildContext context) {
    return WorkplaceEntranceGate.openThen(
      context,
      kind: WorkplaceKind.engSite,
      builder: () => const EngineeringBridgeShowcaseLab(),
    );
  }

  static Future<void> openFullWorkplace(BuildContext context, String labId) {
    late final Widget screen;
    late final WorkplaceKind kind;
    switch (labId) {
      case 'cs_career':
        screen = csCareerPlayableScreen();
        kind = WorkplaceKind.incidentBridge;
      case 'law_firm':
        screen = lawPlayableScreen();
        kind = WorkplaceKind.courtroom;
      case 'engineering':
        screen = engineeringPlayableScreen();
        kind = WorkplaceKind.engSite;
      default:
        return UniversityPracticalLabScreen.openCourse(
          context,
          courseId: labId,
        );
    }
    return WorkplaceEntranceGate.openThen(
      context,
      kind: kind,
      builder: () => screen,
    );
  }
}

// ─── CS: Production incident with eng-review viva ───────────────────────────

class CsIncidentShowcaseLab extends StatefulWidget {
  const CsIncidentShowcaseLab({super.key});

  @override
  State<CsIncidentShowcaseLab> createState() => _CsIncidentShowcaseLabState();
}

class _CsIncidentShowcaseLabState extends State<CsIncidentShowcaseLab> {
  static const Color accent = Color(0xFF22D3EE);
  static const Color bg = Color(0xFF050B12);
  static const Color surface = Color(0xFF0B1622);

  int _phase = 0; // 0 logs, 1 bug+fix, 2 viva, 3 done
  String? _bugLine;
  String? _fix;
  bool _testsRun = false;
  int? _viva;
  String? _coach;
  final Stopwatch _clock = Stopwatch()..start();

  static const List<String> _logs = <String>[
    '10:01:12 INFO  checkout.start order=8821',
    '10:01:12 WARN  retry.queue depth=41',
    '10:01:13 ERROR charge: NullPointerException at PaymentService.java:147',
    '10:01:13 ERROR   → token.providerId used after refresh without null check',
    '10:01:14 INFO  rollback.txn order=8821',
  ];

  bool get _fixReady =>
      _bugLine == '147' && _fix == 'null_guard' && _testsRun;

  Future<void> _finish() async {
    _clock.stop();
    final bool vivaOk = _viva == 1;
    final double accuracy = ((_fixReady ? 0.7 : 0.3) + (vivaOk ? 0.3 : 0))
        .clamp(0.0, 1.0);
    final UniversityLabResult result = UniversityLabResult(
      accuracy: accuracy,
      identifyCorrect: (_fixReady ? 1 : 0) + (vivaOk ? 1 : 0),
      identifyAttempts: 2,
      viewsVisited: 3,
      labelDrillComplete: _testsRun,
      coachingNotes: <String>[
        _fixReady
            ? 'Incident closed: null guard after token refresh + green tests.'
            : 'Root-cause incomplete — re-read the stack and guard the token.',
        vivaOk
            ? 'Eng review viva passed — you defended roll-forward with evidence.'
            : 'Viva weak — judges want WHY, not just a green build.',
      ],
      xpEarned: accuracy >= 0.85 ? 220 : 140,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: accuracy >= 0.85 ? 'incident_responder' : null,
      clinicalSolved: vivaOk && _fixReady,
      clinicalReasoningScore: vivaOk ? 1 : 0.35,
    );
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'INCIDENT PRACTICAL PASSED'
          : 'INCIDENT LAB COMPLETE',
      accentLabel: 'Junior Software Engineer',
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('CS · Production Incident Practical'),
        actions: <Widget>[
          TextButton(
            onPressed: () => WinningCareerShowcases.openFullWorkplace(
              context,
              'cs_career',
            ),
            child: const Text('Full floor', style: TextStyle(color: accent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          _banner(
            color: const Color(0xFFEF4444),
            title: 'PAGER · PAYMENT SYSTEM FAILING',
            body:
                'Checkout success 12%. Read logs → find the bug line → ship a safe fix → '
                'defend your eng-review viva. Competitors quiz syntax. You own the outage.',
          ),
          const SizedBox(height: 14),
          if (_phase == 0) ...<Widget>[
            const Text('LOGS',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 11)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _logs
                    .map(
                      (String l) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: l.contains('ERROR')
                                ? const Color(0xFFF87171)
                                : Colors.white70,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _phase = 1),
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('LOCATE BUG LINE',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else if (_phase == 1) ...<Widget>[
            _choiceBlock(
              label: 'BUG LINE',
              value: _bugLine,
              options: const <(String, String)>[
                ('89', 'Line 89 — retry backoff'),
                ('147', 'Line 147 — token.providerId after refresh'),
                ('210', 'Line 210 — log formatter'),
              ],
              onPick: (String v) => setState(() => _bugLine = v),
            ),
            _choiceBlock(
              label: 'FIX',
              value: _fix,
              options: const <(String, String)>[
                ('retry_more', 'Increase retries to 20'),
                ('null_guard', 'Add null check after token refresh'),
                ('disable_payments', 'Disable payments globally'),
              ],
              onPick: (String v) => setState(() => _fix = v),
            ),
            ListTile(
              tileColor: surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                _testsRun
                    ? 'Tests passed · payment_regression'
                    : 'Run payment regression tests',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              trailing: Icon(
                _testsRun ? Icons.check_circle : Icons.play_circle,
                color: accent,
              ),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _testsRun = true);
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _fixReady
                  ? () => setState(() {
                        _phase = 2;
                        _coach = null;
                      })
                  : () => setState(() => _coach =
                      'Need line 147 + null_guard + green tests before eng review.'),
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('ENTER ENG REVIEW VIVA',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else ...<Widget>[
            Text('ENG REVIEW VIVA',
                style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 11)),
            const SizedBox(height: 8),
            const Text(
              'Avery: Why roll forward with this fix instead of endless rollback?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.35),
            ),
            const SizedBox(height: 12),
            ...List<Widget>.generate(4, (int i) {
              const List<String> opts = <String>[
                'Rollbacks are illegal',
                'Feature is needed — tested null-guard restores value and protects latency',
                'Never look at metrics',
                'Always ship Friday nights',
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _viva = i),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: _viva == i ? accent : Colors.white24),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: Text(opts[i]),
                ),
              );
            }),
            FilledButton(
              onPressed: _viva == null ? null : _finish,
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('SUBMIT BOARD SCORE',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
          if (_coach != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_coach!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _banner({
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, height: 1.3)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }

  Widget _choiceBlock({
    required String label,
    required String? value,
    required List<(String, String)> options,
    required ValueChanged<String> onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 11)),
        ...options.map(((String, String) o) {
          final bool on = value == o.$1;
          return ListTile(
            tileColor: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: on ? accent : Colors.transparent),
            ),
            title: Text(o.$2,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            leading: Icon(
              on ? Icons.radio_button_checked : Icons.radio_button_off,
              color: accent,
            ),
            onTap: () => onPick(o.$1),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Law: Case file + partner viva ──────────────────────────────────────────

class LawCaseShowcaseLab extends StatefulWidget {
  const LawCaseShowcaseLab({super.key});

  @override
  State<LawCaseShowcaseLab> createState() => _LawCaseShowcaseLabState();
}

class _LawCaseShowcaseLabState extends State<LawCaseShowcaseLab> {
  static const Color accent = Color(0xFFD4A574);
  static const Color bg = Color(0xFF0C0A08);
  static const Color surface = Color(0xFF1A1510);

  final Set<String> _tagged = <String>{};
  final List<String> _timeline = <String>[];
  int? _viva;
  bool _onViva = false;
  String? _coach;
  final Stopwatch _clock = Stopwatch()..start();

  static const List<(String, String, bool)> _docs = <(String, String, bool)>[
    ('police', 'Police report — crosswalk collision', true),
    ('contract', 'Delivery scooter service contract', true),
    ('email', 'Internal email: brakes delayed for cost', true),
    ('menu', 'Café lunch receipt (noise)', false),
    ('photo', 'Photo of walk signal + marked crosswalk', true),
  ];

  bool get _ready =>
      _tagged.contains('police') &&
      _tagged.contains('email') &&
      _tagged.contains('photo') &&
      _timeline.length >= 3;

  Future<void> _finish() async {
    _clock.stop();
    final bool vivaOk = _viva == 1;
    final double accuracy =
        ((_ready ? 0.65 : 0.25) + (vivaOk ? 0.35 : 0)).clamp(0.0, 1.0);
    final UniversityLabResult result = UniversityLabResult(
      accuracy: accuracy,
      identifyCorrect: _tagged.where((String id) {
            for (final (String, String, bool) d in _docs) {
              if (d.$1 == id) return d.$3;
            }
            return false;
          }).length,
      identifyAttempts: _docs.length,
      viewsVisited: 3,
      labelDrillComplete: _timeline.length >= 3,
      coachingNotes: <String>[
        _ready
            ? 'Case file tight: relevant facts tagged, timeline built.'
            : 'Tag police + email + photo and build a 3-point timeline.',
        vivaOk
            ? 'Partner viva passed — facts separated from conclusions.'
            : 'Memo viva weak — judges punish conclusory IRAC.',
      ],
      xpEarned: accuracy >= 0.85 ? 210 : 130,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: accuracy >= 0.85 ? 'issue_spotter' : null,
      clinicalSolved: vivaOk && _ready,
      clinicalReasoningScore: vivaOk ? 1 : 0.3,
    );
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'CASE PRACTICAL PASSED'
          : 'LAW LAB COMPLETE',
      accentLabel: 'Junior Law Associate',
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Law · Case Practical'),
        actions: <Widget>[
          TextButton(
            onPressed: () => WinningCareerShowcases.openFullWorkplace(
              context,
              'law_firm',
            ),
            child: const Text('Full firm', style: TextStyle(color: accent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('HALE v. NORTHLINE',
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8)),
                SizedBox(height: 6),
                Text(
                  'Client hit by delivery scooter in a marked crosswalk. '
                  'Tag relevant evidence, build timeline, then defend your memo thesis to Maya. '
                  'Not a vocab quiz — real associate work.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          if (!_onViva) ...<Widget>[
            const SizedBox(height: 14),
            const Text('EVIDENCE LOCKER',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 11)),
            ..._docs.map(((String, String, bool) d) {
              final bool on = _tagged.contains(d.$1);
              return CheckboxListTile(
                value: on,
                activeColor: accent,
                title: Text(d.$2,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(d.$3 ? 'Likely relevant' : 'Probably noise',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                onChanged: (bool? v) {
                  setState(() {
                    if (v == true) {
                      _tagged.add(d.$1);
                      if (!_timeline.contains(d.$2) && d.$3) {
                        _timeline.add(d.$2);
                      }
                    } else {
                      _tagged.remove(d.$1);
                      _timeline.remove(d.$2);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 8),
            Text('Timeline (${_timeline.length}/3+)',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
            ..._timeline.map(
              (String t) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $t',
                    style: const TextStyle(color: Colors.white70, height: 1.35)),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _ready
                  ? () => setState(() => _onViva = true)
                  : () => setState(() => _coach =
                      'Tag police report, brake email, and crosswalk photo — then 3 timeline points.'),
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('MAYA PARTNER VIVA',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 14),
            Text('PARTNER VIVA',
                style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text(
              'Maya: Why separate facts from conclusions in the memo?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.35),
            ),
            const SizedBox(height: 12),
            ...List<Widget>.generate(4, (int i) {
              const List<String> opts = <String>[
                'Judges hate organization',
                'Clean facts let rules apply transparently — conclusions without facts fail scrutiny',
                'Never cite rules',
                'Padding wins cases',
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _viva = i),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: _viva == i ? accent : Colors.white24),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: Text(opts[i]),
                ),
              );
            }),
            FilledButton(
              onPressed: _viva == null ? null : _finish,
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('SUBMIT BOARD SCORE',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
          if (_coach != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_coach!, style: TextStyle(color: accent)),
          ],
        ],
      ),
    );
  }
}

// ─── Engineering: Bridge load + safety-factor viva ──────────────────────────

class EngineeringBridgeShowcaseLab extends StatefulWidget {
  const EngineeringBridgeShowcaseLab({super.key});

  @override
  State<EngineeringBridgeShowcaseLab> createState() =>
      _EngineeringBridgeShowcaseLabState();
}

class _EngineeringBridgeShowcaseLabState
    extends State<EngineeringBridgeShowcaseLab> {
  static const Color accent = Color(0xFFFBBF24);
  static const Color bg = Color(0xFF12100A);
  static const Color surface = Color(0xFF1F1A10);

  String? _material;
  double _beam = 0.4;
  String? _structure;
  bool _reinforced = false;
  bool _tested = false;
  bool _failed = false;
  bool _onViva = false;
  int? _viva;
  String? _coach;
  final Stopwatch _clock = Stopwatch()..start();

  int get _cost {
    int c = 40;
    if (_material == 'steel') c += 25;
    if (_material == 'composite') c += 40;
    if (_material == 'timber') c += 10;
    c += (_beam * 40).round();
    if (_structure == 'truss') c += 15;
    if (_structure == 'arch') c += 20;
    if (_reinforced) c += 18;
    return c;
  }

  bool get _passes {
    if (_material == null || _structure == null) return false;
    if (_material == 'timber' && _beam < 0.7) return false;
    if (!_reinforced && _structure == 'beam') return false;
    return _beam >= 0.45 &&
        (_material == 'steel' ||
            _material == 'composite' ||
            _beam >= 0.7);
  }

  void _test() {
    if (_material == null || _structure == null) {
      setState(() => _coach = 'Set material and structure first.');
      return;
    }
    setState(() {
      _tested = true;
      _failed = !_passes;
      _coach = _failed
          ? 'TEST FAIL · support beam buckled under 10,000 kg. Reinforce / deepen / restructure.'
          : 'TEST PASS · bridge holds 10,000 kg. Cost \$$_cost k.';
    });
  }

  Future<void> _finish() async {
    _clock.stop();
    final bool vivaOk = _viva == 1;
    final bool designOk = _tested && !_failed;
    final double accuracy =
        ((designOk ? 0.65 : 0.2) + (vivaOk ? 0.35 : 0)).clamp(0.0, 1.0);
    final UniversityLabResult result = UniversityLabResult(
      accuracy: accuracy,
      identifyCorrect: designOk ? 1 : 0,
      identifyAttempts: 1,
      viewsVisited: 3,
      labelDrillComplete: designOk,
      coachingNotes: <String>[
        designOk
            ? 'Load path holds 10k kg within design choices (cost \$$_cost k).'
            : 'Design failed load test — buckling risk not controlled.',
        vivaOk
            ? 'Safety-factor viva passed — uncertainty demands margin.'
            : 'Viva incomplete — codes exist because models lie a little.',
      ],
      xpEarned: accuracy >= 0.85 ? 220 : 130,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: accuracy >= 0.85 ? 'structural_defender' : null,
      clinicalSolved: vivaOk && designOk,
      clinicalReasoningScore: vivaOk ? 1 : 0.3,
    );
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'BRIDGE PRACTICAL PASSED'
          : 'ENGINEERING LAB COMPLETE',
      accentLabel: 'Junior Engineer',
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Engineering · Bridge Practical'),
        actions: <Widget>[
          TextButton(
            onPressed: () => WinningCareerShowcases.openFullWorkplace(
              context,
              'engineering',
            ),
            child: const Text('Full studio', style: TextStyle(color: accent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: const Text(
              'SPEC · Pedestrian bridge must carry 10,000 kg live load. '
              'Pick material, depth, structure, reinforce if needed → LOAD TEST → '
              'safety-factor viva. Failure is data — redesign wins.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
          if (!_onViva) ...<Widget>[
            const SizedBox(height: 12),
            Text('Est. cost: \$$_cost k',
                style: const TextStyle(
                    color: accent, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('MATERIAL',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 11)),
            ...<(String, String)>[
              ('timber', 'Timber'),
              ('steel', 'Steel'),
              ('composite', 'Composite'),
            ].map(((String, String) o) {
              final bool on = _material == o.$1;
              return ListTile(
                tileColor: surface,
                leading: Icon(
                    on ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: accent),
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() {
                  _material = o.$1;
                  _tested = false;
                }),
              );
            }),
            const Text('Beam depth',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            Slider(
              value: _beam,
              onChanged: (double v) => setState(() {
                _beam = v;
                _tested = false;
              }),
              activeColor: accent,
            ),
            const Text('STRUCTURE',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 11)),
            ...<(String, String)>[
              ('beam', 'Simple beam'),
              ('truss', 'Truss'),
              ('arch', 'Arch'),
            ].map(((String, String) o) {
              final bool on = _structure == o.$1;
              return ListTile(
                tileColor: surface,
                leading: Icon(
                    on ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: accent),
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() {
                  _structure = o.$1;
                  _tested = false;
                }),
              );
            }),
            SwitchListTile(
              value: _reinforced,
              activeThumbColor: accent,
              title: const Text('Reinforce support beam',
                  style: TextStyle(color: Colors.white)),
              onChanged: (bool v) => setState(() {
                _reinforced = v;
                _tested = false;
              }),
            ),
            OutlinedButton(
              onPressed: _test,
              style: OutlinedButton.styleFrom(foregroundColor: accent),
              child: const Text('RUN LOAD TEST'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: (_tested && !_failed)
                  ? () => setState(() => _onViva = true)
                  : () => setState(() => _coach =
                      'Pass the 10,000 kg load test before the design review viva.'),
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('DESIGN REVIEW VIVA',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 14),
            Text('DESIGN REVIEW VIVA',
                style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text(
              'Mina: Why keep a safety factor above 1.0?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.35),
            ),
            const SizedBox(height: 12),
            ...List<Widget>.generate(4, (int i) {
              const List<String> opts = <String>[
                'Codes hate safety',
                'Uncertainty in loads/materials/models — margin prevents catastrophic failure',
                'Overdesign is illegal',
                'Never inspect',
              ];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _viva = i),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: _viva == i ? accent : Colors.white24),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: Text(opts[i]),
                ),
              );
            }),
            FilledButton(
              onPressed: _viva == null ? null : _finish,
              style: FilledButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.black),
              child: const Text('SUBMIT BOARD SCORE',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
          if (_coach != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_coach!, style: TextStyle(color: accent)),
          ],
        ],
      ),
    );
  }
}

/// Quick open for any remaining course via university practical catalog.
Future<void> openCourseWinningLab(BuildContext context, String courseId) {
  final mission = UniversityPracticalCatalog.forCourse(courseId);
  if (mission == null) {
    return WinningCareerShowcases.openFullWorkplace(context, courseId);
  }
  if (courseId.contains('computer') || courseId == 'cs' || courseId == 'cs_career') {
    return WinningCareerShowcases.openCs(context);
  }
  if (courseId.contains('law')) return WinningCareerShowcases.openLaw(context);
  if (courseId.contains('engin')) {
    return WinningCareerShowcases.openEngineering(context);
  }
  return UniversityPracticalLabScreen.open(context, mission: mission);
}
