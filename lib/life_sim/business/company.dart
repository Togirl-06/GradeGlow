/// Start-a-company simulation: capital, staff, pricing, marketing, customers.
/// Deterministic (seeded noise) and entirely rule based.
library;

import 'dart:math' as math;

import '../core/stable_random.dart';

class CompanyIndustry {
  const CompanyIndustry(this.id, this.name, this.emoji, this.refPrice, this.unitCost);
  final String id;
  final String name;
  final String emoji;

  /// Price customers consider fair.
  final double refPrice;
  final double unitCost;
}

const List<CompanyIndustry> kIndustries = <CompanyIndustry>[
  CompanyIndustry('cafe', 'Coffee shop', '☕', 6, 2),
  CompanyIndustry('apps', 'App studio', '📱', 25, 4),
  CompanyIndustry('tutoring', 'Tutoring service', '📚', 30, 8),
  CompanyIndustry('bakery', 'Bakery', '🥐', 9, 3.5),
];

class Company {
  Company({
    required this.name,
    required this.industryId,
    required this.cash,
    required this.foundedDay,
    double? price,
    this.employees = 0,
    this.marketing = 0,
    this.reputation = 30,
    this.daysOpen = 0,
    this.totalProfit = 0,
    this.lossDays = 0,
    this.closed = false,
    this.lastCustomers = 0,
    this.lastProfit = 0,
    this.lastUnmet = 0,
  }) : price = price ?? industryOf(industryId).refPrice;

  String name;
  final String industryId;
  double cash;
  final int foundedDay;
  double price;
  int employees;

  /// 0..5 marketing intensity.
  int marketing;
  double reputation;
  int daysOpen;
  double totalProfit;
  int lossDays;
  bool closed;
  int lastCustomers;
  double lastProfit;
  int lastUnmet;

  static const int maxEmployees = 5;
  static const double wagePerDay = 60;
  static const double hireCost = 100;
  static const double fixedPerDay = 25;
  static const double minCapital = 500;
  static const int bankruptAfterLossDays = 6;

  static CompanyIndustry industryOf(String id) =>
      kIndustries.firstWhere((CompanyIndustry i) => i.id == id, orElse: () => kIndustries.first);

  CompanyIndustry get industry => industryOf(industryId);
  double get dailyCosts => fixedPerDay + employees * wagePerDay + marketing * 10;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'industryId': industryId,
        'cash': cash,
        'foundedDay': foundedDay,
        'price': price,
        'employees': employees,
        'marketing': marketing,
        'reputation': reputation,
        'daysOpen': daysOpen,
        'totalProfit': totalProfit,
        'lossDays': lossDays,
        'closed': closed,
        'lastCustomers': lastCustomers,
        'lastProfit': lastProfit,
        'lastUnmet': lastUnmet,
      };

  factory Company.fromJson(Map<String, Object?> j) => Company(
        name: j['name'] as String? ?? 'My Company',
        industryId: j['industryId'] as String? ?? 'cafe',
        cash: (j['cash'] as num?)?.toDouble() ?? 0,
        foundedDay: (j['foundedDay'] as num?)?.toInt() ?? 1,
        price: (j['price'] as num?)?.toDouble(),
        employees: (j['employees'] as num?)?.toInt() ?? 0,
        marketing: (j['marketing'] as num?)?.toInt() ?? 0,
        reputation: (j['reputation'] as num?)?.toDouble() ?? 30,
        daysOpen: (j['daysOpen'] as num?)?.toInt() ?? 0,
        totalProfit: (j['totalProfit'] as num?)?.toDouble() ?? 0,
        lossDays: (j['lossDays'] as num?)?.toInt() ?? 0,
        closed: j['closed'] as bool? ?? false,
        lastCustomers: (j['lastCustomers'] as num?)?.toInt() ?? 0,
        lastProfit: (j['lastProfit'] as num?)?.toDouble() ?? 0,
        lastUnmet: (j['lastUnmet'] as num?)?.toInt() ?? 0,
      );
}

class CompanyEngine {
  const CompanyEngine._();

  static String? hire(Company c) {
    if (c.closed) return 'The company is closed.';
    if (c.employees >= Company.maxEmployees) return 'You already have the maximum team (${Company.maxEmployees}).';
    if (c.cash < Company.hireCost) return 'Hiring costs \$${Company.hireCost.round()} in company cash.';
    c.cash -= Company.hireCost;
    c.employees++;
    return null;
  }

  static String? release(Company c) {
    if (c.employees <= 0) return 'You have no employees.';
    c.employees--;
    return null;
  }

  static String? setPrice(Company c, double price) {
    if (price < 1 || price > c.industry.refPrice * 3) return 'Choose a price between \$1 and \$${(c.industry.refPrice * 3).round()}.';
    c.price = price;
    return null;
  }

  static String? setMarketing(Company c, int level) {
    if (level < 0 || level > 5) return 'Marketing is 0–5.';
    c.marketing = level;
    return null;
  }

  /// Simulates one day. [ownerWorked] if the owner spent hours on the business.
  /// [skill] is 0..100 (management/finance) and slightly boosts demand.
  static void simulateDay(Company c, int day, {required bool ownerWorked, double skill = 0, bool creative = false}) {
    if (c.closed) return;
    final CompanyIndustry ind = c.industry;
    final StableRandom rng = StableRandom.fromString('co|${c.name}|$day');
    final double noise = 0.9 + rng.nextDouble() * 0.2;
    final double priceFactor = math.pow(ind.refPrice / c.price, 1.2).toDouble().clamp(0.2, 2.5).toDouble();
    final double base = 6 + c.reputation * 0.35 + c.marketing * 5 + c.employees * 2 + skill * 0.05;
    final double ownerFactor = ownerWorked ? 1.0 : 0.65;
    final int demand = (base * priceFactor * ownerFactor * noise).floor();
    final int capacity = 8 + c.employees * 12 + (ownerWorked ? 8 : 0);
    final int sold = demand < capacity ? demand : capacity;
    final int unmet = demand - sold;
    final double revenue = sold * c.price * (creative ? 1.05 : 1.0);
    final double costs = sold * ind.unitCost + c.dailyCosts;
    final double profit = revenue - costs;
    c.cash += profit;
    c.totalProfit += profit;
    c.lastCustomers = sold;
    c.lastProfit = profit;
    c.lastUnmet = unmet;
    c.daysOpen++;
    double rep = c.reputation;
    if (unmet > 0) {
      rep -= 0.8;
    } else {
      rep += 0.5;
    }
    if (c.price <= ind.refPrice) rep += 0.2;
    if (c.price > ind.refPrice * 1.6) rep -= 0.5;
    c.reputation = rep.clamp(0, 100).toDouble();
    if (c.cash < 0) {
      c.lossDays++;
      if (c.lossDays >= Company.bankruptAfterLossDays) c.closed = true;
    } else {
      c.lossDays = 0;
    }
  }

  /// Cash the owner can safely take home (keeps a cushion).
  static double withdrawable(Company c) => (c.cash - 300).clamp(0, 1e9).toDouble();
}
