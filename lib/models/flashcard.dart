class Flashcard {
  const Flashcard({
    required this.id,
    required this.questionId,
    required this.front,
    required this.back,
    required this.courseCode,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReviewAt,
    required this.createdAt,
  });

  final String id;
  final String questionId;
  final String front;
  final String back;
  final String courseCode;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReviewAt;
  final DateTime createdAt;

  bool get isDue => !nextReviewAt.isAfter(DateTime.now());

  factory Flashcard.fromMap(String id, Map<String, dynamic> data) {
    return Flashcard(
      id: id,
      questionId: data['questionId'] as String? ?? '',
      front: data['front'] as String? ?? '',
      back: data['back'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      easeFactor: (data['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 0,
      repetitions: (data['repetitions'] as num?)?.toInt() ?? 0,
      nextReviewAt: DateTime.tryParse(data['nextReviewAt'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'questionId': questionId,
        'front': front,
        'back': back,
        'courseCode': courseCode,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'repetitions': repetitions,
        'nextReviewAt': nextReviewAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
