/// Chemical Engineering at Aurora Process Industries.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';
import 'design_kit.dart';

const LabPerson _kavita = LabPerson('Dr Kavita Rao', 'Process Engineering Manager', 'Close every balance before you change a set-point. The plant does not forgive guesses.');
const String _d = 'engineering';
const String _m = 'chemical_engineering';
List<String> _sk = const <String>['en_process'];

final LabSpec chemFundamentalsLab = designLab(
  id: 'che_lab_fundamentals', deptId: _d, majorId: _m, number: 1, title: 'Chemical Process Fundamentals', environment: LabEnvironment.engineeringOffice,
  summary: 'Material and energy balances on mixers, evaporators, heaters, burners and dilutions.',
  objectives: const <String>['Write and close material balances', 'Calculate heat duties', 'Apply stoichiometry'],
  skills: _sk,
  reference: const <String>['In = Out + Accumulation (steady state: In = Out).', 'Q = ṁ c_p ΔT.', 'CH₄ + 2O₂ → CO₂ + 2H₂O; air is 21% O₂.', 'C₁V₁ = C₂V₂.'],
  scenarios: fromProblems('cf', <DesignProblem>[
    DesignProblem(
      key: 'mixer', title: 'Brine mixer', brief: 'Blend a 20% salt stream with a weak stream to make 10% brine.',
      inputs: const <SimInput>[SimInput('a', 'Strong stream (20% salt)', 10, 200, step: 10, initial: 100, unit: 'kg/h'), SimInput('b', 'Weak stream', 10, 200, step: 10, initial: 100, unit: 'kg/h'), SimInput('c', 'Weak stream salt fraction', 0, 0.1, step: 0.01, initial: 0.08)],
      outputs: const <SimOutput>[SimOutput('X', 'Product salt fraction', '(a*0.2 + b*c)/(a + b)', decimals: 4), SimOutput('T', 'Product flow', 'a + b', unit: 'kg/h', decimals: 0)],
      given: const <String, double>{'a': 50, 'b': 150, 'c': 0.04}, ask: const <String>['X'], formulas: const <String>['Salt balance: 0.2a + cb = x(a + b)'],
      levels: cum(<SimConstraint>[ge('X', 0.099, 'Product 10% salt (±0.1%)'), le('X', 0.101, 'Product 10% salt (±0.1%)'), ge('T', 150, 'At least 150 kg/h')], <SimConstraint>[le('a', 70, 'Strong stream supply limited to 70 kg/h')], <SimConstraint>[le('c', 0.05, 'Weak stream no more than 5% salt'), ge('T', 160, 'At least 160 kg/h')]),
      models: same(const <String, double>{'a': 70, 'b': 140, 'c': 0.05}),
    ),
    DesignProblem(
      key: 'evaporator', title: 'Juice evaporator', brief: 'Concentrate fruit juice by evaporating water.',
      inputs: const <SimInput>[SimInput('F', 'Feed', 100, 2000, step: 50, initial: 1000, unit: 'kg/h'), SimInput('f', 'Feed solids fraction', 0.05, 0.3, step: 0.01, initial: 0.1), SimInput('p', 'Product solids fraction', 0.3, 0.8, step: 0.05, initial: 0.4)],
      outputs: const <SimOutput>[SimOutput('P', 'Product', 'F*f/p', unit: 'kg/h', decimals: 1), SimOutput('W', 'Water evaporated', 'F - F*f/p', unit: 'kg/h', decimals: 1)],
      given: const <String, double>{'F': 1000, 'f': 0.1, 'p': 0.5}, ask: const <String>['P', 'W'], formulas: const <String>['Solids: F x_F = P x_P', 'Water evaporated = F − P'],
      levels: cum(<SimConstraint>[ge('P', 200, 'At least 200 kg/h of product'), ge('p', 0.5, 'Product at least 50% solids')], <SimConstraint>[le('W', 1200, 'Evaporator capacity 1200 kg/h of water')], <SimConstraint>[le('f', 0.15, 'This season’s juice: no more than 15% solids'), ge('P', 250, 'At least 250 kg/h of product')]),
      models: same(const <String, double>{'F': 900, 'f': 0.15, 'p': 0.5}),
    ),
    DesignProblem(
      key: 'heater', title: 'Process heater duty', brief: 'Heat a liquid stream within a 200 kW heater.',
      inputs: const <SimInput>[SimInput('m', 'Mass flow', 0.1, 5, step: 0.1, initial: 2, unit: 'kg/s'), SimInput('c', 'Heat capacity', 1, 4.2, step: 0.1, initial: 4, unit: 'kJ/kg·K'), SimInput('d', 'Temperature rise', 5, 80, step: 1, initial: 50, unit: 'K')],
      outputs: const <SimOutput>[SimOutput('Q', 'Heat duty', 'm*c*d', unit: 'kW', decimals: 1)],
      given: const <String, double>{'m': 1, 'c': 4.18, 'd': 30}, ask: const <String>['Q'], formulas: const <String>['Q = ṁ c_p ΔT'],
      levels: cum(<SimConstraint>[ge('m', 1, 'At least 1 kg/s'), ge('d', 40, 'Raise by at least 40 K'), le('Q', 200, 'Within the 200 kW heater')], <SimConstraint>[ge('c', 4, 'Aqueous stream: c_p ≥ 4 kJ/kg·K')], <SimConstraint>[ge('m', 1.2, 'Throughput at least 1.2 kg/s')]),
      models: same(const <String, double>{'m': 1.2, 'c': 4, 'd': 40}),
    ),
    DesignProblem(
      key: 'burner', title: 'Gas burner air supply', brief: 'Set the air supply for a methane burner.',
      inputs: const <SimInput>[SimInput('n', 'Methane', 1, 20, step: 1, initial: 10, unit: 'kmol/h'), SimInput('x', 'Excess air', 0, 50, step: 1, initial: 0, unit: '%')],
      outputs: const <SimOutput>[SimOutput('A', 'Air required', 'n*2/0.21*(1 + x/100)', unit: 'kmol/h', decimals: 1), SimOutput('O', 'O₂ in flue gas', 'n*2*x/100', unit: 'kmol/h', decimals: 2)],
      given: const <String, double>{'n': 5, 'x': 20}, ask: const <String>['A', 'O'], formulas: const <String>['O₂ needed = 2 × CH₄', 'Air = O₂ ÷ 0.21 × (1 + excess)'],
      levels: cum(<SimConstraint>[ge('n', 10, 'Fire at least 10 kmol/h'), ge('x', 10, 'At least 10% excess air (complete combustion)')], <SimConstraint>[le('A', 115, 'Fan capacity 115 kmol/h')], <SimConstraint>[ge('x', 15, 'At least 15% excess air (burner vendor)')]),
      models: same(const <String, double>{'n': 10, 'x': 15}),
    ),
    DesignProblem(
      key: 'dilution', title: 'Acid dilution for cleaning', brief: 'Prepare 1 M acid for clean-in-place from a concentrated stock.',
      inputs: const <SimInput>[SimInput('c', 'Stock concentration', 1, 12, step: 0.5, initial: 12, unit: 'M'), SimInput('v', 'Stock volume', 1, 100, step: 1, initial: 10, unit: 'mL'), SimInput('V', 'Final volume', 50, 1000, step: 50, initial: 100, unit: 'mL')],
      outputs: const <SimOutput>[SimOutput('C', 'Final concentration', 'c*v/V', unit: 'M', decimals: 3)],
      given: const <String, double>{'c': 6, 'v': 25, 'V': 250}, ask: const <String>['C'], formulas: const <String>['C₁V₁ = C₂V₂'],
      levels: cum(<SimConstraint>[ge('C', 0.95, 'At least 0.95 M'), le('C', 1.05, 'No more than 1.05 M'), ge('V', 500, 'Make at least 500 mL')], <SimConstraint>[le('v', 60, 'Pipette no more than 60 mL')], <SimConstraint>[le('c', 10, 'Use the 10 M stock (safer handling)')]),
      models: same(const <String, double>{'c': 10, 'v': 50, 'V': 500}),
    ),
  ], person: _kavita),
);

