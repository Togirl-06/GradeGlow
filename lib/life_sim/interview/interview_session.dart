/// A playable interview: one question at a time, adaptive follow-ups, and a
/// final hiring decision with coaching feedback.
library;

import '../careers/career_catalog.dart';
import '../core/stable_random.dart';
import '../employment/employers.dart';
import '../employment/job_listing.dart';
import '../employment/qualifications.dart';
import 'interview_judge.dart';
import 'interview_questions.dart';

enum HireDecision { offer, waitlist, reject }

class InterviewTurn {
  const InterviewTurn({
    required this.questionIndex,
    required this.prompt,
    required this.answer,
    required this.evaluation,
    required this.isFollowUp,
  });

  final int questionIndex;
  final String prompt;
  final String answer;
  final AnswerEvaluation evaluation;
  final bool isFollowUp;
}

class InterviewResult {
  const InterviewResult({
    required this.interviewScore,
    required this.hiringScore,
    required this.offerThreshold,
    required this.decision,
    required this.dimensionAverages,
    required this.strengths,
    required this.improvements,
    required this.questionNotes,
    required this.closingLine,
    this.offerSalary,
    this.waitlistDays,
    this.waitlistWillOffer = false,
  });

  /// 0..100 from the answers (plus professionalism modifiers).
  final double interviewScore;

  /// Blend of interview and application match.
  final double hiringScore;
  final double offerThreshold;
  final HireDecision decision;
  final Map<String, double> dimensionAverages;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> questionNotes;
  final String closingLine;
  final double? offerSalary;
  final int? waitlistDays;
  final bool waitlistWillOffer;

  String get grade {
    if (interviewScore >= 85) return 'Outstanding';
    if (interviewScore >= 70) return 'Strong';
    if (interviewScore >= 55) return 'Decent';
    if (interviewScore >= 40) return 'Needs practice';
    return 'Weak';
  }
}

class InterviewSession {
  InterviewSession._({
    required this.listing,
    required this.qualifications,
    required this.matchScore,
    required this.judge,
    required this.practice,
    required this.seed,
    required List<InterviewQuestion> questions,
  }) : _questions = questions;

  factory InterviewSession.start({
    required JobListing listing,
    required PlayerQualifications qualifications,
    required InterviewJudge judge,
    double matchScore = 60,
    bool practice = false,
    String seed = 'interview',
  }) {
    return InterviewSession._(
      listing: listing,
      qualifications: qualifications,
      matchScore: matchScore,
      judge: judge,
      practice: practice,
      seed: seed,
      questions: InterviewQuestionBank.forRole(listing.careerId, listing.rank),
    );
  }

  static const int maxFollowUps = 2;

  final JobListing listing;
  final PlayerQualifications qualifications;
  final double matchScore;
  final InterviewJudge judge;
  final bool practice;
  final String seed;
  final List<InterviewQuestion> _questions;

  final List<InterviewTurn> turns = <InterviewTurn>[];
  int _index = 0;
  int _followUpsUsed = 0;
  String? _pendingFollowUp;

  Employer get employer => listing.employer;
  CareerDef get career => listing.career;
  InterviewerPersonaView get interviewer => InterviewerPersonaView(employer, practice);

  int get totalQuestions => _questions.length;
  int get questionNumber => (_index + 1).clamp(1, _questions.length);
  bool get finished => _index >= _questions.length;
  bool get isFollowUpPending => _pendingFollowUp != null;

  InterviewQuestion? get currentQuestion => finished ? null : _questions[_index];

  /// What the interviewer says now.
  String get currentPrompt {
    if (finished) return closingLine(null);
    if (_pendingFollowUp != null) return _pendingFollowUp!;
    return _questions[_index].render(employer: employer.name, role: listing.title);
  }

  String get greeting {
    final InterviewerPersona p = employer.interviewer;
    if (practice) {
      return "Hi, I'm ${p.name}, a career coach. This is practice — nothing here affects your applications. "
          "I'll interview you for ${listing.title} at ${employer.name}. Take your time.";
    }
    switch (p.style) {
      case 'direct':
        return "${p.name}, ${p.title}. Please sit. I have a few questions and limited time, so let's begin.";
      case 'technical':
        return "Hey, I'm ${p.name}, ${p.title}. Take a seat — this should feel like a conversation, "
            "with a couple of technical questions.";
      default:
        return "Welcome to ${employer.name}! I'm ${p.name}, ${p.title}. Please, have a seat — "
            "and relax, we just want to get to know you.";
    }
  }

  /// Submits the player's answer for the current prompt.
  Future<InterviewTurn> submit(String answer) async {
    if (finished) throw StateError('Interview already finished.');
    final bool isFollowUp = _pendingFollowUp != null;
    final InterviewQuestion q = _questions[_index];
    final String prompt = currentPrompt;
    final List<String> history = <String>[
      for (final InterviewTurn t in turns) 'Q: ${t.prompt}\nA: ${t.answer}',
    ];
    final AnswerEvaluation eval = await judge.evaluate(InterviewContext(
      question: q,
      questionText: prompt,
      answer: answer,
      employer: employer,
      career: career,
      rank: listing.rank,
      isFollowUp: isFollowUp,
      history: history,
    ));
    final InterviewTurn turn = InterviewTurn(
      questionIndex: _index,
      prompt: prompt,
      answer: answer,
      evaluation: eval,
      isFollowUp: isFollowUp,
    );
    turns.add(turn);

    if (!isFollowUp && eval.followUp != null && _followUpsUsed < maxFollowUps) {
      _followUpsUsed++;
      _pendingFollowUp = eval.followUp;
    } else {
      _pendingFollowUp = null;
      _index++;
    }
    return turn;
  }

