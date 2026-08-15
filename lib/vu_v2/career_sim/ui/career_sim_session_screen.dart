import 'dart:async';

import 'package:flutter/material.dart';

import '../../labs/centers/vu_v2_lab_progress_store.dart';
import '../career_sim_engine.dart';
import '../career_sim_models.dart';
import 'career_sim_er_bridge.dart';
import 'career_sim_report_screen.dart';

/// On-shift session — hospital chrome, vitals, tools, dialogue. Not a quiz page.
class CareerSimSessionScreen extends StatefulWidget {
  const CareerSimSessionScreen({
    super.key,
    required this.world,
    required this.mission,
    required this.progress,
    this.playerCareerLevel = 1,
    this.priorSkillAvg = 50,
    this.initialLocationId,
  });

  final CareerWorld world;
  final CareerMission mission;
  final VuV2LabProgressStore progress;
  final int playerCareerLevel;
  final int priorSkillAvg;
  final String? initialLocationId;

  @override
  State<CareerSimSessionScreen> createState() => _CareerSimSessionScreenState();
}

class _CareerSimSessionScreenState extends State<CareerSimSessionScreen> {
  late final CareerSimEngine _engine;
  final TextEditingController _text = TextEditingController();
  final ScrollController _logScroll = ScrollController();
  Timer? _tick;
  bool _briefDone = false;
  bool _busy = false;
  bool _chartOpen = false;
  Map<String, String> _vitals = <String, String>{
    'HR': '—',
    'BP': '—',
    'SpO₂': '—',
    'RR': '—',
  };

  @override
  void initState() {
    super.initState();
    _engine = CareerSimEngine(
      widget.world,
      playerCareerLevel: widget.playerCareerLevel,
      priorSkillAvg: widget.priorSkillAvg,
    );
    final CareerSimSessionState s = _engine.startMission(widget.mission);
    if (widget.initialLocationId != null) {
      s.locationId = widget.initialLocationId!;
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _text.dispose();
    _logScroll.dispose();
    super.dispose();
  }

  CareerSimSessionState get _s => _engine.session;

  void _ensureTicker() {
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _engine.session.finished) return;
      _engine.tickTimer();
      setState(() {});
    });
  }

  void _syncVitalsFromFlags() {
    final String? v = _s.flags['vitals'];
    if (v == 'borderline') {
      _vitals = <String, String>{
        'HR': '110',
        'BP': '148/94',
        'SpO₂': '93%',
        'RR': '24',
      };
    }
    if (_s.meters['patient'] != null && (_s.meters['patient'] ?? 50) < 45) {
      _vitals = <String, String>{
        'HR': '118',
        'BP': '88/54',
        'SpO₂': '88%',
        'RR': '28',
      };
    }
  }

  Future<void> _finish() async {
    if (_busy) return;
    _busy = true;
    final CareerPerformanceReport draft = _engine.buildReport();
    final List<String> badges = await widget.progress.completeCareerMission(
      worldId: widget.world.id,
      missionId: widget.mission.id,
      missionIndex: widget.mission.index,
      won: draft.won,
      xpGain: draft.xpEarned,
      skillScores: draft.skillScores,
      badgeId: draft.won ? widget.mission.badgeOnClear : null,
      locationsToUnlock: draft.won && widget.mission.index >= 3
          ? const <String>['icu']
          : const <String>[],
    );
    final CareerPerformanceReport report = CareerPerformanceReport(
      missionId: draft.missionId,
      missionTitle: draft.missionTitle,
      won: draft.won,
      overallStars: draft.overallStars,
      skillScores: draft.skillScores,
      supervisorFeedback: draft.supervisorFeedback,
      nextChallenge: draft.nextChallenge,
      xpEarned: draft.xpEarned,
      badgesEarned: badges,
      metersEnd: draft.metersEnd,
    );
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CareerSimReportScreen(
          world: widget.world,
          report: report,
        ),
      ),
    );
  }

  Future<void> _afterAction() async {
    _syncVitalsFromFlags();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.animateTo(
          _logScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
    if (_s.finished) await _finish();
  }

  Future<void> _onContinue() async {
    final CareerBeat beat = _s.beat;
    if (beat.kind == CareerBeatKind.erChallenge) {
      final bool ok = await CareerSimErBridge.openChallenge(context);
      if (!mounted) return;
      _engine.completeErChallenge(success: ok);
      await _afterAction();
      return;
    }
    _engine.continueCinematic();
    await _afterAction();
  }

  Future<void> _choose(String id) async {
    _engine.applyChoice(id);
    await _afterAction();
  }

  Future<void> _tool(String id) async {
    if (id == 'check_vitals' || id.contains('vital')) {
      _vitals = <String, String>{
        'HR': '110',
        'BP': '148/94',
        'SpO₂': '93%',
        'RR': '24',
      };
    }
    _engine.applyTool(id);
    await _afterAction();
  }

  Future<void> _submitText() async {
    final String t = _text.text.trim();
    if (t.isEmpty) return;
    _engine.submitFreeText(t);
    _text.clear();
    await _afterAction();
  }

  @override
  Widget build(BuildContext context) {
    if (!_briefDone) {
      return _CinematicBrief(
        world: widget.world,
        mission: widget.mission,
        onEnter: () {
          setState(() => _briefDone = true);
          _ensureTicker();
        },
      );
    }

    final CareerBeat beat = _s.beat;
    final CareerLocation? loc = widget.world.locationById(_s.locationId);
    final CareerNpc? npc = widget.world.npcById(beat.npcId);
    final String? hint = _engine.hintForCurrentBeat();

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _ShiftHud(
              locationName: loc?.name ?? 'ED',
              missionTitle: widget.mission.title,
              timer: _s.timerRemaining,
              onAbort: () => Navigator.of(context).maybePop(),
              onChart: () => setState(() => _chartOpen = !_chartOpen),
            ),
            _VitalsStrip(vitals: _vitals, patient: _s.meters['patient'] ?? 70),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _ScenePane(
                          beat: beat,
                          npc: npc,
                          narrative: _s.lastNarrative,
                          memory: _s.dialogueMemory,
                          hint: hint,
                          logScroll: _logScroll,
                          objectives: _s.objectives,
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width >= 820)
                        SizedBox(
                          width: 300,
                          child: _ActionRail(
                            beat: beat,
                            textController: _text,
                            onContinue: _onContinue,
                            onChoose: _choose,
                            onTool: _tool,
                            onSubmitText: _submitText,
                          ),
                        ),
                    ],
                  ),
                  if (_chartOpen) _ChartOverlay(onClose: () => setState(() => _chartOpen = false)),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width < 820)
              _ActionRail(
                beat: beat,
                textController: _text,
                onContinue: _onContinue,
                onChoose: _choose,
                onTool: _tool,
                onSubmitText: _submitText,
                compact: true,
              ),
            _StatusMeters(state: _s),
          ],
        ),
      ),
    );
  }
}

