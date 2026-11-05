import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// Faculty of Engineering: six discipline labs, each with its own design
// calculations, checked to engineering tolerances.

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('en_mech', 'Mechanics & machine design'),
  SkillDef('en_struct', 'Structural analysis'),
  SkillDef('en_elec', 'Circuit analysis'),
  SkillDef('en_process', 'Process & mass balance'),
  SkillDef('en_aero', 'Aerodynamics'),
  SkillDef('en_ops', 'Operations & production'),
  SkillDef('en_safety', 'Safety & design review'),
];

const NumericTaskSpec _gears = NumericTaskSpec(
  id: 'gears',
  title: 'Gearbox and shaft check',
  brief: 'A conveyor gearbox: check the output and the stress in the tie rod.',
  diagram: 'gears',
  skills: <String>['en_mech'],
  givens: <Fact>[
    Fact('Driver gear', '20 teeth, 1,500 rpm, 40 N·m'),
    Fact('Driven gear', '60 teeth (ideal, no losses)'),
    Fact('Tie rod', 'Ø20 mm steel, axial load 12 kN, yield 250 MPa'),
  ],
  parts: <NumericPart>[
    NumericPart('Output speed', 500, unit: 'rpm', method: 'Speed ratio = driver teeth ÷ driven teeth.'),
    NumericPart('Output torque', 120, unit: 'N·m', method: 'Torque scales inversely with speed for an ideal gearbox.'),
    NumericPart('Axial stress in the rod', 38.2, unit: 'MPa', relTol: 0.01, method: 'σ = F ÷ A with A = πd²/4.'),
    NumericPart('Factor of safety against yield', 6.54, relTol: 0.01, method: 'FoS = yield ÷ working stress.'),
  ],
);

const NumericTaskSpec _beam = NumericTaskSpec(
  id: 'beam',
  title: 'Simply supported beam',
  brief: 'A 6 m footbridge beam carries a 30 kN point load 2 m from support A.',
  diagram: 'beam',
  skills: <String>['en_struct'],
  givens: <Fact>[
    Fact('Span', '6 m, pinned at A, roller at B'),
    Fact('Point load', '30 kN at 2 m from A'),
    Fact('Second case', 'UDL 5 kN/m over an 8 m span'),
  ],
  parts: <NumericPart>[
    NumericPart('Reaction at A', 20, unit: 'kN', method: 'Take moments about B.'),
    NumericPart('Reaction at B', 10, unit: 'kN', method: 'ΣFy = 0.'),
    NumericPart('Maximum bending moment (point load)', 40, unit: 'kN·m', method: 'M = R_A × distance to the load.'),
    NumericPart('Maximum bending moment (UDL case)', 40, unit: 'kN·m', method: 'M = wL²/8.'),
  ],
);

const NumericTaskSpec _circuit = NumericTaskSpec(
  id: 'circuit',
  title: 'Sensor supply circuit',
  brief: 'A 12 V supply feeds R1 = 4 Ω and R2 = 6 Ω in series.',
  diagram: 'circuit',
  skills: <String>['en_elec'],
  givens: <Fact>[
    Fact('Supply', '12 V DC'),
    Fact('R1, R2', '4 Ω and 6 Ω'),
  ],
  parts: <NumericPart>[
    NumericPart('Current', 1.2, unit: 'A', method: 'I = V ÷ (R1 + R2).'),
    NumericPart('Voltage across R2', 7.2, unit: 'V', method: 'V = I × R2.'),
    NumericPart('Total power', 14.4, unit: 'W', method: 'P = V × I.'),
    NumericPart('Equivalent resistance if R1 and R2 were in parallel', 2.4, unit: 'Ω', method: '1/R = 1/R1 + 1/R2.'),
  ],
);

