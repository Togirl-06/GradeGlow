import 'package:flutter/material.dart';

import '../../models/engineering/engineering_program.dart';

/// Engineering Faculty catalog — majors, courses, labs, simulators, capstones.
class EngineeringCatalog {
  EngineeringCatalog._();

  static const String philosophy =
      'Learn → Understand → Simulate → Design → Build → Test → Fail → Improve → Present';

  static List<EngineeringMajor> get majors => _majors;

  static EngineeringMajor? majorById(String id) {
    for (final EngineeringMajor m in _majors) {
      if (m.id == id) return m;
    }
    return null;
  }

  static EngineeringCourse? courseById({required String majorId, required String courseId}) {
    final EngineeringMajor? major = majorById(majorId);
    if (major == null) return null;
    for (final EngineeringCourse c in major.courses) {
      if (c.id == courseId) return c;
    }
    return null;
  }

  static int get majorCount => _majors.length;

  static int get courseCount =>
      _majors.fold<int>(0, (int sum, EngineeringMajor m) => sum + m.courses.length);

  static const List<EngineeringMajor> _majors = <EngineeringMajor>[
    EngineeringMajor(
      id: 'civil',
      name: 'Civil Engineering',
      tagline: 'Bridges, buildings, roads, and infrastructure that must survive the real world.',
      icon: Icons.apartment_outlined,
      emoji: '🏗',
      gameplay: <String>['Bridge Builder', 'Earthquake Simulator', 'Concrete Lab', 'Foundation Designer', 'Traffic Planner'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'statics',
          title: 'Statics',
          blurb: 'Forces, equilibrium, and free-body diagrams — the language of structures.',
          topics: <String>['What is a force?', 'Balanced forces', 'Free body diagrams', 'Moments', 'Equilibrium', 'Trusses', 'Real bridge example'],
          labTitle: 'Concrete Mix Lab',
          labDescription: 'Change water–cement ratio and aggregate. Watch compressive strength after curing.',
          simulatorTitle: 'Bridge Load Challenge',
          simulatorBrief: 'Design a simple span. Apply traffic, wind, and an earthquake. Does it survive?',
          capstoneTitle: 'Design a pedestrian bridge',
          capstoneStages: <String>['Research', 'Planning', 'Calculations', 'Simulation', 'Safety Review', 'Cost Analysis', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'load', label: 'Applied load', unit: 'kN', min: 10, max: 500, initial: 80),
            EngineeringControlSpec(id: 'depth', label: 'Beam depth', unit: 'cm', min: 20, max: 120, initial: 45),
            EngineeringControlSpec(id: 'span', label: 'Span length', unit: 'm', min: 5, max: 60, initial: 20),
          ],
        ),
        EngineeringCourse(
          id: 'structural',
          title: 'Structural Analysis',
          blurb: 'How loads travel through beams, frames, and foundations.',
          topics: <String>['Load paths', 'Shear & moment', 'Deflection', 'Indeterminate structures', 'Steel vs concrete', 'Failure modes'],
          labTitle: 'Earthquake Shake Table',
          labDescription: 'Build a frame, set base acceleration, and watch story drift and collapse risk.',
          simulatorTitle: 'Skyscraper Survival',
          simulatorBrief: 'Design a mid-rise. Run wind and seismic events. Optimize mass and stiffness.',
          capstoneTitle: 'Airport terminal structure',
          capstoneStages: <String>['Site constraints', 'Structural scheme', 'Analysis', 'Detailing', 'Code check', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'stories', label: 'Stories', unit: '', min: 2, max: 40, initial: 12),
            EngineeringControlSpec(id: 'wind', label: 'Wind speed', unit: 'm/s', min: 10, max: 60, initial: 25),
            EngineeringControlSpec(id: 'damping', label: 'Damping', unit: '%', min: 1, max: 8, initial: 3),
          ],
        ),
        EngineeringCourse(
          id: 'geotech',
          title: 'Geotechnical Engineering',
          blurb: 'Soil, foundations, and what happens when the ground moves.',
          topics: <String>['Soil types', 'Bearing capacity', 'Settlement', 'Retaining walls', 'Slope stability'],
          labTitle: 'Foundation Bearing Lab',
          labDescription: 'Change footing size and soil strength. Measure settlement under load.',
          simulatorTitle: 'Slope Failure Scenario',
          simulatorBrief: 'Plan excavation near a hillside. Prevent collapse under rain infiltration.',
          capstoneTitle: 'High-rise foundation system',
          capstoneStages: <String>['Soil report', 'Foundation options', 'Settlement check', 'Cost', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'footing', label: 'Footing width', unit: 'm', min: 0.5, max: 5, initial: 1.5, step: 0.1),
            EngineeringControlSpec(id: 'cohesion', label: 'Soil cohesion', unit: 'kPa', min: 5, max: 100, initial: 25),
            EngineeringControlSpec(id: 'load', label: 'Column load', unit: 'kN', min: 100, max: 5000, initial: 800),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'mechanical',
      name: 'Mechanical Engineering',
      tagline: 'Machines, heat, motion, and systems that move the world.',
      icon: Icons.precision_manufacturing_outlined,
      emoji: '⚙',
      gameplay: <String>['Gearbox Builder', 'Engine Simulator', 'Robot Designer', 'HVAC Design', 'Stress Analysis'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'mechanics',
          title: 'Mechanics of Materials',
          blurb: 'Stress, strain, and why parts bend, crack, or survive.',
          topics: <String>['Stress & strain', 'Axial loading', 'Torsion', 'Bending', 'Combined loading', 'Failure theories'],
          labTitle: 'Shaft Torque Lab',
          labDescription: 'Increase torque on a shaft. Watch twist, stress, and the onset of yield.',
          simulatorTitle: 'Gearbox Durability Run',
          simulatorBrief: 'Design a transmission. Check heat, stress, noise, wear, and efficiency.',
          capstoneTitle: 'Robotic arm joint design',
          capstoneStages: <String>['Requirements', 'Kinematics', 'Strength check', 'Prototype sim', 'Safety', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'torque', label: 'Torque', unit: 'N·m', min: 10, max: 2000, initial: 250),
            EngineeringControlSpec(id: 'diameter', label: 'Shaft diameter', unit: 'mm', min: 10, max: 80, initial: 30),
            EngineeringControlSpec(id: 'rpm', label: 'RPM', unit: 'rpm', min: 100, max: 6000, initial: 1800),
          ],
        ),
        EngineeringCourse(
          id: 'thermo',
          title: 'Thermodynamics',
          blurb: 'Energy, cycles, and the limits of converting heat into work.',
          topics: <String>['First law', 'Second law', 'Entropy', 'Power cycles', 'Refrigeration', 'Exergy'],
          labTitle: 'Heat Exchanger Lab',
          labDescription: 'Adjust flow rates and inlet temperatures. Track effectiveness and pressure drop.',
          simulatorTitle: 'Engine Cycle Optimizer',
          simulatorBrief: 'Tune compression ratio and fuel mix. Maximize efficiency without knocking.',
          capstoneTitle: 'Compact HVAC system',
          capstoneStages: <String>['Load calc', 'Cycle selection', 'Sizing', 'Energy use', 'Cost', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'tin', label: 'Hot inlet T', unit: '°C', min: 40, max: 200, initial: 90),
            EngineeringControlSpec(id: 'flow', label: 'Mass flow', unit: 'kg/s', min: 0.1, max: 5, initial: 1.2, step: 0.1),
            EngineeringControlSpec(id: 'area', label: 'Area', unit: 'm²', min: 1, max: 50, initial: 12),
          ],
        ),
        EngineeringCourse(
          id: 'fluids',
          title: 'Fluid Mechanics',
          blurb: 'Pressure, flow, pumps, and the forces fluids exert on machines.',
          topics: <String>['Fluid statics', 'Bernoulli', 'Pipe flow', 'Pumps', 'Boundary layers', 'Drag & lift'],
          labTitle: 'Pipe Network Lab',
          labDescription: 'Change diameter and roughness. Measure head loss and pump power.',
          simulatorTitle: 'Plant Cooling Loop',
          simulatorBrief: 'Keep equipment cool under varying load without cavitation or overflow.',
          capstoneTitle: 'Go-kart cooling & drivetrain fluids',
          capstoneStages: <String>['Specs', 'Flow design', 'Pump select', 'Test', 'Iterate', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'diameter', label: 'Pipe diameter', unit: 'mm', min: 10, max: 200, initial: 50),
            EngineeringControlSpec(id: 'flow', label: 'Flow rate', unit: 'L/s', min: 0.5, max: 40, initial: 8, step: 0.5),
            EngineeringControlSpec(id: 'rough', label: 'Roughness', unit: 'mm', min: 0.01, max: 2, initial: 0.15, step: 0.01),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'electrical',
      name: 'Electrical Engineering',
      tagline: 'Circuits, power, signals, and systems that keep cities alive.',
      icon: Icons.electrical_services_outlined,
      emoji: '⚡',
      gameplay: <String>['Circuit Builder', 'Power Grid Simulator', 'PCB Designer', 'Motor Lab', 'Oscilloscope Lab'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'circuits',
          title: 'Circuit Analysis',
          blurb: 'Voltage, current, and the rules that keep electronics from smoking.',
          topics: <String>['Ohm\'s law', 'Kirchhoff', 'Thevenin', 'AC phasors', 'Filters', 'Transients'],
          labTitle: 'Breadboard & Scope Lab',
          labDescription: 'Wire RC circuits, power them, measure waveforms. Overload and watch protection trip.',
          simulatorTitle: 'City Power Grid',
          simulatorBrief: 'Demand spikes every minute. Generators fail. Stabilize the grid.',
          capstoneTitle: 'Solar farm + EV charging network',
          capstoneStages: <String>['Load study', 'Topology', 'Protection', 'Simulation', 'Safety', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'voltage', label: 'Source V', unit: 'V', min: 1, max: 48, initial: 12),
            EngineeringControlSpec(id: 'resistance', label: 'Load R', unit: 'Ω', min: 1, max: 1000, initial: 100),
            EngineeringControlSpec(id: 'capacitance', label: 'C', unit: 'µF', min: 1, max: 1000, initial: 100),
          ],
        ),
        EngineeringCourse(
          id: 'power',
          title: 'Power Systems',
          blurb: 'Generation, transmission, and keeping lights on when demand swings.',
          topics: <String>['Three-phase', 'Transformers', 'Faults', 'Protection', 'Power factor', 'Stability'],
          labTitle: 'Motor Dyno Lab',
          labDescription: 'Vary load torque. Measure current, speed, efficiency, and heating.',
          simulatorTitle: 'Blackout Recovery',
          simulatorBrief: 'Restore a regional grid after cascading outages without overloading lines.',
          capstoneTitle: 'Smart home energy system',
          capstoneStages: <String>['Audit', 'Architecture', 'Controls', 'Safety', 'Cost', 'Demo'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'load', label: 'Load', unit: 'MW', min: 10, max: 500, initial: 120),
            EngineeringControlSpec(id: 'gen', label: 'Generation', unit: 'MW', min: 50, max: 600, initial: 150),
            EngineeringControlSpec(id: 'pf', label: 'Power factor', unit: '', min: 0.7, max: 1.0, initial: 0.9, step: 0.01),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'computer',
      name: 'Computer Engineering',
      tagline: 'Hardware meets software — from gates to systems under load.',
      icon: Icons.memory_outlined,
      emoji: '💻',
      gameplay: <String>['CPU Builder', 'Logic Gate Simulator', 'Memory Debugger', 'Embedded Programming', 'Robot Controller'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'digital',
          title: 'Digital Logic',
          blurb: 'Gates, timing, and the building blocks of every processor.',
          topics: <String>['Boolean algebra', 'Combinational logic', 'Flip-flops', 'FSMs', 'Timing', 'Hazards'],
          labTitle: 'Logic Gate Bench',
          labDescription: 'Assemble combinational circuits. Probe timing diagrams and race conditions.',
          simulatorTitle: 'CPU Pipeline Challenge',
          simulatorBrief: 'Design a simple pipeline. Measure CPI under hazards and cache misses.',
          capstoneTitle: 'Embedded device + firmware',
          capstoneStages: <String>['Spec', 'Architecture', 'RTL/logic', 'Firmware', 'Test', 'Demo'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'clock', label: 'Clock', unit: 'MHz', min: 1, max: 200, initial: 50),
            EngineeringControlSpec(id: 'latency', label: 'Memory latency', unit: 'cycles', min: 1, max: 40, initial: 10),
            EngineeringControlSpec(id: 'width', label: 'Bus width', unit: 'bits', min: 8, max: 64, initial: 32, step: 8),
          ],
        ),
        EngineeringCourse(
          id: 'architecture',
          title: 'Computer Architecture',
          blurb: 'Caches, pipelines, and why some designs scale while others stall.',
          topics: <String>['ISA', 'Pipelines', 'Caches', 'Memory hierarchy', 'Parallelism', 'Performance'],
          labTitle: 'Cache Miss Lab',
          labDescription: 'Change cache size and associativity. Watch hit rate and miss penalty.',
          simulatorTitle: 'Server Scale Storm',
          simulatorBrief: 'Millions of users connect. Can your architecture survive?',
          capstoneTitle: 'Mini OS / scheduler project',
          capstoneStages: <String>['Requirements', 'Design', 'Implementation plan', 'Benchmarks', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'cache', label: 'Cache size', unit: 'KB', min: 8, max: 1024, initial: 64),
            EngineeringControlSpec(id: 'ways', label: 'Associativity', unit: 'ways', min: 1, max: 16, initial: 4),
            EngineeringControlSpec(id: 'users', label: 'Concurrent users', unit: 'k', min: 1, max: 500, initial: 50),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'chemical',
      name: 'Chemical Engineering',
      tagline: 'Reactions, separations, and plants that turn molecules into products.',
      icon: Icons.opacity_outlined,
      emoji: '🧪',
      gameplay: <String>['Chemical Plant Builder', 'Distillation Simulator', 'Reactor Control', 'Pipeline Design', 'Explosion Prevention'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'reactors',
          title: 'Reaction Engineering',
          blurb: 'Rate, yield, and keeping reactors productive without runaway.',
          topics: <String>['Kinetics', 'Batch vs continuous', 'Residence time', 'Catalysts', 'Heat effects', 'Safety'],
          labTitle: 'CSTR Control Lab',
          labDescription: 'Adjust temperature, pressure, catalyst, and flow. Watch yield and stability live.',
          simulatorTitle: 'Ethanol Plant Design',
          simulatorBrief: 'Hit 95% purity with limited budget, energy, and emissions caps.',
          capstoneTitle: 'Ammonia plant concept',
          capstoneStages: <String>['Feedstock', 'Flowsheet', 'Energy balance', 'Safety', 'Economics', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'temp', label: 'Temperature', unit: '°C', min: 20, max: 400, initial: 180),
            EngineeringControlSpec(id: 'pressure', label: 'Pressure', unit: 'bar', min: 1, max: 50, initial: 8),
            EngineeringControlSpec(id: 'flow', label: 'Feed flow', unit: 'mol/s', min: 0.5, max: 20, initial: 5, step: 0.5),
            EngineeringControlSpec(id: 'catalyst', label: 'Catalyst activity', unit: '%', min: 20, max: 100, initial: 70),
          ],
        ),
        EngineeringCourse(
          id: 'separations',
          title: 'Separations',
          blurb: 'Distillation, extraction, and getting purity without wasting energy.',
          topics: <String>['VLE', 'Distillation', 'Reflux', 'Absorption', 'Membranes', 'Energy integration'],
          labTitle: 'Distillation Column Lab',
          labDescription: 'Change reflux ratio and stages. Track purity, energy, and flooding risk.',
          simulatorTitle: 'Refinery Debottleneck',
          simulatorBrief: 'Increase throughput while cutting waste and staying within safety limits.',
          capstoneTitle: 'Pharmaceutical purification train',
          capstoneStages: <String>['Specs', 'Unit ops', 'Simulation', 'QA', 'Cost', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'reflux', label: 'Reflux ratio', unit: '', min: 0.5, max: 8, initial: 2, step: 0.1),
            EngineeringControlSpec(id: 'stages', label: 'Stages', unit: '', min: 5, max: 40, initial: 15),
            EngineeringControlSpec(id: 'feed', label: 'Feed rate', unit: 'kmol/h', min: 10, max: 200, initial: 60),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'aerospace',
      name: 'Aerospace Engineering',
      tagline: 'Flight, propulsion, and missions that leave the ground — or the planet.',
      icon: Icons.flight_outlined,
      emoji: '🚀',
      gameplay: <String>['Rocket Builder', 'Satellite Designer', 'Mars Mission', 'Wind Tunnel', 'Flight Simulator'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'aero',
          title: 'Aerodynamics',
          blurb: 'Lift, drag, and why wing shape decides whether you fly or stall.',
          topics: <String>['Airfoils', 'Angle of attack', 'Lift & drag', 'Boundary layers', 'Compressibility', 'Stall'],
          labTitle: 'Virtual Wind Tunnel',
          labDescription: 'Change wing angle and airspeed. See lift, drag, and stall onset update live.',
          simulatorTitle: 'Mars Rover Design',
          simulatorBrief: 'Meet weight, power, budget, materials, and terrain constraints. Run the mission.',
          capstoneTitle: 'Satellite mission concept',
          capstoneStages: <String>['Mission goals', 'Orbit', 'Power', 'Comms', 'Thermal', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'aoa', label: 'Angle of attack', unit: '°', min: -5, max: 20, initial: 4, step: 0.5),
            EngineeringControlSpec(id: 'speed', label: 'Airspeed', unit: 'm/s', min: 20, max: 250, initial: 80),
            EngineeringControlSpec(id: 'area', label: 'Wing area', unit: 'm²', min: 5, max: 80, initial: 20),
          ],
        ),
        EngineeringCourse(
          id: 'propulsion',
          title: 'Propulsion',
          blurb: 'Rockets, jets, and the energy cost of getting somewhere fast.',
          topics: <String>['Thrust', 'Isp', 'Nozzles', 'Jet engines', 'Staging', 'Propellants'],
          labTitle: 'Rocket Static Fire',
          labDescription: 'Tune mixture ratio and nozzle expansion. Measure thrust and chamber temperature.',
          simulatorTitle: 'Orbital Transfer Planner',
          simulatorBrief: 'Plan burns, manage fuel, and complete mission objectives without missing the window.',
          capstoneTitle: 'Sounding rocket or drone propulsion pack',
          capstoneStages: <String>['Requirements', 'Propulsion choice', 'Sizing', 'Safety', 'Sim', 'Demo'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'mix', label: 'O/F ratio', unit: '', min: 1, max: 8, initial: 2.5, step: 0.1),
            EngineeringControlSpec(id: 'pe', label: 'Exit pressure', unit: 'kPa', min: 10, max: 101, initial: 50),
            EngineeringControlSpec(id: 'mdot', label: 'Mass flow', unit: 'kg/s', min: 0.5, max: 50, initial: 8, step: 0.5),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'biomedical',
      name: 'Biomedical Engineering',
      tagline: 'Devices and systems that interface with the human body safely.',
      icon: Icons.monitor_heart_outlined,
      emoji: '🩺',
      gameplay: <String>['Artificial Heart Builder', 'MRI Simulator', 'Prosthetic Designer', 'Medical Device Testing'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'devices',
          title: 'Medical Devices',
          blurb: 'Sensors, actuators, and the regulations that keep patients safe.',
          topics: <String>['Biocompatibility', 'Sensors', 'Actuators', 'Risk analysis', 'Validation', 'Human factors'],
          labTitle: 'Heart Valve Flow Lab',
          labDescription: 'Design a valve geometry. Test blood-flow patterns and regurgitation.',
          simulatorTitle: 'Prosthetic Arm Challenge',
          simulatorBrief: 'Meet strength, weight, battery, and control accuracy targets.',
          capstoneTitle: 'Artificial knee joint',
          capstoneStages: <String>['Clinical need', 'Materials', 'Mechanics', 'Test plan', 'Regulatory', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'flow', label: 'Flow rate', unit: 'L/min', min: 1, max: 8, initial: 5, step: 0.1),
            EngineeringControlSpec(id: 'orifice', label: 'Orifice area', unit: 'cm²', min: 1, max: 6, initial: 3, step: 0.1),
            EngineeringControlSpec(id: 'stiffness', label: 'Leaflet stiffness', unit: '', min: 1, max: 10, initial: 4),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'environmental',
      name: 'Environmental Engineering',
      tagline: 'Water, air, waste, and systems that keep communities livable.',
      icon: Icons.eco_outlined,
      emoji: '🌍',
      gameplay: <String>['Water Treatment Plant', 'Flood Simulator', 'Air Quality Monitor', 'City Sustainability Challenge'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'water',
          title: 'Water Treatment',
          blurb: 'From contaminated source to safe drinking water — and what can go wrong.',
          topics: <String>['Coagulation', 'Filtration', 'Disinfection', 'Residuals', 'Regulations', 'Monitoring'],
          labTitle: 'Treatment Train Lab',
          labDescription: 'Clean polluted water. Adjust dose and contact time. Measure contamination drop.',
          simulatorTitle: 'City Water Crisis',
          simulatorBrief: 'A contamination event hits. Restore safe supply under budget and time pressure.',
          capstoneTitle: 'Municipal treatment upgrade',
          capstoneStages: <String>['Source study', 'Process train', 'Energy', 'Cost', 'Community', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'dose', label: 'Coagulant dose', unit: 'mg/L', min: 5, max: 80, initial: 25),
            EngineeringControlSpec(id: 'contact', label: 'Contact time', unit: 'min', min: 5, max: 60, initial: 20),
            EngineeringControlSpec(id: 'turbidity', label: 'Influent turbidity', unit: 'NTU', min: 5, max: 200, initial: 40),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'industrial',
      name: 'Industrial Engineering',
      tagline: 'Optimize people, machines, and flow so systems deliver more with less waste.',
      icon: Icons.factory_outlined,
      emoji: '🏭',
      gameplay: <String>['Factory Simulator', 'Warehouse Optimization', 'Production Planning', 'Assembly Line Designer'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'ops',
          title: 'Operations & Simulation',
          blurb: 'Bottlenecks, queues, and the math of making factories flow.',
          topics: <String>['Process mapping', 'Bottlenecks', 'Queuing', 'Lean', 'Six Sigma', 'Simulation'],
          labTitle: 'Assembly Line Lab',
          labDescription: 'Balance stations, change takt time, and watch WIP and throughput respond.',
          simulatorTitle: 'Amazon Warehouse Challenge',
          simulatorBrief: 'Optimize robot paths and staffing. Cut cost without missing SLAs.',
          capstoneTitle: 'Factory layout redesign',
          capstoneStages: <String>['Current state', 'Constraints', 'Layout options', 'Sim', 'ROI', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'stations', label: 'Stations', unit: '', min: 2, max: 12, initial: 6),
            EngineeringControlSpec(id: 'takt', label: 'Takt time', unit: 's', min: 20, max: 180, initial: 60),
            EngineeringControlSpec(id: 'robots', label: 'Robots', unit: '', min: 0, max: 20, initial: 4),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'materials',
      name: 'Materials Engineering',
      tagline: 'Metals, polymers, ceramics — choose and process materials that do not fail.',
      icon: Icons.layers_outlined,
      emoji: '🔬',
      gameplay: <String>['Alloy Designer', 'Crystal Structure Lab', 'Corrosion Testing', 'Material Selection Challenge'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'metals',
          title: 'Metals & Heat Treatment',
          blurb: 'Microstructure decides strength — and heat treatment rewrites it.',
          topics: <String>['Crystal structures', 'Phase diagrams', 'Heat treatment', 'Hardness', 'Fatigue', 'Corrosion'],
          labTitle: 'Heat Treat Lab',
          labDescription: 'Quench and temper steel. Watch hardness and toughness trade off.',
          simulatorTitle: 'Alloy Selection Challenge',
          simulatorBrief: 'Pick materials for a corrosive, high-cycle environment under cost caps.',
          capstoneTitle: 'Failure analysis case study',
          capstoneStages: <String>['Evidence', 'Hypothesis', 'Tests', 'Root cause', 'Fix', 'Report'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'temp', label: 'Austenitize T', unit: '°C', min: 700, max: 1100, initial: 850),
            EngineeringControlSpec(id: 'cool', label: 'Cooling rate', unit: '°C/s', min: 1, max: 200, initial: 40),
            EngineeringControlSpec(id: 'carbon', label: 'Carbon', unit: 'wt%', min: 0.1, max: 1.2, initial: 0.4, step: 0.05),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'nuclear',
      name: 'Nuclear Engineering',
      tagline: 'Reactors, radiation, and the discipline of keeping power plants safe.',
      icon: Icons.warning_amber_outlined,
      emoji: '☢',
      gameplay: <String>['Reactor Control Room', 'Power Plant Simulator', 'Radiation Shielding Lab', 'Emergency Response'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'reactors',
          title: 'Reactor Physics & Safety',
          blurb: 'Control rods, heat removal, and why stability is non-negotiable.',
          topics: <String>['Neutron balance', 'Reactivity', 'Heat transfer', 'Shielding', 'Accidents', 'Defense in depth'],
          labTitle: 'Control Rod Lab',
          labDescription: 'Move rods, watch power and temperature. Avoid excursion and meltdown conditions.',
          simulatorTitle: 'Plant Emergency Scenario',
          simulatorBrief: 'Cooling fault + demand spike. Stabilize without violating safety limits.',
          capstoneTitle: 'Small modular reactor concept review',
          capstoneStages: <String>['Safety case', 'Cooling', 'Shielding', 'Ops plan', 'Public brief'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'rods', label: 'Rod insertion', unit: '%', min: 0, max: 100, initial: 40),
            EngineeringControlSpec(id: 'coolant', label: 'Coolant flow', unit: '%', min: 20, max: 100, initial: 80),
            EngineeringControlSpec(id: 'power', label: 'Demand', unit: 'MW', min: 100, max: 1200, initial: 600),
          ],
        ),
      ],
    ),
    EngineeringMajor(
      id: 'petroleum',
      name: 'Petroleum Engineering',
      tagline: 'Drilling, reservoirs, and producing energy under pressure — literally.',
      icon: Icons.oil_barrel_outlined,
      emoji: '⛽',
      gameplay: <String>['Oil Field Simulator', 'Drilling Challenge', 'Reservoir Management', 'Pipeline Network'],
      courses: <EngineeringCourse>[
        EngineeringCourse(
          id: 'drilling',
          title: 'Drilling & Production',
          blurb: 'Well design, pressure control, and getting hydrocarbons to surface safely.',
          topics: <String>['Well design', 'Mud weight', 'Kick control', 'Reservoirulation', 'Artificial lift', 'Safety'],
          labTitle: 'Drilling Angle Lab',
          labDescription: 'Adjust drilling angle and mud weight. Watch pressure and kick risk.',
          simulatorTitle: 'Reservoir Management Run',
          simulatorBrief: 'Maximize recovery while managing water cut and equipment health.',
          capstoneTitle: 'Offshore well concept',
          capstoneStages: <String>['Geology', 'Well plan', 'Pressure', 'Economics', 'HSE', 'Presentation'],
          conceptControls: <EngineeringControlSpec>[
            EngineeringControlSpec(id: 'angle', label: 'Drill angle', unit: '°', min: 0, max: 90, initial: 30),
            EngineeringControlSpec(id: 'mud', label: 'Mud weight', unit: 'ppg', min: 8, max: 18, initial: 12, step: 0.1),
            EngineeringControlSpec(id: 'depth', label: 'Depth', unit: 'm', min: 500, max: 6000, initial: 2500),
          ],
        ),
      ],
    ),
  ];
}
