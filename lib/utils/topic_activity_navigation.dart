import 'package:flutter/material.dart';

import '../data/practice_lab_course_topics.dart';
import '../data/science_diagram_catalog.dart';
import '../data/visual_learning_catalog.dart';
import '../utils/topic_keyword_matcher.dart';
import '../models/ai_practice_mode.dart';
import '../models/microbiology_specimen.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import '../models/topic_activity.dart';
import '../models/visual_learning_lab.dart';
import '../screens/anatomy_game_screen.dart';
import '../screens/drag_drop_label_lab_screen.dart';
import '../screens/er_simulation_screen.dart';
import '../screens/law_simulation_hub_screen.dart';
import '../screens/leetcode_practice_session_screen.dart';
import '../screens/microbiology_id_lab_screen.dart';
import '../screens/practice_lab_session_screen.dart';
import '../screens/punnett_square_lab_screen.dart';
import '../screens/science_diagram_lab_screen.dart';
import '../screens/virtual_chemistry_lab_screen.dart';
import '../screens/virtual_hospital_hub_screen.dart';
import '../theme/practice_lab_game_theme.dart';
import 'topic_activity_session_info.dart';

/// Launches a [TopicActivity] from the topic activity hub.
void startTopicActivity({
  required BuildContext context,
  required PracticeLabSubject subject,
  required PracticeLabCourse course,
  required PracticeLabUnit unit,
  required PracticeLabTopic topic,
  required TopicActivity activity,
  required PracticeDifficulty difficulty,
}) {
  final PracticeLabCategory category = subject.toCategory();
  final PracticeLabType lab = _labFor(
    subject: subject,
    course: course,
    unit: unit,
    topic: topic,
    activity: activity,
    difficulty: difficulty,
  );
  final VisualLabEnvironmentConfig env = VisualLearningCatalog.configForSubject(subject.id);

  switch (activity.kind) {
    case TopicActivityKind.aiCodingInterview:
    case TopicActivityKind.puzzleChallenge when lab.codeLab:
    case TopicActivityKind.codeCompletion when lab.codeLab:
    case TopicActivityKind.scenarioChallenge when lab.codeLab:
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LeetcodePracticeSessionScreen(
            category: category,
            lab: lab,
            topic: topic,
            area: PracticeLabTopicArea(id: unit.id, name: unit.name, emoji: subject.emoji, topics: unit.topics),
            difficulty: difficulty,
            courseName: course.name,
            subjectId: subject.id,
            courseId: course.id,
          ),
        ),
      );
      return;

    case TopicActivityKind.punnettSquare:
      final VisualLabActivity visual = _visualFor(activity, subject.id);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PunnettSquareLabScreen(category: category, lab: lab, activity: visual, difficulty: difficulty),
        ),
      );
      return;

    case TopicActivityKind.dragDrop:
      if (activity.visualActivityId == 'chem_equipment') {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DragDropLabelLabScreen(
              category: category,
              lab: lab,
              activity: _visualFor(activity, subject.id),
              difficulty: difficulty,
            ),
          ),
        );
        return;
      }
      _openDiagram(context, category, lab, subject, course, topic, activity, env, useTypeEntry: true);
      return;

    case TopicActivityKind.labelDiagram:
    case TopicActivityKind.matching:
    case TopicActivityKind.imageIdentification:
      _openDiagram(context, category, lab, subject, course, topic, activity, env, useTypeEntry: activity.kind == TopicActivityKind.matching);
      return;

    case TopicActivityKind.virtualLab:
      _openVirtualLab(context, category, lab, subject, course, unit, topic, activity, difficulty);
      return;

    case TopicActivityKind.liveSimulation:
    case TopicActivityKind.scenarioChallenge when activity.simulationStyle == SimulationStyle.erEmergency:
      if (activity.visualActivityId != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VirtualHospitalHubScreen(
              subject: subject,
              category: category,
              lab: lab,
              activity: _visualFor(activity, subject.id),
              difficulty: difficulty,
              teachingHospital: subject.id == 'medicine',
            ),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ErSimulationScreen(category: category, lab: lab)),
      );
      return;

    case TopicActivityKind.courtroomSimulation:
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LawSimulationHubScreen(category: category, lab: lab),
        ),
      );
      return;

    case TopicActivityKind.aiRoleplay:
    case TopicActivityKind.caseStudy:
    case TopicActivityKind.practicalExam:
    case TopicActivityKind.multipleChoice:
    case TopicActivityKind.shortAnswer:
    case TopicActivityKind.fillBlank:
    case TopicActivityKind.voiceResponse:
    case TopicActivityKind.timedQuiz:
    case TopicActivityKind.adaptivePractice:
    case TopicActivityKind.reviewMode:
    case TopicActivityKind.puzzleChallenge:
    case TopicActivityKind.codeCompletion:
    case TopicActivityKind.scenarioChallenge:
    case TopicActivityKind.masteryTest:
      _openSession(context, category, lab, course, unit, topic, subject, activity);
      return;
  }
}

