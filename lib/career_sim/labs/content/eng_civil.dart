/// Civil Engineering at Meridian Civil & Structural.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';
import 'design_kit.dart';

const LabPerson _amina = LabPerson('Amina Yusuf CEng', 'Project Engineer', 'Check it by hand, then prove the design meets every clause of the specification.');
const String _d = 'engineering';
const String _m = 'civil_engineering';

final LabSpec civilStructuresLab = designLab(
  id: 'ce_lab_structures', deptId: _d, majorId: _m, number: 1, title: 'Structural Analysis', environment: LabEnvironment.engineeringOffice,
  summary: 'Beams, cantilevers, trusses, columns and load combinations — calculate, then design members to strength and serviceability limits.',
  objectives: const <String>['Calculate moments, deflections and member forces', 'Check strength and serviceability', 'Apply design load factors'],
  skills: const <String>['en_struct'],
  reference: const <String>['Steel E = 200 GPa. Simply supported UDL: M = wL²/8. Cantilever point load: δ = PL³/(3EI).', 'Design load (EN 1990 eq. 6.10): 1.35G + 1.5Q.'],
  scenarios: fromProblems('cs', <DesignProblem>[
    DesignProblem(
      key: 'udl', title: 'Floor beam under a uniform load', brief: 'Size the span and load of a simply supported floor beam.',
      inputs: const <SimInput>[SimInput('w', 'Uniform load', 2, 30, step: 1, initial: 20, unit: 'kN/m'), SimInput('L', 'Span', 2, 10, step: 0.5, initial: 8, unit: 'm')],
      outputs: const <SimOutput>[SimOutput('M', 'Maximum moment', 'w*L^2/8', unit: 'kN·m'), SimOutput('R', 'Support reaction', 'w*L/2', unit: 'kN')],
      given: const <String, double>{'w': 10, 'L': 6}, ask: const <String>['M', 'R'], formulas: const <String>['M = wL²/8', 'R = wL/2'],
      levels: cum(<SimConstraint>[ge('w', 12, 'Carry at least 12 kN/m'), le('M', 100, 'Moment no more than 100 kN·m')], <SimConstraint>[ge('L', 6, 'Span at least 6 m')], <SimConstraint>[le('M', 60, 'Moment no more than 60 kN·m (lighter section)')]),
      models: same(const <String, double>{'w': 12, 'L': 6}),
    ),
    DesignProblem(
      key: 'cantilever', title: 'Balcony cantilever deflection', brief: 'Choose a section so a steel cantilever balcony meets deflection limits.',
      inputs: const <SimInput>[SimInput('P', 'End load', 1, 20, step: 0.5, initial: 10, unit: 'kN'), SimInput('L', 'Length', 0.5, 4, step: 0.1, initial: 3, unit: 'm'), SimInput('I', 'Second moment of area', 100, 5000, step: 100, initial: 500, unit: 'cm⁴')],
      outputs: const <SimOutput>[SimOutput('X', 'Tip deflection', 'P*1000*L^3/(3*200000000000*I*0.00000001)*1000', unit: 'mm'), SimOutput('U', 'Deflection ÷ (L/250) limit', 'P*1000*L^3/(3*200000000000*I*0.00000001)*1000/(L*1000/250)')],
      given: const <String, double>{'P': 5, 'L': 2, 'I': 1000}, ask: const <String>['X'], formulas: const <String>['δ = PL³/(3EI)', 'Serviceability limit: δ ≤ L/250'],
      levels: cum(<SimConstraint>[ge('P', 5, 'Carry 5 kN at the tip'), le('X', 10, 'Deflection no more than 10 mm')], <SimConstraint>[ge('L', 2.5, 'Balcony at least 2.5 m deep')], <SimConstraint>[le('U', 1, 'Within L/250'), le('I', 2000, 'Section no larger than 2000 cm⁴')]),
      models: same(const <String, double>{'P': 5, 'L': 2.5, 'I': 2000}),
    ),
    DesignProblem(
      key: 'truss', title: 'Roof truss member forces', brief: 'A symmetric triangular truss carries an apex load P. Choose the roof pitch.',
      inputs: const <SimInput>[SimInput('P', 'Apex load', 10, 100, step: 5, initial: 50, unit: 'kN'), SimInput('q', 'Pitch angle', 15, 75, step: 1, initial: 20, unit: '°')],
      outputs: const <SimOutput>[SimOutput('F', 'Rafter compression', 'P/(2*sin(q*pi/180))', unit: 'kN'), SimOutput('H', 'Tie tension', 'P/(2*sin(q*pi/180))*cos(q*pi/180)', unit: 'kN')],
      given: const <String, double>{'P': 40, 'q': 30}, ask: const <String>['F', 'H'], formulas: const <String>['Joint equilibrium at the apex: F = P/(2 sin θ)', 'Tie: H = F cos θ'],
      levels: cum(<SimConstraint>[ge('P', 40, 'Apex load at least 40 kN'), le('F', 50, 'Rafter force no more than 50 kN')], <SimConstraint>[le('q', 45, 'Pitch no more than 45° (planning height)')], <SimConstraint>[le('H', 35, 'Tie force no more than 35 kN')]),
      models: same(const <String, double>{'P': 40, 'q': 30}),
      interpret: const ChoiceQuestion('flat', 'As the roof gets flatter, the rafter force', <String>['increases', 'decreases', 'stays the same'], 0),
    ),
    DesignProblem(
      key: 'column', title: 'Steel column: crushing and buckling', brief: 'Check a pinned steel column for axial stress and Euler buckling.',
      inputs: const <SimInput>[
        SimInput('P', 'Axial load', 100, 2000, step: 50, initial: 1500, unit: 'kN'),
        SimInput('A', 'Area', 1000, 10000, step: 100, initial: 2000, unit: 'mm²'),
        SimInput('L', 'Length', 2, 8, step: 0.5, initial: 6, unit: 'm'),
        SimInput('I', 'Second moment of area', 500, 20000, step: 100, initial: 2000, unit: 'cm⁴'),
      ],
      outputs: const <SimOutput>[
        SimOutput('S', 'Axial stress', 'P*1000/A', unit: 'MPa', decimals: 1),
        SimOutput('C', 'Euler buckling load', 'pi^2*200000*I*10000/(L*1000)^2/1000', unit: 'kN', decimals: 0),
        SimOutput('F', 'Buckling factor of safety', 'pi^2*200000*I*10000/(L*1000)^2/1000/P'),
      ],
      given: const <String, double>{'P': 500, 'A': 4000, 'L': 4, 'I': 5000}, ask: const <String>['S', 'C'], formulas: const <String>['σ = P/A', 'P_cr = π²EI/L² (pinned ends)'],
      levels: cum(<SimConstraint>[ge('P', 800, 'Carry at least 800 kN'), le('S', 180, 'Stress no more than 180 MPa')], <SimConstraint>[ge('F', 2, 'Buckling safety factor at least 2')], <SimConstraint>[ge('L', 6, 'Column at least 6 m tall'), le('A', 6000, 'Area no more than 6000 mm²')]),
      models: same(const <String, double>{'P': 800, 'A': 5000, 'L': 6, 'I': 3000}),
    ),
    DesignProblem(
      key: 'combo', title: 'Slab design load', brief: 'Check a floor slab using the EN 1990 load combination against its 15 kN/m² capacity.',
      inputs: const <SimInput>[SimInput('G', 'Permanent load', 1, 10, step: 0.5, initial: 6, unit: 'kN/m²'), SimInput('Q', 'Imposed load', 1, 10, step: 0.5, initial: 5, unit: 'kN/m²')],
      outputs: const <SimOutput>[SimOutput('D', 'Design load', '1.35*G + 1.5*Q', unit: 'kN/m²'), SimOutput('U', 'Utilisation', '(1.35*G + 1.5*Q)/15')],
      given: const <String, double>{'G': 4, 'Q': 3}, ask: const <String>['D'], formulas: const <String>['Design load = 1.35G + 1.5Q'],
      levels: cum(<SimConstraint>[ge('Q', 3, 'Office use: Q ≥ 3 kN/m²'), le('U', 1, 'Utilisation no more than 100%')], <SimConstraint>[ge('G', 4, 'Slab self-weight and finishes: G ≥ 4 kN/m²')], <SimConstraint>[ge('Q', 4, 'Upgraded to Q ≥ 4 kN/m²'), le('U', 0.95, 'Utilisation no more than 95%')]),
      models: same(const <String, double>{'G': 4, 'Q': 4}),
    ),
  ], person: _amina),
);

