import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../vu_v2/design/vu_v2_theme.dart';
import '../../ai/career_ai.dart';
import '../../content/catalog.dart';
import '../../model/career_models.dart';
import '../../model/content_models.dart';
import '../../store/career_sim_store.dart';
import '../../ui/common.dart';
import '../../ui/task_views.dart';
import '../lab_catalog.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import '../lab_blueprint.g.dart';
import '../workplace.dart';
import '../math/math_views.dart';
import 'lab_tools.dart';
import 'step_views.dart';

IconData environmentIcon(LabEnvironment e) => switch (e) {
      LabEnvironment.computingLab => Icons.terminal_rounded,
      LabEnvironment.hospitalWard => Icons.local_hospital_rounded,
      LabEnvironment.clinicRoom => Icons.medical_services_rounded,
      LabEnvironment.accountingFirm => Icons.account_balance_rounded,
      LabEnvironment.mathsLab => Icons.functions_rounded,
      LabEnvironment.lawFirm => Icons.gavel_rounded,
      LabEnvironment.engineeringOffice => Icons.precision_manufacturing_rounded,
      LabEnvironment.scienceLab => Icons.biotech_rounded,
      LabEnvironment.businessOffice => Icons.business_center_rounded,
      LabEnvironment.techOffice => Icons.developer_board_rounded,
      LabEnvironment.securityOps => Icons.security_rounded,
      LabEnvironment.editorialOffice => Icons.edit_note_rounded,
    };

String labStatus(CareerProfile p, LabSpec lab) {
  final LabCompletion? best = p.bestLab(lab.id);
  final LabRun? run = p.labRuns[lab.id];
  if (run != null && !run.done) {
    final int total = lab.scenario(run.scenarioId)?.steps.length ?? 0;
    return 'In progress · ${run.results.length}/$total steps';
  }
  if (best != null) return '${best.passed ? 'Passed' : 'Completed'} · best ${best.score}/100';
  return 'Not started';
}

/// Directory of every practical lab, grouped by major. Labs in the
/// university blueprint that are not built yet are listed with their status
/// and cannot be opened.
class PracticalLabsScreen extends StatefulWidget {
  const PracticalLabsScreen({super.key});

  @override
  State<PracticalLabsScreen> createState() => _PracticalLabsScreenState();
}

class _PracticalLabsScreenState extends State<PracticalLabsScreen> {
  bool _mine = true;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final Department? dept = CareerCatalog.department(store.profile.deptId);
    final Set<String> deptMajors = <String>{...?dept?.majors};
    final bool mine = _mine && blueprintLabs.any((BlueprintLab b) => deptMajors.contains(b.majorId));
    final Map<String, List<BlueprintLab>> byMajor = <String, List<BlueprintLab>>{};
    for (final BlueprintLab b in blueprintLabs) {
      if (mine && !deptMajors.contains(b.majorId)) continue;
      byMajor.putIfAbsent(b.majorId, () => <BlueprintLab>[]).add(b);
    }
    // Majors with working labs first.
    final List<MapEntry<String, List<BlueprintLab>>> majors = byMajor.entries.toList()
      ..sort((MapEntry<String, List<BlueprintLab>> a, MapEntry<String, List<BlueprintLab>> b) =>
          b.value.where((BlueprintLab l) => l.built).length.compareTo(a.value.where((BlueprintLab l) => l.built).length));
    return Scaffold(
      appBar: AppBar(title: const Text('Practical Labs')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Wrap(spacing: 8, children: <Widget>[
            ChoiceChip(key: const ValueKey<String>('labs_mine'), label: const Text('My field'), selected: _mine, onSelected: (_) => setState(() => _mine = true)),
            ChoiceChip(key: const ValueKey<String>('labs_all'), label: const Text('All majors'), selected: !_mine, onSelected: (_) => setState(() => _mine = false)),
          ]),
          const SizedBox(height: 8),
          Text('${blueprintLabs.where((BlueprintLab b) => b.built).length} of ${blueprintLabs.length} university labs are open. Labs marked "Not started" are planned and cannot be opened yet.',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          for (final MapEntry<String, List<BlueprintLab>> e in majors)
            Card(
              margin: const EdgeInsets.only(top: 10),
              child: ExpansionTile(
                key: ValueKey<String>('major_${e.key}'),
                initiallyExpanded: e.value.any((BlueprintLab l) => l.built) && (mine || majors.indexOf(e) < 2),
                title: Text(e.value.first.major, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${e.value.first.school} · ${e.value.where((BlueprintLab l) => l.built).length}/${e.value.length} labs open'),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: <Widget>[for (final BlueprintLab b in e.value) LabCard(blueprint: b)],
              ),
            ),
        ],
      ),
    );
  }
}

