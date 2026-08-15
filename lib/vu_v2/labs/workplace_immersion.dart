import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Real-life workplace atmosphere for labs — you walk into the room, not a quiz.
enum WorkplaceKind {
  courtroom,
  emergencyDept,
  hospitalWard,
  warRoom,
  financeDesk,
  auditRoom,
  marketingStudio,
  policyOffice,
  pharmacyCounter,
  mlsBench,
  researchLab,
  mathStudio,
  soc,
  chemBench,
  physicsBay,
  engSite,
  incidentBridge,
  anatomyTheater,
}

class WorkplaceSet {
  const WorkplaceSet({
    required this.kind,
    required this.placeName,
    required this.youAre,
    required this.liveLine,
    required this.accent,
    required this.bgTop,
    required this.bgBottom,
    required this.surface,
    required this.ambientChips,
    required this.enterVerb,
    required this.enterBody,
  });

  final WorkplaceKind kind;
  final String placeName;
  final String youAre;
  final String liveLine;
  final Color accent;
  final Color bgTop;
  final Color bgBottom;
  final Color surface;
  final List<String> ambientChips;
  final String enterVerb;
  final String enterBody;

  static WorkplaceSet of(WorkplaceKind kind) {
    switch (kind) {
      case WorkplaceKind.courtroom:
        return const WorkplaceSet(
          kind: WorkplaceKind.courtroom,
          placeName: 'County Courthouse · Courtroom 3B',
          youAre: 'Junior Associate',
          liveLine: 'IN SESSION · counsel standing',
          accent: Color(0xFFD4A574),
          bgTop: Color(0xFF1A120C),
          bgBottom: Color(0xFF0A0705),
          surface: Color(0xFF221810),
          ambientChips: <String>['GAVEL READY', 'EXHIBIT TABLE', 'PARTNER WATCHING'],
          enterVerb: 'ENTER THE COURTROOM',
          enterBody:
              'Oak benches. Quiet gallery. Your partner expects issue-spotting, '
              'not flashcard answers. Act like counsel.',
        );
      case WorkplaceKind.emergencyDept:
        return const WorkplaceSet(
          kind: WorkplaceKind.emergencyDept,
          placeName: 'St. Mercy ED · Bay 4',
          youAre: 'ED Nurse',
          liveLine: 'TRIAGE LIVE · 3 arrivals',
          accent: Color(0xFFF472B6),
          bgTop: Color(0xFF1A0A12),
          bgBottom: Color(0xFF08040A),
          surface: Color(0xFF221018),
          ambientChips: <String>['MONITORS ON', 'BAY 4', 'CHARGE RN'],
          enterVerb: 'ENTER THE ED',
          enterBody:
              'Fluorescent lights. Monitor beeps. Stretchers moving. '
              'You prioritize life threats — lives depend on your order.',
        );
      case WorkplaceKind.hospitalWard:
        return const WorkplaceSet(
          kind: WorkplaceKind.hospitalWard,
          placeName: 'St. Mercy · Acute Ward',
          youAre: 'Clinical Clerk',
          liveLine: 'ROUNDS · chest pain workup',
          accent: Color(0xFFFB7185),
          bgTop: Color(0xFF140A0E),
          bgBottom: Color(0xFF070406),
          surface: Color(0xFF1E1216),
          ambientChips: <String>['ECG READY', 'TROP PENDING', 'ATTENDING NEAR'],
          enterVerb: 'ENTER THE WARD',
          enterBody:
              'Chart in hand. Attending arrives in minutes. '
              'Name can’t-miss diagnoses before you reassure anyone.',
        );
      case WorkplaceKind.warRoom:
        return const WorkplaceSet(
          kind: WorkplaceKind.warRoom,
          placeName: 'HQ Conference · War Room',
          youAre: 'Operator',
          liveLine: 'BOARD CALL · sales −18%',
          accent: Color(0xFFFBBF24),
          bgTop: Color(0xFF14100A),
          bgBottom: Color(0xFF080604),
          surface: Color(0xFF1E1810),
          ambientChips: <String>['DASHBOARDS LIVE', 'CEO ON CALL', 'BUDGET LOCK'],
          enterVerb: 'ENTER THE WAR ROOM',
          enterBody:
              'Glass walls. Live dashboards. Silence when you speak. '
              'Pick one lever and defend it like capital is on the line.',
        );
      case WorkplaceKind.financeDesk:
        return const WorkplaceSet(
          kind: WorkplaceKind.financeDesk,
          placeName: 'Trading Floor · Desk 12',
          youAre: 'Analyst',
          liveLine: 'RATE SHOCK · clients waiting',
          accent: Color(0xFF34D399),
          bgTop: Color(0xFF0A1410),
          bgBottom: Color(0xFF040806),
          surface: Color(0xFF102018),
          ambientChips: <String>['TICKER LIVE', 'IPS OPEN', 'COMPLIANCE'],
          enterVerb: 'TAKE THE DESK',
          enterBody:
              'Screens flash red/green. The phone is ringing. '
              'Rebalance inside the IPS — document like a fiduciary.',
        );
      case WorkplaceKind.auditRoom:
        return const WorkplaceSet(
          kind: WorkplaceKind.auditRoom,
          placeName: 'Audit Suite · Room C',
          youAre: 'Staff Auditor',
          liveLine: 'SAMPLE REVIEW · revenue spike',
          accent: Color(0xFFA78BFA),
          bgTop: Color(0xFF120E1A),
          bgBottom: Color(0xFF07050C),
          surface: Color(0xFF1A1624),
          ambientChips: <String>['WORKPAPERS', 'LEDGER OPEN', 'PARTNER REVIEW'],
          enterVerb: 'ENTER THE AUDIT ROOM',
          enterBody:
              'Quiet focus. Binders stacked. Partner wants the misstatement class '
              'and the control fix — not a slogan.',
        );
      case WorkplaceKind.marketingStudio:
        return const WorkplaceSet(
          kind: WorkplaceKind.marketingStudio,
          placeName: 'Growth Studio · Campaign Pit',
          youAre: 'Growth Lead',
          liveLine: 'CAC SPIKE · creative review',
          accent: Color(0xFFF472B6),
          bgTop: Color(0xFF160A12),
          bgBottom: Color(0xFF080408),
          surface: Color(0xFF201018),
          ambientChips: <String>['AD PREVIEW', 'KPI BOARD', 'HOLDOUT'],
          enterVerb: 'ENTER THE STUDIO',
          enterBody:
              'Mood boards on the wall. Spend clock ticking. '
              'Tighten segment and define success before you burn budget.',
        );
      case WorkplaceKind.policyOffice:
        return const WorkplaceSet(
          kind: WorkplaceKind.policyOffice,
          placeName: 'Policy Desk · Briefing Room',
          youAre: 'Economist',
          liveLine: 'MEMO DUE · inflation brief',
          accent: Color(0xFF38BDF8),
          bgTop: Color(0xFF0A1218),
          bgBottom: Color(0xFF04080C),
          surface: Color(0xFF101820),
          ambientChips: <String>['WHITEBOARD', 'DATA PACK', 'BRIEFING'],
          enterVerb: 'ENTER THE BRIEFING ROOM',
          enterBody:
              'Charts on the wall. Principals arrive soon. '
              'State tradeoffs and assumptions — slogans die here.',
        );
      case WorkplaceKind.pharmacyCounter:
        return const WorkplaceSet(
          kind: WorkplaceKind.pharmacyCounter,
          placeName: 'Community Pharmacy · Dispense Counter',
          youAre: 'Pharmacist',
          liveLine: 'ALERT · interaction hold',
          accent: Color(0xFF4ADE80),
          bgTop: Color(0xFF0A140E),
          bgBottom: Color(0xFF040806),
          surface: Color(0xFF102018),
          ambientChips: <String>['RX QUEUE', 'ALERT ON', 'COUNSEL BAY'],
          enterVerb: 'STEP TO THE COUNTER',
          enterBody:
              'Script printer humming. Patient waiting. '
              'Hold the dispense, call the prescriber, protect the patient.',
        );
      case WorkplaceKind.mlsBench:
        return const WorkplaceSet(
          kind: WorkplaceKind.mlsBench,
          placeName: 'Core Lab · Critical Bench',
          youAre: 'MLS',
          liveLine: 'CRITICAL K+ · validate now',
          accent: Color(0xFF22D3EE),
          bgTop: Color(0xFF0A1216),
          bgBottom: Color(0xFF04080A),
          surface: Color(0xFF101820),
          ambientChips: <String>['ANALYZER', 'SAMPLE CHECK', 'CALL LOG'],
          enterVerb: 'ENTER THE CORE LAB',
          enterBody:
              'Cold benches. Analyzer ping. A critical value is flashing. '
              'Validate hemolysis before you frighten the ward.',
        );
      case WorkplaceKind.researchLab:
        return const WorkplaceSet(
          kind: WorkplaceKind.researchLab,
          placeName: 'Methods Lab · Design Critique',
          youAre: 'Researcher',
          liveLine: 'PEER REVIEW · claim vs design',
          accent: Color(0xFFC084FC),
          bgTop: Color(0xFF120E18),
          bgBottom: Color(0xFF07050C),
          surface: Color(0xFF1A1622),
          ambientChips: <String>['PROTOCOL', 'CONFOUND MAP', 'IRB'],
          enterVerb: 'ENTER THE METHODS LAB',
          enterBody:
              'Whiteboard covered in arrows. Someone claimed causation too fast. '
              'Find the confound and fix the design.',
        );
      case WorkplaceKind.mathStudio:
        return const WorkplaceSet(
          kind: WorkplaceKind.mathStudio,
          placeName: 'Modeling Studio · Board 2',
          youAre: 'Mathematician',
          liveLine: 'DEFEND THE MODEL',
          accent: Color(0xFF818CF8),
          bgTop: Color(0xFF0E1018),
          bgBottom: Color(0xFF06070C),
          surface: Color(0xFF161A24),
          ambientChips: <String>['ASSUMPTIONS', 'UNITS', 'LIMITS'],
          enterVerb: 'ENTER THE STUDIO',
          enterBody:
              'Chalk dust. A real claim on the board. '
              'Write assumptions, check units, defend the model aloud.',
        );
      case WorkplaceKind.soc:
        return const WorkplaceSet(
          kind: WorkplaceKind.soc,
          placeName: 'SOC · Incident Theater',
          youAre: 'SOC Analyst',
          liveLine: 'P1 BREACH SUSPECTED',
          accent: Color(0xFFFB923C),
          bgTop: Color(0xFF140C08),
          bgBottom: Color(0xFF080402),
          surface: Color(0xFF1E1410),
          ambientChips: <String>['SIEM LIVE', 'CONTAIN', 'EVIDENCE'],
          enterVerb: 'ENTER THE SOC',
          enterBody:
              'Red alerts. Dark glass. Team lead staring at you. '
              'Contain first — preserve evidence before anyone wipes.',
        );
      case WorkplaceKind.chemBench:
        return const WorkplaceSet(
          kind: WorkplaceKind.chemBench,
          placeName: 'Analytical Lab · Titration Bench',
          youAre: 'Analytical Chemist',
          liveLine: 'UNKNOWN ACID · board check',
          accent: Color(0xFF2DD4BF),
          bgTop: Color(0xFF0A1414),
          bgBottom: Color(0xFF040808),
          surface: Color(0xFF102020),
          ambientChips: <String>['BURETTE', 'INDICATOR', 'FUME HOOD'],
          enterVerb: 'ENTER THE CHEM LAB',
          enterBody:
              'Glassware clinks. Hood airflow. Notebook open. '
              'Run the titration like the board is watching.',
        );
      case WorkplaceKind.physicsBay:
        return const WorkplaceSet(
          kind: WorkplaceKind.physicsBay,
          placeName: 'Mechanics Bay · Track 1',
          youAre: 'Physics Lab Student',
          liveLine: 'ENERGY RUN · defend model',
          accent: Color(0xFF60A5FA),
          bgTop: Color(0xFF0A1018),
          bgBottom: Color(0xFF04060A),
          surface: Color(0xFF101820),
          ambientChips: <String>['TRACK LIVE', 'SENSORS', 'WHITEBOARD'],
          enterVerb: 'ENTER THE PHYSICS BAY',
          enterBody:
              'Cart on the rail. Sensors blinking. TA waiting. '
              'Model energy like a scientist, not a slogan.',
        );
      case WorkplaceKind.engSite:
        return const WorkplaceSet(
          kind: WorkplaceKind.engSite,
          placeName: 'Field Site · Bridge Span A',
          youAre: 'Junior Engineer',
          liveLine: 'LOAD TEST · safety review',
          accent: Color(0xFFFBBF24),
          bgTop: Color(0xFF12100A),
          bgBottom: Color(0xFF080604),
          surface: Color(0xFF1C1810),
          ambientChips: <String>['HARD HAT', 'LOAD CELL', 'DESIGN REVIEW'],
          enterVerb: 'ENTER THE SITE',
          enterBody:
              'Wind on the span. Hard hats. Load cells armed. '
              'Pass the test, then defend the safety factor.',
        );
      case WorkplaceKind.incidentBridge:
        return const WorkplaceSet(
          kind: WorkplaceKind.incidentBridge,
          placeName: 'NOC · Incident Bridge',
          youAre: 'On-call Engineer',
          liveLine: 'PAGER · payments failing',
          accent: Color(0xFF22D3EE),
          bgTop: Color(0xFF061018),
          bgBottom: Color(0xFF03080C),
          surface: Color(0xFF0B1622),
          ambientChips: <String>['PAGER', 'LOG STREAM', 'ENG REVIEW'],
          enterVerb: 'JOIN THE BRIDGE',
          enterBody:
              'Slack exploding. Graphs red. You own the outage. '
              'Read logs, ship a safe fix, defend the roll-forward.',
        );
      case WorkplaceKind.anatomyTheater:
        return const WorkplaceSet(
          kind: WorkplaceKind.anatomyTheater,
          placeName: 'Anatomy Theater · Clinical Practical',
          youAre: 'Medical Student',
          liveLine: 'CLINICAL VIVA · model ready',
          accent: Color(0xFF2DD4BF),
          bgTop: Color(0xFF0A1412),
          bgBottom: Color(0xFF040808),
          surface: Color(0xFF10201C),
          ambientChips: <String>['3D MODEL', 'CASE CHART', 'EXAMINER'],
          enterVerb: 'ENTER THE THEATER',
          enterBody:
              'Quiet room. 3D body lit. Examiner waiting. '
              'Reason clinically — view, structure, WHY.',
        );
    }
  }
}

