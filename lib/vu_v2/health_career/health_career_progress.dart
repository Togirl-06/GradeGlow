import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'health_career_content.dart';

/// Local progress for Medical Simulation Hub (isolated from lesson enrollment).
class HealthCareerProgress extends ChangeNotifier {
  HealthCareerProgress();

  static const String _key = 'health_career_progress_v1';
  static HealthCareerProgress? _instance;
  static HealthCareerProgress get instance =>
      _instance ??= HealthCareerProgress();

  bool loaded = false;
  String courseId = 'nursing';
  int xp = 0;
  int level = 1;
  final Set<String> completedScenarios = <String>{};
  final Set<String> completedSkills = <String>{};
  final Set<String> identifiedStructures = <String>{};
  final Set<String> badges = <String>{};
  final Map<String, int> scenarioScores = <String, int>{};
  String? recommendedNext;

  int get xpIntoLevel => xp % 2000;
  int get xpToNextLevel => 2000;
  HealthProgram get program => HealthPrograms.byId(courseId);

  int get simulationsCompleted => completedScenarios.length;

  Future<void> ensureLoaded() async {
    if (loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(raw) as Map);
        courseId = data['courseId'] as String? ?? courseId;
        xp = data['xp'] as int? ?? 0;
        level = data['level'] as int? ?? ((xp ~/ 2000) + 1);
        recommendedNext = data['recommendedNext'] as String?;
        completedScenarios
          ..clear()
          ..addAll(_stringSet(data['completedScenarios']));
        completedSkills
          ..clear()
          ..addAll(_stringSet(data['completedSkills']));
        identifiedStructures
          ..clear()
          ..addAll(_stringSet(data['identifiedStructures']));
        badges
          ..clear()
          ..addAll(_stringSet(data['badges']));
        final Map<String, dynamic>? scores =
            data['scenarioScores'] as Map<String, dynamic>?;
        if (scores != null) {
          scenarioScores
            ..clear()
            ..addAll(
              scores.map(
                (String k, dynamic v) =>
                    MapEntry<String, int>(k, (v as num?)?.toInt() ?? 0),
              ),
            );
        }
      } catch (_) {}
    }
    loaded = true;
    _refreshRecommended();
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'courseId': courseId,
        'xp': xp,
        'level': level,
        'recommendedNext': recommendedNext,
        'completedScenarios': completedScenarios.toList(),
        'completedSkills': completedSkills.toList(),
        'identifiedStructures': identifiedStructures.toList(),
        'badges': badges.toList(),
        'scenarioScores': scenarioScores,
      }),
    );
  }

  void _refreshRecommended() {
    switch (courseId) {
      case 'medicine':
        recommendedNext = completedScenarios.contains('medicine_consult_v1')
            ? 'Review My Performance'
            : 'Medicine consultation — Jamal Reed';
      case 'public_health':
        recommendedNext = completedScenarios.contains('ph_outbreak_v1')
            ? 'Review My Performance'
            : 'Public Health outbreak simulation';
      case 'nutrition':
        recommendedNext = completedScenarios.contains('nutrition_clinic_v1')
            ? 'Review My Performance'
            : 'Nutrition clinic meal plan';
      case 'pharmacy_fundamentals':
        recommendedNext = completedScenarios.contains('pharmacy_dispense_v1')
            ? 'Review My Performance'
            : 'Pharmacy dispense & counseling';
      case 'healthcare_management':
        recommendedNext = completedScenarios.contains('hm_ops_v1')
            ? 'Review My Performance'
            : 'Hospital operations day';
      case 'medical_lab_science':
        recommendedNext =
            completedScenarios.contains('mls_cbc_v1')
                ? (completedScenarios.contains('mls_ua_v1')
                    ? 'Review My Performance'
                    : 'Medical lab — urinalysis')
                : 'Medical lab — CBC critical value';
      case 'anatomy_physiology':
        recommendedNext = identifiedStructures.length < 4
            ? 'Explore Human Anatomy — identify 4 structures'
            : 'Review My Performance';
      default:
        if (!completedScenarios.contains('nursing_dyspnea_v1')) {
          recommendedNext = 'Start clinical case: Acute dyspnea';
        } else if (identifiedStructures.length < 4) {
          recommendedNext = 'Explore Human Anatomy — identify 4 structures';
        } else if (!completedSkills.contains('vitals_kit')) {
          recommendedNext = 'Practice Clinical Skills — vitals kit';
        } else {
          recommendedNext = 'Review My Performance';
        }
    }
  }

  Future<void> setCourse(String id) async {
    courseId = HealthPrograms.normalizeId(id);
    _refreshRecommended();
    notifyListeners();
    await _persist();
  }

  Future<void> awardXp(int amount, {String? badge}) async {
    xp = (xp + amount).clamp(0, 1000000);
    level = (xp ~/ 2000) + 1;
    if (badge != null) badges.add(badge);
    _refreshRecommended();
    notifyListeners();
    await _persist();
  }

  Future<void> completeScenario(
    String id, {
    required int score,
    int xpGain = 100,
  }) async {
    completedScenarios.add(id);
    scenarioScores[id] = score;
    await awardXp(xpGain, badge: score >= 80 ? 'clinical_high_score' : null);
  }

  Future<void> markStructure(String id) async {
    if (identifiedStructures.add(id)) {
      await awardXp(8);
    } else {
      notifyListeners();
    }
  }

  Future<void> completeSkill(String id, {int xpGain = 40}) async {
    if (!completedSkills.add(id)) return;
    await awardXp(xpGain, badge: 'skill_$id');
  }

  static Set<String> _stringSet(dynamic raw) {
    if (raw is! List) return <String>{};
    return raw.map((dynamic e) => '$e').toSet();
  }
}