class _CinematicBrief extends StatelessWidget {
  const _CinematicBrief({
    required this.world,
    required this.mission,
    required this.onEnter,
  });

  final CareerWorld world;
  final CareerMission mission;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF041018), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Abort', style: TextStyle(color: Colors.white54)),
                ),
                const Spacer(),
                Text(
                  mission.mode.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mission.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'ROLE  ${world.role.title}\n'
                  'FLOOR  ${world.workplace}\n'
                  'BOSS   ${world.role.supervisorName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  mission.brief,
                  style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'OBJECTIVE: ${mission.objective}\n'
                  'REWARD: +${mission.xpReward} XP',
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onEnter,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'WALK ONTO THE FLOOR',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftHud extends StatelessWidget {
  const _ShiftHud({
    required this.locationName,
    required this.missionTitle,
    required this.onAbort,
    required this.onChart,
    this.timer,
  });

  final String locationName;
  final String missionTitle;
  final VoidCallback onAbort;
  final VoidCallback onChart;
  final int? timer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      color: const Color(0xFF0A1420),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onAbort,
            icon: const Icon(Icons.close, color: Colors.white54),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  locationName.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 12,
                  ),
                ),
                Text(
                  missionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChart,
            child: const Text('CHART', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          ),
          if (timer != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⏱ $timer',
                style: const TextStyle(
                  color: Color(0xFFFF8A80),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VitalsStrip extends StatelessWidget {
  const _VitalsStrip({required this.vitals, required this.patient});

  final Map<String, String> vitals;
  final int patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF071820),
      child: Row(
        children: <Widget>[
          ...vitals.entries.map(
            (MapEntry<String, String> e) => Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    e.key,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    e.value,
                    style: TextStyle(
                      color: patient < 50 ? const Color(0xFFF87171) : const Color(0xFF34D399),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePane extends StatelessWidget {
  const _ScenePane({
    required this.beat,
    required this.npc,
    required this.narrative,
    required this.memory,
    required this.hint,
    required this.logScroll,
    required this.objectives,
  });

  final CareerBeat beat;
  final CareerNpc? npc;
  final String narrative;
  final List<String> memory;
  final String? hint;
  final ScrollController logScroll;
  final List<CareerObjective> objectives;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: logScroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: objectives
              .map(
                (CareerObjective o) => Chip(
                  avatar: Icon(
                    o.done ? Icons.check : Icons.circle_outlined,
                    size: 14,
                    color: o.done ? const Color(0xFF34D399) : Colors.white38,
                  ),
                  label: Text(o.label, style: const TextStyle(fontSize: 11)),
                  backgroundColor: const Color(0xFF121A2B),
                  labelStyle: TextStyle(
                    color: o.done ? const Color(0xFF6EE7B7) : Colors.white60,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        if (npc != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121A2B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF243049)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(npc!.avatarGlyph, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        npc!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        npc!.role,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          beat.body,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.45,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...<Widget>[
          Text(
            beat.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            beat.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.45,
              fontSize: 15,
            ),
          ),
        ],
        if (narrative.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              narrative,
              style: const TextStyle(color: Color(0xFFD1FAE5), height: 1.4),
            ),
          ),
        ],
        if (memory.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            'WHAT YOU SAID / DID',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          ...memory.takeLast(5).map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '· $line',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
        if (hint != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            'Diaz (quiet): $hint',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

extension _TakeLast<E> on List<E> {
  Iterable<E> takeLast(int n) => skip(length < n ? 0 : length - n);
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.beat,
    required this.textController,
    required this.onContinue,
    required this.onChoose,
    required this.onTool,
    required this.onSubmitText,
    this.compact = false,
  });

  final CareerBeat beat;
  final TextEditingController textController;
  final VoidCallback onContinue;
  final Future<void> Function(String id) onChoose;
  final Future<void> Function(String id) onTool;
  final VoidCallback onSubmitText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'ACTIONS',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        ..._buttons(),
      ],
    );

    if (compact) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 260),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: Color(0xFF0A1420),
          border: Border(top: BorderSide(color: Color(0xFF243049))),
        ),
        child: SingleChildScrollView(child: body),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1420),
        border: Border(left: BorderSide(color: Color(0xFF243049))),
      ),
      child: SingleChildScrollView(child: body),
    );
  }

  List<Widget> _buttons() {
    switch (beat.kind) {
      case CareerBeatKind.cinematic:
      case CareerBeatKind.erChallenge:
      case CareerBeatKind.missionEnd:
        return <Widget>[
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              beat.continueLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ];
      case CareerBeatKind.freeText:
        return <Widget>[
          TextField(
            controller: textController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: beat.freeTextHint ?? 'Say something…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: const Color(0xFF121A2B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onSubmitText,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('SPEAK', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ];
      case CareerBeatKind.dialogue:
      case CareerBeatKind.decision:
      case CareerBeatKind.tool:
      case CareerBeatKind.timerPressure:
      case CareerBeatKind.randomEvent:
        return beat.choices
            .map(
              (CareerChoice c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => beat.kind == CareerBeatKind.tool
                      ? onTool(c.id)
                      : onChoose(c.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(c.label, style: const TextStyle(height: 1.3)),
                ),
              ),
            )
            .toList();
    }
  }
}

class _ChartOverlay extends StatelessWidget {
  const _ChartOverlay({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1628),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF243049)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'PATIENT CHART · 104',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                const Text(
                  'Mr. Cole, 62\n'
                  'CC: Chest discomfort\n'
                  'Allergies: PENICILLIN\n'
                  'Triage: HR 102 · BP 148/92 · SpO₂ 94% RA\n'
                  'Notes: Anxious, jaw pressure possible.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMeters extends StatelessWidget {
  const _StatusMeters({required this.state});

  final CareerSimSessionState state;

  @override
  Widget build(BuildContext context) {
    Widget m(String label, int v, Color c) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$label $v',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v / 100,
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: c,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      color: const Color(0xFF0A1420),
      child: Row(
        children: <Widget>[
          m('Patient', state.meters['patient'] ?? 0, const Color(0xFF34D399)),
          const SizedBox(width: 10),
          m('Trust', state.meters['trust'] ?? 0, const Color(0xFF60A5FA)),
          const SizedBox(width: 10),
          m('Stress', state.meters['stress'] ?? 0, const Color(0xFFFBBF24)),
        ],
      ),
    );
  }
}