final LabSpec chemReactionLab = designLab(
  id: 'che_lab_reaction', deptId: _d, majorId: _m, number: 2, title: 'Reaction Engineering', environment: LabEnvironment.engineeringOffice,
  summary: 'Conversion, rate constants, reactor sizing, yield and selectivity.',
  objectives: const <String>['Use rate laws and the Arrhenius equation', 'Size batch, CSTR and PFR reactors', 'Trade conversion against selectivity'],
  skills: _sk,
  reference: const <String>['First order batch/PFR: X = 1 − e^(−kt); PFR V = F(−ln(1 − X))/k.', 'CSTR first order: V = F X / (k(1 − X)).', 'Arrhenius: k = A e^(−Ea/RT), R = 8.314 J/mol·K.'],
  scenarios: fromProblems('cr', <DesignProblem>[
    DesignProblem(
      key: 'batch', title: 'Batch reactor cycle time', brief: 'Set the batch time to reach the conversion target.',
      inputs: const <SimInput>[SimInput('k', 'Rate constant', 0.01, 1, step: 0.01, initial: 0.01, unit: '1/min'), SimInput('t', 'Batch time', 1, 120, step: 1, initial: 30, unit: 'min')],
      outputs: const <SimOutput>[SimOutput('X', 'Conversion', '1 - exp(-k*t)', decimals: 3)],
      given: const <String, double>{'k': 0.1, 't': 20}, ask: const <String>['X'], formulas: const <String>['X = 1 − e^(−kt)'],
      levels: cum(<SimConstraint>[ge('X', 0.9, 'Conversion at least 90%')], <SimConstraint>[le('t', 60, 'Batch time no more than 60 min')], <SimConstraint>[le('k', 0.05, 'Temperature limit: k ≤ 0.05 /min')]),
      models: same(const <String, double>{'k': 0.05, 't': 60}),
    ),
    DesignProblem(
      key: 'arrhenius', title: 'Operating temperature', brief: 'Choose a temperature that gives an adequate rate constant (A = 10¹⁰ /s).',
      inputs: const <SimInput>[SimInput('T', 'Temperature', 300, 500, step: 5, initial: 300, unit: 'K'), SimInput('E', 'Activation energy', 40, 120, step: 5, initial: 80, unit: 'kJ/mol')],
      outputs: const <SimOutput>[SimOutput('k', 'Rate constant', '10000000000*exp(-E*1000/(8.314*T))', unit: '1/s', decimals: 5)],
      given: const <String, double>{'T': 350, 'E': 60}, ask: const <String>['k'], formulas: const <String>['k = A e^(−Ea/RT)'],
      levels: cum(<SimConstraint>[ge('k', 0.01, 'k at least 0.01 /s')], <SimConstraint>[le('T', 450, 'Catalyst limit 450 K')], <SimConstraint>[ge('E', 90, 'Measured Ea for this reaction: 90 kJ/mol')]),
      models: same(const <String, double>{'T': 400, 'E': 90}),
      interpret: const ChoiceQuestion('why', 'Raising temperature increases k because', <String>['more molecules exceed the activation energy', 'activation energy falls', 'concentration rises'], 0),
    ),
    DesignProblem(
      key: 'cstr', title: 'CSTR sizing', brief: 'Size a continuous stirred-tank reactor for a first-order reaction.',
      inputs: const <SimInput>[SimInput('F', 'Feed flow', 1, 50, step: 1, initial: 30, unit: 'L/min'), SimInput('X', 'Target conversion', 0.5, 0.95, step: 0.01, initial: 0.9), SimInput('k', 'Rate constant', 0.05, 1, step: 0.01, initial: 0.1, unit: '1/min')],
      outputs: const <SimOutput>[SimOutput('V', 'Reactor volume', 'F*X/(k*(1 - X))', unit: 'L', decimals: 0)],
      given: const <String, double>{'F': 10, 'X': 0.8, 'k': 0.2}, ask: const <String>['V'], formulas: const <String>['V = F X / (k(1 − X))'],
      levels: cum(<SimConstraint>[ge('X', 0.8, 'Conversion at least 80%'), le('V', 500, 'Vessel no larger than 500 L')], <SimConstraint>[ge('F', 20, 'Throughput at least 20 L/min')], <SimConstraint>[le('k', 0.25, 'k no more than 0.25 /min (temperature limit)'), ge('X', 0.85, 'Conversion at least 85%')]),
      models: same(const <String, double>{'F': 20, 'X': 0.85, 'k': 0.25}),
    ),
    DesignProblem(
      key: 'selectivity', title: 'Conversion versus selectivity', brief: 'A → B (wanted) competes with A → C. Higher conversion lowers selectivity: S ≤ 1.3 − 0.5X on this catalyst. Feed 100 kmol/h.',
      inputs: const <SimInput>[SimInput('X', 'Conversion', 0.5, 0.99, step: 0.01, initial: 0.6), SimInput('S', 'Selectivity to B', 0.5, 0.99, step: 0.01, initial: 0.7)],
      outputs: const <SimOutput>[SimOutput('Y', 'Yield of B', 'X*S', decimals: 3), SimOutput('C', 'By-product C', '100*X*(1 - S)', unit: 'kmol/h'), SimOutput('Q', 'S + 0.5X (catalyst limit 1.3)', 'S + 0.5*X')],
      given: const <String, double>{'X': 0.8, 'S': 0.9}, ask: const <String>['Y', 'C'], formulas: const <String>['Yield = conversion × selectivity'],
      levels: cum(<SimConstraint>[ge('Y', 0.75, 'Yield at least 75%'), le('Q', 1.3, 'Within the catalyst’s trade-off')], <SimConstraint>[le('C', 15, 'By-product no more than 15 kmol/h (waste treatment)')], <SimConstraint>[ge('Y', 0.76, 'Yield at least 76%')]),
      models: same(const <String, double>{'X': 0.9, 'S': 0.85}),
    ),
    DesignProblem(
      key: 'pfr', title: 'Plug-flow reactor sizing', brief: 'Size a tubular reactor for a first-order reaction.',
      inputs: const <SimInput>[SimInput('F', 'Feed flow', 1, 50, step: 1, initial: 30, unit: 'L/min'), SimInput('k', 'Rate constant', 0.05, 1, step: 0.01, initial: 0.1, unit: '1/min'), SimInput('X', 'Target conversion', 0.5, 0.99, step: 0.01, initial: 0.95)],
      outputs: const <SimOutput>[SimOutput('V', 'Reactor volume', 'F*(-ln(1 - X))/k', unit: 'L', decimals: 0)],
      given: const <String, double>{'F': 10, 'k': 0.5, 'X': 0.8}, ask: const <String>['V'], formulas: const <String>['V = F(−ln(1 − X))/k'],
      levels: cum(<SimConstraint>[ge('X', 0.9, 'Conversion at least 90%'), le('V', 300, 'Volume no more than 300 L')], <SimConstraint>[ge('F', 15, 'Throughput at least 15 L/min')], <SimConstraint>[le('k', 0.2, 'k no more than 0.2 /min')]),
      models: same(const <String, double>{'F': 15, 'k': 0.2, 'X': 0.9}),
      interpret: const ChoiceQuestion('cmp', 'For the same first-order conversion, compared with a CSTR a PFR needs', <String>['a smaller volume', 'a larger volume', 'the same volume'], 0),
    ),
  ], person: _kavita),
);

