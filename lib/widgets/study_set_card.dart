import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../utils/study_set_stats.dart';
import '../widgets/study_surface.dart';

typedef StudySetMenuAction = void Function(String action);

class StudySetCard extends StatelessWidget {
  const StudySetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statsLabel,
    required this.mastery,
    required this.onFlashcards,
    required this.onPractice,
    required this.onNotes,
    this.focusTopic,
    this.focusReason,
    this.onFocusTap,
    this.onMenuAction,
    this.showFocusRecommendations = false,
  });

  final String title;
  final String subtitle;
  final String statsLabel;
  final StudySetMastery mastery;
  final VoidCallback onFlashcards;
  final VoidCallback onPractice;
  final VoidCallback onNotes;
  final String? focusTopic;
  final String? focusReason;
  final VoidCallback? onFocusTap;
  final StudySetMenuAction? onMenuAction;
  final bool showFocusRecommendations;

  static final List<_MasteryTier> _tiers = <_MasteryTier>[
    const _MasteryTier(key: 'unfamiliar', label: 'New', color: StudyColors.danger),
    const _MasteryTier(key: 'learning', label: 'Learning', color: StudyColors.warning),
    _MasteryTier(key: 'familiar', label: 'Familiar', color: StudyColors.primary),
    const _MasteryTier(key: 'mastered', label: 'Mastered', color: StudyColors.success),
  ];

  Color _accentFromTitle(String title) {
    final List<Color> palette = <Color>[
      StudyColors.primary,
      StudyColors.primaryLight,
      StudyColors.accent,
      StudyColors.success,
      Color(0xFF7C3AED),
      Color(0xFF0891B2),
    ];
    return palette[title.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final Color accent = _accentFromTitle(title);

    return StudySurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              gradient: LinearGradient(
                colors: <Color>[accent, accent.withValues(alpha: 0.35)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _MasteryRing(
                      percent: mastery.masteryPercent,
                      accent: accent,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            statsLabel,
                            style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    if (onMenuAction != null)
                      PopupMenuButton<String>(
                        tooltip: 'Class options',
                        icon: Icon(Icons.more_vert_rounded, color: textSecondary, size: 20),
                        onSelected: onMenuAction,
                        itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(value: 'topics', child: Text('View topics')),
                        ],
                      ),
                  ],
                ),
                if (showFocusRecommendations && focusTopic != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _FocusTopicBanner(
                    topic: focusTopic!,
                    reason: focusReason,
                    onTap: onFocusTap,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Mastery mix',
                  style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                ),
                const SizedBox(height: 8),
                _SegmentedMasteryBar(mastery: mastery),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _tiers.map((_MasteryTier tier) {
                    final int count = switch (tier.key) {
                      'unfamiliar' => mastery.unfamiliar,
                      'learning' => mastery.learning,
                      'familiar' => mastery.familiar,
                      _ => mastery.mastered,
                    };
                    return _MasteryChip(label: tier.label, count: count, color: tier.color);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Text(
                  'Jump in',
                  style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ModeChip(icon: Icons.style_outlined, label: 'Cards', onTap: onFlashcards),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(icon: Icons.quiz_outlined, label: 'Quiz', onTap: onPractice),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(icon: Icons.article_outlined, label: 'Notes', onTap: onNotes),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTopicBanner extends StatelessWidget {
  const _FocusTopicBanner({
    required this.topic,
    this.reason,
    this.onTap,
  });

  final String topic;
  final String? reason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    const Color accent = StudyColors.warning;

    return Material(
      color: accent.withValues(alpha: brightness == Brightness.dark ? 0.14 : 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag_rounded, color: accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Focus on',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w800, height: 1.25),
                    ),
                    if (reason != null && reason!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryTier {
  const _MasteryTier({required this.key, required this.label, required this.color});

  final String key;
  final String label;
  final Color color;
}

class _MasteryRing extends StatelessWidget {
  const _MasteryRing({
    required this.percent,
    required this.accent,
  });

  final int percent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color track = StudyColors.border(brightness);
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final double progress = percent / 100;

    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size(62, 62),
            painter: _RingPainter(progress: progress, accent: accent, track: track),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$percent%',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              Text(
                'done',
                style: TextStyle(color: textSecondary, fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.accent, required this.track});

  final double progress;
  final Color accent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;
    const double stroke = 5;

    final Paint trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: <Color>[accent, StudyColors.accent],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _SegmentedMasteryBar extends StatelessWidget {
  const _SegmentedMasteryBar({required this.mastery});

  final StudySetMastery mastery;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final int total = mastery.total;

    if (total == 0) {
      return Container(
        height: 10,
        decoration: BoxDecoration(
          color: StudyColors.border(brightness),
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    final List<_BarSegment> segments = <_BarSegment>[
      _BarSegment(mastery.unfamiliar, StudyColors.danger),
      _BarSegment(mastery.learning, StudyColors.warning),
      _BarSegment(mastery.familiar, StudyColors.primary),
      _BarSegment(mastery.mastered, StudyColors.success),
    ].where((_BarSegment s) => s.count > 0).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: Row(
          children: segments
              .map(
                (_BarSegment s) => Expanded(
                  flex: s.count,
                  child: Container(color: s.color),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BarSegment {
  _BarSegment(this.count, this.color);

  final int count;
  final Color color;
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: brightness == Brightness.dark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);

    return Material(
      color: StudyColors.primaryTint(brightness),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: StudyColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
