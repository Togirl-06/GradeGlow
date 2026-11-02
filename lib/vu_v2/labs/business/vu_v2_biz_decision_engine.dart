import 'vu_v2_biz_company_state.dart';
import 'vu_v2_biz_department_catalog.dart';

/// Applies department choices to company KPIs with narrative feedback.
abstract final class VuV2BizDecisionEngine {
  static VuV2BizOutcome marketingLaunch({
    required String platform,
    required double budget,
    required String audience,
    required bool retentionBundle,
    String slogan = '',
  }) {
    double lift;
    String note;
    if (platform == 'TikTok') {
      lift = 0.31;
      note = 'Short-form creative hit your $audience segment hard.';
    } else if (platform == 'Instagram') {
      lift = 0.14;
      note = 'Visual storytelling lifted brand recall for $audience.';
    } else if (platform == 'Search') {
      lift = 0.18;
      note = 'Intent-driven search captured ready-to-buy customers.';
    } else if (platform == 'TV Ads') {
      lift = 0.05;
      note = 'Broad awareness rose, but conversion remained weak.';
    } else {
      lift = 0.09;
      note = 'Email nurtured existing leads with steady returns.';
    }
    final String cleanSlogan = slogan.trim();
    if (cleanSlogan.length >= 8) {
      lift += 0.02;
      note = '$note Slogan tested: "$cleanSlogan".';
    }
    final double spend = budget.clamp(1000, 80000);
    final bool adHeavy = spend >= 25000 && !retentionBundle;
    if (retentionBundle) {
      lift += 0.04;
      note = '$note Retention offer attached — loyalty buffer improved.';
    }
    final double revenueGain = monthlyLift(spend, lift);
    return VuV2BizOutcome(
      title: 'Campaign launched on $platform',
      department: 'marketing',
      brief:
          'You are allocating ${VuV2BizCompanyState.money(spend)} to $platform '
          'for $audience. Goal: growth without destroying CAC payback.',
      narrative:
          '$note Measured sales lift ≈ +${(lift * 100).round()}% after launch. '
          'You spent ${VuV2BizCompanyState.money(spend)}. '
          '${adHeavy ? 'This continues an acquisition-heavy pattern.' : 'Spend stayed disciplined.'}',
      debriefPrompt:
          'If CAC rose 18% next month, what would you cut first — creative tests, '
          'audience breadth, or channel mix?',
      tags: <String>[
        if (adHeavy) 'ad_heavy',
        if (retentionBundle) 'retention_focus',
        if (platform == 'Email') 'retention_focus',
      ],
      cashDelta: -spend,
      revenueDelta: revenueGain,
      expenseDelta: spend * 0.15,
      satisfactionDelta: lift * 0.08 + (retentionBundle ? 0.03 : 0),
      brandDelta: retentionBundle ? 0.03 : (adHeavy ? -0.02 : 0.01),
      marketShareDelta: lift * 0.02,
      valueDelta: revenueGain * 8,
      xpGain: 35,
      challenge: lift < 0.1
          ? 'Campaign underperformed. Revisit targeting and creative.'
          : 'Scale winners carefully without inflating CAC.',
    );
  }

  static double monthlyLift(double spend, double lift) {
    return (spend * lift * 0.55).clamp(500, 120000);
  }

