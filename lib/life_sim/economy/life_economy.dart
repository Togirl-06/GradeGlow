import 'shop_catalog.dart';

/// Income tax withheld from every payslip.
const double kIncomeTaxRate = 0.15;

class LedgerEntry {
  const LedgerEntry({
    required this.day,
    required this.label,
    required this.amount,
    required this.category,
  });

  final int day;
  final String label;

  /// Positive = income, negative = expense.
  final double amount;
  final String category;

  Map<String, Object?> toJson() => <String, Object?>{
        'day': day,
        'label': label,
        'amount': amount,
        'category': category,
      };

  factory LedgerEntry.fromJson(Map<String, Object?> json) => LedgerEntry(
        day: (json['day'] as num?)?.toInt() ?? 1,
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: json['category'] as String? ?? 'other',
      );
}

/// Cash, savings, debt, inventory and housing. All deterministic.
class LifeEconomy {
  LifeEconomy({
    this.cash = 600,
    this.savings = 0,
    this.debt = 0,
    this.housingId = 'shared_room',
    this.transitPass = false,
    this.lastBillDay = 1,
    this.missedRentMonths = 0,
    List<LedgerEntry>? ledger,
    Map<String, int>? inventory,
    List<String>? placedFurniture,
  })  : ledger = ledger ?? <LedgerEntry>[],
        inventory = inventory ?? <String, int>{},
        placedFurniture = placedFurniture ?? <String>[];

  static const int maxLedger = 150;

  double cash;
  double savings;
  double debt;
  String housingId;
  bool transitPass;
  int lastBillDay;
  int missedRentMonths;
  final List<LedgerEntry> ledger;

  /// itemId → quantity. Furniture/clothing are 0/1, groceries are meal count.
  final Map<String, int> inventory;

  /// Furniture ids currently placed in the apartment (limited by slots).
  final List<String> placedFurniture;

  Housing get housing => ShopCatalog.housingById(housingId);
  double get netWorth => cash + savings - debt;

  void _log(int day, String label, double amount, String category) {
    ledger.add(LedgerEntry(day: day, label: label, amount: amount, category: category));
    while (ledger.length > maxLedger) {
      ledger.removeAt(0);
    }
  }

  bool canAfford(double amount) => cash + 0.0001 >= amount;

  bool spend(double amount, String label, String category, int day) {
    if (amount < 0 || !canAfford(amount)) return false;
    cash -= amount;
    if (amount > 0) _log(day, label, -amount, category);
    return true;
  }

  void earn(double amount, String label, String category, int day) {
    if (amount <= 0) return;
    cash += amount;
    _log(day, label, amount, category);
  }

  /// Pays a salary: withholds tax and returns the net amount.
  double payWage(double gross, String label, int day) {
    final double tax = (gross * kIncomeTaxRate * 100).round() / 100;
    final double net = gross - tax;
    cash += net;
    _log(day, '$label (gross ${gross.toStringAsFixed(2)}, tax ${tax.toStringAsFixed(2)})', net, 'income');
    return net;
  }

  bool deposit(double amount, int day) {
    if (amount <= 0 || !canAfford(amount)) return false;
    cash -= amount;
    savings += amount;
    _log(day, 'Moved to savings', 0, 'savings');
    return true;
  }

  bool withdraw(double amount, int day) {
    if (amount <= 0 || savings + 0.0001 < amount) return false;
    savings -= amount;
    cash += amount;
    _log(day, 'Withdrew from savings', 0, 'savings');
    return true;
  }

  /// Repays debt from cash. Returns the amount actually repaid.
  double repayDebt(double amount, int day) {
    final double pay = amount.clamp(0, debt).clamp(0, cash).toDouble();
    if (pay <= 0) return 0;
    cash -= pay;
    debt -= pay;
    _log(day, 'Debt repayment', -pay, 'debt');
    return pay;
  }

  int count(String itemId) => inventory[itemId] ?? 0;
  bool owns(String itemId) => count(itemId) > 0;

  /// Buys an item. Returns null on success or an error message.
  String? buy(ShopItem item, int day) {
    if (!canAfford(item.price)) {
      return 'Not enough cash (need \$${item.price.toStringAsFixed(0)}).';
    }
    if (!item.stackable &&
        item.category != ShopCategory.food &&
        item.category != ShopCategory.entertainment &&
        owns(item.id)) {
      return 'You already own ${item.name}.';
    }
    spend(item.price, item.name, item.category.name, day);
    if (item.id == 'groceries') {
      inventory['groceries'] = count('groceries') + ShopCatalog.mealsPerGroceryBag;
    } else if (item.id == 'transit_pass') {
      transitPass = true;
      inventory[item.id] = 1;
    } else if (item.category == ShopCategory.clothing ||
        item.category == ShopCategory.furniture) {
      inventory[item.id] = 1;
    }
    return null;
  }

  bool useMeal() {
    final int n = count('groceries');
    if (n <= 0) return false;
    inventory['groceries'] = n - 1;
    return true;
  }

