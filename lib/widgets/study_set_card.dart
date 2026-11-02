import 'package:flutter/material.dart';

import '../services/expand_state_store.dart';
import '../theme/study_theme.dart';
import '../utils/study_set_stats.dart';

typedef StudySetMenuAction = void Function(String action);

class StudySetCard extends StatefulWidget {
  const StudySetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statsLabel,
    required this.mastery,
    required this.onFlashcards,
    required this.onPractice,
    required this.onNotes,
    this.expandId,
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
  /// Stable id used to remember expand/collapse until the user changes it.
  final String? expandId;
  final String? focusTopic;
  final String? focusReason;
  final VoidCallback? onFocusTap;
  final StudySetMenuAction? onMenuAction;
  final bool showFocusRecommendations;

  @override
  State<StudySetCard> createState() => _StudySetCardState();
}

class _StudySetCardState extends State<StudySetCard> {
  bool _expanded = true;
  bool _loaded = false;

  String get _storageKey {
    final String? id = widget.expandId?.trim();
    if (id != null && id.isNotEmpty) return 'course.$id';
    return 'course.${widget.title}';
  }

  @override
  void initState() {
    super.initState();
    _loadExpanded();
  }

  @override
  void didUpdateWidget(StudySetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expandId != widget.expandId ||
        oldWidget.title != widget.title) {
      _loadExpanded();
    }
  }

  Future<void> _loadExpanded() async {
    final bool expanded = await ExpandStateStore.instance.isExpanded(
      _storageKey,
    );
    if (!mounted) return;
    setState(() {
      _expanded = expanded;
      _loaded = true;
    });
  }

  Future<void> _toggleExpanded() async {
    final bool next = !_expanded;
    setState(() => _expanded = next);
    await ExpandStateStore.instance.setExpanded(_storageKey, next);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int percent = widget.mastery.masteryPercent;
    final String initial = widget.title.trim().isEmpty
        ? 'C'
        : widget.title.trim().substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      if (widget.subtitle.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Text(
                        widget.statsLabel,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onMenuAction != null)
                  PopupMenuButton<String>(
                    tooltip: 'Class options',
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                    onSelected: widget.onMenuAction,
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'topics',
                            child: Text('View all topics'),
                          ),
                        ],
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: _expanded ? 'Collapse course' : 'Expand course',
                  onPressed: _toggleExpanded,
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 220),
            crossFadeState: (!_loaded || _expanded)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = (constraints.maxWidth - 8) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MasteryStage(
                          width: width,
                          count: widget.mastery.unfamiliar,
                          total: widget.mastery.total,
                          label: 'Unfamiliar',
                          caption: 'Not reviewed yet',
                          icon: Icons.visibility_off_outlined,
                          color: StudyColors.danger,
                        ),
                        _MasteryStage(
                          width: width,
                          count: widget.mastery.learning,
                          total: widget.mastery.total,
                          label: 'Learning',
                          caption: 'Building recall',
                          icon: Icons.psychology_outlined,
                          color: StudyColors.warning,
                        ),
                        _MasteryStage(
                          width: width,
                          count: widget.mastery.familiar,
                          total: widget.mastery.total,
                          label: 'Familiar',
                          caption: 'Nearly secure',
                          icon: Icons.lightbulb_outline_rounded,
                          color: scheme.primary,
                        ),
                        _MasteryStage(
                          width: width,
                          count: widget.mastery.mastered,
                          total: widget.mastery.total,
                          label: 'Mastered',
                          caption: 'Long-term recall',
                          icon: Icons.verified_outlined,
                          color: StudyColors.success,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _MasteryJourney(
                  percent: percent,
                  unfamiliar: widget.mastery.unfamiliar,
                  learning: widget.mastery.learning,
                  familiar: widget.mastery.familiar,
                  mastered: widget.mastery.mastered,
                ),
                if (widget.showFocusRecommendations &&
                    widget.focusTopic != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _FocusTopicBanner(
                    topic: widget.focusTopic!,
                    reason: widget.focusReason,
                    onTap: widget.onFocusTap,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$percent% MASTERED',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 8),
                    _ClassAction(
                      tooltip: 'Study flashcards',
                      icon: Icons.school_outlined,
                      onTap: widget.onFlashcards,
                      prominent: true,
                    ),
                    const SizedBox(width: 6),
                    _ClassAction(
                      tooltip: 'Practice quiz',
                      icon: Icons.fact_check_outlined,
                      onTap: widget.onPractice,
                    ),
                    const SizedBox(width: 6),
                    _ClassAction(
                      tooltip: 'Open notes',
                      icon: Icons.menu_book_outlined,
                      onTap: widget.onNotes,
                    ),
                  ],
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _MasteryStage extends StatelessWidget {
  const _MasteryStage({
    required this.width,
    required this.count,
    required this.total,
    required this.label,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final double width;
  final int count;
  final int total;
  final String label;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double share = total == 0 ? 0 : count / total;
    return Container(
      width: width,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                '$count',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 4,
              color: color,
              backgroundColor: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryJourney extends StatelessWidget {
  const _MasteryJourney({
    required this.percent,
    required this.unfamiliar,
    required this.learning,
    required this.familiar,
    required this.mastered,
  });

  final int percent;
  final int unfamiliar;
  final int learning;
  final int familiar;
  final int mastered;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<({String label, bool active})> stages =
        <({String label, bool active})>[
          (label: 'Start', active: unfamiliar > 0 || percent > 0),
          (
            label: 'Learn',
            active: learning > 0 || familiar > 0 || mastered > 0,
          ),
          (label: 'Recall', active: familiar > 0 || mastered > 0),
          (label: 'Master', active: mastered > 0),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'PATH TO MASTERY',
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(stages.length * 2 - 1, (int index) {
              if (index.isOdd) {
                final bool reached = stages[(index + 1) ~/ 2].active;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: reached
                        ? scheme.primary
                        : scheme.onPrimaryContainer.withValues(alpha: 0.12),
                  ),
                );
              }
              final ({String label, bool active}) stage = stages[index ~/ 2];
              return Column(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: stage.active
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      stage.active
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      color: stage.active
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                      size: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.label,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.72),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClassAction extends StatelessWidget {
  const _ClassAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.prominent = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: prominent ? scheme.primary : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              color: prominent ? scheme.onPrimary : scheme.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusTopicBanner extends StatelessWidget {
  const _FocusTopicBanner({required this.topic, this.reason, this.onTap});

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
      color: accent.withValues(
        alpha: brightness == Brightness.dark ? 0.14 : 0.1,
      ),
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
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (reason != null && reason!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
