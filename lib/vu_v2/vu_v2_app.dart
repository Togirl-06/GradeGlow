import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/appearance_service.dart';
import '../services/auth_service.dart';
import 'campus/vu_v2_campus_shell.dart';
import 'data/vu_v2_progress_store.dart';
import 'data/vu_v2_roadmap_sync.dart';
import 'data/vu_v2_scope.dart';
import 'data/vu_v2_session.dart';
import 'design/vu_v2_theme.dart';
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
    final AuthService auth = context.read<AuthService>();
    final String? uid = auth.uid;
    final String authName = auth.displayName.trim();
    await Future.wait(<Future<void>>[
      _session.ensureLoaded(userId: uid),
      _progress.ensureLoaded(userId: uid),
    ]);
    // Prefer account name if onboarding draft is still the default.
    if (!_session.onboardingComplete) {
      if (authName.isNotEmpty &&
          authName != 'Student' &&
          (_session.displayName == 'Student' || _session.displayName.isEmpty)) {
        await _session.saveOnboardingDraft(
          name: authName,
          goals: _session.goals,
          majorId: null,
          majorLabel: null,
          weeklyMinutes: _session.weeklyMinutes,
          step: _session.onboardingStep,
        );
      }
    }
    if (_session.onboardingComplete &&
        !_progress.enrolledDegreeIds.contains(_session.majorId)) {
      await _progress.enroll(_session.majorId);
    }
    if (_progress.enrolledDegreeIds.length > 6 &&
        _session.majorId.isNotEmpty) {
      await _progress.keepOnlyEnrolled(_session.majorId);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));

    return VuV2Scope(
      session: _session,
      progress: _progress,
      child: !_ready
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                        builder: (_) => VuV2CampusShell(
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
    );
  }
}
