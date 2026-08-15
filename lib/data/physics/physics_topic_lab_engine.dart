import 'package:flutter/material.dart';

import '../../models/physics/physics_lab_models.dart';
import '../../models/physics/physics_program.dart';
import 'physics_lab_engine.dart';

/// Complete laboratory experience for a single physics topic.
class PhysicsTopicLabProfile {
  const PhysicsTopicLabProfile({
    required this.simulationTitle,
    required this.simulationEmoji,
    required this.simulationDescription,
    required this.simulationKind,
    required this.mission,
    required this.controls,
    required this.virtualLab,
    required this.report,
    this.engineeringChallenge = '',
  });

  final String simulationTitle;
  final String simulationEmoji;
  final String simulationDescription;
  final PhysicsSimulationKind simulationKind;
  final PhysicsLabMission mission;
  final List<PhysicsControlSpec> controls;
  final PhysicsLabRoom virtualLab;
  final PhysicsExperimentReportTemplate report;
  final String engineeringChallenge;

  String get hubLabel => '$simulationEmoji $simulationTitle';
}

/// Topic-based lab registry — every physics topic gets its own simulation, lab, and report.
class PhysicsTopicLabEngine {
  PhysicsTopicLabEngine._();

  static PhysicsTopicLabProfile profileFor({
    required PhysicsCourse course,
    required PhysicsTopic topic,
  }) {
    return _custom[topic.id] ?? _buildDynamic(course: course, topic: topic);
  }

  static final Map<String, PhysicsTopicLabProfile> _custom = <String, PhysicsTopicLabProfile>{
    'kinematics_velocity': _velocityProfile(),
    'kinematics_acceleration': _accelerationProfile(),
    'newtonian_mechanics_newtons_laws': _newtonLawsProfile(),
    'work_energy_power_kinetic_energy': _energyProfile(),
    'momentum_collisions_momentum': _momentumProfile(),
    'electric_circuits_ohms_law': _ohmsLawProfile(),
    'optics_lenses': _lensesProfile(),
    'kinematics_projectile_motion': _projectileProfile(),
  };

