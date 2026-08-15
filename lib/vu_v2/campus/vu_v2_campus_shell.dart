import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_faculty_screen.dart';
import '../platform/vu_v2_platform.dart';
import 'vu_v2_campus_home.dart';
import 'vu_v2_community_screen.dart';
import 'vu_v2_notifications_screen.dart';
import 'vu_v2_practice_tab.dart';
import 'vu_v2_profile_screen.dart';
import 'vu_v2_search_screen.dart';
import 'vu_v2_study_center_screen.dart';

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

  Widget _page(VuV2Dest d) {
    switch (d) {
      case VuV2Dest.home:
        return VuV2CampusHome(session: session, progress: progress);
      case VuV2Dest.learn:
        return VuV2LearnTab(session: session, progress: progress);
      case VuV2Dest.labs:
        return VuV2PracticeTab(session: session, progress: progress);
      case VuV2Dest.study:
        return VuV2StudyCenterScreen(session: session, progress: progress);
      case VuV2Dest.community:
        return VuV2CommunityScreen(session: session, progress: progress);
      case VuV2Dest.profile:
        return VuV2ProfileScreen(
          session: session,
          progress: progress,
          embedded: true,
          onThemeChanged: (_) => setState(() {}),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 900;
    final int railIndex = vuV2NavDestinations.indexOf(_dest).clamp(0, vuV2NavDestinations.length - 1);
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        backgroundColor: VuV2Colors.navy,
        title: Text(
          wide ? 'Virtual University' : _dest.label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2SearchScreen(
                    session: session,
                    progress: progress,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2NotificationsScreen(progress: progress),
                ),
              );
            },
            icon: Badge(
              isLabelVisible: progress.unreadCount > 0,
              label: Text('${progress.unreadCount}'),
              backgroundColor: VuV2Colors.mint,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Close campus',
            onPressed: widget.onCloseCampus,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: railIndex,
                  onDestinationSelected: (int i) {
                    setState(() => _dest = vuV2NavDestinations[i]);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: VuV2Colors.navyElevated,
                  destinations: <NavigationRailDestination>[
                    for (final VuV2Dest d in vuV2NavDestinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, color: VuV2Colors.stroke),
                Expanded(child: _page(_dest)),
              ],
            )
          : _page(_dest),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _mobileIndex,
              onDestinationSelected: _onMobileTab,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Learn',
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
        _dest = <VuV2Dest>[
          VuV2Dest.home,
          VuV2Dest.learn,
          VuV2Dest.labs,
        ][i];
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
              for (final VuV2Dest d in vuV2MoreDestinations)
                ListTile(
                  leading: Icon(d.icon, color: VuV2Colors.orange),
                  title: Text(
                    d.label,
                    style: const TextStyle(
                      color: VuV2Colors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _dest = d);
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