const NumericTaskSpec _mix = NumericTaskSpec(
  id: 'mix',
  title: 'Brine mixer mass balance',
  brief: 'Two brine streams are mixed at steady state.',
  skills: <String>['en_process'],
  givens: <Fact>[
    Fact('Stream A', '100 kg/h, 20 wt% salt'),
    Fact('Stream B', '50 kg/h, 50 wt% salt'),
  ],
  parts: <NumericPart>[
    NumericPart('Outlet flow', 150, unit: 'kg/h', method: 'Total mass in = total mass out.'),
    NumericPart('Salt in the outlet', 45, unit: 'kg/h', method: 'Component balance on salt.'),
    NumericPart('Outlet salt concentration', 30, unit: 'wt%', method: 'Salt flow ÷ total flow.'),
  ],
);

const NumericTaskSpec _lift = NumericTaskSpec(
  id: 'lift',
  title: 'Light aircraft lift',
  brief: 'Use L = ½ρv²SC_L.',
  diagram: 'airfoil',
  skills: <String>['en_aero'],
  givens: <Fact>[
    Fact('Air density ρ', '1.225 kg/m³'),
    Fact('Wing area S', '16 m²'),
    Fact('Speed', '60 m/s'),
    Fact('Aircraft weight', '12,000 N; C_L,max = 1.4'),
  ],
  parts: <NumericPart>[
    NumericPart('Lift at 60 m/s with C_L = 0.5', 17640, unit: 'N', method: 'Substitute into L = ½ρv²SC_L.'),
    NumericPart('C_L needed for level flight at 60 m/s', 0.340, relTol: 0.01, method: 'Set L = W and solve for C_L.'),
    NumericPart('Stall speed', 29.57, unit: 'm/s', relTol: 0.01, method: 'v = √(2W ÷ (ρ S C_L,max)).'),
  ],
);

const NumericTaskSpec _takt = NumericTaskSpec(
  id: 'takt',
  title: 'Assembly line balance',
  brief: 'Balance the line to customer demand.',
  skills: <String>['en_ops'],
  givens: <Fact>[
    Fact('Available time', '450 min per shift'),
    Fact('Demand', '900 units per shift'),
    Fact('Station cycle times', '25 s, 28 s, 34 s, 22 s'),
    Fact('Availability / performance / quality', '90% / 95% / 98%'),
  ],
  parts: <NumericPart>[
    NumericPart('Takt time', 30, unit: 's', method: 'Available time ÷ demand (convert to seconds).'),
    NumericPart('Minimum number of stations', 4, method: 'Total work content ÷ takt, rounded up.'),
    NumericPart('OEE', 83.79, unit: '%', relTol: 0.005, method: 'Availability × performance × quality.'),
  ],
);

const ClassifyTaskSpec _hazards = ClassifyTaskSpec(
  id: 'hazards',
  title: 'Design review hazards',
  brief: 'Classify each control using the hierarchy of controls.',
  skills: <String>['en_safety'],
  categories: <String>['Elimination', 'Substitution', 'Engineering control', 'Administrative control', 'PPE'],
  items: <ClassifyItem>[
    ClassifyItem('Redesign so maintenance happens at ground level instead of at height', 'Elimination', 'Removes the hazard entirely.'),
    ClassifyItem('Replace a solvent cleaner with a water-based one', 'Substitution', 'A less hazardous substance.'),
    ClassifyItem('Fit an interlocked guard on the press', 'Engineering control', 'Physically isolates people from the hazard.'),
    ClassifyItem('Permit-to-work before entering the tank', 'Administrative control', 'A procedure controlling how work is done.'),
    ClassifyItem('Hearing protection in the compressor room', 'PPE', 'Protects the individual; the last line of defence.'),
  ],
);

TrainingModule _module(String id, String title, String summary, List<String> skills, List<LessonSection> lesson,
        List<TaskSpec> practice) =>
    TrainingModule(id: id, title: title, summary: summary, skills: skills, lesson: lesson, practice: practice);

