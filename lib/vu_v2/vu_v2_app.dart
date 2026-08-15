import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/appearance_service.dart';
import 'campus/vu_v2_campus_home.dart';
import 'campus/vu_v2_notifications_screen.dart';
import 'campus/vu_v2_practice_tab.dart';
import 'campus/vu_v2_progress_tab.dart';
import 'campus/vu_v2_search_screen.dart';
import 'campus/vu_v2_subscription_screen.dart';
import 'data/vu_v2_progress_store.dart';
import 'data/vu_v2_roadmap_sync.dart';
import 'data/vu_v2_scope.dart';
import 'data/vu_v2_session.dart';
import 'design/vu_v2_theme.dart';
import 'learn/vu_v2_faculty_screen.dart';
import 'onboarding/vu_v2_onboarding_screen.dart';

/// Root entry for Virtual University V2 — entirely new product surface.
class VuV2App extends StatefulWidget {
  const VuV2App({super.key});

  @override
  State<VuV2App> createState() => _VuV2AppState();
}

class _VuV2AppState extends State<VuV2App> {
  final VuV2Session _session = VuV2Session();
  final VuV2ProgressStore _progress = VuV2ProgressStore();
  final GlobalKey<NavigatorState> _campusNavKey = GlobalKey<NavigatorState>();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    VuV2RoadmapSync.clearCache();
    await Future.wait(<Future<void>>[
      _session.ensureLoaded(),
      _progress.ensureLoaded(),
    ]);
    if (_session.onboardingComplete &&
        !_progress.enrolledDegreeIds.contains(_session.majorId)) {
      await _progress.enroll(_session.majorId);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the user changes their accent in Appearance settings.
    context.watch<AppearanceService>();
    final ThemeData theme =
        _progress.preferLightTheme ? vuV2LightTheme() : vuV2DarkTheme();

    return Theme(
      data: theme,
      child: VuV2Scope(
        session: _session,
        progress: _progress,
        child: !_ready
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: VuV2Colors.orange),
                ),
              )
            : ListenableBuilder(
                listenable:
                    Listenable.merge(<Listenable>[_session, _progress]),
                builder: (BuildContext context, _) {
                  if (!_session.onboardingComplete) {
                    return VuV2OnboardingScreen(
                      session: _session,
                      progress: _progress,
                      onDone: () => setState(() {}),
                    );
                  }
                  // Nested navigator keeps Lecture Halls / courses under VuV2Scope
                  // (VuV2App itself is pushed on the app root navigator).
                  return Navigator(
                    key: _campusNavKey,
                    onGenerateRoute: (RouteSettings settings) {
                      return MaterialPageRoute<void>(
                        settings: settings,
                        builder: (_) => _CampusShell(
                          session: _session,
                          progress: _progress,
                          onCloseCampus: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).maybePop(),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _CampusShell extends StatefulWidget {
  const _CampusShell({
    required this.session,
    required this.progress,
    required this.onCloseCampus,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VoidCallback onCloseCampus;

  @override
  State<_CampusShell> createState() => _CampusShellState();
}

class _CampusShellState extends State<_CampusShell> {
  int _tab = 0;

  VuV2Session get session => widget.session;
  VuV2ProgressStore get progress => widget.progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual University'),
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
      body: IndexedStack(
        index: _tab,
        children: <Widget>[
          VuV2CampusHome(
            session: session,
            progress: progress,
            onOpenLearn: () => setState(() => _tab = 1),
            onOpenPractice: () => setState(() => _tab = 2),
          ),
          VuV2LearnTab(session: session, progress: progress),
          VuV2PracticeTab(session: session, progress: progress),
          VuV2ProgressTab(session: session, progress: progress),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (int i) => setState(() => _tab = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Campus',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science_rounded),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VuV2SubscriptionScreen(progress: progress),
                  ),
                );
              },
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(progress.isPremium ? 'Premium' : 'Plans'),
            )
          : null,
    );
  }
}
