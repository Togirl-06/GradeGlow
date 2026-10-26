import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'biz_job_catalog.dart';
import 'business_career_content.dart';

/// Persistent School of Business & Economics career-sim progress.
class BusinessCareerProgress extends ChangeNotifier {
  BusinessCareerProgress();

  static const String _key = 'business_career_progress_v1';
  static BusinessCareerProgress? _instance;
  static BusinessCareerProgress get instance =>
      _instance ??= BusinessCareerProgress();

  bool loaded = false;
  bool hasCharacter = false;
  String displayName = 'Student';
  int avatarSkin = 1;
  int avatarHair = 0;
  int avatarHairColor = 0;
  int avatarOutfit = 0;
  String preferredPresentation = 'professional';

  String majorId = 'business_administration';
  int xp = 0;
  int level = 1;
  int careerStage = 1;
  int balanceCents = 0;
  int lifetimeEarnedCents = 0;
  int hourlyWageCents = 2600;

  bool clockedIn = false;
  String? clockInAtIso;
  String? activeJobId;

  String? activeMissionId;
  int activeMissionStep = 0;
  Map<String, dynamic>? lastSimState;

  final Set<String> completedChallenges = <String>{};
  final Set<String> completedMissions = <String>{};
  final Set<String> badges = <String>{};
  final Set<String> appliedJobIds = <String>{};
  final Set<String> employedJobIds = <String>{};
  final Set<String> workplaceTasksDone = <String>{};

  /// jobId → applied | interviewed | offered | hired | rejected
  final Map<String, String> applicationStatus = <String, String>{};
  final Map<String, int> skillLevels = <String, int>{
    'Communication': 1,
    'Problem-solving': 1,
    'Decision-making': 1,
    'Strategy': 1,
    'Operations': 1,
    'Leadership': 1,
  };

  final List<Map<String, dynamic>> portfolioProjects = <Map<String, dynamic>>[];
  bool interviewPassed = false;

  int get xpIntoLevel => xp % 2000;
  int get xpToNextLevel => 2000;

  String get balanceLabel =>
      '\$${(balanceCents / 100.0).toStringAsFixed(2)}';
  String get lifetimeEarnedLabel =>
      '\$${(lifetimeEarnedCents / 100.0).toStringAsFixed(2)}';

  String get stageLabel => switch (careerStage) {
        1 => 'Student',
        2 => 'Intern',
        3 => 'Junior associate',
        4 => 'Mid-level',
        5 => 'Senior',
        6 => 'Director',
        _ => 'Associate',
      };

  BusinessMajor get major => BusinessMajors.byId(majorId);

  bool get hasAnyJob => employedJobIds.isNotEmpty;

  bool get hasStartedWork =>
      clockedIn ||
      lifetimeEarnedCents > 0 ||
      workplaceTasksDone.isNotEmpty;

  int get resumeScore {
    int score = portfolioProjects.length * 28;
    score += completedChallenges.length * 4;
    score += completedMissions.length * 10;
    return score.clamp(0, 100);
  }

  bool get resumeReadyToApply =>
      resumeScore >= 40 || portfolioProjects.isNotEmpty;

  String statusFor(String jobId) => applicationStatus[jobId] ?? 'none';

  String jobActionLabel({String? jobId}) {
    if (!hasAnyJob) return 'Start job';
    if (clockedIn) return 'Continue shift';
    if (hasStartedWork) return 'Continue job';
    return 'Start job';
  }

