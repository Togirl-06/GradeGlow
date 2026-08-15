import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent simulated company — one balance sheet across the degree.
class VuV2BizCompanyState extends ChangeNotifier {
  VuV2BizCompanyState();

  static const String _prefsKey = 'vu_v2_biz_company_state_v2';

  String companyName = 'Nova Technologies';
  String industry = 'Technology';
  String ceoName = 'CEO';
  int foundedYear = 2026;
  double cash = 350000;
  double monthlyRevenue = 95000;
  double monthlyExpenses = 72000;
  int employees = 43;
  double satisfaction = 0.91;
  double reputation = 0.88;
  double companyValue = 4200000;
  double morale = 0.78;
  double marketShare = 0.12;

  /// Product / process quality — underinvestment compounds into earned crises.
  double qualityIndex = 0.82;

  /// Brand health separate from short-term satisfaction.
  double brandStrength = 0.8;

  int ceoLevel = 1;
  int xp = 0;
  int quarterIndex = 4;
  String currentChallenge =
      'Competitor launched a cheaper product in your core market.';
  String? pendingCrisis;
  bool crisisInterruptActive = false;

  List<String> markets = <String>['USA', 'Canada'];
  List<String> awards = <String>[];
  List<VuV2BizHistoryPoint> history = <VuV2BizHistoryPoint>[
    VuV2BizHistoryPoint(label: 'Q1', revenue: 78000, profit: 12000),
    VuV2BizHistoryPoint(label: 'Q2', revenue: 86000, profit: 16000),
    VuV2BizHistoryPoint(label: 'Q3', revenue: 91000, profit: 18000),
    VuV2BizHistoryPoint(label: 'Q4', revenue: 95000, profit: 23000),
  ];
  List<VuV2BizDecisionRecord> decisionLog = <VuV2BizDecisionRecord>[];

  /// Student-produced P&L / balance sheet (Finance room).
  double pnlRevenue = 95000;
  double pnlCogs = 28000;
  double pnlPayroll = 32000;
  double pnlMarketing = 12000;
  double pnlRent = 8000;
  double pnlOther = 4000;
  double bsCash = 350000;
  double bsReceivables = 42000;
  double bsInventory = 18000;
  double bsEquipment = 220000;
  double bsPayables = 35000;
  double bsDebt = 80000;

  /// Decision-style memory (not just company KPIs).
  int styleAdHeavy = 0;
  int styleRetentionFocus = 0;
  int styleQualityCut = 0;
  int styleCashConservative = 0;
  int styleAssertiveNego = 0;
  int styleCollaborativeNego = 0;
  int consecutiveQualityNeglect = 0;
  int consecutiveAdHeavy = 0;

  bool booksLockedByStudent = false;
  bool dayOneComplete = false;
  bool loaded = false;

  double get grossProfit => pnlRevenue - pnlCogs;
  double get operatingExpenses =>
      pnlPayroll + pnlMarketing + pnlRent + pnlOther;
  double get netIncome => grossProfit - operatingExpenses;
  double get totalAssets => bsCash + bsReceivables + bsInventory + bsEquipment;
  double get totalLiabilities => bsPayables + bsDebt;
  double get equity => totalAssets - totalLiabilities;

  double get profitMargin {
    if (monthlyRevenue <= 0) {
      return 0;
    }
    return ((monthlyRevenue - monthlyExpenses) / monthlyRevenue).clamp(-1.0, 1.0);
  }

  String get decisionStyleSummary {
    final List<String> parts = <String>[];
    if (styleAdHeavy >= styleRetentionFocus + 2) {
      parts.add('You tend to over-invest in acquisition vs retention');
    } else if (styleRetentionFocus >= styleAdHeavy + 2) {
      parts.add('You favor retention and relationship capital');
    }
    if (styleQualityCut >= 2) {
      parts.add('you have under-invested in quality more than once');
    }
    if (styleCashConservative >= 3) {
      parts.add('you prefer preserving cash even when growth is available');
    }
    if (styleAssertiveNego > styleCollaborativeNego + 1) {
      parts.add('your negotiation style leans assertive');
    } else if (styleCollaborativeNego > styleAssertiveNego + 1) {
      parts.add('your negotiation style leans collaborative');
    }
    if (parts.isEmpty) {
      return 'Still learning your pattern — keep deciding; I will coach the habits, not just the KPIs.';
    }
    return '${parts.join('; ')}.';
  }

