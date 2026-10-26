import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engineering_career_content.dart';

/// Persistent School of Engineering career-sim progress.
class EngineeringCareerProgress extends ChangeNotifier {
  EngineeringCareerProgress();

  static const String _key = 'engineering_career_progress_v1';
  static EngineeringCareerProgress? _instance;
  static EngineeringCareerProgress get instance =>
      _instance ??= EngineeringCareerProgress();

  bool loaded = false;
  String majorId = 'mechanical_engineering';
  int xp = 0;
  int level = 1;
  int careerStage = 1;
  int balanceCents = 0;
  int lifetimeEarnedCents = 0;
  int hourlyWageCents = 2800;
  bool clockedIn = false;
  String? clockInAtIso;
  String? activeJobId;

  /// Avatar customization (matches career-sim mockup).
  int avatarJacket = 0; // 0 blue, 1 navy, 2 orange
  int avatarHair = 0; // 0 dark, 1 brown, 2 blonde
  int avatarSkin = 0; // 0 light, 1 medium, 2 deep

  /// Continue Playing / mission-of-the-day.
  String? activeMissionId;
  int activeMissionStep = 0; // 0–3 for robotic arm flow
  String? missionOfDayId;
  String? missionOfDayDate;

  final Set<String> completedMissions = <String>{};
  final Set<String> badges = <String>{};
  final Set<String> skills = <String>{'Statics', 'Units', 'Safety factors'};
  final Map<String, int> skillLevels = <String, int>{
    'Statics': 1,
    'Torque': 1,
    'Systems': 1,
  };

  /// missionId → last design JSON
  final Map<String, Map<String, dynamic>> designs =
      <String, Map<String, dynamic>>{};
  final List<Map<String, dynamic>> interviewHistory = <Map<String, dynamic>>[];
  bool interviewPassed = false;

  /// jobId → applied | interviewed | offered | hired | rejected
  final Map<String, String> applicationStatus = <String, String>{};
  final Set<String> employedJobIds = <String>{};
  final Set<String> workplaceTasksDone = <String>{};

  String get balanceLabel =>
      '\$${(balanceCents / 100.0).toStringAsFixed(2)}';
  String get lifetimeEarnedLabel =>
      '\$${(lifetimeEarnedCents / 100.0).toStringAsFixed(2)}';

  String get stageLabel => switch (careerStage) {
        1 => 'Student',
        2 => 'Intern',
        3 => 'Junior Engineer',
        4 => 'Mid-Level Engineer',
        5 => 'Senior Engineer',
        6 => 'Engineering Lead',
        _ => 'Specialist',
      };

  int get xpIntoLevel => xp % 2000;
  int get xpToNextLevel => 2000;
  bool get hasAnyJob => employedJobIds.isNotEmpty;
  bool get employedAtApex =>
      employedJobIds.contains('apex_mech_junior') ||
      statusFor('apex_mech_junior') == 'hired';

  /// Jobs the student has applied to (or further).
  Set<String> get appliedJobIds => applicationStatus.entries
      .where(
        (MapEntry<String, String> e) =>
            e.value == 'applied' ||
            e.value == 'interviewed' ||
            e.value == 'offered' ||
            e.value == 'hired',
      )
      .map((MapEntry<String, String> e) => e.key)
      .toSet();

  bool get hasStartedWork =>
      clockedIn ||
      lifetimeEarnedCents > 0 ||
      workplaceTasksDone.isNotEmpty;

  String jobActionLabel({String? jobId}) {
    if (!hasAnyJob) return 'Start job';
    if (clockedIn) return 'Continue shift';
    if (hasStartedWork) return 'Continue job';
    return 'Start job';
  }

  String statusFor(String jobId) =>
      applicationStatus[jobId] ?? 'none';