  static PhysicsTopicLabProfile _velocityProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Motion Tracking Laboratory',
      simulationEmoji: '🏎️',
      simulationDescription:
          'Measure movement, analyze velocity, and explore how objects move on a 3D track.',
      simulationKind: PhysicsSimulationKind.motionTracking,
      mission: const PhysicsLabMission(
        prompt: 'Set distance and time so the car moves at exactly 10 m/s east.',
        targetDescription: 'Velocity ≈ 10 m/s',
        hint: 'Velocity = distance ÷ time. Try 100 m in 10 s.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'distance', label: 'Distance', unit: 'm', min: 10, max: 500, initial: 100),
        PhysicsControlSpec(id: 'time', label: 'Time', unit: 's', min: 1, max: 60, initial: 10),
        PhysicsControlSpec(id: 'direction', label: 'Direction', unit: '°', min: 0, max: 360, initial: 90),
        PhysicsControlSpec(id: 'object_mass', label: 'Object mass', unit: 'kg', min: 0.5, max: 2000, initial: 1200, step: 50),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'velocity_motion_lab',
        name: 'Motion Tracking Lab',
        emoji: '🔬',
        description: 'Measure velocity using motion sensors and a linear track.',
        equipment: <String>['Motion sensor', 'Camera', 'Track', 'Timer', 'Moving cart'],
        experimentTitle: 'Measuring Velocity Using Motion Sensors',
        experimentSteps: <String>[
          'Mount the motion sensor at the start of the track.',
          'Place the cart at the starting mark and zero the timer.',
          'Release the cart and record position every second.',
          'Plot position vs time and compute v = Δx/Δt.',
          'Compare your slope to the simulation prediction.',
        ],
        icon: Icons.speed_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Determining Velocity of a Moving Object',
        objective: 'Calculate velocity using displacement and time.',
        hypothesis:
            'If displacement increases proportionally with time, the object moves at constant velocity.',
        procedureSteps: <String>[
          'Set up the motion sensor and linear track.',
          'Release the cart from rest at the starting line.',
          'Record position at 1 s intervals for 5 s.',
          'Calculate velocity from the position–time slope.',
        ],
        dataTable: '| Time (s) | Position (m) |\n| --- | --- |\n| 0 | 0 |\n| 1 | 5 |\n| 2 | 10 |\n| 3 | 15 |\n| 4 | 20 |\n| 5 | 25 |',
        calculationHint: 'v = displacement / time = Δx / Δt',
        conclusionHint: 'The object\'s velocity was constant at ___ m/s.',
        aiInsight: 'Your object moved at constant velocity.',
      ),
      engineeringChallenge: 'Design a timing gate system that measures average speed on a highway on-ramp.',
    );
  }

  static PhysicsTopicLabProfile _accelerationProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Vehicle Acceleration Test',
      simulationEmoji: '🚗',
      simulationDescription:
          'Control engine power, vehicle mass, and road conditions to measure acceleration from rest.',
      simulationKind: PhysicsSimulationKind.acceleration,
      mission: const PhysicsLabMission(
        prompt: 'Accelerate from rest to 20 m/s in under 4 seconds.',
        targetDescription: 'Final speed ≥ 20 m/s, time ≤ 4 s',
        hint: 'Acceleration a = Δv/Δt. Increase engine power or reduce mass.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'engine_power', label: 'Engine power', unit: 'kW', min: 50, max: 500, initial: 200, step: 10),
        PhysicsControlSpec(id: 'vehicle_mass', label: 'Vehicle mass', unit: 'kg', min: 800, max: 3000, initial: 1400, step: 50),
        PhysicsControlSpec(id: 'road_friction', label: 'Road friction', unit: '×', min: 0.1, max: 1, initial: 0.3, step: 0.05),
        PhysicsControlSpec(id: 'test_duration', label: 'Test duration', unit: 's', min: 1, max: 10, initial: 4),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'acceleration_lab',
        name: 'Acceleration Test Bay',
        emoji: '🏁',
        description: 'Race car on a straight test track with speed sensors.',
        equipment: <String>['Race car', 'Speed sensors', 'Stopwatch', 'Data logger', 'Safety barriers'],
        experimentTitle: 'Determine Acceleration from Rest',
        experimentSteps: <String>[
          'Position speed sensors at 0 m and 50 m on the track.',
          'Start the vehicle from rest and begin timing.',
          'Record speed at each sensor and the elapsed time.',
          'Compute a = Δv/Δt from your measurements.',
          'Repeat with different loads and compare results.',
        ],
        icon: Icons.directions_car_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Measuring Acceleration of a Vehicle',
        objective: 'Determine acceleration from rest using speed and time data.',
        hypothesis: 'Greater engine force produces higher acceleration for a fixed mass.',
        procedureSteps: <String>[
          'Calibrate speed sensors and zero the stopwatch.',
          'Release the vehicle from rest at the start line.',
          'Record velocity at 1 s intervals until 5 s.',
          'Plot velocity vs time and find the slope.',
        ],
        dataTable: '| Time (s) | Velocity (m/s) |\n| --- | --- |\n| 0 | 0 |\n| 1 | 4 |\n| 2 | 8 |\n| 3 | 12 |\n| 4 | 16 |',
        calculationHint: 'a = Δv / Δt',
        conclusionHint: 'The vehicle accelerated at ___ m/s² from rest.',
        aiInsight: 'Your velocity increased linearly — constant acceleration.',
      ),
      engineeringChallenge: 'Optimize launch acceleration for an electric vehicle without wheel slip.',
    );
  }

  static PhysicsTopicLabProfile _newtonLawsProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Spacecraft Thruster Test',
      simulationEmoji: '🚀',
      simulationDescription:
          'Control rocket mass, engine force, and fuel to observe Newton\'s second law in action.',
      simulationKind: PhysicsSimulationKind.forceThrust,
      mission: const PhysicsLabMission(
        prompt: 'Achieve 5 m/s² acceleration with your spacecraft configuration.',
        targetDescription: 'Acceleration ≈ 5 m/s²',
        hint: 'F = ma. Increase thrust or reduce mass.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'rocket_mass', label: 'Rocket mass', unit: 'kg', min: 500, max: 5000, initial: 2000, step: 100),
        PhysicsControlSpec(id: 'engine_force', label: 'Engine force', unit: 'kN', min: 5, max: 80, initial: 25, step: 1),
        PhysicsControlSpec(id: 'fuel_mass', label: 'Fuel mass', unit: 'kg', min: 0, max: 1000, initial: 300, step: 50),
        PhysicsControlSpec(id: 'burn_time', label: 'Burn time', unit: 's', min: 1, max: 30, initial: 10),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'newton_force_lab',
        name: 'Force & Motion Lab',
        emoji: '⚖️',
        description: 'Investigate the relationship between force, mass, and acceleration.',
        equipment: <String>['Cart', 'Weights', 'Pulley system', 'Force sensor', 'Track'],
        experimentTitle: 'Investigate Force and Acceleration',
        experimentSteps: <String>[
          'Attach a known mass to the cart via the pulley.',
          'Measure the applied force with the force sensor.',
          'Release the cart and record acceleration.',
          'Plot F vs a and verify F = ma.',
          'Repeat with different hanging masses.',
        ],
        icon: Icons.balance_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Investigating Newton\'s Second Law',
        objective: 'Verify that acceleration is proportional to net force and inversely proportional to mass.',
        hypothesis: 'Doubling the applied force doubles the acceleration for a fixed mass.',
        procedureSteps: <String>[
          'Set up cart, pulley, and force sensor on a level track.',
          'Apply a known hanging weight and measure force.',
          'Record acceleration for three different forces.',
          'Plot acceleration vs force and find the slope (1/m).',
        ],
        dataTable: '| Trial | Force (N) | Mass (kg) | Acceleration (m/s²) |\n| --- | --- | --- | --- |\n| 1 |  |  |  |\n| 2 |  |  |  |\n| 3 |  |  |  |',
        calculationHint: 'a = F / m',
        conclusionHint: 'Measured accelerations confirm F = ma within experimental error.',
        aiInsight: 'Force and acceleration scale together as Newton\'s second law predicts.',
      ),
      engineeringChallenge: 'Size thrusters for a satellite maneuver while staying within fuel budget.',
    );
  }

  static PhysicsTopicLabProfile _energyProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Roller Coaster Energy Lab',
      simulationEmoji: '🎢',
      simulationDescription:
          'Design track height, shape, and cart mass — observe potential and kinetic energy exchange.',
      simulationKind: PhysicsSimulationKind.energyCoaster,
      mission: const PhysicsLabMission(
        prompt: 'Design a coaster that reaches 25 m/s at the bottom of a 40 m drop.',
        targetDescription: 'Bottom speed ≈ 25 m/s',
        hint: 'Energy conservation: ½mv² ≈ mgh (ignore friction first).',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'track_height', label: 'Track height', unit: 'm', min: 5, max: 80, initial: 40),
        PhysicsControlSpec(id: 'cart_mass', label: 'Cart mass', unit: 'kg', min: 200, max: 800, initial: 400, step: 50),
        PhysicsControlSpec(id: 'friction', label: 'Track friction', unit: '×', min: 0, max: 0.5, initial: 0.05, step: 0.01),
        PhysicsControlSpec(id: 'loop_radius', label: 'Loop radius', unit: 'm', min: 0, max: 20, initial: 8),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'energy_lab',
        name: 'Energy Conservation Lab',
        emoji: '⚡',
        description: 'Track energy transformations on a roller coaster model.',
        equipment: <String>['Coaster track model', 'Height gauge', 'Speed sensor', 'Energy meter', 'Timer'],
        experimentTitle: 'Potential and Kinetic Energy on a Track',
        experimentSteps: <String>[
          'Measure the cart mass and starting height.',
          'Release the cart from rest at the top of the track.',
          'Record speed at the lowest point.',
          'Compare ½mv² to mgh and account for friction losses.',
          'Adjust height and predict the new bottom speed.',
        ],
        icon: Icons.roller_skating_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Energy Conservation on a Roller Coaster',
        objective: 'Compare gravitational potential energy at the top to kinetic energy at the bottom.',
        hypothesis: 'Mechanical energy is conserved if friction losses are small.',
        procedureSteps: <String>[
          'Measure starting height h and cart mass m.',
          'Release cart from rest and measure bottom speed v.',
          'Calculate PE = mgh and KE = ½mv².',
          'Compute percent energy lost to friction.',
        ],
        dataTable: '| Height (m) | Speed (m/s) | PE (J) | KE (J) |\n| --- | --- | --- | --- |\n| 40 |  |  |  |\n| 30 |  |  |  |\n| 20 |  |  |  |',
        calculationHint: 'PE = mgh, KE = ½mv², v = √(2gh) ideally',
        conclusionHint: 'Energy was conserved within ___% accounting for friction.',
        aiInsight: 'Potential energy converted to kinetic energy as the cart descended.',
      ),
      engineeringChallenge: 'Design a loop-the-loop section that stays above the minimum safe speed.',
    );
  }

  static PhysicsTopicLabProfile _momentumProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Collision Analysis Lab',
      simulationEmoji: '💥',
      simulationDescription:
          'Vary vehicle masses and impact speeds to study momentum conservation in crashes.',
      simulationKind: PhysicsSimulationKind.collision,
      mission: const PhysicsLabMission(
        prompt: 'Design a vehicle that survives a crash at 20 m/s.',
        targetDescription: 'Impact energy below safe threshold',
        hint: 'Lower speed, increase crumple zone, or add mass to the barrier.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'mass_a', label: 'Vehicle mass', unit: 'kg', min: 500, max: 3000, initial: 1200, step: 50),
        PhysicsControlSpec(id: 'mass_b', label: 'Barrier mass', unit: 'kg', min: 500, max: 8000, initial: 2000, step: 50),
        PhysicsControlSpec(id: 'speed', label: 'Impact speed', unit: 'm/s', min: 5, max: 35, initial: 20),
        PhysicsControlSpec(id: 'stiffness', label: 'Crumple stiffness', unit: '×', min: 0.2, max: 2, initial: 1, step: 0.1),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'momentum_lab',
        name: 'Momentum & Collisions Lab',
        emoji: '🛡️',
        description: 'Study momentum conservation with carts on an air track.',
        equipment: <String>['Air track', 'Glider carts', 'Bumpers', 'Motion sensors', 'Scale'],
        experimentTitle: 'Elastic and Inelastic Collisions',
        experimentSteps: <String>[
          'Measure masses of both carts on the air track.',
          'Record velocities before collision with motion sensors.',
          'Perform an elastic collision and record final velocities.',
          'Verify momentum conservation: m₁v₁ + m₂v₂ = m₁v₁\' + m₂v₂\'.',
          'Repeat with Velcro bumpers for an inelastic collision.',
        ],
        icon: Icons.compare_arrows_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Momentum Conservation in Collisions',
        objective: 'Verify that total momentum is conserved in elastic and inelastic collisions.',
        hypothesis: 'Total momentum before equals total momentum after collision.',
        procedureSteps: <String>[
          'Level the air track and measure cart masses.',
          'Record initial velocities of both carts.',
          'Measure final velocities after collision.',
          'Compare total momentum before and after.',
        ],
        dataTable: '| Trial | m₁ (kg) | v₁ᵢ (m/s) | m₂ (kg) | v₂ᵢ (m/s) | v₁f (m/s) | v₂f (m/s) |\n| --- | --- | --- | --- | --- | --- | --- |\n| 1 |  |  |  |  |  |  |',
        calculationHint: 'p = mv, Σp_before = Σp_after',
        conclusionHint: 'Momentum was conserved within ___% experimental error.',
        aiInsight: 'Total momentum remained constant through the collision.',
      ),
      engineeringChallenge: 'Design crumple zones that absorb impact while protecting passengers.',
    );
  }

  static PhysicsTopicLabProfile _ohmsLawProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Circuit Engineering Laboratory',
      simulationEmoji: '⚡',
      simulationDescription:
          'Build circuits and discover electrical laws — drag batteries, wires, resistors, and LEDs.',
      simulationKind: PhysicsSimulationKind.circuit,
      mission: const PhysicsLabMission(
        prompt: 'Light the LED without burning the resistor.',
        targetDescription: 'Current between 5 mA and 25 mA',
        hint: 'Use Ohm\'s law: I = V/R. Adjust resistance or voltage.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'voltage', label: 'Battery', unit: 'V', min: 1.5, max: 12, initial: 9),
        PhysicsControlSpec(id: 'resistance', label: 'Resistor', unit: 'Ω', min: 50, max: 2000, initial: 330),
        PhysicsControlSpec(id: 'led_rating', label: 'LED rating', unit: 'mA', min: 5, max: 30, initial: 20),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'circuit_lab',
        name: 'Circuit Engineering Lab',
        emoji: '🔌',
        description: 'Breadboard circuits with multimeter measurements.',
        equipment: <String>['Breadboard', 'Multimeter', 'DC power supply', 'Resistors', 'LEDs', 'Wires'],
        experimentTitle: 'Verify Ohm\'s Law on a Series Circuit',
        experimentSteps: <String>[
          'Build a series circuit with battery, resistor, and LED.',
          'Measure voltage across the resistor with the multimeter.',
          'Measure current in series with the ammeter.',
          'Calculate R = V/I and compare to resistor rating.',
          'Adjust resistance until LED current is in safe range.',
        ],
        icon: Icons.electric_bolt_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Verification of Ohm\'s Law',
        objective: 'Measure voltage and current to verify V = IR.',
        hypothesis: 'Current is directly proportional to voltage for a fixed resistor.',
        procedureSteps: <String>[
          'Construct a series circuit on the breadboard.',
          'Vary battery voltage in 1 V steps.',
          'Record voltage and current for each setting.',
          'Plot I vs V and find resistance from slope.',
        ],
        dataTable: '| Voltage (V) | Current (mA) | Resistance (Ω) |\n| --- | --- | --- |\n| 3 |  |  |\n| 6 |  |  |\n| 9 |  |  |\n| 12 |  |  |',
        calculationHint: 'R = V / I',
        conclusionHint: 'Measured resistance was ___ Ω, confirming Ohm\'s law.',
        aiInsight: 'Current increased linearly with voltage — Ohm\'s law holds.',
      ),
      engineeringChallenge: 'Design a voltage divider that powers an LED at exactly 15 mA.',
    );
  }

  static PhysicsTopicLabProfile _lensesProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Optics Laboratory',
      simulationEmoji: '🔭',
      simulationDescription:
          'Design lenses, cameras, and telescopes — adjust focal lengths and magnification.',
      simulationKind: PhysicsSimulationKind.optics,
      mission: const PhysicsLabMission(
        prompt: 'Build a telescope that magnifies a distant star 5×.',
        targetDescription: 'Angular magnification ≈ 5',
        hint: 'Magnification ≈ f_objective / f_eyepiece.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'f_objective', label: 'Objective focal length', unit: 'cm', min: 10, max: 100, initial: 50),
        PhysicsControlSpec(id: 'f_eyepiece', label: 'Eyepiece focal length', unit: 'cm', min: 2, max: 25, initial: 10),
        PhysicsControlSpec(id: 'object_distance', label: 'Object distance', unit: 'm', min: 10, max: 1000, initial: 100),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'optics_lab',
        name: 'Optics Laboratory',
        emoji: '🔬',
        description: 'Lenses, mirrors, and laser benches for imaging experiments.',
        equipment: <String>['Convex lens', 'Concave mirror', 'Optical bench', 'Laser', 'Screen'],
        experimentTitle: 'Construct and Test a Simple Telescope',
        experimentSteps: <String>[
          'Mount objective lens and eyepiece on the optical bench.',
          'Focus a distant object onto the screen.',
          'Measure focal lengths of both lenses.',
          'Calculate magnification M = f_obj / f_eye.',
          'Record image clarity and field of view.',
        ],
        icon: Icons.filter_center_focus_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Telescope Magnification Experiment',
        objective: 'Measure focal lengths and calculate angular magnification.',
        hypothesis: 'Magnification equals the ratio of objective to eyepiece focal lengths.',
        procedureSteps: <String>[
          'Set up lenses on the optical bench.',
          'Measure focal length of each lens.',
          'Align telescope and focus on distant target.',
          'Estimate magnification from image size ratio.',
        ],
        dataTable: '| Lens | Focal length (cm) | Magnification |\n| --- | --- | --- |\n| Objective |  |  |\n| Eyepiece |  |  |\n| Combined |  |  |',
        calculationHint: 'M = f_objective / f_eyepiece',
        conclusionHint: 'Measured magnification was ___×, matching the focal length ratio.',
        aiInsight: 'Image size scaled with the focal length ratio as predicted.',
      ),
      engineeringChallenge: 'Design a camera lens system with 3× zoom and minimal distortion.',
    );
  }

  static PhysicsTopicLabProfile _projectileProfile() {
    return PhysicsTopicLabProfile(
      simulationTitle: 'Projectile Launch Laboratory',
      simulationEmoji: '🎯',
      simulationDescription:
          'Launch projectiles at varying angles and speeds — predict range and trajectory.',
      simulationKind: PhysicsSimulationKind.projectile,
      mission: const PhysicsLabMission(
        prompt: 'Design a rocket shot that lands 500 meters away.',
        targetDescription: 'Range ≈ 500 m (±40 m)',
        hint: 'On level ground with no drag, 45° often maximizes range.',
      ),
      controls: const <PhysicsControlSpec>[
        PhysicsControlSpec(id: 'velocity', label: 'Launch velocity', unit: 'm/s', min: 5, max: 80, initial: 50),
        PhysicsControlSpec(id: 'angle', label: 'Launch angle', unit: '°', min: 5, max: 85, initial: 45),
        PhysicsControlSpec(id: 'gravity', label: 'Gravity', unit: 'm/s²', min: 1.6, max: 20, initial: 9.81, step: 0.1),
        PhysicsControlSpec(id: 'mass', label: 'Projectile mass', unit: 'kg', min: 0.5, max: 20, initial: 2, step: 0.5),
        PhysicsControlSpec(id: 'drag', label: 'Air resistance', unit: '×', min: 0, max: 1, initial: 0, step: 0.05),
      ],
      virtualLab: const PhysicsLabRoom(
        id: 'projectile_lab',
        name: 'Ballistics Laboratory',
        emoji: '🎯',
        description: 'Launch angles, range finders, and trajectory analysis.',
        equipment: <String>['Launch ramp', 'Protractor', 'Range finder', 'Timer', 'Carbon paper'],
        experimentTitle: 'Range vs Launch Angle',
        experimentSteps: <String>[
          'Set launch angle to 30° and record the range.',
          'Repeat for 45° and 60° at the same launch speed.',
          'Plot range vs angle and identify maximum range.',
          'Compare measured range to v²sin(2θ)/g prediction.',
          'Enable air resistance and note the range decrease.',
        ],
        icon: Icons.sports_baseball_outlined,
      ),
      report: const PhysicsExperimentReportTemplate(
        title: 'Projectile Range vs Launch Angle',
        objective: 'Measure range as a function of launch angle and compare to theory.',
        hypothesis: 'Range is maximized near 45° on level ground with no air resistance.',
        procedureSteps: <String>[
          'Fix launch speed and vary angle in 15° steps.',
          'Measure horizontal range for each trial.',
          'Plot range vs angle.',
          'Compare to R = v²sin(2θ)/g.',
        ],
        dataTable: '| Angle (°) | Range (m) | Predicted (m) |\n| --- | --- | --- |\n| 30 |  |  |\n| 45 |  |  |\n| 60 |  |  |',
        calculationHint: 'R = v²sin(2θ)/g',
        conclusionHint: 'Maximum range occurred at ___°, matching theory within error.',
        aiInsight: 'Range peaked near 45° as projectile motion theory predicts.',
      ),
      engineeringChallenge: 'Hit a 500 m target from a moving platform with crosswind.',
    );
  }

  static PhysicsTopicLabProfile _buildDynamic({
    required PhysicsCourse course,
    required PhysicsTopic topic,
  }) {
    final String t = topic.title;
    final String tl = t.toLowerCase();
    final _KindBundle bundle = _resolveKind(course.id, tl, topic.id);

    return PhysicsTopicLabProfile(
      simulationTitle: bundle.simulationTitle(t),
      simulationEmoji: bundle.emoji,
      simulationDescription: bundle.description(t, course.title),
      simulationKind: bundle.kind,
      mission: bundle.mission(t),
      controls: bundle.controls(t),
      virtualLab: _virtualLab(t, course.title, bundle),
      report: _reportTemplate(t, course.title, bundle),
      engineeringChallenge: bundle.challenge(t),
    );
  }

  static _KindBundle _resolveKind(String courseId, String tl, String topicId) {
    if (topicId.contains('velocity') ||
        topicId.contains('speed') ||
        topicId.contains('displacement') ||
        topicId.contains('position') ||
        topicId.contains('distance') ||
        tl.contains('velocity') ||
        tl.contains('speed') ||
        tl.contains('displacement')) {
      return _KindBundle.motion;
    }
    if (topicId.contains('acceleration') || tl.contains('acceleration')) {
      return _KindBundle.acceleration;
    }
    if (topicId.contains('force') ||
        topicId.contains('newton') ||
        tl.contains('force') ||
        tl.contains('newton')) {
      return _KindBundle.force;
    }
    if (topicId.contains('energy') ||
        topicId.contains('work') ||
        topicId.contains('power') ||
        tl.contains('energy') ||
        tl.contains('kinetic') ||
        tl.contains('potential')) {
      return _KindBundle.energy;
    }
    if (topicId.contains('momentum') ||
        topicId.contains('collision') ||
        tl.contains('momentum') ||
        tl.contains('collision')) {
      return _KindBundle.collision;
    }
    if (_circuitCourses.contains(courseId) ||
        tl.contains('circuit') ||
        tl.contains('resistance') ||
        tl.contains('current') ||
        tl.contains('voltage')) {
      return _KindBundle.circuit;
    }
    if (courseId == 'optics' || tl.contains('lens') || tl.contains('mirror') || tl.contains('light')) {
      return _KindBundle.optics;
    }
    if (courseId.contains('astro') ||
        courseId.contains('space') ||
        tl.contains('rocket') ||
        tl.contains('orbit') ||
        tl.contains('satellite')) {
      return _KindBundle.rocket;
    }
    if (courseId == 'gravitation' || tl.contains('gravity') || tl.contains('planet')) {
      return _KindBundle.gravity;
    }
    if (_waveCourses.contains(courseId) || tl.contains('wave') || tl.contains('frequency')) {
      return _KindBundle.wave;
    }
    if (tl.contains('projectile') || tl.contains('launch')) {
      return _KindBundle.projectile;
    }
    if (_mechanicsCourses.contains(courseId)) {
      return _KindBundle.motion;
    }
    return _KindBundle.generic;
  }

  static const Set<String> _mechanicsCourses = <String>{
    'kinematics',
    'newtonian_mechanics',
    'work_energy_power',
    'momentum_collisions',
    'rotational_mechanics',
    'gravitation',
    'oscillations',
    'fluid_mechanics',
  };

  static const Set<String> _circuitCourses = <String>{
    'electrostatics',
    'electric_circuits',
    'magnetism',
    'em_induction',
    'maxwell_equations',
  };

  static const Set<String> _waveCourses = <String>{
    'waves',
    'acoustics',
    'optics',
  };

  static PhysicsLabRoom _virtualLab(String topicTitle, String courseTitle, _KindBundle bundle) {
    return PhysicsLabRoom(
      id: '${topicTitle.toLowerCase().replaceAll(' ', '_')}_lab',
      name: '$topicTitle Laboratory',
      emoji: bundle.labEmoji,
      description: 'University bench for studying $topicTitle in $courseTitle.',
      equipment: bundle.equipment(topicTitle),
      experimentTitle: bundle.experimentTitle(topicTitle),
      experimentSteps: bundle.experimentSteps(topicTitle),
      icon: bundle.labIcon,
    );
  }

  static PhysicsExperimentReportTemplate _reportTemplate(
    String topicTitle,
    String courseTitle,
    _KindBundle bundle,
  ) {
    return PhysicsExperimentReportTemplate(
      title: 'Determining $topicTitle — ${bundle.experimentTitle(topicTitle)}',
      objective: 'Measure and analyze $topicTitle and compare results to theoretical predictions in $courseTitle.',
      hypothesis:
          'If the primary experimental variable for $topicTitle is changed, the measured response will follow the governing physics relation.',
      procedureSteps: bundle.experimentSteps(topicTitle),
      dataTable: bundle.dataTable(topicTitle),
      calculationHint: bundle.calculationHint(topicTitle),
      conclusionHint: 'The measured $topicTitle value was ___ with appropriate units.',
      aiInsight: bundle.aiInsight(topicTitle),
    );
  }
}