/// One lab: name, description, skills, difficulty, status, previous score,
/// scenarios and a Start or Continue button.
class LabCard extends StatelessWidget {
  const LabCard({super.key, required this.blueprint});
  final BlueprintLab blueprint;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final LabSpec? lab = blueprint.built ? LabCatalog.lab(blueprint.labId) : null;
    if (lab == null) {
      return ListTile(
        key: ValueKey<String>('planned_${blueprint.majorId}_${blueprint.letter}'),
        contentPadding: EdgeInsets.zero,
        enabled: false,
        leading: const Icon(Icons.lock_clock_rounded),
        title: Text('${blueprint.letter}. ${blueprint.title}'),
        subtitle: Text(blueprintStatusLabels[blueprint.status] ?? blueprint.status),
      );
    }
    final Department? d = CareerCatalog.department(lab.deptId);
    final LabRun? run = store.labRun(lab.id);
    final bool inProgress = run != null && !run.done;
    final LabCompletion? best = store.profile.bestLab(lab.id);
    final int passedScenarios = lab.scenarios.where((LabScenario s) => store.profile.labScenarioPassed(lab.id, s.id)).length;
    void open() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LabIntroScreen(labId: lab.id)));
    return Container(
      key: ValueKey<String>('lab_${lab.id}'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: VuV2Colors.mute.withValues(alpha: 0.25)), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Icon(environmentIcon(lab.environment), color: VuV2Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('${blueprint.letter}. ${lab.title}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 4),
        Text(lab.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: VuV2Colors.mute, fontSize: 12.5)),
        const SizedBox(height: 4),
        Text('Skills: ${lab.skills.map((String s) => d?.skillLabel(s) ?? s).join(', ')}', style: TextStyle(color: VuV2Colors.ink, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
          StatusChip(lab.difficulty.label),
          StatusChip('${lab.scenarios.length} scenario${lab.scenarios.length == 1 ? '' : 's'} · $passedScenarios passed'),
          StatusChip(labStatus(store.profile, lab), color: VuV2Colors.mute),
          if (best != null) StatusChip('Previous best ${best.score}/100', color: VuV2Colors.mute),
        ]),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            key: ValueKey<String>('open_${lab.id}'),
            onPressed: open,
            child: Text(inProgress ? 'Continue' : (best == null ? 'Start' : 'Open')),
          ),
        ),
      ]),
    );
  }
}