final LabSpec chemSeparationLab = designLab(
  id: 'che_lab_separation', deptId: _d, majorId: _m, number: 3, title: 'Separation Processes', environment: LabEnvironment.engineeringOffice,
  summary: 'Distillation, filtration, extraction, reverse osmosis and drying.',
  objectives: const <String>['Estimate distillation stages', 'Size filters and membranes', 'Design extraction and drying duties'],
  skills: _sk,
  reference: const <String>['Fenske: N_min = ln[(x_D/(1 − x_D))((1 − x_B)/x_B)] / ln α.', 'Single-stage extraction: fraction extracted = 1 − 1/(1 + K S/F).', 'Latent heat of water ≈ 2260 kJ/kg.'],
  scenarios: fromProblems('cx', <DesignProblem>[
    DesignProblem(
      key: 'fenske', title: 'Distillation column stages', brief: 'Estimate the minimum stages for a binary separation.',
      inputs: const <SimInput>[SimInput('a', 'Relative volatility α', 1.2, 4, step: 0.1, initial: 1.5), SimInput('d', 'Distillate purity x_D', 0.8, 0.99, step: 0.01, initial: 0.99), SimInput('b', 'Bottoms light-component x_B', 0.01, 0.2, step: 0.01, initial: 0.01)],
      outputs: const <SimOutput>[SimOutput('N', 'Minimum stages', 'ln(d/(1 - d)*(1 - b)/b)/ln(a)', decimals: 2)],
      given: const <String, double>{'a': 2, 'd': 0.95, 'b': 0.05}, ask: const <String>['N'], formulas: const <String>['Fenske equation'],
      levels: cum(<SimConstraint>[ge('d', 0.95, 'Distillate at least 95%'), le('b', 0.05, 'Bottoms no more than 5% light'), le('N', 12, 'No more than 12 stages (existing column)')], <SimConstraint>[le('a', 2.5, 'This mixture: α ≤ 2.5')], <SimConstraint>[ge('d', 0.98, 'Distillate at least 98%')]),
      models: same(const <String, double>{'a': 2.5, 'd': 0.98, 'b': 0.05}),
    ),
    DesignProblem(
      key: 'filter', title: 'Filter press area', brief: 'Size a filter to process a batch of slurry filtrate.',
      inputs: const <SimInput>[SimInput('V', 'Filtrate volume', 1, 50, step: 1, initial: 30, unit: 'm³'), SimInput('j', 'Average flux', 0.05, 1, step: 0.05, initial: 0.1, unit: 'm³/m²·h'), SimInput('t', 'Filtration time', 1, 12, step: 0.5, initial: 4, unit: 'h')],
      outputs: const <SimOutput>[SimOutput('A', 'Filter area', 'V/(j*t)', unit: 'm²', decimals: 1)],
      given: const <String, double>{'V': 10, 'j': 0.2, 't': 5}, ask: const <String>['A'], formulas: const <String>['A = V / (flux × time)'],
      levels: cum(<SimConstraint>[ge('V', 20, 'Process at least 20 m³'), le('A', 40, 'Area no more than 40 m²')], <SimConstraint>[le('t', 8, 'Within one shift (8 h)')], <SimConstraint>[le('j', 0.1, 'Fine solids: flux ≤ 0.1 m³/m²·h'), le('A', 30, 'Area no more than 30 m²')]),
      models: same(const <String, double>{'V': 20, 'j': 0.1, 't': 8}),
    ),
    DesignProblem(
      key: 'extraction', title: 'Solvent extraction', brief: 'Recover a product from water with a single extraction stage.',
      inputs: const <SimInput>[SimInput('K', 'Partition coefficient', 1, 20, step: 1, initial: 5), SimInput('r', 'Solvent-to-feed ratio', 0.1, 3, step: 0.05, initial: 0.5)],
      outputs: const <SimOutput>[SimOutput('E', 'Fraction extracted', '1 - 1/(1 + K*r)', decimals: 3)],
      given: const <String, double>{'K': 4, 'r': 1}, ask: const <String>['E'], formulas: const <String>['E = 1 − 1/(1 + K S/F)'],
      levels: cum(<SimConstraint>[ge('E', 0.9, 'Recover at least 90%')], <SimConstraint>[le('r', 1, 'Solvent ratio no more than 1 (cost)')], <SimConstraint>[le('K', 12, 'Available solvent: K ≤ 12')]),
      models: same(const <String, double>{'K': 12, 'r': 0.75}),
    ),
    DesignProblem(
      key: 'ro', title: 'Reverse osmosis desalination', brief: 'Set recovery for a reverse-osmosis plant (assume full salt rejection).',
      inputs: const <SimInput>[SimInput('F', 'Feed', 10, 200, step: 10, initial: 50, unit: 'm³/h'), SimInput('R', 'Recovery', 0.3, 0.9, step: 0.05, initial: 0.5), SimInput('c', 'Feed salinity', 1, 40, step: 1, initial: 10, unit: 'g/L')],
      outputs: const <SimOutput>[SimOutput('P', 'Permeate', 'F*R', unit: 'm³/h', decimals: 1), SimOutput('K', 'Concentrate salinity', 'c/(1 - R)', unit: 'g/L', decimals: 1)],
      given: const <String, double>{'F': 100, 'R': 0.45, 'c': 35}, ask: const <String>['P', 'K'], formulas: const <String>['Permeate = F × R', 'Concentrate = c_F/(1 − R)'],
      levels: cum(<SimConstraint>[ge('P', 50, 'At least 50 m³/h of water')], <SimConstraint>[le('K', 70, 'Concentrate no more than 70 g/L (scaling)')], <SimConstraint>[ge('c', 35, 'Seawater feed (≥ 35 g/L)'), ge('P', 60, 'At least 60 m³/h')]),
      models: same(const <String, double>{'F': 120, 'R': 0.5, 'c': 35}),
    ),
    DesignProblem(
      key: 'dryer', title: 'Filter-cake dryer', brief: 'Size the drying duty for a wet filter cake.',
      inputs: const <SimInput>[SimInput('s', 'Dry solids', 100, 2000, step: 50, initial: 1000, unit: 'kg/h'), SimInput('a', 'Initial moisture (dry basis)', 0.2, 1.5, step: 0.05, initial: 1.2), SimInput('b', 'Final moisture (dry basis)', 0.02, 0.3, step: 0.01, initial: 0.1)],
      outputs: const <SimOutput>[SimOutput('W', 'Water removed', 's*(a - b)', unit: 'kg/h', decimals: 0), SimOutput('Q', 'Evaporation duty', 's*(a - b)*2260/3600', unit: 'kW', decimals: 0)],
      given: const <String, double>{'s': 400, 'a': 0.8, 'b': 0.1}, ask: const <String>['W', 'Q'], formulas: const <String>['Water = solids × (X₁ − X₂)', 'Q = water × 2260 kJ/kg'],
      levels: cum(<SimConstraint>[ge('s', 500, 'At least 500 kg/h of solids'), le('b', 0.1, 'Dry to at most 10% moisture'), le('Q', 400, 'Dryer duty no more than 400 kW')], <SimConstraint>[ge('a', 1.0, 'Wet cake at 100% moisture (dry basis)')], <SimConstraint>[le('b', 0.05, 'Customer spec: at most 5% moisture'), le('Q', 380, 'Duty no more than 380 kW')]),
      models: same(const <String, double>{'s': 500, 'a': 1.0, 'b': 0.05}),
    ),
  ], person: _kavita),
);

