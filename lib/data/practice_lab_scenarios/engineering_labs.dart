import '../../models/practice_lab.dart';

const Map<String, List<PracticeLabType>> engineeringLabs =
    <String, List<PracticeLabType>>{
  'mechanical_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'mech_part_failure',
      title: 'Cracked Gearbox Shaft',
      subtitle:
          'A shaft has fractured in service and the lead engineer wants your root-cause analysis.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Engineer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Inspect the fracture surface and describe the failure mode',
        'Identify the most likely loading that caused the crack',
        'Recommend a redesign or inspection fix',
      ],
      evaluationCriteria: <String>[
        'Correctly distinguishes fatigue from overload',
        'Links evidence to a plausible root cause',
        'Proposes a practical corrective action',
      ],
    ),
    PracticeLabType(
      id: 'mech_design_review',
      title: 'Pump Housing Design Review',
      subtitle:
          'Present your new pump housing concept to a senior reviewer for sign-off.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Design Review Lead',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Walk through the load paths in your housing design',
        'Justify your material and wall-thickness choices',
        'Address the reviewer\'s manufacturability concerns',
      ],
      evaluationCriteria: <String>[
        'Design intent is clearly communicated',
        'Trade-offs are reasoned, not arbitrary',
        'Responds well to reviewer pushback',
      ],
    ),
    PracticeLabType(
      id: 'mech_thermal_tradeoff',
      title: 'Engine Cooling Trade-Off',
      subtitle:
          'Negotiate a thermal-load versus weight trade-off with the project client.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Client',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Explain the thermal margin needed for safe operation',
        'Quantify the weight cost of added cooling capacity',
        'Recommend a balanced option the client can accept',
      ],
      evaluationCriteria: <String>[
        'Uses sound heat-transfer reasoning',
        'Balances performance against weight honestly',
        'Frames the trade-off in client terms',
      ],
    ),
  ],
  'civil_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'civil_bridge_concern',
      title: 'Bridge Girder Cracking',
      subtitle:
          'Brief the city engineer on a structural concern found during a bridge inspection.',
      style: SimulationStyle.customerScenario,
      aiRole: 'City Engineer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Describe the observed cracking and its location',
        'Assess whether the bridge remains safe for traffic',
        'Recommend monitoring or closure with justification',
      ],
      evaluationCriteria: <String>[
        'Sound structural reasoning about load capacity',
        'Clear public-safety risk judgment',
        'Defensible recommendation to the official',
      ],
    ),
    PracticeLabType(
      id: 'civil_site_safety',
      title: 'Trench Collapse Risk',
      subtitle:
          'Decide whether to halt excavation work after the safety officer raises a soil concern.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Safety Officer',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Evaluate the trench shoring against site conditions',
        'Identify the hazard to workers in the excavation',
        'Make a stop-work or proceed decision',
      ],
      evaluationCriteria: <String>[
        'Recognizes the collapse hazard correctly',
        'Prioritizes worker safety appropriately',
        'Justifies the decision with clear logic',
      ],
    ),
    PracticeLabType(
      id: 'civil_cost_safety',
      title: 'Foundation Cost Versus Safety',
      subtitle:
          'Defend a more expensive foundation design against a client pushing to cut costs.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Client',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Explain the settlement risk of the cheaper option',
        'Quantify the added cost of the safer design',
        'Persuade the client toward an acceptable margin',
      ],
      evaluationCriteria: <String>[
        'Grounds the argument in geotechnical risk',
        'Honest about cost implications',
        'Maintains professional ethics under pressure',
      ],
    ),
  ],
  'electrical_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'elec_circuit_fault',
      title: 'Dead Power Supply Board',
      subtitle:
          'Troubleshoot a non-functioning power supply with a senior engineer guiding you.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Senior Electrical Engineer',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Trace the fault from input to output stages',
        'Identify the failed component from the symptoms',
        'Propose a safe repair and retest plan',
      ],
      evaluationCriteria: <String>[
        'Systematic fault-isolation approach',
        'Correct component-level diagnosis',
        'Observes electrical safety throughout',
      ],
    ),
    PracticeLabType(
      id: 'elec_power_design',
      title: 'Grid Substation Design Review',
      subtitle:
          'Present your substation power distribution design to the review board.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Power Systems Reviewer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Explain your load distribution and protection scheme',
        'Justify transformer sizing and fault tolerance',
        'Address reliability and redundancy questions',
      ],
      evaluationCriteria: <String>[
        'Sound power-system engineering reasoning',
        'Adequate protection and fault handling',
        'Clear justification of design choices',
      ],
    ),
    PracticeLabType(
      id: 'elec_signal_noise',
      title: 'Noisy Sensor Signal',
      subtitle:
          'Investigate why a sensor readout is swamped by noise on the production line.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Engineer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Characterize the noise source and its frequency',
        'Distinguish grounding from interference problems',
        'Recommend filtering or shielding to fix it',
      ],
      evaluationCriteria: <String>[
        'Correctly identifies the noise mechanism',
        'Logical signal-integrity troubleshooting',
        'Practical and effective mitigation plan',
      ],
    ),
  ],
  'aerospace_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'aero_flight_anomaly',
      title: 'In-Flight Vibration Anomaly',
      subtitle:
          'Investigate an unexpected vibration reported during a test flight.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Flight Test Engineer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Review the telemetry to localize the anomaly',
        'Hypothesize the structural or aero cause',
        'Recommend whether further flights are safe',
      ],
      evaluationCriteria: <String>[
        'Rigorous use of flight data',
        'Plausible root-cause hypothesis',
        'Sound flight-safety judgment',
      ],
    ),
    PracticeLabType(
      id: 'aero_trade_study',
      title: 'Wing Material Trade Study',
      subtitle:
          'Present a composite versus aluminum wing trade study to the chief engineer.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Chief Engineer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Compare weight, cost, and fatigue life of options',
        'Recommend a material with clear justification',
        'Defend your choice against the chief\'s questions',
      ],
      evaluationCriteria: <String>[
        'Balanced multi-criteria comparison',
        'Evidence-based recommendation',
        'Strong technical defense',
      ],
    ),
    PracticeLabType(
      id: 'aero_mission_risk',
      title: 'Launch Mission Risk Briefing',
      subtitle:
          'Brief the mission director on go or no-go risks ahead of launch.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Mission Director',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Summarize the top mission risks and their likelihood',
        'Explain mitigations already in place',
        'Give a clear go or no-go recommendation',
      ],
      evaluationCriteria: <String>[
        'Risks are prioritized sensibly',
        'Clear and concise communication',
        'Decision is well justified',
      ],
    ),
  ],
  'chemical_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'chem_process_incident',
      title: 'Reactor Overpressure Incident',
      subtitle:
          'Walk the safety officer through a process safety incident on the reactor line.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Safety Officer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Reconstruct the events leading to the overpressure',
        'Identify the failed safety barrier',
        'Recommend safeguards to prevent recurrence',
      ],
      evaluationCriteria: <String>[
        'Accurate hazard and cause analysis',
        'Understands layers of protection',
        'Actionable preventive recommendations',
      ],
    ),
    PracticeLabType(
      id: 'chem_scaleup_review',
      title: 'Reactor Scale-Up Review',
      subtitle:
          'Present your pilot-to-plant reactor scale-up plan for design review.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Process Design Lead',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Explain how heat and mass transfer change with scale',
        'Justify the chosen reactor sizing and mixing',
        'Address the reviewer\'s safety concerns',
      ],
      evaluationCriteria: <String>[
        'Sound scale-up reasoning',
        'Recognizes transport limitations',
        'Integrates safety into the design',
      ],
    ),
    PracticeLabType(
      id: 'chem_yield_optimization',
      title: 'Distillation Yield Problem',
      subtitle:
          'Diagnose why product yield dropped in a distillation column.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Process Engineer',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Examine the operating data for anomalies',
        'Identify the likely cause of the yield loss',
        'Propose operating changes to recover yield',
      ],
      evaluationCriteria: <String>[
        'Reads process data correctly',
        'Logical cause identification',
        'Practical optimization proposal',
      ],
    ),
  ],
  'industrial_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'ind_bottleneck',
      title: 'Assembly Line Bottleneck',
      subtitle:
          'Analyze a production bottleneck slowing the assembly line and report to the plant manager.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Plant Manager',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Map the line and locate the constraint station',
        'Quantify the throughput lost to the bottleneck',
        'Recommend a fix to raise overall capacity',
      ],
      evaluationCriteria: <String>[
        'Correctly identifies the constraint',
        'Uses throughput data effectively',
        'Recommendation improves flow realistically',
      ],
    ),
    PracticeLabType(
      id: 'ind_process_improvement',
      title: 'Process Improvement Proposal',
      subtitle:
          'Pitch a lean process improvement to a skeptical operations director.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Operations Director',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Present the waste your proposal eliminates',
        'Estimate the cost savings and payback',
        'Address the director\'s implementation concerns',
      ],
      evaluationCriteria: <String>[
        'Applies lean principles correctly',
        'Quantifies benefits credibly',
        'Persuasive and realistic delivery',
      ],
    ),
    PracticeLabType(
      id: 'ind_ergonomics',
      title: 'Workstation Ergonomics Review',
      subtitle:
          'Review a packing workstation with the safety officer to reduce injury risk.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Safety Officer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Identify the ergonomic risk factors at the station',
        'Assess the injury risk to the operators',
        'Recommend redesigns to reduce strain',
      ],
      evaluationCriteria: <String>[
        'Recognizes key ergonomic hazards',
        'Prioritizes risks sensibly',
        'Recommendations are practical and effective',
      ],
    ),
  ],
  'biomedical_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'biomed_device_review',
      title: 'Infusion Pump Design Review',
      subtitle:
          'Present your infusion pump design to a clinical engineering reviewer.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Clinical Engineering Reviewer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Explain how the design meets clinical dosing needs',
        'Justify the alarm and fail-safe features',
        'Address the reviewer\'s patient-safety questions',
      ],
      evaluationCriteria: <String>[
        'Design meets clinical requirements',
        'Strong patient-safety reasoning',
        'Clear justification of features',
      ],
    ),
    PracticeLabType(
      id: 'biomed_regulatory',
      title: 'FDA Regulatory Safety Briefing',
      subtitle:
          'Brief a regulatory official on the safety case for your medical device.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Regulatory Official',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Summarize the risk analysis for the device',
        'Explain the verification and validation evidence',
        'Respond to the official\'s compliance questions',
      ],
      evaluationCriteria: <String>[
        'Understands regulatory risk expectations',
        'Evidence supports the safety case',
        'Communicates clearly to a non-design audience',
      ],
    ),
    PracticeLabType(
      id: 'biomed_device_failure',
      title: 'Monitor Sensor Failure',
      subtitle:
          'Troubleshoot a patient monitor giving false readings in the ward.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Biomedical Engineer',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Reproduce and characterize the faulty readings',
        'Isolate the failure to sensor or signal path',
        'Recommend a safe fix before clinical reuse',
      ],
      evaluationCriteria: <String>[
        'Systematic troubleshooting method',
        'Correct failure isolation',
        'Prioritizes patient safety in the fix',
      ],
    ),
  ],
  'environmental_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'env_treatment_design',
      title: 'Wastewater Treatment Design',
      subtitle:
          'Present a wastewater treatment process design for technical review.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Design Review Lead',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Explain each treatment stage and its purpose',
        'Justify sizing against the effluent standards',
        'Address the reviewer\'s reliability concerns',
      ],
      evaluationCriteria: <String>[
        'Process meets discharge requirements',
        'Sound sizing and staging logic',
        'Clear technical communication',
      ],
    ),
    PracticeLabType(
      id: 'env_remediation',
      title: 'Groundwater Contamination Plan',
      subtitle:
          'Diagnose a groundwater contamination case and plan remediation.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Environmental Engineer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Interpret the contamination plume data',
        'Identify the likely source and pathway',
        'Recommend a remediation approach with rationale',
      ],
      evaluationCriteria: <String>[
        'Correctly interprets site data',
        'Plausible source and pathway analysis',
        'Feasible, well-justified remediation plan',
      ],
    ),
    PracticeLabType(
      id: 'env_permitting',
      title: 'Air Permit Compliance Briefing',
      subtitle:
          'Brief a permitting official on your facility\'s emissions compliance.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Permitting Official',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Summarize the emission sources and controls',
        'Show how limits are met under permit rules',
        'Answer the official\'s compliance questions',
      ],
      evaluationCriteria: <String>[
        'Understands permit requirements',
        'Compliance argument is supported',
        'Communicates clearly and credibly',
      ],
    ),
  ],
  'materials_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'mat_selection',
      title: 'Material Selection Trade-Off',
      subtitle:
          'Recommend a material for a high-temperature part to the design lead.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Design Lead',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Define the service requirements for the part',
        'Compare candidate materials against those needs',
        'Recommend a material with clear justification',
      ],
      evaluationCriteria: <String>[
        'Requirements are correctly framed',
        'Sound property-based comparison',
        'Recommendation is well justified',
      ],
    ),
    PracticeLabType(
      id: 'mat_fracture',
      title: 'Component Fracture Analysis',
      subtitle:
          'Analyze a fractured component with a senior metallurgist.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Senior Metallurgist',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Examine the fracture surface features',
        'Determine the failure mechanism at work',
        'Link the failure to material or loading factors',
      ],
      evaluationCriteria: <String>[
        'Reads fractographic evidence correctly',
        'Identifies the correct failure mechanism',
        'Connects cause to material behavior',
      ],
    ),
    PracticeLabType(
      id: 'mat_defect',
      title: 'Casting Defect Investigation',
      subtitle:
          'Investigate a recurring defect in cast parts on the shop floor.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Lead Materials Engineer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Characterize the defect type and pattern',
        'Trace it to a step in the casting process',
        'Recommend a process change to eliminate it',
      ],
      evaluationCriteria: <String>[
        'Correct defect classification',
        'Logical process-cause linkage',
        'Effective corrective recommendation',
      ],
    ),
  ],
  'nuclear_engineering': <PracticeLabType>[
    PracticeLabType(
      id: 'nuc_reactor_safety',
      title: 'Reactor Coolant Loss',
      subtitle:
          'Respond to a loss-of-coolant scenario under the shift supervisor\'s watch.',
      style: SimulationStyle.diagnosis,
      aiRole: 'Shift Supervisor',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Interpret the plant indications during the event',
        'Identify the safety systems that must respond',
        'Recommend operator actions to stabilize the core',
      ],
      evaluationCriteria: <String>[
        'Correctly reads plant conditions',
        'Understands safety system function',
        'Sound and timely action recommendations',
      ],
    ),
    PracticeLabType(
      id: 'nuc_radiation_safety',
      title: 'Radiation Safety Briefing',
      subtitle:
          'Brief the radiation safety officer before a maintenance task in a controlled area.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Radiation Safety Officer',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Summarize the dose risks of the planned work',
        'Explain the ALARA controls you will apply',
        'Answer the officer\'s exposure questions',
      ],
      evaluationCriteria: <String>[
        'Understands dose and exposure concepts',
        'Applies ALARA principles correctly',
        'Communicates the safety plan clearly',
      ],
    ),
    PracticeLabType(
      id: 'nuc_incident_response',
      title: 'Plant Incident Response',
      subtitle:
          'Decide on response actions during an emerging plant incident.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Emergency Director',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Assess the severity and trend of the incident',
        'Prioritize protective actions for staff and public',
        'Recommend a clear next step to the director',
      ],
      evaluationCriteria: <String>[
        'Accurate severity assessment',
        'Sensible prioritization of protective actions',
        'Decisive, well-reasoned recommendation',
      ],
    ),
  ],
};
