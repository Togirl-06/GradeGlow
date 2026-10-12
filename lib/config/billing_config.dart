import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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
    required this.checkoutPath,
    this.perMonthLabel,
    this.savingsLabel,
  });

  final BillingInterval interval;
  final String label;
  final String priceAmount;
  final String priceLabel;
  final String suffix;
  /// Stripe Payment Link path after buy.stripe.com/
  final String checkoutPath;
  final String? perMonthLabel;
  final String? savingsLabel;

  Uri checkoutUri({String? clientReferenceId, String? email}) {
    return Uri.https('buy.stripe.com', '/$checkoutPath', <String, String>{
      if (clientReferenceId != null && clientReferenceId.isNotEmpty)
        'client_reference_id': clientReferenceId,
      if (email != null && email.isNotEmpty) 'prefilled_email': email,
    });
  }
}

/// Public Stripe checkout for GradeGlow Premium.
///
/// Create matching Payment Links in Stripe Dashboard for each price, then
/// paste the link IDs below. Webhook `stripeWebhook` sets `users/{uid}.plan`.
abstract final class BillingConfig {
  static const String premiumMonthlyPrice = r'$6.99';
  static const String premiumPriceAmount = '6.99';
  static const String premiumSemesterPrice = r'$19.99';
  static const String premiumSemesterAmount = '19.99';
  static const String premiumAnnualPrice = r'$49.99';
  static const String premiumAnnualAmount = '49.99';

  static const int freeTrialDays = 30;
  static const String trialLabel = '30 DAYS FREE';
  static const String trialFooter =
      '30 days free · No card required · Cancel anytime';

  /// Student discount when paying with a verified .edu email (Stripe coupon).
  static const int eduDiscountPercent = 15;
  static const String eduDiscountLabel =
      '15% off with a .edu email (verify at checkout)';

  /// Replace these with Payment Link IDs from Stripe Dashboard
  /// (Products → Payment links). Until replaced, monthly still uses the
  /// existing live link — update that product to $6.99/mo + 30-day trial.
  static const String monthlyCheckoutPath = '5kQ14h1yc4b74fIdU8bV600';
  static const String semesterCheckoutPath = '5kQ14h1yc4b74fIdU8bV600';
  static const String annualCheckoutPath = '5kQ14h1yc4b74fIdU8bV600';

  static const List<BillingPlanOption> plans = <BillingPlanOption>[
    BillingPlanOption(
      interval: BillingInterval.monthly,
      label: 'Monthly',
      priceAmount: premiumPriceAmount,
      priceLabel: premiumMonthlyPrice,
      suffix: '/ month after trial',
      checkoutPath: monthlyCheckoutPath,
    ),
    BillingPlanOption(
      interval: BillingInterval.semester,
      label: 'Semester',
      priceAmount: premiumSemesterAmount,
      priceLabel: premiumSemesterPrice,
      suffix: '/ 4 months',
      checkoutPath: semesterCheckoutPath,
      perMonthLabel: r'~$5.00/mo',
      savingsLabel: 'Save 28%',
    ),
    BillingPlanOption(
      interval: BillingInterval.annual,
      label: 'Annual',
      priceAmount: premiumAnnualAmount,
      priceLabel: premiumAnnualPrice,
      suffix: '/ year',
      checkoutPath: annualCheckoutPath,
      perMonthLabel: r'~$4.17/mo',
      savingsLabel: 'Save 40%',
    ),
  ];

  static BillingPlanOption planFor(BillingInterval interval) {
    return plans.firstWhere((BillingPlanOption p) => p.interval == interval);
  }

  static const String checkoutCta = 'Start 30-day free trial';

  static String priceFootnoteFor(BillingPlanOption plan) {
    switch (plan.interval) {
      case BillingInterval.monthly:
        return '${plan.priceLabel}/month after the 30-day free trial. Cancel anytime.';
      case BillingInterval.semester:
        return '${plan.priceLabel} for 4 months after trial. Cancel anytime.';
      case BillingInterval.annual:
        return '${plan.priceLabel}/year after trial. Cancel anytime.';
    }
  }

  /// Default monthly footnote (compat for older screens).
  static String get priceFootnote =>
      priceFootnoteFor(planFor(BillingInterval.monthly));

  static Future<bool> openStripeCheckout({
    BillingInterval interval = BillingInterval.monthly,
    String? userId,
    String? email,
  }) {
    final BillingPlanOption plan = planFor(interval);
    return launchUrl(
      plan.checkoutUri(clientReferenceId: userId, email: email),
      mode: LaunchMode.externalApplication,
    );
  }

  static String checkoutOpenedMessage() {
    if (kIsWeb) {
      return 'Finish checkout in the new tab. Premium unlocks after Stripe confirms payment.';
    }
    return 'Finish checkout in your browser. Premium unlocks after Stripe confirms payment.';
  }

  static bool isEduEmail(String? email) {
    if (email == null) return false;
    final String e = email.trim().toLowerCase();
    return e.endsWith('.edu') || e.contains('.edu.');
  }
}