final LabSpec chemFlowsheetLab = designLab(
  id: 'che_lab_flowsheet', deptId: _d, majorId: _m, number: 4, title: 'Process Flow Design', environment: LabEnvironment.engineeringOffice,
  summary: 'Whole-plant decisions: overall yield, recycle loops, heat integration, capacity and utilities.',
  objectives: const <String>['Combine unit operations into a flowsheet', 'Use recycle and heat integration', 'Size capacity and utilities'],
  skills: _sk,
  reference: const <String>['Overall conversion with recycle (recovery r of unreacted): X = x/(x + (1 − x)(1 − r)).', 'Heat exchangers need at least 10 K approach temperature at each end.'],
  scenarios: fromProblems('cw', <DesignProblem>[
    DesignProblem(
      key: 'train', title: 'Overall plant yield', brief: 'Feed passes a reactor, a separation and packaging (98%). Meet the product target.',
      inputs: const <SimInput>[SimInput('f', 'Feed', 100, 1000, step: 50, initial: 500, unit: 't/yr'), SimInput('a', 'Reactor yield', 0.5, 0.99, step: 0.01, initial: 0.7), SimInput('b', 'Separation recovery', 0.5, 0.99, step: 0.01, initial: 0.8)],
      outputs: const <SimOutput>[SimOutput('P', 'Saleable product', 'f*a*b*0.98', unit: 't/yr', decimals: 1)],
      given: const <String, double>{'f': 400, 'a': 0.9, 'b': 0.9}, ask: const <String>['P'], formulas: const <String>['Product = feed × y_reactor × y_separation × 0.98'],
      levels: cum(<SimConstraint>[ge('P', 500, 'At least 500 t/yr')], <SimConstraint>[le('f', 700, 'Feed contract: no more than 700 t/yr')], <SimConstraint>[le('a', 0.9, 'Reactor yield no better than 90%'), le('b', 0.95, 'Recovery no better than 95%'), ge('P', 550, 'At least 550 t/yr')]),
      models: same(const <String, double>{'f': 700, 'a': 0.9, 'b': 0.95}),
    ),
    DesignProblem(
      key: 'recycle', title: 'Recycle loop', brief: 'An equilibrium-limited reactor converts only part of its feed; unreacted material is recovered and recycled.',
      inputs: const <SimInput>[SimInput('x', 'Single-pass conversion', 0.1, 0.9, step: 0.05, initial: 0.2), SimInput('r', 'Recovery to recycle', 0, 0.99, step: 0.01, initial: 0.5)],
      outputs: const <SimOutput>[SimOutput('X', 'Overall conversion', 'x/(x + (1 - x)*(1 - r))', decimals: 3)],
      given: const <String, double>{'x': 0.25, 'r': 0.9}, ask: const <String>['X'], formulas: const <String>['X = x/(x + (1 − x)(1 − r))'],
      levels: cum(<SimConstraint>[ge('X', 0.9, 'Overall conversion at least 90%')], <SimConstraint>[le('x', 0.3, 'Equilibrium limit: single pass ≤ 30%')], <SimConstraint>[le('r', 0.97, 'Purge needed: recovery ≤ 97%')]),
      models: same(const <String, double>{'x': 0.3, 'r': 0.97}),
    ),
    DesignProblem(
      key: 'integration', title: 'Feed–effluent heat exchanger', brief: 'Recover heat from a hot product (2 kg/s, c_p 2 kJ/kg·K, 180 °C in) into a cold feed (30 °C in, c_p 4.2).',
      inputs: const <SimInput>[SimInput('a', 'Hot outlet temperature', 40, 150, step: 0.5, initial: 150, unit: '°C'), SimInput('m', 'Cold-side flow', 0.5, 5, step: 0.1, initial: 1, unit: 'kg/s')],
      outputs: const <SimOutput>[
        SimOutput('Q', 'Heat recovered', '2*2*(180 - a)', unit: 'kW', decimals: 0),
        SimOutput('C', 'Cold outlet temperature', '30 + 2*2*(180 - a)/(m*4.2)', unit: '°C', decimals: 1),
        SimOutput('A', 'Cold-end approach', 'a - 30', unit: 'K', decimals: 1),
        SimOutput('B', 'Hot-end approach', '180 - (30 + 2*2*(180 - a)/(m*4.2))', unit: 'K', decimals: 1),
      ],
      given: const <String, double>{'a': 100, 'm': 2}, ask: const <String>['Q', 'C'], formulas: const <String>['Q = ṁ_h c_h (T_h,in − T_h,out)', 'T_c,out = T_c,in + Q/(ṁ_c c_c)'],
      levels: cum(<SimConstraint>[ge('Q', 400, 'Recover at least 400 kW'), ge('A', 10, 'Cold-end approach at least 10 K')], <SimConstraint>[ge('B', 10, 'Hot-end approach at least 10 K')], <SimConstraint>[le('C', 120, 'Cold stream no hotter than 120 °C'), ge('Q', 450, 'Recover at least 450 kW')]),
      models: same(const <String, double>{'a': 67.5, 'm': 1.2}),
    ),
    DesignProblem(
      key: 'capacity', title: 'Plant capacity', brief: 'Annual output = rate × hours × availability × 350 days.',
      inputs: const <SimInput>[SimInput('r', 'Production rate', 1, 20, step: 1, initial: 5, unit: 't/h'), SimInput('h', 'Operating hours per day', 8, 24, step: 1, initial: 16), SimInput('a', 'Availability', 0.7, 0.98, step: 0.01, initial: 0.8)],
      outputs: const <SimOutput>[SimOutput('P', 'Annual output', 'r*h*a*350', unit: 't/yr', decimals: 0)],
      given: const <String, double>{'r': 8, 'h': 20, 'a': 0.9}, ask: const <String>['P'], formulas: const <String>['P = rate × h × availability × 350'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('P', 80000, 'At least 80 000 t/yr')],
        <SimConstraint>[ge('P', 80000, 'At least 80 000 t/yr'), le('a', 0.95, 'Availability no better than 95%')],
        <SimConstraint>[ge('P', 75000, 'At least 75 000 t/yr'), le('a', 0.95, 'Availability no better than 95%'), le('r', 10, 'Existing reactor: rate ≤ 10 t/h')],
      ],
      models: const <Map<String, double>>[<String, double>{'r': 12, 'h': 24, 'a': 0.95}, <String, double>{'r': 12, 'h': 24, 'a': 0.95}, <String, double>{'r': 10, 'h': 24, 'a': 0.95}],
    ),
    DesignProblem(
      key: 'utilities', title: 'Boiler fuel demand', brief: 'Estimate gas fuel (LHV 50 MJ/kg) for the site’s steam demand.',
      inputs: const <SimInput>[SimInput('q', 'Heat demand', 100, 2000, step: 50, initial: 1500, unit: 'kW'), SimInput('k', 'Boiler efficiency', 0.7, 0.95, step: 0.01, initial: 0.75)],
      outputs: const <SimOutput>[SimOutput('F', 'Fuel use', 'q/(k*50000)*3600', unit: 'kg/h', decimals: 1)],
      given: const <String, double>{'q': 500, 'k': 0.85}, ask: const <String>['F'], formulas: const <String>['fuel = Q / (η × LHV)'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('q', 1000, 'Demand at least 1000 kW'), le('F', 90, 'Gas supply no more than 90 kg/h')],
        <SimConstraint>[ge('q', 1000, 'Demand at least 1000 kW'), le('F', 90, 'Gas supply no more than 90 kg/h'), le('k', 0.92, 'Boiler efficiency no better than 92%')],
        <SimConstraint>[ge('q', 1200, 'Demand at least 1200 kW (new line)'), le('F', 100, 'Upgraded supply: 100 kg/h'), le('k', 0.92, 'Boiler efficiency no better than 92%')],
      ],
      models: const <Map<String, double>>[<String, double>{'q': 1000, 'k': 0.92}, <String, double>{'q': 1000, 'k': 0.92}, <String, double>{'q': 1200, 'k': 0.92}],
    ),
  ], person: _kavita),
);

