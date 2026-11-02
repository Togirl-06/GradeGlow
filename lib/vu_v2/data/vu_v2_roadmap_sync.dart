import '../../config/vu_schools_catalog.dart';
import '../../data/biology_degree_catalog.dart';
import '../../data/business_school_catalog.dart';
import '../../data/chemistry_degree_catalog.dart';
import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../data/engineering/engineering_catalog.dart';
import '../../data/health_faculty_catalog.dart';
import '../../data/law/law_catalog.dart';
import '../../data/mathematics_degree_catalog.dart';
import '../../data/physics/physics_catalog.dart';
import '../../data/practice_lab_university_catalog.dart';
import '../../data/world_curriculum_topics.dart';
import '../../models/biology_degree.dart';
import '../../models/business_school.dart';
import '../../models/chemistry_degree.dart';
import '../../models/cs_curriculum.dart';
import '../../models/engineering/engineering_program.dart';
import '../../models/health_faculty_program.dart';
import '../../models/law/law_program.dart';
import '../../models/mathematics_degree.dart';
import '../../models/physics/physics_program.dart';
import '../../models/practice_lab_subject.dart';
import '../../models/practice_lab_topic.dart';
import '../../models/practice_lab_unit.dart';
import 'vu_v2_degree_catalog.dart';
import 'vu_v2_roadmap_models.dart';

/// Syncs every college / uni faculty roadmap into one V2 browse tree.
///
/// Prefer rich degree catalogs when present; otherwise world curriculum topics;
/// finally Practice Lab course → unit → topic.
class VuV2RoadmapSync {
  VuV2RoadmapSync._();

  static final Map<String, VuV2DegreeRoadmap> _cache = <String, VuV2DegreeRoadmap>{};

  static void clearCache() => _cache.clear();

  static VuV2DegreeRoadmap forSubjectId(String subjectId) {
    final VuV2DegreeRoadmap? cached = _cache[subjectId];
    if (cached != null) return cached;
    final VuV2DegreeRoadmap built = _build(subjectId);
    _cache[subjectId] = built;
    return built;
  }

  static VuV2DegreeRoadmap forSubject(PracticeLabSubject subject) {
    return forSubjectId(subject.id);
  }

  static List<VuV2DegreeRoadmap> allFaculties() {
    final Map<String, VuV2DegreeRoadmap> byId = <String, VuV2DegreeRoadmap>{};
    for (final PracticeLabSubject s in PracticeLabUniversityCatalog.subjects) {
      if (s.id == 'sciences') continue;
      byId[s.id] = forSubjectId(s.id);
    }
    for (final VuV2DegreeDef d in VuV2DegreeCatalog.degrees) {
      byId.putIfAbsent(d.roadmapSubjectId, () => forSubjectId(d.roadmapSubjectId));
    }
    return byId.values.toList(growable: false);
  }

  static int get totalSyncedLessons =>
      allFaculties().fold<int>(0, (int n, VuV2DegreeRoadmap r) => n + r.lessonCount);

  static VuV2DegreeRoadmap _build(String subjectId) {
    return switch (subjectId) {
      'biology' => _biology(),
      'chemistry' => _chemistry(),
      'mathematics' => _mathematics(),
      'physics' => _physics(),
      'computer_science' => _computerScience(),
      'business' || 'business_administration' => _business(),
      'law' || 'introduction_to_law' => _law(),
      'engineering' || 'mechanical_engineering' => _engineering(),
      'nursing' => _health(HealthFaculty.nursing),
      'medicine' => _health(HealthFaculty.medicine),
      'psychology' => _health(HealthFaculty.psychology),
      'english' ||
      'environmental_science' ||
      'political_science' =>
        _world(subjectId),
      _ => _practiceLabOrEmpty(subjectId),
    };
  }