  static VuV2BizOutcome financeEvent(String choice) {
    if (choice == 'repair') {
      return const VuV2BizOutcome(
        title: 'Machine repaired',
        department: 'finance',
        brief: 'Factory machine failed. Capex vs opex trade-off.',
        narrative:
            'You spent \$40,000 to repair. Production resumed quickly, '
            'but residual downtime risk remains.',
        debriefPrompt:
            'Did you buy time or kick the can? What preventive budget belongs on next quarter\'s P&L?',
        tags: <String>['cash_conservative'],
        cashDelta: -40000,
        expenseDelta: 2000,
        qualityDelta: -0.02,
        moraleDelta: 0.02,
        xpGain: 30,
        challenge: 'Schedule preventive maintenance to avoid repeats.',
      );
    }
    if (choice == 'replace') {
      return const VuV2BizOutcome(
        title: 'Equipment replaced',
        department: 'finance',
        brief: 'Replace broken machine with new capacity.',
        narrative:
            '\$80,000 capex bought reliability and capacity. Cash tighter now; '
            'throughput and quality should improve.',
        debriefPrompt:
            'How will this asset appear on your balance sheet vs a lease?',
        tags: <String>['quality_invest'],
        cashDelta: -80000,
        revenueDelta: 8000,
        qualityDelta: 0.06,
        valueDelta: 25000,
        xpGain: 40,
        award: 'Operations Investor',
      );
    }
    return const VuV2BizOutcome(
      title: 'Equipment leased',
      department: 'finance',
      brief: 'Lease equipment to preserve cash.',
      narrative:
          'Lease costs \$15,000/month. Lower upfront cash, higher ongoing burn.',
      debriefPrompt:
          'Lease keeps cash, but raises fixed burn. What runway do you need before signing?',
      tags: <String>['cash_conservative'],
      cashDelta: -15000,
      expenseDelta: 15000,
      xpGain: 28,
      challenge: 'Watch runway — lease payments compound each month.',
    );
  }

  static VuV2BizOutcome booksClosed(VuV2BizCompanyState s) {
    final double net = s.netIncome;
    return VuV2BizOutcome(
      title: 'Quarter books closed',
      department: 'finance',
      brief: 'You built this quarter\'s P&L and balance sheet yourself.',
      narrative:
          'Net income ${VuV2BizCompanyState.money(net)}. '
          'Equity ${VuV2BizCompanyState.money(s.equity)}. '
          'These are your numbers — Strategy and the Board will inherit them.',
      debriefPrompt:
          'Which line item is most fragile if revenue drops 15%?',
      tags: <String>['retention_focus'],
      advanceQuarter: true,
      syncBooks: false,
      xpGain: 40,
      challenge: net < 0
          ? 'Loss-making quarter on the books. Cut burn or raise revenue before expansion.'
          : 'Profitable quarter. Decide whether to reinvest or build cash.',
    );
  }

  static VuV2BizOutcome hrConflict(String choice) {
    if (choice == 'mediate') {
      return const VuV2BizOutcome(
        title: 'Conflict mediated',
        department: 'hr',
        brief: 'Two managers are in open conflict.',
        narrative:
            'Structured mediation restored trust. Morale recovered and retention risk fell.',
        debriefPrompt: 'What policy would prevent this conflict pattern next time?',
        tags: <String>['retention_focus'],
        moraleDelta: 0.08,
        reputationDelta: 0.03,
        satisfactionDelta: 0.02,
        xpGain: 40,
        award: 'Best Employer',
      );
    }
    if (choice == 'discipline') {
      return const VuV2BizOutcome(
        title: 'Disciplinary action taken',
        department: 'hr',
        brief: 'Enforce standards after a public conflict.',
        narrative:
            'Standards enforced. Some feel safer; others feel chilled.',
        debriefPrompt: 'When is discipline clarity vs when is it fear?',
        cashDelta: 0,
        moraleDelta: -0.03,
        reputationDelta: 0.01,
        xpGain: 25,
      );
    }
    return const VuV2BizOutcome(
      title: 'Conflict ignored',
      department: 'hr',
      brief: 'You chose not to intervene.',
      narrative:
          'Avoiding the issue saved time today but poisoned collaboration.',
      debriefPrompt: 'What early signal did you miss before it went public?',
      tags: <String>['quality_cut'],
      moraleDelta: -0.1,
      revenueDelta: -4000,
      reputationDelta: -0.04,
      qualityDelta: -0.03,
      xpGain: 10,
      challenge: 'Team friction is spilling into customer delivery.',
    );
  }

