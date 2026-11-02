import '../../models/engineering/engineering_program.dart';

/// Educational engineering outcomes for labs / concepts / simulators.
/// These are teaching models (order-of-magnitude correct), not certified solvers.
class EngineeringLabSnapshot {
  const EngineeringLabSnapshot({
    required this.metrics,
    required this.status,
    required this.statusLevel,
    required this.plainEnglish,
    required this.coachTip,
    required this.whatToTry,
    this.goal,
  });

  final List<EngineeringMetric> metrics;
  final String status;
  final EngineeringStatusLevel statusLevel;
  final String plainEnglish;
  final String coachTip;
  final String whatToTry;
  final String? goal;
}

enum EngineeringStatusLevel { good, caution, danger, idle }

class EngineeringMetric {
  const EngineeringMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    this.goodMin,
    this.goodMax,
  });

  final String id;
  final String label;
  final double value;
  final String unit;
  final double? goodMin;
  final double? goodMax;

  String get display {
    if (value.abs() >= 100) return value.toStringAsFixed(0);
    if (value.abs() >= 10) return value.toStringAsFixed(1);
    return value.toStringAsFixed(2);
  }
}

/// Maps slider inputs → educational physics + coaching for each course.
class EngineeringLabEngine {
  EngineeringLabEngine._();

  static EngineeringLabSnapshot evaluate({
    required EngineeringMajor major,
    required EngineeringCourse course,
    required EngineeringLearningMode mode,
    required Map<String, double> values,
  }) {
    final String key = '${major.id}|${course.id}';
    final EngineeringLabSnapshot base = switch (key) {
      'civil|statics' => _civilStatics(values),
      'civil|structural' => _civilStructural(values),
      'civil|geotech' => _civilGeotech(values),
      'mechanical|mechanics' => _mechMaterials(values),
      'mechanical|thermo' => _mechThermo(values),
      'mechanical|fluids' => _mechFluids(values),
      'electrical|circuits' => _elecCircuits(values),
      'electrical|power' => _elecPower(values),
      'computer|digital' => _compDigital(values),
      'computer|architecture' => _compArch(values),
      'chemical|reactors' => _chemReactors(values),
      'chemical|separations' => _chemSeparations(values),
      'aerospace|aero' => _aeroAero(values),
      'aerospace|propulsion' => _aeroProp(values),
      'biomedical|devices' => _biomed(values),
      'environmental|water' => _envWater(values),
      'industrial|ops' => _industrial(values),
      'materials|metals' => _materials(values),
      'nuclear|reactors' => _nuclear(values),
      'petroleum|drilling' => _petroleum(values),
      _ => _generic(values),
    };

    final String? goal = switch (mode) {
      EngineeringLearningMode.concepts =>
        'Goal: Change one slider at a time. Predict what will happen, then check the metrics.',
      EngineeringLearningMode.virtualLab =>
        'Lab goal: Reach a GOOD status, then deliberately break it and explain why it failed.',
      EngineeringLearningMode.simulator =>
        'Challenge: ${course.simulatorBrief}',
      _ => null,
    };

    return EngineeringLabSnapshot(
      metrics: base.metrics,
      status: base.status,
      statusLevel: base.statusLevel,
      plainEnglish: base.plainEnglish,
      coachTip: base.coachTip,
      whatToTry: base.whatToTry,
      goal: goal,
    );
  }

  static double _n(Map<String, double> v, String id, [double fallback = 0]) => v[id] ?? fallback;

