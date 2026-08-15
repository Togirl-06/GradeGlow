import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../data/leetcode_problem_bank.dart';
import '../data/practice_labs_catalog.dart';
import '../data/practice_lab_question_bank.dart';
import '../models/leetcode_problem.dart';
import '../models/law_simulation.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_question.dart';
import '../models/subscription_plan.dart';
import '../models/visual_learning_lab.dart';
import '../utils/practice_lab_helpers.dart';
import '../utils/practice_lab_limits.dart';
import '../utils/premium_access.dart';
import '../utils/api_error_messages.dart';
import 'auth_service.dart';
import 'openai_service.dart';
import 'subscription_service.dart';
import 'leetcode_debug_judge.dart';

class PracticeLabService extends ChangeNotifier {
  PracticeLabService(this._auth, this._openAi, this._subscription);

  final AuthService _auth;
  final OpenAiService _openAi;
  final SubscriptionService _subscription;

  bool _isLoading = false;
  PracticeLabUsage? _usageCache;
  int _demoCount = 0;
  String _demoMonth = '';
  final List<PracticeLabRecord> _demoHistory = <PracticeLabRecord>[];

  bool get isLoading => _isLoading;
  PracticeLabUsage? get usage => _usageCache;

  List<PracticeLabCategory> get categories => PracticeLabsCatalog.categories;

