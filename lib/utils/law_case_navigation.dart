import 'package:flutter/material.dart';

import '../data/law_simulation_data.dart';
import '../models/law_simulation.dart';
import '../models/practice_lab.dart';
import '../screens/law/law_case_side_select_screen.dart';
import '../services/law_case_history_service.dart';
import '../utils/study_messenger.dart';

/// Shared helpers for advancing to the next unplayed courtroom case.
class LawCaseNavigation {
  LawCaseNavigation._();

  static Future<void> openNextCase(
    BuildContext context, {
    required LawCaseFile current,
    required PracticeLabCategory category,
    required PracticeLabType lab,
    bool isDailyCase = false,
    bool replace = true,
  }) async {
    final LawCaseFile? next = await LawCaseHistoryService.instance.nextCase(
      currentCaseId: current.id,
      preferSpecializationId: current.specializationId,
    );
    if (!context.mounted) return;
    if (next == null) {
      StudyMessenger.showInfo(context, 'No more cases in the library right now.');
      return;
    }
    await LawCaseHistoryService.instance.markPlayed(current.id);
    if (!context.mounted) return;
    final MaterialPageRoute<void> route = MaterialPageRoute<void>(
      builder: (_) => LawCaseSideSelectScreen(
        caseFile: next,
        category: category,
        lab: lab,
        isDailyCase: isDailyCase,
      ),
    );
    if (replace) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }
  }

  static String nextButtonTooltip(LawCaseFile current) {
    final int left = LawCaseHistoryService.instance.remainingUnplayed(excludeCaseId: current.id);
    final int total = LawSimulationData.allCases.length;
    if (left <= 0) return 'Next case (new cycle · $total cases)';
    return 'Next case ($left left unplayed)';
  }
}
