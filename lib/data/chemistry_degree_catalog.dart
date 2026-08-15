import '../models/chemistry_degree.dart';
import 'practice_lab_course_topics/science_topics.dart';
import 'chemistry_degree/builders.dart';

/// Full Virtual University Chemistry curriculum — 26 specializations.
class ChemistryDegreeCatalog {
  ChemistryDegreeCatalog._();

  static final List<ChemistryDegreeYear> years = <ChemistryDegreeYear>[
    _year1(),
    _year2(),
    _year3(),
    _year4(),
  ];

  static int get totalLessons {
    var count = 0;
    for (final ChemistryDegreeYear year in years) {
      for (final ChemistryDegreeCourse course in year.courses) {
        count += course.lessonCount;
      }
    }
    return count;
  }

  static ChemistryDegreeYear? yearByNumber(int year) {
    for (final ChemistryDegreeYear entry in years) {
      if (entry.year == year) return entry;
    }
    return null;
  }

  static ChemistryLessonPath? resolveLesson(String lessonId) {
    for (final ChemistryDegreeYear year in years) {
      for (final ChemistryDegreeCourse course in year.courses) {
        for (final ChemistryDegreeModule module in course.modules) {
          for (final ChemistryDegreeLesson lesson in module.lessons) {
            if (lesson.id == lessonId) {
              return ChemistryLessonPath(
                year: year,
                course: course,
                module: module,
                lesson: lesson,
              );
            }
          }
        }
      }
    }
    return null;
  }

  static ChemistryLessonPath get defaultLesson {
    final ChemistryDegreeYear year = years.first;
    final ChemistryDegreeCourse course = year.courses.first;
    final ChemistryDegreeModule module = course.modules.first;
    final ChemistryDegreeLesson lesson = module.lessons.first;
    return ChemistryLessonPath(
      year: year,
      course: course,
      module: module,
      lesson: lesson,
    );
  }

  static List<ChemistryLessonPath>? _allLessonPathsCache;

  static List<ChemistryLessonPath> get allLessonPaths {
    return _allLessonPathsCache ??= _buildAllLessonPaths();
  }

  static List<ChemistryLessonPath> _buildAllLessonPaths() {
    final List<ChemistryLessonPath> paths = <ChemistryLessonPath>[];
    for (final ChemistryDegreeYear year in years) {
      for (final ChemistryDegreeCourse course in year.courses) {
        for (final ChemistryDegreeModule module in course.modules) {
          for (final ChemistryDegreeLesson lesson in module.lessons) {
            paths.add(
              ChemistryLessonPath(
                year: year,
                course: course,
                module: module,
                lesson: lesson,
              ),
            );
          }
        }
      }
    }
    return paths;
  }

  static List<ChemistryCourseRef> get allCourses {
    final List<ChemistryCourseRef> refs = <ChemistryCourseRef>[];
    for (final ChemistryDegreeYear year in years) {
      for (final ChemistryDegreeCourse course in year.courses) {
        refs.add(ChemistryCourseRef(year: year, course: course));
      }
    }
    return refs;
  }

  static List<ChemistryCourseRef> coursesForTrack(int? yearNumber) {
    if (yearNumber == null) return allCourses;
    return allCourses.where((ChemistryCourseRef r) => r.year.year == yearNumber).toList();
  }

