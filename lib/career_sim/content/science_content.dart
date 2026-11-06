import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// Natural Sciences (biology, chemistry, physics labs) and Mathematics.

// ======================================================= Natural Sciences

const LabelTaskSpec _cell = LabelTaskSpec(
  id: 'cell_label',
  title: 'Identify the organelles',
  brief: 'Label each marker on the electron-micrograph tracing of an animal cell.',
  diagram: 'cell',
  skills: <String>['sc_bio'],
  hotspots: <Hotspot>[
    Hotspot(0.50, 0.48, 'Nucleus'),
    Hotspot(0.24, 0.30, 'Mitochondrion'),
    Hotspot(0.08, 0.50, 'Cell membrane'),
    Hotspot(0.72, 0.30, 'Rough endoplasmic reticulum'),
    Hotspot(0.72, 0.72, 'Golgi apparatus'),
  ],
  distractors: <String>['Chloroplast', 'Cell wall'],
);

const NumericTaskSpec _dilution = NumericTaskSpec(
  id: 'dilution',
  title: 'Viable count by serial dilution',
  brief: 'A water sample is diluted 1:10 three times; 0.1 mL of the last tube is spread and gives 56 colonies.',
  skills: <String>['sc_bio', 'sc_quant'],
  givens: <Fact>[Fact('Dilutions', 'Three serial 1:10 dilutions'), Fact('Plated volume', '0.1 mL'), Fact('Colonies', '56')],
  parts: <NumericPart>[
    NumericPart('Total dilution factor', 1000, method: 'Multiply the dilution of each step.'),
    NumericPart('Viable count in the original sample', 560000, unit: 'CFU/mL', method: 'Colonies ÷ (volume plated × dilution).'),
  ],
);

const NumericTaskSpec _titration = NumericTaskSpec(
  id: 'titration',
  title: 'Acid–base titration',
  brief: '25.0 mL of NaOH is titrated with 0.100 mol/L HCl. Mean titre 22.40 mL. HCl + NaOH → NaCl + H₂O.',
  skills: <String>['sc_chem', 'sc_quant'],
  givens: <Fact>[Fact('HCl', '0.100 mol/L'), Fact('Mean titre', '22.40 mL'), Fact('NaOH aliquot', '25.0 mL')],
  parts: <NumericPart>[
    NumericPart('Moles of HCl used', 0.00224, unit: 'mol', relTol: 0.005, method: 'n = c × V (V in litres).'),
    NumericPart('Concentration of NaOH', 0.0896, unit: 'mol/L', relTol: 0.005, method: '1:1 ratio, then c = n ÷ V.'),
  ],
);

const NumericTaskSpec _kinematics = NumericTaskSpec(
  id: 'kinematics',
  title: 'Motion and measurement',
  brief: 'Analyse two experiments from the physics practical.',
  skills: <String>['sc_phys', 'sc_quant'],
  givens: <Fact>[
    Fact('Trolley', 'From rest, a = 2.5 m/s² for 8.0 s'),
    Fact('Pendulum', 'L = 0.500 m, g = 9.81 m/s²'),
    Fact('Measured g', '9.6 ± 0.3 m/s²'),
  ],
  parts: <NumericPart>[
    NumericPart('Final speed of the trolley', 20, unit: 'm/s', method: 'v = u + at.'),
    NumericPart('Distance travelled', 80, unit: 'm', method: 's = ut + ½at².'),
    NumericPart('Pendulum period', 1.418, unit: 's', relTol: 0.005, method: 'T = 2π√(L/g).'),
    NumericPart('Percentage uncertainty in measured g', 3.125, unit: '%', relTol: 0.01, method: 'Absolute uncertainty ÷ value × 100.'),
  ],
);

