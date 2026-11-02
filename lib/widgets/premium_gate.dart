import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/membership_screen.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';

/// Shows [child] for Premium users; otherwise an upgrade prompt.
class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.icon = Icons.workspace_premium_rounded,
  });

  final String title;
  final String description;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    if (isPremium) return child;

    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 56, color: StudyColors.accent),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.45, fontSize: 15),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: StudyColors.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
