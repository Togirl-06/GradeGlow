import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../models/subscription_plan.dart';
import '../utils/ai_practice_limits.dart';
import '../utils/premium_access.dart';
import 'auth_service.dart';
import 'openai_service.dart';
import 'subscription_service.dart';

class AiPracticeService extends ChangeNotifier {
  AiPracticeService(this._auth, this._openAi, this._subscription);

  final AuthService _auth;
  final OpenAiService _openAi;
  final SubscriptionService _subscription;

  bool _isLoading = false;
  AiPracticeUsage? _usageCache;
  int _demoCount = 0;
  String _demoMonth = '';
  final List<AiPracticeRecord> _demoHistory = <AiPracticeRecord>[];

  bool get isLoading => _isLoading;
  AiPracticeUsage? get usage => _usageCache;

  static String _monthKey([DateTime? when]) {
    final DateTime d = when ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  Future<AiPracticeUsage> refreshUsage() async {
    _usageCache = await _loadUsage(_subscription.plan);
    notifyListeners();
    return _usageCache!;
  }

  Future<bool> canStartSession() async {
    final AiPracticeUsage usage = await _loadUsage(_subscription.plan);
    _usageCache = usage;
    return usage.canStart();
  }

  Stream<List<AiPracticeRecord>> watchHistory() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<AiPracticeRecord>>.value(<AiPracticeRecord>[]);

    if (_auth.isDemoMode) {
      return Stream<List<AiPracticeRecord>>.multi((StreamController<List<AiPracticeRecord>> controller) {
        void emit() => controller.add(List<AiPracticeRecord>.from(_demoHistory));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_practice_sessions')
        .orderBy('completedAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => AiPracticeRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<AiPracticeLeaderboardEntry>> watchLeaderboard() {
    final String month = _monthKey();

    if (_auth.isDemoMode || !AppConfig.hasFirebase) {
      return Stream<List<AiPracticeLeaderboardEntry>>.value(_demoLeaderboard());
    }

    return FirebaseFirestore.instance
        .collection('ai_practice_leaderboard')
        .doc(month)
        .collection('entries')
        .orderBy('totalScore', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    AiPracticeLeaderboardEntry.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  List<AiPracticeLeaderboardEntry> _demoLeaderboard() {
    return <AiPracticeLeaderboardEntry>[
      const AiPracticeLeaderboardEntry(
        userId: 'demo1',
        displayName: 'Alex M.',
        totalScore: 890,
        sessionCount: 10,
        averageScore: 89,
      ),
      const AiPracticeLeaderboardEntry(
        userId: 'demo2',
        displayName: 'Jordan K.',
        totalScore: 820,
        sessionCount: 9,
        averageScore: 91,
      ),
      AiPracticeLeaderboardEntry(
        userId: _auth.uid ?? 'you',
        displayName: _auth.displayName.isNotEmpty ? _auth.displayName : 'You',
        totalScore: _demoHistory.fold<int>(0, (int sum, AiPracticeRecord r) => sum + r.score),
        sessionCount: _demoHistory.length.clamp(1, 99),
        averageScore: _demoHistory.isEmpty
            ? 0
            : (_demoHistory.fold<int>(0, (int sum, AiPracticeRecord r) => sum + r.score) / _demoHistory.length).round(),
      ),
    ]..sort((AiPracticeLeaderboardEntry a, AiPracticeLeaderboardEntry b) => b.totalScore.compareTo(a.totalScore));
  }

  Future<SimulationStart> startSession({
    required PracticeLabCategory major,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
  }) async {
    if (!await canStartSession()) {
      throw PremiumRequiredException(AiPracticeLimits.monthlyLimitReached);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final SimulationStart start = await _openAi.startAiPracticeMode(
        majorName: major.name,
        scenario: scenario,
        difficulty: difficulty,
        premium: _subscription.isPremium,
      );
      await _incrementUsageCounter(_subscription.plan);
      return start;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> sendStudentMessage({
    required PracticeLabCategory major,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    required SimulationStart start,
    required List<SimulationMessage> history,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _openAi.continueAiPracticeMode(
        majorName: major.name,
        scenario: scenario,
        difficulty: difficulty,
        scenarioBriefing: start.briefing,
        aiRole: start.aiRole,
        history: history,
        studentMessage: message,
        premium: _subscription.isPremium,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PracticeModeGrade> endAndGrade({
    required PracticeLabCategory major,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    required SimulationStart start,
    required List<SimulationMessage> history,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final PracticeModeGrade grade = await _openAi.gradeAiPracticeMode(
        majorName: major.name,
        scenario: scenario,
        difficulty: difficulty,
        scenarioBriefing: start.briefing,
        history: history,
        premium: _subscription.isPremium,
      );

      await _saveSession(
        major: major,
        scenario: scenario,
        difficulty: difficulty,
        start: start,
        history: history,
        grade: grade,
      );
      return grade;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession({
    required PracticeLabCategory major,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    required SimulationStart start,
    required List<SimulationMessage> history,
    required PracticeModeGrade grade,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String completedAt = DateTime.now().toIso8601String();
    final Map<String, dynamic> payload = <String, dynamic>{
      'majorId': major.id,
      'majorName': major.name,
      'scenarioId': scenario.id,
      'scenarioTitle': start.scenarioTitle,
      'difficulty': difficulty.name,
      'avatarRole': scenario.avatarRole.name,
      'score': grade.score,
      'summary': grade.summary,
      'improvementPlan': grade.improvementPlan,
      'strengths': grade.strengths,
      'improvements': grade.improvements,
      'studyTopics': grade.studyTopics,
      'criteriaScores': grade.criteriaScores,
      'completedAt': completedAt,
      'transcript': history.map((SimulationMessage m) => m.toMap()).toList(),
    };

    if (_auth.isDemoMode) {
      _demoHistory.insert(
        0,
        AiPracticeRecord(
          id: completedAt,
          majorId: major.id,
          majorName: major.name,
          scenarioTitle: start.scenarioTitle,
          difficulty: difficulty.name,
          score: grade.score,
          summary: grade.summary,
          completedAt: DateTime.parse(completedAt),
          avatarRole: scenario.avatarRole.name,
        ),
      );
      notifyListeners();
      return;
    }

    if (!AppConfig.hasFirebase) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_practice_sessions')
        .add(payload);

    await _updateLeaderboard(uid, grade.score);
  }

  Future<void> _updateLeaderboard(String uid, int score) async {
    if (!AppConfig.hasFirebase) return;

    final String month = _monthKey();
    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('ai_practice_leaderboard')
        .doc(month)
        .collection('entries')
        .doc(uid);

    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      final Map<String, dynamic> data = snap.data() ?? <String, dynamic>{};
      final int count = ((data['sessionCount'] as num?)?.toInt() ?? 0) + 1;
      final int total = ((data['totalScore'] as num?)?.toInt() ?? 0) + score;

      tx.set(ref, <String, dynamic>{
        'displayName': _auth.displayName.isNotEmpty ? _auth.displayName : 'Student',
        'sessionCount': count,
        'totalScore': total,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    });
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
      _usageCache = AiPracticeUsage(
        count: _demoCount,
        limit: AiPracticeLimits.freeSessionsPerMonth,
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
    if (data['aiPracticeMonth'] == month) {
      count = (data['aiPracticeCount'] as num?)?.toInt() ?? 0;
    }
    count += 1;

    await ref.set(<String, dynamic>{
      'aiPracticeMonth': month,
      'aiPracticeCount': count,
    }, SetOptions(merge: true));

    _usageCache = AiPracticeUsage(
      count: count,
      limit: AiPracticeLimits.freeSessionsPerMonth,
      isPremium: false,
    );
    notifyListeners();
  }

  Future<AiPracticeUsage> _loadUsage(SubscriptionPlan plan) async {
    if (plan.isPaid) {
      return AiPracticeUsage(
        count: 0,
        limit: AiPracticeLimits.freeSessionsPerMonth,
        isPremium: true,
      );
    }

    final String month = _monthKey();
    final String? uid = _auth.uid;
    if (uid == null) {
      return const AiPracticeUsage(
        count: 0,
        limit: AiPracticeLimits.freeSessionsPerMonth,
        isPremium: false,
      );
    }

    if (_auth.isDemoMode) {
      if (_demoMonth != month) {
        _demoMonth = month;
        _demoCount = 0;
      }
      return AiPracticeUsage(
        count: _demoCount,
        limit: AiPracticeLimits.freeSessionsPerMonth,
        isPremium: false,
      );
    }

    if (!AppConfig.hasFirebase) {
      return const AiPracticeUsage(
        count: 0,
        limit: AiPracticeLimits.freeSessionsPerMonth,
        isPremium: false,
      );
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    int count = 0;
    if (data?['aiPracticeMonth'] == month) {
      count = (data?['aiPracticeCount'] as num?)?.toInt() ?? 0;
    }

    return AiPracticeUsage(
      count: count,
      limit: AiPracticeLimits.freeSessionsPerMonth,
      isPremium: false,
    );
  }
}