  static VuV2BizOutcome hireEmployee({required bool senior}) {
    if (senior) {
      return const VuV2BizOutcome(
        title: 'Senior hire onboarded',
        department: 'hr',
        brief: 'Hire senior talent to raise capability.',
        narrative:
            'Senior operator raised capability and wage costs.',
        debriefPrompt: 'What 90-day outcome proves this hire was worth it?',
        cashDelta: -12000,
        employeeDelta: 1,
        expenseDelta: 9000,
        moraleDelta: 0.04,
        revenueDelta: 6000,
        qualityDelta: 0.03,
        tags: <String>['quality_invest'],
        xpGain: 30,
      );
    }
    return const VuV2BizOutcome(
      title: 'Junior hire onboarded',
      department: 'hr',
      brief: 'Hire junior capacity.',
      narrative:
          'Fresh capacity at lower cost. Training load rises short term.',
      debriefPrompt: 'Who owns onboarding quality for this role?',
      cashDelta: -4000,
      employeeDelta: 1,
      expenseDelta: 3500,
      moraleDelta: 0.02,
      revenueDelta: 2000,
      xpGain: 20,
    );
  }

  static VuV2BizOutcome operationsShock(String choice) {
    if (choice == 'air_freight') {
      return const VuV2BizOutcome(
        title: 'Air freight authorized',
        department: 'operations',
        brief: 'Supplier delay threatens delivery SLAs.',
        narrative:
            'Expensive logistics protected SLAs. Margin compressed this month.',
        debriefPrompt: 'Was speed worth the margin — for which customer segment?',
        cashDelta: -22000,
        expenseDelta: 8000,
        satisfactionDelta: 0.05,
        reputationDelta: 0.02,
        xpGain: 32,
      );
    }
    if (choice == 'alternate_supplier') {
      return const VuV2BizOutcome(
        title: 'Alternate supplier locked',
        department: 'operations',
        brief: 'Diversify supply after a delay.',
        narrative:
            'Lead times recovered with a modest unit-cost increase.',
        debriefPrompt: 'How many single-source SKUs remain in your catalog?',
        tags: <String>['quality_invest'],
        cashDelta: -8000,
        expenseDelta: 3000,
        marketShareDelta: 0.005,
        qualityDelta: 0.02,
        xpGain: 35,
        award: 'Supply Chain Resilience',
      );
    }
    return const VuV2BizOutcome(
      title: 'Delay accepted',
      department: 'operations',
      brief: 'Accept supplier delay to save cash.',
      narrative:
          'You conserved cash but missed deliveries. Satisfaction and reputation took the hit.',
      debriefPrompt: 'Which customers will forgive a miss — and which will churn?',
      tags: <String>['cash_conservative', 'quality_cut'],
      satisfactionDelta: -0.08,
      reputationDelta: -0.06,
      revenueDelta: -12000,
      qualityDelta: -0.05,
      brandDelta: -0.04,
      xpGain: 12,
      challenge: 'Backorders are climbing. Customers are comparing rivals.',
    );
  }

  static VuV2BizOutcome skipQualityControl() {
    return const VuV2BizOutcome(
      title: 'Quality checks deferred',
      department: 'operations',
      brief: 'Skip QC this quarter to hit shipment targets.',
      narrative:
          'Shipments cleared faster. Defect risk is now compounding — '
          'ignore this twice and a recall crisis will earn itself.',
      debriefPrompt: 'What metric would have told you QC was already thin?',
      tags: <String>['quality_cut'],
      cashDelta: 5000,
      revenueDelta: 4000,
      qualityDelta: -0.12,
      brandDelta: -0.03,
      xpGain: 15,
      challenge: 'Quality debt is rising. Inspection backlog is growing.',
    );
  }

  static VuV2BizOutcome investQuality() {
    return const VuV2BizOutcome(
      title: 'Quality investment',
      department: 'operations',
      brief: 'Fund inspection and process fixes.',
      narrative:
          'You slowed shipments slightly and cut defect probability. '
          'Brand trust compounds quietly when quality holds.',
      debriefPrompt: 'How will you show ROI on quality spend to the Board?',
      tags: <String>['quality_invest'],
      cashDelta: -18000,
      expenseDelta: 4000,
      qualityDelta: 0.1,
      brandDelta: 0.04,
      satisfactionDelta: 0.03,
      xpGain: 35,
    );
  }

