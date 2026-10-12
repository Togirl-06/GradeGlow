import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../labs/centers/vu_v2_lab_game.dart';
import '../../labs/centers/vu_v2_lab_progress_store.dart';
import '../career/objective_mission.dart';
import '../career/vu_career_world_pack.dart';
import '../core/isometric_camera.dart';
import '../core/vu_game_controller.dart';
import '../models/vu_game_models.dart';
import '../services/vu_game_ai_dialogue.dart';
import 'game_dialogue_sheet.dart';
import 'game_life_sim_chrome.dart';
import 'game_mission_results_screen.dart';
import 'vu_game_world_painter.dart';

/// Shared walkable career world — engine gameplay, major-specific content.
class CareerWorldGameScreen extends StatefulWidget {
  const CareerWorldGameScreen({super.key, required this.pack});

  final VuCareerWorldPack pack;

  @override
  State<CareerWorldGameScreen> createState() => _CareerWorldGameScreenState();
}

class _CareerWorldGameScreenState extends State<CareerWorldGameScreen>
    with SingleTickerProviderStateMixin {
  final VuV2LabProgressStore _progress = VuV2LabProgressStore();
  late final ObjectiveMission _mission;
  late final VuGameController _controller;
  late final VuGamePlayerAppearance _appearance;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _ready = false;
  int _mistakes = 0;
  bool _missionActive = false;
  String? _toast;
  String? _statusLine;
  String? _bubbleText;
  String? _npcBubbleId;
  String? _selectedTool = 'hands';

  VuCareerWorldPack get pack => widget.pack;

  @override
  void initState() {
    super.initState();
    _mission = ObjectiveMission(
      missionId: pack.mission.missionId,
      title: pack.mission.title,
      objectives: pack.mission.objectives,
      xpComplete: pack.mission.xpComplete,
    );
    _controller = VuGameController(layout: pack.layout);
    _appearance = VuGamePlayerAppearance(
      displayName: pack.role,
      outfitColor: pack.accent,
    );
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (!mounted) return;
    setState(() => _ready = true);
    _ticker = createTicker(_onTick)..start();
    if (!_progress.sawDayOneLabel(pack.id)) {
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
  }

  Future<void> _showWelcome() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E1628),
        title: Text(
          pack.welcomeTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          pack.welcomeBody,
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: <Widget>[
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Color(pack.accent)),
            onPressed: () async {
              await _progress.markDayOneLabel(pack.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enter world'),
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
      worldSize: pack.layout.worldSize,
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final VuGameDialogueNodeData? node = pack.dialogue.node(nodeId);
        if (node == null) return const SizedBox.shrink();
        return GameDialogueSheet(
          node: node,
          accent: Color(pack.accent),
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
    if (actionId == 'mission_start') {
      setState(() => _missionActive = true);
      _mission.mark('brief');
      _flash('Mission started');
    } else if (actionId.startsWith('mark_')) {
      _mission.mark(actionId.substring(5));
      _flash('Noted');
    }
    setState(() {});
    _maybeComplete();
  }

  void _handleObject(VuGameInteractable item) {
    final VuObjectHandler? handler = pack.objectHandlers[item.actionId];
    if (handler == null) {
      _flash('${item.label}: ready');
      return;
    }
    if (handler.requiresMission && !_missionActive) {
      _flash('Talk to your supervisor to start the mission first.');
      return;
    }
    final bool missing = handler.requireMarks.any((String m) => !_mission.has(m));
    if (missing) {
      if (handler.mistakeIfLocked) _mistakes++;
      _flash(handler.lockedToast ?? 'Complete earlier steps first.');
      setState(() {});
      return;
    }
    for (final String o in handler.markObjectives) {
      _mission.mark(o);
    }
    if (handler.vitalsLine != null) {
      _statusLine = handler.vitalsLine;
    }
    _flash(handler.toast);
    if (handler.openDialogueId != null) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _openDialogue(handler.openDialogueId!);
      });
    }
    setState(() {});
    _maybeComplete();
  }

  Future<void> _maybeComplete() async {
    if (!_mission.complete) return;
    final List<String> cats = pack.skillKeys.keys.toList();
    final Map<String, int> scores = _mission.scoreBreakdown(
      mistakeCount: _mistakes,
      skillCategories: cats,
    );
    final int xp = _mission.xpReward(mistakeCount: _mistakes);
    final Map<String, int> skillScores = <String, int>{};
    for (final MapEntry<String, String> e in pack.skillKeys.entries) {
      skillScores[e.value] = scores[e.key] ?? 80;
    }
    await _progress.completeCareerMission(
      worldId: pack.id,
      missionId: _mission.missionId,
      missionIndex: 1,
      won: true,
      xpGain: xp,
      skillScores: skillScores,
      badgeId: '${pack.id}_mission_1',
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameMissionResultsScreen(
          completeLabel: pack.completeLabel,
          missionTitle: _mission.title,
          scores: scores,
          overall: scores['overall'] ?? 0,
          xpEarned: xp,
          totalXp: _progress.xp,
          achievement: pack.achievement,
          onDone: () => Navigator.pop(context),
        ),
      ),
    );
    setState(() {
      _missionActive = false;
      _mission.reset();
      _mistakes = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: const Color(0xFF06101C),
        body: Center(
          child: CircularProgressIndicator(color: Color(pack.accent)),
        ),
      );
    }

    final VuGameInteractable? near = _controller.nearestInteractable();
    final VuGameNpc? nearNpc = _controller.nearestNpc();
    final int level = VuV2LabGame.levelForXp(_progress.xp);
    final Color accent = Color(pack.accent);

    return Scaffold(
      backgroundColor: const Color(0xFF7EC8F0),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final Size viewSize = Size(c.maxWidth, c.maxHeight);
                  final VuGameViewTransform transform = VuGameViewTransform(
                    worldSize: pack.layout.worldSize,
                    viewSize: viewSize,
                    follow: _controller.player,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (TapUpDetails d) =>
                        _onTapWorld(d.localPosition, viewSize),
                    child: CustomPaint(
                      painter: VuGameWorldPainter(
                        layout: pack.layout,
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
              locationName: _controller.zoneNameAtPlayer() ?? pack.layout.title,
              playerName: pack.role,
              level: level,
              xp: _progress.xp,
              accent: accent,
              onBack: () => Navigator.maybePop(context),
              onInteract: _interact,
              statusLine: _statusLine,
              toast: _toast,
              nearLabel: nearNpc != null
                  ? 'Near ${nearNpc.name}'
                  : near != null
                      ? 'Near ${near.label}'
                      : 'Tap the ground to walk',
              missionTitle: _missionActive ? _mission.title : null,
              objectives: _missionActive
                  ? _mission.objectives
                      .map(
                        (({String id, String label}) o) => (
                          label: o.label,
                          done: _mission.has(o.id),
                        ),
                      )
                      .toList()
                  : const <({String label, bool done})>[],
              selectedHotbar: _selectedTool,
              onHotbar: (String id) {
                setState(() => _selectedTool = id);
                _flash('${id.replaceAll('_', ' ')} selected');
              },
              hotbar: const <({IconData icon, String label, String id})>[
                (icon: Icons.pan_tool_alt_rounded, label: 'Hands', id: 'hands'),
                (icon: Icons.chat_bubble_rounded, label: 'Talk', id: 'talk'),
                (icon: Icons.inventory_2_rounded, label: 'Tools', id: 'tools'),
                (icon: Icons.flag_rounded, label: 'Objectives', id: 'objectives'),
                (icon: Icons.backpack_rounded, label: 'Inventory', id: 'inventory'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
