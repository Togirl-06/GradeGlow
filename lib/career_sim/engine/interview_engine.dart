/// Adaptive interview. The next question depends on the last answer's
/// validated score: a weak answer is probed, a strong one is stretched.
/// Scores come from rubrics and graded practicals; any AI commentary shown
/// in the interview screen is separate and never feeds these numbers.
library;

import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import 'text_rubric.dart';

class CandidateAnswer {
  const CandidateAnswer(this.topic, this.reply);

  /// Empty when the question was off-topic.
  final String topic;
  final String reply;
}

class InterviewSession {
  InterviewSession({
    required this.plan,
    required this.company,
    required this.applicationId,
    required this.day,
    this.practice = false,
  }) : _queue = List<String>.from(plan.main) {
    _advance();
  }

  final InterviewPlan plan;
  final CompanyProfile company;
  final String applicationId;
  final int day;
  final bool practice;

  final List<String> _queue;
  final Set<String> _asked = <String>{};
  final List<InterviewTurn> turns = <InterviewTurn>[];
  final List<double> _structure = <double>[];
  final List<String> candidateQuestions = <String>[];
  final Set<String> _topicsAsked = <String>{};
  final Set<String> _probes = <String>{};
  bool _practicalFailed = false;
  bool _practicalAsked = false;

  InterviewQuestion? current;

  /// Interviewer's spoken reaction to the last answer (rule-based).
  String lastReaction = '';

  bool get questionsDone => current == null;
  int get asked => turns.length;

  static const List<Concept> starRubric = <Concept>[
    Concept('situation', 'Describes the situation', <String>['when i', 'during', 'at my', 'in my', 'once', 'last year', 'on a', 'while']),
    Concept('action', 'Explains your own actions', <String>['i decided', 'i started', 'i asked', 'i made', 'i took', 'i spoke', 'i built', 'i checked', 'i suggested', 'i organi*', 'i created', 'i wrote', 'i led', 'i set']),
    Concept('result', 'States the result', <String>['result*', 'outcome', 'as a result', 'which led', 'in the end', 'improv*', 'reduc*', 'increas*', 'finished', 'deliver*', 'learned']),
  ];

  void _advance() {
    current = null;
    if (turns.length >= plan.maxQuestions) return;
    while (_queue.isNotEmpty) {
      final String id = _queue.removeAt(0);
      if (_asked.contains(id)) continue;
      final InterviewQuestion? q = plan.question(id);
      if (q == null) continue;
      current = q;
      _asked.add(id);
      return;
    }
  }

  void _record(InterviewQuestion q, String answer, int score, List<String> notes) {
    turns.add(InterviewTurn(
      questionId: q.id,
      prompt: q.prompt,
      answer: answer,
      score: score,
      competency: q.competency.name,
      notes: notes,
      isFollowUp: _probes.contains(q.id) || !plan.main.contains(q.id),
    ));
    final String? probe = q.probeId;
    final String? stretch = q.stretchId;
    if (score < 60 && probe != null && !_asked.contains(probe)) {
      _queue.insert(0, probe);
      _probes.add(probe);
      lastReaction = 'Let me dig into that a little more.';
    } else if (score >= 85 && stretch != null && !_asked.contains(stretch)) {
      _queue.insert(0, stretch);
      lastReaction = 'Good — let\'s take that further.';
    } else {
      lastReaction = score >= 70 ? 'Thank you, that\'s clear.' : 'Okay. Moving on.';
    }
    _advance();
  }

  /// Open (spoken/typed) answer.
  void answerOpen(String text) {
    final InterviewQuestion? q = current;
    if (q == null || q.isChoice || q.practical != null) {
      throw StateError('The current question is not an open question.');
    }
    if (text.trim().isEmpty) throw ArgumentError('Answer the question first.');
    final List<Concept> rubric = <Concept>[...q.rubric, if (q.behavioural) ...starRubric];
    final TextAssessment t = TextRubric.assess(text, rubric, minWords: q.minWords, maxWords: 300);
    _structure.add(t.structure);
    _record(q, text, t.score, <String>[
      ...t.notes,
      for (final Concept c in t.misses) 'Missing: ${c.label}.',
    ]);
  }

  void answerChoice(int index) {
    final InterviewQuestion? q = current;
    if (q == null || !q.isChoice) throw StateError('The current question is not multiple choice.');
    if (index < 0 || index >= q.options.length) throw ArgumentError('Pick an answer.');
    final bool right = index == q.correctOption;
    _record(q, q.options[index], right ? 100 : 0,
        <String>[right ? 'Accurate.' : 'Inaccurate answer noted by the interviewer.']);
  }

