import '../../models/physics/physics_program.dart';
import 'physics_formula_engine.dart';

/// All governing formulas per topic (keyed by topic id).
class PhysicsTopicFormulas {
  PhysicsTopicFormulas._();

  static List<PhysicsFormula> forTopic({
    required String courseId,
    required PhysicsTopic topic,
  }) {
    final List<PhysicsFormula>? byId = _byTopicId[topic.id];
    if (byId != null && byId.isNotEmpty) return byId;

    final List<PhysicsFormula> collected = PhysicsFormulaEngine.collectForTopic(
      courseId: courseId,
      topic: topic,
    );
    collected.addAll(_extrasFor(courseId, topic.title));
    final List<PhysicsFormula> deduped = _dedupe(collected);
    if (deduped.isNotEmpty) return deduped;

    return PhysicsFormulaEngine.handlersFor(courseId: courseId, title: topic.title);
  }

  static List<PhysicsFormula> _dedupe(List<PhysicsFormula> items) {
    final Set<String> seen = <String>{};
    final List<PhysicsFormula> out = <PhysicsFormula>[];
    for (final PhysicsFormula f in items) {
      final String key = '${f.name}|${f.latex}';
      if (seen.add(key)) out.add(f);
    }
    return out;
  }

  static List<PhysicsFormula> _extrasFor(String courseId, String title) {
    if (courseId == 'kinematics') return _kinematicsExtras(title);
    if (courseId == 'newtonian_mechanics') return _newtonExtras(title);
    if (courseId == 'work_energy_power') return _energyExtras(title);
    if (courseId == 'electric_circuits') return _circuitExtras(title);
    return const <PhysicsFormula>[];
  }

  static final Map<String, List<PhysicsFormula>> _byTopicId = <String, List<PhysicsFormula>>{
    'kinematics_position': _positionAll,
    'kinematics_distance': _distanceAll,
    'kinematics_displacement': _displacementAll,
    'kinematics_speed': _speedAll,
    'kinematics_velocity': _velocityAll,
    'kinematics_acceleration': _accelerationAll,
    'kinematics_motion_graphs': _graphsAll,
    'kinematics_one_dimensional_motion': _oneDAll,
    'kinematics_two_dimensional_motion': _twoDAll,
    'kinematics_projectile_motion': _projectileAll,
    'kinematics_circular_motion': _circularAll,
    'kinematics_relative_motion': _relativeAll,
    'kinematics_reference_frames': _referenceFramesAll,
  };

