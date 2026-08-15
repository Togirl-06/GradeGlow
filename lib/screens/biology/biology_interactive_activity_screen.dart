import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/biology_cell_organelles.dart';
import '../../data/biology_interactive_catalog.dart';
import '../../data/biology_studio_data.dart';
import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

/// Interactive Activity — students label structures on the topic diagram.
class BiologyInteractiveActivityScreen extends StatefulWidget {
  const BiologyInteractiveActivityScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyInteractiveActivityScreen> createState() =>
      _BiologyInteractiveActivityScreenState();
}

enum _SlotState { empty, placed, correct, wrong }

class _BiologyInteractiveActivityScreenState
    extends State<BiologyInteractiveActivityScreen> {
  BiologyInteractivePack? _pack;
  List<BiologyCellOrganelle> _targets = const <BiologyCellOrganelle>[];
  String _assetPath = 'assets/biology/animal_cell.svg';
  bool _ready = false;

  final Map<String, String?> _placements = <String, String?>{};
  final Map<String, _SlotState> _states = <String, _SlotState>{};
  final Set<String> _usedLabels = <String>{};
  String? _hint;
  String? _aiLine;
  int _checks = 0;

  BiologyInteractivePack get pack {
    _ensureReady();
    return _pack!;
  }

  void _ensureReady() {
    if (_ready && _pack != null) return;
    final BiologyInteractivePack loaded = BiologyInteractiveCatalog.forPath(
      topic: widget.path.lesson.title,
      courseId: widget.path.course.id,
    );
    final String t = widget.path.lesson.title.toLowerCase();
    final bool animal = t.contains('cell') ||
        t.contains('organelle') ||
        loaded.title.toLowerCase().contains('animal cell');
    final List<BiologyCellOrganelle> targets = animal
        ? BiologyCellOrganelleCatalog.animalCell
            .where((BiologyCellOrganelle o) => o.id != 'membrane')
            .toList()
        : _targetsFromPack(loaded);

    _pack = loaded;
    _targets = targets;
    _assetPath = animal
        ? 'assets/biology/animal_cell.svg'
        : BiologyStudioData.modelForTopic(
            widget.path.lesson.title,
            widget.path.course.id,
          ).assetPath;
    if (_placements.isEmpty) {
      for (final BiologyCellOrganelle o in targets) {
        _placements[o.id] = null;
        _states[o.id] = _SlotState.empty;
      }
      _aiLine ??=
          'Professor: Drag each label onto the matching structure on the diagram.';
    }
    _ready = true;
  }

  @override
  void initState() {
    super.initState();
    _ensureReady();
  }

  List<BiologyCellOrganelle> _targetsFromPack(BiologyInteractivePack pack) {
    return pack.labels.map((BiologyLabelTarget l) {
      return BiologyCellOrganelle(
        id: l.id,
        name: l.label,
        shortName: l.label,
        function: l.hint,
        contains: const <String>[],
        diseases: const <String>[],
        animationLabel: '',
        quizPrompt: '',
        quizChoices: const <String>[],
        quizCorrect: 0,
        color: 0xFF4ADE80,
        ax: l.posX,
        ay: l.posY,
        hitRadius: 0.08,
      );
    }).toList();
  }

  List<BiologyCellOrganelle> get _trayLabels {
    _ensureReady();
    return _targets
        .where((BiologyCellOrganelle o) => !_usedLabels.contains(o.id))
        .toList();
  }

  double get _progress {
    _ensureReady();
    if (_targets.isEmpty) return 0;
    final int n =
        _states.values.where((_SlotState s) => s == _SlotState.correct).length;
    return n / _targets.length;
  }

  void _accept(String targetId, String labelId) {
    setState(() {
      // If this label was on another target, clear it.
      for (final String key in _placements.keys.toList()) {
        if (_placements[key] == labelId) {
          _placements[key] = null;
          if (_states[key] != _SlotState.correct) {
            _states[key] = _SlotState.empty;
          }
        }
      }
      final String? previous = _placements[targetId];
      if (previous != null) _usedLabels.remove(previous);
      _placements[targetId] = labelId;
      _states[targetId] = _SlotState.placed;
      _usedLabels.add(labelId);
      _aiLine = null;
      _hint = null;
    });
  }

  void _reset() {
    setState(() {
      for (final String id in _placements.keys) {
        _placements[id] = null;
        _states[id] = _SlotState.empty;
      }
      _usedLabels.clear();
      _hint = null;
      _checks = 0;
      _aiLine =
          'Professor: Diagram cleared. Drag each label onto the matching structure.';
    });
  }

  void _hintAction() {
    _ensureReady();
    final BiologyCellOrganelle? next = _targets.cast<BiologyCellOrganelle?>().firstWhere(
          (BiologyCellOrganelle? o) =>
              o != null && _states[o.id] != _SlotState.correct,
          orElse: () => null,
        );
    setState(() {
      if (next == null) {
        _hint = 'All structures labeled correctly.';
      } else {
        _hint = 'Hint: Find the ${next.shortName} — ${next.function}';
        _aiLine = 'Professor: ${next.function}';
      }
    });
  }

  void _check() {
    _ensureReady();
    setState(() {
      _checks += 1;
      var correct = 0;
      for (final BiologyCellOrganelle target in _targets) {
        final String? placed = _placements[target.id];
        if (placed == target.id) {
          _states[target.id] = _SlotState.correct;
          correct += 1;
        } else if (placed != null) {
          _states[target.id] = _SlotState.wrong;
          _usedLabels.remove(placed);
          _placements[target.id] = null;
        }
      }
      _aiLine = correct == _targets.length
          ? 'Professor: Perfect — every structure is labeled correctly.'
          : 'Professor: $correct/${_targets.length} correct. Red markers need another try.';
    });
  }

  String _labelText(String? placedId) {
    if (placedId == null) return '';
    for (final BiologyCellOrganelle o in _targets) {
      if (o.id == placedId) return o.shortName;
    }
    return placedId;
  }

  @override
  Widget build(BuildContext context) {
    _ensureReady();
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final String title = '${pack.title} Activity';

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1726),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            color: c.primary,
            backgroundColor: Colors.white12,
          ),
          if (_aiLine != null)
            Container(
              width: double.infinity,
              color: c.primary.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.record_voice_over, color: c.primaryLight, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiLine!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1A2B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: c.primary.withValues(alpha: 0.35)),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const Size svgLogical = Size(480, 400);
                  final double scale = math.min(
                    constraints.maxWidth / svgLogical.width,
                    constraints.maxHeight / svgLogical.height,
                  );
                  final double drawW = svgLogical.width * scale;
                  final double drawH = svgLogical.height * scale;
                  final double originX = (constraints.maxWidth - drawW) / 2;
                  final double originY = (constraints.maxHeight - drawH) / 2;

                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0xFF0B1522),
                          child: Center(
                            child: SvgPicture.asset(
                              _assetPath,
                              width: drawW,
                              height: drawH,
                              fit: BoxFit.fill,
                              placeholderBuilder: (_) => Icon(
                                Icons.biotech,
                                size: 96,
                                color: c.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ..._targets.map((BiologyCellOrganelle target) {
                        final double x = originX + target.ax * drawW;
                        final double y = originY + target.ay * drawH;
                        final _SlotState state =
                            _states[target.id] ?? _SlotState.empty;
                        final String? placed = _placements[target.id];
                        final Color border = switch (state) {
                          _SlotState.correct => c.success,
                          _SlotState.wrong => const Color(0xFFEF4444),
                          _SlotState.placed => c.accent,
                          _SlotState.empty => Color(target.color),
                        };
                        final bool filled = placed != null;
                        return Positioned(
                          left: x - (filled ? 52 : 18),
                          top: y - (filled ? 16 : 18),
                          child: DragTarget<String>(
                            onWillAcceptWithDetails: (_) =>
                                state != _SlotState.correct,
                            onAcceptWithDetails:
                                (DragTargetDetails<String> d) =>
                                    _accept(target.id, d.data),
                            builder: (BuildContext context, List<String?> pending, _) {
                              final bool hover = pending.isNotEmpty;
                              if (!filled) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: hover
                                        ? Color(target.color).withValues(alpha: 0.55)
                                        : Color(target.color).withValues(alpha: 0.22),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: border, width: 2.2),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: border.withValues(alpha: 0.45),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                width: 104,
                                height: 32,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xF0132033),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: border,
                                    width: state == _SlotState.correct ||
                                            state == _SlotState.wrong
                                        ? 2.4
                                        : 1.5,
                                  ),
                                ),
                                child: Text(
                                  _labelText(placed),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: state == _SlotState.wrong
                                        ? const Color(0xFFFF8A80)
                                        : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Drag labels onto the correct structures on the diagram',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _trayLabels.map((BiologyCellOrganelle label) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Draggable<String>(
                    data: label.id,
                    feedback: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: Color(label.color),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          label.shortName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.25,
                      child: _trayChip(label, c),
                    ),
                    child: _trayChip(label, c),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_hint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _hint!,
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _hintAction,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                    child: const Text('Hint'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: _check,
                    style: FilledButton.styleFrom(backgroundColor: c.primary),
                    child: const Text('Check Answer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FilledButton(
                onPressed: _progress >= 0.6 || _checks > 0
                    ? () => Navigator.of(context).pop(true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  _progress >= 1
                      ? 'Complete · +${BioLessonActivityKind.interactive.xpReward} XP'
                      : 'Finish labeling to unlock XP',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trayChip(BiologyCellOrganelle label, BiologyDegreeColors c) {
    return Chip(
      label: Text(label.shortName),
      backgroundColor: Color(label.color).withValues(alpha: 0.25),
      side: BorderSide(color: Color(label.color).withValues(alpha: 0.6)),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
    );
  }
}

/// Soft living-cell backdrop for labeling (still a diagram students mark up).
