import 'package:flutter/material.dart';

import '../../theme/mathematics_degree_theme.dart';
import '../../theme/study_theme.dart';

/// AI video lesson top bar — back, topic, timer, end lesson.
class LectureLiveHeader extends StatelessWidget {
  const LectureLiveHeader({
    super.key,
    required this.topicTitle,
    required this.courseLabel,
    required this.elapsedSeconds,
    required this.onEndLesson,
    this.onBack,
  });

  final String topicTitle;
  final String courseLabel;
  final int elapsedSeconds;
  final VoidCallback onEndLesson;
  final VoidCallback? onBack;

  String get _clock {
    final int m = elapsedSeconds ~/ 60;
    final int s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Go back',
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: StudyColors.success.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: StudyColors.success.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI VIDEO LESSON',
                  style: TextStyle(
                    color: StudyColors.success,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  topicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  courseLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            _clock,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          TextButton(
            onPressed: onEndLesson,
            style: TextButton.styleFrom(
              foregroundColor: StudyColors.danger,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'End',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
