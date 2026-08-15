/// Hosted legal URLs — set when you publish web pages; null uses in-app text only.
abstract final class LegalUrls {
  /// Optional public privacy policy page (null = in-app only).
  static final Uri? privacyPolicy = null;

  /// Optional public terms page (null = in-app only).
  static final Uri? termsOfService = null;

  static const String supportEmail = 'support@gradeglow.app';
  static const String privacyEmail = 'privacy@gradeglow.app';
}