const ClassifyTaskSpec _labSafety = ClassifyTaskSpec(
  id: 'lab_safety',
  title: 'Laboratory safety decisions',
  brief: 'Classify each situation by the correct response.',
  skills: <String>['sc_lab'],
  categories: <String>['Fume cupboard', 'Biosafety cabinet', 'Stop and report', 'Standard bench is fine'],
  items: <ClassifyItem>[
    ClassifyItem('Diluting concentrated hydrochloric acid', 'Fume cupboard', 'Corrosive fumes must be extracted.'),
    ClassifyItem('Subculturing an unknown environmental isolate', 'Biosafety cabinet', 'Protects you and the culture from aerosols.'),
    ClassifyItem('Glassware cracked under vacuum', 'Stop and report', 'Implosion risk; stop the work and report it.'),
    ClassifyItem('Weighing sodium chloride', 'Standard bench is fine', 'Low hazard.'),
    ClassifyItem('Spill of an unlabelled liquid', 'Stop and report', 'Unknown hazard: isolate, report, follow the spill procedure.'),
  ],
);

const OrderTaskSpec _aseptic = OrderTaskSpec(
  id: 'aseptic',
  title: 'Aseptic transfer',
  brief: 'Order the steps to transfer a culture aseptically.',
  skills: <String>['sc_lab', 'sc_bio'],
  steps: <String>[
    'Disinfect the bench and wash hands',
    'Flame the loop until red-hot and let it cool',
    'Open the culture tube and flame its neck',
    'Remove a loopful of culture',
    'Flame the neck again and close the tube',
    'Inoculate the plate and flame the loop',
  ],
  why: 'Sterilise before and after every contact so neither the culture nor you is contaminated.',
);

const Department sciences = Department(
  id: 'sciences',
  title: 'Natural Sciences',
  school: 'Faculty of Science',
  emoji: '🔬',
  summary: 'Biology, chemistry and physics laboratories: real measurements, calculations and lab reports.',
  majors: <String>['biology', 'chemistry', 'physics', 'environmental_science'],
  skills: <SkillDef>[
    SkillDef('sc_bio', 'Biological techniques'),
    SkillDef('sc_chem', 'Analytical chemistry'),
    SkillDef('sc_phys', 'Experimental physics'),
    SkillDef('sc_quant', 'Quantitative analysis'),
    SkillDef('sc_lab', 'Laboratory safety & practice'),
  ],
  units: <DeptUnit>[
    DeptUnit(
      id: 'sc_bio_lab',
      title: 'Biology Laboratory',
      emoji: '🧬',
      setting: 'Microscopy bench, incubators and a class II biosafety cabinet.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'sc_m_bio',
          title: 'Cells and microbiology technique',
          summary: 'Identify organelles and perform aseptic technique and viable counts.',
          skills: <String>['sc_bio', 'sc_lab'],
          lesson: <LessonSection>[
            LessonSection('The eukaryotic cell', 'The nucleus holds DNA; mitochondria make ATP; rough ER makes proteins; the Golgi packages them; the membrane controls what enters.'),
            LessonSection('Aseptic technique', 'Flame the loop and the tube neck before and after every transfer; work near the flame or in a cabinet.'),
            LessonSection('Viable counts', 'CFU/mL = colonies ÷ (volume plated × total dilution). Count plates with 30–300 colonies.'),
          ],
          practice: <TaskSpec>[_cell, _aseptic, _dilution],
        ),
      ],
    ),
    DeptUnit(
      id: 'sc_chem_lab',
      title: 'Chemistry Laboratory',
      emoji: '⚗️',
      setting: 'Titration benches with burettes, pipettes and a fume cupboard.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'sc_m_chem',
          title: 'Volumetric analysis and safety',
          summary: 'Run a titration and choose the right containment.',
          skills: <String>['sc_chem', 'sc_lab'],
          lesson: <LessonSection>[
            LessonSection('Titration', 'Rinse the burette with titrant, record to 0.05 mL, repeat until concordant (within 0.10 mL). n = cV with V in litres.'),
            LessonSection('Containment', 'Fume cupboards for volatile or corrosive chemicals; biosafety cabinets for microorganisms.'),
          ],
          practice: <TaskSpec>[_titration, _labSafety],
        ),
      ],
    ),
    DeptUnit(
      id: 'sc_phys_lab',
      title: 'Physics Laboratory',
      emoji: '⚛️',
      setting: 'Air track, light gates, pendulum rig and data loggers.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'sc_m_phys',
          title: 'Kinematics and uncertainty',
          summary: 'Apply the equations of motion and quantify uncertainty.',
          skills: <String>['sc_phys', 'sc_quant'],
          lesson: <LessonSection>[
            LessonSection('Equations of motion', 'v = u + at; s = ut + ½at²; v² = u² + 2as — for constant acceleration.'),
            LessonSection('The simple pendulum', 'T = 2π√(L/g) for small swings.'),
            LessonSection('Uncertainty', 'Percentage uncertainty = absolute ÷ value × 100. Report results with their uncertainty.'),
          ],
          practice: <TaskSpec>[_kinematics],
        ),
      ],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'sc_p1',
          title: 'River water quality report',
          brief: 'Analyse river samples for alkalinity and bacterial load, then write the lab report.',
          requiresModules: <String>['sc_m_bio', 'sc_m_chem'],
          skills: <String>['sc_chem', 'sc_bio', 'sc_quant'],
          deliverables: <TaskSpec>[_titration, _dilution],
          writeUp: WrittenTaskSpec(
            id: 'lab_report',
            title: 'Lab report',
            brief: 'Write the report: aim, method, results, uncertainty and conclusion.',
            minWords: 100,
            rubric: <Concept>[
              Concept('aim', 'Aim', <String>['aim', 'purpose', 'to determine', 'to measure']),
              Concept('method', 'Method', <String>['titrat*', 'dilution*', 'plated', 'method', 'burette']),
              Concept('results', 'Results with units', <String>['mol/l', 'cfu', 'mol l', 'concentration']),
              Concept('error', 'Uncertainty / errors', <String>['uncertaint*', 'error*', 'concordant', 'repeat*']),
              Concept('conclude', 'Conclusion', <String>['conclu*', 'therefore', 'indicates', 'suggests']),
            ],
          ),
        ),
      ],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'sc_cert_lab',
      title: 'Laboratory Practice Certificate',
      issuer: 'GradeGlow Faculty of Science',
      requiresModules: <String>['sc_m_chem'],
      tasks: <TaskSpec>[_labSafety, _titration, _aseptic],
    ),
  ],
);

