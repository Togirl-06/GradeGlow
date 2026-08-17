import 'package:flutter/material.dart';

import '../config/app_branding.dart';
import '../config/billing_config.dart';
import '../config/virtual_university.dart';
import '../config/vu_schools_catalog.dart';
import '../theme/study_theme.dart';
import '../widgets/web_site_header.dart';

/// Public marketing homepage for GradeGlow on web.
class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({
    super.key,
    required this.onSignIn,
    required this.onGetStarted,
  });

  final VoidCallback onSignIn;
  final VoidCallback onGetStarted;

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _schoolsKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final BuildContext? target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool dark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: StudyColors.background(brightness),
      body: Column(
        children: <Widget>[
          WebMarketingHeader(
            onHome: () => _scroll.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            ),
            onSchools: () => _scrollTo(_schoolsKey),
            onHowItWorks: () => _scrollTo(_howKey),
            onSignIn: widget.onSignIn,
            onGetStarted: widget.onGetStarted,
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.zero,
              children: <Widget>[
                _HeroBand(
                  onGetStarted: widget.onGetStarted,
                  onBrowseSchools: () => _scrollTo(_schoolsKey),
                ),
                const _NowOnCampusBand(),
                KeyedSubtree(
                  key: _schoolsKey,
                  child: _SchoolsSection(dark: dark, scheme: scheme),
                ),
                KeyedSubtree(
                  key: _howKey,
                  child: _HowItWorksSection(dark: dark),
                ),
                _MissionSection(dark: dark),
                const WebSiteFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBand extends StatelessWidget {
  const _HeroBand({
    required this.onGetStarted,
    required this.onBrowseSchools,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onBrowseSchools;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool compact = size.width < 900;
    final double heroHeight = compact
        ? size.height.clamp(520, 720).toDouble()
        : size.height.clamp(560, 780).toDouble();

    return SizedBox(
      height: heroHeight * 0.92,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF0B1220),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              right: -80,
              top: -40,
              child: IgnorePointer(
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppBranding.glowOrange.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -60,
              bottom: -80,
              child: IgnorePointer(
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppBranding.glowYellow.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            WebSiteLayout.constrained(
              maxWidth: WebSiteLayout.wideMaxWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  compact ? 48 : 72,
                  0,
                  compact ? 40 : 56,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppBranding.name,
                          style: TextStyle(
                            color: AppBranding.glowOrange,
                            fontSize: compact ? 18 : 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppBranding.glowOrange.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Text(
                              'Campus is free  ·  Premium ${BillingConfig.premiumMonthlyPrice}/mo after a ${BillingConfig.freeTrialDays}-day trial',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'A virtual campus with live labs — and Career Skills with no lectures',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 32 : 48,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Sign in to campus. Academic programs still use professor plus lab. School of Career and Life Skills is labs and real-world practice only.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: compact ? 16 : 18,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            FilledButton(
                              onPressed: onGetStarted,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppBranding.glowOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Start learning free',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: onBrowseSchools,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Browse schools',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowOnCampusBand extends StatelessWidget {
  const _NowOnCampusBand();

  @override
  Widget build(BuildContext context) {
    const List<(String, String)> items = <(String, String)>[
      (
        'Registrar profile',
        'Official student record: ID, program, standing, GPA, credits. No game cards.',
      ),
      (
        'Textbook notes',
        'Lecture notes are full chapters, not slide summaries.',
      ),
      (
        'Interactive labs',
        'Mission, equipment, decisions, and a report — a workspace, not a quiz.',
      ),
      (
        'Career & Life Skills',
        'No lectures. Resume, interview, speaking, and money skills as workplace practice.',
      ),
    ];
    return ColoredBox(
      color: const Color(0xFFF7F4EE),
      child: WebSiteLayout.constrained(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 36, 0, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'NOW ON CAMPUS',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8A6A32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What changed',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17324D),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items
                    .map(
                      ((String, String) item) => SizedBox(
                        width: 280,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFD8D0C4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.$1,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A2332),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.$2,
                                  style: const TextStyle(
                                    color: Color(0xFF5C6570),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchoolsSection extends StatelessWidget {
  const _SchoolsSection({required this.dark, required this.scheme});

  final bool dark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final Color muted = StudyColors.textSecondary(Theme.of(context).brightness);

    return ColoredBox(
      color: dark ? const Color(0xFF0F172A) : Colors.white,
      child: WebSiteLayout.constrained(
        maxWidth: WebSiteLayout.wideMaxWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 64, 0, 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Ten schools. One campus.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Explore programs across technology, engineering, business, health, '
                'sciences, arts, law, and career skills.',
                style: TextStyle(color: muted, height: 1.45, fontSize: 16),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final int cols = c.maxWidth >= 960
                      ? 3
                      : c.maxWidth >= 640
                          ? 2
                          : 1;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: VuSchoolsCatalog.schools.map((VuSchool school) {
                      final double width = cols == 1
                          ? c.maxWidth
                          : (c.maxWidth - (cols - 1) * 14) / cols;
                      return SizedBox(
                        width: width,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: StudyColors.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${school.emoji}  ${school.title}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${school.programs.length} programs',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color muted = StudyColors.textSecondary(Theme.of(context).brightness);
    final List<_HowStep> steps = <_HowStep>[
      const _HowStep(
        title: 'Pick a school',
        body: 'Choose a program from Grade Glow Virtual University.',
      ),
      const _HowStep(
        title: 'Learn with AI professors',
        body: 'Full lectures, diagrams, practice, and homework — not chatbots.',
      ),
      const _HowStep(
        title: 'Build career skills',
        body: 'Apply what you learn with projects, quizzes, and real-world practice.',
      ),
    ];

    return ColoredBox(
      color: dark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      child: WebSiteLayout.constrained(
        maxWidth: WebSiteLayout.wideMaxWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 64, 0, 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How GradeGlow works',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'A simple path from curiosity to mastery.',
                style: TextStyle(color: muted, height: 1.45, fontSize: 16),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final bool row = c.maxWidth >= 800;
                  Widget stepTile(int i, _HowStep step) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: row && i < steps.length - 1 ? 28 : 0,
                        bottom: row ? 0 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '0${i + 1}',
                            style: TextStyle(
                              color: StudyColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.body,
                            style: TextStyle(
                              color: muted,
                              height: 1.45,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (row) {
                    final List<Widget> children = <Widget>[];
                    for (int i = 0; i < steps.length; i++) {
                      children.add(Expanded(child: stepTile(i, steps[i])));
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    );
                  }
                  final List<Widget> children = <Widget>[];
                  for (int i = 0; i < steps.length; i++) {
                    children.add(stepTile(i, steps[i]));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowStep {
  const _HowStep({required this.title, required this.body});

  final String title;
  final String body;
}

class _MissionSection extends StatelessWidget {
  const _MissionSection({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark ? AppBranding.navy : Colors.white,
      child: WebSiteLayout.constrained(
        maxWidth: 760,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 64, 0, 72),
          child: Column(
            children: <Widget>[
              Text(
                'Our mission',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                VirtualUniversity.mission,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StudyColors.textSecondary(
                    Theme.of(context).brightness,
                  ),
                  height: 1.55,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
