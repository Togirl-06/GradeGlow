import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Pure Dart game logic for Budget Boss. No Flutter imports, so it can be
// unit-tested with `flutter test` without pumping any widgets.
// ---------------------------------------------------------------------------

// ----- Puzzle scoring -------------------------------------------------------

/// Needs / Wants / Savings sort: 100% = 3 stars.
int sortStars(int correct, int total) {
  if (total <= 0) return 0;
  final double ratio = correct / total;
  if (correct == total) return 3;
  if (ratio >= 0.7) return 2;
  if (ratio >= 0.5) return 1;
  return 0;
}

/// Spot-the-fee score: share of real problems found, minus 10 per false flag.
int spotScore(int found, int falseFlags, int totalProblems) {
  if (totalProblems <= 0) return 0;
  final double raw = (found * 100 / totalProblems) - (falseFlags * 10);
  return raw.round().clamp(0, 100).toInt();
}

int spotStars(int score) {
  if (score >= 100) return 3;
  if (score >= 60) return 2;
  if (score >= 30) return 1;
  return 0;
}

// ----- Paycheck simulator ---------------------------------------------------

class MonthEventChoice {
  const MonthEventChoice({
    required this.label,
    this.cost = 0,
    this.stress = 0,
  });

  final String label;

  /// Dollars out this month. Negative = extra income.
  final int cost;

  /// Added to the stress meter.
  final int stress;
}

class MonthEvent {
  const MonthEvent({
    required this.emoji,
    required this.title,
    required this.body,
    required this.choices,
  });

  final String emoji;
  final String title;
  final String body;
  final List<MonthEventChoice> choices;
}

class PaycheckMonth {
  const PaycheckMonth({required this.label, required this.income, this.event});

  final String label;
  final int income;
  final MonthEvent? event;
}

class PaycheckScenario {
  const PaycheckScenario({
    required this.months,
    required this.startCash,
    required this.fixedCosts,
    required this.savings3,
    required this.savings2,
    required this.savings1,
    required this.maxStress3,
  });

  final List<PaycheckMonth> months;
  final int startCash;

  /// Rent + utilities. Not adjustable by the player.
  final int fixedCosts;
  final int savings3;
  final int savings2;
  final int savings1;
  final int maxStress3;
}

class PaycheckPlan {
  const PaycheckPlan({
    required this.groceries,
    required this.transport,
    required this.fun,
    required this.savings,
  });

  final int groceries;
  final int transport;
  final int fun;
  final int savings;

  int get total => groceries + transport + fun + savings;
}

class PaycheckState {
  const PaycheckState({
    required this.month,
    required this.cash,
    required this.savings,
    required this.stress,
    required this.overdrafts,
    this.lastNote = '',
  });

  /// Index of the month about to be played (0-based). Equals months.length
  /// once the run is finished.
  final int month;
  final int cash;
  final int savings;

  /// 0-100.
  final int stress;
  final int overdrafts;
  final String lastNote;
}

abstract final class PaycheckEngine {
  static const int overdraftFee = 35;

  static PaycheckState start(PaycheckScenario s) => PaycheckState(
        month: 0,
        cash: s.startCash,
        savings: 0,
        stress: 20,
        overdrafts: 0,
      );

  static bool isFinished(PaycheckScenario s, PaycheckState st) =>
      st.month >= s.months.length;

  /// Cash left over this month, before any emergency-fund draw.
  static int leftover(
    PaycheckScenario s,
    PaycheckState st,
    PaycheckPlan p,
    MonthEventChoice? choice,
  ) {
    final PaycheckMonth m = s.months[st.month];
    return m.income - s.fixedCosts - p.total - (choice?.cost ?? 0);
  }

  static PaycheckState advance(
    PaycheckScenario s,
    PaycheckState st,
    PaycheckPlan p,
    MonthEventChoice? choice,
  ) {
    int cash = st.cash + leftover(s, st, p, choice);
    int savings = st.savings + p.savings;
    int stress = st.stress + (choice?.stress ?? 0);
    int overdrafts = st.overdrafts;
    final List<String> notes = <String>[];

    if (cash < 0) {
      // The emergency fund exists for exactly this.
      final int draw = math.min(-cash, savings);
      if (draw > 0) {
        cash += draw;
        savings -= draw;
        notes.add('Your savings covered a \$$draw shortfall.');
      }
      if (cash < 0) {
        cash -= overdraftFee;
        overdrafts += 1;
        stress += 20;
        notes.add('Overdraft! The bank charged a \$$overdraftFee fee.');
      }
    }

    if (p.fun < 100) {
      stress += 6;
      notes.add('No fun money made the month feel grim (+stress).');
    } else if (p.fun >= 200) {
      stress -= 4;
    }
    if (p.groceries < 250) {
      stress += 6;
      notes.add('Skimping on food took a toll (+stress).');
    }
    if (p.savings >= 250) {
      stress -= 4;
      notes.add('Saving \$${p.savings} let you sleep easier (-stress).');
    }

    stress = stress.clamp(0, 100).toInt();

    return PaycheckState(
      month: st.month + 1,
      cash: cash,
      savings: savings,
      stress: stress,
      overdrafts: overdrafts,
      lastNote: notes.join(' '),
    );
  }

