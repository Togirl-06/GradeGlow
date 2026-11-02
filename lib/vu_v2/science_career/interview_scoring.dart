/// Evidence-based scoring for the Science & Tech interview room.
///
/// Every dimension starts at 1 (out of 5) and rises only for evidence in the
/// student's own words: the role's key concepts, reasoning connectors, concrete
/// steps, and a clear, complete answer. Length alone never passes.
library;

class InterviewAnswerScore {
  const InterviewAnswerScore({
    required this.technical,
    required this.reasoning,
    required this.problemSolving,
    required this.communication,
    required this.keywordsUsed,
    required this.notes,
  });

  final int technical;
  final int reasoning;
  final int problemSolving;
  final int communication;
  final Set<String> keywordsUsed;
  final List<String> notes;
}

class InterviewVerdict {
  const InterviewVerdict({required this.passed, required this.scores, required this.feedback});
  final bool passed;
  final Map<String, int> scores;
  final String feedback;
}

abstract final class ScienceInterviewScoring {
  static const List<String> _reasoning = <String>[
    'because', 'so that', 'therefore', 'which means', 'since', 'as a result', 'if ', 'otherwise', 'trade-off', 'tradeoff', 'instead',
  ];
  static const List<String> _steps = <String>[
    'first', 'then', 'next', 'finally', 'reproduce', 'isolate', 'measure', 'verify', 'check', 'compare', 'test', 'log', 'monitor', 'rollback', 'review', 'document',
  ];

  static int _words(String t) => t.trim().isEmpty ? 0 : t.trim().split(RegExp(r'\s+')).length;

  static bool _has(String lower, String k) {
    final String kk = k.toLowerCase().trim();
    if (kk.isEmpty) return false;
    if (RegExp(r'^[a-z0-9]+$').hasMatch(kk)) {
      return RegExp('\\b${RegExp.escape(kk)}\\w*').hasMatch(lower);
    }
    return lower.contains(kk);
  }

  /// Scores one answer (0–3 points per dimension; added to the base of 1).
  static InterviewAnswerScore scoreAnswer(String answer, List<String> keywords) {
    final String lower = answer.toLowerCase();
    final int words = _words(answer);
    final Set<String> used = <String>{for (final String k in keywords) if (_has(lower, k)) k};
    final int reasons = _reasoning.where((String r) => lower.contains(r)).length;
    final int steps = _steps.where((String s) => _has(lower, s.trim())).length;
    final List<String> notes = <String>[];

    final int technical = used.length >= 3 ? 3 : used.length;
    if (used.isEmpty) notes.add('Use the concepts this role is about (${keywords.take(3).join(', ')}).');
    final int reasoning = reasons >= 3 ? 3 : reasons;
    if (reasons == 0) notes.add('Explain why: connect your choices with "because" or "so that".');
    final int problem = steps >= 4 ? 3 : (steps >= 2 ? 2 : steps);
    if (steps < 2) notes.add('Walk through concrete steps (first…, then…, verify…).');
    int comm;
    if (words < 12) {
      comm = 0;
      notes.add('Give a complete answer (at least a few sentences).');
    } else if (words <= 160) {
      comm = words >= 25 ? 2 : 1;
      if (RegExp(r'[.!?]').allMatches(answer).length >= 2) comm++;
    } else {
      comm = 1;
      notes.add('Tighten it: aim for under 160 words.');
    }
    return InterviewAnswerScore(
      technical: technical,
      reasoning: reasoning,
      problemSolving: problem,
      communication: comm.clamp(0, 3),
      keywordsUsed: used,
      notes: notes,
    );
  }

  /// Combines all answers into the four interview scores (1–5) and a decision.
  static InterviewVerdict decide(List<String> answers, List<String> keywords) {
    final List<InterviewAnswerScore> s = <InterviewAnswerScore>[for (final String a in answers) scoreAnswer(a, keywords)];
    int avgOf(int Function(InterviewAnswerScore) f) {
      if (s.isEmpty) return 1;
      final double mean = s.map(f).reduce((int a, int b) => a + b) / s.length;
      return (1 + (mean / 3) * 4).round().clamp(1, 5);
    }

    final Map<String, int> scores = <String, int>{
      'Technical correctness': avgOf((InterviewAnswerScore x) => x.technical),
      'Communication': avgOf((InterviewAnswerScore x) => x.communication),
      'Reasoning': avgOf((InterviewAnswerScore x) => x.reasoning),
      'Problem solving': avgOf((InterviewAnswerScore x) => x.problemSolving),
    };
    final Set<String> covered = <String>{for (final InterviewAnswerScore x in s) ...x.keywordsUsed};
    final double avg = scores.values.reduce((int a, int b) => a + b) / scores.length;
    final bool passed = avg >= 3 && covered.length >= 2 && scores['Technical correctness']! >= 3;
    final List<String> tips = <String>{for (final InterviewAnswerScore x in s) ...x.notes}.take(3).toList();
    final String feedback = passed
        ? 'Strong interview: you used ${covered.length} key concepts and explained your reasoning.'
        : (tips.isEmpty ? 'Close. Add more role-specific detail.' : tips.join(' '));
    return InterviewVerdict(passed: passed, scores: scores, feedback: feedback);
  }
}
