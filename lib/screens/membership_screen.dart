import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/billing_config.dart';
import '../models/membership_plans.dart';
import '../models/subscription_plan.dart';
import '../services/appearance_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';

/// Premium checkout matching the GradeGlow trial sales layout.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  BillingInterval _interval = BillingInterval.monthly;
  bool _checkoutBusy = false;
  bool _confirming = false;
  final Set<int> _openFaqs = <int>{};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleBillingReturn();
      });
    }
  }

  Future<void> _handleBillingReturn() async {
    if (_confirming || !mounted) return;
    final Uri uri = Uri.base;
    if (uri.queryParameters['billing'] != 'success') return;
    setState(() => _confirming = true);
    final SubscriptionService subs = context.read<SubscriptionService>();
    final bool unlocked = await subs.confirmCheckoutFromReturnUrl(uri);
    if (!mounted) return;
    setState(() => _confirming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          unlocked
              ? 'Premium is active. Welcome aboard.'
              : 'Payment received — Premium will unlock shortly.',
        ),
      ),
    );
    if (unlocked) await subs.loadPlan();
  }

  Future<void> _startCheckout() async {
    if (_checkoutBusy) return;
    final SubscriptionService subs = context.read<SubscriptionService>();
    if (subs.plan.isPaid) return;

    setState(() => _checkoutBusy = true);
    try {
      final bool ok = await subs.startPremiumCheckout(interval: _interval);
      if (!mounted) return;
      setState(() => _checkoutBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? BillingConfig.checkoutOpenedMessage()
                : (subs.lastCheckoutError ??
                    'Could not open checkout. Try again in a moment.'),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _checkoutBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SubscriptionService subs = context.watch<SubscriptionService>();
    final AppearanceService appearance = context.watch<AppearanceService>();
    final bool isPremium = subs.plan.isPaid;
    final BillingPlanOption billing = BillingConfig.planFor(_interval);
    final Brightness brightness = Theme.of(context).brightness;
    final Color accent = appearance.primaryColor;
    final Color bg = StudyColors.background(brightness);
    final Color card = StudyColors.surface(brightness);
    final Color ink = StudyColors.textPrimary(brightness);
    final Color mute = StudyColors.textSecondary(brightness);
    final Color stroke = StudyColors.border(brightness);
    final DateTime chargeDate =
        DateTime.now().add(Duration(days: BillingConfig.freeTrialDays));
    final String chargeLabel = DateFormat('MMM d').format(chargeDate);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: <Widget>[
              Text(
                'Study without limits.\nTry it free for 30 days.',
                style: TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Campus, lectures and labs stay free. Premium removes the caps '
                'on AI Tutor, study sets and uploads. Cancel any time before '
                'the trial ends — you will not be charged.',
                style: TextStyle(color: mute, fontSize: 14, height: 1.45),
              ),
              const SizedBox(height: 28),
              Text(
                'Pick how you want to pay',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _PayOptionCard(
                selected: _interval == BillingInterval.monthly,
                accent: accent,
                title: 'Monthly',
                subtitle: 'Flexible. Stop whenever you like.',
                price: BillingConfig.premiumMonthlyPrice,
                period: 'per month',
                onTap: () =>
                    setState(() => _interval = BillingInterval.monthly),
              ),
              const SizedBox(height: 10),
              _PayOptionCard(
                selected: _interval == BillingInterval.semester,
                accent: accent,
                title: 'Semester',
                subtitle:
                    'One payment covers 4 months. Works out to \$5.00 a month.',
                price: BillingConfig.premiumSemesterPrice,
                period: 'every 4 months',
                badge: 'Best for exams',
                onTap: () =>
                    setState(() => _interval = BillingInterval.semester),
              ),
              const SizedBox(height: 10),
              _PayOptionCard(
                selected: _interval == BillingInterval.annual,
                accent: accent,
                title: 'Annual',
                subtitle:
                    'Covers the whole school year. Works out to \$4.17 a month.',
                price: BillingConfig.premiumAnnualPrice,
                period: 'per year',
                badge: 'Save 40%',
                onTap: () =>
                    setState(() => _interval = BillingInterval.annual),
              ),
              const SizedBox(height: 22),
              Text(
                'What Premium adds',
                style: TextStyle(
                  color: ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _BenefitRow(
                      accent: accent,
                      title: 'Unlimited AI Tutor',
                      body: 'Chat as much as you want, or talk it out with live voice.',
                    ),
                    _BenefitRow(
                      accent: accent,
                      title: 'No caps on study sets, flashcards and quizzes',
                      body: 'Free covers 10 sets and 10 flashcards per course.',
                    ),
                    _BenefitRow(
                      accent: accent,
                      title: 'Unlimited uploads and export',
                      body:
                          'Files, images and recordings, with downloads. Free covers 5 uploads a day.',
                    ),
                    _BenefitRow(
                      accent: accent,
                      title: 'Exam prep tools',
                      body:
                          'Study guides, personalized plans and the Grade Predictor.',
                    ),
                    _BenefitRow(
                      accent: accent,
                      title: 'Faster AI, no ads, early access',
                      body: 'Quicker answers and first look at new features.',
                      isLast: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Not ready? Your Free plan keeps the full Virtual University, '
                      'lectures, labs, quizzes and certificates.',
                      style: TextStyle(color: mute, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your order',
                      style: TextStyle(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _OrderLine(
                      label: 'Plan',
                      value: 'Premium, ${billing.label.toLowerCase()}',
                      ink: ink,
                      mute: mute,
                    ),
                    const SizedBox(height: 8),
                    _OrderLine(
                      label: 'Price after trial',
                      value: _interval == BillingInterval.semester
                          ? '${billing.priceLabel} / 4 months'
                          : '${billing.priceLabel} / ${billing.label.toLowerCase() == 'annual' ? 'year' : 'month'}',
                      ink: ink,
                      mute: mute,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      'Due today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      r'$0.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _TrialTimeline(
                accent: accent,
                chargeLabel: chargeLabel,
                billing: billing,
                ink: ink,
                mute: mute,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: stroke),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isPremium || _checkoutBusy
                            ? null
                            : _startCheckout,
                        style: FilledButton.styleFrom(
                          backgroundColor: StudyColors.accent,
                          foregroundColor: const Color(0xFF1C1917),
                          disabledBackgroundColor:
                              StudyColors.accent.withValues(alpha: 0.4),
                          shape: const StadiumBorder(),
                        ),
                        child: _checkoutBusy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Color(0xFF1C1917),
                                ),
                              )
                            : Text(
                                isPremium
                                    ? 'Premium is active'
                                    : 'Start 30-day free trial',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No charge today. Cancel any time in Settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mute, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.lock_outline_rounded, size: 14, color: mute),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Payment is handled securely by Stripe. We never see your card.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: mute, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Questions students ask',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ..._faqEntries(accent, ink, mute, stroke),
            ],
          ),
          if (_confirming)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _faqEntries(
    Color accent,
    Color ink,
    Color mute,
    Color stroke,
  ) {
    const List<(String, String)> faqs = <(String, String)>[
      (
        'Do I need a card to start the trial?',
        'Yes — Stripe holds a payment method so the trial can convert if you keep Premium. You are not charged today.',
      ),
      (
        'How do I cancel?',
        'Open Settings → Premium (or your Stripe receipt email) and cancel before day 30. Access stays until the trial ends.',
      ),
      (
        'What happens to my work if I go back to Free?',
        'Everything you created stays. Free limits apply again for new Tutor messages, sets and uploads.',
      ),
      (
        'Will Premium sync on my phone and laptop?',
        'Yes. Your plan, theme and accent color follow your GradeGlow account on every device you sign into.',
      ),
    ];

    return <Widget>[
      for (int i = 0; i < faqs.length; i++) ...<Widget>[
        if (i > 0) Divider(height: 1, color: stroke),
        InkWell(
          onTap: () => setState(() {
            if (_openFaqs.contains(i)) {
              _openFaqs.remove(i);
            } else {
              _openFaqs.add(i);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        faqs[i].$1,
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (_openFaqs.contains(i)) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          faqs[i].$2,
                          style: TextStyle(
                            color: mute,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  _openFaqs.contains(i) ? Icons.remove : Icons.add,
                  color: accent,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}

class _PayOptionCard extends StatelessWidget {
  const _PayOptionCard({
    required this.selected,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final Color accent;
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color ink = StudyColors.textPrimary(brightness);
    final Color mute = StudyColors.textSecondary(brightness);
    final Color card = StudyColors.surface(brightness);

    return Material(
      color: card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : StudyColors.border(brightness),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? accent : mute,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (badge != null) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: StudyColors.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: mute, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    price,
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(color: mute, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.accent,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final Color accent;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.check_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: StudyColors.textPrimary(brightness),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    color: StudyColors.textSecondary(brightness),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({
    required this.label,
    required this.value,
    required this.ink,
    required this.mute,
  });

  final String label;
  final String value;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label, style: TextStyle(color: mute, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TrialTimeline extends StatelessWidget {
  const _TrialTimeline({
    required this.accent,
    required this.chargeLabel,
    required this.billing,
    required this.ink,
    required this.mute,
  });

  final Color accent;
  final String chargeLabel;
  final BillingPlanOption billing;
  final Color ink;
  final Color mute;

  @override
  Widget build(BuildContext context) {
    final String chargeDetail = switch (billing.interval) {
      BillingInterval.monthly =>
        '${billing.priceLabel}, then every month. Cancel any time before.',
      BillingInterval.semester =>
        '${billing.priceLabel} for 4 months. Cancel any time before.',
      BillingInterval.annual =>
        '${billing.priceLabel}, then every year. Cancel any time before.',
    };

    return Column(
      children: <Widget>[
        _TimelineStep(
          color: accent,
          title: 'Today',
          body: 'Your 30-day free trial starts. All Premium tools unlock.',
          ink: ink,
          mute: mute,
          showLine: true,
        ),
        _TimelineStep(
          color: accent,
          title: 'Day 23',
          body: 'We email you a reminder before you are charged.',
          ink: ink,
          mute: mute,
          showLine: true,
        ),
        _TimelineStep(
          color: StudyColors.accent,
          title: '$chargeLabel: first charge',
          body: chargeDetail,
          ink: ink,
          mute: mute,
          showLine: false,
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.color,
    required this.title,
    required this.body,
    required this.ink,
    required this.mute,
    required this.showLine,
  });

  final Color color;
  final String title;
  final String body;
  final Color ink;
  final Color mute;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 22,
            child: Column(
              children: <Widget>[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: StudyColors.border(Theme.of(context).brightness),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(color: mute, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact upgrade teaser for profile / home.
class MembershipTeaserCard extends StatelessWidget {
  const MembershipTeaserCard({
    super.key,
    required this.onTap,
    this.plan = SubscriptionPlan.free,
  });

  final VoidCallback onTap;
  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isPremium = plan.isPaid;
    final Color accent = context.watch<AppearanceService>().primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StudyColors.surface(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium
                  ? accent.withValues(alpha: 0.45)
                  : StudyColors.border(brightness),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.auto_awesome_rounded,
                color: accent,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isPremium ? 'Premium is active' : 'Try Premium free',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremium
                          ? 'Unlimited study tools'
                          : '30 days free · from ${MembershipPlans.premiumPromoPrice}/mo',
                      style: TextStyle(
                        color: StudyColors.textSecondary(brightness),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: StudyColors.textSecondary(brightness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
