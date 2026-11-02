import 'package:flutter/material.dart';

import '../../business/company.dart';
import '../../economy/life_economy.dart';
import '../../economy/shop_catalog.dart';
import '../../game/life_game.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import 'avatar_editor.dart';

// ---------------------------------------------------------------------------
// Shops
// ---------------------------------------------------------------------------

List<ShopItem> shopItems(String shopId) {
  switch (shopId) {
    case 'cafe':
      return <ShopItem>[ShopCatalog.item('coffee')!, ShopCatalog.item('snack')!];
    case 'mall_food':
      return <ShopItem>[ShopCatalog.item('restaurant_meal')!, ShopCatalog.item('snack')!, ShopCatalog.item('coffee')!];
    case 'grocery':
      return <ShopItem>[ShopCatalog.item('groceries')!, ShopCatalog.item('snack')!];
    case 'mall_clothing':
      return ShopCatalog.clothing;
    case 'mall_furniture':
      return ShopCatalog.furniture;
    case 'transit':
      return ShopCatalog.transport;
  }
  return const <ShopItem>[];
}

String shopTitle(String shopId) => const <String, String>{
      'cafe': '☕ Café',
      'mall_food': '🍔 Food court',
      'grocery': '🛒 Fresh Mart',
      'mall_clothing': '👔 Clothing store',
      'mall_furniture': '🛋️ Furniture store',
      'transit': '🚇 Transit kiosk',
    }[shopId] ??
    'Shop';

const Map<String, String> _effectLabels = <String, String>{'hunger': 'Hunger', 'energy': 'Energy', 'happiness': 'Mood', 'health': 'Health', 'social': 'Social'};

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.life, required this.shopId});
  final LifeSession life;
  final String shopId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeEconomy eco = life.game.economy;
          return LifePage(
            title: shopTitle(shopId),
            subtitle: 'Cash ${money(eco.cash)}',
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              for (final ShopItem it in shopItems(shopId))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Panel(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(it.emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          Text(it.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          if (it.blurb.isNotEmpty) Text(it.blurb, style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
                          const SizedBox(height: 6),
                          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
                            for (final MapEntry<String, double> e in it.effects.entries) Tag('${_effectLabels[e.key] ?? e.key} ${e.value >= 0 ? '+' : ''}${e.value.round()}', color: e.value >= 0 ? LifeColors.green : LifeColors.red),
                            if (it.comfort > 0) Tag('Comfort +${it.comfort}', color: LifeColors.purple),
                            if (it.professionalism > 0) Tag('Professional +${it.professionalism}', color: LifeColors.blue),
                            if (it.id == 'groceries') Tag('You have ${eco.count('groceries')} meals', color: LifeColors.teal),
                            if (eco.owns(it.id) && !it.stackable && it.category != ShopCategory.food) const Tag('Owned', color: LifeColors.muted),
                          ]),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      Column(children: <Widget>[
                        Text(money(it.price), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 6),
                        FilledButton(
                          onPressed: (!it.stackable && it.category != ShopCategory.food && it.category != ShopCategory.entertainment && eco.owns(it.id)) ? null : () => life.report(life.game.buyItem(it.id)),
                          child: const Text('Buy'),
                        ),
                      ]),
                    ]),
                  ),
                ),
            ]),
          );
        },
      );
}

// ---------------------------------------------------------------------------
// Bank
// ---------------------------------------------------------------------------