const CompanyProfile _kestrel = CompanyProfile(
  name: 'Kestrel Biosciences',
  industry: 'Pharmaceutical manufacturing and testing',
  about: 'Kestrel manufactures sterile injectables and runs an accredited QC laboratory.',
  team: 'The QC lab has chemistry and microbiology sections, each with a supervisor and five analysts.',
  training: 'Method training with sign-off, GMP training and support for professional registration.',
  culture: 'Good Manufacturing Practice: if it isn\'t documented, it didn\'t happen.',
  success: 'Accurate, documented results that pass second-person review.',
  tools: 'LIMS, calibrated balances and burettes, biosafety cabinets and an electronic lab notebook.',
  nextSteps: 'You will hear within two working days.',
);

const List<JobPosting> sciencePostings = <JobPosting>[
  JobPosting(
    id: 'sc_intern_kestrel',
    deptId: 'sciences',
    company: _kestrel,
    title: 'Research Laboratory Intern',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A summer placement in the QC laboratory.',
    responsibilities: <String>['Run routine assays', 'Record results in the notebook', 'Follow GMP procedures'],
    qualifications: <String>['Science student with Trainee status', 'Two laboratory modules'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['sc_m_bio', 'sc_m_chem'],
      skills: <String, int>{'sc_lab': 1, 'sc_quant': 1},
      projects: 0,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2400,
    salaryMax: 2800,
    salaryPeriod: 'month',
    location: 'On-site · Cambridge',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'sc_iv',
    workplaceId: 'sc_kestrel',
  ),
  JobPosting(
    id: 'sc_qc_kestrel',
    deptId: 'sciences',
    company: _kestrel,
    title: 'Junior QC Analyst',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'A permanent analyst role in chemistry and microbiology QC.',
    responsibilities: <String>['Test product batches', 'Investigate out-of-specification results', 'Maintain equipment records'],
    qualifications: <String>['Completed placement', 'Laboratory Practice Certificate'],
    experience: 'A completed laboratory placement.',
    requirements: JobRequirements(
      modules: <String>['sc_m_bio', 'sc_m_chem', 'sc_m_phys'],
      skills: <String, int>{'sc_lab': 2, 'sc_quant': 2, 'sc_chem': 1},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['sc_cert_lab'],
      completedInternship: true,
    ),
    salaryMin: 33000,
    salaryMax: 38000,
    location: 'On-site · Cambridge',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'sc_iv',
    workplaceId: 'sc_kestrel',
  ),
];

const InterviewPlan scienceInterview = InterviewPlan(
  id: 'sc_iv',
  interviewer: 'Dr Mei Chen',
  interviewerRole: 'QC Laboratory Manager',
  opening: 'Hello. I\'ll ask about your lab experience, give you a titration calculation and discuss data integrity.',
  main: <String>['sc_q1', 'sc_calc', 'sc_q2', 'sc_q3', 'sc_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'sc_q1',
      prompt: 'Describe a practical you carried out and how you made sure your results were reliable.',
      competency: Competency.communication,
      behavioural: true,
      minWords: 40,
      rubric: <Concept>[
        Concept('repeat', 'Repeats / concordance', <String>['repeat*', 'concordant', 'replicate*', 'triplicate']),
        Concept('calib', 'Calibration / controls', <String>['calibrat*', 'control*', 'blank', 'standard*']),
      ],
    ),
    InterviewQuestion(
      id: 'sc_calc',
      prompt: 'Calculation: determine the NaOH concentration.',
      competency: Competency.technical,
      practical: _titration,
    ),
    InterviewQuestion(
      id: 'sc_q2',
      prompt: 'A result is out of specification. What do you do?',
      competency: Competency.problemSolving,
      minWords: 30,
      probeId: 'sc_q2p',
      rubric: <Concept>[
        Concept('report', 'Reports immediately', <String>['report*', 'supervisor', 'inform*', 'raise']),
        Concept('nodelete', 'Does not discard or retest silently', <String>['not discard', 'don\'t discard', 'do not delete', 'keep the result', 'not retest', 'without approval']),
        Concept('investigate', 'Investigates lab error first', <String>['investigat*', 'lab error', 'check calculations', 'equipment', 'root cause']),
      ],
    ),
    InterviewQuestion(
      id: 'sc_q2p',
      prompt: 'Why can\'t you just repeat the test until it passes?',
      competency: Competency.readiness,
      minWords: 15,
      rubric: <Concept>[
        Concept('integrity', 'Data integrity', <String>['integrity', 'testing into compliance', 'bias', 'gmp', 'fraud']),
      ],
    ),
    InterviewQuestion(
      id: 'sc_q3',
      prompt: 'Which is the right containment for subculturing an unknown bacterial isolate?',
      competency: Competency.technical,
      options: <String>['Open bench', 'Fume cupboard', 'Biosafety cabinet', 'Cold room'],
      correctOption: 2,
    ),
    InterviewQuestion(
      id: 'sc_q4',
      prompt: 'How do you document lab work so another analyst could repeat it?',
      competency: Competency.readiness,
      minWords: 25,
      rubric: <Concept>[
        Concept('contemp', 'Recorded at the time', <String>['at the time', 'immediately', 'contemporaneous*', 'as i go']),
        Concept('detail', 'Method, equipment IDs, batches', <String>['equipment', 'batch*', 'lot', 'method', 'calibration']),
        Concept('sign', 'Signed and reviewed', <String>['sign*', 'review*', 'second person', 'witness*']),
      ],
    ),
  ],
);

