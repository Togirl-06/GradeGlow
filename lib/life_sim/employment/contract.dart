/// The employment contract a player signs when hired.
library;

import '../careers/career_catalog.dart';
import 'employers.dart';

class EmploymentContract {
  const EmploymentContract({
    required this.employerId,
    required this.careerId,
    required this.rank,
    required this.title,
    required this.monthlySalary,
    required this.startDay,
    required this.startHour,
    required this.endHour,
    required this.signedDay,
    this.probationDays = 14,
  });

  final String employerId;
  final String careerId;
  final int rank;
  final String title;
  final double monthlySalary;
  final int startDay;
  final int startHour;
  final int endHour;
  final int signedDay;
  final int probationDays;

  Employer get employer => EmployerCatalog.require(employerId);
  CareerDef get career => CareerCatalog.require(careerId);

  EmploymentContract copyWith({
    int? rank,
    String? title,
    double? monthlySalary,
  }) =>
      EmploymentContract(
        employerId: employerId,
        careerId: careerId,
        rank: rank ?? this.rank,
        title: title ?? this.title,
        monthlySalary: monthlySalary ?? this.monthlySalary,
        startDay: startDay,
        startHour: startHour,
        endHour: endHour,
        signedDay: signedDay,
        probationDays: probationDays,
      );

  /// Plain-language contract shown on the signing screen.
  String legalText() {
    final Employer e = employer;
    return 'EMPLOYMENT AGREEMENT (simulation)\n\n'
        'Employer: ${e.name}\n'
        'Position: $title\n'
        'Start date: Day $startDay\n'
        'Hours: Monday–Friday, $startHour:00–$endHour:00\n'
        'Salary: \$${monthlySalary.round()} per month (gross). Income tax is withheld from every payslip.\n'
        'Pay day: every 14 days.\n'
        'Probation: $probationDays days. During probation either side may end the agreement at once.\n'
        'Duties: ${career.dayInLife.take(3).join('; ')}.\n\n'
        'You agree to attend your scheduled shifts, act professionally and keep patient/client information confidential. '
        'Repeated unexplained absence may lead to dismissal.';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'employerId': employerId,
        'careerId': careerId,
        'rank': rank,
        'title': title,
        'monthlySalary': monthlySalary,
        'startDay': startDay,
        'startHour': startHour,
        'endHour': endHour,
        'signedDay': signedDay,
        'probationDays': probationDays,
      };

  factory EmploymentContract.fromJson(Map<String, Object?> j) => EmploymentContract(
        employerId: j['employerId'] as String? ?? '',
        careerId: j['careerId'] as String? ?? '',
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        title: j['title'] as String? ?? '',
        monthlySalary: (j['monthlySalary'] as num?)?.toDouble() ?? 0,
        startDay: (j['startDay'] as num?)?.toInt() ?? 1,
        startHour: (j['startHour'] as num?)?.toInt() ?? 9,
        endHour: (j['endHour'] as num?)?.toInt() ?? 17,
        signedDay: (j['signedDay'] as num?)?.toInt() ?? 1,
        probationDays: (j['probationDays'] as num?)?.toInt() ?? 14,
      );
}
