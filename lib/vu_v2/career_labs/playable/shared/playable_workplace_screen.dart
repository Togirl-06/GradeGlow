import 'dart:async';

import 'package:flutter/material.dart';

import 'playable_cinematic.dart';
import 'playable_models.dart';
import 'playable_progress.dart';

/// Immersive workplace hub — scene, HUD, floor map, live feed.
class PlayableWorkplaceScreen extends StatefulWidget {
  const PlayableWorkplaceScreen({
    super.key,
    required this.career,
    required this.onOpenStage,
  });

  final PlayableCareer career;
  final Future<bool> Function(BuildContext context, PlayableStage stage)
      onOpenStage;

  @override
  State<PlayableWorkplaceScreen> createState() =>
      _PlayableWorkplaceScreenState();
}

class _PlayableWorkplaceScreenState extends State<PlayableWorkplaceScreen>
    with TickerProviderStateMixin {
  late final PlayableProgress _progress = PlayableProgress(widget.career.id);
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  bool _ready = false;
  bool _sawHire = false;
  String _locationId = '';
  final Map<String, bool> _stageDone = <String, bool>{};
  int _feedIndex = 0;
  Timer? _feedTimer;

  PlayableCareer get _c => widget.career;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _feedTimer?.cancel();
    _enter.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final String fallback =
        _c.rooms.isNotEmpty ? _c.rooms.first.id : _c.startLocationId;
    final bool saw = await _progress.getSawHire();
    final String loc = await _progress.getLocation(fallback: fallback);
    final Map<String, bool> flags = await _progress.loadStageFlags(
      _c.stages.map((PlayableStage s) => s.id),
    );
    if (!mounted) return;
    setState(() {
      _sawHire = saw;
      _locationId = loc;
      _stageDone
        ..clear()
        ..addAll(flags);
      _ready = true;
    });
    _enter.forward();
    _feedTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _c.ambientFeed.isEmpty) return;
      setState(() => _feedIndex = (_feedIndex + 1) % _c.ambientFeed.length);
    });
    if (!_sawHire) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_sawHire) _openHireFlow();
      });
    }
  }

  bool _isStageComplete(PlayableStage stage) => _stageDone[stage.id] == true;

  bool _isUnlockSatisfied(String? key) {
    if (key == null || key.isEmpty) return true;
    for (final PlayableStage s in _c.stages) {
      if (s.unlockKey == key || s.id == key) return _isStageComplete(s);
    }
    return _stageDone[key] == true;
  }

  bool _roomLocked(PlayableRoom room) {
    final String? until = room.lockedUntilStageId;
    if (until == null || until.isEmpty) return false;
    return !_isUnlockSatisfied(until);
  }

  PlayableStage? get _nextIncompleteStage {
    for (final PlayableStage s in _c.stages) {
      if (_isStageComplete(s)) continue;
      if (!_isUnlockSatisfied(s.requiresKey)) continue;
      return s;
    }
    return null;
  }

  int get _doneCount =>
      _c.stages.where(_isStageComplete).length;

  double get _progressPct =>
      _c.stages.isEmpty ? 0 : _doneCount / _c.stages.length;

  PlayableRoom get _currentRoom {
    for (final PlayableRoom r in _c.rooms) {
      if (r.id == _locationId) return r;
    }
    return _c.rooms.isNotEmpty
        ? _c.rooms.first
        : const PlayableRoom(
            id: 'lobby',
            name: 'Lobby',
            icon: '🚪',
            blurb: '',
            atmosphere: '',
          );
  }

  Future<void> _openHireFlow() async {
    await showPlayableCinematic(
      context: context,
      accent: _c.accent,
      bg: _c.bg,
      surface: _c.surface,
      eyebrow: 'Career assignment',
      title: 'YOU ARE HIRED\n${_c.roleTitle}',
      body: '${_c.workplaceName}\nSupervisor: ${_c.supervisorName}\n\n${_c.hireTagline}',
      cta: _c.enterCta,
      glyph: _c.roleGlyph,
    );
    if (!mounted) return;

    await showPlayableCinematic(
      context: context,
      accent: _c.accent,
      bg: _c.bg,
      surface: _c.surface,
      eyebrow: '${_c.supervisorRole} · briefing',
      title: _c.supervisorName,
      body: _c.supervisorBrief,
      cta: _c.startCta,
      glyph: _c.supervisorGlyph,
    );
    if (!mounted) return;

    setState(() {
      _sawHire = true;
      _locationId = _c.startLocationId;
    });
    await _progress.setSawHire(true);
    await _progress.setLocation(_locationId);

    final PlayableStage? first = _nextIncompleteStage;
    if (first != null && mounted) await _runStage(first);
  }

  Future<void> _runStage(PlayableStage stage) async {
    if (!_isUnlockSatisfied(stage.requiresKey)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the previous step first.')),
      );
      return;
    }
    setState(() => _locationId = stage.locationId);
    await _progress.setLocation(_locationId);
    if (!mounted) return;

    final bool done = await widget.onOpenStage(context, stage);
    if (!mounted) return;
    if (done) {
      setState(() => _stageDone[stage.id] = true);
      await _progress.setStageDone(stage.id);
    }
  }

  void _go(PlayableRoom room) {
    if (_roomLocked(room)) return;
    setState(() => _locationId = room.id);
    _progress.setLocation(room.id);
    final PlayableStage? next = _nextIncompleteStage;
    if (next != null && next.locationId == room.id) _runStage(next);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: _c.bg,
        body: Center(child: CircularProgressIndicator(color: _c.accent)),
      );
    }

    final PlayableRoom current = _currentRoom;
    final PlayableStage? next = _nextIncompleteStage;
    final String feed = _c.ambientFeed.isEmpty
        ? 'Systems nominal · waiting for your move'
        : _c.ambientFeed[_feedIndex % _c.ambientFeed.length];

    return Scaffold(
      backgroundColor: _c.bg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PlayableSceneBackdrop(
              accent: _c.accent,
              bg: _c.bg,
              surface: _c.surface,
              roomId: current.id,
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _TopBar(
                    career: _c,
                    onBack: () => Navigator.pop(context),
                    progress: _progressPct,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _c.clockLine,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      current.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        height: 1.05,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      current.blurb,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PlayableLiveBadge(
                                accent: _c.accent,
                                label: _c.liveLabel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _MetersRow(
                            accent: _c.accent,
                            labels: _c.meterLabels,
                            progress: _progressPct,
                            pressure: 0.35 + (1 - _progressPct) * 0.4,
                            trust: 0.45 + _progressPct * 0.4,
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: _SceneCard(
                              accent: _c.accent,
                              surface: _c.surface,
                              atmosphere: current.atmosphere,
                              supervisorGlyph: _c.supervisorGlyph,
                              supervisorName: _c.supervisorName,
                              feed: feed,
                              next: next,
                              onMission: next == null
                                  ? null
                                  : () => _runStage(next),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'FLOOR MAP',
                            style: TextStyle(
                              color: _c.accent.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      itemCount: _c.rooms.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int i) {
                        final PlayableRoom r = _c.rooms[i];
                        final bool locked = _roomLocked(r);
                        final bool here = r.id == _locationId;
                        final bool hot = next?.locationId == r.id;
                        return _RoomTile(
                          room: r,
                          accent: _c.accent,
                          surface: _c.surface,
                          locked: locked,
                          here: here,
                          hot: hot,
                          onTap: locked ? null : () => _go(r),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.career,
    required this.onBack,
    required this.progress,
  });

  final PlayableCareer career;
  final VoidCallback onBack;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  career.workplaceName.toUpperCase(),
                  style: TextStyle(
                    color: career.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.05, 1),
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    color: career.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            career.roleGlyph,
            style: const TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _MetersRow extends StatelessWidget {
  const _MetersRow({
    required this.accent,
    required this.labels,
    required this.progress,
    required this.pressure,
    required this.trust,
  });

  final Color accent;
  final List<String> labels;
  final double progress;
  final double pressure;
  final double trust;

  @override
  Widget build(BuildContext context) {
    final List<double> vals = <double>[pressure, trust, progress];
    return Row(
      children: List<Widget>.generate(3, (int i) {
        final String label = i < labels.length ? labels[i] : 'Meter';
        final double v = vals[i].clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 5,
                      backgroundColor: Colors.white10,
                      color: i == 0
                          ? const Color(0xFFF97316)
                          : i == 1
                              ? accent
                              : const Color(0xFF60A5FA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.accent,
    required this.surface,
    required this.atmosphere,
    required this.supervisorGlyph,
    required this.supervisorName,
    required this.feed,
    required this.next,
    required this.onMission,
  });

  final Color accent;
  final Color surface;
  final String atmosphere;
  final String supervisorGlyph;
  final String supervisorName;
  final String feed;
  final PlayableStage? next;
  final VoidCallback? onMission;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  surface.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.15),
                        border: Border.all(color: accent.withValues(alpha: 0.45)),
                      ),
                      child: Text(supervisorGlyph, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            supervisorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'On site · watching your decisions',
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
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      atmosphere,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.55,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.sensors, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            feed,
                            key: ValueKey<String>(feed),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (next != null && onMission != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _MissionLaunch(
                    accent: accent,
                    title: next!.bannerTitle,
                    body: next!.bannerBody,
                    cta: next!.cta,
                    onTap: onMission!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionLaunch extends StatelessWidget {
  const _MissionLaunch({
    required this.accent,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final Color accent;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cta,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.accent,
    required this.surface,
    required this.locked,
    required this.here,
    required this.hot,
    required this.onTap,
  });

  final PlayableRoom room;
  final Color accent;
  final Color surface;
  final bool locked;
  final bool here;
  final bool hot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 128,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: here
                ? Color.lerp(surface, accent, 0.18)
                : Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: here
                  ? accent
                  : hot
                      ? accent.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.08),
              width: here || hot ? 1.6 : 1,
            ),
            boxShadow: hot
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(locked ? '🔒' : room.icon, style: const TextStyle(fontSize: 22)),
                  const Spacer(),
                  if (hot && !locked)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                room.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: locked ? Colors.white38 : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