void _openDiagram(
  BuildContext context,
  PracticeLabCategory category,
  PracticeLabType lab,
  PracticeLabSubject subject,
  PracticeLabCourse course,
  PracticeLabTopic topic,
  TopicActivity activity,
  VisualLabEnvironmentConfig env, {
  bool useTypeEntry = false,
}) {
  final String? diagramId = activity.diagramId == 'skeleton' && 
      TopicKeywordMatcher(
        topicId: topic.id,
        topicName: topic.name,
        subjectId: subject.id,
        courseId: course.id,
      ).excludesBoneContent
      ? ScienceDiagramCatalog.diagramIdFor(
          subjectId: subject.id,
          courseId: course.id,
          topicId: topic.id,
          topicName: topic.name,
        )
      : activity.diagramId ??
      ScienceDiagramCatalog.diagramIdFor(
        subjectId: subject.id,
        courseId: course.id,
        topicId: topic.id,
        topicName: topic.name,
      );

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ScienceDiagramLabScreen(
        category: category,
        lab: lab,
        subjectId: subject.id,
        courseId: course.id,
        topic: topic,
        diagramId: diagramId,
        useTypeEntry: useTypeEntry,
        environmentConfig: env,
      ),
    ),
  );
}

void _openVirtualLab(
  BuildContext context,
  PracticeLabCategory category,
  PracticeLabType lab,
  PracticeLabSubject subject,
  PracticeLabCourse course,
  PracticeLabUnit unit,
  PracticeLabTopic topic,
  TopicActivity activity,
  PracticeDifficulty difficulty,
) {
  final VisualLabActivity visual = _visualFor(activity, subject.id);
  if (visual.id == 'bio_punnett') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PunnettSquareLabScreen(category: category, lab: lab, activity: visual, difficulty: difficulty),
      ),
    );
    return;
  }
  if (visual.id == 'chem_mix' || visual.id == 'chem_ph' || visual.id == 'chem_experiments') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VirtualChemistryLabScreen(category: category, lab: lab, activity: visual, difficulty: difficulty),
      ),
    );
    return;
  }
  final MicrobiologyCategory? micro = switch (visual.id) {
    'bio_bacteria' => MicrobiologyCategory.bacteria,
    'bio_viruses' => MicrobiologyCategory.virus,
    'bio_fungi' => MicrobiologyCategory.fungi,
    _ => null,
  };
  if (micro != null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MicrobiologyIdLabScreen(
          category: category,
          lab: lab,
          activity: visual,
          difficulty: difficulty,
          specimenCategory: micro,
        ),
      ),
    );
    return;
  }
  _openSession(context, category, lab, course, unit, topic, subject, activity);
}

void _openSession(
  BuildContext context,
  PracticeLabCategory category,
  PracticeLabType lab,
  PracticeLabCourse course,
  PracticeLabUnit unit,
  PracticeLabTopic topic,
  PracticeLabSubject subject,
  TopicActivity activity,
) {
  if (activity.kind == TopicActivityKind.liveSimulation && topic.style == SimulationStyle.anatomyGame) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AnatomyGameScreen(category: category, lab: lab)),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PracticeLabSessionScreen(
        category: category,
        lab: lab,
        courseName: course.name,
        topicAreaName: unit.name,
        topicName: topic.name,
        subjectId: subject.id,
        courseId: course.id,
        topicId: topic.id,
      ),
    ),
  );
}


PracticeLabType _labFor({
  required PracticeLabSubject subject,
  required PracticeLabCourse course,
  required PracticeLabUnit unit,
  required PracticeLabTopic topic,
  required TopicActivity activity,
  required PracticeDifficulty difficulty,
}) {
  final String styleLabel = activity.title;
  final bool csCodingCourse =
      subject.id == 'computer_science' && PracticeLabCourseTopics.codeLabForCourse(subject.id, course.id);
  final SimulationStyle sessionStyle = switch (activity.kind) {
    TopicActivityKind.puzzleChallenge => SimulationStyle.debugging,
    _ => activity.simulationStyle ?? topic.style,
  };
  final bool useCodeLab = csCodingCourse &&
      (activity.kind == TopicActivityKind.aiCodingInterview ||
          activity.kind == TopicActivityKind.puzzleChallenge ||
          activity.kind == TopicActivityKind.codeCompletion ||
          activity.kind == TopicActivityKind.scenarioChallenge);

  return PracticeLabType(
    id: 'topic_${subject.id}_${course.id}_${unit.id}_${topic.id}_${activity.kind.name}_${difficulty.name}',
    title: '${topic.name} · $styleLabel',
    subtitle:
        '${course.name} · ${unit.name} · ${activity.description} · ${difficulty.label}',
    style: sessionStyle,
    codeLab: useCodeLab,
    timed: activity.timed,
    aiRole: _aiRole(activity, topic),
    studentTasks: <String>[
      activity.description,
      'Apply ${topic.name} concepts accurately',
      'Explain your reasoning clearly',
    ],
    evaluationCriteria: const <String>['Accuracy', 'Critical thinking', 'Communication'],
    difficulty: difficulty.label,
  );
}

