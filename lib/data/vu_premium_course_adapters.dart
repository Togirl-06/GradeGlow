import 'package:flutter/material.dart';

import '../models/biology_degree.dart';
import '../models/chemistry_degree.dart';
import '../models/health_faculty_program.dart';
import '../models/mathematics_degree.dart';
import '../models/vu_premium_course.dart';
import '../models/world_curriculum_program.dart';
import '../screens/biology/biology_lesson_hub_screen.dart';
import '../screens/chemistry/chemistry_lesson_hub_screen.dart';
import '../screens/curriculum/world_curriculum_lesson_hub_screen.dart';
import '../screens/health/health_ai_professor_screen.dart';
import '../screens/health/health_lesson_hub_screen.dart';
import '../screens/mathematics/mathematics_lesson_hub_screen.dart';

/// Builds [VuPremiumCourse] classrooms from existing faculty catalogs.
abstract final class VuPremiumCourseAdapters {
  static VuPremiumCourse fromHealth({
    required HealthFaculty faculty,
    required HealthCourse course,
    required BuildContext context,
  }) {
    final List<VuPremiumModule> modules = _chunkTopics(
      course.topics
          .map(
            (HealthTopic t) => (
              id: t.id,
              title: t.title,
              summary: t.summary,
            ),
          )
          .toList(),
      modulePrefix: course.title,
    );

    return VuPremiumCourse(
      id: course.id,
      title: course.title,
      facultyLabel: faculty.title,
      emoji: faculty.emoji,
      professorName: _professorName(faculty.title),
      professorTitle: 'AI Professor of ${faculty.title}',
      tagline: faculty.tagline,
      description:
          'Master ${course.title} through AI lectures, interactive practice, '
          'simulations, and university-style assessments in ${faculty.title}.',
      modules: modules,
      announcements: <VuCourseAnnouncement>[
        VuCourseAnnouncement(
          title: 'Welcome to ${course.title}',
          body:
              'Your AI Professor is ready. Complete lessons in order for the best mastery path.',
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      resources: <VuCourseResource>[
        VuCourseResource(
          title: 'Clinical vocabulary bank',
          subtitle: 'Key terms for ${course.title}',
          icon: Icons.translate_rounded,
        ),
        VuCourseResource(
          title: 'Study checklist',
          subtitle: 'Weekly goals and review prompts',
          icon: Icons.checklist_rounded,
        ),
      ],
      upcoming: _upcomingFromModules(modules),
      actions: VuPremiumCourseActions(
        onOpenAiProfessor: (VuPremiumLessonItem item) async {
          final HealthTopic? topic = _healthTopic(course, item.id);
          if (topic == null || !context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HealthAiProfessorScreen(
                path: HealthLessonPath(
                  faculty: faculty,
                  course: course,
                  topic: topic,
                ),
              ),
            ),
          );
        },
        onOpenInteractive: (VuPremiumLessonItem item) async {
          await _openHealthHub(context, faculty, course, item.id);
        },
        onOpenSimulation: (VuPremiumLessonItem item) async {
          await _openHealthHub(context, faculty, course, item.id);
        },
        onOpenPractice: (VuPremiumLessonItem item) async {
          await _openHealthHub(context, faculty, course, item.id);
        },
        onOpenQuiz: (VuPremiumLessonItem item) async {
          await _openHealthHub(context, faculty, course, item.id);
        },
        onOpenDiscussion: (VuPremiumLessonItem item) async {
          await _openHealthHub(context, faculty, course, item.id);
        },
      ),
    );
  }

  static VuPremiumCourse fromWorld({
    required WorldSubjectMeta meta,
    required WorldCourse course,
    required BuildContext context,
  }) {
    final List<VuPremiumModule> modules = _chunkTopics(
      course.topics
          .map(
            (WorldTopic t) => (
              id: t.id,
              title: t.title,
              summary: t.summary,
            ),
          )
          .toList(),
      modulePrefix: course.title,
    );

    return VuPremiumCourse(
      id: course.id,
      title: course.title,
      facultyLabel: meta.title,
      emoji: meta.emoji,
      professorName: _professorName(meta.title),
      professorTitle: 'AI Professor of ${meta.title}',
      tagline: meta.tagline,
      description:
          'A full university classroom for ${course.title}: lectures, practice, '
          'discussions, and assessments guided by your AI Professor.',
      modules: modules,
      announcements: <VuCourseAnnouncement>[
        VuCourseAnnouncement(
          title: 'Course orientation',
          body: 'Work module by module. Use Ask AI Tutor whenever you get stuck.',
          postedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
      resources: <VuCourseResource>[
        VuCourseResource(
          title: 'Reading pack',
          subtitle: 'Core readings for ${course.title}',
        ),
        VuCourseResource(
          title: 'Exam blueprint',
          subtitle: 'What mastery looks like in this course',
          icon: Icons.map_outlined,
        ),
      ],
      upcoming: _upcomingFromModules(modules),
      actions: VuPremiumCourseActions(
        onOpenAiProfessor: (VuPremiumLessonItem item) async {
          await _openWorldHub(context, meta, course, item.id);
        },
        onOpenInteractive: (VuPremiumLessonItem item) async {
          await _openWorldHub(context, meta, course, item.id);
        },
        onOpenPractice: (VuPremiumLessonItem item) async {
          await _openWorldHub(context, meta, course, item.id);
        },
        onOpenQuiz: (VuPremiumLessonItem item) async {
          await _openWorldHub(context, meta, course, item.id);
        },
        onOpenDiscussion: (VuPremiumLessonItem item) async {
          await _openWorldHub(context, meta, course, item.id);
        },
      ),
    );
  }

  static VuPremiumCourse fromBiology({
    required BiologyDegreeYear year,
    required BiologyDegreeCourse course,
    required BuildContext context,
  }) {
    final List<VuPremiumModule> modules = course.modules
        .map(
          (BiologyDegreeModule m) => VuPremiumModule(
            id: m.id,
            title: m.title,
            subtitle: '${m.lessonCount} lessons',
            items: m.lessons
                .expand(
                  (BiologyDegreeLesson lesson) => <VuPremiumLessonItem>[
                    VuPremiumLessonItem(
                      id: lesson.id,
                      title: lesson.title,
                      kind: VuLessonItemKind.lesson,
                      estimatedMinutes: 30,
                      xpReward: 50,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__interactive',
                      title: '${lesson.title} · Lab',
                      kind: VuLessonItemKind.simulation,
                      subtitle: 'Virtual experiment',
                      estimatedMinutes: 20,
                      xpReward: 45,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__quiz',
                      title: '${lesson.title} · Quiz',
                      kind: VuLessonItemKind.quiz,
                      estimatedMinutes: 15,
                      xpReward: 60,
                    ),
                  ],
                )
                .toList(),
          ),
        )
        .toList();

    return VuPremiumCourse(
      id: course.id,
      title: course.title,
      facultyLabel: 'Biology',
      emoji: course.emoji,
      professorName: 'Prof. Aria',
      professorTitle: 'AI Professor of Biology',
      tagline: course.tagline ?? year.title,
      description:
          'Immersive biology classroom with AI lectures, virtual labs, '
          'case studies, and mastery assessments for ${course.title}.',
      modules: modules,
      announcements: <VuCourseAnnouncement>[
        VuCourseAnnouncement(
          title: 'Lab safety reminder',
          body: 'Complete interactive labs before the module quiz for best results.',
          postedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      resources: <VuCourseResource>[
        VuCourseResource(
          title: 'Cell atlas',
          subtitle: 'Diagrams and labeled structures',
          icon: Icons.biotech_outlined,
        ),
        VuCourseResource(
          title: 'Lab notebook tips',
          subtitle: 'How to document experiments',
          icon: Icons.science_outlined,
        ),
      ],
      upcoming: _upcomingFromModules(modules),
      actions: VuPremiumCourseActions(
        onOpenAiProfessor: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
        onOpenInteractive: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
        onOpenSimulation: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
        onOpenPractice: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
        onOpenQuiz: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
        onOpenDiscussion: (VuPremiumLessonItem item) async {
          await _openBioHub(context, year, course, item.id);
        },
      ),
    );
  }

  static VuPremiumCourse fromChemistry({
    required ChemistryDegreeYear year,
    required ChemistryDegreeCourse course,
    required BuildContext context,
  }) {
    final List<VuPremiumModule> modules = course.modules
        .map(
          (ChemistryDegreeModule m) => VuPremiumModule(
            id: m.id,
            title: m.title,
            subtitle: '${m.lessonCount} lessons',
            items: m.lessons
                .expand(
                  (ChemistryDegreeLesson lesson) => <VuPremiumLessonItem>[
                    VuPremiumLessonItem(
                      id: lesson.id,
                      title: lesson.title,
                      kind: VuLessonItemKind.lesson,
                      estimatedMinutes: 30,
                      xpReward: 50,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__lab',
                      title: '${lesson.title} · Lab',
                      kind: VuLessonItemKind.simulation,
                      estimatedMinutes: 20,
                      xpReward: 45,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__quiz',
                      title: '${lesson.title} · Quiz',
                      kind: VuLessonItemKind.quiz,
                      estimatedMinutes: 15,
                      xpReward: 60,
                    ),
                  ],
                )
                .toList(),
          ),
        )
        .toList();

    return VuPremiumCourse(
      id: course.id,
      title: course.title,
      facultyLabel: 'Chemistry',
      emoji: course.emoji,
      professorName: 'Prof. Quinn',
      professorTitle: 'AI Professor of Chemistry',
      tagline: course.tagline ?? year.title,
      description:
          'Immersive chemistry classroom with AI lectures, virtual labs, '
          'and mastery assessments for ${course.title}.',
      modules: modules,
      announcements: <VuCourseAnnouncement>[
        VuCourseAnnouncement(
          title: 'Lab week',
          body: 'Complete the virtual experiment before attempting the quiz.',
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      resources: <VuCourseResource>[
        VuCourseResource(
          title: 'Periodic patterns',
          subtitle: 'Reference charts for this course',
          icon: Icons.grid_on_rounded,
        ),
      ],
      upcoming: _upcomingFromModules(modules),
      actions: VuPremiumCourseActions(
        onOpenAiProfessor: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
        onOpenInteractive: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
        onOpenSimulation: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
        onOpenPractice: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
        onOpenQuiz: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
        onOpenDiscussion: (VuPremiumLessonItem item) async {
          await _openChemHub(context, year, course, item.id);
        },
      ),
    );
  }

  static VuPremiumCourse fromMathematics({
    required MathematicsDegreeYear year,
    required MathematicsDegreeCourse course,
    required BuildContext context,
  }) {
    final List<VuPremiumModule> modules = course.modules
        .map(
          (MathematicsDegreeModule m) => VuPremiumModule(
            id: m.id,
            title: m.title,
            subtitle: '${m.lessonCount} lessons',
            items: m.lessons
                .expand(
                  (MathematicsDegreeLesson lesson) => <VuPremiumLessonItem>[
                    VuPremiumLessonItem(
                      id: lesson.id,
                      title: lesson.title,
                      kind: VuLessonItemKind.lesson,
                      estimatedMinutes: 30,
                      xpReward: 50,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__practice',
                      title: '${lesson.title} · Practice',
                      kind: VuLessonItemKind.interactive,
                      estimatedMinutes: 20,
                      xpReward: 45,
                    ),
                    VuPremiumLessonItem(
                      id: '${lesson.id}__quiz',
                      title: '${lesson.title} · Quiz',
                      kind: VuLessonItemKind.quiz,
                      estimatedMinutes: 15,
                      xpReward: 60,
                    ),
                  ],
                )
                .toList(),
          ),
        )
        .toList();

    return VuPremiumCourse(
      id: course.id,
      title: course.title,
      facultyLabel: 'Mathematics',
      emoji: course.emoji,
      professorName: 'Prof. Iris',
      professorTitle: 'AI Professor of Mathematics',
      tagline: course.tagline ?? year.title,
      description:
          'University mathematics classroom with AI lectures, guided practice, '
          'and assessments for ${course.title}.',
      modules: modules,
      announcements: <VuCourseAnnouncement>[
        VuCourseAnnouncement(
          title: 'Problem sets open',
          body: 'Work practice activities before the module quiz.',
          postedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ],
      resources: <VuCourseResource>[
        VuCourseResource(
          title: 'Formula sheet',
          subtitle: 'Core identities for this course',
          icon: Icons.functions_rounded,
        ),
      ],
      upcoming: _upcomingFromModules(modules),
      actions: VuPremiumCourseActions(
        onOpenAiProfessor: (VuPremiumLessonItem item) async {
          await _openMathHub(context, year, course, item.id);
        },
        onOpenInteractive: (VuPremiumLessonItem item) async {
          await _openMathHub(context, year, course, item.id);
        },
        onOpenPractice: (VuPremiumLessonItem item) async {
          await _openMathHub(context, year, course, item.id);
        },
        onOpenQuiz: (VuPremiumLessonItem item) async {
          await _openMathHub(context, year, course, item.id);
        },
        onOpenDiscussion: (VuPremiumLessonItem item) async {
          await _openMathHub(context, year, course, item.id);
        },
      ),
    );
  }

  static String _baseLessonId(String itemId) {
    final int cut = itemId.indexOf('__');
    return cut < 0 ? itemId : itemId.substring(0, cut);
  }

  static HealthTopic? _healthTopic(HealthCourse course, String itemId) {
    final String id = _baseLessonId(itemId);
    for (final HealthTopic t in course.topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Future<void> _openHealthHub(
    BuildContext context,
    HealthFaculty faculty,
    HealthCourse course,
    String itemId,
  ) async {
    final HealthTopic? topic = _healthTopic(course, itemId);
    if (topic == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthLessonHubScreen(
          path: HealthLessonPath(
            faculty: faculty,
            course: course,
            topic: topic,
          ),
        ),
      ),
    );
  }

  static Future<void> _openWorldHub(
    BuildContext context,
    WorldSubjectMeta meta,
    WorldCourse course,
    String itemId,
  ) async {
    final String id = _baseLessonId(itemId);
    WorldTopic? topic;
    for (final WorldTopic t in course.topics) {
      if (t.id == id) {
        topic = t;
        break;
      }
    }
    if (topic == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorldCurriculumLessonHubScreen(
          meta: meta,
          path: WorldLessonPath(
            subjectId: meta.subjectId,
            course: course,
            topic: topic!,
          ),
        ),
      ),
    );
  }

  static Future<void> _openBioHub(
    BuildContext context,
    BiologyDegreeYear year,
    BiologyDegreeCourse course,
    String itemId,
  ) async {
    final String id = _baseLessonId(itemId);
    for (final BiologyDegreeModule module in course.modules) {
      for (final BiologyDegreeLesson lesson in module.lessons) {
        if (lesson.id == id) {
          if (!context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BiologyLessonHubScreen(
                path: BiologyLessonPath(
                  year: year,
                  course: course,
                  module: module,
                  lesson: lesson,
                ),
              ),
            ),
          );
          return;
        }
      }
    }
  }

  static Future<void> _openChemHub(
    BuildContext context,
    ChemistryDegreeYear year,
    ChemistryDegreeCourse course,
    String itemId,
  ) async {
    final String id = _baseLessonId(itemId);
    for (final ChemistryDegreeModule module in course.modules) {
      for (final ChemistryDegreeLesson lesson in module.lessons) {
        if (lesson.id == id) {
          if (!context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChemistryLessonHubScreen(
                path: ChemistryLessonPath(
                  year: year,
                  course: course,
                  module: module,
                  lesson: lesson,
                ),
              ),
            ),
          );
          return;
        }
      }
    }
  }

  static Future<void> _openMathHub(
    BuildContext context,
    MathematicsDegreeYear year,
    MathematicsDegreeCourse course,
    String itemId,
  ) async {
    final String id = _baseLessonId(itemId);
    for (final MathematicsDegreeModule module in course.modules) {
      for (final MathematicsDegreeLesson lesson in module.lessons) {
        if (lesson.id == id) {
          if (!context.mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MathematicsLessonHubScreen(
                path: MathematicsLessonPath(
                  year: year,
                  course: course,
                  module: module,
                  lesson: lesson,
                ),
              ),
            ),
          );
          return;
        }
      }
    }
  }

  static String _professorName(String faculty) {
    final String key = faculty.toLowerCase();
    if (key.contains('nursing')) return 'Prof. Elena';
    if (key.contains('medicine')) return 'Prof. Marcus';
    if (key.contains('psych')) return 'Prof. Naomi';
    if (key.contains('environ')) return 'Prof. Kai';
    if (key.contains('politic')) return 'Prof. Jordan';
    return 'Prof. Avery';
  }

  static List<VuPremiumModule> _chunkTopics(
    List<({String id, String title, String summary})> topics, {
    required String modulePrefix,
  }) {
    if (topics.isEmpty) {
      return <VuPremiumModule>[
        const VuPremiumModule(
          id: 'empty',
          title: 'Module 1',
          items: <VuPremiumLessonItem>[],
        ),
      ];
    }
    const int chunk = 5;
    final List<VuPremiumModule> out = <VuPremiumModule>[];
    for (int i = 0; i < topics.length; i += chunk) {
      final int end = (i + chunk).clamp(0, topics.length);
      final List<({String id, String title, String summary})> slice =
          topics.sublist(i, end);
      final int moduleIndex = (i ~/ chunk) + 1;
      out.add(
        VuPremiumModule(
          id: '${modulePrefix}_m$moduleIndex',
          title: 'Module $moduleIndex',
          subtitle: slice.first.title,
          items: slice
              .expand(
                (t) => <VuPremiumLessonItem>[
                  VuPremiumLessonItem(
                    id: t.id,
                    title: t.title,
                    subtitle: t.summary,
                    kind: VuLessonItemKind.lesson,
                  ),
                  VuPremiumLessonItem(
                    id: '${t.id}__interactive',
                    title: '${t.title} · Practice',
                    kind: VuLessonItemKind.interactive,
                    estimatedMinutes: 15,
                    xpReward: 35,
                  ),
                  VuPremiumLessonItem(
                    id: '${t.id}__quiz',
                    title: 'Quiz: ${t.title}',
                    kind: VuLessonItemKind.quiz,
                    estimatedMinutes: 12,
                    xpReward: 55,
                  ),
                ],
              )
              .toList(),
        ),
      );
    }
    // Cap AI discussion at end of each module
    return out
        .map(
          (VuPremiumModule m) => VuPremiumModule(
            id: m.id,
            title: m.title,
            subtitle: m.subtitle,
            items: <VuPremiumLessonItem>[
              ...m.items,
              VuPremiumLessonItem(
                id: '${m.id}__discussion',
                title: '${m.title} · AI Discussion',
                kind: VuLessonItemKind.discussion,
                estimatedMinutes: 10,
                xpReward: 30,
              ),
            ],
          ),
        )
        .toList();
  }

  static List<VuCourseUpcoming> _upcomingFromModules(
    List<VuPremiumModule> modules,
  ) {
    final List<VuPremiumLessonItem> quizzes = modules
        .expand((VuPremiumModule m) => m.items)
        .where((VuPremiumLessonItem i) => i.kind == VuLessonItemKind.quiz)
        .take(2)
        .toList();
    final List<VuCourseUpcoming> out = <VuCourseUpcoming>[];
    for (int i = 0; i < quizzes.length; i++) {
      out.add(
        VuCourseUpcoming(
          title: quizzes[i].title,
          whenLabel: i == 0 ? 'This week' : 'Next week',
          kind: VuLessonItemKind.quiz,
        ),
      );
    }
    if (modules.isNotEmpty) {
      out.add(
        const VuCourseUpcoming(
          title: 'Module reflection assignment',
          whenLabel: 'Due in 5 days',
          kind: VuLessonItemKind.assignment,
        ),
      );
    }
    return out;
  }
}
