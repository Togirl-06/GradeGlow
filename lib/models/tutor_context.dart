import 'parsed_question.dart';

/// Course / exam context for context-aware AI tutor.
class TutorContext {
  const TutorContext({
    this.courseCode = '',
    this.professor = '',
    this.examType = '',
    this.materialLabel = '',
    this.questions = const <ParsedQuestion>[],
  });

  final String courseCode;
  final String professor;
  final String examType;
  final String materialLabel;
  final List<ParsedQuestion> questions;

  bool get hasContext => courseCode.isNotEmpty || questions.isNotEmpty;

  String get displayLabel {
    if (courseCode.isEmpty) return 'No course selected';
    final String exam = examType.isNotEmpty ? ' · $examType' : '';
    return '$courseCode$exam';
  }

  ParsedQuestion? questionAtIndex(int oneBased) {
    if (oneBased < 1 || oneBased > questions.length) return null;
    return questions[oneBased - 1];
  }

  String toSystemPrompt() {
    if (!hasContext) return '';
    final StringBuffer buffer = StringBuffer()
      ..writeln('The student is studying: ${courseCode.isNotEmpty ? courseCode : "a course"}.');
    if (professor.isNotEmpty) buffer.writeln('Professor: $professor');
    if (examType.isNotEmpty) buffer.writeln('Exam: $examType');
    if (materialLabel.isNotEmpty) buffer.writeln('Material: $materialLabel');
    if (questions.isNotEmpty) {
      buffer.writeln('Exam questions (use these when they say "Q3" or "question 2"):');
      for (int i = 0; i < questions.length; i++) {
        buffer.writeln('Q${i + 1}: ${questions[i].text}');
      }
    }
    return buffer.toString().trim();
  }

  TutorContext copyWith({
    String? courseCode,
    String? professor,
    String? examType,
    String? materialLabel,
    List<ParsedQuestion>? questions,
  }) {
    return TutorContext(
      courseCode: courseCode ?? this.courseCode,
      professor: professor ?? this.professor,
      examType: examType ?? this.examType,
      materialLabel: materialLabel ?? this.materialLabel,
      questions: questions ?? this.questions,
    );
  }
}