/// Screen 1: what the lab is, what it needs, and previous results.
class LabIntroScreen extends StatelessWidget {
  const LabIntroScreen({super.key, required this.labId});
  final String labId;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final LabSpec? lab = LabCatalog.lab(labId);
    if (lab == null) return const Scaffold(body: Center(child: Text('Lab not found')));
    final Department? d = CareerCatalog.department(lab.deptId);
    final LabRun? run = store.labRun(lab.id);
    final bool inProgress = run != null && !run.done;
    final List<String> missing = store.labPrerequisitesMissing(lab);
    final List<LabCompletion> history = store.profile.labCompletions.where((LabCompletion c) => c.labId == lab.id).toList();
    final LabScenario? next = store.nextLabScenario(lab);
    Future<void> open(String scenarioId, {bool restart = false}) async {
      final LabRun? r = await runCareerAction<LabRun>(context, () => store.startLab(lab, scenarioId: scenarioId, restart: restart));
      if (r != null && context.mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LabSessionScreen(labId: lab.id)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Lab ${lab.number}: ${lab.title}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[
            Icon(environmentIcon(lab.environment), color: VuV2Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text('${d?.title ?? lab.deptId} · ${lab.environment.label}', style: TextStyle(color: VuV2Colors.mute))),
          ]),
          const SizedBox(height: 8),
          Text(lab.summary, style: TextStyle(color: VuV2Colors.ink, height: 1.45)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            StatusChip(lab.difficulty.label),
            StatusChip('About ${lab.minutes} min'),
            StatusChip(labStatus(store.profile, lab), color: VuV2Colors.mute),
          ]),
          const SizedBox(height: 12),
          SectionCard(title: 'Learning objectives', child: BulletList(lab.objectives, icon: Icons.flag_outlined)),
          SectionCard(title: 'Skills practised', child: Text(lab.skills.map((String s) => d?.skillLabel(s) ?? s).join(' · '), style: TextStyle(color: VuV2Colors.ink))),
          SectionCard(
            title: 'Prerequisites',
            child: lab.prerequisites.isEmpty
                ? Text('None.', style: TextStyle(color: VuV2Colors.mute))
                : BulletList(<String>[
                    for (final String id in lab.prerequisites)
                      '${LabCatalog.lab(id)?.title ?? id}${store.profile.labPassed(id) ? ' — passed' : ' — recommended first'}',
                  ]),
          ),
          for (final LabDifficulty level in LabDifficulty.values)
            if (lab.atLevel(level).isNotEmpty)
              SectionCard(
                title: '${level.label} scenarios',
                subtitle: level == LabDifficulty.foundation
                    ? 'Open to everyone.'
                    : 'Unlock by passing ${LabGrader.unlockAfter} ${LabDifficulty.values[level.index - 1].label.toLowerCase()} scenarios.',
                child: Column(children: <Widget>[
                  for (final LabScenario sc in lab.atLevel(level)) _ScenarioTile(lab: lab, scenario: sc, onOpen: () => open(sc.id, restart: true)),
                ]),
              ),
          if (history.isNotEmpty)
            SectionCard(
              title: 'Previous results',
              child: Column(children: <Widget>[
                for (final LabCompletion c in history.reversed.take(10))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${c.score}/100 · ${c.passed ? 'Passed' : 'Not passed'}'),
                    subtitle: Text('${lab.scenario(c.scenarioId)?.title ?? c.scenarioId} · Day ${c.day}'),
                  ),
              ]),
            ),
          if (missing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Recommended first: ${missing.join(', ')}. You can still start.', style: const TextStyle(color: Color(0xFFF59E0B))),
            ),
          if (inProgress) ...<Widget>[
            BusyButton(key: const ValueKey<String>('lab_continue'), label: 'Continue lab', icon: Icons.play_arrow_rounded, onPressed: () => open(run.scenarioId)),
            const SizedBox(height: 6),
            BusyButton(key: const ValueKey<String>('lab_restart'), label: 'Start over', icon: Icons.restart_alt_rounded, outlined: true, onPressed: () => open(run.scenarioId, restart: true)),
          ] else
            BusyButton(
              key: const ValueKey<String>('lab_start'),
              label: next == null ? 'Retake lab' : (history.isEmpty ? 'Start lab' : 'Next scenario: ${next.title}'),
              icon: Icons.play_arrow_rounded,
              onPressed: () => open((next ?? lab.scenarios.first).id, restart: true),
            ),
        ],
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({required this.lab, required this.scenario, required this.onOpen});
  final LabSpec lab;
  final LabScenario scenario;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final bool unlocked = store.labScenarioUnlocked(lab, scenario);
    final LabCompletion? best = store.profile.bestLabScenario(lab.id, scenario.id);
    final LabRun? run = store.labRun(lab.id);
    final bool current = run != null && !run.done && run.scenarioId == scenario.id;
    return ListTile(
      key: ValueKey<String>('scenario_${scenario.id}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        !unlocked ? Icons.lock_rounded : (best?.passed ?? false) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: (best?.passed ?? false) ? VuV2Colors.success : VuV2Colors.mute,
      ),
      title: Text(scenario.title),
      subtitle: Text('${scenario.steps.length} task${scenario.steps.length == 1 ? '' : 's'} · ${scenario.briefing.what}'
          '${best == null ? '' : ' · best ${best.score}/100'}${current ? ' · in progress' : ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: unlocked && !current
          ? TextButton(key: ValueKey<String>('start_${scenario.id}'), onPressed: onOpen, child: Text(best == null ? 'Start' : 'Retake'))
          : null,
    );
  }
}

