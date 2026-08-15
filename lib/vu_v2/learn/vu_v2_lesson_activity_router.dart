import 'package:flutter/material.dart';

import '../../data/university_learning_engine.dart';
import '../career_labs/career_lab_home_screen.dart';
import '../career_labs/playable/engineering/engineering_playable.dart';
import '../career_labs/playable/law/law_playable.dart';
import '../career_labs/playable/playable_router.dart';
import '../career_labs/playable/science/biology/biology_anatomy_3d_lab.dart';
import '../career_labs/playable/science/biology/biology_lab_home.dart';
import '../career_labs/playable/science/chemistry/chemistry_lab_home.dart';
import '../career_labs/playable/science/physics/physics_lab_home.dart';
import '../labs/major_wow_router.dart';
import '../labs/university_lab_briefing.dart';
import '../labs/university_lab_result.dart';
import '../labs/university_practical/practical_catalog.dart';
import '../labs/university_practical/practical_mission.dart';
import '../labs/university_practical/university_practical_lab.dart';
import '../labs/vu_v2_cs_coding_arena.dart';
import '../labs/winning_career_showcases.dart';
import '../labs/winning_major_showcases.dart';

/// Routes students through the university learning loop: lecture → lab → debrief.
abstract final class VuV2LessonActivityRouter {
  static UniversityLabLink? linkedLab({
    required String subjectId,
    required String lessonTitle,
    String? moduleTitle,
  }) {
    return UniversityLearningEngine.labForLesson(
      subjectId: subjectId,
      lessonTitle: lessonTitle,
      moduleTitle: moduleTitle,
    );
  }

  static Future<UniversityLabResult?> _pushResult(
    BuildContext context,
    Widget screen,
  ) async {
    final Object? raw = await Navigator.of(context).push<Object>(
      MaterialPageRoute<Object>(builder: (_) => screen),
    );
    return raw is UniversityLabResult ? raw : null;
  }

  static Future<UniversityLabResult?> openLinkedLab({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
  }) async {
    final bool enter = await showUniversityLabBriefing(
      context: context,
      link: link,
      subjectId: subjectId,
    );
    if (!enter || !context.mounted) return null;

    UniversityLabResult? result;

    // Prefer graded interactive showcase whenever one exists for this lab.
    final Widget? showcase = MajorWowRouter.showcaseForLabId(link.labId);
    if (showcase != null &&
        (link.stationId == 'practical' ||
            link.stationId == 'anatomy_3d' ||
            link.stationId == 'titration' ||
            link.stationId == 'energy')) {
      result = await _pushResult(context, showcase);
    } else {
      switch (link.labId) {
        case 'biology':
          if (link.stationId == 'anatomy_3d' || link.stationId == 'practical') {
            result = await _pushResult(
              context,
              const BiologyAnatomy3dLab(
                caseId: 'shoulder_scapula',
                missionMode: true,
              ),
            );
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => BiologyLabHomeScreen(
                  initialStationId: link.stationId,
                ),
              ),
            );
            result = _benchVisitResult('Biology bench visit complete.');
          }
        case 'chemistry':
          if (link.stationId == 'titration' || link.stationId == 'practical') {
            result = await _pushResult(
              context,
              const ChemistryTitrationShowcaseLab(),
            );
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => ChemistryLabHome(
                  initialStationId: link.stationId,
                ),
              ),
            );
            result = _benchVisitResult('Chemistry station completed.');
          }
        case 'physics':
          if (link.stationId == 'energy' || link.stationId == 'practical') {
            result = await _pushResult(
              context,
              const PhysicsEnergyShowcaseLab(),
            );
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => PhysicsLabHome(
                  initialStationId: link.stationId,
                ),
              ),
            );
            result = _benchVisitResult('Physics station completed.');
          }
        case 'computer_science':
          if (link.stationId == 'practical') {
            result = await _pushResult(context, const CsIncidentShowcaseLab());
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const VuV2CsCodingArenaScreen(title: 'Coding Lab'),
              ),
            );
            result = _benchVisitResult('Coding arena session logged.');
          }
        case 'law_firm':
          if (link.stationId == 'practical') {
            result = await _pushResult(context, const LawCaseShowcaseLab());
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => lawPlayableScreen()),
            );
            result = _benchVisitResult('Law firm floor visit logged.');
          }
        case 'engineering':
        case 'civil_engineering':
        case 'electrical_engineering':
          if (link.stationId == 'practical') {
            result =
                await _pushResult(context, const EngineeringBridgeShowcaseLab());
          } else {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => engineeringPlayableScreen(),
              ),
            );
            result = _benchVisitResult('Engineering studio visit logged.');
          }
        default:
          final Widget? again = MajorWowRouter.showcaseForLabId(link.labId);
          if (again != null) {
            result = await _pushResult(context, again);
          } else {
            final Widget? playable = playableScreenFor(link.labId);
            if (playable != null) {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => playable),
              );
              result = _benchVisitResult('Workplace simulation completed.');
            } else {
              final UniversityPracticalMission? mission =
                  UniversityPracticalCatalog.forCourse(link.labId) ??
                      UniversityPracticalCatalog.forCourse(subjectId);
              if (mission != null) {
                result = await UniversityPracticalLabScreen.open(
                  context,
                  mission: mission,
                );
              } else {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => CareerLabHomeScreen(labId: link.labId),
                  ),
                );
                result = _benchVisitResult('Career lab visit logged.');
              }
            }
          }
      }
    }

    if (!context.mounted) return result;
    await showUniversityLabDebrief(
      context: context,
      link: link,
      subjectId: subjectId,
      result: result,
    );
    return result;
  }

  static UniversityLabResult _benchVisitResult(String note) {
    return UniversityLabResult(
      accuracy: 0.72,
      identifyCorrect: 1,
      identifyAttempts: 1,
      viewsVisited: 2,
      labelDrillComplete: true,
      coachingNotes: <String>[note, 'Return for the graded board viva next.'],
      xpEarned: 90,
      clinicalSolved: false,
      clinicalReasoningScore: 0.5,
    );
  }
}
