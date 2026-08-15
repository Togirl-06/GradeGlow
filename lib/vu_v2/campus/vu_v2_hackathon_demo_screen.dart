import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/diagram_misconception_store.dart';
import '../../data/university_learning_engine.dart';
import '../../screens/ai_professor/ai_professor_classroom_screen.dart';
import '../../services/openai_service.dart';
import '../../widgets/virtual_lecture/lecture_diagram_label_activity.dart';
import '../career_labs/playable/science/biology/anatomy_3d_viewer_screen.dart';
import '../career_labs/playable/science/biology/biology_lab_home.dart';
import '../career_labs/playable/science/biology/clinical_viva_quiz_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_lesson_activity_router.dart';
import 'vu_v2_adaptive_review_drill_screen.dart';

/// Clinical showcase demo hub — fast path through lecture → labels → viva.
class VuV2HackathonDemoScreen extends StatelessWidget {
  const VuV2HackathonDemoScreen({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  static const String demoLessonTitle = 'Human Skeleton';
  static const String demoLessonId = 'hackathon_demo_skeleton';

  static Future<void> open(
    BuildContext context, {
    required VuV2Session session,
    required VuV2ProgressStore progress,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VuV2HackathonDemoScreen(
          session: session,
          progress: progress,
        ),
      ),
    );
  }

  Future<void> _seedAdaptiveWow() async {
    await DiagramMisconceptionStore.instance.seedDemoConfusions();
    await progress.syncDiagramMisconceptions();
  }

  Future<void> _startProfessor(BuildContext context) async {
    await _seedAdaptiveWow();
    if (!context.mounted) return;
    final OpenAiService openAi = context.read<OpenAiService>();
    const UniversityLabLink lab = UniversityLabLink(
      labId: 'biology',
      stationId: 'anatomy_3d',
      title: 'Clinical Viva Practical · Shoulder Trauma',
      purpose:
          'Patient case → required 3D view → diagnose structure → clinical WHY score.',
      objectives: <String>[
        'Orbit to the required clinical view',
        'Identify the injured structure on the model',
        'Answer the clinical viva (why it matters)',
      ],
    );
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AiProfessorClassroomScreen(
          openAi: openAi,
          lessonId: demoLessonId,
          lessonTitle: demoLessonTitle,
          courseId: 'general_biology',
          courseTitle: 'BIO-101 · General Biology',
          moduleTitle: 'Anatomy Teaching Showcase',
          faculty: 'biology',
          masteryHint: 0.35,
          linkedLabTitle: lab.title,
          onEnterLab: () => VuV2LessonActivityRouter.openLinkedLab(
            context: context,
            link: lab,
            subjectId: 'biology',
          ),
          onPractice: () async {
            await LectureDiagramLabelActivity.open(
              context,
              diagramId: 'skeleton',
              regionIds: const <String>['radius', 'ulna', 'humerus', 'scapula'],
              title: 'In-lecture label practice',
            );
          },
          onCompleted: () async {
            await progress.completeLesson(demoLessonId, minutes: 8);
            await progress.syncDiagramMisconceptions();
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
        title: const Text('Clinical Showcase Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  VuV2Colors.mint.withValues(alpha: 0.22),
                  VuV2Colors.card,
                ],
              ),
              borderRadius: BorderRadius.circular(VuV2Radii.lg),
              border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'PRODUCT PITCH',
                  style: TextStyle(
                    color: VuV2Colors.mint,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Videos teach.\nFlashcards drill.\nWe run a clinical viva on a 3D body.',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Patient chart → correct view → injured bone → clinical WHY → '
                  'labels → board score. That is university practical — not a quiz toy.',
                  style: TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          VuV2PrimaryButton(
            label: 'START 90-SEC DEMO',
            trailingArrow: true,
            onPressed: () => _startProfessor(context),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => VuV2LessonActivityRouter.openLinkedLab(
              context: context,
              link: const UniversityLabLink(
                labId: 'biology',
                stationId: 'anatomy_3d',
                title: '3D Skeleton Mission Lab',
                purpose:
                    'Graded university practical: orbit, identify, label, submit.',
                objectives: <String>[
                  'Orbit anterior, lateral, and posterior views',
                  'Identify scapula, radius, and ulna',
                  'Complete drag-and-drop labeling',
                ],
                estimatedMinutes: 10,
                difficulty: 'Judge Showcase',
                prerequisite: 'Human Skeleton lecture',
              ),
              subjectId: 'biology',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: VuV2Colors.gold,
              foregroundColor: const Color(0xFF04110C),
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.view_in_ar_rounded),
            label: const Text(
              'WOW CLINICAL VIVA LAB',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ClinicalVivaQuizScreen.open(context),
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Clinical Quiz'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VuV2Colors.ink,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Anatomy3dViewerHubScreen.open(context),
                  icon: const Icon(Icons.threed_rotation, size: 18),
                  label: const Text('3D Viewers'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VuV2Colors.ink,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await _seedAdaptiveWow();
              if (!context.mounted) return;
              await VuV2AdaptiveReviewDrillScreen.open(
                context,
                progress: progress,
                focusMisconceptionId: 'radius_ulna',
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: VuV2Colors.mint,
              side: const BorderSide(color: VuV2Colors.mint),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.psychology_alt_outlined),
            label: const Text('Skip to adaptive review wow'),
          ),
          const SizedBox(height: 22),
          const Text(
            'Demo chapters (jump in anywhere)',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _DemoJump(
            icon: Icons.school_rounded,
            title: '1 · AI Professor skeleton lecture',
            body: 'Progressive teaching — not 28 labels at once.',
            onTap: () => _startProfessor(context),
          ),
          _DemoJump(
            icon: Icons.drag_indicator,
            title: '2 · Drag-and-drop labeling',
            body: 'Radius · ulna · humerus — lab practical style.',
            onTap: () => LectureDiagramLabelActivity.open(
              context,
              diagramId: 'skeleton',
              regionIds: const <String>['radius', 'ulna', 'humerus'],
              title: 'Skeleton Label Drill',
            ),
          ),
          _DemoJump(
            icon: Icons.view_in_ar_rounded,
            title: '3 · Clinical Viva · 3D practical',
            body: 'Patient case → required view → diagnose → clinical WHY score.',
            onTap: () => VuV2LessonActivityRouter.openLinkedLab(
              context: context,
              link: const UniversityLabLink(
                labId: 'biology',
                stationId: 'anatomy_3d',
                title: 'Clinical Viva · 3D Anatomy',
                purpose:
                    'Graded clinical practical on a rotatable anatomy model.',
                objectives: <String>[
                  'Orbit required clinical views',
                  'Diagnose the implicated structure',
                  'Pass the clinical reasoning viva',
                ],
                estimatedMinutes: 12,
                difficulty: 'Showcase',
                prerequisite: 'Human Skeleton lecture',
              ),
              subjectId: 'biology',
            ),
          ),
          _DemoJump(
            icon: Icons.quiz_outlined,
            title: '3b · Clinical Viva Quiz battery',
            body: 'MCQs + live 3D diagnose items with clinical score.',
            onTap: () => ClinicalVivaQuizScreen.open(context),
          ),
          _DemoJump(
            icon: Icons.threed_rotation,
            title: '3c · 3D viewers (skeleton + heart)',
            body: 'Free orbit viewers — then launch any clinical case.',
            onTap: () => Anatomy3dViewerHubScreen.open(context),
          ),
          _DemoJump(
            icon: Icons.science_outlined,
            title: '4 · Full biology lab hub',
            body: 'Enter station anatomy_3d from the lab floor.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const BiologyLabHomeScreen(initialStationId: 'anatomy_3d'),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '90-second script',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ...const <String>[
                  '0:00 — “Other apps quiz. We teach like a university.”',
                  '0:10 — Demo lecture: progressive plate (not 28 labels)',
                  '0:25 — Axial → appendicular → part focus HUD',
                  '0:40 — Tap-to-find scapula on the stage',
                  '0:55 — Label drill + 3D clinical handoff',
                  '1:10 — Clinical case check matches the trauma',
                  '1:25 — Close: “Enter Clinical Viva — grade the WHY.”',
                ].map(
                  (String line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: VuV2Colors.mute,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tip: stay on this path. Don’t open unfinished degree stubs.',
            style: TextStyle(
              color: VuV2Colors.gold.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoJump extends StatelessWidget {
  const _DemoJump({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: <Widget>[
                Icon(icon, color: VuV2Colors.mint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: const TextStyle(
                          color: VuV2Colors.mute,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: VuV2Colors.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience lesson handle for deep links.
abstract final class VuV2HackathonDemoLesson {
  static const VuV2RoadmapLesson skeleton = VuV2RoadmapLesson(
    id: VuV2HackathonDemoScreen.demoLessonId,
    title: VuV2HackathonDemoScreen.demoLessonTitle,
  );
}
