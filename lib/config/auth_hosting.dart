/// Firebase Auth / Hosting URLs for sign-in and out-of-band email actions.
abstract final class AuthHosting {
  AuthHosting._();

  static const String projectId = 'ai-studybuddy-1fad1';

  /// Where the Flutter web app is deployed today.
  static const String publicAppUrl = 'https://gradeglow-virtualuni.web.app';

  /// Public .com name once Hosting custom domain is Connected.
  static const String customDomainUrl = 'https://gradeglowuniversity.com';

  /// Firebase Auth handler domain (OAuth popup / default auth links).
  static const String authDomain = '$projectId.firebaseapp.com';

  /// Template Action URL (%LINK%) — Hosting site, not the old default firebaseapp.com.
  static const String emailActionUrl =
      'https://gradeglow-virtualuni.web.app/__/auth/action';

  /// Continue URL after verify-email / reset-password. Must be authorized in Firebase Console.
  static const String emailActionContinueUrl = publicAppUrl;

  /// Custom email sender domain — add DNS at your registrar, not on .web.app.
  static const String emailSenderDomain = 'gradeglowuniversity.com';

  /// From address after the custom email domain is verified.
  static const String emailFromAddress = 'noreply@$emailSenderDomain';
}
