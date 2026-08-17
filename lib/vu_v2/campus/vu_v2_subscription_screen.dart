import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/billing_config.dart';
import '../../services/subscription_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2SubscriptionScreen extends StatelessWidget {
  const VuV2SubscriptionScreen({super.key, required this.progress});

  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          const Text(
            'The Virtual University is free for every student — lectures, labs, '
            'AI Professor, quizzes, and certificates. Premium is optional study-tool extras.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
          const SizedBox(height: 16),
          _PlanCard(
            title: 'Campus',
            price: r'$0',
            bullets: const <String>[
              'Full Virtual University access',
              'AI Professor lectures',
              'Professional labs',
              'Quizzes, exams & certificates',
            ],
            selected: true,
            cta: 'Included for everyone',
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Premium',
            price: '${BillingConfig.premiumMonthlyPrice} / mo',
            bullets: const <String>[
              '${BillingConfig.freeTrialDays}-day free trial',
              'Then ${BillingConfig.premiumMonthlyPrice}/month',
              'Unlimited tutor chat, live voice & study tools',
              'Campus stays free either way',
            ],
            accent: true,
            cta: BillingConfig.checkoutCta,
            onTap: () async {
              final SubscriptionService subs = context.read<SubscriptionService>();
              final bool ok = await subs.startPremiumCheckout();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? BillingConfig.checkoutOpenedMessage()
                        : 'Could not open checkout. Try Plans & features from Settings.',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            BillingConfig.priceFootnote,
            style: TextStyle(color: VuV2Colors.mute, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.completedLessonIds.length} campus lessons completed — all included at no cost.',
            style: const TextStyle(color: VuV2Colors.mute, height: 1.4, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.bullets,
    required this.cta,
    this.selected = false,
    this.onTap,
    this.accent = false,
  });

  final String title;
  final String price;
  final List<String> bullets;
  final bool selected;
  final String cta;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              if (selected)
                Text(
                  'INCLUDED',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: accent ? VuV2Colors.orange : VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (String b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $b', style: const TextStyle(color: VuV2Colors.mute)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accent ? VuV2Colors.orange : VuV2Colors.navyElevated,
                foregroundColor: Colors.white,
                disabledBackgroundColor: VuV2Colors.navyElevated.withValues(alpha: 0.5),
              ),
              child: Text(cta, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
