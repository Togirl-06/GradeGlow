/// Curriculum scope for a single practice-lab topic — drives questions, diagrams, and AI prompts.
class TopicProfile {
  const TopicProfile({
    required this.topicId,
    required this.topicName,
    required this.domain,
    required this.learningObjectives,
    required this.skillsToTest,
    required this.forbiddenTerms,
    this.subjectId,
    this.courseId,
    this.courseName,
    this.unitName,
    this.questionBankKeys = const <String>[],
    this.allowedDiagramIds = const <String>[],
    this.strictScoping = true,
  });

  final String? subjectId;
  final String? courseId;
  final String topicId;
  final String topicName;
  final String? courseName;
  final String? unitName;
  final String domain;
  final List<String> learningObjectives;
  final List<String> skillsToTest;
  final List<String> forbiddenTerms;
  final List<String> questionBankKeys;
  final List<String> allowedDiagramIds;
  final bool strictScoping;

  String get cacheKey => '${subjectId ?? ''}|${courseId ?? ''}|$topicId';

  TopicProfile copyWith({
    String? topicName,
    String? courseName,
    String? unitName,
    List<String>? learningObjectives,
  }) {
    return TopicProfile(
      subjectId: subjectId,
      courseId: courseId,
      topicId: topicId,
      topicName: topicName ?? this.topicName,
      courseName: courseName ?? this.courseName,
      unitName: unitName ?? this.unitName,
      domain: domain,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      skillsToTest: skillsToTest,
      forbiddenTerms: forbiddenTerms,
      questionBankKeys: questionBankKeys,
      allowedDiagramIds: allowedDiagramIds,
      strictScoping: strictScoping,
    );
  }
}