  static EngineeringLabSnapshot _civilStatics(Map<String, double> v) {
    final double loadKn = _n(v, 'load', 80);
    final double depthCm = _n(v, 'depth', 45);
    final double spanM = _n(v, 'span', 20);
    final double depthM = depthCm / 100;
    // Educational bending stress proxy ~ M c / I with rectangular section feel.
    final double moment = loadKn * spanM / 4; // kN·m midspan simply supported
    final double sectionModulus = (1.0 * depthM * depthM) / 6; // m³ proxy (width=1m)
    final double stress = sectionModulus <= 0 ? 999 : moment / sectionModulus; // kPa-ish index
    final double allowable = 120; // educational allowable index
    final double fos = allowable / (stress + 0.01);

    EngineeringStatusLevel level;
    String status;
    if (fos < 1.0) {
      level = EngineeringStatusLevel.danger;
      status = 'FAIL — beam likely yields or collapses';
    } else if (fos < 1.5) {
      level = EngineeringStatusLevel.caution;
      status = 'MARGINAL — too little safety margin for real structures';
    } else if (fos < 2.0) {
      level = EngineeringStatusLevel.caution;
      status = 'ACCEPTABLE for teaching — real bridges often target higher margins';
    } else {
      level = EngineeringStatusLevel.good;
      status = 'SAFE band — good educational factor of safety';
    }

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'moment', label: 'Bending moment (midspan)', value: moment, unit: 'kN·m'),
        EngineeringMetric(id: 'stress', label: 'Stress index', value: stress, unit: '', goodMax: allowable),
        EngineeringMetric(id: 'fos', label: 'Factor of safety', value: fos.clamp(0.1, 10), unit: '', goodMin: 1.5, goodMax: 6),
      ],
      status: status,
      statusLevel: level,
      plainEnglish:
          'A longer span or heavier load increases bending. A deeper beam resists bending much better '
          '(depth helps a lot — roughly with depth²). Factor of safety = how many times stronger the beam is than the load needs.',
      coachTip: fos < 1.5
          ? 'Increase beam depth, shorten the span, or reduce load. Engineers almost never design at FoS ≈ 1.'
          : 'Nice. Now increase load until it turns MARGINAL — that is how you learn the failure boundary.',
      whatToTry: 'Double the span while keeping depth fixed. Watch FoS drop. Then restore FoS by increasing depth.',
    );
  }

  static EngineeringLabSnapshot _civilStructural(Map<String, double> v) {
    final double stories = _n(v, 'stories', 12);
    final double wind = _n(v, 'wind', 25);
    final double damping = _n(v, 'damping', 3);
    final double drift = (stories * wind) / (80 + damping * 25);
    final double limit = 1.0;

    final EngineeringStatusLevel level = drift > 1.6
        ? EngineeringStatusLevel.danger
        : drift > limit
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'drift', label: 'Story drift index', value: drift, unit: '', goodMax: limit),
        EngineeringMetric(id: 'wind_force', label: 'Wind demand', value: stories * wind / 10, unit: ''),
        EngineeringMetric(id: 'damping', label: 'Damping', value: damping, unit: '%'),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'EXCESSIVE DRIFT — cladding/structure at risk'
          : level == EngineeringStatusLevel.caution
              ? 'HIGH DRIFT — stiffen the frame or add damping'
              : 'Drift within teaching limit',
      statusLevel: level,
      plainEnglish:
          'Taller buildings catch more wind. Drift is how much floors sway. Too much sway breaks glass, scares people, and can damage connections. Damping (like tuned mass dampers) soaks up motion.',
      coachTip: drift > limit
          ? 'Add damping or reduce height/wind exposure. In real towers, engineers add shear walls or braces.'
          : 'Push wind higher until drift fails, then “fix” it with damping — that is the design loop.',
      whatToTry: 'Set stories to 30 and wind to 40. Can you recover with damping alone?',
    );
  }

  static EngineeringLabSnapshot _civilGeotech(Map<String, double> v) {
    final double footing = _n(v, 'footing', 1.5);
    final double cohesion = _n(v, 'cohesion', 25);
    final double load = _n(v, 'load', 800);
    final double capacity = cohesion * footing * footing * 12; // educational kN
    final double fos = capacity / (load + 0.01);
    final double settlement = load / (cohesion * footing * 8 + 1);

    final EngineeringStatusLevel level = fos < 1
        ? EngineeringStatusLevel.danger
        : fos < 2
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'capacity', label: 'Bearing capacity', value: capacity, unit: 'kN'),
        EngineeringMetric(id: 'fos', label: 'Bearing FoS', value: fos.clamp(0.1, 12), unit: '', goodMin: 2),
        EngineeringMetric(id: 'settle', label: 'Settlement index', value: settlement, unit: '', goodMax: 5),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'FOUNDATION FAILURE RISK'
          : level == EngineeringStatusLevel.caution
              ? 'LOW MARGIN — enlarge footing or improve soil'
              : 'Foundation capacity OK (teaching model)',
      statusLevel: level,
      plainEnglish:
          'The ground must push up at least as hard as the building pushes down. Wider footings spread the load. Stronger soil (higher cohesion) carries more. Settlement is how much the ground compresses.',
      coachTip: fos < 2
          ? 'Widen the footing or reduce column load. Geotech often targets FoS around 2–3 for bearing.'
          : 'Try weaker soil (lower cohesion) and see how quickly capacity collapses.',
      whatToTry: 'Halve cohesion. Restore safety by changing only footing width.',
    );
  }

  static EngineeringLabSnapshot _mechMaterials(Map<String, double> v) {
    final double torque = _n(v, 'torque', 250); // N·m
    final double diaMm = _n(v, 'diameter', 30);
    final double rpm = _n(v, 'rpm', 1800);
    final double d = diaMm / 1000;
    final double tau = (16 * torque) / (3.14159265 * d * d * d) / 1e6; // MPa
    final double allowable = 80; // educational steel shear allowable MPa
    final double fos = allowable / (tau + 0.01);
    final double powerKw = torque * rpm * 2 * 3.14159265 / 60 / 1000;

    final EngineeringStatusLevel level = fos < 1
        ? EngineeringStatusLevel.danger
        : fos < 1.5
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'tau', label: 'Shear stress', value: tau, unit: 'MPa', goodMax: allowable),
        EngineeringMetric(id: 'fos', label: 'Factor of safety', value: fos.clamp(0.1, 15), unit: '', goodMin: 1.5),
        EngineeringMetric(id: 'power', label: 'Shaft power', value: powerKw, unit: 'kW'),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'SHAFT YIELD RISK — diameter too small for torque'
          : level == EngineeringStatusLevel.caution
              ? 'LOW MARGIN — enlarge shaft or reduce torque'
              : 'Shaft stress in safe teaching band',
      statusLevel: level,
      plainEnglish:
          'Torque twists the shaft. Stress rises fast as diameter shrinks (diameter³ in the denominator). '
          'Power depends on torque × RPM. A thin, high-RPM shaft can transmit power but may be overstressed.',
      coachTip: fos < 1.5
          ? 'Increase diameter first — it is the most powerful lever against torsion stress.'
          : 'Now raise torque until it fails, then recover with diameter. Feel the cubic sensitivity.',
      whatToTry: 'Keep power roughly constant: raise RPM and lower torque. Does stress improve?',
    );
  }

  static EngineeringLabSnapshot _mechThermo(Map<String, double> v) {
    final double tin = _n(v, 'tin', 90);
    final double flow = _n(v, 'flow', 1.2);
    final double area = _n(v, 'area', 12);
    final double effectiveness = (1 - (1 / (1 + area * 0.08 / (flow + 0.1)))).clamp(0.1, 0.95) * 100;
    final double duty = flow * (tin - 30) * 4.2; // educational kW proxy
    final double dp = flow * flow * 2 / (area + 1);

    final EngineeringStatusLevel level = effectiveness < 35
        ? EngineeringStatusLevel.caution
        : dp > 25
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'eff', label: 'Effectiveness', value: effectiveness, unit: '%', goodMin: 40),
        EngineeringMetric(id: 'duty', label: 'Heat duty', value: duty, unit: 'kW'),
        EngineeringMetric(id: 'dp', label: 'Pressure drop index', value: dp, unit: '', goodMax: 20),
      ],
      status: level == EngineeringStatusLevel.caution
          ? 'Tradeoff — more area helps heat transfer but flow/ΔP may hurt'
          : 'Heat exchanger operating in a reasonable teaching window',
      statusLevel: level,
      plainEnglish:
          'Hot fluid gives heat to cold fluid across area. More area usually means better heat transfer. '
          'Higher flow moves more energy but can raise pressure drop (pumps work harder).',
      coachTip: 'Engineers balance effectiveness vs pumping cost. Bigger is not always better.',
      whatToTry: 'Increase flow a lot. Watch duty rise and pressure-drop index rise.',
    );
  }

  static EngineeringLabSnapshot _mechFluids(Map<String, double> v) {
    final double dia = _n(v, 'diameter', 50); // mm
    final double flow = _n(v, 'flow', 8); // L/s
    final double rough = _n(v, 'rough', 0.15);
    final double area = 3.1416 * (dia / 2000) * (dia / 2000);
    final double velocity = (flow / 1000) / (area + 1e-9); // m/s
    final double headLoss = (velocity * velocity) * (1 + rough * 4) / (dia / 50);
    final double power = flow * headLoss / 20;

    final EngineeringStatusLevel level = velocity > 4
        ? EngineeringStatusLevel.caution
        : velocity < 0.5
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'vel', label: 'Velocity', value: velocity, unit: 'm/s', goodMin: 0.8, goodMax: 3.5),
        EngineeringMetric(id: 'hl', label: 'Head loss index', value: headLoss, unit: ''),
        EngineeringMetric(id: 'pump', label: 'Pump power index', value: power, unit: ''),
      ],
      status: velocity > 4
          ? 'HIGH VELOCITY — noise, erosion, big pump bills'
          : velocity < 0.5
              ? 'LOW VELOCITY — solids may settle in real pipes'
              : 'Pipe flow in a typical design band',
      statusLevel: level,
      plainEnglish:
          'For the same flow, a bigger pipe means slower water and usually less friction loss. '
          'Rough pipes waste more energy. Pumps must overcome head loss.',
      coachTip: 'If velocity is wild, change diameter before blaming the pump.',
      whatToTry: 'Cut diameter in half at fixed flow. Watch velocity and head loss jump.',
    );
  }

  static EngineeringLabSnapshot _elecCircuits(Map<String, double> v) {
    final double volts = _n(v, 'voltage', 12);
    final double r = _n(v, 'resistance', 100);
    final double c = _n(v, 'capacitance', 100); // µF
    final double i = volts / (r + 0.001);
    final double p = volts * i;
    final double tauMs = r * c / 1000; // ms educational
    final double wireLimit = 2.0; // A teaching fuse

    final EngineeringStatusLevel level = i > wireLimit
        ? EngineeringStatusLevel.danger
        : i > wireLimit * 0.7
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'i', label: 'Current', value: i, unit: 'A', goodMax: wireLimit),
        EngineeringMetric(id: 'p', label: 'Power', value: p, unit: 'W'),
        EngineeringMetric(id: 'tau', label: 'RC time constant', value: tauMs, unit: 'ms'),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'OVERCURRENT — fuse/breaker would open (or smoke)'
          : level == EngineeringStatusLevel.caution
              ? 'HIGH CURRENT — close to protection trip'
              : 'Circuit within teaching current limit',
      statusLevel: level,
      plainEnglish:
          'Ohm’s law: I = V / R. Higher voltage or lower resistance means more current. '
          'Power (heating) is V×I. The RC time constant says how fast a capacitor charges — bigger R or C means slower.',
      coachTip: i > wireLimit
          ? 'Increase resistance or lower voltage. Never “fix” overcurrent by ignoring protection.'
          : 'Drop R toward 5 Ω and watch current explode — that is a short-circuit lesson.',
      whatToTry: 'Keep power under 5 W while maximizing voltage. What R do you need?',
    );
  }

  static EngineeringLabSnapshot _elecPower(Map<String, double> v) {
    final double load = _n(v, 'load', 120);
    final double gen = _n(v, 'gen', 150);
    final double pf = _n(v, 'pf', 0.9);
    final double reserve = gen - load;
    final double apparent = load / (pf + 0.001);

    final EngineeringStatusLevel level = reserve < 0
        ? EngineeringStatusLevel.danger
        : reserve < 15
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'reserve', label: 'Reserve margin', value: reserve, unit: 'MW', goodMin: 15),
        EngineeringMetric(id: 'apparent', label: 'Apparent power', value: apparent, unit: 'MVA'),
        EngineeringMetric(id: 'pf', label: 'Power factor', value: pf, unit: '', goodMin: 0.9),
      ],
      status: reserve < 0
          ? 'BLACKOUT RISK — demand exceeds generation'
          : reserve < 15
              ? 'TIGHT — little spare generation if a unit trips'
              : 'Grid balanced with healthy reserve (teaching)',
      statusLevel: level,
      plainEnglish:
          'The grid must generate at least as much power as people use, every second. '
          'Reserve margin is spare generation. Low power factor means equipment must handle more current for the same real power.',
      coachTip: reserve < 0
          ? 'Increase generation or shed load. Real operators do both in emergencies.'
          : 'Trip 40 MW of generation (lower gen) and recover by improving PF and cutting load.',
      whatToTry: 'Set load above gen, then restore balance without raising gen above 160.',
    );
  }

  static EngineeringLabSnapshot _compDigital(Map<String, double> v) {
    final double clock = _n(v, 'clock', 50);
    final double latency = _n(v, 'latency', 10);
    final double width = _n(v, 'width', 32);
    final double cycleNs = 1000 / clock;
    final double memDelay = latency * cycleNs;
    final double bandwidth = clock * width / 8; // MB/s educational

    final EngineeringStatusLevel level = memDelay > 400
        ? EngineeringStatusLevel.caution
        : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'cycle', label: 'Clock period', value: cycleNs, unit: 'ns'),
        EngineeringMetric(id: 'mem', label: 'Memory wait', value: memDelay, unit: 'ns', goodMax: 300),
        EngineeringMetric(id: 'bw', label: 'Bus bandwidth', value: bandwidth, unit: 'MB/s'),
      ],
      status: memDelay > 400
          ? 'MEMORY BOUND — CPU spends ages waiting'
          : 'Timing looks balanced for a teaching CPU',
      statusLevel: level,
      plainEnglish:
          'Faster clocks mean shorter cycles, but memory still takes many cycles. '
          'Wider buses move more bits per beat. If memory latency is high, a fast clock mostly waits.',
      coachTip: 'If memory wait dominates, cut latency or widen the bus before cranking clock.',
      whatToTry: 'Max the clock with latency=40. Then fix performance without lowering clock.',
    );
  }

  static EngineeringLabSnapshot _compArch(Map<String, double> v) {
    final double cache = _n(v, 'cache', 64);
    final double ways = _n(v, 'ways', 4);
    final double users = _n(v, 'users', 50);
    final double hitRate = (100 * (1 - 1 / (1 + cache / 20 + ways))).clamp(40, 99);
    final double missPenalty = 40;
    final double cpi = 1 + (1 - hitRate / 100) * missPenalty / 5;
    final double capacity = hitRate * 10 / (1 + users / 80);

    final EngineeringStatusLevel level = cpi > 4 || capacity < 20
        ? EngineeringStatusLevel.caution
        : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'hit', label: 'Cache hit rate', value: hitRate, unit: '%', goodMin: 85),
        EngineeringMetric(id: 'cpi', label: 'Effective CPI', value: cpi, unit: '', goodMax: 3),
        EngineeringMetric(id: 'cap', label: 'Service capacity', value: capacity, unit: '', goodMin: 25),
      ],
      status: capacity < 20
          ? 'OVERLOADED — too many users for this memory system'
          : cpi > 4
              ? 'SLOW — miss penalty dominating'
              : 'Architecture handling the load',
      statusLevel: level,
      plainEnglish:
          'Caches remember recent data so the CPU avoids slow main memory. Bigger / smarter caches raise hit rate. '
          'Misses are expensive. More users amplify every inefficiency.',
      coachTip: 'Raise hit rate before adding servers in this teaching model.',
      whatToTry: 'Set users to 300. Recover capacity using only cache size and associativity.',
    );
  }

  static EngineeringLabSnapshot _chemReactors(Map<String, double> v) {
    final double temp = _n(v, 'temp', 180);
    final double pressure = _n(v, 'pressure', 8);
    final double flow = _n(v, 'flow', 5);
    final double catalyst = _n(v, 'catalyst', 70);
    // Bell-shaped yield around an educational optimum.
    final double tempScore = 100 - (temp - 190).abs() * 0.7;
    final double pressScore = 100 - (pressure - 10).abs() * 3;
    final double yield = ((tempScore * 0.35 + pressScore * 0.2 + catalyst * 0.45) - flow * 1.5).clamp(5, 98);
    final double runaway = ((temp - 250) / 30 + (pressure - 20) / 10).clamp(0, 10);
    final double stability = (100 - runaway * 12 - (flow - 8).abs()).clamp(5, 99);

    final EngineeringStatusLevel level = runaway > 2.5 || stability < 35
        ? EngineeringStatusLevel.danger
        : yield < 45 || stability < 55
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'yield', label: 'Product yield', value: yield, unit: '%', goodMin: 60),
        EngineeringMetric(id: 'stab', label: 'Stability', value: stability, unit: '%', goodMin: 60),
        EngineeringMetric(id: 'runaway', label: 'Runaway risk', value: runaway, unit: '', goodMax: 1.5),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'RUNAWAY RISK — cool down / depressurize / slow feed'
          : level == EngineeringStatusLevel.caution
              ? 'OFF-OPTIMUM — tune temperature and residence (flow)'
              : 'Reactor in a productive, stable window',
      statusLevel: level,
      plainEnglish:
          'Reactions need enough temperature and catalyst activity, but too hot/pressurized can run away. '
          'Very high feed flow shortens time in the reactor (lower conversion). ChemE is always a tradeoff: yield vs safety vs rate.',
      coachTip: runaway > 1.5
          ? 'Lower temperature first, then pressure. Safety before yield.'
          : 'Sweep temperature while watching yield — find the peak, then check stability.',
      whatToTry: 'Max yield without letting runaway risk exceed 1.0.',
    );
  }

  static EngineeringLabSnapshot _chemSeparations(Map<String, double> v) {
    final double reflux = _n(v, 'reflux', 2);
    final double stages = _n(v, 'stages', 15);
    final double feed = _n(v, 'feed', 60);
    final double purity = (55 + stages * 1.4 + reflux * 6 - feed * 0.15).clamp(40, 99.5);
    final double energy = reflux * feed * 0.4 + stages * 0.8;
    final double flood = (feed / (stages + 5) + reflux / 6).clamp(0, 5);

    final EngineeringStatusLevel level = flood > 2.2
        ? EngineeringStatusLevel.danger
        : purity < 90 || energy > 120
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'purity', label: 'Distillate purity', value: purity, unit: '%', goodMin: 95),
        EngineeringMetric(id: 'energy', label: 'Energy use index', value: energy, unit: '', goodMax: 100),
        EngineeringMetric(id: 'flood', label: 'Flooding risk', value: flood, unit: '', goodMax: 1.8),
      ],
      status: flood > 2.2
          ? 'FLOODING — liquid/vapor traffic jam in the column'
          : purity < 95
              ? 'OFF-SPEC — raise stages or reflux (costs energy)'
              : 'On-spec with manageable energy (teaching)',
      statusLevel: level,
      plainEnglish:
          'Distillation separates by boiling differences. More stages and higher reflux usually raise purity, '
          'but reflux costs heat. Too much traffic (feed/reflux) floods the column.',
      coachTip: 'Hit 95% purity at the lowest energy you can. That is real plant optimization.',
      whatToTry: 'Reach ≥95% purity with energy index under 90.',
    );
  }

  static EngineeringLabSnapshot _aeroAero(Map<String, double> v) {
    final double aoa = _n(v, 'aoa', 4);
    final double speed = _n(v, 'speed', 80);
    final double area = _n(v, 'area', 20);
    const double stallAoa = 15;
    final double cl = (0.11 * aoa).clamp(-0.5, 1.5).toDouble();
    final bool stalled = aoa >= stallAoa;
    final double lift = 0.5 * 1.225 * speed * speed * area * (stalled ? cl * 0.35 : cl) / 1000;
    final double cd = 0.02 + 0.04 * cl * cl + (stalled ? 0.2 : 0);
    final double drag = 0.5 * 1.225 * speed * speed * area * cd / 1000;
    final double ld = lift / (drag + 0.001);

    final EngineeringStatusLevel level = stalled
        ? EngineeringStatusLevel.danger
        : ld < 6
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'lift', label: 'Lift', value: lift, unit: 'kN'),
        EngineeringMetric(id: 'drag', label: 'Drag', value: drag, unit: 'kN'),
        EngineeringMetric(id: 'ld', label: 'Lift / Drag', value: ld, unit: '', goodMin: 8),
      ],
      status: stalled
          ? 'STALL — wing no longer holds clean lift; nose drop risk'
          : ld < 8
              ? 'INEFFICIENT — lots of drag for the lift you get'
              : 'Healthy cruise-like L/D for teaching',
      statusLevel: level,
      plainEnglish:
          'Angle of attack tilts the wing into the air. More tilt → more lift, up to a point. '
          'Past stall angle, airflow separates and lift collapses while drag spikes. Speed squared strongly affects forces.',
      coachTip: stalled
          ? 'Reduce angle of attack immediately. Add speed only after the wing is flying again.'
          : 'Find the AoA that maximizes L/D at this speed — that is efficient flight.',
      whatToTry: 'Increase AoA slowly to 18°. Watch stall. Recover without touching wing area.',
    );
  }

  static EngineeringLabSnapshot _aeroProp(Map<String, double> v) {
    final double mix = _n(v, 'mix', 2.5);
    final double pe = _n(v, 'pe', 50);
    final double mdot = _n(v, 'mdot', 8);
    final double mixScore = 100 - (mix - 2.3).abs() * 25;
    final double expansion = 100 - (pe - 40).abs();
    final double thrust = mdot * (mixScore + expansion) / 30;
    final double temp = 800 + mix * 120 + mdot * 8;
    final double isp = 250 + mixScore * 0.4 - (pe - 40).abs() * 0.5;

    final EngineeringStatusLevel level = temp > 2200
        ? EngineeringStatusLevel.danger
        : thrust < 40
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'thrust', label: 'Thrust index', value: thrust, unit: '', goodMin: 50),
        EngineeringMetric(id: 'isp', label: 'Isp index', value: isp, unit: 's'),
        EngineeringMetric(id: 'temp', label: 'Chamber temp index', value: temp, unit: 'K', goodMax: 2100),
      ],
      status: temp > 2200
          ? 'OVERTEMP — chamber materials at risk'
          : thrust < 40
              ? 'LOW THRUST — tune mixture / mass flow'
              : 'Propulsion in a usable teaching band',
      statusLevel: level,
      plainEnglish:
          'Thrust comes from throwing mass out the nozzle fast. Mixture ratio changes flame temperature and efficiency. '
          'Nozzle exit pressure should match outside air for best expansion. Hotter is not always better — engines melt.',
      coachTip: 'Optimize Isp without exceeding the temperature limit.',
      whatToTry: 'Maximize thrust with chamber temp index ≤ 2000.',
    );
  }

  static EngineeringLabSnapshot _biomed(Map<String, double> v) {
    final double flow = _n(v, 'flow', 5);
    final double orifice = _n(v, 'orifice', 3);
    final double stiffness = _n(v, 'stiffness', 4);
    final double gradient = (flow * flow) / (orifice * orifice + 0.1) * stiffness / 4;
    final double regurg = (stiffness * 2 + 1 / orifice).clamp(1, 40);
    final double hemolysis = (gradient / 8 + flow / 3).clamp(0, 20);

    final EngineeringStatusLevel level = gradient > 25 || hemolysis > 10
        ? EngineeringStatusLevel.danger
        : regurg > 18
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'grad', label: 'Pressure gradient', value: gradient, unit: '', goodMax: 15),
        EngineeringMetric(id: 'regurg', label: 'Regurgitation index', value: regurg, unit: '', goodMax: 15),
        EngineeringMetric(id: 'hemo', label: 'Hemolysis risk', value: hemolysis, unit: '', goodMax: 8),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'UNSAFE VALVE — high gradient / blood damage risk'
          : level == EngineeringStatusLevel.caution
              ? 'LEAKY — regurgitation too high'
              : 'Valve hemodynamics acceptable (teaching)',
      statusLevel: level,
      plainEnglish:
          'A heart valve must open enough for blood to pass (low gradient) and close well (low leak). '
          'Too small an opening or too stiff leaflets makes the heart work harder and can damage blood cells.',
      coachTip: 'Clinical design balances opening vs sealing. Improve one metric without wrecking the other.',
      whatToTry: 'Get gradient ≤ 12 and regurgitation ≤ 12 at flow = 5.',
    );
  }

  static EngineeringLabSnapshot _envWater(Map<String, double> v) {
    final double dose = _n(v, 'dose', 25);
    final double contact = _n(v, 'contact', 20);
    final double turbidity = _n(v, 'turbidity', 40);
    final double removal = (100 * (1 - turbidity / (turbidity + dose * contact / 8))).clamp(5, 99);
    final double effluent = turbidity * (1 - removal / 100);
    final double chemicalCost = dose * 0.4;

    final EngineeringStatusLevel level = effluent > 5
        ? EngineeringStatusLevel.caution
        : dose > 60
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'removal', label: 'Turbidity removal', value: removal, unit: '%', goodMin: 85),
        EngineeringMetric(id: 'effluent', label: 'Effluent turbidity', value: effluent, unit: 'NTU', goodMax: 5),
        EngineeringMetric(id: 'cost', label: 'Chemical cost index', value: chemicalCost, unit: ''),
      ],
      status: effluent > 5
          ? 'OFF-SPEC WATER — increase dose or contact time'
          : dose > 60
              ? 'OVERDOSED — works but wasteful / residual risk'
              : 'Treatment meeting teaching turbidity target',
      statusLevel: level,
      plainEnglish:
          'Coagulant sticks tiny particles together so filters can catch them. Dose and contact time both matter. '
          'Dirty influent needs more treatment. Overdosing wastes money and can leave chemicals in the water.',
      coachTip: 'Hit effluent ≤ 5 NTU at the lowest dose you can.',
      whatToTry: 'Influent 150 NTU → still reach ≤ 5 NTU effluent.',
    );
  }

  static EngineeringLabSnapshot _industrial(Map<String, double> v) {
    final double stations = _n(v, 'stations', 6);
    final double takt = _n(v, 'takt', 60);
    final double robots = _n(v, 'robots', 4);
    final double bottleneck = takt * (1 + 1 / (stations + robots * 0.5));
    final double throughput = 3600 / bottleneck;
    final double wip = stations * takt / 40;
    final double utilization = (100 * (1 - robots / (stations + robots + 1))).clamp(40, 98);

    final EngineeringStatusLevel level = throughput < 30
        ? EngineeringStatusLevel.caution
        : wip > 20
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'thruput', label: 'Throughput', value: throughput, unit: 'units/h', goodMin: 40),
        EngineeringMetric(id: 'wip', label: 'WIP index', value: wip, unit: '', goodMax: 15),
        EngineeringMetric(id: 'util', label: 'Labor/robot util.', value: utilization, unit: '%'),
      ],
      status: throughput < 30
          ? 'BOTTLENECKED — line too slow for demand'
          : wip > 15
              ? 'TOO MUCH WIP — inventory hiding problems'
              : 'Line flowing reasonably',
      statusLevel: level,
      plainEnglish:
          'Takt time is the drumbeat of customer demand. If any station is slower, it becomes the bottleneck. '
          'More stations/robots can help, but excess WIP means unfinished work sitting around — expensive and chaotic.',
      coachTip: 'Raise throughput without letting WIP explode.',
      whatToTry: 'Beat 50 units/h with WIP ≤ 12.',
    );
  }

  static EngineeringLabSnapshot _materials(Map<String, double> v) {
    final double temp = _n(v, 'temp', 850);
    final double cool = _n(v, 'cool', 40);
    final double carbon = _n(v, 'carbon', 0.4);
    final double hardness = (carbon * 80 + cool * 0.9 + (temp - 750) * 0.05).clamp(10, 100);
    final double toughness = (100 - hardness * 0.7 + (temp > 900 ? 5 : 0)).clamp(5, 95);
    final double distortion = cool / 25;

    final EngineeringStatusLevel level = hardness > 85 && toughness < 25
        ? EngineeringStatusLevel.caution
        : distortion > 5
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'hard', label: 'Hardness index', value: hardness, unit: ''),
        EngineeringMetric(id: 'tough', label: 'Toughness index', value: toughness, unit: ''),
        EngineeringMetric(id: 'dist', label: 'Distortion risk', value: distortion, unit: '', goodMax: 4),
      ],
      status: hardness > 85 && toughness < 25
          ? 'BRITTLE — hard but may crack in service'
          : distortion > 4
              ? 'FAST QUENCH — warping risk'
              : 'Heat-treat balance looks usable',
      statusLevel: level,
      plainEnglish:
          'Heat treatment changes steel’s microscopic structure. Faster cooling usually hardens more but can reduce toughness and warp parts. '
          'Carbon content strongly affects how hard steel can become.',
      coachTip: 'Aim for both decent hardness and toughness — real parts need both.',
      whatToTry: 'Get hardness ≥ 60 and toughness ≥ 40.',
    );
  }

  static EngineeringLabSnapshot _nuclear(Map<String, double> v) {
    final double rods = _n(v, 'rods', 40);
    final double coolant = _n(v, 'coolant', 80);
    final double demand = _n(v, 'power', 600);
    final double power = ((100 - rods) / 100 * 1100 * coolant / 100).clamp(50, 1200);
    final double imbalance = (power - demand).abs();
    final double temp = 290 + imbalance / 6 + (100 - coolant) * 1.2 + (100 - rods) * 0.15;
    final double margin = 320 - temp;

    final EngineeringStatusLevel level = temp > 330 || margin < 0
        ? EngineeringStatusLevel.danger
        : temp > 310 || imbalance > 80
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'power', label: 'Reactor power', value: power, unit: 'MW'),
        EngineeringMetric(id: 'temp', label: 'Core temp index', value: temp, unit: '°C', goodMax: 310),
        EngineeringMetric(id: 'margin', label: 'Thermal margin', value: margin, unit: '°C', goodMin: 15),
      ],
      status: level == EngineeringStatusLevel.danger
          ? 'CRITICAL — insert rods / raise coolant immediately'
          : level == EngineeringStatusLevel.caution
              ? 'WARNING — match power to demand and keep cooling high'
              : 'NOMINAL — power tracking demand with margin',
      statusLevel: level,
      plainEnglish:
          'Control rods absorb neutrons and lower power when inserted. Coolant removes heat. '
          'If you make more power than you remove, temperature rises. Nuclear engineering prioritizes margins over cleverness.',
      coachTip: temp > 310
          ? 'Safety first: insert rods and/or increase coolant before chasing demand.'
          : 'Match reactor power to demand while keeping thermal margin ≥ 15°C.',
      whatToTry: 'Demand spike to 900 MW — meet it without temp index > 310.',
    );
  }

  static EngineeringLabSnapshot _petroleum(Map<String, double> v) {
    final double angle = _n(v, 'angle', 30);
    final double mud = _n(v, 'mud', 12);
    final double depth = _n(v, 'depth', 2500);
    final double pore = 9 + depth / 800;
    final double fracture = 16 + depth / 2000;
    final double kickRisk = (pore - mud + angle / 50).clamp(0, 10);
    final double lossRisk = (mud - fracture + 1).clamp(0, 10);

    final EngineeringStatusLevel level = kickRisk > 2 || lossRisk > 2
        ? EngineeringStatusLevel.danger
        : kickRisk > 1 || lossRisk > 1
            ? EngineeringStatusLevel.caution
            : EngineeringStatusLevel.good;

    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'pore', label: 'Pore pressure', value: pore, unit: 'ppg'),
        EngineeringMetric(id: 'frac', label: 'Fracture gradient', value: fracture, unit: 'ppg'),
        EngineeringMetric(id: 'kick', label: 'Kick risk', value: kickRisk, unit: '', goodMax: 1),
        EngineeringMetric(id: 'loss', label: 'Loss risk', value: lossRisk, unit: '', goodMax: 1),
      ],
      status: kickRisk > 2
          ? 'KICK RISK — mud too light for formation pressure'
          : lossRisk > 2
              ? 'LOSSES — mud too heavy, may fracture formation'
              : 'Mud window OK (teaching)',
      statusLevel: level,
      plainEnglish:
          'Mud weight must sit in a window: heavier than pore pressure (to prevent kicks) but lighter than fracture pressure (to avoid breaking rock). '
          'Deeper wells and angled wells change the pressures you fight.',
      coachTip: 'Keep mud between pore and fracture with margin on both sides.',
      whatToTry: 'At 4500 m depth, find a mud weight with kick and loss risk both ≤ 1.',
    );
  }

  static EngineeringLabSnapshot _generic(Map<String, double> v) {
    final List<double> vals = v.values.isEmpty ? <double>[1] : v.values.toList();
    final double avg = vals.reduce((a, b) => a + b) / vals.length;
    return EngineeringLabSnapshot(
      metrics: <EngineeringMetric>[
        EngineeringMetric(id: 'avg', label: 'Control average', value: avg, unit: ''),
      ],
      status: 'Adjust controls and observe',
      statusLevel: EngineeringStatusLevel.idle,
      plainEnglish: 'Change one input at a time and watch how outputs move. That habit is half of engineering.',
      coachTip: 'Predict first, then slide.',
      whatToTry: 'Move each slider to min and max once.',
    );
  }
}