final LabSpec chemControlLab = designLab(
  id: 'che_lab_control', deptId: _d, majorId: _m, number: 5, title: 'Process Control', environment: LabEnvironment.engineeringOffice,
  summary: 'First-order dynamics, proportional control offset, level control, valve sizing and temperature loops.',
  objectives: const <String>['Predict dynamic response', 'Tune proportional controllers', 'Size control valves'],
  skills: _sk,
  reference: const <String>['First-order: 95% response at about 3τ.', 'P-only offset = 1/(1 + K_c K_p).', 'Valve: Q = C_v √(ΔP/SG) (US gpm, psi).'],
  scenarios: fromProblems('cc', <DesignProblem>[
    DesignProblem(
      key: 'firstorder', title: 'Temperature sensor response', brief: 'A 2-unit step is applied to a first-order process. Choose gain and time constant.',
      inputs: const <SimInput>[SimInput('K', 'Process gain', 0.5, 3, step: 0.1, initial: 1), SimInput('T', 'Time constant', 1, 20, step: 0.5, initial: 15, unit: 's')],
      outputs: const <SimOutput>[SimOutput('S', '95% response time', '3*T', unit: 's', decimals: 1), SimOutput('Y', 'Final value', '2*K', decimals: 2)],
      given: const <String, double>{'K': 1.5, 'T': 10}, ask: const <String>['S', 'Y'], formulas: const <String>['y(∞) = K × step', 't₉₅ ≈ 3τ'],
      levels: cum(<SimConstraint>[ge('Y', 3.9, 'Final value at least 3.9'), le('Y', 4.1, 'Final value no more than 4.1')], <SimConstraint>[le('S', 30, 'Settled within 30 s')], <SimConstraint>[ge('T', 8, 'Actuator limit: τ ≥ 8 s'), le('S', 25, 'Settled within 25 s')]),
      models: same(const <String, double>{'K': 2, 'T': 8}),
    ),
    DesignProblem(
      key: 'offset', title: 'Proportional controller offset', brief: 'Tune a P-only controller on a process with gain 2.',
      inputs: const <SimInput>[SimInput('c', 'Controller gain K_c', 0.1, 20, step: 0.1, initial: 1)],
      outputs: const <SimOutput>[SimOutput('E', 'Steady-state offset', '1/(1 + 2*c)', decimals: 4)],
      given: const <String, double>{'c': 2}, ask: const <String>['E'], formulas: const <String>['offset = 1/(1 + K_c K_p)'],
      levels: cum(<SimConstraint>[le('E', 0.1, 'Offset no more than 10%')], <SimConstraint>[le('c', 8, 'Stability margin: K_c ≤ 8')], <SimConstraint>[le('E', 0.06, 'Offset no more than 6%')]),
      models: same(const <String, double>{'c': 8}),
      interpret: const ChoiceQuestion('pi', 'To remove the offset entirely you would add', <String>['integral action', 'more proportional gain', 'derivative action only'], 0),
    ),
    DesignProblem(
      key: 'level', title: 'Tank level rise', brief: 'Raise a tank’s level by 2 m during start-up.',
      inputs: const <SimInput>[SimInput('A', 'Tank area', 0.5, 10, step: 0.5, initial: 5, unit: 'm²'), SimInput('q', 'Inflow', 0.1, 2, step: 0.1, initial: 0.5, unit: 'm³/min'), SimInput('o', 'Outflow', 0, 1, step: 0.1, initial: 0.4, unit: 'm³/min')],
      outputs: const <SimOutput>[SimOutput('N', 'Net inflow', 'q - o', unit: 'm³/min', decimals: 2), SimOutput('T', 'Time to rise 2 m', 'A*2/(q - o)', unit: 'min', decimals: 1)],
      given: const <String, double>{'A': 2, 'q': 1, 'o': 0.5}, ask: const <String>['T'], formulas: const <String>['dh/dt = (Q_in − Q_out)/A'],
      levels: cum(<SimConstraint>[ge('N', 0.05, 'Level must rise (net inflow > 0)'), le('T', 10, 'Within 10 minutes')], <SimConstraint>[ge('o', 0.3, 'Process draw at least 0.3 m³/min')], <SimConstraint>[ge('A', 4, 'Tank area 4 m² or more'), le('T', 8, 'Within 8 minutes')]),
      models: same(const <String, double>{'A': 4, 'q': 1.3, 'o': 0.3}),
    ),
    DesignProblem(
      key: 'valve', title: 'Control valve sizing', brief: 'Size a control valve for water (SG 1).',
      inputs: const <SimInput>[SimInput('C', 'Valve C_v', 1, 100, step: 1, initial: 10), SimInput('p', 'Pressure drop', 1, 50, step: 1, initial: 10, unit: 'psi')],
      outputs: const <SimOutput>[SimOutput('Q', 'Flow', 'C*sqrt(p)', unit: 'gpm', decimals: 1)],
      given: const <String, double>{'C': 30, 'p': 16}, ask: const <String>['Q'], formulas: const <String>['Q = C_v √(ΔP/SG)'],
      levels: cum(<SimConstraint>[ge('Q', 100, 'At least 100 gpm')], <SimConstraint>[le('p', 25, 'Pump head allows ΔP ≤ 25 psi')], <SimConstraint>[le('C', 25, 'Line size limits C_v ≤ 25'), ge('Q', 110, 'At least 110 gpm')]),
      models: same(const <String, double>{'C': 25, 'p': 20}),
    ),
    DesignProblem(
      key: 'heater', title: 'Jacketed vessel temperature', brief: 'Hold a vessel at 80 °C (±2) in a 20 °C room: T = 20 + P × R_th.',
      inputs: const <SimInput>[SimInput('P', 'Heater power', 0, 500, step: 10, initial: 100, unit: 'W'), SimInput('R', 'Thermal resistance', 0.05, 0.5, step: 0.01, initial: 0.1, unit: 'K/W')],
      outputs: const <SimOutput>[SimOutput('T', 'Steady temperature', '20 + P*R', unit: '°C', decimals: 1)],
      given: const <String, double>{'P': 200, 'R': 0.25}, ask: const <String>['T'], formulas: const <String>['T = T_amb + P R_th'],
      levels: cum(<SimConstraint>[ge('T', 78, 'At least 78 °C'), le('T', 82, 'No more than 82 °C')], <SimConstraint>[le('P', 400, 'Heater no larger than 400 W')], <SimConstraint>[le('R', 0.2, 'Insulation: R_th ≤ 0.2 K/W'), ge('P', 300, 'Use the 300 W element or larger')]),
      models: same(const <String, double>{'P': 300, 'R': 0.2}),
    ),
  ], person: _kavita),
);

