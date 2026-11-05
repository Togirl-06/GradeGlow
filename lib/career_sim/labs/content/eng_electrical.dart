/// Electrical Engineering at Voltaris Systems.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';
import 'design_kit.dart';

const LabPerson _peter = LabPerson('Peter Lindqvist', 'Senior Electrical Engineer', 'Calculate first, then build it on the bench model. Nothing gets energised until it is within rating.');
const String _d = 'engineering';
const String _m = 'electrical_engineering';

final LabSpec elecConstructionLab = designLab(
  id: 'ee_lab_construction', deptId: _d, majorId: _m, number: 1, title: 'Circuit Construction', environment: LabEnvironment.engineeringOffice,
  summary: 'Build working circuits on a virtual bench: LED drivers, dividers, resistor networks, RC timers and fused loads — every value checked against component ratings.',
  objectives: const <String>['Apply Ohm’s law and power ratings', 'Build series–parallel networks to a target', 'Choose protective devices'],
  skills: const <String>['en_elec'],
  reference: const <String>['V = IR, P = VI = I²R = V²/R.', 'Series: R = R₁ + R₂. Parallel: R = R₁R₂/(R₁ + R₂).', 'τ = RC.'],
  scenarios: fromProblems('ec', <DesignProblem>[
    DesignProblem(
      key: 'led', title: 'LED current-limiting resistor', brief: 'Drive a status LED (forward voltage 2 V) from a supply rail.',
      inputs: const <SimInput>[SimInput('V', 'Supply voltage', 3, 24, step: 1, initial: 12), SimInput('R', 'Series resistor', 10, 2000, step: 10, initial: 100, unit: 'Ω')],
      outputs: const <SimOutput>[SimOutput('I', 'LED current', '(V - 2)/R*1000', unit: 'mA', decimals: 1), SimOutput('P', 'Resistor power', '(V - 2)^2/R', unit: 'W', decimals: 3)],
      given: const <String, double>{'V': 5, 'R': 150}, ask: const <String>['I', 'P'], formulas: const <String>['I = (V_s − V_f)/R', 'P = (V_s − V_f)²/R'],
      levels: cum(<SimConstraint>[ge('V', 9, 'Use the 9 V or higher rail'), ge('I', 15, 'At least 15 mA (visible)'), le('I', 20, 'No more than 20 mA (LED rating)')], <SimConstraint>[le('P', 0.25, 'Resistor within ¼ W')], <SimConstraint>[ge('V', 12, '12 V rail'), ge('I', 18, 'At least 18 mA (daylight)')]),
      models: same(const <String, double>{'V': 12, 'R': 510}),
    ),
    DesignProblem(
      key: 'divider', title: 'Sensor reference divider', brief: 'Derive a 5 V reference from 12 V for a sensor input.',
      inputs: const <SimInput>[SimInput('a', 'R1', 1, 100, step: 1, initial: 10, unit: 'kΩ'), SimInput('b', 'R2', 1, 100, step: 1, initial: 10, unit: 'kΩ')],
      outputs: const <SimOutput>[SimOutput('O', 'Output voltage', '12*b/(a + b)', unit: 'V', decimals: 3), SimOutput('I', 'Divider current', '12/(a + b)', unit: 'mA', decimals: 3)],
      given: const <String, double>{'a': 20, 'b': 10}, ask: const <String>['O', 'I'], formulas: const <String>['V_out = V_in R₂/(R₁ + R₂)'],
      levels: cum(<SimConstraint>[ge('O', 4.9, 'Output at least 4.9 V'), le('O', 5.1, 'Output no more than 5.1 V')], <SimConstraint>[le('I', 1, 'Divider current no more than 1 mA')], <SimConstraint>[ge('O', 4.95, 'Output at least 4.95 V'), le('O', 5.05, 'Output no more than 5.05 V')]),
      models: same(const <String, double>{'a': 7, 'b': 5}),
    ),
    DesignProblem(
      key: 'network', title: 'Series–parallel network', brief: 'Make a 470 Ω load from R1 in series with R2 ∥ R3, on a 12 V supply.',
      inputs: const <SimInput>[SimInput('a', 'R1', 10, 1000, step: 10, initial: 100, unit: 'Ω'), SimInput('b', 'R2', 10, 1000, step: 10, initial: 100, unit: 'Ω'), SimInput('c', 'R3', 10, 1000, step: 10, initial: 100, unit: 'Ω')],
      outputs: const <SimOutput>[SimOutput('R', 'Equivalent resistance', 'a + b*c/(b + c)', unit: 'Ω', decimals: 1), SimOutput('P', 'Total power at 12 V', '144/(a + b*c/(b + c))', unit: 'W', decimals: 3)],
      given: const <String, double>{'a': 100, 'b': 200, 'c': 300}, ask: const <String>['R'], formulas: const <String>['R = R₁ + R₂R₃/(R₂ + R₃)'],
      levels: cum(<SimConstraint>[ge('R', 465, 'At least 465 Ω'), le('R', 475, 'No more than 475 Ω (1% tolerance)')], <SimConstraint>[le('P', 0.35, 'Total power no more than 0.35 W')], <SimConstraint>[ge('b', 220, 'R2 at least 220 Ω (available stock)')]),
      models: same(const <String, double>{'a': 220, 'b': 500, 'c': 500}),
    ),
    DesignProblem(
      key: 'rc', title: 'RC timing circuit', brief: 'Set a 1-second delay with an RC network.',
      inputs: const <SimInput>[SimInput('R', 'Resistance', 1, 100, step: 0.1, initial: 10, unit: 'kΩ'), SimInput('C', 'Capacitance', 1, 1000, step: 1, initial: 1000, unit: 'µF')],
      outputs: const <SimOutput>[SimOutput('T', 'Time constant', 'R*C/1000', unit: 's', decimals: 3), SimOutput('F', 'Settling time (5τ)', '5*R*C/1000', unit: 's', decimals: 2)],
      given: const <String, double>{'R': 47, 'C': 22}, ask: const <String>['T'], formulas: const <String>['τ = RC'],
      levels: cum(<SimConstraint>[ge('T', 0.9, 'τ at least 0.9 s'), le('T', 1.1, 'τ no more than 1.1 s')], <SimConstraint>[le('C', 470, 'Capacitor no larger than 470 µF (board space)')], <SimConstraint>[ge('R', 4.7, 'R at least 4.7 kΩ (input loading)'), le('F', 5.5, 'Settles within 5.5 s')]),
      models: same(const <String, double>{'R': 10, 'C': 100}),
    ),
    DesignProblem(
      key: 'fuse', title: 'Appliance fuse selection', brief: 'Choose a plug fuse for a 230 V appliance so normal current is no more than 80% of the fuse rating.',
      inputs: const <SimInput>[SimInput('P', 'Appliance power', 100, 3000, step: 50, initial: 2000, unit: 'W'), SimInput('f', 'Fuse rating', 1, 13, step: 1, initial: 5, unit: 'A')],
      outputs: const <SimOutput>[SimOutput('I', 'Running current', 'P/230', unit: 'A', decimals: 2), SimOutput('U', 'Current ÷ fuse rating', 'P/230/f')],
      given: const <String, double>{'P': 920, 'f': 5}, ask: const <String>['I'], formulas: const <String>['I = P/V'],
      levels: cum(<SimConstraint>[ge('P', 1500, 'Appliance at least 1.5 kW'), le('U', 0.8, 'Running current ≤ 80% of fuse')], <SimConstraint>[le('f', 13, 'UK plug fuse no larger than 13 A')], <SimConstraint>[ge('P', 2000, 'Appliance at least 2 kW')]),
      models: same(const <String, double>{'P': 2000, 'f': 13}),
    ),
  ], person: _peter),
);

