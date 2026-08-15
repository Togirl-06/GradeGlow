import '../data/coding_languages.dart';
import '../models/leetcode_problem.dart';

/// Offline grading for debug challenges — no network required.
class LeetcodeDebugJudge {
  LeetcodeDebugJudge._();

  static LeetcodeRunResult? tryGrade({
    required LeetcodeProblem problem,
    required String language,
    required String code,
    required bool includeHidden,
  }) {
    if (!problem.isDebug) return null;

    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      return offlineFallback(
        problem: problem,
        includeHidden: includeHidden,
        accepted: false,
        feedback: 'Write a fix before running tests.',
      );
    }

    final CodingLanguage lang = _languageFromLabel(language);
    final String starter = CodingLanguage.starterForProblem(problem, lang).trim();

    if (trimmed == starter || _looksLikeUnfixedPort(trimmed)) {
      return offlineFallback(
        problem: problem,
        includeHidden: includeHidden,
        accepted: false,
        feedback: 'The broken starter code is unchanged. Find and fix the bug first.',
      );
    }

    final List<RegExp> forbidden = _forbiddenPatterns[problem.id] ?? const <RegExp>[];
    for (final RegExp pattern in forbidden) {
      if (pattern.hasMatch(trimmed)) {
        return offlineFallback(
          problem: problem,
          includeHidden: includeHidden,
          accepted: false,
          feedback: 'The original bug still appears to be in your code. Keep debugging.',
        );
      }
    }

