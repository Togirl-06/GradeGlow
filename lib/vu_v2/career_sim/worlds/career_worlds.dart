import '../career_sim_models.dart';
import 'accounting_world.dart';
import 'biology_world.dart';
import 'business_world.dart';
import 'chemistry_world.dart';
import 'civil_engineering_world.dart';
import 'cs_career_world.dart';
import 'cybersecurity_world.dart';
import 'economics_world.dart';
import 'electrical_engineering_world.dart';
import 'engineering_world.dart';
import 'finance_world.dart';
import 'law_firm_world.dart';
import 'marketing_world.dart';
import 'mathematics_world.dart';
import 'medical_lab_science_world.dart';
import 'medicine_world.dart';
import 'nursing_ed_world.dart';
import 'pharmacy_world.dart';
import 'physics_world.dart';
import 'psychology_world.dart';

/// Lookup table for every Career Lab world.
CareerWorld? careerWorldById(String id) {
  switch (id) {
    case LawFirmWorld.worldId:
      return LawFirmWorld.build();
    case NursingEdWorld.worldId:
      return NursingEdWorld.build();
    case MedicineWorld.worldId:
      return MedicineWorld.build();
    case BusinessWorld.worldId:
      return BusinessWorld.build();
    case FinanceWorld.worldId:
      return FinanceWorld.build();
    case AccountingWorld.worldId:
      return AccountingWorld.build();
    case MarketingWorld.worldId:
      return MarketingWorld.build();
    case EconomicsWorld.worldId:
      return EconomicsWorld.build();
    case CsCareerWorld.worldId:
      return CsCareerWorld.build();
    case PsychologyWorld.worldId:
      return PsychologyWorld.build();
    case BiologyWorld.worldId:
      return BiologyWorld.build();
    case ChemistryWorld.worldId:
      return ChemistryWorld.build();
    case PhysicsWorld.worldId:
      return PhysicsWorld.build();
    case EngineeringWorld.worldId:
      return EngineeringWorld.build();
    case MathematicsWorld.worldId:
      return MathematicsWorld.build();
    case CivilEngineeringWorld.worldId:
      return CivilEngineeringWorld.build();
    case ElectricalEngineeringWorld.worldId:
      return ElectricalEngineeringWorld.build();
    case MedicalLabScienceWorld.worldId:
      return MedicalLabScienceWorld.build();
    case PharmacyWorld.worldId:
      return PharmacyWorld.build();
    case CybersecurityWorld.worldId:
      return CybersecurityWorld.build();
    default:
      return null;
  }
}

/// All playable Career Worlds in master-plan order.
List<CareerWorld> allCareerWorlds() => <CareerWorld>[
      LawFirmWorld.build(),
      NursingEdWorld.build(),
      MedicineWorld.build(),
      BusinessWorld.build(),
      FinanceWorld.build(),
      AccountingWorld.build(),
      MarketingWorld.build(),
      EconomicsWorld.build(),
      CsCareerWorld.build(),
      PsychologyWorld.build(),
      BiologyWorld.build(),
      ChemistryWorld.build(),
      PhysicsWorld.build(),
      EngineeringWorld.build(),
      MathematicsWorld.build(),
      CivilEngineeringWorld.build(),
      ElectricalEngineeringWorld.build(),
      MedicalLabScienceWorld.build(),
      PharmacyWorld.build(),
      CybersecurityWorld.build(),
    ];
