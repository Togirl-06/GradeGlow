/// Structured textbook chapter + assessment for Virtual University V2.
class VuV2TextbookSection {
  const VuV2TextbookSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class VuV2Mcq {
  const VuV2Mcq({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    this.kind = VuV2QuestionKind.multipleChoice,
    this.shortAnswerKey,
  });

  final String id;
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String explanation;
  final VuV2QuestionKind kind;
  /// For short-answer questions — accepted lowercase keywords.
  final List<String>? shortAnswerKey;
}

enum VuV2QuestionKind { multipleChoice, trueFalse, shortAnswer }


class VuV2TopicPackage {
  const VuV2TopicPackage({
    required this.subjectId,
    required this.facultyTitle,
    required this.courseTitle,
    required this.trackTitle,
    required this.topicTitle,
    required this.sections,
    required this.topicQuiz,
  });

  final String subjectId;
  final String facultyTitle;
  final String courseTitle;
  final String trackTitle;
  final String topicTitle;
  final List<VuV2TextbookSection> sections;
  final List<VuV2Mcq> topicQuiz;

  String get readingTimeLabel {
    final int words = sections.fold<int>(
      0,
      (int n, VuV2TextbookSection s) =>
          n + s.title.split(RegExp(r'\s+')).length + s.body.split(RegExp(r'\s+')).length,
    );
    final int minutes = (words / 180).ceil().clamp(8, 45);
    return '~$minutes min read';
  }
}

class VuV2ExamPackage {
  const VuV2ExamPackage({
    required this.courseTitle,
    required this.facultyTitle,
    required this.questions,
    this.passPercent = 70,
  });

  final String courseTitle;
  final String facultyTitle;
  final List<VuV2Mcq> questions;
  final int passPercent;

  int get questionCount => questions.length;
}
