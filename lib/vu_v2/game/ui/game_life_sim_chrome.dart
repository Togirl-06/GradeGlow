import 'package:flutter/material.dart';

/// Life-sim HUD: location chip, objectives, vitals, hotbar — GradeGlow original.
class GameLifeSimChrome extends StatelessWidget {
  const GameLifeSimChrome({
    super.key,
    required this.locationName,
    required this.playerName,
    required this.level,
    required this.xp,
    required this.accent,
    required this.onBack,
    required this.onInteract,
    required this.hotbar,
    required this.selectedHotbar,
    required this.onHotbar,
    this.objectives = const <({String label, bool done})>[],
    this.missionTitle,
    this.statusLine,
    this.toast,
    this.nearLabel,
    this.mood = 11,
  });

  final String locationName;
  final String playerName;
  final int level;
  final int xp;
  final Color accent;
  final VoidCallback onBack;
  final VoidCallback onInteract;
  final List<({IconData icon, String label, String id})> hotbar;
  final String? selectedHotbar;
  final ValueChanged<String> onHotbar;
  final List<({String label, bool done})> objectives;
  final String? missionTitle;
  final String? statusLine;
  final String? toast;
  final String? nearLabel;
  final int mood;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      color: const Color(0xFF1A2E1A),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1A2E1A),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '$playerName · Lv $level',
                            style: TextStyle(
                              color: const Color(0xFF1A2E1A).withValues(alpha: 0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const Spacer(),
              if (statusLine != null)
                Flexible(
                  child: _pill(
                    color: const Color(0xFF1A2E1A).withValues(alpha: 0.88),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        statusLine!,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              _pill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.mood_rounded, color: accent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$mood',
                        style: const TextStyle(
                          color: Color(0xFF1A2E1A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (missionTitle != null && objectives.isNotEmpty)
          Positioned(
            top: 64,
            right: 10,
            child: _objectivesCard(),
          ),
        if (toast != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: 118,
            child: Center(
              child: _pill(
                color: const Color(0xFF1A2E1A).withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    toast!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _bottomBar(),
        ),
      ],
    );
  }

  Widget _objectivesCard() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'OBJECTIVES',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            missionTitle!,
            style: const TextStyle(
              color: Color(0xFF1A2E1A),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...objectives.take(6).map(
            (({String label, bool done}) o) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    o.done ? Icons.check_circle : Icons.circle_outlined,
                    size: 15,
                    color: o.done ? accent : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      o.label,
                      style: TextStyle(
                        color: o.done
                            ? const Color(0xFF1A2E1A)
                            : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        decoration:
                            o.done ? TextDecoration.lineThrough : null,
                      ),
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

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            const Color(0xFF0B1220).withValues(alpha: 0.55),
            const Color(0xFF0B1220).withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (nearLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                nearLabel!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (final ({IconData icon, String label, String id}) slot
                          in hotbar)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _hotSlot(slot),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onInteract,
                icon: const Icon(Icons.touch_app_rounded),
                label: const Text('INTERACT'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$xp XP  ·  tap the world to walk',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotSlot(({IconData icon, String label, String id}) slot) {
    final bool on = selectedHotbar == slot.id;
    return Tooltip(
      message: slot.label,
      child: InkWell(
        onTap: () => onHotbar(slot.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: on ? accent.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: on ? accent : Colors.white24,
              width: on ? 2 : 1,
            ),
          ),
          child: Icon(slot.icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _pill({required Widget child, Color? color}) {
    return Material(
      color: color ?? Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: child,
    );
  }
}