/// The working tools available in a lab's environment.
class EnvironmentTools extends StatelessWidget {
  const EnvironmentTools({super.key, required this.lab});
  final LabSpec lab;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tools = <Widget>[];
    switch (lab.environment) {
      case LabEnvironment.computingLab:
        tools.add(const ExpansionTile(key: ValueKey<String>('tool_console'), tilePadding: EdgeInsets.zero, leading: Icon(Icons.terminal_rounded), title: Text('Console — run any program'), children: <Widget>[ConsoleTool()]));
        if (lab.database.isNotEmpty) {
          tools.add(ExpansionTile(key: const ValueKey<String>('tool_sql'), tilePadding: EdgeInsets.zero, leading: const Icon(Icons.storage_rounded), title: const Text('SQL workbench'), children: <Widget>[SqlWorkbench(lab: lab)]));
        }
      case LabEnvironment.hospitalWard:
      case LabEnvironment.clinicRoom:
        for (final Patient p in lab.patients) {
          tools.add(ExpansionTile(
            key: ValueKey<String>('tool_patient_${p.id}'),
            tilePadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_shared_rounded),
            title: Text('Patient record — ${p.name}, ${p.bed}'),
            children: <Widget>[PatientChartView(patient: p), if (p.vitals.isNotEmpty) ...<Widget>[const SizedBox(height: 6), BedsideMonitor(vitals: p.vitals.first)]],
          ));
        }
        if (lab.id == 'md_lab_anatomy') {
          tools.add(const ExpansionTile(key: ValueKey<String>('tool_atlas'), tilePadding: EdgeInsets.zero, leading: Icon(Icons.accessibility_new_rounded), title: Text('Anatomy atlas'), children: <Widget>[AnatomyAtlas()]));
        }
      case LabEnvironment.mathsLab:
      case LabEnvironment.engineeringOffice:
      case LabEnvironment.scienceLab:
        tools.addAll(mathsTools(lab));
      case LabEnvironment.businessOffice:
      case LabEnvironment.techOffice:
      case LabEnvironment.securityOps:
      case LabEnvironment.lawFirm:
      case LabEnvironment.editorialOffice:
        tools.add(const ExpansionTile(key: ValueKey<String>('tool_calculator'), tilePadding: EdgeInsets.zero, leading: Icon(Icons.calculate_rounded), title: Text('Calculator'), children: <Widget>[CalculatorTool()]));
        tools.add(ExpansionTile(key: const ValueKey<String>('tool_notes'), tilePadding: EdgeInsets.zero, leading: const Icon(Icons.draw_rounded), title: const Text('Scratch pad (saved)'), children: <Widget>[Whiteboard(lab: lab)]));
      case LabEnvironment.accountingFirm:
        tools.add(const ExpansionTile(
          key: ValueKey<String>('tool_policies'),
          tilePadding: EdgeInsets.zero,
          leading: Icon(Icons.rule_rounded),
          title: Text('Firm reference: double entry'),
          children: <Widget>[
            BulletList(<String>[
              'Assets and expenses increase with a debit.',
              'Liabilities, equity and revenue increase with a credit.',
              'Every entry must have equal debits and credits.',
            ]),
          ],
        ));
    }
    if (lab.reference.isNotEmpty) {
      tools.add(ExpansionTile(
        key: const ValueKey<String>('tool_reference'),
        tilePadding: EdgeInsets.zero,
        leading: const Icon(Icons.menu_book_rounded),
        title: const Text('Workplace reference'),
        children: <Widget>[BulletList(lab.reference)],
      ));
    }
    if (tools.isEmpty) return Text('No tools in this environment.', style: TextStyle(color: VuV2Colors.mute));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: tools);
  }
}

