import '../labs/lab_models.dart';
import '../model/career_models.dart';

/// Virtual pay in US dollars. Everything here is simulated GradeGlow money:
/// it is never real wages and can never be withdrawn.
///
/// * Employees are paid for approved work: each evaluated assignment is one
///   work week (the role's weekly hours). A paycheck is processed when a pay
///   period's weeks are complete: weekly = 1, biweekly = 2, monthly = 4
///   (a simulated pay month). Each period is paid exactly once.
/// * Gross pay comes from the salary: annual ÷ 52 per week (annual ÷ 12 for
///   a monthly paycheck), or hourly rate × approved hours.
/// * Simulated deductions (tax and benefits) are a flat 10%.
/// * Students who are not employed get a small training stipend the first
///   time they pass each lab scenario.
abstract final class PayRules {
  static const String notice =
      'GradeGlow Career Simulation: Practice real professional skills, experience realistic recruitment, and earn virtual USD salaries. '
      'These positions and payments are part of your educational simulation and are not actual employment or cash payments.';

  /// Training stipend (cents) for a first pass at each level.
  static const Map<LabDifficulty, int> stipendCents = <LabDifficulty, int>{
    LabDifficulty.foundation: 7500,
    LabDifficulty.intermediate: 14000,
    LabDifficulty.advanced: 22500,
  };

  static int stipend(LabDifficulty level, int score) => (stipendCents[level]! * score.clamp(0, 100) / 100).round();

  static const double deductionRate = 0.10;

  static int weeksPerPeriod(String frequency) => switch (frequency) {
        'weekly' => 1,
        'monthly' => 4,
        _ => 2,
      };

  static String frequencyLabel(String f) => switch (f) {
        'weekly' => 'Weekly',
        'monthly' => 'Monthly',
        _ => 'Every two weeks',
      };

  /// Annual equivalent in whole dollars.
  static int annual(int salary, String period, {int hoursPerWeek = 40}) => switch (period) {
        'hour' => salary * hoursPerWeek * 52,
        'week' => salary * 52,
        'month' => salary * 12,
        _ => salary,
      };

  /// Gross pay for one work week, in cents.
  static int weeklyGrossCents(int salary, String period, {int hoursPerWeek = 40}) => switch (period) {
        'hour' => salary * hoursPerWeek * 100,
        _ => (annual(salary, period) * 100 / 52).round(),
      };

  /// Gross pay for one full pay period, in cents.
  static int periodGrossCents(int salary, String period, String frequency, {int hoursPerWeek = 40}) {
    if (frequency == 'monthly') {
      return (annual(salary, period, hoursPerWeek: hoursPerWeek) * 100 / 12).round();
    }
    return weeklyGrossCents(salary, period, hoursPerWeek: hoursPerWeek) * weeksPerPeriod(frequency);
  }

  static int deductionsCents(int gross) => (gross * deductionRate).round();

  /// Paycheck for an employment's next period (does not record it).
  static Paycheck paycheck(Employment e, int period, int day) {
    final int weeks = weeksPerPeriod(e.payFrequency);
    final int gross = periodGrossCents(e.salary, e.salaryPeriod, e.payFrequency, hoursPerWeek: e.hoursPerWeek);
    return Paycheck(
      id: '${e.id}_p$period',
      employmentId: e.id,
      employer: e.employer,
      title: e.title,
      period: period,
      weeks: weeks,
      hours: weeks * e.hoursPerWeek,
      grossCents: gross,
      deductionCents: deductionsCents(gross),
      day: day,
      frequency: e.payFrequency,
    );
  }

  /// Merit raise for a review outcome (percent).
  static int raiseFor(String outcome) => switch (outcome) {
        'Excellent performance' => 5,
        'Meets expectations' => 2,
        _ => 0,
      };

  /// Salary after a raise, rounded sensibly for the pay period.
  static int raised(int salary, String period, double factor) {
    final int step = period == 'year' ? 500 : (period == 'month' ? 10 : 1);
    final double v = salary * factor;
    final int r = (v / step).round() * step;
    return r <= salary ? salary + step : r;
  }
}

String _group(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m[1]},');

/// "$5,166.67" from cents.
String usd(int cents) {
  final int a = cents.abs();
  return '${cents < 0 ? '−' : ''}\$${_group(a ~/ 100)}.${(a % 100).toString().padLeft(2, '0')}';
}

/// "$62,000" from whole dollars.
String usdWhole(int dollars) => '${dollars < 0 ? '−' : ''}\$${_group(dollars.abs())}';
