import 'package:flutter/material.dart';

import '../data/science_diagram_catalog.dart';
import '../data/visual_learning_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/microbiology_specimen.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import '../models/visual_learning_lab.dart';
import '../screens/drag_drop_label_lab_screen.dart';
import '../screens/microbiology_id_lab_screen.dart';
import '../screens/practice_lab_session_screen.dart';
import '../screens/punnett_square_lab_screen.dart';
import '../screens/science_diagram_lab_screen.dart';
import '../screens/virtual_chemistry_lab_screen.dart';
import '../screens/law_simulation_hub_screen.dart';
import '../screens/virtual_hospital_hub_screen.dart';
import 'practice_lab_university_navigation.dart';

/// Builds a [PracticeLabType] for a visual learning activity.
PracticeLabType visualLabTypeFor({
  required PracticeLabSubject subject,
  required VisualLabActivity activity,
  required PracticeDifficulty difficulty,
}) {
  return PracticeLabType(
    id: 'visual_${activity.id}_${difficulty.name}',
    title: activity.title,
    subtitle:
        '${activity.sectionTitle} · ${activity.typeLabel} · ${difficulty.label} — ${activity.description}',
    style: activity.simulationStyle ?? SimulationStyle.diagramLab,
    timed: activity.type == VisualLabActivityType.aiSimulation,
    aiRole: _aiRoleFor(activity),
    studentTasks: _tasksFor(activity),
    evaluationCriteria: activity.scoreCategories.map(_scoreLabel).toList(),
    difficulty: difficulty.label,
  );
}

String? _aiRoleFor(VisualLabActivity activity) => switch (activity.type) {
      VisualLabActivityType.aiSimulation => switch (activity.simulationStyle) {
          SimulationStyle.erEmergency => 'Patient',
          SimulationStyle.courtroom => 'Judge',
          SimulationStyle.counseling => 'Client',
          SimulationStyle.codingInterview => 'Interviewer',
          SimulationStyle.classroom => 'Student',
          _ => 'AI Partner',
        },
      _ => null,
    };

List<String> _tasksFor(VisualLabActivity activity) => switch (activity.type) {
      VisualLabActivityType.labeling => <String>['Identify every labeled structure accurately'],
      VisualLabActivityType.dragDrop => <String>['Drag each label to the correct target'],
      VisualLabActivityType.aiSimulation => <String>['Assess the situation', 'Take appropriate action', 'Communicate clearly'],
      _ => <String>['Complete all prompts', 'Apply course concepts', 'Explain your reasoning'],
    };

String _scoreLabel(VisualLabScoreCategory category) => switch (category) {
      VisualLabScoreCategory.accuracy => 'Accuracy',
      VisualLabScoreCategory.speed => 'Speed',
      VisualLabScoreCategory.criticalThinking => 'Critical Thinking',
      VisualLabScoreCategory.communication => 'Communication',
      VisualLabScoreCategory.clinicalDecisionMaking => 'Clinical Decision Making',
    };

PracticeLabTopic syntheticTopicFor(VisualLabActivity activity) => PracticeLabTopic(
      id: activity.id,
      name: activity.title,
      description: activity.description,
      style: activity.simulationStyle ?? SimulationStyle.diagramLab,
      beginner: true,
      intermediate: true,
      advanced: true,
    );

PracticeLabUnit syntheticUnitFor(VisualLabActivity activity) => PracticeLabUnit(
      id: 'visual_${activity.sectionTitle.toLowerCase().replaceAll(' ', '_')}',
      name: activity.sectionTitle,
      topics: <PracticeLabTopic>[syntheticTopicFor(activity)],
    );

MicrobiologyCategory? _microCategoryFor(String activityId) => switch (activityId) {
      'bio_bacteria' => MicrobiologyCategory.bacteria,
      'bio_viruses' => MicrobiologyCategory.virus,
      'bio_fungi' => MicrobiologyCategory.fungi,
      _ => null,
    };

bool _isVirtualChemActivity(String id) =>
    id == 'chem_mix' || id == 'chem_ph' || id == 'chem_experiments';

