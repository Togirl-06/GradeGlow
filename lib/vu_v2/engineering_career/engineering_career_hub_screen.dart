import 'package:flutter/material.dart';

import 'challenge_arena_screen.dart';
import 'engineering_career_center_screen.dart';
import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_interview_screen.dart';
import 'engineering_profile_screen.dart';
import 'engineering_project_lab_screen.dart';
import 'mechworks_workplace_screen.dart';
import 'work_task_board_screen.dart';

/// School of Engineering career simulation hub — same loop as Tech / Business.
class EngineeringCareerHubScreen extends StatefulWidget {
  const EngineeringCareerHubScreen({
    super.key,
    this.initialMajorId,
    this.playerName,
  });

  final String? initialMajorId;
  final String? playerName;

  @override
  State<EngineeringCareerHubScreen> createState() =>
      _EngineeringCareerHubScreenState();
}

class _EngineeringCareerHubScreenState
    extends State<EngineeringCareerHubScreen> {
  final EngineeringCareerProgress _progress = EngineeringCareerProgress.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (widget.initialMajorId != null) {
      await _progress.setMajor(widget.initialMajorId!);
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, Animation<double> a, _, Widget child) {
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: EngCosmic.bg,
        body: Center(
          child: CircularProgressIndicator(color: EngCosmic.electric),
        ),
      );
    }

    final EngineeringMajor major = EngineeringMajors.byId(_progress.majorId);
    final String name =
        (widget.playerName ?? 'Student').trim().split(' ').first;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      body: EngStarfield(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _progress,
            builder: (BuildContext context, _) {
              final bool interviewReady = _progress.appliedJobIds.any(
                (String id) {
                  final String s = _progress.statusFor(id);
                  return s == 'applied' || s == 'interviewed';
                },
              );

              return Column(
                children: <Widget>[
                  _TopHud(
                    name: name,
                    initial: initial,
                    level: _progress.level,
                    stage: _progress.stageLabel,
                    xp: _progress.xpIntoLevel,
                    xpMax: _progress.xpToNextLevel,
                    balanceLabel: _progress.balanceLabel,
                    lifetimeEarnedLabel: _progress.lifetimeEarnedLabel,
                    onProfile: () => _open(
                      EngineeringProfileScreen(
                        progress: _progress,
                        playerName: widget.playerName,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Destinations(
                      employed: _progress.hasAnyJob,
                      jobActionLabel: _progress.jobActionLabel(),
                      interviewReady: interviewReady,
                      onArena: () => _open(
                        ChallengeArenaScreen(progress: _progress),
                      ),
                      onCareer: () => _open(
                        EngineeringCareerCenterScreen(progress: _progress),
                      ),
                      onInterview: () {
                        final String? jobId = _progress.appliedJobIds
                            .cast<String?>()
                            .firstWhere(
                              (String? id) {
                                final String s = _progress.statusFor(id!);
                                return s == 'applied' || s == 'interviewed';
                              },
                              orElse: () => null,
                            );
                        _open(
                          EngineeringInterviewScreen(
                            progress: _progress,
                            forJobId: jobId,
                          ),
                        );
                      },
                      onCompany: () {
                        if (_progress.hasAnyJob) {
                          _open(
                            WorkTaskBoardScreen(progress: _progress),
                          );
                        } else {
                          _toast(
                            'Company District unlocks after you accept a job offer',
                          );
                        }
                      },
                      onProject: () => _open(
                        EngineeringProjectLabScreen(progress: _progress),
                      ),
                      onWorkplace: _progress.hasAnyJob
                          ? () => _open(
                                MechWorksWorkplaceScreen(progress: _progress),
                              )
                          : null,
                    ),
                  ),
                  _BottomHud(
                    major: major,
                    progress: _progress,
                    onMajorChanged: (String id) async {
                      await _progress.setMajor(id);
                      setState(() {});
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.name,
    required this.initial,
    required this.level,
    required this.stage,
    required this.xp,
    required this.xpMax,
    required this.balanceLabel,
    required this.lifetimeEarnedLabel,
    required this.onProfile,
  });

  final String name;
  final String initial;
  final int level;
  final String stage;
  final int xp;
  final int xpMax;
  final String balanceLabel;
  final String lifetimeEarnedLabel;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: EngCosmic.mute,
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: EngCosmic.blue,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: EngCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Level $level · $stage',
                  style: const TextStyle(
                    color: EngCosmic.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: xpMax <= 0 ? 0 : (xp / xpMax).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: EngCosmic.stroke,
                    color: EngCosmic.electric,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp / $xpMax XP',
                  style: const TextStyle(color: EngCosmic.mute, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                EngCosmic.pill(
                  'Bank $balanceLabel',
                  icon: Icons.account_balance_wallet_rounded,
                  bg: EngCosmic.gold.withValues(alpha: 0.18),
                  fg: EngCosmic.gold,
                ),
                const SizedBox(height: 6),
                EngCosmic.pill(
                  'Made $lifetimeEarnedLabel',
                  icon: Icons.trending_up_rounded,
                  bg: EngCosmic.success.withValues(alpha: 0.16),
                  fg: EngCosmic.success,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onProfile,
                  style: TextButton.styleFrom(
                    foregroundColor: EngCosmic.electric,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Profile', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Destinations extends StatelessWidget {
  const _Destinations({
    required this.employed,
    required this.jobActionLabel,
    required this.interviewReady,
    required this.onArena,
    required this.onInterview,
    required this.onCareer,
    required this.onCompany,
    required this.onProject,
    this.onWorkplace,
  });

  final bool employed;
  final String jobActionLabel;
  final bool interviewReady;
  final VoidCallback onArena;
  final VoidCallback onInterview;
  final VoidCallback onCareer;
  final VoidCallback onCompany;
  final VoidCallback onProject;
  final VoidCallback? onWorkplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'School of Engineering',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: EngCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Challenges · applications · interviews · paid work',
          style: TextStyle(
            color: EngCosmic.mute.withValues(alpha: 0.95),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: <Widget>[
              _DestTile(
                color: EngCosmic.purple,
                label: '1. Challenge Arena',
                sub: 'Missions and engineering checks',
                icon: Icons.emoji_events_rounded,
                glow: true,
                onTap: onArena,
              ),
              _DestTile(
                color: const Color(0xFF1E3A5F),
                label: '2. Career Center',
                sub: 'Apply after you complete a mission',
                icon: Icons.work_rounded,
                glow: true,
                onTap: onCareer,
              ),
              _DestTile(
                color: EngCosmic.electric,
                label: '3. Interview Center',
                sub: 'After you apply',
                icon: Icons.chat_bubble_rounded,
                badge: interviewReady ? '!' : null,
                onTap: onInterview,
              ),
              _DestTile(
                color: EngCosmic.teal,
                label: '4. Company District',
                sub: employed ? jobActionLabel : 'Locked until hired',
                icon: Icons.apartment_rounded,
                glow: employed,
                dim: !employed,
                youMarker: employed,
                onTap: onCompany,
              ),
              _DestTile(
                color: EngCosmic.gold,
                label: '5. Innovation Garage',
                sub: 'Projects · portfolio · résumé',
                icon: Icons.science_rounded,
                onTap: onProject,
              ),
              if (onWorkplace != null)
                _DestTile(
                  color: EngCosmic.blue,
                  label: 'Workplace floor',
                  sub: 'Clock in · run shift tasks',
                  icon: Icons.precision_manufacturing_rounded,
                  glow: true,
                  onTap: onWorkplace!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestTile extends StatelessWidget {
  const _DestTile({
    required this.color,
    required this.label,
    required this.sub,
    required this.icon,
    required this.onTap,
    this.glow = false,
    this.dim = false,
    this.youMarker = false,
    this.badge,
  });

  final Color color;
  final String label;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;
  final bool glow;
  final bool dim;
  final bool youMarker;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: dim ? 0.6 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    color.withValues(alpha: 0.95),
                    color.withValues(alpha: 0.45),
                    EngCosmic.bgDeep.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: glow
                      ? EngCosmic.electric
                      : Colors.white.withValues(alpha: 0.16),
                  width: glow ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (badge != null) ...<Widget>[
                              const SizedBox(width: 6),
                              EngCosmic.pill(
                                badge!,
                                bg: EngCosmic.orange.withValues(alpha: 0.25),
                                fg: EngCosmic.orange,
                              ),
                            ],
                            if (youMarker) ...<Widget>[
                              const SizedBox(width: 6),
                              EngCosmic.pill('You'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.major,
    required this.progress,
    required this.onMajorChanged,
  });

  final EngineeringMajor major;
  final EngineeringCareerProgress progress;
  final ValueChanged<String> onMajorChanged;

  @override
  Widget build(BuildContext context) {
    final bool missionDone = progress.completedMissions.isNotEmpty;
    final bool appliedDone = progress.appliedJobIds.isNotEmpty;
    final bool interviewDone = progress.interviewPassed ||
        progress.applicationStatus.values.any(
          (String s) =>
              s == 'interviewed' || s == 'offered' || s == 'hired',
        );
    final bool hiredDone = progress.hasAnyJob;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: EngCosmic.panelBox(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Your major',
            style: TextStyle(color: EngCosmic.mute, fontSize: 11),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: progress.majorId,
              dropdownColor: EngCosmic.panelAlt,
              style: const TextStyle(
                color: EngCosmic.ink,
                fontWeight: FontWeight.w700,
              ),
              items: EngineeringMajors.all
                  .map(
                    (EngineeringMajor m) => DropdownMenuItem<String>(
                      value: m.id,
                      child: Text(m.title),
                    ),
                  )
                  .toList(),
              onChanged: (String? id) {
                if (id != null) onMajorChanged(id);
              },
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _Step(
                  n: 1,
                  label: 'Clear a mission',
                  state: missionDone ? 'Cleared' : 'Next up',
                  done: missionDone,
                  active: !missionDone,
                ),
                _Step(
                  n: 2,
                  label: 'Apply',
                  state: appliedDone
                      ? 'Cleared'
                      : missionDone
                          ? 'Next up'
                          : 'Locked',
                  done: appliedDone,
                  active: missionDone && !appliedDone,
                ),
                _Step(
                  n: 3,
                  label: 'Interview',
                  state: hiredDone
                      ? 'Cleared'
                      : interviewDone
                          ? 'In loop'
                          : appliedDone
                              ? 'Next up'
                              : 'Locked',
                  done: hiredDone,
                  active: appliedDone && !hiredDone,
                ),
                _Step(
                  n: 4,
                  label: 'Offer · Job',
                  state: hiredDone
                      ? 'Cleared'
                      : progress.applicationStatus.values.contains('offered')
                          ? 'Accept offer'
                          : interviewDone
                              ? 'Next up'
                              : 'Locked',
                  done: hiredDone,
                  active:
                      progress.applicationStatus.values.contains('offered') &&
                          !hiredDone,
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EngCosmic.panelAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EngCosmic.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Earnings · Made ${progress.lifetimeEarnedLabel}',
                  style: const TextStyle(
                    color: EngCosmic.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bank ${progress.balanceLabel}',
                  style: const TextStyle(
                    color: EngCosmic.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Facility: ${major.facility}',
                  style: const TextStyle(color: EngCosmic.mute, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.n,
    required this.label,
    required this.state,
    required this.done,
    required this.active,
    this.last = false,
  });

  final int n;
  final String label;
  final String state;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final Color ring = done
        ? EngCosmic.success
        : active
            ? EngCosmic.electric
            : EngCosmic.mute;
    return Padding(
      padding: EdgeInsets.only(right: last ? 0 : 10),
      child: SizedBox(
        width: 88,
        child: Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? EngCosmic.success.withValues(alpha: 0.2)
                    : EngCosmic.panelAlt,
                border: Border.all(color: ring, width: 2),
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  color: ring,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EngCosmic.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              state,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? EngCosmic.electric : EngCosmic.mute,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