class BankScreen extends StatefulWidget {
  const BankScreen({super.key, required this.life});
  final LifeSession life;
  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  @override
  Widget build(BuildContext context) {
    final LifeSession life = widget.life;
    return ListenableBuilder(
      listenable: life,
      builder: (BuildContext context, _) {
        final LifeGame g = life.game;
        final LifeEconomy e = g.economy;
        final Map<String, double> spend = <String, double>{};
        double income = 0;
        for (final LedgerEntry l in e.ledger) {
          if (g.day - l.day > 30) continue;
          if (l.amount > 0) {
            income += l.amount;
          } else if (l.amount < 0) {
            spend[l.category] = (spend[l.category] ?? 0) - l.amount;
          }
        }
        final double totalSpend = spend.values.fold(0, (double a, double b) => a + b);
        final List<MapEntry<String, double>> cats = spend.entries.toList()..sort((MapEntry<String, double> a, MapEntry<String, double> b) => b.value.compareTo(a.value));
        return LifePage(
          title: '🏦 Glow Bank',
          subtitle: 'Net worth ${money(e.netWorth)}',
          child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: _stat('Cash', money(e.cash), LifeColors.green)),
              const SizedBox(width: 8),
              Expanded(child: _stat('Savings', money(e.savings), LifeColors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _stat('Debt', money(e.debt), e.debt > 0 ? LifeColors.red : LifeColors.muted)),
            ]),
            const SectionTitle('Move money'),
            Panel(
              child: Column(children: <Widget>[
                Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                  for (final double a in <double>[50, 100, 250, 500])
                    OutlinedButton(onPressed: () => life.report(g.deposit(a)), child: Text('Save ${money(a)}')),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                  for (final double a in <double>[50, 100, 250, 500])
                    OutlinedButton(onPressed: () => life.report(g.withdraw(a)), child: Text('Take ${money(a)}')),
                  if (e.savings > 0) OutlinedButton(onPressed: () => life.report(g.withdraw(e.savings)), child: const Text('Take all')),
                ]),
                if (e.debt > 0) ...<Widget>[
                  const Divider(height: 22),
                  Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                    for (final double a in <double>[50, 100, 250])
                      FilledButton.tonal(onPressed: () => life.report(g.repayDebt(a)), child: Text('Repay ${money(a)}')),
                    FilledButton(onPressed: () => life.report(g.repayDebt(e.debt)), child: const Text('Repay all')),
                  ]),
                  const Text('Debt grows 3% interest when bills are missed. Pay it early.', style: TextStyle(color: LifeColors.amber, fontSize: 12)),
                ],
              ]),
            ),
            const SectionTitle('Budget — last 30 days'),
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text('Income ${money(income)}  ·  Spending ${money(totalSpend)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(income - totalSpend >= 0 ? 'You saved ${money(income - totalSpend)} 👍' : 'You spent ${money(totalSpend - income)} more than you earned ⚠️', style: TextStyle(color: income - totalSpend >= 0 ? LifeColors.green : LifeColors.amber)),
                const SizedBox(height: 8),
                if (cats.isEmpty) const Text('No spending yet.', style: TextStyle(color: LifeColors.muted)),
                for (final MapEntry<String, double> c in cats)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: <Widget>[
                      SizedBox(width: 90, child: Text(c.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: totalSpend == 0 ? 0 : c.value / totalSpend, minHeight: 9, backgroundColor: Colors.white12))),
                      const SizedBox(width: 8),
                      SizedBox(width: 74, child: Text(money(c.value), textAlign: TextAlign.right)),
                    ]),
                  ),
                const SizedBox(height: 6),
                Text('Fixed monthly costs: ${money(e.monthlyFixedCosts)} (rent + utilities${e.transitPass ? ' + transit' : ''}). Next bill on Day ${e.lastBillDay + ShopCatalog.billingPeriodDays}.', style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
              ]),
            ),
            const SectionTitle('Recent transactions'),
            Panel(
              child: Column(children: <Widget>[
                if (e.ledger.isEmpty) const Text('Nothing yet.', style: TextStyle(color: LifeColors.muted)),
                for (final LedgerEntry l in e.ledger.reversed.take(25))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: <Widget>[
                      Text('D${l.day}', style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(l.amount == 0 ? '—' : money(l.amount), style: TextStyle(fontWeight: FontWeight.w800, color: l.amount > 0 ? LifeColors.green : (l.amount < 0 ? LifeColors.red : LifeColors.muted))),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 24),
          ]),
        );
      },
    );
  }

  Widget _stat(String k, String v, Color c) => Panel(child: Column(children: <Widget>[Text(k, style: const TextStyle(color: LifeColors.muted, fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 4), Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: c))]));
}

