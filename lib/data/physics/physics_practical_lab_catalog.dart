import '../../models/physics/physics_program.dart';
import 'physics_catalog.dart';

/// One hands-on practical from the Virtual Physics Lab (PhysicLab-style).
class PhysicsPracticalLab {
  const PhysicsPracticalLab({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.trackId,
    required this.courseId,
    required this.topicId,
    this.comingSoon = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String category;
  final String trackId;
  final String courseId;
  final String topicId;
  final bool comingSoon;

  PhysicsTrack? get track => PhysicsCatalog.trackById(trackId);
  PhysicsCourse? get course => PhysicsCatalog.courseById(trackId: trackId, courseId: courseId);
  PhysicsTopic? get topic => PhysicsCatalog.topicById(trackId: trackId, courseId: courseId, topicId: topicId);
}

/// Free virtual experiments — inspired by physiclab.onrender.com topic grid.
class PhysicsPracticalLabCatalog {
  PhysicsPracticalLabCatalog._();

  static const String tagline = 'Free virtual physics experiments & interactive simulations';
  static const String intro =
      'Click any practical below to explore real-world physics through simulation — '
      'with live data, formulas, and theory built in.';

  static const List<String> benefits = <String>[
    'Interactive simulators',
    'Real-time data & graphs',
    'Theory & applications',
    'College physics ready',
  ];

  static const List<PhysicsPracticalLab> all = <PhysicsPracticalLab>[
    PhysicsPracticalLab(
      id: 'gravity_drop',
      emoji: '🌍',
      title: 'Gravity Drop',
      subtitle: 'See how gravity affects falling objects on different planets.',
      category: 'Mechanics',
      trackId: 'undergraduate_core',
      courseId: 'gravitation',
      topicId: 'gravitation_newton_s_law_of_gravity',
    ),
    PhysicsPracticalLab(
      id: 'light_reflection',
      emoji: '🔁',
      title: 'Light Reflection',
      subtitle: 'Understand how light reflects off various surfaces.',
      category: 'Optics',
      trackId: 'undergraduate_core',
      courseId: 'optics',
      topicId: 'optics_reflection',
    ),
    PhysicsPracticalLab(
      id: 'light_refraction',
      emoji: '💧',
      title: 'Light Refraction',
      subtitle: 'Learn how light bends in water, glass, and air.',
      category: 'Optics',
      trackId: 'undergraduate_core',
      courseId: 'optics',
      topicId: 'optics_refraction',
    ),
    PhysicsPracticalLab(
      id: 'thermal_expansion',
      emoji: '🔥',
      title: 'Thermal Expansion',
      subtitle: 'Discover how heat makes objects expand.',
      category: 'Thermodynamics',
      trackId: 'undergraduate_core',
      courseId: 'thermodynamics',
      topicId: 'thermodynamics_thermal_expansion',
    ),
    PhysicsPracticalLab(
      id: 'heat_flow',
      emoji: '🌡️',
      title: 'Heat Flow Rate',
      subtitle: 'Measure how materials transfer heat differently.',
      category: 'Thermodynamics',
      trackId: 'undergraduate_core',
      courseId: 'thermodynamics',
      topicId: 'thermodynamics_heat',
    ),
    PhysicsPracticalLab(
      id: 'negative_charge',
      emoji: '➖',
      title: 'Negative Charge',
      subtitle: 'Visualize electrons charging a body negatively.',
      category: 'Electricity',
      trackId: 'undergraduate_core',
      courseId: 'electrostatics',
      topicId: 'electrostatics_electric_charge',
    ),
    PhysicsPracticalLab(
      id: 'positive_charge',
      emoji: '➕',
      title: 'Positive Charge',
      subtitle: 'Understand how a body loses electrons.',
      category: 'Electricity',
      trackId: 'undergraduate_core',
      courseId: 'electrostatics',
      topicId: 'electrostatics_electric_charge',
    ),
    PhysicsPracticalLab(
      id: 'parallel_circuit',
      emoji: '🔌',
      title: 'Parallel Circuit',
      subtitle: 'Explore how current splits and flows in branches.',
      category: 'Circuits',
      trackId: 'undergraduate_core',
      courseId: 'electric_circuits',
      topicId: 'electric_circuits_parallel_circuits',
    ),
    PhysicsPracticalLab(
      id: 'series_circuit',
      emoji: '🔗',
      title: 'Series Circuit',
      subtitle: 'Simulate current flow in one complete loop.',
      category: 'Circuits',
      trackId: 'undergraduate_core',
      courseId: 'electric_circuits',
      topicId: 'electric_circuits_series_circuits',
    ),
    PhysicsPracticalLab(
      id: 'projectile_motion',
      emoji: '🎯',
      title: 'Projectile Motion',
      subtitle: 'Explore 2D motion with realistic trajectories.',
      category: 'Mechanics',
      trackId: 'undergraduate_core',
      courseId: 'kinematics',
      topicId: 'kinematics_projectile_motion',
    ),
    PhysicsPracticalLab(
      id: 'pendulum',
      emoji: '⚖️',
      title: 'Pendulum Simulator',
      subtitle: 'Visualize simple harmonic motion and oscillations.',
      category: 'Mechanics',
      trackId: 'undergraduate_core',
      courseId: 'oscillations',
      topicId: 'oscillations_pendulums',
    ),
  ];

  static PhysicsPracticalLab? byId(String id) {
    for (final PhysicsPracticalLab p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  static List<PhysicsPracticalLab> forCategory(String category) =>
      all.where((PhysicsPracticalLab p) => p.category == category).toList();

  static List<String> get categories =>
      all.map((PhysicsPracticalLab p) => p.category).toSet().toList()..sort();
}