final LabSpec elecAnalysisLab = designLab(
  id: 'ee_lab_analysis', deptId: _d, majorId: _m, number: 2, title: 'Circuit Analysis', environment: LabEnvironment.engineeringOffice,
  summary: 'Maximum power transfer, AC impedance, power-factor correction, three-phase power and cable voltage drop.',
  objectives: const <String>['Analyse DC and AC circuits', 'Correct power factor', 'Size cables for voltage drop'],
  skills: const <String>['en_elec'],
  reference: const <String>['Z = √(R² + X²), X_L = 2πfL, pf = R/Z.', 'Q_c = P(tan φ₁ − tan φ₂).', 'Three-phase P = √3 V I pf.', 'Voltage drop (single-phase) = 2IL ρ/A, ρ_Cu = 0.0172 Ω·mm²/m.'],
  scenarios: fromProblems('ea', <DesignProblem>[
    DesignProblem(
      key: 'thevenin', title: 'Matching a load to a source', brief: 'A sensor amplifier has a Thévenin equivalent of 12 V with 10 Ω. Choose the load.',
      inputs: const <SimInput>[SimInput('L', 'Load resistance', 1, 100, step: 1, initial: 50, unit: 'Ω')],
      outputs: const <SimOutput>[SimOutput('P', 'Load power', '144*L/(10 + L)^2', unit: 'W', decimals: 3), SimOutput('E', 'Efficiency', 'L/(10 + L)', decimals: 3)],
      given: const <String, double>{'L': 20}, ask: const <String>['P'], formulas: const <String>['P = V²R_L/(R_th + R_L)²'],
      levels: cum(<SimConstraint>[ge('P', 3.4, 'Deliver at least 3.4 W')], <SimConstraint>[ge('E', 0.5, 'Efficiency at least 50%')], <SimConstraint>[ge('P', 3.6, 'Deliver the maximum available power (3.6 W)')]),
      models: same(const <String, double>{'L': 10}),
      interpret: const ChoiceQuestion('mpt', 'Maximum power is transferred when', <String>['R_L = R_th', 'R_L is as large as possible', 'R_L = 0'], 0),
    ),
    DesignProblem(
      key: 'impedance', title: 'Inductive load on the mains', brief: 'Choose R and L for a 230 V, 50 Hz inductive load.',
      inputs: const <SimInput>[SimInput('R', 'Resistance', 1, 100, step: 1, initial: 10, unit: 'Ω'), SimInput('L', 'Inductance', 1, 500, step: 1, initial: 300, unit: 'mH')],
      outputs: const <SimOutput>[
        SimOutput('X', 'Reactance', '2*pi*50*L/1000', unit: 'Ω'),
        SimOutput('Z', 'Impedance', 'sqrt(R^2 + (2*pi*50*L/1000)^2)', unit: 'Ω'),
        SimOutput('I', 'Current', '230/sqrt(R^2 + (2*pi*50*L/1000)^2)', unit: 'A'),
        SimOutput('F', 'Power factor', 'R/sqrt(R^2 + (2*pi*50*L/1000)^2)', decimals: 3),
      ],
      given: const <String, double>{'R': 30, 'L': 100}, ask: const <String>['X', 'Z', 'I'], formulas: const <String>['X_L = 2πfL', 'Z = √(R² + X²)', 'I = V/Z', 'pf = R/Z'],
      levels: cum(<SimConstraint>[ge('F', 0.8, 'Power factor at least 0.8')], <SimConstraint>[le('I', 10, 'Current no more than 10 A')], <SimConstraint>[ge('I', 8, 'Current at least 8 A'), ge('F', 0.9, 'Power factor at least 0.9')]),
      models: same(const <String, double>{'R': 25, 'L': 30}),
    ),
    DesignProblem(
      key: 'pfc', title: 'Power-factor correction', brief: 'Size a capacitor bank to improve a factory’s power factor.',
      inputs: const <SimInput>[SimInput('P', 'Real power', 10, 200, step: 5, initial: 100, unit: 'kW'), SimInput('a', 'Existing pf', 0.6, 0.95, step: 0.01, initial: 0.7), SimInput('b', 'Target pf', 0.85, 1, step: 0.01, initial: 0.9)],
      outputs: const <SimOutput>[SimOutput('Q', 'Capacitor kVAr', 'P*(tan(acos(a)) - tan(acos(b)))', unit: 'kVAr', decimals: 1)],
      given: const <String, double>{'P': 50, 'a': 0.8, 'b': 0.95}, ask: const <String>['Q'], formulas: const <String>['Q_c = P(tan φ₁ − tan φ₂), φ = cos⁻¹(pf)'],
      levels: cum(<SimConstraint>[ge('b', 0.95, 'Reach pf 0.95 (tariff threshold)'), le('Q', 50, 'Bank no larger than 50 kVAr')], <SimConstraint>[ge('P', 80, 'Plant load at least 80 kW')], <SimConstraint>[le('a', 0.75, 'Measured pf no better than 0.75'), le('Q', 60, 'Bank no larger than 60 kVAr')]),
      models: same(const <String, double>{'P': 80, 'a': 0.75, 'b': 0.95}),
    ),
    DesignProblem(
      key: 'threephase', title: 'Three-phase motor supply', brief: 'Supply a 30 kW, 400 V three-phase motor within cable limits.',
      inputs: const <SimInput>[SimInput('I', 'Line current', 5, 100, step: 1, initial: 20, unit: 'A'), SimInput('f', 'Power factor', 0.7, 1, step: 0.01, initial: 0.8)],
      outputs: const <SimOutput>[SimOutput('P', 'Power delivered', 'sqrt(3)*400*I*f/1000', unit: 'kW', decimals: 2)],
      given: const <String, double>{'I': 40, 'f': 0.85}, ask: const <String>['P'], formulas: const <String>['P = √3 V I pf'],
      levels: cum(<SimConstraint>[ge('P', 30, 'Deliver at least 30 kW')], <SimConstraint>[le('I', 60, 'Cable rating 60 A')], <SimConstraint>[le('f', 0.9, 'Realistic motor pf (≤ 0.9)'), le('I', 55, 'Derated cable: 55 A')]),
      models: same(const <String, double>{'I': 50, 'f': 0.9}),
    ),
    DesignProblem(
      key: 'vdrop', title: 'Cable voltage drop', brief: 'Size a single-phase 230 V cable run to a workshop.',
      inputs: const <SimInput>[SimInput('I', 'Load current', 5, 50, step: 1, initial: 32, unit: 'A'), SimInput('L', 'Cable length', 5, 100, step: 5, initial: 60, unit: 'm'), SimInput('A', 'Conductor size', 1, 16, step: 0.5, initial: 2.5, unit: 'mm²')],
      outputs: const <SimOutput>[SimOutput('D', 'Voltage drop', '2*I*L*0.0172/A', unit: 'V'), SimOutput('Z', 'Voltage drop', '2*I*L*0.0172/A/230*100', unit: '%')],
      given: const <String, double>{'I': 16, 'L': 30, 'A': 2.5}, ask: const <String>['D', 'Z'], formulas: const <String>['V_d = 2ILρ/A'],
      levels: cum(<SimConstraint>[ge('I', 20, 'Load at least 20 A'), ge('L', 40, 'Run at least 40 m'), le('Z', 3, 'Drop no more than 3%')], <SimConstraint>[le('A', 10, 'Conductor no larger than 10 mm²')], <SimConstraint>[ge('I', 32, 'Load 32 A'), ge('L', 50, 'Run 50 m'), le('Z', 2.5, 'Drop no more than 2.5%')]),
      models: same(const <String, double>{'I': 32, 'L': 50, 'A': 10}),
    ),
  ], person: _peter),
);