final LabSpec civilMaterialsLab = designLab(
  id: 'ce_lab_materials', deptId: _d, majorId: _m, number: 2, title: 'Concrete and Materials Testing', environment: LabEnvironment.engineeringOffice,
  summary: 'Mix design, tensile testing, thermal movement, safety factors and statistical acceptance of cube results.',
  objectives: const <String>['Interpret material test data', 'Design concrete mixes to strength and durability', 'Apply statistical acceptance'],
  skills: const <String>['en_struct'],
  reference: const <String>['Lab calibration for this cement: 28-day strength f = 100 / 6^(w/c) MPa.', 'Target mean strength = f_ck + 1.64σ.', 'Steel α = 12 × 10⁻⁶ /K.'],
  scenarios: fromProblems('cm', <DesignProblem>[
    DesignProblem(
      key: 'mix', title: 'Concrete mix design', brief: 'Design a mix for a C30/37 slab (cube strength ≥ 37 MPa).',
      inputs: const <SimInput>[SimInput('w', 'Water–cement ratio', 0.3, 0.8, step: 0.01, initial: 0.7), SimInput('c', 'Cement content', 250, 500, step: 10, initial: 300, unit: 'kg/m³')],
      outputs: const <SimOutput>[SimOutput('f', '28-day strength', '100/6^w', unit: 'MPa'), SimOutput('W', 'Water content', 'w*c', unit: 'kg/m³', decimals: 0), SimOutput('K', 'Cement cost', '0.12*c', unit: '£/m³')],
      given: const <String, double>{'w': 0.5, 'c': 350}, ask: const <String>['f', 'W'], formulas: const <String>['f = 100/6^(w/c)', 'water = (w/c) × cement'],
      levels: cum(<SimConstraint>[ge('f', 37, 'Strength at least 37 MPa')], <SimConstraint>[le('W', 175, 'Water no more than 175 kg/m³ (shrinkage)')], <SimConstraint>[le('K', 45, 'Cement cost no more than £45/m³'), le('w', 0.55, 'w/c no more than 0.55 (exposure class)')]),
      models: same(const <String, double>{'w': 0.55, 'c': 310}),
    ),
    DesignProblem(
      key: 'tensile', title: 'Tensile test on a 12 mm bar', brief: 'Choose a valid load–extension reading from the elastic region (gauge length 200 mm, area 113.1 mm²).',
      inputs: const <SimInput>[SimInput('F', 'Load', 10, 150, step: 1, initial: 40, unit: 'kN'), SimInput('x', 'Extension', 0.01, 0.5, step: 0.01, initial: 0.3, unit: 'mm')],
      outputs: const <SimOutput>[SimOutput('S', 'Stress', 'F*1000/113.1', unit: 'MPa', decimals: 1), SimOutput('E', 'Apparent modulus', 'F*1000/113.1/(x/200)/1000', unit: 'GPa', decimals: 1)],
      given: const <String, double>{'F': 20, 'x': 0.18}, ask: const <String>['S', 'E'], formulas: const <String>['σ = F/A, ε = ΔL/L₀, E = σ/ε'],
      levels: cum(<SimConstraint>[ge('E', 190, 'Modulus consistent with steel (≥ 190 GPa)'), le('E', 210, 'Modulus consistent with steel (≤ 210 GPa)')], <SimConstraint>[le('S', 250, 'Stress within the elastic range (≤ 250 MPa)')], <SimConstraint>[ge('S', 150, 'Stress large enough to measure accurately (≥ 150 MPa)')]),
      models: same(const <String, double>{'F': 20, 'x': 0.18}),
    ),
    DesignProblem(
      key: 'expansion', title: 'Bridge deck expansion joint', brief: 'Size an expansion joint for a steel bridge deck.',
      inputs: const <SimInput>[SimInput('L', 'Deck length', 10, 200, step: 5, initial: 150, unit: 'm'), SimInput('t', 'Temperature range', 10, 60, step: 5, initial: 50, unit: 'K'), SimInput('g', 'Joint gap', 10, 100, step: 5, initial: 40, unit: 'mm')],
      outputs: const <SimOutput>[SimOutput('X', 'Thermal movement', '0.000012*L*t*1000', unit: 'mm', decimals: 1), SimOutput('U', 'Movement ÷ gap', '0.000012*L*t*1000/g')],
      given: const <String, double>{'L': 50, 't': 40, 'g': 30}, ask: const <String>['X'], formulas: const <String>['ΔL = α L ΔT'],
      levels: cum(<SimConstraint>[ge('L', 100, 'Deck at least 100 m'), ge('t', 40, 'Design range at least 40 K'), le('U', 1, 'Gap accommodates the movement')], <SimConstraint>[le('g', 80, 'Joint product no larger than 80 mm')], <SimConstraint>[ge('t', 50, 'Design range at least 50 K (exposed site)'), le('U', 0.8, 'Use no more than 80% of the gap')]),
      models: same(const <String, double>{'L': 100, 't': 50, 'g': 75}),
    ),
    DesignProblem(
      key: 'safety', title: 'Steel grade and working stress', brief: 'Choose a steel grade and working stress with an adequate factor of safety.',
      inputs: const <SimInput>[SimInput('f', 'Yield strength', 235, 460, step: 5, initial: 235, unit: 'MPa'), SimInput('s', 'Working stress', 50, 300, step: 5, initial: 250, unit: 'MPa')],
      outputs: const <SimOutput>[SimOutput('F', 'Factor of safety', 'f/s')],
      given: const <String, double>{'f': 275, 's': 180}, ask: const <String>['F'], formulas: const <String>['FoS = f_y / σ_working'],
      levels: cum(<SimConstraint>[ge('F', 1.5, 'Factor of safety at least 1.5')], <SimConstraint>[ge('s', 150, 'Working stress at least 150 MPa (economy)')], <SimConstraint>[le('f', 355, 'Grade S355 or lower (stocked)'), ge('F', 1.6, 'Factor of safety at least 1.6')]),
      models: same(const <String, double>{'f': 355, 's': 200}),
    ),
    DesignProblem(
      key: 'acceptance', title: 'Accepting a batch of cube results', brief: 'Check whether a supplier’s mean cube strength meets the target mean for the specified class.',
      inputs: const <SimInput>[SimInput('k', 'Characteristic strength f_ck', 20, 50, step: 5, initial: 40, unit: 'MPa'), SimInput('s', 'Standard deviation', 2, 8, step: 0.5, initial: 6, unit: 'MPa'), SimInput('m', 'Batch mean', 25, 70, step: 0.5, initial: 45, unit: 'MPa')],
      outputs: const <SimOutput>[SimOutput('T', 'Target mean', 'k + 1.64*s', unit: 'MPa'), SimOutput('D', 'Margin over target', 'm - k - 1.64*s', unit: 'MPa')],
      given: const <String, double>{'k': 30, 's': 5, 'm': 40}, ask: const <String>['T'], formulas: const <String>['Target mean = f_ck + 1.64σ'],
      levels: cum(<SimConstraint>[ge('k', 30, 'Class at least 30 MPa'), ge('D', 0, 'Mean meets the target')], <SimConstraint>[le('s', 5, 'Process control: σ ≤ 5 MPa')], <SimConstraint>[ge('k', 35, 'Class at least 35 MPa'), le('m', 46, 'Mean no more than 46 MPa (cement economy)')]),
      models: same(const <String, double>{'k': 35, 's': 4, 'm': 45}),
    ),
  ], person: _amina),
);