  static VuV2BizOutcome strategyExpand(bool enterAsia, {String justification = ''}) {
    final String why = justification.trim();
    final bool evidence = why.length >= 40 &&
        (why.toLowerCase().contains('margin') ||
            why.toLowerCase().contains('cash') ||
            why.toLowerCase().contains('risk') ||
            why.toLowerCase().contains('competitor') ||
            why.toLowerCase().contains('retention'));
    if (enterAsia) {
      return VuV2BizOutcome(
        title: 'Asia market entry approved',
        department: 'strategy',
        brief: 'Board-level question: enter Asia now?',
        narrative:
            'Capital committed to localization and partnerships. Near-term burn rises.'
            '${evidence ? ' Your written justification cited real constraints — directors noticed.' : ' Justification was thin — expect tougher questions next time.'}',
        debriefPrompt: 'What leading indicator tells you to pause country #2?',
        cashDelta: -75000,
        expenseDelta: 12000,
        marketShareDelta: 0.015,
        valueDelta: evidence ? 200000 : 140000,
        reputationDelta: evidence ? 0.03 : -0.01,
        xpGain: evidence ? 55 : 35,
        market: 'Japan',
        challenge: 'Prove unit economics in Asia before a second country.',
        award: evidence ? 'Global Operator' : null,
      );
    }
    return VuV2BizOutcome(
      title: 'Asia expansion deferred',
      department: 'strategy',
      brief: 'Defer Asia to protect focus and cash.',
      narrative:
          'You protected runway. Opportunity cost rises if rivals plant flags first.'
          '${evidence ? ' You defended the deferral with evidence — good CEO discipline.' : ''}',
      debriefPrompt: 'What milestone would flip you from defer to enter?',
      tags: const <String>['cash_conservative'],
      cashDelta: 5000,
      reputationDelta: evidence ? 0.01 : -0.01,
      xpGain: evidence ? 30 : 18,
      challenge: 'Core market defense while competitors explore Asia.',
    );
  }

  static VuV2BizOutcome analyticsHypothesis({
    required String driver,
    required String hypothesis,
    required VuV2BizCompanyState company,
  }) {
    final bool detailed = hypothesis.trim().length >= 40;
    final bool matchesBooks = (driver == 'marketing' &&
            company.styleAdHeavy >= company.styleRetentionFocus) ||
        (driver == 'operations' && company.qualityIndex < 0.7) ||
        (driver == 'competitor' &&
            company.currentChallenge.toLowerCase().contains('competitor')) ||
        (driver == 'finance' && company.cash < 120000);
    return VuV2BizOutcome(
      title: 'Root-cause analysis filed',
      department: 'analytics',
      brief: 'Investigate what moved revenue — using YOUR dashboard.',
      narrative: matchesBooks
          ? 'Your hypothesis ($driver) lines up with the company\'s fingerprint. '
              '${detailed ? 'Write-up was specific enough for an internship memo.' : 'Next time add more evidence.'}'
          : 'Interesting angle, but the books point elsewhere. Re-check quality, cash, and ad bias before briefing the board.',
      debriefPrompt:
          'Which single chart would you put on slide 1 for the Board?',
      tags: <String>[
        if (driver == 'marketing') 'ad_heavy',
        if (driver == 'operations') 'quality_invest',
      ],
      reputationDelta: matchesBooks ? 0.03 : -0.01,
      xpGain: matchesBooks ? (detailed ? 45 : 30) : 18,
      advanceQuarter: false,
    );
  }