// ---------------------------------------------------------------------------
// Apartment: housing, furniture placement, wardrobe, bills
// ---------------------------------------------------------------------------

class ApartmentScreen extends StatelessWidget {
  const ApartmentScreen({super.key, required this.life, this.initialTab = 0});
  final LifeSession life;
  final int initialTab;

  @override
  Widget build(BuildContext context) => Theme(
        data: lifeTheme(),
        child: DefaultTabController(
          length: 3,
          initialIndex: initialTab,
          child: Scaffold(
            appBar: AppBar(title: const Text('My apartment'), bottom: const TabBar(tabs: <Tab>[Tab(text: 'Home'), Tab(text: 'Furniture'), Tab(text: 'Bills')])),
            body: ListenableBuilder(
              listenable: life,
              builder: (BuildContext context, _) => TabBarView(children: <Widget>[_home(context), _furniture(context), _bills(context)]),
            ),
          ),
        ),
      );

  Widget _home(BuildContext context) {
    final LifeEconomy e = life.game.economy;
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Panel(
        border: LifeColors.green,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('You live in: ${e.housing.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text('Comfort ${e.comfort.toStringAsFixed(1)}/10 · rent ${money(e.housing.rent)}/month · ${e.housing.slots} furniture slots'),
          const SizedBox(height: 10),
          BigButton(
            label: 'Change my look (wardrobe)',
            icon: Icons.checkroom_rounded,
            color: LifeColors.pink,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WardrobeScreen(profile: life.game.avatar, onChanged: life.changed))),
          ),
        ]),
      ),
      const SectionTitle('Move to a new place'),
      for (final Housing h in ShopCatalog.housing)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            child: Row(children: <Widget>[
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text(h.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(h.blurb, style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, children: <Widget>[Tag('${money(h.rent)}/mo', color: LifeColors.amber), Tag('Comfort ${h.comfort}', color: LifeColors.purple), Tag('${h.slots} slots', color: LifeColors.teal)]),
                ]),
              ),
              FilledButton(onPressed: h.id == e.housingId ? null : () => life.report(life.game.moveHome(h.id)), child: Text(h.id == e.housingId ? 'Here' : 'Move in')),
            ]),
          ),
        ),
      const Text('Moving costs the first month\'s rent up front. Missing rent twice means eviction.', style: TextStyle(color: LifeColors.muted, fontSize: 12)),
    ]);
  }

  Widget _furniture(BuildContext context) {
    final LifeEconomy e = life.game.economy;
    final List<ShopItem> owned = ShopCatalog.furniture.where((ShopItem i) => e.owns(i.id)).toList();
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Text('Slots used ${e.placedFurniture.length}/${e.housing.slots}. Placed furniture raises comfort (better sleep and mood).', style: const TextStyle(color: LifeColors.muted)),
      const SizedBox(height: 10),
      if (owned.isEmpty) const Panel(child: Text('You do not own any furniture yet. Visit the furniture store in the mall.')),
      for (final ShopItem i in owned)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            child: Row(children: <Widget>[
              Text(i.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Expanded(child: Text('${i.name}  ·  comfort +${i.comfort}', style: const TextStyle(fontWeight: FontWeight.w800))),
              if (e.placedFurniture.contains(i.id))
                OutlinedButton(onPressed: () {
                  e.removeFurniture(i.id);
                  life.changed();
                }, child: const Text('Remove'))
              else
                FilledButton(onPressed: () {
                  final String? err = e.placeFurniture(i.id);
                  life.report(err == null ? ActionResult.ok('${i.name} placed.') : ActionResult.fail(err));
                }, child: const Text('Place')),
            ]),
          ),
        ),
    ]);
  }

  Widget _bills(BuildContext context) {
    final LifeEconomy e = life.game.economy;
    final int next = e.lastBillDay + ShopCatalog.billingPeriodDays;
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Next bill: Day $next (${next - life.game.day} days)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 6),
          Text('Rent ${money(e.housing.rent)}'),
          Text('Utilities ${money(ShopCatalog.utilitiesPerMonth)}'),
          if (e.transitPass) Text('Transit pass ${money(ShopCatalog.transitPassPerMonth)}'),
          const Divider(),
          Text('Total ${money(e.monthlyFixedCosts)}', style: const TextStyle(fontWeight: FontWeight.w900)),
          Text('You have ${money(e.cash)} cash and ${money(e.savings)} in savings.${e.cash + e.savings < e.monthlyFixedCosts ? '  ⚠️ Not enough for the next bill!' : ''}', style: TextStyle(color: e.cash + e.savings < e.monthlyFixedCosts ? LifeColors.amber : LifeColors.muted)),
        ]),
      ),
      if (e.debt > 0) ...<Widget>[
        const SectionTitle('Debt'),
        Panel(
          border: LifeColors.red,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('You owe ${money(e.debt)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: LifeColors.red)),
            const SizedBox(height: 8),
            BigButton(label: 'Pay as much as I can', icon: Icons.payments_rounded, onPressed: () => life.report(life.game.repayDebt(e.cash))),
          ]),
        ),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------
