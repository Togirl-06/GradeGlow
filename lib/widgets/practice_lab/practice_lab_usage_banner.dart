import 'package:flutter/material.dart';

import '../../theme/practice_lab_game_theme.dart';
import '../../screens/membership_screen.dart';

/// Shows free-tier session allowance on hub screens.
class PracticeLabUsageBanner extends StatelessWidget {
  const PracticeLabUsageBanner({
    super.key,
    required this.remaining,
    required this.limit,
    required this.isPremium,
  });

  final int remaining;
  final int limit;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final PracticeLabColors lab = context.practiceLab;

    if (isPremium) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lab.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: lab.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.verified_rounded, color: lab.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Virtual University labs are free for every student',
                style: TextStyle(color: lab.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final bool atLimit = remaining <= 0;
    return Material(
      color: atLimit ? lab.danger.withValues(alpha: 0.12) : lab.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MembershipScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: atLimit ? lab.danger.withValues(alpha: 0.35) : lab.border),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                atLimit ? Icons.lock_rounded : Icons.bolt_rounded,
                color: atLimit ? lab.danger : lab.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  atLimit
                      ? 'No free sessions left this month — upgrade for unlimited labs'
                      : '$remaining of $limit free AI sessions left this month',
                  style: TextStyle(
                    color: atLimit ? lab.danger : lab.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: lab.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