final LabSpec civilGeotechLab = designLab(
  id: 'ce_lab_geotech', deptId: _d, majorId: _m, number: 3, title: 'Geotechnical Engineering', environment: LabEnvironment.engineeringOffice,
  summary: 'Footing pressures, effective stress, settlement, slope stability and retaining wall thrust.',
  objectives: const <String>['Apply effective stress', 'Check bearing, settlement and stability', 'Calculate earth pressures'],
  skills: const <String>['en_struct', 'en_safety'],
  reference: const <String>['γ_w = 9.81 kN/m³. Infinite dry slope: FS = tan φ / tan β. Rankine: K_a = (1 − sin φ)/(1 + sin φ), P_a = ½K_aγH².'],
  scenarios: fromProblems('cg', <DesignProblem>[
    DesignProblem(
      key: 'footing', title: 'Pad footing size', brief: 'Size a square pad footing so bearing pressure stays within 200 kPa.',
      inputs: const <SimInput>[SimInput('P', 'Column load', 200, 2000, step: 50, initial: 1200, unit: 'kN'), SimInput('B', 'Footing width', 1, 4, step: 0.1, initial: 1.5, unit: 'm')],
      outputs: const <SimOutput>[SimOutput('q', 'Bearing pressure', 'P/B^2', unit: 'kPa', decimals: 0)],
      given: const <String, double>{'P': 800, 'B': 2}, ask: const <String>['q'], formulas: const <String>['q = P / B²'],
      levels: cum(<SimConstraint>[ge('P', 1000, 'Column load at least 1000 kN'), le('q', 200, 'Pressure no more than 200 kPa')], <SimConstraint>[le('B', 2.5, 'Width no more than 2.5 m (boundary)')], <SimConstraint>[ge('P', 1100, 'Column load at least 1100 kN'), le('q', 180, 'Pressure no more than 180 kPa')]),
      models: same(const <String, double>{'P': 1100, 'B': 2.5}),
    ),
    DesignProblem(
      key: 'effective', title: 'Basement formation level', brief: 'Choose an excavation depth and dewatering level that give enough effective stress on the bearing stratum.',
      inputs: const <SimInput>[SimInput('h', 'Depth', 1, 20, step: 0.5, initial: 10, unit: 'm'), SimInput('w', 'Water table depth', 0, 20, step: 0.5, initial: 2, unit: 'm'), SimInput('g', 'Soil unit weight', 16, 22, step: 0.5, initial: 18, unit: 'kN/m³')],
      outputs: const <SimOutput>[SimOutput('V', 'Total stress', 'g*h', unit: 'kPa'), SimOutput('U', 'Pore pressure', '9.81*(h - w)', unit: 'kPa'), SimOutput('E', 'Effective stress', 'g*h - 9.81*(h - w)', unit: 'kPa'), SimOutput('Z', 'Depth below water table', 'h - w', unit: 'm')],
      given: const <String, double>{'h': 10, 'w': 2, 'g': 18}, ask: const <String>['V', 'E'], formulas: const <String>['σ = γh', 'u = γ_w (h − h_w)', 'σ′ = σ − u'],
      levels: cum(<SimConstraint>[le('h', 8, 'Excavation no deeper than 8 m'), ge('Z', 0, 'Water table above formation level'), ge('E', 100, 'Effective stress at least 100 kPa')], <SimConstraint>[ge('w', 3, 'Dewater to at least 3 m below ground')], <SimConstraint>[ge('g', 19, 'Use the measured unit weight (≥ 19 kN/m³)'), ge('E', 110, 'Effective stress at least 110 kPa')]),
      models: same(const <String, double>{'h': 8, 'w': 6, 'g': 19}),
    ),
    DesignProblem(
      key: 'settlement', title: 'Clay layer settlement', brief: 'Estimate consolidation settlement and choose a foundation pressure.',
      inputs: const <SimInput>[SimInput('H', 'Clay thickness', 1, 10, step: 0.5, initial: 6, unit: 'm'), SimInput('m', 'Coefficient of compressibility m_v', 0.05, 1, step: 0.05, initial: 0.5, unit: 'm²/MN'), SimInput('d', 'Stress increase', 20, 200, step: 5, initial: 150, unit: 'kPa')],
      outputs: const <SimOutput>[SimOutput('s', 'Settlement', 'H*m*d', unit: 'mm', decimals: 0)],
      given: const <String, double>{'H': 4, 'm': 0.3, 'd': 100}, ask: const <String>['s'], formulas: const <String>['s = m_v Δσ H'],
      levels: cum(<SimConstraint>[ge('H', 4, 'Site investigation: 4 m of clay'), ge('m', 0.2, 'Measured m_v ≥ 0.2 m²/MN'), le('s', 150, 'Settlement no more than 150 mm')], <SimConstraint>[ge('d', 100, 'Stress increase at least 100 kPa (building load)')], <SimConstraint>[le('s', 100, 'Settlement no more than 100 mm (services)')]),
      models: same(const <String, double>{'H': 4, 'm': 0.2, 'd': 100}),
    ),
    DesignProblem(
      key: 'slope', title: 'Cutting slope angle', brief: 'Choose a stable slope angle for a cutting in dry granular soil.',
      inputs: const <SimInput>[SimInput('f', 'Friction angle φ', 20, 40, step: 1, initial: 30, unit: '°'), SimInput('b', 'Slope angle β', 10, 45, step: 1, initial: 40, unit: '°')],
      outputs: const <SimOutput>[SimOutput('F', 'Factor of safety', 'tan(f*pi/180)/tan(b*pi/180)')],
      given: const <String, double>{'f': 30, 'b': 25}, ask: const <String>['F'], formulas: const <String>['FS = tan φ / tan β'],
      levels: cum(<SimConstraint>[ge('F', 1.3, 'Factor of safety at least 1.3')], <SimConstraint>[ge('b', 20, 'Slope at least 20° (land take)')], <SimConstraint>[le('f', 32, 'Measured φ no more than 32°'), ge('F', 1.5, 'Factor of safety at least 1.5')]),
      models: same(const <String, double>{'f': 32, 'b': 22}),
    ),
    DesignProblem(
      key: 'wall', title: 'Retaining wall thrust', brief: 'Choose backfill and wall height so the active thrust stays within the wall’s capacity.',
      inputs: const <SimInput>[SimInput('f', 'Backfill φ', 20, 40, step: 1, initial: 25, unit: '°'), SimInput('H', 'Retained height', 1, 6, step: 0.5, initial: 5, unit: 'm'), SimInput('g', 'Backfill unit weight', 16, 22, step: 0.5, initial: 20, unit: 'kN/m³')],
      outputs: const <SimOutput>[SimOutput('K', 'Active coefficient', '(1 - sin(f*pi/180))/(1 + sin(f*pi/180))', decimals: 3), SimOutput('P', 'Active thrust', '0.5*(1 - sin(f*pi/180))/(1 + sin(f*pi/180))*g*H^2', unit: 'kN/m')],
      given: const <String, double>{'f': 30, 'H': 4, 'g': 18}, ask: const <String>['K', 'P'], formulas: const <String>['K_a = (1 − sin φ)/(1 + sin φ)', 'P_a = ½ K_a γ H²'],
      levels: cum(<SimConstraint>[ge('H', 3, 'Retain at least 3 m'), le('P', 60, 'Thrust no more than 60 kN/m')], <SimConstraint>[ge('g', 18, 'Backfill unit weight at least 18 kN/m³')], <SimConstraint>[le('f', 32, 'Granular fill φ no more than 32°'), ge('H', 3.5, 'Retain at least 3.5 m'), le('P', 55, 'Thrust no more than 55 kN/m')]),
      models: same(const <String, double>{'f': 32, 'H': 3.5, 'g': 18}),
    ),
  ], person: _amina),
);

