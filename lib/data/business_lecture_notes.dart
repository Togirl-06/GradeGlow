import '../models/business_school.dart';

/// Topic-specific lecture chapters for every Business School lesson.
abstract final class BusinessLectureNotes {
  static BusinessLectureNote forLesson(String lessonId) {
    final BusinessLectureNote? note = _byId[lessonId];
    if (note == null) {
      throw StateError('Missing business lecture notes for lesson: $lessonId');
    }
    return note;
  }

  /// Full textbook chapter for any lesson path.
  ///
  /// Curated seed notes are expanded into complete chapters; every other
  /// lesson receives a topic-specific textbook chapter generated from the
  /// lesson title, course, outcomes, and discipline.
  static BusinessLectureNote forPath(BusinessLessonPath path) {
    final BusinessLectureNote? seed = _byId[path.lesson.id];
    return _buildFullTextbook(path, seed: seed);
  }

  static bool hasNotes(String lessonId) => _byId.containsKey(lessonId);

  static Iterable<String> get lessonIds => _byId.keys;

  static BusinessLectureNote _buildFullTextbook(
    BusinessLessonPath path, {
    BusinessLectureNote? seed,
  }) {
    final String topic = path.lesson.title;
    final String course = path.course.title;
    final String discipline = path.major.title;
    final String field = discipline.toLowerCase();
    final List<String> outcomes = path.lesson.outcomes;

    final List<String> definitions = _definitionsFor(path.major, topic);
    final List<BusinessTextbookSection> sections = _theorySections(
      path.major,
      topic,
      course,
      outcomes,
    );
    final List<String> formulas = <String>[
      ...?seed?.formulas,
      ..._formulasFor(path.major, topic),
    ];
    final List<String> uniqueFormulas = <String>[
      ...{...formulas},
    ];

    final String overview = seed == null
        ? _overview(topic, course, discipline, outcomes)
        : '${_overview(topic, course, discipline, outcomes)}\n\n'
              'Core chapter focus: ${seed.overview}';

    final List<String> keyConcepts = <String>[
      ..._foundations(path.major),
      ...?seed?.keyConcepts,
      ...outcomes.map(
        (String outcome) =>
            'Learning objective — $outcome. To demonstrate mastery, define the '
            'governing principle, identify the required evidence, perform the '
            'analysis, state assumptions, and explain what evidence would '
            'invalidate the conclusion.',
      ),
    ];

    final String workedExample = seed == null
        ? _workedExample(path.major, topic, discipline)
        : '${_workedExample(path.major, topic, discipline)}\n\n'
              'Illustrative calculation from this chapter:\n${seed.workedExample}';

    final String application = seed == null
        ? _application(topic, field)
        : '${_application(topic, field)}\n\n'
              'Applied emphasis for this topic: ${seed.application}';

    final List<String> mistakes = <String>[
      ..._commonMistakes(path.major, topic),
      ...?seed?.commonMistakes,
    ];

    final String summary = seed == null
        ? _summary(topic, outcomes)
        : '${_summary(topic, outcomes)}\n\n'
              'Remember: ${seed.summary}';

    final List<String> review = <String>[
      ..._reviewQuestions(topic),
      ...?seed?.reviewQuestions,
    ];

    return BusinessLectureNote(
      lessonId: path.lesson.id,
      overview: overview,
      keyConcepts: <String>[
        ...{...keyConcepts},
      ],
      formulas: uniqueFormulas,
      workedExample: workedExample,
      application: application,
      commonMistakes: <String>[
        ...{...mistakes},
      ],
      summary: summary,
      reviewQuestions: <String>[
        ...{...review},
      ],
      definitions: definitions,
      sections: sections,
      practiceProblems: _practiceProblems(path.major, topic),
    );
  }

  static String _overview(
    String topic,
    String course,
    String discipline,
    List<String> outcomes,
  ) {
    final String outcomeText = outcomes.isEmpty
        ? 'explain theory, apply methods, and evaluate evidence'
        : outcomes.map((String o) => o.toLowerCase()).join('; ');
    return 'Chapter title: $topic\n'
        'Course: $course\n'
        'Field: $discipline\n\n'
        'This is a complete textbook chapter, not a summary. It explains $topic '
        'from first principles, develops the vocabulary and theory in full, '
        'shows formulas and frameworks with interpretation, walks through a '
        'detailed worked analysis, connects the ideas to professional practice, '
        'and ends with practice problems and review questions.\n\n'
        'Why this chapter matters: decisions involving $topic affect customers, '
        'employees, investors, regulators, and society. Incomplete reasoning '
        'creates costly errors: wrong prices, weak controls, misleading reports, '
        'failed strategies, and unethical outcomes. Mastery means you can teach '
        'the idea to a peer, defend it under questioning, and apply it to a new '
        'case without copying a template.\n\n'
        'By the end of this chapter you will be able to $outcomeText. Read '
        'slowly. Define every new term. Rework every calculation. Do not skip '
        'sections because later applications depend on earlier theory.';
  }

  static List<String> _foundations(BusinessMajor major) => switch (major) {
    BusinessMajor.businessAdministration => <String>[
      'Decision context: identify the organization, stakeholders, objective, constraints, resources, and time horizon before choosing an action.',
      'Causal operating model: map how people, processes, incentives, information, and technology combine to produce results.',
      'Strategic coherence: test whether the action strengthens a durable advantage or merely creates temporary activity.',
      'Value and trade-offs: measure benefits, costs, risks, and distributional effects for every major option, including doing nothing.',
      'Execution system: assign owners, metrics, thresholds, review cadence, escalation paths, and ethical boundaries.',
      'Learning loop: after action, compare outcomes with predictions, update assumptions, and institutionalize what worked.',
    ],
    BusinessMajor.economics => <String>[
      'Agents and constraints: specify who chooses, what they want, what they know, and what limits them.',
      'Opportunity cost: every choice is evaluated against the best forgone alternative, not against zero.',
      'Incentives: prices, taxes, subsidies, contracts, norms, and regulations change behavior by changing payoffs.',
      'Equilibrium thinking: describe a benchmark outcome, then use comparative statics to predict responses to shocks.',
      'Efficiency versus equity: separate total surplus from who gains and who loses, and state the normative criterion used.',
      'Identification: distinguish theory, correlation, accounting identity, and credible causal evidence.',
    ],
    BusinessMajor.finance => <String>[
      'Cash-flow mapping: identify amount, timing, uncertainty, currency, and seniority of every claim.',
      'Time value of money: a dollar today is not equal to a dollar later because of opportunity cost and risk.',
      'Risk decomposition: separate market, credit, liquidity, operational, model, and behavioral exposures.',
      'Required return discipline: discount or evaluate cash flows with a rate consistent with their risk.',
      'Portfolio thinking: judge positions by contribution to total risk and return, not by isolated stories.',
      'Governance and incentives: capital decisions reflect agency conflicts, covenants, regulation, and information asymmetry.',
    ],
    BusinessMajor.marketing => <String>[
      'Customer job: define the progress the customer seeks, the barriers, and the alternatives already in use.',
      'Segmentation discipline: create groups that differ in needs, behavior, and profitability and that can be reached.',
      'Value proposition design: align offer, proof, price, channel, and experience around a clear positioning.',
      'Journey measurement: connect awareness, consideration, conversion, retention, and advocacy with unit economics.',
      'Experimentation: treat campaigns and product changes as tests with hypotheses, controls, and decision rules.',
      'Ethics of influence: persuasion must respect autonomy, truthfulness, privacy, and fairness.',
    ],
    BusinessMajor.accounting => <String>[
      'Economic event recognition: identify what happened, when it happened, and which accounts are affected.',
      'Measurement bases: distinguish historical cost, amortized cost, fair value, net realizable value, and estimates.',
      'Double-entry integrity: every transaction preserves Assets = Liabilities + Equity through balanced debits and credits.',
      'Control objectives: design for authorization, completeness, accuracy, cutoff, classification, and restricted access.',
      'Statement articulation: link income, financial position, cash flow, equity, tax, and disclosures into one story.',
      'Professional skepticism: challenge management assertions with evidence, alternatives, and documented judgment.',
    ],
  };

  static List<String> _definitionsFor(BusinessMajor major, String topic) {
    final List<String> shared = <String>[
      'Concept: a named idea used to organize evidence and predictions about $topic.',
      'Assumption: a statement treated as true for analysis that must be tested or bounded.',
      'Counterfactual: what would have happened under an alternative decision or policy.',
      'Evidence: observable information that supports, weakens, or refutes a claim.',
      'Model: a simplified representation that links inputs to outputs through explicit relationships.',
      'Decision rule: the criterion used to choose among options once analysis is complete.',
    ];
    final List<String> field = switch (major) {
      BusinessMajor.businessAdministration => <String>[
        'Stakeholder: any party affected by or able to affect the organization\'s outcomes.',
        'KPI: a measurable indicator used to manage performance toward a defined objective.',
        'Capability: an organizational ability that is valuable, scarce, and hard to imitate.',
        'Governance: the system of rights, responsibilities, and oversight that guides decisions.',
        'Unit economics: contribution and cost structure measured at the level of one customer, product, or transaction.',
      ],
      BusinessMajor.economics => <String>[
        'Marginal analysis: evaluating the incremental benefit and cost of one more unit of activity.',
        'Elasticity: the percentage response of one variable to a one-percent change in another.',
        'Market failure: a situation where unregulated markets do not achieve an efficient allocation.',
        'Externality: a cost or benefit imposed on third parties not reflected in private prices.',
        'Welfare: a normative evaluation of outcomes based on efficiency, equity, or social criteria.',
      ],
      BusinessMajor.finance => <String>[
        'Present value: the current worth of future cash flows discounted at a risk-appropriate rate.',
        'Expected return: the probability-weighted average of possible returns.',
        'Systematic risk: risk that cannot be eliminated by diversification within the relevant market.',
        'Liquidity: the ability to convert an asset into cash quickly without large price impact.',
        'Capital structure: the mix of debt, equity, and hybrid claims used to fund the firm.',
      ],
      BusinessMajor.marketing => <String>[
        'Positioning: the intended meaning of the brand in the customer\'s mind relative to alternatives.',
        'Conversion: the rate at which an audience completes a desired action.',
        'Customer lifetime value: the discounted contribution expected from a customer relationship.',
        'Attribution: the method used to credit marketing activities for observed outcomes.',
        'Brand equity: the differential effect of brand knowledge on customer response.',
      ],
      BusinessMajor.accounting => <String>[
        'Recognition: deciding whether and when an item enters the financial statements.',
        'Accrual: recording economic effects in the period they occur, not only when cash moves.',
        'Materiality: the threshold at which an omission or misstatement could influence users.',
        'Internal control: processes designed to provide reasonable assurance about reporting and compliance.',
        'Audit evidence: information used to support or refute management\'s financial assertions.',
      ],
    };
    return <String>[
      'Topic anchor: $topic is the subject of this chapter and the decision domain under study.',
      ...field,
      ...shared,
    ];
  }

