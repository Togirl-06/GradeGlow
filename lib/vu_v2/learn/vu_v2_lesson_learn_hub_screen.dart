import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/university_learning_engine.dart';
import '../../data/biology_degree_catalog.dart';
import '../../data/chemistry_degree_catalog.dart';
import '../../data/health_faculty_catalog.dart';
import '../../data/mathematics_degree_catalog.dart';
import '../../models/biology_degree.dart';
import '../../models/chemistry_degree.dart';
import '../../models/health_faculty_program.dart';
import '../../models/mathematics_degree.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../screens/mathematics/mathematics_practice_screen.dart';
import '../../services/biology_progress_service.dart';
import '../../services/chemistry_progress_service.dart';
import '../../services/mathematics_progress_service.dart';
import '../../services/openai_service.dart';
import '../../theme/study_theme.dart';
import '../../widgets/virtual_lecture/lecture_professor_badge.dart';
import '../data/vu_v2_lesson_flow.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_scope.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_mixed_quiz.dart';
import '../data/vu_v2_topic_content.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../labs/university_lab_result.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_lesson_activity_router.dart';
import 'vu_v2_lesson_classroom_screen.dart';

/// Lesson hub: Professor teaches → professional lab → knowledge check.
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
    this.courseLessonIds = const <String>[],
  });

  final VuV2Session session;
  final VuV2ProgressStore? progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final String courseTitle;
  final VuV2RoadmapLesson lesson;
  final List<String> courseLessonIds;

  VuV2ProgressStore? _store(BuildContext context) =>
      progress ?? VuV2Scope.maybeOf(context)?.progress;

  UniversityLabLink? get _lab => VuV2LessonActivityRouter.linkedLab(
        subjectId: subjectId,
        lessonTitle: lesson.title,
        moduleTitle: courseTitle,
      );

  bool get _requiresLab => _lab != null;

  @override
  Widget build(BuildContext context) {
    final VuV2ProgressStore? store = _store(context);
    if (store == null) return _scaffold(context, null);
    return ListenableBuilder(
      listenable: store,
      builder: (BuildContext context, _) => _scaffold(context, store),
    );
  }

  Widget _scaffold(BuildContext context, VuV2ProgressStore? store) {
    final bool lectureDone =
        store?.isStepComplete(lesson.id, VuV2LessonStep.aiProfessor) ?? false;
    final bool labDone =
        store?.isStepComplete(lesson.id, VuV2LessonStep.realWorldLab) ?? false;
    final bool checkDone =
        store?.isStepComplete(lesson.id, VuV2LessonStep.knowledgeCheck) ??
            false;
    final bool mastered =
        store?.meetsMastery(lesson.id, requiresLab: _requiresLab) ?? false;
    final UniversityLabLink? lab = _lab;

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
                  mastered ? 'SKILL MASTERED' : 'LEARNING LOOP',
                  style: TextStyle(
                    color: mastered ? VuV2Colors.success : StudyColors.primary,
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
                Text(
                  mastered
                      ? 'You learned it from the professor, used it in the lab, and proved it.'
                      : 'Professor teaches → interactive visuals → professional lab → '
                          'decisions have consequences → knowledge check.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PrivateProfessorHero(
            lectureDone: lectureDone,
            onStart: () => _openAiTutor(context),
          ),
          if (lab != null) ...<Widget>[
            const SizedBox(height: 12),
            _JourneyStepCard(
              step: 2,
              emoji: '🔬',
              title: lab.title,
              subtitle:
                  '${lab.purpose} Your choices change the simulation — then the professor debriefs.',
              cta: labDone ? 'Replay lab' : 'Enter professional lab',
              status: labDone
                  ? 'Complete'
                  : (lectureDone ? 'Ready' : 'Best after the lecture'),
              done: labDone,
              onTap: () => _openLab(context, lab),
            ),
          ],
          const SizedBox(height: 12),
          _JourneyStepCard(
            step: lab == null ? 2 : 3,
            emoji: '✅',
            title: 'Knowledge check',
            subtitle:
                'Prove you can use the concept — not memorize a percentage.',
            cta: checkDone ? 'Retake check' : 'Take knowledge check',
            status: checkDone
                ? 'Passed'
                : (lectureDone ? 'Ready' : 'Best after the lecture'),
            done: checkDone,
            onTap: () => _openQuiz(context),
          ),
          const SizedBox(height: 12),
          _JourneyStepCard(
            step: null,
            emoji: '📘',
            title: 'Lecture notes',
            subtitle:
                'Key concepts, examples, and common mistakes from this class.',
            cta: 'Open notes',
            status: 'Optional',
            done: store?.isStepComplete(lesson.id, VuV2LessonStep.coreNotes) ??
                false,
            onTap: () => _openNotes(context),
          ),
        ],
      ),
    );
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
    if (!context.mounted) return;
    await _store(context)?.markStep(
      lesson.id,
      VuV2LessonStep.coreNotes,
      requiresLab: _requiresLab,
    );
  }

  Future<void> _openAiTutor(BuildContext context) async {
    await session.setContinue(
      title: lesson.title,
      subtitle: '$facultyTitle · AI Professor',
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
        subtitle: '$facultyTitle · lecture complete · enter the lab',
        progress: 0.55,
      );
      if (!context.mounted) return;
      await _store(context)?.markStep(
        lesson.id,
        VuV2LessonStep.aiProfessor,
        requiresLab: _requiresLab,
      );
    }
  }

  Future<void> _openLab(BuildContext context, UniversityLabLink lab) async {
    await session.setContinue(
      title: lesson.title,
      subtitle: '$facultyTitle · Professional lab',
      progress: 0.7,
    );
    if (!context.mounted) return;
    final UniversityLabResult? result =
        await VuV2LessonActivityRouter.openLinkedLab(
      context: context,
      link: lab,
      subjectId: subjectId,
    );
    if (!context.mounted || result == null) return;
    await _store(context)?.markStep(
      lesson.id,
      VuV2LessonStep.realWorldLab,
      requiresLab: true,
    );
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
          subtitle: '$courseTitle · knowledge check · pass ≥70%',
          questions: VuV2MixedQuiz.enrich(pack.topicQuiz),
          passPercent: 70,
          onCompleted: (double pct) {
            _store(context)?.recordQuiz('${lesson.id}_quiz', pct);
            if (pct >= 70) {
              _store(context)?.markStep(
                lesson.id,
                VuV2LessonStep.knowledgeCheck,
                requiresLab: _requiresLab,
              );
            }
          },
        ),
      ),
    );
  }
}