  /// Per-question score (initial answer blended with its follow-up).
  List<double> _questionScores() {
    final List<double> out = <double>[];
    for (int i = 0; i < _questions.length; i++) {
      final List<InterviewTurn> ts = turns.where((InterviewTurn t) => t.questionIndex == i).toList();
      if (ts.isEmpty) continue;
      final double first = ts.first.evaluation.overall;
      if (ts.length > 1) {
        out.add(first * 0.6 + ts.last.evaluation.overall * 0.4);
      } else {
        out.add(first);
      }
    }
    return out;
  }

  String closingLine(HireDecision? d) {
    final InterviewerPersona p = employer.interviewer;
    switch (d) {
      case HireDecision.offer:
        return "Thank you — I really enjoyed this. I'd like to make you an offer.";
      case HireDecision.waitlist:
        return "Thank you. You interviewed well but we have other strong candidates. "
            "We'll put you on our waiting list and be in touch.";
      case HireDecision.reject:
        return p.style == 'direct'
            ? "Thank you for your time. We'll be moving forward with other candidates."
            : "Thank you so much for coming in. We won't be taking this forward right now, "
                "but I'll send you some feedback.";
      case null:
        return "That's all my questions. Thank you for your time.";
    }
  }

  InterviewResult result({String applicationId = 'practice'}) {
    if (turns.isEmpty) throw StateError('No answers submitted yet.');
    final List<double> qs = _questionScores();
    double interview = qs.isEmpty ? 0 : qs.reduce((double a, double b) => a + b) / qs.length;

    // Preparation matters: professional dress and charisma.
    interview += (qualifications.professionalism * 0.4).clamp(0, 4);
    if (qualifications.hasTrait('charismatic')) interview += 2;
    interview = interview.clamp(0, 100).toDouble();

    final Map<String, double> avg = <String, double>{};
    for (final String d in InterviewDims.all) {
      final List<double> vals = turns.map((InterviewTurn t) => t.evaluation.scores[d] ?? 0).toList();
      avg[d] = vals.reduce((double a, double b) => a + b) / vals.length;
    }
    final List<String> sorted = List<String>.of(InterviewDims.all)
      ..sort((String a, String b) => avg[b]!.compareTo(avg[a]!));
    final List<String> strengths = <String>[
      for (final String d in sorted.take(2))
        if (avg[d]! >= 6.5) '${InterviewDims.labels[d]} (${avg[d]!.toStringAsFixed(1)}/10)',
    ];
    final List<String> improvements = <String>[
      for (final String d in sorted.reversed.take(3))
        if (avg[d]! < 7) '${InterviewDims.labels[d]} (${avg[d]!.toStringAsFixed(1)}/10): ${InterviewDims.advice[d]}',
    ];
    final List<String> notes = <String>[
      for (final InterviewTurn t in turns.where((InterviewTurn t) => !t.isFollowUp))
        '“${_short(t.prompt)}” → ${t.evaluation.overall.round()}/100. ${t.evaluation.comment}',
    ];

    final double hiring = interview * 0.7 + matchScore * 0.3;
    final double threshold = 58 + employer.hiringBar * 0.8 + listing.rank * 1.5;
    HireDecision decision;
    double? salary;
    int? waitDays;
    bool waitOffer = false;
    if (hiring >= threshold) {
      decision = HireDecision.offer;
      final double bump = hiring >= threshold + 15 ? 1.05 : 1.0;
      salary = ((listing.monthlySalary * bump) / 10).round() * 10.0;
    } else if (hiring >= threshold - 7) {
      decision = HireDecision.waitlist;
      final StableRandom rng = StableRandom.fromString('wl|$applicationId|$seed');
      waitDays = 3 + rng.nextInt(4);
      final double gap = threshold - hiring;
      waitOffer = rng.chance((0.65 - gap * 0.065).clamp(0.15, 0.65));
    } else {
      decision = HireDecision.reject;
    }

    return InterviewResult(
      interviewScore: interview,
      hiringScore: hiring,
      offerThreshold: threshold,
      decision: decision,
      dimensionAverages: avg,
      strengths: strengths,
      improvements: improvements,
      questionNotes: notes,
      closingLine: closingLine(decision),
      offerSalary: salary,
      waitlistDays: waitDays,
      waitlistWillOffer: waitOffer,
    );
  }

  static String _short(String s) => s.length <= 60 ? s : '${s.substring(0, 57)}…';
}

/// Small view of who is interviewing (practice sessions use a coach label).
class InterviewerPersonaView {
  InterviewerPersonaView(this.employer, this.practice);
  final Employer employer;
  final bool practice;

  String get name => employer.interviewer.name;
  String get title => practice ? 'Career coach' : employer.interviewer.title;
  InterviewerPersona get persona => employer.interviewer;
}
