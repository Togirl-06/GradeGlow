import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

/// Builds major-scoped topic areas so every major has unique topic IDs and content.
List<PracticeLabTopicArea> majorTopicAreas({
  required String majorId,
  required List<({String id, String name, String emoji, List<PracticeLabTopic> topics})> areas,
}) {
  return areas
      .map(
        (({String id, String name, String emoji, List<PracticeLabTopic> topics}) area) => PracticeLabTopicArea(
              id: '${majorId}_${area.id}',
              name: area.name,
              emoji: area.emoji,
              topics: area.topics
                  .map(
                    (PracticeLabTopic topic) => PracticeLabTopic(
                      id: '${majorId}_${topic.id}',
                      name: topic.name,
                      description: topic.description,
                      style: topic.style,
                      aiRole: topic.aiRole,
                      codeLab: topic.codeLab,
                      beginner: topic.beginner,
                      intermediate: topic.intermediate,
                      advanced: topic.advanced,
                      studentTasks: topic.studentTasks,
                      evaluationCriteria: topic.evaluationCriteria,
                    ),
                  )
                  .toList(),
            ),
      )
      .toList();
}

PracticeLabTopic labTopic({
  required String id,
  required String name,
  required String description,
  SimulationStyle style = SimulationStyle.customerScenario,
  String aiRole = 'Supervisor',
  bool codeLab = false,
  bool beginner = true,
  bool intermediate = true,
  bool advanced = false,
  List<String>? studentTasks,
  List<String>? evaluationCriteria,
}) {
  return PracticeLabTopic(
    id: id,
    name: name,
    description: description,
    style: style,
    aiRole: aiRole,
    codeLab: codeLab,
    beginner: beginner,
    intermediate: intermediate,
    advanced: advanced,
    studentTasks: studentTasks ?? const <String>[
      'Analyze the situation using your coursework',
      'Communicate your reasoning clearly',
      'Recommend evidence-based next steps',
    ],
    evaluationCriteria: evaluationCriteria ?? const <String>[
      'Domain knowledge',
      'Critical thinking',
      'Professional communication',
    ],
  );
}
