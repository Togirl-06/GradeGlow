/// Items, housing and prices for the GradeGlow virtual economy.
///
/// Money is virtual dollars (`$`). Prices are intentionally close to real-life
/// proportions so students learn budgeting.
library;

enum ShopCategory { food, clothing, furniture, transport, entertainment }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.price,
    this.effects = const <String, double>{},
    this.minutes = 0,
    this.comfort = 0,
    this.professionalism = 0,
    this.stackable = false,
    this.blurb = '',
  });

  final String id;
  final String name;
  final String emoji;
  final ShopCategory category;
  final double price;

  /// Need deltas applied when used/consumed (`hunger`, `energy`, …).
  final Map<String, double> effects;

  /// Game minutes consumed when used.
  final int minutes;

  /// Added to home comfort (0..10 scale in total) when owned furniture.
  final double comfort;

  /// Added to interview/work professionalism when owned clothing.
  final double professionalism;

  /// Consumable stock (groceries) vs one-time purchase.
  final bool stackable;
  final String blurb;
}

class Housing {
  const Housing({
    required this.id,
    required this.name,
    required this.rent,
    required this.comfort,
    required this.blurb,
    this.slots = 4,
  });

  final String id;
  final String name;
  final double rent;

  /// Base comfort of the place (0..10 scale).
  final double comfort;
  final String blurb;

  /// How many furniture pieces fit.
  final int slots;
}

class ShopCatalog {
  const ShopCatalog._();

  static const double utilitiesPerMonth = 80;
  static const double transitPassPerMonth = 60;
  static const double commuteFare = 6;
  static const int billingPeriodDays = 30;

  static const List<Housing> housing = <Housing>[
    Housing(
      id: 'shared_room',
      name: 'Shared room',
      rent: 350,
      comfort: 1,
      slots: 2,
      blurb: 'A bed in a shared flat. Cheap, noisy, close to campus.',
    ),
    Housing(
      id: 'studio',
      name: 'Studio apartment',
      rent: 700,
      comfort: 3,
      slots: 4,
      blurb: 'Your own space with a small kitchen.',
    ),
    Housing(
      id: 'one_bed',
      name: 'One-bedroom apartment',
      rent: 1100,
      comfort: 5,
      slots: 6,
      blurb: 'Separate bedroom and living area.',
    ),
    Housing(
      id: 'penthouse',
      name: 'Skyline penthouse',
      rent: 2200,
      comfort: 8,
      slots: 8,
      blurb: 'Top-floor views. Needs a senior salary.',
    ),
  ];

  static const List<ShopItem> food = <ShopItem>[
    ShopItem(
      id: 'snack',
      name: 'Snack',
      emoji: '🍪',
      category: ShopCategory.food,
      price: 3,
      effects: <String, double>{'hunger': 15, 'happiness': 2},
      minutes: 5,
      blurb: 'Quick bite. Eaten on the spot.',
    ),
    ShopItem(
      id: 'coffee',
      name: 'Coffee',
      emoji: '☕',
      category: ShopCategory.food,
      price: 4,
      effects: <String, double>{'energy': 12, 'happiness': 2, 'hunger': 3},
      minutes: 10,
      blurb: 'A short energy boost.',
    ),
    ShopItem(
      id: 'restaurant_meal',
      name: 'Restaurant meal',
      emoji: '🍛',
      category: ShopCategory.food,
      price: 18,
      effects: <String, double>{'hunger': 55, 'happiness': 8, 'social': 6},
      minutes: 45,
      blurb: 'Sit-down meal. Good for the mood.',
    ),
    ShopItem(
      id: 'groceries',
      name: 'Groceries (5 meals)',
      emoji: '🛒',
      category: ShopCategory.food,
      price: 25,
      stackable: true,
      blurb: 'Adds 5 home-cooked meals to your fridge. Cheapest way to eat.',
    ),
  ];

  /// What one home-cooked meal gives.
  static const Map<String, double> homeMealEffects = <String, double>{
    'hunger': 45,
    'energy': 3,
    'happiness': 3,
  };
  static const int homeMealMinutes = 30;
  static const int mealsPerGroceryBag = 5;