  static VuV2BizOutcome negotiation({
    required String stance,
    required int messageCount,
    required bool mentionedUnitEconomics,
    required bool offeredConcession,
  }) {
    final int clarity = mentionedUnitEconomics ? 5 : 2;
    final int tone = stance == 'collaborative'
        ? 4
        : stance == 'assertive'
            ? 3
            : 4;
    final int concession = offeredConcession
        ? 4
        : stance == 'walk'
            ? 3
            : 2;
    final int preparation = messageCount >= 2 ? 4 : 2;
    final VuV2BizRubricScore rubric = VuV2BizRubricScore(
      criteria: <VuV2BizRubricCriterion>[
        VuV2BizRubricCriterion(
          label: 'Clarity of ask',
          score: clarity,
          maxScore: 5,
          note: mentionedUnitEconomics
              ? 'You anchored on economics, not vibes.'
              : 'Missing unit economics / payback language.',
        ),
        VuV2BizRubricCriterion(
          label: 'Tone & rapport',
          score: tone,
          maxScore: 5,
          note: stance == 'collaborative'
              ? 'Collaborative tone builds long-term optionality.'
              : stance == 'assertive'
                  ? 'Assertive can win terms; watch relationship cost.'
                  : 'Walk-away preserved credibility.',
        ),
        VuV2BizRubricCriterion(
          label: 'Concession strategy',
          score: concession,
          maxScore: 5,
          note: offeredConcession
              ? 'You traded a concession for something concrete.'
              : 'Little evidence of structured give/get.',
        ),
        VuV2BizRubricCriterion(
          label: 'Preparation',
          score: preparation,
          maxScore: 5,
          note: messageCount >= 2
              ? 'You engaged the counterpart across turns.'
              : 'Thin dialogue before closing.',
        ),
      ],
    );

    if (stance == 'assertive') {
      return VuV2BizOutcome(
        title: 'Assertive deal closed',
        department: 'negotiation',
        brief: 'Investor asks why they should put in \$2M.',
        narrative:
            'Favorable terms secured. Counterpart respects strength; next round may be harder.',
        debriefPrompt:
            'Which rubric line would you improve before the next fundraise?',
        tags: <String>['nego_assertive'],
        cashDelta: 200000,
        valueDelta: 150000,
        reputationDelta: 0.03,
        xpGain: 40 + rubric.total,
        award: rubric.total >= 14 ? 'Negotiation Master' : null,
        rubric: rubric,
      );
    }
    if (stance == 'collaborative') {
      return VuV2BizOutcome(
        title: 'Partnership formed',
        department: 'negotiation',
        brief: 'Investor asks why they should put in \$2M.',
        narrative:
            'Shared upside built trust. Terms balanced; relationship capital rose.',
        debriefPrompt:
            'What did you give — and what binding return did you secure?',
        tags: <String>['nego_collaborative', 'retention_focus'],
        cashDelta: 120000,
        revenueDelta: 10000,
        reputationDelta: 0.05,
        xpGain: 35 + rubric.total,
        rubric: rubric,
      );
    }
    return VuV2BizOutcome(
      title: 'Walk-away',
      department: 'negotiation',
      brief: 'Investor asks why they should put in \$2M.',
      narrative:
          'You declined a weak offer. No cash today; disciplined capital reputation rose.',
      debriefPrompt: 'What BATNA made walking rational?',
      tags: <String>['cash_conservative'],
      reputationDelta: 0.02,
      xpGain: 20 + rubric.total,
      challenge: 'Find a better-fit investor or partner this quarter.',
      rubric: rubric,
    );
  }