final LabSpec civilSurveyingLab = designLab(
  id: 'ce_lab_surveying', deptId: _d, majorId: _m, number: 4, title: 'Surveying', environment: LabEnvironment.engineeringOffice,
  summary: 'Levelling, setting out by bearing and distance, plot areas, gradients and tape corrections.',
  objectives: const <String>['Reduce levels', 'Set out points from bearings and distances', 'Apply corrections and gradients'],
  skills: const <String>['en_struct'],
  reference: const <String>['RL = RL_benchmark + backsight − foresight.', 'ΔE = d sin θ, ΔN = d cos θ (whole-circle bearing).', 'Tape temperature correction = α L (T − 20 °C), α = 11.5 × 10⁻⁶ /K.'],
  scenarios: fromProblems('cv', <DesignProblem>[
    DesignProblem(
      key: 'level', title: 'Setting out a formation level', brief: 'From a benchmark at 100.000 m, find the foresight reading that puts a peg at the design level.',
      inputs: const <SimInput>[SimInput('a', 'Backsight on benchmark', 0.5, 3, step: 0.005, initial: 1.5, unit: 'm'), SimInput('f', 'Foresight on peg', 0.5, 3, step: 0.005, initial: 2.5, unit: 'm')],
      outputs: const <SimOutput>[SimOutput('R', 'Reduced level of peg', '100 + a - f', unit: 'm', decimals: 3)],
      given: const <String, double>{'a': 1.5, 'f': 2.5}, ask: const <String>['R'], formulas: const <String>['RL = 100.000 + BS − FS'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('a', 1.4199, 'Backsight read as 1.420 m'), le('a', 1.4201, 'Backsight read as 1.420 m'), ge('R', 100.745, 'Peg at 100.750 m (±5 mm)'), le('R', 100.755, 'Peg at 100.750 m (±5 mm)')],
        <SimConstraint>[ge('a', 1.4199, 'Backsight read as 1.420 m'), le('a', 1.4201, 'Backsight read as 1.420 m'), ge('R', 99.875, 'Peg at 99.880 m (±5 mm)'), le('R', 99.885, 'Peg at 99.880 m (±5 mm)')],
        <SimConstraint>[ge('a', 1.7849, 'Backsight read as 1.785 m'), le('a', 1.7851, 'Backsight read as 1.785 m'), ge('R', 100.112, 'Peg at 100.115 m (±3 mm)'), le('R', 100.118, 'Peg at 100.115 m (±3 mm)')],
      ],
      models: const <Map<String, double>>[<String, double>{'a': 1.42, 'f': 0.67}, <String, double>{'a': 1.42, 'f': 1.54}, <String, double>{'a': 1.785, 'f': 1.67}],
    ),
    DesignProblem(
      key: 'setout', title: 'Setting out by bearing and distance', brief: 'Set out a point from a station using a bearing and a distance.',
      inputs: const <SimInput>[SimInput('d', 'Distance', 10, 200, step: 0.5, initial: 120, unit: 'm'), SimInput('q', 'Whole-circle bearing', 0, 359, step: 1, initial: 90, unit: '°')],
      outputs: const <SimOutput>[SimOutput('X', 'ΔEasting', 'd*sin(q*pi/180)', unit: 'm'), SimOutput('Y', 'ΔNorthing', 'd*cos(q*pi/180)', unit: 'm')],
      given: const <String, double>{'d': 50, 'q': 60}, ask: const <String>['X', 'Y'], formulas: const <String>['ΔE = d sin θ', 'ΔN = d cos θ'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('X', 49.95, 'ΔE = +50.00 m (±50 mm)'), le('X', 50.05, 'ΔE = +50.00 m'), ge('Y', 86.55, 'ΔN = +86.60 m (±50 mm)'), le('Y', 86.65, 'ΔN = +86.60 m')],
        <SimConstraint>[ge('X', -70.76, 'ΔE = −70.71 m (±50 mm)'), le('X', -70.66, 'ΔE = −70.71 m'), ge('Y', 70.66, 'ΔN = +70.71 m (±50 mm)'), le('Y', 70.76, 'ΔN = +70.71 m')],
        <SimConstraint>[ge('X', -40.05, 'ΔE = −40.00 m (±50 mm)'), le('X', -39.95, 'ΔE = −40.00 m'), ge('Y', -69.33, 'ΔN = −69.28 m (±50 mm)'), le('Y', -69.23, 'ΔN = −69.28 m')],
      ],
      models: const <Map<String, double>>[<String, double>{'d': 100, 'q': 30}, <String, double>{'d': 100, 'q': 315}, <String, double>{'d': 80, 'q': 210}],
    ),
    DesignProblem(
      key: 'area', title: 'Plot area for a planning application', brief: 'A trapezoidal plot has corners (0,0), (40,0), (x,30) and (0,30) in metres. Fix the third corner.',
      inputs: const <SimInput>[SimInput('x', 'Easting of corner 3', 0, 80, step: 1, initial: 10, unit: 'm')],
      outputs: const <SimOutput>[SimOutput('A', 'Plot area', '30*(40 + x)/2', unit: 'm²', decimals: 0)],
      given: const <String, double>{'x': 20}, ask: const <String>['A'], formulas: const <String>['Trapezium: A = h(a + b)/2 (or the shoelace formula)'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('A', 1049, 'Area 1050 m²'), le('A', 1051, 'Area 1050 m²')],
        <SimConstraint>[ge('A', 1499, 'Area 1500 m²'), le('A', 1501, 'Area 1500 m²')],
        <SimConstraint>[ge('A', 1199, 'Area 1200 m²'), le('A', 1201, 'Area 1200 m²'), le('x', 45, 'Corner within the 45 m easement')],
      ],
      models: const <Map<String, double>>[<String, double>{'x': 30}, <String, double>{'x': 60}, <String, double>{'x': 40}],
    ),
    DesignProblem(
      key: 'ramp', title: 'Accessible ramp gradient', brief: 'Design an access ramp to a building entrance.',
      inputs: const <SimInput>[SimInput('h', 'Rise', 0.5, 2, step: 0.05, initial: 1.5, unit: 'm'), SimInput('L', 'Ramp length', 5, 40, step: 0.5, initial: 10, unit: 'm')],
      outputs: const <SimOutput>[SimOutput('G', 'Gradient', 'h/L*100', unit: '%')],
      given: const <String, double>{'h': 0.8, 'L': 12}, ask: const <String>['G'], formulas: const <String>['gradient = rise / run × 100%', '1:12 = 8.33%'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('h', 1.2, 'Rise of 1.2 m'), le('G', 8.33, 'No steeper than 1:12')],
        <SimConstraint>[ge('h', 1.2, 'Rise of 1.2 m'), le('G', 8.33, 'No steeper than 1:12'), le('L', 20, 'Ramp no longer than 20 m')],
        <SimConstraint>[ge('h', 1, 'Rise of 1.0 m'), le('G', 5, 'Preferred gradient: no steeper than 1:20'), le('L', 20, 'Ramp no longer than 20 m')],
      ],
      models: const <Map<String, double>>[<String, double>{'h': 1.2, 'L': 15}, <String, double>{'h': 1.2, 'L': 15}, <String, double>{'h': 1, 'L': 20}],
    ),
    DesignProblem(
      key: 'tape', title: 'Tape temperature correction', brief: 'Decide when a steel tape can be used without correction.',
      inputs: const <SimInput>[SimInput('L', 'Measured length', 10, 100, step: 5, initial: 50, unit: 'm'), SimInput('t', 'Temperature', -10, 40, step: 0.5, initial: 32, unit: '°C')],
      outputs: const <SimOutput>[SimOutput('C', 'Correction', '0.0000115*L*(t - 20)*1000', unit: 'mm', decimals: 2)],
      given: const <String, double>{'L': 30, 't': 30}, ask: const <String>['C'], formulas: const <String>['C = α L (T − 20)'],
      levels: <List<SimConstraint>>[
        <SimConstraint>[ge('L', 50, 'Length at least 50 m'), le('C', 2, 'Correction within +2 mm'), ge('C', -2, 'Correction within −2 mm')],
        <SimConstraint>[ge('L', 80, 'Length at least 80 m'), le('C', 2, 'Correction within +2 mm'), ge('C', -2, 'Correction within −2 mm')],
        <SimConstraint>[ge('L', 100, 'Length 100 m'), le('C', 1, 'Correction within +1 mm'), ge('C', -1, 'Correction within −1 mm')],
      ],
      models: const <Map<String, double>>[<String, double>{'L': 50, 't': 22}, <String, double>{'L': 80, 't': 21}, <String, double>{'L': 100, 't': 20.5}],
    ),
  ], person: _amina),
);

