import '../../models/physics/physics_program.dart';
import 'physics_topic_formulas.dart';

/// One governing relation with textbook-style symbol definitions.
class PhysicsFormula {
  const PhysicsFormula({
    required this.name,
    required this.latex,
    required this.symbols,
    this.whenToUse,
    this.unitCheck,
  });

  final String name;
  final String latex;
  final String symbols;
  final String? whenToUse;
  final String? unitCheck;
}

/// Topic-specific physics formulas — textbook reference for the Formula Notebook.
class PhysicsFormulaEngine {
  PhysicsFormulaEngine._();

  static List<PhysicsFormula> formulasFor({
    required String courseId,
    required PhysicsTopic topic,
  }) =>
      PhysicsTopicFormulas.forTopic(courseId: courseId, topic: topic);

  /// Internal handler lookup (used by topic formula catalog).
  static List<PhysicsFormula> handlersFor({
    required String courseId,
    required String title,
  }) {
    final List<PhysicsFormula> Function(String title)? handler = _courseHandlers[courseId];
    if (handler != null) {
      final List<PhysicsFormula> fromCourse = handler(title);
      if (fromCourse.isNotEmpty) return fromCourse;
    }
    return _keywordFallback(title);
  }

  /// Gathers every formula match for a topic (title, id slug, key concepts, words).
  static List<PhysicsFormula> collectForTopic({
    required String courseId,
    required PhysicsTopic topic,
  }) {
    final List<PhysicsFormula> collected = <PhysicsFormula>[];
    final Set<String> queries = <String>{};

    void addQuery(String? raw) {
      if (raw == null) return;
      final String normalized = raw.trim().toLowerCase();
      if (normalized.length >= 3) queries.add(normalized);
    }

    addQuery(topic.title);
    addQuery(_slugFromTopicId(topic.id, courseId));
    for (final String concept in topic.keyConcepts) {
      addQuery(concept);
    }
    for (final String part in topic.title.split(RegExp(r'[^\w]+'))) {
      addQuery(part);
    }
    for (final String part in topic.id.split('_')) {
      if (part != courseId) addQuery(part);
    }

    for (final String query in queries) {
      collected.addAll(handlersFor(courseId: courseId, title: query));
    }
    return collected;
  }

  static String _slugFromTopicId(String topicId, String courseId) {
    final String prefix = '${courseId}_';
    if (topicId.startsWith(prefix)) {
      return topicId.substring(prefix.length).replaceAll('_', ' ');
    }
    final int underscore = topicId.indexOf('_');
    if (underscore > 0 && underscore < topicId.length - 1) {
      return topicId.substring(underscore + 1).replaceAll('_', ' ');
    }
    return topicId.replaceAll('_', ' ');
  }

  static String notebookMarkdown({
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required String levelLabel,
  }) {
    final List<PhysicsFormula> formulas = formulasFor(courseId: course.id, topic: topic);
    final StringBuffer buf = StringBuffer()
      ..writeln('## Formula Notebook — ${topic.title}')
      ..writeln()
      ..writeln('**${course.title}** · $levelLabel')
      ..writeln()
      ..writeln('### All Formulas for ${topic.title}')
      ..writeln(
        'Every governing relation for **${topic.title}** in ${course.title}. '
        'Define every symbol before substituting numbers.',
      )
      ..writeln()
      ..writeln('### Governing Relations');

    for (int i = 0; i < formulas.length; i++) {
      final PhysicsFormula f = formulas[i];
      buf
        ..writeln()
        ..writeln('#### ${i + 1}. ${f.name}')
        ..writeln()
        ..writeln(r'$$')
        ..writeln(f.latex)
        ..writeln(r'$$')
        ..writeln()
        ..writeln('**Symbols:** ${f.symbols}');
      if (f.whenToUse != null) {
        buf.writeln('**When to use:** ${f.whenToUse}');
      }
      if (f.unitCheck != null) {
        buf.writeln('**Unit check:** ${f.unitCheck}');
      }
    }

    buf
      ..writeln()
      ..writeln('### How to Study These Relations')
      ..writeln('- Write each formula from memory, then define every symbol.')
      ..writeln('- Substitute SI units and confirm both sides match.')
      ..writeln(r'- State one limiting case (e.g., $t \to 0$ or $v \ll c$).')
      ..writeln('- Verify a prediction in the 3D Simulation & Lab.')
      ..writeln()
      ..writeln('### Summary')
      ..writeln('- Topic: ${topic.title}')
      ..writeln('- Relations covered: ${formulas.length}')
      ..writeln('- Course: ${course.title}');

    return buf.toString();
  }

  static List<String> formulaLines({
    required String courseId,
    required PhysicsTopic topic,
  }) =>
      formulasFor(courseId: courseId, topic: topic)
          .map((PhysicsFormula f) => '${f.name}: \$${f.latex}\$')
          .toList();

  // --- course handlers ---