final LabSpec chemSafetyLab = designLab(
  id: 'che_lab_safety', deptId: _d, majorId: _m, number: 6, title: 'Process Safety', environment: LabEnvironment.engineeringOffice,
  summary: 'Investigate process incidents: identify the hazard, confirm it with a calculation and plan the safe response.',
  objectives: const <String>['Identify process hazards', 'Analyse incidents with evidence', 'Plan safe responses'],
  skills: const <String>['en_process', 'en_safety'],
  portfolio: true,
  scenarios: fromInvestigations('cy', const <Investigation>[
    Investigation(
      key: 'runaway', title: 'Reactor temperature excursion', brief: 'An exothermic batch reactor’s temperature rose 40 K above set-point.',
      evidence: <(String, bool)>[('Cooling-water flow to the jacket dropped to zero at 14:02.', true), ('The temperature rise began at 14:03 and accelerated.', true), ('A cooling-water pump tripped on overload at 14:02.', true), ('The reactor was repainted last month.', false), ('Raw-material lot numbers match the specification.', false)],
      cause: 'Loss of cooling during an exothermic reaction (thermal runaway onset)', wrongCauses: <String>['Wrong raw material', 'Instrument calibration drift only', 'Operator overfilled the reactor'],
      fix: 'Add a cooling-failure interlock that stops feed and opens emergency cooling, with a standby pump', wrongFixes: <String>['Raise the alarm set-point', 'Run the batch faster', 'Increase the feed rate to finish sooner'],
      calc: ('Heat release 500 kW, reactor contents 5000 kg with c_p 2.5 kJ/kg·K. Temperature rise rate with no cooling, in K per minute?', 2.4, 'K/min', '500 / (5000 × 2.5) = 0.04 K/s = 2.4 K/min.'),
      steps: <String>['Stop the reactant feed', 'Start emergency cooling', 'Notify the shift supervisor', 'Investigate the pump trip', 'Fit and test the cooling-failure interlock before restart'],
      mustPrecede: <(int, int)>[(0, 3), (3, 4)],
    ),
    Investigation(
      key: 'relief', title: 'Vessel overpressure', brief: 'A storage vessel’s pressure exceeded its design pressure during a fire test scenario review.',
      evidence: <(String, bool)>[('The relief valve was sized for normal venting only, not fire.', true), ('Calculated fire-case vapour load exceeds the valve capacity.', true), ('The relief valve was last tested five years ago.', true), ('The vessel nameplate is in good condition.', false), ('The site has two fire assembly points.', false)],
      cause: 'Undersized and poorly maintained pressure relief for the fire case', wrongCauses: <String>['Vessel wall corrosion', 'Wrong level reading', 'Static electricity'],
      fix: 'Resize the relief device for the fire case and put it on a test schedule', wrongFixes: <String>['Raise the relief set pressure', 'Remove the relief valve', 'Paint the vessel'],
      calc: ('Fire-case load 9000 kg/h; valve capacity 6000 kg/h. Shortfall as a percentage of the required load?', 33.3, '%', '(9000 − 6000)/9000 = 33%.'),
      steps: <String>['Reduce the vessel inventory', 'Isolate ignition sources nearby', 'Install a correctly sized relief valve', 'Test the new valve', 'Update the relief register'],
      mustPrecede: <(int, int)>[(0, 2), (2, 3)],
    ),
    Investigation(
      key: 'dust', title: 'Flash fire in a powder room', brief: 'A flash fire occurred while emptying flour sacks into a hopper.',
      evidence: <(String, bool)>[('A visible dust cloud formed during tipping.', true), ('The hopper was not earthed.', true), ('A static spark was seen at the hopper rim.', true), ('The flour was within its use-by date.', false), ('The room has a window.', false)],
      cause: 'Dust cloud ignited by static discharge from an unearthed hopper', wrongCauses: <String>['Spontaneous combustion of flour', 'An electrical short in the lights', 'Smoking in the room'],
      fix: 'Earth and bond all equipment, use dust extraction and an ATEX-rated sack-tip station', wrongFixes: <String>['Tip faster', 'Wet the flour', 'Open the window'],
      calc: ('Dust concentration: 2 kg dispersed in a 20 m³ room. Concentration in g/m³?', 100, 'g/m³', '2000 g / 20 m³ = 100 g/m³ — above the typical lower explosive limit (~50 g/m³).'),
      steps: <String>['Stop work and evacuate the room', 'Isolate power to the area', 'Clean up deposited dust safely', 'Fit earthing and dust extraction', 'Brief operators before restart'],
      mustPrecede: <(int, int)>[(0, 2), (3, 4)],
    ),
    Investigation(
      key: 'leak', title: 'Toxic gas alarm at a flange', brief: 'Ammonia detectors alarmed near a pipe flange.',
      evidence: <(String, bool)>[('Detector reading peaked at 35 ppm near flange F-12.', true), ('The gasket at F-12 was replaced last week with a non-specified material.', true), ('Soap test shows bubbles at F-12.', true), ('Wind was from the west.', false), ('The pipe is insulated.', false)],
      cause: 'Leak from an incorrect gasket material at flange F-12', wrongCauses: <String>['Detector fault', 'Corrosion through the pipe wall', 'Overpressure of the whole system'],
      fix: 'Isolate, depressurise, fit the specified gasket, leak-test and tighten change control on parts', wrongFixes: <String>['Tighten the bolts while live', 'Silence the detector', 'Wrap the flange in tape'],
      calc: ('Workplace exposure limit 25 ppm. Peak reading as a multiple of the limit?', 1.4, '', '35/25 = 1.4 × the limit.'),
      steps: <String>['Evacuate downwind and wear breathing apparatus', 'Isolate and depressurise the line', 'Replace the gasket with the specified type', 'Leak-test at operating pressure', 'Review the parts change control'],
      mustPrecede: <(int, int)>[(0, 1), (1, 2), (2, 3)],
    ),
    Investigation(
      key: 'overfill', title: 'Storage tank overfill', brief: 'A solvent storage tank overflowed into its bund during a tanker delivery.',
      evidence: <(String, bool)>[('The level gauge stuck at 60% for the last hour of filling.', true), ('The independent high-level alarm had been disabled for maintenance.', true), ('The delivery volume exceeded the remaining free space.', true), ('The tanker driver was experienced.', false), ('The bund wall was recently repainted.', false)],
      cause: 'Stuck level gauge with the independent high-level protection disabled', wrongCauses: <String>['Tank roof failure', 'Thermal expansion of the solvent', 'A leaking bund'],
      fix: 'Restore the independent high-high level trip, repair the gauge, and require free-space checks before deliveries', wrongFixes: <String>['Ask drivers to fill more slowly', 'Raise the bund wall only', 'Remove the alarm permanently'],
      calc: ('Tank 100 m³ actually at 85% full; tanker delivers 20 m³. Overflow volume?', 5, 'm³', 'Free space 15 m³, delivery 20 m³ → 5 m³ overflow.'),
      steps: <String>['Stop the transfer', 'Contain and recover the spilled solvent', 'Repair the level gauge', 'Restore and test the high-level trip', 'Resume deliveries with a free-space check'],
      mustPrecede: <(int, int)>[(0, 1), (3, 4)],
    ),
  ], person: _kavita),
);

final List<LabSpec> chemicalLabs = <LabSpec>[chemFundamentalsLab, chemReactionLab, chemSeparationLab, chemFlowsheetLab, chemControlLab, chemSafetyLab];
