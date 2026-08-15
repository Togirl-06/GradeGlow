import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../widgets/web_site_header.dart';
import '../widgets/study_bottom_nav.dart';
import 'ai_tutor_screen.dart';
import 'dashboard_screen.dart';
import 'progress_screen.dart';
import 'flashcards_screen.dart';
import 'profile_screen.dart';
import 'quiz_mode_screen.dart';
import '../vu_v2/vu_v2_app.dart';
import 'notes_summarizer_screen.dart';
import 'pomodoro_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final Widget page = switch (_tab) {
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
                builder: (_) => QuizModeScreen(initialMaterialId: materialId),
              ),
            );
          },
          onFlashcards: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FlashcardsScreen()),
            );
          },
          onWeaknessReview: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WeaknessReviewScreen(
                  onStartQuiz: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const QuizModeScreen()),
                    );
                  },
                ),
              ),
            );
          },
          onSummarize: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NotesSummarizerScreen()),
            );
          },
          onPlanner: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StudyPlannerScreen()),
            );
          },
          onPomodoro: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PomodoroScreen()),
            );
          },
          onPracticeLabs: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VuV2App()),
            );
          },
        ),
      1 => const ProgressScreen(),
      2 => const TodosScreen(),
      3 => const AiTutorScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      body: SafeArea(
        top: !kIsWeb,
        bottom: false,
        child: kIsWeb
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  WebSiteHeader(currentIndex: _tab, onChanged: _goToTab),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: page,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  Expanded(child: page),
                  StudyBottomNav(currentIndex: _tab, onChanged: _goToTab),
                ],
              ),
      ),
    );
  }
}
