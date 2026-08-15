import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/biology_degree_catalog.dart';
import '../../data/chemistry_degree_catalog.dart';
import '../../data/mathematics_degree_catalog.dart';
import '../../models/biology_degree.dart';
import '../../models/chemistry_degree.dart';
import '../../models/mathematics_degree.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../screens/mathematics/mathematics_practice_screen.dart';
import '../../services/biology_progress_service.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/mathematics_progress_service.dart';
import '../../services/openai_service.dart';
import '../../theme/study_theme.dart';
import '../../widgets/virtual_lecture/lecture_professor_badge.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_scope.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_lesson_classroom_screen.dart';

/// Khan Academy–style hub: AI Professor video lesson (hero) or Notes.
class VuV2LessonLearnHubScreen extends StatelessWidget {
  const VuV2LessonLearnHubScreen({
    super.key,
    required this.session,
    this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.courseTitle,
    required this.lesson,
  });

  final VuV2Session session;
  final VuV2ProgressStore? progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final String courseTitle;
  final VuV2RoadmapLesson lesson;

  VuV2ProgressStore? _store(BuildContext context) =>
      progress ?? VuV2Scope.maybeOf(context)?.progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '$facultyEmoji  $facultyTitle',
            style: const TextStyle(color: VuV2Colors.mute, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '$trackTitle · $courseTitle',
            style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
          ),
          const SizedBox(height: 14),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'HOW DO YOU WANT TO LEARN?',
                  style: TextStyle(
                    color: StudyColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Like Khan Academy videos — but your teacher is AI. '
                  'Watch the chalkboard lesson, pause anytime, ask questions, then practice.',
                  style: TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PrivateProfessorHero(
            onStart: () => _openAiTutor(context),
          ),
          const SizedBox(height: 12),
          _LearnModeCard(
            emoji: '📘',
            title: 'Notes',
            subtitle:
                'Read clear explanations, examples, and practice checks at your own pace.',
            cta: 'Start notes',
            onTap: () => _openNotes(context),
          ),
          const SizedBox(height: 12),
          _LearnModeCard(
            emoji: '✅',
            title: 'Practice quiz',
            subtitle: 'Check what you know with a short topic quiz.',
            cta: 'Take quiz',
            onTap: () => _openQuiz(context),
          ),
        ],
      ),
    );
  }

  Future<void> _markComplete(BuildContext context) async {
    final VuV2ProgressStore? store = _store(context);
    await store?.completeLesson(lesson.id);
  }

  Future<void> _openNotes(BuildContext context) async {
    await session.setContinue(
      title: lesson.title,
      subtitle: '$facultyTitle · Notes',
      progress: 0.2,
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2LessonClassroomScreen(
          session: session,
          subjectId: subjectId,
          facultyTitle: facultyTitle,
          facultyEmoji: facultyEmoji,
          trackTitle: trackTitle,
          courseTitle: courseTitle,
          topicTitle: lesson.title,
          topicId: lesson.id,
          topicSubtitle: lesson.subtitle,
        ),
      ),
    );
  }

  Future<void> _openAiTutor(BuildContext context) async {
    await session.setContinue(
      title: lesson.title,
      subtitle: '$facultyTitle · AI Tutor',
      progress: 0.25,
    );
    if (!context.mounted) return;
    final bool? completed = await VuV2AiTutorLauncher.open(
      context: context,
      subjectId: subjectId,
      courseTitle: courseTitle,
      lesson: lesson,
    );
    if (!context.mounted) return;
    if (completed == true) {
      await session.setContinue(
        title: lesson.title,
        subtitle: '$facultyTitle · AI Tutor complete',
        progress: 0.9,
      );
      if (!context.mounted) return;
      await _markComplete(context);
    }
  }

  Future<void> _openQuiz(BuildContext context) async {
    final pack = VuV2TopicContent.forLesson(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      facultyEmoji: facultyEmoji,
      trackTitle: trackTitle,
      courseTitle: courseTitle,
      topicTitle: lesson.title,
      topicSubtitle: lesson.subtitle,
      interactive: true,
    );
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2AssessmentScreen(
          title: lesson.title,
          subtitle: '$courseTitle · topic quiz · pass ≥70%',
          questions: pack.topicQuiz,
          passPercent: 70,
          onCompleted: (double pct) {
            _store(context)?.recordQuiz('${lesson.id}_quiz', pct);
            if (pct >= 70) {
              _markComplete(context);
            }
          },
        ),
      ),
    );
  }
}

/// Hero card — the memorable “private professor” first impression for judges.
class _PrivateProfessorHero extends StatelessWidget {
  const _PrivateProfessorHero({required this.onStart});

  final VoidCallback onStart;

