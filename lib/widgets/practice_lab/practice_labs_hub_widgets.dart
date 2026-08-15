import 'package:flutter/material.dart';

import '../../data/practice_lab_topics_catalog.dart';
import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import '../../theme/leetcode_theme.dart';
import '../../theme/study_theme.dart';

/// Accent palette per subject field for visual variety on the Practice Labs hub.
class PracticeLabGroupStyle {
  const PracticeLabGroupStyle({required this.gradient, required this.accent, required this.iconBg});

  final List<Color> gradient;
  final Color accent;
  final Color iconBg;

  static PracticeLabGroupStyle forGroup(String groupId) {
    return switch (groupId) {
      'health_medical' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFFB7185), Color(0xFFE11D48)],
          accent: Color(0xFFE11D48),
          iconBg: Color(0xFFFFE4E6),
        ),
      'computer_technology' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF818CF8), Color(0xFF4F46E5)],
          accent: Color(0xFF4F46E5),
          iconBg: Color(0xFFE0E7FF),
        ),
      'business' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFFBBF24), Color(0xFFD97706)],
          accent: Color(0xFFD97706),
          iconBg: Color(0xFFFEF3C7),
        ),
      'law_criminal_justice' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF94A3B8), Color(0xFF475569)],
          accent: Color(0xFF475569),
          iconBg: Color(0xFFF1F5F9),
        ),
      'psychology_social_sciences' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFC084FC), Color(0xFF9333EA)],
          accent: Color(0xFF9333EA),
          iconBg: Color(0xFFF3E8FF),
        ),
      'science' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF34D399), Color(0xFF059669)],
          accent: Color(0xFF059669),
          iconBg: Color(0xFFD1FAE5),
        ),
      'engineering' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFFB923C), Color(0xFFEA580C)],
          accent: Color(0xFFEA580C),
          iconBg: Color(0xFFFFEDD5),
        ),
      'architecture_design' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFA78BFA), Color(0xFF7C3AED)],
          accent: Color(0xFF7C3AED),
          iconBg: Color(0xFFEDE9FE),
        ),
      'arts_creative' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFF472B6), Color(0xFFDB2777)],
          accent: Color(0xFFDB2777),
          iconBg: Color(0xFFFCE7F3),
        ),
      'communications_media' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF38BDF8), Color(0xFF0284C7)],
          accent: Color(0xFF0284C7),
          iconBg: Color(0xFFE0F2FE),
        ),
      'humanities' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFA8A29E), Color(0xFF78716C)],
          accent: Color(0xFF78716C),
          iconBg: Color(0xFFF5F5F4),
        ),
      'hospitality_tourism' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFFFCD34D), Color(0xFFEAB308)],
          accent: Color(0xFFCA8A04),
          iconBg: Color(0xFFFEF9C3),
        ),
      'agriculture_environment' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF84CC16), Color(0xFF65A30D)],
          accent: Color(0xFF65A30D),
          iconBg: Color(0xFFECFCCB),
        ),
      'mathematics_finance' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF60A5FA), Color(0xFF2563EB)],
          accent: Color(0xFF2563EB),
          iconBg: Color(0xFFDBEAFE),
        ),
      'public_safety_government' => const PracticeLabGroupStyle(
          gradient: <Color>[Color(0xFF64748B), Color(0xFF1E293B)],
          accent: Color(0xFF1E293B),
          iconBg: Color(0xFFE2E8F0),
        ),
      _ => PracticeLabGroupStyle(
          gradient: <Color>[StudyColors.primaryLight, StudyColors.primary],
          accent: StudyColors.primary,
          iconBg: StudyColors.primary.withValues(alpha: 0.12),
        ),
    };
  }
}

class PracticeLabsHubHero extends StatelessWidget {
  const PracticeLabsHubHero({
    super.key,
    required this.totalMajors,
    this.remaining,
    this.monthlyLimit,
    this.isPremium = false,
  });

