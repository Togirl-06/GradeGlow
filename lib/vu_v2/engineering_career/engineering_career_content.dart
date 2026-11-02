import 'package:flutter/material.dart';

class EngineeringMajor {
  const EngineeringMajor({
    required this.id,
    required this.title,
    required this.facility,
    required this.blurb,
    required this.icon,
    required this.accent,
    this.playable = true,
  });

  final String id;
  final String title;
  final String facility;
  final String blurb;
  final IconData icon;
  final Color accent;
  /// Facility hub + missions are open for play.
  final bool playable;
}

abstract final class EngineeringMajors {
  static const List<EngineeringMajor> all = <EngineeringMajor>[
    EngineeringMajor(
      id: 'mechanical_engineering',
      title: 'Mechanical Engineering',
      facility: 'MechWorks Factory',
      blurb: 'Robotic arms, torque, motion, energy and vibration.',
      icon: Icons.precision_manufacturing_rounded,
      accent: Color(0xFF3B82F6),
    ),
    EngineeringMajor(
      id: 'civil_engineering',
      title: 'Civil Engineering',
      facility: 'Build-a-City District',
      blurb: 'Bridges, loads, foundations and drainage.',
      icon: Icons.apartment_rounded,
      accent: Color(0xFF22C55E),
    ),
    EngineeringMajor(
      id: 'electrical_engineering',
      title: 'Electrical Engineering',
      facility: 'Power Grid Lab',
      blurb: 'Circuits, faults and grid balancing.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFFD97706),
    ),
    EngineeringMajor(
      id: 'chemical_engineering',
      title: 'Chemical Engineering',
      facility: 'Process Plant',
      blurb: 'Material balances, yield and process alarms.',
      icon: Icons.science_rounded,
      accent: Color(0xFFA78BFA),
    ),
    EngineeringMajor(
      id: 'aerospace_engineering',
      title: 'Aerospace Engineering',
      facility: 'FlightWorks Center',
      blurb: 'Lift, drag, thrust and flight scenarios.',
      icon: Icons.flight_takeoff_rounded,
      accent: Color(0xFF8B5CF6),
    ),
    EngineeringMajor(
      id: 'industrial_engineering',
      title: 'Industrial Engineering',
      facility: 'Smart Factory',
      blurb: 'Workflows, bottlenecks and throughput.',
      icon: Icons.factory_rounded,
      accent: Color(0xFF14B8A6),
    ),
  ];

  static EngMission featuredMissionFor(String majorId) {
    final List<EngMission> list = EngMissionCatalog.forMajor(majorId);
    return list.isEmpty ? EngMissionCatalog.roboticArm : list.first;
  }

  static EngineeringMajor byId(String id) => all.firstWhere(
        (EngineeringMajor m) => m.id == id,
        orElse: () => all.first,
      );
}

class EngMission {
  const EngMission({
    required this.id,
    required this.majorId,
    required this.title,
    required this.objective,
    required this.difficulty,
    required this.xpReward,
    required this.hint,
  });

  final String id;
  final String majorId;
  final String title;
  final String objective;
  final String difficulty;
  final int xpReward;
  final String hint;
}

abstract final class EngMissionCatalog {
  static const EngMission roboticArm = EngMission(
    id: 'mech_robotic_arm_v1',
    majorId: 'mechanical_engineering',
    title: 'Robotic arm lift check',
    objective:
        'Configure a conceptual robotic arm to lift 5 kg at horizontal reach '
        'while meeting motor torque and joint strength with a 1.25 safety factor.',
    difficulty: 'Beginner',
    xpReward: 120,
    hint:
        'Required torque ≈ m·g·L. With safety factor 1.25, multiply that result. '
        'Increase motor torque or shorten the arm if you fail.',
  );

  static const EngMission bridge = EngMission(
    id: 'civil_bridge_v1',
    majorId: 'civil_engineering',
    title: 'Conceptual bridge capacity',
    objective:
        'Size a simply-supported deck so midspan capacity meets demand within budget.',
    difficulty: 'Beginner',
    xpReward: 120,
    hint: 'For uniform load, M = wL²/8. Apply safety factor 1.5.',
  );

