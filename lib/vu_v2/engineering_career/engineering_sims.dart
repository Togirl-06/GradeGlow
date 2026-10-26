/// Pure engineering calculation helpers (deterministic, labeled simplified).
///
/// These are educational game models — not certified engineering analysis.
abstract final class EngineeringSims {
  static const double g = 9.81; // m/s²
  static const String disclaimer =
      'Simplified educational model — not certified engineering analysis.';

  /// Robotic arm: required joint torque ≈ m·g·L (horizontal reach, N·m).
  static RoboticArmResult evaluateRoboticArm({
    required double massKg,
    required double lengthM,
    required double motorTorqueNm,
    required double jointStrengthNm,
    double safetyFactor = 1.25,
  }) {
    final List<String> issues = <String>[];
    if (massKg <= 0 || massKg > 200) {
      issues.add('Mass must be between 0 and 200 kg.');
    }
    if (lengthM < 0.2 || lengthM > 2.5) {
      issues.add('Arm length must be between 0.2 m and 2.5 m.');
    }
    if (motorTorqueNm <= 0) issues.add('Motor torque must be positive.');
    if (jointStrengthNm <= 0) issues.add('Joint strength must be positive.');

    final double loadN = massKg * g;
    final double requiredNm = loadN * lengthM;
    final double withSafety = requiredNm * safetyFactor;
    final bool motorOk = motorTorqueNm + 1e-9 >= withSafety;
    final bool jointOk = jointStrengthNm + 1e-9 >= withSafety;
    if (!motorOk) {
      issues.add(
        'Motor torque ${motorTorqueNm.toStringAsFixed(1)} N·m is below '
        'required ${withSafety.toStringAsFixed(1)} N·m '
        '(includes safety factor $safetyFactor).',
      );
    }
    if (!jointOk) {
      issues.add(
        'Joint rating ${jointStrengthNm.toStringAsFixed(1)} N·m is below '
        'required ${withSafety.toStringAsFixed(1)} N·m.',
      );
    }

    return RoboticArmResult(
      loadN: loadN,
      requiredTorqueNm: requiredNm,
      requiredWithSafetyNm: withSafety,
      motorOk: motorOk,
      jointOk: jointOk,
      passed: issues.isEmpty && motorOk && jointOk,
      issues: issues,
      assumptions:
          'Assumes static horizontal reach, point load at tip, '
          'τ = F·L, and a constant safety factor of $safetyFactor. '
          '$disclaimer',
    );
  }

  /// Simplified bridge: midspan moment M = wL²/8; capacity check.
  static BridgeSimResult evaluateBridge({
    required double spanM,
    required double uniformLoadKNPerM,
    required double momentCapacityKNm,
    required double budgetUsd,
    required double costUsd,
    double safetyFactor = 1.5,
  }) {
    final List<String> issues = <String>[];
    final double demand =
        (uniformLoadKNPerM * spanM * spanM) / 8.0; // kN·m
    final double required = demand * safetyFactor;
    final bool strengthOk = momentCapacityKNm + 1e-9 >= required;
    final bool budgetOk = costUsd <= budgetUsd + 1e-6;
    if (!strengthOk) {
      issues.add(
        'Moment capacity ${momentCapacityKNm.toStringAsFixed(1)} kN·m '
        '< required ${required.toStringAsFixed(1)} kN·m.',
      );
    }
    if (!budgetOk) {
      issues.add(
        'Cost \$${costUsd.toStringAsFixed(0)} exceeds budget '
        '\$${budgetUsd.toStringAsFixed(0)}.',
      );
    }
    return BridgeSimResult(
      demandKNm: demand,
      requiredKNm: required,
      strengthOk: strengthOk,
      budgetOk: budgetOk,
      passed: issues.isEmpty,
      issues: issues,
      assumptions:
          'Simply supported beam, uniform load, M = wL²/8. $disclaimer',
    );
  }

