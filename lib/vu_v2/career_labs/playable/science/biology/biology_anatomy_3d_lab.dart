import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../data/science_diagram_catalog.dart';
import '../../../../../models/science_diagram.dart';
import '../../../../../widgets/science/anatomy_asset_canvas.dart';
import '../../../../labs/lab_mission_celebration.dart';
import '../../../../labs/university_lab_result.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_label_lab.dart';
import 'clinical_viva_cases.dart';

/// Clinical Viva + 3D anatomy practical — graded clinical reasoning on the model.
///
/// Flow: patient chart → orbit views → bone IDs → clinical viva → labels → scored debrief.
class BiologyAnatomy3dLab extends StatefulWidget {
  const BiologyAnatomy3dLab({
    super.key,
    this.diagramId,
    this.caseId,
    this.focusRegionIds,
    this.embedded = false,
    this.onComplete,
    this.missionMode = true,
  });

  /// Overrides case diagram when set without a case.
  final String? diagramId;
  final String? caseId;
  final List<String>? focusRegionIds;
  final bool embedded;
  final VoidCallback? onComplete;
  final bool missionMode;

  @override
  State<BiologyAnatomy3dLab> createState() => _BiologyAnatomy3dLabState();
}

enum _MissionStep { orbit, identify, clinical, label, submit }

