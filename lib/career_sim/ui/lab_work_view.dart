import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../labs/lab_catalog.dart';
import '../labs/lab_models.dart';
import '../labs/ui/lab_screens.dart';
import '../labs/workplace.dart';
import '../model/career_models.dart';
import '../model/tasks.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'gg_kit.dart';

/// A workplace task done at the field's workstation (the practical lab).
/// The lab's own checks grade the work; the result is attached to the
/// assignment for the supervisor.
class LabWorkView extends StatelessWidget {
  const LabWorkView({super.key, required this.spec, required this.onGraded});
  final LabTaskSpec spec;
  final Future<void> Function(TaskResult result) onGraded;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final LabSpec? lab = LabCatalog.lab(spec.labId);
    final LabScenario? sc = lab?.scenario(spec.scenarioId);
    if (lab == null || sc == null) return const Text('This workstation task is not available.');
    final int issued = store.profile.currentJob?.open?.issuedDay ?? 0;
    LabCompletion? done;
    for (final LabCompletion c in store.profile.labCompletions.reversed) {
      if (c.labId == lab.id && c.scenarioId == sc.id && c.day >= issued) {
        done = c;
        break;
      }
    }
    final LabCompletion? last = done;
    final LabRun? run = store.labRun(lab.id);
    final bool inProgress = run != null && !run.done && run.scenarioId == sc.id;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text('Workstation: ${lab.environment.label} · ${sc.level.label}', style: TextStyle(color: GG.mute, fontSize: 12.5)),
      const SizedBox(height: 4),
      if (sc.briefing.expected.isNotEmpty) Text('Expected output: ${sc.briefing.expected}', style: TextStyle(color: GG.ink)),
      const SizedBox(height: 8),
      FilledButton.icon(
        key: const ValueKey<String>('work_open_lab'),
        onPressed: () async {
          final LabRun? r = await runCareerAction<LabRun>(context, () => store.startLab(lab, scenarioId: sc.id, restart: !inProgress, forWork: true));
          if (r != null && context.mounted) {
            await Navigator.of(context).push(ggRoute<void>((_) => LabSessionScreen(labId: lab.id)));
          }
        },
        icon: const Icon(Icons.desktop_windows_rounded),
        label: Text(inProgress ? 'Continue at the workstation' : (last == null ? 'Open the workstation' : 'Redo at the workstation')),
      ),
      if (last != null) ...<Widget>[
        const SizedBox(height: 10),
        Text('Workstation result: ${last.score}/100 · ${last.passed ? 'checks passed' : 'checks not passed'}', key: const ValueKey<String>('work_result'),
            style: TextStyle(color: last.passed ? GG.green : GG.red, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        FilledButton.tonalIcon(
          key: const ValueKey<String>('work_attach_result'),
          onPressed: () => onGraded(TaskResult(
            taskId: spec.id,
            score: last.score,
            passed: last.passed && last.score >= spec.passMark,
            feedback: <String>[
              performanceRating(last.score, last.passed),
              'Completed at the ${lab.environment.label.toLowerCase()} on day ${last.day}.',
            ],
          )),
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('Attach this result to the assignment'),
        ),
      ],
    ]);
  }
}
