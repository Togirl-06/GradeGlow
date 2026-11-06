import '../labs/lab_models.dart';
import '../model/career_models.dart';

/// Simulated pay. Students earn for passing practical lab work (first pass of
/// each scenario, more for harder levels) and, once employed, a week's pay for
/// each evaluated assignment, with a bonus for strong work and on promotion.
/// This is in-game money only.
abstract final class PayRules {
  static const Map<LabDifficulty, int> labRates = <LabDifficulty, int>{
    LabDifficulty.foundation: 60,
    LabDifficulty.intermediate: 110,
    LabDifficulty.advanced: 180,
  };

  /// Pay for a first pass of a lab scenario, scaled by the score.
  static int labPay(LabDifficulty level, int score) => (labRates[level]! * score.clamp(0, 100) / 100).round();

  /// A week's gross pay for a salary quoted per year, month, week or hour.
  static int weeklyPay(int salary, String period) => switch (period) {
        'hour' => (salary * 37.5).round(),
        'week' => salary,
        'month' => (salary * 12 / 52).round(),
        _ => (salary / 52).round(),
      };

  /// Strong evaluations (85+) earn a 10% bonus on top of the week's pay.
  static const int bonusThreshold = 85;

  static (int pay, int bonus) assignmentPay(Employment e, SupervisorEvaluation ev) {
    final int week = weeklyPay(e.salary, e.salaryPeriod);
    return (week, ev.overall >= bonusThreshold ? (week * 0.1).round() : 0);
  }

  /// One-off bonus on promotion: two weeks at the new salary.
  static int promotionBonus(int newSalary, String period) => weeklyPay(newSalary, period) * 2;
}

/// "£1,234" for whole pounds.
String pounds(int amount) {
  final String s = amount.abs().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m[1]},');
  return '${amount < 0 ? '−' : ''}£$s';
}
