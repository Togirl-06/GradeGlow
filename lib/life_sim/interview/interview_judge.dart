/// Scoring of interview answers: offline heuristic judge + AI judge interface.
library;

import '../careers/career_catalog.dart';
import '../employment/employers.dart';
import 'interview_questions.dart';

/// The seven dimensions from the product brief.
class InterviewDims {
  const InterviewDims._();

  static const String relevance = 'relevance';
  static const String communication = 'communication';
  static const String confidence = 'confidence';
  static const String problemSolving = 'problem_solving';
  static const String professionalism = 'professionalism';
  static const String clarity = 'clarity';
  static const String examples = 'examples';

  static const List<String> all = <String>[
    relevance, communication, confidence, problemSolving, professionalism, clarity, examples,
  ];

  static const Map<String, String> labels = <String, String>{
    relevance: 'Relevance',
    communication: 'Communication',
    confidence: 'Confidence',
    problemSolving: 'Problem-solving',
    professionalism: 'Professionalism',
    clarity: 'Clarity',
    examples: 'Examples & explanations',
  };

  /// What to do to improve each dimension.
  static const Map<String, String> advice = <String, String>{
    relevance: 'Answer the actual question and use the language of the role and the company.',
    communication: 'Aim for 40–120 words, joined with connectors like "because" and "as a result".',
    confidence: 'Own your achievements ("I led…", "I built…") and drop hedges like "maybe" or "I guess".',
    problemSolving: 'Show your steps: what you noticed, what you tried, why, and what happened.',
    professionalism: 'Keep a respectful, polished tone — no slang, no blaming others, and say thank you.',
    clarity: 'Use short, complete sentences and one idea at a time.',
    examples: 'Back every claim with a specific example and a measurable result.',
  };

  /// Weights for each question kind. Each map sums to 1.
  static Map<String, double> weightsFor(QuestionKind kind) {
    switch (kind) {
      case QuestionKind.technical:
        return const <String, double>{
          relevance: 0.30, communication: 0.08, confidence: 0.08, problemSolving: 0.26,
          professionalism: 0.06, clarity: 0.12, examples: 0.10,
        };
      case QuestionKind.opening:
        return const <String, double>{
          relevance: 0.20, communication: 0.18, confidence: 0.16, problemSolving: 0.04,
          professionalism: 0.14, clarity: 0.18, examples: 0.10,
        };
      case QuestionKind.motivation:
        return const <String, double>{
          relevance: 0.30, communication: 0.12, confidence: 0.12, problemSolving: 0.04,
          professionalism: 0.14, clarity: 0.12, examples: 0.16,
        };
      default:
        return const <String, double>{
          relevance: 0.18, communication: 0.12, confidence: 0.12, problemSolving: 0.18,
          professionalism: 0.12, clarity: 0.12, examples: 0.16,
        };
    }
  }
}

class InterviewContext {
  const InterviewContext({
    required this.question,
    required this.questionText,
    required this.answer,
    required this.employer,
    required this.career,
    required this.rank,
    this.isFollowUp = false,
    this.history = const <String>[],
  });

  final InterviewQuestion question;
  final String questionText;
  final String answer;
  final Employer employer;
  final CareerDef career;
  final int rank;
  final bool isFollowUp;

  /// Prior "Q: … / A: …" lines for context.
  final List<String> history;
}

class AnswerEvaluation {
  AnswerEvaluation({
    required this.scores,
    required this.comment,
    required this.reaction,
    required this.kind,
    this.followUp,
  });

  /// Dimension → 0..10.
  final Map<String, double> scores;

  /// Private coaching note shown in the end-of-interview report.
  final String comment;

  /// What the interviewer says out loud right after the answer.
  final String reaction;
  final QuestionKind kind;

  /// Set when the interviewer wants to probe further.
  final String? followUp;

  /// 0..100 weighted by question kind.
  double get overall {
    final Map<String, double> w = InterviewDims.weightsFor(kind);
    double sum = 0;
    w.forEach((String k, double weight) => sum += (scores[k] ?? 0) * weight);
    return (sum * 10).clamp(0, 100).toDouble();
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'scores': scores,
        'comment': comment,
        'reaction': reaction,
        'kind': kind.name,
        'followUp': followUp,
      };
}

abstract class InterviewJudge {
  Future<AnswerEvaluation> evaluate(InterviewContext ctx);
}

/// Deterministic judge used offline and as the fallback for the AI judge.
class HeuristicInterviewJudge implements InterviewJudge {
  const HeuristicInterviewJudge();