  static List<BusinessTextbookSection> _theorySections(
    BusinessMajor major,
    String topic,
    String course,
    List<String> outcomes,
  ) {
    final String o1 = outcomes.isNotEmpty
        ? outcomes[0]
        : 'explain the core theory';
    final String o2 = outcomes.length > 1
        ? outcomes[1]
        : 'apply the method to a real case';
    final String o3 = outcomes.length > 2
        ? outcomes[2]
        : 'evaluate limitations and ethical implications';

    return <BusinessTextbookSection>[
      BusinessTextbookSection(
        title: 'A. Setting and scope of $topic',
        body:
            'Begin by locating $topic inside $course. Ask four questions before any calculation: '
            '(1) What decision does this chapter help someone make? '
            '(2) Who are the decision makers and affected parties? '
            '(3) What information is available, delayed, noisy, or missing? '
            '(4) What constraints—legal, ethical, financial, operational, or political—bound the choice?\n\n'
            'Write the decision in one sentence. Example form: “Choose among options A, B, and C to improve '
            'outcome X for population Y over horizon Z, subject to constraints W.” If you cannot write that '
            'sentence, you are not ready to apply methods. Scope also includes what this chapter does not cover: '
            'adjacent topics matter, but they must not dilute the analysis of $topic itself.',
      ),
      BusinessTextbookSection(
        title: 'B. Historical development and competing views',
        body:
            'Every mature idea in this field has a history. Early practice often relied on rules of thumb. '
            'Later research formalized mechanisms, identified exceptions, and created measurement tools. '
            'For $topic, study at least two competing perspectives: a mainstream or textbook view and a critical '
            'or alternative view. The mainstream view usually emphasizes efficiency, optimization, or standard '
            'procedure. The alternative view may emphasize power, institutions, behavioral limits, distribution, '
            'or implementation failure.\n\n'
            'Do not treat disagreement as noise. Competing views tell you which assumptions are contested. '
            'When you recommend an action, state which view you are using and what evidence would push you '
            'toward the alternative interpretation. This is how professionals and researchers avoid dogma.',
      ),
      BusinessTextbookSection(
        title: 'C. Core theory explained in full',
        body:
            'The central theory of $topic can be stated in three layers.\n\n'
            'Layer 1 — Definitions: name the objects, variables, and relationships. Every symbol or term must '
            'map to something observable or clearly estimated.\n\n'
            'Layer 2 — Mechanism: explain why the relationship should exist. A mechanism is a causal story: '
            'if condition C changes, process P responds, which moves outcome O. If you cannot state the '
            'mechanism, you only have a correlation slogan.\n\n'
            'Layer 3 — Predictions: derive testable implications. Good theory predicts what rises, falls, or '
            'stays unchanged when an input changes. It also predicts where the theory should fail.\n\n'
            'Connect this structure to the chapter objective: $o1. Write the theory until a classmate who missed '
            'class can reconstruct it from your notes alone.',
      ),
      BusinessTextbookSection(
        title: 'D. Measurement, data, and evidence standards',
        body:
            'Theory without measurement remains speculation. For $topic, classify evidence into four grades:\n\n'
            '1. Descriptive facts: volumes, rates, balances, counts, and timestamps.\n'
            '2. Comparative benchmarks: peers, history, plans, or regulatory thresholds.\n'
            '3. Analytical estimates: models, regressions, valuations, costings, or experiments.\n'
            '4. Causal claims: designs that isolate the effect of a specific intervention.\n\n'
            'Always record source, date, definition, sample, and known bias. Never present a chart without '
            'units. Never present a coefficient without identifying assumptions. When evidence conflicts, '
            'do not average blindly; explain which source is more relevant to the decision and why.',
      ),
      BusinessTextbookSection(
        title: 'E. Methods and step-by-step procedure',
        body:
            'Use this standard procedure for any analysis of $topic:\n\n'
            'Step 1. Restate the decision and success criterion.\n'
            'Step 2. List options, including the status quo.\n'
            'Step 3. Identify required inputs and missing data.\n'
            'Step 4. Select the framework or formula that matches the decision.\n'
            'Step 5. Compute a transparent base case with every assumption visible.\n'
            'Step 6. Stress-test the two or three assumptions that most affect the answer.\n'
            'Step 7. Interpret results in plain language for the audience.\n'
            'Step 8. Recommend an action with owner, metric, threshold, and review date.\n'
            'Step 9. State residual risks and monitoring signals.\n\n'
            'This procedure fulfills the applied objective: $o2. Skipping steps is the most common cause of '
            'confident but wrong recommendations.',
      ),
      BusinessTextbookSection(
        title: 'F. Institutional, ethical, and distributional context',
        body:
            'No technical answer is complete until you examine institutions and consequences. Ask:\n\n'
            '• Who gains and who loses if the recommendation is adopted?\n'
            '• Which laws, standards, contracts, or norms constrain the choice?\n'
            '• What incentives might cause agents to game the metric or hide information?\n'
            '• What irreversible harms must be avoided even if expected value looks attractive?\n'
            '• What disclosure or consent obligations apply?\n\n'
            'Address the evaluative objective: $o3. Ethical analysis is not an appendix; it can reverse an '
            'otherwise profitable recommendation. Write the ethical constraint before you finalize the decision.',
      ),
      BusinessTextbookSection(
        title: 'G. Integration with adjacent topics',
        body:
            '$topic rarely stands alone. Link it upstream to diagnosis and downstream to implementation. '
            'Upstream links include market conditions, customer needs, accounting quality, capital availability, '
            'and organizational capability. Downstream links include operating plans, dashboards, contracts, '
            'controls, and communication.\n\n'
            'Build a one-page systems map: inputs → process → outputs → feedback. Mark where delays, noise, '
            'and incentive conflicts sit. This map prevents local optimization—improving one metric while '
            'damaging the system. In examinations and board papers, examiners reward students who show these '
            'linkages explicitly.',
      ),
      BusinessTextbookSection(
        title: 'H. Limits of the theory and open research questions',
        body:
            'Every framework for $topic has boundaries. Common limits include unstable parameters, selection '
            'bias, omitted variables, model risk, rare events, institutional differences across countries, and '
            'behavioral responses that invalidate historical elasticities.\n\n'
            'State the boundary conditions in writing: “This method is reliable when A and B hold; it is weak '
            'when C or D occurs.” Then list open questions a researcher or advanced practitioner would pursue: '
            'better measurement, stronger identification, richer dynamics, or distributional analysis. Treating '
            'limits seriously is a mark of expertise, not weakness.',
      ),
    ];
  }

  static List<String> _formulasFor(
    BusinessMajor major,
    String topic,
  ) => switch (major) {
    BusinessMajor.businessAdministration => <String>[
      'Expected decision value = Σ (probability_i × net payoff_i) − risk adjustment',
      'Contribution margin = Price − Variable cost per unit',
      'Productivity = Quality-adjusted output / Resource input',
      'Variance = Actual result − Planned result',
      'Payback period ≈ Initial investment / Periodic net inflow',
      'Stakeholder impact score = Benefit to group − Cost to group (qualitative + quantitative)',
      'For $topic: Base case + Sensitivity cases = Decision range',
    ],
    BusinessMajor.economics => <String>[
      'Marginal rule: choose activity until MB = MC',
      'Elasticity = (%Δ outcome) / (%Δ driver)',
      'Consumer surplus ≈ area under demand above price',
      'Producer surplus ≈ area above supply below price',
      'Present value = Σ Benefit_t/(1+r)^t − Σ Cost_t/(1+r)^t',
      'Multiplier (simple) ≈ 1 / (1 − marginal propensity to consume), subject to leakages',
      'For $topic: Equilibrium condition + comparative statics → predicted change',
    ],
    BusinessMajor.finance => <String>[
      'Present value = Σ CF_t / (1 + required return)^t',
      'Expected return = Σ probability_s × return_s',
      'Portfolio variance (two assets) = w_a²σ_a² + w_b²σ_b² + 2w_a w_b ρ σ_a σ_b',
      'WACC = (E/V)r_e + (D/V)r_d(1 − tax rate)',
      'NPV = PV(inflows) − PV(outflows)',
      'Sharpe ratio = (Expected return − risk-free rate) / σ',
      'For $topic: Value = Risk-adjusted claim on future cash flows',
    ],
    BusinessMajor.marketing => <String>[
      'Conversion rate = Desired actions / Eligible audience',
      'CAC = Acquisition spend / New customers acquired',
      'LTV ≈ Σ (contribution_t × retention probability to t) / (1+r)^t',
      'ROAS = Attributed revenue / Ad spend',
      'Retention_dN = Active users on day N / Cohort start size',
      'Marketing contribution = Incremental revenue × margin − incremental spend',
      'For $topic: Insight → offer design → measurement → iteration',
    ],
    BusinessMajor.accounting => <String>[
      'Accounting equation: Assets = Liabilities + Equity',
      'Net income = Recognized revenues − Matched expenses',
      'Ending equity = Beginning equity + Net income − Dividends ± other equity',
      'Cash flow identity: ΔCash = CFO + CFI + CFF',
      'Break-even units = Fixed costs / Contribution margin per unit',
      'Exception rate = Control exceptions / Items tested',
      'For $topic: Event → recognition → measurement → presentation → disclosure',
    ],
  };

  static String _workedExample(
    BusinessMajor major,
    String topic,
    String discipline,
  ) {
    return 'Worked case: applying $topic in $discipline\n\n'
        'Context. A mid-sized organization must make a decision involving $topic. '
        'Leadership wants a recommendation within one week. Data are incomplete, '
        'stakeholders disagree, and the cost of delay is rising.\n\n'
        'Step 1 — Frame the decision.\n'
        'Write: “We must choose among Continue, Modify, or Replace the current approach '
        'to $topic in order to improve a measurable outcome within 90 days.” Define the '
        'outcome metric and minimum acceptable improvement.\n\n'
        'Step 2 — Gather evidence.\n'
        'Collect at least: (a) internal performance for the last 12 periods, '
        '(b) one external benchmark, (c) cost or risk of each option, and '
        '(d) qualitative interviews with two operators and one customer or user.\n\n'
        'Step 3 — Build the base case.\n'
        'Quantify each option. Show every input. Example structure:\n'
        '• Option Continue: expected benefit 100, cost 70, risk penalty 15 → net 15\n'
        '• Option Modify: expected benefit 140, cost 95, risk penalty 20 → net 25\n'
        '• Option Replace: expected benefit 180, cost 150, risk penalty 40 → net −10\n'
        'Select Modify on expected net value, subject to feasibility.\n\n'
        'Step 4 — Sensitivity analysis.\n'
        'Increase implementation cost of Modify by 20% and reduce benefits by 15%. '
        'Recompute. If Modify remains best, confidence rises. If ranking flips, the '
        'decision is fragile and needs better data or a staged pilot.\n\n'
        'Step 5 — Interpret and recommend.\n'
        'Recommendation: run a 30-day pilot of Modify with an owner, budget, success '
        'threshold, and kill criteria. Report weekly. Expand only if the pilot clears '
        'the threshold without violating ethical or control constraints.\n\n'
        'Step 6 — Document assumptions.\n'
        'List assumptions, data sources, rejected alternatives, and residual risks. '
        'A complete worked example is reproducible by another analyst.';
  }

  static String _application(String topic, String field) {
    return 'Professional application lab for $topic\n\n'
        'Produce a board-ready or classroom-ready packet with these exact parts:\n\n'
        '1. One-page executive summary: decision, recommendation, value at stake, risks.\n'
        '2. Definitions appendix: every technical term used in the memo.\n'
        '3. Evidence table: metric, source, date, definition, limitation.\n'
        '4. Method section: why this framework fits $topic and which alternatives were rejected.\n'
        '5. Base-case analysis with transparent arithmetic.\n'
        '6. Two sensitivity cases and one reverse stress test.\n'
        '7. Implementation plan: owners, timeline, budget, controls, communications.\n'
        '8. Monitoring dashboard: leading indicators, lagging indicators, review cadence.\n'
        '9. Ethics and compliance note specific to $field practice.\n\n'
        'Presentation standard: a skeptical reviewer must be able to audit your logic '
        'without asking you to explain missing steps. If a number appears, its formula '
        'and inputs appear nearby.';
  }

