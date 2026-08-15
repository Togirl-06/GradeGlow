import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/physics/physics_program.dart';
import '../../models/physics_degree.dart';
import '../../services/physics_progress_service.dart';
import '../../theme/physics_degree_theme.dart';
import '../../widgets/physics/physics_degree_widgets.dart';
import 'physics_degree_lesson_hub_screen.dart';

class PhysicsDegreeCourseScreen extends StatelessWidget {
  const PhysicsDegreeCourseScreen({
    super.key,
    required this.track,
    required this.course,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);
    final PhysicsProgressService progress = context.watch<PhysicsProgressService>();
    final double mastery = progress.courseMastery(course);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: course.topics.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                child: Row(
                  children: <Widget>[
                    Text(
                      track.emoji.isEmpty ? '🔭' : track.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            track.level.label,
                            style: TextStyle(
                              color: c.primaryLight.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            course.blurb,
                            style: TextStyle(
                              color: c.textPrimary.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PhysDegreeMasteryBar(mastery: mastery),
                          const SizedBox(height: 6),
                          Text(
                            '${mastery.round()}% course mastery · ${course.topics.length} topics',
                            style: TextStyle(
                              color: c.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (index == 1) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: PhysDegreeSectionHeader(
                title: 'Topics',
                subtitle: 'Tap any topic to open the lesson hub',
              ),
            );
          }

          final int topicIndex = index - 2;
          final PhysicsTopic topic = course.topics[topicIndex];
          final double lessonMastery = progress.lessonMastery(topic.id);
          final PhysicsLessonPath path = PhysicsLessonPath(
            track: track,
            course: course,
            topic: topic,
          );
          final String readiness = progress.readinessLabel(path);
          final bool mastered = progress.isLessonMastered(topic.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PhysicsDegreeLessonHubScreen(path: path),
                  ),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: c.cardDecoration(
                    borderColor: mastered ? c.success.withValues(alpha: 0.5) : null,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: mastered
                              ? c.success.withValues(alpha: 0.2)
                              : c.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: mastered ? c.success : c.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          mastered ? '✓' : '${topicIndex + 1}',
                          style: TextStyle(
                            color: mastered ? c.success : c.primaryLight,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              topic.title,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topic.hook,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textPrimary.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            PhysDegreeMasteryBar(mastery: lessonMastery),
                            const SizedBox(height: 4),
                            Text(
                              '${lessonMastery.round()}% · $readiness',
                              style: TextStyle(
                                color: c.textPrimary.withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: c.textPrimary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