  static String _monthKey([DateTime? when]) {
    final DateTime d = when ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  Future<PracticeLabUsage> refreshUsage() async {
    _usageCache = await _loadUsage(_subscription.plan);
    notifyListeners();
    return _usageCache!;
  }

  Future<bool> canStartSimulation() async {
    final PracticeLabUsage usage = await _loadUsage(_subscription.plan);
    _usageCache = usage;
    return usage.canStart();
  }

  /// Reserves one monthly simulation slot (anatomy game or other non-AI labs).
  Future<void> consumeSimulationSlot() async {
    if (!await canStartSimulation()) {
      throw PremiumRequiredException(PracticeLabLimits.monthlyLimitReached);
    }
    await _incrementUsageCounter(_subscription.plan);
  }

  Future<void> saveAnatomyGameResult({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required int score,
    required String summary,
    required int roundsPlayed,
    required int xpEarned,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': 'Anatomy diagram quest',
      'score': score,
      'summary': summary,
      'improvementPlan': 'Review missed organs and replay to build muscle memory.',
      'completedAt': completedAt,
      'gameType': 'anatomy',
      'roundsPlayed': roundsPlayed,
      'xpEarned': xpEarned,
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: 'Anatomy diagram quest',
          score: score,
          summary: summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<void> saveScienceDiagramResult({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required String diagramTitle,
    required int score,
    required String summary,
    required int roundsPlayed,
    required int xpEarned,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': '$diagramTitle labeling',
      'score': score,
      'summary': summary,
      'improvementPlan': 'Review missed labels and replay the diagram lab.',
      'completedAt': completedAt,
      'gameType': 'science_diagram',
      'roundsPlayed': roundsPlayed,
      'xpEarned': xpEarned,
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: '$diagramTitle labeling',
          score: score,
          summary: summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<void> saveVisualLabResult({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required String activityTitle,
    required VisualLabActivityType activityType,
    required VisualLabScoreBreakdown scoreBreakdown,
    required String summary,
    required int roundsPlayed,
    required int xpEarned,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': activityTitle,
      'score': scoreBreakdown.overall,
      'summary': summary,
      'improvementPlan': 'Replay missed items and review the diagram.',
      'completedAt': completedAt,
      'gameType': 'visual_learning_${activityType.name}',
      'roundsPlayed': roundsPlayed,
      'xpEarned': xpEarned,
      'scoreBreakdown': scoreBreakdown.toMap(),
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: activityTitle,
          score: scoreBreakdown.overall,
          summary: summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<void> saveErSimulationResult({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required int score,
    required String summary,
    required int xpEarned,
    required int stars,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': 'ER simulation',
      'score': score,
      'summary': summary,
      'improvementPlan': 'Replay the case and complete all objectives under time pressure for 3 stars.',
      'completedAt': completedAt,
      'gameType': 'er_simulation',
      'xpEarned': xpEarned,
      'stars': stars,
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: 'ER simulation',
          score: score,
          summary: summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<void> saveLawSimulationResult({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required String caseTitle,
    required LawVerdictBreakdown verdict,
    required String sideLabel,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': caseTitle,
      'score': verdict.overall,
      'summary': verdict.summary,
      'improvementPlan': verdict.weakPoints.join('; '),
      'completedAt': completedAt,
      'gameType': 'law_simulation',
      'xpEarned': verdict.xpEarned,
      'side': sideLabel,
      'ruling': verdict.ruling,
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: caseTitle,
          score: verdict.overall,
          summary: verdict.summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<String> lawWitnessInterview({
    required LawWitness witness,
    required String caseBrief,
    required String truthBlock,
    required String question,
    required List<SimulationMessage> history,
  }) async {
    return _openAi.lawWitnessReply(
      witness: witness,
      caseBrief: caseBrief,
      truthBlock: truthBlock,
      studentQuestion: question,
      history: history,
      premium: _subscription.isPremium,
    );
  }

  Future<String> lawOpponentReply({
    required String sideLabel,
    required String opponentLabel,
    required String caseBrief,
    required String truthBlock,
    required String studentLine,
    required List<SimulationMessage> history,
  }) async {
    return _openAi.lawOpponentReply(
      sideLabel: sideLabel,
      opponentLabel: opponentLabel,
      caseBrief: caseBrief,
      truthBlock: truthBlock,
      studentArgument: studentLine,
      history: history,
      premium: _subscription.isPremium,
    );
  }

  Future<String> lawJudgeLine({
    required String action,
    required String caseBrief,
    required String truthBlock,
    required String studentLine,
  }) async {
    return _openAi.lawJudgeLine(
      action: action,
      caseBrief: caseBrief,
      truthBlock: truthBlock,
      studentLine: studentLine,
      premium: _subscription.isPremium,
    );
  }

  Future<LawVerdictBreakdown> lawVerdict({
    required String caseBrief,
    required String truthBlock,
    required String sideLabel,
    required String argumentSummary,
    required List<SimulationMessage> courtroomHistory,
  }) async {
    return _openAi.lawSimulationVerdict(
      caseBrief: caseBrief,
      truthBlock: truthBlock,
      sideLabel: sideLabel,
      argumentSummary: argumentSummary,
      courtroomHistory: courtroomHistory,
      premium: _subscription.isPremium,
    );
  }

  Stream<List<PracticeLabRecord>> watchHistory() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<PracticeLabRecord>>.value(<PracticeLabRecord>[]);

    if (_auth.isDemoMode) {
      return Stream<List<PracticeLabRecord>>.multi((StreamController<List<PracticeLabRecord>> controller) {
        void emit() => controller.add(List<PracticeLabRecord>.from(_demoHistory));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .orderBy('completedAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => PracticeLabRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<SimulationStart> startSimulation({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    String? topicAreaName,
    String? topicName,
  }) async {
    if (!await canStartSimulation()) {
      throw PremiumRequiredException(PracticeLabLimits.monthlyLimitReached);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final bool liveCharacter = usesLiveAiCharacter(category.id, groupId: category.groupId);
      final SimulationStart start = await _openAi.startPracticeSimulation(
        categoryName: category.name,
        labTitle: lab.title,
        labSubtitle: lab.subtitle,
        roleplayGuide: PracticeLabsCatalog.roleplayGuide(lab.style),
        aiRole: lab.aiRole,
        studentTasks: lab.studentTasks,
        difficulty: lab.difficulty,
        topicAreaName: topicAreaName,
        topicName: topicName,
        premium: _subscription.isPremium,
        liveCharacter: liveCharacter,
        venueGroupId: category.groupId,
      );
      await _incrementUsageCounter(_subscription.plan);
      return start;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads a large question set for a topic practice session (AI + local bank).
  Future<List<PracticeLabQuestion>> loadPracticeQuestions({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    String? courseName,
    String? unitName,
    String? topicName,
    String? subjectId,
    String? courseId,
    String? topicId,
  }) async {
    final String topic = topicName ?? lab.title;
    final String course = courseName ?? category.name;
    final String unit = unitName ?? lab.subtitle;
    final String resolvedTopicId = topicId ?? _slug(topic);

    if (lab.codeLab) {
      return _loadLeetcodeQuestions(
        topicId: resolvedTopicId,
        topicName: topic,
        unitName: unit,
        difficulty: lab.difficulty,
        debugMode: lab.style == SimulationStyle.debugging,
      );
    }

    List<String> aiQuestions = const <String>[];
    if (AppConfig.hasOpenAi) {
      try {
        aiQuestions = await _openAi.generatePracticeQuestions(
          categoryName: category.name,
          courseName: course,
          unitName: unit,
          topicName: topic,
          difficulty: lab.difficulty,
          count: 30,
          premium: _subscription.isPremium,
          topicId: resolvedTopicId,
          subjectId: subjectId,
          courseId: courseId,
          directMathProblems: subjectId == 'mathematics',
          mathSessionTier: _mathSessionTier(lab.id),
        );
      } catch (_) {
        aiQuestions = const <String>[];
      }
    }

    return PracticeLabQuestionBank.build(
      topicName: topic,
      courseName: course,
      unitName: unit,
      difficulty: lab.difficulty,
      aiQuestions: aiQuestions,
      subjectId: subjectId,
      courseId: courseId,
      topicId: resolvedTopicId,
    );
  }

  Future<List<PracticeLabQuestion>> _loadLeetcodeQuestions({
    required String topicId,
    required String topicName,
    required String unitName,
    required String difficulty,
    bool debugMode = false,
  }) async {
    final int count = PracticeLabQuestionBank.targetCountForDifficulty(difficulty);
    final List<PracticeLabQuestion> bank = LeetcodeProblemBank.buildForTopic(
      topicId: topicId,
      topicName: topicName,
      difficulty: difficulty,
      count: count,
      preferDebug: debugMode,
    );

    final bool debugTopic = debugMode || LeetcodeProblemBank.isDebugTopic(topicId: topicId, topicName: topicName);

    if (!AppConfig.hasOpenAi) return bank;

    try {
      final List<LeetcodeProblem> aiProblems = await _openAi.generateLeetcodeProblems(
        topicName: topicName,
        unitName: unitName,
        difficulty: difficulty,
        count: count.clamp(2, 4),
        premium: _subscription.isPremium,
        debugMode: debugTopic,
      );
      if (aiProblems.isEmpty) return bank;

      final Set<String> slugs = bank.map((PracticeLabQuestion q) => q.leetcode?.slug ?? q.id).toSet();
      final List<PracticeLabQuestion> merged = List<PracticeLabQuestion>.from(bank);
      for (final LeetcodeProblem p in aiProblems) {
        if (slugs.contains(p.slug)) continue;
        merged.insert(0, PracticeLabQuestion(id: p.slug, prompt: p.promptFallback, leetcode: p));
        slugs.add(p.slug);
      }
      return merged.take(count).toList();
    } catch (_) {
      return bank;
    }
  }

  Future<LeetcodeRunResult> runLeetcodeTests({
    required LeetcodeProblem problem,
    required String language,
    required String code,
    bool submit = false,
  }) async {
    // Debug challenges always grade offline — never call OpenAI.
    if (problem.isDebug) {
      return LeetcodeDebugJudge.tryGrade(
            problem: problem,
            language: language,
            code: code,
            includeHidden: submit,
          ) ??
          LeetcodeDebugJudge.offlineFallback(
            problem: problem,
            includeHidden: submit,
            accepted: false,
            feedback: 'Could not grade locally. Edit the buggy starter and try again.',
          );
    }

    const int maxAttempts = 3;
    Object? lastError;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await _openAi
            .evaluateLeetcodeSubmission(
              problem: problem,
              language: language,
              code: code,
              includeHidden: submit,
              premium: _subscription.isPremium,
            )
            .timeout(const Duration(seconds: 90));
      } catch (error) {
        lastError = error;
        final bool retryable = ApiErrorMessages.friendlyNetworkMessage(error.toString()) != null ||
            error is TimeoutException;
        if (attempt < maxAttempts - 1 && retryable) {
          await Future<void>.delayed(Duration(milliseconds: 700 * (attempt + 1)));
          continue;
        }
        rethrow;
      }
    }
    throw lastError ?? Exception('Could not grade your submission. Try again.');
  }

  Future<String> requestLeetcodeHint({
    required LeetcodeProblem problem,
    required int hintLevel,
    required String language,
    String? currentCode,
  }) async {
    return _openAi.leetcodeHint(
      problem: problem,
      hintLevel: hintLevel,
      language: language,
      currentCode: currentCode,
      premium: _subscription.isPremium,
    );
  }

  /// Debug-challenge coach. Falls back to a local tip if the network/API is unavailable.
  Future<String> askDebugCoach({
    required LeetcodeProblem problem,
    required String language,
    required String question,
    String? currentCode,
  }) async {
    try {
      return await _openAi
          .debugCoachAnswer(
            problem: problem,
            language: language,
            question: question,
            currentCode: currentCode,
            premium: _subscription.isPremium,
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      return _offlineDebugCoachTip(problem: problem, question: question);
    }
  }

  static String _offlineDebugCoachTip({
    required LeetcodeProblem problem,
    required String question,
  }) {
    final String id = problem.id;
    final String title = problem.title.toLowerCase();
    if (id == 'debug-704' || title.contains('binary search')) {
      return 'Offline tip: Look at how `left` and `right` move after comparing `nums[mid]`. '
          'If you set a bound to `mid` instead of `mid ± 1`, the loop can stall or skip the answer.\n\n'
          '(Ask again when you are online for a fuller AI reply.)';
    }
    if (id == 'debug-1') {
      return 'Offline tip: Check the nested loop indices — an off-by-one or wrong range often creates duplicates or misses pairs.\n\n'
          '(Ask again when you are online for a fuller AI reply.)';
    }
    if (id == 'debug-53') {
      return 'Offline tip: Watch the running sum reset. Initializing best/current to 0 can hide all-negative arrays.\n\n'
          '(Ask again when you are online for a fuller AI reply.)';
    }
    if (id == 'debug-bank-121' || title.contains('profit')) {
      return 'Offline tip: Initialize the minimum price from the first price (or infinity), not from 0.\n\n'
          '(Ask again when you are online for a fuller AI reply.)';
    }
    return 'Offline tip: Compare your code to the intended algorithm. Find one wrong assignment, return, or loop bound — that is usually the bug.\n\n'
        '(Ask again when you are online for a fuller AI reply.)';
  }

  Future<String> runCodeSnippet({
    required String language,
    required String code,
    required String taskContext,
  }) async {
    return _openAi.runCodeSnippet(
      language: language,
      code: code,
      taskContext: taskContext,
      premium: _subscription.isPremium,
    );
  }

  Future<String> requestOptimalExplanation({
    required LeetcodeProblem problem,
    required String language,
  }) async {
    return _openAi.leetcodeOptimalExplanation(
      problem: problem,
      language: language,
      premium: _subscription.isPremium,
    );
  }

  static String? _mathSessionTier(String labId) {
    if (!labId.startsWith('math_')) return null;
    if (labId.endsWith('_exam')) return 'exam';
    if (labId.endsWith('_quiz')) return 'quiz';
    if (labId.endsWith('_homework')) return 'homework';
    return null;
  }

  static String _slug(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Future<String> feedbackPracticeAnswer({
    required PracticeLabCategory category,
    required String topicName,
    required String question,
    required String studentAnswer,
    required String difficulty,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _openAi.feedbackPracticeAnswer(
        categoryName: category.name,
        topicName: topicName,
        question: question,
        studentAnswer: studentAnswer,
        difficulty: difficulty,
        premium: _subscription.isPremium,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> explainLabelingMistake({
    required String diagramTitle,
    required String correctLabel,
    required String studentChoice,
    required String subjectName,
    String context = 'diagram labeling',
  }) async {
    try {
      return await _openAi.explainLabelingMistake(
        diagramTitle: diagramTitle,
        correctLabel: correctLabel,
        studentChoice: studentChoice,
        subjectName: subjectName,
        context: context,
        premium: _subscription.isPremium,
      );
    } catch (_) {
      return 'The correct label is $correctLabel. Review the diagram and try again.';
    }
  }

  Future<String> explainChemistryReaction({
    required String reagentA,
    required String reagentB,
    required String outcome,
    required double ph,
    required String subjectName,
  }) async {
    try {
      return await _openAi.explainChemistryReaction(
        reagentA: reagentA,
        reagentB: reagentB,
        outcome: outcome,
        ph: ph,
        subjectName: subjectName,
        premium: _subscription.isPremium,
      );
    } catch (_) {
      return outcome;
    }
  }

  /// Builds a simulation transcript from Q&A responses for grading.
  List<SimulationMessage> historyFromQuestionResponses({
    required SimulationStart start,
    required List<PracticeLabQuestionResponse> responses,
  }) {
    final List<SimulationMessage> history = <SimulationMessage>[
      SimulationMessage.ai(start.openingMessage),
    ];
    for (final PracticeLabQuestionResponse response in responses) {
      history.add(SimulationMessage.ai('Question: ${response.question.prompt}'));
      history.add(SimulationMessage.student(response.answer));
      final String? feedback = response.feedback;
      if (feedback != null && feedback.trim().isNotEmpty) {
        history.add(SimulationMessage.ai(feedback.trim()));
      }
    }
    return history;
  }

  Future<String> sendStudentMessage({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationStart start,
    required List<SimulationMessage> history,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _openAi.continuePracticeSimulation(
        categoryName: category.name,
        labTitle: lab.title,
        roleplayGuide: PracticeLabsCatalog.roleplayGuide(lab.style),
        scenarioBriefing: start.briefing,
        aiRole: start.aiRole,
        history: history,
        studentMessage: message,
        premium: _subscription.isPremium,
        liveCharacter: usesLiveAiCharacter(category.id, groupId: category.groupId),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> requestHint({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationStart start,
    required List<SimulationMessage> history,
  }) async {
    return _openAi.practiceLabHint(
      categoryName: category.name,
      labTitle: lab.title,
      scenarioBriefing: start.briefing,
      history: history,
      studentTasks: lab.studentTasks,
      premium: _subscription.isPremium,
    );
  }

  Future<PracticeLabLiveScore> pulseLiveScore({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationStart start,
    required List<SimulationMessage> history,
  }) async {
    return _openAi.practiceLabLiveScore(
      categoryName: category.name,
      labTitle: lab.title,
      scenarioBriefing: start.briefing,
      history: history,
      evaluationCriteria: lab.evaluationCriteria,
      premium: _subscription.isPremium,
    );
  }

  Future<SimulationGrade> endAndGrade({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationStart start,
    required List<SimulationMessage> history,
    int hintsUsed = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final SimulationGrade raw = await _openAi.gradePracticeSimulation(
        categoryName: category.name,
        labTitle: lab.title,
        scenarioBriefing: start.briefing,
        history: history,
        evaluationCriteria: lab.evaluationCriteria,
        studentTasks: lab.studentTasks,
        difficulty: lab.difficulty,
        premium: _subscription.isPremium,
      );
      final SimulationGrade grade = SimulationGrade(
        score: raw.score,
        summary: raw.summary,
        improvementPlan: raw.improvementPlan,
        strengths: raw.strengths,
        improvements: raw.improvements,
        studyTopics: raw.studyTopics,
        criteriaScores: raw.criteriaScores,
        hintsUsed: hintsUsed,
      );

      await _saveSession(
        category: category,
        lab: lab,
        start: start,
        history: history,
        grade: grade,
      );
      await _saveSkillProgress(category: category, lab: lab, grade: grade);
      return grade;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationStart start,
    required List<SimulationMessage> history,
    required SimulationGrade grade,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'categoryId': category.id,
      'labId': lab.id,
      'categoryName': category.name,
      'labTitle': lab.title,
      'scenarioTitle': start.scenarioTitle,
      'score': grade.score,
      'summary': grade.summary,
      'improvementPlan': grade.improvementPlan,
      'strengths': grade.strengths,
      'improvements': grade.improvements,
      'studyTopics': grade.studyTopics,
      'criteriaScores': grade.criteriaScores,
      'hintsUsed': grade.hintsUsed,
      'completedAt': completedAt,
      'transcript': history.map((SimulationMessage m) => m.toMap()).toList(),
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        PracticeLabRecord(
          id: completedAt,
          categoryId: category.id,
          labId: lab.id,
          categoryName: category.name,
          labTitle: lab.title,
          scenarioTitle: start.scenarioTitle,
          score: grade.score,
          summary: grade.summary,
          completedAt: DateTime.parse(completedAt),
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_sessions')
        .add(payload);
  }

  Future<void> _saveSkillProgress({
    required PracticeLabCategory category,
    required PracticeLabType lab,
    required SimulationGrade grade,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null || _auth.isDemoMode || !AppConfig.hasFirebase) return;
    if (grade.criteriaScores.isEmpty && grade.score == 0) return;

    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('practice_lab_skills')
        .doc('${category.id}_${lab.id}');

    await ref.set(<String, dynamic>{
      'categoryId': category.id,
      'categoryName': category.name,
      'labId': lab.id,
      'labTitle': lab.title,
      'lastScore': grade.score,
      'criteriaScores': grade.criteriaScores,
      'studyTopics': grade.studyTopics,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> _incrementUsageCounter(SubscriptionPlan plan) async {
    if (plan.isPaid) return;

    final String month = _monthKey();
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (_auth.isDemoMode) {
      if (_demoMonth != month) {
        _demoMonth = month;
        _demoCount = 0;
      }
      _demoCount += 1;
      _usageCache = PracticeLabUsage(
        count: _demoCount,
        limit: PracticeLabLimits.freeSimulationsPerMonth,
        isPremium: false,
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    final DocumentReference<Map<String, dynamic>> ref =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    int count = 0;
    if (data['practiceLabMonth'] == month) {
      count = (data['practiceLabCount'] as num?)?.toInt() ?? 0;
    }
    count += 1;

    await ref.set(<String, dynamic>{
      'practiceLabMonth': month,
      'practiceLabCount': count,
    }, SetOptions(merge: true));

    _usageCache = PracticeLabUsage(
      count: count,
      limit: PracticeLabLimits.freeSimulationsPerMonth,
      isPremium: false,
    );
    notifyListeners();
  }

  Future<PracticeLabUsage> _loadUsage(SubscriptionPlan plan) async {
    if (plan.isPaid) {
      return PracticeLabUsage(
        count: 0,
        limit: PracticeLabLimits.freeSimulationsPerMonth,
        isPremium: true,
      );
    }

    final String month = _monthKey();
    final String? uid = _auth.uid;
    if (uid == null) {
      return const PracticeLabUsage(
        count: 0,
        limit: PracticeLabLimits.freeSimulationsPerMonth,
        isPremium: false,
      );
    }

    if (_auth.isDemoMode) {
      if (_demoMonth != month) {
        _demoMonth = month;
        _demoCount = 0;
      }
      return PracticeLabUsage(
        count: _demoCount,
        limit: PracticeLabLimits.freeSimulationsPerMonth,
        isPremium: false,
      );
    }

    if (!AppConfig.hasFirebase) {
      return const PracticeLabUsage(
        count: 0,
        limit: PracticeLabLimits.freeSimulationsPerMonth,
        isPremium: false,
      );
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    int count = 0;
    if (data?['practiceLabMonth'] == month) {
      count = (data?['practiceLabCount'] as num?)?.toInt() ?? 0;
    }

    return PracticeLabUsage(
      count: count,
      limit: PracticeLabLimits.freeSimulationsPerMonth,
      isPremium: false,
    );
  }
}
