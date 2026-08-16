import 'package:flutter/material.dart';

import '../career_labs/playable/science/biology/biology_anatomy_3d_lab.dart';
import '../career_labs/playable/science/biology/clinical_viva_quiz_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import 'course_labs_catalog.dart';
import 'winning_career_showcases.dart';
import 'winning_major_showcases.dart';

/// Routes every major to graded workplace practicals — several labs per course.
abstract final class MajorWowRouter {
  static String continueLabel(String majorId) {
    final int n = CourseLabsCatalog.forMajor(majorId).length;
    final String m = majorId.toLowerCase();
    if (m.contains('bio')) return 'Open biology labs ($n)';
    if (m.contains('chem')) return 'Open chemistry labs ($n)';
    if (m.contains('phys')) return 'Open physics labs ($n)';
    if (m.contains('computer') ||
        m == 'cs' ||
        m.startsWith('cs_') ||
        m.contains('software') ||
        m.contains('data_science') ||
        m.contains('artificial')) {
      return 'Open CS labs ($n)';
    }
    if (m.contains('law')) return 'Open law labs ($n)';
    if (m.contains('engin') || m.contains('civil') || m.contains('electric')) {
      return 'Open engineering labs ($n)';
    }
    if (m.contains('nurs')) return 'Open nursing labs ($n)';
    if (m.contains('medicine') || m == 'med') return 'Open medicine labs ($n)';
    if (m.contains('bus')) return 'Open business labs ($n)';
    if (m.contains('fin')) return 'Open finance labs ($n)';
    if (m.contains('account')) return 'Open accounting labs ($n)';
    if (m.contains('market')) return 'Open marketing labs ($n)';
    if (m.contains('econ')) return 'Open economics labs ($n)';
    if (m.contains('pharm')) return 'Open pharmacy labs ($n)';
    if (m.contains('mls') ||
        m.contains('lab_science') ||
        m.contains('medical_lab')) {
      return 'Open MLS labs ($n)';
    }
    if (m.contains('psych')) return 'Open psychology labs ($n)';
    if (m.contains('math')) return 'Open math labs ($n)';
    if (m.contains('cyber')) return 'Open cyber labs ($n)';
    return 'Open course labs ($n)';
  }

  static Future<void> openContinue(
    BuildContext context, {
    required VuV2Session session,
    required VuV2ProgressStore progress,
  }) {
    return CourseLabsCatalog.openCoursePicker(
      context,
      majorId: session.majorId,
      session: session,
      progress: progress,
    );
  }

  static Future<void> openShowcaseForMajor(
    BuildContext context,
    String majorId, {
    VuV2Session? session,
    VuV2ProgressStore? progress,
  }) {
    return CourseLabsCatalog.openCoursePicker(
      context,
      majorId: majorId,
      session: session,
      progress: progress,
    );
  }

  static Future<void> openPrimaryLab(
    BuildContext context,
    String majorId, {
    VuV2Session? session,
    VuV2ProgressStore? progress,
  }) {
    final List<CourseLabEntry> labs = CourseLabsCatalog.forMajor(majorId);
    if (labs.isEmpty) {
      return WinningMajorShowcases.openBusiness(context);
    }
    return labs.first.open(context);
  }

  static Future<void> openStudyQuizHero(
    BuildContext context,
    String majorId,
  ) {
    final String m = majorId.toLowerCase();
    if (m.contains('bio')) {
      return ClinicalVivaQuizScreen.open(context);
    }
    return openShowcaseForMajor(context, majorId);
  }

  static String studyQuizTitle(String majorId) {
    final String m = majorId.toLowerCase();
    if (m.contains('bio')) return 'Clinical Viva Quiz';
    if (m.contains('chem')) return 'Chemistry labs';
    if (m.contains('phys')) return 'Physics labs';
    if (m.contains('computer') || m == 'cs' || m.startsWith('cs_')) {
      return 'CS labs';
    }
    if (m.contains('law')) return 'Law labs';
    if (m.contains('nurs')) return 'Nursing labs';
    if (m.contains('medicine')) return 'Medicine labs';
    if (m.contains('bus')) return 'Business labs';
    return 'Course labs';
  }

  static String studyQuizBody(String majorId) {
    final int n = CourseLabsCatalog.forMajor(majorId).length;
    return '$n working practicals for your course — pick one and earn a board score.';
  }

  static String labsHeroTitle(String majorId) {
    final int n = CourseLabsCatalog.forMajor(majorId).length;
    return '$n labs for your major — board practicals, benches, and workplaces';
  }

  static Widget? showcaseForLabId(String labId) {
    switch (labId.toLowerCase()) {
      case 'biology':
        return const BiologyAnatomy3dLab(
          caseId: 'shoulder_scapula',
          missionMode: true,
        );
      case 'chemistry':
        return const ChemistryTitrationShowcaseLab();
      case 'physics':
        return const PhysicsEnergyShowcaseLab();
      case 'computer_science':
      case 'cs_career':
        return const CsIncidentShowcaseLab();
      case 'law_firm':
        return const LawCaseShowcaseLab();
      case 'engineering':
      case 'civil_engineering':
      case 'electrical_engineering':
        return const EngineeringBridgeShowcaseLab();
      case 'nursing_ed':
        return const NursingTriageShowcaseLab();
      case 'medicine':
        return const MedicineDifferentialShowcaseLab();
      case 'business':
        return const BusinessWarRoomShowcaseLab();
      case 'finance':
        return const FinanceDeskShowcaseLab();
      case 'accounting':
        return const AccountingAuditShowcaseLab();
      case 'marketing':
        return const MarketingCampaignShowcaseLab();
      case 'economics':
        return const EconomicsPolicyShowcaseLab();
      case 'pharmacy':
        return const PharmacyRxShowcaseLab();
      case 'medical_lab_science':
        return const MlsCriticalShowcaseLab();
      case 'psychology':
        return const PsychologyMethodsShowcaseLab();
      case 'mathematics':
        return const MathModelShowcaseLab();
      case 'cybersecurity':
        return const CyberSocShowcaseLab();
      default:
        return null;
    }
  }
}
