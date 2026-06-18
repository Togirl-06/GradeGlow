class ParsedQuestion {
  const ParsedQuestion({
    required this.id,
    required this.materialId,
    required this.courseId,
    required this.courseCode,
    required this.professor,
    required this.semester,
    required this.examType,
    required this.questionType,
    required this.topics,
    required this.text,
    required this.orderIndex,
    required this.hasSolution,
    required this.createdAt,
  });

  final String id;
  final String materialId;
  final String courseId;
  final String courseCode;
  final String professor;
  final String semester;
  final String examType;
  final String questionType;
  final List<String> topics;
  final String text;
  final int orderIndex;
  final bool hasSolution;
  final DateTime createdAt;

  factory ParsedQuestion.fromMap(String id, Map<String, dynamic> data) {
    return ParsedQuestion(
      id: id,
      materialId: data['materialId'] as String? ?? '',
      courseId: data['courseId'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      professor: data['professor'] as String? ?? '',
      semester: data['semester'] as String? ?? '',
      examType: data['examType'] as String? ?? '',
      questionType: data['questionType'] as String? ?? 'General',
      topics: (data['topics'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      text: data['text'] as String? ?? '',
      orderIndex: (data['orderIndex'] as num?)?.toInt() ?? 0,
      hasSolution: data['hasSolution'] as bool? ?? false,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'materialId': materialId,
        'courseId': courseId,
        'courseCode': courseCode,
        'professor': professor,
        'semester': semester,
        'examType': examType,
        'questionType': questionType,
        'topics': topics,
        'text': text,
        'orderIndex': orderIndex,
        'hasSolution': hasSolution,
        'createdAt': createdAt.toIso8601String(),
      };
}
