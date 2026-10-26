import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_buddy/vu_v2/career_labs/playable/glow/life_skills/budget_boss_engine.dart';
import 'package:ai_study_buddy/vu_v2/career_labs/playable/glow/life_skills/budget_boss_lab.dart';
import 'package:ai_study_buddy/vu_v2/career_labs/playable/playable_router.dart';

// Same numbers as the First Paycheck level.
const PaycheckScenario _paycheck = PaycheckScenario(
  startCash: 300,
  fixedCosts: 1250,
  savings3: 900,
  savings2: 600,
  savings1: 300,
  maxStress3: 55,
  months: <PaycheckMonth>[
    PaycheckMonth(label: 'Month 1', income: 2400),
    PaycheckMonth(label: 'Month 2', income: 2400),
    PaycheckMonth(label: 'Month 3', income: 2400),
  ],
);

// Same numbers as the Credit Card Trap level.
const CardScenario _card = CardScenario(
  startBalance: 1200,
  monthlyBudget: 300,
  monthlyRatePercent: 2,
  balance3: 100,
  interest3: 60,
  balance2: 450,
  interest2: 100,
  purchases: <CardPurchase>[
    CardPurchase(emoji: 'a', title: 'a', amount: 180),
    CardPurchase(emoji: 'b', title: 'b', amount: 240),
    CardPurchase(emoji: 'c', title: 'c', amount: 90),
    CardPurchase(emoji: 'd', title: 'd', amount: 320),
    CardPurchase(emoji: 'e', title: 'e', amount: 110),
    CardPurchase(emoji: 'f', title: 'f', amount: 75),
  ],
);

PaycheckState _runPaycheck(
  PaycheckPlan plan,
  List<MonthEventChoice?> choices,
) {
  PaycheckState st = PaycheckEngine.start(_paycheck);
  for (int m = 0; m < _paycheck.months.length; m++) {
    st = PaycheckEngine.advance(_paycheck, st, plan, choices[m]);
  }
  return st;
}

CardState _runCard(List<bool> buys) {
  CardState st = CardEngine.start(_card);
  for (int m = 0; m < _card.purchases.length; m++) {
    st = CardEngine.advance(
      _card,
      st,
      buy: buys[m],
      payment: 999999, // clamps to the maximum allowed payment
    );
  }
  return st;
}

void main() {
  group('puzzle scoring', () {
    test('sortStars', () {
      expect(sortStars(9, 9), 3);
      expect(sortStars(7, 9), 2);
      expect(sortStars(5, 9), 1);
      expect(sortStars(4, 9), 0);
    });

    test('spotScore penalises false flags and never goes below 0', () {
      expect(spotScore(5, 0, 5), 100);
      expect(spotScore(5, 2, 5), 80);
      expect(spotScore(0, 3, 5), 0);
      expect(spotStars(100), 3);
      expect(spotStars(80), 2);
      expect(spotStars(40), 1);
      expect(spotStars(20), 0);
    });
  });

  group('paycheck simulator', () {
    const List<MonthEventChoice> events = <MonthEventChoice>[
      MonthEventChoice(label: 'fix phone', cost: 120),
      MonthEventChoice(label: 'concert', cost: 90, stress: -8),
      MonthEventChoice(label: 'dentist', cost: 220),
    ];

    test('a steady saver earns 3 stars', () {
      final PaycheckState st = _runPaycheck(
        const PaycheckPlan(
          groceries: 350,
          transport: 100,
          fun: 150,
          savings: 300,
        ),
        events,
      );
      expect(st.savings, 900);
      expect(st.cash, 620);
      expect(st.overdrafts, 0);
      expect(PaycheckEngine.isFinished(_paycheck, st), isTrue);
      expect(PaycheckEngine.stars(_paycheck, st), 3);
    });

    test('saving nothing earns 0 stars', () {
      final PaycheckState st = _runPaycheck(
        const PaycheckPlan(
          groceries: 450,
          transport: 200,
          fun: 450,
          savings: 0,
        ),
        events,
      );
      expect(PaycheckEngine.stars(_paycheck, st), 0);
    });

    test('overspending drains savings first, then charges an overdraft fee', () {
      final PaycheckScenario broke = PaycheckScenario(
        startCash: 0,
        fixedCosts: 1250,
        savings3: 900,
        savings2: 600,
        savings1: 300,
        maxStress3: 55,
        months: const <PaycheckMonth>[
          PaycheckMonth(label: 'Month 1', income: 2400),
        ],
      );
      final PaycheckState st = PaycheckEngine.advance(
        broke,
        PaycheckEngine.start(broke),
        const PaycheckPlan(
          groceries: 600,
          transport: 300,
          fun: 500,
          savings: 800,
        ),
        null,
      );
      // Short by 1,050; savings (800) cover part, the rest overdraws.
      expect(st.savings, 0);
      expect(st.cash, -285); // -250 shortfall, then a 35 fee
      expect(st.overdrafts, 1);
      expect(st.stress, 32);
      expect(PaycheckEngine.stars(broke, st), 0);
    });
  });

  group('credit card simulator', () {
    test('minimum payment is 3% with a 25 floor, capped at the balance', () {
      expect(CardEngine.minPayment(1200), 36);
      expect(CardEngine.minPayment(500), 25);
      expect(CardEngine.minPayment(10), 10);
      expect(CardEngine.minPayment(0), 0);
    });

    test('skipping every purchase beats the card', () {
      final CardState st = _runCard(<bool>[false, false, false, false, false, false]);
      expect(st.balance, 0);
      expect(st.interestPaid, 38);
      expect(CardEngine.stars(_card, st), 3);
    });

    test('buying everything leaves a balance and costs more interest', () {
      final CardState st = _runCard(<bool>[true, true, true, true, true, true]);
      expect(st.balance, 517);
      expect(st.interestPaid, 102);
      expect(CardEngine.stars(_card, st), 1);
    });

    test('payment is clamped to the allowed range', () {
      final CardState st = CardEngine.advance(
        _card,
        CardEngine.start(_card),
        buy: false,
        payment: 1, // below the minimum, so the minimum is used
      );
      // 1200 - 36 = 1164, plus 2% interest (23) = 1187
      expect(st.balance, 1187);
    });
  });

  group('wiring', () {
    test('personal_finance resolves to Budget Boss in the router', () {
      expect(playableScreens.containsKey('personal_finance'), isTrue);
    });

    test('lab has 5 levels with unique ids and a boss last', () {
      final Set<String> ids = budgetBossLab.levels.map((l) => l.id).toSet();
      expect(budgetBossLab.levels.length, 5);
      expect(ids.length, 5);
      expect(budgetBossLab.levels.last.isBoss, isTrue);
    });

    testWidgets('level map shows level 1 unlocked and the rest locked', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(MaterialApp(home: budgetBossScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Level 1 · Needs vs Wants'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));
    });
  });
}