/// Screens 2–6: environment, briefing, work, evaluation and completion.
class LabSessionScreen extends StatelessWidget {
  const LabSessionScreen({super.key, required this.labId});
  final String labId;

  static const List<String> _phaseLabels = <String>['Clock in', 'Inbox', 'Work queue', 'Review', 'Logged'];

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final LabSpec? lab = LabCatalog.lab(labId);
    final LabRun? run = lab == null ? null : store.labRun(lab.id);
    if (lab == null || run == null) return const Scaffold(body: Center(child: Text('Start the lab from its introduction.')));
    final LabScenario sc = lab.scenario(run.scenarioId)!;
    return Scaffold(
      appBar: AppBar(title: Text(lab.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Row(children: <Widget>[
            for (int i = 0; i < _phaseLabels.length; i++) ...<Widget>[
              Expanded(
                child: Column(children: <Widget>[
                  Container(height: 4, color: i <= run.phase.index ? VuV2Colors.orange : VuV2Colors.stroke),
                  const SizedBox(height: 2),
                  Text(_phaseLabels[i], style: TextStyle(fontSize: 10, color: i == run.phase.index ? VuV2Colors.ink : VuV2Colors.mute)),
                ]),
              ),
              if (i < _phaseLabels.length - 1) const SizedBox(width: 3),
            ],
          ]),
          const SizedBox(height: 12),
          switch (run.phase) {
            LabPhase.environment => _EnvironmentPhase(lab: lab, scenario: sc),
            LabPhase.briefing => _BriefingPhase(lab: lab, scenario: sc),
            LabPhase.work => _WorkPhase(lab: lab, scenario: sc, run: run),
            LabPhase.evaluation => _EvaluationPhase(lab: lab, scenario: sc, run: run),
            LabPhase.complete => _CompletePhase(lab: lab, run: run),
          },
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.lab, required this.scenario});
  final LabSpec lab;
  final LabScenario scenario;

  @override
  Widget build(BuildContext context) {
    final Workplace w = workplaceFor(lab);
    return SectionCard(
      key: const ValueKey<String>('shift_card'),
      title: 'Your shift at ${w.employer}',
      subtitle: '${w.kind} · ${w.location}',
      child: BulletList(<String>[
        'Role: ${w.role}',
        'Supervisor: ${w.supervisor.name}, ${w.supervisor.role}',
        'Assignment: ${scenario.title} (${scenario.level.label})',
        'Expected time: about ${lab.minutes} minutes · ${scenario.steps.length} ticket${scenario.steps.length == 1 ? '' : 's'} in your queue',
        'Your supervisor reviews every submission and signs off the shift at the end.',
      ], icon: Icons.badge_rounded),
    );
  }
}

class _EnvironmentPhase extends StatelessWidget {
  const _EnvironmentPhase({required this.lab, required this.scenario});
  final LabSpec lab;
  final LabScenario scenario;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(lab.environment.label, style: TextStyle(color: VuV2Colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(scenario.title, style: TextStyle(color: VuV2Colors.mute)),
        const SizedBox(height: 10),
        _ShiftCard(lab: lab, scenario: scenario),
        if (scenario.people.isNotEmpty)
          SectionCard(
            title: 'People here',
            child: Column(children: <Widget>[
              for (final LabPerson p in scenario.people)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(p.name.split(' ').map((String w) => w.isEmpty ? '' : w[0]).take(2).join())),
                  title: Text('${p.name} · ${p.role}'),
                  subtitle: Text('“${p.says}”'),
                ),
            ]),
          ),
        SectionCard(title: 'Equipment and records', subtitle: 'These tools work — open them now or at any point during the work.', child: EnvironmentTools(lab: lab)),
        BusyButton(
          key: const ValueKey<String>('to_briefing'),
          label: 'Clock in and open your inbox',
          icon: Icons.login_rounded,
          onPressed: () => runCareerAction<void>(context, () => store.setLabPhase(lab, LabPhase.briefing)),
        ),
      ],
    );
  }
}