final LabSpec elecElectronicsLab = designLab(
  id: 'ee_lab_electronics', deptId: _d, majorId: _m, number: 3, title: 'Electronic Systems', environment: LabEnvironment.engineeringOffice,
  summary: 'Design op-amp amplifiers, transistor switches, 555 oscillators, filters and battery systems to specification.',
  objectives: const <String>['Design amplifier and switching stages', 'Design timing and filter circuits', 'Size battery systems'],
  skills: const <String>['en_elec'],
  reference: const <String>['Non-inverting gain G = 1 + R_f/R_g; bandwidth ≈ GBW/G.', '555 astable: f = 1.44/((R₁ + 2R₂)C).', 'RC low-pass: f_c = 1/(2πRC).'],
  scenarios: fromProblems('el', <DesignProblem>[
    DesignProblem(
      key: 'opamp', title: 'Microphone pre-amplifier gain', brief: 'Set a gain of 10 on a non-inverting op-amp (GBW 1 MHz).',
      inputs: const <SimInput>[SimInput('f', 'R_f', 1, 200, step: 1, initial: 10, unit: 'kΩ'), SimInput('g', 'R_g', 1, 100, step: 1, initial: 10, unit: 'kΩ')],
      outputs: const <SimOutput>[SimOutput('G', 'Gain', '1 + f/g', decimals: 2), SimOutput('B', 'Bandwidth', '1000000/(1 + f/g)', unit: 'Hz', decimals: 0)],
      given: const <String, double>{'f': 47, 'g': 4.7}, ask: const <String>['G', 'B'], formulas: const <String>['G = 1 + R_f/R_g', 'BW = GBW/G'],
      levels: cum(<SimConstraint>[ge('G', 9.8, 'Gain at least 9.8'), le('G', 10.2, 'Gain no more than 10.2')], <SimConstraint>[ge('B', 95000, 'Bandwidth at least 95 kHz')], <SimConstraint>[ge('g', 2, 'R_g at least 2 kΩ (input loading)'), le('f', 100, 'R_f no more than 100 kΩ (noise)')]),
      models: same(const <String, double>{'f': 90, 'g': 10}),
    ),
    DesignProblem(
      key: 'switch', title: 'Transistor relay driver', brief: 'Drive a relay from a 5 V logic output through an NPN transistor, with base overdrive of at least 2.',
      inputs: const <SimInput>[SimInput('c', 'Collector current', 10, 500, step: 10, initial: 100, unit: 'mA'), SimInput('b', 'Minimum h_FE', 50, 300, step: 10, initial: 100), SimInput('R', 'Base resistor', 0.1, 20, step: 0.1, initial: 10, unit: 'kΩ')],
      outputs: const <SimOutput>[SimOutput('I', 'Base current', '(5 - 0.7)/R', unit: 'mA', decimals: 2), SimOutput('N', 'Base current needed', 'c/b', unit: 'mA', decimals: 2), SimOutput('S', 'Overdrive factor', '(5 - 0.7)/R/(c/b)', decimals: 2)],
      given: const <String, double>{'c': 150, 'b': 150, 'R': 2.2}, ask: const <String>['I', 'S'], formulas: const <String>['I_B = (V_in − 0.7)/R_B', 'needed I_B = I_C/h_FE'],
      levels: cum(<SimConstraint>[ge('c', 100, 'Relay coil at least 100 mA'), ge('S', 2, 'Overdrive at least 2')], <SimConstraint>[le('b', 100, 'Use the datasheet minimum h_FE (≤ 100)')], <SimConstraint>[ge('c', 200, 'Larger relay: 200 mA'), le('S', 5, 'Overdrive no more than 5 (logic pin load)')]),
      models: same(const <String, double>{'c': 200, 'b': 100, 'R': 1}),
    ),
    DesignProblem(
      key: 'astable', title: '555 oscillator for a buzzer', brief: 'Set a 555 astable to about 1 kHz.',
      inputs: const <SimInput>[SimInput('a', 'R1', 1, 100, step: 1, initial: 10, unit: 'kΩ'), SimInput('b', 'R2', 1, 100, step: 1, initial: 10, unit: 'kΩ'), SimInput('C', 'C', 0.01, 10, step: 0.01, initial: 1, unit: 'µF')],
      outputs: const <SimOutput>[SimOutput('f', 'Frequency', '1.44/((a + 2*b)*1000*C/1000000)', unit: 'Hz', decimals: 0), SimOutput('D', 'Duty cycle', '(a + b)/(a + 2*b)', decimals: 3)],
      given: const <String, double>{'a': 10, 'b': 10, 'C': 0.1}, ask: const <String>['f', 'D'], formulas: const <String>['f = 1.44/((R₁ + 2R₂)C)', 'duty = (R₁ + R₂)/(R₁ + 2R₂)'],
      levels: cum(<SimConstraint>[ge('f', 900, 'At least 900 Hz'), le('f', 1100, 'No more than 1100 Hz')], <SimConstraint>[le('D', 0.6, 'Duty no more than 60%')], <SimConstraint>[le('D', 0.55, 'Duty no more than 55%')]),
      models: same(const <String, double>{'a': 1, 'b': 10, 'C': 0.07}),
    ),
    DesignProblem(
      key: 'filter', title: 'Anti-aliasing low-pass filter', brief: 'Set an RC low-pass cut-off of about 1 kHz.',
      inputs: const <SimInput>[SimInput('R', 'Resistance', 0.1, 100, step: 0.1, initial: 10, unit: 'kΩ'), SimInput('C', 'Capacitance', 1, 1000, step: 1, initial: 100, unit: 'nF')],
      outputs: const <SimOutput>[SimOutput('F', 'Cut-off frequency', '1/(2*pi*R*1000*C/1000000000)', unit: 'Hz', decimals: 0)],
      given: const <String, double>{'R': 4.7, 'C': 47}, ask: const <String>['F'], formulas: const <String>['f_c = 1/(2πRC)'],
      levels: cum(<SimConstraint>[ge('F', 950, 'Cut-off at least 950 Hz'), le('F', 1050, 'Cut-off no more than 1050 Hz')], <SimConstraint>[le('C', 100, 'Capacitor no larger than 100 nF (film type)')], <SimConstraint>[ge('R', 1.5, 'R at least 1.5 kΩ (op-amp load)'), ge('C', 10, 'C at least 10 nF (parasitics)')]),
      models: same(const <String, double>{'R': 1.6, 'C': 100}),
    ),
    DesignProblem(
      key: 'battery', title: 'Wearable battery life', brief: 'Choose a 3.7 V cell for a wearable device with a DC–DC converter.',
      inputs: const <SimInput>[SimInput('c', 'Cell capacity', 500, 5000, step: 100, initial: 1000, unit: 'mAh'), SimInput('p', 'Device power', 50, 2000, step: 50, initial: 1000, unit: 'mW'), SimInput('k', 'Converter efficiency', 0.6, 0.95, step: 0.05, initial: 0.8)],
      outputs: const <SimOutput>[SimOutput('I', 'Battery current', 'p/(3.7*k)', unit: 'mA', decimals: 1), SimOutput('H', 'Runtime', 'c/(p/(3.7*k))', unit: 'h', decimals: 2)],
      given: const <String, double>{'c': 2000, 'p': 740, 'k': 0.8}, ask: const <String>['I', 'H'], formulas: const <String>['I = P/(V η)', 'runtime = capacity / I'],
      levels: cum(<SimConstraint>[ge('H', 8, 'Run at least 8 hours')], <SimConstraint>[le('c', 3000, 'Cell no larger than 3000 mAh (enclosure)')], <SimConstraint>[ge('p', 500, 'Device draws at least 500 mW (screen on)'), le('k', 0.9, 'Converter no better than 90%'), ge('H', 12, 'Run at least 12 hours')]),
      models: same(const <String, double>{'c': 1900, 'p': 500, 'k': 0.9}),
    ),
  ], person: _peter),
);