final Department engineering = Department(
  id: 'engineering',
  title: 'Engineering',
  school: 'Faculty of Engineering',
  emoji: '⚙️',
  summary: 'Six discipline labs with real design calculations, safety reviews and a design-office workplace.',
  majors: const <String>[
    'mechanical_engineering', 'civil_engineering', 'electrical_engineering', 'chemical_engineering',
    'aerospace_engineering', 'industrial_engineering',
  ],
  skills: _skills,
  units: <DeptUnit>[
    DeptUnit(
      id: 'en_mech_lab',
      title: 'Mechanical Engineering Lab',
      emoji: '🔩',
      setting: 'Machine shop with a gearbox test rig, tensile tester and CAD stations.',
      modules: <TrainingModule>[
        _module('en_m_mech', 'Power transmission and stress', 'Gear ratios, torque and axial stress with a factor of safety.',
            const <String>['en_mech'], const <LessonSection>[
          LessonSection('Gear trains',
              'Speed ratio = driven teeth ÷ driver teeth. An ideal gearbox conserves power, so torque rises as speed falls: '
                  'T_out = T_in × ratio.'),
          LessonSection('Axial stress and factor of safety',
              'σ = F/A. For a round bar, A = πd²/4 — keep units consistent (N and mm² give MPa). Factor of safety = yield '
                  'strength ÷ working stress; design codes typically require 1.5–3 for static loads.'),
        ], const <TaskSpec>[_gears, _hazards]),
      ],
    ),
    DeptUnit(
      id: 'en_civil_lab',
      title: 'Civil & Structural Lab',
      emoji: '🌉',
      setting: 'Structures hall with a loaded beam rig and strain gauges.',
      modules: <TrainingModule>[
        _module('en_m_civil', 'Beam reactions and bending moments', 'Equilibrium and bending in simply supported beams.',
            const <String>['en_struct'], const <LessonSection>[
          LessonSection('Equilibrium',
              'A statically determinate beam satisfies ΣFy = 0 and ΣM = 0. Take moments about one support to find the other reaction.'),
          LessonSection('Bending moment',
              'For a point load, the maximum moment is under the load: M = R_A × a. For a uniformly distributed load w over '
                  'span L, M_max = wL²/8 at midspan.'),
        ], const <TaskSpec>[_beam]),
      ],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'en_p1',
          title: 'Footbridge design check',
          brief: 'Check the footbridge beam and write the design note the checking engineer will sign.',
          requiresModules: const <String>['en_m_civil'],
          skills: const <String>['en_struct', 'en_safety'],
          deliverables: const <TaskSpec>[_beam],
          writeUp: const WrittenTaskSpec(
            id: 'design_note',
            title: 'Design note',
            brief: 'Write the design note: loads, assumptions, results, checks and recommendation.',
            minWords: 90,
            rubric: <Concept>[
              Concept('loads', 'Loads and load cases', <String>['load*', 'kn', 'udl', 'point load']),
              Concept('assume', 'Assumptions', <String>['assum*', 'simply supported', 'pinned', 'roller']),
              Concept('results', 'Results', <String>['reaction*', 'moment', 'kn·m', 'knm', '40']),
              Concept('check', 'Checks and factor of safety', <String>['check*', 'factor of safety', 'capacity', 'code']),
              Concept('rec', 'Recommendation', <String>['recommend*', 'acceptable', 'adequate', 'approve*']),
            ],
          ),
        ),
      ],
    ),
    DeptUnit(
      id: 'en_elec_lab',
      title: 'Electrical Engineering Lab',
      emoji: '🔌',
      setting: 'Bench supplies, multimeters, oscilloscopes and a breadboard station.',
      modules: <TrainingModule>[
        _module('en_m_elec', 'DC circuit analysis', 'Ohm\'s law, series and parallel resistance and power.',
            const <String>['en_elec'], const <LessonSection>[
          LessonSection('Ohm\'s law and power', 'V = IR and P = VI = I²R. In series, resistances add and the current is common.'),
          LessonSection('Parallel', 'In parallel, the voltage is common and 1/R_eq = Σ 1/R_i; R_eq is smaller than the smallest branch.'),
        ], <TaskSpec>[
          _circuit,
          const OrderTaskSpec(
            id: 'isolation',
            title: 'Safe isolation',
            brief: 'Order the steps to isolate a circuit before work.',
            skills: <String>['en_safety', 'en_elec'],
            steps: <String>[
              'Identify the circuit and the isolation point',
              'Switch off and isolate',
              'Lock off and tag the isolator',
              'Prove the tester on a known live source',
              'Test the circuit is dead',
              'Re-prove the tester on the known source',
            ],
            why: 'Prove–test–prove confirms your tester works before and after you rely on it.',
          ),
        ]),
      ],
    ),
    DeptUnit(
      id: 'en_chem_lab',
      title: 'Chemical Engineering Pilot Plant',
      emoji: '🏭',
      setting: 'Pilot plant with mixers, an evaporator and flow meters.',
      modules: <TrainingModule>[
        _module('en_m_chem', 'Mass balances', 'Steady-state total and component balances.', const <String>['en_process'],
            const <LessonSection>[
          LessonSection('Conservation of mass', 'At steady state, in = out for the total flow and for each component that does not react.'),
          LessonSection('Method', 'Draw the flow sheet, label every stream with flow and composition, choose a basis, and write one balance per unknown.'),
        ], const <TaskSpec>[_mix]),
      ],
    ),
    DeptUnit(
      id: 'en_aero_lab',
      title: 'Aerospace Wind Tunnel',
      emoji: '✈️',
      setting: 'Low-speed wind tunnel with a force balance and an aerofoil model.',
      modules: <TrainingModule>[
        _module('en_m_aero', 'Lift and stall', 'Apply the lift equation to performance limits.', const <String>['en_aero'],
            const <LessonSection>[
          LessonSection('The lift equation', 'L = ½ρv²SC_L. Lift grows with the square of speed.'),
          LessonSection('Stall speed', 'Level flight needs L = W. At C_L,max the aircraft flies at its minimum (stall) speed: v_s = √(2W/(ρSC_L,max)).'),
        ], const <TaskSpec>[_lift]),
      ],
    ),
    DeptUnit(
      id: 'en_ind_lab',
      title: 'Industrial Engineering Production Lab',
      emoji: '📦',
      setting: 'A four-station assembly line with timers and a production board.',
      modules: <TrainingModule>[
        _module('en_m_ind', 'Takt time, line balance and OEE', 'Match production to demand and measure effectiveness.',
            const <String>['en_ops'], const <LessonSection>[
          LessonSection('Takt time', 'Takt = available time ÷ customer demand. Any station slower than takt is a bottleneck.'),
          LessonSection('Line balancing', 'Minimum stations = total work content ÷ takt, rounded up.'),
          LessonSection('OEE', 'Overall equipment effectiveness = availability × performance × quality.'),
        ], const <TaskSpec>[_takt]),
      ],
    ),
  ],
  certifications: const <Certification>[
    Certification(
      id: 'en_cert_calc',
      title: 'Engineering Calculations Certificate',
      issuer: 'GradeGlow Faculty of Engineering',
      requiresModules: <String>['en_m_civil'],
      tasks: <TaskSpec>[_beam, _gears, _circuit],
    ),
    Certification(
      id: 'en_cert_safety',
      title: 'Safety & Design Review Certificate',
      issuer: 'GradeGlow Faculty of Engineering',
      requiresModules: <String>['en_m_mech'],
      tasks: <TaskSpec>[_hazards],
    ),
  ],
);

