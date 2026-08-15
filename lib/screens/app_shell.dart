import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../widgets/gradeglow_logo.dart';
import '../widgets/study_bottom_nav.dart';
import '../widgets/web_site_header.dart';
import '../vu_v2/vu_v2_app.dart';
import 'ai_tutor_screen.dart';
import 'dashboard_screen.dart';
import 'flashcards_screen.dart';
import 'notes_summarizer_screen.dart';
import 'pomodoro_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'quiz_mode_screen.dart';
import 'study_planner_screen.dart';
import 'todos_screen.dart';
import 'upload_screen.dart';
import 'weakness_review_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  void _goToTab(int index) => setState(() => _tab = index);

  void _openCampus() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VuV2App()),
    );
  }

  Widget get _page => switch (_tab) {
        0 => DashboardScreen(
            onProgress: () => _goToTab(1),
            onUpload: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const UploadScreen()),
              );
            },
            onAskAi: () => _goToTab(3),
            onQuiz: ([String? materialId]) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      QuizModeScreen(initialMaterialId: materialId),
                ),
              );
            },
            onFlashcards: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FlashcardsScreen(),
                ),
              );
            },
            onWeaknessReview: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WeaknessReviewScreen(
                    onStartQuiz: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const QuizModeScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            onSummarize: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotesSummarizerScreen(),
                ),
              );
            },
            onPlanner: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StudyPlannerScreen(),
                ),
              );
            },
            onPomodoro: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PomodoroScreen(),
                ),
              );
            },
            onPracticeLabs: _openCampus,
          ),
        1 => const ProgressScreen(),
        2 => const TodosScreen(),
        3 => const AiTutorScreen(),
        _ => const ProfileScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: !kIsWeb,
        bottom: false,
        child: kIsWeb
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  WebSiteHeader(
                    currentIndex: _tab,
                    onChanged: _goToTab,
                    onOpenCampus: _openCampus,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: WebSiteLayout.wideMaxWidth,
                        ),
                        child: _page,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  _MobileCampusBar(onOpenCampus: _openCampus),
                  Expanded(child: _page),
                  StudyBottomNav(currentIndex: _tab, onChanged: _goToTab),
                ],
              ),
      ),
    );
  }
}

/// Same Campus entry the website header has, so the phone app opens VU the same way.
class _MobileCampusBar extends StatelessWidget {
  const _MobileCampusBar({required this.onOpenCampus});

  final VoidCallback onOpenCampus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 12, 8),
        child: Row(
          children: <Widget>[
            const GradeGlowLogo(height: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'GradeGlow',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: onOpenCampus,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Campus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
