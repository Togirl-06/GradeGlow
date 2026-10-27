/// Every learning station inside a GradeGlow school building.
///
/// A station in the 3D/2D world is an [Interactable] with
/// `type: ActionType.openLab` and `arg: <lab id>`. Walking up to it and using
/// it opens the real GradeGlow activity for that major (most already existed in
/// the app as separate menus; the campus puts them in physical places).
library;

import 'package:flutter/material.dart';

import '../../screens/business/business_school_screen.dart';
import '../../screens/chemistry/chemistry_degree_home_screen.dart';
import '../../screens/english/english_program_screen.dart';
import '../../screens/law/law_program_screen.dart';
import '../../screens/mathematics/mathematics_degree_home_screen.dart';
import '../../screens/physics/physics_practical_lab_hub_screen.dart';
import '../../vu_v2/business_career/business_career_hub_screen.dart';
import '../../vu_v2/career_labs/playable/economics/economics_playable.dart';
import '../../vu_v2/career_labs/playable/law/law_interview_screen.dart';
import '../../vu_v2/career_labs/playable/law/law_workplace_screen.dart';
import '../../vu_v2/career_labs/playable/mathematics/mathematics_playable.dart';
import '../../vu_v2/career_labs/playable/medicine/medicine_lab1_interview.dart';
import '../../vu_v2/career_labs/playable/medicine/medicine_lab2_differential.dart';
import '../../vu_v2/career_labs/playable/nursing/nursing_lab1_shift.dart';
import '../../vu_v2/career_labs/playable/nursing/nursing_lab2_assessment.dart';
import '../../vu_v2/career_labs/playable/pharmacy/pharmacy_lab1_verify.dart';
import '../../vu_v2/career_labs/playable/pharmacy/pharmacy_lab2_counsel.dart';
import '../../vu_v2/career_labs/playable/psychology/psychology_playable.dart';
import '../../vu_v2/career_labs/playable/science/biology/anatomy_3d_viewer_screen.dart';
import '../../vu_v2/career_labs/playable/science/biology/biology_lab_home.dart';
import '../../vu_v2/career_labs/playable/science/chemistry/chemistry_lab_home.dart';
import '../../vu_v2/career_labs/playable/science/physics/physics_lab_home.dart';
import '../../vu_v2/engineering_career/engineering_career_hub_screen.dart';
import '../../vu_v2/game/career/vu_career_world_router.dart';
import '../../vu_v2/health_career/health_career_progress.dart';
import '../../vu_v2/health_career/health_simulation_hub_screen.dart';
import '../../vu_v2/health_career/medicine_consultation_screen.dart';
import '../../vu_v2/health_career/nursing_clinical_case_screen.dart';
import '../../vu_v2/labs/vu_v2_cs_coding_arena.dart';
import '../../vu_v2/science_career/science_career_hub_screen.dart';
import 'lab_info.dart';
import 'real_case_center_screen.dart';

/// A school station plus the screen it opens.
class CampusLab {
  const CampusLab(this.info, this.open);
  final LabInfo info;
  final Future<void> Function(BuildContext context) open;

  String get id => info.id;
  String get name => info.name;
  String get emoji => info.emoji;
  String get hint => info.hint;
  String get skill => info.skill;
}

Future<void> _go(BuildContext c, Widget screen) => Navigator.of(c).push<void>(MaterialPageRoute<void>(builder: (_) => screen));

Future<void> _health(BuildContext c, Widget Function(HealthCareerProgress p) build) async {
  final HealthCareerProgress p = HealthCareerProgress.instance;
  await p.ensureLoaded();
  if (!c.mounted) return;
  await _go(c, build(p));
}

