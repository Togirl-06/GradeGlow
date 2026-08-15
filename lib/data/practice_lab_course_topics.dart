import '../models/practice_lab.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import 'practice_lab_course_topics/business_topics.dart';
import 'practice_lab_course_topics/computer_science_topics.dart';
import 'practice_lab_course_topics/engineering_topics.dart';
import 'practice_lab_course_topics/health_topics.dart';
import 'practice_lab_course_topics/humanities_social_topics.dart';
import 'practice_lab_course_topics/mathematics_topics.dart';
import 'practice_lab_course_topics/science_topics.dart';
import 'practice_lab_hierarchy_data.dart';
import 'science_diagram_catalog.dart';

/// Builds Subject → Course → Unit → Topic hierarchy for Practice Labs.
class PracticeLabCourseTopics {
  PracticeLabCourseTopics._();

  static final Map<String, List<PracticeLabUnit>> _unitCache = <String, List<PracticeLabUnit>>{};

  static String slug(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static SimulationStyle styleForGroup(String groupId) => switch (groupId) {
        'health_medical' => SimulationStyle.aiPatient,
        'law_criminal_justice' => SimulationStyle.courtroom,
        'computer_technology' => SimulationStyle.codingInterview,
        'science' => SimulationStyle.diagnosis,
        'engineering' => SimulationStyle.systemDesign,
        'business' || 'mathematics_finance' => SimulationStyle.customerScenario,
        'psychology_social_sciences' => SimulationStyle.counseling,
        'humanities' => SimulationStyle.classroom,
        _ => SimulationStyle.customerScenario,
      };

  static bool codeLabForCourse(String subjectId, String courseId) {
    if (subjectId != 'computer_science') return false;
    return const <String>{
      'programming_fundamentals',
      'data_structures',
      'algorithms',
      'databases',
      'operating_systems',
      'computer_networks',
      'software_engineering',
      'artificial_intelligence',
      'machine_learning',
      'cybersecurity',
    }.contains(courseId);
  }

  static String aiRoleForGroup(String groupId) => switch (groupId) {
        'health_medical' => 'Patient',
        'law_criminal_justice' => 'Witness',
        'computer_technology' => 'Technical Interviewer',
        'science' => 'Lab Partner',
        'engineering' => 'Project Manager',
        'psychology_social_sciences' => 'Client',
        _ => 'Supervisor',
      };

  static List<PracticeLabUnit> buildUnits({
    required String subjectId,
    required String courseId,
    required String courseName,
    required String groupId,
  }) {
    final String key = '$subjectId|$courseId';
    return _unitCache.putIfAbsent(key, () {
      final List<PracticeLabHierarchySeed> seeds = PracticeLabHierarchyData.forCourse(subjectId, courseId);
      final List<PracticeLabHierarchySeed> effective =
          seeds.isNotEmpty ? seeds : _fallbackSeeds(subjectId, courseId, courseName);

      final SimulationStyle style = styleForGroup(groupId);
      final String aiRole = aiRoleForGroup(groupId);

      return effective.map((PracticeLabHierarchySeed seed) {
        final String unitId = slug(seed.unit);
        return PracticeLabUnit(
          id: unitId,
          name: seed.unit,
          topics: seed.topics
              .map(
                (String topicName) {
                  final String topicId = slug(topicName);
                  final bool diagramLab = ScienceDiagramCatalog.supportsSubject(subjectId);
                  return PracticeLabTopic(
                    id: topicId,
                    name: topicName,
                    description: '',
                    style: diagramLab ? SimulationStyle.diagramLab : style,
                    aiRole: aiRole,
                    codeLab: false,
                    beginner: true,
                    intermediate: true,
                    advanced: true,
                  );
                },
              )
              .toList(),
        );
      }).toList();
    });
  }

  static List<PracticeLabHierarchySeed> _fallbackSeeds(String subjectId, String courseId, String courseName) {
    final List<String> curated = _allCourseTopics['$subjectId|$courseId'] ?? _defaultNames(courseName);
    if (curated.length <= 6) {
      return <PracticeLabHierarchySeed>[PracticeLabHierarchySeed(unit: 'Core Topics', topics: curated)];
    }
    final int half = (curated.length / 2).ceil();
    return <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Unit 1', topics: curated.sublist(0, half)),
      PracticeLabHierarchySeed(unit: 'Unit 2', topics: curated.sublist(half)),
    ];
  }

  static List<String> _defaultNames(String courseName) => <String>[
        '$courseName Foundations',
        '$courseName Applied Practice',
        '$courseName Case Scenarios',
        '$courseName Skills Assessment',
      ];

  static final Map<String, List<String>> _allCourseTopics = <String, List<String>>{
    ...mathematicsCourseTopics,
    ...computerScienceCourseTopics,
    ...biologyCourseTopics,
    ...chemistryCourseTopics,
    ...physicsCourseTopics,
    ...nursingCourseTopics,
    ...medicineCourseTopics,
    ...psychologyCourseTopics,
    ...lawCourseTopics,
    ...englishCourseTopics,
    ...businessCourseTopics,
    ...economicsCourseTopics,
    ...financeCourseTopics,
    ...marketingCourseTopics,
    ...accountingCourseTopics,
    ...engineeringCourseTopics,
  };
}
