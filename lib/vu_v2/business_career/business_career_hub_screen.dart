import 'package:flutter/material.dart';

import 'biz_career_center_screen.dart';
import 'biz_character_screen.dart';
import 'biz_interview_center_screen.dart';
import 'biz_project_lab_screen.dart';
import 'biz_workplace_screen.dart';
import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';
import 'case_arena_screen.dart';

/// School of Business & Economics career simulation hub.
class BusinessCareerHubScreen extends StatefulWidget {
  const BusinessCareerHubScreen({
    super.key,
    this.initialMajorId,
    this.playerName,
  });

  final String? initialMajorId;
  final String? playerName;

  @override
  State<BusinessCareerHubScreen> createState() =>
      _BusinessCareerHubScreenState();
}

class _BusinessCareerHubScreenState extends State<BusinessCareerHubScreen> {
  final BusinessCareerProgress _progress = BusinessCareerProgress.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (widget.initialMajorId != null) {
      await _progress.setMajor(_mapFeaturedToMajor(widget.initialMajorId!));
    }
    if (mounted) setState(() => _ready = true);
  }

  String _mapFeaturedToMajor(String id) {
    final String s = id.toLowerCase();
    if (s.contains('account')) return 'accounting';
    if (s.contains('financ')) return 'finance';
    if (s.contains('econom')) return 'economics';
    if (s.contains('entre')) return 'entrepreneurship';
    if (s.contains('market')) return 'marketing';
    if (s.contains('human') || s.contains('hr')) {
      return 'human_resource_management';
    }
    if (s.contains('international') || s.contains('global')) {
      return 'international_business';
    }
    return 'business_administration';
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

  Future<void> _openAppearance() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BizCharacterScreen(
          progress: _progress,
          onDone: () => Navigator.of(context).pop(),
        ),
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
        backgroundColor: BizCosmic.bg,
        body: Center(
          child: CircularProgressIndicator(color: BizCosmic.emerald),
        ),
      );
    }

    final BusinessMajor major = BusinessMajors.byId(_progress.majorId);
    final String name =
        (widget.playerName ?? 'Student').trim().split(' ').first;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      body: BizStarfield(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _progress,
            builder: (BuildContext context, _) {
              final bool interviewReady = _progress.appliedJobIds.any(
                (String id) {
                  final String s =
                      _progress.applicationStatus[id] ?? 'none';
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
                    onAppearance: _openAppearance,
                  ),
                  Expanded(
                    child: _Destinations(
                      employed: _progress.hasAnyJob,
                      jobActionLabel: _progress.jobActionLabel(),
                      interviewReady: interviewReady,
                      onArena: () => _open(
                        CaseArenaScreen(progress: _progress),
                      ),
                      onCareer: () => _open(
                        BizCareerCenterScreen(progress: _progress),
                      ),
                      onInterview: () => _open(
                        BizInterviewCenterScreen(progress: _progress),
                      ),
                      onCompany: () {
                        if (_progress.hasAnyJob) {
                          _open(BizWorkplaceScreen(progress: _progress));
                        } else {
                          _toast(
                            'Company District unlocks after you accept a job offer',
                          );
                        }
                      },
                      onProject: () => _open(
                        BizProjectLabScreen(progress: _progress),
                      ),
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
    required this.onAppearance,
  });

  final String name;
  final String initial;
  final int level;
  final String stage;
  final int xp;
  final int xpMax;
  final String balanceLabel;
  final String lifetimeEarnedLabel;
  final VoidCallback onAppearance;

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
              color: BizCosmic.mute,
            ),
          ),
          GestureDetector(
            onTap: onAppearance,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: BizCosmic.emerald,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
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
                    color: BizCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Level $level · $stage',
                  style: const TextStyle(
                    color: BizCosmic.mute,
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
                    backgroundColor: BizCosmic.stroke,
                    color: BizCosmic.electric,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp / $xpMax XP',
                  style: const TextStyle(color: BizCosmic.mute, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                BizCosmic.pill(
                  'Bank $balanceLabel',
                  icon: Icons.account_balance_wallet_rounded,
                  bg: BizCosmic.gold.withValues(alpha: 0.18),
                  fg: BizCosmic.gold,
                ),
                const SizedBox(height: 6),
                BizCosmic.pill(
                  'Made $lifetimeEarnedLabel',
                  icon: Icons.trending_up_rounded,
                  bg: BizCosmic.success.withValues(alpha: 0.16),
                  fg: BizCosmic.success,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onAppearance,
                  style: TextButton.styleFrom(
                    foregroundColor: BizCosmic.electric,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Appearance', style: TextStyle(fontSize: 11)),
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
  });

  final bool employed;
  final String jobActionLabel;
  final bool interviewReady;
  final VoidCallback onArena;
  final VoidCallback onInterview;
  final VoidCallback onCareer;
  final VoidCallback onCompany;
  final VoidCallback onProject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'School of Business & Economics',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BizCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cases · applications · interviews · paid work',
          style: TextStyle(
            color: BizCosmic.mute.withValues(alpha: 0.95),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: <Widget>[
              _DestTile(
                color: BizCosmic.purple,
                label: '1. Case Arena',
                sub: 'Case challenges and decision drills',
                icon: Icons.psychology_alt_rounded,
                glow: true,
                onTap: onArena,
              ),
              _DestTile(
                color: const Color(0xFF1E3A5F),
                label: '2. Career Center',
                sub: 'Apply with résumé',
                icon: Icons.work_rounded,
                glow: true,
                onTap: onCareer,
              ),
              _DestTile(
                color: BizCosmic.royal,
                label: '3. Interview Center',
                sub: 'After you apply',
                icon: Icons.chat_bubble_rounded,
                badge: interviewReady ? '!' : null,
                onTap: onInterview,
              ),
              _DestTile(
                color: BizCosmic.emerald,
                label: '4. Company District',
                sub: employed ? jobActionLabel : 'Locked until hired',
                icon: Icons.apartment_rounded,
                glow: employed,
                dim: !employed,
                youMarker: employed,
                onTap: onCompany,
              ),
              _DestTile(
                color: BizCosmic.gold,
                label: '5. Project Lab',
                sub: 'Build résumé · add projects',
                icon: Icons.folder_special_rounded,
                onTap: onProject,
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
                    BizCosmic.bgDeep.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: glow
                      ? BizCosmic.electric
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
                              BizCosmic.pill(
                                badge!,
                                bg: BizCosmic.warning.withValues(alpha: 0.25),
                                fg: BizCosmic.warning,
                              ),
                            ],
                            if (youMarker) ...<Widget>[
                              const SizedBox(width: 6),
                              BizCosmic.pill('You'),
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

  final BusinessMajor major;
  final BusinessCareerProgress progress;
  final ValueChanged<String> onMajorChanged;

  @override
  Widget build(BuildContext context) {
    final bool resumeDone = progress.resumeReadyToApply;
    final bool appliedDone = progress.appliedJobIds.isNotEmpty;
    final bool interviewDone = progress.applicationStatus.values.any(
      (dynamic s) =>
          '$s' == 'interviewed' ||
          '$s' == 'offered' ||
          '$s' == 'hired',
    );
    final bool hiredDone = progress.hasAnyJob;
    final bool offered = progress.applicationStatus.values.any(
      (dynamic s) => '$s' == 'offered',
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BizCosmic.panelBox(radius: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool stack = c.maxWidth < 700;
          final Widget majorDrop = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your major',
                style: TextStyle(color: BizCosmic.mute, fontSize: 11),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: progress.majorId,
                  isExpanded: true,
                  dropdownColor: BizCosmic.panelAlt,
                  style: const TextStyle(
                    color: BizCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  items: BusinessMajors.all
                      .map(
                        (BusinessMajor m) => DropdownMenuItem<String>(
                          value: m.id,
                          child: Text(m.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (String? id) {
                    if (id != null) onMajorChanged(id);
                  },
                ),
              ),
            ],
          );

          final Widget path = Row(
            children: <Widget>[
              _Step(
                n: 1,
                label: 'Build résumé',
                state: resumeDone ? 'Cleared' : 'Next up',
                done: resumeDone,
                active: !resumeDone,
              ),
              _Step(
                n: 2,
                label: 'Apply',
                state: appliedDone
                    ? 'Cleared'
                    : resumeDone
                        ? 'Next up'
                        : 'Locked',
                done: appliedDone,
                active: resumeDone && !appliedDone,
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
                done: hiredDone || offered,
                active: appliedDone && !hiredDone && !offered,
              ),
              _Step(
                n: 4,
                label: 'Offer / Start job',
                state: hiredDone
                    ? 'Cleared'
                    : offered
                        ? 'Accept offer'
                        : interviewDone
                            ? 'Next up'
                            : 'Locked',
                done: hiredDone,
                active: offered && !hiredDone,
                last: true,
              ),
            ],
          );

          final Widget earnings = Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BizCosmic.panelAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BizCosmic.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Earnings · Made ${progress.lifetimeEarnedLabel}',
                  style: const TextStyle(
                    color: BizCosmic.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bank ${progress.balanceLabel}',
                  style: const TextStyle(
                    color: BizCosmic.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  major.facility,
                  style: const TextStyle(
                    color: BizCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                majorDrop,
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: path,
                ),
                const SizedBox(height: 10),
                earnings,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 200, child: majorDrop),
              Expanded(child: path),
              const SizedBox(width: 12),
              SizedBox(width: 200, child: earnings),
            ],
          );
        },
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
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? BizCosmic.royal
                    : active
                        ? BizCosmic.ink
                        : BizCosmic.stroke,
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$n',
                      style: TextStyle(
                        color: active ? BizCosmic.bg : BizCosmic.mute,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: BizCosmic.ink,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              state,
              style: TextStyle(
                color: done
                    ? BizCosmic.success
                    : active
                        ? BizCosmic.electric
                        : BizCosmic.mute,
                fontSize: 10,
              ),
            ),
          ],
        ),
        if (!last)
          Container(
            width: 28,
            height: 2,
            margin: const EdgeInsets.only(bottom: 28, left: 4, right: 4),
            color: BizCosmic.stroke,
          ),
      ],
    );
  }
}