class _KindBundle {
  const _KindBundle({
    required this.kind,
    required this.emoji,
    required this.labEmoji,
    required this.labIcon,
    required this.simulationTitleFn,
    required this.descriptionFn,
    required this.missionFn,
    required this.controlsFn,
    required this.equipmentFn,
    required this.experimentTitleFn,
    required this.experimentStepsFn,
    required this.dataTableFn,
    required this.calculationHintFn,
    required this.aiInsightFn,
    required this.challengeFn,
  });

  final PhysicsSimulationKind kind;
  final String emoji;
  final String labEmoji;
  final IconData labIcon;
  final String Function(String topic) simulationTitleFn;
  final String Function(String topic, String course) descriptionFn;
  final PhysicsLabMission Function(String topic) missionFn;
  final List<PhysicsControlSpec> Function(String topic) controlsFn;
  final List<String> Function(String topic) equipmentFn;
  final String Function(String topic) experimentTitleFn;
  final List<String> Function(String topic) experimentStepsFn;
  final String Function(String topic) dataTableFn;
  final String Function(String topic) calculationHintFn;
  final String Function(String topic) aiInsightFn;
  final String Function(String topic) challengeFn;

  String simulationTitle(String t) => simulationTitleFn(t);
  String description(String t, String c) => descriptionFn(t, c);
  PhysicsLabMission mission(String t) => missionFn(t);
  List<PhysicsControlSpec> controls(String t) => controlsFn(t);
  List<String> equipment(String t) => equipmentFn(t);
  String experimentTitle(String t) => experimentTitleFn(t);
  List<String> experimentSteps(String t) => experimentStepsFn(t);
  String dataTable(String t) => dataTableFn(t);
  String calculationHint(String t) => calculationHintFn(t);
  String aiInsight(String t) => aiInsightFn(t);
  String challenge(String t) => challengeFn(t);

