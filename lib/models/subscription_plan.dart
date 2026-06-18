enum SubscriptionPlan {
  free,
  premium,
  premiumPlus;

  static SubscriptionPlan fromString(String? value) {
    return switch (value) {
      'premium' => SubscriptionPlan.premium,
      'premium_plus' => SubscriptionPlan.premiumPlus,
      _ => SubscriptionPlan.free,
    };
  }

  String get firestoreValue => switch (this) {
        SubscriptionPlan.free => 'free',
        SubscriptionPlan.premium => 'premium',
        SubscriptionPlan.premiumPlus => 'premium_plus',
      };

  String get label => switch (this) {
        SubscriptionPlan.free => 'Free',
        SubscriptionPlan.premium => 'Premium',
        SubscriptionPlan.premiumPlus => 'Premium',
      };

  String get priceLabel => switch (this) {
        SubscriptionPlan.free => r'$0',
        SubscriptionPlan.premium => r'$7.99/month',
        SubscriptionPlan.premiumPlus => r'$7.99/month',
      };

  bool get isPaid => this != SubscriptionPlan.free;
}