  static const List<({String icon, String label})> _pillars =
      <({String icon, String label})>[
    (icon: '🎓', label: '25–40 min lecture'),
    (icon: '📜', label: 'History + theory'),
    (icon: '✍️', label: 'Live chalkboard'),
    (icon: '🌍', label: 'Real-world examples'),
    (icon: '📝', label: 'Exercises + homework'),
  ];

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    return Material(
      color: VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(VuV2Radii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        onTap: onStart,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.xl),
            border: Border.all(color: accent.withValues(alpha: 0.55)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                accent.withValues(alpha: 0.18),
                VuV2Colors.navyElevated,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const LectureProfessorBadge(size: 64, speaking: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'AI Professor',
                          style: TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full university lecture · every course',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Not a chatbot. Your professor teaches for 25–40 minutes: '
                'intro, history, deep theory, chalkboard visuals, real-world examples, '
                'questions, exercises, and homework.',
                style: TextStyle(
                  color: VuV2Colors.mute,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pillars
                    .map(
                      (({String icon, String label}) p) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          '${p.icon}  ${p.label}',
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Play AI video lesson',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnModeCard extends StatelessWidget {
  const _LearnModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    return Material(
      color: VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(VuV2Radii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.xl),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: accent),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: VuV2Colors.mute,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    cta,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the shared AI Professor video classroom for every course.
/// Returns `true` if the student finished, `false` if they left early.
abstract final class VuV2AiTutorLauncher {
  static Future<bool?> open({
    required BuildContext context,
    required String subjectId,
    required String courseTitle,
    required VuV2RoadmapLesson lesson,
  }) async {
    final OpenAiService openAi = context.read<OpenAiService>();

    String lessonTitle = lesson.title;
    String courseId = subjectId;
    String resolvedCourse = courseTitle;
    String moduleTitle = 'Lesson';
    String lessonId = lesson.id;
    double mastery = 0;
    Future<void> Function()? onCompleted;
    Future<void> Function()? onPractice;
    String? nextTitle;
    VoidCallback? onNext;

    if (subjectId == 'mathematics') {
      final MathematicsLessonPath? path =
          MathematicsDegreeCatalog.resolveLesson(lesson.id);
      if (path != null) {
        lessonTitle = path.lesson.title;
        courseId = path.course.id;
        resolvedCourse = path.course.title;
        moduleTitle = path.module.title;
        lessonId = path.lesson.id;
        final MathematicsProgressService progress =
            context.read<MathematicsProgressService>();
        mastery = progress.lessonMastery(path.lesson.id) / 100.0;
        onCompleted = () => progress.completeActivity(
              path.lesson.id,
              MathLessonActivityKind.lecture,
            );
        onPractice = () async {
          if (!context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MathematicsPracticeScreen(
                path: path,
                kind: MathLessonActivityKind.quiz,
              ),
            ),
          );
        };
        final List<MathematicsLessonPath> all =
            MathematicsDegreeCatalog.allLessonPaths;
        final int i = all.indexWhere(
          (MathematicsLessonPath p) => p.lesson.id == path.lesson.id,
        );
        if (i >= 0 && i < all.length - 1) {
          final MathematicsLessonPath next = all[i + 1];
          nextTitle = next.lesson.title;
          onNext = () {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<bool>(
                builder: (_) => AiProfessorClassroomScreen(
                  openAi: openAi,
                  lessonId: next.lesson.id,
                  lessonTitle: next.lesson.title,
                  courseId: next.course.id,
                  courseTitle: next.course.title,
                  moduleTitle: next.module.title,
                  faculty: 'mathematics',
                ),
              ),
            );
          };
        }
      }
    } else if (subjectId == 'biology') {
      final BiologyLessonPath? path =
          BiologyDegreeCatalog.resolveLesson(lesson.id);
      if (path != null) {
        lessonTitle = path.lesson.title;
        courseId = path.course.id;
        resolvedCourse = path.course.title;
        moduleTitle = path.module.title;
        lessonId = path.lesson.id;
        final BiologyProgressService progress =
            context.read<BiologyProgressService>();
        mastery = progress.lessonMastery(path.lesson.id) / 100.0;
        onCompleted = () => progress.completeActivity(
              path.lesson.id,
              BioLessonActivityKind.lecture,
            );
      }
    } else if (subjectId == 'chemistry') {
      final ChemistryLessonPath? path =
          ChemistryDegreeCatalog.resolveLesson(lesson.id);
      if (path != null) {
        lessonTitle = path.lesson.title;
        courseId = path.course.id;
        resolvedCourse = path.course.title;
        moduleTitle = path.module.title;
        lessonId = path.lesson.id;
        final ChemistryProgressService progress =
            context.read<ChemistryProgressService>();
        mastery = progress.lessonMastery(path.lesson.id) / 100.0;
        onCompleted = () => progress.completeActivity(
              path.lesson.id,
              ChemLessonActivityKind.lecture,
            );
      }
    }

    // CS family degrees share lecture faculty prompts with computer_science.
    final String faculty = switch (subjectId) {
      'software_engineering' ||
      'artificial_intelligence' ||
      'cybersecurity' =>
        'computer_science',
      'accounting' || 'economics' || 'marketing' => 'business',
      _ => subjectId,
    };

    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AiProfessorClassroomScreen(
          openAi: openAi,
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          courseId: courseId,
          courseTitle: resolvedCourse,
          moduleTitle: moduleTitle,
          faculty: faculty,
          masteryHint: mastery,
          nextLessonTitle: nextTitle,
          onStartNextLesson: onNext,
          onPractice: onPractice,
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}
