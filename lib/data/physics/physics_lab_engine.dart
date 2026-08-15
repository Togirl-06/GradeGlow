import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/physics/physics_lab_models.dart';

/// Slider specs and educational physics outcomes for Virtual University labs.
class PhysicsControlSpec {
  const PhysicsControlSpec({
    required this.id,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.initial,
    this.step = 1,
  });

  final String id;
  final String label;
  final String unit;
  final double min;
  final double max;
  final double initial;
  final double step;
}

class PhysicsMetric {
  const PhysicsMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  String get display {
    if (value.abs() >= 1000) return value.toStringAsFixed(0);
    if (value.abs() >= 100) return value.toStringAsFixed(1);
    if (value.abs() >= 10) return value.toStringAsFixed(2);
    return value.toStringAsFixed(3);
  }
}

enum PhysicsStatusLevel { good, caution, danger }

class PhysicsLabSnapshot {
  const PhysicsLabSnapshot({
    required this.metrics,
    required this.status,
    required this.statusLevel,
    required this.plainEnglish,
    required this.coachTip,
    required this.whatToTry,
    this.graphs = const <PhysicsGraphSeries>[],
    this.trajectory = const <Offset2D>[],
    this.missionResult,
    this.instructorNote,
  });

  final List<PhysicsMetric> metrics;
  final String status;
  final PhysicsStatusLevel statusLevel;
  final String plainEnglish;
  final String coachTip;
  final String whatToTry;
  final List<PhysicsGraphSeries> graphs;
  final List<Offset2D> trajectory;
  final PhysicsMissionResult? missionResult;
  final String? instructorNote;
}

/// Simple 2D point for painting trajectories.
class Offset2D {
  const Offset2D(this.x, this.y);
  final double x;
  final double y;
}

class PhysicsLabEngine {
  PhysicsLabEngine._();

  static const double _earthG = 9.81;

  static PhysicsSimulationKind simulationKind({
    required String courseId,
    required String topicTitle,
  }) {
    final String t = topicTitle.toLowerCase();
    if (courseId == 'gravitation' || t.contains('orbit') || t.contains('planet')) {
      return PhysicsSimulationKind.gravityPlanet;
    }
    if (t.contains('collision') || t.contains('momentum') || t.contains('crash')) {
      return PhysicsSimulationKind.collision;
    }
    if (_circuitCourses.contains(courseId)) return PhysicsSimulationKind.circuit;
    if (courseId == 'optics' || t.contains('lens') || t.contains('mirror')) {
      return PhysicsSimulationKind.optics;
    }
    if (courseId.contains('astro') ||
        courseId.contains('space') ||
        t.contains('rocket') ||
        t.contains('satellite')) {
      return PhysicsSimulationKind.rocket;
    }
    if (_waveCourses.contains(courseId)) return PhysicsSimulationKind.wave;
    if (_mechanicsCourses.contains(courseId)) {
      if (t.contains('projectile') || t.contains('launch') || courseId == 'kinematics') {
        return PhysicsSimulationKind.projectile;
      }
      return PhysicsSimulationKind.projectile;
    }
    return PhysicsSimulationKind.generic;
  }

  static PhysicsLabMission missionFor({
    required PhysicsSimulationKind kind,
    required String topicTitle,
  }) {
    return switch (kind) {
      PhysicsSimulationKind.motionTracking => PhysicsLabMission(
          prompt: 'Set distance and time to achieve a target velocity for $topicTitle.',
          targetDescription: 'Velocity within ±10% of target',
          hint: 'Velocity = distance ÷ time.',
        ),
      PhysicsSimulationKind.acceleration => PhysicsLabMission(
          prompt: 'Accelerate from rest to 20 m/s in under 4 seconds.',
          targetDescription: 'Final speed ≥ 20 m/s',
          hint: 'Acceleration a = Δv/Δt. Increase engine power or reduce mass.',
        ),
      PhysicsSimulationKind.forceThrust => PhysicsLabMission(
          prompt: 'Achieve 5 m/s² acceleration with your thrust configuration.',
          targetDescription: 'Acceleration ≈ 5 m/s²',
          hint: 'F = ma. Increase thrust or reduce mass.',
        ),
      PhysicsSimulationKind.energyCoaster => PhysicsLabMission(
          prompt: 'Design a coaster that reaches 25 m/s at the bottom of a 40 m drop.',
          targetDescription: 'Bottom speed ≈ 25 m/s',
          hint: 'Energy conservation: ½mv² ≈ mgh.',
        ),
      PhysicsSimulationKind.projectile => const PhysicsLabMission(
          prompt: 'Design a rocket shot that lands 500 meters away.',
          targetDescription: 'Range ≈ 500 m (±40 m)',
          hint: 'On level ground with no drag, 45° often maximizes range. Tune velocity and angle.',
        ),
      PhysicsSimulationKind.gravityPlanet => const PhysicsLabMission(
          prompt: 'Create a planet where a human can jump 10 meters high.',
          targetDescription: 'Jump height ≈ 10 m',
          hint: 'Lower surface gravity increases jump height. Try smaller planet mass or larger radius.',
        ),
      PhysicsSimulationKind.collision => const PhysicsLabMission(
          prompt: 'Design a vehicle that survives a crash at 20 m/s.',
          targetDescription: 'Impact energy below safe threshold',
          hint: 'Increase mass ratio, lower closing speed, or increase crumple zone (lower stiffness).',
        ),
      PhysicsSimulationKind.circuit => const PhysicsLabMission(
          prompt: 'Light the LED without burning the resistor.',
          targetDescription: 'Current between 5 mA and 25 mA',
          hint: 'Use Ohm\'s law: raise resistance or lower voltage if current is too high.',
        ),
      PhysicsSimulationKind.optics => const PhysicsLabMission(
          prompt: 'Build a telescope that magnifies a distant star 5×.',
          targetDescription: 'Angular magnification ≈ 5',
          hint: 'Magnification ≈ focal length of objective / focal length of eyepiece.',
        ),
      PhysicsSimulationKind.rocket => const PhysicsLabMission(
          prompt: 'Reach 50 km altitude with stable flight.',
          targetDescription: 'Apogee ≥ 50 km, stability OK',
          hint: 'Balance fuel, thrust, and dry mass. Too little fuel — short burn; too heavy — low altitude.',
        ),
      PhysicsSimulationKind.wave => const PhysicsLabMission(
          prompt: 'Tune a standing wave with wavelength 0.5 m.',
          targetDescription: 'λ ≈ 0.5 m',
          hint: 'On a string, adjust tension and frequency: v = fλ.',
        ),
      PhysicsSimulationKind.generic => PhysicsLabMission(
          prompt: 'Find control settings that double the measured response.',
          targetDescription: 'Response ≥ 2× baseline',
          hint: 'Change one variable at a time and predict before launching.',
        ),
    };
  }

