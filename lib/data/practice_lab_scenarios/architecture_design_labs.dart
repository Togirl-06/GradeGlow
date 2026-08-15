import '../../models/practice_lab.dart';

const Map<String, List<PracticeLabType>> architectureDesignLabs =
    <String, List<PracticeLabType>>{
  'architecture': <PracticeLabType>[
    PracticeLabType(
      id: 'arch_client_review',
      title: 'Client Design Review',
      subtitle:
          'Present your residential concept to a demanding homeowner client.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Design Client',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Walk the client through your floor plan',
        'Justify material and budget choices',
        'Address the client\'s lifestyle concerns',
      ],
      evaluationCriteria: <String>[
        'Clarity of design communication',
        'Responsiveness to client needs',
        'Feasibility of proposed solution',
      ],
    ),
    PracticeLabType(
      id: 'arch_code_feasibility',
      title: 'Building Code Feasibility',
      subtitle:
          'Defend your mixed-use proposal against a strict permitting official.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Building Code Official',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Confirm egress and fire separation compliance',
        'Demonstrate setback and height conformance',
        'Propose remedies for flagged violations',
      ],
      evaluationCriteria: <String>[
        'Accuracy of code interpretation',
        'Quality of compliance evidence',
        'Practicality of proposed fixes',
      ],
    ),
    PracticeLabType(
      id: 'arch_studio_critique',
      title: 'Studio Design Critique',
      subtitle:
          'Defend a bold civic pavilion concept before a sharp studio critic.',
      style: SimulationStyle.classroom,
      aiRole: 'Studio Critic',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Articulate your design concept and parti',
        'Defend spatial and structural decisions',
        'Respond to critique with revisions',
      ],
      evaluationCriteria: <String>[
        'Conceptual depth and originality',
        'Strength of design reasoning',
        'Composure under critique',
      ],
    ),
  ],
  'interior_design': <PracticeLabType>[
    PracticeLabType(
      id: 'int_space_concept',
      title: 'Client Space Concept',
      subtitle:
          'Pitch a cozy living-room concept to a hesitant first-time client.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Design Client',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Present mood board and color palette',
        'Explain furniture layout and flow',
        'Align the concept with client taste',
      ],
      evaluationCriteria: <String>[
        'Coherence of design vision',
        'Listening to client preferences',
        'Spatial planning quality',
      ],
    ),
    PracticeLabType(
      id: 'int_budget_tradeoffs',
      title: 'Budget Material Trade-offs',
      subtitle:
          'Negotiate finish choices with a client facing a tightened budget.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Budget-Conscious Client',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Compare premium and value materials',
        'Recommend cost-saving substitutions',
        'Protect design intent within budget',
      ],
      evaluationCriteria: <String>[
        'Soundness of material reasoning',
        'Cost-versus-quality judgment',
        'Persuasiveness of recommendations',
      ],
    ),
    PracticeLabType(
      id: 'int_accessibility_review',
      title: 'Accessibility Design Review',
      subtitle:
          'Review a clinic interior with an accessibility compliance officer.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Accessibility Officer',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Verify clearances and turning radii',
        'Assess tactile and signage provisions',
        'Revise layout for universal access',
      ],
      evaluationCriteria: <String>[
        'Knowledge of accessibility standards',
        'Thoroughness of design audit',
        'Inclusivity of final solution',
      ],
    ),
  ],
  'urban_planning': <PracticeLabType>[
    PracticeLabType(
      id: 'urban_zoning_hearing',
      title: 'Community Zoning Hearing',
      subtitle:
          'Defend a rezoning request before a skeptical community board.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Community Board Chair',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Summarize the rezoning rationale',
        'Address resident traffic concerns',
        'Propose community benefit measures',
      ],
      evaluationCriteria: <String>[
        'Clarity of public communication',
        'Handling of community objections',
        'Strength of planning justification',
      ],
    ),
    PracticeLabType(
      id: 'urban_transit_landuse',
      title: 'Transit Land-Use Proposal',
      subtitle:
          'Present a transit-oriented density plan to a regional planner.',
      style: SimulationStyle.systemDesign,
      aiRole: 'City Planner',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Map density around transit nodes',
        'Balance housing and commercial uses',
        'Project mobility and parking impacts',
      ],
      evaluationCriteria: <String>[
        'Integration of transit and land use',
        'Realism of density assumptions',
        'Sustainability of the proposal',
      ],
    ),
    PracticeLabType(
      id: 'urban_conflict_mediation',
      title: 'Stakeholder Conflict Mediation',
      subtitle:
          'Mediate a waterfront redevelopment dispute among rival stakeholders.',
      style: SimulationStyle.counseling,
      aiRole: 'Stakeholder Representative',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Surface each stakeholder\'s core interests',
        'Identify shared ground for compromise',
        'Propose a balanced development path',
      ],
      evaluationCriteria: <String>[
        'Neutrality and fairness in mediation',
        'Creativity of compromise solutions',
        'Effectiveness at de-escalation',
      ],
    ),
  ],
  'landscape_architecture': <PracticeLabType>[
    PracticeLabType(
      id: 'land_park_presentation',
      title: 'Park Design Presentation',
      subtitle:
          'Present a neighborhood park concept to a parks department client.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Parks Department Client',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Present circulation and program zones',
        'Explain planting and seating strategy',
        'Address maintenance and safety needs',
      ],
      evaluationCriteria: <String>[
        'Quality of site programming',
        'Clarity of design presentation',
        'Responsiveness to client goals',
      ],
    ),
    PracticeLabType(
      id: 'land_drainage_review',
      title: 'Sustainability Drainage Review',
      subtitle:
          'Defend a stormwater landscape design before a sustainability reviewer.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Sustainability Reviewer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Detail grading and drainage flow',
        'Integrate bioswales and permeable paving',
        'Quantify runoff reduction outcomes',
      ],
      evaluationCriteria: <String>[
        'Technical soundness of drainage plan',
        'Ecological sustainability of approach',
        'Clarity of performance evidence',
      ],
    ),
    PracticeLabType(
      id: 'land_site_concept',
      title: 'Client Site Concept',
      subtitle:
          'Pitch a sloped hillside garden concept to a discerning estate owner.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Estate Owner Client',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Interpret the site\'s terrain and views',
        'Propose terracing and planting themes',
        'Tie the concept to client lifestyle',
      ],
      evaluationCriteria: <String>[
        'Sensitivity to site context',
        'Originality of design concept',
        'Alignment with client aspirations',
      ],
    ),
  ],
  'industrial_design': <PracticeLabType>[
    PracticeLabType(
      id: 'ind_concept_pitch',
      title: 'Product Concept Pitch',
      subtitle:
          'Pitch a new kitchen-appliance concept to a product brand client.',
      style: SimulationStyle.customerScenario,
      aiRole: 'Product Brand Client',
      difficulty: 'Beginner',
      studentTasks: <String>[
        'Present the product concept and form',
        'Explain target user and value',
        'Defend aesthetic and ergonomic choices',
      ],
      evaluationCriteria: <String>[
        'Clarity of product vision',
        'Fit with user needs',
        'Persuasiveness of the pitch',
      ],
    ),
    PracticeLabType(
      id: 'ind_manufacturability_review',
      title: 'Usability Manufacturability Review',
      subtitle:
          'Defend your design against a manufacturing engineer\'s feasibility audit.',
      style: SimulationStyle.systemDesign,
      aiRole: 'Manufacturing Engineer',
      difficulty: 'Intermediate',
      studentTasks: <String>[
        'Justify material and tooling choices',
        'Address assembly and tolerance issues',
        'Balance usability with production cost',
      ],
      evaluationCriteria: <String>[
        'Awareness of manufacturing constraints',
        'Usability of the final form',
        'Quality of trade-off reasoning',
      ],
    ),
    PracticeLabType(
      id: 'ind_design_critique',
      title: 'Product Design Critique',
      subtitle:
          'Defend a flagship product portfolio before a senior design critic.',
      style: SimulationStyle.classroom,
      aiRole: 'Studio Critic',
      difficulty: 'Advanced',
      studentTasks: <String>[
        'Present the design story and intent',
        'Defend form, material, and detail',
        'Iterate the concept from feedback',
      ],
      evaluationCriteria: <String>[
        'Depth of design rationale',
        'Refinement of form and detail',
        'Maturity in handling critique',
      ],
    ),
  ],
};