final LabSpec civilTransportLab = designLab(
  id: 'ce_lab_transport', deptId: _d, majorId: _m, number: 5, title: 'Transportation and Infrastructure', environment: LabEnvironment.engineeringOffice,
  summary: 'Stopping sight distance, curve radius, drainage, traffic flow and open-channel capacity.',
  objectives: const <String>['Apply highway geometry standards', 'Size drainage', 'Analyse traffic flow'],
  skills: const <String>['en_struct', 'en_safety'],
  reference: const <String>['SSD = vt + v²/(2gf), v in m/s.', 'Minimum radius R = V²/(127(e + f)), V in km/h.', 'Rational method Q = CiA/360 (i mm/h, A ha).', 'Manning: Q = (1/n) A R^(2/3) S^(1/2), n = 0.015 (concrete).'],
  scenarios: fromProblems('ct', <DesignProblem>[
    DesignProblem(
      key: 'ssd', title: 'Stopping sight distance', brief: 'Set a design speed for a road where only 120 m of forward visibility is available.',
      inputs: const <SimInput>[SimInput('V', 'Design speed', 30, 120, step: 5, initial: 100, unit: 'km/h'), SimInput('t', 'Reaction time', 1, 3, step: 0.1, initial: 2.5, unit: 's'), SimInput('f', 'Friction coefficient', 0.25, 0.45, step: 0.01, initial: 0.35)],
      outputs: const <SimOutput>[SimOutput('S', 'Stopping sight distance', 'V/3.6*t + (V/3.6)^2/(2*9.81*f)', unit: 'm', decimals: 1)],
      given: const <String, double>{'V': 80, 't': 2.5, 'f': 0.35}, ask: const <String>['S'], formulas: const <String>['SSD = vt + v²/(2gf)'],
      levels: cum(<SimConstraint>[ge('V', 60, 'Design speed at least 60 km/h'), le('S', 120, 'Within the 120 m sight line')], <SimConstraint>[ge('t', 2, 'Reaction time at least 2 s (design standard)')], <SimConstraint>[ge('V', 70, 'Design speed at least 70 km/h'), le('f', 0.35, 'Wet-road friction (f ≤ 0.35)')]),
      models: same(const <String, double>{'V': 70, 't': 2, 'f': 0.35}),
    ),
    DesignProblem(
      key: 'curve', title: 'Horizontal curve design', brief: 'The site only allows a 250 m radius curve. Choose speed and superelevation.',
      inputs: const <SimInput>[SimInput('V', 'Design speed', 40, 120, step: 5, initial: 100, unit: 'km/h'), SimInput('u', 'Superelevation', 0, 0.1, step: 0.01, initial: 0.04), SimInput('f', 'Side friction', 0.1, 0.2, step: 0.01, initial: 0.12)],
      outputs: const <SimOutput>[SimOutput('R', 'Minimum radius', 'V^2/(127*(u + f))', unit: 'm', decimals: 0)],
      given: const <String, double>{'V': 90, 'u': 0.06, 'f': 0.15}, ask: const <String>['R'], formulas: const <String>['R = V²/(127(e + f))'],
      levels: cum(<SimConstraint>[ge('V', 70, 'Design speed at least 70 km/h'), le('R', 250, 'Radius fits the site (≤ 250 m)')], <SimConstraint>[le('u', 0.07, 'Superelevation no more than 7%')], <SimConstraint>[ge('V', 80, 'Design speed at least 80 km/h'), le('f', 0.14, 'Side friction no more than 0.14')]),
      models: same(const <String, double>{'V': 80, 'u': 0.07, 'f': 0.14}),
    ),
    DesignProblem(
      key: 'drainage', title: 'Car park drainage', brief: 'Check a car park’s storm runoff against a 0.5 m³/s outfall pipe.',
      inputs: const <SimInput>[SimInput('C', 'Runoff coefficient', 0.3, 0.95, step: 0.05, initial: 0.9), SimInput('i', 'Rainfall intensity', 20, 150, step: 5, initial: 100, unit: 'mm/h'), SimInput('A', 'Catchment area', 0.5, 10, step: 0.5, initial: 5, unit: 'ha')],
      outputs: const <SimOutput>[SimOutput('Q', 'Peak runoff', 'C*i*A/360', unit: 'm³/s', decimals: 3)],
      given: const <String, double>{'C': 0.7, 'i': 50, 'A': 2}, ask: const <String>['Q'], formulas: const <String>['Q = CiA/360'],
      levels: cum(<SimConstraint>[ge('i', 60, 'Design storm at least 60 mm/h'), ge('A', 3, 'Catchment at least 3 ha'), le('Q', 0.5, 'Within pipe capacity (0.5 m³/s)')], <SimConstraint>[ge('C', 0.6, 'Paved surface: C ≥ 0.6')], <SimConstraint>[ge('i', 80, 'Climate allowance: at least 80 mm/h'), le('Q', 0.45, 'Leave 10% capacity spare')]),
      models: same(const <String, double>{'C': 0.65, 'i': 80, 'A': 3}),
    ),
    DesignProblem(
      key: 'traffic', title: 'Motorway traffic flow', brief: 'Use the Greenshields model (jam density 150 veh/km) to set an operating density.',
      inputs: const <SimInput>[SimInput('k', 'Density', 5, 150, step: 5, initial: 120, unit: 'veh/km'), SimInput('f', 'Free-flow speed', 60, 120, step: 5, initial: 100, unit: 'km/h')],
      outputs: const <SimOutput>[SimOutput('v', 'Speed', 'f*(1 - k/150)', unit: 'km/h', decimals: 1), SimOutput('q', 'Flow', 'k*f*(1 - k/150)', unit: 'veh/h', decimals: 0)],
      given: const <String, double>{'k': 40, 'f': 90}, ask: const <String>['v', 'q'], formulas: const <String>['v = v_f (1 − k/k_j)', 'q = k v'],
      levels: cum(<SimConstraint>[ge('q', 3000, 'Flow at least 3000 veh/h')], <SimConstraint>[ge('v', 50, 'Speed at least 50 km/h (level of service)')], <SimConstraint>[le('f', 100, 'Free-flow speed no more than 100 km/h (limit)'), ge('q', 3300, 'Flow at least 3300 veh/h')]),
      models: same(const <String, double>{'k': 60, 'f': 100}),
      interpret: const ChoiceQuestion('max', 'Flow is greatest when density is', <String>['half the jam density', 'equal to the jam density', 'zero'], 0),
    ),
    DesignProblem(
      key: 'channel', title: 'Rectangular storm channel', brief: 'Size a concrete channel to carry 2 m³/s.',
      inputs: const <SimInput>[SimInput('b', 'Width', 0.5, 4, step: 0.1, initial: 1, unit: 'm'), SimInput('y', 'Flow depth', 0.2, 2, step: 0.1, initial: 0.5, unit: 'm'), SimInput('S', 'Bed slope', 0.001, 0.02, step: 0.001, initial: 0.002)],
      outputs: const <SimOutput>[SimOutput('Q', 'Capacity', '1/0.015*b*y*(b*y/(b + 2*y))^(2/3)*S^0.5', unit: 'm³/s', decimals: 2)],
      given: const <String, double>{'b': 1.5, 'y': 0.8, 'S': 0.004}, ask: const <String>['Q'], formulas: const <String>['A = by, R = by/(b + 2y)', 'Q = (1/n) A R^(2/3) S^(1/2)'],
      levels: cum(<SimConstraint>[ge('Q', 2, 'Carry at least 2 m³/s')], <SimConstraint>[le('y', 1, 'Depth no more than 1 m (freeboard)')], <SimConstraint>[le('b', 2, 'Width no more than 2 m'), le('S', 0.005, 'Slope no more than 0.5% (terrain)')]),
      models: same(const <String, double>{'b': 2, 'y': 1, 'S': 0.005}),
    ),
  ], person: _amina),
);