  static VuV2DegreeRoadmap _practiceLabOrEmpty(String subjectId) {
    final VuV2DegreeRoadmap lab = _practiceLab(subjectId);
    if (lab.tracks.isNotEmpty && lab.lessonCount > 0) return lab;

    final VuV2DegreeRoadmap school = _schoolProgram(subjectId);
    if (school.tracks.isNotEmpty && school.lessonCount > 0) return school;

    final VuV2DegreeDef? d = VuV2DegreeCatalog.byId(subjectId) ??
        VuV2DegreeCatalog.byRoadmapSubjectId(subjectId);
    if (d != null) {
      return VuV2DegreeCatalog.emptyRoadmap(
        subjectId: d.roadmapSubjectId,
        title: d.title,
        emoji: d.emoji,
        blurb: d.blurb,
      );
    }
    return VuV2DegreeCatalog.emptyRoadmap(
      subjectId: subjectId,
      title: subjectId.replaceAll('_', ' '),
      emoji: '📚',
      blurb: 'Curriculum not synced yet.',
    );
  }

  /// Builds a full course → topic roadmap from [VuSchoolsCatalog] program courses.
  static VuV2DegreeRoadmap _schoolProgram(String subjectId) {
    final VuSchoolProgram? program =
        VuSchoolsCatalog.programByExactId(subjectId) ??
            VuSchoolsCatalog.programById(subjectId);
    if (program == null) {
      return VuV2DegreeRoadmap(
        subjectId: subjectId,
        title: subjectId,
        emoji: '📚',
        sourceLabel: 'No school program mapped',
        tracks: const <VuV2RoadmapTrack>[],
      );
    }

    final VuSchool? school = VuSchoolsCatalog.schoolForProgramId(program.id);
    final List<String> courseNames = program.courses.isNotEmpty
        ? program.courses
        : <String>[
            '${program.title} Foundations',
            'Core Concepts in ${program.title}',
            'Methods and Practice',
            'Applied ${program.title}',
            'Advanced Topics',
            '${program.title} Capstone',
          ];

    final List<VuV2RoadmapCourse> courses = courseNames.map((String name) {
      final List<String> topics = WorldCurriculumTopics.topicsFor(
        subjectId: program.id,
        courseName: name,
      );
      final String courseId = WorldCurriculumTopics.slug(name);
      return VuV2RoadmapCourse(
        id: courseId,
        title: name,
        lessons: topics
            .asMap()
            .entries
            .map(
              (MapEntry<int, String> e) => VuV2RoadmapLesson(
                id: '${courseId}_${e.key}',
                title: e.value,
              ),
            )
            .toList(growable: false),
      );
    }).toList(growable: false);

    final int lessons =
        courses.fold<int>(0, (int n, VuV2RoadmapCourse c) => n + c.lessonCount);

    return VuV2DegreeRoadmap(
      subjectId: program.roadmapSubjectId,
      title: program.title,
      emoji: school?.emoji ?? '🎓',
      tagline: program.blurb ??
          '${school?.title ?? 'Grade Glow Virtual University'} program',
      sourceLabel:
          '${school?.title ?? 'Virtual University'} · ${courses.length} courses · $lessons lessons',
      tracks: <VuV2RoadmapTrack>[
        VuV2RoadmapTrack(
          id: '${program.id}_program',
          title: '${program.title} roadmap',
          subtitle: school?.title ?? 'Program curriculum',
          courses: courses,
        ),
      ],
    );
  }

  // ── Biology / Chemistry / Math (Year → Course → Module → Lesson) ─────────

