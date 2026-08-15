import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import '../../theme/mathematics_degree_theme.dart';

/// Eight-step lecture roadmap — Khan Academy clarity + university structure.
class LecturePhaseRoadmap extends StatelessWidget {
  const LecturePhaseRoadmap({
    super.key,
    required this.current,
  });

  final LecturePhase current;

  static const List<LecturePhase> _coreFlow = <LecturePhase>[
    LecturePhase.introduction,
    LecturePhase.conceptExplanation,
    LecturePhase.visualDemonstration,
    LecturePhase.guidedExamples,
    LecturePhase.studentParticipation,
    LecturePhase.knowledgeCheck,
    LecturePhase.lessonSummary,
    LecturePhase.homeworkRecommendation,
  ];

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final int currentIndex = _coreFlow.indexOf(current).clamp(0, _coreFlow.length - 1);

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _coreFlow.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int index) {
          final LecturePhase phase = _coreFlow[index];
          final bool done = index < currentIndex;
          final bool active = index == currentIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? c.primary.withValues(alpha: 0.14)
                  : done
                      ? c.success.withValues(alpha: 0.12)
                      : c.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? c.primary
                    : done
                        ? c.success.withValues(alpha: 0.5)
                        : c.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : active
                          ? Icons.play_circle_fill_rounded
                          : Icons.circle_outlined,
                  size: 14,
                  color: active
                      ? c.primary
                      : done
                          ? c.success
                          : c.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  _shortLabel(phase),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? c.primary : c.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _shortLabel(LecturePhase phase) {
    return switch (phase) {
      LecturePhase.introduction => 'Intro',
      LecturePhase.objectives => 'Goals',
      LecturePhase.conceptExplanation => 'Concept',
      LecturePhase.visualDemonstration => 'Visual',
      LecturePhase.guidedExamples => 'Example',
      LecturePhase.studentParticipation => 'You',
      LecturePhase.knowledgeCheck => 'Check',
      LecturePhase.practiceProblems => 'Practice',
      LecturePhase.lessonSummary => 'Summary',
      LecturePhase.homeworkRecommendation => 'Next',
    };
  }
}
