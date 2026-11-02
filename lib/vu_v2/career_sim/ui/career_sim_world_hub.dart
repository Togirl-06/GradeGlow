import 'package:flutter/material.dart';

import '../../design/vu_v2_theme.dart';
import '../../labs/centers/vu_v2_lab_game.dart';
import '../../labs/centers/vu_v2_lab_progress_store.dart';
import '../career_sim_models.dart';
import '../worlds/nursing_ed_world.dart';
import 'career_sim_session_screen.dart';

/// Riverside Med ED — you are ON the floor, not opening a quiz menu.
class CareerSimWorldHub extends StatefulWidget {
  const CareerSimWorldHub({super.key, required this.world});

  final CareerWorld world;

  factory CareerSimWorldHub.nursingEd() =>
      CareerSimWorldHub(world: NursingEdWorld.build());

  @override
  State<CareerSimWorldHub> createState() => _CareerSimWorldHubState();
}

class _CareerSimWorldHubState extends State<CareerSimWorldHub> {
  final VuV2LabProgressStore _progress = VuV2LabProgressStore();
  bool _ready = false;
  late String _locationId;
  bool _showBriefing = true;

  CareerWorld get world => widget.world;

  @override
  void initState() {
    super.initState();
    _locationId = world.locations.first.id;
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    if (!_progress.sawDayOneLabel(world.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showHire();
      });
    }
  }

  Future<void> _showHire() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      pageBuilder: (BuildContext ctx, _, _) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: const Color(0xFF0E1628),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '7:00 AM · RIVERSIDE MED',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You are hired as\n${world.role.title}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _hireRow('LOCATION', world.workplace),
                    _hireRow('SHIFT', world.role.shift),
                    _hireRow('SUPERVISOR', world.role.supervisorName),
                    const SizedBox(height: 14),
                    Text(
                      world.role.tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is not a quiz. Move through the hospital. '
                      'Talk to people. Use tools. Deal with consequences.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await _progress.markDayOneLabel(world.id);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'ENTER THE ED',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hireRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  CareerLocation get _loc =>
      world.locationById(_locationId) ?? world.locations.first;

  int get _careerLevel => _progress.careerLevelFor(world.id);

  CareerMission? get _activeMission {
    for (final CareerMission m in world.missions) {
      if (_progress.isMissionCleared(world.id, m.id)) continue;
      final bool priorOk = m.index <= 1 ||
          world.missions.any(
            (CareerMission p) =>
                p.index == m.index - 1 &&
                _progress.isMissionCleared(world.id, p.id),
          );
      if (priorOk && m.requiredCareerLevel <= _careerLevel) return m;
    }
    return null;
  }

  bool _locationUnlocked(CareerLocation loc) => _progress.isLocationUnlocked(
        worldId: world.id,
        unlockCareerLevel: loc.unlockCareerLevel,
        locationId: loc.id,
      );

  Future<void> _startMission(CareerMission mission) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareerSimSessionScreen(
          world: world,
          mission: mission,
          progress: _progress,
          playerCareerLevel: _careerLevel,
          priorSkillAvg: _progress.skillAvgFor(world.id),
          initialLocationId: mission.startLocationId,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _go(String locationId) {
    final CareerLocation? loc = world.locationById(locationId);
    if (loc == null) return;
    if (!_locationUnlocked(loc)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.lockedHint ?? 'Location locked')),
      );
      return;
    }
    setState(() {
      _locationId = locationId;
      _showBriefing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF06101C),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(color: Color(0xFF10B981)),
              SizedBox(height: 16),
              Text(
                'Opening Riverside Med…',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    final double w = MediaQuery.sizeOf(context).width;
    final bool wide = w >= 960;
    final CareerMission? active = _activeMission;
    final Map<String, int> skills =
        _progress.careerSkills[world.id] ?? <String, int>{};

    return Scaffold(
      backgroundColor: const Color(0xFF06101C),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF06101C),
              Color(0xFF0A1A2E),
              Color(0xFF071422),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _topBar(),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _floorRail(),
                          Expanded(child: _roomStage(active, skills)),
                          SizedBox(
                            width: 300,
                            child: _sidePanel(active),
                          ),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(child: _roomStage(active, skills)),
                          _mobileFloorNav(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final int level = _careerLevel;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          const Text(
            'NURSING LAB',
            style: TextStyle(
              color: Color(0xFF34D399),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${world.role.title} · ${world.titleForLevel(level)} · Lv $level',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _pill('XP ${_progress.xp}'),
          const SizedBox(width: 6),
          _pill(world.role.shift.split('–').first.trim()),
        ],
      ),
    );
  }

  Widget _pill(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
      ),
      child: Text(
        t,
        style: TextStyle(
          color: Color(0xFF6EE7B7),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _floorRail() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        children: <Widget>[
          Text(
            'HOSPITAL FLOOR',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ...world.locations.map((CareerLocation loc) {
            final bool unlocked = _locationUnlocked(loc);
            final bool here = loc.id == _locationId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: here
                    ? const Color(0xFF10B981).withValues(alpha: 0.18)
                    : const Color(0xFF121A2B),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _go(loc.id),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        Text(
                          unlocked ? loc.icon : '🔒',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.name,
                            style: TextStyle(
                              color: unlocked ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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

  Widget _mobileFloorNav() {
    return SizedBox(
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: world.locations.map((CareerLocation loc) {
          final bool unlocked = _locationUnlocked(loc);
          final bool here = loc.id == _locationId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: here,
              label: Text('${unlocked ? loc.icon : '🔒'} ${loc.name}'),
              onSelected: (_) => _go(loc.id),
              selectedColor: const Color(0xFF10B981),
              backgroundColor: const Color(0xFF121A2B),
              labelStyle: TextStyle(
                color: here ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _roomStage(CareerMission? active, Map<String, int> skills) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: <Widget>[
        // Environment header
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _roomColors(_loc.id),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _loc.icon,
                style: TextStyle(fontSize: 32),
              ),
              const Spacer(),
              Text(
                _loc.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _loc.blurb,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _roomAmbience(_loc.id),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        if (_loc.id == 'nurses_station' || _showBriefing) ...<Widget>[
          _missionBoard(active),
          const SizedBox(height: 14),
        ],
        if (_loc.id == 'ed_bay') _bayPanel(active),
        if (_loc.id == 'med_room') _medPanel(active),
        if (_loc.id == 'triage') _triagePanel(active),
        if (skills.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          Text(
            'YOUR CLINICAL SKILLS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          ...skills.entries.take(6).map(
            (MapEntry<String, int> e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      CareerSkillId.label(e.key),
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: e.value / 100,
                        minHeight: 7,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _missionBoard(CareerMission? active) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243049)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.assignment_outlined, color: Color(0xFF34D399)),
              const SizedBox(width: 8),
              const Text(
                'ASSIGNMENT BOARD',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                world.role.supervisorName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (active == null)
            Text(
              'All current missions cleared. Harder wards unlock as you level.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            )
          else ...<Widget>[
            Text(
              active.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              active.brief,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'OBJECTIVE: ${active.objective}',
              style: TextStyle(
                color: Color(0xFF6EE7B7),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${active.mode.name.toUpperCase()} · '
              '${'★' * active.difficultyStars} · +${active.xpReward} XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _startMission(active),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'START SHIFT · Go to ${_locationName(active.startLocationId)}',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...world.missions.map((CareerMission m) {
            final bool cleared = _progress.isMissionCleared(world.id, m.id);
            final bool isActive = active?.id == m.id;
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: <Widget>[
                  Icon(
                    cleared
                        ? Icons.check_circle
                        : isActive
                            ? Icons.play_circle_fill
                            : Icons.lock_outline,
                    size: 18,
                    color: cleared
                        ? const Color(0xFF34D399)
                        : isActive
                            ? VuV2Colors.orange
                            : Colors.white24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.title,
                      style: TextStyle(
                        color: cleared || isActive
                            ? Colors.white
                            : Colors.white38,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (cleared)
                    TextButton(
                      onPressed: () => _startMission(m),
                      child: const Text('Replay', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _bayPanel(CareerMission? active) {
    return _envCard(
      title: 'BAY STATUS',
      body:
          'Monitors hum. Bay 3 flagged for Student Nurse coverage.\n'
          'Patient 104 · Mr. Cole · Chest discomfort.',
      actionLabel: active != null && active.startLocationId == 'ed_bay'
          ? 'Begin bedside mission'
          : 'Return to nurses\' station for assignment',
      onAction: () {
        if (active != null && active.startLocationId == 'ed_bay') {
          _startMission(active);
        } else {
          _go('nurses_station');
        }
      },
    );
  }

  Widget _medPanel(CareerMission? active) {
    return _envCard(
      title: 'MEDICATION ROOM',
      body:
          'Pyxis locked. Allergy flags glow amber on the screen.\n'
          'Never pull a med without two identifiers.',
      actionLabel: active?.id == 'nurse_m4_meds'
          ? 'Start medication round'
          : 'Wait for med-round assignment',
      onAction: active?.id == 'nurse_m4_meds'
          ? () => _startMission(active!)
          : null,
    );
  }

  Widget _triagePanel(CareerMission? active) {
    return _envCard(
      title: 'TRIAGE DESK',
      body:
          'Waiting room noise. Acuity tags. Ambulance radio crackles.\n'
          'Crisis missions start here.',
      actionLabel: active?.mode == CareerSimGameMode.crisis
          ? 'Take the surge'
          : 'Stand by for surge assignment',
      onAction: active?.mode == CareerSimGameMode.crisis
          ? () => _startMission(active!)
          : null,
    );
  }

  Widget _envCard({
    required String title,
    required String body,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243049)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF34D399),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: onAction == null
                  ? Colors.white12
                  : const Color(0xFF10B981),
              foregroundColor: onAction == null ? Colors.white38 : Colors.black,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _sidePanel(CareerMission? active) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243049)),
      ),
      child: ListView(
        children: <Widget>[
          const Text(
            'CHARGE NURSE',
            style: TextStyle(
              color: Color(0xFF34D399),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            world.role.supervisorName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            active == null
                ? '"Solid work. Check the board when you\'re ready for the next ward."'
                : '"$activeTitle — don\'t make me regret staffing you."',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CAREER XP',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: VuV2LabGame.levelProgress(_progress.xp),
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          if (_progress.badges.isNotEmpty) ...<Widget>[
            Text(
              'BADGES',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _progress.badges
                  .take(8)
                  .map(
                    (String b) => Chip(
                      label: Text(b, style: TextStyle(fontSize: 11)),
                      backgroundColor:
                          const Color(0xFF10B981).withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: Colors.white),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String get activeTitle {
    final CareerMission? m = _activeMission;
    return m?.title ?? 'standby';
  }

  String _locationName(String id) =>
      world.locationById(id)?.name ?? id;

  List<Color> _roomColors(String id) {
    switch (id) {
      case 'ed_bay':
        return const <Color>[Color(0xFF12324A), Color(0xFF0B1C2E)];
      case 'med_room':
        return const <Color>[Color(0xFF2A1F3D), Color(0xFF140F22)];
      case 'triage':
        return const <Color>[Color(0xFF3A2418), Color(0xFF1A120E)];
      case 'icu':
      case 'or':
        return const <Color>[Color(0xFF1A1A28), Color(0xFF0C0C14)];
      default:
        return const <Color>[Color(0xFF0F2F2A), Color(0xFF0A1A18)];
    }
  }

  String _roomAmbience(String id) {
    switch (id) {
      case 'nurses_station':
        return 'Phones. Assignment board. Diaz\'s coffee. Your shift starts here — '
            'read the board, then move.';
      case 'ed_bay':
        return 'Curtains. Beeps. Someone calling for water three bays down. '
            'This is where patients live or die on your watch.';
      case 'med_room':
        return 'Cold air. Locked drawers. Every scan is a safety check.';
      case 'triage':
        return 'Lobby noise. Wristbands. The next ambulance could change everything.';
      case 'supply':
        return 'Gloves, O2 tubing, crash cart access. Grab what the bay needs.';
      default:
        return 'Locked ward. Earn the clearance.';
    }
  }
}
