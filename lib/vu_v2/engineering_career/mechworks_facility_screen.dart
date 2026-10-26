import 'package:flutter/material.dart';

import 'activity_selector_screen.dart';
import 'challenge_arena_screen.dart';
import 'engineering_career_center_screen.dart';
import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_interview_screen.dart';
import 'engineering_profile_screen.dart';
import 'engineering_project_lab_screen.dart';
import 'mission_briefing_screen.dart';
import 'work_task_board_screen.dart';

/// Major facility hub — MechWorks / Build-a-City / Power Grid / etc.
class MechWorksFacilityScreen extends StatefulWidget {
  const MechWorksFacilityScreen({
    super.key,
    required this.progress,
    this.playerName,
    this.majorId,
  });

  final EngineeringCareerProgress progress;
  final String? playerName;
  final String? majorId;

  @override
  State<MechWorksFacilityScreen> createState() =>
      _MechWorksFacilityScreenState();
}

class _MechWorksFacilityScreenState extends State<MechWorksFacilityScreen> {
  int _tab = 0;

  EngineeringCareerProgress get p => widget.progress;

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EngineeringMajor major = EngineeringMajors.byId(
      widget.majorId ?? p.majorId,
    );
    final EngMission featured = p.hasActiveMission &&
            (EngMissionCatalog.byId(p.activeMissionId!)?.majorId == major.id)
        ? (EngMissionCatalog.byId(p.activeMissionId!) ??
            EngineeringMajors.featuredMissionFor(major.id))
        : EngineeringMajors.featuredMissionFor(major.id);

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: major.facility,
        icon: major.icon,
        subtitle: major.title.split(' ').first,
      ),
      body: EngStarfield(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: <Widget>[
                  Container(
                    height: 200,
                    decoration: EngCosmic.panelBox(radius: 18),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(painter: _FactoryScenePainter()),
                        ),
                        Positioned(
                          left: 14,
                          top: 14,
                          child: EngCosmic.pill(
                            'Lv ${p.level} · ${p.stageLabel}',
                            bg: EngCosmic.bg.withValues(alpha: 0.7),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: EngCosmic.bg.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    EngCosmic.electric.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'YOUR MISSION',
                                  style: TextStyle(
                                    color: EngCosmic.electric,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  featured.title,
                                  style: const TextStyle(
                                    color: EngCosmic.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  featured.objective,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: EngCosmic.mute,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                FilledButton(
                                  onPressed: () => _open(
                                    MissionBriefingScreen(
                                      progress: p,
                                      mission: featured,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: EngCosmic.electric,
                                  ),
                                  child: Text(
                                    p.hasActiveMission
                                        ? 'Continue Mission'
                                        : 'Start Mission',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      const CircleAvatar(
                        backgroundColor: EngCosmic.teal,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mentor Priya · Welcome to ${major.facility}. '
                          'Hotspots below open real activities — not decorations.',
                          style: const TextStyle(
                            color: EngCosmic.mute,
                            height: 1.35,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Facility hotspots',
                    style: TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _Hot(
                        label: 'Activity floor',
                        onTap: () => _open(ActivitySelectorScreen(progress: p)),
                      ),
                      _Hot(
                        label: 'Featured mission',
                        onTap: () => _open(
                          MissionBriefingScreen(
                            progress: p,
                            mission: featured,
                          ),
                        ),
                      ),
                      _Hot(
                        label: 'Challenge Arena',
                        onTap: () => _open(ChallengeArenaScreen(progress: p)),
                      ),
                      _Hot(
                        label: 'Mission board',
                        onTap: () => _open(
                          MissionBriefingScreen(
                            progress: p,
                            mission: EngMissionCatalog.forMajor(major.id).isEmpty
                                ? featured
                                : (EngMissionCatalog.forMajor(major.id).length >
                                        1
                                    ? EngMissionCatalog.forMajor(major.id)[0]
                                    : featured),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Skills · Torque Lv ${p.skillLevels['Torque'] ?? 1} · '
                    'Statics Lv ${p.skillLevels['Statics'] ?? 1} · '
                    'Bank ${p.balanceLabel}',
                    style: const TextStyle(color: EngCosmic.gold, fontSize: 12),
                  ),
                ],
              ),
            ),
            _BottomNav(
              index: _tab,
              employed: p.hasAnyJob,
              onSelect: (int i) async {
                setState(() => _tab = i);
                switch (i) {
                  case 0:
                    await _open(ChallengeArenaScreen(progress: p));
                  case 1:
                    await _open(EngineeringProjectLabScreen(progress: p));
                  case 2:
                    await _open(EngineeringInterviewScreen(progress: p));
                  case 3:
                    await _open(EngineeringCareerCenterScreen(progress: p));
                  case 4:
                    if (!p.hasAnyJob) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Workplace unlocks after you accept a job offer.',
                          ),
                        ),
                      );
                    } else {
                      await _open(WorkTaskBoardScreen(progress: p));
                    }
                  case 5:
                    await _open(
                      EngineeringProfileScreen(
                        progress: p,
                        playerName: widget.playerName,
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Hot extends StatelessWidget {
  const _Hot({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: EngCosmic.panelAlt,
      side: const BorderSide(color: EngCosmic.stroke),
      label: Text(label, style: const TextStyle(color: EngCosmic.ink)),
      avatar: const Icon(Icons.place, size: 16, color: EngCosmic.electric),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.employed,
    required this.onSelect,
  });

  final int index;
  final bool employed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String)> items = <(IconData, String)>[
      (Icons.emoji_events_rounded, 'Challenges'),
      (Icons.science_rounded, 'Projects'),
      (Icons.record_voice_over_rounded, 'Interview'),
      (Icons.work_rounded, 'Career'),
      (Icons.apartment_rounded, 'Workplace'),
      (Icons.badge_rounded, 'Profile'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: EngCosmic.panel.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: EngCosmic.stroke.withValues(alpha: 0.8))),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      items[i].$1,
                      size: 20,
                      color: i == 4 && !employed
                          ? EngCosmic.mute.withValues(alpha: 0.5)
                          : i == index
                              ? EngCosmic.electric
                              : EngCosmic.mute,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        color: i == index ? EngCosmic.ink : EngCosmic.mute,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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

class _FactoryScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0B1224),
    );
    final Paint floor = Paint()..color = const Color(0xFF1E293B);
    final Path platform = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
    canvas.drawPath(platform, floor);

    final Paint gear = Paint()..color = const Color(0xFF60A5FA);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.38), 26, gear);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.34), 16, gear);
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.38),
      9,
      Paint()..color = const Color(0xFF0B1224),
    );

    final Paint arm = Paint()
      ..color = EngCosmic.gold
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final Offset base = Offset(size.width * 0.28, size.height * 0.5);
    canvas.drawLine(base, Offset(base.dx + 55, base.dy - 30), arm);
    canvas.drawCircle(Offset(base.dx + 55, base.dy - 30), 7, arm);

    // avatar blob
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.42),
      14,
      Paint()..color = const Color(0xFFF5D0B0),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.22, size.height * 0.52),
          width: 28,
          height: 22,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF93C5FD),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