  static VuV2BizOutcome boardPresentation(String quality) {
    final VuV2BizRubricScore rubric = VuV2BizRubricScore(
      criteria: <VuV2BizRubricCriterion>[
        VuV2BizRubricCriterion(
          label: 'Financial understanding',
          score: quality == 'strong'
              ? 5
              : quality == 'mixed'
                  ? 3
                  : 1,
          maxScore: 5,
          note: 'Unit economics and risks must be explicit.',
        ),
        VuV2BizRubricCriterion(
          label: 'Logic & structure',
          score: quality == 'strong'
              ? 5
              : quality == 'mixed'
                  ? 3
                  : 2,
          maxScore: 5,
          note: 'Lead with evidence, then ask.',
        ),
        VuV2BizRubricCriterion(
          label: 'Confidence (calibrated)',
          score: quality == 'strong'
              ? 4
              : quality == 'mixed'
                  ? 3
                  : 2,
          maxScore: 5,
          note: 'Confidence without substance reads as risk.',
        ),
        VuV2BizRubricCriterion(
          label: 'Communication',
          score: quality == 'strong'
              ? 5
              : quality == 'mixed'
                  ? 3
                  : 1,
          maxScore: 5,
          note: 'Directors reward clarity over volume.',
        ),
      ],
    );
    if (quality == 'strong') {
      return VuV2BizOutcome(
        title: 'Board impressed',
        department: 'board',
        brief: 'Present quarterly results to the board.',
        narrative:
            'Clear metrics, honest risks, and a credible plan earned confidence.',
        debriefPrompt: 'Which risk did you name that most built trust?',
        valueDelta: 220000,
        reputationDelta: 0.06,
        xpGain: 40 + rubric.total,
        award: 'Boardroom Confidence',
        rubric: rubric,
      );
    }
    if (quality == 'mixed') {
      return VuV2BizOutcome(
        title: 'Board wants follow-ups',
        department: 'board',
        brief: 'Present quarterly results to the board.',
        narrative:
            'Numbers were fine; narrative was fuzzy. Tighter risk plan requested.',
        debriefPrompt: 'What one slide would have prevented the follow-up ask?',
        valueDelta: 40000,
        xpGain: 20 + rubric.total,
        challenge: 'Prepare a sharper risk memo for the next board session.',
        rubric: rubric,
      );
    }
    return VuV2BizOutcome(
      title: 'Board concerned',
      department: 'board',
      brief: 'Present quarterly results to the board.',
      narrative:
          'Hand-waving on unit economics raised red flags.',
      debriefPrompt: 'What number should you have led with?',
      reputationDelta: -0.05,
      valueDelta: -80000,
      xpGain: 10 + rubric.total,
      challenge: 'Rebuild trust with a transparent turnaround brief.',
      rubric: rubric,
    );
  }

  static VuV2BizOutcome crisisResponse(String choice) {
    if (choice == 'transparent') {
      return const VuV2BizOutcome(
        title: 'Transparent crisis response',
        department: 'crisis',
        brief: 'Unscheduled crisis — respond under pressure.',
        narrative:
            'You owned the issue publicly and moved fast. Short-term cost; faster trust recovery.',
        debriefPrompt: 'Which prior decision most likely caused this crisis?',
        tags: <String>['quality_invest', 'retention_focus'],
        cashDelta: -35000,
        reputationDelta: 0.07,
        satisfactionDelta: 0.05,
        qualityDelta: 0.04,
        brandDelta: 0.05,
        xpGain: 50,
        award: 'Crisis Commander',
        challenge: 'Monitor residual complaints for two weeks.',
      );
    }
    if (choice == 'discount') {
      return const VuV2BizOutcome(
        title: 'Discount blitz launched',
        department: 'crisis',
        brief: 'Unscheduled crisis — respond under pressure.',
        narrative:
            'Price cuts stemmed churn quickly but trained deal-seeking behavior.',
        debriefPrompt: 'What non-price remedy could have protected brand premium?',
        tags: <String>['ad_heavy'],
        cashDelta: -20000,
        revenueDelta: 5000,
        expenseDelta: 6000,
        satisfactionDelta: 0.03,
        reputationDelta: -0.02,
        brandDelta: -0.04,
        xpGain: 28,
      );
    }
    return const VuV2BizOutcome(
      title: 'Deny and delay',
      department: 'crisis',
      brief: 'Unscheduled crisis — respond under pressure.',
      narrative:
          'Silence amplified the story. Competitors captured frustrated buyers.',
      debriefPrompt: 'Why does denial usually compound brand damage?',
      tags: <String>['quality_cut'],
      revenueDelta: -18000,
      reputationDelta: -0.12,
      satisfactionDelta: -0.1,
      brandDelta: -0.1,
      valueDelta: -200000,
      xpGain: 8,
      challenge: 'Viral backlash continues — rebuild with proof, not PR.',
    );
  }

