import 'package:flutter/widgets.dart';

import 'content/catalog.dart';
import 'model/content_models.dart';
import 'ui/department_screens.dart';

export 'store/career_sim_store.dart' show CareerSimStore;
export 'ui/career_dashboard.dart' show CareerSimDashboard;

/// Entry points used by the rest of the app (courses, school pages, community).
abstract final class CareerSim {
  static const Map<String, String> _aliases = <String, String>{
    'computer_science': 'cs',
    'business': 'business',
    'engineering': 'engineering',
    'law': 'law',
    'medicine': 'medicine',
    'nursing': 'nursing',
    'mathematics': 'mathematics',
    'english': 'communication',
    'biology': 'sciences',
    'chemistry': 'sciences',
    'physics': 'sciences',
  };

  /// The department where a course subject is practised, if any.
  static Department? departmentForSubject(String subjectId) {
    final String id = subjectId.trim().toLowerCase();
    final Department? byMajor = CareerCatalog.forMajor(id);
    if (byMajor != null) return byMajor;
    final String? alias = _aliases[id];
    if (alias != null) return CareerCatalog.department(alias);
    for (final MapEntry<String, String> e in _aliases.entries) {
      if (id.contains(e.key)) return CareerCatalog.department(e.value);
    }
    return CareerCatalog.department(id);
  }

  static Future<void> openDepartmentById(BuildContext context, String deptId) => openDepartment(context, deptId);

  /// Opens the matching department, or the department list when none matches.
  static Future<void> openForSubject(BuildContext context, String subjectId) async {
    final Department? d = departmentForSubject(subjectId);
    if (d != null) {
      await openDepartment(context, d.id);
      return;
    }
    await Navigator.of(context).push(PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const DepartmentPickerScreen(),
    ));
  }
}