  Future<void> ensureLoaded({String? displayName}) async {
    if (loaded) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_prefsKey);
    raw ??= prefs.getString('vu_v2_biz_company_state_v1');
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _applyMap(decoded);
        } else if (decoded is Map) {
          _applyMap(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }
    if (displayName != null &&
        displayName.trim().isNotEmpty &&
        displayName != 'Student') {
      ceoName = displayName.trim();
    }
    _syncBooksFromOps();
    loaded = true;
    notifyListeners();
  }

  void _syncBooksFromOps() {
    pnlRevenue = monthlyRevenue;
    bsCash = cash;
    final double opex = monthlyExpenses;
    pnlPayroll = opex * 0.44;
    pnlMarketing = opex * 0.18;
    pnlRent = opex * 0.11;
    pnlOther = opex * 0.08;
    pnlCogs = (opex * 0.19).clamp(0, monthlyRevenue * 0.6);
  }

  void _applyMap(Map<String, dynamic> data) {
    companyName = data['companyName'] as String? ?? companyName;
    industry = data['industry'] as String? ?? industry;
    ceoName = data['ceoName'] as String? ?? ceoName;
    foundedYear = data['foundedYear'] as int? ?? foundedYear;
    cash = (data['cash'] as num?)?.toDouble() ?? cash;
    monthlyRevenue =
        (data['monthlyRevenue'] as num?)?.toDouble() ?? monthlyRevenue;
    monthlyExpenses =
        (data['monthlyExpenses'] as num?)?.toDouble() ?? monthlyExpenses;
    employees = data['employees'] as int? ?? employees;
    satisfaction = (data['satisfaction'] as num?)?.toDouble() ?? satisfaction;
    reputation = (data['reputation'] as num?)?.toDouble() ?? reputation;
    companyValue = (data['companyValue'] as num?)?.toDouble() ?? companyValue;
    morale = (data['morale'] as num?)?.toDouble() ?? morale;
    marketShare = (data['marketShare'] as num?)?.toDouble() ?? marketShare;
    qualityIndex = (data['qualityIndex'] as num?)?.toDouble() ?? qualityIndex;
    brandStrength =
        (data['brandStrength'] as num?)?.toDouble() ?? brandStrength;
    ceoLevel = data['ceoLevel'] as int? ?? ceoLevel;
    xp = data['xp'] as int? ?? xp;
    quarterIndex = data['quarterIndex'] as int? ?? quarterIndex;
    currentChallenge =
        data['currentChallenge'] as String? ?? currentChallenge;
    pendingCrisis = data['pendingCrisis'] as String?;
    crisisInterruptActive = data['crisisInterruptActive'] as bool? ?? false;
    styleAdHeavy = data['styleAdHeavy'] as int? ?? 0;
    styleRetentionFocus = data['styleRetentionFocus'] as int? ?? 0;
    styleQualityCut = data['styleQualityCut'] as int? ?? 0;
    styleCashConservative = data['styleCashConservative'] as int? ?? 0;
    styleAssertiveNego = data['styleAssertiveNego'] as int? ?? 0;
    styleCollaborativeNego = data['styleCollaborativeNego'] as int? ?? 0;
    consecutiveQualityNeglect =
        data['consecutiveQualityNeglect'] as int? ?? 0;
    consecutiveAdHeavy = data['consecutiveAdHeavy'] as int? ?? 0;
    booksLockedByStudent = data['booksLockedByStudent'] as bool? ?? false;
    dayOneComplete = data['dayOneComplete'] as bool? ?? false;
    pnlRevenue = (data['pnlRevenue'] as num?)?.toDouble() ?? pnlRevenue;
    pnlCogs = (data['pnlCogs'] as num?)?.toDouble() ?? pnlCogs;
    pnlPayroll = (data['pnlPayroll'] as num?)?.toDouble() ?? pnlPayroll;
    pnlMarketing = (data['pnlMarketing'] as num?)?.toDouble() ?? pnlMarketing;
    pnlRent = (data['pnlRent'] as num?)?.toDouble() ?? pnlRent;
    pnlOther = (data['pnlOther'] as num?)?.toDouble() ?? pnlOther;
    bsCash = (data['bsCash'] as num?)?.toDouble() ?? bsCash;
    bsReceivables =
        (data['bsReceivables'] as num?)?.toDouble() ?? bsReceivables;
    bsInventory = (data['bsInventory'] as num?)?.toDouble() ?? bsInventory;
    bsEquipment = (data['bsEquipment'] as num?)?.toDouble() ?? bsEquipment;
    bsPayables = (data['bsPayables'] as num?)?.toDouble() ?? bsPayables;
    bsDebt = (data['bsDebt'] as num?)?.toDouble() ?? bsDebt;
    final Object? marketsRaw = data['markets'];
    if (marketsRaw is List) {
      markets = marketsRaw.map((Object? e) => '$e').toList();
    }
    final Object? awardsRaw = data['awards'];
    if (awardsRaw is List) {
      awards = awardsRaw.map((Object? e) => '$e').toList();
    }
    final Object? historyRaw = data['history'];
    if (historyRaw is List) {
      final List<VuV2BizHistoryPoint> points = <VuV2BizHistoryPoint>[];
      for (final Object? item in historyRaw) {
        if (item is Map) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(item);
          points.add(
            VuV2BizHistoryPoint(
              label: m['label'] as String? ?? 'Q',
              revenue: (m['revenue'] as num?)?.toDouble() ?? 0,
              profit: (m['profit'] as num?)?.toDouble() ?? 0,
            ),
          );
        }
      }
      if (points.isNotEmpty) {
        history = points;
      }
    }
    final Object? logRaw = data['decisionLog'];
    if (logRaw is List) {
      final List<VuV2BizDecisionRecord> logs = <VuV2BizDecisionRecord>[];
      for (final Object? item in logRaw) {
        if (item is Map) {
          final Map<String, dynamic> m = Map<String, dynamic>.from(item);
          logs.add(
            VuV2BizDecisionRecord(
              department: m['department'] as String? ?? 'ops',
              title: m['title'] as String? ?? '',
              tags: ((m['tags'] as List?) ?? <dynamic>[])
                  .map((Object? e) => '$e')
                  .toList(),
              quarter: m['quarter'] as int? ?? quarterIndex,
            ),
          );
        }
      }
      decisionLog = logs;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'companyName': companyName,
      'industry': industry,
      'ceoName': ceoName,
      'foundedYear': foundedYear,
      'cash': cash,
      'monthlyRevenue': monthlyRevenue,
      'monthlyExpenses': monthlyExpenses,
      'employees': employees,
      'satisfaction': satisfaction,
      'reputation': reputation,
      'companyValue': companyValue,
      'morale': morale,
      'marketShare': marketShare,
      'qualityIndex': qualityIndex,
      'brandStrength': brandStrength,
      'ceoLevel': ceoLevel,
      'xp': xp,
      'quarterIndex': quarterIndex,
      'currentChallenge': currentChallenge,
      'pendingCrisis': pendingCrisis,
      'crisisInterruptActive': crisisInterruptActive,
      'markets': markets,
      'awards': awards,
      'styleAdHeavy': styleAdHeavy,
      'styleRetentionFocus': styleRetentionFocus,
      'styleQualityCut': styleQualityCut,
      'styleCashConservative': styleCashConservative,
      'styleAssertiveNego': styleAssertiveNego,
      'styleCollaborativeNego': styleCollaborativeNego,
      'consecutiveQualityNeglect': consecutiveQualityNeglect,
      'consecutiveAdHeavy': consecutiveAdHeavy,
      'booksLockedByStudent': booksLockedByStudent,
      'dayOneComplete': dayOneComplete,
      'pnlRevenue': pnlRevenue,
      'pnlCogs': pnlCogs,
      'pnlPayroll': pnlPayroll,
      'pnlMarketing': pnlMarketing,
      'pnlRent': pnlRent,
      'pnlOther': pnlOther,
      'bsCash': bsCash,
      'bsReceivables': bsReceivables,
      'bsInventory': bsInventory,
      'bsEquipment': bsEquipment,
      'bsPayables': bsPayables,
      'bsDebt': bsDebt,
      'history': history
          .map(
            (VuV2BizHistoryPoint h) => <String, dynamic>{
              'label': h.label,
              'revenue': h.revenue,
              'profit': h.profit,
            },
          )
          .toList(),
      'decisionLog': decisionLog
          .map(
            (VuV2BizDecisionRecord d) => <String, dynamic>{
              'department': d.department,
              'title': d.title,
              'tags': d.tags,
              'quarter': d.quarter,
            },
          )
          .toList(),
    };
  }

  Future<void> save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toMap()));
    notifyListeners();
  }

  Future<void> applyOutcome(VuV2BizOutcome outcome) async {
    cash += outcome.cashDelta;
    monthlyRevenue += outcome.revenueDelta;
    monthlyExpenses += outcome.expenseDelta;
    employees += outcome.employeeDelta;
    satisfaction =
        (satisfaction + outcome.satisfactionDelta).clamp(0.0, 1.0);
    reputation = (reputation + outcome.reputationDelta).clamp(0.0, 1.0);
    morale = (morale + outcome.moraleDelta).clamp(0.0, 1.0);
    marketShare = (marketShare + outcome.marketShareDelta).clamp(0.0, 1.0);
    companyValue += outcome.valueDelta;
    qualityIndex =
        (qualityIndex + outcome.qualityDelta).clamp(0.05, 1.0);
    brandStrength =
        (brandStrength + outcome.brandDelta).clamp(0.05, 1.0);

    _applyStyleTags(outcome.tags);

    if (outcome.challenge != null && outcome.challenge!.isNotEmpty) {
      currentChallenge = outcome.challenge!;
    }
    if (outcome.award != null &&
        outcome.award!.isNotEmpty &&
        !awards.contains(outcome.award)) {
      awards.add(outcome.award!);
    }
    if (outcome.market != null &&
        outcome.market!.isNotEmpty &&
        !markets.contains(outcome.market)) {
      markets.add(outcome.market!);
    }

    decisionLog = <VuV2BizDecisionRecord>[
      VuV2BizDecisionRecord(
        department: outcome.department,
        title: outcome.title,
        tags: outcome.tags,
        quarter: quarterIndex,
      ),
      ...decisionLog,
    ];
    if (decisionLog.length > 24) {
      decisionLog = decisionLog.sublist(0, 24);
    }

    _evaluateEarnedCrisis(outcome);

    xp += outcome.xpGain;
    while (xp >= ceoLevel * 100) {
      xp -= ceoLevel * 100;
      ceoLevel += 1;
    }

    if (outcome.advanceQuarter) {
      quarterIndex += 1;
      _pushHistory();
    }

    // Never wipe student-built books after they closed the quarter.
    if (!booksLockedByStudent) {
      _syncBooksFromOps();
      if (outcome.syncBooks) {
        pnlMarketing = (pnlMarketing + outcome.cashDelta.abs() * 0.1)
            .clamp(0, monthlyRevenue);
        bsCash = cash;
      }
    } else {
      bsCash = cash;
    }

    await save();
  }

  void _applyStyleTags(List<String> tags) {
    for (int i = 0; i < tags.length; i++) {
      final String t = tags[i];
      if (t == 'ad_heavy') {
        styleAdHeavy += 1;
        consecutiveAdHeavy += 1;
      } else if (t == 'retention_focus') {
        styleRetentionFocus += 1;
        consecutiveAdHeavy = 0;
      } else if (t == 'quality_cut') {
        styleQualityCut += 1;
        consecutiveQualityNeglect += 1;
      } else if (t == 'quality_invest') {
        consecutiveQualityNeglect = 0;
      } else if (t == 'cash_conservative') {
        styleCashConservative += 1;
      } else if (t == 'nego_assertive') {
        styleAssertiveNego += 1;
      } else if (t == 'nego_collaborative') {
        styleCollaborativeNego += 1;
      }
    }
    if (!tags.contains('ad_heavy')) {
      // decay streak slowly when not advertising heavily
    }
    if (!tags.contains('quality_cut') && tags.contains('quality_invest')) {
      consecutiveQualityNeglect = 0;
    }
  }

  void _evaluateEarnedCrisis(VuV2BizOutcome outcome) {
    if (pendingCrisis != null && pendingCrisis!.isNotEmpty) {
      return;
    }
    if (consecutiveQualityNeglect >= 2 || qualityIndex < 0.45) {
      pendingCrisis =
          'Product defect reports are spiking. Quality underinvestment caught up.';
      crisisInterruptActive = true;
      currentChallenge = pendingCrisis!;
      return;
    }
    if (consecutiveAdHeavy >= 3 && brandStrength < satisfaction) {
      pendingCrisis =
          'Brand fatigue: acquisition is up but loyalty is slipping. Churn crisis.';
      crisisInterruptActive = true;
      currentChallenge = pendingCrisis!;
      return;
    }
    if (cash < 60000 && monthlyExpenses > monthlyRevenue) {
      pendingCrisis =
          'Cash crunch: runway under 60 days. Creditors are calling.';
      crisisInterruptActive = true;
      currentChallenge = pendingCrisis!;
      return;
    }
    if (outcome.forceCrisis != null) {
      pendingCrisis = outcome.forceCrisis;
      crisisInterruptActive = true;
      currentChallenge = pendingCrisis!;
    }
  }

  Future<void> clearCrisisFlag() async {
    crisisInterruptActive = false;
    pendingCrisis = null;
    await save();
  }

  Future<void> commitStudentBooks({
    required double revenue,
    required double cogs,
    required double payroll,
    required double marketing,
    required double rent,
    required double other,
    required double receivables,
    required double inventory,
    required double equipment,
    required double payables,
    required double debt,
  }) async {
    pnlRevenue = revenue;
    pnlCogs = cogs;
    pnlPayroll = payroll;
    pnlMarketing = marketing;
    pnlRent = rent;
    pnlOther = other;
    bsReceivables = receivables;
    bsInventory = inventory;
    bsEquipment = equipment;
    bsPayables = payables;
    bsDebt = debt;
    bsCash = cash;
    monthlyRevenue = revenue;
    monthlyExpenses = payroll + marketing + rent + other + cogs * 0.15;
    booksLockedByStudent = true;
    await save();
  }

  Future<void> completeDayOne() async {
    dayOneComplete = true;
    await save();
  }

  void _pushHistory() {
    history = <VuV2BizHistoryPoint>[
      ...history,
      VuV2BizHistoryPoint(
        label: 'Q$quarterIndex',
        revenue: monthlyRevenue,
        profit: monthlyRevenue - monthlyExpenses,
      ),
    ];
    if (history.length > 12) {
      history = history.sublist(history.length - 12);
    }
  }

  Future<void> resetStartup({
    required String name,
    required String industryLabel,
  }) async {
    companyName = name.trim().isEmpty ? 'Nova Technologies' : name.trim();
    industry = industryLabel;
    cash = 120000;
    monthlyRevenue = 0;
    monthlyExpenses = 18000;
    employees = 3;
    satisfaction = 0.7;
    reputation = 0.55;
    companyValue = 250000;
    morale = 0.8;
    marketShare = 0.01;
    qualityIndex = 0.75;
    brandStrength = 0.6;
    markets = <String>['USA'];
    currentChallenge = 'Launch your first product and find product-market fit.';
    pendingCrisis = null;
    crisisInterruptActive = false;
    quarterIndex = 0;
    consecutiveQualityNeglect = 0;
    consecutiveAdHeavy = 0;
    booksLockedByStudent = false;
    history = <VuV2BizHistoryPoint>[
      VuV2BizHistoryPoint(label: 'Seed', revenue: 0, profit: -18000),
    ];
    decisionLog = <VuV2BizDecisionRecord>[];
    _syncBooksFromOps();
    await save();
  }

  static String money(double v) {
    final bool neg = v < 0;
    final double abs = v.abs();
    String body;
    if (abs >= 1000000) {
      body = '\$${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      body = '\$${(abs / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}K';
    } else {
      body = '\$${abs.toStringAsFixed(0)}';
    }
    return neg ? '-$body' : body;
  }

  static String pct(double v) => '${(v * 100).round()}%';
}

