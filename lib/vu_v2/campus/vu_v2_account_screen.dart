import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/billing_config.dart';
import '../../config/legal_urls.dart';
import '../../services/appearance_service.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../../widgets/accent_color_picker_sheet.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import 'vu_v2_registrar_style.dart';

/// University account settings — identity, study load, appearance, billing.
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
      const SnackBar(content: Text('Name updated on the academic record')),
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

    return RegistrarScaffold(
      title: 'Account',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: <Widget>[
          const RegistrarSection('Identity'),
          RegistrarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RegistrarRow(label: 'Sign-in', value: '$authLabel · $email'),
                RegistrarRow(label: 'Program', value: session.majorLabel),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  style: RegistrarType.body,
                  decoration: InputDecoration(
                    labelText: 'Name on record',
                    labelStyle: RegistrarType.label,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: RegistrarColors.rule),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: RegistrarColors.navy),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _saving ? null : _saveName,
                    style: TextButton.styleFrom(
                      foregroundColor: RegistrarColors.navy,
                    ),
                    child: Text(_saving ? 'Saving…' : 'Save name'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Study load'),
          RegistrarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${session.weeklyMinutes} minutes per week',
                  style: RegistrarType.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: session.weeklyMinutes.toDouble().clamp(30, 360),
                  min: 30,
                  max: 360,
                  divisions: 11,
                  label: '${session.weeklyMinutes} min',
                  onChanged: (double v) {
                    setState(() => session.weeklyMinutes = v.round());
                  },
                  onChangeEnd: (double v) {
                    session.updateAccount(weeklyMinutes: v.round());
                  },
                ),
                Text(
                  'Used to pace lectures and laboratories. Changing it does not erase grades.',
                  style: TextStyle(color: RegistrarColors.mute, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Display'),
          RegistrarCard(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Dark mode', style: RegistrarType.body),
                  subtitle: Text(
                    'Same setting as GradeGlow. Campus uses this theme.',
                    style: TextStyle(color: RegistrarColors.mute, fontSize: 13),
                  ),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (bool v) {
                    context.read<AppearanceService>().setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
                const Divider(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App color', style: RegistrarType.body),
                  subtitle: Text(
                    'Buttons, links, and campus highlights',
                    style: TextStyle(color: RegistrarColors.mute, fontSize: 13),
                  ),
                  trailing: CircleAvatar(
                    radius: 12,
                    backgroundColor: context.watch<AppearanceService>().primaryColor,
                  ),
                  onTap: () => AccentColorPickerSheet.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Tuition & tools'),
          _PlanBlock(
            title: 'Virtual University campus',
            price: r'$0',
            badge: 'INCLUDED',
            bullets: const <String>[
              'Lectures, laboratories, notes, examinations, certificates',
              'AI Professor on campus',
              'No tuition for the degree catalog',
            ],
            cta: 'Campus access is active',
          ),
          const SizedBox(height: 12),
          _PlanBlock(
            title: 'Premium study tools',
            price: '${BillingConfig.premiumMonthlyPrice}/month',
            badge: premiumTools ? 'ACTIVE' : BillingConfig.trialLabel,
            accent: true,
            bullets: <String>[
              'Unlimited AI Tutor + live voice',
              'Unlimited study sets, flashcards, quizzes & uploads',
              BillingConfig.trialFooter,
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
            '${BillingConfig.priceFootnote} ${progress.completedLessonIds.length} campus lessons on record.',
            style: TextStyle(
              color: RegistrarColors.mute,
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          const RegistrarSection('Correspondence'),
          RegistrarCard(
            child: RegistrarRow(label: 'Support', value: LegalUrls.supportEmail),
          ),
        ],
      ),
    );
  }
}

class _PlanBlock extends StatelessWidget {
  const _PlanBlock({
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
    return RegistrarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: RegistrarType.body.copyWith(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge != null)
                Text(badge!, style: RegistrarType.kicker),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 24,
              color: accent ? RegistrarColors.gold : RegistrarColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (String b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $b', style: RegistrarType.body.copyWith(color: RegistrarColors.mute)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: RegistrarColors.navy,
                side: BorderSide(color: RegistrarColors.navy),
                minimumSize: const Size.fromHeight(44),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}