const List<AssignmentSpec> _scAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'sc_a1',
    title: 'QC-311 · Alkalinity assay',
    ticket: 'Determine the NaOH concentration of batch 2207.',
    acceptance: <String>['Result within tolerance', 'Notebook entry handed over'],
    task: _titration,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'sc_a2',
    title: 'QC-318 · Bioburden count',
    ticket: 'Calculate the viable count for the water-system sample.',
    acceptance: <String>['Count within tolerance'],
    task: _dilution,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'sc_a3',
    title: 'QC-322 · Safety walk-round',
    ticket: 'Classify the issues found on today\'s safety walk-round.',
    acceptance: <String>['Every issue handled correctly'],
    task: _labSafety,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'sc_a4',
    title: 'QC-330 · Aseptic transfer qualification',
    ticket: 'Demonstrate the aseptic transfer procedure for requalification.',
    acceptance: <String>['Correct sequence'],
    task: _aseptic,
  ),
  AssignmentSpec(
    id: 'sc_a5',
    title: 'QC-341 · Equipment verification',
    ticket: 'Verify the light-gate rig used for the packaging drop test.',
    acceptance: <String>['All values within tolerance'],
    task: _kinematics,
  ),
  AssignmentSpec(
    id: 'sc_lead1',
    title: 'Lead an OOS investigation',
    ticket: 'Batch 2210 failed assay. Write the investigation plan for your team.',
    acceptance: <String>['Phase 1 lab check, root cause, CAPA, documentation'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'oos_plan',
      title: 'OOS investigation plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('phase1', 'Laboratory error check first', <String>['lab error', 'phase 1', 'calculation*', 'equipment', 'analyst']),
        Concept('root', 'Root cause analysis', <String>['root cause', 'fishbone', 'five whys', '5 whys']),
        Concept('capa', 'Corrective and preventive action', <String>['capa', 'corrective', 'preventive']),
        Concept('doc', 'Documentation and QA', <String>['document*', 'qa', 'quality assurance', 'record*']),
      ],
    ),
  ),
];