  static final _KindBundle motion = _KindBundle(
    kind: PhysicsSimulationKind.motionTracking,
    emoji: '🏎️',
    labEmoji: '🔬',
    labIcon: Icons.speed_outlined,
    simulationTitleFn: (String t) => '$t Motion Laboratory',
    descriptionFn: (String t, String _) =>
        'Measure movement, analyze $t, and explore how objects move on a 3D track.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Set distance and time to achieve a target $t reading.',
      targetDescription: 'Computed $t within ±10% of target',
      hint: 'Use the relation between distance, time, and $t.',
    ),
    controlsFn: (_) => const <PhysicsControlSpec>[
      PhysicsControlSpec(id: 'distance', label: 'Distance', unit: 'm', min: 10, max: 500, initial: 100),
      PhysicsControlSpec(id: 'time', label: 'Time', unit: 's', min: 1, max: 60, initial: 10),
      PhysicsControlSpec(id: 'direction', label: 'Direction', unit: '°', min: 0, max: 360, initial: 90),
      PhysicsControlSpec(id: 'object_mass', label: 'Object mass', unit: 'kg', min: 0.5, max: 2000, initial: 500, step: 50),
    ],
    equipmentFn: (String t) => <String>['Motion sensor', 'Track', 'Timer', 'Camera', '$t measurement kit'],
    experimentTitleFn: (String t) => 'Measuring $t Using Motion Sensors',
    experimentStepsFn: (String t) => <String>[
      'Calibrate the motion sensor on the track.',
      'Release the object and record position vs time.',
      'Calculate $t from your data table.',
      'Compare measured $t to the simulation result.',
      'Repeat with a different distance and verify consistency.',
    ],
    dataTableFn: (_) => '| Time (s) | Position (m) |\n| --- | --- |\n| 0 | 0 |\n| 1 |  |\n| 2 |  |\n| 3 |  |',
    calculationHintFn: (String t) => 'Compute $t from measured displacement and elapsed time.',
    aiInsightFn: (String t) => 'Your data shows how $t relates to position and time.',
    challengeFn: (String t) => 'Design a sensor array that logs $t in real time on a test track.',
  );

  static final _KindBundle acceleration = _KindBundle(
    kind: PhysicsSimulationKind.acceleration,
    emoji: '🚗',
    labEmoji: '🏁',
    labIcon: Icons.directions_car_outlined,
    simulationTitleFn: (String t) => '$t Acceleration Test',
    descriptionFn: (String t, String _) =>
        'Control engine power, mass, and road conditions to measure $t.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Achieve a measurable $t above 3 m/s².',
      targetDescription: '$t ≥ 3 m/s²',
      hint: 'Acceleration depends on net force and mass.',
    ),
    controlsFn: (_) => const <PhysicsControlSpec>[
      PhysicsControlSpec(id: 'engine_power', label: 'Engine power', unit: 'kW', min: 50, max: 500, initial: 200, step: 10),
      PhysicsControlSpec(id: 'vehicle_mass', label: 'Vehicle mass', unit: 'kg', min: 800, max: 3000, initial: 1400, step: 50),
      PhysicsControlSpec(id: 'road_friction', label: 'Road friction', unit: '×', min: 0.1, max: 1, initial: 0.3, step: 0.05),
      PhysicsControlSpec(id: 'test_duration', label: 'Test duration', unit: 's', min: 1, max: 10, initial: 4),
    ],
    equipmentFn: (String t) => <String>['Test vehicle', 'Speed sensors', 'Stopwatch', 'Data logger', '$t meter'],
    experimentTitleFn: (String t) => 'Determine $t from Rest',
    experimentStepsFn: (String t) => <String>[
      'Position speed sensors along the test track.',
      'Accelerate from rest and record velocity vs time.',
      'Compute $t from the slope of the v–t graph.',
      'Repeat with different loads.',
      'Compare results to simulation predictions.',
    ],
    dataTableFn: (_) => '| Time (s) | Velocity (m/s) |\n| --- | --- |\n| 0 | 0 |\n| 1 |  |\n| 2 |  |\n| 3 |  |',
    calculationHintFn: (String t) => '$t = Δv / Δt',
    aiInsightFn: (String t) => 'Velocity changed steadily — your $t was nearly constant.',
    challengeFn: (String t) => 'Minimize 0–60 mph time while keeping $t below tire grip limit.',
  );

  static final _KindBundle force = _KindBundle(
    kind: PhysicsSimulationKind.forceThrust,
    emoji: '🚀',
    labEmoji: '⚖️',
    labIcon: Icons.balance_outlined,
    simulationTitleFn: (String t) => '$t Thruster Laboratory',
    descriptionFn: (String t, String _) =>
        'Apply forces and observe how $t governs motion and equilibrium.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Configure forces so the system accelerates at 4 m/s².',
      targetDescription: 'Acceleration ≈ 4 m/s²',
      hint: 'Net force divided by mass gives acceleration.',
    ),
    controlsFn: (_) => const <PhysicsControlSpec>[
      PhysicsControlSpec(id: 'rocket_mass', label: 'System mass', unit: 'kg', min: 500, max: 5000, initial: 2000, step: 100),
      PhysicsControlSpec(id: 'engine_force', label: 'Applied force', unit: 'kN', min: 5, max: 80, initial: 25, step: 1),
      PhysicsControlSpec(id: 'fuel_mass', label: 'Fuel mass', unit: 'kg', min: 0, max: 1000, initial: 300, step: 50),
      PhysicsControlSpec(id: 'burn_time', label: 'Burn time', unit: 's', min: 1, max: 30, initial: 10),
    ],
    equipmentFn: (String t) => <String>['Force sensor', 'Cart', 'Weights', 'Pulley', '$t apparatus'],
    experimentTitleFn: (String t) => 'Investigate $t and Acceleration',
    experimentStepsFn: (String t) => <String>[
      'Measure the applied force on the system.',
      'Record acceleration for three different forces.',
      'Plot results and verify $t = ma.',
      'Add mass and observe the change in acceleration.',
      'Document sources of friction error.',
    ],
    dataTableFn: (_) => '| Trial | Force (N) | Mass (kg) | Acceleration (m/s²) |\n| --- | --- | --- | --- |\n| 1 |  |  |  |\n| 2 |  |  |  |',
    calculationHintFn: (String t) => 'Use $t and F = ma for calculations.',
    aiInsightFn: (String t) => 'Acceleration scaled with applied $t as Newton\'s laws predict.',
    challengeFn: (String t) => 'Size actuators to deliver required $t without exceeding structural limits.',
  );

  static final _KindBundle energy = _KindBundle(
    kind: PhysicsSimulationKind.energyCoaster,
    emoji: '🎢',
    labEmoji: '⚡',
    labIcon: Icons.roller_skating_outlined,
    simulationTitleFn: (String t) => '$t Energy Laboratory',
    descriptionFn: (String t, String _) =>
        'Track energy transformations and measure how $t changes along a path.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Design a system where $t converts efficiently between forms.',
      targetDescription: 'Energy balance within 10%',
      hint: 'Conservation of energy links height, speed, and $t.',
    ),
    controlsFn: (_) => const <PhysicsControlSpec>[
      PhysicsControlSpec(id: 'track_height', label: 'Track height', unit: 'm', min: 5, max: 80, initial: 30),
      PhysicsControlSpec(id: 'cart_mass', label: 'Cart mass', unit: 'kg', min: 200, max: 800, initial: 400, step: 50),
      PhysicsControlSpec(id: 'friction', label: 'Friction', unit: '×', min: 0, max: 0.5, initial: 0.05, step: 0.01),
      PhysicsControlSpec(id: 'loop_radius', label: 'Loop radius', unit: 'm', min: 0, max: 20, initial: 0),
    ],
    equipmentFn: (String t) => <String>['Track model', 'Height gauge', 'Speed sensor', 'Energy meter', '$t scale'],
    experimentTitleFn: (String t) => 'Measuring $t Transformation',
    experimentStepsFn: (String t) => <String>[
      'Measure initial $t at the top of the track.',
      'Record speed at the lowest point.',
      'Calculate energy before and after.',
      'Account for friction losses.',
      'Predict $t at a new height and test.',
    ],
    dataTableFn: (_) => '| Height (m) | Speed (m/s) | Energy (J) |\n| --- | --- | --- |\n|  |  |  |\n|  |  |  |',
    calculationHintFn: (String t) => 'Relate $t to mgh and ½mv².',
    aiInsightFn: (String t) => 'Energy converted between forms while total $t was nearly conserved.',
    challengeFn: (String t) => 'Design a system that maximizes useful $t output with minimal waste.',
  );

  static final _KindBundle collision = _KindBundle(
    kind: PhysicsSimulationKind.collision,
    emoji: '💥',
    labEmoji: '🛡️',
    labIcon: Icons.compare_arrows_outlined,
    simulationTitleFn: (String t) => '$t Collision Laboratory',
    descriptionFn: (String t, String _) => 'Study impacts and how $t is conserved in collisions.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Configure a safe collision scenario for $t analysis.',
      targetDescription: 'Impact energy below threshold',
      hint: 'Lower speed or soften the crumple zone.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'momentum_collisions', kind: PhysicsSimulationKind.collision),
    equipmentFn: (String t) => <String>['Air track', 'Carts', 'Bumpers', 'Motion sensors', '$t scale'],
    experimentTitleFn: (String t) => 'Analyzing $t in Collisions',
    experimentStepsFn: (String t) => <String>[
      'Measure masses and initial velocities.',
      'Perform collision and record final velocities.',
      'Verify conservation of $t.',
      'Classify collision as elastic or inelastic.',
      'Compute energy lost in the collision.',
    ],
    dataTableFn: (String t) => '| Trial | v_before (m/s) | v_after (m/s) | $t (kg·m/s) |\n| --- | --- | --- | --- |\n| 1 |  |  |  |',
    calculationHintFn: (String t) => 'Total $t before = total $t after.',
    aiInsightFn: (String t) => '$t was conserved through the collision event.',
    challengeFn: (String t) => 'Design impact protection that preserves passenger safety.',
  );

  static final _KindBundle circuit = _KindBundle(
    kind: PhysicsSimulationKind.circuit,
    emoji: '⚡',
    labEmoji: '🔌',
    labIcon: Icons.electric_bolt_outlined,
    simulationTitleFn: (String t) => '$t Circuit Laboratory',
    descriptionFn: (String t, String _) => 'Build circuits and measure how $t behaves in real components.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Build a circuit where $t stays in the safe operating range.',
      targetDescription: 'Current within component ratings',
      hint: 'Apply Ohm\'s law: adjust R or V.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'electric_circuits', kind: PhysicsSimulationKind.circuit),
    equipmentFn: (String t) => <String>['Breadboard', 'Multimeter', 'Resistors', 'LEDs', 'Wires', '$t probe'],
    experimentTitleFn: (String t) => 'Measuring $t in a Circuit',
    experimentStepsFn: (String t) => <String>[
      'Wire the circuit on the breadboard.',
      'Measure voltage and current.',
      'Calculate $t from your readings.',
      'Compare to theoretical prediction.',
      'Adjust components and re-measure.',
    ],
    dataTableFn: (String t) => '| Voltage (V) | Current (mA) | $t |\n| --- | --- | --- |\n|  |  |  |\n|  |  |  |',
    calculationHintFn: (String t) => 'Use V = IR and power relations for $t.',
    aiInsightFn: (String t) => 'Measured $t matched Ohm\'s law predictions.',
    challengeFn: (String t) => 'Design a circuit that delivers stable $t under load changes.',
  );

  static final _KindBundle optics = _KindBundle(
    kind: PhysicsSimulationKind.optics,
    emoji: '🔭',
    labEmoji: '🔬',
    labIcon: Icons.filter_center_focus_outlined,
    simulationTitleFn: (String t) => '$t Optics Laboratory',
    descriptionFn: (String t, String _) => 'Design optical systems and study how $t affects images.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Align lenses to achieve clear imaging of $t.',
      targetDescription: 'Magnification within target range',
      hint: 'Focal length ratio sets magnification.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'optics', kind: PhysicsSimulationKind.optics),
    equipmentFn: (String t) => <String>['Lenses', 'Mirrors', 'Laser', 'Optical bench', 'Screen', '$t filter'],
    experimentTitleFn: (String t) => 'Imaging Experiment with $t',
    experimentStepsFn: (String t) => <String>[
      'Mount lenses on the optical bench.',
      'Focus the image on the screen.',
      'Measure focal lengths.',
      'Calculate magnification for $t.',
      'Record image quality and field of view.',
    ],
    dataTableFn: (_) => '| Lens | Focal length (cm) | Image distance (cm) |\n| --- | --- | --- |\n|  |  |  |',
    calculationHintFn: (String t) => 'Use lens equation and magnification for $t.',
    aiInsightFn: (String t) => 'Image properties followed the optics equations for $t.',
    challengeFn: (String t) => 'Design an optical instrument optimized for $t observation.',
  );

  static final _KindBundle rocket = _KindBundle(
    kind: PhysicsSimulationKind.rocket,
    emoji: '🚀',
    labEmoji: '🌌',
    labIcon: Icons.rocket_launch_outlined,
    simulationTitleFn: (String t) => '$t Aerospace Simulator',
    descriptionFn: (String t, String _) => 'Launch vehicles and study $t in space missions.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Reach target altitude while studying $t.',
      targetDescription: 'Apogee ≥ 50 km',
      hint: 'Balance fuel, thrust, and dry mass.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'astrophysics', kind: PhysicsSimulationKind.rocket),
    equipmentFn: (String t) => <String>['Rocket model', 'Thrust stand', 'Fuel tanks', 'Altimeter', '$t sensor'],
    experimentTitleFn: (String t) => 'Flight Test for $t',
    experimentStepsFn: (String t) => <String>[
      'Load fuel and set thrust parameters.',
      'Launch and record altitude vs time.',
      'Measure $t at key flight phases.',
      'Compare to mission profile.',
      'Analyze fuel consumption.',
    ],
    dataTableFn: (String t) => '| Time (s) | Altitude (km) | $t |\n| --- | --- | --- |\n|  |  |  |',
    calculationHintFn: (String t) => 'Use kinematics and energy for $t in flight.',
    aiInsightFn: (String t) => 'Flight data shows how $t evolved during ascent.',
    challengeFn: (String t) => 'Plan a mission trajectory that optimizes $t delivery.',
  );

  static final _KindBundle gravity = _KindBundle(
    kind: PhysicsSimulationKind.gravityPlanet,
    emoji: '🌍',
    labEmoji: '🪐',
    labIcon: Icons.public_outlined,
    simulationTitleFn: (String t) => '$t Gravity Laboratory',
    descriptionFn: (String t, String _) => 'Explore planetary gravity and how $t changes on different worlds.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Create a world where $t produces a 10 m jump height.',
      targetDescription: 'Jump height ≈ 10 m',
      hint: 'Surface gravity g = GM/R².',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'gravitation', kind: PhysicsSimulationKind.gravityPlanet),
    equipmentFn: (String t) => <String>['Planet simulator', 'Mass balance', 'Jump rig', 'Timer', '$t gauge'],
    experimentTitleFn: (String t) => 'Measuring $t on a Simulated Planet',
    experimentStepsFn: (String t) => <String>[
      'Set planet mass and radius.',
      'Measure surface gravity.',
      'Perform jump test and record height.',
      'Calculate expected $t from g.',
      'Compare simulation to calculation.',
    ],
    dataTableFn: (String t) => '| Planet setting | g (m/s²) | Jump height (m) | $t |\n| --- | --- | --- | --- |\n|  |  |  |  |',
    calculationHintFn: (String t) => 'g = GM/R²; relate $t to gravitational field.',
    aiInsightFn: (String t) => 'Jump height confirmed the gravitational model for $t.',
    challengeFn: (String t) => 'Design a habitat where $t conditions support human activity.',
  );

  static final _KindBundle wave = _KindBundle(
    kind: PhysicsSimulationKind.wave,
    emoji: '🌊',
    labEmoji: '🎵',
    labIcon: Icons.graphic_eq_outlined,
    simulationTitleFn: (String t) => '$t Wave Laboratory',
    descriptionFn: (String t, String _) => 'Tune frequencies and observe how $t propagates on strings and in media.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Lock a standing wave pattern for $t.',
      targetDescription: 'Wavelength ≈ 0.5 m',
      hint: 'v = fλ on a string.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'waves', kind: PhysicsSimulationKind.wave),
    equipmentFn: (String t) => <String>['String apparatus', 'Frequency generator', 'Tension scale', 'Ruler', '$t meter'],
    experimentTitleFn: (String t) => 'Standing Waves and $t',
    experimentStepsFn: (String t) => <String>[
      'Set string tension and length.',
      'Sweep frequency until resonance appears.',
      'Measure wavelength for $t.',
      'Compute wave speed v = fλ.',
      'Compare harmonics at higher modes.',
    ],
    dataTableFn: (String t) => '| Frequency (Hz) | Wavelength (m) | $t |\n| --- | --- | --- |\n|  |  |  |',
    calculationHintFn: (String t) => 'v = fλ; relate harmonics to $t.',
    aiInsightFn: (String t) => 'Resonance occurred when wavelength matched $t predictions.',
    challengeFn: (String t) => 'Tune an instrument string to the correct $t pitch.',
  );

  static final _KindBundle projectile = _KindBundle(
    kind: PhysicsSimulationKind.projectile,
    emoji: '🎯',
    labEmoji: '🎯',
    labIcon: Icons.sports_baseball_outlined,
    simulationTitleFn: (String t) => '$t Launch Laboratory',
    descriptionFn: (String t, String _) => 'Launch objects and analyze trajectories involving $t.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Hit a 500 m target using $t principles.',
      targetDescription: 'Range ≈ 500 m',
      hint: 'Range = v²sin(2θ)/g.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'kinematics', kind: PhysicsSimulationKind.projectile),
    equipmentFn: (String t) => <String>['Launch ramp', 'Protractor', 'Range finder', 'Timer', '$t marker'],
    experimentTitleFn: (String t) => 'Trajectory Study of $t',
    experimentStepsFn: (String t) => <String>[
      'Set launch angle and speed.',
      'Measure horizontal range.',
      'Compare to theoretical $t prediction.',
      'Vary angle and plot range vs θ.',
      'Enable drag and note changes.',
    ],
    dataTableFn: (String t) => '| Angle (°) | Range (m) | $t prediction |\n| --- | --- | --- |\n|  |  |  |',
    calculationHintFn: (String t) => 'R = v²sin(2θ)/g; connect to $t.',
    aiInsightFn: (String t) => 'Measured range matched $t trajectory theory.',
    challengeFn: (String t) => 'Hit a moving target using $t ballistics.',
  );

  static final _KindBundle generic = _KindBundle(
    kind: PhysicsSimulationKind.generic,
    emoji: '🧪',
    labEmoji: '🔬',
    labIcon: Icons.science_outlined,
    simulationTitleFn: (String t) => '$t Research Laboratory',
    descriptionFn: (String t, String c) =>
        'Run controlled experiments on $t within $c — predict, measure, and analyze.',
    missionFn: (String t) => PhysicsLabMission(
      prompt: 'Find settings where the measured $t response doubles.',
      targetDescription: 'Response ≥ 2× baseline',
      hint: 'Change one variable at a time and predict before launching.',
    ),
    controlsFn: (_) => PhysicsLabEngine.controlsFor(courseId: 'generic', kind: PhysicsSimulationKind.generic),
    equipmentFn: (String t) => <String>['Measurement sensors', 'Data logger', 'Calibration kit', 'Timer', '$t apparatus'],
    experimentTitleFn: (String t) => 'Quantitative Study of $t',
    experimentStepsFn: (String t) => <String>[
      'State the measurable quantity for $t.',
      'Set initial experimental conditions.',
      'Collect at least three data trials.',
      'Plot results and identify the trend.',
      'Compare data to the theoretical model for $t.',
    ],
    dataTableFn: (String t) => '| Trial | Measurement | Units | $t computed |\n| --- | --- | --- | --- |\n| 1 |  |  |  |\n| 2 |  |  |  |',
    calculationHintFn: (String t) => 'Show formula, substitution, and final $t value with units.',
    aiInsightFn: (String t) => 'Your data reveals how $t behaves under controlled conditions.',
    challengeFn: (String t) => 'Engineering challenge: apply $t to a real-world design problem.',
  );
}
