import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';

const List<PracticeLabTopicArea> engineeringTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'civil_engineering',
    name: 'Civil Engineering',
    emoji: '🌉',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'surveying', name: 'Surveying', description: 'Interpret survey data and resolve a boundary dispute.', style: SimulationStyle.diagnosis, aiRole: 'Project Manager'),
      PracticeLabTopic(id: 'structural_analysis', name: 'Structural Analysis', description: 'Analyze load paths for a proposed commercial building.', style: SimulationStyle.diagnosis, aiRole: 'Structural Engineer', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'bridge_failure', name: 'Bridge Failure Investigations', description: 'Investigate signs of structural failure before collapse.', style: SimulationStyle.diagnosis, aiRole: 'Safety Inspector', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'mechanical_engineering',
    name: 'Mechanical Engineering',
    emoji: '⚙️',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'machine_components', name: 'Machine Components', description: 'Select bearings and fasteners for a high-load assembly.', style: SimulationStyle.diagnosis, aiRole: 'Design Engineer'),
      PracticeLabTopic(id: 'thermodynamics', name: 'Thermodynamics', description: 'Optimize a heat exchanger design for industrial efficiency.', style: SimulationStyle.diagnosis, aiRole: 'Plant Engineer', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'manufacturing_systems', name: 'Manufacturing Systems', description: 'Troubleshoot a production line bottleneck affecting quality.', style: SimulationStyle.customerScenario, aiRole: 'Operations Manager', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'electrical_engineering',
    name: 'Electrical Engineering',
    emoji: '⚡',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'circuits', name: 'Circuits', description: 'Debug a failing circuit and explain your troubleshooting process.', style: SimulationStyle.debugging, aiRole: 'Lab Instructor', codeLab: true),
      PracticeLabTopic(id: 'power_systems', name: 'Power Systems', description: 'Design protection schemes for a distribution substation.', style: SimulationStyle.systemDesign, aiRole: 'Utility Engineer', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'grid_failures', name: 'Grid Failures', description: 'Restore power after a cascading grid failure.', style: SimulationStyle.diagnosis, aiRole: 'Grid Operator', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];

const List<PracticeLabTopicArea> aviationTopicAreas = <PracticeLabTopicArea>[
  PracticeLabTopicArea(
    id: 'flight_operations',
    name: 'Flight Operations',
    emoji: '✈️',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'preflight_checks', name: 'Pre-Flight Checks', description: 'Complete a thorough pre-flight inspection and brief the crew.', style: SimulationStyle.diagnosis, aiRole: 'Captain'),
      PracticeLabTopic(id: 'weather_decisions', name: 'Weather Decisions', description: 'Decide whether to divert around severe weather en route.', style: SimulationStyle.customerScenario, aiRole: 'Dispatcher', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'emergency_landings', name: 'Emergency Landings', description: 'Manage an engine failure and prepare for emergency landing.', style: SimulationStyle.erEmergency, aiRole: 'First Officer', beginner: false, intermediate: true, advanced: true),
    ],
  ),
  PracticeLabTopicArea(
    id: 'air_traffic_control',
    name: 'Air Traffic Control',
    emoji: '🗼',
    topics: <PracticeLabTopic>[
      PracticeLabTopic(id: 'traffic_sequencing', name: 'Traffic Sequencing', description: 'Sequence arriving aircraft during peak traffic volume.', style: SimulationStyle.diagnosis, aiRole: 'Tower Controller'),
      PracticeLabTopic(id: 'weather_disruptions', name: 'Weather Disruptions', description: 'Reroute traffic when a thunderstorm closes a major approach.', style: SimulationStyle.diagnosis, aiRole: 'Center Controller', beginner: true, intermediate: true, advanced: true),
      PracticeLabTopic(id: 'airspace_emergencies', name: 'Airspace Emergencies', description: 'Handle a lost-communication aircraft in congested airspace.', style: SimulationStyle.erEmergency, aiRole: 'Supervisor', beginner: false, intermediate: true, advanced: true),
    ],
  ),
];