  static const EngMission circuit = EngMission(
    id: 'ee_series_fault_v1',
    majorId: 'electrical_engineering',
    title: 'Series circuit current limit',
    objective:
        'Choose resistance so current stays under the breaker limit for a given voltage.',
    difficulty: 'Beginner',
    xpReward: 100,
    hint: 'I = V/R. Raise R to lower current.',
  );

  static const EngMission factory = EngMission(
    id: 'ie_bottleneck_v1',
    majorId: 'industrial_engineering',
    title: 'Line bottleneck fix',
    objective:
        'Balance station rates so throughput meets demand within operating budget.',
    difficulty: 'Beginner',
    xpReward: 100,
    hint: 'Throughput equals the slowest station.',
  );

  static const EngMission chemYield = EngMission(
    id: 'chem_yield_v1',
    majorId: 'chemical_engineering',
    title: 'Process yield dial-in',
    objective:
        'Tune fictional reactor temperature and feed to raise yield without '
        'exceeding energy and quality limits (simplified model).',
    difficulty: 'Beginner',
    xpReward: 100,
    hint: 'Higher temperature raises rate but also energy use — find the band.',
  );

  static const EngMission aeroTakeoff = EngMission(
    id: 'aero_takeoff_v1',
    majorId: 'aerospace_engineering',
    title: 'Takeoff performance check',
    objective:
        'Balance wing area and mass so conceptual lift meets takeoff weight '
        'at the design speed (simplified).',
    difficulty: 'Beginner',
    xpReward: 100,
    hint: 'Lift ≈ ½ ρ V² S CL. Keep mass down or increase wing area.',
  );

  static const EngMission mechVibration = EngMission(
    id: 'mech_vibration_v1',
    majorId: 'mechanical_engineering',
    title: 'Vibration envelope check',
    objective:
        'Keep fictional unbalance × RPM product under the alarm limit for a pick-and-place cell.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Lower RPM or reduce unbalance mass — product must stay under the limit.',
  );

  static const EngMission civilDrainage = EngMission(
    id: 'civil_drainage_v1',
    majorId: 'civil_engineering',
    title: 'Drainage capacity sketch',
    objective:
        'Size a conceptual channel so peak runoff stays under capacity with freeboard.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Raise capacity or reduce assumed peak — keep a small freeboard margin.',
  );

  static const EngMission eeParallel = EngMission(
    id: 'ee_parallel_load_v1',
    majorId: 'electrical_engineering',
    title: 'Parallel load current share',
    objective:
        'Pick branch resistance so total current stays under the feeder limit.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Lower R raises current. Keep I_total under the breaker.',
  );

  static const EngMission chemAlarm = EngMission(
    id: 'chem_alarm_v1',
    majorId: 'chemical_engineering',
    title: 'Alarm triage drill',
    objective:
        'Choose the first safe response when temperature and pressure alarms fire together.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Stabilize energy input before chasing secondary indicators.',
  );

  static const EngMission aeroDrag = EngMission(
    id: 'aero_drag_v1',
    majorId: 'aerospace_engineering',
    title: 'Cruise drag trade',
    objective:
        'Balance speed and drag area so required thrust stays within engine limit.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Drag rises with speed squared — lower V or CdA if thrust is short.',
  );

  static const EngMission ieStaffing = EngMission(
    id: 'ie_staffing_v1',
    majorId: 'industrial_engineering',
    title: 'Staffing vs overtime',
    objective:
        'Meet daily demand with station rates and headcount under overtime budget.',
    difficulty: 'Beginner',
    xpReward: 90,
    hint: 'Throughput ≈ rate × people × hours. Watch overtime cost.',
  );

  static List<EngMission> forMajor(String majorId) {
    final List<EngMission> all = <EngMission>[
      roboticArm,
      mechVibration,
      bridge,
      civilDrainage,
      circuit,
      eeParallel,
      factory,
      ieStaffing,
      chemYield,
      chemAlarm,
      aeroTakeoff,
      aeroDrag,
    ];
    return all.where((EngMission m) => m.majorId == majorId).toList();
  }