  /// A practical graded by its own rule (code judge, scenario, calculation).
  void answerPractical(TaskResult result, String summary) {
    final InterviewQuestion? q = current;
    if (q == null || q.practical == null) throw StateError('The current question is not a practical.');
    _practicalAsked = true;
    if (!result.passed) _practicalFailed = true;
    _record(q, summary, result.score, result.feedback.take(3).toList());
  }

  /// The candidate's own question to the interviewer.
  CandidateAnswer ask(String question) {
    final String q = question.trim();
    if (q.isEmpty) throw ArgumentError('Type a question for the interviewer.');
    if (candidateQuestions.length >= 3) throw StateError('You can ask up to three questions.');
    candidateQuestions.add(q);
    final String lower = q.toLowerCase();
    bool has(List<String> words) =>
        words.any((String w) => TextRubric.mentions(lower, Concept('t', 't', <String>[w])));
    String topic = '';
    String reply;
    if (has(<String>['team', 'work with', 'colleague*', 'report to', 'manager', 'supervisor'])) {
      topic = 'team';
      reply = company.team;
    } else if (has(<String>['train*', 'learn*', 'mentor*', 'develop*', 'grow*', 'progress*'])) {
      topic = 'training';
      reply = company.training;
    } else if (has(<String>['success*', 'expect*', 'measure*', 'first month*', 'first 90', 'first three', 'evaluat*', 'perform*'])) {
      topic = 'success';
      reply = company.success;
    } else if (has(<String>['culture', 'values', 'environment', 'typical day', 'day to day', 'like to work'])) {
      topic = 'culture';
      reply = company.culture;
    } else if (has(<String>['tool*', 'stack', 'technolog*', 'software', 'system*', 'equipment'])) {
      topic = 'tools';
      reply = company.tools;
    } else if (has(<String>['next step*', 'timeline', 'hear back', 'process', 'decision'])) {
      topic = 'next';
      reply = company.nextSteps;
    } else if (has(<String>['salary', 'pay', 'benefit*', 'holiday*', 'vacation'])) {
      reply = 'Compensation and benefits are set out in writing if we make an offer.';
    } else {
      reply = 'I don\'t have a specific answer for that — I\'ll follow up by email.';
    }
    if (topic.isNotEmpty) _topicsAsked.add(topic);
    return CandidateAnswer(topic, reply);
  }

  int _avg(Iterable<int> xs, int fallback) {
    final List<int> l = xs.toList();
    if (l.isEmpty) return fallback;
    return (l.reduce((int a, int b) => a + b) / l.length).round();
  }

  InterviewRecord finish() {
    if (!questionsDone) throw StateError('The interview has unanswered questions.');
    final int all = _avg(turns.map((InterviewTurn t) => t.score), 0);
    int comp(Competency c) =>
        _avg(turns.where((InterviewTurn t) => t.competency == c.name).map((InterviewTurn t) => t.score), all);
    final int structure = _avg(_structure.map((double s) => (s * 100).round()), all);
    final int communication = ((comp(Competency.communication) + structure) / 2).round();
    final int engagement = (_topicsAsked.length.clamp(0, 3) / 3 * 100).round();
    final int readiness = (0.7 * comp(Competency.readiness) + 0.3 * engagement).round();
    final List<String> feedback = <String>[
      if (_topicsAsked.isEmpty) 'You asked no questions about the role, team or training.',
      if (_topicsAsked.length >= 2) 'Good questions about the ${_topicsAsked.join(' and ')}.',
      if (_practicalFailed) 'The practical exercise was not passed.',
      if (_probes.isNotEmpty) 'The interviewer had to probe ${_probes.length} answer(s) for more depth.',
    ];
    return InterviewRecord(
      applicationId: applicationId,
      day: day,
      turns: List<InterviewTurn>.from(turns),
      communication: communication,
      technical: comp(Competency.technical),
      problemSolving: comp(Competency.problemSolving),
      readiness: readiness,
      candidateQuestions: List<String>.from(candidateQuestions),
      practicalPassed: _practicalAsked && !_practicalFailed,
      practice: practice,
      feedback: feedback,
    );
  }
}

/// Helper so screens can tell which practical type a question carries.
String practicalLabel(TaskSpec t) => t.kindLabel;