  /// Series circuit: V = IR.
  static CircuitSimResult evaluateSeriesCircuit({
    required double voltageV,
    required double resistanceOhm,
    required double maxCurrentA,
  }) {
    final List<String> issues = <String>[];
    if (resistanceOhm <= 0) {
      issues.add('Resistance must be positive (open circuit if zero).');
      return CircuitSimResult(
        currentA: 0,
        powerW: 0,
        withinLimit: false,
        passed: false,
        issues: issues,
        assumptions: 'Ohm\'s law I = V/R for a single series resistor. $disclaimer',
      );
    }
    final double i = voltageV / resistanceOhm;
    final double p = voltageV * i;
    final bool ok = i <= maxCurrentA + 1e-9;
    if (!ok) {
      issues.add(
        'Current ${i.toStringAsFixed(3)} A exceeds limit '
        '${maxCurrentA.toStringAsFixed(3)} A.',
      );
    }
    return CircuitSimResult(
      currentA: i,
      powerW: p,
      withinLimit: ok,
      passed: issues.isEmpty,
      issues: issues,
      assumptions: 'Ohm\'s law I = V/R for a single series resistor. $disclaimer',
    );
  }

  /// Factory throughput: bottleneck = min station rates.
  static FactorySimResult evaluateFactoryLine({
    required List<double> stationUnitsPerHour,
    required double demandPerHour,
    required double budgetUsd,
    required double operatingCostUsd,
  }) {
    final List<String> issues = <String>[];
    if (stationUnitsPerHour.isEmpty) {
      issues.add('Add at least one workstation.');
      return FactorySimResult(
        bottleneckRate: 0,
        meetsDemand: false,
        withinBudget: false,
        passed: false,
        issues: issues,
        assumptions: 'Throughput limited by slowest station. $disclaimer',
      );
    }
    final double bottleneck =
        stationUnitsPerHour.reduce((double a, double b) => a < b ? a : b);
    final bool demandOk = bottleneck + 1e-9 >= demandPerHour;
    final bool budgetOk = operatingCostUsd <= budgetUsd + 1e-6;
    if (!demandOk) {
      issues.add(
        'Bottleneck ${bottleneck.toStringAsFixed(1)} u/h '
        '< demand ${demandPerHour.toStringAsFixed(1)} u/h.',
      );
    }
    if (!budgetOk) {
      issues.add('Operating cost exceeds budget.');
    }
    return FactorySimResult(
      bottleneckRate: bottleneck,
      meetsDemand: demandOk,
      withinBudget: budgetOk,
      passed: issues.isEmpty,
      issues: issues,
      assumptions: 'Throughput limited by slowest station. $disclaimer',
    );
  }
}

class RoboticArmResult {
  const RoboticArmResult({
    required this.loadN,
    required this.requiredTorqueNm,
    required this.requiredWithSafetyNm,
    required this.motorOk,
    required this.jointOk,
    required this.passed,
    required this.issues,
    required this.assumptions,
  });

  final double loadN;
  final double requiredTorqueNm;
  final double requiredWithSafetyNm;
  final bool motorOk;
  final bool jointOk;
  final bool passed;
  final List<String> issues;
  final String assumptions;
}

class BridgeSimResult {
  const BridgeSimResult({
    required this.demandKNm,
    required this.requiredKNm,
    required this.strengthOk,
    required this.budgetOk,
    required this.passed,
    required this.issues,
    required this.assumptions,
  });

  final double demandKNm;
  final double requiredKNm;
  final bool strengthOk;
  final bool budgetOk;
  final bool passed;
  final List<String> issues;
  final String assumptions;
}

class CircuitSimResult {
  const CircuitSimResult({
    required this.currentA,
    required this.powerW,
    required this.withinLimit,
    required this.passed,
    required this.issues,
    required this.assumptions,
  });

  final double currentA;
  final double powerW;
  final bool withinLimit;
  final bool passed;
  final List<String> issues;
  final String assumptions;
}

class FactorySimResult {
  const FactorySimResult({
    required this.bottleneckRate,
    required this.meetsDemand,
    required this.withinBudget,
    required this.passed,
    required this.issues,
    required this.assumptions,
  });

  final double bottleneckRate;
  final bool meetsDemand;
  final bool withinBudget;
  final bool passed;
  final List<String> issues;
  final String assumptions;
}