  static VuV2DegreeRoadmap _biology() {
    final List<VuV2RoadmapTrack> tracks = BiologyDegreeCatalog.years
        .map(
          (BiologyDegreeYear y) => VuV2RoadmapTrack(
            id: 'year_${y.year}',
            title: y.title,
            subtitle: y.subtitle ?? 'Year ${y.year}',
            courses: y.courses
                .map(
                  (BiologyDegreeCourse c) => VuV2RoadmapCourse(
                    id: c.id,
                    title: c.title,
                    emoji: c.emoji,
                    subtitle: c.tagline,
                    modules: c.modules
                        .map(
                          (BiologyDegreeModule m) => VuV2RoadmapModule(
                            id: m.id,
                            title: m.title,
                            lessons: m.lessons
                                .map(
                                  (BiologyDegreeLesson l) => VuV2RoadmapLesson(
                                    id: l.id,
                                    title: l.title,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'biology',
      title: 'Biology',
      emoji: '🧬',
      tagline: 'Foundations through research — full degree roadmap',
      sourceLabel:
          'Biology Degree Catalog · ${tracks.length} years · ${BiologyDegreeCatalog.totalLessons} lessons',
      tracks: tracks,
    );
  }

  static VuV2DegreeRoadmap _chemistry() {
    final List<VuV2RoadmapTrack> tracks = ChemistryDegreeCatalog.years
        .map(
          (ChemistryDegreeYear y) => VuV2RoadmapTrack(
            id: 'year_${y.year}',
            title: y.title,
            subtitle: y.subtitle ?? 'Year ${y.year}',
            courses: y.courses
                .map(
                  (ChemistryDegreeCourse c) => VuV2RoadmapCourse(
                    id: c.id,
                    title: c.title,
                    emoji: c.emoji,
                    subtitle: c.tagline,
                    modules: c.modules
                        .map(
                          (ChemistryDegreeModule m) => VuV2RoadmapModule(
                            id: m.id,
                            title: m.title,
                            lessons: m.lessons
                                .map(
                                  (ChemistryDegreeLesson l) => VuV2RoadmapLesson(
                                    id: l.id,
                                    title: l.title,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'chemistry',
      title: 'Chemistry',
      emoji: '⚗️',
      tagline: 'General through advanced specializations',
      sourceLabel:
          'Chemistry Degree Catalog · ${tracks.length} years · ${ChemistryDegreeCatalog.totalLessons} lessons',
      tracks: tracks,
    );
  }

  static VuV2DegreeRoadmap _mathematics() {
    final List<VuV2RoadmapTrack> tracks = MathematicsDegreeCatalog.years
        .map(
          (MathematicsDegreeYear y) => VuV2RoadmapTrack(
            id: 'year_${y.year}',
            title: y.title,
            subtitle: y.subtitle ?? 'Year ${y.year}',
            courses: y.courses
                .map(
                  (MathematicsDegreeCourse c) => VuV2RoadmapCourse(
                    id: c.id,
                    title: c.title,
                    emoji: c.emoji,
                    subtitle: c.tagline,
                    modules: c.modules
                        .map(
                          (MathematicsDegreeModule m) => VuV2RoadmapModule(
                            id: m.id,
                            title: m.title,
                            lessons: m.lessons
                                .map(
                                  (MathematicsDegreeLesson l) => VuV2RoadmapLesson(
                                    id: l.id,
                                    title: l.title,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'mathematics',
      title: 'Mathematics',
      emoji: '📐',
      tagline: 'Four-year university mathematics degree',
      sourceLabel:
          'Mathematics Degree Catalog · ${tracks.length} years · ${MathematicsDegreeCatalog.totalLessons} lessons',
      tracks: tracks,
    );
  }

  // ── Physics (Level → Track → Course → Topic) ─────────────────────────────

  static VuV2DegreeRoadmap _physics() {
    final List<VuV2RoadmapTrack> tracks = PhysicsLevel.values.map((PhysicsLevel level) {
      final List<PhysicsTrack> levelTracks = PhysicsCatalog.tracksForLevel(level);
      final List<VuV2RoadmapCourse> courses = <VuV2RoadmapCourse>[];
      for (final PhysicsTrack track in levelTracks) {
        for (final PhysicsCourse course in track.courses) {
          courses.add(
            VuV2RoadmapCourse(
              id: '${track.id}|${course.id}',
              title: course.title,
              subtitle: '${track.name} · ${course.blurb}',
              lessons: course.topics
                  .map(
                    (PhysicsTopic t) => VuV2RoadmapLesson(
                      id: t.id,
                      title: t.title,
                      subtitle: track.name,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }
      }
      final PhysicsLevelStats stats = PhysicsCatalog.statsForLevel(level);
      return VuV2RoadmapTrack(
        id: level.name,
        title: level.label,
        subtitle: '${level.subtitle} · ${stats.courses} courses · ${stats.topics} topics',
        courses: courses,
      );
    }).toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'physics',
      title: 'Physics',
      emoji: '⚛️',
      tagline: PhysicsCatalog.mission,
      sourceLabel:
          'Physics Catalog · ${PhysicsCatalog.trackCount} tracks · ${PhysicsCatalog.topicCount} topics',
      tracks: tracks,
    );
  }

  // ── Computer Science (Language → Topics + Algorithms) ────────────────────

  static VuV2DegreeRoadmap _computerScience() {
    final List<VuV2RoadmapTrack> tracks = <VuV2RoadmapTrack>[
      ...CsCurriculumCatalog.languages.map((CsCurriculumLanguage lang) {
        final List<CsCurriculumTopic> topics =
            CsCurriculumCatalog.topicsInTrack(lang.id);
        return VuV2RoadmapTrack(
          id: lang.id,
          title: lang.label,
          subtitle: lang.isWeb ? 'Web track' : 'Programming track',
          courses: <VuV2RoadmapCourse>[
            VuV2RoadmapCourse(
              id: '${lang.id}_core',
              title: '${lang.label} curriculum',
              subtitle: '${topics.length} sequenced lessons',
              lessons: topics
                  .map(
                    (CsCurriculumTopic t) => VuV2RoadmapLesson(
                      id: t.id,
                      title: t.title,
                      subtitle: t.level.label,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        );
      }),
      VuV2RoadmapTrack(
        id: 'algorithms',
        title: 'Algorithms & Data Structures',
        subtitle: 'Shared track after language fundamentals',
        courses: <VuV2RoadmapCourse>[
          VuV2RoadmapCourse(
            id: 'algorithms_core',
            title: 'Algorithms curriculum',
            subtitle: '${CsCurriculumCatalog.algorithmsTopics.length} topics',
            lessons: CsCurriculumCatalog.algorithmsTopics
                .map(
                  (CsAlgorithmsTopic t) => VuV2RoadmapLesson(
                    id: t.id,
                    title: t.title,
                    subtitle: t.level.label,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    ];

    return VuV2DegreeRoadmap(
      subjectId: 'computer_science',
      title: 'Computer Science',
      emoji: '💻',
      tagline: 'Languages, web, and algorithms — college CS path',
      sourceLabel:
          'CS Curriculum · ${CsCurriculumCatalog.languages.length} languages · ${CsCurriculumCatalog.totalLessonCount()} lessons',
      tracks: tracks,
    );
  }

  // ── Business (Major → Course → Lesson) ───────────────────────────────────

  static VuV2DegreeRoadmap _business() {
    final List<VuV2RoadmapTrack> tracks = BusinessMajor.values.map((BusinessMajor major) {
      final List<BusinessCourse> courses = BusinessSchoolCatalog.coursesFor(major);
      return VuV2RoadmapTrack(
        id: major.name,
        title: major.title,
        subtitle: major.tagline,
        courses: courses
            .map(
              (BusinessCourse c) => VuV2RoadmapCourse(
                id: c.id,
                title: c.title,
                emoji: c.emoji,
                subtitle: '${c.code} · Year ${c.year}',
                lessons: c.lessons
                    .map(
                      (BusinessLesson l) => VuV2RoadmapLesson(
                        id: l.id,
                        title: l.title,
                      ),
                    )
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
    }).toList(growable: false);

    final int lessons = tracks.fold<int>(0, (int n, VuV2RoadmapTrack t) => n + t.lessonCount);
    return VuV2DegreeRoadmap(
      subjectId: 'business',
      title: 'Business',
      emoji: '💼',
      tagline: 'Management, economics, finance, marketing, accounting',
      sourceLabel: 'Business School Catalog · ${tracks.length} majors · $lessons lessons',
      tracks: tracks,
    );
  }

  // ── Law (Specialization → Course → Lesson) ──────────────────────────────

  static VuV2DegreeRoadmap _law() {
    final List<VuV2RoadmapTrack> tracks = LawCatalog.specializations
        .map(
          (LawSpecialization spec) => VuV2RoadmapTrack(
            id: spec.id,
            title: spec.name,
            subtitle: spec.tagline,
            courses: spec.courses
                .map(
                  (LawCourse c) => VuV2RoadmapCourse(
                    id: c.id,
                    title: c.title,
                    subtitle: c.blurb,
                    lessons: c.lessons
                        .map(
                          (LawLesson l) => VuV2RoadmapLesson(
                            id: l.id,
                            title: l.title,
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'law',
      title: 'Law',
      emoji: '⚖️',
      tagline: LawCatalog.mission,
      sourceLabel:
          'Law Catalog · ${LawCatalog.specializationCount} specializations · ${LawCatalog.lessonCount} lessons',
      tracks: tracks,
    );
  }

  // ── Engineering (Major → Course → Topics) ────────────────────────────────

  static VuV2DegreeRoadmap _engineering() {
    final List<VuV2RoadmapTrack> tracks = EngineeringCatalog.majors
        .map(
          (EngineeringMajor major) => VuV2RoadmapTrack(
            id: major.id,
            title: major.name,
            subtitle: major.tagline,
            courses: major.courses
                .map(
                  (EngineeringCourse c) => VuV2RoadmapCourse(
                    id: c.id,
                    title: c.title,
                    subtitle: c.blurb,
                    lessons: c.topics
                        .asMap()
                        .entries
                        .map(
                          (MapEntry<int, String> e) => VuV2RoadmapLesson(
                            id: '${c.id}_t${e.key}',
                            title: e.value,
                            subtitle: c.labTitle,
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: 'engineering',
      title: 'Engineering',
      emoji: '⚙️',
      tagline: EngineeringCatalog.philosophy,
      sourceLabel:
          'Engineering Catalog · ${EngineeringCatalog.majorCount} majors · ${EngineeringCatalog.courseCount} courses',
      tracks: tracks,
    );
  }

  // ── Health (Nursing / Medicine / Psychology) ─────────────────────────────

  static VuV2DegreeRoadmap _health(HealthFaculty faculty) {
    final List<HealthCourse> courses = HealthFacultyCatalog.coursesFor(faculty);
    final List<VuV2RoadmapCourse> mapped = courses
        .map(
          (HealthCourse c) => VuV2RoadmapCourse(
            id: c.id,
            title: c.title,
            lessons: c.topics
                .map(
                  (HealthTopic t) => VuV2RoadmapLesson(
                    id: t.id,
                    title: t.title,
                    subtitle: t.summary,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);

    final int lessonCount =
        mapped.fold<int>(0, (int n, VuV2RoadmapCourse c) => n + c.lessonCount);

    return VuV2DegreeRoadmap(
      subjectId: faculty.name,
      title: faculty.title,
      emoji: faculty.emoji,
      tagline: faculty.tagline,
      sourceLabel:
          'Health Faculty Catalog · ${courses.length} courses · $lessonCount topics (world curriculum)',
      tracks: <VuV2RoadmapTrack>[
        VuV2RoadmapTrack(
          id: '${faculty.name}_degree',
          title: '${faculty.title} degree roadmap',
          subtitle: 'Aligned to college / university health curricula',
          courses: mapped,
        ),
      ],
    );
  }

  // ── World curriculum subjects ────────────────────────────────────────────

  static VuV2DegreeRoadmap _world(String subjectId) {
    final PracticeLabSubject? subject =
        PracticeLabUniversityCatalog.subjectById(subjectId);
    final List<String> courseNames = WorldCurriculumTopics.coursesFor(subjectId);
    final List<VuV2RoadmapCourse> courses = courseNames.map((String name) {
      final List<String> topics = WorldCurriculumTopics.topicsFor(
        subjectId: subjectId,
        courseName: name,
      );
      final String courseId = WorldCurriculumTopics.slug(name);
      return VuV2RoadmapCourse(
        id: courseId,
        title: name,
        lessons: topics
            .asMap()
            .entries
            .map(
              (MapEntry<int, String> e) => VuV2RoadmapLesson(
                id: '${courseId}_${e.key}',
                title: e.value,
              ),
            )
            .toList(growable: false),
      );
    }).toList(growable: false);

    final int lessons =
        courses.fold<int>(0, (int n, VuV2RoadmapCourse c) => n + c.lessonCount);

    return VuV2DegreeRoadmap(
      subjectId: subjectId,
      title: subject?.name ?? subjectId,
      emoji: subject?.emoji ?? '🌍',
      tagline: 'World university curriculum roadmap',
      sourceLabel:
          'World Curriculum · ${courses.length} courses · $lessons topics',
      tracks: <VuV2RoadmapTrack>[
        VuV2RoadmapTrack(
          id: '${subjectId}_world',
          title: 'Degree roadmap',
          subtitle: 'Synced with world college / university course maps',
          courses: courses,
        ),
      ],
    );
  }

  // ── Practice Lab fallback ────────────────────────────────────────────────

  static VuV2DegreeRoadmap _practiceLab(String subjectId) {
    final PracticeLabSubject? subject =
        PracticeLabUniversityCatalog.subjectById(subjectId);
    if (subject == null) {
      return VuV2DegreeRoadmap(
        subjectId: subjectId,
        title: subjectId,
        emoji: '📚',
        sourceLabel: 'No catalog mapped',
        tracks: const <VuV2RoadmapTrack>[],
      );
    }

    // Prefer world course names when available (keeps titles university-aligned).
    final List<String> worldCourses =
        WorldCurriculumTopics.coursesFor(subjectId);
    if (worldCourses.isNotEmpty) {
      return _world(subjectId);
    }

    final List<VuV2RoadmapCourse> courses = subject.courses.map((PracticeLabCourse c) {
      final List<PracticeLabUnit> units = c.units;
      if (units.isEmpty) {
        return VuV2RoadmapCourse(
          id: c.id,
          title: c.name,
          lessons: const <VuV2RoadmapLesson>[
            VuV2RoadmapLesson(id: 'intro', title: 'Course orientation'),
          ],
        );
      }
      return VuV2RoadmapCourse(
        id: c.id,
        title: c.name,
        modules: units
            .map(
              (PracticeLabUnit u) => VuV2RoadmapModule(
                id: u.id,
                title: u.name,
                lessons: u.topics
                    .map(
                      (PracticeLabTopic t) => VuV2RoadmapLesson(
                        id: t.id,
                        title: t.name,
                      ),
                    )
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
    }).toList(growable: false);

    return VuV2DegreeRoadmap(
      subjectId: subject.id,
      title: subject.name,
      emoji: subject.emoji,
      tagline: 'Practice Lab university catalog',
      sourceLabel:
          'Practice Lab Catalog · ${courses.length} courses · ${subject.topicCount} topics',
      tracks: <VuV2RoadmapTrack>[
        VuV2RoadmapTrack(
          id: '${subject.id}_path',
          title: '${subject.name} roadmap',
          subtitle: 'Synced college course map',
          courses: courses,
        ),
      ],
    );
  }
}