  static List<PhysicsLabRoom> labRoomsFor(String courseId) {
    return <PhysicsLabRoom>[
      const PhysicsLabRoom(
        id: 'mechanics',
        name: 'Mechanics Lab',
        emoji: '🧪',
        description: 'Motion tracks, pendulums, springs, and force sensors.',
        equipment: <String>[
          'Motion track',
          'Pendulum kit',
          'Spring set',
          'Force sensors',
          'Mass blocks',
          'High-speed camera',
        ],
        experimentTitle: 'Measure gravity using a pendulum',
        experimentSteps: <String>[
          'Build a simple pendulum and measure string length L.',
          'Release from small angle and time 10 full periods.',
          'Compute period T = (total time) / 10.',
          'Calculate g = 4π²L / T² and compare to 9.8 m/s².',
        ],
        icon: Icons.precision_manufacturing_outlined,
      ),
      const PhysicsLabRoom(
        id: 'electricity',
        name: 'Electricity Lab',
        emoji: '⚡',
        description: 'Circuit boards, multimeters, and power supplies.',
        equipment: <String>[
          'Breadboard',
          'Multimeter',
          'Oscilloscope',
          'DC power supply',
          'Resistors',
          'LEDs',
        ],
        experimentTitle: 'Build and test a series circuit',
        experimentSteps: <String>[
          'Place battery, resistor, and LED in series.',
          'Measure voltage across the resistor.',
          'Measure current with the multimeter in series.',
          'Verify V = IR and check the LED is within safe current.',
        ],
        icon: Icons.electric_bolt_outlined,
      ),
      const PhysicsLabRoom(
        id: 'optics',
        name: 'Optics Lab',
        emoji: '🔭',
        description: 'Lasers, lenses, mirrors, and screens.',
        equipment: <String>['Laser', 'Convex lens', 'Concave mirror', 'Optical bench', 'Screen'],
        experimentTitle: 'Construct a simple telescope',
        experimentSteps: <String>[
          'Mount objective lens and eyepiece on the bench.',
          'Focus a distant object onto a screen.',
          'Measure focal lengths and estimate magnification.',
          'Record image clarity and field of view.',
        ],
        icon: Icons.filter_center_focus_outlined,
      ),
      const PhysicsLabRoom(
        id: 'thermal',
        name: 'Thermal Lab',
        emoji: '🌡',
        description: 'Heat chambers, thermometers, and material samples.',
        equipment: <String>['Heat chamber', 'Thermometer', 'Insulation samples', 'Timer', 'Balance'],
        experimentTitle: 'Find the best thermal insulator',
        experimentSteps: <String>[
          'Wrap identical hot water cups with different materials.',
          'Record temperature every 2 minutes for 20 minutes.',
          'Plot temperature vs time for each material.',
          'Identify the slowest cooling curve — best insulator.',
        ],
        icon: Icons.thermostat_outlined,
      ),
      const PhysicsLabRoom(
        id: 'aerospace',
        name: 'Aerospace Lab',
        emoji: '🚀',
        description: 'Wind tunnel, rocket rig, and flight computer.',
        equipment: <String>['Wind tunnel', 'Model wing', 'Rocket simulator', 'Thrust stand', 'Flight computer'],
        experimentTitle: 'Improve wing lift at cruise speed',
        experimentSteps: <String>[
          'Mount wing model in the wind tunnel.',
          'Set airspeed and measure lift and drag.',
          'Adjust angle of attack and note stall point.',
          'Compute lift-to-drag ratio for best cruise setting.',
        ],
        icon: Icons.rocket_launch_outlined,
      ),
      const PhysicsLabRoom(
        id: 'nuclear',
        name: 'Nuclear Lab',
        emoji: '⚛',
        description: 'Geiger counter, shielding, and safe sources.',
        equipment: <String>['Geiger counter', 'Shielding sheets', 'Radioactive source (sim)', 'Timer', 'Safety gear'],
        experimentTitle: 'Measure radiation attenuation',
        experimentSteps: <String>[
          'Record baseline count rate with no shielding.',
          'Add aluminum sheets one at a time.',
          'Plot count rate vs shield thickness.',
          'Estimate half-value layer from your data.',
        ],
        icon: Icons.science_outlined,
      ),
      const PhysicsLabRoom(
        id: 'astronomy',
        name: 'Astronomy Lab',
        emoji: '🌌',
        description: 'Telescope mount, spectrometer, and star charts.',
        equipment: <String>['Telescope', 'Spectrometer', 'CCD camera', 'Star chart', 'Filter wheel'],
        experimentTitle: 'Classify a stellar spectrum',
        experimentSteps: <String>[
          'Point telescope at a calibration star.',
          'Capture spectrum with the spectrometer.',
          'Identify absorption lines (H, Ca, Na).',
          'Estimate spectral class from line pattern.',
        ],
        icon: Icons.nightlight_round_outlined,
      ),
    ];
  }

