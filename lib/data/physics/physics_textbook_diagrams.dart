/// ASCII diagrams and graph templates for physics textbook chapters.
class PhysicsTextbookDiagrams {
  PhysicsTextbookDiagrams._();

  static String gallery({
    required String courseId,
    required String topicTitle,
    required String topicLower,
  }) {
    final StringBuffer buf = StringBuffer()
      ..writeln('Each diagram below is a model you should be able to sketch from memory and interpret quantitatively.')
      ..writeln();

    for (final String block in _diagramsFor(courseId, topicLower, topicTitle)) {
      buf.writeln(block);
      buf.writeln();
    }

    buf.writeln('**How to read any graph in this course**');
    buf.writeln('1. Label both axes with quantity **and** SI unit.');
    buf.writeln('2. Identify **slope** (rate of change of y with respect to x).');
    buf.writeln('3. Identify **area under the curve** when it represents a physical accumulation (e.g., displacement from v–t).');
    buf.writeln('4. State whether the graph assumes constant conditions or an idealized model.');

    return buf.toString().trim();
  }

  static List<String> _diagramsFor(String courseId, String tl, String title) {
    if (_mechanics(courseId) || tl.contains('motion') || tl.contains('velocity') || tl.contains('speed') || tl.contains('acceleration')) {
      return <String>[
        _labeled('Position–time graph', _positionTime),
        _labeled('Velocity–time graph', _velocityTime),
        _labeled('Acceleration–time graph', _accelerationTime),
        _labeled('Vector on a coordinate axis', _vectorAxis(title)),
        _labeled('Motion along a straight track', _linearTrack),
      ];
    }
    if (courseId.contains('circuit') || courseId.contains('electro') || tl.contains('resist') || tl.contains('current')) {
      return <String>[
        _labeled('Series circuit schematic', _seriesCircuit),
        _labeled('V–I characteristic (Ohm\'s law)', _viCharacteristic),
        _labeled('Power dissipation in a resistor', _powerResistor),
      ];
    }
    if (courseId == 'optics' || tl.contains('lens') || tl.contains('light') || tl.contains('mirror')) {
      return <String>[
        _labeled('Ray diagram — convex lens', _convexLens),
        _labeled('Telescope optical layout', _telescope),
      ];
    }
    if (courseId.contains('thermo') || tl.contains('heat') || tl.contains('energy')) {
      return <String>[
        _labeled('Energy bar chart', _energyBar),
        _labeled('PV diagram (thermodynamics)', _pvDiagram),
      ];
    }
    if (courseId.contains('wave') || courseId.contains('acoust') || tl.contains('wave')) {
      return <String>[
        _labeled('Sinusoidal wave', _sinWave),
        _labeled('Standing wave on a string', _standingWave),
      ];
    }
    return <String>[
      _labeled('System schematic for $title', _genericSystem(title)),
      _labeled('Cause → effect flow', _causeEffect(title)),
    ];
  }

  static String _labeled(String caption, String art) =>
      '### Diagram: $caption\n\n```\n$art\n```';

  static bool _mechanics(String id) => <String>{
        'kinematics',
        'newtonian_mechanics',
        'work_energy_power',
        'momentum_collisions',
        'rotational_mechanics',
        'gravitation',
        'oscillations',
        'fluid_mechanics',
      }.contains(id);

  static const String _positionTime = r'''
Position x (m)
    ^
 40 |              *
 30 |           *
 20 |        *
 10 |     *
  0 +--+--+--+--+---> Time t (s)
    0  1  2  3  4

Slope Δx/Δt = average velocity.
''';

  static const String _velocityTime = r'''
Velocity v (m/s)
    ^
 20 |  ****************  constant v
 10 |
  0 +--------------------> Time t (s)
    0    1    2    3    4

Slope = acceleration. Area under curve = displacement.
''';

  static const String _accelerationTime = r'''
Acceleration a (m/s²)
    ^
  4 |  ****************  constant a
  2 |
  0 +--------------------> Time t (s)
    0    1    2    3    4

Slope = jerk (rate of change of a). Area under curve = change in velocity Δv.
''';

  static String _vectorAxis(String title) => '''
        +y
         ^
         |     v (arrow)
         |    /
         |   /  magnitude |v|
         |  /
         +-----------> +x

Topic: $title — always state direction with magnitude.
''';

  static const String _linearTrack = r'''
Start          Motion --->
[====|==================|====] Track
  O                 x(t)

Place origin O, choose + direction, record x at each clock reading.
''';

  static const String _seriesCircuit = r'''
    +---[ Battery 9V ]---+
    |                    |
   [R]                  (LED)
    |                    |
    +--------------------+

Current same in series. Sum of voltage drops = battery voltage.
''';

  static const String _viCharacteristic = r'''
Current I (A)
    ^
    |        /
    |       /  slope = 1/R
    |      /
    +------------> Voltage V (V)

Linear region: Ohm's law V = IR.
''';

  static const String _powerResistor = r'''
Power P = IV = I²R = V²/R

High current + low R  -->  hot resistor (check rating!)
''';

  static const String _convexLens = r'''
Object        Lens         Image
  *             ()            *
  |             ||            |
  +-------------++------------+  optical axis
                f             2f

Object beyond f: real, inverted image possible.
''';

  static const String _telescope = r'''
Distant object ====>  ( Objective )====( Eyepiece )====> Eye
                           f_obj            f_eye

Angular magnification ~ f_obj / f_eye
''';

  static const String _energyBar = r'''
PE (top)  |████████████| 100%
          |            |
KE (bottom)|░░░░░░░░░░|  0%   (released from rest)

As object falls: PE bar shrinks, KE bar grows (if friction small).
''';

  static const String _pvDiagram = r'''
Pressure P
    ^
    |  *---*
    | |     \
    | |      *---*
    +--------------> Volume V

Closed cycle: net work = area enclosed.
''';

  static const String _sinWave = r'''
Displacement
    ^     *
    |    * *
    |   *   *
----+--*-----*----> x
    | *       *
    |*         *

Wavelength λ = distance between identical points on wave.
''';

  static const String _standingWave = r'''
Fixed ends: * nodes (no motion)  * antinodes (max amplitude)

|N|   |A|   |N|   |A|   |N|
''';

  static String _genericSystem(String title) => '''
Inputs  --->  [ $title system ]  --->  Measurable outputs
              (model assumptions listed)
''';

  static String _causeEffect(String title) => '''
Cause (change one variable in $title)
   |
   v
Physical mechanism (use definitions from Section 3)
   |
   v
Predicted effect (quantitative, with units)
''';
}
