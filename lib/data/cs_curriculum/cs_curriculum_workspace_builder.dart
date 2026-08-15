import '../../models/cs_curriculum.dart';
import '../../models/cs_w3s_topic.dart';
import '../../models/leetcode_problem.dart';
import '../../models/practice_lab_question.dart';
import '../coding_languages.dart';
import '../leetcode_problem_bank.dart';
import '../cs_curriculum/cs_curriculum_practice_bank.dart';
import '../cs_curriculum/cs_curriculum_quiz_bank.dart';
import 'cs_curriculum_catalog.dart';

/// Builds hybrid workspace topics from curriculum lessons.
class CsCurriculumWorkspaceBuilder {
  CsCurriculumWorkspaceBuilder._();

  static CsW3sTopic? resolveTopic(String topicId) {
    final CsCurriculumTopic? curriculum = CsCurriculumCatalog.topicById(topicId);
    if (curriculum == null) return null;
    if (curriculum.languageId == 'algorithms') {
      return _fromAlgorithms(CsCurriculumCatalog.algorithmsTopicById(topicId)!);
    }
    return _fromLanguageTopic(curriculum);
  }

  static CsW3sTopic _fromLanguageTopic(CsCurriculumTopic topic) {
    final CsCurriculumLanguage? lang = CsCurriculumCatalog.languageById(topic.languageId);
    final String langLabel = lang?.label ?? topic.languageId;
    final String codeLang = lang?.codingLanguageId ?? 'python3';
    final String starter = _starterFor(codeLang, topic.title, lang?.isWeb ?? false);

    return CsW3sTopic(
      id: topic.id,
      title: topic.title,
      track: langLabel,
      lesson: CsW3sLesson(
        whatItDoes: 'Learn ${topic.title} in $langLabel.',
        whenToUse: 'Use this when building real $langLabel projects and writing clean, maintainable code.',
        keyIdea: 'Master ${topic.title} with a short lesson, a hands-on exercise, then coding challenges.',
        bullets: _lessonBullets(topic.title, langLabel),
      ),
      example: CsW3sExample(
        input: 'Concept: ${topic.title}',
        output: 'Working ${langLabel.toLowerCase()} example',
        steps: 'Read the key idea → run Try It Yourself → solve Easy, Medium, and Hard problems.',
      ),
      tryIt: CsW3sTryIt(
        task: 'Practice ${topic.title}: write a small $langLabel snippet that demonstrates the concept.',
        starterCode: starter,
        runContext: 'Your code should demonstrate ${topic.title} correctly.',
      ),
      easy: _problem(topic, 'Easy', codeLang, preferDebug: false),
      medium: _problem(topic, 'Medium', codeLang, preferDebug: false),
      hard: _problem(topic, 'Hard', codeLang, preferDebug: false),
      quizzes: CsCurriculumQuizBank.forTopic(topic: topic, langLabel: langLabel, codeLang: codeLang),
    );
  }

  static CsW3sTopic _fromAlgorithms(CsAlgorithmsTopic topic) {
    return CsW3sTopic(
      id: topic.id,
      title: topic.title,
      track: 'Problem Solving & Algorithms',
      lesson: CsW3sLesson(
        whatItDoes: 'Apply algorithmic thinking to ${topic.title.toLowerCase()}.',
        whenToUse: 'Interview prep, competitive programming, and optimizing real applications.',
        keyIdea: 'Start with brute force, then optimize time and space complexity.',
        bullets: <String>[
          'Read the problem carefully and identify inputs/outputs',
          'Choose a data structure that fits the constraints',
          'Write pseudocode before coding',
          'Test edge cases: empty input, single element, duplicates',
          'Analyze Big-O before you submit',
        ],
      ),
      example: CsW3sExample(
        input: 'Sample test case',
        output: 'Expected result',
        steps: 'Trace through your approach on paper, then implement and submit.',
      ),
      tryIt: CsW3sTryIt(
        task: 'Sketch your approach for a ${topic.title.toLowerCase()} problem in comments, then implement.',
        starterCode: CodingLanguage.defaultLanguage.starter,
        runContext: 'Demonstrate the core pattern for ${topic.title}.',
      ),
      easy: _algoProblem(topic, 'Easy'),
      medium: _algoProblem(topic, 'Medium'),
      hard: _algoProblem(topic, 'Hard'),
      quizzes: CsCurriculumQuizBank.forTopic(
        topic: CsCurriculumTopic(
          id: topic.id,
          languageId: 'algorithms',
          title: topic.title,
          order: topic.order,
          level: topic.level,
        ),
        langLabel: 'Algorithms',
        codeLang: 'python3',
      ),
    );
  }

  static LeetcodeProblem _algoProblem(CsAlgorithmsTopic topic, String difficulty) {
    final List<PracticeLabQuestion> problems = LeetcodeProblemBank.buildForTopic(
      topicId: topic.problemBankKey,
      topicName: topic.title,
      difficulty: difficulty,
      count: 1,
    );
    if (problems.isNotEmpty && problems.first.leetcode != null) {
      return problems.first.leetcode!;
    }
    return _fallbackAlgoProblem(topic.title, difficulty);
  }

  static LeetcodeProblem _fallbackAlgoProblem(String title, String difficulty) {
    final String slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return LeetcodeProblem(
      id: 'algo-$slug-$difficulty',
      title: '$title Challenge',
      slug: 'algo-$slug',
      difficulty: difficulty,
      description: 'Apply **$title** from your algorithms lecture. Use the pattern taught in class.',
      functionName: 'solve',
      examples: <LeetcodeExample>[
        const LeetcodeExample(input: 'Sample input', output: 'Expected output'),
      ],
      constraints: <String>['Use concepts from the $title lecture'],
      tags: <String>['Algorithms', 'Lecture practice'],
    );
  }

  static LeetcodeProblem _problem(
    CsCurriculumTopic topic,
    String difficulty,
    String codeLang, {
    required bool preferDebug,
  }) {
    final CsCurriculumLanguage? lang = CsCurriculumCatalog.languageById(topic.languageId);
    return CsCurriculumPracticeBank.forTopic(
      topic: topic,
      difficulty: difficulty,
      codeLang: codeLang,
      langLabel: lang?.label ?? topic.languageId,
      isWeb: lang?.isWeb ?? false,
    );
  }

  static List<String> _lessonBullets(String title, String lang) {
    return <String>[
      'Topic: $title',
      'Language: $lang',
      'Step 1: Read the key idea above',
      'Step 2: Study the example input/output',
      'Step 3: Complete Try It Yourself',
      'Step 4: Solve Easy → Medium → Hard problems',
    ];
  }

  static String _starterFor(String codeLang, String title, bool isWeb) {
    if (codeLang == 'html') {
      return '<!DOCTYPE html>\n<html>\n<head>\n  <title>$title</title>\n</head>\n<body>\n  <!-- Practice $title here -->\n</body>\n</html>\n';
    }
    if (codeLang == 'css') {
      return '/* Practice $title */\nbody {\n  font-family: sans-serif;\n}\n';
    }
    final CodingLanguage? lang = CodingLanguage.byId(codeLang);
    if (lang != null) return lang.starter;
    if (isWeb) {
      return '// Practice $title\nconsole.log("Hello");\n';
    }
    return CodingLanguage.defaultLanguage.starter;
  }
}
