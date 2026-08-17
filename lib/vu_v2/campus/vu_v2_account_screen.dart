import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/billing_config.dart';
import '../../config/legal_urls.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// Campus account: identity, study targets, appearance, and billing.
class VuV2AccountScreen extends StatefulWidget {
  const VuV2AccountScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.onThemeChanged,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<VuV2AccountScreen> createState() => _VuV2AccountScreenState();
}

class _VuV2AccountScreenState extends State<VuV2AccountScreen> {
  late final TextEditingController _name;
  bool _saving = false;

  VuV2Session get session => widget.session;
  VuV2ProgressStore get progress => widget.progress;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: session.displayName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => _saving = true);
    await session.updateAccount(name: _name.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Campus name saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = 'Not signed in';
    String authLabel = 'Guest';
    try {
      final AuthService auth = context.watch<AuthService>();
      email = auth.email.trim().isEmpty ? 'No email on file' : auth.email;
      if (auth.isDemoMode) {
        authLabel = 'Demo session';
      } else if (auth.usesGoogleSignIn) {
        authLabel = 'Google';
      } else if (auth.usesAppleSignIn) {
        authLabel = 'Apple';
      } else if (auth.usesEmailPassword) {
        authLabel = 'Email';
      } else if (auth.isAuthenticated) {
        authLabel = 'Signed in';
      }
    } catch (_) {}

    bool premiumTools = false;
    try {
      premiumTools = context.watch<SubscriptionService>().isPremium;
    } catch (_) {}

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: <Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'SIGNED IN AS',
                  style: TextStyle(
                    color: VuV2Colors.mint,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$authLabel · ${session.majorLabel}',
                  style: const TextStyle(color: VuV2Colors.mute),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  style: const TextStyle(color: VuV2Colors.ink),
                  decoration: InputDecoration(
                    labelText: 'Campus display name',
                    labelStyle: const TextStyle(color: VuV2Colors.mute),
                    filled: true,
                    fillColor: VuV2Colors.navyElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _saving ? null : _saveName,
                    child: Text(_saving ? 'Saving…' : 'Save name'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Study targets'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${session.weeklyMinutes} minutes / week',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  value: session.weeklyMinutes.toDouble().clamp(30, 600),
                  min: 30,
                  max: 360,
                  divisions: 11,
                  label: '${session.weeklyMinutes} min',
                  activeColor: VuV2Colors.mint,
                  onChanged: (double v) {
                    setState(() => session.weeklyMinutes = v.round());
                  },
                  onChangeEnd: (double v) {
                    session.updateAccount(weeklyMinutes: v.round());
                  },
                ),
                const Text(
                  'Used to pace lectures and labs. Changing it does not erase progress.',
                  style: TextStyle(color: VuV2Colors.mute, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Appearance'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Light campus theme',
                style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Optional lighter boards. Default campus is dark.',
                style: TextStyle(color: VuV2Colors.mute),
              ),
              value: progress.preferLightTheme,
              activeThumbColor: VuV2Colors.mint,
              onChanged: (bool v) async {
                await progress.setPreferLightTheme(v);
                widget.onThemeChanged(v);
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Campus plan'),
          const SizedBox(height: 8),
          _PlanCard(
            title: 'Virtual University',
            price: r'$0',
            badge: 'INCLUDED',
            bullets: const <String>[
              'All lectures, labs, notes, quizzes, and certificates',
              'AI Professor on campus',
              'No tuition for the degree catalog',
            ],
            cta: 'Your campus access',
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Premium study tools',
            price: '${BillingConfig.premiumMonthlyPrice}/mo',
            accent: true,
            badge: premiumTools ? 'ACTIVE' : BillingConfig.trialLabel,
            bullets: const <String>[
              '${BillingConfig.freeTrialDays}-day free trial, then ${BillingConfig.premiumMonthlyPrice}/month',
              'Unlimited tutor chat, live voice, extra uploads',
              'Campus stays free either way',
            ],
            cta: premiumTools
                ? 'Premium tools are active'
                : BillingConfig.checkoutCta,
            onTap: premiumTools
                ? null
                : () async {
                    try {
                      final SubscriptionService subs =
                          context.read<SubscriptionService>();
                      final bool ok = await subs.startPremiumCheckout();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? BillingConfig.checkoutOpenedMessage()
                                : 'Could not open checkout.',
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checkout is unavailable.')),
                      );
                    }
                  },
          ),
          const SizedBox(height: 10),
          Text(
            '${BillingConfig.priceFootnote} ${progress.completedLessonIds.length} campus lessons completed.',
            style: const TextStyle(color: VuV2Colors.mute, height: 1.45, fontSize: 13),
          ),
          const SizedBox(height: 22),
          const VuV2SectionTitle('Help'),
          const SizedBox(height: 8),
          VuV2Surface(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.mail_outline_rounded, color: VuV2Colors.mint),
              title: const Text(
                'Support',
                style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                LegalUrls.supportEmail,
                style: const TextStyle(color: VuV2Colors.mute),
              ),
            ),
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
    this.onTap,
    this.accent = false,
    this.badge,
  });

  final String title;
  final String price;
  final List<String> bullets;
  final String cta;
  final VoidCallback? onTap;
  final bool accent;
  final String? badge;

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
                    fontSize: 18,
                  ),
                ),
              ),
              if (badge != null)
                Text(
                  badge!,
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
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (String b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $b', style: const TextStyle(color: VuV2Colors.mute)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor:
                    accent ? VuV2Colors.orange : VuV2Colors.navyElevated,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    VuV2Colors.navyElevated.withValues(alpha: 0.55),
              ),
              child: Text(cta, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