/// Opens the correct screen for a visual learning activity.
void startVisualLearningActivity({
  required BuildContext context,
  required PracticeLabSubject subject,
  required VisualLabActivity activity,
  required PracticeDifficulty difficulty,
}) {
  final PracticeLabCategory category = subject.toCategory();
  final PracticeLabType lab = visualLabTypeFor(subject: subject, activity: activity, difficulty: difficulty);
  final PracticeLabTopic topic = syntheticTopicFor(activity);
  final VisualLabEnvironmentConfig env = VisualLearningCatalog.configForSubject(subject.id);

  if (activity.id == 'bio_punnett') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PunnettSquareLabScreen(category: category, lab: lab, activity: activity, difficulty: difficulty),
      ),
    );
    return;
  }

  if (_isVirtualChemActivity(activity.id)) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VirtualChemistryLabScreen(category: category, lab: lab, activity: activity, difficulty: difficulty),
      ),
    );
    return;
  }

  final MicrobiologyCategory? microCat = _microCategoryFor(activity.id);
  if (microCat != null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MicrobiologyIdLabScreen(
          category: category,
          lab: lab,
          activity: activity,
          difficulty: difficulty,
          specimenCategory: microCat,
        ),
      ),
    );
    return;
  }

  if (activity.id == 'law_trial') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawSimulationHubScreen(category: category, lab: lab),
      ),
    );
    return;
  }

  if (activity.id == 'nurse_virtual_hospital' || activity.id == 'med_teaching_hospital') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VirtualHospitalHubScreen(
          subject: subject,
          category: category,
          lab: lab,
          activity: activity,
          difficulty: difficulty,
          teachingHospital: activity.id == 'med_teaching_hospital',
        ),
      ),
    );
    return;
  }

  if (!activity.isLive && activity.type != VisualLabActivityType.aiSimulation) {
    _startAiFallback(
      context: context,
      subject: subject,
      activity: activity,
      difficulty: difficulty,
      category: category,
      lab: lab,
      topic: topic,
    );
    return;
  }

  if (activity.type == VisualLabActivityType.dragDrop && activity.diagramId == 'chem_equipment') {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DragDropLabelLabScreen(category: category, lab: lab, activity: activity, difficulty: difficulty),
      ),
    );
    return;
  }

  final String? diagramId = activity.diagramId;
  if ((activity.type == VisualLabActivityType.labeling ||
          activity.type == VisualLabActivityType.interactiveDiagram) &&
      diagramId != null &&
      ScienceDiagramCatalog.diagramById(diagramId) != null) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScienceDiagramLabScreen(
          category: category,
          lab: lab,
          subjectId: subject.id,
          courseId: activity.sectionTitle,
          topic: topic,
          diagramId: diagramId,
          useTypeEntry: activity.useTypeEntry,
          scoreCategories: activity.scoreCategories,
          environmentConfig: env,
        ),
      ),
    );
    return;
  }

  if (activity.type == VisualLabActivityType.aiSimulation) {
    _startAiFallback(
      context: context,
      subject: subject,
      activity: activity,
      difficulty: difficulty,
      category: category,
      lab: lab,
      topic: topic,
    );
    return;
  }

  _startAiFallback(
    context: context,
    subject: subject,
    activity: activity,
    difficulty: difficulty,
    category: category,
    lab: lab,
    topic: topic,
  );
}

void _startAiFallback({
  required BuildContext context,
  required PracticeLabSubject subject,
  required VisualLabActivity activity,
  required PracticeDifficulty difficulty,
  required PracticeLabCategory category,
  required PracticeLabType lab,
  required PracticeLabTopic topic,
}) {
  final PracticeLabCourse? course = subject.courses.isNotEmpty ? subject.courses.first : null;
  if (course != null) {
    final PracticeLabUnit unit = syntheticUnitFor(activity);
    startUniversityPracticeLab(
      context: context,
      subject: subject,
      course: course,
      unit: unit,
      topic: topic,
      difficulty: difficulty,
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PracticeLabSessionScreen(
        category: category,
        lab: lab,
        courseName: activity.sectionTitle,
        topicAreaName: activity.sectionTitle,
        topicName: activity.title,
      ),
    ),
  );
}

/// Show difficulty picker then launch a visual activity.
Future<void> pickDifficultyAndStartVisualActivity({
  required BuildContext context,
  required PracticeLabSubject subject,
  required VisualLabActivity activity,
}) async {
  final PracticeDifficulty? difficulty = await showModalBottomSheet<PracticeDifficulty>(
    context: context,
    backgroundColor: const Color(0xFF111827),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (BuildContext ctx) {
      final VisualLabEnvironmentConfig env = VisualLearningCatalog.configForSubject(subject.id);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(activity.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 6),
            Text(activity.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            if (!activity.isLive) ...<Widget>[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: env.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Includes AI-guided practice where the full interactive module is still in development',
                  style: TextStyle(color: env.accent, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Text('CHOOSE DIFFICULTY', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6)),
            const SizedBox(height: 12),
            _DifficultyChip(label: '🟢 Beginner', color: const Color(0xFF22C55E), onTap: () => Navigator.pop(ctx, PracticeDifficulty.beginner)),
            const SizedBox(height: 8),
            _DifficultyChip(label: '🟡 Intermediate', color: const Color(0xFFEAB308), onTap: () => Navigator.pop(ctx, PracticeDifficulty.intermediate)),
            const SizedBox(height: 8),
            _DifficultyChip(label: '🔴 Advanced', color: const Color(0xFFEF4444), onTap: () => Navigator.pop(ctx, PracticeDifficulty.advanced)),
          ],
        ),
      );
    },
  );

  if (!context.mounted || difficulty == null) return;
  startVisualLearningActivity(context: context, subject: subject, activity: activity, difficulty: difficulty);
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.label, required this.color, required this.onTap});

  final String label;
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
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }
}
