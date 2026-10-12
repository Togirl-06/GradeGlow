import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/billing_config.dart';
import '../config/virtual_university.dart';
import '../models/membership_plans.dart';
import '../models/subscription_plan.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';

/// Free vs Premium — side-by-side plan cards with billing interval toggle.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  BillingInterval _interval = BillingInterval.monthly;

  @override
  Widget build(BuildContext context) {
    final SubscriptionService subs = context.watch<SubscriptionService>();
    final AuthService auth = context.watch<AuthService>();
    final bool isPremium = subs.plan.isPaid;
    final BillingPlanOption billing = BillingConfig.planFor(_interval);
    final MembershipPlanDetails premiumPlan = MembershipPlans.premiumFor(billing);
    final bool edu = BillingConfig.isEduEmail(auth.email);

    return Scaffold(
      appBar: AppBar(title: const Text('Plans & features')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            VirtualUniversity.companyStatement,
            style: TextStyle(
              color: StudyColors.textSecondary(Theme.of(context).brightness),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Campus is free for everyone. Premium study tools start at '
            '${BillingConfig.premiumMonthlyPrice}/month after a '
            '${BillingConfig.freeTrialDays}-day trial.',
            style: TextStyle(
              color: StudyColors.textSecondary(Theme.of(context).brightness),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _BillingToggle(
            selected: _interval,
            onChanged: (BillingInterval v) => setState(() => _interval = v),
          ),
          if (billing.savingsLabel != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '${billing.savingsLabel}'
              '${billing.perMonthLabel != null ? ' · ${billing.perMonthLabel}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StudyColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: StudyColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: StudyColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.school_rounded,
                  size: 18,
                  color: StudyColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    edu
                        ? 'Your .edu email qualifies for ${BillingConfig.eduDiscountPercent}% off at checkout.'
                        : BillingConfig.eduDiscountLabel,
                    style: TextStyle(
                      color: StudyColors.textPrimary(
                        Theme.of(context).brightness,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool sideBySide = constraints.maxWidth >= 560;
              final Widget freeCard = _PlanOfferCard(
                plan: MembershipPlans.free,
                isCurrent: !isPremium,
                buttonLabel:
                    isPremium ? 'Downgrade to Free' : 'Your current plan',
                filledButton: false,
                enabled: isPremium,
                onPressed: isPremium
                    ? () async {
                        await subs.restoreFree();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Switched to Free')),
                          );
                        }
                      }
                    : null,
              );
              final Widget premiumCard = _PlanOfferCard(
                plan: premiumPlan,
                isCurrent: isPremium,
                isHighlighted: true,
                buttonLabel: isPremium
                    ? 'Your current plan'
                    : BillingConfig.checkoutCta,
                filledButton: !isPremium,
                enabled: !isPremium,
                onPressed: !isPremium
                    ? () async {
                        final bool ok = await subs.startPremiumCheckout(
                          interval: _interval,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? BillingConfig.checkoutOpenedMessage()
                                  : 'Could not open checkout. Try again or open Stripe from a browser.',
                            ),
                          ),
                        );
                      }
                    : null,
              );

              if (sideBySide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(child: freeCard),
                      const SizedBox(width: 12),
                      Expanded(child: premiumCard),
                    ],
                  ),
                );
              }

              return Column(
                children: <Widget>[
                  premiumCard,
                  const SizedBox(height: 12),
                  freeCard,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            BillingConfig.trialFooter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StudyColors.textSecondary(Theme.of(context).brightness),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            BillingConfig.priceFootnoteFor(billing),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StudyColors.textSecondary(Theme.of(context).brightness),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.selected, required this.onChanged});

  final BillingInterval selected;
  final ValueChanged<BillingInterval> onChanged;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StudyColors.surfaceElevated(brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Row(
        children: <Widget>[
          for (final BillingPlanOption plan in BillingConfig.plans)
            Expanded(
              child: _ToggleChip(
                label: plan.label,
                selected: selected == plan.interval,
                badge: plan.savingsLabel,
                onTap: () => onChanged(plan.interval),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StudyColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: <Widget>[
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : StudyColors.textPrimary(Theme.of(context).brightness),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              if (badge != null && selected) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  badge!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanOfferCard extends StatelessWidget {
  const _PlanOfferCard({
    required this.plan,
    required this.isCurrent,
    required this.buttonLabel,
    required this.filledButton,
    required this.enabled,
    this.isHighlighted = false,
    this.onPressed,
  });

  final MembershipPlanDetails plan;
  final bool isCurrent;
  final bool isHighlighted;
  final String buttonLabel;
  final bool filledButton;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final Color textPrimary =
        isHighlighted ? Colors.white : StudyColors.textPrimary(brightness);
    final Color textMuted = isHighlighted
        ? Colors.white.withValues(alpha: 0.72)
        : StudyColors.textSecondary(brightness);

    final Color background = isHighlighted
        ? (isDark ? const Color(0xFF1E2A5E) : const Color(0xFF1D4ED8))
        : (isDark ? const Color(0xFF171C26) : const Color(0xFFF8FAFC));

    final Color borderColor = isHighlighted
        ? StudyColors.primaryLight.withValues(alpha: 0.45)
        : StudyColors.border(brightness);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: isHighlighted && !isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: StudyColors.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              if (plan.promoLabel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isHighlighted ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.schedule_rounded, size: 12, color: textMuted),
                      const SizedBox(width: 4),
                      Text(
                        plan.promoLabel!,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _PriceRow(
            amount: plan.priceAmount,
            suffix: plan.priceSuffix,
            strikethrough: plan.strikethroughPrice,
            lightText: isHighlighted,
          ),
          const SizedBox(height: 10),
          Text(
            plan.tagline,
            style: TextStyle(
              color: textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...plan.features.map(
            (PlanFeature feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isHighlighted ? StudyColors.accent : StudyColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.label,
                      style: TextStyle(
                        color: textPrimary.withValues(alpha: 0.92),
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (plan.footerNote != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              plan.footerNote!,
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: filledButton
                ? FilledButton(
                    onPressed: enabled ? onPressed : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: isHighlighted
                          ? StudyColors.accent
                          : StudyColors.primary,
                      foregroundColor: const Color(0xFF1C1917),
                      disabledBackgroundColor:
                          Colors.white.withValues(alpha: 0.12),
                      disabledForegroundColor: textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  )
                : OutlinedButton(
                    onPressed: enabled ? onPressed : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textMuted,
                      disabledForegroundColor: textMuted.withValues(alpha: 0.7),
                      side: BorderSide(color: textMuted.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.amount,
    required this.suffix,
    this.strikethrough,
    this.lightText = false,
  });

  final String amount;
  final String suffix;
  final String? strikethrough;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final Color main = lightText
        ? Colors.white
        : StudyColors.textPrimary(Theme.of(context).brightness);
    final Color muted = lightText
        ? Colors.white.withValues(alpha: 0.65)
        : StudyColors.textSecondary(Theme.of(context).brightness);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 8,
      runSpacing: 4,
      children: <Widget>[
        if (strikethrough != null)
          Text(
            strikethrough!,
            style: TextStyle(
              color: muted,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.lineThrough,
              decorationColor: muted,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                r'$',
                style: TextStyle(
                  color: main,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: main,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            suffix,
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? <Color>[
                      StudyColors.accent.withValues(alpha: 0.25),
                      StudyColors.accentTint(brightness),
                    ]
                  : <Color>[
                      StudyColors.primaryTint(brightness),
                      StudyColors.primary.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPremium
                  ? StudyColors.accent.withValues(alpha: 0.4)
                  : StudyColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.auto_awesome_rounded,
                color: isPremium ? StudyColors.accentDark : StudyColors.primary,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isPremium
                          ? 'Premium is active'
                          : 'See Free & Premium plans',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremium
                          ? 'Study tools without limits'
                          : 'From ${MembershipPlans.premiumPromoPrice}/mo · ${BillingConfig.trialFooter}',
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
