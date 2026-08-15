import 'package:flutter/material.dart';

import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../data/leetcode_problem_bank.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'cs_curriculum_home_screen.dart';
import 'cs_problem_browser_screen.dart';

/// Computer Science home — curriculum, coding workspace, and practice.
class CsProgramScreen extends StatelessWidget {
  const CsProgramScreen({super.key});

    @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.computerScience(context);
    return FacultyScaffold(
      palette: palette,
      title: 'Computer Science',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: palette,
            title: 'Learn by coding',
            tagline: 'Beginner → intermediate → advanced',
            body:
                'Structured lessons across languages, then hands-on coding exercises and timed practice problems.',
            stats: <String>[
              '${CsCurriculumCatalog.languages.length} languages',
              '${CsCurriculumCatalog.totalLessonCount()} lessons',
              '${LeetcodeProblemBank.allCuratedProblems.length} problems',
            ],
            trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.terminal_rounded, color: palette.accent, size: 28),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: palette.primary,
            borderRadius: BorderRadius.circular(palette.cardRadius),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CsCurriculumHomeScreen()),
              ),
              borderRadius: BorderRadius.circular(palette.cardRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.school_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Browse curriculum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FacultySectionHeader(palette: palette, label: 'Curriculum', icon: Icons.language_rounded),
          FacultyNavCard(
            palette: palette,
            icon: Icons.language_rounded,
            title: 'All languages & topics',
            subtitle: 'HTML to Rust — structured lesson paths',
            detail:
                '${CsCurriculumCatalog.languages.length} languages · ${CsCurriculumCatalog.totalLessonCount()} lessons',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CsCurriculumHomeScreen()),
            ),
          ),
          const SizedBox(height: 8),
          FacultySectionHeader(palette: palette, label: 'More practice', icon: Icons.code_rounded),
          FacultyNavCard(
            palette: palette,
            icon: Icons.code_rounded,
            title: 'All coding problems',
            subtitle: 'Curated problem bank with hints and solutions',
            detail: '${LeetcodeProblemBank.allCuratedProblems.length} problems',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CsProblemBrowserScreen()),
            ),
          ),
          FacultyNavCard(
            palette: palette,
            icon: Icons.bug_report_outlined,
            title: 'Debug challenges',
            subtitle: 'Find and fix broken programs',
            detail: '${LeetcodeProblemBank.allDebugProblems.length} broken programs',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CsProblemBrowserScreen(preferDebug: true)),
            ),
          ),
        ],
      ),
    );
  }
}
