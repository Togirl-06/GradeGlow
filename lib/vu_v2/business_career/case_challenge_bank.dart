/// Typed case challenges with deterministic option-based grading.
class CaseOption {
  const CaseOption({
    required this.id,
    required this.label,
    required this.detail,
    this.coachTip,
  });

  final String id;
  final String label;
  final String detail;
  final String? coachTip;
}

class CaseResult {
  const CaseResult({
    required this.name,
    required this.passed,
    required this.detail,
  });

  final String name;
  final bool passed;
  final String detail;
}

class CaseChallenge {
  const CaseChallenge({
    required this.id,
    required this.majorId,
    required this.title,
    required this.difficulty,
    required this.topics,
    required this.prompt,
    required this.scenario,
    required this.xpReward,
    required this.options,
    required this.correctOptionId,
    required this.grade,
  });

  final String id;
  final String majorId;
  final String title;
  final String difficulty;
  final List<String> topics;
  final String prompt;
  final String scenario;
  final int xpReward;
  final List<CaseOption> options;
  final String correctOptionId;
  final List<CaseResult> Function(String optionId) grade;
}

abstract final class CaseChallengeBank {
  static List<CaseChallenge>? _cache;

  static List<CaseChallenge> all() {
    final List<CaseChallenge>? existing = _cache;
    if (existing != null) return existing;
    _cache = <CaseChallenge>[
      ..._businessAdministration(),
      ..._accounting(),
      ..._finance(),
      ..._economics(),
      ..._entrepreneurship(),
      ..._marketing(),
      ..._humanResourceManagement(),
      ..._internationalBusiness(),
    ];
    return _cache!;
  }

  static List<CaseChallenge> forMajor(String majorId) {
    return all()
        .where((CaseChallenge c) => c.majorId == majorId)
        .toList(growable: false);
  }

  static List<CaseResult> _grade(
    String optionId,
    String correctId, {
    required List<String> criteria,
  }) {
    final bool ok = optionId == correctId;
    if (ok) {
      return criteria
          .map(
            (String c) => CaseResult(
              name: c.split(':').first.trim(),
              passed: true,
              detail: c,
            ),
          )
          .toList(growable: false);
    }
    // Incorrect: fail primary checks; last row may pass only for non-panic choices.
    final List<CaseResult> rows = <CaseResult>[];
    for (int i = 0; i < criteria.length; i++) {
      final String c = criteria[i];
      final bool passed =
          i == criteria.length - 1 && optionId != 'panic' && optionId != 'ignore';
      rows.add(
        CaseResult(
          name: c.split(':').first.trim(),
          passed: passed,
          detail: i == 0 ? 'Incorrect approach. $c' : c,
        ),
      );
    }
    return rows;
  }

  static CaseChallenge _c({
    required String id,
    required String majorId,
    required String title,
    required String difficulty,
    required List<String> topics,
    required String prompt,
    required String scenario,
    required int xpReward,
    required List<CaseOption> options,
    required String correctOptionId,
    required List<String> criteria,
  }) {
    return CaseChallenge(
      id: id,
      majorId: majorId,
      title: title,
      difficulty: difficulty,
      topics: topics,
      prompt: prompt,
      scenario: scenario,
      xpReward: xpReward,
      options: options,
      correctOptionId: correctOptionId,
      grade: (String optionId) =>
          _grade(optionId, correctOptionId, criteria: criteria),
    );
  }

