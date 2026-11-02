/// Multiple-choice interview questions with deterministic correct answers.
class BizInterviewQ {
  const BizInterviewQ({
    required this.id,
    required this.majorId,
    required this.prompt,
    required this.options,
    required this.correctId,
    required this.tip,
  });

  final String id;
  final String majorId;
  final String prompt;
  final List<({String id, String label})> options;
  final String correctId;
  final String tip;
}

abstract final class BizInterviewCatalog {
  static List<BizInterviewQ>? _cache;

  static List<BizInterviewQ> all() {
    final List<BizInterviewQ>? existing = _cache;
    if (existing != null) return existing;
    _cache = <BizInterviewQ>[
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

  static List<BizInterviewQ> forMajor(String majorId) {
    return all()
        .where((BizInterviewQ q) => q.majorId == majorId)
        .toList(growable: false);
  }

  static BizInterviewQ _q({
    required String id,
    required String majorId,
    required String prompt,
    required List<({String id, String label})> options,
    required String correctId,
    required String tip,
  }) {
    return BizInterviewQ(
      id: id,
      majorId: majorId,
      prompt: prompt,
      options: options,
      correctId: correctId,
      tip: tip,
    );
  }

  static List<BizInterviewQ> _businessAdministration() => <BizInterviewQ>[
        _q(
          id: 'ba_q_prioritize',
          majorId: 'business_administration',
          prompt:
              'Three fires land at once: a VIP customer complaint, a payroll file '
              'error, and a missing slide for tomorrow\'s board deck. What first?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Finish the pretty board slides so leadership looks good'),
            (id: 'b', label: 'Fix payroll first — people get paid correctly, then triage VIP'),
            (id: 'c', label: 'Ignore all three and schedule a kickoff meeting next week'),
          ],
          correctId: 'b',
          tip: 'Protect irreversible employee harm (payroll) before optics.',
        ),
        _q(
          id: 'ba_q_kpi',
          majorId: 'business_administration',
          prompt: 'A team celebrates "emails sent" as their north-star KPI. Your take?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Keep it — activity always equals outcomes'),
            (id: 'b', label: 'Replace with outcome KPIs (conversion, retention, SLA)'),
            (id: 'c', label: 'Remove all metrics to reduce stress'),
          ],
          correctId: 'b',
          tip: 'Measure outcomes customers feel, not vanity activity.',
        ),
        _q(
          id: 'ba_q_tradeoff',
          majorId: 'business_administration',
          prompt:
              'Cutting a low-margin SKU frees capacity but upsets a loud retailer. Best frame?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Never cut anything a retailer likes'),
            (id: 'b', label: 'Quantify capacity/profit gain vs relationship risk; offer alternatives'),
            (id: 'c', label: 'Cut silently and hope they do not notice'),
          ],
          correctId: 'b',
          tip: 'Make the trade-off explicit and manage the stakeholder.',
        ),
        _q(
          id: 'ba_q_meeting',
          majorId: 'business_administration',
          prompt: 'A recurring meeting has no agenda and rarely decides anything. You…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Keep it forever for "visibility"'),
            (id: 'b', label: 'Add an owner, agenda, and decision log — or cancel it'),
            (id: 'c', label: 'Invite the entire company so it feels important'),
          ],
          correctId: 'b',
          tip: 'Meetings need owners and decisions, not audience size.',
        ),
      ];

  static List<BizInterviewQ> _accounting() => <BizInterviewQ>[
        _q(
          id: 'ac_q_recon',
          majorId: 'accounting',
          prompt: 'Book cash is \$12k above the bank. First step?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Plug the difference to miscellaneous expense'),
            (id: 'b', label: 'Rebuild the bank reconciliation for timing items and exceptions'),
            (id: 'c', label: 'Delete the bank feed and start over next quarter'),
          ],
          correctId: 'b',
          tip: 'Reconcile before you adjust — timing items are common.',
        ),
        _q(
          id: 'ac_q_revenue',
          majorId: 'accounting',
          prompt: 'Goods ship Dec 31 but control transfers Jan 2. When is revenue?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Dec 31 if sales needs the quota'),
            (id: 'b', label: 'When control transfers — likely January'),
            (id: 'c', label: 'Whenever the invoice is printed'),
          ],
          correctId: 'b',
          tip: 'Revenue follows control transfer, not shipping theater.',
        ),
        _q(
          id: 'ac_q_capex',
          majorId: 'accounting',
          prompt: 'Laptops (\$18k) and cables (\$2k) on one PO. Policy threshold \$1k.',
          options: <({String id, String label})>[
            (id: 'a', label: 'Capitalize everything because it is one PO'),
            (id: 'b', label: 'Capitalize laptops; expense cables'),
            (id: 'c', label: 'Expense everything to be "conservative"'),
          ],
          correctId: 'b',
          tip: 'Classify by asset nature and policy, not PO packaging.',
        ),
        _q(
          id: 'ac_q_control',
          majorId: 'accounting',
          prompt: 'The same person creates vendors and approves payments. Risk?',
          options: <({String id, String label})>[
            (id: 'a', label: 'No risk if they are trustworthy'),
            (id: 'b', label: 'Segregation-of-duties failure — split create vs approve'),
            (id: 'c', label: 'Only a problem for public companies'),
          ],
          correctId: 'b',
          tip: 'SoD reduces fraud opportunity regardless of company size.',
        ),
      ];

  static List<BizInterviewQ> _finance() => <BizInterviewQ>[
        _q(
          id: 'fi_q_wacc',
          majorId: 'finance',
          prompt: 'A riskier-than-average project has IRR slightly above firm WACC. Approve?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Yes — any IRR above WACC is an automatic yes'),
            (id: 'b', label: 'Compare to a risk-adjusted hurdle, not average WACC alone'),
            (id: 'c', label: 'Never use discount rates; go with gut'),
          ],
          correctId: 'b',
          tip: 'Match the hurdle to project risk.',
        ),
        _q(
          id: 'fi_q_diversify',
          majorId: 'finance',
          prompt: 'Moderate-risk client wants 100% meme stocks. You recommend…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Agree — concentration maximizes expected return narratives'),
            (id: 'b', label: 'Diversified core allocation aligned to risk and horizon'),
            (id: 'c', label: 'All cash until the client stops asking questions'),
          ],
          correctId: 'b',
          tip: 'Suitability beats hype.',
        ),
        _q(
          id: 'fi_q_liquidity',
          majorId: 'finance',
          prompt: 'A large receivable slips 45 days; payroll is in 10 days. Move?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Skip payroll to protect ratios'),
            (id: 'b', label: 'Bridge with revolver/collections; cut noncritical spend'),
            (id: 'c', label: 'Pay a special dividend to reassure markets'),
          ],
          correctId: 'b',
          tip: 'Liquidity first — payroll is non-negotiable.',
        ),
        _q(
          id: 'fi_q_npv',
          majorId: 'finance',
          prompt: 'Why prefer NPV over "payback period only"?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Payback ignores time value and cash after cutoff'),
            (id: 'b', label: 'NPV is always slower to calculate so it must be worse'),
            (id: 'c', label: 'Payback includes option value automatically'),
          ],
          correctId: 'a',
          tip: 'NPV discounts cash flows; payback is a rough liquidity screen.',
        ),
      ];

  static List<BizInterviewQ> _economics() => <BizInterviewQ>[
        _q(
          id: 'ec_q_ceiling',
          majorId: 'economics',
          prompt: 'A binding rent ceiling below equilibrium typically causes…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Surplus housing and falling waitlists'),
            (id: 'b', label: 'Shortage / non-price rationing'),
            (id: 'c', label: 'No change in quantity demanded'),
          ],
          correctId: 'b',
          tip: 'Price ceilings ration through shortage and queues.',
        ),
        _q(
          id: 'ec_q_inflation',
          majorId: 'economics',
          prompt: 'CPI jumps on energy while core is milder. Policy communication should…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Ignore all inflation forever'),
            (id: 'b', label: 'Separate volatile components; set a clear tightening path'),
            (id: 'c', label: 'Announce a random 300bp hike with no analysis'),
          ],
          correctId: 'b',
          tip: 'Diagnose composition; communicate a credible path.',
        ),
        _q(
          id: 'ec_q_incidence',
          majorId: 'economics',
          prompt: 'Who bears more of a tariff when import demand is inelastic?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Mostly domestic buyers via higher prices'),
            (id: 'b', label: 'Always 100% foreign exporters by law'),
            (id: 'c', label: 'Nobody — tariffs are free revenue'),
          ],
          correctId: 'a',
          tip: 'Inelastic demand → buyers absorb more incidence.',
        ),
        _q(
          id: 'ec_q_opp',
          majorId: 'economics',
          prompt: 'Opportunity cost of using a owned warehouse for a new line is…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Zero because the building is already paid for'),
            (id: 'b', label: 'The best alternative use / rent forgone'),
            (id: 'c', label: 'Only the electricity bill'),
          ],
          correctId: 'b',
          tip: 'Opportunity cost is the next-best forgone use.',
        ),
      ];

  static List<BizInterviewQ> _entrepreneurship() => <BizInterviewQ>[
        _q(
          id: 'en_q_mvp',
          majorId: 'entrepreneurship',
          prompt: 'Six weeks and \$8k to test a B2B idea. Best MVP approach?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Build AI + native apps + marketplace before talking to users'),
            (id: 'b', label: 'Concierge/manual MVP with target users; measure willingness to pay'),
            (id: 'c', label: 'Skip users and buy consumer ads'),
          ],
          correctId: 'b',
          tip: 'Learn the job-to-be-done before platform complexity.',
        ),
        _q(
          id: 'en_q_runway',
          majorId: 'entrepreneurship',
          prompt: '3.5 months runway, soft term sheet, long enterprise cycle. Do you…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Hire four AEs immediately'),
            (id: 'b', label: 'Cut noncritical burn and parallelize bridge options'),
            (id: 'c', label: 'Ignore burn because the term sheet feels promising'),
          ],
          correctId: 'b',
          tip: 'Soft paper is not cash — extend runway.',
        ),
        _q(
          id: 'en_q_price',
          majorId: 'entrepreneurship',
          prompt: 'Users love the product but churn; some say it is "too cheap." Next?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Cut price further'),
            (id: 'b', label: 'Interview churn; test value-based tiers'),
            (id: 'c', label: 'Add 40 features before touching packaging'),
          ],
          correctId: 'b',
          tip: 'Price and packaging are product decisions.',
        ),
        _q(
          id: 'en_q_pivot',
          majorId: 'entrepreneurship',
          prompt: 'When is a pivot justified?',
          options: <({String id, String label})>[
            (id: 'a', label: 'After one lukewarm tweet'),
            (id: 'b', label: 'When evidence shows the core hypothesis is false'),
            (id: 'c', label: 'Whenever a competitor launches something shiny'),
          ],
          correctId: 'b',
          tip: 'Pivot on disconfirming evidence, not vibes.',
        ),
      ];

  static List<BizInterviewQ> _marketing() => <BizInterviewQ>[
        _q(
          id: 'mk_q_cac',
          majorId: 'marketing',
          prompt: 'Paid CAC spikes 70% WoW. First move?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Triple budget to average it down'),
            (id: 'b', label: 'Diagnose creative, landing page, and attribution before scaling'),
            (id: 'c', label: 'Delete the analytics dashboard'),
          ],
          correctId: 'b',
          tip: 'Do not scale a broken funnel.',
        ),
        _q(
          id: 'mk_q_position',
          majorId: 'marketing',
          prompt: 'Ads say "fun for teens" while sales says "enterprise secure." Fix?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Keep both messages everywhere'),
            (id: 'b', label: 'Pick one ICP from win/loss data and align message/proof'),
            (id: 'c', label: 'Only change the logo colors'),
          ],
          correctId: 'b',
          tip: 'Positioning requires focus.',
        ),
        _q(
          id: 'mk_q_launch',
          majorId: 'marketing',
          prompt: '\$25k DTC sneaker launch — best early mix?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Owned + creator seeding, then paid retargeting'),
            (id: 'b', label: 'One unaffordable mass TV blast'),
            (id: 'c', label: 'Wholesale exclusivity that blocks DTC learning'),
          ],
          correctId: 'a',
          tip: 'Own the customer relationship early.',
        ),
        _q(
          id: 'mk_q_brand',
          majorId: 'marketing',
          prompt: 'What is a brand\'s job in a crowded category?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Be everything to everyone'),
            (id: 'b', label: 'Create distinctive, relevant meaning buyers can remember'),
            (id: 'c', label: 'Only discount harder than rivals'),
          ],
          correctId: 'b',
          tip: 'Memory and meaning beat generic noise.',
        ),
      ];

  static List<BizInterviewQ> _humanResourceManagement() => <BizInterviewQ>[
        _q(
          id: 'hr_q_retention',
          majorId: 'human_resource_management',
          prompt: 'Support turnover is 28%; exits cite chaos and weak coaching. Response?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Only raise pay 20% for everyone'),
            (id: 'b', label: 'Fix schedules, train managers, and target critical-role pay'),
            (id: 'c', label: 'Hire faster and ignore why people leave'),
          ],
          correctId: 'b',
          tip: 'Retention is multi-causal — managers matter.',
        ),
        _q(
          id: 'hr_q_bias',
          majorId: 'human_resource_management',
          prompt: 'Panel rejects one school despite similar work-sample scores. You…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Quietly ban that school'),
            (id: 'b', label: 'Audit rubrics and weight structured work samples'),
            (id: 'c', label: 'Lean harder into unstructured "culture fit"'),
          ],
          correctId: 'b',
          tip: 'Structure reduces pedigree bias.',
        ),
        _q(
          id: 'hr_q_pip',
          majorId: 'human_resource_management',
          prompt: 'Strong performer slips after a tool migration with thin training. Next?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Terminate same day'),
            (id: 'b', label: 'Short documented support plan before a formal PIP'),
            (id: 'c', label: 'Say nothing and hope'),
          ],
          correctId: 'b',
          tip: 'Enablement before punishment when context changed.',
        ),
        _q(
          id: 'hr_q_offer',
          majorId: 'human_resource_management',
          prompt: 'Two finalists are close; one needs a start-date accommodation. Best practice?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Ghost both and reopen the req'),
            (id: 'b', label: 'Evaluate role needs fairly; document criteria; communicate clearly'),
            (id: 'c', label: 'Pick randomly to avoid thinking'),
          ],
          correctId: 'b',
          tip: 'Transparent, job-related criteria beat opacity.',
        ),
      ];

  static List<BizInterviewQ> _internationalBusiness() => <BizInterviewQ>[
        _q(
          id: 'ib_q_entry',
          majorId: 'international_business',
          prompt: 'Enter a market with strict data residency and no local staff. Mode?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Ignore residency and host abroad'),
            (id: 'b', label: 'Local partner/reseller after compliance review'),
            (id: 'c', label: 'Acquire the largest competitor this week'),
          ],
          correctId: 'b',
          tip: 'Learn and comply before heavy capital bets.',
        ),
        _q(
          id: 'ib_q_fx',
          majorId: 'international_business',
          prompt: 'Thin-margin 9-month contract in a volatile currency. Protect how?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Absorb all FX risk silently'),
            (id: 'b', label: 'Hedge or add an FX clause'),
            (id: 'c', label: 'Revisit only after a 30% move'),
          ],
          correctId: 'b',
          tip: 'Price currency risk explicitly.',
        ),
        _q(
          id: 'ib_q_tariff',
          majorId: 'international_business',
          prompt: 'New tariff raises landed cost 12%. First analytical step?',
          options: <({String id, String label})>[
            (id: 'a', label: 'Exit the market immediately'),
            (id: 'b', label: 'Recalculate full landed cost and evaluate dual-source options'),
            (id: 'c', label: 'Keep old prices and eat the loss forever with no plan'),
          ],
          correctId: 'b',
          tip: 'Duty is one input in total cost-to-serve.',
        ),
        _q(
          id: 'ib_q_culture',
          majorId: 'international_business',
          prompt: 'A negotiation stalls because of differing decision norms. You…',
          options: <({String id, String label})>[
            (id: 'a', label: 'Force your home-country process and talk louder'),
            (id: 'b', label: 'Map decision makers, adapt cadence, keep terms clear'),
            (id: 'c', label: 'Walk away at the first cultural difference'),
          ],
          correctId: 'b',
          tip: 'Adapt process without blurring commercial terms.',
        ),
      ];
}