String _aiRole(TopicActivity activity, PracticeLabTopic topic) => switch (activity.kind) {
      TopicActivityKind.aiRoleplay => topic.aiRole,
      TopicActivityKind.caseStudy => 'Patient',
      TopicActivityKind.courtroomSimulation => 'Judge',
      TopicActivityKind.aiCodingInterview => 'Technical Interviewer',
      _ => topic.aiRole,
    };

VisualLabActivity _visualFor(TopicActivity activity, String subjectId) {
  final String id = activity.visualActivityId ?? activity.kind.name;
  final VisualLabActivity? existing = VisualLearningCatalog.activityById(id);
  if (existing != null) return existing;

  return VisualLabActivity(
    id: id,
    subjectId: subjectId,
    sectionTitle: activity.title,
    title: activity.title,
    description: activity.description,
    type: switch (activity.kind) {
      TopicActivityKind.dragDrop => VisualLabActivityType.dragDrop,
      TopicActivityKind.punnettSquare => VisualLabActivityType.interactiveDiagram,
      TopicActivityKind.virtualLab => VisualLabActivityType.virtualLab,
      TopicActivityKind.imageIdentification => VisualLabActivityType.imageIdentification,
      _ => VisualLabActivityType.labeling,
    },
    environment: VisualLearningCatalog.environmentFor(subjectId),
    diagramId: activity.diagramId,
    availability: activity.isLive ? VisualLabAvailability.live : VisualLabAvailability.aiFallback,
  );
}

/// Pick difficulty then launch a topic activity.
Future<void> pickDifficultyAndStartTopicActivity({
  required BuildContext context,
  required PracticeLabSubject subject,
  required PracticeLabCourse course,
  required PracticeLabUnit unit,
  required PracticeLabTopic topic,
  required TopicActivity activity,
}) async {
  final PracticeDifficulty? difficulty = await showModalBottomSheet<PracticeDifficulty>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext ctx) => _DifficultySheet(activity: activity, topic: topic),
  );

  if (!context.mounted || difficulty == null) return;
  startTopicActivity(
    context: context,
    subject: subject,
    course: course,
    unit: unit,
    topic: topic,
    activity: activity,
    difficulty: difficulty,
  );
}

class _DifficultySheet extends StatelessWidget {
  const _DifficultySheet({required this.activity, required this.topic});

  final TopicActivity activity;
  final PracticeLabTopic topic;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final PracticeLabColors lab = context.practiceLab;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${activity.emoji} ${activity.title}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(topic.name, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(activity.description, style: Theme.of(context).textTheme.bodyMedium),
          if (!activity.isLive) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'AI tutor guides you with hints, feedback, and a graded report',
                style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'CHOOSE DIFFICULTY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          if (topic.beginner)
            _DifficultyChip(
              label: '🟢 Beginner',
              subtitle: _subtitleFor(PracticeDifficulty.beginner),
              color: lab.success,
              onTap: () => Navigator.pop(context, PracticeDifficulty.beginner),
            ),
          if (topic.beginner) const SizedBox(height: 8),
          if (topic.intermediate)
            _DifficultyChip(
              label: '🟡 Intermediate',
              subtitle: _subtitleFor(PracticeDifficulty.intermediate),
              color: lab.warning,
              onTap: () => Navigator.pop(context, PracticeDifficulty.intermediate),
            ),
          if (topic.intermediate) const SizedBox(height: 8),
          if (topic.advanced)
            _DifficultyChip(
              label: '🔴 Advanced',
              subtitle: _subtitleFor(PracticeDifficulty.advanced),
              color: lab.danger,
              onTap: () => Navigator.pop(context, PracticeDifficulty.advanced),
            ),
        ],
      ),
    );
  }

  String _subtitleFor(PracticeDifficulty difficulty) {
    final TopicActivitySessionInfo info = TopicActivitySessionInfo.forActivity(activity, difficulty.label);
    return '${info.sizeLabel} · ${info.durationLabel}';
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.label, required this.subtitle, required this.color, required this.onTap});

  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: color.withValues(alpha: 0.75), fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.play_arrow_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}