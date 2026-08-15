import '../data/practice_lab_question_bank.dart';
import '../data/science_diagram_catalog.dart';
import '../models/topic_activity.dart';

/// Session size and time estimates shown before starting an activity.
class TopicActivitySessionInfo {
  const TopicActivitySessionInfo({
    required this.itemCount,
    required this.itemLabel,
    required this.estimatedMinutes,
  });

  final int itemCount;
  final String itemLabel;
  final int estimatedMinutes;

  String get durationLabel => estimatedMinutes <= 1 ? '~1 min' : '~$estimatedMinutes min';

  String get sizeLabel => '$itemCount $itemLabel';

  static TopicActivitySessionInfo forActivity(TopicActivity activity, String difficulty) {
    final String d = difficulty.toLowerCase();
    final bool isDiagram = activity.kind == TopicActivityKind.labelDiagram ||
        activity.kind == TopicActivityKind.dragDrop ||
        activity.kind == TopicActivityKind.matching ||
        activity.kind == TopicActivityKind.imageIdentification;

    if (isDiagram) {
      final int rounds = ScienceDiagramCatalog.roundTargetForDifficulty(difficulty);
      return TopicActivitySessionInfo(
        itemCount: rounds,
        itemLabel: 'labels',
        estimatedMinutes: _minutesForCount(rounds, secondsPerItem: 35),
      );
    }

    if (activity.kind == TopicActivityKind.aiCodingInterview) {
      final int problems = d.contains('adv') ? 3 : d.contains('inter') ? 2 : 1;
      return TopicActivitySessionInfo(
        itemCount: problems,
        itemLabel: problems == 1 ? 'problem' : 'problems',
        estimatedMinutes: problems * 25,
      );
    }

    if (activity.kind == TopicActivityKind.liveSimulation ||
        activity.kind == TopicActivityKind.scenarioChallenge ||
        activity.kind == TopicActivityKind.virtualLab) {
      return const TopicActivitySessionInfo(itemCount: 1, itemLabel: 'scenario', estimatedMinutes: 20);
    }

    if (activity.kind == TopicActivityKind.punnettSquare) {
      return const TopicActivitySessionInfo(itemCount: 12, itemLabel: 'crosses', estimatedMinutes: 15);
    }

    final int questions = PracticeLabQuestionBank.targetCountForDifficulty(difficulty);
    return TopicActivitySessionInfo(
      itemCount: questions,
      itemLabel: 'questions',
      estimatedMinutes: _minutesForCount(questions, secondsPerItem: 55),
    );
  }

  static int _minutesForCount(int count, {required int secondsPerItem}) {
    final int totalSeconds = count * secondsPerItem;
    return (totalSeconds / 60).ceil().clamp(5, 90);
  }
}