class _BriefingPhase extends StatelessWidget {
  const _BriefingPhase({required this.lab, required this.scenario});
  final LabSpec lab;
  final LabScenario scenario;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    final Briefing b = scenario.briefing;
    final Workplace w = workplaceFor(lab);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionCard(
          key: const ValueKey<String>('inbox_email'),
          title: 'Inbox · 1 new message',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('From: ${w.supervisor.name} (${w.supervisor.role}, ${w.employer})', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
            Text('To: you (${w.role})', style: TextStyle(color: VuV2Colors.mute, fontSize: 12.5)),
            Text('Subject: ${scenario.title} — ${scenario.level.label.toLowerCase()} assignment', style: TextStyle(color: VuV2Colors.ink)),
            const Divider(),
            Text('Hi — please pick this up today. Everything you need is below and in the ${lab.environment.label.toLowerCase()}. '
                'Work through the queue; I will review each item when you submit.', style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
          ]),
        ),
        SectionCard(title: 'What needs to be done', child: Text(b.what, style: TextStyle(color: VuV2Colors.ink, height: 1.4))),
        SectionCard(title: 'Why it matters', child: Text(b.why, style: TextStyle(color: VuV2Colors.ink, height: 1.4))),
        SectionCard(title: 'Information available', child: BulletList(b.information)),
        SectionCard(title: 'Tools', child: BulletList(b.tools, icon: Icons.build_rounded)),
        SectionCard(title: 'Expected result', child: Text(b.expected, style: TextStyle(color: VuV2Colors.ink, height: 1.4))),
        if (b.requirements.isNotEmpty)
          SectionCard(title: 'Safety and professional requirements', child: BulletList(b.requirements, icon: Icons.health_and_safety_rounded, color: VuV2Colors.danger)),
        SectionCard(title: 'Tasks', child: BulletList(<String>[for (final LabStep s in scenario.steps) '${s.title} (${s.kind})'])),
        BusyButton(
          key: const ValueKey<String>('begin_work'),
          label: 'Accept and open the work queue',
          icon: Icons.play_arrow_rounded,
          onPressed: () => runCareerAction<void>(context, () => store.setLabPhase(lab, LabPhase.work)),
        ),
      ],
    );
  }
}

