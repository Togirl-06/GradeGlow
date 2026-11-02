import 'package:flutter/material.dart';

import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// End-of-lesson summary sheet — key points, cheat sheet, final tips.
class VuV2LessonSummaryScreen extends StatelessWidget {
  const VuV2LessonSummaryScreen({
    super.key,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.courseTitle,
    required this.topicTitle,
    this.topicSubtitle,
  });

  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final String courseTitle;
  final String topicTitle;
  final String? topicSubtitle;

  @override
  Widget build(BuildContext context) {
    final VuV2TopicPackage full = VuV2TopicContent.forLesson(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      facultyEmoji: facultyEmoji,
      trackTitle: trackTitle,
      courseTitle: courseTitle,
      topicTitle: topicTitle,
      topicSubtitle: topicSubtitle,
      interactive: false,
    );
    final List<VuV2TextbookSection> blocks =
        VuV2TopicContent.summaryBlocks(full);
    final List<VuV2TextbookSection> core =
        VuV2TopicContent.coreNoteBlocks(full);
    VuV2TextbookSection? formulas;
    VuV2TextbookSection? mistakes;
    for (final VuV2TextbookSection s in core) {
      if (s.title == 'Formulas or rules') formulas = s;
      if (s.title == 'Common mistakes') mistakes = s;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Summary sheet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '$facultyEmoji  $facultyTitle',
            style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            topicTitle,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$courseTitle · cheat sheet',
            style: TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 16),
          for (final VuV2TextbookSection block in blocks) ...<Widget>[
            VuV2SectionTitle(block.title),
            const SizedBox(height: 8),
            VuV2Surface(
              child: Text(
                block.body,
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (formulas != null) ...<Widget>[
            const VuV2SectionTitle('Formulas & rules'),
            const SizedBox(height: 8),
            VuV2Surface(
              child: Text(
                formulas.body,
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (mistakes != null) ...<Widget>[
            const VuV2SectionTitle('Final tips'),
            const SizedBox(height: 8),
            VuV2Surface(
              child: Text(
                mistakes.body,
                style: TextStyle(color: VuV2Colors.ink, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
          ],
          VuV2PrimaryButton(
            label: 'Mark summary complete',
            icon: Icons.check_circle_outline,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