  Future<void> ensureLoaded() async {
    if (loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        majorId = data['majorId'] as String? ?? majorId;
        xp = data['xp'] as int? ?? 0;
        level = data['level'] as int? ?? ((xp ~/ 2000) + 1);
        careerStage = data['careerStage'] as int? ?? 1;
        balanceCents = data['balanceCents'] as int? ?? 0;
        lifetimeEarnedCents = data['lifetimeEarnedCents'] as int? ?? 0;
        hourlyWageCents = data['hourlyWageCents'] as int? ?? 2800;
        clockedIn = data['clockedIn'] as bool? ?? false;
        clockInAtIso = data['clockInAtIso'] as String?;
        activeJobId = data['activeJobId'] as String?;
        interviewPassed = data['interviewPassed'] as bool? ?? false;
        avatarJacket = data['avatarJacket'] as int? ?? 0;
        avatarHair = data['avatarHair'] as int? ?? 0;
        avatarSkin = data['avatarSkin'] as int? ?? 0;
        activeMissionId = data['activeMissionId'] as String?;
        activeMissionStep = data['activeMissionStep'] as int? ?? 0;
        missionOfDayId = data['missionOfDayId'] as String?;
        missionOfDayDate = data['missionOfDayDate'] as String?;
        completedMissions
          ..clear()
          ..addAll(_stringSet(data['completedMissions']));
        badges
          ..clear()
          ..addAll(_stringSet(data['badges']));
        skills
          ..clear()
          ..addAll(_stringSet(data['skills']));
        if (skills.isEmpty) {
          skills.addAll(<String>['Statics', 'Units', 'Safety factors']);
        }
        employedJobIds
          ..clear()
          ..addAll(_stringSet(data['employedJobIds']));
        workplaceTasksDone
          ..clear()
          ..addAll(_stringSet(data['workplaceTasksDone']));
        applicationStatus
          ..clear()
          ..addAll(_stringMap(data['applicationStatus']));
        designs
          ..clear()
          ..addAll(_draftMap(data['designs']));
        final Object? levels = data['skillLevels'];
        if (levels is Map) {
          skillLevels
            ..clear()
            ..addAll(
              levels.map(
                (Object? k, Object? v) =>
                    MapEntry<String, int>('$k', int.tryParse('$v') ?? 1),
              ),
            );
        }
        interviewHistory
          ..clear()
          ..addAll(
            ((data['interviewHistory'] as List?) ?? <dynamic>[])
                .whereType<Map>()
                .map((Map e) => Map<String, dynamic>.from(e)),
          );
      } catch (e) {
        debugPrint('EngineeringCareerProgress load failed: $e');
      }
    }
    _rollMissionOfDay();
    loaded = true;
    notifyListeners();
  }

  Set<String> _stringSet(Object? raw) {
    if (raw is! List) return <String>{};
    return raw.map((Object? e) => '$e').toSet();
  }

  Map<String, String> _stringMap(Object? raw) {
    if (raw is! Map) return <String, String>{};
    return raw.map(
      (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
    );
  }

  Map<String, Map<String, dynamic>> _draftMap(Object? raw) {
    if (raw is! Map) return <String, Map<String, dynamic>>{};
    return raw.map(
      (Object? k, Object? v) => MapEntry<String, Map<String, dynamic>>(
        '$k',
        v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
      ),
    );
  }

  Future<void> _save() async {
    level = (xp ~/ 2000) + 1;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
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
        'completedMissions': completedMissions.toList(),
        'badges': badges.toList(),
        'skills': skills.toList(),
        'skillLevels': skillLevels,
        'designs': designs,
        'interviewHistory': interviewHistory,
        'interviewPassed': interviewPassed,
        'applicationStatus': applicationStatus,
        'employedJobIds': employedJobIds.toList(),
        'workplaceTasksDone': workplaceTasksDone.toList(),
        'avatarJacket': avatarJacket,
        'avatarHair': avatarHair,
        'avatarSkin': avatarSkin,
        'activeMissionId': activeMissionId,
        'activeMissionStep': activeMissionStep,
        'missionOfDayId': missionOfDayId,
        'missionOfDayDate': missionOfDayDate,
      }),
    );
    notifyListeners();
  }

  void _rollMissionOfDay() {
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    if (missionOfDayDate == today && missionOfDayId != null) return;
    missionOfDayDate = today;
    final List<EngMission> pool = EngMissionCatalog.forMajor(majorId);
    if (pool.isEmpty) {
      missionOfDayId = EngMissionCatalog.roboticArm.id;
    } else {
      missionOfDayId = pool[DateTime.now().day % pool.length].id;
    }
  }

  EngMission get missionOfDay {
    _rollMissionOfDay();
    return EngMissionCatalog.byId(missionOfDayId ?? '') ??
        EngMissionCatalog.roboticArm;
  }

  bool get hasActiveMission =>
      activeMissionId != null &&
      activeMissionId!.isNotEmpty &&
      !completedMissions.contains(activeMissionId);

  Future<void> setMajor(String id) async {
    majorId = id;
    _rollMissionOfDay();
    await _save();
  }

  Future<void> startMission(String id, {int step = 0}) async {
    activeMissionId = id;
    activeMissionStep = step;
    await _save();
  }

  Future<void> setMissionStep(int step) async {
    activeMissionStep = step.clamp(0, 10);
    await _save();
  }

  Future<void> clearActiveMission() async {
    activeMissionId = null;
    activeMissionStep = 0;
    await _save();
  }

  Future<void> setAvatar({int? jacket, int? hair, int? skin}) async {
    if (jacket != null) avatarJacket = jacket.clamp(0, 2);
    if (hair != null) avatarHair = hair.clamp(0, 2);
    if (skin != null) avatarSkin = skin.clamp(0, 2);
    await _save();
  }

  Future<void> awardXp(int amount, {String? badge, int payCents = 0}) async {
    xp = (xp + amount).clamp(0, 1000000);
    if (payCents > 0) {
      balanceCents += payCents;
      lifetimeEarnedCents += payCents;
    }
    if (badge != null) badges.add(badge);
    await _save();
  }

  Future<void> saveDesign(
    String missionId,
    Map<String, dynamic> design,
  ) async {
    designs[missionId] = Map<String, dynamic>.from(design);
    await _save();
  }

  Map<String, dynamic> designFor(String missionId) =>
      Map<String, dynamic>.from(designs[missionId] ?? <String, dynamic>{});

  bool isMissionComplete(String id) => completedMissions.contains(id);

  Future<bool> completeMission(
    String id, {
    int xpGain = 100,
    int payCents = 500,
    List<String> skillTags = const <String>[],
  }) async {
    if (!completedMissions.add(id)) return false;
    for (final String s in skillTags) {
      skills.add(s);
      skillLevels[s] = (skillLevels[s] ?? 1) + 1;
    }
    if (careerStage < 2) careerStage = 2;
    if (activeMissionId == id) {
      activeMissionId = null;
      activeMissionStep = 0;
    }
    await awardXp(xpGain, badge: 'mission_$id', payCents: payCents);
    return true;
  }

  Future<void> recordInterview({
    required bool passed,
    String? forJobId,
  }) async {
    interviewHistory.insert(0, <String, dynamic>{
      'at': DateTime.now().toIso8601String(),
      'passed': passed,
      if (forJobId != null) 'forJobId': forJobId,
    });
    if (passed) {
      interviewPassed = true;
      if (forJobId != null && statusFor(forJobId) == 'applied') {
        applicationStatus[forJobId] = 'interviewed';
      }
      skills.add('Technical interview');
      await awardXp(40, badge: 'eng_interview_pass');
    } else {
      await _save();
    }
  }

  /// Apply → must complete mission first for Apex junior mech role.
  Future<String?> applyToJob(String jobId) async {
    final EngJob? job = EngJobs.byId(jobId);
    if (job == null) return 'Unknown job.';
    final String st = statusFor(jobId);
    if (st == 'hired' || st == 'offered' || st == 'applied' || st == 'interviewed') {
      return 'Already in progress for this role.';
    }
    if (job.majorId == 'mechanical_engineering' &&
        jobId.startsWith('apex') &&
        !isMissionComplete(EngMissionCatalog.roboticArm.id)) {
      return 'Complete the Robotic arm lift check mission in Challenge Arena first.';
    }
    final List<EngMission> majorMissions =
        EngMissionCatalog.forMajor(job.majorId);
    final bool majorMissionDone = majorMissions.any(
      (EngMission m) => isMissionComplete(m.id),
    );
    final bool ready =
        majorMissionDone || completedMissions.isNotEmpty || interviewPassed;
    if (!ready) {
      return 'Complete at least one ${job.majorId.replaceAll('_', ' ')} mission before applying.';
    }
    applicationStatus[jobId] = 'applied';
    await awardXp(15, badge: 'applied_$jobId');
    return null;
  }

  Future<bool> advanceAfterInterview(String jobId, {required bool passed}) async {
    if (statusFor(jobId) != 'applied' && statusFor(jobId) != 'interviewed') {
      return false;
    }
    await recordInterview(passed: passed, forJobId: jobId);
    if (!passed) {
      applicationStatus[jobId] = 'rejected';
      await _save();
      return false;
    }
    applicationStatus[jobId] = 'offered';
    await awardXp(80, badge: 'offer_$jobId');
    return true;
  }

  Future<bool> acceptOffer(String jobId) async {
    if (statusFor(jobId) != 'offered') return false;
    applicationStatus[jobId] = 'hired';
    employedJobIds.add(jobId);
    careerStage = 3;
    final EngJob? job = EngJobs.byId(jobId);
    if (job != null) {
      // Mid of pay band ≈ $30/hr for Apex
      hourlyWageCents = jobId.startsWith('apex') ? 3000 : 2800;
    }
    await awardXp(120, badge: 'hired_$jobId', payCents: 0);
    return true;
  }

  Future<bool> declineOffer(String jobId) async {
    if (statusFor(jobId) != 'offered') return false;
    applicationStatus[jobId] = 'rejected';
    await _save();
    return true;
  }

  Future<bool> clockIn({String? jobId}) async {
    if (!hasAnyJob) return false;
    if (clockedIn) return false;
    clockedIn = true;
    clockInAtIso = DateTime.now().toIso8601String();
    activeJobId = jobId ?? employedJobIds.first;
    await _save();
    return true;
  }

  Future<int> clockOut() async {
    if (!clockedIn || clockInAtIso == null) return 0;
    final DateTime start = DateTime.tryParse(clockInAtIso!) ?? DateTime.now();
    double hours = DateTime.now().difference(start).inSeconds / 3600.0;
    if (hours < 0.25) hours = 0.25;
    if (hours > 8) hours = 8;
    final int earned = (hours * hourlyWageCents).round();
    balanceCents += earned;
    lifetimeEarnedCents += earned;
    clockedIn = false;
    clockInAtIso = null;
    activeJobId = null;
    await _save();
    return earned;
  }

  Future<bool> completeWorkplaceTask(String taskId, {int xpGain = 100}) async {
    if (!clockedIn) return false;
    if (!workplaceTasksDone.add(taskId)) return false;
    skillLevels['Systems'] = (skillLevels['Systems'] ?? 1) + 1;
    await awardXp(xpGain, badge: 'task_$taskId', payCents: 1200);
    return true;
  }
}