class _WorkPhase extends StatelessWidget {
  const _WorkPhase({required this.lab, required this.scenario, required this.run});
  final LabSpec lab;
  final LabScenario scenario;
  final LabRun run;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    final int i = run.stepIndex.clamp(0, scenario.steps.length - 1);
    final LabStep step = scenario.steps[i];
    final TaskResult? done = run.results[step.id];
    final bool last = i == scenario.steps.length - 1;
    final bool allDone = scenario.steps.every((LabStep s) => run.results.containsKey(s.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Work queue · ticket ${i + 1} of ${scenario.steps.length}: ${step.title}', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
          for (int k = 0; k < scenario.steps.length; k++)
            ChoiceChip(
              key: ValueKey<String>('step_tab_$k'),
              avatar: run.results[scenario.steps[k].id] == null
                  ? null
                  : Icon(run.results[scenario.steps[k].id]!.passed ? Icons.check_rounded : Icons.close_rounded, size: 16),
              label: Text('${k + 1}'),
              selected: k == i,
              onSelected: (_) => runCareerAction<void>(context, () => store.goToLabStep(lab, k)),
            ),
        ]),
        const SizedBox(height: 10),
        if (done != null) ...<Widget>[
          Text('Last attempt at this task', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          ResultPanel(result: done),
          const SizedBox(height: 8),
        ],
        LabStepView(
          key: ValueKey<String>('step_${run.scenarioId}_${step.id}_${done?.day ?? -1}_${done?.score ?? -1}'),
          lab: lab,
          step: step,
          onGraded: (TaskResult r) async {
            await runCareerAction<TaskResult>(context, () => store.recordLabStep(lab, step, r));
          },
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          key: const ValueKey<String>('work_tools'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Environment tools'),
          children: <Widget>[EnvironmentTools(lab: lab)],
        ),
        ExpansionTile(
          key: const ValueKey<String>('work_ai'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Ask the AI lecturer for a hint'),
          children: <Widget>[AiAssistPanel(role: CareerAiRole.lecturer, contextText: 'Lab: ${lab.title}. Task: ${step.title}. ${step.instructions}')],
        ),
        const SizedBox(height: 8),
        Row(children: <Widget>[
          if (i > 0) TextButton(key: const ValueKey<String>('step_prev'), onPressed: () => runCareerAction<void>(context, () => store.goToLabStep(lab, i - 1)), child: const Text('Previous task')),
          const Spacer(),
          if (!last)
            FilledButton(
              key: const ValueKey<String>('step_next'),
              onPressed: done == null
                  ? null
                  : () => runCareerAction<void>(context, () => store.goToLabStep(lab, i + 1)),
              child: const Text('Next task'),
            ),
          if (last)
            BusyButton(
              key: const ValueKey<String>('to_evaluation'),
              label: 'See evaluation',
              icon: Icons.assessment_rounded,
              onPressed: allDone ? () => runCareerAction<void>(context, () => store.setLabPhase(lab, LabPhase.evaluation)) : null,
            ),
        ]),
        if (!allDone && last) Text('Submit every task to see the evaluation.', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
      ],
    );
  }
}

class _EvaluationPhase extends StatelessWidget {
  const _EvaluationPhase({required this.lab, required this.scenario, required this.run});
  final LabSpec lab;
  final LabScenario scenario;
  final LabRun run;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    final Department? d = CareerCatalog.department(lab.deptId);
    final (int score, bool passed) = LabGrader.scenario(scenario, run.results);
    final List<LabStep> good = scenario.steps.where((LabStep s) => run.results[s.id]?.passed ?? false).toList();
    final List<LabStep> bad = scenario.steps.where((LabStep s) => !(run.results[s.id]?.passed ?? false)).toList();
    final Set<String> skills = <String>{for (final LabStep s in good) ...(s.skills.isEmpty ? lab.skills : s.skills)};
    final Workplace w = workplaceFor(lab);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionCard(
          key: const ValueKey<String>('supervisor_review'),
          title: 'Supervisor review · ${performanceRating(score, passed)}',
          subtitle: '${w.supervisor.name}, ${w.supervisor.role} · ${w.employer}',
          child: Text(supervisorReview(lab, scenario, run.results, score, passed), style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
        ),
        SectionCard(
          title: 'Final result: $score/100 · ${passed ? 'Passed' : 'Not passed'}',
          subtitle: '${good.length} of ${scenario.steps.length} tasks passed. A lab is passed when every task meets its pass mark.',
          trailing: const ValidatedBadge(),
          child: Column(children: <Widget>[
            for (final LabStep s in scenario.steps)
              ExpansionTile(
                key: ValueKey<String>('eval_${s.id}'),
                tilePadding: EdgeInsets.zero,
                leading: Icon(run.results[s.id]!.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: run.results[s.id]!.passed ? VuV2Colors.success : VuV2Colors.danger),
                title: Text(s.title),
                subtitle: Text('${run.results[s.id]!.score}/100 · ${s.kind}'),
                children: <Widget>[BulletList(run.results[s.id]!.feedback)],
              ),
          ]),
        ),
        SectionCard(
          title: 'Professional skills demonstrated',
          child: Text(skills.isEmpty ? 'None yet — pass a task to demonstrate a skill.' : skills.map((String s) => d?.skillLabel(s) ?? s).join(' · '), style: TextStyle(color: VuV2Colors.ink)),
        ),
        if (bad.isNotEmpty)
          SectionCard(
            title: 'Areas to improve',
            child: BulletList(<String>[for (final LabStep s in bad) ...run.results[s.id]!.feedback.take(2).map((String f) => '${s.title}: $f')]),
          ),
        Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
          OutlinedButton(key: const ValueKey<String>('eval_back'), onPressed: () => runCareerAction<void>(context, () => store.goToLabStep(lab, 0)), child: const Text('Revise my work')),
          BusyButton(
            key: const ValueKey<String>('finish_lab'),
            label: 'Finish and save result',
            icon: Icons.save_rounded,
            onPressed: () async {
              await runCareerAction<LabCompletion>(context, () => store.finishLab(lab), success: 'Lab result saved.');
            },
          ),
        ]),
      ],
    );
  }
}