// ---------------------------------------------------------------- D. Digital logic

class _Logic {
  const _Logic(this.key, this.title, this.brief, this.inputs, this.outputs, this.f, this.describe, this.wrongDescribe, this.expr, this.wrongExpr);
  final String key;
  final String title;
  final String brief;
  final List<String> inputs;
  final List<String> outputs;

  /// Truth function: input bits → output bits.
  final List<int> Function(List<int>) f;
  final String describe;
  final List<String> wrongDescribe;
  final String expr;
  final List<String> wrongExpr;
}

final List<_Logic> _logic = <_Logic>[
  _Logic('alarm', 'Intruder alarm logic', 'The siren Y sounds if a door is open (A) while the system is armed (B), or if the panic button (C) is pressed.', <String>['A', 'B', 'C'], <String>['Y'],
      (List<int> x) => <int>[(x[0] & x[1]) | x[2]], 'Y is 1 when A and B are both 1, or whenever C is 1', <String>['Y is 1 only when all inputs are 1', 'Y is 1 when any input is 1'], 'Y = AB + C', <String>['Y = A + BC', 'Y = (A + B)C', 'Y = ABC']),
  _Logic('majority', 'Triple-redundant sensor voter', 'Three safety sensors vote: the output trips when at least two agree.', <String>['A', 'B', 'C'], <String>['Y'],
      (List<int> x) => <int>[(x[0] + x[1] + x[2]) >= 2 ? 1 : 0], 'Y is 1 when at least two inputs are 1', <String>['Y is 1 when exactly one input is 1', 'Y is 1 only when all are 1'], 'Y = AB + BC + AC', <String>['Y = A + B + C', 'Y = ABC', 'Y = A ⊕ B ⊕ C']),
  _Logic('parity', 'Parity generator', 'A serial link adds a parity bit so the number of 1s is even.', <String>['A', 'B', 'C'], <String>['P'],
      (List<int> x) => <int>[x[0] ^ x[1] ^ x[2]], 'P is 1 when an odd number of inputs are 1', <String>['P is 1 when all inputs are equal', 'P is 1 when at least two inputs are 1'], 'P = A ⊕ B ⊕ C', <String>['P = ABC', 'P = A + B + C', 'P = AB + C']),
  _Logic('halfadder', 'Half adder', 'Add two bits A and B, producing a sum S and a carry K.', <String>['A', 'B'], <String>['S', 'K'],
      (List<int> x) => <int>[x[0] ^ x[1], x[0] & x[1]], 'S is A XOR B and K is A AND B', <String>['S is A OR B and K is A AND B', 'S is A AND B and K is A XOR B'], 'S = A ⊕ B, K = AB', <String>['S = A + B, K = AB', 'S = AB, K = A ⊕ B']),
  _Logic('demorgan', 'Interlock with NOR logic', 'A machine may run (Y = 1) only when neither guard switch A nor B is open.', <String>['A', 'B'], <String>['Y'],
      (List<int> x) => <int>[1 - (x[0] | x[1])], 'Y is 1 only when both A and B are 0', <String>['Y is 1 when either is 0', 'Y is 1 when both are 1'], 'Y = ¬(A + B) = ¬A·¬B', <String>['Y = ¬A + ¬B', 'Y = ¬(AB)', 'Y = A + B']),
];