  static final Map<String, List<PhysicsFormula> Function(String title)> _courseHandlers =
      <String, List<PhysicsFormula> Function(String title)>{
    'intro_physics': _introPhysics,
    'math_foundations': _mathFoundations,
    'kinematics': _kinematics,
    'newtonian_mechanics': _newtonian,
    'work_energy_power': _workEnergy,
    'momentum_collisions': _momentum,
    'rotational_mechanics': _rotational,
    'gravitation': _gravitation,
    'oscillations': _oscillations,
    'fluid_mechanics': _fluids,
    'thermodynamics': _thermodynamics,
    'statistical_mechanics': _statMech,
    'waves': _waves,
    'acoustics': _acoustics,
    'electrostatics': _electrostatics,
    'electric_circuits': _circuits,
    'magnetism': _magnetism,
    'em_induction': _emInduction,
    'maxwell_equations': _maxwell,
    'optics': _optics,
    'special_relativity': _specialRelativity,
    'general_relativity': _generalRelativity,
    'quantum_mechanics': _quantum,
    'atomic_physics': _atomic,
    'nuclear_physics': _nuclear,
    'particle_physics': _particle,
  };

  static List<PhysicsFormula> _kinematics(String title) {
    final String t = title.toLowerCase();
    if (t.contains('displacement') || t == 'position') {
      return _pack(
        name: 'Displacement',
        latex: r'\Delta x = x_f - x_i',
        symbols: r'$x$ position (m); $\Delta x$ displacement (m); subscripts $f$ final, $i$ initial',
        when: 'Comparing start and end location along one axis (vector in 1D).',
        units: r'$\mathrm{m} = \mathrm{m} - \mathrm{m}$',
      );
    }
    if (t.contains('distance')) {
      return _pack(
        name: 'Path length',
        latex: r's = \int |v|\,dt',
        symbols: r'$s$ distance traveled (m); $v$ speed (m/s); $t$ time (s)',
        when: 'Total length along the path — not the same as displacement if direction changes.',
        units: r'$\mathrm{m} = \mathrm{m/s}\cdot\mathrm{s}$',
      );
    }
    if (t.contains('speed')) {
      return _pack(
        name: 'Average speed',
        latex: r'v_{\mathrm{avg}} = \frac{s}{\Delta t}',
        symbols: r'$v_{\mathrm{avg}}$ average speed (m/s); $s$ distance (m); $\Delta t$ time interval (s)',
        when: 'Scalar rate over a trip.',
        units: r'$\mathrm{m/s} = \mathrm{m}/\mathrm{s}$',
      );
    }
    if (t.contains('velocity')) {
      return _pack(
        name: 'Average velocity',
        latex: r'\bar{v} = \frac{\Delta x}{\Delta t}',
        symbols: r'$\bar{v}$ average velocity (m/s); $\Delta x$ displacement (m); $\Delta t$ time (s)',
        when: 'Vector rate of position change.',
        units: r'$\mathrm{m/s} = \mathrm{m}/\mathrm{s}$',
      );
    }
    if (t.contains('acceleration')) {
      return _pack(
        name: 'Constant acceleration',
        latex: r'a = \frac{\Delta v}{\Delta t}',
        symbols: r'$a$ acceleration (m/s²); $\Delta v$ change in velocity (m/s); $\Delta t$ time (s)',
        when: 'Uniform acceleration along a straight line.',
        units: r'$\mathrm{m/s^2} = \mathrm{m/s}/\mathrm{s}$',
      );
    }
    if (t.contains('projectile')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: 'Horizontal motion',
          latex: r'x = v_0\cos\theta\, t',
          symbols: r'$x$ horizontal position (m); $v_0$ launch speed (m/s); $\theta$ launch angle; $t$ time (s)',
          whenToUse: 'No horizontal acceleration (neglect air drag).',
          unitCheck: r'$\mathrm{m} = (\mathrm{m/s})\cdot\mathrm{s}$',
        ),
        const PhysicsFormula(
          name: 'Vertical motion',
          latex: r'y = v_0\sin\theta\, t - \tfrac{1}{2}gt^2',
          symbols: r'$y$ vertical position (m); $g$ gravitational acceleration (≈9.8 m/s²)',
          whenToUse: r'Near Earth surface with downward $g$.',
          unitCheck: r'$\mathrm{m} = (\mathrm{m/s})\cdot\mathrm{s} - (\mathrm{m/s^2})\cdot\mathrm{s^2}$',
        ),
      ];
    }
    if (t.contains('circular')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: 'Tangential speed',
          latex: r'v = r\omega',
          symbols: r'$v$ tangential speed (m/s); $r$ radius (m); $\omega$ angular speed (rad/s)',
          unitCheck: r'$\mathrm{m/s} = \mathrm{m}\cdot\mathrm{rad/s}$',
        ),
        const PhysicsFormula(
          name: 'Centripetal acceleration',
          latex: r'a_c = \frac{v^2}{r} = r\omega^2',
          symbols: r'$a_c$ centripetal acceleration (m/s²) toward the center',
          whenToUse: 'Uniform circular motion.',
        ),
      ];
    }
    if (t.contains('reference') || t.contains('frame')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: 'Galilean position transform',
          latex: r"x' = x - vt",
          symbols: r"$x'$ position in moving frame; $x$ in lab frame; $v$ relative speed; $t$ time",
          whenToUse: r'Inertial frames at speeds much less than $c$.',
        ),
        const PhysicsFormula(
          name: 'Relative velocity',
          latex: r'\vec{v}_{A/B} = \vec{v}_A - \vec{v}_B',
          symbols: r'Velocity of object A measured in frame B.',
        ),
      ];
    }
    if (t.contains('one-dimensional') || t.contains('1d')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: r'Position under constant $a$',
          latex: r'x = x_0 + v_0 t + \tfrac{1}{2} a t^2',
          symbols: r'$x_0$ initial position; $v_0$ initial velocity; $a$ constant acceleration',
        ),
        const PhysicsFormula(
          name: r'Velocity under constant $a$',
          latex: r'v = v_0 + a t',
          symbols: r'$v$ velocity at time $t$',
        ),
      ];
    }
    return _pack(
      name: 'Instantaneous velocity',
      latex: r'v = \frac{dx}{dt}',
      symbols: r'$v$ velocity (m/s); $x$ position (m); $t$ time (s)',
      when: 'Slope of the position–time graph at one instant.',
    );
  }

  static List<PhysicsFormula> _newtonian(String title) {
    final String t = title.toLowerCase();
    if (t.contains('third law')) {
      return _pack(
        name: "Newton's third law",
        latex: r'\vec{F}_{AB} = -\vec{F}_{BA}',
        symbols: r'Forces between two bodies are equal in magnitude and opposite in direction.',
      );
    }
    if (t.contains('first law') || t.contains('inertia')) {
      return _pack(
        name: "Newton's first law",
        latex: r'\sum \vec{F} = 0 \Rightarrow \vec{v} = \text{constant}',
        symbols: r'If net force is zero, velocity does not change (inertia).',
      );
    }
    if (t.contains('newton') || t.contains('second law')) {
      return _pack(
        name: "Newton's second law",
        latex: r'\sum \vec{F} = m\vec{a}',
        symbols: r'$\sum\vec{F}$ net force (N); $m$ mass (kg); $\vec{a}$ acceleration (m/s²)',
        when: 'Relates net force to acceleration in an inertial frame.',
        units: r'$\mathrm{N} = \mathrm{kg}\cdot\mathrm{m/s^2}$',
      );
    }
    if (t.contains('weight')) {
      return _pack(
        name: 'Weight',
        latex: r'W = mg',
        symbols: r'$W$ weight (N); $m$ mass (kg); $g$ gravitational field strength (N/kg or m/s²)',
      );
    }
    if (t.contains('friction')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: 'Static friction (limit)',
          latex: r'f_s \le \mu_s N',
          symbols: r'$f_s$ static friction (N); $\mu_s$ coefficient of static friction; $N$ normal force (N)',
        ),
        const PhysicsFormula(
          name: 'Kinetic friction',
          latex: r'f_k = \mu_k N',
          symbols: r'$f_k$ kinetic friction (N); $\mu_k$ coefficient of kinetic friction',
        ),
      ];
    }
    if (t.contains('spring')) {
      return _pack(
        name: "Hooke's law",
        latex: r'F = -kx',
        symbols: r'$F$ restoring force (N); $k$ spring constant (N/m); $x$ displacement from equilibrium (m)',
        when: 'Linear elastic deformation.',
      );
    }
    if (t.contains('equilibrium')) {
      return _pack(
        name: 'Static equilibrium',
        latex: r'\sum \vec{F} = 0 \quad \text{and} \quad \sum \tau = 0',
        symbols: r'Net force and net torque both zero for a rigid body at rest.',
      );
    }
    return _pack(
      name: "Newton's first law",
      latex: r'\sum \vec{F} = 0 \Rightarrow \vec{v} = \text{constant}',
      symbols: r'If net force is zero, velocity does not change (inertia).',
    );
  }

  static List<PhysicsFormula> _workEnergy(String title) {
    final String t = title.toLowerCase();
    if (t.contains('kinetic')) {
      return _pack(
        name: 'Kinetic energy',
        latex: r'K = \tfrac{1}{2}mv^2',
        symbols: r'$K$ kinetic energy (J); $m$ mass (kg); $v$ speed (m/s)',
        units: r'$\mathrm{J} = \mathrm{kg}\cdot(\mathrm{m/s})^2$',
      );
    }
    if (t.contains('potential') || t.contains('gravitational')) {
      return _pack(
        name: 'Gravitational potential energy (near Earth)',
        latex: r'U_g = mgh',
        symbols: r'$U_g$ gravitational PE (J); $h$ height above reference (m)',
      );
    }
    if (t.contains('elastic')) {
      return _pack(
        name: 'Elastic potential energy',
        latex: r'U_s = \tfrac{1}{2}kx^2',
        symbols: r'$U_s$ stored elastic energy (J); $k$ spring constant (N/m); $x$ stretch (m)',
      );
    }
    if (t.contains('conservation')) {
      return _pack(
        name: 'Mechanical energy conservation',
        latex: r'K_i + U_i = K_f + U_f',
        symbols: r'Valid when only conservative forces do work.',
      );
    }
    if (t.contains('power')) {
      return _pack(
        name: 'Power',
        latex: r'P = \frac{W}{\Delta t} = \vec{F}\cdot\vec{v}',
        symbols: r'$P$ power (W); $W$ work (J); $\Delta t$ time (s)',
        units: r'$\mathrm{W} = \mathrm{J/s}$',
      );
    }
    if (t.contains('work')) {
      return _pack(
        name: 'Work by constant force',
        latex: r'W = Fd\cos\theta',
        symbols: r'$W$ work (J); $F$ force (N); $d$ displacement (m); $\theta$ angle between $\vec{F}$ and $\vec{d}$',
      );
    }
    return _pack(
      name: 'Work–energy theorem',
      latex: r'W_{\mathrm{net}} = \Delta K',
      symbols: r'Net work equals change in kinetic energy.',
    );
  }

  static List<PhysicsFormula> _momentum(String title) {
    final String t = title.toLowerCase();
    if (t.contains('impulse')) {
      return _pack(
        name: 'Impulse–momentum theorem',
        latex: r'J = \Delta p = F_{\mathrm{avg}}\Delta t',
        symbols: r'$J$ impulse (N·s); $p$ momentum (kg·m/s); $F_{\mathrm{avg}}$ average force',
      );
    }
    if (t.contains('conservation')) {
      return _pack(
        name: 'Momentum conservation',
        latex: r'\sum p_i = \sum p_f',
        symbols: r'Total momentum constant if external impulse is negligible.',
      );
    }
    if (t.contains('elastic')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: '1D elastic collision — momentum',
          latex: r"m_1v_1 + m_2v_2 = m_1v_1' + m_2v_2'",
          symbols: r'Primes denote final velocities.',
        ),
        const PhysicsFormula(
          name: '1D elastic collision — kinetic energy',
          latex: r"\tfrac{1}{2}m_1v_1^2 + \tfrac{1}{2}m_2v_2^2 = \tfrac{1}{2}m_1v_1'^2 + \tfrac{1}{2}m_2v_2'^2",
          symbols: r'Kinetic energy also conserved in elastic collisions.',
        ),
      ];
    }
    if (t.contains('center of mass')) {
      return _pack(
        name: 'Center of mass',
        latex: r'x_{\mathrm{cm}} = \frac{\sum m_i x_i}{\sum m_i}',
        symbols: r'$x_{\mathrm{cm}}$ center of mass position; $m_i$ masses at positions $x_i$',
      );
    }
    return _pack(
      name: 'Linear momentum',
      latex: r'\vec{p} = m\vec{v}',
      symbols: r'$p$ momentum (kg·m/s); $m$ mass (kg); $v$ velocity (m/s)',
    );
  }

  static List<PhysicsFormula> _rotational(String title) {
    final String t = title.toLowerCase();
    if (t.contains('torque')) {
      return _pack(
        name: 'Torque',
        latex: r'\tau = rF\sin\theta',
        symbols: r'$\tau$ torque (N·m); $r$ lever arm (m); $F$ force (N); $\theta$ angle between $\vec{r}$ and $\vec{F}$',
      );
    }
    if (t.contains('angular momentum') || t.contains('conservation')) {
      return _pack(
        name: 'Angular momentum',
        latex: r'L = I\omega',
        symbols: r'$L$ angular momentum (kg·m²/s); $I$ rotational inertia (kg·m²); $\omega$ angular speed (rad/s)',
      );
    }
    if (t.contains('rotational energy') || t.contains('inertia')) {
      return _pack(
        name: 'Rotational kinetic energy',
        latex: r'K_{\mathrm{rot}} = \tfrac{1}{2}I\omega^2',
        symbols: r'$I$ moment of inertia depends on mass distribution about the axis.',
      );
    }
    if (t.contains('angular velocity')) {
      return _pack(
        name: 'Angular velocity',
        latex: r'\omega = \frac{d\theta}{dt}',
        symbols: r'$\omega$ angular velocity (rad/s); $\theta$ angular position (rad)',
      );
    }
    return _pack(
      name: 'Rotational kinematics',
      latex: r'\alpha = \frac{d\omega}{dt}',
      symbols: r'$\alpha$ angular acceleration (rad/s²)',
    );
  }

  static List<PhysicsFormula> _gravitation(String title) {
    final String t = title.toLowerCase();
    if (t.contains('kepler')) {
      return _pack(
        name: "Kepler's third law",
        latex: r'T^2 \propto a^3',
        symbols: r'$T$ orbital period; $a$ semi-major axis for a planet orbiting the Sun.',
      );
    }
    if (t.contains('escape')) {
      return _pack(
        name: 'Escape speed',
        latex: r'v_{\mathrm{esc}} = \sqrt{\frac{2GM}{r}}',
        symbols: r'$G$ gravitational constant; $M$ planet mass; $r$ distance from center',
      );
    }
    if (t.contains('orbital') || t.contains('satellite')) {
      return _pack(
        name: 'Circular orbit speed',
        latex: r'v = \sqrt{\frac{GM}{r}}',
        symbols: r'$v$ orbital speed; $r$ orbital radius from center of attracting body',
      );
    }
    return _pack(
      name: "Newton's law of gravitation",
      latex: r'F = G\frac{m_1 m_2}{r^2}',
      symbols: r'$F$ gravitational force (N); $m_1,m_2$ masses (kg); $r$ center-to-center distance (m)',
      units: r'$\mathrm{N} = \mathrm{kg^2\cdot m/(kg\cdot m^2)}$ with $G$ in SI',
    );
  }

  static List<PhysicsFormula> _oscillations(String title) {
    final String t = title.toLowerCase();
    if (t.contains('pendulum')) {
      return _pack(
        name: 'Small-angle pendulum period',
        latex: r'T = 2\pi\sqrt{\frac{L}{g}}',
        symbols: r'$T$ period (s); $L$ length (m); $g$ gravitational acceleration (m/s²)',
        when: 'Valid for small oscillations.',
      );
    }
    if (t.contains('spring') || t.contains('harmonic')) {
      return <PhysicsFormula>[
        const PhysicsFormula(
          name: 'SHM position',
          latex: r'x(t) = A\cos(\omega t + \phi)',
          symbols: r'$A$ amplitude (m); $\omega$ angular frequency (rad/s); $\phi$ phase constant',
        ),
        const PhysicsFormula(
          name: 'Angular frequency (mass–spring)',
          latex: r'\omega = \sqrt{\frac{k}{m}}',
          symbols: r'$k$ spring constant (N/m); $m$ mass (kg)',
        ),
        const PhysicsFormula(
          name: 'Period (mass–spring)',
          latex: r'T = 2\pi\sqrt{\frac{m}{k}}',
          symbols: r'$T$ period (s)',
        ),
      ];
    }
    return _pack(
      name: 'Restoring force (SHM)',
      latex: r'F = -kx \Rightarrow a = -\frac{k}{m}x',
      symbols: r'Acceleration proportional to negative displacement defines SHM.',
    );
  }

  static List<PhysicsFormula> _fluids(String title) {
    final String t = title.toLowerCase();
    if (t.contains('bernoulli')) {
      return _pack(
        name: 'Bernoulli equation (steady, incompressible)',
        latex: r'P + \tfrac{1}{2}\rho v^2 + \rho gh = \text{constant}',
        symbols: r'$P$ pressure (Pa); $\rho$ density (kg/m³); $v$ flow speed (m/s); $h$ height (m)',
      );
    }
    if (t.contains('continuity')) {
      return _pack(
        name: 'Continuity equation',
        latex: r'A_1 v_1 = A_2 v_2',
        symbols: r'$A$ cross-sectional area (m²); $v$ flow speed (m/s); incompressible fluid.',
      );
    }
    if (t.contains('pressure')) {
      return _pack(
        name: 'Hydrostatic pressure',
        latex: r'P = P_0 + \rho gh',
        symbols: r'$P_0$ pressure at surface; $\rho$ fluid density; $h$ depth below surface',
      );
    }
    if (t.contains('archimedes') || t.contains('buoyancy')) {
      return _pack(
        name: 'Archimedes principle',
        latex: r'F_b = \rho_{\mathrm{fluid}} V_{\mathrm{disp}} g',
        symbols: r'$F_b$ buoyant force (N); $V_{\mathrm{disp}}$ displaced volume (m³)',
      );
    }
    return _pack(
      name: 'Density',
      latex: r'\rho = \frac{m}{V}',
      symbols: r'$\rho$ density (kg/m³); $m$ mass (kg); $V$ volume (m³)',
    );
  }

  static List<PhysicsFormula> _thermodynamics(String title) {
    final String t = title.toLowerCase();
    if (t.contains('first law')) {
      return _pack(
        name: 'First law of thermodynamics',
        latex: r'\Delta U = Q - W',
        symbols: r'$\Delta U$ internal energy change (J); $Q$ heat into system (J); $W$ work done by system (J)',
      );
    }
    if (t.contains('ideal') || t.contains('gas')) {
      return _pack(
        name: 'Ideal gas law',
        latex: r'PV = nRT',
        symbols: r'$P$ pressure (Pa); $V$ volume (m³); $n$ moles; $R$ gas constant; $T$ absolute temperature (K)',
      );
    }
    if (t.contains('entropy') || t.contains('second')) {
      return _pack(
        name: 'Second law (entropy statement)',
        latex: r'\Delta S_{\mathrm{universe}} \ge 0',
        symbols: r'Total entropy of an isolated system never decreases.',
      );
    }
    if (t.contains('carnot')) {
      return _pack(
        name: 'Carnot efficiency',
        latex: r'\eta_{\mathrm{Carnot}} = 1 - \frac{T_c}{T_h}',
        symbols: r'$T_h$ hot reservoir temperature (K); $T_c$ cold reservoir temperature (K)',
      );
    }
    return _pack(
      name: 'Thermal expansion (linear)',
      latex: r'\Delta L = \alpha L_0 \Delta T',
      symbols: r'$\alpha$ coefficient of linear expansion (1/K); $\Delta T$ temperature change (K)',
    );
  }

  static List<PhysicsFormula> _statMech(String title) {
    return _pack(
      name: 'Boltzmann entropy',
      latex: r'S = k_B \ln \Omega',
      symbols: r'$S$ entropy (J/K); $k_B$ Boltzmann constant; $\Omega$ number of microstates',
    );
  }

  static List<PhysicsFormula> _waves(String title) {
    final String t = title.toLowerCase();
    if (t.contains('speed') || t.contains('wavelength') || t.contains('frequency')) {
      return _pack(
        name: 'Wave speed',
        latex: r'v = f\lambda',
        symbols: r'$v$ wave speed (m/s); $f$ frequency (Hz); $\lambda$ wavelength (m)',
        units: r'$\mathrm{m/s} = \mathrm{Hz}\cdot\mathrm{m}$',
      );
    }
    if (t.contains('standing')) {
      return _pack(
        name: 'Standing wave (string fixed at both ends)',
        latex: r'f_n = \frac{n v}{2L}, \quad n = 1,2,3,\ldots',
        symbols: r'$L$ string length (m); $n$ harmonic number',
      );
    }
    return _pack(
      name: 'Wave number',
      latex: r'k = \frac{2\pi}{\lambda}',
      symbols: r'$k$ angular wave number (rad/m); $\lambda$ wavelength (m)',
    );
  }

  static List<PhysicsFormula> _acoustics(String title) {
    return _pack(
      name: 'Sound intensity level',
      latex: r'\beta = 10\log_{10}\left(\frac{I}{I_0}\right)\,\mathrm{dB}',
      symbols: r'$I$ intensity (W/m²); $I_0 = 10^{-12}\,\mathrm{W/m^2}$ reference',
    );
  }

  static List<PhysicsFormula> _electrostatics(String title) {
    final String t = title.toLowerCase();
    if (t.contains('coulomb')) {
      return _pack(
        name: "Coulomb's law",
        latex: r'F = k_e\frac{|q_1 q_2|}{r^2}',
        symbols: r'$F$ force (N); $q_1,q_2$ charges (C); $r$ separation (m); $k_e$ Coulomb constant',
      );
    }
    if (t.contains('gauss')) {
      return _pack(
        name: "Gauss's law",
        latex: r'\oint \vec{E}\cdot d\vec{A} = \frac{Q_{\mathrm{enc}}}{\varepsilon_0}',
        symbols: r'$Q_{\mathrm{enc}}$ charge enclosed; $\varepsilon_0$ permittivity of free space',
      );
    }
    return _pack(
      name: 'Electric field definition',
      latex: r'\vec{E} = \frac{\vec{F}}{q}',
      symbols: r'$\vec{E}$ electric field (N/C); $\vec{F}$ force on test charge $q$ (C)',
    );
  }

  static List<PhysicsFormula> _circuits(String title) {
    final String t = title.toLowerCase();
    if (t.contains('ohm')) {
      return _pack(
        name: "Ohm's law",
        latex: r'V = IR',
        symbols: r'$V$ potential difference (V); $I$ current (A); $R$ resistance (Ω)',
        units: r'$\mathrm{V} = \mathrm{A}\cdot\Omega$',
      );
    }
    if (t.contains('series')) {
      return _pack(
        name: 'Series resistance',
        latex: r'R_{\mathrm{eq}} = R_1 + R_2 + \cdots',
        symbols: r'Same current through each series resistor.',
      );
    }
    if (t.contains('parallel')) {
      return _pack(
        name: 'Parallel resistance',
        latex: r'\frac{1}{R_{\mathrm{eq}}} = \frac{1}{R_1} + \frac{1}{R_2} + \cdots',
        symbols: r'Same voltage across each parallel branch.',
      );
    }
    if (t.contains('capacitor')) {
      return _pack(
        name: 'Capacitance',
        latex: r'C = \frac{Q}{V}',
        symbols: r'$C$ capacitance (F); $Q$ stored charge (C); $V$ voltage (V)',
      );
    }
    return _pack(
      name: 'Electrical power',
      latex: r'P = IV = I^2 R = \frac{V^2}{R}',
      symbols: r'$P$ power (W); $I$ current (A); $V$ voltage (V); $R$ resistance (Ω)',
    );
  }

  static List<PhysicsFormula> _magnetism(String title) {
    final String t = title.toLowerCase();
    if (t.contains('force')) {
      return _pack(
        name: 'Magnetic force on moving charge',
        latex: r'\vec{F} = q\vec{v}\times\vec{B}',
        symbols: r'$q$ charge (C); $\vec{v}$ velocity (m/s); $\vec{B}$ magnetic field (T)',
      );
    }
    if (t.contains('hall')) {
      return _pack(
        name: 'Hall voltage',
        latex: r'V_H = \frac{IB}{nqt}',
        symbols: r'$I$ current; $B$ magnetic field; $n$ carrier density; $q$ carrier charge; $t$ thickness',
      );
    }
    return _pack(
      name: 'Biot–Savart / wire field (long straight wire)',
      latex: r'B = \frac{\mu_0 I}{2\pi r}',
      symbols: r'$B$ magnetic field (T); $\mu_0$ permeability of free space; $I$ current (A); $r$ distance (m)',
    );
  }

  static List<PhysicsFormula> _emInduction(String title) {
    return _pack(
      name: "Faraday's law",
      latex: r'\mathcal{E} = -\frac{d\Phi_B}{dt}',
      symbols: r'$\mathcal{E}$ induced emf (V); $\Phi_B$ magnetic flux (Wb); Lenz sign opposes change',
    );
  }

  static List<PhysicsFormula> _maxwell(String title) {
    return <PhysicsFormula>[
      const PhysicsFormula(
        name: 'Gauss (electric)',
        latex: r'\nabla\cdot\vec{E} = \frac{\rho}{\varepsilon_0}',
        symbols: r'$\rho$ charge density',
      ),
      const PhysicsFormula(
        name: 'Gauss (magnetic)',
        latex: r'\nabla\cdot\vec{B} = 0',
        symbols: r'No magnetic monopoles in classical Maxwell theory.',
      ),
      const PhysicsFormula(
        name: 'Faraday',
        latex: r'\nabla\times\vec{E} = -\frac{\partial\vec{B}}{\partial t}',
        symbols: r'Changing $\vec{B}$ induces curling $\vec{E}$.',
      ),
      const PhysicsFormula(
        name: 'Ampère–Maxwell',
        latex: r'\nabla\times\vec{B} = \mu_0\vec{J} + \mu_0\varepsilon_0\frac{\partial\vec{E}}{\partial t}',
        symbols: r'$\vec{J}$ current density; displacement current term.',
      ),
    ];
  }

  static List<PhysicsFormula> _optics(String title) {
    final String t = title.toLowerCase();
    if (t.contains('refraction') || t.contains('snell')) {
      return _pack(
        name: "Snell's law",
        latex: r'n_1\sin\theta_1 = n_2\sin\theta_2',
        symbols: r'$n$ refractive index; $\theta$ angle measured from normal',
      );
    }
    if (t.contains('lens') || t.contains('mirror') || t.contains('image')) {
      return _pack(
        name: 'Thin lens equation',
        latex: r'\frac{1}{f} = \frac{1}{d_o} + \frac{1}{d_i}',
        symbols: r'$f$ focal length; $d_o$ object distance; $d_i$ image distance',
      );
    }
    return _pack(
      name: 'Index of refraction',
      latex: r'n = \frac{c}{v}',
      symbols: r'$c$ speed of light in vacuum; $v$ phase speed in medium',
    );
  }

  static List<PhysicsFormula> _specialRelativity(String title) {
    final String t = title.toLowerCase();
    if (t.contains('mass-energy') || t.contains('equivalence')) {
      return _pack(
        name: 'Mass–energy equivalence',
        latex: r'E = mc^2',
        symbols: r'$E$ rest energy (J); $m$ rest mass (kg); $c$ speed of light',
      );
    }
    if (t.contains('time dilation')) {
      return _pack(
        name: 'Time dilation',
        latex: r'\Delta t = \gamma \Delta t_0, \quad \gamma = \frac{1}{\sqrt{1-v^2/c^2}}',
        symbols: r'$\Delta t_0$ proper time; $v$ relative speed',
      );
    }
    if (t.contains('length contraction')) {
      return _pack(
        name: 'Length contraction',
        latex: r'L = \frac{L_0}{\gamma}',
        symbols: r'$L_0$ proper length; $L$ measured length in frame where object moves at $v$',
      );
    }
    return _pack(
      name: 'Relativistic momentum',
      latex: r'p = \gamma mv',
      symbols: r'$p$ momentum; $m$ rest mass; $v$ speed; $\gamma$ Lorentz factor',
    );
  }

  static List<PhysicsFormula> _generalRelativity(String title) {
    return _pack(
      name: 'Einstein field equations (compact form)',
      latex: r'G_{\mu\nu} + \Lambda g_{\mu\nu} = \frac{8\pi G}{c^4}T_{\mu\nu}',
      symbols: r'$G_{\mu\nu}$ Einstein tensor; $T_{\mu\nu}$ stress–energy; $\Lambda$ cosmological constant',
    );
  }

  static List<PhysicsFormula> _quantum(String title) {
    final String t = title.toLowerCase();
    if (t.contains('schr')) {
      return _pack(
        name: 'Time-dependent Schrödinger equation',
        latex: r'i\hbar\frac{\partial\Psi}{\partial t} = \hat{H}\Psi',
        symbols: r'$\Psi$ wave function; $\hat{H}$ Hamiltonian operator; $\hbar$ reduced Planck constant',
      );
    }
    if (t.contains('de broglie') || t.contains('wave-particle')) {
      return _pack(
        name: 'de Broglie wavelength',
        latex: r'\lambda = \frac{h}{p}',
        symbols: r'$h$ Planck constant; $p$ momentum',
      );
    }
    if (t.contains('uncertainty')) {
      return _pack(
        name: 'Heisenberg uncertainty (position–momentum)',
        latex: r'\Delta x\,\Delta p \ge \frac{\hbar}{2}',
        symbols: r'$\Delta x$, $\Delta p$ standard deviations of measurements',
      );
    }
    return _pack(
      name: 'Planck relation',
      latex: r'E = hf',
      symbols: r'$E$ photon energy (J); $h$ Planck constant; $f$ frequency (Hz)',
    );
  }

  static List<PhysicsFormula> _atomic(String title) {
    return _pack(
      name: 'Hydrogen energy levels (Bohr model)',
      latex: r'E_n = -\frac{13.6\,\mathrm{eV}}{n^2}',
      symbols: r'$n = 1,2,3,\ldots$ principal quantum number',
    );
  }

  static List<PhysicsFormula> _nuclear(String title) {
    final String t = title.toLowerCase();
    if (t.contains('binding')) {
      return _pack(
        name: 'Mass defect / binding energy',
        latex: r'E_b = \Delta m\, c^2',
        symbols: r'$\Delta m$ mass defect; binding energy released when nucleus forms',
      );
    }
    return _pack(
      name: 'Radioactive decay law',
      latex: r'N(t) = N_0 e^{-\lambda t}',
      symbols: r'$N$ number of undecayed nuclei; $\lambda$ decay constant (1/s)',
    );
  }

  static List<PhysicsFormula> _particle(String title) {
    return _pack(
      name: 'Invariant mass (relativistic)',
      latex: r'(mc^2)^2 = E^2 - (pc)^2',
      symbols: r'$m$ invariant mass; $E$ total energy; $p$ momentum',
    );
  }

  static List<PhysicsFormula> _introPhysics(String title) {
    final String t = title.toLowerCase();
    if (t.contains('unit') || t.contains('si')) {
      return _pack(
        name: 'SI base units',
        latex: r'[Q] = \mathrm{kg^{a}\,m^{b}\,s^{c}\,A^{d}\,K^{e}\,mol^{f}\,cd^{g}}',
        symbols: r'Every physical quantity can be expressed with the seven SI base units.',
      );
    }
    if (t.contains('uncertainty') || t.contains('error')) {
      return _pack(
        name: 'Percent uncertainty',
        latex: r'\frac{\delta x}{|x|}\times 100\%',
        symbols: r'$\delta x$ absolute uncertainty in measurement $x$',
      );
    }
    return _pack(
      name: 'Scientific notation',
      latex: r'x = a\times 10^{n}, \quad 1 \le a < 10',
      symbols: r'$a$ mantissa; $n$ integer exponent',
    );
  }

  static List<PhysicsFormula> _mathFoundations(String title) {
    final String t = title.toLowerCase();
    if (t.contains('derivative')) {
      return _pack(
        name: 'Derivative (definition)',
        latex: r'\frac{df}{dx} = \lim_{\Delta x\to 0}\frac{f(x+\Delta x)-f(x)}{\Delta x}',
        symbols: r'Instantaneous rate of change of $f$ with respect to $x$.',
      );
    }
    if (t.contains('integral')) {
      return _pack(
        name: 'Definite integral',
        latex: r'\int_a^b f(x)\,dx = F(b) - F(a)',
        symbols: r'$F$ is an antiderivative of $f$.',
      );
    }
    if (t.contains('vector')) {
      return _pack(
        name: 'Vector magnitude',
        latex: r'|\vec{v}| = \sqrt{v_x^2 + v_y^2 + v_z^2}',
        symbols: r'Components $v_x,v_y,v_z$ in Cartesian coordinates.',
      );
    }
    return _pack(
      name: 'Pythagorean theorem',
      latex: r'c^2 = a^2 + b^2',
      symbols: r'Right triangle with legs $a,b$ and hypotenuse $c$.',
    );
  }

  static List<PhysicsFormula> _keywordFallback(String title) {
    final String t = title.toLowerCase();
    if (t.contains('energy')) {
      return _pack(name: 'Energy', latex: r'E = mc^2 \text{ (rest)}', symbols: r'Or mechanical: $K+U$ for conservative systems.');
    }
    if (t.contains('force')) {
      return _pack(name: 'Force', latex: r'\vec{F} = m\vec{a}', symbols: r'Net force produces acceleration.');
    }
    if (t.contains('wave')) {
      return _pack(name: 'Wave speed', latex: r'v = f\lambda', symbols: r'$v$ speed; $f$ frequency; $\lambda$ wavelength.');
    }
    return <PhysicsFormula>[
      PhysicsFormula(
        name: '$title — definition',
        latex: r'Q = f(x_1, x_2, \ldots)',
        symbols: 'State the physical meaning of $title and list each variable with SI units.',
        whenToUse: 'Start from the definition in AI Professor, then specialize.',
        unitCheck: 'Substitute SI units on both sides before calculating.',
      ),
      const PhysicsFormula(
        name: 'Dimensional consistency',
        latex: r'[Q] = \mathrm{kg^{a}\,m^{b}\,s^{c}\,A^{d}\,K^{e}\,mol^{f}\,cd^{g}}',
        symbols: r'Both sides of any equation must have identical SI dimensions.',
      ),
    ];
  }

  static List<PhysicsFormula> _pack({
    required String name,
    required String latex,
    required String symbols,
    String? when,
    String? units,
  }) =>
      <PhysicsFormula>[
        PhysicsFormula(
          name: name,
          latex: latex,
          symbols: symbols,
          whenToUse: when,
          unitCheck: units,
        ),
      ];
}
