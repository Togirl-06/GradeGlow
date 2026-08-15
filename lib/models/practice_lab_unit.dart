import 'practice_lab_topic.dart';

/// Unit within a course (e.g. "Functions" under College Algebra).
class PracticeLabUnit {
  const PracticeLabUnit({
    required this.id,
    required this.name,
    required this.topics,
  });

  final String id;
  final String name;
  final List<PracticeLabTopic> topics;
}