List<LabScenario> _logicScenarios() {
  final List<LabScenario> out = <LabScenario>[];
  for (int l = 0; l < 3; l++) {
    for (final _Logic g in _logic) {
      final int n = g.inputs.length;
      final List<List<int>> rows = <List<int>>[for (int r = 0; r < (1 << n); r++) <int>[for (int k = n - 1; k >= 0; k--) (r >> k) & 1]];
      final int ones = rows.where((List<int> r) => g.f(r).first == 1).length;
      out.add(LabScenario(
        id: 'eg_${g.key}_${l + 1}',
        title: '${g.title}${<String>['', ' — simplify', ' — implement and verify'][l]}',
        level: levels3[l],
        people: const <LabPerson>[_peter],
        briefing: Briefing(
          what: g.brief,
          why: 'Control and safety systems depend on logic that is exactly right for every input combination.',
          information: <String>['Inputs: ${g.inputs.join(', ')}. Outputs: ${g.outputs.join(', ')}.', '⊕ is XOR, + is OR, juxtaposition is AND, ¬ is NOT.'],
          tools: const <String>['Truth-table workbench', 'Calculator'],
          expected: 'A truth table correct for every input combination${l > 0 ? ' and the correct Boolean expression' : ''}${l > 1 ? ', with the implementation checked' : ''}.',
        ),
        steps: <LabStep>[
          TriageStep(
            id: 'eg_${g.key}_${l + 1}_tt',
            title: 'Complete the truth table',
            instructions: 'Set each output for every input combination.',
            queueName: 'Truth table',
            fields: <TriageField>[for (final String o in g.outputs) TriageField(o, 'Output $o', const <String>['0', '1'])],
            items: <TriageItem>[
              for (final List<int> r in rows)
                TriageItem(
                  id: 'r${r.join()}',
                  title: g.inputs.asMap().entries.map((MapEntry<int, String> e) => '${e.value} = ${r[e.key]}').join(', '),
                  body: 'Input combination ${r.join()}',
                  answers: <String, String>{for (int k = 0; k < g.outputs.length; k++) g.outputs[k]: '${g.f(r)[k]}'},
                ),
            ],
          ),
          if (l > 0)
            NumericStep(id: 'eg_${g.key}_${l + 1}_expr', title: 'Write the logic', instructions: 'Choose the expression that matches your table.', questions: <MathQuestion>[
              pick('expr', 'Boolean expression', g.expr, g.wrongExpr),
              if (l == 2) pick('desc', 'Describe the behaviour for the client', g.describe, g.wrongDescribe),
              if (l == 2) NumberQuestion('ones', 'How many input combinations give ${g.outputs.first} = 1?', ones.toDouble(), tolerance: 0),
            ]),
        ],
      ));
    }
  }
  return out;
}

