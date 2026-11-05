import 'content/accounting_labs.dart';
import 'content/cs_labs.dart';
import 'content/health_labs.dart';
import 'content/law_labs.dart';
import 'content/math_labs_applied.dart';
import 'content/math_labs_pure.dart';
import 'lab_models.dart';

/// Every practical lab, by major.
abstract final class LabCatalog {
  static final List<LabSpec> all = <LabSpec>[...csLabs, ...nursingLabs, ...medicineLabs, ...accountingLabs, ...mathLabs, ...lawLabs];

  static final List<LabSpec> mathLabs = <LabSpec>[
    mathAlgebraLab,
    mathCalculusLab,
    mathLinearAlgebraLab,
    mathStatisticsLab,
    mathDiffEqLab,
    mathAppliedLab,
  ];

  static LabSpec? lab(String id) {
    for (final LabSpec l in all) {
      if (l.id == id) return l;
    }
    return null;
  }

  static List<LabSpec> forDept(String deptId) => all.where((LabSpec l) => l.deptId == deptId).toList();

  static List<LabSpec> forMajor(String majorId) => all.where((LabSpec l) => l.majorId == majorId).toList();

  static const Map<String, String> majorLabels = <String, String>{
    'computer_science': 'Computer Science',
    'nursing': 'Nursing',
    'medicine': 'Medicine',
    'accounting': 'Accounting',
    'mathematics': 'Mathematics',
    'introduction_to_law': 'Law',
  };
}
