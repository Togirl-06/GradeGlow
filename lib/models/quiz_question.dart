class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuizRecord {
  const QuizRecord({
    required this.id,
    required this.noteName,
    required this.questionCount,
    required this.createdAt,
  });

  final String id;
  final String noteName;
  final int questionCount;
  final DateTime createdAt;

  factory QuizRecord.fromMap(String id, Map<String, dynamic> data) {
    return QuizRecord(
      id: id,
      noteName: data['noteName'] as String? ?? 'Quiz',
      questionCount: (data['questionCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