  static List<ChemistryLessonPath> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <ChemistryLessonPath>[];
    return allLessonPaths
        .where(
          (ChemistryLessonPath path) =>
              path.lesson.title.toLowerCase().contains(q) ||
              path.course.title.toLowerCase().contains(q) ||
              path.year.title.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<String> _topicsFor(String courseKey, String fallbackName) {
    return chemistryCourseTopics[courseKey] ?? chemDefaultTopics(fallbackName);
  }

  static ChemistryDegreeYear _year1() {
    return chemYear(
      1,
      'Foundations',
      <ChemistryDegreeCourse>[
        chemFlatCourse(
          'general_chemistry',
          'General Chemistry',
          _topicsFor('chemistry|general_chemistry', 'General Chemistry'),
          emoji: '⚗️',
          tagline: 'Atoms · bonding · stoichiometry · reactions',
        ),
      ],
      subtitle: 'Build laboratory literacy and core theory',
    );
  }

  static ChemistryDegreeYear _year2() {
    return chemYear(
      2,
      'Core Disciplines',
      <ChemistryDegreeCourse>[
        chemFlatCourse(
          'organic_chemistry',
          'Organic Chemistry',
          _topicsFor('chemistry|organic_chemistry', 'Organic Chemistry'),
          emoji: '🧪',
          tagline: 'Mechanisms · synthesis · spectroscopy',
        ),
        chemFlatCourse(
          'inorganic_chemistry',
          'Inorganic Chemistry',
          chemDefaultTopics('Inorganic Chemistry'),
          emoji: '🔷',
          tagline: 'Coordination · crystal field · main group',
        ),
        chemFlatCourse(
          'analytical_chemistry',
          'Analytical Chemistry',
          _topicsFor('chemistry|analytical_chemistry', 'Analytical Chemistry'),
          emoji: '📊',
          tagline: 'Titration · chromatography · instrumentation',
        ),
        chemFlatCourse(
          'physical_chemistry',
          'Physical Chemistry',
          _topicsFor('chemistry|physical_chemistry', 'Physical Chemistry'),
          emoji: '⚛️',
          tagline: 'Thermo · kinetics · quantum',
        ),
        chemFlatCourse(
          'biochemistry',
          'Biochemistry',
          _topicsFor('chemistry|biochemistry', 'Biochemistry'),
          emoji: '🧬',
          tagline: 'Proteins · metabolism · molecular life',
        ),
      ],
      subtitle: 'University core chemistry programs',
    );
  }

  static ChemistryDegreeYear _year3() {
    return chemYear(
      3,
      'Applied Chemistry',
      <ChemistryDegreeCourse>[
        _spec('environmental_chemistry', 'Environmental Chemistry', '🌍'),
        _spec('industrial_chemistry', 'Industrial Chemistry', '🏭'),
        _spec('medicinal_chemistry', 'Medicinal Chemistry', '💊'),
        _spec('pharmaceutical_chemistry', 'Pharmaceutical Chemistry', '💉'),
        _spec('polymer_chemistry', 'Polymer Chemistry', '🔗'),
        _spec('materials_chemistry', 'Materials Chemistry', '🧱'),
        _spec('food_chemistry', 'Food Chemistry', '🍎'),
        _spec('forensic_chemistry', 'Forensic Chemistry', '🔍'),
        _spec('green_chemistry', 'Green Chemistry', '♻️'),
      ],
      subtitle: 'Industry · medicine · environment',
    );
  }

  static ChemistryDegreeYear _year4() {
    return chemYear(
      4,
      'Advanced & Research',
      <ChemistryDegreeCourse>[
        _spec('nuclear_chemistry', 'Nuclear Chemistry', '☢️'),
        _spec('computational_chemistry', 'Computational Chemistry', '💻'),
        _spec('theoretical_chemistry', 'Theoretical Chemistry', '📐'),
        _spec('electrochemistry', 'Electrochemistry', '🔋'),
        _spec('photochemistry', 'Photochemistry', '💡'),
        _spec('surface_chemistry', 'Surface Chemistry', '🫧'),
        _spec('nanochemistry', 'Nanochemistry', '🔬'),
        _spec('atmospheric_chemistry', 'Atmospheric Chemistry', '🌤️'),
        _spec('geochemistry', 'Geochemistry', '🪨'),
        _spec('marine_chemistry', 'Marine Chemistry', '🌊'),
        _spec('astrochemistry', 'Astrochemistry', '🌌'),
      ],
      subtitle: 'Research frontier & capstone readiness',
    );
  }

  static ChemistryDegreeCourse _spec(String id, String title, String emoji) {
    return chemFlatCourse(
      id,
      title,
      chemDefaultTopics(title),
      emoji: emoji,
      tagline: 'AI lectures · virtual lab · textbook depth',
    );
  }
}