  static List<String> _commonMistakes(
    BusinessMajor major,
    String topic,
  ) => <String>[
    'Starting calculations before defining the decision, options, and success metric for $topic.',
    'Using jargon as a substitute for a mechanism: naming a framework without explaining how it works.',
    'Reporting a single point estimate with no assumptions, ranges, or counterfactual.',
    'Cherry-picking supportive evidence and ignoring contradictory indicators.',
    'Confusing correlation, accounting identity, or model output with proven causation.',
    'Optimizing a local KPI while damaging cash, trust, quality, compliance, or long-run capability.',
    'Ignoring who bears downside risk and whether consent, fairness, or legality is compromised.',
    'Writing a recommendation without owner, threshold, timeline, and monitoring plan.',
    ...switch (major) {
      BusinessMajor.businessAdministration => <String>[
        'Equating activity (meetings, slides, initiatives) with organizational performance.',
        'Copying a competitor strategy without transferable capabilities.',
      ],
      BusinessMajor.economics => <String>[
        'Treating demand and supply shifts as movements along a curve.',
        'Claiming policy success from outcomes that would have occurred anyway.',
      ],
      BusinessMajor.finance => <String>[
        'Mixing equity cash flows with WACC, or debt cash flows with unlevered discounting.',
        'Ignoring liquidity and covenants while focusing only on expected return.',
      ],
      BusinessMajor.marketing => <String>[
        'Scaling spend on last-click metrics without testing incrementality.',
        'Using dark patterns that raise short-term conversion and destroy trust.',
      ],
      BusinessMajor.accounting => <String>[
        'Booking entries that balance mathematically but violate recognition principles.',
        'Equating net income with cash generation.',
      ],
    },
  ];

  static String _summary(String topic, List<String> outcomes) {
    final String checks = outcomes.isEmpty
        ? 'explain, apply, evaluate, and communicate'
        : outcomes.map((String o) => '• Can I $o?').join('\n');
    return 'Chapter summary: $topic\n\n'
        'You have now studied the decision setting, competing views, core theory, '
        'measurement standards, method, institutional context, linkages, and limits. '
        'Mastery is demonstrated only when you can teach the chapter, rework the '
        'example with new numbers, and defend a recommendation under challenge.\n\n'
        'Self-check:\n$checks\n'
        '• Can I state assumptions and invalidate conditions?\n'
        '• Can I show a transparent calculation?\n'
        '• Can I identify ethical and distributional consequences?\n\n'
        'If any answer is no, return to the matching section before attempting Homework '
        'or the Exam.';
  }

  static List<String> _reviewQuestions(String topic) => <String>[
    'Define $topic in your own words without using the chapter title in the definition.',
    'What decision does $topic help a professional make, and who are the stakeholders?',
    'Explain the central mechanism of $topic step by step.',
    'List the key assumptions and describe how you would test each one.',
    'Create a numerical example with at least four inputs and show every calculation.',
    'Change one assumption by 20% and explain how the recommendation changes.',
    'What evidence would falsify the leading interpretation of $topic?',
    'Compare two schools of thought about $topic and state which you would use and why.',
    'Identify an ethical, legal, or distributional issue that could overturn a profitable recommendation.',
    'Design a 30-day pilot or research study that would improve decision quality on $topic.',
    'Which adjacent topics must be integrated before implementation?',
    'Write a five-sentence briefing for an executive who has only two minutes.',
  ];

  static List<String> _practiceProblems(BusinessMajor major, String topic) {
    final List<String> common = <String>[
      'Write a one-sentence decision statement for a real or invented case involving $topic.',
      'Build a glossary of eight terms from this chapter with original examples.',
      'Construct a base-case table with three options and compute expected net value.',
      'Perform sensitivity analysis on your two most uncertain inputs and discuss ranking stability.',
      'Draft a monitoring dashboard with three leading and three lagging indicators for $topic.',
      'Write a dissenting memo arguing against your own recommendation using alternative evidence.',
    ];
    final List<String> specific = switch (major) {
      BusinessMajor.businessAdministration => <String>[
        'Map stakeholders and rate each by interest and power for a $topic decision.',
        'Create an implementation RACI for the first 60 days after approval.',
      ],
      BusinessMajor.economics => <String>[
        'Draw or describe the comparative statics of a shock related to $topic.',
        'Estimate an elasticity from invented before/after data and interpret it carefully.',
      ],
      BusinessMajor.finance => <String>[
        'Discount a three-period cash-flow example relevant to $topic at two different required returns.',
        'Identify the main risk factors in your example and propose one hedge or control for each.',
      ],
      BusinessMajor.marketing => <String>[
        'Design an A/B test for a $topic intervention with hypothesis, metric, and stop rule.',
        'Estimate CAC and LTV from invented campaign data and decide whether to scale.',
      ],
      BusinessMajor.accounting => <String>[
        'Record the journal entries implied by a transaction related to $topic and explain statement impact.',
        'Design three internal controls that would detect or prevent misstatement in this area.',
      ],
    };
    return <String>[...common, ...specific];
  }