  static const List<PhysicsFormula> _positionAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Position',
      latex: r'x,\, y,\, z',
      symbols: r'Coordinates along orthogonal axes (m) relative to a chosen origin.',
    ),
    PhysicsFormula(
      name: 'Displacement',
      latex: r'\Delta \vec{r} = \vec{r}_f - \vec{r}_i',
      symbols: r'Change in position vector from initial to final point.',
    ),
    PhysicsFormula(
      name: '1D position',
      latex: r'x = x_0 + v_0 t + \tfrac{1}{2}at^2',
      symbols: r'Constant acceleration along one axis.',
    ),
  ];

  static const List<PhysicsFormula> _distanceAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Path length',
      latex: r's = \int |v|\,dt',
      symbols: r'$s$ total distance traveled (m); scalar quantity.',
    ),
    PhysicsFormula(
      name: 'Average speed',
      latex: r'v_{\mathrm{avg}} = \frac{s}{\Delta t}',
      symbols: r'$s$ distance over time interval $\Delta t$.',
    ),
    PhysicsFormula(
      name: 'Distance vs displacement',
      latex: r's \geq |\Delta x|',
      symbols: r'Equality only for motion in one direction without reversing.',
    ),
  ];

  static const List<PhysicsFormula> _velocityAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Average velocity',
      latex: r'\bar{v} = \frac{\Delta x}{\Delta t}',
      symbols: r'$\bar{v}$ average velocity (m/s); $\Delta x$ displacement (m); $\Delta t$ time (s)',
      whenToUse: 'Whole trip or interval.',
      unitCheck: r'$\mathrm{m/s}=\mathrm{m}/\mathrm{s}$',
    ),
    PhysicsFormula(
      name: 'Instantaneous velocity',
      latex: r'v = \frac{dx}{dt}',
      symbols: r'$v$ velocity at one instant; $x$ position; $t$ time',
      whenToUse: 'Slope of position–time graph at a point.',
    ),
    PhysicsFormula(
      name: 'Speed (scalar)',
      latex: r'\text{speed} = \frac{\text{distance}}{\Delta t}',
      symbols: r'Scalar — no direction.',
    ),
    PhysicsFormula(
      name: 'km/h to m/s',
      latex: r'v_{\mathrm{m/s}} = v_{\mathrm{km/h}} \times \frac{1000}{3600}',
      symbols: r'Multiply km/h by $5/18$ to get m/s.',
    ),
    PhysicsFormula(
      name: 'm/s to km/h',
      latex: r'v_{\mathrm{km/h}} = v_{\mathrm{m/s}} \times 3.6',
      symbols: r'Multiply m/s by 3.6.',
    ),
    PhysicsFormula(
      name: r'Final velocity (constant $a$)',
      latex: r'v_f = v_i + at',
      symbols: r'$v_f$ final; $v_i$ initial; $a$ acceleration; $t$ time',
    ),
    PhysicsFormula(
      name: r'Displacement (constant $a$)',
      latex: r'\Delta x = v_i t + \tfrac{1}{2}at^2',
      symbols: r'$\Delta x$ displacement with uniform acceleration.',
    ),
    PhysicsFormula(
      name: 'Velocity without time',
      latex: r'v_f^2 = v_i^2 + 2a\Delta x',
      symbols: r'Use when time is unknown.',
    ),
    PhysicsFormula(
      name: 'Projectile horizontal',
      latex: r'v_x = v_0\cos\theta',
      symbols: r'$v_x$ constant if no air drag.',
    ),
    PhysicsFormula(
      name: 'Projectile vertical',
      latex: r'v_y = v_0\sin\theta - gt',
      symbols: r'$g \approx 9.8$ m/s² downward.',
    ),
    PhysicsFormula(
      name: 'Circular tangential speed',
      latex: r'v = \frac{2\pi r}{T} = r\omega',
      symbols: r'$r$ radius; $T$ period; $\omega$ angular speed (rad/s).',
    ),
    PhysicsFormula(
      name: 'Angular velocity',
      latex: r'\omega = \frac{\Delta\theta}{\Delta t}',
      symbols: r'$\theta$ in radians.',
    ),
    PhysicsFormula(
      name: 'Relative velocity (1D)',
      latex: r'v_{A/B} = v_A - v_B',
      symbols: r"Velocity of A measured in B's frame (collinear).",
    ),
    PhysicsFormula(
      name: 'Earth escape speed',
      latex: r'v_{\mathrm{esc}} \approx 11.2\,\mathrm{km/s}',
      symbols: r"Minimum speed to escape Earth's gravity without further thrust.",
    ),
  ];

  static const List<PhysicsFormula> _accelerationAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Average acceleration',
      latex: r'a_{\mathrm{avg}} = \frac{\Delta v}{\Delta t}',
      symbols: r'$a$ in m/s²; $\Delta v$ change in velocity.',
    ),
    PhysicsFormula(
      name: 'Instantaneous acceleration',
      latex: r'a = \frac{dv}{dt}',
      symbols: r'Slope of velocity–time graph.',
    ),
    PhysicsFormula(
      name: 'Constant acceleration',
      latex: r'v_f = v_i + at',
      symbols: r'Kinematic equation 1.',
    ),
    PhysicsFormula(
      name: 'Displacement',
      latex: r'\Delta x = v_i t + \tfrac{1}{2}at^2',
      symbols: r'Kinematic equation 2.',
    ),
    PhysicsFormula(
      name: 'Velocity squared',
      latex: r'v_f^2 = v_i^2 + 2a\Delta x',
      symbols: r'Kinematic equation 3 (no $t$).',
    ),
    PhysicsFormula(
      name: 'Centripetal acceleration',
      latex: r'a_c = \frac{v^2}{r}',
      symbols: r'Direction toward center of circle.',
    ),
  ];

  static const List<PhysicsFormula> _displacementAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Displacement',
      latex: r'\Delta x = x_f - x_i',
      symbols: r'Vector change in position (m).',
    ),
    PhysicsFormula(
      name: 'Distance vs displacement',
      latex: r's \geq |\Delta x|',
      symbols: r'Distance $s$ is path length; displacement is shortest vector between endpoints.',
    ),
    PhysicsFormula(
      name: 'From velocity',
      latex: r'\Delta x = \bar{v}\,\Delta t',
      symbols: r'Constant $\bar{v}$ over interval.',
    ),
  ];

  static const List<PhysicsFormula> _speedAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Average speed',
      latex: r'v_{\mathrm{avg}} = \frac{s}{\Delta t}',
      symbols: r'$s$ total distance (scalar).',
    ),
    PhysicsFormula(
      name: 'Instantaneous speed',
      latex: r'|\vec{v}|',
      symbols: r'Magnitude of velocity vector.',
    ),
    PhysicsFormula(
      name: 'Unit conversion',
      latex: r'1\,\mathrm{m/s} = 3.6\,\mathrm{km/h}',
      symbols: r'Common road-speed conversion.',
    ),
  ];

  static const List<PhysicsFormula> _projectileAll = <PhysicsFormula>[
    PhysicsFormula(name: 'Horizontal position', latex: r'x = v_0\cos\theta\, t', symbols: r'$x$ horizontal (m).'),
    PhysicsFormula(name: 'Vertical position', latex: r'y = v_0\sin\theta\, t - \tfrac{1}{2}gt^2', symbols: r'$y$ vertical (m).'),
    PhysicsFormula(name: 'Horizontal velocity', latex: r'v_x = v_0\cos\theta', symbols: r'Constant without drag.'),
    PhysicsFormula(name: 'Vertical velocity', latex: r'v_y = v_0\sin\theta - gt', symbols: r'Changes with gravity.'),
    PhysicsFormula(name: 'Range (level ground)', latex: r'R = \frac{v_0^2\sin 2\theta}{g}', symbols: r'Max at $\theta=45°$ (no drag).'),
    PhysicsFormula(name: 'Max height', latex: r'H = \frac{v_0^2\sin^2\theta}{2g}', symbols: r'Peak altitude.'),
  ];

  static const List<PhysicsFormula> _circularAll = <PhysicsFormula>[
    PhysicsFormula(name: 'Tangential speed', latex: r'v = r\omega', symbols: r'$r$ radius; $\omega$ rad/s.'),
    PhysicsFormula(name: 'Period', latex: r'T = \frac{2\pi r}{v}', symbols: r'Time for one revolution.'),
    PhysicsFormula(name: 'Centripetal acceleration', latex: r'a_c = \frac{v^2}{r} = r\omega^2', symbols: r'Toward center.'),
    PhysicsFormula(name: 'Angular velocity', latex: r'\omega = \frac{2\pi}{T}', symbols: r'rad/s.'),
  ];

  static const List<PhysicsFormula> _oneDAll = <PhysicsFormula>[
    PhysicsFormula(name: 'Position', latex: r'x = x_0 + v_0 t + \tfrac{1}{2}at^2', symbols: r'Constant $a$.'),
    PhysicsFormula(name: 'Velocity', latex: r'v = v_0 + at', symbols: r'Constant $a$.'),
    PhysicsFormula(name: 'Velocity squared', latex: r'v^2 = v_0^2 + 2a(x-x_0)', symbols: r'No time needed.'),
  ];

  static const List<PhysicsFormula> _twoDAll = <PhysicsFormula>[
    PhysicsFormula(name: 'Vector components', latex: r'\vec{v} = v_x\hat{i} + v_y\hat{j}', symbols: r'Independent axes.'),
    PhysicsFormula(name: 'Magnitude', latex: r'|\vec{v}| = \sqrt{v_x^2 + v_y^2}', symbols: r'Speed from components.'),
    PhysicsFormula(name: 'Direction', latex: r'\theta = \tan^{-1}(v_y/v_x)', symbols: r'Angle of velocity vector.'),
  ];

  static const List<PhysicsFormula> _relativeAll = <PhysicsFormula>[
    PhysicsFormula(name: 'Relative velocity', latex: r'\vec{v}_{A/B} = \vec{v}_A - \vec{v}_B', symbols: r'Galilean relativity (low speed).'),
    PhysicsFormula(name: '1D relative speed', latex: r'v_{\text{rel}} = |v_A - v_B|', symbols: r'Same line of motion.'),
  ];

  static const List<PhysicsFormula> _graphsAll = <PhysicsFormula>[
    PhysicsFormula(name: r'Slope of $x$–$t$', latex: r'v = \frac{dx}{dt}', symbols: r'Instantaneous velocity.'),
    PhysicsFormula(name: r'Slope of $v$–$t$', latex: r'a = \frac{dv}{dt}', symbols: r'Instantaneous acceleration.'),
    PhysicsFormula(name: r'Area under $v$–$t$', latex: r'\Delta x = \int v\,dt', symbols: r'Displacement.'),
  ];

  static const List<PhysicsFormula> _referenceFramesAll = <PhysicsFormula>[
    PhysicsFormula(
      name: 'Galilean position transform',
      latex: r"x' = x - vt",
      symbols: r"Position in frame moving at constant $v$ relative to lab frame.",
    ),
    PhysicsFormula(
      name: 'Relative velocity',
      latex: r'\vec{v}_{A/B} = \vec{v}_A - \vec{v}_B',
      symbols: r'Velocity of A as measured in B’s frame (Galilean).',
    ),
    PhysicsFormula(
      name: 'Inertial frame',
      latex: r'\sum \vec{F} = m\vec{a}',
      symbols: r"Newton's laws hold in inertial (non-accelerating) reference frames.",
    ),
  ];

  static List<PhysicsFormula> _kinematicsExtras(String title) {
    final String t = title.toLowerCase();
    if (t.contains('velocity')) return _velocityAll;
    if (t.contains('acceleration')) return _accelerationAll;
    return const <PhysicsFormula>[];
  }

  static List<PhysicsFormula> _newtonExtras(String title) => const <PhysicsFormula>[
        PhysicsFormula(name: "Newton's second law", latex: r'\sum \vec{F} = m\vec{a}', symbols: r'Net force (N).'),
        PhysicsFormula(name: 'Weight', latex: r'W = mg', symbols: r'$W$ in newtons.'),
      ];

  static List<PhysicsFormula> _energyExtras(String title) => const <PhysicsFormula>[
        PhysicsFormula(name: 'Kinetic energy', latex: r'K = \tfrac{1}{2}mv^2', symbols: r'J.'),
        PhysicsFormula(name: 'Work–energy', latex: r'W_{\mathrm{net}} = \Delta K', symbols: r'Work in joules.'),
      ];

  static List<PhysicsFormula> _circuitExtras(String title) => const <PhysicsFormula>[
        PhysicsFormula(name: "Ohm's law", latex: r'V = IR', symbols: r'$V$ volts; $I$ amps; $R$ ohms.'),
        PhysicsFormula(name: 'Electrical power', latex: r'P = IV = I^2R', symbols: r'$P$ in watts.'),
      ];
}
