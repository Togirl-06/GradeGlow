import 'package:flutter/material.dart';

import 'accounting/accounting_playable.dart';
import 'biology/biology_playable.dart';
import 'business/business_playable.dart';
import 'chemistry/chemistry_playable.dart';
import 'civil_engineering/civil_engineering_playable.dart';
import 'cs_career/cs_career_playable.dart';
import 'cybersecurity/cybersecurity_playable.dart';
import 'economics/economics_playable.dart';
import 'electrical_engineering/electrical_engineering_playable.dart';
import 'engineering/engineering_playable.dart';
import 'finance/finance_playable.dart';
import 'law/law_playable.dart';
import 'marketing/marketing_playable.dart';
import 'mathematics/mathematics_playable.dart';
import 'medical_lab_science/mls_playable.dart';
import 'medicine/medicine_playable.dart';
import 'nursing/nursing_playable.dart';
import 'pharmacy/pharmacy_playable.dart';
import 'physics/physics_playable.dart';
import 'professional/accounting/accounting_pro_home.dart';
import 'professional/business/business_pro_home.dart';
import 'professional/economics/economics_pro_home.dart';
import 'professional/finance/finance_pro_home.dart';
import 'professional/marketing/marketing_pro_home.dart';
import 'psychology/psychology_playable.dart';

/// Returns a playable workplace for [labId], or null if not yet wired.
Widget? playableScreenFor(String labId) {
  return playableScreens[labId]?.call();
}

/// Lab id → playable workplace builder.
final Map<String, Widget Function()> playableScreens =
    <String, Widget Function()>{
  'law_firm': lawPlayableScreen,
  'nursing_ed': nursingPlayableScreen,
  'medicine': medicinePlayableScreen,
  'medical_lab_science': mlsPlayableScreen,
  'pharmacy': pharmacyPlayableScreen,
  // Professional business simulations (shared engine).
  'business': () => const BusinessProHome(),
  'finance': () => const FinanceProHome(),
  'accounting': () => const AccountingProHome(),
  'marketing': () => const MarketingProHome(),
  'economics': () => const EconomicsProHome(),
  // Legacy workplace floors retained for reference / fallback:
  'business_legacy': () => const BusinessPlayableScreen(),
  'finance_legacy': () => const FinancePlayableScreen(),
  'accounting_legacy': () => const AccountingPlayableScreen(),
  'marketing_legacy': () => const MarketingPlayableScreen(),
  'economics_legacy': () => const EconomicsPlayableScreen(),
  'cs_career': csCareerPlayableScreen,
  'biology': biologyPlayableScreen,
  'chemistry': chemistryPlayableScreen,
  'physics': physicsPlayableScreen,
  'engineering': engineeringPlayableScreen,
  'mathematics': mathematicsPlayableScreen,
  'civil_engineering': civilEngineeringPlayableScreen,
  'electrical_engineering': electricalEngineeringPlayableScreen,
  'psychology': psychologyPlayableScreen,
  'cybersecurity': cybersecurityPlayableScreen,
};