const CompanyProfile _meridian = CompanyProfile(
  name: 'Meridian Engineering',
  industry: 'Multidisciplinary engineering consultancy',
  about: 'Meridian designs bridges, plant upgrades and production lines for public and private clients.',
  team: 'The design office has structural, mechanical, electrical and process teams; every calculation is checked by a chartered engineer.',
  training: 'A graduate scheme towards chartership: mentor, structured experience logbook and paid professional exams.',
  culture: 'Safety first and "check before you issue" — nothing leaves the office without an independent check.',
  success: 'Accurate, checked calculations with clear design notes, delivered to programme.',
  tools: 'Calculation templates, CAD, structural analysis software and the document control system.',
  nextSteps: 'You will hear from us within two working days.',
);

const List<JobPosting> engineeringPostings = <JobPosting>[
  JobPosting(
    id: 'en_intern_meridian',
    deptId: 'engineering',
    company: _meridian,
    title: 'Engineering Intern — Design Office',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A summer internship producing checked calculations across disciplines.',
    responsibilities: <String>['Prepare design calculations', 'Write design notes', 'Take part in design reviews'],
    qualifications: <String>['Engineering student with Trainee status', 'Two discipline modules'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['en_m_mech', 'en_m_civil'],
      skills: <String, int>{'en_mech': 1, 'en_struct': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2100,
    salaryMax: 2500,
    salaryPeriod: 'month',
    location: 'Hybrid · Bristol',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'en_iv',
    workplaceId: 'en_meridian',
  ),
  JobPosting(
    id: 'en_grad_meridian',
    deptId: 'engineering',
    company: _meridian,
    title: 'Graduate Engineer',
    type: JobType.graduate,
    stageOnHire: CareerStage.entryLevel,
    description: 'Join the graduate scheme in the design office.',
    responsibilities: <String>['Own calculation packages', 'Coordinate with other disciplines', 'Support site visits'],
    qualifications: <String>['Completed internship', 'Engineering Calculations Certificate'],
    experience: 'A completed engineering internship.',
    requirements: JobRequirements(
      modules: <String>['en_m_mech', 'en_m_civil', 'en_m_elec'],
      skills: <String, int>{'en_struct': 2, 'en_mech': 1, 'en_safety': 1},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['en_cert_calc'],
      completedInternship: true,
    ),
    salaryMin: 31000,
    salaryMax: 36000,
    location: 'Hybrid · Bristol',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'en_iv',
    workplaceId: 'en_meridian',
  ),
];

const InterviewPlan engineeringInterview = InterviewPlan(
  id: 'en_iv',
  interviewer: 'Tomasz Kowalski',
  interviewerRole: 'Chartered Engineer, Design Office Lead',
  opening: 'Welcome. I\'ll ask about your projects, give you a calculation to work, and discuss safety.',
  main: <String>['en_q1', 'en_calc', 'en_q2', 'en_q3', 'en_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'en_q1',
      prompt: 'Describe an engineering project you worked on and the main technical challenge.',
      competency: Competency.communication,
      behavioural: true,
      minWords: 40,
      rubric: <Concept>[
        Concept('challenge', 'The challenge', <String>['challenge', 'problem', 'difficult*', 'constraint*']),
        Concept('calc', 'Engineering method', <String>['calculat*', 'analys*', 'design*', 'model*', 'test*']),
      ],
    ),
    InterviewQuestion(
      id: 'en_calc',
      prompt: 'Calculation: check this footbridge beam.',
      competency: Competency.technical,
      practical: _beam,
    ),
    InterviewQuestion(
      id: 'en_q2',
      prompt: 'Your calculation shows a member is overstressed the day before the drawings are issued. What do you do?',
      competency: Competency.readiness,
      minWords: 30,
      probeId: 'en_q2p',
      rubric: <Concept>[
        Concept('stop', 'Stops the issue', <String>['stop', 'hold', 'do not issue', 'don\'t issue', 'delay']),
        Concept('tell', 'Tells the lead/checker', <String>['tell', 'inform', 'escalat*', 'checker', 'lead', 'manager']),
        Concept('fix', 'Proposes a fix', <String>['resize', 'redesign', 'larger section', 'recheck', 'revise']),
      ],
    ),
    InterviewQuestion(
      id: 'en_q2p',
      prompt: 'The project manager says the deadline cannot move. How do you respond?',
      competency: Competency.readiness,
      minWords: 20,
      rubric: <Concept>[
        Concept('safety', 'Safety over schedule', <String>['safety', 'cannot issue', 'professional', 'liab*', 'duty']),
      ],
    ),
    InterviewQuestion(
      id: 'en_q3',
      prompt: 'Which control is most effective in the hierarchy of controls?',
      competency: Competency.technical,
      options: <String>['PPE', 'Administrative control', 'Elimination', 'Engineering control'],
      correctOption: 2,
    ),
    InterviewQuestion(
      id: 'en_q4',
      prompt: 'How do you make sure your calculations are right before you hand them over?',
      competency: Competency.problemSolving,
      minWords: 25,
      rubric: <Concept>[
        Concept('units', 'Units and sense checks', <String>['units', 'sense check*', 'order of magnitude', 'estimate']),
        Concept('independent', 'Independent check', <String>['checker', 'independent', 'second engineer', 'peer review']),
        Concept('method', 'Alternative method', <String>['hand calc*', 'alternative method', 'software', 'compare']),
      ],
    ),
  ],
);

const List<AssignmentSpec> _enAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'en_a1',
    title: 'MER-2041 · Footbridge beam check',
    ticket: 'Check the main beam reactions and moments before the design review.',
    acceptance: <String>['All values within tolerance', 'Handoff note for the checker'],
    task: _beam,
  ),
  AssignmentSpec(
    id: 'en_a2',
    title: 'MER-2055 · Conveyor gearbox',
    ticket: 'The client wants to confirm output speed, torque and the tie-rod factor of safety.',
    acceptance: <String>['All values within tolerance'],
    task: _gears,
  ),
  AssignmentSpec(
    id: 'en_a3',
    title: 'MER-2060 · Sensor supply',
    ticket: 'Size the sensor supply for the plant upgrade.',
    acceptance: <String>['All values within tolerance'],
    task: _circuit,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'en_a4',
    title: 'MER-2071 · Design review: hazards',
    ticket: 'Classify the controls proposed at the design review.',
    acceptance: <String>['Every control classified correctly'],
    task: _hazards,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'en_a5',
    title: 'MER-2088 · Brine plant balance',
    ticket: 'Confirm the outlet flow and concentration for the process client.',
    acceptance: <String>['All values within tolerance'],
    task: _mix,
  ),
  AssignmentSpec(
    id: 'en_a6',
    title: 'MER-2093 · Line balance for the packing hall',
    ticket: 'The production client needs takt, station count and OEE.',
    acceptance: <String>['All values within tolerance'],
    task: _takt,
  ),
  AssignmentSpec(
    id: 'en_lead1',
    title: 'Lead the design review',
    ticket: 'Prepare the agenda and process for next week\'s multidisciplinary design review.',
    acceptance: <String>['Scope, roles, hazard review, actions tracked'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'review_plan',
      title: 'Design review plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('scope', 'Scope and objectives', <String>['scope', 'objective*', 'purpose']),
        Concept('roles', 'Roles and attendees', <String>['role*', 'attend*', 'each discipline', 'checker', 'chair']),
        Concept('hazard', 'Hazard review', <String>['hazard*', 'risk*', 'safety']),
        Concept('actions', 'Actions and owners', <String>['action*', 'owner*', 'due date*', 'track*']),
      ],
    ),
  ),
];

const List<WorkplaceDef> engineeringWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'en_meridian',
    deptId: 'engineering',
    name: 'Meridian Engineering — Design Office',
    environment: 'Drawing office with calculation templates; every package has a designer, a checker and an approver.',
    supervisor: 'Tomasz Kowalski',
    supervisorRole: 'Chartered Engineer, supervisor',
    tools: <String>['Calculation templates', 'CAD', 'Document control', 'Design review log'],
    assignments: _enAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Engineering Intern',
      CareerStage.entryLevel: 'Graduate Engineer',
      CareerStage.junior: 'Engineer',
      CareerStage.experienced: 'Chartered Engineer',
      CareerStage.senior: 'Senior Engineer',
      CareerStage.lead: 'Associate Director, Engineering',
    },
    returnOfferPostingId: 'en_grad_meridian',
  ),
];
