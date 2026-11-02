import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_branding.dart';
import '../config/legal_urls.dart';
import '../theme/study_theme.dart';

/// In-app Privacy Policy / Terms — required for store listings.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.kind,
  });

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final bool privacy = kind == LegalDocumentKind.privacy;
    final String title = privacy ? 'Privacy Policy' : 'Terms of Service';
    final String body = privacy ? _privacyBody : _termsBody;
    final Uri? web = privacy ? LegalUrls.privacyPolicy : LegalUrls.termsOfService;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: <Widget>[
          Text(
            '$title · ${AppBranding.name}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: July 29, 2026',
            style: TextStyle(
              color: StudyColors.textSecondary(Theme.of(context).brightness),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            body,
            style: const TextStyle(height: 1.5, fontSize: 14),
          ),
          if (web != null) ...<Widget>[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => launchUrl(web, mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text('Open on web'),
            ),
          ],
        ],
      ),
    );
  }
}

enum LegalDocumentKind { privacy, terms }

const String _privacyBody = '''
GradeGlow ("we", "our", or "us") provides an AI-powered study assistant and learning tools.

1. Information we collect
• Account data: email, display name, school/major you choose to add, and authentication identifiers from Google or Apple Sign-In.
• Study content: notes, uploads, flashcards, quizzes, chat messages with the AI Tutor / AI Professor, and progress you create in the app.
• Usage data: feature usage, device type, crash logs (when crash reporting is enabled), and approximate diagnostics needed to keep the service reliable.
• Payment data: if you subscribe through the App Store or Google Play, those stores process payments. We receive subscription status, not your full card number.

2. How we use information
• To provide tutoring, summaries, quizzes, Virtual University lessons, and progress tracking.
• To enforce free-tier limits and (when billing is live) Premium entitlements.
• To improve reliability, prevent abuse, and comply with law.
• AI features send relevant lesson or note text to our AI providers solely to generate your requested response. Do not submit secrets, passwords, or sensitive personal data you do not want processed by AI.

3. Sharing
We do not sell your personal information. We share data with:
• Firebase / Google Cloud (auth, database, storage)
• AI providers (e.g. OpenAI) for features you invoke
• Apple / Google for sign-in and (when enabled) subscriptions
• Service providers under contract who help us operate the app

4. Retention & deletion
You can delete your account in Settings. Deletion schedules permanent removal after a 30-day recovery window, then removes Firestore data, Storage files, and the auth account as described in-app.

5. Children
GradeGlow is not directed at children under 13. If you believe a child provided data, contact us to delete it.

6. Your choices
• Access and update profile fields in Settings.
• Sign out or delete your account.
• Limit AI features by not using Tutor / Professor / summarizer tools.

7. Contact
Privacy questions: privacy@gradeglow.app (or the support email listed on our website).

This in-app policy is the controlling summary for the mobile apps. If a hosted web policy is published, that page may include additional region-specific disclosures.
''';

const String _termsBody = '''
Welcome to GradeGlow. By using the app you agree to these Terms.

1. The service
GradeGlow offers study tools (notes, flashcards, quizzes, AI tutoring) and educational Virtual University experiences. Content is for learning support only. GradeGlow is not an accredited university and does not grant official college credit unless explicitly stated in a future partnership.

2. Accounts
You must provide accurate information and keep your credentials secure. You are responsible for activity under your account.

3. Acceptable use
You may not: abuse AI quotas, reverse-engineer the app for harm, upload illegal content, harass others, attempt to bypass paywalls or security, or use the service to cheat on exams in violation of your school's rules.

4. AI outputs
AI-generated explanations, grades, and certificates of completion inside the app are educational aids. Verify important facts independently. Do not rely on AI output as professional, legal, medical, or academic advice.

5. Subscriptions
Paid plans (when available through the App Store or Google Play) renew according to store rules. Manage or cancel in your store account settings. Demo or beta unlocks are not a paid entitlement.

6. Intellectual property
App software, branding, and curated curricula remain ours or our licensors'. Your uploaded notes remain yours; you grant us a license to process them to provide the features you request.

7. Disclaimers
The service is provided "as is." We do not guarantee uninterrupted availability, perfect AI accuracy, or exam outcomes.

8. Limitation of liability
To the fullest extent permitted by law, GradeGlow is not liable for indirect or consequential damages arising from use of the app.

9. Termination
We may suspend accounts that violate these Terms. You may stop using the app and delete your account at any time.

10. Changes
We may update these Terms. Continued use after an in-app update constitutes acceptance of the revised Terms.

11. Contact
support@gradeglow.app
''';