  static const List<String> _hedges = <String>[
    'maybe', 'i guess', 'kind of', 'sort of', 'not sure', 'probably', ' um ', ' uh ',
    "i don't know", 'i dont know', 'i think i', 'just ', 'hopefully', 'i suppose',
  ];
  static const List<String> _assertive = <String>[
    'i led', 'i built', 'i achieved', 'i decided', 'i am confident', "i'm confident",
    'i delivered', 'i completed', 'i took ownership', 'i created', 'i improved',
    'i managed', 'i organised', 'i organized', 'i solved', 'i will', 'i can',
  ];
  static const List<String> _slang = <String>[
    'gonna', 'wanna', 'dude', ' bro ', ' lol', ' idk', ' u ', ' ur ', ' nah', 'yeah', 'kinda',
    ' tbh', 'whatever', 'stuff like that',
  ];
  static const List<String> _profanity = <String>['damn', 'crap', 'shit', 'fuck', 'hell no', 'wtf'];
  static const List<String> _negative = <String>[
    'hate', 'stupid', 'idiot', 'boring', 'lazy boss', 'useless', 'sucks', 'worst',
  ];
  static const List<String> _polite = <String>[
    'thank', 'appreciate', 'opportunity', 'pleased', 'grateful', 'excited to', 'respect',
  ];
  static const List<String> _structure = <String>[
    'first', 'then', 'next', 'finally', 'after that', 'root cause', 'solution', 'fixed',
    'resolved', 'decided', 'analys', 'prioritis', 'prioritiz', 'plan', 'step', 'because',
    'so that', 'therefore', 'as a result',
  ];
  static const List<String> _exampleCues = <String>[
    'for example', 'for instance', 'when i', 'last year', 'at my', 'in my project',
    'one time', 'once ', 'during', '%', 'result', 'achieved', 'improved', 'reduced',
    'increased', 'saved', 'led to', 'a time',
  ];

  @override
  Future<AnswerEvaluation> evaluate(InterviewContext ctx) async => score(ctx);

  static List<String> _words(String s) => RegExp(r"[A-Za-z0-9'%]+")
      .allMatches(s)
      .map((RegExpMatch m) => m.group(0)!.toLowerCase())
      .toList();

  static int _count(String haystack, List<String> needles) {
    int n = 0;
    for (final String needle in needles) {
      if (haystack.contains(needle)) n++;
    }
    return n;
  }