// Company registry / management
// ---------------------------------------------------------------------------

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key, required this.life});
  final LifeSession life;
  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final TextEditingController _name = TextEditingController();
  String _industry = kIndustries.first.id;
  double _capital = 600;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LifeSession life = widget.life;
    return ListenableBuilder(
      listenable: life,
      builder: (BuildContext context, _) {
        final Company? c = life.game.company;
        return LifePage(
          title: '📋 Company Registry',
          subtitle: c == null ? 'Start your own business' : c.name,
          child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[if (c == null || c.closed) ..._start(life, c) else ..._manage(life, c)]),
        );
      },
    );
  }

  List<Widget> _start(LifeSession life, Company? old) {
    final String? block = life.game.canStartCompany(_capital);
    return <Widget>[
      if (old != null && old.closed) Panel(border: LifeColors.red, child: Text('${old.name} closed after ${old.daysOpen} days (total profit ${money(old.totalProfit)}). Learn from it and try again.')),
      const Panel(child: Text('Running a business means balancing price, marketing and staff against customers and costs. Start small, watch cash flow, and keep serving customers well.')),
      const SectionTitle('Company name'),
      TextField(controller: _name, decoration: const InputDecoration(hintText: 'e.g. Sunrise Bakery')),
      const SectionTitle('Industry'),
      Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
        for (final CompanyIndustry i in kIndustries) ChoiceChip(label: Text('${i.emoji} ${i.name}'), selected: _industry == i.id, onSelected: (_) => setState(() => _industry = i.id)),
      ]),
      const SectionTitle('Start-up capital'),
      Text('${money(_capital)} (plus a \$100 registration fee)', style: const TextStyle(fontWeight: FontWeight.w800)),
      Slider(value: _capital, min: Company.minCapital, max: 3000, divisions: 25, onChanged: (double v) => setState(() => _capital = v)),
      Text('You have ${money(life.game.economy.cash)} cash.', style: const TextStyle(color: LifeColors.muted)),
      if (block != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(block, style: const TextStyle(color: LifeColors.amber))),
      const SizedBox(height: 12),
      BigButton(label: 'Register company', icon: Icons.add_business_rounded, color: LifeColors.green, onPressed: block != null ? null : () => life.report(life.game.startCompany(_name.text, _industry, _capital))),
    ];
  }

  List<Widget> _manage(LifeSession life, Company c) {
    final LifeGame g = life.game;
    return <Widget>[
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('${c.industry.emoji} ${c.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          Row(children: <Widget>[
            Expanded(child: _kpi('Company cash', money(c.cash), c.cash < 0 ? LifeColors.red : LifeColors.green)),
            const SizedBox(width: 8),
            Expanded(child: _kpi('Last day profit', money(c.lastProfit), c.lastProfit >= 0 ? LifeColors.green : LifeColors.red)),
          ]),
          const SizedBox(height: 8),
          NeedBar(label: 'Reputation', value: c.reputation, emoji: '⭐'),
          Text('Customers yesterday: ${c.lastCustomers}${c.lastUnmet > 0 ? ' · turned away ${c.lastUnmet} (hire more staff!)' : ''}'),
          Text('Open ${c.daysOpen} days · lifetime profit ${money(c.totalProfit)} · daily costs ${money(c.dailyCosts)}'),
          if (c.cash < 0) Text('⚠️ In the red for ${c.lossDays} day(s) — closes at ${Company.bankruptAfterLossDays}.', style: const TextStyle(color: LifeColors.red, fontWeight: FontWeight.w800)),
        ]),
      ),
      const SectionTitle('Price'),
      Panel(child: Column(children: <Widget>[
        Text('${money(c.price)} per sale (fair price ≈ ${money(c.industry.refPrice)})', style: const TextStyle(fontWeight: FontWeight.w800)),
        Slider(value: c.price.clamp(1, c.industry.refPrice * 3), min: 1, max: c.industry.refPrice * 3, divisions: 40, onChanged: (double v) {
          CompanyEngine.setPrice(c, double.parse(v.toStringAsFixed(1)));
          life.changed();
        }),
      ])),
      const SectionTitle('Marketing & team'),
      Panel(child: Column(children: <Widget>[
        Row(children: <Widget>[
          const Text('Marketing level', style: TextStyle(fontWeight: FontWeight.w800)),
          Expanded(child: Slider(value: c.marketing.toDouble(), min: 0, max: 5, divisions: 5, label: '${c.marketing}', onChanged: (double v) {
            CompanyEngine.setMarketing(c, v.round());
            life.changed();
          })),
          Text('${money(c.marketing * 10.0)}/day'),
        ]),
        Row(children: <Widget>[
          Expanded(child: Text('Employees: ${c.employees}/${Company.maxEmployees}  (${money(Company.wagePerDay)}/day each)', style: const TextStyle(fontWeight: FontWeight.w800))),
          IconButton(onPressed: () {
            final String? err = CompanyEngine.release(c);
            life.report(err == null ? const ActionResult.ok('Employee let go.') : ActionResult.fail(err));
          }, icon: const Icon(Icons.remove_circle_outline_rounded)),
          IconButton(onPressed: () {
            final String? err = CompanyEngine.hire(c);
            life.report(err == null ? const ActionResult.ok('Hired a new employee.') : ActionResult.fail(err));
          }, icon: const Icon(Icons.add_circle_rounded, color: LifeColors.green)),
        ]),
      ])),
      const SizedBox(height: 12),
      BigButton(label: 'Work in the business (4 hours)', icon: Icons.storefront_rounded, color: LifeColors.blue, onPressed: () => life.report(g.workOnCompany())),
      const SizedBox(height: 8),
      BigButton(label: 'Take profits home (${money(CompanyEngine.withdrawable(c))})', icon: Icons.account_balance_wallet_rounded, color: LifeColors.teal, onPressed: () => life.report(g.companyWithdraw())),
      const SizedBox(height: 20),
      const Text('Each night the business serves customers: demand depends on reputation, marketing, staff and price; costs include wages and fixed fees. Working there yourself boosts capacity.', style: TextStyle(color: LifeColors.muted, fontSize: 12.5)),
    ];
  }

  Widget _kpi(String k, String v, Color c) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: LifeColors.panel, borderRadius: BorderRadius.circular(12)),
        child: Column(children: <Widget>[Text(k, style: const TextStyle(color: LifeColors.muted, fontSize: 11.5, fontWeight: FontWeight.w700)), Text(v, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 18))]),
      );
}
