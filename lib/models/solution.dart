class QuestionSolution {
  const QuestionSolution({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.authorName,
    required this.stepByStep,
    required this.finalAnswer,
    required this.upvotes,
    required this.downvotes,
    required this.verified,
    required this.createdAt,
  });

  final String id;
  final String questionId;
  final String authorId;
  final String authorName;
  final String stepByStep;
  final String finalAnswer;
  final int upvotes;
  final int downvotes;
  final bool verified;
  final DateTime createdAt;

  int get score => upvotes - downvotes;

  factory QuestionSolution.fromMap(String id, Map<String, dynamic> data) {
    return QuestionSolution(
      id: id,
      questionId: data['questionId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      stepByStep: data['stepByStep'] as String? ?? '',
      finalAnswer: data['finalAnswer'] as String? ?? '',
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (data['downvotes'] as num?)?.toInt() ?? 0,
      verified: data['verified'] as bool? ?? false,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'questionId': questionId,
        'authorId': authorId,
        'authorName': authorName,
        'stepByStep': stepByStep,
        'finalAnswer': finalAnswer,
        'upvotes': upvotes,
        'downvotes': downvotes,
        'verified': verified,
        'createdAt': createdAt.toIso8601String(),
      };
}
