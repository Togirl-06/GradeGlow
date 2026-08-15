import 'package:flutter/material.dart';

import '../career_labs/playable/science/biology/anatomy_3d_viewer_screen.dart';
import '../career_labs/playable/science/biology/clinical_viva_quiz_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_custom_exam_setup_screen.dart';
import 'vu_v2_study_course_picker.dart';

/// Study Center → Quizzes & exams: clinical viva + course quizzes.
class VuV2QuizzesExamsHubScreen extends StatelessWidget {
  const VuV2QuizzesExamsHubScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  void _openCoursePicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2StudyCoursePickerScreen(
          session: session,
          progress: progress,
          title: 'Quizzes & exams',
          subtitle:
              'Pick a course, select the topics you want, then start a quiz or timed exam.',
          onCourseSelected: (BuildContext ctx, VuV2StudyCourseRef c) {
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2CustomExamSetupScreen(
                  session: session,
                  progress: progress,
                  subjectId: c.subjectId,
                  facultyTitle: c.facultyTitle,
                  facultyEmoji: c.facultyEmoji,
                  trackTitle: c.trackTitle,
                  course: c.course,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        backgroundColor: VuV2Colors.navyElevated,
        foregroundColor: VuV2Colors.ink,
        title: const Text('Quizzes & exams'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ClinicalVivaQuizScreen.open(context),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      VuV2Colors.mint.withValues(alpha: 0.22),
                      VuV2Colors.card,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: VuV2Colors.mint.withValues(alpha: 0.5),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'JUDGE DIFFERENTIATOR',
                      style: TextStyle(
                        color: VuV2Colors.mint,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Clinical Viva Quiz',
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Patient case → required 3D view → diagnose bone → clinical reasoning score.',
                      style: TextStyle(color: VuV2Colors.mute, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Anatomy3dViewerHubScreen.open(context),
            icon: const Icon(Icons.threed_rotation),
            label: const Text('3D Anatomy Viewers'),
            style: OutlinedButton.styleFrom(
              foregroundColor: VuV2Colors.ink,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Course quizzes & timed exams',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Standard topic quizzes across your enrolled programs.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.4),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _openCoursePicker(context),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Pick a course quiz'),
            style: FilledButton.styleFrom(
              backgroundColor: VuV2Colors.mint,
              foregroundColor: const Color(0xFF04110C),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