  /// Synchronous scoring (also used directly by tests).
  AnswerEvaluation score(InterviewContext ctx) {
    final String raw = ctx.answer.trim();
    final String padded = ' ${raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')} ';
    final List<String> words = _words(raw);
    final int wc = words.length;

    if (wc == 0) {
      return AnswerEvaluation(
        scores: <String, double>{for (final String d in InterviewDims.all) d: 0},
        comment: 'No answer given. Always say something — even a short, structured answer beats silence.',
        reaction: "That's okay — let's move on.",
        kind: ctx.question.kind,
      );
    }

    final int sentences = RegExp(r'[.!?]+').allMatches(raw).length.clamp(1, 1000);
    final double avgSentence = wc / sentences;
    final double diversity = words.toSet().length / wc;

    // --- Relevance ------------------------------------------------------
    final int qHits = _count(padded, ctx.question.keywords);
    final int cHits = _count(padded, ctx.career.interviewKeywords);
    final int vHits = _count(padded, ctx.employer.values);
    final int needed = ctx.question.keywords.isEmpty ? 1 : (ctx.question.keywords.length / 3).ceil().clamp(1, 4);
    double relevance = 1.5 + (qHits / needed).clamp(0, 1.4) * 3.6;
    if (cHits >= 2) relevance += 1.5;
    if (cHits >= 4) relevance += 0.5;
    if (ctx.question.kind == QuestionKind.motivation) {
      relevance += vHits >= 1 ? 1.5 : 0;
      if (padded.contains(ctx.employer.name.toLowerCase().split(' ').first)) relevance += 1;
    } else if (vHits >= 1) {
      relevance += 0.5;
    }
    if (qHits == 0 && cHits == 0) relevance = relevance.clamp(0, 2.5);
    if (wc < 8) relevance = relevance.clamp(0, 3);

    // --- Communication --------------------------------------------------
    double communication;
    if (wc >= 40 && wc <= 150) {
      communication = 7.5;
    } else if (wc > 150 && wc <= 220) {
      communication = 6.5;
    } else if (wc > 220) {
      communication = 5;
    } else if (wc >= 20) {
      communication = 5.5;
    } else if (wc >= 10) {
      communication = 3.5;
    } else {
      communication = 2;
    }
    final int connectors = _count(padded, <String>[
      'because', 'so ', 'therefore', 'however', 'which ', 'as a result', 'and then', 'although',
    ]);
    communication += (connectors * 0.6).clamp(0, 1.5);
    if (sentences >= 3) communication += 0.8;

    // --- Confidence -----------------------------------------------------
    double confidence = 6;
    confidence -= (_count(padded, _hedges) * 1.1).clamp(0, 4.5);
    confidence += (_count(padded, _assertive) * 1.4).clamp(0, 3.5);
    final int iCount = words.where((String w) => w == 'i').length;
    if (iCount >= 2) confidence += 0.8;
    if (wc < 10) confidence -= 2;

    // --- Problem-solving ------------------------------------------------
    final int sHits = _count(padded, _structure);
    double problem = 2.5 + sHits * 1.0;
    if (ctx.question.kind == QuestionKind.technical) {
      problem += (qHits * 0.5).clamp(0, 2.5);
    }
    if (wc < 12) problem = problem.clamp(0, 3);

    // --- Professionalism ------------------------------------------------
    double prof = 8;
    prof -= _count(padded, _profanity) * 4;
    prof -= (_count(padded, _slang) * 1.0).clamp(0, 4);
    prof -= (_count(padded, _negative) * 2.0).clamp(0, 4);
    final int caps = RegExp(r'\b[A-Z]{3,}\b').allMatches(raw).length;
    if (caps >= 3) prof -= 1.5;
    prof += (_count(padded, _polite) * 0.7).clamp(0, 2);
    if (raw.contains('!!')) prof -= 1;

    // --- Clarity --------------------------------------------------------
    double clarity = 5;
    if (avgSentence >= 8 && avgSentence <= 26) {
      clarity += 2;
    } else if (avgSentence > 38) {
      clarity -= 1.5;
    }
    if (sentences >= 3 && sentences <= 10) clarity += 1;
    if (wc >= 30 && wc <= 170) clarity += 1;
    if (wc > 25 && !RegExp(r'[.!?]').hasMatch(raw)) clarity -= 2;
    if (diversity < 0.5 && wc > 20) clarity -= 1.5;
    if (wc < 15) clarity -= 2;

    // --- Examples -------------------------------------------------------
    double examples = 1 + _count(padded, _exampleCues) * 2.0;
    // Specific past actions ("fixed", "shipped", "reproduced") signal a real story.
    final int pastActions = words.where((String w) => w.length > 4 && w.endsWith('ed')).length;
    examples += (pastActions * 0.7).clamp(0, 3);
    if (RegExp(r'\d').hasMatch(raw)) examples += 1;
    if (wc < 15) examples = examples.clamp(0, 2.5);

    double c(double v) => double.parse(v.clamp(0, 10).toStringAsFixed(1));
    final Map<String, double> scores = <String, double>{
      InterviewDims.relevance: c(relevance),
      InterviewDims.communication: c(communication),
      InterviewDims.confidence: c(confidence),
      InterviewDims.problemSolving: c(problem),
      InterviewDims.professionalism: c(prof),
      InterviewDims.clarity: c(clarity),
      InterviewDims.examples: c(examples),
    };

    final AnswerEvaluation draft = AnswerEvaluation(
      scores: scores,
      comment: '',
      reaction: '',
      kind: ctx.question.kind,
    );
    final double overall = draft.overall;

    // Weakest dimension drives the private note.
    String weakest = InterviewDims.all.first;
    for (final String d in InterviewDims.all) {
      if ((scores[d] ?? 0) < (scores[weakest] ?? 0)) weakest = d;
    }
    final String comment = overall >= 75
        ? 'Strong answer. To polish further: ${InterviewDims.advice[weakest]}'
        : 'Weakest area — ${InterviewDims.labels[weakest]}: ${InterviewDims.advice[weakest]}';

    final bool wantsMore = !ctx.isFollowUp &&
        ((scores[InterviewDims.examples] ?? 0) < 4 || wc < 25) &&
        ctx.question.kind != QuestionKind.opening &&
        ctx.question.kind != QuestionKind.closing;

    return AnswerEvaluation(
      scores: scores,
      comment: comment,
      reaction: reactionFor(ctx.employer.interviewer.style, overall, wantsMore),
      kind: ctx.question.kind,
      followUp: wantsMore ? ctx.question.followUp : null,
    );
  }

  /// A natural spoken reaction matching the interviewer's style.
  static String reactionFor(String style, double overall, bool probing) {
    final int band = overall >= 75 ? 2 : (overall >= 52 ? 1 : 0);
    const Map<String, List<String>> lines = <String, List<String>>{
      'warm': <String>[
        "Mm, I'd have loved a little more detail there, but thank you.",
        "Thank you — that gives me a good picture.",
        "That's a really thoughtful answer, thank you for sharing it.",
      ],
      'direct': <String>[
        "That was thin. I need specifics.",
        "Okay. Noted.",
        "Good. That's the kind of answer I'm looking for.",
      ],
      'technical': <String>[
        "Hmm, that doesn't quite get to the core of it.",
        "Reasonable. I follow your thinking.",
        "Solid reasoning — I like how you structured that.",
      ],
    };
    final List<String> set = lines[style] ?? lines['warm']!;
    String r = set[band];
    if (probing) r = '$r Let me dig into that a little.';
    return r;
  }
}