/// Full-screen immersive workplace for board practicals.
class WorkplaceImmersionShell extends StatelessWidget {
  const WorkplaceImmersionShell({
    super.key,
    required this.set,
    required this.child,
    this.titleOverride,
    this.onLeave,
    this.scrollable = true,
  });

  final WorkplaceSet set;
  final Widget child;
  final String? titleOverride;
  final VoidCallback? onLeave;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: set.bgBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[set.bgTop, set.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _LocationBar(
                set: set,
                titleOverride: titleOverride,
                onLeave: onLeave ?? () => Navigator.of(context).maybePop(),
              ),
              _AmbientStrip(set: set),
              Expanded(
                child: scrollable
                    ? ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        children: <Widget>[
                          _RoomFrame(set: set, child: child),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _RoomFrame(
                          set: set,
                          expand: true,
                          child: child,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationBar extends StatelessWidget {
  const _LocationBar({
    required this.set,
    required this.onLeave,
    this.titleOverride,
  });

  final WorkplaceSet set;
  final VoidCallback onLeave;
  final String? titleOverride;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
            tooltip: 'Leave workplace',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOU ARE HERE',
                  style: TextStyle(
                    color: set.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  titleOverride ?? set.placeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: set.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: set.accent.withValues(alpha: 0.45)),
            ),
            child: Text(
              set.youAre,
              style: TextStyle(
                color: set.accent,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientStrip extends StatelessWidget {
  const _AmbientStrip({required this.set});

  final WorkplaceSet set;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: set.accent,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: set.accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  set.liveLine,
                  style: TextStyle(
                    color: set.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: set.ambientChips
                .map(
                  (String c) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RoomFrame extends StatelessWidget {
  const _RoomFrame({
    required this.set,
    required this.child,
    this.expand = false,
  });

  final WorkplaceSet set;
  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: expand ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: set.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: set.accent.withValues(alpha: 0.28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: set.accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Walk-in gate before the practical — sets the scene.
class WorkplaceEntranceGate extends StatelessWidget {
  const WorkplaceEntranceGate({
    super.key,
    required this.set,
    required this.onEnter,
  });

  final WorkplaceSet set;
  final VoidCallback onEnter;

  static Future<void> openThen(
    BuildContext context, {
    required WorkplaceKind kind,
    required Widget Function() builder,
  }) async {
    final WorkplaceSet set = WorkplaceSet.of(kind);
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (BuildContext gateCtx, __, ___) => WorkplaceEntranceGate(
          set: set,
          onEnter: () {
            Navigator.of(gateCtx).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => builder()),
            );
          },
        ),
        transitionsBuilder: (_, Animation<double> a, __, Widget child) {
          return FadeTransition(opacity: a, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[set.bgTop, set.bgBottom, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text('Back', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const Spacer(),
                Text(
                  'WALKING IN',
                  style: TextStyle(
                    color: set.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  set.placeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Role: ${set.youAre}',
                  style: TextStyle(
                    color: set.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  set.enterBody,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.45,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: set.ambientChips
                      .map(
                        (String c) => Chip(
                          label: Text(c),
                          backgroundColor: set.accent.withValues(alpha: 0.12),
                          side: BorderSide(color: set.accent.withValues(alpha: 0.35)),
                          labelStyle: TextStyle(
                            color: set.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    unawaited(HapticFeedback.mediumImpact());
                    onEnter();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: set.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    set.enterVerb,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