final LabSpec elecLogicLab = designLab(
  id: 'ee_lab_logic', deptId: _d, majorId: _m, number: 4, title: 'Digital Logic', environment: LabEnvironment.engineeringOffice,
  summary: 'Specify control and safety logic: build truth tables for every input combination, derive the Boolean expression and verify the implementation.',
  objectives: const <String>['Build truth tables', 'Derive and simplify Boolean expressions', 'Verify logic designs'],
  skills: const <String>['en_elec'],
  scenarios: _logicScenarios(),
);

final LabSpec elecPowerLab = designLab(
  id: 'ee_lab_power', deptId: _d, majorId: _m, number: 5, title: 'Power Systems', environment: LabEnvironment.engineeringOffice,
  summary: 'Transmission losses, transformers, generator sizing, solar PV yield and fault levels.',
  objectives: const <String>['Reduce transmission losses', 'Specify transformers and generators', 'Check fault levels and renewable yield'],
  skills: const <String>['en_elec', 'en_safety'],
  reference: const <String>['Line current I = P/(√3 V pf); loss = 3I²R.', 'Turns ratio V_s/V_p = N_s/N_p.', 'Fault current I_f = V/(√3 Z).'],
  scenarios: fromProblems('ep', <DesignProblem>[
    DesignProblem(
      key: 'losses', title: 'Transmission voltage choice', brief: 'Transmit power over a line (pf 0.95) with acceptable I²R losses.',
      inputs: const <SimInput>[SimInput('P', 'Power', 10, 200, step: 5, initial: 100, unit: 'MW'), SimInput('V', 'Line voltage', 11, 400, step: 1, initial: 33, unit: 'kV'), SimInput('R', 'Resistance per phase', 0.5, 10, step: 0.5, initial: 5, unit: 'Ω')],
      outputs: const <SimOutput>[SimOutput('I', 'Line current', 'P*1000000/(sqrt(3)*V*1000*0.95)', unit: 'A', decimals: 0), SimOutput('L', 'Line loss', '3*(P*1000000/(sqrt(3)*V*1000*0.95))^2*R/1000000', unit: 'MW', decimals: 3), SimOutput('Z', 'Loss', '3*(P*1000000/(sqrt(3)*V*1000*0.95))^2*R/1000000/P*100', unit: '%', decimals: 2)],
      given: const <String, double>{'P': 50, 'V': 132, 'R': 2}, ask: const <String>['I', 'L'], formulas: const <String>['I = P/(√3 V pf)', 'loss = 3I²R'],
      levels: cum(<SimConstraint>[ge('P', 100, 'Transmit at least 100 MW'), le('Z', 5, 'Losses no more than 5%')], <SimConstraint>[ge('R', 4, 'Long line: R ≥ 4 Ω per phase')], <SimConstraint>[le('V', 275, 'Voltage no more than 275 kV (existing substation)'), le('Z', 1, 'Losses no more than 1%')]),
      models: same(const <String, double>{'P': 100, 'V': 275, 'R': 4}),
      interpret: const ChoiceQuestion('why', 'Raising transmission voltage reduces losses because', <String>['current falls, and losses go with current squared', 'resistance falls', 'power factor improves'], 0),
    ),
    DesignProblem(
      key: 'transformer', title: 'Distribution transformer', brief: 'Specify turns for an 11 kV to 415 V distribution transformer.',
      inputs: const <SimInput>[SimInput('p', 'Primary turns', 100, 2000, step: 10, initial: 1000), SimInput('s', 'Secondary turns', 10, 500, step: 1, initial: 100)],
      outputs: const <SimOutput>[SimOutput('V', 'Secondary voltage', '11000*s/p', unit: 'V', decimals: 1)],
      given: const <String, double>{'p': 500, 's': 10}, ask: const <String>['V'], formulas: const <String>['V_s = V_p N_s/N_p'],
      levels: cum(<SimConstraint>[ge('V', 410, 'At least 410 V'), le('V', 420, 'No more than 420 V')], <SimConstraint>[le('p', 1500, 'No more than 1500 primary turns')], <SimConstraint>[le('s', 40, 'No more than 40 secondary turns (conductor size)')]),
      models: same(const <String, double>{'p': 1060, 's': 40}),
    ),
    DesignProblem(
      key: 'generator', title: 'Standby generator sizing', brief: 'Size a standby generator (pf 0.8) with headroom.',
      inputs: const <SimInput>[SimInput('L', 'Connected load', 50, 500, step: 10, initial: 300, unit: 'kW'), SimInput('d', 'Diversity factor', 0.5, 1, step: 0.05, initial: 0.6), SimInput('G', 'Generator rating', 50, 500, step: 10, initial: 200, unit: 'kVA')],
      outputs: const <SimOutput>[SimOutput('D', 'Maximum demand', 'L*d', unit: 'kW', decimals: 0), SimOutput('U', 'Loading', 'L*d/(G*0.8)', decimals: 3)],
      given: const <String, double>{'L': 200, 'd': 0.8, 'G': 250}, ask: const <String>['D', 'U'], formulas: const <String>['demand = connected × diversity', 'loading = demand / (kVA × pf)'],
      levels: cum(<SimConstraint>[ge('L', 300, 'Connected load 300 kW'), le('U', 0.8, 'Generator loaded no more than 80%')], <SimConstraint>[le('G', 350, 'Generator no larger than 350 kVA (plant room)')], <SimConstraint>[ge('d', 0.7, 'Measured diversity at least 0.7'), le('U', 0.75, 'Loaded no more than 75%')]),
      models: same(const <String, double>{'L': 300, 'd': 0.7, 'G': 350}),
    ),
    DesignProblem(
      key: 'solar', title: 'Rooftop solar array', brief: 'Size a PV array to cover a small office’s daily use.',
      inputs: const <SimInput>[SimInput('k', 'Array size', 1, 20, step: 0.5, initial: 3, unit: 'kWp'), SimInput('h', 'Peak sun hours', 2, 6, step: 0.1, initial: 3.5, unit: 'h/day'), SimInput('r', 'Performance ratio', 0.6, 0.9, step: 0.05, initial: 0.75)],
      outputs: const <SimOutput>[SimOutput('E', 'Daily yield', 'k*h*r', unit: 'kWh/day')],
      given: const <String, double>{'k': 5, 'h': 3.5, 'r': 0.8}, ask: const <String>['E'], formulas: const <String>['E = kWp × sun hours × PR'],
      levels: cum(<SimConstraint>[ge('E', 20, 'At least 20 kWh/day')], <SimConstraint>[le('h', 4, 'Site data: no more than 4 sun hours')], <SimConstraint>[le('r', 0.8, 'PR no more than 0.8'), le('k', 8, 'Roof space: no more than 8 kWp')]),
      models: same(const <String, double>{'k': 8, 'h': 4, 'r': 0.8}),
    ),
    DesignProblem(
      key: 'fault', title: 'Fault level at a switchboard', brief: 'Check prospective fault current against a 10 kA breaker, while ensuring protection still trips.',
      inputs: const <SimInput>[SimInput('Z', 'Fault-loop impedance', 0.01, 1, step: 0.01, initial: 0.01, unit: 'Ω')],
      outputs: const <SimOutput>[SimOutput('I', 'Prospective fault current', '400/(sqrt(3)*Z)/1000', unit: 'kA', decimals: 2)],
      given: const <String, double>{'Z': 0.1}, ask: const <String>['I'], formulas: const <String>['I_f = V/(√3 Z), V = 400 V'],
      levels: cum(<SimConstraint>[le('I', 10, 'Within the 10 kA breaking capacity')], <SimConstraint>[le('Z', 0.05, 'Short cable run: Z ≤ 0.05 Ω')], <SimConstraint>[ge('I', 4, 'At least 4 kA so protection trips fast')]),
      models: same(const <String, double>{'Z': 0.05}),
    ),
  ], person: _peter),
);