  final int totalMajors;
  final int? remaining;
  final int? monthlyLimit;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1D4ED8), Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StudyColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'AI Practice Labs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Live AI characters, voice chat, and real-time scoring across every major.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.45, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _HeroStatChip(icon: Icons.school_outlined, label: '$totalMajors majors'),
                      _HeroStatChip(icon: Icons.all_inclusive_rounded, label: 'Unlimited scenarios'),
                      if (!isPremium && remaining != null && monthlyLimit != null)
                        _HeroStatChip(
                          icon: Icons.bolt_rounded,
                          label: '$remaining/$monthlyLimit free this month',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({required this.icon, required this.label, this.dark = false});

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color fg = dark ? LeetCodeTheme.textPrimary : Colors.white;
    final Color bg = dark ? LeetCodeTheme.surfaceElevated : Colors.white.withValues(alpha: 0.16);
    final Color border = dark ? LeetCodeTheme.border : Colors.white.withValues(alpha: 0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: dark ? LeetCodeTheme.accent : Colors.white),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class PracticeLabsFeatureCarousel extends StatelessWidget {
  const PracticeLabsFeatureCarousel({super.key});

  static const List<({IconData icon, String label, Color color})> _features =
      <({IconData icon, String label, Color color})>[
    (icon: Icons.record_voice_over_rounded, label: 'Live AI character', color: Color(0xFF6366F1)),
    (icon: Icons.mic_rounded, label: 'Voice chat', color: Color(0xFF0EA5E9)),
    (icon: Icons.speed_rounded, label: 'Live scoring', color: Color(0xFF10B981)),
    (icon: Icons.lightbulb_rounded, label: 'Hints', color: Color(0xFFF59E0B)),
    (icon: Icons.trending_up_rounded, label: 'Skill tracking', color: Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Every lab includes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: StudyColors.textPrimary(Theme.of(context).brightness)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _features.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final ({IconData icon, String label, Color color}) f = _features[index];
              return Container(
                width: 108,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StudyColors.surface(Theme.of(context).brightness),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: f.color.withValues(alpha: 0.25)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: f.color.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: f.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.icon, size: 18, color: f.color),
                    ),
                    const Spacer(),
                    Text(
                      f.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: StudyColors.textPrimary(Theme.of(context).brightness), height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PracticeLabsGroupCard extends StatelessWidget {
  const PracticeLabsGroupCard({
    super.key,
    required this.group,
    required this.onSubjectTap,
  });

  final PracticeLabSubjectGroup group;
  final ValueChanged<PracticeLabCategory> onSubjectTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final PracticeLabGroupStyle style = PracticeLabGroupStyle.forGroup(group.id);

    return Container(
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.accent.withValues(alpha: 0.15)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: style.accent.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: style.gradient),
            ),
            child: Row(
              children: <Widget>[
                Text(group.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${group.subjects.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth > 520;
                if (wide) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.subjects
                        .map(
                          (PracticeLabCategory category) => SizedBox(
                            width: (constraints.maxWidth - 8) / 2,
                            child: _MajorTile(
                              category: category,
                              style: style,
                              textSecondary: textSecondary,
                              onTap: () => onSubjectTap(category),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
                return Column(
                  children: group.subjects
                      .map(
                        (PracticeLabCategory category) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _MajorTile(
                            category: category,
                            style: style,
                            textSecondary: textSecondary,
                            onTap: () => onSubjectTap(category),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MajorTile extends StatelessWidget {
  const _MajorTile({
    required this.category,
    required this.style,
    required this.textSecondary,
    required this.onTap,
  });

  final PracticeLabCategory category;
  final PracticeLabGroupStyle style;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int labCount = PracticeLabTopicsCatalog.totalLabCountFor(
      category.id,
      groupId: category.groupId,
      majorName: category.name,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: style.iconBg.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.55),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: style.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, size: 20, color: style.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('$labCount+ AI labs', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: style.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: style.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeLabScoreTile extends StatelessWidget {
  const PracticeLabScoreTile({super.key, required this.record});

  final PracticeLabRecord record;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final bool passed = record.score >= 70;
    final Color scoreColor = passed ? StudyColors.success : StudyColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StudyColors.surface(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.12),
              border: Border.all(color: scoreColor.withValues(alpha: 0.35), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${record.score}',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: scoreColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(record.labTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '${record.categoryName} · ${record.scenarioTitle}',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(passed ? Icons.emoji_events_outlined : Icons.replay_rounded, color: scoreColor, size: 20),
        ],
      ),
    );
  }
}

/// Elevated search field used across practice-lab drill-down screens.
class PracticeLabStyledSearch extends StatelessWidget {
  const PracticeLabStyledSearch({
    super.key,
    required this.controller,
    required this.hintText,
    this.onClear,
    this.dark = false,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = dark || brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LeetCodeTheme.surface : StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? LeetCodeTheme.border : StudyColors.border(brightness)),
        boxShadow: isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: StudyColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? LeetCodeTheme.textPrimary : null),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: isDark ? LeetCodeTheme.textSecondary : null),
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? LeetCodeTheme.accent : StudyColors.primary),
          suffixIcon: onClear != null
              ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClear)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Gradient hero for a single major's practice-lab hub.
class PracticeLabMajorHero extends StatelessWidget {
  const PracticeLabMajorHero({
    super.key,
    required this.category,
    required this.description,
    required this.totalLabs,
    required this.areaCount,
    required this.areaLabel,
    this.venueTitle,
    this.dark = false,
  });

  final PracticeLabCategory category;
  final String description;
  final int totalLabs;
  final int areaCount;
  final String areaLabel;
  final String? venueTitle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final PracticeLabGroupStyle style = PracticeLabGroupStyle.forGroup(category.groupId ?? '');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? <Color>[LeetCodeTheme.surfaceElevated, LeetCodeTheme.surface] : style.gradient,
        ),
        border: dark ? Border.all(color: LeetCodeTheme.border) : null,
        boxShadow: dark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: style.accent.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: dark ? 0.04 : 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: dark ? 0.1 : 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(category.icon, color: dark ? LeetCodeTheme.accent : Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              category.name,
                              style: TextStyle(
                                color: dark ? LeetCodeTheme.textPrimary : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              venueTitle ?? 'AI Practice Labs',
                              style: TextStyle(
                                color: dark ? LeetCodeTheme.textSecondary : Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: venueTitle != null ? 0.6 : 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: dark ? LeetCodeTheme.textSecondary : Colors.white.withValues(alpha: 0.92),
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _HeroStatChip(
                        icon: Icons.layers_outlined,
                        label: '$totalLabs+ AI labs',
                        dark: dark,
                      ),
                      _HeroStatChip(
                        icon: Icons.grid_view_rounded,
                        label: '$areaCount $areaLabel',
                        dark: dark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeLabPromoTile extends StatelessWidget {
  const PracticeLabPromoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.style,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final PracticeLabGroupStyle style;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: <Color>[
                style.accent.withValues(alpha: 0.12),
                style.iconBg.withValues(alpha: brightness == Brightness.dark ? 0.08 : 0.9),
              ],
            ),
            border: Border.all(color: style.accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: style.gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(subtitle, style: TextStyle(color: StudyColors.textSecondary(brightness), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: style.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeLabUsageBanner extends StatelessWidget {
  const PracticeLabUsageBanner({
    super.key,
    required this.remaining,
    required this.limit,
    this.onUpgrade,
    this.dark = false,
  });

  final int remaining;
  final int limit;
  final VoidCallback? onUpgrade;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bool atLimit = remaining <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? LeetCodeTheme.surfaceElevated : StudyColors.surface(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: atLimit
              ? LeetCodeTheme.hard.withValues(alpha: 0.4)
              : (dark ? LeetCodeTheme.border : StudyColors.border(Theme.of(context).brightness)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            atLimit ? Icons.lock_outline_rounded : Icons.bolt_rounded,
            color: atLimit ? StudyColors.danger : (dark ? LeetCodeTheme.accent : StudyColors.primary),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$remaining of $limit free simulations left this month',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: dark ? LeetCodeTheme.textPrimary : null,
              ),
            ),
          ),
          if (atLimit && onUpgrade != null)
            TextButton(onPressed: onUpgrade, child: const Text('Upgrade')),
        ],
      ),
    );
  }
}

class PracticeLabTopicAreaTile extends StatelessWidget {
  const PracticeLabTopicAreaTile({
    super.key,
    required this.area,
    required this.style,
    required this.onTap,
    this.topicsLabel = 'topics',
    this.dark = false,
  });

  final PracticeLabTopicArea area;
  final PracticeLabGroupStyle style;
  final VoidCallback onTap;
  final String topicsLabel;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = dark
        ? LeetCodeTheme.textSecondary
        : StudyColors.textSecondary(Theme.of(context).brightness);
    final String preview = area.topics.take(3).map((PracticeLabTopic t) => t.name).join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? LeetCodeTheme.surface : StudyColors.surface(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: style.accent.withValues(alpha: dark ? 0.25 : 0.18)),
            boxShadow: dark
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: style.accent.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: style.gradient.map((Color c) => c.withValues(alpha: 0.85)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(area.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      area.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: dark ? LeetCodeTheme.textPrimary : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: style.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${area.topics.length} $topicsLabel · ${area.labCount}+ AI labs',
                        style: TextStyle(color: style.accent, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (preview.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        preview,
                        style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: style.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_rounded, color: style.accent, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeLabFeaturedTile extends StatelessWidget {
  const PracticeLabFeaturedTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.style,
    required this.onTap,
    this.dark = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final PracticeLabGroupStyle style;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = dark
        ? LeetCodeTheme.textSecondary
        : StudyColors.textSecondary(Theme.of(context).brightness);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: dark ? LeetCodeTheme.surface : StudyColors.surface(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: style.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: style.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: dark ? LeetCodeTheme.textPrimary : null,
                      ),
                    ),
                    Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: style.gradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeLabAreaHeader extends StatelessWidget {
  const PracticeLabAreaHeader({
    super.key,
    required this.majorName,
    required this.area,
    required this.style,
    this.dark = false,
  });

  final String majorName;
  final PracticeLabTopicArea area;
  final PracticeLabGroupStyle style;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: dark ? <Color>[LeetCodeTheme.surfaceElevated, LeetCodeTheme.surface] : style.gradient),
        border: dark ? Border.all(color: LeetCodeTheme.border) : null,
        boxShadow: dark
            ? null
            : <BoxShadow>[
                BoxShadow(color: style.accent.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8)),
              ],
      ),
      child: Row(
        children: <Widget>[
          Text(area.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  area.name,
                  style: TextStyle(
                    color: dark ? LeetCodeTheme.textPrimary : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$majorName · ${area.topics.length} topics · ${area.labCount}+ labs',
                  style: TextStyle(
                    color: dark ? LeetCodeTheme.textSecondary : Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class PracticeLabDifficultyLegend extends StatelessWidget {
  const PracticeLabDifficultyLegend({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textColor = dark ? LeetCodeTheme.textSecondary : StudyColors.textSecondary(Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? LeetCodeTheme.surface : StudyColors.surface(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? LeetCodeTheme.border : StudyColors.border(Theme.of(context).brightness)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _LegendItem(color: StudyColors.success, label: 'Beginner', textColor: textColor),
          _LegendItem(color: StudyColors.warning, label: 'Intermediate', textColor: textColor),
          _LegendItem(color: StudyColors.danger, label: 'Advanced', textColor: textColor),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.textColor});

  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
      ],
    );
  }
}

class PracticeLabTopicTile extends StatelessWidget {
  const PracticeLabTopicTile({
    super.key,
    required this.topic,
    required this.style,
    this.onBeginner,
    this.onIntermediate,
    this.onAdvanced,
    this.onTap,
    this.activityCount,
    this.dark = false,
  });

  final PracticeLabTopic topic;
  final PracticeLabGroupStyle style;
  final VoidCallback? onBeginner;
  final VoidCallback? onIntermediate;
  final VoidCallback? onAdvanced;
  final VoidCallback? onTap;
  final int? activityCount;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = dark
        ? LeetCodeTheme.textSecondary
        : StudyColors.textSecondary(Theme.of(context).brightness);

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(color: style.accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          topic.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: dark ? LeetCodeTheme.textPrimary : null,
                          ),
                        ),
                      ),
                      if (activityCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: style.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$activityCount activities',
                            style: TextStyle(color: style.accent, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(topic.description, style: TextStyle(color: textSecondary, height: 1.35, fontSize: 13)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: style.accent.withValues(alpha: 0.6)),
          ],
        ),
        if (onTap == null) ...<Widget>[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (topic.beginner && onBeginner != null)
                _DifficultyButton(color: StudyColors.success, label: 'Beginner', onTap: onBeginner!),
              if (topic.intermediate && onIntermediate != null)
                _DifficultyButton(color: StudyColors.warning, label: 'Intermediate', onTap: onIntermediate!),
              if (topic.advanced && onAdvanced != null)
                _DifficultyButton(color: StudyColors.danger, label: 'Advanced', onTap: onAdvanced!),
            ],
          ),
        ] else ...<Widget>[
          const SizedBox(height: 10),
          Text(
            'Tap to choose activity type & difficulty',
            style: TextStyle(color: style.accent.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _decoration(dark, style),
        child: content,
      );
    }

    return Material(
      color: dark ? LeetCodeTheme.surface : StudyColors.surface(Theme.of(context).brightness),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _decoration(dark, style),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _decoration(bool dark, PracticeLabGroupStyle style) => BoxDecoration(
        color: dark ? LeetCodeTheme.surface : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.accent.withValues(alpha: dark ? 0.2 : 0.14)),
        boxShadow: dark
            ? null
            : <BoxShadow>[
                BoxShadow(color: style.accent.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
              ],
      );
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({required this.color, required this.label, required this.onTap});

  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
