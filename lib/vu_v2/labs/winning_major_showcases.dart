import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lab_mission_celebration.dart';
import 'university_lab_result.dart';
import 'workplace_immersion.dart';

/// Graded interactive practicals — immersive real workplaces + board viva.
abstract final class WinningMajorShowcases {
  static Future<void> openChemistry(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.chemBench,
        builder: () => const ChemistryTitrationShowcaseLab(),
      );
  static Future<void> openPhysics(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.physicsBay,
        builder: () => const PhysicsEnergyShowcaseLab(),
      );
  static Future<void> openNursing(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.emergencyDept,
        builder: () => const NursingTriageShowcaseLab(),
      );
  static Future<void> openMedicine(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.hospitalWard,
        builder: () => const MedicineDifferentialShowcaseLab(),
      );
  static Future<void> openBusiness(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.warRoom,
        builder: () => const BusinessWarRoomShowcaseLab(),
      );
  static Future<void> openFinance(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.financeDesk,
        builder: () => const FinanceDeskShowcaseLab(),
      );
  static Future<void> openAccounting(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.auditRoom,
        builder: () => const AccountingAuditShowcaseLab(),
      );
  static Future<void> openMarketing(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.marketingStudio,
        builder: () => const MarketingCampaignShowcaseLab(),
      );
  static Future<void> openEconomics(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.policyOffice,
        builder: () => const EconomicsPolicyShowcaseLab(),
      );
  static Future<void> openPharmacy(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.pharmacyCounter,
        builder: () => const PharmacyRxShowcaseLab(),
      );
  static Future<void> openMls(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.mlsBench,
        builder: () => const MlsCriticalShowcaseLab(),
      );
  static Future<void> openPsychology(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.researchLab,
        builder: () => const PsychologyMethodsShowcaseLab(),
      );
  static Future<void> openMathematics(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.mathStudio,
        builder: () => const MathModelShowcaseLab(),
      );
  static Future<void> openCyber(BuildContext context) =>
      WorkplaceEntranceGate.openThen(
        context,
        kind: WorkplaceKind.soc,
        builder: () => const CyberSocShowcaseLab(),
      );
}

// ── Shared graded shell ─────────────────────────────────────────────────────

class _PhaseChoice {
  const _PhaseChoice({required this.id, required this.label});
  final String id;
  final String label;
}

Future<void> _finishShowcase({
  required BuildContext context,
  required Stopwatch clock,
  required bool stepsOk,
  required bool vivaOk,
  required String passNote,
  required String failNote,
  required String vivaPass,
  required String vivaFail,
  required String titlePass,
  required String titleFail,
  required String accentLabel,
  String? badgeId,
}) async {
  clock.stop();
  final double accuracy =
      ((stepsOk ? 0.65 : 0.28) + (vivaOk ? 0.35 : 0)).clamp(0.0, 1.0);
  final UniversityLabResult result = UniversityLabResult(
    accuracy: accuracy,
    identifyCorrect: (stepsOk ? 1 : 0) + (vivaOk ? 1 : 0),
    identifyAttempts: 2,
    viewsVisited: 3,
    labelDrillComplete: stepsOk,
    coachingNotes: <String>[
      stepsOk ? passNote : failNote,
      vivaOk ? vivaPass : vivaFail,
    ],
    xpEarned: accuracy >= 0.85 ? 210 : 130,
    secondsElapsed: clock.elapsed.inSeconds,
    badgeId: accuracy >= 0.85 ? badgeId : null,
    clinicalSolved: stepsOk && vivaOk,
    clinicalReasoningScore: vivaOk ? 1 : 0.35,
  );
  if (!context.mounted) return;
  await showLabMissionCelebration(
    context: context,
    result: result,
    title: result.clinicalSolved ? titlePass : titleFail,
    accentLabel: accentLabel,
  );
  if (context.mounted) Navigator.of(context).pop(result);
}

class _ShowcaseScaffold extends StatelessWidget {
  const _ShowcaseScaffold({
    required this.title,
    required this.accent,
    required this.bannerTitle,
    required this.bannerBody,
    required this.child,
    required this.workplace,
  });

  final String title;
  final Color accent;
  final String bannerTitle;
  final String bannerBody;
  final Widget child;
  final WorkplaceKind workplace;

  @override
  Widget build(BuildContext context) {
    final WorkplaceSet set = WorkplaceSet.of(workplace);
    return WorkplaceImmersionShell(
      set: set,
      titleOverride: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: set.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: set.accent.withValues(alpha: 0.45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  bannerTitle,
                  style: TextStyle(
                    color: set.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bannerBody,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    required this.choices,
    required this.selectedId,
    required this.accent,
    required this.onSelect,
  });

  final List<_PhaseChoice> choices;
  final String? selectedId;
  final Color accent;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: choices.map((_PhaseChoice c) {
        final bool on = selectedId == c.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            tileColor: const Color(0xFF0B1622),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: on ? accent : Colors.white12,
              ),
            ),
            leading: Icon(
              on ? Icons.radio_button_checked : Icons.radio_button_off,
              color: accent,
            ),
            title: Text(
              c.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              onSelect(c.id);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _VivaBlock extends StatelessWidget {
  const _VivaBlock({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.accent,
    required this.selected,
    required this.onSelect,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final Color accent;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'BOARD VIVA',
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          prompt,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(options.length, (int i) {
          final bool on = selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => onSelect(i),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: on ? accent : Colors.white24),
                backgroundColor: on ? accent.withValues(alpha: 0.18) : null,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                alignment: Alignment.centerLeft,
              ),
              child: Text(options[i]),
            ),
          );
        }),
      ],
    );
  }
}