class VuV2BizHistoryPoint {
  const VuV2BizHistoryPoint({
    required this.label,
    required this.revenue,
    required this.profit,
  });

  final String label;
  final double revenue;
  final double profit;
}

class VuV2BizDecisionRecord {
  const VuV2BizDecisionRecord({
    required this.department,
    required this.title,
    required this.tags,
    required this.quarter,
  });

  final String department;
  final String title;
  final List<String> tags;
  final int quarter;
}

class VuV2BizOutcome {
  const VuV2BizOutcome({
    required this.title,
    required this.narrative,
    this.department = 'general',
    this.brief = '',
    this.debriefPrompt = '',
    this.tags = const <String>[],
    this.cashDelta = 0,
    this.revenueDelta = 0,
    this.expenseDelta = 0,
    this.employeeDelta = 0,
    this.satisfactionDelta = 0,
    this.reputationDelta = 0,
    this.moraleDelta = 0,
    this.marketShareDelta = 0,
    this.valueDelta = 0,
    this.qualityDelta = 0,
    this.brandDelta = 0,
    this.xpGain = 25,
    this.challenge,
    this.award,
    this.market,
    this.forceCrisis,
    this.advanceQuarter = true,
    this.syncBooks = true,
    this.rubric,
  });

  final String title;
  final String narrative;
  final String department;
  final String brief;
  final String debriefPrompt;
  final List<String> tags;
  final double cashDelta;
  final double revenueDelta;
  final double expenseDelta;
  final int employeeDelta;
  final double satisfactionDelta;
  final double reputationDelta;
  final double moraleDelta;
  final double marketShareDelta;
  final double valueDelta;
  final double qualityDelta;
  final double brandDelta;
  final int xpGain;
  final String? challenge;
  final String? award;
  final String? market;
  final String? forceCrisis;
  final bool advanceQuarter;
  final bool syncBooks;
  final VuV2BizRubricScore? rubric;
}

class VuV2BizRubricScore {
  const VuV2BizRubricScore({
    required this.criteria,
  });

  final List<VuV2BizRubricCriterion> criteria;

  int get total {
    int s = 0;
    for (int i = 0; i < criteria.length; i++) {
      s += criteria[i].score;
    }
    return s;
  }

  int get maxTotal {
    int s = 0;
    for (int i = 0; i < criteria.length; i++) {
      s += criteria[i].maxScore;
    }
    return s;
  }
}

class VuV2BizRubricCriterion {
  const VuV2BizRubricCriterion({
    required this.label,
    required this.score,
    required this.maxScore,
    required this.note,
  });

  final String label;
  final int score;
  final int maxScore;
  final String note;
}