  static PhysicsLabRoom defaultRoomFor(String courseId) {
    final List<PhysicsLabRoom> rooms = labRoomsFor(courseId);
    if (_circuitCourses.contains(courseId)) return rooms[1];
    if (_waveCourses.contains(courseId) && courseId == 'optics') return rooms[2];
    if (courseId.contains('thermo') || courseId.contains('statistical')) return rooms[3];
    if (courseId.contains('astro') || courseId.contains('space')) return rooms[6];
    if (courseId.contains('nuclear') || courseId.contains('particle')) return rooms[5];
    if (courseId.contains('fluid') || courseId.contains('engineering')) return rooms[4];
    return rooms.first;
  }

  static PhysicsLabDifficulty difficultyFor(String levelLabel) {
    return switch (levelLabel.toLowerCase()) {
      'foundations' => PhysicsLabDifficulty.beginner,
      'graduate' || 'research' => PhysicsLabDifficulty.advanced,
      _ => PhysicsLabDifficulty.intermediate,
    };
  }

  static List<PhysicsControlSpec> controlsFor({
    required String courseId,
    required PhysicsSimulationKind kind,
  }) {
    return switch (kind) {
      PhysicsSimulationKind.motionTracking => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'distance', label: 'Distance', unit: 'm', min: 10, max: 500, initial: 100),
          PhysicsControlSpec(id: 'time', label: 'Time', unit: 's', min: 1, max: 60, initial: 10),
          PhysicsControlSpec(id: 'direction', label: 'Direction', unit: '°', min: 0, max: 360, initial: 90),
          PhysicsControlSpec(id: 'object_mass', label: 'Object mass', unit: 'kg', min: 0.5, max: 2000, initial: 500, step: 50),
        ],
      PhysicsSimulationKind.acceleration => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'engine_power', label: 'Engine power', unit: 'kW', min: 50, max: 500, initial: 200, step: 10),
          PhysicsControlSpec(id: 'vehicle_mass', label: 'Vehicle mass', unit: 'kg', min: 800, max: 3000, initial: 1400, step: 50),
          PhysicsControlSpec(id: 'road_friction', label: 'Road friction', unit: '×', min: 0.1, max: 1, initial: 0.3, step: 0.05),
          PhysicsControlSpec(id: 'test_duration', label: 'Test duration', unit: 's', min: 1, max: 10, initial: 4),
        ],
      PhysicsSimulationKind.forceThrust => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'rocket_mass', label: 'System mass', unit: 'kg', min: 500, max: 5000, initial: 2000, step: 100),
          PhysicsControlSpec(id: 'engine_force', label: 'Applied force', unit: 'kN', min: 5, max: 80, initial: 25, step: 1),
          PhysicsControlSpec(id: 'fuel_mass', label: 'Fuel mass', unit: 'kg', min: 0, max: 1000, initial: 300, step: 50),
          PhysicsControlSpec(id: 'burn_time', label: 'Burn time', unit: 's', min: 1, max: 30, initial: 10),
        ],
      PhysicsSimulationKind.energyCoaster => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'track_height', label: 'Track height', unit: 'm', min: 5, max: 80, initial: 30),
          PhysicsControlSpec(id: 'cart_mass', label: 'Cart mass', unit: 'kg', min: 200, max: 800, initial: 400, step: 50),
          PhysicsControlSpec(id: 'friction', label: 'Friction', unit: '×', min: 0, max: 0.5, initial: 0.05, step: 0.01),
          PhysicsControlSpec(id: 'loop_radius', label: 'Loop radius', unit: 'm', min: 0, max: 20, initial: 0),
        ],
      PhysicsSimulationKind.projectile => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'velocity', label: 'Velocity', unit: 'm/s', min: 5, max: 80, initial: 50),
          PhysicsControlSpec(id: 'angle', label: 'Launch angle', unit: '°', min: 5, max: 85, initial: 45),
          PhysicsControlSpec(id: 'gravity', label: 'Gravity', unit: 'm/s²', min: 1.6, max: 20, initial: 9.81, step: 0.1),
          PhysicsControlSpec(id: 'mass', label: 'Mass', unit: 'kg', min: 0.5, max: 20, initial: 2, step: 0.5),
          PhysicsControlSpec(id: 'drag', label: 'Air resistance', unit: '×', min: 0, max: 1, initial: 0, step: 0.05),
        ],
      PhysicsSimulationKind.gravityPlanet => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'planet_mass', label: 'Planet mass', unit: '× Earth', min: 0.1, max: 5, initial: 1, step: 0.1),
          PhysicsControlSpec(id: 'planet_radius', label: 'Planet radius', unit: '× Earth', min: 0.3, max: 3, initial: 1, step: 0.05),
          PhysicsControlSpec(id: 'jump_speed', label: 'Jump speed', unit: 'm/s', min: 1, max: 12, initial: 3.2, step: 0.1),
        ],
      PhysicsSimulationKind.collision => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'mass_a', label: 'Vehicle mass', unit: 'kg', min: 500, max: 3000, initial: 1200, step: 50),
          PhysicsControlSpec(id: 'mass_b', label: 'Barrier mass', unit: 'kg', min: 500, max: 8000, initial: 2000, step: 50),
          PhysicsControlSpec(id: 'speed', label: 'Impact speed', unit: 'm/s', min: 5, max: 35, initial: 20),
          PhysicsControlSpec(id: 'stiffness', label: 'Crumple stiffness', unit: '×', min: 0.2, max: 2, initial: 1, step: 0.1),
        ],
      PhysicsSimulationKind.circuit => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'voltage', label: 'Battery', unit: 'V', min: 1.5, max: 12, initial: 9),
          PhysicsControlSpec(id: 'resistance', label: 'Resistor', unit: 'Ω', min: 50, max: 2000, initial: 330),
          PhysicsControlSpec(id: 'led_rating', label: 'LED rating', unit: 'mA', min: 5, max: 30, initial: 20),
        ],
      PhysicsSimulationKind.optics => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'f_objective', label: 'Objective focal length', unit: 'cm', min: 10, max: 100, initial: 50),
          PhysicsControlSpec(id: 'f_eyepiece', label: 'Eyepiece focal length', unit: 'cm', min: 2, max: 25, initial: 10),
          PhysicsControlSpec(id: 'object_distance', label: 'Object distance', unit: 'm', min: 10, max: 1000, initial: 100),
        ],
      PhysicsSimulationKind.rocket => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'fuel', label: 'Fuel mass', unit: 'kg', min: 50, max: 500, initial: 200, step: 10),
          PhysicsControlSpec(id: 'thrust', label: 'Engine thrust', unit: 'kN', min: 50, max: 400, initial: 150, step: 10),
          PhysicsControlSpec(id: 'dry_mass', label: 'Dry mass', unit: 'kg', min: 80, max: 400, initial: 150, step: 10),
          PhysicsControlSpec(id: 'drag_coef', label: 'Drag coefficient', unit: '×', min: 0.2, max: 1.5, initial: 0.5, step: 0.05),
        ],
      PhysicsSimulationKind.wave => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'frequency', label: 'Frequency', unit: 'Hz', min: 20, max: 2000, initial: 440),
          PhysicsControlSpec(id: 'tension', label: 'String tension', unit: 'N', min: 10, max: 200, initial: 80),
          PhysicsControlSpec(id: 'length', label: 'String length', unit: 'm', min: 0.3, max: 3, initial: 1.2, step: 0.1),
        ],
      PhysicsSimulationKind.generic => const <PhysicsControlSpec>[
          PhysicsControlSpec(id: 'param_a', label: 'Control A', unit: '', min: 0, max: 10, initial: 5, step: 0.5),
          PhysicsControlSpec(id: 'param_b', label: 'Control B', unit: '', min: 0, max: 10, initial: 3, step: 0.5),
        ],
    };
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

  static PhysicsLabSnapshot evaluate({
    required String courseId,
    required String topicTitle,
    required Map<String, double> values,
    PhysicsSimulationKind? kind,
    PhysicsLabMission? mission,
  }) {
    final PhysicsSimulationKind k = kind ?? simulationKind(courseId: courseId, topicTitle: topicTitle);
    final PhysicsLabMission m = mission ?? missionFor(kind: k, topicTitle: topicTitle);
    return switch (k) {
      PhysicsSimulationKind.motionTracking => _motionTracking(values, topicTitle, m),
      PhysicsSimulationKind.acceleration => _acceleration(values, topicTitle, m),
      PhysicsSimulationKind.forceThrust => _forceThrust(values, topicTitle, m),
      PhysicsSimulationKind.energyCoaster => _energyCoaster(values, topicTitle, m),
      PhysicsSimulationKind.projectile => _projectile(values, topicTitle, m),
      PhysicsSimulationKind.gravityPlanet => _gravityPlanet(values, topicTitle, m),
      PhysicsSimulationKind.collision => _collision(values, topicTitle, m),
      PhysicsSimulationKind.circuit => _circuit(values, topicTitle, m),
      PhysicsSimulationKind.optics => _optics(values, topicTitle, m),
      PhysicsSimulationKind.rocket => _rocket(values, topicTitle, m),
      PhysicsSimulationKind.wave => _wave(values, topicTitle, m),
      PhysicsSimulationKind.generic => _generic(values, topicTitle, m),
    };
  }

  static double _v(Map<String, double> m, String k, [double d = 0]) => m[k] ?? d;

  static String _directionLabel(double degrees) {
    final double d = degrees % 360;
    if (d >= 45 && d < 135) return 'east';
    if (d >= 135 && d < 225) return 'south';
    if (d >= 225 && d < 315) return 'west';
    return 'north';
  }

  static PhysicsLabSnapshot _motionTracking(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double distance = _v(v, 'distance', 100);
    final double time = _v(v, 'time', 10).clamp(0.1, 1000);
    final double directionDeg = _v(v, 'direction', 90);
    final double mass = _v(v, 'object_mass', 500);
    final double velocity = distance / time;
    final String dir = _directionLabel(directionDeg);

    final List<PhysicsGraphPoint> posPts = <PhysicsGraphPoint>[];
    final List<Offset2D> traj = <Offset2D>[];
    for (int i = 0; i <= 20; i++) {
      final double t = time * i / 20;
      final double x = velocity * t;
      posPts.add(PhysicsGraphPoint(t: t, y: x));
      traj.add(Offset2D(x / distance.clamp(1, 10000), 0.5));
    }

    final bool missionOk = (velocity - 10).abs() <= 0.8;
    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Velocity', value: velocity, unit: 'm/s'),
        PhysicsMetric(label: 'Distance', value: distance, unit: 'm'),
        PhysicsMetric(label: 'Time', value: time, unit: 's'),
        PhysicsMetric(label: 'Direction', value: directionDeg, unit: '°'),
        PhysicsMetric(label: 'Mass', value: mass, unit: 'kg'),
      ],
      status: missionOk ? 'CONSTANT VELOCITY' : 'ADJUST DISTANCE/TIME',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish:
          '$topic: ${velocity.toStringAsFixed(1)} m/s $dir over ${distance.toStringAsFixed(0)} m in ${time.toStringAsFixed(1)} s.',
      coachTip: missionOk
          ? 'Your object moved at constant velocity — slope of position vs time is steady.'
          : 'Velocity = distance ÷ time. Try 100 m in 10 s for 10 m/s.',
      whatToTry: 'Change direction and confirm speed stays the same.',
      graphs: <PhysicsGraphSeries>[
        PhysicsGraphSeries(label: 'Position vs Time', xLabel: 't (s)', yLabel: 'x (m)', points: posPts),
      ],
      trajectory: traj,
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 95 : (80 - (velocity - 10).abs() * 5).clamp(30, 85).round(),
        feedback: missionOk
            ? 'Velocity ≈ ${velocity.toStringAsFixed(1)} m/s $dir — motion sensor data matches prediction.'
            : 'Current velocity is ${velocity.toStringAsFixed(1)} m/s — adjust distance or time toward 10 m/s.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _acceleration(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double power = _v(v, 'engine_power', 200) * 1000;
    final double mass = _v(v, 'vehicle_mass', 1400);
    final double friction = _v(v, 'road_friction', 0.3);
    final double duration = _v(v, 'test_duration', 4).clamp(0.5, 30);
    final double force = power / 25;
    final double netForce = force - mass * _earthG * friction * 0.02;
    final double accel = netForce / mass;
    final double finalSpeed = accel * duration;

    final List<PhysicsGraphPoint> velPts = <PhysicsGraphPoint>[];
    for (int i = 0; i <= 20; i++) {
      final double t = duration * i / 20;
      velPts.add(PhysicsGraphPoint(t: t, y: accel * t));
    }

    final bool missionOk = finalSpeed >= 20 && duration <= 4.5;
    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Acceleration', value: accel, unit: 'm/s²'),
        PhysicsMetric(label: 'Final speed', value: finalSpeed, unit: 'm/s'),
        PhysicsMetric(label: 'Engine power', value: power / 1000, unit: 'kW'),
        PhysicsMetric(label: 'Vehicle mass', value: mass, unit: 'kg'),
      ],
      status: missionOk ? 'TARGET SPEED REACHED' : 'TUNE ENGINE',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish:
          '$topic: a ≈ ${accel.toStringAsFixed(2)} m/s² → ${finalSpeed.toStringAsFixed(1)} m/s after ${duration.toStringAsFixed(1)} s.',
      coachTip: 'Lower mass or raise engine power to increase acceleration.',
      whatToTry: 'Increase friction and observe how acceleration drops.',
      graphs: <PhysicsGraphSeries>[
        PhysicsGraphSeries(label: 'Velocity vs Time', xLabel: 't (s)', yLabel: 'v (m/s)', points: velPts),
      ],
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 93 : (60 + finalSpeed).clamp(35, 80).round(),
        feedback: missionOk
            ? 'Reached ${finalSpeed.toStringAsFixed(1)} m/s — acceleration test passed.'
            : 'Final speed ${finalSpeed.toStringAsFixed(1)} m/s — add power or reduce mass.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _forceThrust(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double mass = _v(v, 'rocket_mass', 2000) + _v(v, 'fuel_mass', 300);
    final double force = _v(v, 'engine_force', 25) * 1000;
    final double burn = _v(v, 'burn_time', 10);
    final double accel = force / mass;
    final double deltaV = accel * burn;
    final bool missionOk = (accel - 5).abs() <= 0.6;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Acceleration', value: accel, unit: 'm/s²'),
        PhysicsMetric(label: 'Net force', value: force / 1000, unit: 'kN'),
        PhysicsMetric(label: 'Total mass', value: mass, unit: 'kg'),
        PhysicsMetric(label: 'Δv', value: deltaV, unit: 'm/s'),
      ],
      status: missionOk ? 'F = ma CONFIRMED' : 'ADJUST THRUST',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish: '$topic: F = ma → a ≈ ${accel.toStringAsFixed(2)} m/s² with ${(force / 1000).toStringAsFixed(1)} kN thrust.',
      coachTip: 'Newton\'s second law: doubling force doubles acceleration for fixed mass.',
      whatToTry: 'Burn fuel (reduce mass) mid-thrust and watch acceleration rise.',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 94 : 58,
        feedback: missionOk
            ? 'Acceleration ≈ ${accel.toStringAsFixed(1)} m/s² — thruster test successful.'
            : 'Acceleration ${accel.toStringAsFixed(2)} m/s² — adjust force or mass toward 5 m/s².',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _energyCoaster(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double height = _v(v, 'track_height', 30);
    final double mass = _v(v, 'cart_mass', 400);
    final double friction = _v(v, 'friction', 0.05);
    final double loopR = _v(v, 'loop_radius', 0);
    final double pe = mass * _earthG * height;
    final double speed = math.sqrt(2 * _earthG * height * (1 - friction * 2)).clamp(0, 80);
    final double ke = 0.5 * mass * speed * speed;
    final bool missionOk = (speed - 25).abs() <= 3 && height >= 35;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Potential energy', value: pe / 1000, unit: 'kJ'),
        PhysicsMetric(label: 'Kinetic energy', value: ke / 1000, unit: 'kJ'),
        PhysicsMetric(label: 'Bottom speed', value: speed, unit: 'm/s'),
        PhysicsMetric(label: 'Track height', value: height, unit: 'm'),
      ],
      status: missionOk ? 'ENERGY CONSERVED' : 'REDESIGN TRACK',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish:
          '$topic: ${height.toStringAsFixed(0)} m drop → ${speed.toStringAsFixed(1)} m/s at bottom (PE → KE).',
      coachTip: 'Higher track height increases bottom speed: v ≈ √(2gh) with small friction losses.',
      whatToTry: loopR > 0 ? 'Check if speed is enough for a loop of radius $loopR m.' : 'Add a loop and check minimum speed.',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 92 : 55,
        feedback: missionOk
            ? 'Bottom speed ${speed.toStringAsFixed(1)} m/s — energy transformation verified.'
            : 'Speed ${speed.toStringAsFixed(1)} m/s — raise height toward 40 m for ~25 m/s.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _projectile(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double vel = _v(v, 'velocity', 50);
    final double angleDeg = _v(v, 'angle', 45);
    final double g = _v(v, 'gravity', _earthG);
    final double mass = _v(v, 'mass', 2);
    final double dragFactor = _v(v, 'drag', 0);
    final double angle = angleDeg * math.pi / 180;
    final double range = vel * vel * math.sin(2 * angle) / g * (1 - dragFactor * 0.35);
    final double maxHeight = vel * vel * math.sin(angle) * math.sin(angle) / (2 * g);
    final double flightTime = 2 * vel * math.sin(angle) / g;

    final List<PhysicsGraphPoint> heightPts = <PhysicsGraphPoint>[];
    final List<PhysicsGraphPoint> velPts = <PhysicsGraphPoint>[];
    final List<Offset2D> traj = <Offset2D>[];
    final int steps = 40;
    for (int i = 0; i <= steps; i++) {
      final double t = flightTime * i / steps;
      final double y = vel * math.sin(angle) * t - 0.5 * g * t * t;
      final double vy = vel * math.sin(angle) - g * t;
      final double x = vel * math.cos(angle) * t;
      if (y >= 0) {
        heightPts.add(PhysicsGraphPoint(t: t, y: y, vy: vy));
        velPts.add(PhysicsGraphPoint(t: t, y: vy));
        traj.add(Offset2D(x, y));
      }
    }

    final bool missionOk = (range - 500).abs() <= 40;
    final PhysicsStatusLevel level = missionOk
        ? PhysicsStatusLevel.good
        : range > 20
            ? PhysicsStatusLevel.caution
            : PhysicsStatusLevel.danger;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Distance', value: range, unit: 'm'),
        PhysicsMetric(label: 'Maximum height', value: maxHeight, unit: 'm'),
        PhysicsMetric(label: 'Flight time', value: flightTime, unit: 's'),
        PhysicsMetric(label: 'Initial KE', value: 0.5 * mass * vel * vel, unit: 'J'),
      ],
      status: missionOk ? 'MISSION SUCCESS' : 'ADJUST PARAMETERS',
      statusLevel: level,
      plainEnglish:
          '$topic: at ${vel.toStringAsFixed(0)} m/s and ${angleDeg.toStringAsFixed(0)}°, range ≈ ${range.toStringAsFixed(0)} m.',
      coachTip: missionOk
          ? 'Excellent — you hit the 500 m target. Now try with air resistance enabled.'
          : 'Your angle was ${angleDeg < 40 ? 'too low' : angleDeg > 55 ? 'too high for this speed' : 'reasonable'} — tune velocity and angle together.',
      whatToTry: 'Enable drag and find the new optimal angle.',
      graphs: <PhysicsGraphSeries>[
        PhysicsGraphSeries(label: 'Height vs Time', xLabel: 't (s)', yLabel: 'h (m)', points: heightPts),
        PhysicsGraphSeries(label: 'Velocity vs Time', xLabel: 't (s)', yLabel: 'v_y (m/s)', points: velPts),
      ],
      trajectory: traj,
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 95 : (40 - (range - 500).abs() / 10).clamp(20, 85).round(),
        feedback: missionOk
            ? 'Target acquired at ${range.toStringAsFixed(0)} m. NASA would call this a good launch window.'
            : 'Range is ${range.toStringAsFixed(0)} m — ${range < 500 ? 'increase angle or velocity' : 'decrease angle or velocity'} to approach 500 m.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _gravityPlanet(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double massFactor = _v(v, 'planet_mass', 1);
    final double radiusFactor = _v(v, 'planet_radius', 1);
    final double jumpV = _v(v, 'jump_speed', 3.2);
    final double g = _earthG * massFactor / (radiusFactor * radiusFactor);
    final double jumpHeight = jumpV * jumpV / (2 * g);
    final bool missionOk = (jumpHeight - 10).abs() <= 1.5;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Surface gravity', value: g, unit: 'm/s²'),
        PhysicsMetric(label: 'Jump height', value: jumpHeight, unit: 'm'),
        PhysicsMetric(label: 'Escape speed', value: math.sqrt(2 * g * 6371000 * radiusFactor) / 1000, unit: 'km/s'),
      ],
      status: missionOk ? 'HABITABLE JUMP ZONE' : 'TUNE PLANET',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish: 'On this world, g ≈ ${g.toStringAsFixed(2)} m/s² — you jump ${jumpHeight.toStringAsFixed(1)} m.',
      coachTip: 'Gravity scales with M/R². Shrinking the planet lowers g dramatically.',
      whatToTry: 'Halve planet mass and observe jump height.',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 92 : 60,
        feedback: missionOk
            ? 'Astronauts could train here — jump height ≈ 10 m.'
            : 'Jump height is ${jumpHeight.toStringAsFixed(1)} m. Adjust mass and radius toward g ≈ ${(jumpV * jumpV / 20).toStringAsFixed(2)} m/s².',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _collision(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double m1 = _v(v, 'mass_a', 1200);
    final double m2 = _v(v, 'mass_b', 2000);
    final double speed = _v(v, 'speed', 20);
    final double stiffness = _v(v, 'stiffness', 1);
    final double ke = 0.5 * m1 * speed * speed;
    final double damage = ke / (m2 * stiffness);
    final bool survived = damage < 120;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Impact energy', value: ke / 1000, unit: 'kJ'),
        PhysicsMetric(label: 'Damage index', value: damage, unit: ''),
        PhysicsMetric(label: 'Closing speed', value: speed, unit: 'm/s'),
      ],
      status: survived ? 'VEHICLE SURVIVED' : 'STRUCTURAL FAILURE',
      statusLevel: survived ? PhysicsStatusLevel.good : PhysicsStatusLevel.danger,
      plainEnglish: '$topic crash at ${speed.toStringAsFixed(0)} m/s — damage index ${damage.toStringAsFixed(0)}.',
      coachTip: 'Lower speed or add crumple zone (reduce stiffness) to absorb energy.',
      whatToTry: 'Double barrier mass — what happens to damage index?',
      missionResult: PhysicsMissionResult(
        passed: survived,
        scorePercent: survived ? 90 : 35,
        feedback: survived
            ? 'Crash energy absorbed — occupants likely safe with proper restraints.'
            : 'Too much impact energy — reduce speed below ${math.sqrt(120 * m2 * stiffness * 2 / m1).toStringAsFixed(0)} m/s or soften crumple zone.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _circuit(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double volt = _v(v, 'voltage', 9);
    final double res = _v(v, 'resistance', 330).clamp(1, 10000);
    final double ledRating = _v(v, 'led_rating', 20);
    final double currentMa = volt / res * 1000;
    final double power = volt * volt / res;
    final bool ledOk = currentMa >= 5 && currentMa <= ledRating;
    final PhysicsStatusLevel level = currentMa > ledRating * 1.2
        ? PhysicsStatusLevel.danger
        : ledOk
            ? PhysicsStatusLevel.good
            : PhysicsStatusLevel.caution;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Voltage', value: volt, unit: 'V'),
        PhysicsMetric(label: 'Current', value: currentMa, unit: 'mA'),
        PhysicsMetric(label: 'Power', value: power, unit: 'W'),
      ],
      status: level == PhysicsStatusLevel.danger
          ? 'DANGER — RESISTOR OVERHEATING'
          : ledOk
              ? 'LED ON — SAFE CURRENT'
              : 'CURRENT TOO LOW',
      statusLevel: level,
      plainEnglish: '$topic: ${currentMa.toStringAsFixed(1)} mA through ${res.toStringAsFixed(0)} Ω at ${volt.toStringAsFixed(1)} V.',
      coachTip: level == PhysicsStatusLevel.danger
          ? 'Your resistor will burn because current is too high. Increase resistance or lower voltage.'
          : 'Measure V and I — verify Ohm\'s law on your breadboard.',
      whatToTry: 'Add a second resistor in series to drop current.',
      missionResult: PhysicsMissionResult(
        passed: ledOk,
        scorePercent: ledOk ? 94 : level == PhysicsStatusLevel.danger ? 25 : 55,
        feedback: ledOk
            ? 'LED glowing at safe ${currentMa.toStringAsFixed(1)} mA — good circuit design.'
            : currentMa > ledRating
                ? 'Current too high — LED or resistor may fail.'
                : 'Increase voltage or decrease resistance to light the LED.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _optics(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double fObj = _v(v, 'f_objective', 50);
    final double fEye = _v(v, 'f_eyepiece', 10);
    final double mag = fObj / fEye;
    final bool missionOk = (mag - 5).abs() <= 0.8;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Magnification', value: mag, unit: '×'),
        PhysicsMetric(label: 'Objective f', value: fObj, unit: 'cm'),
        PhysicsMetric(label: 'Eyepiece f', value: fEye, unit: 'cm'),
      ],
      status: missionOk ? 'TELESCOPE ALIGNED' : 'ADJUST LENSES',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish: '$topic telescope magnification ≈ ${mag.toStringAsFixed(1)}×.',
      coachTip: 'Move lenses on the bench until the image is sharp on the screen.',
      whatToTry: 'Use a longer objective focal length for higher magnification.',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 91 : 62,
        feedback: missionOk ? '5× view achieved — sharp star field.' : 'Magnification is ${mag.toStringAsFixed(1)}× — adjust focal lengths toward ratio 5:1.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _rocket(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double fuel = _v(v, 'fuel', 200);
    final double thrust = _v(v, 'thrust', 150) * 1000;
    final double dry = _v(v, 'dry_mass', 150);
    final double drag = _v(v, 'drag_coef', 0.5);
    final double total = dry + fuel;
    final double burnTime = fuel / (thrust / 3000);
    final double deltaV = thrust * burnTime / total - 500 * drag;
    final double apogeeKm = (deltaV * deltaV / (2 * _earthG)) / 1000 * 0.15;
    final bool stable = dry / total > 0.25 && fuel > 80;
    final bool missionOk = apogeeKm >= 50 && stable;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Apogee', value: apogeeKm, unit: 'km'),
        PhysicsMetric(label: 'Δv', value: deltaV, unit: 'm/s'),
        PhysicsMetric(label: 'Burn time', value: burnTime, unit: 's'),
        PhysicsMetric(label: 'Mass ratio', value: total / dry, unit: ''),
      ],
      status: missionOk ? 'ORBITAL INSERTION' : stable ? 'SUBORBITAL' : 'UNSTABLE',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish: '$topic rocket reaches ≈ ${apogeeKm.toStringAsFixed(0)} km altitude.',
      coachTip: 'NASA trade-off: more fuel adds mass but extends burn time.',
      whatToTry: 'Increase thrust while watching stability (dry mass fraction).',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 96 : apogeeKm > 30 ? 70 : 45,
        feedback: missionOk
            ? 'Apogee ${apogeeKm.toStringAsFixed(0)} km — mission profile acceptable.'
            : 'Need ≥ 50 km — add fuel or thrust, reduce drag coefficient.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _wave(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double f = _v(v, 'frequency', 440);
    final double tension = _v(v, 'tension', 80);
    final double length = _v(v, 'length', 1.2);
    final double mu = 0.005;
    final double speed = math.sqrt(tension / mu);
    final double wavelength = speed / f;
    final bool missionOk = (wavelength - 0.5).abs() <= 0.08;

    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[
        PhysicsMetric(label: 'Wave speed', value: speed, unit: 'm/s'),
        PhysicsMetric(label: 'Wavelength', value: wavelength, unit: 'm'),
        PhysicsMetric(label: 'Frequency', value: f, unit: 'Hz'),
        PhysicsMetric(label: 'String length', value: length, unit: 'm'),
      ],
      status: missionOk ? 'STANDING WAVE LOCKED' : 'DETUNE',
      statusLevel: missionOk ? PhysicsStatusLevel.good : PhysicsStatusLevel.caution,
      plainEnglish: '$topic: λ ≈ ${wavelength.toStringAsFixed(2)} m at $f Hz.',
      coachTip: 'Higher tension raises wave speed — adjust f to lock λ = 0.5 m.',
      whatToTry: 'Double string length — how does fundamental wavelength change?',
      missionResult: PhysicsMissionResult(
        passed: missionOk,
        scorePercent: missionOk ? 93 : 58,
        feedback: missionOk ? 'λ ≈ 0.5 m — resonance achieved.' : 'Wavelength ${wavelength.toStringAsFixed(2)} m — tune tension or frequency.',
      ),
      instructorNote: mission.prompt,
    );
  }

  static PhysicsLabSnapshot _generic(Map<String, double> v, String topic, PhysicsLabMission mission) {
    final double a = _v(v, 'param_a', 5);
    final double b = _v(v, 'param_b', 3);
    final double result = a * b;
    return PhysicsLabSnapshot(
      metrics: <PhysicsMetric>[PhysicsMetric(label: 'Response', value: result, unit: 'a.u.')],
      status: result > 10 ? 'HIGH response' : 'LOW response',
      statusLevel: result > 10 ? PhysicsStatusLevel.caution : PhysicsStatusLevel.good,
      plainEnglish: 'Educational model for $topic.',
      coachTip: 'Change one slider at a time and predict the trend first.',
      whatToTry: 'Find settings that double the response.',
      missionResult: PhysicsMissionResult(
        passed: result >= 10,
        scorePercent: result >= 10 ? 80 : 50,
        feedback: 'Response = ${result.toStringAsFixed(1)} a.u.',
      ),
      instructorNote: mission.prompt,
    );
  }

  /// Auto equipment list for experiment reports.
  static List<String> reportEquipment({
    required String courseId,
    required String topicTitle,
    PhysicsLabRoom? room,
  }) {
    final PhysicsLabRoom r = room ?? defaultRoomFor(courseId);
    return <String>[...r.equipment, 'Notebook', 'Timer', '$topicTitle apparatus'];
  }

  /// Suggested report title.
  static String reportTitle({
    required String topicTitle,
    required String courseTitle,
    PhysicsLabRoom? room,
  }) {
    final PhysicsLabRoom r = room ?? const PhysicsLabRoom(
      id: 'mechanics',
      name: 'Mechanics Lab',
      emoji: '🧪',
      description: '',
      equipment: <String>[],
      experimentTitle: 'Measure physical quantities',
      experimentSteps: <String>[],
      icon: Icons.science_outlined,
    );
    return 'Determining $topicTitle — ${r.experimentTitle}';
  }
}