  static int stars(PaycheckScenario s, PaycheckState st) {
    if (st.cash < 0) return 0;
    if (st.savings >= s.savings3 &&
        st.stress <= s.maxStress3 &&
        st.overdrafts == 0) {
      return 3;
    }
    if (st.savings >= s.savings2 && st.overdrafts <= 1) return 2;
    if (st.savings >= s.savings1) return 1;
    return 0;
  }

  /// 0-100 for the result card.
  static int score(PaycheckScenario s, PaycheckState st) {
    if (st.cash < 0) return 0;
    final double saved = (st.savings / s.savings3).clamp(0.0, 1.0).toDouble();
    final double calm =
        ((100 - st.stress) / 100).clamp(0.0, 1.0).toDouble();
    final double raw = (saved * 70) + (calm * 30) - (st.overdrafts * 10);
    return raw.round().clamp(0, 100).toInt();
  }
}

// ----- Credit card simulator -----------------------------------------------

class CardPurchase {
  const CardPurchase({
    required this.emoji,
    required this.title,
    required this.amount,
  });

  final String emoji;
  final String title;
  final int amount;
}

class CardScenario {
  const CardScenario({
    required this.startBalance,
    required this.monthlyBudget,
    required this.monthlyRatePercent,
    required this.purchases,
    required this.balance3,
    required this.interest3,
    required this.balance2,
    required this.interest2,
  });

  final int startBalance;

  /// The most the player can put toward the card each month.
  final int monthlyBudget;

  /// 2 = 2% per month (about 24% APR).
  final int monthlyRatePercent;
  final List<CardPurchase> purchases;
  final int balance3;
  final int interest3;
  final int balance2;
  final int interest2;
}

class CardState {
  const CardState({
    required this.month,
    required this.balance,
    required this.interestPaid,
    this.lastNote = '',
  });

  final int month;
  final int balance;
  final int interestPaid;
  final String lastNote;
}

abstract final class CardEngine {
  static CardState start(CardScenario s) =>
      CardState(month: 0, balance: s.startBalance, interestPaid: 0);

  static bool isFinished(CardScenario s, CardState st) =>
      st.month >= s.purchases.length;

  /// Typical card minimum: 3% of the balance, never under $25.
  static int minPayment(int balance) {
    if (balance <= 0) return 0;
    return math.min(balance, math.max(25, (balance * 0.03).ceil()));
  }

  static int maxPayment(CardScenario s, int balance) {
    final int lo = minPayment(balance);
    return math.max(lo, math.min(balance, s.monthlyBudget));
  }

  static CardState advance(
    CardScenario s,
    CardState st, {
    required bool buy,
    required int payment,
  }) {
    int balance = st.balance;
    if (buy) balance += s.purchases[st.month].amount;
    final int pay = payment
        .clamp(minPayment(balance), maxPayment(s, balance))
        .toInt();
    balance -= pay;
    final int interest = (balance * s.monthlyRatePercent / 100).round();
    balance += interest;
    return CardState(
      month: st.month + 1,
      balance: balance,
      interestPaid: st.interestPaid + interest,
      lastNote: interest > 0
          ? 'You paid \$$pay. The card then charged \$$interest interest on '
              'what was left.'
          : 'You paid \$$pay and owe no interest this month.',
    );
  }

  static int stars(CardScenario s, CardState st) {
    if (st.balance <= s.balance3 && st.interestPaid <= s.interest3) return 3;
    if (st.balance <= s.balance2 && st.interestPaid <= s.interest2) return 2;
    if (st.balance < s.startBalance) return 1;
    return 0;
  }

  static int score(CardScenario s, CardState st) {
    final double paidDown =
        ((s.startBalance - st.balance) / s.startBalance).clamp(0.0, 1.0)
            .toDouble();
    final double cheap =
        (1 - (st.interestPaid / 160)).clamp(0.0, 1.0).toDouble();
    return ((paidDown * 60) + (cheap * 40)).round().clamp(0, 100).toInt();
  }
}
