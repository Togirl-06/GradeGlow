import '../../models/physics/physics_program.dart';
import 'physics_chapter_navigation.dart';
import 'physics_textbook_chapter_engine.dart';
import 'physics_formula_engine.dart';
import 'knowledge/velocity_knowledge.dart';

/// Complete physics knowledge guides — textbook-depth reference for every topic.
class PhysicsTopicKnowledgeEngine {
  PhysicsTopicKnowledgeEngine._();

  static final Map<String, String Function()> _custom = <String, String Function()>{
    'kinematics_velocity': velocityCompleteKnowledge,
  };

  static String completeGuide({
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required String levelLabel,
  }) {
    final String Function()? custom = _custom[topic.id];
    if (custom != null) {
      return PhysicsChapterNav.wrapChapter(
        course: course,
        topic: topic,
        chapterBody: custom(),
      );
    }

    final String Function(PhysicsCourse, PhysicsTopic, String)? builder = _courseBuilders[course.id];
    if (builder != null) return builder(course, topic, levelLabel);

    return PhysicsTextbookChapterEngine.build(
      course: course,
      topic: topic,
      levelLabel: levelLabel,
    );
  }

  /// Shorter outline for AI professor context (token limit).
  static String lectureOutline({
    required PhysicsCourse course,
    required PhysicsTopic topic,
  }) {
    final PhysicsChapterNav nav = PhysicsChapterNav.forTopic(course: course, topic: topic);
    final List<PhysicsFormula> formulas = PhysicsFormulaEngine.formulasFor(
      courseId: course.id,
      topic: topic,
    );
    final String formulaLines = formulas
        .map((PhysicsFormula f) => '- ${f.name}: \$${f.latex}\$')
        .join('\n');
    final String prev = nav.previous?.title ?? '(first chapter)';
    final String next = nav.next?.title ?? '(last chapter)';
    return 'Chapter ${nav.chapterNumber} of ${nav.totalChapters}\n'
        'Previous chapter: $prev\n'
        'Next chapter: $next\n'
        'Topic: ${topic.title}\nCourse: ${course.title}\n'
        'Hook: ${topic.hook}\n'
        'Key concepts: ${topic.keyConcepts.join(', ')}\n'
        'Formulas:\n$formulaLines\n'
        'Real world: ${topic.realWorld}';
  }

  static final Map<String, String Function(PhysicsCourse, PhysicsTopic, String)> _courseBuilders =
      <String, String Function(PhysicsCourse, PhysicsTopic, String)>{
    'kinematics': _chapterForCourse,
    'newtonian_mechanics': _chapterForCourse,
    'work_energy_power': _chapterForCourse,
    'momentum_collisions': _chapterForCourse,
    'electric_circuits': _chapterForCourse,
    'electrostatics': _chapterForCourse,
    'quantum_mechanics': _chapterForCourse,
    'thermodynamics': _chapterForCourse,
    'optics': _chapterForCourse,
    'gravitation': _chapterForCourse,
  };

  static String _chapterForCourse(PhysicsCourse course, PhysicsTopic topic, String levelLabel) {
    if (topic.id == 'kinematics_velocity') return velocityCompleteKnowledge();
    return PhysicsTextbookChapterEngine.build(
      course: course,
      topic: topic,
      levelLabel: levelLabel,
    );
  }
}
