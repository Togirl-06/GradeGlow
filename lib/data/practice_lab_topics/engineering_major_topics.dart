import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> mechanicalEngineeringMajorTopics = majorTopicAreas(
  majorId: 'mechanical_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'mechanical_core',
      name: 'Mechanical Engineering',
      emoji: '⚙️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'machine_components', name: 'Machine Components', description: 'Select bearings and fasteners for a high-load assembly.', style: SimulationStyle.diagnosis, aiRole: 'Design Engineer'),
        labTopic(id: 'thermodynamics', name: 'Thermodynamics', description: 'Optimize a heat exchanger design for industrial efficiency.', style: SimulationStyle.diagnosis, aiRole: 'Plant Engineer', advanced: true),
        labTopic(id: 'manufacturing', name: 'Manufacturing Systems', description: 'Troubleshoot a production line bottleneck affecting quality.', style: SimulationStyle.customerScenario, aiRole: 'Operations Manager', advanced: true),
      ],
    ),
    (
      id: 'hvac_fluids',
      name: 'HVAC & Fluid Systems',
      emoji: '💨',
      topics: <PracticeLabTopic>[
        labTopic(id: 'fluid_mechanics', name: 'Fluid Mechanics', description: 'Diagnose pressure drops in a piping network.', style: SimulationStyle.diagnosis, aiRole: 'HVAC Engineer'),
        labTopic(id: 'vibration', name: 'Vibration Analysis', description: 'Identify root cause of abnormal machinery vibration.', style: SimulationStyle.diagnosis, aiRole: 'Reliability Engineer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> civilEngineeringMajorTopics = majorTopicAreas(
  majorId: 'civil_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'civil_core',
      name: 'Civil Engineering',
      emoji: '🌉',
      topics: <PracticeLabTopic>[
        labTopic(id: 'surveying', name: 'Surveying', description: 'Interpret survey data and resolve a boundary dispute.', style: SimulationStyle.diagnosis, aiRole: 'Project Manager'),
        labTopic(id: 'structural', name: 'Structural Analysis', description: 'Analyze load paths for a proposed commercial building.', style: SimulationStyle.diagnosis, aiRole: 'Structural Engineer', advanced: true),
        labTopic(id: 'bridge_failure', name: 'Bridge Investigations', description: 'Investigate signs of structural failure before collapse.', style: SimulationStyle.diagnosis, aiRole: 'Safety Inspector', advanced: true),
      ],
    ),
    (
      id: 'infrastructure',
      name: 'Infrastructure & Transportation',
      emoji: '🛣️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'geotechnical', name: 'Geotechnical Engineering', description: 'Assess soil stability for a high-rise foundation.', style: SimulationStyle.diagnosis, aiRole: 'Geotechnical Lead'),
        labTopic(id: 'traffic', name: 'Traffic Engineering', description: 'Redesign an intersection to reduce congestion and accidents.', style: SimulationStyle.systemDesign, aiRole: 'City Traffic Engineer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> electricalEngineeringMajorTopics = majorTopicAreas(
  majorId: 'electrical_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'electrical_core',
      name: 'Electrical Engineering',
      emoji: '⚡',
      topics: <PracticeLabTopic>[
        labTopic(id: 'circuits', name: 'Circuit Analysis', description: 'Debug a failing circuit and explain your troubleshooting process.', style: SimulationStyle.debugging, aiRole: 'Lab Instructor', codeLab: true),
        labTopic(id: 'power_systems', name: 'Power Systems', description: 'Design protection schemes for a distribution substation.', style: SimulationStyle.systemDesign, aiRole: 'Utility Engineer', advanced: true),
        labTopic(id: 'grid_failures', name: 'Grid Failures', description: 'Restore power after a cascading grid failure.', style: SimulationStyle.diagnosis, aiRole: 'Grid Operator', advanced: true),
      ],
    ),
    (
      id: 'electronics',
      name: 'Electronics & Signals',
      emoji: '📡',
      topics: <PracticeLabTopic>[
        labTopic(id: 'signal_processing', name: 'Signal Processing', description: 'Filter noisy sensor data for a control system.', style: SimulationStyle.codingInterview, aiRole: 'Controls Engineer', codeLab: true),
        labTopic(id: 'pcb_design', name: 'PCB Design Review', description: 'Review a PCB layout for EMI and thermal issues.', style: SimulationStyle.diagnosis, aiRole: 'Hardware Lead', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> aerospaceEngineeringMajorTopics = majorTopicAreas(
  majorId: 'aerospace_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'flight_ops',
      name: 'Flight Operations',
      emoji: '✈️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'preflight', name: 'Pre-Flight Checks', description: 'Complete a thorough pre-flight inspection and brief the crew.', style: SimulationStyle.diagnosis, aiRole: 'Captain'),
        labTopic(id: 'weather', name: 'Weather Decisions', description: 'Decide whether to divert around severe weather en route.', style: SimulationStyle.customerScenario, aiRole: 'Dispatcher', advanced: true),
        labTopic(id: 'emergency_landing', name: 'Emergency Landings', description: 'Manage engine failure and prepare for emergency landing.', style: SimulationStyle.erEmergency, aiRole: 'First Officer', advanced: true),
      ],
    ),
    (
      id: 'aero_design',
      name: 'Aerospace Design',
      emoji: '🛩️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'aerodynamics', name: 'Aerodynamics', description: 'Explain stall recovery and wing design trade-offs.', style: SimulationStyle.classroom, aiRole: 'Aerospace Professor'),
        labTopic(id: 'propulsion', name: 'Propulsion Systems', description: 'Diagnose turbine efficiency loss in a jet engine test cell.', style: SimulationStyle.diagnosis, aiRole: 'Propulsion Engineer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> chemicalEngineeringMajorTopics = majorTopicAreas(
  majorId: 'chemical_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'process',
      name: 'Chemical Process Engineering',
      emoji: '⚗️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'reactor_design', name: 'Reactor Design', description: 'Size a reactor for exothermic reaction safety margins.', style: SimulationStyle.diagnosis, aiRole: 'Process Engineer'),
        labTopic(id: 'separation', name: 'Separation Processes', description: 'Optimize distillation columns for purity targets.', style: SimulationStyle.diagnosis, aiRole: 'Plant Manager', advanced: true),
        labTopic(id: 'process_safety', name: 'Process Safety', description: 'Investigate a near-miss chemical release and recommend controls.', style: SimulationStyle.erEmergency, aiRole: 'Safety Officer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> industrialEngineeringMajorTopics = majorTopicAreas(
  majorId: 'industrial_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'industrial_ops',
      name: 'Industrial Engineering',
      emoji: '🏭',
      topics: <PracticeLabTopic>[
        labTopic(id: 'lean', name: 'Lean Manufacturing', description: 'Map value stream and eliminate bottlenecks on a factory floor.', style: SimulationStyle.diagnosis, aiRole: 'Plant Manager'),
        labTopic(id: 'ergonomics', name: 'Ergonomics & Safety', description: 'Redesign a workstation to reduce injury rates.', style: SimulationStyle.diagnosis, aiRole: 'Safety Engineer'),
        labTopic(id: 'simulation', name: 'Operations Simulation', description: 'Model throughput under variable demand scenarios.', style: SimulationStyle.systemDesign, aiRole: 'IE Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> biomedicalEngineeringMajorTopics = majorTopicAreas(
  majorId: 'biomedical_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'medical_devices',
      name: 'Medical Devices',
      emoji: '🫀',
      topics: <PracticeLabTopic>[
        labTopic(id: 'device_design', name: 'Device Design', description: 'Design a wearable monitor meeting FDA usability requirements.', style: SimulationStyle.systemDesign, aiRole: 'Regulatory Affairs'),
        labTopic(id: 'biomaterials', name: 'Biomaterials', description: 'Select implant materials for biocompatibility and durability.', style: SimulationStyle.classroom, aiRole: 'Biomaterials Researcher', advanced: true),
        labTopic(id: 'clinical_validation', name: 'Clinical Validation', description: 'Plan clinical trials for a Class II medical device.', style: SimulationStyle.customerScenario, aiRole: 'Clinical Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> environmentalEngineeringMajorTopics = majorTopicAreas(
  majorId: 'environmental_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'environmental',
      name: 'Environmental Engineering',
      emoji: '🌿',
      topics: <PracticeLabTopic>[
        labTopic(id: 'water_treatment', name: 'Water Treatment', description: 'Design treatment for contaminated groundwater at a Superfund site.', style: SimulationStyle.systemDesign, aiRole: 'Environmental Consultant'),
        labTopic(id: 'air_quality', name: 'Air Quality', description: 'Model emissions dispersion from an industrial facility.', style: SimulationStyle.diagnosis, aiRole: 'EPA Inspector', advanced: true),
        labTopic(id: 'remediation', name: 'Site Remediation', description: 'Choose remediation technology for soil and groundwater pollution.', style: SimulationStyle.diagnosis, aiRole: 'Remediation Engineer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> materialsEngineeringMajorTopics = majorTopicAreas(
  majorId: 'materials_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'materials',
      name: 'Materials Science',
      emoji: '🔬',
      topics: <PracticeLabTopic>[
        labTopic(id: 'material_selection', name: 'Material Selection', description: 'Choose alloys for high-temperature aerospace applications.', style: SimulationStyle.diagnosis, aiRole: 'Materials Scientist'),
        labTopic(id: 'failure_analysis', name: 'Failure Analysis', description: 'Determine fracture cause in a failed structural component.', style: SimulationStyle.diagnosis, aiRole: 'Forensic Metallurgist', advanced: true),
        labTopic(id: 'composites', name: 'Composites', description: 'Design layup schedule for carbon fiber load-bearing parts.', style: SimulationStyle.systemDesign, aiRole: 'Composites Engineer', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> nuclearEngineeringMajorTopics = majorTopicAreas(
  majorId: 'nuclear_engineering',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'nuclear',
      name: 'Nuclear Engineering',
      emoji: '☢️',
      topics: <PracticeLabTopic>[
        labTopic(id: 'reactor_physics', name: 'Reactor Physics', description: 'Explain reactivity control and neutron flux in PWR operations.', style: SimulationStyle.classroom, aiRole: 'Senior Reactor Operator'),
        labTopic(id: 'radiation_safety', name: 'Radiation Safety', description: 'Respond to an alarm in a controlled radiation area.', style: SimulationStyle.erEmergency, aiRole: 'Health Physicist', advanced: true),
        labTopic(id: 'waste_management', name: 'Nuclear Waste', description: 'Evaluate storage options for spent fuel assemblies.', style: SimulationStyle.systemDesign, aiRole: 'Nuclear Regulator', advanced: true),
      ],
    ),
  ],
);

final Map<String, List<PracticeLabTopicArea>> engineeringTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'mechanical_engineering': mechanicalEngineeringMajorTopics,
  'civil_engineering': civilEngineeringMajorTopics,
  'electrical_engineering': electricalEngineeringMajorTopics,
  'aerospace_engineering': aerospaceEngineeringMajorTopics,
  'chemical_engineering': chemicalEngineeringMajorTopics,
  'industrial_engineering': industrialEngineeringMajorTopics,
  'biomedical_engineering': biomedicalEngineeringMajorTopics,
  'environmental_engineering': environmentalEngineeringMajorTopics,
  'materials_engineering': materialsEngineeringMajorTopics,
  'nuclear_engineering': nuclearEngineeringMajorTopics,
};
