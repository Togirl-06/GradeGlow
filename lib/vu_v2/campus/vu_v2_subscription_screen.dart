import 'package:flutter/material.dart';

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
            'Campus Premium unlocks unlimited AI Professor lessons and certificates. '
            'Store billing is coming soon — until then, use Free campus access.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
          const SizedBox(height: 16),
          _PlanCard(
            title: 'Free',
            price: '\$0',
            bullets: const <String>[
              'Lessons & notes',
              'AI Professor (fair-use limits)',
              'Quizzes & practice',
            ],
            selected: !progress.isPremium,
            cta: progress.isPremium ? 'Switch to Free' : 'Your current plan',
            onTap: progress.isPremium
                ? () async {
                    await progress.setPremium(false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Switched to Free plan')),
                      );
                    }
                  }
                : null,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Premium',
            price: '\$12 / mo',
            bullets: const <String>[
              'Unlimited AI Professor',
              'Full university access',
              'Quizzes & exams',
              'Certificates of completion',
            ],
            selected: progress.isPremium,
            accent: true,
            cta: progress.isPremium ? 'Your current plan' : 'Coming soon',
            onTap: null,
          ),
          const SizedBox(height: 16),
          const Text(
            'When billing goes live, you will upgrade through the App Store or Google Play. '
            'We no longer offer one-tap demo Premium unlocks.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4, fontSize: 13),
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
    required this.selected,
    required this.cta,
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
                  'CURRENT',
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
