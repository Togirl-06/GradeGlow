import 'leetcode_problem.dart';
import 'cs_w3s_topic.dart';

export 'cs_w3s_topic.dart' show CsW3sQuiz;

typedef CsBigOQuiz = CsW3sQuiz;

/// W3Schools-style Big-O lesson: micro-lesson → example → try it → quizzes.
class CsBigOLesson {
  const CsBigOLesson({
    required this.id,
    required this.title,
    required this.track,
    required this.lesson,
    required this.example,
    required this.tryIt,
    this.quizzes = const <CsW3sQuiz>[],
  });

  final String id;
  final String title;
  final String track;
  final CsW3sLesson lesson;
  final CsW3sExample example;
  final CsW3sTryIt tryIt;
  final List<CsW3sQuiz> quizzes;

  /// Adapter so we can reuse [CsLessonPanel] and language syntax helpers.
  CsW3sTopic asW3sTopic() {
    return CsW3sTopic(
      id: id,
      title: title,
      track: track,
      lesson: lesson,
      example: example,
      tryIt: tryIt,
      easy: _placeholderProblem,
      medium: _placeholderProblem,
      hard: _placeholderProblem,
      quizzes: quizzes,
    );
  }

  static const LeetcodeProblem _placeholderProblem = LeetcodeProblem(
    id: '_bigo_placeholder',
    title: 'Placeholder',
    slug: 'bigo-placeholder',
    difficulty: 'Easy',
    description: '',
    functionName: 'solve',
    examples: <LeetcodeExample>[],
    constraints: <String>[],
    tags: <String>[],
  );
}