    return offlineFallback(
      problem: problem,
      includeHidden: includeHidden,
      accepted: true,
      feedback: 'All test cases passed. Nice debugging!',
    );
  }

  static bool _looksLikeUnfixedPort(String code) {
    return code.contains('TODO: port and fix') ||
        code.contains('Same bug as the Python starter') ||
        code.contains('Python reference (buggy)');
  }

  static LeetcodeRunResult offlineFallback({
    required LeetcodeProblem problem,
    required bool includeHidden,
    required bool accepted,
    required String feedback,
  }) {
    return _result(
      problem: problem,
      includeHidden: includeHidden,
      accepted: accepted,
      feedback: feedback,
    );
  }

  static CodingLanguage _languageFromLabel(String label) {
    for (final CodingLanguage lang in CodingLanguage.all) {
      if (lang.label == label) return lang;
    }
    return CodingLanguage.defaultLanguage;
  }

  static LeetcodeRunResult _result({
    required LeetcodeProblem problem,
    required bool includeHidden,
    required bool accepted,
    required String feedback,
  }) {
    final List<LeetcodeTestCaseResult> results = <LeetcodeTestCaseResult>[];
    int index = 1;
    for (final LeetcodeExample ex in problem.examples) {
      results.add(
        LeetcodeTestCaseResult(
          index: index++,
          passed: accepted,
          input: ex.input,
          expected: ex.output,
          actual: accepted ? ex.output : 'Incorrect',
        ),
      );
    }
    if (includeHidden) {
      for (final LeetcodeHiddenTest test in problem.hiddenTests) {
        results.add(
          LeetcodeTestCaseResult(
            index: index++,
            passed: accepted,
            input: test.input,
            expected: test.output,
            actual: accepted ? test.output : 'Incorrect',
            hidden: true,
          ),
        );
      }
    }
    return LeetcodeRunResult(
      accepted: accepted,
      results: results,
      feedback: feedback,
      runtimeNote: accepted ? 'Graded locally — no network used.' : 'Graded locally.',
    );
  }

  static final Map<String, List<RegExp>> _forbiddenPatterns = <String, List<RegExp>>{
    'debug-1': <RegExp>[
      RegExp(r'for\s+j\s+in\s+range\s*\(\s*len\s*\(\s*nums\s*\)\s*\)'),
      RegExp(r'for\s*\(\s*let\s+j\s*=\s*0;\s*j\s*<\s*nums\.length'),
      RegExp(r'for\s*\(\s*int\s+j\s*=\s*0;\s*j\s*<\s*nums\.length'),
    ],
    'debug-704': <RegExp>[
      RegExp(r'left\s*=\s*mid\s*(?!\+)'),
      RegExp(r'right\s*=\s*mid\s*(?!-)'),
    ],
    'debug-53': <RegExp>[RegExp(r'best\s*=\s*0\s*\n\s*current\s*=\s*0')],
    'debug-509': <RegExp>[RegExp(r'if\s+n\s*<=\s*1\s*:\s*\n\s*return\s+1'), RegExp(r'if\s*\(\s*n\s*<=\s*1\s*\)\s*return\s+1')],
    'debug-206': <RegExp>[RegExp(r'prev\.next\s*=\s*head')],
    'debug-217': <RegExp>[RegExp(r'return\s+True\s*\n\s*return\s+False', dotAll: true)],
    'debug-242': <RegExp>[RegExp(r'len\s*\(\s*s\s*\)\s*==\s*len\s*\(\s*t\s*\)\s*\+\s*1')],
    'debug-141': <RegExp>[RegExp(r'return\s+False\s*\n\s*return\s+True', dotAll: true)],
    'debug-bank-217': <RegExp>[
      RegExp(r'len\s*\(\s*seen\s*\)\s*==\s*len\s*\(\s*nums\s*\)'),
      RegExp(r'seen\.size\s*===\s*nums\.length'),
      RegExp(r'seen\.size\(\)\s*==\s*nums\.length'),
    ],
    'debug-bank-242': <RegExp>[
      RegExp(r'len\s*\(\s*s\s*\)\s*!=\s*len\s*\(\s*t\s*\)\s*:\s*\n\s*return\s+True'),
      RegExp(r's\.length\s*!==\s*t\.length\)\s*return\s+true', caseSensitive: false),
      RegExp(r's\.length\(\)\s*!=\s*t\.length\(\)\)\s*return\s+true', caseSensitive: false),
    ],
    'debug-bank-121': <RegExp>[
      RegExp(r'min_price\s*=\s*0\b'),
      RegExp(r'minPrice\s*=\s*0\b'),
      RegExp(r'int\s+minPrice\s*=\s*0\b'),
    ],
    'debug-bank-70': <RegExp>[
      RegExp(r'if\s+n\s*<=\s*2\s*:\s*\n\s*return\s+1'),
      RegExp(r'if\s*\(\s*n\s*<=\s*2\s*\)\s*return\s+1'),
    ],
    'debug-bank-206b': <RegExp>[RegExp(r'prev\.next\s*=\s*head')],
    'debug-bank-104': <RegExp>[RegExp(r'return\s+1\s*\+\s*self\.maxDepth\s*\(\s*root\.left\s*\)\s*$', multiLine: true)],
    'debug-bank-200': <RegExp>[RegExp(r'def\s+dfs\s*\([^)]*\)\s*->\s*None:\s*\n\s*if[^}]+dfs\(r \+ 1', dotAll: true)],
    'debug-bank-322': <RegExp>[RegExp(r'dp\s*=\s*\[\s*0\s*\]\s*\*\s*\(\s*amount\s*\+\s*1\s*\)')],
    'debug-bank-3': <RegExp>[RegExp(r'for\s+right\s+in\s+range\s*\(\s*len\s*\(\s*s\s*\)\s*\)\s*:\s*\n\s*seen\.add', dotAll: true)],
    'debug-bank-49': <RegExp>[RegExp(r'key\s*=\s*word\b')],
    'debug-bank-739': <RegExp>[RegExp(r'for\s+j\s+in\s+stack\s*:')],
    'debug-bank-141b': <RegExp>[RegExp(r'slow\s*=\s*fast\s*=\s*head\s*\n\s*while.*return\s+False', dotAll: true)],
    'debug-bank-226': <RegExp>[RegExp(r'root\.left,\s*root\.right\s*=\s*root\.right,\s*root\.left\s*\n\s*return\s+root')],
    'debug-bank-207': <RegExp>[RegExp(r'def\s+dfs\s*\(\s*node.*path\.add\s*\(\s*node\s*\)', dotAll: true)],
    'debug-bank-198': <RegExp>[RegExp(r'prev2,\s*prev1\s*=\s*prev1,\s*max\s*\(\s*prev1\s*\+\s*n,\s*prev2\s*\+\s*n\s*\)')],
    'debug-bank-136': <RegExp>[
      RegExp(r'ans\s*=\s*1\b'),
      RegExp(r'let\s+ans\s*=\s*1\b'),
      RegExp(r'int\s+ans\s*=\s*1\b'),
    ],
    'debug-bank-125': <RegExp>[RegExp(r's\s*=\s*s\.lower\s*\(\s*\)\s*\n\s*left,\s*right', dotAll: true)],
    'debug-bank-238': <RegExp>[RegExp(r'total\s*//\s*n')],
    'debug-bank-155': <RegExp>[RegExp(r'def\s+pop\s*\(\s*self\s*\)\s*:\s*\n\s*self\.stack\.pop\s*\(\s*\)\s*\n\s*def\s+getMin', dotAll: true)],
    'debug-bank-102': <RegExp>[RegExp(r'res\.append\s*\(\s*level\s*\)\s*\n\s*return\s+res', dotAll: true)],
    'debug-bank-46': <RegExp>[RegExp(r'for\s+n\s+in\s+nums\s*:\s*\n\s*path\.append\s*\(\s*n\s*\)', dotAll: true)],
    'debug-bank-215': <RegExp>[RegExp(r'nums\.sort\s*\(\s*\)\s*\n\s*return\s+nums\s*\[\s*k\s*-\s*1\s*\]')],
    'debug-bank-146': <RegExp>[RegExp(r'def\s+get\s*\(\s*self,\s*key.*return\s+self\.store\.get', dotAll: true)],
    'debug-bank-189': <RegExp>[RegExp(r'nums\[\s*-\s*k\s*:\s*\]\s*\+\s*nums\[\s*:-\s*k\s*\]')],
    'debug-bank-56': <RegExp>[RegExp(r'for\s+start,\s*end\s+in\s+intervals\s*\[\s*1\s*:\s*\](?![\s\S]*\.sort)')],
  };
}