const List<WorkplaceDef> scienceWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'sc_kestrel',
    deptId: 'sciences',
    name: 'Kestrel Biosciences — QC Laboratory',
    environment: 'GMP laboratory: gowning, calibrated equipment, electronic notebook and second-person review of every result.',
    supervisor: 'Dr Mei Chen',
    supervisorRole: 'QC Laboratory Manager',
    tools: <String>['LIMS', 'Electronic lab notebook', 'Burettes & balances', 'Biosafety cabinet'],
    assignments: _scAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Laboratory Intern',
      CareerStage.entryLevel: 'Junior QC Analyst',
      CareerStage.junior: 'QC Analyst',
      CareerStage.experienced: 'Senior QC Analyst',
      CareerStage.senior: 'QC Team Leader',
      CareerStage.lead: 'QC Laboratory Manager',
    },
    returnOfferPostingId: 'sc_qc_kestrel',
  ),
];

// ============================================================ Mathematics

const NumericTaskSpec _stats = NumericTaskSpec(
  id: 'stats',
  title: 'Sample statistics',
  brief: 'Delivery times (minutes) for five orders: 12, 15, 11, 18, 14.',
  skills: <String>['ma_stats'],
  givens: <Fact>[Fact('Data', '12, 15, 11, 18, 14'), Fact('t (4 d.f., 95%)', '2.776')],
  parts: <NumericPart>[
    NumericPart('Mean', 14, method: 'Sum ÷ n.'),
    NumericPart('Sample variance', 7.5, method: 'Σ(x − mean)² ÷ (n − 1).'),
    NumericPart('Sample standard deviation', 2.739, relTol: 0.005, method: 'Square root of the variance.'),
    NumericPart('Half-width of the 95% confidence interval', 3.40, relTol: 0.01, method: 't × s ÷ √n.'),
  ],
);

