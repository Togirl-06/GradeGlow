import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public Stripe checkout for GradeGlow Premium.
abstract final class BillingConfig {
  static const String premiumMonthlyPrice = r'$11.99';
  static const String premiumPriceAmount = '11.99';
  static const int freeTrialDays = 30;
  static const String trialLabel = '30 DAYS FREE';

  static final Uri stripeCheckout = Uri.parse(
    'https://buy.stripe.com/5kQ14h1yc4b74fIdU8bV600',
  );

  static const String checkoutCta = 'Start 30-day free trial';

  static const String priceFootnote =
      r'$11.99/month after the 30-day free trial. Cancel anytime.';

  static Future<bool> openStripeCheckout() {
    return launchUrl(stripeCheckout, mode: LaunchMode.externalApplication);
  }

  static String checkoutOpenedMessage() {
    if (kIsWeb) {
      return 'Finish checkout in the new tab. Campus stays free; Premium study tools unlock after Stripe confirms.';
    }
    return 'Finish checkout in your browser. Campus stays free; Premium study tools unlock after Stripe confirms.';
  }
}