  static VuV2BizOutcome expandMarket(String region) {
    return VuV2BizOutcome(
      title: 'Expanded into $region',
      department: 'expansion',
      brief: 'Open a beachhead market.',
      narrative:
          'Beachhead in $region opened. Setup costs hit cash; local execution decides ROI.',
      debriefPrompt: 'What is the kill-criterion if month-3 CAC is 2x plan?',
      cashDelta: -45000,
      expenseDelta: 7000,
      marketShareDelta: 0.01,
      valueDelta: 90000,
      xpGain: 40,
      market: region,
      award: region == 'Germany' ? 'European Beachhead' : null,
    );
  }

  static String mentorAdvice(VuV2BizCompanyState s) {
    final String style = s.decisionStyleSummary;
    if (s.crisisInterruptActive && s.pendingCrisis != null) {
      return 'Interrupt: ${s.pendingCrisis} This was earned by prior choices — not random. $style';
    }
    if (s.consecutiveQualityNeglect >= 1) {
      return 'Pattern alert: quality neglect is stacking. One more deferral can trigger a defect crisis. $style';
    }
    if (s.styleAdHeavy >= s.styleRetentionFocus + 2) {
      return 'You tend to over-invest in ad spend and under-invest in retention — '
          'last quarters bought attention without enough loyalty buffer. '
          'What cheaper retention move could replace 20% of acquisition? $style';
    }
    if (s.cash < 80000) {
      return 'Cash is tight. Prioritize runway. $style';
    }
    if (s.morale < 0.55) {
      return 'Morale is slipping. Visit HR before productivity taxes compound. $style';
    }
    if (s.satisfaction < 0.7) {
      return 'Satisfaction is soft. Check Operations SLAs and Marketing promises. $style';
    }
    if (s.currentChallenge.toLowerCase().contains('competitor')) {
      return 'A cheaper rival is pressuring share. Differentiate, match carefully, or niche upmarket. $style';
    }
    return 'Loop reminder: Brief → Decide → Consequence → Debrief → Next challenge. $style';
  }

  static String nextChallengeHint(VuV2BizCompanyState s) {
    if (s.crisisInterruptActive) {
      return 'Open Crisis Center — this interrupt will not wait.';
    }
    if (s.qualityIndex < 0.55) {
      return 'Operations: invest in quality before the defect crisis fires.';
    }
    if (s.styleAdHeavy > s.styleRetentionFocus) {
      return 'Marketing: run a retention-bundled campaign to rebalance your pattern.';
    }
    if (s.cash < 100000) {
      return 'Finance: close the books and stress-test runway.';
    }
    if (s.morale < 0.6) {
      return 'HR: morale is soft — mediate before productivity slips.';
    }
    if (s.decisionLog.isEmpty) {
      return 'Start in Marketing or Negotiation — make your first CEO decision.';
    }
    return 'Strategy or Board: pressure-test your plan with evidence from your books.';
  }

  /// Smart "Continue simulation" target — never blindly dumps into Crisis unless earned.
  static VuV2BizRoomId nextRecommendedRoom(VuV2BizCompanyState s) {
    if (s.crisisInterruptActive) {
      return VuV2BizRoomId.crisis;
    }
    if (s.qualityIndex < 0.55 || s.consecutiveQualityNeglect >= 1) {
      return VuV2BizRoomId.operations;
    }
    if (s.cash < 100000 || s.monthlyExpenses > s.monthlyRevenue) {
      return VuV2BizRoomId.finance;
    }
    if (s.morale < 0.6) {
      return VuV2BizRoomId.hr;
    }
    if (s.styleAdHeavy > s.styleRetentionFocus + 1) {
      return VuV2BizRoomId.marketing;
    }
    if (s.decisionLog.isEmpty) {
      return VuV2BizRoomId.marketing;
    }
    if (s.decisionLog.length >= 3 && s.decisionLog.length % 4 == 0) {
      return VuV2BizRoomId.board;
    }
    return VuV2BizRoomId.strategy;
  }
}
