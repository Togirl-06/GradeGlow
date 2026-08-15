import 'package:flutter/material.dart';

import '../career_sim/career_sim_models.dart';
import '../career_sim/ui/career_sim_session_screen.dart';
import '../career_sim/worlds/career_worlds.dart';
import '../career_sim/worlds/nursing_ed_world.dart';
import '../labs/centers/vu_v2_lab_game.dart';
import '../labs/centers/vu_v2_lab_progress_store.dart';
import 'career_lab_registry.dart';
import 'playable/law/law_workplace_screen.dart';

/// CAREER HUB → Training → … → Boss → Mastery
/// Law opens the playable firm (not a mission list).
class CareerLabHomeScreen extends StatefulWidget {
  const CareerLabHomeScreen({super.key, required this.labId});

  final String labId;

  @override
  State<CareerLabHomeScreen> createState() => _CareerLabHomeScreenState();
}

class _CareerLabHomeScreenState extends State<CareerLabHomeScreen> {
  final VuV2LabProgressStore _progress = VuV2LabProgressStore();
  bool _ready = false;
  late final CareerWorld _world;
  late final CareerLabDef _def;

  @override
  void initState() {
    super.initState();
    if (widget.labId == 'law_firm') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LawWorkplaceScreen()),
        );
      });
      return;
    }
    _def = CareerLabRegistry.byId(widget.labId) ?? CareerLabRegistry.all.first;
    _world = careerWorldById(widget.labId) ?? NursingEdWorld.build();
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    if (!_progress.sawDayOneLabel(_world.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRoleAccept();
      });
    }
  }

  Future<void> _showRoleAccept() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      pageBuilder: (BuildContext ctx, Animation<double> a1, Animation<double> a2) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              color: const Color(0xFF0E1628),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _def.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'YOU ARE HIRED\n${_world.role.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_world.workplace}\n'
                      'Supervisor: ${_world.role.supervisorName}\n'
                      'Shift: ${_world.role.shift}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _world.role.tagline,
                      style: const TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This is a Career Lab — not a quiz.\n'
                      'Track: Training → First Mission → Scenarios → '
                      'Advanced → Crisis → Boss → Mastery',
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
                          await _progress.markDayOneLabel(_world.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'ACCEPT ROLE',
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

  bool _unlocked(CareerMission m) {
    if (m.index <= 1) return true;
    if (_progress.isMissionCleared(_world.id, m.id)) return true;
    CareerMission? prior;
    for (final CareerMission x in _world.missions) {
      if (x.index == m.index - 1) {
        prior = x;
        break;
      }
    }
    if (prior == null) return false;
    return _progress.isMissionCleared(_world.id, prior.id) &&
        m.requiredCareerLevel <= _progress.careerLevelFor(_world.id);
  }

  Future<void> _play(CareerMission m) async {
    if (!_unlocked(m)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clear the previous mission first.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareerSimSessionScreen(
          world: _world,
          mission: m,
          progress: _progress,
          playerCareerLevel: _progress.careerLevelFor(_world.id),
          priorSkillAvg: _progress.skillAvgFor(_world.id),
          initialLocationId: m.startLocationId,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labId == 'law_firm') {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0A08),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4A574))),
      );
    }
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF06101C),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      );
    }

    final int level = _progress.careerLevelFor(_world.id);
    final bool mastery = _world.missions
        .where((CareerMission m) => m.trackStage == CareerTrackStage.boss)
        .every((CareerMission m) => _progress.isMissionCleared(_world.id, m.id));

    final Map<CareerTrackStage, List<CareerMission>> byStage =
        <CareerTrackStage, List<CareerMission>>{};
    for (final CareerMission m in _world.missions) {
      byStage.putIfAbsent(m.trackStage, () => <CareerMission>[]).add(m);
    }

    const List<CareerTrackStage> order = <CareerTrackStage>[
      CareerTrackStage.training,
      CareerTrackStage.firstMission,
      CareerTrackStage.realScenarios,
      CareerTrackStage.advanced,
      CareerTrackStage.crisis,
      CareerTrackStage.boss,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF06101C),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                ),
                Expanded(
                  child: Text(
                    'CAREER HUB',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${_def.emoji} ${_def.title}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_world.role.title} · ${_world.titleForLevel(level)} · Lv $level',
              style: const TextStyle(color: Color(0xFF6EE7B7), fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${_world.workplace} · ${_world.role.supervisorName}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: VuV2LabGame.levelProgress(_progress.xp),
                minHeight: 8,
                backgroundColor: Colors.white12,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'XP ${_progress.xp}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
            ),
            const SizedBox(height: 18),
            _LocationsStrip(world: _world, progress: _progress),
            const SizedBox(height: 18),
            ...order.map((CareerTrackStage stage) {
              final List<CareerMission> missions =
                  byStage[stage] ?? const <CareerMission>[];
              if (missions.isEmpty) return const SizedBox.shrink();
              return _StageBlock(
                stage: stage,
                missions: missions,
                unlocked: _unlocked,
                cleared: (CareerMission m) =>
                    _progress.isMissionCleared(_world.id, m.id),
                onPlay: _play,
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mastery
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFF121A2B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: mastery
                      ? const Color(0xFF10B981)
                      : const Color(0xFF243049),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    CareerTrackStage.mastery.label.toUpperCase(),
                    style: TextStyle(
                      color: mastery
                          ? const Color(0xFF34D399)
                          : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mastery
                        ? 'Boss cleared. You own this career track. Replay any mission — situations can change.'
                        : 'Clear the Boss Mission to unlock Career Mastery.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (_progress.careerSkills[_world.id] != null) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                'SKILLS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              ..._progress.careerSkills[_world.id]!.entries.map(
                (MapEntry<String, int> e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          CareerSkillId.label(e.key),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: const TextStyle(
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
        ),
      ),
    );
  }
}

class _LocationsStrip extends StatelessWidget {
  const _LocationsStrip({required this.world, required this.progress});

  final CareerWorld world;
  final VuV2LabProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: world.locations.map((CareerLocation loc) {
          final bool open = progress.isLocationUnlocked(
            worldId: world.id,
            unlockCareerLevel: loc.unlockCareerLevel,
            locationId: loc.id,
          );
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF121A2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF243049)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(open ? loc.icon : '🔒', style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Text(
                  loc.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: open ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StageBlock extends StatelessWidget {
  const _StageBlock({
    required this.stage,
    required this.missions,
    required this.unlocked,
    required this.cleared,
    required this.onPlay,
  });

  final CareerTrackStage stage;
  final List<CareerMission> missions;
  final bool Function(CareerMission m) unlocked;
  final bool Function(CareerMission m) cleared;
  final Future<void> Function(CareerMission m) onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            stage.label.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFFF59E0B),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...missions.map((CareerMission m) {
            final bool open = unlocked(m);
            final bool done = cleared(m);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: const Color(0xFF121A2B),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: open ? () => onPlay(m) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          done
                              ? Icons.check_circle
                              : open
                                  ? Icons.play_circle_fill
                                  : Icons.lock_outline,
                          color: done
                              ? const Color(0xFF34D399)
                              : open
                                  ? const Color(0xFF10B981)
                                  : Colors.white24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                m.title,
                                style: TextStyle(
                                  color: open ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${'★' * m.difficultyStars} · +${m.xpReward} XP · ${m.objective}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
}
