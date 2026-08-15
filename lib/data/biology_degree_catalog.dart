import '../models/biology_degree.dart';
import 'biology_degree/builders.dart';
import 'practice_lab_course_topics/science_topics.dart';

/// Full Virtual University Biology curriculum — foundations through research.
class BiologyDegreeCatalog {
  BiologyDegreeCatalog._();

  static final List<BiologyDegreeYear> years = <BiologyDegreeYear>[
    _year1(),
    _year2(),
    _year3(),
    _year4(),
  ];

  static int get totalLessons {
    var count = 0;
    for (final BiologyDegreeYear year in years) {
      for (final BiologyDegreeCourse course in year.courses) {
        count += course.lessonCount;
      }
    }
    return count;
  }

  static BiologyDegreeYear? yearByNumber(int year) {
    for (final BiologyDegreeYear entry in years) {
      if (entry.year == year) return entry;
    }
    return null;
  }

  static BiologyLessonPath? resolveLesson(String lessonId) {
    for (final BiologyDegreeYear year in years) {
      for (final BiologyDegreeCourse course in year.courses) {
        for (final BiologyDegreeModule module in course.modules) {
          for (final BiologyDegreeLesson lesson in module.lessons) {
            if (lesson.id == lessonId) {
              return BiologyLessonPath(
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

  static BiologyLessonPath get defaultLesson {
    final BiologyDegreeYear year = years.first;
    final BiologyDegreeCourse course = year.courses.first;
    final BiologyDegreeModule module = course.modules.first;
    final BiologyDegreeLesson lesson = module.lessons.first;
    return BiologyLessonPath(
      year: year,
      course: course,
      module: module,
      lesson: lesson,
    );
  }

  static List<BiologyLessonPath>? _allLessonPathsCache;

  static List<BiologyLessonPath> get allLessonPaths {
    return _allLessonPathsCache ??= _buildAllLessonPaths();
  }

  static List<BiologyLessonPath> _buildAllLessonPaths() {
    final List<BiologyLessonPath> paths = <BiologyLessonPath>[];
    for (final BiologyDegreeYear year in years) {
      for (final BiologyDegreeCourse course in year.courses) {
        for (final BiologyDegreeModule module in course.modules) {
          for (final BiologyDegreeLesson lesson in module.lessons) {
            paths.add(
              BiologyLessonPath(
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

  static List<BiologyCourseRef> get allCourses {
    final List<BiologyCourseRef> refs = <BiologyCourseRef>[];
    for (final BiologyDegreeYear year in years) {
      for (final BiologyDegreeCourse course in year.courses) {
        refs.add(BiologyCourseRef(year: year, course: course));
      }
    }
    return refs;
  }

  static List<BiologyCourseRef> coursesForTrack(int? yearNumber) {
    if (yearNumber == null) return allCourses;
    return allCourses.where((BiologyCourseRef r) => r.year.year == yearNumber).toList();
  }

  static List<BiologyLessonPath> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <BiologyLessonPath>[];
    return allLessonPaths
        .where(
          (BiologyLessonPath path) =>
              path.lesson.title.toLowerCase().contains(q) ||
              path.course.title.toLowerCase().contains(q) ||
              path.year.title.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<String> _topicsFor(String courseKey, String fallbackName) {
    return biologyCourseTopics[courseKey] ?? bioDefaultTopics(fallbackName);
  }

  static BiologyDegreeCourse _spec(String id, String title, String emoji) {
    return bioFlatCourse(
      id,
      title,
      bioDefaultTopics(title),
      emoji: emoji,
      tagline: 'Specialized track · labs · research applications',
    );
  }

  static BiologyDegreeYear _year1() {
    return bioYear(
      1,
      'Foundations',
      <BiologyDegreeCourse>[
        bioFlatCourse(
          'general_biology',
          'General Biology',
          _topicsFor('biology|general_biology', 'General Biology'),
          emoji: '🌱',
          tagline: 'Life · scientific method · macromolecules · cells',
        ),
        bioFlatCourse(
          'cell_biology',
          'Cell Biology',
          _topicsFor('biology|cell_biology', 'Cell Biology'),
          emoji: '🧫',
          tagline: 'Organelles · membranes · mitosis · communication',
        ),
        bioFlatCourse(
          'biochemistry_life',
          'Biochemistry of Life',
          <String>[
            'Characteristics of Life',
            'Water & Life',
            'Macromolecules',
            'Carbohydrates',
            'Lipids',
            'Proteins',
            'Nucleic Acids',
            'Enzymes',
            'Enzyme Kinetics',
            'ATP & Energy Coupling',
            'Metabolic Pathways Intro',
            'Common Misconceptions',
            'Lab Techniques',
            'Exam Review',
          ],
          emoji: '⚗️',
          tagline: 'Molecules that make living systems run',
        ),
      ],
      subtitle: 'Build scientific literacy and cellular foundations',
    );
  }

  static BiologyDegreeYear _year2() {
    return bioYear(
      2,
      'Core Life Sciences',
      <BiologyDegreeCourse>[
        bioFlatCourse(
          'molecular_biology',
          'Molecular Biology',
          <String>[
            'DNA Structure',
            'RNA',
            'DNA Replication',
            'Transcription',
            'Translation',
            'Gene Regulation',
            'Mutations',
            'Biotechnology',
            'CRISPR',
            'Genomics',
            'PCR',
            'Gel Electrophoresis',
            'DNA Sequencing',
            'Exam Review',
          ],
          emoji: '🧬',
          tagline: 'Central dogma · gene expression · biotech tools',
        ),
        bioFlatCourse(
          'genetics',
          'Genetics',
          _topicsFor('biology|genetics', 'Genetics'),
          emoji: '👪',
          tagline: 'Mendel · pedigrees · populations · disorders',
        ),
        bioFlatCourse(
          'microbiology',
          'Microbiology',
          _topicsFor('biology|microbiology', 'Microbiology'),
          emoji: '🦠',
          tagline: 'Bacteria · viruses · immunity · antibiotics',
        ),
        bioFlatCourse(
          'evolution',
          'Evolution',
          <String>[
            'Natural Selection',
            'Adaptation',
            'Speciation',
            'Evolutionary Evidence',
            'Phylogenetics',
            'Hardy-Weinberg',
            'Sexual Selection',
            'Coevolution',
            'Extinction & Mass Extinction',
            'Human Evolution',
            'Exam Review',
          ],
          emoji: '🦕',
          tagline: 'Change through time · evidence · trees of life',
        ),
        bioFlatCourse(
          'diversity_of_life',
          'Diversity of Life',
          <String>[
            'Viruses',
            'Bacteria',
            'Archaea',
            'Protists',
            'Fungi',
            'Plants',
            'Invertebrates',
            'Vertebrates',
            'Taxonomy',
            'Exam Review',
          ],
          emoji: '🌍',
          tagline: 'Tree of life across domains and kingdoms',
        ),
      ],
      subtitle: 'Genes · microbes · evolution · biodiversity',
    );
  }

  static BiologyDegreeYear _year3() {
    return bioYear(
      3,
      'Organismal & Human Biology',
      <BiologyDegreeCourse>[
        bioFlatCourse(
          'plant_biology',
          'Plant Biology',
          <String>[
            'Plant Cells',
            'Plant Tissues',
            'Roots',
            'Stems',
            'Leaves',
            'Flowers',
            'Photosynthesis',
            'Plant Hormones',
            'Plant Reproduction',
            'Water Transport',
            'Exam Review',
          ],
          emoji: '🌿',
          tagline: 'Structure · photosynthesis · plant hormones',
        ),
        bioFlatCourse(
          'anatomy',
          'Human Anatomy',
          _topicsFor('biology|anatomy', 'Human Anatomy'),
          emoji: '🦴',
          tagline: 'Systems from integument to reproduction',
        ),
        bioFlatCourse(
          'physiology',
          'Human Physiology',
          _topicsFor('biology|physiology', 'Human Physiology'),
          emoji: '❤️',
          tagline: 'How organ systems keep you alive',
        ),
        bioFlatCourse(
          'developmental_biology',
          'Developmental Biology',
          <String>[
            'Fertilization',
            'Embryonic Development',
            'Tissue Formation',
            'Organ Development',
            'Stem Cells in Development',
            'Aging',
            'Exam Review',
          ],
          emoji: '🐣',
          tagline: 'From zygote to organ systems',
        ),
        bioFlatCourse(
          'ecology',
          'Ecology',
          _topicsFor('biology|ecology', 'Ecology'),
          emoji: '🏞️',
          tagline: 'Ecosystems · populations · climate · conservation',
        ),
      ],
      subtitle: 'Plants · body systems · development · ecosystems',
    );
  }

  static BiologyDegreeYear _year4() {
    return bioYear(
      4,
      'Applied Biology & Research',
      <BiologyDegreeCourse>[
        _spec('immunology', 'Immunology', '🛡️'),
        _spec('biotechnology', 'Biotechnology & Research', '🧪'),
        _spec('bioinformatics', 'Bioinformatics', '💻'),
        _spec('biomedical_research', 'Biomedical Research', '🩺'),
        _spec('conservation_biology', 'Conservation Biology', '🐼'),
        _spec('neuroscience', 'Neuroscience', '🧠'),
        _spec('synthetic_biology', 'Synthetic Biology', '🔧'),
        _spec('scientific_writing', 'Scientific Writing', '📝'),
      ],
      subtitle: 'Labs · papers · clinical and research careers',
    );
  }
}