  // —— Business Administration ——
  static List<CaseChallenge> _businessAdministration() => <CaseChallenge>[
        _c(
          id: 'ba_declining_margin',
          majorId: 'business_administration',
          title: 'Declining Operating Margin',
          difficulty: 'Medium',
          topics: const <String>['Operations', 'Cost control', 'Strategy'],
          prompt:
              'Margin fell from 18% to 11% in two quarters. Choose the first move.',
          scenario:
              'A mid-market retailer has rising freight costs, stalled same-store '
              'sales, and a bloated SKU list. The board wants a 90-day plan.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'cut_all',
              label: 'Cut 20% headcount across every department',
              detail: 'Immediate payroll savings without analysis.',
              coachTip: 'Blanket cuts damage capacity before you know the drivers.',
            ),
            CaseOption(
              id: 'diagnose',
              label: 'Map cost drivers, then cut low-ROI SKUs and renegotiate freight',
              detail: 'Diagnose margin leak, then act on the largest levers.',
              coachTip: 'Correct — diagnose before cutting.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Raise prices 15% on all products immediately',
              detail: 'Try to restore margin through price alone.',
              coachTip: 'Sudden broad price hikes can crush volume.',
            ),
          ],
          correctOptionId: 'diagnose',
          criteria: const <String>[
            'Root cause: Identified freight and SKU complexity as primary leaks',
            'Action plan: Prioritized high-impact, reversible moves in 90 days',
            'Risk: Avoided capacity destruction from blanket cuts',
          ],
        ),
        _c(
          id: 'ba_capacity_crunch',
          majorId: 'business_administration',
          title: 'Warehouse Capacity Crunch',
          difficulty: 'Easy',
          topics: const <String>['Operations', 'Capacity', 'Prioritization'],
          prompt: 'Peak season is three weeks away and the warehouse is at 92% fill.',
          scenario:
              'Outbound SLA is slipping. Leadership wants a decision tonight: '
              'expand storage, throttle inbound, or overtime everything.',
          xpReward: 40,
          options: const <CaseOption>[
            CaseOption(
              id: 'throttle',
              label: 'Throttle slow movers and prioritize A-SKU inbound/outbound',
              detail: 'Free space by slotting and flow priority.',
              coachTip: 'Correct — protect service on what sells.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Do nothing and hope overtime clears the backlog',
              detail: 'Rely on labor alone.',
              coachTip: 'Overtime does not create cubic space.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Lease a second warehouse starting tomorrow',
              detail: 'Immediate expansion without demand check.',
              coachTip: 'Too slow and expensive for a three-week peak.',
            ),
          ],
          correctOptionId: 'throttle',
          criteria: const <String>[
            'Service: Protected A-SKU flow before peak',
            'Capacity: Freed cubic space via slow-mover throttle',
            'Speed: Decision executable within days, not months',
          ],
        ),
        _c(
          id: 'ba_vendor_sla',
          majorId: 'business_administration',
          title: 'Vendor SLA Breach',
          difficulty: 'Medium',
          topics: const <String>['Procurement', 'Contracts', 'Risk'],
          prompt: 'A critical vendor missed SLA three times this quarter.',
          scenario:
              'Switching vendors takes 8 weeks. Production needs parts next month. '
              'Legal wants a paper trail; ops wants parts.',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'terminate',
              label: 'Terminate immediately and halt orders',
              detail: 'Punish the vendor with a hard stop.',
              coachTip: 'Creates a supply cliff before dual-sourcing is ready.',
            ),
            CaseOption(
              id: 'dual_source',
              label: 'Issue formal cure notice, dual-source 30%, keep critical flow',
              detail: 'Document breach while de-risking supply.',
              coachTip: 'Correct — pressure + continuity.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore breaches to keep the relationship warm',
              detail: 'No escalation.',
              coachTip: 'Silence trains the vendor to under-deliver.',
            ),
          ],
          correctOptionId: 'dual_source',
          criteria: const <String>[
            'Continuity: Critical parts still flowing',
            'Leverage: Formal cure notice creates accountability',
            'Risk: Dual-sourcing reduces single-vendor exposure',
          ],
        ),
        _c(
          id: 'ba_meeting_overload',
          majorId: 'business_administration',
          title: 'Meeting Overload Tax',
          difficulty: 'Easy',
          topics: const <String>['Leadership', 'Productivity', 'Culture'],
          prompt: 'Managers report 22 hours/week in meetings and missed deadlines.',
          scenario:
              'A 180-person ops org grew fast. Calendar sprawl is delaying projects. '
              'You can reset norms without a reorg.',
          xpReward: 35,
          options: const <CaseOption>[
            CaseOption(
              id: 'norms',
              label: 'Set no-meeting blocks, require agendas, kill zombie recurring meetings',
              detail: 'Reset calendar norms and reclaim maker time.',
              coachTip: 'Correct — process before headcount.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Ban all meetings company-wide for a month',
              detail: 'Extreme freeze.',
              coachTip: 'Breaks coordination for cross-team work.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Hire more managers to attend the meetings',
              detail: 'Scale attendance.',
              coachTip: 'Adds cost without fixing the root cause.',
            ),
          ],
          correctOptionId: 'norms',
          criteria: const <String>[
            'Focus time: Protected maker blocks on calendars',
            'Hygiene: Agendas required; unused recurring meetings removed',
            'Cost: Fix without unnecessary headcount',
          ],
        ),
      ];

  // —— Accounting ——
  static List<CaseChallenge> _accounting() => <CaseChallenge>[
        _c(
          id: 'ac_missing_12k',
          majorId: 'accounting',
          title: 'The Missing \$12,000',
          difficulty: 'Medium',
          topics: const <String>['Reconciliation', 'Internal controls', 'Cash'],
          prompt: 'Bank shows \$12,000 less than the book cash balance.',
          scenario:
              'Month-end close. Three unrecorded wire fees, one uncleared deposit, '
              'and a possible duplicate AP payment are in play.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'recon',
              label: 'Rebuild bank rec: timing items first, then investigate AP duplicate',
              detail: 'Standard recon before fraud assumptions.',
              coachTip: 'Correct — timing differences first.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Accuse payroll of theft and freeze all payments',
              detail: 'Jump to fraud.',
              coachTip: 'Escalate only after recon evidence.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Force the books to match the bank with a plug entry',
              detail: 'Hide the difference.',
              coachTip: 'Plugs destroy audit trails.',
            ),
          ],
          correctOptionId: 'recon',
          criteria: const <String>[
            'Process: Bank reconciliation completed before conclusions',
            'Evidence: Timing items separated from true exceptions',
            'Control: No unsupported plug entries posted',
          ],
        ),
        _c(
          id: 'ac_revenue_cutover',
          majorId: 'accounting',
          title: 'Revenue Cutoff Risk',
          difficulty: 'Hard',
          topics: const <String>['Revenue recognition', 'Cutoff', 'Audit'],
          prompt: 'Sales shipped Dec 31 but risk title transfer on Jan 2.',
          scenario:
              'Quota pressure is high. Sales wants Q4 revenue. Shipping docs are '
              'ambiguous on FOB terms.',
          xpReward: 65,
          options: const <CaseOption>[
            CaseOption(
              id: 'defer',
              label: 'Defer revenue until control transfers; disclose if material',
              detail: 'Follow ASC 606 / control transfer.',
              coachTip: 'Correct — substance over quota.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Book all shipments as Q4 to hit the board target',
              detail: 'Prioritize optics.',
              coachTip: 'Premature recognition is a restatement risk.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Split 50/50 between Q4 and Q1 without evidence',
              detail: 'Compromise without docs.',
              coachTip: 'Arbitrary splits are not GAAP.',
            ),
          ],
          correctOptionId: 'defer',
          criteria: const <String>[
            'GAAP: Revenue tied to control transfer evidence',
            'Documentation: Shipping terms reviewed before booking',
            'Integrity: Targets did not override recognition rules',
          ],
        ),
        _c(
          id: 'ac_expense_class',
          majorId: 'accounting',
          title: 'Capex vs Expense',
          difficulty: 'Easy',
          topics: const <String>['Classification', 'Fixed assets', 'P&L'],
          prompt: 'IT bought \$18k of laptops and \$2k of cables in one PO.',
          scenario:
              'Controller asks whether to capitalize the full PO or expense it. '
              'Policy threshold is \$1,000 per asset with useful life > 1 year.',
          xpReward: 40,
          options: const <CaseOption>[
            CaseOption(
              id: 'split',
              label: 'Capitalize laptops; expense cables as supplies',
              detail: 'Apply threshold and useful life per item class.',
              coachTip: 'Correct — classify by nature, not PO total.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Expense everything to reduce taxable income this year',
              detail: 'Tax-driven misclassification.',
              coachTip: 'Book per policy, then consider tax elections separately.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Capitalize the entire \$20k PO as one asset',
              detail: 'Bundle dissimilar items.',
              coachTip: 'Cables are not a long-lived asset unit.',
            ),
          ],
          correctOptionId: 'split',
          criteria: const <String>[
            'Policy: Threshold applied per asset class',
            'Accuracy: Laptops capitalized; cables expensed',
            'Audit: Classification supported by useful life',
          ],
        ),
      ];

  // —— Finance ——
  static List<CaseChallenge> _finance() => <CaseChallenge>[
        _c(
          id: 'fi_portfolio_50k',
          majorId: 'finance',
          title: 'The \$50,000 Portfolio',
          difficulty: 'Medium',
          topics: const <String>['Allocation', 'Risk', 'Diversification'],
          prompt: 'Build a starter \$50k portfolio for a client with moderate risk.',
          scenario:
              'Client is 32, 10-year horizon, no near-term house purchase. '
              'They ask for "maximum upside" after seeing meme stocks.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'balanced',
              label: '70/25/5 equities/bonds/cash with broad-index core',
              detail: 'Diversified core, modest satellite risk.',
              coachTip: 'Correct — match risk to horizon.',
            ),
            CaseOption(
              id: 'panic',
              label: '100% in three meme stocks for upside',
              detail: 'Concentrated speculation.',
              coachTip: 'Concentration risk ignores moderate profile.',
            ),
            CaseOption(
              id: 'ignore',
              label: '100% cash until markets feel safer',
              detail: 'Sit out indefinitely.',
              coachTip: 'Cash drag vs 10-year horizon.',
            ),
          ],
          correctOptionId: 'balanced',
          criteria: const <String>[
            'Fit: Allocation matches moderate risk and horizon',
            'Diversification: Broad-index core reduces idiosyncratic risk',
            'Liquidity: Small cash buffer for rebalancing',
          ],
        ),
        _c(
          id: 'fi_wacc_project',
          majorId: 'finance',
          title: 'Project Hurdle Rate',
          difficulty: 'Hard',
          topics: const <String>['WACC', 'Capital budgeting', 'NPV'],
          prompt: 'Should the firm greenlight a plant expansion with IRR 9.2%?',
          scenario:
              'Company WACC is 8.0%. Project is riskier than the average firm '
              'project (new geography). CFO wants a simple yes/no.',
          xpReward: 65,
          options: const <CaseOption>[
            CaseOption(
              id: 'risk_adjust',
              label: 'Use a risk-adjusted hurdle above WACC; reject if IRR below it',
              detail: 'Match discount rate to project risk.',
              coachTip: 'Correct — WACC is for average-risk projects.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Approve because IRR beats WACC by 1.2 points',
              detail: 'Ignore incremental risk.',
              coachTip: 'Spread may vanish after risk adjustment.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Reject every project below 15% IRR forever',
              detail: 'Arbitrary high bar.',
              coachTip: 'Leaves value on the table.',
            ),
          ],
          correctOptionId: 'risk_adjust',
          criteria: const <String>[
            'Method: Hurdle reflects project risk, not only firm WACC',
            'Decision: IRR compared to risk-adjusted rate',
            'Governance: Clear rationale for CFO/board',
          ],
        ),
        _c(
          id: 'fi_liquidity_shock',
          majorId: 'finance',
          title: 'Liquidity Shock Week',
          difficulty: 'Medium',
          topics: const <String>['Liquidity', 'Working capital', 'Treasury'],
          prompt: 'A major customer delayed a \$2M receivable by 45 days.',
          scenario:
              'Payroll is in 10 days. Revolver has \$1.2M unused. Inventory is '
              'elevated. Rating agency watches leverage.',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'bridge',
              label: 'Draw revolver as bridge, accelerate collections, pause noncritical spend',
              detail: 'Bridge liquidity while fixing WC.',
              coachTip: 'Correct — survive first, then optimize.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Skip payroll to protect the cash ratio',
              detail: 'Break payroll.',
              coachTip: 'Catastrophic legal and culture risk.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Issue a large special dividend to calm investors',
              detail: 'Outflow during a squeeze.',
              coachTip: 'Worsens the liquidity hole.',
            ),
          ],
          correctOptionId: 'bridge',
          criteria: const <String>[
            'Solvency: Near-term payroll covered',
            'Working capital: Collections and spend discipline activated',
            'Credit: Revolver used as bridge, not permanent crutch',
          ],
        ),
      ];

  // —— Economics ——
  static List<CaseChallenge> _economics() => <CaseChallenge>[
        _c(
          id: 'ec_inflation_challenge',
          majorId: 'economics',
          title: 'The Inflation Challenge',
          difficulty: 'Medium',
          topics: const <String>['Inflation', 'Policy', 'Trade-offs'],
          prompt: 'CPI is 6%. Unemployment is 4.1%. Recommend a policy mix.',
          scenario:
              'Advising a fictional central bank. Growth is soft but not collapsing. '
              'Energy prices drove half the CPI print.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'gradual',
              label: 'Tighten gradually; target core; avoid shock hiking into soft growth',
              detail: 'Balance inflation fight with growth risk.',
              coachTip: 'Correct — path matters, not only destination.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Emergency 300bp hike tomorrow regardless of growth',
              detail: 'Shock therapy.',
              coachTip: 'Overshoot risk into recession.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore CPI because energy is "transitory forever"',
              detail: 'No response.',
              coachTip: 'Expectations can un-anchor.',
            ),
          ],
          correctOptionId: 'gradual',
          criteria: const <String>[
            'Diagnosis: Separated volatile energy from core pressure',
            'Tooling: Gradual tightening path specified',
            'Trade-off: Growth risk acknowledged',
          ],
        ),
        _c(
          id: 'ec_price_ceiling',
          majorId: 'economics',
          title: 'Rent Price Ceiling',
          difficulty: 'Easy',
          topics: const <String>['Supply', 'Demand', 'Controls'],
          prompt: 'City proposes a hard rent ceiling 20% below market.',
          scenario:
              'Short-run housing supply is inelastic. Vacancy is already low. '
              'Mayor wants "affordability now."',
          xpReward: 40,
          options: const <CaseOption>[
            CaseOption(
              id: 'shortage',
              label: 'Warn of shortages/queues; pair any control with supply incentives',
              detail: 'Classic price ceiling outcome.',
              coachTip: 'Correct — ceilings ration via shortage.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Claim ceilings always raise quantity supplied',
              detail: 'Wrong supply response.',
              coachTip: 'Lower price reduces quantity supplied.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore incidence and only publish the headline savings',
              detail: 'Optics over analysis.',
              coachTip: 'Misses rationing and quality decline.',
            ),
          ],
          correctOptionId: 'shortage',
          criteria: const <String>[
            'Theory: Price ceiling below equilibrium → shortage',
            'Policy: Supply-side complements recommended',
            'Clarity: Trade-offs communicated to policymakers',
          ],
        ),
        _c(
          id: 'ec_tariff_shock',
          majorId: 'economics',
          title: 'Tariff Incidence Brief',
          difficulty: 'Medium',
          topics: const <String>['Trade', 'Incidence', 'Elasticity'],
          prompt: 'A 15% tariff hits imported components used by domestic factories.',
          scenario:
              'Who bears the burden — foreign exporters, domestic firms, or consumers? '
              'Import demand is inelastic short run.',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'pass_through',
              label: 'Expect high pass-through to domestic costs/prices short run',
              detail: 'Inelastic demand → buyers bear more.',
              coachTip: 'Correct — elasticity drives incidence.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Assume foreign exporters always pay 100% of tariffs',
              detail: 'Wishful incidence.',
              coachTip: 'Not true when demand is inelastic.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore intermediate goods and only model final retail',
              detail: 'Skip supply chain.',
              coachTip: 'Misses factory cost shock.',
            ),
          ],
          correctOptionId: 'pass_through',
          criteria: const <String>[
            'Incidence: Linked to elasticities',
            'Channel: Intermediate-goods cost path identified',
            'Horizon: Short-run inelasticity noted',
          ],
        ),
      ];

  // —— Entrepreneurship ——
  static List<CaseChallenge> _entrepreneurship() => <CaseChallenge>[
        _c(
          id: 'en_mvp_scope',
          majorId: 'entrepreneurship',
          title: 'MVP Scope Trap',
          difficulty: 'Easy',
          topics: const <String>['Validation', 'MVP', 'Focus'],
          prompt: 'You have 6 weeks and \$8k to test a B2B scheduling idea.',
          scenario:
              'Cofounder wants AI, native apps, and a marketplace in v1. '
              'You have 12 waitlist emails and no paid pilots.',
          xpReward: 40,
          options: const <CaseOption>[
            CaseOption(
              id: 'thin_mvp',
              label: 'Ship a concierge/manual MVP to 5 target users; measure willingness to pay',
              detail: 'Learn before building platform complexity.',
              coachTip: 'Correct — validate the job-to-be-done.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Build the full platform before talking to customers',
              detail: 'Feature maximalism.',
              coachTip: 'Burns runway on unvalidated scope.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Skip customer talks and launch ads to consumers instead',
              detail: 'Wrong segment.',
              coachTip: 'B2B problem needs B2B evidence.',
            ),
          ],
          correctOptionId: 'thin_mvp',
          criteria: const <String>[
            'Learning: Real user workflow tested quickly',
            'Burn: Scope matched to \$8k / 6 weeks',
            'Signal: Willingness-to-pay measured',
          ],
        ),
        _c(
          id: 'en_runway_crunch',
          majorId: 'entrepreneurship',
          title: 'Runway Crunch',
          difficulty: 'Medium',
          topics: const <String>['Cash flow', 'Fundraising', 'Prioritization'],
          prompt: 'Runway is 3.5 months. Burn is \$42k/month. MRR is \$9k.',
          scenario:
              'A seed term sheet is soft. Enterprise sales cycle is 5 months. '
              'Two contractors are noncritical.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'extend',
              label: 'Cut noncritical burn, push cash-collection, and parallelize bridge options',
              detail: 'Extend runway while fundraising.',
              coachTip: 'Correct — buy time and options.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Hire 4 enterprise AEs to force growth',
              detail: 'Increase burn into a long cycle.',
              coachTip: 'Deepens the runway hole.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore burn and wait for the soft term sheet',
              detail: 'Hope as strategy.',
              coachTip: 'Soft sheets are not cash.',
            ),
          ],
          correctOptionId: 'extend',
          criteria: const <String>[
            'Runway: Noncritical burn reduced',
            'Cash: Collections prioritized',
            'Options: Bridge/fundraising paths in parallel',
          ],
        ),
        _c(
          id: 'en_pricing_test',
          majorId: 'entrepreneurship',
          title: 'First Pricing Test',
          difficulty: 'Medium',
          topics: const <String>['Pricing', 'Experiments', 'Positioning'],
          prompt: 'Early users love the product but churn at renewal.',
          scenario:
              'You priced at \$19/mo to grow fast. Power users say it is "too cheap '
              'to take seriously." Support load is high.',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'value_tiers',
              label: 'Test value-based tiers; interview churned users; raise for power features',
              detail: 'Price to value segments.',
              coachTip: 'Correct — cheap can signal low value.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Cut price to \$5 to reduce churn',
              detail: 'Race to the bottom.',
              coachTip: 'Worsens unit economics and signal.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Add 40 features before touching price',
              detail: 'Feature sprint distraction.',
              coachTip: 'Churn root may be packaging/price.',
            ),
          ],
          correctOptionId: 'value_tiers',
          criteria: const <String>[
            'Insight: Churn interviews before big bets',
            'Packaging: Value tiers tested',
            'Signal: Price aligned with seriousness of use',
          ],
        ),
      ];

  // —— Marketing ——
  static List<CaseChallenge> _marketing() => <CaseChallenge>[
        _c(
          id: 'mk_sneaker_launch',
          majorId: 'marketing',
          title: 'Launch a Sneaker Brand',
          difficulty: 'Medium',
          topics: const <String>['Brand', 'Channels', 'Launch'],
          prompt: 'Choose the launch channel mix for a \$25k DTC sneaker debut.',
          scenario:
              'Audience is 18–28 urban creators. Organic waitlist is 1,200. '
              'Wholesale wants exclusivity that would delay DTC by a quarter.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'owned_first',
              label: 'Owned + creator seeding first; paid retargeting; delay wholesale',
              detail: 'Control brand and learn CAC before wholesale.',
              coachTip: 'Correct — protect brand learning early.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Spend entire budget on one Super Bowl-style blast',
              detail: 'Vanity reach.',
              coachTip: 'Unmeasurable and too broad for \$25k.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Give wholesale exclusivity and skip DTC data',
              detail: 'Outsource demand.',
              coachTip: 'Loses customer data and margin.',
            ),
          ],
          correctOptionId: 'owned_first',
          criteria: const <String>[
            'Brand control: Owned channels prioritized',
            'Learning: CAC/creative tested before scale',
            'Partners: Wholesale deferred until proof',
          ],
        ),
        _c(
          id: 'mk_cac_spike',
          majorId: 'marketing',
          title: 'CAC Spike Diagnosis',
          difficulty: 'Easy',
          topics: const <String>['Analytics', 'Paid media', 'Funnel'],
          prompt: 'Paid CAC jumped 70% week-over-week.',
          scenario:
              'Creative fatigue is visible. Landing page speed worsened after a '
              'promo banner. Attribution window also changed.',
          xpReward: 40,
          options: const <CaseOption>[
            CaseOption(
              id: 'funnel',
              label: 'Isolate creative, page speed, and attribution changes before scaling spend',
              detail: 'Diagnose funnel breaks.',
              coachTip: 'Correct — don\'t scale a broken funnel.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Triple budget to "average down" CAC',
              detail: 'Spend into the spike.',
              coachTip: 'Amplifies waste.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore metrics and trust brand vibes',
              detail: 'No measurement.',
              coachTip: 'Leaves the leak open.',
            ),
          ],
          correctOptionId: 'funnel',
          criteria: const <String>[
            'Diagnosis: Creative, UX, and attribution checked',
            'Spend: Scale paused until root cause clear',
            'Measurement: Comparable windows restored',
          ],
        ),
        _c(
          id: 'mk_positioning_clash',
          majorId: 'marketing',
          title: 'Positioning Clash',
          difficulty: 'Medium',
          topics: const <String>['Positioning', 'Messaging', 'Research'],
          prompt: 'Sales says "enterprise secure"; ads say "fun for teens."',
          scenario:
              'Win rates are low in both segments. Website hero tries to please '
              'everyone. Budget is fixed.',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'pick_icp',
              label: 'Pick one ICP from win/loss data; align message, proof, and channels',
              detail: 'Focus beats ambivalence.',
              coachTip: 'Correct — clarity compounds.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Run both messages on every channel forever',
              detail: 'Split personality.',
              coachTip: 'Confuses buyers and creatives.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Rewrite only the logo and hope perception shifts',
              detail: 'Cosmetic change.',
              coachTip: 'Positioning is not a logo swap.',
            ),
          ],
          correctOptionId: 'pick_icp',
          criteria: const <String>[
            'Focus: Single ICP selected from evidence',
            'Consistency: Message, proof, channels aligned',
            'Efficiency: Fixed budget concentrated',
          ],
        ),
      ];

  // —— Human Resource Management ——
  static List<CaseChallenge> _humanResourceManagement() => <CaseChallenge>[
        _c(
          id: 'hr_retention_crisis',
          majorId: 'human_resource_management',
          title: 'Employee Retention Crisis',
          difficulty: 'Medium',
          topics: const <String>['Retention', 'Engagement', 'Manager quality'],
          prompt: 'Voluntary turnover hit 28% in customer support.',
          scenario:
              'Exit interviews cite schedule chaos and weak coaching—not only pay. '
              'Competitor pay is ~8% higher.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'root_fix',
              label: 'Stabilize schedules, train managers, and target pay for critical roles',
              detail: 'Multi-cause retention plan.',
              coachTip: 'Correct — pay alone rarely fixes manager gaps.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Give everyone a 20% raise with no other changes',
              detail: 'Cash-only response.',
              coachTip: 'Expensive and may not stop chaos-driven exits.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore exits; hire faster to replace people',
              detail: 'Replace forever.',
              coachTip: 'Replacement cost compounds.',
            ),
          ],
          correctOptionId: 'root_fix',
          criteria: const <String>[
            'Drivers: Schedule and coaching addressed',
            'Comp: Targeted, not scattershot',
            'Managers: Capability investment included',
          ],
        ),
        _c(
          id: 'hr_bias_screen',
          majorId: 'human_resource_management',
          title: 'Screening Bias Flag',
          difficulty: 'Hard',
          topics: const <String>['Hiring', 'Fairness', 'Process'],
          prompt: 'A hiring panel keeps rejecting candidates from one university.',
          scenario:
              'Role is skills-based. Pass rates diverge sharply by school even when '
              'work-sample scores are similar.',
          xpReward: 60,
          options: const <CaseOption>[
            CaseOption(
              id: 'structured',
              label: 'Pause panel; audit rubrics; switch to structured work-sample weighting',
              detail: 'Reduce unstructured bias.',
              coachTip: 'Correct — structure beats vibes.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Quietly ban that university forever without review',
              detail: 'Opaque exclusion.',
              coachTip: 'Creates legal and fairness risk.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Trust "culture fit" comments and continue',
              detail: 'Status quo.',
              coachTip: 'Culture-fit can mask bias.',
            ),
          ],
          correctOptionId: 'structured',
          criteria: const <String>[
            'Fairness: Structured criteria prioritized',
            'Evidence: Work-sample scores weighted over pedigree',
            'Governance: Panel process audited',
          ],
        ),
        _c(
          id: 'hr_pip_decision',
          majorId: 'human_resource_management',
          title: 'PIP vs Role Misfit',
          difficulty: 'Medium',
          topics: const <String>['Performance', 'Coaching', 'Documentation'],
          prompt: 'A solid employee is missing targets after a tool migration.',
          scenario:
              'Prior reviews were strong. Training was incomplete. Manager wants '
              'an immediate PIP to "send a message."',
          xpReward: 50,
          options: const <CaseOption>[
            CaseOption(
              id: 'support_first',
              label: 'Document a short improvement plan with training support before formal PIP',
              detail: 'Enablement before punishment.',
              coachTip: 'Correct — distinguish misfit from capability gap.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Terminate same day for missing one sprint',
              detail: 'Zero process.',
              coachTip: 'Disproportionate and risky.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Say nothing and hope numbers recover',
              detail: 'No feedback.',
              coachTip: 'Leaves performance unmanaged.',
            ),
          ],
          correctOptionId: 'support_first',
          criteria: const <String>[
            'Context: Prior performance and training gap considered',
            'Support: Concrete enablement offered',
            'Documentation: Expectations clarified without premature PIP theater',
          ],
        ),
      ];

  // —— International Business ——
  static List<CaseChallenge> _internationalBusiness() => <CaseChallenge>[
        _c(
          id: 'ib_market_entry',
          majorId: 'international_business',
          title: 'Expand Into a New Country',
          difficulty: 'Medium',
          topics: const <String>['Market entry', 'Mode choice', 'Risk'],
          prompt: 'Choose an entry mode for a SaaS tool into Country X.',
          scenario:
              'Data residency rules are strict. Local competitors are strong on '
              'support. You lack in-country staff.',
          xpReward: 55,
          options: const <CaseOption>[
            CaseOption(
              id: 'partner',
              label: 'Local partner/reseller + compliance review before direct hire',
              detail: 'Speed with regulatory cover.',
              coachTip: 'Correct — learn locally before heavy CapEx.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Acquire the largest local competitor this week',
              detail: 'Instant scale bet.',
              coachTip: 'Too capital-heavy before product-market proof.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore residency rules and host everything abroad',
              detail: 'Compliance skip.',
              coachTip: 'Blocks enterprise deals and invites fines.',
            ),
          ],
          correctOptionId: 'partner',
          criteria: const <String>[
            'Compliance: Data residency reviewed before scale',
            'Mode: Partner path fits thin local presence',
            'Learning: Market knowledge gained before acquisition',
          ],
        ),
        _c(
          id: 'ib_fx_contract',
          majorId: 'international_business',
          title: 'FX Swing on a Contract',
          difficulty: 'Hard',
          topics: const <String>['Currency', 'Contracts', 'Hedging'],
          prompt: 'A 9-month supply contract is priced in a volatile foreign currency.',
          scenario:
              'Margins are thin. Treasury can hedge. Sales wants a simple USD quote '
              'to win the deal today.',
          xpReward: 60,
          options: const <CaseOption>[
            CaseOption(
              id: 'hedge',
              label: 'Price with FX clause or hedge; avoid naked multi-month FX risk',
              detail: 'Protect margin explicitly.',
              coachTip: 'Correct — don\'t donate FX volatility.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Absorb all FX risk silently to win the logo',
              detail: 'Hidden exposure.',
              coachTip: 'Can erase the deal\'s profit.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Ignore currency and revisit if rates move 30%',
              detail: 'Reactive only.',
              coachTip: 'Too late once margins are gone.',
            ),
          ],
          correctOptionId: 'hedge',
          criteria: const <String>[
            'Risk: FX exposure quantified',
            'Tool: Hedge or contractual adjustment chosen',
            'Margin: Deal economics protected',
          ],
        ),
        _c(
          id: 'ib_tariff_reroute',
          majorId: 'international_business',
          title: 'Tariff Reroute Decision',
          difficulty: 'Easy',
          topics: const <String>['Trade', 'Logistics', 'Landed cost'],
          prompt: 'A new tariff raises landed cost 12% on your top SKU.',
          scenario:
              'Alternate origin country has +3 weeks lead time but lower duty. '
              'Customers hate stockouts more than a small price rise.',
          xpReward: 45,
          options: const <CaseOption>[
            CaseOption(
              id: 'landed',
              label: 'Recalculate landed cost; dual-source; communicate price/lead trade-offs',
              detail: 'Optimize total cost-to-serve.',
              coachTip: 'Correct — duty is only one input.',
            ),
            CaseOption(
              id: 'panic',
              label: 'Exit the market immediately',
              detail: 'Overreaction.',
              coachTip: 'Skips mitigation options.',
            ),
            CaseOption(
              id: 'ignore',
              label: 'Keep old pricing and eat the 12% forever',
              detail: 'Silent margin loss.',
              coachTip: 'Unsustainable without a plan.',
            ),
          ],
          correctOptionId: 'landed',
          criteria: const <String>[
            'Analysis: Full landed cost recomputed',
            'Supply: Dual-source / origin options evaluated',
            'Customers: Service vs price trade-off communicated',
          ],
        ),
      ];
}