/// Hero card — AI Professor lecture (step 1 of the loop).
class _PrivateProfessorHero extends StatelessWidget {
  const _PrivateProfessorHero({
    required this.onStart,
    this.lectureDone = false,
  });

  final VoidCallback onStart;
  final bool lectureDone;

  static const List<_Pillar> _pillars = <_Pillar>[
    _Pillar(icon: '🗣️', label: 'Professor teaches'),
    _Pillar(icon: '✨', label: 'Speech-synced visuals'),
    _Pillar(icon: '❓', label: 'In-lecture questions'),
    _Pillar(icon: '🔬', label: 'Then the lab'),
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
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: lectureDone
                          ? VuV2Colors.success.withValues(alpha: 0.18)
                          : accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lectureDone ? '✓' : '1',
                      style: TextStyle(
                        color: lectureDone ? VuV2Colors.success : accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const LectureProfessorBadge(size: 56, speaking: true),
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
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lectureDone
                              ? 'Lecture complete · enter the lab'
                              : 'Teaches. Visuals follow every word.',
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
                'Your professor teaches the concept, highlights it as they speak, '
                'asks you questions, then sends you into the professional lab.',
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
                children: <Widget>[
                  for (int i = 0; i < _pillars.length; i++)
                    Container(
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
                        '${_pillars[i].icon}  ${_pillars[i].label}',
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
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
                  icon: Icon(
                    lectureDone
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    lectureDone ? 'Replay lecture' : 'Start lecture',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
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

class _Pillar {
  const _Pillar({required this.icon, required this.label});

  final String icon;
  final String label;
}

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
    required this.status,
    this.step,
    this.done = false,
  });

  final int? step;
  final String emoji;
  final String title;
  final String subtitle;
  final String cta;
  final String status;
  final bool done;
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
            border: Border.all(
              color: done
                  ? VuV2Colors.success.withValues(alpha: 0.45)
                  : accent.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (step != null || done)
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done
                            ? VuV2Colors.success.withValues(alpha: 0.18)
                            : accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        done ? '✓' : '${step ?? ''}',
                        style: TextStyle(
                          color: done ? VuV2Colors.success : accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  if (step != null || done) const SizedBox(width: 10),
                  Text(emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: done ? VuV2Colors.success : VuV2Colors.mute,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
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
    } else if (subjectId == 'nursing' ||
        subjectId == 'medicine' ||
        subjectId == 'psychology') {
      final HealthFaculty? facultyEnum = HealthFaculty.fromId(subjectId);
      if (facultyEnum != null) {
        final List<HealthLessonPath> paths =
            HealthFacultyCatalog.pathsFor(facultyEnum);
        HealthLessonPath? match;
        for (final HealthLessonPath p in paths) {
          if (p.topic.id == lesson.id ||
              p.topic.title.toLowerCase() == lesson.title.toLowerCase()) {
            match = p;
            break;
          }
        }
        if (match == null) {
          final String lid = lesson.id.toLowerCase();
          for (final HealthLessonPath p in paths) {
            if (lid.contains(p.topic.id.toLowerCase()) ||
                p.topic.id.toLowerCase().contains(lid)) {
              match = p;
              break;
            }
          }
        }
        if (match != null) {
          lessonTitle = match.topic.title;
          courseId = match.course.id;
          resolvedCourse = match.course.title;
          moduleTitle = match.course.title;
          lessonId = match.topic.id;
        } else {
          courseId = subjectId;
          moduleTitle = courseTitle;
        }
      }
    }

    final String faculty = switch (subjectId) {
      'software_engineering' ||
      'artificial_intelligence' ||
      'cybersecurity' =>
        'computer_science',
      'accounting' || 'economics' || 'marketing' => 'business',
      _ => subjectId,
    };

    final UniversityLabLink? linkedLab = UniversityLearningEngine.labForLesson(
      subjectId: subjectId,
      lessonTitle: lessonTitle,
      moduleTitle: moduleTitle,
    );

    Future<void> Function()? onEnterLab;
    if (linkedLab != null) {
      onEnterLab = () async {
        final UniversityLabResult? result =
            await VuV2LessonActivityRouter.openLinkedLab(
          context: context,
          link: linkedLab,
          subjectId: subjectId,
        );
        if (result == null) return;
        if (!context.mounted) return;
        await VuV2Scope.maybeOf(context)?.progress.markStep(
              lesson.id,
              VuV2LessonStep.realWorldLab,
              requiresLab: true,
            );
      };
    }

    final Future<void> Function()? baseCompleted = onCompleted;
    onCompleted = () async {
      await baseCompleted?.call();
      if (!context.mounted) return;
      await VuV2Scope.maybeOf(context)?.progress.syncDiagramMisconceptions();
    };

    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AiProfessorClassroomScreen(
          key: ValueKey<String>('$lessonId|$lessonTitle|$courseId'),
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
          linkedLabTitle: linkedLab?.title,
          onEnterLab: onEnterLab,
        ),
      ),
    );
  }
}
