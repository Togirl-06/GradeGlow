import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/ai_tutor_screen.dart';
import '../../services/appearance_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_faculty_screen.dart';
import '../platform/vu_v2_platform.dart';
import 'vu_v2_account_screen.dart';
import 'vu_v2_campus_home.dart';
import 'vu_v2_community_screen.dart';
import 'vu_v2_notifications_screen.dart';
import 'vu_v2_progress_tab.dart';
import '../labs/vu_v2_labs_hub.dart';

class VuV2CampusShell extends StatefulWidget {
  const VuV2CampusShell({
    super.key,
    required this.session,
    required this.progress,
    required this.onCloseCampus,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VoidCallback onCloseCampus;

  @override
  State<VuV2CampusShell> createState() => _VuV2CampusShellState();
}

class _VuV2CampusShellState extends State<VuV2CampusShell> {
  VuV2Dest _dest = VuV2Dest.home;

  VuV2Session get session => widget.session;
  VuV2ProgressStore get progress => widget.progress;

  int get _xp {
    final int base = progress.completedLessonIds.length * 40;
    final int quiz = progress.quizScores.length * 25;
    return base + quiz + 120;
  }

  int get _level => 1 + (_xp ~/ 1000);
  int get _xpIntoLevel => _xp % 1000;

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2NotificationsScreen(progress: progress),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2AccountScreen(
          session: session,
          progress: progress,
          onThemeChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _page(VuV2Dest d) {
    switch (d) {
      case VuV2Dest.home:
        return VuV2CampusHome(session: session, progress: progress);
      case VuV2Dest.learn:
        return VuV2FacultyScreen(
          session: session,
          progress: progress,
          embedded: true,
        );
      case VuV2Dest.labs:
        return VuV2LabsHub(session: session, progress: progress);
      case VuV2Dest.community:
        return VuV2CommunityScreen(session: session, progress: progress);
      case VuV2Dest.profile:
        return VuV2ProgressTab(session: session, progress: progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));
    final bool wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      body: wide
          ? Row(
              children: <Widget>[
                _SideNav(
                  dest: _dest,
                  session: session,
                  onSelect: (VuV2Dest d) => setState(() => _dest = d),
                  onAiTutor: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AiTutorScreen(),
                      ),
                    );
                  },
                  onProfile: _openSettings,
                  onClose: widget.onCloseCampus,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _TopBar(
                        level: _level,
                        xp: _xpIntoLevel,
                        xpMax: 1000,
                        displayName: session.displayName,
                        unread: progress.unreadCount,
                        onNotify: _openNotifications,
                        onProfile: _openSettings,
                      ),
                      Expanded(child: _page(_dest)),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: _TopBar(
                    level: _level,
                    xp: _xpIntoLevel,
                    xpMax: 1000,
                    displayName: session.displayName,
                    unread: progress.unreadCount,
                    onNotify: _openNotifications,
                    onProfile: _openSettings,
                    onBack: widget.onCloseCampus,
                  ),
                ),
                Expanded(child: _page(_dest)),
              ],
            ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              backgroundColor: VuV2Colors.navyElevated,
              indicatorColor: VuV2Colors.mint.withValues(alpha: 0.25),
              selectedIndex: _mobileIndex,
              onDestinationSelected: _onMobileTab,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: 'Courses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.science_outlined),
                  selectedIcon: Icon(Icons.science_rounded),
                  label: 'Labs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz_rounded),
                  selectedIcon: Icon(Icons.more_horiz_rounded),
                  label: 'More',
                ),
              ],
            ),
    );
  }

  int get _mobileIndex {
    switch (_dest) {
      case VuV2Dest.home:
        return 0;
      case VuV2Dest.learn:
        return 1;
      case VuV2Dest.labs:
        return 2;
      default:
        return 3;
    }
  }

  void _onMobileTab(int i) {
    if (i < 3) {
      setState(() {
        _dest = <VuV2Dest>[VuV2Dest.home, VuV2Dest.learn, VuV2Dest.labs][i];
      });
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VuV2Colors.navyElevated,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.smart_toy_outlined, color: VuV2Colors.mint),
                title: Text('AI Tutor', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AiTutorScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.groups_outlined, color: VuV2Colors.mint),
                title: Text('Community', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _dest = VuV2Dest.community);
                },
              ),
              ListTile(
                leading: Icon(Icons.insights_outlined, color: VuV2Colors.mint),
                title: Text(
                  'Progress',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _dest = VuV2Dest.profile);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.displayName,
    required this.unread,
    required this.onNotify,
    required this.onProfile,
    this.onBack,
  });

  final int level;
  final int xp;
  final int xpMax;
  final String displayName;
  final int unread;
  final VoidCallback onNotify;
  final VoidCallback onProfile;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: BoxDecoration(
        color: VuV2Colors.navyElevated.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: VuV2Colors.stroke.withValues(alpha: 0.8)),
        ),
      ),
      child: Row(
        children: <Widget>[
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.close_rounded, color: VuV2Colors.mute),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: VuV2Colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VuV2Colors.stroke),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Level $level',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (xp / xpMax).clamp(0.05, 1),
                      minHeight: 7,
                      backgroundColor: VuV2Colors.stroke,
                      color: VuV2Colors.mint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$xp / $xpMax XP',
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: onNotify,
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              backgroundColor: VuV2Colors.danger,
              child: Icon(Icons.notifications_outlined, color: VuV2Colors.mute),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Settings',
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onProfile,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: VuV2Colors.mint,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.dest,
    required this.session,
    required this.onSelect,
    required this.onAiTutor,
    required this.onProfile,
    required this.onClose,
  });

  final VuV2Dest dest;
  final VuV2Session session;
  final ValueChanged<VuV2Dest> onSelect;
  final VoidCallback onAiTutor;
  final VoidCallback onProfile;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: VuV2Colors.navyElevated,
        border: Border(right: BorderSide(color: VuV2Colors.stroke)),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: <Color>[VuV2Colors.mint, VuV2Colors.dashPink],
                ),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white),
            ),
            const SizedBox(height: 18),
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              selected: dest == VuV2Dest.home,
              onTap: () => onSelect(VuV2Dest.home),
            ),
            _NavItem(
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book_rounded,
              label: 'Courses',
              selected: dest == VuV2Dest.learn,
              onTap: () => onSelect(VuV2Dest.learn),
            ),
            _NavItem(
              icon: Icons.apartment_outlined,
              selectedIcon: Icons.apartment_rounded,
              label: 'Virtual\nUniversity',
              selected: dest == VuV2Dest.home,
              highlight: true,
              onTap: () => onSelect(VuV2Dest.home),
            ),
            _NavItem(
              icon: Icons.smart_toy_outlined,
              selectedIcon: Icons.smart_toy_rounded,
              label: 'AI Tutor',
              selected: false,
              onTap: onAiTutor,
            ),
            _NavItem(
              icon: Icons.science_outlined,
              selectedIcon: Icons.science_rounded,
              label: 'Labs',
              selected: dest == VuV2Dest.labs,
              onTap: () => onSelect(VuV2Dest.labs),
            ),
            _NavItem(
              icon: Icons.insights_outlined,
              selectedIcon: Icons.insights_rounded,
              label: 'Progress',
              selected: dest == VuV2Dest.profile,
              onTap: () => onSelect(VuV2Dest.profile),
            ),
            _NavItem(
              icon: Icons.groups_outlined,
              selectedIcon: Icons.groups_rounded,
              label: 'Community',
              selected: dest == VuV2Dest.community,
              onTap: () => onSelect(VuV2Dest.community),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: <Widget>[
                  Tooltip(
                    message: 'Settings',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onProfile,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: VuV2Colors.mint,
                        child: Text(
                          session.displayName.isNotEmpty
                              ? session.displayName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.displayName.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: VuV2Colors.mute,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: onClose,
                    child: Text(
                      'Exit',
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 11,
                      ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bool active = selected || highlight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: highlight
                ? VuV2Colors.mint.withValues(alpha: 0.28)
                : selected
                    ? VuV2Colors.ink.withValues(alpha: 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                active ? selectedIcon : icon,
                color: highlight
                    ? VuV2Colors.mint
                    : selected
                        ? VuV2Colors.ink
                        : VuV2Colors.mute,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlight || selected ? VuV2Colors.ink : VuV2Colors.mute,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
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