  static EngMission? byId(String id) {
    for (final EngineeringMajor maj in EngineeringMajors.all) {
      for (final EngMission m in forMajor(maj.id)) {
        if (m.id == id) return m;
      }
    }
    return null;
  }
}

class EngJob {
  const EngJob({
    required this.id,
    required this.title,
    required this.company,
    required this.majorId,
    required this.payLabel,
    required this.blurb,
    required this.skills,
  });

  final String id;
  final String title;
  final String company;
  final String majorId;
  final String payLabel;
  final String blurb;
  final List<String> skills;
}

abstract final class EngJobs {
  static const List<EngJob> all = <EngJob>[
    // Mechanical
    EngJob(
      id: 'apex_mech_junior',
      title: 'Mechanical Design Engineer',
      company: 'Apex Dynamics',
      majorId: 'mechanical_engineering',
      payLabel: '\$30.00 / hour',
      blurb:
          'Fictional employer. Design fixtures and conceptual mechanisms for '
          'factory automation. Validate torque with teaching models on the MechWorks floor.',
      skills: <String>['Statics', 'Torque', 'CAD basics', 'Safety factors'],
    ),
    EngJob(
      id: 'northforge_mech_intern',
      title: 'Mechanical Engineering Intern',
      company: 'Northforge Automation',
      majorId: 'mechanical_engineering',
      payLabel: '\$22.00 / hour',
      blurb:
          'Fictional internship. Support vibration tickets and robotic-arm rebuilds.',
      skills: <String>['Units', 'Debugging', 'Documentation'],
    ),
    EngJob(
      id: 'gearlab_mech_associate',
      title: 'Mechatronics Associate',
      company: 'GearLab Works',
      majorId: 'mechanical_engineering',
      payLabel: '\$26.00 / hour',
      blurb: 'Fictional employer. Fixture redesigns and motion package reviews.',
      skills: <String>['Mechanisms', 'Tolerance', 'Testing'],
    ),
    // Civil
    EngJob(
      id: 'spanline_civil_junior',
      title: 'Junior Civil Engineer',
      company: 'Spanline Civic',
      majorId: 'civil_engineering',
      payLabel: '\$28.00 / hour',
      blurb: 'Fictional employer. Conceptual bridge and foundation studies.',
      skills: <String>['Statics', 'Loads', 'Materials', 'Budgeting'],
    ),
    EngJob(
      id: 'bedrock_civil_intern',
      title: 'Civil Engineering Intern',
      company: 'Bedrock Municipal',
      majorId: 'civil_engineering',
      payLabel: '\$20.00 / hour',
      blurb: 'Fictional internship. Drainage checks and load takeoffs.',
      skills: <String>['Survey basics', 'Spreadsheets', 'Codes intro'],
    ),
    EngJob(
      id: 'archspan_structural_associate',
      title: 'Structural Associate',
      company: 'ArchSpan Partners',
      majorId: 'civil_engineering',
      payLabel: '\$27.00 / hour',
      blurb: 'Fictional employer. Deck capacity studies and constructability notes.',
      skills: <String>['Moments', 'Safety factors', 'Writing'],
    ),
    // Electrical
    EngJob(
      id: 'voltgrid_ee_junior',
      title: 'Junior Electrical Engineer',
      company: 'VoltGrid Systems',
      majorId: 'electrical_engineering',
      payLabel: '\$29.00 / hour',
      blurb: 'Fictional employer. Lab circuits and light-duty distribution.',
      skills: <String>['Ohm\'s law', 'Power', 'Fault finding'],
    ),
    EngJob(
      id: 'sparkline_ee_intern',
      title: 'Electrical Intern',
      company: 'Sparkline Controls',
      majorId: 'electrical_engineering',
      payLabel: '\$21.00 / hour',
      blurb: 'Fictional internship. Panel checks and series/parallel drills.',
      skills: <String>['Circuits', 'Safety', 'Documentation'],
    ),
    EngJob(
      id: 'gridnest_power_associate',
      title: 'Power Systems Associate',
      company: 'GridNest Energy',
      majorId: 'electrical_engineering',
      payLabel: '\$28.00 / hour',
      blurb: 'Fictional employer. Breaker sizing and load studies.',
      skills: <String>['Power', 'Protection', 'Analysis'],
    ),
    // Chemical
    EngJob(
      id: 'chemflow_process_junior',
      title: 'Junior Process Engineer',
      company: 'ChemFlow Labs',
      majorId: 'chemical_engineering',
      payLabel: '\$30.00 / hour',
      blurb: 'Fictional safe process simulator — not hazardous plant training.',
      skills: <String>['Balances', 'Yield', 'Energy'],
    ),
    EngJob(
      id: 'purebatch_chem_intern',
      title: 'Process Intern',
      company: 'PureBatch Sim',
      majorId: 'chemical_engineering',
      payLabel: '\$21.00 / hour',
      blurb: 'Fictional internship. Yield dial-ins and alarm triage.',
      skills: <String>['Mass balance', 'QA', 'Ops'],
    ),
    EngJob(
      id: 'reactorlab_associate',
      title: 'Reactor Lab Associate',
      company: 'ReactorLab Training',
      majorId: 'chemical_engineering',
      payLabel: '\$27.00 / hour',
      blurb: 'Fictional employer. Temperature/feed trade-offs in a teaching model.',
      skills: <String>['Kinetics intro', 'Energy', 'Controls'],
    ),
    // Aerospace
    EngJob(
      id: 'skyforge_aero_junior',
      title: 'Junior Aerospace Engineer',
      company: 'Skyforge FlightWorks',
      majorId: 'aerospace_engineering',
      payLabel: '\$31.00 / hour',
      blurb: 'Fictional employer. Conceptual aircraft trade studies.',
      skills: <String>['Lift', 'Drag', 'Mass properties'],
    ),
    EngJob(
      id: 'liftline_aero_intern',
      title: 'Aerospace Intern',
      company: 'LiftLine Concepts',
      majorId: 'aerospace_engineering',
      payLabel: '\$22.00 / hour',
      blurb: 'Fictional internship. Wing area vs mass takeoff checks.',
      skills: <String>['Aero basics', 'Units', 'Reports'],
    ),
    EngJob(
      id: 'orbitbay_flight_associate',
      title: 'Flight Performance Associate',
      company: 'OrbitBay Sims',
      majorId: 'aerospace_engineering',
      payLabel: '\$29.00 / hour',
      blurb: 'Fictional employer. Simplified takeoff performance packages.',
      skills: <String>['Performance', 'Trade studies', 'Safety'],
    ),
    // Industrial
    EngJob(
      id: 'flowline_ie_junior',
      title: 'Junior Industrial Engineer',
      company: 'Flowline Systems',
      majorId: 'industrial_engineering',
      payLabel: '\$27.00 / hour',
      blurb: 'Fictional employer. Bottlenecks and Smart Factory staffing.',
      skills: <String>['Throughput', 'Scheduling', 'Cost'],
    ),
    EngJob(
      id: 'taktworks_ie_intern',
      title: 'IE Intern',
      company: 'TaktWorks',
      majorId: 'industrial_engineering',
      payLabel: '\$20.00 / hour',
      blurb: 'Fictional internship. Station timing and line balance drills.',
      skills: <String>['Time study', 'Lean basics', 'Excel'],
    ),
    EngJob(
      id: 'pulselane_ops_associate',
      title: 'Ops Excellence Associate',
      company: 'PulseLane Factory',
      majorId: 'industrial_engineering',
      payLabel: '\$26.00 / hour',
      blurb: 'Fictional employer. Throughput targets under budget caps.',
      skills: <String>['Bottlenecks', 'Costing', 'Communication'],
    ),
  ];

  static EngJob? byId(String id) {
    for (final EngJob j in all) {
      if (j.id == id) return j;
    }
    return null;
  }

  static List<EngJob> forMajor(String majorId) =>
      all.where((EngJob j) => j.majorId == majorId).toList();
}