class _CompletePhase extends StatelessWidget {
  const _CompletePhase({required this.lab, required this.run});
  final LabSpec lab;
  final LabRun run;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = careerStore(context);
    final bool passed = store.profile.labCompletions.any((LabCompletion c) => c.labId == lab.id && c.passed && c.day == run.completedDay && c.score == run.score);
    final LabScenario? nextScenario = store.nextLabScenario(lab);
    LabSpec? next;
    for (final LabSpec l in LabCatalog.forMajor(lab.majorId)) {
      if (!store.profile.labPassed(l.id) && l.id != lab.id) {
        next = l;
        break;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(passed ? Icons.verified_rounded : Icons.flag_rounded, size: 48, color: passed ? VuV2Colors.success : VuV2Colors.orange),
        Text(passed ? 'Lab passed — ${run.score}/100' : 'Lab completed — ${run.score}/100', textAlign: TextAlign.center, style: TextStyle(color: VuV2Colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        SectionCard(
          title: 'Saved to your record',
          child: BulletList(<String>[
            'Lab result and every task attempt',
            if (passed) 'Skill progress for ${lab.skills.length} skill(s)',
            if (passed && lab.addsToPortfolio) 'Project added to your portfolio',
            'Work experience log: ${shiftHours(lab)} h as ${workplaceFor(lab).role} at ${workplaceFor(lab).employer}',
            'Practical experience counted in your career readiness',
            if (!passed) 'Retake the lab to pass every task — your best result is kept.',
          ], icon: Icons.check_rounded),
        ),
        if (nextScenario != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: BusyButton(
              key: const ValueKey<String>('next_scenario'),
              label: 'Next challenge: ${nextScenario.title} (${nextScenario.level.label})',
              icon: Icons.trending_up_rounded,
              onPressed: () async {
                await runCareerAction<LabRun>(context, () => store.startLab(lab, scenarioId: nextScenario.id, restart: true));
              },
            ),
          ),
        if (next != null)
          FilledButton.icon(
            key: const ValueKey<String>('next_lab'),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => LabIntroScreen(labId: next!.id))),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text('Next: ${next.title}'),
          ),
        const SizedBox(height: 6),
        OutlinedButton(key: const ValueKey<String>('lab_done'), onPressed: () => Navigator.of(context).pop(), child: const Text('Back to the lab')),
      ],
    );
  }
}