  static final Map<String, BusinessLectureNote>
  _byId = <String, BusinessLectureNote>{
    // —— Business Administration ——
    'bus_org': const BusinessLectureNote(
      lessonId: 'bus_org',
      overview:
          'Organizations create value when they transform inputs into outputs customers prefer to alternatives. This chapter connects customers, operations, people, and finance to measurable value creation.',
      keyConcepts: <String>[
        'Value proposition: the specific benefit relative to alternatives',
        'Value chain: activities that add cost and create willingness to pay',
        'Business model: how the firm acquires customers, delivers value, and captures margin',
        'Stakeholder map: owners, customers, employees, suppliers, regulators, community',
      ],
      formulas: <String>[
        'Economic profit ≈ Revenue − Opportunity cost of capital employed',
        'CLV ≈ Σ (margin_t × retention^t) / (1 + r)^t',
        'Contribution margin = Price − Variable cost per unit',
      ],
      workedExample:
          'A grocery delivery firm charges \$12/order with \$7 variable cost and 40% monthly retention. Expected contribution over three months at 10% monthly discount: Month 1 \$5; Month 2 ≈ \$1.82; Month 3 ≈ \$0.66. Approximate CLV ≈ \$7.48. If CAC is \$6, unit economics are positive but fragile.',
      application:
          'Build an executive dashboard with leading indicators (pipeline, capacity, engagement) and lagging indicators (revenue, margin, cash). When growth rises while contribution falls, investigate pricing, mix, and waste before celebrating volume.',
      commonMistakes: <String>[
        'Confusing revenue growth with value creation when margins and cash deteriorate',
        'Ignoring opportunity cost of capital in inventory or receivables',
        'Dashboard vanity metrics with no decision owner',
      ],
      summary:
          'Value creation links customer need to operations, people systems, and financial returns. Measure both the benefit created and the cost of creating it.',
      reviewQuestions: <String>[
        'How would you redesign a dashboard for a declining retail chain?',
        'When is high growth destroying economic value?',
        'Which stakeholder trade-offs appear when cutting service to raise margin?',
      ],
    ),
    'bus_management': const BusinessLectureNote(
      lessonId: 'bus_management',
      overview:
          'Managers convert strategy into coordinated action through planning, organizing, leading, and controlling. CEO, operations, project, store, and HR roles face different decision rights and information problems.',
      keyConcepts: <String>[
        'Decision structure: diagnose, options, criteria, decide, monitor',
        'Span of control and escalation paths',
        'Principal–agent problem between owners and managers',
        'RACI clarity for cross-functional work',
      ],
      formulas: <String>[
        'Expected value = Σ (probability_i × payoff_i)',
        'Opportunity cost = value of best forgone alternative',
      ],
      workedExample:
          'A store manager can discount slow inventory 20% now or hold for a seasonal rebound with 40% chance of full-price sale and 60% chance of write-off. Compute expected payoffs including storage cost, then choose the higher EV option while stating headquarters’ risk preference.',
      application:
          'Before a major hire, define the decision owner, success metric, and review date. Balance customer experience, labor cost, and team capacity rather than optimizing one stakeholder alone.',
      commonMistakes: <String>[
        'Treating gut feel as analysis without documenting assumptions',
        'Delegating accountability without authority or resources',
        'Optimizing local KPIs that harm system performance',
      ],
      summary:
          'Effective management is structured decision-making under constraints, with clear ownership and feedback loops.',
      reviewQuestions: <String>[
        'Write a one-page decision brief for a pricing change.',
        'How should a CEO and operations lead disagree productively?',
        'What evidence would reverse your recommendation?',
      ],
    ),
    'bus_people': const BusinessLectureNote(
      lessonId: 'bus_people',
      overview:
          'People systems turn strategy into daily behavior. Hiring, training, promotion, and rewards shape culture; culture then shapes productivity, quality, and retention.',
      keyConcepts: <String>[
        'Person–job and person–organization fit',
        'Engagement drivers: autonomy, mastery, purpose, fairness',
        'Task conflict vs relationship conflict',
        'Psychological safety as a performance enabler',
      ],
      formulas: <String>[
        'Turnover cost ≈ recruiting + training + lost productivity',
        'Productivity = Output / Labor hours (quality-adjusted when possible)',
      ],
      workedExample:
          'A call center with 120 agents has 30% annual turnover. Replacement cost is \$4,000 per hire → ≈ \$144,000/year. A \$40,000 coaching program that cuts turnover to 18% saves ≈ \$57,600 plus service quality gains.',
      application:
          'When resolving workplace conflict, separate interests from positions, restate shared goals, and document commitments. Connect engagement themes to operating metrics such as defect rates or schedule adherence.',
      commonMistakes: <String>[
        'Using tenure alone as a promotion criterion',
        'Ignoring burnout signals until attrition spikes',
        'Rewarding individual heroics that break team processes',
      ],
      summary:
          'People decisions are capital allocation decisions: invest where capability compounds and remove friction that destroys trust.',
      reviewQuestions: <String>[
        'Design a fair promotion rubric for a retail team.',
        'How would you diagnose low engagement with high wages?',
        'What is the cost of delaying a difficult performance conversation?',
      ],
    ),
    'bus_idea': const BusinessLectureNote(
      lessonId: 'bus_idea',
      overview:
          'Entrepreneurship begins with a valuable problem, not a product. Opportunity evaluation tests whether customers will pay, whether founders can deliver, and whether the market can support a durable business.',
      keyConcepts: <String>[
        'Jobs-to-be-done framing of customer problems',
        'Value proposition canvas: pains, gains, products',
        'Problem–solution and solution–market fit',
        'Founder–market fit and unfair advantages',
      ],
      formulas: <String>[
        'Willingness-to-pay evidence > stated interest surveys',
        'Beachhead size ≈ reachable customers × adoption × price',
      ],
      workedExample:
          'Interview 12 logistics managers about invoice disputes. Eight report weekly reconciliation taking 3 hours. If a tool saves 2 hours/week at \$45/hour, monthly value ≈ \$360. Price at \$99/month if reliability justifies capturing part of that value.',
      application:
          'Write: For [customer] who [problem], our [solution] provides [benefit] unlike [alternative]. Test with paid pilots before scaling features.',
      commonMistakes: <String>[
        'Falling in love with the solution before validating the problem',
        'Defining the market as “everyone”',
        'Confusing compliments with purchase commitments',
      ],
      summary:
          'A strong opportunity statement is specific, evidenced, and falsifiable.',
      reviewQuestions: <String>[
        'What evidence would kill your idea this week?',
        'Who is the economic buyer versus the end user?',
        'What is your beachhead and why?',
      ],
    ),
    'bus_canvas': const BusinessLectureNote(
      lessonId: 'bus_canvas',
      overview:
          'The Business Model Canvas links segments, propositions, channels, relationships, revenue, resources, activities, partners, and costs. Unit economics then stress-test whether the model can scale.',
      keyConcepts: <String>[
        'Revenue streams vs cost structure',
        'Key resources and critical dependencies',
        'Unit economics after variable costs',
        'Payback period on customer acquisition',
      ],
      formulas: <String>[
        'Contribution margin % = (Price − VC) / Price',
        'Payback months ≈ CAC / Monthly contribution',
        'Break-even customers = Fixed costs / Contribution per customer',
      ],
      workedExample:
          'CAC = \$80, ARPU = \$25/month, VC = \$5 → contribution \$20. Payback = 4 months. At 8% monthly churn, lifetime ≈ 12.5 months, lifetime contribution ≈ \$250, LTV/CAC ≈ 3.1 if retention holds.',
      application:
          'Map partners and channels that create single points of failure. Redesign the canvas when a channel tax or supplier constraint collapses contribution margin.',
      commonMistakes: <String>[
        'Ignoring churn when celebrating LTV',
        'Mixing one-time and recurring revenue in one unit model',
        'Underestimating support costs as “variable”',
      ],
      summary:
          'A canvas without numbers is a storyboard; unit economics make it a plan.',
      reviewQuestions: <String>[
        'Where does your model break if CAC rises 40%?',
        'Which canvas block is your scarcest constraint?',
        'How would you test pricing before building more features?',
      ],
    ),
    'bus_pitch': const BusinessLectureNote(
      lessonId: 'bus_pitch',
      overview:
          'An investor pitch is an evidence narrative: problem, solution, market, traction, model, team, ask. Valuation and funding must follow from assumptions you can defend.',
      keyConcepts: <String>[
        'Pitch narrative arc and risk disclosure',
        'Traction metrics that prove learning speed',
        'Use of funds tied to milestones',
        'Dilution and ownership math',
      ],
      formulas: <String>[
        'Post-money = Pre-money + Investment',
        'Investor ownership % = Investment / Post-money',
        'Runway months ≈ Cash / Net burn',
      ],
      workedExample:
          'Raise \$1.2M on \$4.8M pre-money → post-money \$6.0M, investor owns 20%. With \$100k monthly burn and \$200k already in bank, runway ≈ 14 months. Tie the ask to launch, 200 paying customers, and ≥65% gross margin.',
      application:
          'Design growth that compounds retention and contribution, not vanity downloads. Include compliance, support capacity, and honest risk language.',
      commonMistakes: <String>[
        'Inflating TAM without a path to the beachhead',
        'Hiding key risks until diligence',
        'Asking for capital without milestone clarity',
      ],
      summary:
          'Investors fund learning velocity and capital efficiency as much as vision.',
      reviewQuestions: <String>[
        'What is the single riskiest assumption in your pitch?',
        'How does use of funds change if growth misses by 30%?',
        'What valuation evidence would a skeptical partner demand?',
      ],
    ),
    'bus_operations': const BusinessLectureNote(
      lessonId: 'bus_operations',
      overview:
          'Operations converts strategy into reliable flow: inventory, production, suppliers, and logistics—throughput, quality, and service within cost and working-capital constraints.',
      keyConcepts: <String>[
        'Flow time, throughput, and bottlenecks',
        'Inventory as a buffer and a cost',
        'Supplier scorecards: cost, quality, lead time, risk',
        'Service level vs inventory trade-off',
      ],
      formulas: <String>[
        'Throughput ≈ 1 / bottleneck cycle time',
        'Inventory turns = COGS / Average inventory',
        'Reorder point ≈ demand during lead time + safety stock',
      ],
      workedExample:
          'Demand 100 units/day, lead time 5 days, safety stock 150 → reorder point 650. If average inventory is \$200k and COGS \$1.2M, turns = 6. Improving turns to 8 frees ≈ \$50k cash at the same COGS.',
      application:
          'When service drops, diagnose whether the bottleneck is capacity, quality yield, or logistics variability before adding inventory everywhere.',
      commonMistakes: <String>[
        'Optimizing unit cost while starving the bottleneck',
        'Using average demand without variability',
        'Evaluating suppliers only on purchase price',
      ],
      summary:
          'Operational excellence is synchronized flow, not local efficiency theater.',
      reviewQuestions: <String>[
        'How do you identify the true bottleneck this week?',
        'What service level is worth the inventory cost?',
        'Which supplier risk is uninsured today?',
      ],
    ),
    'bus_strategy': const BusinessLectureNote(
      lessonId: 'bus_strategy',
      overview:
          'Strategy chooses where to compete and how to win. Corporate strategy allocates capital across businesses; competitive strategy builds advantage within a market.',
      keyConcepts: <String>[
        'Industry structure and competitive forces',
        'Cost leadership vs differentiation vs focus',
        'Expand, acquire, divest, or partner',
        'Strategy-to-metric translation',
      ],
      formulas: <String>[
        'Relative cost position = Your unit cost / Rival unit cost',
        'ROIC = NOPAT / Invested capital',
      ],
      workedExample:
          'Acquire a rival for \$40M with expected synergy NPV \$12M, or invest \$25M organically with NPV \$9M. Prefer acquisition only if integration risk is priced and cultural fit is credible; otherwise organic may dominate risk-adjusted value.',
      application:
          'Translate strategy into a few operating metrics: target-segment share, gross margin, cycle time, retention. If metrics do not move, the strategy is a slogan.',
      commonMistakes: <String>[
        'Confusing goals (“be #1”) with strategy',
        'Entering adjacent markets without transferable advantage',
        'Ignoring competitor responses',
      ],
      summary:
          'Good strategy is an integrated set of choices that create a hard-to-copy position.',
      reviewQuestions: <String>[
        'Where will you not compete, and why?',
        'What capability is genuinely scarce?',
        'Which metric proves the strategy is working within 90 days?',
      ],
    ),
    'bus_negotiation': const BusinessLectureNote(
      lessonId: 'bus_negotiation',
      overview:
          'Negotiation prepares interests, alternatives, and reservation points before tactics. Ethical negotiators create value through trades and claim value without deception.',
      keyConcepts: <String>[
        'BATNA and reservation price',
        'Interests vs positions',
        'ZOPA: zone of possible agreement',
        'Value-creating trades across issues',
      ],
      formulas: <String>[
        'ZOPA exists if buyer max ≥ seller min',
        'Surplus = buyer max − seller min',
      ],
      workedExample:
          'Seller reservation \$90k, buyer max \$110k → ZOPA \$20k. If delivery timing matters more to the buyer and payment timing more to the seller, trade earlier delivery for faster payment to enlarge joint gains before splitting surplus.',
      application:
          'Prepare a stakeholder map: blockers, decision makers, influencers. Negotiate packages, not single issues, and document owners and dates.',
      commonMistakes: <String>[
        'Anchoring without preparation',
        'Revealing reservation price early',
        'Winning the deal while destroying the relationship needed for execution',
      ],
      summary:
          'Preparation beats improvisation; multi-issue trades beat zero-sum haggling.',
      reviewQuestions: <String>[
        'What is your BATNA if talks fail tomorrow?',
        'Which issue can you trade at low cost to you but high value to them?',
        'How will you verify commitments after signing?',
      ],
    ),
    'bus_leadership': const BusinessLectureNote(
      lessonId: 'bus_leadership',
      overview:
          'Crisis leadership protects trust while restoring performance. Leaders decide under incomplete information, communicate clearly, and maintain safety without denying urgency.',
      keyConcepts: <String>[
        'Sense-making under uncertainty',
        'Decision speed vs decision quality',
        'Crisis communication principles',
        'Trust repair after disruption',
      ],
      formulas: <String>['Prioritize by severity × likelihood × reversibility'],
      workedExample:
          'A product defect affects 2% of units with potential safety risk. Stop shipment, disclose to regulators and customers, quarantine inventory, and staff a response team. Short-term revenue loss beats irreversible brand and liability damage.',
      application:
          'Communicate facts, actions, and next update time. Separate blame hunting from problem solving until customers and employees are safe.',
      commonMistakes: <String>[
        'Optimistic silence that looks like cover-up',
        'Optimizing optics over operational truth',
        'Centralizing every decision and freezing the front line',
      ],
      summary:
          'In crisis, legitimacy comes from competence, honesty, and consistent follow-through.',
      reviewQuestions: <String>[
        'What decision must be made in the next hour vs next week?',
        'Who needs what information, and when is the next update?',
        'How will you restore trust after the immediate threat ends?',
      ],
    ),
    'bus_internship': const BusinessLectureNote(
      lessonId: 'bus_internship',
      overview:
          'An executive practicum turns frameworks into board-ready deliverables: memos, models, and recommendations that survive skeptical review.',
      keyConcepts: <String>[
        'Professional assignment scoping',
        'Feedback loops with executives',
        'Evidence standards for recommendations',
        'Board packet hygiene: clarity, options, risks',
      ],
      formulas: <String>[
        'Decision memo: context → options → analysis → recommendation → risks → ask',
      ],
      workedExample:
          'Cut \$2M cost without harming NPS. Build three options with quantified impact, customer risk, and implementation time. Recommend the best risk-adjusted option with a 30-day pilot metric.',
      application:
          'Respond to executive feedback by updating assumptions, not defending ego. Produce work an absent board member can understand in five minutes.',
      commonMistakes: <String>[
        'Submitting analysis without a clear ask',
        'Hiding uncertainty instead of bounding it',
        'Ignoring political constraints that block execution',
      ],
      summary: 'Board-ready work is concise, option-based, and owned.',
      reviewQuestions: <String>[
        'What would make your memo fail in a board meeting?',
        'How will you measure success 30 days after approval?',
        'Which stakeholder must be enrolled before implementation?',
      ],
    ),
    'bus_capstone': const BusinessLectureNote(
      lessonId: 'bus_capstone',
      overview:
          'The multi-year company capstone integrates strategy, operations, finance, and people under competitive pressure. Survival requires cash discipline and adaptive strategy.',
      keyConcepts: <String>[
        'Multi-period planning under uncertainty',
        'Competitive response and capacity races',
        'Cash runway and covenant awareness',
        'Board reporting of performance vs plan',
      ],
      formulas: <String>[
        'Ending cash = Beginning + CFO − Capex − Debt service ± financing',
        'Runway = Cash / |Monthly burn| when burn > 0',
      ],
      workedExample:
          'Year-1 growth overextends inventory. Working capital spikes and cash falls below covenant. Correct by slowing SKUs, renegotiating payables, and cutting low-ROIC projects before raising expensive emergency capital.',
      application:
          'Compete by choosing a focused segment, protecting contribution margin, and investing only where learning compounds. Present honest variance analysis to the board.',
      commonMistakes: <String>[
        'Growing revenue while ignoring cash conversion',
        'Copying rival moves without advantage',
        'Waiting too long to cut a failing experiment',
      ],
      summary:
          'Long-horizon performance is a sequence of disciplined short-horizon decisions.',
      reviewQuestions: <String>[
        'What early warning metrics predict a downturn for your firm?',
        'When should you raise capital versus cut cost?',
        'How do you explain a strategic pivot without losing board trust?',
      ],
    ),

    // —— Economics ——
    'econ_demand': const BusinessLectureNote(
      lessonId: 'econ_demand',
      overview:
          'Supply and demand determine market prices and quantities. Equilibrium clears the market; shifts change surplus and create winners and losers.',
      keyConcepts: <String>[
        'Law of demand and law of supply',
        'Market equilibrium and shortages/surpluses',
        'Consumer and producer surplus',
        'Shifts vs movements along a curve',
      ],
      formulas: <String>[
        'At equilibrium: Qd = Qs',
        'Consumer surplus ≈ area under demand above price',
        'Producer surplus ≈ area above supply below price',
      ],
      workedExample:
          'Demand Qd = 100 − 2P, supply Qs = 20 + 2P. Set equal: 100 − 2P = 20 + 2P → P* = 20, Q* = 60. A demand shift to Qd = 120 − 2P raises P* to 25 and Q* to 70; consumer and producer surplus both change.',
      application:
          'When predicting a tax or subsidy, sketch both curves, identify the wedge, and calculate who bears the burden using relative elasticities.',
      commonMistakes: <String>[
        'Confusing a price change (movement) with a demand shift',
        'Assuming surplus is always maximized under price controls',
        'Ignoring quantity rationing under ceilings',
      ],
      summary:
          'Equilibrium is a benchmark; policy and shocks matter through how they shift curves and redistribute surplus.',
      reviewQuestions: <String>[
        'What happens to surplus when demand rises and supply is inelastic?',
        'How would you illustrate a binding price ceiling?',
        'Which factors shift supply without shifting demand?',
      ],
    ),
    'econ_elasticity': const BusinessLectureNote(
      lessonId: 'econ_elasticity',
      overview:
          'Elasticity measures responsiveness. Price elasticity links pricing decisions to revenue and tax incidence.',
      keyConcepts: <String>[
        'Price elasticity of demand and supply',
        'Elastic, inelastic, and unit-elastic regions',
        'Cross-price and income elasticities',
        'Tax incidence and relative elasticities',
      ],
      formulas: <String>[
        'Ed = (%ΔQd) / (%ΔP)',
        'Midpoint Ed = [(Q2−Q1)/((Q1+Q2)/2)] / [(P2−P1)/((P1+P2)/2)]',
        'If |Ed| > 1, a price cut raises revenue',
      ],
      workedExample:
          'Price rises from \$10 to \$12; quantity falls from 100 to 80. Midpoint Ed = (−20/90) / (2/11) ≈ −1.22. Demand is elastic; revenue falls from \$1,000 to \$960.',
      application:
          'A city proposes a \$1/unit tax. If demand is more inelastic than supply, consumers bear more of the tax. Estimate incidence before lobbying claims.',
      commonMistakes: <String>[
        'Using arc formulas inconsistently',
        'Assuming “inelastic” means “zero response”',
        'Ignoring substitutes when forecasting elasticity',
      ],
      summary:
          'Elasticity turns qualitative curve stories into quantitative pricing and tax analysis.',
      reviewQuestions: <String>[
        'When should a firm raise price to increase revenue?',
        'Who bears more of a tax when supply is perfectly elastic?',
        'How does time horizon change elasticity?',
      ],
    ),
    'econ_market_structure': const BusinessLectureNote(
      lessonId: 'econ_market_structure',
      overview:
          'Market structure shapes pricing power. Perfect competition, monopoly, and oligopoly differ in barriers, entry, and welfare outcomes.',
      keyConcepts: <String>[
        'Perfect competition: P = MC in long run',
        'Monopoly: MR = MC, P > MC',
        'Deadweight loss from restricted output',
        'Regulation and natural monopoly trade-offs',
      ],
      formulas: <String>[
        'Profit = (P − ATC) × Q',
        'MR for linear demand: if P = a − bQ, MR = a − 2bQ',
        'Markup ≈ 1 / |Ed| under monopoly power',
      ],
      workedExample:
          'Monopolist faces P = 100 − Q, MC = 20. MR = 100 − 2Q = 20 → Q = 40, P = 60. Competitive benchmark Q where P = MC → Q = 80. Deadweight loss is the triangle between 40 and 80.',
      application:
          'When evaluating merger policy, estimate whether efficiency gains outweigh the price increase from higher concentration.',
      commonMistakes: <String>[
        'Assuming high accounting profit always means monopoly power',
        'Using average cost instead of marginal cost for optimal output',
        'Ignoring potential entry',
      ],
      summary:
          'Structure determines incentives; incentives determine price, quantity, and welfare.',
      reviewQuestions: <String>[
        'Why is MR below price for a single-price monopolist?',
        'When might regulating P = ATC be preferred to P = MC?',
        'How does contestability discipline pricing?',
      ],
    ),
    'econ_gdp': const BusinessLectureNote(
      lessonId: 'econ_gdp',
      overview:
          'Macroeconomics measures aggregate performance with GDP, inflation, and unemployment, then interprets business-cycle position.',
      keyConcepts: <String>[
        'Nominal vs real GDP',
        'CPI and inflation measurement',
        'Unemployment types: frictional, structural, cyclical',
        'Okun’s relationship and gaps',
      ],
      formulas: <String>[
        'Real GDP = Nominal GDP / Price index × 100',
        'Inflation ≈ %Δ price index',
        'Unemployment rate = Unemployed / Labor force',
      ],
      workedExample:
          'Nominal GDP rises 6%, price index rises 2% → real growth ≈ 4%. If natural unemployment is 4.5% and actual is 6.5%, cyclical unemployment ≈ 2 points, implying slack and room for expansionary policy if inflation is contained.',
      application:
          'Read a dashboard of real GDP growth, core inflation, and unemployment together before recommending fiscal or monetary moves.',
      commonMistakes: <String>[
        'Treating nominal growth as real prosperity',
        'Ignoring labor-force exits that lower the unemployment rate',
        'Using headline inflation alone when core drives policy',
      ],
      summary:
          'Indicators are complementary: growth, prices, and labor markets jointly describe the cycle.',
      reviewQuestions: <String>[
        'How can unemployment fall while the economy is weak?',
        'Why might GDP and well-being diverge?',
        'What is a positive output gap?',
      ],
    ),
    'econ_policy': const BusinessLectureNote(
      lessonId: 'econ_policy',
      overview:
          'Fiscal and monetary policy stabilize demand. Interest-rate transmission and fiscal multipliers determine how tools interact.',
      keyConcepts: <String>[
        'IS–LM / modern rate-setting intuition',
        'Fiscal multipliers and crowding out',
        'Automatic stabilizers vs discretionary policy',
        'Policy mix under inflation and slack',
      ],
      formulas: <String>[
        'Simple Keynesian multiplier ≈ 1 / (1 − MPC) absent leakages',
        'Real rate ≈ nominal rate − expected inflation',
      ],
      workedExample:
          'MPC = 0.8 implies a crude multiplier of 5, but imports and taxes cut it. If a \$100B spending package raises GDP by \$150B, the effective multiplier is 1.5. Pair with tighter money if inflation exceeds target.',
      application:
          'Design a mix: temporary targeted transfers for demand support plus credible rate path for inflation. State the lag structure and exit criteria.',
      commonMistakes: <String>[
        'Assuming multipliers are constant across states of the economy',
        'Ignoring supply constraints when stimulating demand',
        'Confusing nominal rate cuts with easier financial conditions',
      ],
      summary:
          'Policy works through expectations, channels, and constraints—not slogans.',
      reviewQuestions: <String>[
        'When is fiscal policy more powerful than monetary policy?',
        'How do supply shocks change the policy mix?',
        'What is an exit rule for emergency stimulus?',
      ],
    ),
    'econ_crisis': const BusinessLectureNote(
      lessonId: 'econ_crisis',
      overview:
          'Crisis management diagnoses demand vs supply shocks, stabilizes banking and employment, and defends a coherent response package.',
      keyConcepts: <String>[
        'Demand shock vs supply shock',
        'Lender of last resort and liquidity vs solvency',
        'Automatic stabilizers under stress',
        'Communication and credibility',
      ],
      formulas: <String>[
        'Output gap ≈ (Actual − Potential) / Potential',
        'Stress capital ratio = Capital / Risk-weighted assets',
      ],
      workedExample:
          'Bank deposits flee 8% in two weeks. Provide emergency liquidity against good collateral, guarantee deposits temporarily, and force recapitalization for insolvent banks—separating liquidity support from bailouts of equity holders.',
      application:
          'Build a crisis playbook: diagnose shock type, protect payment systems, target employment support, and publish transparent conditions for aid.',
      commonMistakes: <String>[
        'Treating every crisis as a demand shortfall',
        'Confusing illiquidity with insolvency',
        'Announcing open-ended guarantees without fiscal backing',
      ],
      summary:
          'Speed, triage, and credibility determine whether a shock becomes a depression.',
      reviewQuestions: <String>[
        'How do you tell a demand shock from a supply shock in real time?',
        'When should equity holders be wiped out?',
        'What metrics trigger exit from emergency measures?',
      ],
    ),
    'econ_trade': const BusinessLectureNote(
      lessonId: 'econ_trade',
      overview:
          'Trade theory explains gains from specialization. Tariffs and exchange rates redistribute surplus and create strategic exposure.',
      keyConcepts: <String>[
        'Comparative advantage vs absolute advantage',
        'Tariff incidence and deadweight loss',
        'Exchange-rate appreciation/depreciation effects',
        'Trade exposure and hedging',
      ],
      formulas: <String>[
        'Opportunity cost = units forgone / units gained',
        'Real exchange rate ≈ e × P_domestic / P_foreign',
      ],
      workedExample:
          'Country A forgoes 2 cloth for 1 wine; B forgoes 1 cloth for 1 wine. A has comparative advantage in cloth. A 10% tariff on wine raises domestic price, helps local producers, hurts consumers, and creates DWL triangles.',
      application:
          'For an exporter invoicing in dollars, model revenue under a 10% home-currency appreciation and decide hedges vs natural offsets.',
      commonMistakes: <String>[
        'Equating trade deficits with “losing”',
        'Ignoring retaliatory tariffs',
        'Treating nominal exchange moves as real competitiveness',
      ],
      summary:
          'Trade gains are real; distributional and FX risks require policy and firm responses.',
      reviewQuestions: <String>[
        'Who gains and loses from a steel tariff?',
        'How does comparative advantage differ from absolute advantage?',
        'When is FX hedging value-destroying?',
      ],
    ),
    'econ_development': const BusinessLectureNote(
      lessonId: 'econ_development',
      overview:
          'Development economics studies growth constraints, institutions, and the roles of IMF and World Bank tools in crisis and long-run development.',
      keyConcepts: <String>[
        'Growth accounting and TFP',
        'Poverty traps and complementarity',
        'Conditionality and moral hazard',
        'Inclusive institutions and human capital',
      ],
      formulas: <String>[
        'Y = A F(K, L, H)',
        'Growth ≈ contribution of capital + labor + TFP',
      ],
      workedExample:
          'A country faces FX shortage and inflation. IMF standby provides liquidity with fiscal consolidation; World Bank finances targeted infrastructure and education. Sequence liquidity first, then growth projects with governance safeguards.',
      application:
          'Design inclusive policy: cash transfers with work/education links, competition policy against entrenched rents, and measurable human-capital KPIs.',
      commonMistakes: <String>[
        'Copying policies without institutional capacity',
        'Debt-financed projects without productivity returns',
        'Ignoring elite capture of aid',
      ],
      summary:
          'Sustainable development compounds human capital, institutions, and productive investment—not one-off transfers alone.',
      reviewQuestions: <String>[
        'What is the binding constraint: capital, skills, or institutions?',
        'When does conditionality help versus harm?',
        'How do you measure inclusive growth?',
      ],
    ),
    'econ_regression': const BusinessLectureNote(
      lessonId: 'econ_regression',
      overview:
          'Regression estimates relationships; causal inference asks whether coefficients answer “what if” policy questions.',
      keyConcepts: <String>[
        'OLS interpretation and omitted variable bias',
        'Confounding vs mediators',
        'Natural experiments and differences-in-differences',
        'External validity for policy',
      ],
      formulas: <String>[
        'Y = β0 + β1X + u',
        'β1 ≈ ΔY / ΔX holding covariates fixed (if identified)',
      ],
      workedExample:
          'Job-training participants earn \$2,000 more, but selection bias may inflate the effect. A lottery assignment design identifies a causal effect of \$800. Report both and discuss external validity.',
      application:
          'When briefing policymakers, state the identification strategy, threats to validity, and the decision that would reverse if the estimate halves.',
      commonMistakes: <String>[
        'Treating correlation as causation',
        'p-hacking without pre-registration',
        'Ignoring clustered standard errors',
      ],
      summary:
          'Credible policy advice requires identification, not just a significant star.',
      reviewQuestions: <String>[
        'What omitted variable would bias your estimate upward?',
        'How would a DiD design help here?',
        'What is the policy-relevant treatment effect?',
      ],
    ),
    'econ_capstone': const BusinessLectureNote(
      lessonId: 'econ_capstone',
      overview:
          'The national economy capstone integrates macro measurement, policy tools, trade, and evidence into a five-year plan under shocks.',
      keyConcepts: <String>[
        'Macro dashboard stewardship',
        'Shock response playbooks',
        'Medium-term fiscal and monetary anchors',
        'Inclusive growth metrics',
      ],
      formulas: <String>[
        'Debt dynamics: Δ(debt/GDP) depends on primary balance, growth, and interest',
        'Policy loss ≈ w_π(π−π*)² + w_y(y−y*)²',
      ],
      workedExample:
          'Commodity price spike raises inflation and slows growth. Tighten policy gradually, use targeted transfers for vulnerable households, and avoid blanket price controls that create shortages. Publish a five-year path for debt/GDP and inflation.',
      application:
          'Present a cabinet brief: diagnosis, policy package, distributional impacts, risks, and monitoring calendar.',
      commonMistakes: <String>[
        'One-instrument responses to multi-dimensional shocks',
        'Ignoring debt sustainability',
        'Plans without measurable milestones',
      ],
      summary:
          'Governing an economy is iterated learning under constraints with transparent accountability.',
      reviewQuestions: <String>[
        'What is your inflation–employment priority this quarter?',
        'Which shock scenario breaks your plan?',
        'How will citizens verify progress?',
      ],
    ),

    // —— Finance ——
    'fin_markets': const BusinessLectureNote(
      lessonId: 'fin_markets',
      overview:
          'Financial markets allocate capital across stocks, bonds, and ETFs. Understanding pricing, yield, and diversification is foundational investing literacy.',
      keyConcepts: <String>[
        'Equity ownership vs fixed-income claims',
        'Bond price–yield inverse relationship',
        'ETF mechanics and tracking',
        'Diversification across uncorrelated risks',
      ],
      formulas: <String>[
        'Bond price ≈ Σ C_t/(1+y)^t + Face/(1+y)^n',
        'Current yield ≈ Coupon / Price',
        'Portfolio return = Σ w_i r_i',
      ],
      workedExample:
          'A 2-year \$1,000 bond pays 5% annual coupons. If y = 6%, price ≈ 50/1.06 + 1050/1.06² ≈ \$981.67. Yield above coupon implies discount price.',
      application:
          'Construct a portfolio with a core ETF, satellite equities, and duration-matched bonds aligned to horizon and risk tolerance.',
      commonMistakes: <String>[
        'Chasing past returns without risk budgets',
        'Confusing nominal yield with real return',
        'Concentrating in a single sector labeled “diversified”',
      ],
      summary:
          'Asset classes differ in claims, risks, and roles; portfolios combine them intentionally.',
      reviewQuestions: <String>[
        'Why do bond prices fall when yields rise?',
        'When is an ETF preferable to individual stocks?',
        'How do you define diversification beyond “many tickers”?',
      ],
    ),
    'fin_risk': const BusinessLectureNote(
      lessonId: 'fin_risk',
      overview:
          'Portfolio theory links expected return to risk. Volatility, beta, and correlation determine diversification benefits and risk-adjusted performance.',
      keyConcepts: <String>[
        'Systematic vs idiosyncratic risk',
        'Mean–variance trade-off',
        'Beta as sensitivity to the market',
        'Sharpe ratio and risk budgeting',
      ],
      formulas: <String>[
        'E[R] = Σ w_i E[R_i]',
        'σ_p² = w_a²σ_a² + w_b²σ_b² + 2w_a w_b ρ σ_a σ_b',
        'Sharpe = (E[R] − r_f) / σ',
      ],
      workedExample:
          'Two assets with σ = 20%, correlation 0.2, equal weights: σ_p = √(0.5²·0.04 + 0.5²·0.04 + 2·0.5·0.5·0.2·0.2·0.2) ≈ 15.5%. Diversification cuts risk without cutting average return if expected returns match.',
      application:
          'Optimize risk-adjusted return by reducing concentrated bets and sizing positions to contribution to portfolio variance, not gut feel.',
      commonMistakes: <String>[
        'Using volatility alone when drawdown risk matters',
        'Assuming historical correlation is stable in crises',
        'Ignoring leverage when comparing Sharpe ratios',
      ],
      summary:
          'Risk is multidimensional; correlation is the hidden portfolio multiplier.',
      reviewQuestions: <String>[
        'When does diversification fail?',
        'How should beta influence required return?',
        'What risk metric fits a pension vs a day trader?',
      ],
    ),
    'fin_capital': const BusinessLectureNote(
      lessonId: 'fin_capital',
      overview:
          'Capital structure mixes debt and equity. WACC and leverage effects determine the cost of funding investments.',
      keyConcepts: <String>[
        'Cost of equity and cost of debt',
        'Tax shield of interest',
        'Financial distress costs',
        'Trade-off and pecking-order intuitions',
      ],
      formulas: <String>[
        'WACC = E/V·r_e + D/V·r_d·(1 − t_c)',
        'r_e ≈ r_f + β·ERP',
      ],
      workedExample:
          'E = 60, D = 40, r_e = 12%, r_d = 6%, tax = 25%. WACC = 0.6·12% + 0.4·6%·0.75 = 7.2% + 1.8% = 9.0%. Higher leverage may cut WACC via tax shields until distress costs dominate.',
      application:
          'Compare financing a plant with debt vs equity by modeling WACC, covenants, and downside cash scenarios.',
      commonMistakes: <String>[
        'Using WACC with a mismatched project risk',
        'Ignoring covenants and refinancing risk',
        'Treating book weights as market weights',
      ],
      summary:
          'Optimal capital structure balances tax benefits against distress and agency costs.',
      reviewQuestions: <String>[
        'When does more debt destroy firm value?',
        'Why might equity be preferred despite a higher cost?',
        'How do you adjust WACC for a riskier division?',
      ],
    ),
    'fin_npv': const BusinessLectureNote(
      lessonId: 'fin_npv',
      overview:
          'Capital budgeting decides which projects create value. NPV is the primary rule; IRR is a useful but imperfect companion.',
      keyConcepts: <String>[
        'Incremental free cash flows',
        'Sunk costs and externalities',
        'NPV vs IRR conflicts',
        'Sensitivity and scenario analysis',
      ],
      formulas: <String>[
        'NPV = Σ CF_t / (1+r)^t − Initial investment',
        'IRR: rate that sets NPV = 0',
        'Profitability index = PV(inflows) / PV(outflows)',
      ],
      workedExample:
          'Invest \$100k, CF1–3 = \$40k, \$50k, \$40k, r = 10%. NPV ≈ 40/1.1 + 50/1.21 + 40/1.331 − 100 ≈ \$8.1k → accept. If mutually exclusive with a higher IRR but lower NPV project, choose higher NPV.',
      application:
          'Build base, upside, and downside cases; show which assumption flips the accept/reject decision.',
      commonMistakes: <String>[
        'Including sunk costs',
        'Forgetting working capital recovery',
        'Comparing IRRs across different scales/timings blindly',
      ],
      summary:
          'NPV aligns investment with shareholder value when cash flows and risk are honest.',
      reviewQuestions: <String>[
        'When can IRR mislead?',
        'How do you treat cannibalization of existing products?',
        'What discount rate belongs on this project?',
      ],
    ),
    'fin_statements': const BusinessLectureNote(
      lessonId: 'fin_statements',
      overview:
          'Three-statement models link income statement, balance sheet, and cash flow into a coherent forecast engine.',
      keyConcepts: <String>[
        'Integrated financial statements',
        'Operating drivers and plug (cash/revolver)',
        'Working capital and capex bridges',
        'Circular interest and iteration',
      ],
      formulas: <String>[
        'Cash flow identity: ΔCash = CFO + CFI + CFF',
        'Net income → retained earnings bridge',
        'NWC = Current assets − Current liabilities (ex-cash/debt as defined)',
      ],
      workedExample:
          'Revenue grows 8%, COGS 60% of sales, DSO 45 days. Forecast receivables = (45/365)×Sales. Link depreciation to PP&E schedule and ensure the balance sheet balances via a revolver plug.',
      application:
          'Stress-test: cut growth to 0%, raise DSO by 10 days, and show cash and covenant impacts before approving a budget.',
      commonMistakes: <String>[
        'Forecasting statements that do not articulate',
        'Hard-coding plugs instead of logic',
        'Ignoring seasonality in working capital',
      ],
      summary:
          'A credible model is linked, driver-based, and stress-tested—not a spreadsheet sculpture.',
      reviewQuestions: <String>[
        'What is your balancing plug and why?',
        'Which driver most affects cash conversion?',
        'How do you validate historical articulation?',
      ],
    ),
    'fin_dcf': const BusinessLectureNote(
      lessonId: 'fin_dcf',
      overview:
          'DCF and comps produce valuation ranges. Free cash flow, WACC, and terminal value drive intrinsic value; multiples provide market cross-checks.',
      keyConcepts: <String>[
        'Unlevered free cash flow',
        'Explicit forecast vs terminal value',
        'Exit multiple and Gordon growth methods',
        'Football-field valuation ranges',
      ],
      formulas: <String>[
        'UFCF ≈ EBIT(1−t) + D&A − Capex − ΔNWC',
        'TV_Gordon = FCF_{n+1} / (WACC − g)',
        'Enterprise value = Σ PV(UFCF) + PV(TV)',
      ],
      workedExample:
          'Year-5 FCF = \$50M, g = 2%, WACC = 9% → TV = 50×1.02/(0.09−0.02) ≈ \$729M. Discount TV and explicit FCFs, subtract net debt for equity value, then cross-check with EV/EBITDA comps.',
      application:
          'Present a valuation range, not a single number. Show sensitivity of value to WACC and g, and defend the midpoint for the investment committee.',
      commonMistakes: <String>[
        'g ≥ WACC in perpetuity',
        'Double-counting cash or debt items',
        'Mixing equity cash flows with WACC',
      ],
      summary:
          'Valuation is disciplined storytelling with transparent assumptions and triangulation.',
      reviewQuestions: <String>[
        'When is an exit multiple more credible than Gordon growth?',
        'How do you choose the forecast horizon?',
        'What comps adjustments are essential?',
      ],
    ),
    'fin_bank': const BusinessLectureNote(
      lessonId: 'fin_bank',
      overview:
          'Banks transform deposits into loans. Liquidity, capital, and credit underwriting determine whether the franchise survives stress.',
      keyConcepts: <String>[
        'Asset–liability management',
        'Liquidity coverage and deposit stickiness',
        'Credit underwriting and loss given default',
        'Bank-run dynamics',
      ],
      formulas: <String>[
        'Net interest margin ≈ (Interest income − Interest expense) / Earning assets',
        'Capital ratio = Capital / Risk-weighted assets',
      ],
      workedExample:
          'Loan book \$800M, deposits \$700M, wholesale funding \$150M. A deposit outflow of 10% requires liquidity buffers or asset sales. Pre-position HQLA and contingency funding before rumor spirals.',
      application:
          'Underwrite a commercial loan with cash-flow coverage, collateral, covenants, and concentration limits. Escalate if relationship pressure overrides credit standards.',
      commonMistakes: <String>[
        'Funding long assets with flighty short liabilities without buffers',
        'Evergreening bad loans',
        'Ignoring concentration risk',
      ],
      summary:
          'Banking soundness is credit quality plus liquidity confidence plus adequate capital.',
      reviewQuestions: <String>[
        'What triggers a run in your deposit base?',
        'How do covenants protect lenders?',
        'When should a loan be marked as nonperforming?',
      ],
    ),
    'fin_crypto': const BusinessLectureNote(
      lessonId: 'fin_crypto',
      overview:
          'Digital assets introduce new settlement rails and risks. Consensus, wallets, and tokenomics must be analyzed with traditional risk tools.',
      keyConcepts: <String>[
        'Consensus mechanisms and finality',
        'Custodial vs self-custody wallets',
        'Token supply, utility, and governance',
        'Operational, market, and smart-contract risk',
      ],
      formulas: <String>[
        'Fully diluted valuation = Price × Fully diluted supply',
        'On-chain velocity ≈ Transaction volume / Market cap (interpret cautiously)',
      ],
      workedExample:
          'A token with circulating 100M and unlocks of 400M over two years trades at \$2 (\$200M circ mcap) but \$1B FDV. Model unlock overhang and demand needed to absorb supply before sizing a position.',
      application:
          'Evaluate digital-asset exposure with custody controls, key management, and scenario losses—not narrative hype.',
      commonMistakes: <String>[
        'Confusing circ mcap with FDV',
        'Ignoring smart-contract and oracle risk',
        'Treating all tokens as “currency”',
      ],
      summary:
          'Crypto analysis is finance plus computer security plus incentive design.',
      reviewQuestions: <String>[
        'What fails if the oracle is manipulated?',
        'How do unlocks affect valuation?',
        'When is self-custody inappropriate for an institution?',
      ],
    ),
    'fin_capstone': const BusinessLectureNote(
      lessonId: 'fin_capstone',
      overview:
          'The portfolio capstone deploys capital under an investment committee mandate: return targets, risk limits, and transparent reporting.',
      keyConcepts: <String>[
        'Mandate and IPS constraints',
        'Trade rationale and risk budget',
        'Performance attribution',
        'Drawdown and liquidity management',
      ],
      formulas: <String>[
        'Active return = Portfolio return − Benchmark return',
        'Tracking error = σ(active returns)',
      ],
      workedExample:
          'Deploy \$100k with 60/40 core, 20% satellite, 20% hedges/cash. A 12% drawdown breaches risk limits—delever satellites first, document lessons, and report attribution to the committee.',
      application:
          'Defend every trade with thesis, invalidation level, size, and correlation to existing book.',
      commonMistakes: <String>[
        'Style drift without mandate update',
        'Hiding losses in illiquid marks',
        'Performance theater without risk context',
      ],
      summary:
          'Professional investing is process, risk control, and accountable communication.',
      reviewQuestions: <String>[
        'What would force you to exit a winning trade?',
        'How do you report a period of underperformance?',
        'Where is liquidity risk hiding in your book?',
      ],
    ),

    // —— Marketing ——
    'mkt_segmentation': const BusinessLectureNote(
      lessonId: 'mkt_segmentation',
      overview:
          'STP—segmentation, targeting, positioning—focuses scarce marketing resources on customers you can win and serve profitably.',
      keyConcepts: <String>[
        'Meaningful, measurable, accessible segments',
        'Target attractiveness and fit',
        'Positioning statement structure',
        'Differentiation that customers value',
      ],
      formulas: <String>[
        'Segment attractiveness ≈ size × growth × accessibility × profitability',
        'Positioning: For [target], Brand is [frame] that [benefit] because [reason]',
      ],
      workedExample:
          'A meal-kit firm finds three segments: convenience parents, fitness singles, budget students. Target convenience parents (highest willingness to pay and retention). Position: “For busy parents, FreshBox is the weeknight dinner system that delivers chef meals in 20 minutes because of pre-portioned kits and kid-approved menus.”',
      application:
          'Refuse “everyone” targeting. Choose one beachhead segment, write positioning, and align product, price, and channel to it.',
      commonMistakes: <String>[
        'Segments that are not actionable',
        'Positioning on features rivals can copy overnight',
        'Targeting without capacity to serve',
      ],
      summary:
          'Focus beats spray-and-pray: clear segments, chosen targets, sharp positioning.',
      reviewQuestions: <String>[
        'What evidence proves your segments differ in behavior?',
        'Why this target over the next-best segment?',
        'What is your frame of reference and point of difference?',
      ],
    ),
    'mkt_brand': const BusinessLectureNote(
      lessonId: 'mkt_brand',
      overview:
          'Brand strategy defines mission, audience, voice, and identity so every touchpoint reinforces a coherent promise.',
      keyConcepts: <String>[
        'Brand equity components',
        'Identity system: logo, color, typography, voice',
        'Brand architecture choices',
        'Measurement of awareness, consideration, preference',
      ],
      formulas: <String>[
        'Brand equity ≈ awareness × associations × perceived quality × loyalty',
        'Share of voice vs share of market diagnostics',
      ],
      workedExample:
          'A regional coffee brand refreshes identity: clearer mission (“third place for remote workers”), warmer visual system, and voice guidelines. Track aided awareness and repeat purchase; a 5-point awareness lift with flat retention signals message reach without product love.',
      application:
          'Build a one-page brand book and audit the top 10 customer touchpoints for consistency before launching campaigns.',
      commonMistakes: <String>[
        'Confusing logo redesign with strategy',
        'Inconsistent voice across channels',
        'No brand KPIs beyond vanity followers',
      ],
      summary:
          'Brand is a managed asset: promise, proof, and consistent expression.',
      reviewQuestions: <String>[
        'What associations should customers complete for your brand?',
        'Which touchpoint most violates the brand today?',
        'How will you measure equity this quarter?',
      ],
    ),
    'mkt_behavior': const BusinessLectureNote(
      lessonId: 'mkt_behavior',
      overview:
          'Consumer psychology explains journeys from need recognition to post-purchase. Behavioral principles must be applied ethically.',
      keyConcepts: <String>[
        'Customer journey stages',
        'Heuristics and biases (anchoring, social proof, scarcity)',
        'Motivation, ability, opportunity',
        'Ethical boundaries for persuasion',
      ],
      formulas: <String>[
        'Conversion ≈ traffic × intent × friction^(-1)',
        'NPS ≈ % promoters − % detractors',
      ],
      workedExample:
          'Checkout drop-off is 68%. Journey map shows unexpected shipping costs. Transparent shipping on PDP plus a progress bar lifts conversion 12% without dark patterns.',
      application:
          'Map the journey, identify friction and anxiety points, and redesign with clear information—not manipulative countdown timers on false scarcity.',
      commonMistakes: <String>[
        'Using dark patterns that destroy trust',
        'Assuming rational utility maximization always holds',
        'Ignoring post-purchase dissonance',
      ],
      summary:
          'Behaviorally informed marketing reduces friction and respects autonomy.',
      reviewQuestions: <String>[
        'Where is anxiety highest in your journey?',
        'Which bias are you tempted to misuse?',
        'How do you measure ethical persuasion?',
      ],
    ),
    'mkt_research': const BusinessLectureNote(
      lessonId: 'mkt_research',
      overview:
          'Research turns opinions into evidence through surveys, interviews, personas, and experiments.',
      keyConcepts: <String>[
        'Qualitative vs quantitative methods',
        'Sampling and bias',
        'Persona as decision tool, not fiction',
        'A/B testing and statistical caution',
      ],
      formulas: <String>[
        'Conversion lift = (B − A) / A',
        'Sample size rises with smaller effects and tighter confidence',
      ],
      workedExample:
          'Interview 15 users, survey 400, build 2 personas. A/B test a new headline: A 4.0% vs B 4.8% conversion on 20k sessions each. Relative lift 20%; check significance before rolling out.',
      application:
          'Write a research brief: decision to inform, method, sample, success metric, and kill criteria for weak ideas.',
      commonMistakes: <String>[
        'Personas invented without data',
        'Stopping tests too early',
        'Leading interview questions',
      ],
      summary:
          'Evidence beats HiPPO: design research that can change a decision.',
      reviewQuestions: <String>[
        'What decision will this study change?',
        'What bias threatens your sample?',
        'When is qualitative enough?',
      ],
    ),
    'mkt_ads': const BusinessLectureNote(
      lessonId: 'mkt_ads',
      overview:
          'Digital growth allocates budgets across paid media, SEO, and email. Unit economics—CTR, CAC, ROAS, LTV—decide scale or cut.',
      keyConcepts: <String>[
        'Funnel stages and channel roles',
        'Paid vs organic complementarity',
        'Creative and audience testing',
        'Incrementality vs last-click myths',
      ],
      formulas: <String>[
        'CTR = Clicks / Impressions',
        'CAC = Spend / New customers',
        'ROAS = Revenue / Ad spend',
        'LTV/CAC target often ≥ 3 depending on payback',
      ],
      workedExample:
          'Spend \$10k, 200 customers → CAC \$50. Average contribution month-1 \$20, LTV \$180 → LTV/CAC = 3.6. Scale if incrementality tests confirm causality; otherwise creative is stealing branded search.',
      application:
          'Allocate budget by marginal CAC and payback, not by historical habit. Pair SEO compounding with paid learning loops.',
      commonMistakes: <String>[
        'Optimizing ROAS while ignoring contribution margin',
        'Scaling before creative diversity',
        'Trusting last-click attribution alone',
      ],
      summary: 'Growth is an experiment machine governed by unit economics.',
      reviewQuestions: <String>[
        'Which channel is incrementally profitable?',
        'What is acceptable payback for your cash position?',
        'How do SEO and paid reinforce each other?',
      ],
    ),
    'mkt_analytics': const BusinessLectureNote(
      lessonId: 'mkt_analytics',
      overview:
          'Analytics diagnoses funnels, retention cohorts, and attribution so teams fix leaks instead of guessing.',
      keyConcepts: <String>[
        'Conversion funnel diagnostics',
        'Cohort retention curves',
        'Attribution model trade-offs',
        'Leading vs lagging growth metrics',
      ],
      formulas: <String>[
        'Step conversion = Users_step / Users_prior',
        'Retention_d30 = Active_d30 / Cohort_start',
        'Blended CAC = Total growth spend / New customers',
      ],
      workedExample:
          'Signup→activate 40%, activate→pay 10%. Improving activation by 10 points to 50% at constant pay rate raises paying users 25% without more traffic—usually cheaper than buying clicks.',
      application:
          'Build a weekly funnel review: biggest drop-off, experiment hypothesis, owner, and ship date. Compare first-touch, last-touch, and data-driven attribution qualitatively.',
      commonMistakes: <String>[
        'Averaging retention without cohorts',
        'Chasing vanity traffic',
        'Changing five variables in one test',
      ],
      summary:
          'Analytics is a decision system: find the constraint, test, measure, repeat.',
      reviewQuestions: <String>[
        'Where is the largest convertible leak?',
        'What does a healthy retention curve look like for your product?',
        'Which attribution story would change budget most?',
      ],
    ),
    'mkt_launch': const BusinessLectureNote(
      lessonId: 'mkt_launch',
      overview:
          'An integrated product launch aligns price, packaging, promotion, and distribution, then adapts to daily market feedback.',
      keyConcepts: <String>[
        '4Ps / 7Ps coherence',
        'Launch readiness checklist',
        'Feedback loops and kill/iterate criteria',
        'Postmortem learning',
      ],
      formulas: <String>[
        'Launch ROI ≈ (Incremental contribution − Launch cost) / Launch cost',
        'Sell-through = Units sold / Units shipped',
      ],
      workedExample:
          'Launch week sell-through is 35% vs 60% plan. Cut underperforming SKUs, shift budget to winning creative, and renegotiate display. Document what leading indicator failed.',
      application:
          'Run a war-room cadence: daily metrics, owners, and decisions. End with a postmortem that changes the next launch checklist.',
      commonMistakes: <String>[
        'Launching without support capacity',
        'Fixed plans that ignore early signal',
        'No postmortem ownership',
      ],
      summary: 'Launches are learning sprints with commercial stakes.',
      reviewQuestions: <String>[
        'What leading indicator predicts launch failure by day 3?',
        'Which P is misaligned today?',
        'What will you change in the next launch playbook?',
      ],
    ),
    'mkt_capstone': const BusinessLectureNote(
      lessonId: 'mkt_capstone',
      overview:
          'The global brand capstone requires leading an integrated team, managing budget, and defending ROI and brand decisions together.',
      keyConcepts: <String>[
        'Cross-functional brand leadership',
        'Budget allocation under uncertainty',
        'Brand vs performance trade-offs',
        'Executive storytelling with metrics',
      ],
      formulas: <String>[
        'Marketing contribution = Revenue lift × Margin − Spend',
        'Brand health index (custom composite of awareness, consideration, NPS)',
      ],
      workedExample:
          'A \$2M global launch over-indexes on performance ads; brand search stagnates. Rebalance 30% to always-on brand and creator partnerships; show blended CAC and consideration lift to leadership.',
      application:
          'Defend decisions with a one-slide narrative: goal, allocation, results, risks, next bets.',
      commonMistakes: <String>[
        'Optimizing short-term CAC while burning brand equity',
        'Orphaned regional campaigns without global guardrails',
        'Reporting activity instead of outcomes',
      ],
      summary:
          'Brand leadership balances enduring equity with accountable growth.',
      reviewQuestions: <String>[
        'How do you trade off brand and performance this quarter?',
        'What governance keeps global brand coherent?',
        'Which metric would make you cut a sacred channel?',
      ],
    ),

    // —— Accounting ——
    'acc_equation': const BusinessLectureNote(
      lessonId: 'acc_equation',
      overview:
          'The accounting equation and double-entry system keep the books in balance. Every transaction has balanced debits and credits.',
      keyConcepts: <String>[
        'Assets = Liabilities + Equity',
        'Debits and credits by account type',
        'Journal entries and T-accounts',
        'Accrual vs cash timing',
      ],
      formulas: <String>[
        'Assets = Liabilities + Equity',
        'Expanded: Assets = Liabilities + Common stock + Retained earnings',
        'Retained earnings bridges via Net income − Dividends',
      ],
      workedExample:
          'Buy \$5,000 inventory on credit: Debit Inventory 5,000, Credit Accounts Payable 5,000. Equation stays balanced: assets ↑, liabilities ↑.',
      application:
          'Classify unfamiliar accounts before booking. If unsure, ask: did an economic resource, obligation, or owner claim change?',
      commonMistakes: <String>[
        'Debiting revenue or crediting expenses by habit',
        'Recording cash basis in an accrual system',
        'Unbalanced journal entries',
      ],
      summary:
          'Double-entry is the grammar of financial truth: every story balances.',
      reviewQuestions: <String>[
        'How does paying a payable affect the equation?',
        'When does revenue get credited under accrual accounting?',
        'What is the normal balance of Unearned Revenue?',
      ],
    ),
    'acc_statements': const BusinessLectureNote(
      lessonId: 'acc_statements',
      overview:
          'Financial statements present performance and position. Income statement, balance sheet, and cash flow link into one story.',
      keyConcepts: <String>[
        'Income statement: performance over a period',
        'Balance sheet: position at a point in time',
        'Cash flow: operating, investing, financing',
        'Articulation across statements',
      ],
      formulas: <String>[
        'Net income = Revenues − Expenses',
        'Ending equity = Beginning + NI − Dividends ± other equity',
        'CFO (indirect) starts from NI ± noncash ± ΔNWC',
      ],
      workedExample:
          'NI \$120k, depreciation \$30k, ΔAR +\$20k, ΔAP +\$10k → rough CFO ≈ 120 + 30 − 20 + 10 = \$140k. Link NI to retained earnings on the balance sheet and reconcile cash.',
      application:
          'Explain to a non-accountant why profitable firms can run out of cash: growth in receivables and inventory.',
      commonMistakes: <String>[
        'Equating NI with cash',
        'Misclassifying financing as operating cash flow',
        'Statements that do not articulate',
      ],
      summary:
          'Statements are three camera angles on one business—read them together.',
      reviewQuestions: <String>[
        'How does Capex appear across statements?',
        'Why can CFO exceed NI?',
        'What does negative CFO with rising NI suggest?',
      ],
    ),
    'acc_cost': const BusinessLectureNote(
      lessonId: 'acc_cost',
      overview:
          'Managerial costing separates fixed and variable costs to support pricing, mix, and break-even decisions.',
      keyConcepts: <String>[
        'Cost behavior patterns',
        'Contribution margin',
        'Break-even and margin of safety',
        'Operating leverage',
      ],
      formulas: <String>[
        'Contribution margin = Sales − Variable costs',
        'Break-even units = Fixed costs / CM per unit',
        'Degree of operating leverage ≈ CM / Operating income',
      ],
      workedExample:
          'Price \$50, VC \$30, fixed \$100,000 → CM \$20, break-even 5,000 units. At 6,000 units, operating income \$20,000. A 10% volume drop hurts high-DOL firms more.',
      application:
          'Before a price cut, recompute break-even and check whether volume can realistically rise enough to protect profit.',
      commonMistakes: <String>[
        'Treating stepped-fixed costs as purely variable',
        'Using absorption cost for short-run pricing',
        'Ignoring capacity constraints',
      ],
      summary:
          'Cost behavior is the bridge from accounting to operating decisions.',
      reviewQuestions: <String>[
        'How does a higher fixed-cost base change risk?',
        'When is contribution margin the right pricing floor?',
        'What is margin of safety in units and dollars?',
      ],
    ),
    'acc_budget': const BusinessLectureNote(
      lessonId: 'acc_budget',
      overview:
          'Budgets translate plans into numbers; variance analysis explains why results differed and what to do next.',
      keyConcepts: <String>[
        'Operating budget cascade',
        'Flexible vs static budgets',
        'Price and efficiency variances',
        'Management by exception',
      ],
      formulas: <String>[
        'Flexible budget = Standard × Actual activity',
        'Price variance ≈ (AP − SP) × AQ',
        'Efficiency variance ≈ (AQ − SQ) × SP',
      ],
      workedExample:
          'Standard materials \$4/kg, 2 kg/unit. Actual 1,050 kg for 500 units at \$4.20. Price variance = 0.20×1,050 = \$210 U. Efficiency = (1,050 − 1,000)×4 = \$200 U.',
      application:
          'Investigate significant variances with process owners; recommend corrective action or revise standards if they are obsolete.',
      commonMistakes: <String>[
        'Judging managers on static budgets when volume changed',
        'Punishing variances without root-cause analysis',
        'Sandbagging budgets',
      ],
      summary:
          'Budgets coordinate; variances teach—if the culture allows learning.',
      reviewQuestions: <String>[
        'When is a favorable variance still a problem?',
        'How do flexible budgets improve accountability?',
        'Which variance should ops own vs purchasing?',
      ],
    ),
    'acc_audit': const BusinessLectureNote(
      lessonId: 'acc_audit',
      overview:
          'Auditing obtains reasonable assurance that financial statements are free of material misstatement through risk assessment, controls, and evidence.',
      keyConcepts: <String>[
        'Materiality and risk of material misstatement',
        'Internal control components',
        'Substantive vs control tests',
        'Documentation and professional skepticism',
      ],
      formulas: <String>[
        'Audit risk ≈ Inherent × Control × Detection (conceptual)',
        'Sample size rises with risk and desired assurance',
      ],
      workedExample:
          'Revenue recognition risk is high for contracts with multiple performance obligations. Design walkthroughs of controls, then substantive tests of details on a stratified sample of large contracts.',
      application:
          'Document evidence so a reviewer can re-perform the logic. Escalate when management overrides controls.',
      commonMistakes: <String>[
        'Over-relying on inquiry without corroboration',
        'Ignoring fraud risk factors',
        'Poor tick-mark and workpaper trail',
      ],
      summary: 'Audit quality is skepticism plus evidence plus documentation.',
      reviewQuestions: <String>[
        'What makes a misstatement material?',
        'When do you test controls vs go substantive?',
        'How do you respond to management override risk?',
      ],
    ),
    'acc_fraud': const BusinessLectureNote(
      lessonId: 'acc_fraud',
      overview:
          'Fraud investigation follows red flags, traces transactions, and documents findings suitable for legal and board scrutiny.',
      keyConcepts: <String>[
        'Fraud triangle: pressure, opportunity, rationalization',
        'Asset misappropriation vs financial reporting fraud',
        'Data analytics red flags',
        'Chain of custody and reporting',
      ],
      formulas: <String>[
        'Beneish-style ratio screens (interpret cautiously)',
        'Unexpected relationship tests: e.g., revenue vs cash collections',
      ],
      workedExample:
          'Vendor master shows a new payee matching an employee address. Trace invoices, approvals, and bank payments. Quantify loss, preserve evidence, and draft a findings memo with control recommendations.',
      application:
          'Separate investigation from remediation. Do not tip subjects prematurely; coordinate with counsel when needed.',
      commonMistakes: <String>[
        'Confronting suspects before securing evidence',
        'Stopping at one anomaly without pattern analysis',
        'Informal notes that fail legal standards',
      ],
      summary:
          'Forensics is disciplined inquiry: hypothesize, trace, corroborate, report.',
      reviewQuestions: <String>[
        'Which red flags are most predictive in AP fraud?',
        'How do you preserve digital evidence?',
        'What belongs in a board findings memo?',
      ],
    ),
    'acc_tax': const BusinessLectureNote(
      lessonId: 'acc_tax',
      overview:
          'Business tax computation covers corporate income tax, VAT/GST concepts, and payroll taxes, plus book–tax differences.',
      keyConcepts: <String>[
        'Taxable income vs book income',
        'Temporary vs permanent differences',
        'VAT input/output mechanics',
        'Payroll tax employer/employee split',
      ],
      formulas: <String>[
        'Taxable income = Book income ± adjustments',
        'VAT payable ≈ Output VAT − Input VAT',
        'Employer payroll cost = Wages + employer taxes + benefits',
      ],
      workedExample:
          'Book income \$500k, nondeductible fines \$20k, extra tax depreciation \$30k → taxable income \$490k. At 25%, tax \$122.5k. Explain each adjustment in a reconciliation rollforward.',
      application:
          'Build a book–tax bridge every period. For VAT, reconcile returns to sales and purchase ledgers before filing.',
      commonMistakes: <String>[
        'Missing permanent differences',
        'Netting VAT incorrectly across jurisdictions',
        'Ignoring late-deposit payroll penalties',
      ],
      summary:
          'Tax accounting is precision plus explanation: compute, reconcile, document.',
      reviewQuestions: <String>[
        'Give an example of a temporary difference.',
        'How does input VAT recovery work?',
        'What controls prevent payroll tax late payments?',
      ],
    ),
    'acc_capstone': const BusinessLectureNote(
      lessonId: 'acc_capstone',
      overview:
          'The Big Four-style audit capstone integrates planning, controls, evidence, deficiencies, and audit-committee communication.',
      keyConcepts: <String>[
        'End-to-end audit lifecycle',
        'Significant deficiencies vs material weaknesses',
        'Management letter recommendations',
        'Audit committee reporting',
      ],
      formulas: <String>[
        'Materiality benchmarks (e.g., % of pretax income) set planning thresholds',
        'Uncorrected misstatement aggregation vs materiality',
      ],
      workedExample:
          'Control testing finds missing approvals on journal entries above threshold. Evaluate severity, expand substantive testing, draft a deficiency, and present remediation timeline to the audit committee.',
      application:
          'Lead the engagement narrative: risks, procedures, results, open items, and opinion implications—without burying bad news.',
      commonMistakes: <String>[
        'Soft-pedaling control failures',
        'Late communication of significant risks',
        'Opinion shopping pressure without documentation',
      ],
      summary:
          'Capstone auditing is professional judgment under public-interest duty.',
      reviewQuestions: <String>[
        'How do you classify a control deficiency?',
        'What must the audit committee hear before sign-off?',
        'When does a scope limitation affect the opinion?',
      ],
    ),
  };
}