  /// Places owned furniture if there is a free slot. Returns an error or null.
  String? placeFurniture(String id) {
    if (!owns(id)) return 'You do not own that item.';
    if (placedFurniture.contains(id)) return 'Already placed.';
    if (placedFurniture.length >= housing.slots) {
      return 'No free slots — ${housing.name} fits ${housing.slots} items.';
    }
    placedFurniture.add(id);
    return null;
  }

  void removeFurniture(String id) => placedFurniture.remove(id);

  /// Total home comfort (housing + placed furniture), capped at 10.
  double get comfort {
    double c = housing.comfort;
    for (final String id in placedFurniture) {
      c += ShopCatalog.item(id)?.comfort ?? 0;
    }
    return c.clamp(0, 10).toDouble();
  }

  double get professionalism {
    double p = 0;
    for (final MapEntry<String, int> e in inventory.entries) {
      if (e.value <= 0) continue;
      final ShopItem? item = ShopCatalog.item(e.key);
      if (item != null && item.category == ShopCategory.clothing) {
        p += item.professionalism;
      }
    }
    return p.clamp(0, 10).toDouble();
  }

  double get monthlyFixedCosts =>
      housing.rent + ShopCatalog.utilitiesPerMonth + (transitPass ? ShopCatalog.transitPassPerMonth : 0);

  /// Moves to a new home: first month's rent is charged up front.
  String? moveTo(Housing h, int day) {
    if (h.id == housingId) return 'You already live here.';
    if (!canAfford(h.rent)) {
      return 'Moving in needs the first month up front (\$${h.rent.toStringAsFixed(0)}).';
    }
    spend(h.rent, 'Move-in: ${h.name}', 'housing', day);
    housingId = h.id;
    while (placedFurniture.length > h.slots) {
      placedFurniture.removeLast();
    }
    lastBillDay = day;
    return null;
  }

  /// Processes monthly bills due on [today]. Returns human-readable events.
  List<String> processBills(int today) {
    final List<String> events = <String>[];
    while (today - lastBillDay >= ShopCatalog.billingPeriodDays) {
      lastBillDay += ShopCatalog.billingPeriodDays;
      final double bill = monthlyFixedCosts;
      double remaining = bill;
      final double fromCash = remaining.clamp(0, cash).toDouble();
      cash -= fromCash;
      remaining -= fromCash;
      if (remaining > 0) {
        final double fromSavings = remaining.clamp(0, savings).toDouble();
        savings -= fromSavings;
        remaining -= fromSavings;
      }
      _log(lastBillDay, 'Rent + utilities${transitPass ? ' + transit pass' : ''}', -bill, 'bills');
      if (remaining > 0) {
        debt += remaining;
        missedRentMonths += 1;
        events.add(
          'You could not cover \$${remaining.toStringAsFixed(0)} of this month\'s bills. '
          'It was added to your debt.',
        );
      } else {
        missedRentMonths = 0;
        events.add('Paid rent and utilities: \$${bill.toStringAsFixed(0)}.');
      }
      if (debt > 0) {
        final double interest = (debt * 0.03 * 100).round() / 100;
        debt += interest;
        events.add('Debt interest charged: \$${interest.toStringAsFixed(2)}.');
      }
      if (missedRentMonths >= 2 && housingId != 'shared_room') {
        housingId = 'shared_room';
        placedFurniture.clear();
        missedRentMonths = 0;
        events.add('You were evicted and moved into a shared room.');
      }
    }
    return events;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'cash': cash,
        'savings': savings,
        'debt': debt,
        'housingId': housingId,
        'transitPass': transitPass,
        'lastBillDay': lastBillDay,
        'missedRentMonths': missedRentMonths,
        'ledger': ledger.map((LedgerEntry e) => e.toJson()).toList(),
        'inventory': inventory,
        'placedFurniture': placedFurniture,
      };

  factory LifeEconomy.fromJson(Map<String, Object?> json) {
    final Object? rawLedger = json['ledger'];
    final Object? rawInv = json['inventory'];
    final Object? rawPlaced = json['placedFurniture'];
    return LifeEconomy(
      cash: (json['cash'] as num?)?.toDouble() ?? 600,
      savings: (json['savings'] as num?)?.toDouble() ?? 0,
      debt: (json['debt'] as num?)?.toDouble() ?? 0,
      housingId: json['housingId'] as String? ?? 'shared_room',
      transitPass: json['transitPass'] as bool? ?? false,
      lastBillDay: (json['lastBillDay'] as num?)?.toInt() ?? 1,
      missedRentMonths: (json['missedRentMonths'] as num?)?.toInt() ?? 0,
      ledger: rawLedger is List
          ? rawLedger
              .whereType<Map>()
              .map((Map m) => LedgerEntry.fromJson(Map<String, Object?>.from(m)))
              .toList()
          : <LedgerEntry>[],
      inventory: rawInv is Map
          ? rawInv.map((Object? k, Object? v) =>
              MapEntry<String, int>(k.toString(), (v as num?)?.toInt() ?? 0))
          : <String, int>{},
      placedFurniture:
          rawPlaced is List ? rawPlaced.map((Object? e) => e.toString()).toList() : <String>[],
    );
  }
}