  Future<void> ensureLoaded() async {
    if (loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        hasCharacter = data['hasCharacter'] as bool? ?? false;
        displayName = data['displayName'] as String? ?? displayName;
        avatarSkin = data['avatarSkin'] as int? ?? 1;
        avatarHair = data['avatarHair'] as int? ?? 0;
        avatarHairColor = data['avatarHairColor'] as int? ?? 0;
        avatarOutfit = data['avatarOutfit'] as int? ?? 0;
        preferredPresentation =
            data['preferredPresentation'] as String? ?? preferredPresentation;
        majorId = data['majorId'] as String? ?? majorId;
        xp = data['xp'] as int? ?? 0;
        level = data['level'] as int? ?? ((xp ~/ 2000) + 1);
        careerStage = data['careerStage'] as int? ?? 1;
        balanceCents = data['balanceCents'] as int? ?? 0;
        lifetimeEarnedCents = data['lifetimeEarnedCents'] as int? ?? 0;
        hourlyWageCents = data['hourlyWageCents'] as int? ?? 2600;
        clockedIn = data['clockedIn'] as bool? ?? false;
        clockInAtIso = data['clockInAtIso'] as String?;
        activeJobId = data['activeJobId'] as String?;
        activeMissionId = data['activeMissionId'] as String?;
        activeMissionStep = data['activeMissionStep'] as int? ?? 0;
        interviewPassed = data['interviewPassed'] as bool? ?? false;
        lastSimState = data['lastSimState'] as Map<String, dynamic>?;
        completedChallenges
          ..clear()
          ..addAll(_stringSet(data['completedChallenges']));
        completedMissions
          ..clear()
          ..addAll(_stringSet(data['completedMissions']));
        badges
          ..clear()
          ..addAll(_stringSet(data['badges']));
        appliedJobIds
          ..clear()
          ..addAll(_stringSet(data['appliedJobIds']));
        employedJobIds
          ..clear()
          ..addAll(_stringSet(data['employedJobIds']));
        workplaceTasksDone
          ..clear()
          ..addAll(_stringSet(data['workplaceTasksDone']));
        applicationStatus
          ..clear()
          ..addAll(_stringMap(data['applicationStatus']));
        final Map<String, dynamic>? skills =
            data['skillLevels'] as Map<String, dynamic>?;
        if (skills != null) {
          for (final MapEntry<String, dynamic> e in skills.entries) {
            skillLevels[e.key] = (e.value as num?)?.toInt() ?? 1;
          }
        }
        portfolioProjects
          ..clear()
          ..addAll(_mapList(data['portfolioProjects']));
      } catch (_) {
        // Keep defaults on corrupt save.
      }
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'hasCharacter': hasCharacter,
        'displayName': displayName,
        'avatarSkin': avatarSkin,
        'avatarHair': avatarHair,
        'avatarHairColor': avatarHairColor,
        'avatarOutfit': avatarOutfit,
        'preferredPresentation': preferredPresentation,
        'majorId': majorId,
        'xp': xp,
        'level': level,
        'careerStage': careerStage,
        'balanceCents': balanceCents,
        'lifetimeEarnedCents': lifetimeEarnedCents,
        'hourlyWageCents': hourlyWageCents,
        'clockedIn': clockedIn,
        'clockInAtIso': clockInAtIso,
        'activeJobId': activeJobId,
        'activeMissionId': activeMissionId,
        'activeMissionStep': activeMissionStep,
        'interviewPassed': interviewPassed,
        'lastSimState': lastSimState,
        'completedChallenges': completedChallenges.toList(),
        'completedMissions': completedMissions.toList(),
        'badges': badges.toList(),
        'appliedJobIds': appliedJobIds.toList(),
        'employedJobIds': employedJobIds.toList(),
        'workplaceTasksDone': workplaceTasksDone.toList(),
        'applicationStatus': applicationStatus,
        'skillLevels': skillLevels,
        'portfolioProjects': portfolioProjects,
      }),
    );
  }

  Future<void> saveCharacter({
    required String name,
    required int skin,
    required int hair,
    required int hairColor,
    required int outfit,
    required String presentation,
  }) async {
    displayName = name.trim().isEmpty ? 'Student' : name.trim();
    avatarSkin = skin;
    avatarHair = hair;
    avatarHairColor = hairColor;
    avatarOutfit = outfit;
    preferredPresentation = presentation;
    hasCharacter = true;
    notifyListeners();
    await _persist();
  }

  Future<void> setMajor(String id) async {
    majorId = id;
    notifyListeners();
    await _persist();
  }

  Future<void> awardXp(int amount) async {
    xp = (xp + amount).clamp(0, 1000000);
    level = (xp ~/ 2000) + 1;
    notifyListeners();
    await _persist();
  }

  Future<void> completeChallenge(String id, {int xpGain = 40}) async {
    if (completedChallenges.contains(id)) {
      notifyListeners();
      return;
    }
    completedChallenges.add(id);
    await awardXp(xpGain);
  }

  Future<void> addPortfolioProject({
    required String title,
    required String summary,
    required List<String> skills,
  }) async {
    portfolioProjects.add(<String, dynamic>{
      'id': 'proj_${DateTime.now().millisecondsSinceEpoch}',
      'title': title.trim(),
      'summary': summary.trim(),
      'skills': skills,
    });
    if (careerStage < 2) careerStage = 2;
    notifyListeners();
    await _persist();
  }

  Future<void> removePortfolioProject(String id) async {
    portfolioProjects.removeWhere((Map<String, dynamic> p) => p['id'] == id);
    notifyListeners();
    await _persist();
  }

  Future<void> applyToJob(String jobId) async {
    if (!resumeReadyToApply) return;
    appliedJobIds.add(jobId);
    applicationStatus[jobId] = 'applied';
    final BizJobListing? job = BizCareerJobs.byId(jobId);
    if (job != null) hourlyWageCents = job.hourlyWageCents;
    notifyListeners();
    await _persist();
  }

  Future<void> markInterviewed(String jobId) async {
    applicationStatus[jobId] = 'interviewed';
    interviewPassed = true;
    notifyListeners();
    await _persist();
  }

  Future<void> grantOffer(String jobId) async {
    applicationStatus[jobId] = 'offered';
    notifyListeners();
    await _persist();
  }

  Future<void> acceptOffer(String jobId) async {
    applicationStatus[jobId] = 'hired';
    employedJobIds.add(jobId);
    activeJobId = jobId;
    final BizJobListing? job = BizCareerJobs.byId(jobId);
    if (job != null) hourlyWageCents = job.hourlyWageCents;
    if (careerStage < 3) careerStage = 3;
    notifyListeners();
    await _persist();
  }

  Future<void> declineOffer(String jobId) async {
    applicationStatus[jobId] = 'rejected';
    notifyListeners();
    await _persist();
  }

  Future<void> clockIn(String jobId) async {
    clockedIn = true;
    clockInAtIso = DateTime.now().toIso8601String();
    activeJobId = jobId;
    notifyListeners();
    await _persist();
  }

  Future<void> clockOut() async {
    if (clockedIn && clockInAtIso != null) {
      final DateTime start = DateTime.tryParse(clockInAtIso!) ?? DateTime.now();
      final int minutes =
          DateTime.now().difference(start).inMinutes.clamp(5, 240);
      final int earned = ((minutes / 60.0) * hourlyWageCents).round();
      balanceCents += earned;
      lifetimeEarnedCents += earned;
    }
    clockedIn = false;
    clockInAtIso = null;
    notifyListeners();
    await _persist();
  }

  Future<void> completeWorkTask(
    String taskId, {
    int payCents = 800,
    int xpGain = 25,
  }) async {
    final String key = 'task_$taskId';
    if (workplaceTasksDone.contains(taskId) ||
        completedChallenges.contains(key)) {
      return;
    }
    workplaceTasksDone.add(taskId);
    completedChallenges.add(key);
    balanceCents += payCents;
    lifetimeEarnedCents += payCents;
    await awardXp(xpGain);
  }

  Future<void> startMission(String missionId) async {
    activeMissionId = missionId;
    activeMissionStep = 0;
    notifyListeners();
    await _persist();
  }

  Future<void> setMissionStep(int step) async {
    activeMissionStep = step;
    notifyListeners();
    await _persist();
  }

  Future<void> saveSimState(Map<String, dynamic> state) async {
    lastSimState = state;
    notifyListeners();
    await _persist();
  }

  Future<void> completeMission(
    String missionId, {
    int xpGain = 100,
    List<String> skills = const <String>[],
    List<String>? skillsGained,
    String? badge,
  }) async {
    if (completedMissions.contains(missionId)) {
      activeMissionId = null;
      activeMissionStep = 0;
      notifyListeners();
      await _persist();
      return;
    }
    completedMissions.add(missionId);
    final List<String> gained = skillsGained ?? skills;
    for (final String s in gained) {
      skillLevels[s] = (skillLevels[s] ?? 1) + 1;
    }
    if (badge != null) badges.add(badge);
    if (careerStage < 2) careerStage = 2;
    if (completedMissions.length >= 2 && careerStage < 3) careerStage = 3;
    activeMissionId = null;
    activeMissionStep = 0;
    await awardXp(xpGain);
  }

  bool isMissionComplete(String id) => completedMissions.contains(id);

  static Set<String> _stringSet(dynamic raw) {
    if (raw is! List) return <String>{};
    return raw.map((dynamic e) => '$e').toSet();
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is! Map) return <String, String>{};
    return raw.map(
      (dynamic k, dynamic v) => MapEntry<String, String>('$k', '$v'),
    );
  }

  static List<Map<String, dynamic>> _mapList(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((Map e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