final LabSpec civilConstructionLab = designLab(
  id: 'ce_lab_construction', deptId: _d, majorId: _m, number: 6, title: 'Construction Project Management', environment: LabEnvironment.engineeringOffice,
  summary: 'Plan time, cost, labour, materials and lifts on a live construction project.',
  objectives: const <String>['Trade off time and cost', 'Plan labour, deliveries and materials', 'Plan safe crane lifts'],
  skills: const <String>['en_ops', 'en_safety'],
  portfolio: true,
  reference: const <String>['Crane: capacity at radius = load moment ÷ radius; plan lifts to no more than 75% of capacity.'],
  scenarios: fromProblems('cp', <DesignProblem>[
    DesignProblem(
      key: 'crash', title: 'Crashing the programme', brief: 'A 60-day job must finish sooner. Crash activity A (£2k/day) and B (£3.5k/day); indirect site costs are £3k/day.',
      inputs: const <SimInput>[SimInput('x', 'Days saved on A', 0, 10, step: 1, initial: 0), SimInput('y', 'Days saved on B', 0, 8, step: 1, initial: 0)],
      outputs: const <SimOutput>[SimOutput('T', 'Project duration', '60 - x - y', unit: 'days', decimals: 0), SimOutput('K', 'Total cost', '400 + 2*x + 3.5*y + 3*(60 - x - y)', unit: '£k', decimals: 1)],
      given: const <String, double>{'x': 4, 'y': 2}, ask: const <String>['T', 'K'], formulas: const <String>['Duration = 60 − x − y', 'Cost = 400 + 2x + 3.5y + 3 × duration'],
      levels: cum(<SimConstraint>[le('T', 52, 'Finish within 52 days')], <SimConstraint>[le('K', 575, 'Total cost no more than £575k')], <SimConstraint>[le('T', 48, 'Finish within 48 days (client penalty date)'), le('K', 576, 'Total cost no more than £576k')]),
      models: same(const <String, double>{'x': 10, 'y': 2}),
      interpret: const ChoiceQuestion('which', 'Which activity should be crashed first?', <String>['A — it costs less per day saved than the £3k/day indirect cost', 'B — the more expensive one', 'Neither'], 0),
    ),
    DesignProblem(
      key: 'crew', title: 'Blockwork crew planning', brief: 'Plan a crew to lay 1200 m² of blockwork (labour £180 per worker-day).',
      inputs: const <SimInput>[SimInput('n', 'Crew size', 1, 15, step: 1, initial: 4), SimInput('p', 'Productivity per worker', 2, 12, step: 0.5, initial: 5, unit: 'm²/day')],
      outputs: const <SimOutput>[SimOutput('D', 'Duration', '1200/(n*p)', unit: 'days', decimals: 1), SimOutput('K', 'Labour cost', '1200/p*180', unit: '£', decimals: 0)],
      given: const <String, double>{'n': 6, 'p': 8}, ask: const <String>['D', 'K'], formulas: const <String>['Duration = area ÷ (crew × productivity)', 'Cost = worker-days × £180'],
      levels: cum(<SimConstraint>[le('D', 20, 'Finish within 20 days')], <SimConstraint>[le('n', 10, 'No more than 10 workers (site space)')], <SimConstraint>[le('K', 30000, 'Labour no more than £30,000'), le('p', 8, 'Realistic productivity (≤ 8 m²/day)')]),
      models: same(const <String, double>{'n': 8, 'p': 8}),
      interpret: const ChoiceQuestion('crewcost', 'Adding workers (same productivity) changes labour cost by', <String>['nothing — it only shortens the duration', 'increasing it in proportion', 'halving it'], 0),
    ),
    DesignProblem(
      key: 'pour', title: 'Concrete pour logistics', brief: 'Plan truck deliveries (8 m³ each) for a slab pour in one shift.',
      inputs: const <SimInput>[SimInput('V', 'Pour volume', 50, 400, step: 10, initial: 300, unit: 'm³'), SimInput('r', 'Trucks per hour', 1, 8, step: 1, initial: 2)],
      outputs: const <SimOutput>[SimOutput('h', 'Pour duration', 'V/(8*r)', unit: 'h', decimals: 2)],
      given: const <String, double>{'V': 120, 'r': 3}, ask: const <String>['h'], formulas: const <String>['duration = volume ÷ (8 m³ × trucks/h)'],
      levels: cum(<SimConstraint>[ge('V', 200, 'Pour at least 200 m³'), le('h', 8, 'Within one 8-hour shift')], <SimConstraint>[le('r', 4, 'Pump handles at most 4 trucks/h (32 m³/h)')], <SimConstraint>[ge('V', 240, 'Full slab: 240 m³'), le('h', 7.5, 'Allow 30 minutes for set-up')]),
      models: same(const <String, double>{'V': 240, 'r': 4}),
    ),
    DesignProblem(
      key: 'order', title: 'Material order with wastage', brief: 'Order concrete for the frame within budget, allowing for wastage.',
      inputs: const <SimInput>[SimInput('n', 'Net quantity', 100, 500, step: 10, initial: 300, unit: 'm³'), SimInput('w', 'Wastage allowance', 0, 15, step: 1, initial: 10, unit: '%'), SimInput('p', 'Unit price', 80, 150, step: 5, initial: 120, unit: '£/m³')],
      outputs: const <SimOutput>[SimOutput('Q', 'Order quantity', 'n*(1 + w/100)', unit: 'm³', decimals: 1), SimOutput('K', 'Order cost', 'n*(1 + w/100)*p', unit: '£', decimals: 0)],
      given: const <String, double>{'n': 200, 'w': 8, 'p': 110}, ask: const <String>['Q', 'K'], formulas: const <String>['order = net × (1 + waste%)', 'cost = order × price'],
      levels: cum(<SimConstraint>[ge('n', 250, 'Net quantity at least 250 m³'), le('K', 33000, 'Budget no more than £33,000')], <SimConstraint>[ge('w', 5, 'Realistic wastage (≥ 5%)')], <SimConstraint>[ge('p', 100, 'Approved suppliers only (≥ £100/m³)'), le('K', 28000, 'Revised budget £28,000')]),
      models: same(const <String, double>{'n': 250, 'w': 5, 'p': 100}),
    ),
    DesignProblem(
      key: 'lift', title: 'Crane lift plan', brief: 'Plan a tower-crane lift (load moment 600 t·m) to no more than 75% of capacity.',
      inputs: const <SimInput>[SimInput('r', 'Radius', 5, 40, step: 1, initial: 30, unit: 'm'), SimInput('L', 'Load', 1, 30, step: 0.5, initial: 20, unit: 't')],
      outputs: const <SimOutput>[SimOutput('C', 'Capacity at radius', '600/r', unit: 't'), SimOutput('U', 'Utilisation', 'L/(600/r)')],
      given: const <String, double>{'r': 25, 'L': 15}, ask: const <String>['C', 'U'], formulas: const <String>['capacity = load moment ÷ radius'],
      levels: cum(<SimConstraint>[ge('L', 10, 'Lift a 10 t precast unit'), le('U', 0.75, 'No more than 75% of capacity')], <SimConstraint>[ge('r', 15, 'Crane cannot be closer than 15 m')], <SimConstraint>[ge('r', 30, 'Unit lands 30 m from the mast'), ge('L', 12, 'Heavier 12 t unit')]),
      models: same(const <String, double>{'r': 30, 'L': 12}),
    ),
  ], person: _amina),
);

final List<LabSpec> civilLabs = <LabSpec>[civilStructuresLab, civilMaterialsLab, civilGeotechLab, civilSurveyingLab, civilTransportLab, civilConstructionLab];
