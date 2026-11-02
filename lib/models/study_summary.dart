import 'summary_categories.dart';

class StudySummary {
  const StudySummary({
    required this.id,
    required this.title,
    required this.cheatSheet,
    required this.keyConcepts,
    required this.createdAt,
    this.category = SummarySubjects.defaultSubject,
    this.courseCode = '',
    this.courseId = '',
    this.sourceText = '',
    this.flashcards = const <Map<String, String>>[],
    this.quizQuestions = const <Map<String, dynamic>>[],
  });

  final String id;
  final String title;
  final String cheatSheet;
  final List<String> keyConcepts;
  final DateTime createdAt;
  final String category;
  final String courseCode;
  final String courseId;
  /// Original extracted text/transcript used to build notes (for regenerate).
  final String sourceText;
  final List<Map<String, String>> flashcards;
  final List<Map<String, dynamic>> quizQuestions;

  StudySummary copyWith({String? category, String? title, String? courseCode, String? courseId}) {
    return StudySummary(
      id: id,
      title: title ?? this.title,
      cheatSheet: cheatSheet,
      keyConcepts: keyConcepts,
      createdAt: createdAt,
      category: category ?? this.category,
      courseCode: courseCode ?? this.courseCode,
      courseId: courseId ?? this.courseId,
      sourceText: sourceText,
      flashcards: flashcards,
      quizQuestions: quizQuestions,
    );
  }

  StudySummary copyWithMaterials({
    List<Map<String, String>>? flashcards,
    List<Map<String, dynamic>>? quizQuestions,
    String? cheatSheet,
    List<String>? keyConcepts,
    String? sourceText,
  }) {
    return StudySummary(
      id: id,
      title: title,
      cheatSheet: cheatSheet ?? this.cheatSheet,
      keyConcepts: keyConcepts ?? this.keyConcepts,
      createdAt: createdAt,
      category: category,
      courseCode: courseCode,
      courseId: courseId,
      sourceText: sourceText ?? this.sourceText,
      flashcards: flashcards ?? this.flashcards,
      quizQuestions: quizQuestions ?? this.quizQuestions,
    );
  }

  factory StudySummary.fromMap(String id, Map<String, dynamic> data) {
    final List<Map<String, String>> cards = <Map<String, String>>[];
    final dynamic rawCards = data['flashcards'];
    if (rawCards is List) {
      for (final dynamic item in rawCards) {
        if (item is Map) {
          cards.add(<String, String>{
            'front': item['front']?.toString() ?? '',
            'back': item['back']?.toString() ?? '',
          });
        }
      }
    }

    final List<Map<String, dynamic>> quizzes = <Map<String, dynamic>>[];
    final dynamic rawQuiz = data['quizQuestions'];
    if (rawQuiz is List) {
      for (final dynamic item in rawQuiz) {
        if (item is Map) {
          quizzes.add(item.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)));
        }
      }
    }

    return StudySummary(
      id: id,
      title: data['title'] as String? ?? 'Summary',
      cheatSheet: data['cheatSheet'] as String? ?? '',
      keyConcepts: (data['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      category: data['category'] as String? ?? SummarySubjects.defaultSubject,
      courseCode: data['courseCode'] as String? ?? '',
      courseId: data['courseId'] as String? ?? '',
      sourceText: data['sourceText'] as String? ?? '',
      flashcards: cards,
      quizQuestions: quizzes,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'cheatSheet': cheatSheet,
        'keyConcepts': keyConcepts,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        if (courseCode.isNotEmpty) 'courseCode': courseCode,
        if (courseId.isNotEmpty) 'courseId': courseId,
        if (sourceText.isNotEmpty) 'sourceText': sourceText,
        if (flashcards.isNotEmpty) 'flashcards': flashcards,
        if (quizQuestions.isNotEmpty) 'quizQuestions': quizQuestions,
      };
}
