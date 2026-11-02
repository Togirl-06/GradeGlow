import 'package:flutter/foundation.dart';

import '../utils/open_checkout.dart';

/// Billing interval for Premium study tools.
enum BillingInterval {
  monthly,
  semester,
  annual,
}

/// One Premium purchase option (monthly / semester / annual).
class BillingPlanOption {
  const BillingPlanOption({
    required this.interval,
    required this.label,
    required this.priceAmount,
    required this.priceLabel,
    required this.suffix,
    required this.amountCents,
    this.perMonthLabel,
    this.savingsLabel,
  });

  final BillingInterval interval;
  final String label;
  final String priceAmount;
  final String priceLabel;
  final String suffix;
  final int amountCents;
  final String? perMonthLabel;
  final String? savingsLabel;

  String get apiInterval {
    switch (interval) {
      case BillingInterval.monthly:
        return 'monthly';
      case BillingInterval.semester:
        return 'semester';
      case BillingInterval.annual:
        return 'annual';
    }
  }
}

/// Public Stripe checkout for GradeGlow Premium.
///
/// Checkout Sessions are created by `createStripeCheckout` (correct prices).
/// `confirmStripeCheckout` + `stripeWebhook` set `users/{uid}.plan`.
abstract final class BillingConfig {
  static const String premiumMonthlyPrice = r'$6.99';
  static const String premiumPriceAmount = '6.99';
  static const String premiumSemesterPrice = r'$19.99';
  static const String premiumSemesterAmount = '19.99';
  static const String premiumAnnualPrice = r'$49.99';
  static const String premiumAnnualAmount = '49.99';

  static const int freeTrialDays = 30;
  static const String trialLabel = '30-DAY FREE TRIAL';
  static const String trialFooter = '30-day free trial · Cancel anytime';

  static const List<BillingPlanOption> plans = <BillingPlanOption>[
    BillingPlanOption(
      interval: BillingInterval.monthly,
      label: 'Monthly',
      priceAmount: premiumPriceAmount,
      priceLabel: premiumMonthlyPrice,
      suffix: '/month after trial',
      amountCents: 699,
    ),
    BillingPlanOption(
      interval: BillingInterval.semester,
      label: 'Semester',
      priceAmount: premiumSemesterAmount,
      priceLabel: premiumSemesterPrice,
      suffix: '/4 months',
      amountCents: 1999,
      perMonthLabel: r'~$5.00/mo',
      savingsLabel: 'Save 28%',
    ),
    BillingPlanOption(
      interval: BillingInterval.annual,
      label: 'Annual',
      priceAmount: premiumAnnualAmount,
      priceLabel: premiumAnnualPrice,
      suffix: '/year',
      amountCents: 4999,
      perMonthLabel: r'~$4.17/mo',
      savingsLabel: 'Best value',
    ),
  ];

  static BillingPlanOption planFor(BillingInterval interval) {
    return plans.firstWhere((BillingPlanOption p) => p.interval == interval);
  }

  static const String checkoutCta = 'Start free trial';

  static String priceFootnoteFor(BillingPlanOption plan) {
    switch (plan.interval) {
      case BillingInterval.monthly:
        return '${plan.priceLabel}/month after the 30-day free trial. Cancel anytime.';
      case BillingInterval.semester:
        return '${plan.priceLabel} covers 4 months of Premium. Secure checkout via Stripe.';
      case BillingInterval.annual:
        return '${plan.priceLabel}/year after trial. Cancel anytime.';
    }
  }

  /// Default monthly footnote (compat for older screens).
  static String get priceFootnote =>
      priceFootnoteFor(planFor(BillingInterval.monthly));

  /// Direct Cloud Function URLs (more reliable than Hosting rewrites for JSON errors).
  static const String _functionsBase =
      'https://us-central1-ai-studybuddy-1fad1.cloudfunctions.net';

  static Uri createCheckoutUri() =>
      Uri.parse('$_functionsBase/createStripeCheckout');

  static Uri confirmCheckoutUri() =>
      Uri.parse('$_functionsBase/confirmStripeCheckout');

  static String webSuccessUrl() {
    final String origin = kIsWeb
        ? Uri.base.origin
        : 'https://gradeglow-virtualuni.web.app';
    return '$origin/?billing=success&session_id={CHECKOUT_SESSION_ID}';
  }

  static String webCancelUrl() {
    final String origin = kIsWeb
        ? Uri.base.origin
        : 'https://gradeglow-virtualuni.web.app';
    return '$origin/?billing=cancel';
  }

  /// Legacy Payment Link (Dashboard). Prefer Checkout Sessions for correct prices.
  static const String legacyPaymentLinkPath = '5kQ14h1yc4b74fIdU8bV600';

  static Uri legacyPaymentLinkUri({String? userId, String? email}) {
    return Uri.https('buy.stripe.com', '/$legacyPaymentLinkPath', <String, String>{
      if (userId != null && userId.isNotEmpty) 'client_reference_id': userId,
      if (email != null && email.isNotEmpty) 'prefilled_email': email,
    });
  }

  /// Opens Stripe Checkout (hard redirect on web).
  static Future<bool> openCheckoutUrl(String url) {
    return openCheckoutInBrowser(url);
  }

  static Future<bool> openLegacyPaymentLink({
    String? userId,
    String? email,
  }) {
    return openCheckoutUrl(
      legacyPaymentLinkUri(userId: userId, email: email).toString(),
    );
  }

  static String checkoutOpenedMessage() {
    if (kIsWeb) {
      return 'Redirecting to secure Stripe checkout…';
    }
    return 'Finish checkout in your browser. Premium unlocks when payment confirms.';
  }
}
