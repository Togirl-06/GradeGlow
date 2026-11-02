import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/english/english_lesson_catalog.dart';
import '../../data/english/english_question_bank.dart';
import '../../models/world_curriculum_program.dart';
import '../../services/english_progress_service.dart';
import '../../services/world_curriculum_progress_service.dart';
import '../../theme/study_theme.dart';
import '../../widgets/english/english_session_chrome.dart';
import '../../widgets/study_surface.dart';
import '../curriculum/world_curriculum_home_screen.dart';
import 'english_lesson_screen.dart';

/// English home — recommended session and practice library.
class EnglishProgramScreen extends StatefulWidget {
  const EnglishProgramScreen({super.key});

  @override
  State<EnglishProgramScreen> createState() => _EnglishProgramScreenState();
}

class _EnglishProgramScreenState extends State<EnglishProgramScreen> {
  final EnglishProgressService _progress = EnglishProgressService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _progress.ensureLoaded();
    if (mounted) setState(() => _loading = false);
  }

  void _openLesson(EnglishLessonEntry entry) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => EnglishLessonScreen(script: entry.script),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final EnglishLessonEntry next = lessonForSkill(_progress.nextSkillId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('English'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: EnglishLessonTheme.heroGradient(brightness),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const EnglishProfessorChip(),
                      const SizedBox(height: 14),
                      Text(
                        'Live tutoring session',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick any practice below — each session is short, '
                        'interactive steps with instant feedback.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.tonal(
                        onPressed: () {
                          WorldCurriculumProgressService? world;
                          try {
                            world = context
                                .read<WorldCurriculumProgressService>();
                          } catch (_) {
                            world = null;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => world == null
                                  ? const WorldCurriculumHomeScreen(
                                      meta: WorldSubjectMeta.english,
                                    )
                                  : ChangeNotifierProvider<
                                      WorldCurriculumProgressService
                                    >.value(
                                      value: world,
                                      child: const WorldCurriculumHomeScreen(
                                        meta: WorldSubjectMeta.english,
                                      ),
                                    ),
                            ),
                          );
                        },
                        child: const Text('Browse all English courses & topics'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StudySurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Recommended',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: textSecondary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        next.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next.skillLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textSecondary,
                            ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openLesson(next),
                          style: EnglishLessonTheme.primaryButton(brightness),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Begin session'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Practice library',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$englishLessonCount topics · every session stays on one skill',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                ...englishPracticeCategoryOrder.map((EnglishPracticeCategory cat) {
                  final List<EnglishLessonEntry> lessons =
                      lessonsInCategory(cat);
                  if (lessons.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Text(
                          cat.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: StudyColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      ...lessons.map(
                        (EnglishLessonEntry entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _PracticeCard(
                            entry: entry,
                            completed: _progress.isCompleted(entry.id),
                            isNext: entry.id == _progress.nextSkillId,
                            onTap: () => _openLesson(entry),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.entry,
    required this.completed,
    required this.isNext,
    required this.onTap,
  });

  final EnglishLessonEntry entry;
  final bool completed;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return StudySurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: StudyColors.primaryTint(brightness),
            child: Icon(entry.icon, color: StudyColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    if (completed)
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: StudyColors.success)
                    else if (isNext)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: StudyColors.primaryTint(brightness),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: StudyColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.skillLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                      ),
                ),
                Text(
                  '~${entry.script.activities.length + EnglishQuestionBank.extraPerSession} steps per run',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: StudyColors.primary,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: textSecondary),
        ],
      ),
    );
  }
}