  static const List<ShopItem> clothing = <ShopItem>[
    ShopItem(
      id: 'casual_outfit',
      name: 'Casual outfit',
      emoji: '👕',
      category: ShopCategory.clothing,
      price: 40,
      professionalism: 1,
      blurb: 'Everyday wear.',
    ),
    ShopItem(
      id: 'smart_shoes',
      name: 'Smart shoes',
      emoji: '👞',
      category: ShopCategory.clothing,
      price: 60,
      professionalism: 2,
      blurb: 'Polished shoes make a first impression.',
    ),
    ShopItem(
      id: 'business_suit',
      name: 'Business suit',
      emoji: '🕴️',
      category: ShopCategory.clothing,
      price: 120,
      professionalism: 4,
      blurb: 'Interview-ready. Raises your professionalism.',
    ),
    ShopItem(
      id: 'scrubs',
      name: 'Medical scrubs',
      emoji: '🥼',
      category: ShopCategory.clothing,
      price: 45,
      professionalism: 3,
      blurb: 'Required look for clinical roles.',
    ),
  ];

  static const List<ShopItem> furniture = <ShopItem>[
    ShopItem(
      id: 'plant',
      name: 'House plant',
      emoji: '🪴',
      category: ShopCategory.furniture,
      price: 20,
      comfort: 0.5,
      blurb: 'A little life for the room.',
    ),
    ShopItem(
      id: 'bookshelf',
      name: 'Bookshelf',
      emoji: '📚',
      category: ShopCategory.furniture,
      price: 90,
      comfort: 0.8,
      blurb: 'Study sessions at home give +10% skill.',
    ),
    ShopItem(
      id: 'sofa',
      name: 'Sofa',
      emoji: '🛋️',
      category: ShopCategory.furniture,
      price: 180,
      comfort: 1.5,
      blurb: 'Lets you relax at home.',
    ),
    ShopItem(
      id: 'desk_setup',
      name: 'Desk setup',
      emoji: '🖥️',
      category: ShopCategory.furniture,
      price: 150,
      comfort: 1,
      blurb: 'Better focus: home study restores less energy.',
    ),
    ShopItem(
      id: 'tv',
      name: 'Television',
      emoji: '📺',
      category: ShopCategory.furniture,
      price: 220,
      comfort: 1,
      blurb: 'Watch shows at home for happiness.',
    ),
    ShopItem(
      id: 'bed_upgrade',
      name: 'Quality mattress',
      emoji: '🛏️',
      category: ShopCategory.furniture,
      price: 300,
      comfort: 2,
      blurb: 'Sleep restores more energy.',
    ),
  ];

  static const List<ShopItem> transport = <ShopItem>[
    ShopItem(
      id: 'transit_pass',
      name: 'Monthly transit pass',
      emoji: '🚌',
      category: ShopCategory.transport,
      price: 60,
      blurb: 'Removes the \$6 commute fare. Billed every 30 days.',
    ),
  ];

  static const List<ShopItem> entertainment = <ShopItem>[
    ShopItem(
      id: 'cinema_ticket',
      name: 'Cinema ticket',
      emoji: '🎬',
      category: ShopCategory.entertainment,
      price: 12,
      effects: <String, double>{'happiness': 25, 'social': 8, 'energy': -5},
      minutes: 120,
    ),
    ShopItem(
      id: 'gym_pass',
      name: 'Gym session',
      emoji: '🏋️',
      category: ShopCategory.entertainment,
      price: 10,
      effects: <String, double>{
        'health': 8,
        'happiness': 10,
        'energy': -14,
        'hunger': -10,
      },
      minutes: 60,
    ),
  ];

  static List<ShopItem> get all => <ShopItem>[
        ...food,
        ...clothing,
        ...furniture,
        ...transport,
        ...entertainment,
      ];

  static ShopItem? item(String id) {
    for (final ShopItem i in all) {
      if (i.id == id) return i;
    }
    return null;
  }

  static Housing housingById(String id) {
    for (final Housing h in housing) {
      if (h.id == id) return h;
    }
    return housing.first;
  }
}
