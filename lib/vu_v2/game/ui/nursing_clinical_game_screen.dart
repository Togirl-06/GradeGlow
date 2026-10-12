import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../labs/centers/vu_v2_lab_game.dart';
import '../../labs/centers/vu_v2_lab_progress_store.dart';
import '../core/isometric_camera.dart';
import '../core/vu_game_controller.dart';
import '../missions/patient_assessment_mission.dart';
import '../models/vu_game_models.dart';
import '../nursing/nursing_floor_layout.dart';
import '../services/vu_game_ai_dialogue.dart';
import 'game_dialogue_sheet.dart';
import 'game_life_sim_chrome.dart';
import 'game_mission_results_screen.dart';
import 'vu_game_world_painter.dart';

/// Walkable GradeGlow Nursing Virtual Clinical — MVP interactive floor.
class NursingClinicalGameScreen extends StatefulWidget {
  const NursingClinicalGameScreen({super.key});

  @override
  State<NursingClinicalGameScreen> createState() =>
      _NursingClinicalGameScreenState();
}

class _NursingClinicalGameScreenState extends State<NursingClinicalGameScreen>
    with SingleTickerProviderStateMixin {
  final VuV2LabProgressStore _progress = VuV2LabProgressStore();
  final PatientAssessmentMission _mission = PatientAssessmentMission();
  final VuGameScriptedDialogue _dialogue = nursingClinicalDialogue();
  final VuGamePlayerAppearance _appearance = const VuGamePlayerAppearance(
    displayName: 'Student Nurse',
  );

  late VuGameWorldLayout _layout;
  late VuGameController _controller;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _ready = false;
  int _mistakes = 0;

  String? _dialogueNodeId;
  String? _toast;
  String? _vitalsLine;
  String? _bubbleText;
  String? _npcBubbleId;
  String? _selectedTool = 'hands';
  bool _missionActive = false;

  static const String _worldId = 'nursing';

  @override
  void initState() {
    super.initState();
    _layout = NursingFloorLayout.build();
    _controller = VuGameController(layout: _layout);
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    _ticker = createTicker(_onTick)..start();
    if (!_progress.sawDayOneLabel(_worldId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcome());
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final double dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    _controller.tick(dt);
    if (mounted) setState(() {});
    _checkZoneObjectives();
  }

  void _checkZoneObjectives() {
    if (!_missionActive) return;
    if (_controller.zoneAtPlayer() == 'patient_room' && !_mission.enteredRoom) {
      _mission.mark('enter_room');
      _flash('Entered Patient Room 103');
    }
  }

  Future<void> _showWelcome() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1628),
        title: const Text(
          'GradeGlow Nursing Clinical',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Tap the floor to walk. Use Interact near people and equipment. '
          'Talk to Charge Nurse Diaz to begin Patient Assessment.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () async {
              await _progress.markDayOneLabel(_worldId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enter hospital'),
          ),
        ],
      ),
    );
  }

  void _flash(String msg, {String? npcId}) {
    setState(() {
      _toast = msg;
      _bubbleText = msg;
      _npcBubbleId = npcId;
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toast = null;
          _bubbleText = null;
          _npcBubbleId = null;
        });
      }
    });
  }

  void _onTapWorld(Offset local, Size viewSize) {
    final VuGameViewTransform transform = VuGameViewTransform(
      worldSize: _layout.worldSize,
      viewSize: viewSize,
    );
    _controller.setMoveTarget(transform.screenToWorld(local));
  }

  Future<void> _interact() async {
    final VuGameNpc? npc = _controller.nearestNpc();
    if (npc != null) {
      _openDialogue(npc.dialogueRootId);
      return;
    }
    final VuGameInteractable? item = _controller.nearestInteractable();
    if (item != null) {
      _handleObject(item);
      return;
    }
    _flash('Move closer to a person or object to interact.');
  }

  void _openDialogue(String nodeId) {
    setState(() => _dialogueNodeId = nodeId);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final VuGameDialogueNodeData? node = _dialogue.node(_dialogueNodeId ?? nodeId);
        if (node == null) return const SizedBox.shrink();
        return GameDialogueSheet(
          node: node,
          accent: const Color(0xFF10B981),
          onClose: () => Navigator.pop(ctx),
          onChoice: (VuGameDialogueChoiceData choice) {
            _applyDialogueAction(choice.actionId);
            Navigator.pop(ctx);
            if (choice.nextNodeId != null) {
              Future<void>.delayed(const Duration(milliseconds: 200), () {
                if (mounted) _openDialogue(choice.nextNodeId!);
              });
            }
          },
        );
      },
    );
  }

  void _applyDialogueAction(String? actionId) {
    if (actionId == null) return;
    switch (actionId) {
      case 'mission_start':
        setState(() => _missionActive = true);
        _flash('Mission: Patient Assessment started');
      case 'talk_patient':
        _mission.mark('talk_patient');
      case 'identify_concern':
        _mission.mark('concern');
        _flash('Concerning symptoms noted — consider escalation');
      case 'notify_doctor':
        if (_mission.checkedVitals && _mission.identifiedConcern) {
          _mission.mark('notify');
        } else {
          _mistakes++;
          _flash('Escalate after vitals and assessment — Dr. Park needs data');
        }
    }
    setState(() {});
    _maybeCompleteMission();
  }

  void _handleObject(VuGameInteractable item) {
    if (!_missionActive && item.actionId != 'view_assignments') {
      _flash('Check in with Charge Nurse Diaz first.');
      return;
    }
    switch (item.actionId) {
      case 'view_assignments':
        _flash('Assignment: Room 103 — Mr. Cole, respiratory distress');
        if (_missionActive) _mission.mark('enter_room');
      case 'review_chart':
        _mission.mark('chart');
        _flash(
          'Chart: COPD + HFrEF. SpO₂ 88% overnight on 2L NC. Allergies: sulfa.',
        );
      case 'check_monitor':
      case 'check_bp':
      case 'auscultate':
        _mission.mark('vitals');
        setState(() {
          _vitalsLine = 'HR 112 · BP 148/92 · SpO₂ 86% · RR 32 — abnormal';
        });
        _flash('Vitals recorded on monitor');
      case 'document':
        if (_mission.checkedVitals) {
          _mission.mark('document');
          _flash('Assessment documented in EHR');
        } else {
          _mistakes++;
          _flash('Document after you assess vitals');
        }
      case 'call_team':
        if (_mission.identifiedConcern && _mission.checkedVitals) {
          _mission.mark('notify');
          _openDialogue('doctor_root');
        } else {
          _mistakes++;
          _flash('Gather assessment data before calling the team');
        }
      case 'med_cabinet':
        _mistakes++;
        _flash('No med pass without orders — safety first');
      case 'bedside':
        _openDialogue('patient_root');
      default:
        _flash('${item.label}: ready');
    }
    setState(() {});
    _maybeCompleteMission();
  }

  Future<void> _maybeCompleteMission() async {
    if (!_mission.complete) return;
    final Map<String, int> scores =
        _mission.scoreBreakdown(mistakeCount: _mistakes);
    final int xp = _mission.xpReward(mistakeCount: _mistakes);
    await _progress.completeCareerMission(
      worldId: _worldId,
      missionId: PatientAssessmentMission.missionId,
      missionIndex: 2,
      won: true,
      xpGain: xp,
      skillScores: <String, int>{
        'patient_care': scores['Patient Assessment'] ?? 80,
        'critical_thinking': scores['Critical Thinking'] ?? 80,
        'communication': scores['Communication'] ?? 80,
        'clinical_knowledge': scores['Safety'] ?? 80,
        'professionalism': scores['Decision Making'] ?? 80,
      },
      badgeId: 'first_clinical',
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameMissionResultsScreen(
          completeLabel: 'CLINICAL COMPLETE',
          missionTitle: PatientAssessmentMission.title,
          scores: scores,
          overall: scores['overall'] ?? 0,
          xpEarned: xp,
          totalXp: _progress.xp,
          achievement: 'First Clinical',
          onDone: () => Navigator.pop(context),
        ),
      ),
    );
    setState(() {
      _missionActive = false;
      _mission.objectivesDone.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF06101C),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final VuGameInteractable? near = _controller.nearestInteractable();
    final VuGameNpc? nearNpc = _controller.nearestNpc();
    final int level = VuV2LabGame.levelForXp(_progress.xp);
    const Color accent = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFF7EC8F0),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Size viewSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  final VuGameViewTransform transform = VuGameViewTransform(
                    worldSize: _layout.worldSize,
                    viewSize: viewSize,
                    follow: _controller.player,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (TapUpDetails d) =>
                        _onTapWorld(d.localPosition, viewSize),
                    child: CustomPaint(
                      painter: VuGameWorldPainter(
                        layout: _layout,
                        transform: transform,
                        player: _controller.player,
                        appearance: _appearance,
                        highlightInteractableId: near?.id,
                        moveTarget: _controller.moveTarget,
                        bubbleText: _bubbleText,
                        npcBubbleId: _npcBubbleId,
                      ),
                      size: viewSize,
                    ),
                  );
                },
              ),
            ),
            GameLifeSimChrome(
              locationName:
                  _controller.zoneNameAtPlayer() ?? _layout.title,
              playerName: _appearance.displayName,
              level: level,
              xp: _progress.xp,
              accent: accent,
              onBack: () => Navigator.maybePop(context),
              onInteract: _interact,
              statusLine: _vitalsLine,
              toast: _toast,
              nearLabel: nearNpc != null
                  ? 'Near ${nearNpc.name} — tap Interact to talk'
                  : near != null
                      ? 'Near ${near.label}'
                      : 'Tap the ground to walk',
              missionTitle: _missionActive ? PatientAssessmentMission.title : null,
              objectives: _missionActive
                  ? PatientAssessmentMission.objectiveLabels
                      .map(
                        (({String id, String label}) o) => (
                          label: o.label,
                          done: _mission.objectivesDone.contains(o.id),
                        ),
                      )
                      .toList()
                  : const <({String label, bool done})>[],
              selectedHotbar: _selectedTool,
              onHotbar: (String id) {
                setState(() => _selectedTool = id);
                switch (id) {
                  case 'stethoscope':
                    _flash('Stethoscope ready — use near the patient');
                  case 'chart':
                    _flash('Chart tool selected');
                  case 'radio':
                    _flash('Call team when assessment is ready');
                  default:
                    _flash('Hands free — walk and interact');
                }
              },
              hotbar: const <({IconData icon, String label, String id})>[
                (icon: Icons.pan_tool_alt_rounded, label: 'Hands', id: 'hands'),
                (icon: Icons.hearing_rounded, label: 'Stethoscope', id: 'stethoscope'),
                (icon: Icons.assignment_rounded, label: 'Chart', id: 'chart'),
                (icon: Icons.phone_in_talk_rounded, label: 'Call team', id: 'radio'),
                (icon: Icons.medical_services_rounded, label: 'Kit', id: 'kit'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