final LabSpec elecFaultLab = designLab(
  id: 'ee_lab_faults', deptId: _d, majorId: _m, number: 6, title: 'Fault Diagnosis', environment: LabEnvironment.engineeringOffice,
  summary: 'Test, diagnose, correct and document faults in real circuits — always isolating safely first.',
  objectives: const <String>['Interpret test readings', 'Diagnose faults', 'Repair safely'],
  skills: const <String>['en_elec', 'en_safety'],
  portfolio: true,
  scenarios: fromInvestigations('ef', const <Investigation>[
    Investigation(
      key: 'open', title: 'Lighting circuit dead', brief: 'A string of 230 V lights in series stopped working.',
      evidence: <(String, bool)>[('The supply measures 230 V at the input.', true), ('Continuity test: infinite resistance across lamp 4, others read about 500 Ω.', true), ('Voltage across lamp 4 reads the full 230 V with the circuit live.', true), ('The lamps are a warm-white colour.', false), ('The switch was replaced last year.', false)],
      cause: 'An open-circuit filament in lamp 4', wrongCauses: <String>['A short circuit in the supply', 'The supply voltage is too low', 'All lamps have aged equally'],
      fix: 'Isolate, replace lamp 4 and re-test continuity', wrongFixes: <String>['Bridge lamp 4 with wire', 'Increase the supply voltage', 'Replace every lamp without testing'],
      calc: ('Ten 500 Ω lamps in series on 230 V. Current when working?', 0.046, 'A', 'I = 230/5000 = 0.046 A.'),
      steps: <String>['Isolate the circuit and prove it dead', 'Remove lamp 4', 'Fit a replacement lamp', 'Restore supply', 'Confirm all lamps light and record the test'],
      mustPrecede: <(int, int)>[(0, 1), (2, 3)],
    ),
    Investigation(
      key: 'short', title: 'Fuse blows on switch-on', brief: 'A 13 A fused spur blows its fuse every time a heater is switched on.',
      evidence: <(String, bool)>[('Insulation resistance between live and neutral reads 0.2 Ω.', true), ('The heater element is rated 2 kW (about 8.7 A).', true), ('Burn marks on the terminal block inside the heater.', true), ('The fuse is the correct 13 A type.', false), ('The heater is two years old.', false)],
      cause: 'A live-to-neutral short circuit at the heater terminal block', wrongCauses: <String>['An overload from the 2 kW element', 'A faulty fuse type', 'Low supply voltage'],
      fix: 'Isolate, replace the damaged terminal block and re-test insulation resistance before re-energising', wrongFixes: <String>['Fit a 30 A fuse', 'Wrap the terminals in tape', 'Keep replacing fuses'],
      calc: ('Fault current through a 0.2 Ω short at 230 V?', 1150, 'A', '230/0.2 = 1150 A — far above 13 A, so the fuse operates.'),
      steps: <String>['Isolate and lock off the spur', 'Prove dead with a tester', 'Replace the terminal block', 'Insulation-resistance test', 'Re-energise and function-test'],
      mustPrecede: <(int, int)>[(0, 2), (1, 2), (3, 4)],
    ),
    Investigation(
      key: 'rcd', title: 'RCD trips in wet weather', brief: 'An outdoor socket circuit’s RCD trips whenever it rains.',
      evidence: <(String, bool)>[('Insulation resistance live–earth falls to 0.3 MΩ after rain.', true), ('Water is found inside the outdoor socket enclosure.', true), ('The RCD trips at 28 mA in a test (rated 30 mA).', true), ('The circuit cable is new.', false), ('The garden lights are LED.', false)],
      cause: 'Water ingress causing earth leakage at the outdoor socket', wrongCauses: <String>['A faulty RCD that trips too easily', 'Overload from the garden lights', 'A neutral–earth swap at the board'],
      fix: 'Replace the socket with an IP-rated weatherproof enclosure and re-test', wrongFixes: <String>['Replace the RCD with a non-RCD breaker', 'Bypass the RCD in wet weather', 'Turn off the circuit in winter'],
      calc: ('Leakage current at 230 V through 0.3 MΩ, in mA?', 0.767, 'mA', '230 / 300 000 Ω = 0.77 mA — combined with other leakage and transients it causes trips.'),
      steps: <String>['Isolate the circuit', 'Open and dry the enclosure', 'Fit a weatherproof IP66 socket', 'Insulation-resistance and RCD test', 'Restore supply'],
      mustPrecede: <(int, int)>[(0, 1), (3, 4)],
    ),
    Investigation(
      key: 'motor', title: 'Motor overheating and humming', brief: 'A three-phase pump motor hums, runs slowly and overheats.',
      evidence: <(String, bool)>[('Phase voltages: L1 400 V, L2 400 V, L3 0 V.', true), ('One fuse in the motor starter has blown.', true), ('Current on the two healthy phases is about 1.7 times normal.', true), ('The pump was painted last month.', false), ('The motor nameplate is faded.', false)],
      cause: 'Single-phasing from a blown fuse on one phase', wrongCauses: <String>['A bearing failure', 'An over-voltage on all phases', 'An incorrect pump impeller'],
      fix: 'Isolate, find why the fuse blew, replace it and fit phase-failure protection', wrongFixes: <String>['Keep running and monitor', 'Increase the overload setting', 'Swap two phases'],
      calc: ('A motor normally draws 20 A. Current on the healthy phases at 1.73 times normal?', 34.6, 'A', '20 × 1.73 = 34.6 A — enough to overheat the windings.'),
      steps: <String>['Stop and isolate the motor', 'Test the fuses and phase voltages', 'Find and correct the cause of the blown fuse', 'Replace the fuse and fit phase-failure protection', 'Restart and measure the three phase currents'],
      mustPrecede: <(int, int)>[(0, 1), (2, 3)],
    ),
    Investigation(
      key: 'drain', title: 'Vehicle battery flat overnight', brief: 'A fleet van’s 12 V battery goes flat after being parked overnight.',
      evidence: <(String, bool)>[('With everything off, the battery supplies 450 mA.', true), ('Pulling the fuse for the aftermarket tracker drops it to 30 mA.', true), ('The tracker was fitted last week.', true), ('The battery passes a load test when charged.', false), ('The van is white.', false)],
      cause: 'A parasitic drain from the incorrectly wired aftermarket tracker', wrongCauses: <String>['A failed battery', 'A faulty alternator', 'Cold weather alone'],
      fix: 'Rewire the tracker to an ignition-switched feed and re-measure the parasitic draw', wrongFixes: <String>['Fit a bigger battery', 'Disconnect the battery every night', 'Ignore it'],
      calc: ('A 70 Ah battery losing 0.45 A. Hours until it is half discharged?', 77.8, 'h', '35 Ah / 0.45 A ≈ 78 h — and starting fails well before half charge in cold weather.'),
      steps: <String>['Connect an ammeter in series with the battery', 'Pull fuses one at a time to find the drain', 'Rewire the tracker to an ignition feed', 'Re-measure the parasitic current', 'Record the repair on the job card'],
      mustPrecede: <(int, int)>[(0, 1), (2, 3)],
    ),
  ], person: _peter),
);

final List<LabSpec> electricalLabs = <LabSpec>[elecConstructionLab, elecAnalysisLab, elecElectronicsLab, elecLogicLab, elecPowerLab, elecFaultLab];