abstract final class CampusLabs {
  /// Lab id → the existing GradeGlow activity it opens.
  static final Map<String, Future<void> Function(BuildContext c)> _open = <String, Future<void> Function(BuildContext c)>{
    'cs_arena': (BuildContext c) => _go(c, const VuV2CsCodingArenaScreen()),
    'cs_software': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'software_engineering')),
    'cs_ai': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'ai_ml')),
    'cs_data': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'data_science')),
    'cs_cyber': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'cybersecurity')),
    'cs_it': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'information_technology')),
    'cs_web': (BuildContext c) => _go(c, const ScienceCareerHubScreen(initialMajorId: 'web_development')),
    'cs_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'computer_science'),
    'med_anatomy': (BuildContext c) => _go(c, const Anatomy3dViewerHubScreen()),
    'med_history': (BuildContext c) => _go(c, const MedicineLab1InterviewScreen()),
    'med_diagnosis': (BuildContext c) => _go(c, const MedicineLab2DifferentialScreen()),
    'med_clinic': (BuildContext c) => _health(c, (HealthCareerProgress p) => MedicineConsultationScreen(progress: p)),
    'med_labsci': (BuildContext c) => _go(c, const HealthSimulationHubScreen(initialCourseId: 'medical_lab_science')),
    'med_pharmacy': (BuildContext c) => _go(c, const PharmacyLab2CounselScreen()),
    'med_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'medicine'),
    'nurse_ward': (BuildContext c) => _go(c, const NursingLab1ShiftScreen()),
    'nurse_assess': (BuildContext c) => _go(c, const NursingLab2AssessmentScreen()),
    'nurse_case': (BuildContext c) => _health(c, (HealthCareerProgress p) => NursingClinicalCaseScreen(progress: p)),
    'nurse_anatomy': (BuildContext c) => _go(c, const Anatomy3dViewerHubScreen()),
    'nurse_public': (BuildContext c) => _go(c, const HealthSimulationHubScreen(initialCourseId: 'public_health')),
    'nurse_meds': (BuildContext c) => _go(c, const PharmacyLab1VerifyScreen()),
    'nurse_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'nursing'),
    'law_real_cases': (BuildContext c) => _go(c, const RealCaseCenterScreen()),
    'law_school': (BuildContext c) => _go(c, const LawProgramScreen()),
    'law_client': (BuildContext c) => _go(c, const LawInterviewScreen()),
    'law_firm': (BuildContext c) => _go(c, const LawWorkplaceScreen()),
    'law_court': (BuildContext c) => VuCareerWorldRouter.openById(c, 'law'),
    'eng_mech': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'mechanical_engineering')),
    'eng_civil': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'civil_engineering')),
    'eng_elec': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'electrical_engineering')),
    'eng_chem': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'chemical_engineering')),
    'eng_aero': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'aerospace_engineering')),
    'eng_industrial': (BuildContext c) => _go(c, const EngineeringCareerHubScreen(initialMajorId: 'industrial_engineering')),
    'eng_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'engineering'),
    'biz_hq': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'business_administration')),
    'biz_accounting': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'accounting')),
    'biz_finance': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'finance')),
    'biz_marketing': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'marketing')),
    'biz_hr': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'human_resource_management')),
    'biz_startup': (BuildContext c) => _go(c, const BusinessCareerHubScreen(initialMajorId: 'entrepreneurship')),
    'econ_policy': (BuildContext c) => _go(c, const EconomicsPlayableScreen()),
    'biz_school': (BuildContext c) => _go(c, const BusinessSchoolScreen()),
    'math_whiteboard': (BuildContext c) => _go(c, const MathematicsDegreeHomeScreen()),
    'math_applied': (BuildContext c) => _go(c, const MathematicsPlayableScreen()),
    'math_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'math'),
    'arts_writing': (BuildContext c) => _go(c, const EnglishProgramScreen()),
    'arts_psych': (BuildContext c) => _go(c, const PsychologyPlayableScreen()),
    'arts_newsroom': (BuildContext c) => VuCareerWorldRouter.openById(c, 'english'),
    'bio_lab': (BuildContext c) => _go(c, const BiologyLabHomeScreen()),
    'bio_anatomy': (BuildContext c) => _go(c, const Anatomy3dViewerHubScreen()),
    'bio_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'biology'),
    'chem_bench': (BuildContext c) => _go(c, const ChemistryLabHome()),
    'chem_lessons': (BuildContext c) => _go(c, const ChemistryDegreeHomeScreen()),
    'chem_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'chemistry'),
    'phys_lab': (BuildContext c) => _go(c, const PhysicsLabHome()),
    'phys_practical': (BuildContext c) => _go(c, const PhysicsPracticalLabHubScreen()),
    'phys_career': (BuildContext c) => VuCareerWorldRouter.openById(c, 'physics'),
  };

  static CampusLab? byId(String id) {
    final LabInfo? info = labInfo(id);
    final Future<void> Function(BuildContext c)? open = _open[id];
    if (info == null || open == null) return null;
    return CampusLab(info, open);
  }

  /// Every lab that has both metadata and a screen (used by tests).
  static List<CampusLab> get all => <CampusLab>[
        for (final LabInfo i in kCampusLabs)
          if (_open[i.id] != null) CampusLab(i, _open[i.id]!),
      ];
}
