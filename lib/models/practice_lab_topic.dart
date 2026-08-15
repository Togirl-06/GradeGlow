import 'practice_lab.dart';

/// A curriculum topic inside a practice-lab area (e.g. "Vital signs").
class PracticeLabTopic {
  const PracticeLabTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    this.aiRole = 'Supervisor',
    this.codeLab = false,
    this.beginner = true,
    this.intermediate = true,
    this.advanced = false,
    this.studentTasks = const <String>[
      'Analyze the situation using your coursework',
      'Communicate your reasoning clearly',
      'Recommend evidence-based next steps',
    ],
    this.evaluationCriteria = const <String>[
      'Domain knowledge',
      'Critical thinking',
      'Professional communication',
    ],
  });

  final String id;
  final String name;
  final String description;
  final SimulationStyle style;
  final String aiRole;
  final bool codeLab;
  final bool beginner;
  final bool intermediate;
  final bool advanced;
  final List<String> studentTasks;
  final List<String> evaluationCriteria;

  int get difficultySlots {
    int count = 0;
    if (beginner) count++;
    if (intermediate) count++;
    if (advanced) count++;
    return count;
  }
}

/// A subject area grouping related topics (e.g. "Fundamentals", "Pharmacology").
class PracticeLabTopicArea {
  const PracticeLabTopicArea({
    required this.id,
    required this.name,
    required this.emoji,
    required this.topics,
  });

  final String id;
  final String name;
  final String emoji;
  final List<PracticeLabTopic> topics;

  /// Display count — each difficulty slot supports unlimited AI-generated variants.
  int get labCount => topics.fold<int>(0, (int sum, PracticeLabTopic t) => sum + t.difficultySlots) * 7;
}
