import 'leetcode_problem.dart';
import '../data/cs_w3s_multilang.dart';

/// W3Schools-style micro-lesson (bullets only, no lectures).
class CsW3sLesson {
  const CsW3sLesson({
    required this.whatItDoes,
    required this.whenToUse,
    required this.keyIdea,
    this.bullets = const <String>[],
  });

  final String whatItDoes;
  final String whenToUse;
  final String keyIdea;
  final List<String> bullets;
}

class CsW3sExample {
  const CsW3sExample({
    required this.input,
    required this.output,
    required this.steps,
  });

  final String input;
  final String output;
  final String steps;
}

class CsW3sTryIt {
  const CsW3sTryIt({
    required this.task,
    this.starterCode = '',
    this.runContext = '',
    this.startersByLanguage = const <String, String>{},
  });

  final String task;
  /// Legacy single-language fallback (Python).
  final String starterCode;
  final String runContext;
  final Map<String, String> startersByLanguage;

  String starterFor(String languageId) {
    if (startersByLanguage.containsKey(languageId)) {
      return startersByLanguage[languageId]!;
    }
    if (languageId == 'python' && startersByLanguage.containsKey('python3')) {
      return startersByLanguage['python3']!;
    }
    if (starterCode.isNotEmpty) return starterCode;
    final Iterable<String> values = startersByLanguage.values;
    return values.isEmpty ? '' : values.first;
  }
}

enum CsProblemTier { easy, medium, hard }

/// W3Schools-style multiple-choice exercise (code snippet + question + options).
class CsW3sQuiz {
  const CsW3sQuiz({
    required this.code,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String code;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// One topic: short lesson → example → try it → practice exercises.
class CsW3sTopic {
  const CsW3sTopic({
    required this.id,
    required this.title,
    required this.track,
    required this.lesson,
    required this.example,
    required this.tryIt,
    required this.easy,
    required this.medium,
    required this.hard,
    this.quizzes = const <CsW3sQuiz>[],
  });

  final String id;
  final String title;
  final String track;
  final CsW3sLesson lesson;
  final CsW3sExample example;
  final CsW3sTryIt tryIt;
  final LeetcodeProblem easy;
  final LeetcodeProblem medium;
  final LeetcodeProblem hard;
  final List<CsW3sQuiz> quizzes;

  LeetcodeProblem problemFor(CsProblemTier tier) => switch (tier) {
        CsProblemTier.easy => easy,
        CsProblemTier.medium => medium,
        CsProblemTier.hard => hard,
      };

  /// Language-specific syntax bullets (falls back to lesson.bullets).
  List<String> syntaxFor(String languageId) {
    final List<String> lang = CsW3sMultilang.syntaxBullets(id, languageId);
    if (lang.isNotEmpty) return lang;
    return lesson.bullets;
  }

  /// Language-specific Try It starter code.
  String tryItStarterFor(String languageId) {
    final String fromBank = CsW3sMultilang.tryItStarter(id, languageId);
    if (fromBank.isNotEmpty) return fromBank;
    return tryIt.starterFor(languageId);
  }
}

class CsW3sTrack {
  const CsW3sTrack({required this.name, required this.topicIds});

  final String name;
  final List<String> topicIds;
}