// ── Chemistry ───────────────────────────────────────────────────────────────

class ChemistryTitrationShowcaseLab extends StatefulWidget {
  const ChemistryTitrationShowcaseLab({super.key});

  @override
  State<ChemistryTitrationShowcaseLab> createState() =>
      _ChemistryTitrationShowcaseLabState();
}

class _ChemistryTitrationShowcaseLabState
    extends State<ChemistryTitrationShowcaseLab> {
  static const Color accent = Color(0xFF2DD4BF);
  final Stopwatch _clock = Stopwatch()..start();
  String? _indicator;
  String? _endpoint;
  bool _onViva = false;
  int? _viva;

  bool get _stepsOk => _indicator == 'phenolphthalein' && _endpoint == 'faint_pink';

  @override
  Widget build(BuildContext context) {
    return _ShowcaseScaffold(
      title: 'Chemistry · Titration Practical',
      workplace: WorkplaceKind.chemBench,
      accent: accent,
      bannerTitle: 'ANALYTICAL BENCH · UNKNOWN ACID',
      bannerBody:
          'Pick indicator → stop at true endpoint → defend equivalence in viva. '
          'Competitors quiz formulas. You run the board.',
      child: !_onViva
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('1 · Indicator',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _ChoiceList(
                  accent: accent,
                  selectedId: _indicator,
                  onSelect: (String id) => setState(() => _indicator = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(id: 'phenolphthalein', label: 'Phenolphthalein'),
                    _PhaseChoice(id: 'methyl_orange', label: 'Methyl orange'),
                    _PhaseChoice(id: 'none', label: 'No indicator needed'),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('2 · Endpoint',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _ChoiceList(
                  accent: accent,
                  selectedId: _endpoint,
                  onSelect: (String id) => setState(() => _endpoint = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(id: 'faint_pink', label: 'Stop at lasting faint pink'),
                    _PhaseChoice(id: 'deep_red', label: 'Keep going to deep red'),
                    _PhaseChoice(id: 'colorless', label: 'Stop while still colorless'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _stepsOk
                      ? () => setState(() => _onViva = true)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Phenolphthalein + lasting faint pink before viva.',
                              ),
                            ),
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('EQUIVALENCE VIVA',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                _VivaBlock(
                  accent: accent,
                  prompt: 'Why does the faint pink endpoint approximate equivalence?',
                  options: const <String>[
                    'Color is random',
                    'One drop past equivalence flips the indicator in a tiny volume',
                    'You need excess base always',
                    'Indicators ignore pH',
                  ],
                  correctIndex: 1,
                  selected: _viva,
                  onSelect: (int i) => setState(() => _viva = i),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _viva == null
                      ? null
                      : () => _finishShowcase(
                            context: context,
                            clock: _clock,
                            stepsOk: _stepsOk,
                            vivaOk: _viva == 1,
                            passNote: 'Titration technique locked: indicator + endpoint.',
                            failNote: 'Re-run: phenolphthalein → lasting faint pink.',
                            vivaPass: 'Equivalence viva passed — you defended the WHY.',
                            vivaFail: 'Viva weak — endpoint ≠ random color change.',
                            titlePass: 'TITRATION PRACTICAL PASSED',
                            titleFail: 'TITRATION LAB COMPLETE',
                            accentLabel: 'Analytical Chemist',
                            badgeId: 'titration_board',
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('SUBMIT BOARD SCORE',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
    );
  }
}

// ── Physics ─────────────────────────────────────────────────────────────────

class PhysicsEnergyShowcaseLab extends StatefulWidget {
  const PhysicsEnergyShowcaseLab({super.key});

  @override
  State<PhysicsEnergyShowcaseLab> createState() =>
      _PhysicsEnergyShowcaseLabState();
}

class _PhysicsEnergyShowcaseLabState extends State<PhysicsEnergyShowcaseLab> {
  static const Color accent = Color(0xFF60A5FA);
  final Stopwatch _clock = Stopwatch()..start();
  String? _model;
  String? _conserve;
  bool _onViva = false;
  int? _viva;

  bool get _stepsOk => _model == 'me_total' && _conserve == 'no_noncons';

  @override
  Widget build(BuildContext context) {
    return _ShowcaseScaffold(
      title: 'Physics · Energy Practical',
      workplace: WorkplaceKind.physicsBay,
      accent: accent,
      bannerTitle: 'MECHANICS BAY · ROLLER TRACK',
      bannerBody:
          'Choose the energy model → state conservation conditions → defend the WHY. '
          'Not a multiple-choice dump — a board viva.',
      child: !_onViva
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('1 · Model the cart',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _model,
                  onSelect: (String id) => setState(() => _model = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(id: 'me_total', label: 'Track KE + PE (mechanical energy)'),
                    _PhaseChoice(id: 'force_only', label: 'Ignore energy; only use F=ma slogans'),
                    _PhaseChoice(id: 'heat_only', label: 'Assume all energy is heat already'),
                  ],
                ),
                const Text('2 · Conservation',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _conserve,
                  onSelect: (String id) => setState(() => _conserve = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(
                        id: 'no_noncons',
                        label: 'ME conserved if non-conservative work ≈ 0'),
                    _PhaseChoice(id: 'always', label: 'ME always conserved, friction OK'),
                    _PhaseChoice(id: 'never', label: 'Energy is never conserved'),
                  ],
                ),
                FilledButton(
                  onPressed: _stepsOk
                      ? () => setState(() => _onViva = true)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pick KE+PE model + real conservation rule.'),
                            ),
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('ENERGY VIVA',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                _VivaBlock(
                  accent: accent,
                  prompt: 'Cart loses height but speeds up. Best explanation?',
                  options: const <String>[
                    'Energy appeared from nowhere',
                    'PE converted to KE (approx. conserved ME)',
                    'Mass changed',
                    'Gravity turned off',
                  ],
                  correctIndex: 1,
                  selected: _viva,
                  onSelect: (int i) => setState(() => _viva = i),
                ),
                FilledButton(
                  onPressed: _viva == null
                      ? null
                      : () => _finishShowcase(
                            context: context,
                            clock: _clock,
                            stepsOk: _stepsOk,
                            vivaOk: _viva == 1,
                            passNote: 'Energy model + conservation conditions locked.',
                            failNote: 'Revisit KE/PE accounting and friction assumptions.',
                            vivaPass: 'Viva passed — PE→KE conversion defended.',
                            vivaFail: 'Viva weak — height drop must map to KE gain.',
                            titlePass: 'ENERGY PRACTICAL PASSED',
                            titleFail: 'ENERGY LAB COMPLETE',
                            accentLabel: 'Physics Lab',
                            badgeId: 'energy_board',
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('SUBMIT BOARD SCORE',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
    );
  }
}

// ── Nursing ─────────────────────────────────────────────────────────────────

class NursingTriageShowcaseLab extends StatefulWidget {
  const NursingTriageShowcaseLab({super.key});

  @override
  State<NursingTriageShowcaseLab> createState() =>
      _NursingTriageShowcaseLabState();
}

class _NursingTriageShowcaseLabState extends State<NursingTriageShowcaseLab> {
  static const Color accent = Color(0xFFF472B6);
  final Stopwatch _clock = Stopwatch()..start();
  String? _priority;
  String? _abc;
  bool _onViva = false;
  int? _viva;

  bool get _stepsOk => _priority == 'airway' && _abc == 'oxygen_then_escalate';

  @override
  Widget build(BuildContext context) {
    return _ShowcaseScaffold(
      title: 'Nursing · ED Triage Practical',
      workplace: WorkplaceKind.emergencyDept,
      accent: accent,
      bannerTitle: 'ED · THREE PATIENTS ARRIVE',
      bannerBody:
          'Prioritize life threats → run ABC → escalate with reasoning. '
          'University practicals grade judgment under pressure.',
      child: !_onViva
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('1 · Who first?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _priority,
                  onSelect: (String id) => setState(() => _priority = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(
                        id: 'airway',
                        label: 'Stridor + cyanosis (airway threat)'),
                    _PhaseChoice(id: 'ankle', label: 'Stable ankle sprain'),
                    _PhaseChoice(id: 'paperwork', label: 'Charting backlog first'),
                  ],
                ),
                const Text('2 · Immediate action',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _abc,
                  onSelect: (String id) => setState(() => _abc = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(
                        id: 'oxygen_then_escalate',
                        label: 'Support airway/O₂ + escalate now'),
                    _PhaseChoice(id: 'wait_labs', label: 'Wait for full labs first'),
                    _PhaseChoice(id: 'send_home', label: 'Reassure and discharge'),
                  ],
                ),
                FilledButton(
                  onPressed: _stepsOk
                      ? () => setState(() => _onViva = true)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Airway first, then escalate.'),
                            ),
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('CLINICAL VIVA',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                _VivaBlock(
                  accent: accent,
                  prompt: 'Why escalate the cyanotic patient before the sprain?',
                  options: const <String>[
                    'Sprains never matter',
                    'Airway/breathing threats kill minutes — triage is mortality first',
                    'Cyanosis is cosmetic',
                    'Charge more for airway cases',
                  ],
                  correctIndex: 1,
                  selected: _viva,
                  onSelect: (int i) => setState(() => _viva = i),
                ),
                FilledButton(
                  onPressed: _viva == null
                      ? null
                      : () => _finishShowcase(
                            context: context,
                            clock: _clock,
                            stepsOk: _stepsOk,
                            vivaOk: _viva == 1,
                            passNote: 'Triage order + ABC action locked.',
                            failNote: 'Life threats before stable complaints.',
                            vivaPass: 'Viva passed — mortality-first reasoning.',
                            vivaFail: 'Defend WHY airway outranks the sprain.',
                            titlePass: 'TRIAGE PRACTICAL PASSED',
                            titleFail: 'TRIAGE LAB COMPLETE',
                            accentLabel: 'ED Nurse',
                            badgeId: 'triage_board',
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('SUBMIT BOARD SCORE',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
    );
  }
}

// ── Medicine ────────────────────────────────────────────────────────────────

class MedicineDifferentialShowcaseLab extends StatefulWidget {
  const MedicineDifferentialShowcaseLab({super.key});

  @override
  State<MedicineDifferentialShowcaseLab> createState() =>
      _MedicineDifferentialShowcaseLabState();
}

class _MedicineDifferentialShowcaseLabState
    extends State<MedicineDifferentialShowcaseLab> {
  static const Color accent = Color(0xFFFB7185);
  final Stopwatch _clock = Stopwatch()..start();
  String? _dx;
  String? _test;
  bool _onViva = false;
  int? _viva;

  bool get _stepsOk => _dx == 'acs' && _test == 'ecg_troponin';

  @override
  Widget build(BuildContext context) {
    return _ShowcaseScaffold(
      title: 'Medicine · Chest Pain Practical',
      workplace: WorkplaceKind.hospitalWard,
      accent: accent,
      bannerTitle: 'WARD · 58YO CHEST PRESSURE',
      bannerBody:
          'Name life threats → order urgent tests → defend the differential WHY.',
      child: !_onViva
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('1 · Top life threat',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _dx,
                  onSelect: (String id) => setState(() => _dx = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(id: 'acs', label: 'Acute coronary syndrome'),
                    _PhaseChoice(id: 'gerd', label: 'Assume GERD and discharge'),
                    _PhaseChoice(id: 'anxiety', label: 'Anxiety only'),
                  ],
                ),
                const Text('2 · First tests',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                _ChoiceList(
                  accent: accent,
                  selectedId: _test,
                  onSelect: (String id) => setState(() => _test = id),
                  choices: const <_PhaseChoice>[
                    _PhaseChoice(id: 'ecg_troponin', label: 'ECG + troponin now'),
                    _PhaseChoice(id: 'mri', label: 'Elective MRI next week'),
                    _PhaseChoice(id: 'none', label: 'No tests — observe only'),
                  ],
                ),
                FilledButton(
                  onPressed: _stepsOk
                      ? () => setState(() => _onViva = true)
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ACS first + ECG/troponin.'),
                            ),
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('DIFFERENTIAL VIVA',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                _VivaBlock(
                  accent: accent,
                  prompt: 'Why rule out ACS before assuming GERD?',
                  options: const <String>[
                    'GERD is never real',
                    'Missed ACS has catastrophic downside — can’t-miss first',
                    'ECG is entertainment',
                    'Insurance prefers ACS',
                  ],
                  correctIndex: 1,
                  selected: _viva,
                  onSelect: (int i) => setState(() => _viva = i),
                ),
                FilledButton(
                  onPressed: _viva == null
                      ? null
                      : () => _finishShowcase(
                            context: context,
                            clock: _clock,
                            stepsOk: _stepsOk,
                            vivaOk: _viva == 1,
                            passNote: 'Can’t-miss differential + urgent tests locked.',
                            failNote: 'Chest pressure → ACS until proven otherwise.',
                            vivaPass: 'Viva passed — risk-first reasoning.',
                            vivaFail: 'Defend why can’t-miss diseases lead.',
                            titlePass: 'DIFFERENTIAL PRACTICAL PASSED',
                            titleFail: 'DIFFERENTIAL LAB COMPLETE',
                            accentLabel: 'Clinical Clerk',
                            badgeId: 'diff_board',
                          ),
                  style: FilledButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.black),
                  child: const Text('SUBMIT BOARD SCORE',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
    );
  }
}

// ── Business family (compact variants) ──────────────────────────────────────

class BusinessWarRoomShowcaseLab extends StatefulWidget {
  const BusinessWarRoomShowcaseLab({super.key});

  @override
  State<BusinessWarRoomShowcaseLab> createState() =>
      _BusinessWarRoomShowcaseLabState();
}

class _BusinessWarRoomShowcaseLabState extends State<BusinessWarRoomShowcaseLab> {
  static const Color accent = Color(0xFFFBBF24);
  final Stopwatch _clock = Stopwatch()..start();
  String? _channel;
  String? _budget;
  bool _onViva = false;
  int? _viva;

  bool get _stepsOk => _channel == 'retain' && _budget == 'test_then_scale';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Business · War-Room Practical',
      workplace: WorkplaceKind.warRoom,
      accent: accent,
      bannerTitle: 'WAR ROOM · SALES DROP 18%',
      bannerBody: 'Diagnose channel → allocate budget → defend ROI in viva.',
      step1Label: '1 · Primary move',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'retain', label: 'Fix retention + onboarding leak'),
        _PhaseChoice(id: 'blast', label: 'Blind ad spend 3×'),
        _PhaseChoice(id: 'fire', label: 'Fire the whole team today'),
      ],
      step1Id: _channel,
      onStep1: (String id) => setState(() => _channel = id),
      step2Label: '2 · Budget rule',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'test_then_scale', label: 'Small tests → scale winners'),
        _PhaseChoice(id: 'all_in', label: 'All-in on one untested channel'),
        _PhaseChoice(id: 'zero', label: 'Freeze all spend forever'),
      ],
      step2Id: _budget,
      onStep2: (String id) => setState(() => _budget = id),
      stepsOk: _stepsOk,
      gateMsg: 'Retention leak + test-then-scale before viva.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why test-then-scale beats blind 3× ad spend?',
      vivaOptions: const <String>[
        'Ads never work',
        'Unknown CAC/LTV — experiments buy information before capital risk',
        'Budgets should always be random',
        'Retention never matters',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'War-room diagnosis + capital discipline locked.',
        failNote: 'Fix retention leak; don’t burn cash blind.',
        vivaPass: 'ROI viva passed — information before scale.',
        vivaFail: 'Defend experimental capital allocation.',
        titlePass: 'WAR-ROOM PRACTICAL PASSED',
        titleFail: 'WAR-ROOM LAB COMPLETE',
        accentLabel: 'Operator',
        badgeId: 'warroom_board',
      ),
    );
  }
}

class FinanceDeskShowcaseLab extends StatefulWidget {
  const FinanceDeskShowcaseLab({super.key});

  @override
  State<FinanceDeskShowcaseLab> createState() => _FinanceDeskShowcaseLabState();
}

class _FinanceDeskShowcaseLabState extends State<FinanceDeskShowcaseLab> {
  static const Color accent = Color(0xFF34D399);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'duration' && _b == 'rebalance_ips';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Finance · Desk Practical',
      workplace: WorkplaceKind.financeDesk,
      accent: accent,
      bannerTitle: 'DESK · RATE SHOCK',
      bannerBody: 'Identify duration risk → rebalance inside IPS → defend fiduciary WHY.',
      step1Label: '1 · Shock diagnosis',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'duration', label: 'Long-duration bonds hurt when rates rise'),
        _PhaseChoice(id: 'ignore', label: 'Rates irrelevant to bonds'),
        _PhaseChoice(id: 'equity_only', label: 'Only equities matter ever'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Action',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'rebalance_ips', label: 'Rebalance within IPS constraints'),
        _PhaseChoice(id: 'yolo', label: '100% speculative options'),
        _PhaseChoice(id: 'hide', label: 'Hide the loss from the client'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Duration risk + IPS rebalance.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why document the rebalance process?',
      vivaOptions: const <String>[
        'Paperwork hobbies',
        'Fiduciary duty — process evidence under review',
        'Clients hate notes',
        'IPS is optional decoration',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Duration diagnosis + IPS action locked.',
        failNote: 'Rates ↑ hurt long duration — rebalance inside IPS.',
        vivaPass: 'Fiduciary viva passed.',
        vivaFail: 'Process evidence is the job.',
        titlePass: 'FINANCE PRACTICAL PASSED',
        titleFail: 'FINANCE LAB COMPLETE',
        accentLabel: 'Analyst',
        badgeId: 'finance_board',
      ),
    );
  }
}

class AccountingAuditShowcaseLab extends StatefulWidget {
  const AccountingAuditShowcaseLab({super.key});

  @override
  State<AccountingAuditShowcaseLab> createState() =>
      _AccountingAuditShowcaseLabState();
}

class _AccountingAuditShowcaseLabState extends State<AccountingAuditShowcaseLab> {
  static const Color accent = Color(0xFFA78BFA);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'cutoff' && _b == 'correct_control';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Accounting · Audit Practical',
      workplace: WorkplaceKind.auditRoom,
      accent: accent,
      bannerTitle: 'AUDIT · REVENUE SPIKE',
      bannerBody: 'Classify misstatement → correct → remediate control → defend WHY.',
      step1Label: '1 · Likely issue',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'cutoff', label: 'Cutoff / premature revenue recognition'),
        _PhaseChoice(id: 'ignore', label: 'Ignore — spikes are always good'),
        _PhaseChoice(id: 'delete', label: 'Delete the ledger'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Remediation',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'correct_control', label: 'Correct entry + strengthen cutoff control'),
        _PhaseChoice(id: 'hide', label: 'Hide adjusting entry'),
        _PhaseChoice(id: 'bonus', label: 'Pay bonus on inflated revenue'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Cutoff issue + control fix.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why fix the control, not only the entry?',
      vivaOptions: const <String>[
        'Controls are optional',
        'Otherwise the same misstatement recurs next period',
        'Auditors hate controls',
        'Entries never err twice',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Misstatement class + control remediation locked.',
        failNote: 'Premature revenue needs correction AND control.',
        vivaPass: 'Control viva passed.',
        vivaFail: 'Entry-only fixes recur.',
        titlePass: 'AUDIT PRACTICAL PASSED',
        titleFail: 'AUDIT LAB COMPLETE',
        accentLabel: 'Auditor',
        badgeId: 'audit_board',
      ),
    );
  }
}

class MarketingCampaignShowcaseLab extends StatefulWidget {
  const MarketingCampaignShowcaseLab({super.key});

  @override
  State<MarketingCampaignShowcaseLab> createState() =>
      _MarketingCampaignShowcaseLabState();
}

class _MarketingCampaignShowcaseLabState
    extends State<MarketingCampaignShowcaseLab> {
  static const Color accent = Color(0xFFF472B6);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'segment' && _b == 'measure';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Marketing · Campaign Practical',
      workplace: WorkplaceKind.marketingStudio,
      accent: accent,
      bannerTitle: 'CAMPAIGN · CAC SPIKE',
      bannerBody: 'Segment → message → measure. Defend creative with metrics.',
      step1Label: '1 · First move',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'segment', label: 'Tighten segment + creative fit'),
        _PhaseChoice(id: 'spam', label: 'Spam every channel identically'),
        _PhaseChoice(id: 'quit', label: 'Quit measuring forever'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Success definition',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'measure', label: 'Predefine KPI + holdout'),
        _PhaseChoice(id: 'vibes', label: 'Judge by vibes only'),
        _PhaseChoice(id: 'vanity', label: 'Optimize only vanity likes'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Segment fit + measurable KPI.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why define KPI before launch?',
      vivaOptions: const <String>[
        'Meetings need agendas',
        'Without a success definition you can’t learn — only spend',
        'KPIs kill creativity always',
        'Holdouts are unethical',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Segment + measurement design locked.',
        failNote: 'Creative without KPI is spend, not learning.',
        vivaPass: 'Measurement viva passed.',
        vivaFail: 'Define success before spend.',
        titlePass: 'CAMPAIGN PRACTICAL PASSED',
        titleFail: 'CAMPAIGN LAB COMPLETE',
        accentLabel: 'Growth',
        badgeId: 'campaign_board',
      ),
    );
  }
}

class EconomicsPolicyShowcaseLab extends StatefulWidget {
  const EconomicsPolicyShowcaseLab({super.key});

  @override
  State<EconomicsPolicyShowcaseLab> createState() =>
      _EconomicsPolicyShowcaseLabState();
}

class _EconomicsPolicyShowcaseLabState extends State<EconomicsPolicyShowcaseLab> {
  static const Color accent = Color(0xFF38BDF8);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'tradeoff' && _b == 'evidence';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Economics · Policy Practical',
      workplace: WorkplaceKind.policyOffice,
      accent: accent,
      bannerTitle: 'POLICY DESK · INFLATION',
      bannerBody: 'Map tradeoffs → pick instrument → defend with evidence.',
      step1Label: '1 · Framing',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'tradeoff', label: 'State inflation vs growth/employment tradeoff'),
        _PhaseChoice(id: 'magic', label: 'Claim zero tradeoffs exist'),
        _PhaseChoice(id: 'ignore', label: 'Ignore incentives'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Recommendation basis',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'evidence', label: 'Cite mechanism + data, note uncertainty'),
        _PhaseChoice(id: 'slogan', label: 'Slogan louder than evidence'),
        _PhaseChoice(id: 'secret', label: 'Hide assumptions'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Tradeoff framing + evidence.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why surface assumptions in a policy memo?',
      vivaOptions: const <String>[
        'Padding page count',
        'Reviewers must stress-test mechanism under alternate assumptions',
        'Assumptions are shameful',
        'Data never changes',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Tradeoff + evidence discipline locked.',
        failNote: 'Policy without tradeoffs is slogan.',
        vivaPass: 'Memo viva passed.',
        vivaFail: 'Assumptions must be reviewable.',
        titlePass: 'POLICY PRACTICAL PASSED',
        titleFail: 'POLICY LAB COMPLETE',
        accentLabel: 'Economist',
        badgeId: 'policy_board',
      ),
    );
  }
}

class PharmacyRxShowcaseLab extends StatefulWidget {
  const PharmacyRxShowcaseLab({super.key});

  @override
  State<PharmacyRxShowcaseLab> createState() => _PharmacyRxShowcaseLabState();
}

class _PharmacyRxShowcaseLabState extends State<PharmacyRxShowcaseLab> {
  static const Color accent = Color(0xFF4ADE80);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'interaction' && _b == 'call_prescriber';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Pharmacy · Rx Safety Practical',
      workplace: WorkplaceKind.pharmacyCounter,
      accent: accent,
      bannerTitle: 'DISPENSE · INTERACTION ALERT',
      bannerBody: 'Catch interaction → intervene → defend patient-safety WHY.',
      step1Label: '1 · Alert',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'interaction', label: 'Serious interaction — hold dispense'),
        _PhaseChoice(id: 'ignore', label: 'Override all alerts always'),
        _PhaseChoice(id: 'guess', label: 'Guess a different drug silently'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Action',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'call_prescriber', label: 'Contact prescriber with evidence'),
        _PhaseChoice(id: 'shame', label: 'Shame the patient'),
        _PhaseChoice(id: 'dispense', label: 'Dispense anyway for speed'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Hold + call prescriber.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why call instead of silent override?',
      vivaOptions: const <String>[
        'Phone hobbies',
        'Therapy change needs shared clinical accountability',
        'Alerts are always wrong',
        'Speed > safety',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Safety hold + prescriber loop locked.',
        failNote: 'Serious alerts are holds, not speed bumps.',
        vivaPass: 'Safety viva passed.',
        vivaFail: 'Accountability beats silent override.',
        titlePass: 'RX PRACTICAL PASSED',
        titleFail: 'RX LAB COMPLETE',
        accentLabel: 'Pharmacist',
        badgeId: 'rx_board',
      ),
    );
  }
}

class MlsCriticalShowcaseLab extends StatefulWidget {
  const MlsCriticalShowcaseLab({super.key});

  @override
  State<MlsCriticalShowcaseLab> createState() => _MlsCriticalShowcaseLabState();
}

class _MlsCriticalShowcaseLabState extends State<MlsCriticalShowcaseLab> {
  static const Color accent = Color(0xFF22D3EE);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'hemolysis' && _b == 'call_critical';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'MLS · Critical Value Practical',
      workplace: WorkplaceKind.mlsBench,
      accent: accent,
      bannerTitle: 'BENCH · CRITICAL POTASSIUM',
      bannerBody: 'Validate sample → call critical → defend hemolysis reasoning.',
      step1Label: '1 · Sample check',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'hemolysis', label: 'Check hemolysis / integrity first'),
        _PhaseChoice(id: 'report', label: 'Report without validation'),
        _PhaseChoice(id: 'delete', label: 'Delete the result'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Communication',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'call_critical', label: 'Call critical + document read-back'),
        _PhaseChoice(id: 'email', label: 'Vague email tomorrow'),
        _PhaseChoice(id: 'wait', label: 'Wait for someone to notice'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Integrity check + critical call.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why hemolysis matters for potassium?',
      vivaOptions: const <String>[
        'It looks pink',
        'RBC lysis falsely elevates K+ — may be artifactual',
        'Hemolysis is decorative',
        'Criticals ignore preanalytics',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Preanalytic check + critical call locked.',
        failNote: 'Validate before you frighten the ward.',
        vivaPass: 'Hemolysis viva passed.',
        vivaFail: 'Artifactual K+ is a classic trap.',
        titlePass: 'CRITICAL PRACTICAL PASSED',
        titleFail: 'CRITICAL LAB COMPLETE',
        accentLabel: 'MLS',
        badgeId: 'mls_board',
      ),
    );
  }
}

class PsychologyMethodsShowcaseLab extends StatefulWidget {
  const PsychologyMethodsShowcaseLab({super.key});

  @override
  State<PsychologyMethodsShowcaseLab> createState() =>
      _PsychologyMethodsShowcaseLabState();
}

class _PsychologyMethodsShowcaseLabState
    extends State<PsychologyMethodsShowcaseLab> {
  static const Color accent = Color(0xFFC084FC);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'confound' && _b == 'control';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Psychology · Methods Practical',
      workplace: WorkplaceKind.researchLab,
      accent: accent,
      bannerTitle: 'METHODS · CLAIM VS DESIGN',
      bannerBody: 'Spot confound → fix control → defend causal language limits.',
      step1Label: '1 · Flaw',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'confound', label: 'Confound / no control group'),
        _PhaseChoice(id: 'fine', label: 'Design is automatically fine'),
        _PhaseChoice(id: 'n', label: 'Only worry about sample size slogans'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Fix',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'control', label: 'Add control + random assignment where ethical'),
        _PhaseChoice(id: 'hype', label: 'Hype causation from correlation'),
        _PhaseChoice(id: 'hide', label: 'Hide limitations'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Name confound + add control.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why not claim causation from a confound-heavy design?',
      vivaOptions: const <String>[
        'Editors hate verbs',
        'Alternate explanations remain — causal language overclaims',
        'Correlation is causation',
        'Controls are optional aesthetics',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Methods critique + redesign locked.',
        failNote: 'Confounds block causal claims.',
        vivaPass: 'Methods viva passed.',
        vivaFail: 'Language must match design strength.',
        titlePass: 'METHODS PRACTICAL PASSED',
        titleFail: 'METHODS LAB COMPLETE',
        accentLabel: 'Researcher',
        badgeId: 'methods_board',
      ),
    );
  }
}

class MathModelShowcaseLab extends StatefulWidget {
  const MathModelShowcaseLab({super.key});

  @override
  State<MathModelShowcaseLab> createState() => _MathModelShowcaseLabState();
}

class _MathModelShowcaseLabState extends State<MathModelShowcaseLab> {
  static const Color accent = Color(0xFF818CF8);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'assumptions' && _b == 'check_units';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Mathematics · Model Practical',
      workplace: WorkplaceKind.mathStudio,
      accent: accent,
      bannerTitle: 'MODELING · REAL CLAIM',
      bannerBody: 'State assumptions → check units/limits → defend the model WHY.',
      step1Label: '1 · First move',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'assumptions', label: 'Write assumptions + domain explicitly'),
        _PhaseChoice(id: 'plug', label: 'Plug numbers with no model story'),
        _PhaseChoice(id: 'hide', label: 'Hide where the model breaks'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Sanity',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'check_units', label: 'Check units + limiting cases'),
        _PhaseChoice(id: 'trust', label: 'Trust calculator output blindly'),
        _PhaseChoice(id: 'round', label: 'Round until it looks nice'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Assumptions + unit/limit checks.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why test limiting cases?',
      vivaOptions: const <String>[
        'Busywork',
        'Broken models often fail extremes even if mid-range looks fine',
        'Limits never matter',
        'Units are fashion',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Assumptions + sanity checks locked.',
        failNote: 'Models need domain + limits, not blind plug-in.',
        vivaPass: 'Model viva passed.',
        vivaFail: 'Extremes expose broken structure.',
        titlePass: 'MODEL PRACTICAL PASSED',
        titleFail: 'MODEL LAB COMPLETE',
        accentLabel: 'Mathematician',
        badgeId: 'model_board',
      ),
    );
  }
}

class CyberSocShowcaseLab extends StatefulWidget {
  const CyberSocShowcaseLab({super.key});

  @override
  State<CyberSocShowcaseLab> createState() => _CyberSocShowcaseLabState();
}

class _CyberSocShowcaseLabState extends State<CyberSocShowcaseLab> {
  static const Color accent = Color(0xFFFB923C);
  final Stopwatch _clock = Stopwatch()..start();
  String? _a;
  String? _b;
  bool _onViva = false;
  int? _viva;
  bool get _stepsOk => _a == 'contain' && _b == 'evidence';

  @override
  Widget build(BuildContext context) {
    return _GenericTwoStepShowcase(
      title: 'Cyber · SOC Practical',
      workplace: WorkplaceKind.soc,
      accent: accent,
      bannerTitle: 'SOC · SUSPECTED BREACH',
      bannerBody: 'Contain → preserve evidence → defend IR WHY.',
      step1Label: '1 · Immediate',
      step1: const <_PhaseChoice>[
        _PhaseChoice(id: 'contain', label: 'Contain affected hosts / revoke tokens'),
        _PhaseChoice(id: 'reboot', label: 'Reboot everything randomly'),
        _PhaseChoice(id: 'tweet', label: 'Tweet the breach first'),
      ],
      step1Id: _a,
      onStep1: (String id) => setState(() => _a = id),
      step2Label: '2 · Forensics',
      step2: const <_PhaseChoice>[
        _PhaseChoice(id: 'evidence', label: 'Preserve logs/images before wipe'),
        _PhaseChoice(id: 'wipe', label: 'Wipe disks immediately'),
        _PhaseChoice(id: 'ignore', label: 'Ignore chain of custody'),
      ],
      step2Id: _b,
      onStep2: (String id) => setState(() => _b = id),
      stepsOk: _stepsOk,
      gateMsg: 'Contain + preserve evidence.',
      onViva: _onViva,
      openViva: () => setState(() => _onViva = true),
      vivaPrompt: 'Why preserve evidence before wipe?',
      vivaOptions: const <String>[
        'Hoarding habit',
        'Without artifacts you can’t attribute, learn, or prove response',
        'Wipes are always first',
        'Logs never matter in court/IR',
      ],
      vivaCorrect: 1,
      viva: _viva,
      onVivaPick: (int i) => setState(() => _viva = i),
      onSubmit: () => _finishShowcase(
        context: context,
        clock: _clock,
        stepsOk: _stepsOk,
        vivaOk: _viva == 1,
        passNote: 'Containment + evidence discipline locked.',
        failNote: 'Contain first; don’t destroy the crime scene.',
        vivaPass: 'IR viva passed.',
        vivaFail: 'Wiping without capture burns learning.',
        titlePass: 'SOC PRACTICAL PASSED',
        titleFail: 'SOC LAB COMPLETE',
        accentLabel: 'Analyst',
        badgeId: 'soc_board',
      ),
    );
  }
}

// ── Generic two-step + viva builder ─────────────────────────────────────────

class _GenericTwoStepShowcase extends StatelessWidget {
  const _GenericTwoStepShowcase({
    required this.title,
    required this.accent,
    required this.workplace,
    required this.bannerTitle,
    required this.bannerBody,
    required this.step1Label,
    required this.step1,
    required this.step1Id,
    required this.onStep1,
    required this.step2Label,
    required this.step2,
    required this.step2Id,
    required this.onStep2,
    required this.stepsOk,
    required this.gateMsg,
    required this.onViva,
    required this.openViva,
    required this.vivaPrompt,
    required this.vivaOptions,
    required this.vivaCorrect,
    required this.viva,
    required this.onVivaPick,
    required this.onSubmit,
  });

  final String title;
  final Color accent;
  final WorkplaceKind workplace;
  final String bannerTitle;
  final String bannerBody;
  final String step1Label;
  final List<_PhaseChoice> step1;
  final String? step1Id;
  final ValueChanged<String> onStep1;
  final String step2Label;
  final List<_PhaseChoice> step2;
  final String? step2Id;
  final ValueChanged<String> onStep2;
  final bool stepsOk;
  final String gateMsg;
  final bool onViva;
  final VoidCallback openViva;
  final String vivaPrompt;
  final List<String> vivaOptions;
  final int vivaCorrect;
  final int? viva;
  final ValueChanged<int> onVivaPick;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _ShowcaseScaffold(
      title: title,
      accent: accent,
      workplace: workplace,
      bannerTitle: bannerTitle,
      bannerBody: bannerBody,
      child: !onViva
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(step1Label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _ChoiceList(
                  accent: accent,
                  choices: step1,
                  selectedId: step1Id,
                  onSelect: onStep1,
                ),
                const SizedBox(height: 8),
                Text(step2Label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _ChoiceList(
                  accent: accent,
                  choices: step2,
                  selectedId: step2Id,
                  onSelect: onStep2,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: stepsOk
                      ? openViva
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(gateMsg)),
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('BOARD VIVA',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                _VivaBlock(
                  accent: accent,
                  prompt: vivaPrompt,
                  options: vivaOptions,
                  correctIndex: vivaCorrect,
                  selected: viva,
                  onSelect: onVivaPick,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: viva == null ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('SUBMIT BOARD SCORE',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
    );
  }
}
