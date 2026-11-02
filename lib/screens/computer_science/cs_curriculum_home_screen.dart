import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../models/cs_curriculum.dart';
import '../../services/cs_curriculum_progress_service.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'cs_language_track_screen.dart';

/// Browse all language tracks in the CS curriculum.
class CsCurriculumHomeScreen extends StatefulWidget {
  const CsCurriculumHomeScreen({super.key});

  @override
  State<CsCurriculumHomeScreen> createState() => _CsCurriculumHomeScreenState();
}

class _CsCurriculumHomeScreenState extends State<CsCurriculumHomeScreen> {
    @override
  void initState() {
    super.initState();
    context.read<CsCurriculumProgressService>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.computerScience(context);
    final CsCurriculumProgressService progress = context.watch<CsCurriculumProgressService>();

    return FacultyScaffold(
      palette: palette,
      title: 'Curriculum',
      subtitle: 'Computer Science',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: palette,
            title: 'Beginner → Advanced',
            body:
                '${CsCurriculumCatalog.totalLessonCount()} lessons across ${CsCurriculumCatalog.languages.length} languages. '
                'Each topic includes a lesson, coding exercise, and practice problems.',
            stats: <String>['${CsCurriculumCatalog.languages.length} languages', 'Progress tracked'],
          ),
          const SizedBox(height: 22),
          FacultySectionHeader(palette: palette, label: 'Web', icon: Icons.language_rounded),
          for (final CsCurriculumLanguage lang in CsCurriculumCatalog.languages.where((CsCurriculumLanguage l) => l.isWeb))
            _LanguageCard(palette: palette, language: lang, progress: progress),
          const SizedBox(height: 16),
          FacultySectionHeader(palette: palette, label: 'Programming languages', icon: Icons.code_rounded),
          for (final CsCurriculumLanguage lang in CsCurriculumCatalog.languages.where((CsCurriculumLanguage l) => !l.isWeb))
            _LanguageCard(palette: palette, language: lang, progress: progress),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.palette, required this.language, required this.progress});

  final FacultyPalette palette;
  final CsCurriculumLanguage language;
  final CsCurriculumProgressService progress;

  @override
  Widget build(BuildContext context) {
    final int total = CsCurriculumCatalog.topicsForLanguage(language.id).length;
    final double ratio = progress.progressRatioForLanguage(language.id);
    final int percent = (ratio * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: <Widget>[
          FacultyNavCard(
            palette: palette,
            title: language.label,
            subtitle: '$total lessons · structured path',
            detail: '$percent% complete',
            badge: percent >= 100 ? 'Done' : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => CsLanguageTrackScreen(languageId: language.id)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: palette.background,
                color: palette.primary,
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