class _BiologyAnatomy3dLabState extends State<BiologyAnatomy3dLab>
    with SingleTickerProviderStateMixin {
  static const ScienceLabTheme t = ScienceLabTheme.biology;

  late final ClinicalVivaCase _case =
      ClinicalVivaCatalog.byId(widget.caseId);

  List<String> get _quizTargets => _case.identifyTargets;
  String get _clinicalTarget => _case.diagnoseTargetId;
  String get _diagramId => widget.diagramId ?? _case.diagramId;

  double _yawRadians = 0;
  double _pitchRadians = 0;
  String? _highlightId;
  String? _feedbackId;
  bool? _feedbackCorrect;

  bool _sawAnterior = true;
  bool _sawPosterior = false;
  bool _sawLateral = false;
  bool _labelDrillDone = false;

  int _quizIndex = 0;
  int _identifyCorrect = 0;
  int _identifyAttempts = 0;
  int _combo = 0;
  int _bestCombo = 0;
  String? _coachFlash;
  final Set<String> _identified = <String>{};

  bool _clinicalBoneFound = false;
  bool _clinicalVivaDone = false;
  bool _clinicalVivaCorrect = false;
  bool _caseAccepted = false;
  int? _vivaChoice;

  late final AnimationController _casePulse;
  final Stopwatch _clock = Stopwatch();

  @override
  void initState() {
    super.initState();
    _clock.start();
    _casePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    if (widget.missionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPatientChart());
    } else {
      _caseAccepted = true;
    }
  }

  @override
  void dispose() {
    _casePulse.dispose();
    super.dispose();
  }

  ScienceDiagram? get _diagram => ScienceDiagramCatalog.diagramById(_diagramId);

  bool get _onRequiredView {
    switch (_case.requiredView) {
      case ClinicalRequiredView.anterior:
        return _viewLabel.startsWith('Anterior');
      case ClinicalRequiredView.posterior:
        return _viewLabel.startsWith('Posterior');
      case ClinicalRequiredView.lateral:
        return _viewLabel.startsWith('Lateral');
    }
  }

  String get _viewLabel {
    final double deg = (_yawRadians * 180 / math.pi) % 360;
    final double a = deg < 0 ? deg + 360 : deg;
    if (a < 45 || a >= 315) return 'Anterior view';
    if (a < 135) return 'Lateral view (right)';
    if (a < 225) return 'Posterior view';
    return 'Lateral view (left)';
  }

  Set<String> get _enabledRegions {
    final ScienceDiagram? d = _diagram;
    if (d == null) return const <String>{};
    if (widget.focusRegionIds == null || widget.focusRegionIds!.isEmpty) {
      return d.regions.map((ScienceDiagramRegion r) => r.id).toSet();
    }
    return widget.focusRegionIds!.toSet();
  }

  bool get _orbitDone => _sawAnterior && _sawPosterior && _sawLateral;
  bool get _identifyDone => _identified.length >= _quizTargets.length;
  bool get _clinicalDone => _clinicalBoneFound && _clinicalVivaDone;
  bool get _canSubmit =>
      !widget.missionMode ||
      (_orbitDone && _identifyDone && _clinicalDone && _labelDrillDone);

  _MissionStep get _step {
    if (!_orbitDone) return _MissionStep.orbit;
    if (!_identifyDone) return _MissionStep.identify;
    if (!_clinicalDone) return _MissionStep.clinical;
    if (!_labelDrillDone) return _MissionStep.label;
    return _MissionStep.submit;
  }

  String get _coachTip {
    if (_coachFlash != null) return _coachFlash!;
    switch (_step) {
      case _MissionStep.orbit:
        return 'Professor: Drag through Anterior · Lateral · Posterior — clinicians inspect from the ${_case.requiredViewLabel.toLowerCase()} first.';
      case _MissionStep.identify:
        final String id =
            _quizTargets[_quizIndex.clamp(0, _quizTargets.length - 1)];
        if (id == 'radius') {
          return 'Professor: Radius = thumb side (lateral). Ulna hugs the pinky.';
        }
        if (id == 'ulna') {
          return 'Professor: Ulna is medial and forms the elbow point.';
        }
        if (id == 'left_ventricle') {
          return 'Professor: Left ventricle = thick systemic pump.';
        }
        if (id == 'right_ventricle') {
          return 'Professor: Right ventricle → lungs via pulmonary artery.';
        }
        if (id == 'aorta') {
          return 'Professor: Aorta leaves the left ventricle to the body.';
        }
        return 'Professor: Tap ${_regionName(id)} on the model.';
      case _MissionStep.clinical:
        if (!_onRequiredView) {
          return 'Viva: Rotate to ${_case.requiredViewLabel.toUpperCase()} view before you diagnose.';
        }
        if (!_clinicalBoneFound) {
          return 'Viva: Tap the structure implicated by this patient case.';
        }
        return 'Viva: Answer the clinical reasoning question.';
      case _MissionStep.label:
        return 'Professor: Label drill — practical exams grade placement accuracy.';
      case _MissionStep.submit:
        return 'Professor: Clinical + spatial mastery. Submit for board scoring.';
    }
  }

  String get _missionPrompt {
    switch (_step) {
      case _MissionStep.orbit:
        return 'Mission 1 — Orbit: Anterior · Lateral · Posterior';
      case _MissionStep.identify:
        return 'Mission 2 — Tap ${_regionName(_quizTargets[_quizIndex.clamp(0, _quizTargets.length - 1)])}';
      case _MissionStep.clinical:
        return 'Mission 3 — CLINICAL VIVA: ${_case.title}';
      case _MissionStep.label:
        return 'Mission 4 — Drag-and-drop label drill';
      case _MissionStep.submit:
        return 'Board ready — submit your clinical practical';
    }
  }

  String _regionName(String id) {
    final ScienceDiagram? d = _diagram;
    if (d == null) return id;
    for (final ScienceDiagramRegion r in d.regions) {
      if (r.id == id) return r.name;
    }
    return id;
  }

  Future<void> _showPatientChart() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'ED CHART · CLINICAL VIVA',
                style: TextStyle(
                  color: t.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Patient: ${_case.patientLine}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _case.chartBody,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'What makes this unique',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Name quizzes stop at labels. We force the correct VIEW (${_case.requiredViewLabel}), '
                'the injured STRUCTURE, and a clinical WHY — then grade it like a university practical.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: const Color(0xFF04110C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ACCEPT CASE · ENTER PRACTICAL',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() => _caseAccepted = true);
  }

  void _trackView() {
    final String v = _viewLabel;
    if (v.startsWith('Anterior')) _sawAnterior = true;
    if (v.startsWith('Posterior')) _sawPosterior = true;
    if (v.startsWith('Lateral')) _sawLateral = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _yawRadians += details.delta.dx * 0.012;
      _pitchRadians =
          (_pitchRadians + details.delta.dy * 0.008).clamp(-0.45, 0.45);
      _trackView();
    });
  }

  void _onRegionTap(ScienceDiagramRegion region) {
    HapticFeedback.lightImpact();
    if (!widget.missionMode) {
      setState(() {
        _highlightId = region.id;
        _feedbackId = region.id;
        _feedbackCorrect = true;
      });
      return;
    }

    if (_step == _MissionStep.clinical) {
      if (!_onRequiredView) {
        setState(() {
          _coachFlash =
              'Wrong view — rotate to ${_case.requiredViewLabel.toUpperCase()} before diagnosing.';
          _feedbackId = region.id;
          _feedbackCorrect = false;
        });
        return;
      }
      final bool ok = region.id == _clinicalTarget;
      setState(() {
        _feedbackId = region.id;
        _feedbackCorrect = ok;
        _highlightId = region.id;
        if (ok) {
          _clinicalBoneFound = true;
          _coachFlash =
              '${_regionName(_clinicalTarget)} at risk — now answer the viva (why it matters).';
        } else {
          _coachFlash = _case.coachOnWrongBone;
        }
      });
      return;
    }

    if (_step != _MissionStep.identify) {
      setState(() {
        _highlightId = region.id;
        _feedbackId = region.id;
        _feedbackCorrect = true;
      });
      return;
    }

    final String target =
        _quizTargets[_quizIndex.clamp(0, _quizTargets.length - 1)];
    final bool ok = region.id == target;
    setState(() {
      _identifyAttempts += 1;
      _highlightId = region.id;
      _feedbackId = region.id;
      _feedbackCorrect = ok;
      if (ok) {
        _identifyCorrect += 1;
        _combo += 1;
        if (_combo > _bestCombo) _bestCombo = _combo;
        _identified.add(target);
        _coachFlash = _combo >= 2
            ? 'Combo x$_combo!'
            : 'Correct — ${_regionName(target)} locked.';
        if (_quizIndex < _quizTargets.length - 1) _quizIndex += 1;
      } else {
        _combo = 0;
        _coachFlash =
            'Not ${_regionName(target)}. You tapped ${_regionName(region.id)}.';
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _coachFlash = null);
    });
  }

  Future<void> _openLabelDrill() async {
    final ScienceDiagram? diagram = _diagram;
    if (diagram == null) return;
    final List<String> ids = widget.focusRegionIds ??
        (_diagramId == 'heart_detail'
            ? <String>[
                'left_ventricle',
                'right_ventricle',
                'aorta',
                'left_atrium',
                'right_atrium',
                'pulmonary_artery',
              ]
            : <String>[
                'radius',
                'ulna',
                'humerus',
                'scapula',
                'clavicle',
                'femur',
              ]);
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _InlineLabelDrill(
          diagramId: _diagramId,
          regionIds: ids.take(6).toList(),
        ),
      ),
    );
    if (ok == true && mounted) setState(() => _labelDrillDone = true);
  }

  void _answerViva(int choice) {
    final bool ok = choice == _case.correctVivaIndex;
    setState(() {
      _vivaChoice = choice;
      _clinicalVivaDone = true;
      _clinicalVivaCorrect = ok;
      _coachFlash = ok
          ? _case.coachOnPass
          : 'Not quite — re-read the case and think spatially on the model.';
    });
  }

  UniversityLabResult _buildResult() {
    final int views = <bool>[_sawAnterior, _sawPosterior, _sawLateral]
        .where((bool v) => v)
        .length;
    final double idAcc =
        _identifyAttempts == 0 ? 0 : _identifyCorrect / _identifyAttempts;
    final double orbitScore = views / 3.0;
    final double labelScore = _labelDrillDone ? 1.0 : 0.0;
    final double clinicalScore = (_clinicalBoneFound ? 0.55 : 0) +
        (_clinicalVivaCorrect ? 0.45 : 0);
    final double accuracy = ((orbitScore * 0.18) +
            (idAcc * 0.32) +
            (labelScore * 0.20) +
            (clinicalScore * 0.30))
        .clamp(0.0, 1.0);

    final List<String> notes = <String>[];
    if (!_clinicalBoneFound || !_clinicalVivaCorrect) {
      notes.add(
        'Clinical viva incomplete — university practicals grade reasoning, not only labels.',
      );
    } else {
      notes.add(
        'Clinical viva passed: ${_case.title} — you linked the case to ${_regionName(_clinicalTarget)}.',
      );
    }
    if (_case.requiredView == ClinicalRequiredView.posterior && !_sawPosterior) {
      notes.add('Posterior view under-used — critical for this case.');
    }
    if (idAcc < 0.7) {
      notes.add('Structure IDs need work — spatial traps cost board points.');
    }
    if (_labelDrillDone && clinicalScore >= 0.9 && idAcc >= 0.8) {
      notes.add('Board-level practical: spatial + clinical mastery.');
    }

    final int xp = accuracy >= 0.9
        ? 220
        : accuracy >= 0.75
            ? 175
            : accuracy >= 0.6
                ? 120
                : 60;

    return UniversityLabResult(
      accuracy: accuracy,
      identifyCorrect: _identifyCorrect,
      identifyAttempts: math.max(_identifyAttempts, 1),
      viewsVisited: views,
      labelDrillComplete: _labelDrillDone,
      coachingNotes: notes,
      xpEarned: xp,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: accuracy >= 0.85 ? 'clinical_anatomist' : null,
      clinicalSolved: _clinicalBoneFound && _clinicalVivaCorrect,
      clinicalReasoningScore: clinicalScore,
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_orbitDone
                ? 'Finish orbiting all three views.'
                : !_identifyDone
                    ? 'Identify all target bones.'
                    : !_clinicalDone
                        ? 'Complete the clinical viva (${_case.requiredViewLabel} + ${_regionName(_clinicalTarget)} + question).'
                        : 'Finish the label drill.',
          ),
          backgroundColor: const Color(0xFF1B3A2F),
        ),
      );
      return;
    }
    _clock.stop();
    final UniversityLabResult result = _buildResult();
    widget.onComplete?.call();
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'CLINICAL PRACTICAL PASSED'
          : (result.passed ? 'LAB COMPLETE' : 'LAB NEEDS RETRY'),
      accentLabel: 'Clinical Anatomist',
    );
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Widget _patientBanner() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.75, end: 1).animate(_casePulse),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1020),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF472B6).withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '🩺 ACTIVE CASE',
              style: TextStyle(
                color: Color(0xFFF472B6),
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _case.patientLine,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.3,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vivaPanel() {
    if (_step != _MissionStep.clinical || !_clinicalBoneFound) {
      return const SizedBox.shrink();
    }
    final List<String> options = _case.vivaOptions;
    final int correct = _case.correctVivaIndex;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1624),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.accent.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _case.vivaPrompt,
              style: TextStyle(
                color: t.accent,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...List<Widget>.generate(options.length, (int i) {
              final bool selected = _vivaChoice == i;
              final bool showResult = _clinicalVivaDone;
              Color border = Colors.white24;
              if (showResult && i == correct) border = t.accent;
              if (showResult && selected && i != correct) border = Colors.redAccent;
              if (selected && !showResult) border = t.accent;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: OutlinedButton(
                  onPressed: _clinicalVivaDone ? null : () => _answerViva(i),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: border),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: Text(options[i], style: const TextStyle(fontSize: 12.5)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _missionHud() {
    Widget chip(String label, bool done) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: done
                ? t.accent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: done ? t.accent : Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: done ? t.accent : Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: done ? t.accent : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _missionPrompt,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              chip('Orbit', _orbitDone),
              chip('IDs ${_identified.length}/${_quizTargets.length}', _identifyDone),
              chip('Clinical viva', _clinicalDone),
              chip('Labels', _labelDrillDone),
              if (_bestCombo > 1) chip('Combo x$_bestCombo', true),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: t.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.record_voice_over_rounded, color: t.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _coachTip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram = _diagram;
    if (diagram == null) {
      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(title: const Text('3D Anatomy Lab')),
        body: const Center(child: Text('Diagram not found')),
      );
    }

    if (!_caseAccepted && widget.missionMode) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: <Widget>[
              Icon(Icons.medical_services_outlined, color: t.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CLINICAL VIVA LAB — ${diagram.title}',
                  style: TextStyle(
                    color: t.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Text(
                _viewLabel,
                style: TextStyle(
                  color: _step == _MissionStep.clinical && !_onRequiredView
                      ? Colors.orangeAccent
                      : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (widget.missionMode) _patientBanner(),
        if (widget.missionMode) _missionHud(),
        if (widget.missionMode) _vivaPanel(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1624),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _step == _MissionStep.clinical
                      ? const Color(0xFFF472B6).withValues(alpha: 0.55)
                      : t.accent.withValues(alpha: 0.35),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (_step == _MissionStep.clinical
                            ? const Color(0xFFF472B6)
                            : t.accent)
                        .withValues(alpha: 0.14),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  child: InteractiveViewer(
                    minScale: 0.6,
                    maxScale: 4,
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(_yawRadians)
                          ..rotateX(_pitchRadians),
                        child: AspectRatio(
                          aspectRatio: 1 / diagram.aspectRatio,
                          child: AnatomyAssetCanvas(
                            diagram: diagram,
                            highlightRegionId: _highlightId,
                            highlightRegionIds: _step == _MissionStep.clinical
                                ? <String>{_clinicalTarget}
                                : _step == _MissionStep.identify
                                    ? <String>{
                                        _quizTargets[_quizIndex.clamp(
                                          0,
                                          _quizTargets.length - 1,
                                        )],
                                      }
                                    : _enabledRegions,
                            enabledRegionIds: _enabledRegions,
                            showOverlays: _feedbackId != null ||
                                _step == _MissionStep.identify ||
                                _step == _MissionStep.clinical,
                            dimNonHighlighted:
                                _step == _MissionStep.clinical || _feedbackId != null,
                            feedbackRegionId: _feedbackId,
                            feedbackCorrect: _feedbackCorrect,
                            pulse: _step == _MissionStep.clinical ||
                                _step == _MissionStep.identify,
                            onRegionTap: _onRegionTap,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: <Widget>[
              if (_step == _MissionStep.label || _labelDrillDone)
                OutlinedButton.icon(
                  onPressed: _openLabelDrill,
                  icon: const Icon(Icons.drag_indicator),
                  label: Text(_labelDrillDone ? 'Relabel' : 'Start labels'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _canSubmit
                    ? _submit
                    : (_step == _MissionStep.label ? _openLabelDrill : null),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  disabledBackgroundColor: Colors.white12,
                ),
                child: Text(
                  _canSubmit
                      ? 'SUBMIT CLINICAL PRACTICAL'
                      : _step == _MissionStep.label
                          ? 'OPEN LABEL DRILL'
                          : 'COMPLETE MISSIONS',
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ColoredBox(color: t.bg, child: body);
    }

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121C2E),
        foregroundColor: Colors.white,
        title: const Text('Clinical Viva · 3D Anatomy'),
      ),
      body: body,
    );
  }
}

class _InlineLabelDrill extends StatelessWidget {
  const _InlineLabelDrill({required this.diagramId, required this.regionIds});

  final String diagramId;
  final List<String> regionIds;

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(diagramId);
    if (diagram == null) {
      return const Scaffold(body: Center(child: Text('Diagram unavailable')));
    }
    final List<ScienceDiagramRegion> regions = diagram.regions
        .where((ScienceDiagramRegion r) => regionIds.contains(r.id))
        .toList();
    final List<ScienceLabelHotspot> hotspots = regions
        .map(
          (ScienceDiagramRegion r) => ScienceLabelHotspot(
            id: r.id,
            correctLabel: r.name,
            fx: r.center.dx,
            fy: r.center.dy,
            hint: r.funFact,
          ),
        )
        .toList();
    final List<String> bank =
        hotspots.map((ScienceLabelHotspot h) => h.correctLabel).toList()..shuffle();

    return ScienceLabelLab(
      theme: ScienceLabTheme.biology,
      hotspots: hotspots,
      mode: ScienceLabelMode.normal,
      diagramTitle: diagram.title,
      diagramId: diagramId,
      wordBank: bank,
      popOnComplete: true,
      diagramChild: AnatomyAssetCanvas(
        diagram: diagram,
        highlightRegionId: null,
        showOverlays: false,
        onRegionTap: (_) {},
      ),
      onComplete: (_) => Navigator.of(context).pop(true),
    );
  }
}
