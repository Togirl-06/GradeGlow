import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/law/law_catalog.dart';
import '../../data/law_simulation_data.dart';
import '../../models/law/law_program.dart';
import '../../models/practice_lab.dart';
import '../../services/law_daily_progress_service.dart';
import '../../theme/law_theme.dart';
import '../law_simulation_hub_screen.dart';
import 'law_case_side_select_screen.dart';
import 'law_exam_screen.dart';
import 'law_lecture_screen.dart';
import 'law_negotiation_screen.dart';
import 'law_objection_screen.dart';
import 'law_writing_screen.dart';

/// Lesson hub — every mode for one dispute-driven lesson.
class LawLessonScreen extends StatelessWidget {
  const LawLessonScreen({
    super.key,
    required this.specializationId,
    required this.courseId,
    required this.lessonId,
    this.isDailyCase = false,
  });

  final String specializationId;
  final String courseId;
  final String lessonId;
  final bool isDailyCase;

  static final PracticeLabCategory _cat = PracticeLabCategory(
    id: 'law',
    name: 'Law',
    emoji: '⚖️',
    icon: Icons.balance_outlined,
    labs: const <PracticeLabType>[],
    groupId: 'law_criminal_justice',
  );

  static const PracticeLabType _lab = PracticeLabType(
    id: 'law_school_courtroom',
    title: 'Live Courtroom',
    subtitle: 'Argue before an AI judge',
    style: SimulationStyle.courtroom,
    aiRole: 'Judge',
  );

  bool get _isTodaysDailyLesson {
    final LawLesson? daily = LawDailyProgressService.dailyLessonFor(specializationId);
    return daily != null && daily.id == lessonId;
  }

  Future<void> _markDailyIfNeeded() async {
    if (!isDailyCase && !_isTodaysDailyLesson) return;
    await LawDailyProgressService.instance.markDailyCompleted(specializationId);
  }

  @override
  Widget build(BuildContext context) {
    final LawSpecialization? spec = LawCatalog.byId(specializationId);
    final LawCourse? course = LawCatalog.courseById(specId: specializationId, courseId: courseId);
    final LawLesson? lesson = LawCatalog.lessonById(specId: specializationId, courseId: courseId, lessonId: lessonId);
    if (spec == null || course == null || lesson == null) {
      return Scaffold(appBar: AppBar(title: const Text('Lesson')), body: const Center(child: Text('Not found')));
    }

    final bool showDailyChrome = isDailyCase || _isTodaysDailyLesson;

    return Consumer<LawDailyProgressService>(
      builder: (BuildContext context, LawDailyProgressService progress, Widget? _) {
        final bool dailyDone = progress.isDailyCompleted(specializationId);

        return Scaffold(
          backgroundColor: LawTheme.background,
          appBar: AppBar(
            backgroundColor: LawTheme.bench,
            foregroundColor: Colors.white,
            title: Text(lesson.title),
            actions: <Widget>[
              if (showDailyChrome)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      dailyDone ? 'Daily ✓' : 'Daily case',
                      style: TextStyle(
                        color: dailyDone ? LawTheme.gavel : Colors.white70,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              if (showDailyChrome)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (dailyDone ? LawTheme.success : LawTheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (dailyDone ? LawTheme.success : LawTheme.primary).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    dailyDone
                        ? 'Today\'s court case is marked complete for ${spec.name}.'
                        : 'Today\'s court case for ${spec.name}. Complete any practice mode below to mark it done.',
                    style: TextStyle(
                      color: dailyDone ? LawTheme.success : LawTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: LawTheme.courtroomPanel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'CASE HOOK',
                      style: TextStyle(
                        color: LawTheme.gavel,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.hook,
                      style: const TextStyle(
                        color: LawTheme.courtroomText,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Q: ${lesson.question}',
                      style: TextStyle(color: LawTheme.gavel, fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(lesson.doctrine, style: TextStyle(color: LawTheme.textSecondary, height: 1.45)),
              const SizedBox(height: 16),
              Text(
                'PRACTICE MODES',
                style: TextStyle(
                  color: LawTheme.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              ...LawLearningMode.values.map((LawLearningMode mode) {
                if (mode == LawLearningMode.hookCase) return const SizedBox.shrink();
                return _ModeTile(
                  mode: mode,
                  onTap: () => _open(context, spec: spec, course: course, lesson: lesson, mode: mode),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _open(
    BuildContext context, {
    required LawSpecialization spec,
    required LawCourse course,
    required LawLesson lesson,
    required LawLearningMode mode,
  }) async {
    final Widget page = switch (mode) {
      LawLearningMode.hookCase => this,
      LawLearningMode.aiProfessor => LawLectureScreen(course: course, lesson: lesson),
      LawLearningMode.legalWriting => LawWritingScreen(lesson: lesson),
      LawLearningMode.courtroom => lesson.simulationCaseId == null
          ? LawSimulationHubScreen(category: _cat, lab: _lab)
          : LawCaseSideSelectScreen(
              caseFile: LawSimulationData.caseById(lesson.simulationCaseId!),
              category: _cat,
              lab: _lab,
              isDailyCase: isDailyCase,
            ),
      LawLearningMode.objections => LawObjectionScreen(lesson: lesson),
      LawLearningMode.negotiation => LawNegotiationScreen(lesson: lesson),
      LawLearningMode.exam => LawExamScreen(lesson: lesson, courseTitle: course.title),
    };
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
    await _markDailyIfNeeded();
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.mode, required this.onTap});
  final LawLearningMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LawTheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: LawTheme.border)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: LawTheme.primary.withValues(alpha: 0.12),
          child: Icon(mode.icon, color: LawTheme.primary, size: 20),
        ),
        title: Text(mode.label, style: TextStyle(fontWeight: FontWeight.w800, color: LawTheme.textPrimary)),
        subtitle: Text(mode.subtitle, style: TextStyle(color: LawTheme.textSecondary, fontSize: 12)),
        trailing: Icon(Icons.play_arrow_rounded, color: LawTheme.primary),
        onTap: onTap,
      ),
    );
  }
}