const NumericTaskSpec _regression = NumericTaskSpec(
  id: 'regression',
  title: 'Fit a linear model',
  brief: 'Shuttle demand (x = week, y = hundreds of riders): (1, 3), (2, 5), (3, 7), (4, 9).',
  skills: <String>['ma_model'],
  givens: <Fact>[Fact('Data', '(1,3), (2,5), (3,7), (4,9)')],
  parts: <NumericPart>[
    NumericPart('Least-squares slope', 2, method: 'b = Σ(x−x̄)(y−ȳ) ÷ Σ(x−x̄)².'),
    NumericPart('Intercept', 1, method: 'a = ȳ − b x̄.'),
    NumericPart('Predicted demand in week 10', 21, method: 'y = a + b x.'),
  ],
);

const NumericTaskSpec _bayes = NumericTaskSpec(
  id: 'bayes',
  title: 'Quality test: Bayes\' theorem',
  brief: '2% of parts are defective. The test flags 95% of defective parts and 5% of good parts.',
  skills: <String>['ma_stats'],
  givens: <Fact>[Fact('P(defect)', '0.02'), Fact('P(+ | defect)', '0.95'), Fact('P(+ | good)', '0.05')],
  parts: <NumericPart>[
    NumericPart('P(positive test)', 0.068, relTol: 0.005, method: 'Law of total probability.'),
    NumericPart('P(defect | positive)', 0.2794, relTol: 0.005, method: 'Bayes: P(+|D)P(D) ÷ P(+).'),
  ],
);

const OrderTaskSpec _proof = OrderTaskSpec(
  id: 'proof',
  title: 'Proof: √2 is irrational',
  brief: 'Put the steps of the proof by contradiction in order.',
  skills: <String>['ma_proof'],
  steps: <String>[
    'Assume √2 = p/q with p, q integers with no common factor',
    'Square both sides: p² = 2q²',
    'So p² is even, hence p is even: p = 2k',
    'Substitute: 4k² = 2q², so q² = 2k²',
    'So q is even too',
    'p and q share the factor 2 — a contradiction, so √2 is irrational',
  ],
);

const Department mathematics = Department(
  id: 'mathematics',
  title: 'Mathematics & Statistics',
  school: 'School of Mathematics',
  emoji: '📐',
  summary: 'Applied statistics, modelling and proof, used on real analytical work.',
  majors: <String>['mathematics', 'statistics'],
  skills: <SkillDef>[
    SkillDef('ma_stats', 'Statistics & probability'),
    SkillDef('ma_model', 'Mathematical modelling'),
    SkillDef('ma_proof', 'Proof & rigour'),
    SkillDef('ma_algebra', 'Algebra & equation solving'),
    SkillDef('ma_calc', 'Calculus'),
    SkillDef('ma_linalg', 'Linear algebra'),
    SkillDef('ma_de', 'Differential equations'),
  ],
  units: <DeptUnit>[
    DeptUnit(
      id: 'ma_lab',
      title: 'Applied Mathematics Lab',
      emoji: '📊',
      setting: 'Analytics lab with datasets from campus services and a statistics package.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'ma_m_stats',
          title: 'Inference and probability',
          summary: 'Summaries, confidence intervals and conditional probability.',
          skills: <String>['ma_stats'],
          lesson: <LessonSection>[
            LessonSection('Spread', 'Sample variance divides by n − 1 to estimate the population variance without bias.'),
            LessonSection('Confidence intervals', 'mean ± t × s/√n. Small samples use the t distribution.'),
            LessonSection('Bayes', 'P(A|B) = P(B|A)P(A)/P(B). Rare conditions give many false positives even with good tests.'),
          ],
          practice: <TaskSpec>[_stats, _bayes],
        ),
        TrainingModule(
          id: 'ma_m_model',
          title: 'Linear models and proof',
          summary: 'Fit and use a linear model; structure a rigorous argument.',
          skills: <String>['ma_model', 'ma_proof'],
          lesson: <LessonSection>[
            LessonSection('Least squares', 'The line minimising squared residuals has slope Sxy/Sxx and passes through (x̄, ȳ).'),
            LessonSection('Proof by contradiction', 'Assume the opposite of what you want, derive an impossibility.'),
          ],
          practice: <TaskSpec>[_regression, _proof],
        ),
      ],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'ma_p1',
          title: 'Shuttle demand forecast',
          brief: 'Forecast campus shuttle demand and advise transport services.',
          requiresModules: <String>['ma_m_model'],
          skills: <String>['ma_model', 'ma_stats'],
          deliverables: <TaskSpec>[_regression, _stats],
          writeUp: WrittenTaskSpec(
            id: 'forecast_memo',
            title: 'Forecast memo',
            brief: 'Write the memo: model, forecast, uncertainty, assumptions and recommendation.',
            minWords: 90,
            rubric: <Concept>[
              Concept('model', 'The model', <String>['linear', 'regression', 'slope', 'model']),
              Concept('forecast', 'The forecast', <String>['forecast', 'predict*', 'week 10', '21']),
              Concept('uncertainty', 'Uncertainty', <String>['confidence', 'uncertain*', 'interval', 'error']),
              Concept('assume', 'Assumptions/limits', <String>['assum*', 'trend continues', 'limitation*', 'extrapolat*']),
              Concept('rec', 'Recommendation', <String>['recommend*', 'should', 'advise']),
            ],
          ),
        ),
      ],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'ma_cert_stats',
      title: 'Applied Statistics Certificate',
      issuer: 'GradeGlow School of Mathematics',
      requiresModules: <String>['ma_m_stats'],
      tasks: <TaskSpec>[_stats, _bayes, _regression],
    ),
  ],
);

const CompanyProfile _quanta = CompanyProfile(
  name: 'Quanta Analytics',
  industry: 'Data analytics consultancy',
  about: 'Quanta builds forecasting and quality analytics for transport, retail and manufacturing clients.',
  team: 'Analysts work in pods of four with a lead statistician.',
  training: 'Peer code/analysis review, a mentor and funded professional statistics exams.',
  culture: 'Show your working; every number in a client deck is reproducible.',
  success: 'Correct, reproducible analyses with clearly stated uncertainty.',
  tools: 'Python/R notebooks, SQL and a BI tool.',
  nextSteps: 'We\'ll come back to you within two working days.',
);

const List<JobPosting> mathPostings = <JobPosting>[
  JobPosting(
    id: 'ma_intern_quanta',
    deptId: 'mathematics',
    company: _quanta,
    title: 'Data Analyst Intern',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A summer internship producing client analyses.',
    responsibilities: <String>['Clean and summarise data', 'Fit simple models', 'Write findings'],
    qualifications: <String>['Mathematics/statistics student with Trainee status'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['ma_m_stats', 'ma_m_model'],
      skills: <String, int>{'ma_stats': 1, 'ma_model': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2800,
    salaryMax: 3200,
    salaryPeriod: 'month',
    location: 'Hybrid · Edinburgh',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'ma_iv',
    workplaceId: 'ma_quanta',
  ),
  JobPosting(
    id: 'ma_analyst_quanta',
    deptId: 'mathematics',
    company: _quanta,
    title: 'Junior Data Analyst',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'A permanent analyst role.',
    responsibilities: <String>['Own client analyses', 'Build forecasts', 'Present to clients'],
    qualifications: <String>['Completed internship', 'Applied Statistics Certificate'],
    experience: 'A completed analytics internship.',
    requirements: JobRequirements(
      modules: <String>['ma_m_stats', 'ma_m_model'],
      skills: <String, int>{'ma_stats': 2, 'ma_model': 2},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['ma_cert_stats'],
      completedInternship: true,
    ),
    salaryMin: 40500,
    salaryMax: 48500,
    location: 'Hybrid · Edinburgh',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'ma_iv',
    workplaceId: 'ma_quanta',
  ),
];

const InterviewPlan mathInterview = InterviewPlan(
  id: 'ma_iv',
  interviewer: 'Fiona MacLeod',
  interviewerRole: 'Lead Statistician',
  opening: 'Welcome. We\'ll do a short statistics exercise and talk about communicating results.',
  main: <String>['ma_q1', 'ma_calc', 'ma_q2', 'ma_q3'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'ma_q1',
      prompt: 'How would you explain a confidence interval to a client with no statistics background?',
      competency: Competency.communication,
      minWords: 30,
      rubric: <Concept>[
        Concept('range', 'A range of plausible values', <String>['range', 'between', 'plausible', 'likely values']),
        Concept('conf', 'What the confidence means', <String>['95', 'confiden*', 'repeated', 'most of the time']),
        Concept('plain', 'Plain language', <String>['for example', 'imagine', 'in other words', 'simply']),
      ],
    ),
    InterviewQuestion(
      id: 'ma_calc',
      prompt: 'Exercise: summarise these delivery times.',
      competency: Competency.technical,
      practical: _stats,
    ),
    InterviewQuestion(
      id: 'ma_q2',
      prompt: 'A test is 95% accurate and the condition affects 2% of items. A client says a positive result means 95% chance of a defect. Respond.',
      competency: Competency.problemSolving,
      minWords: 30,
      rubric: <Concept>[
        Concept('base', 'Base rate', <String>['base rate', 'prevalence', 'rare', '2%']),
        Concept('fp', 'False positives', <String>['false positive*', 'good parts', 'flags good']),
        Concept('bayes', 'Bayes / about 28%', <String>['bayes', '28', 'about a quarter', 'conditional']),
      ],
    ),
    InterviewQuestion(
      id: 'ma_q3',
      prompt: 'Which divides by n − 1?',
      competency: Competency.technical,
      options: <String>['Population variance', 'Sample variance', 'Mean', 'Median'],
      correctOption: 1,
    ),
  ],
);

const List<AssignmentSpec> _maAssignments = <AssignmentSpec>[
  AssignmentSpec(id: 'ma_a1', title: 'Client: CityCouriers — delivery KPIs', ticket: 'Summarise delivery times with a 95% interval.',
      acceptance: <String>['All values within tolerance'], task: _stats, deadlineDays: 1),
  AssignmentSpec(id: 'ma_a2', title: 'Client: Campus Transport — forecast', ticket: 'Fit the demand model and forecast week 10.',
      acceptance: <String>['Model and forecast correct'], task: _regression),
  AssignmentSpec(id: 'ma_a3', title: 'Client: Axis Parts — test accuracy', ticket: 'Explain the real meaning of a positive test.',
      acceptance: <String>['Probabilities correct'], task: _bayes, deadlineDays: 1),
  AssignmentSpec(id: 'ma_a4', title: 'Internal: methods review', ticket: 'Check the proof in the methods appendix.',
      acceptance: <String>['Correct order'], task: _proof),
  AssignmentSpec(
    id: 'ma_lead1',
    title: 'Lead the analytics pod',
    ticket: 'Plan the next client engagement for your pod of three analysts.',
    acceptance: <String>['Scope, allocation, review, reproducibility'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'pod_plan',
      title: 'Engagement plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('scope', 'Scope', <String>['scope', 'question*', 'objective*']),
        Concept('alloc', 'Allocation', <String>['allocat*', 'analyst*', 'assign*']),
        Concept('review', 'Review', <String>['review*', 'check*', 'peer']),
        Concept('repro', 'Reproducibility', <String>['reproducib*', 'notebook*', 'version control', 'documented']),
      ],
    ),
  ),
];

const List<WorkplaceDef> mathWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'ma_quanta',
    deptId: 'mathematics',
    name: 'Quanta Analytics — Forecasting pod',
    environment: 'Client analyses in shared notebooks; every deliverable is peer reviewed before release.',
    supervisor: 'Fiona MacLeod',
    supervisorRole: 'Lead Statistician',
    tools: <String>['Analysis notebooks', 'SQL', 'BI dashboards'],
    assignments: _maAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Data Analyst Intern',
      CareerStage.entryLevel: 'Junior Data Analyst',
      CareerStage.junior: 'Data Analyst',
      CareerStage.experienced: 'Senior Data Analyst',
      CareerStage.senior: 'Principal Analyst',
      CareerStage.lead: 'Analytics Lead',
    },
    returnOfferPostingId: 'ma_analyst_quanta',
  ),
];
