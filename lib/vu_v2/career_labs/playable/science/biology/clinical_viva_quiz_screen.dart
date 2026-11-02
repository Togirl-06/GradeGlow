import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../data/science_diagram_catalog.dart';
import '../../../../../models/science_diagram.dart';
import '../../../../../widgets/science/anatomy_asset_canvas.dart';
import '../../../../labs/lab_mission_celebration.dart';
import '../../../../labs/university_lab_result.dart';
import '../shared/science_lab_theme.dart';
import 'clinical_viva_cases.dart';

enum _QuizKind { mcq, diagnose3d }

class _QuizItem {
  const _QuizItem.mcq({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  })  : kind = _QuizKind.mcq,
        caseRef = null,
        assert(options.length >= 2);

  const _QuizItem.diagnose({
    required this.caseRef,
  })  : kind = _QuizKind.diagnose3d,
        prompt = '',
        options = const <String>[],
        correctIndex = 0;

  final _QuizKind kind;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final ClinicalVivaCase? caseRef;
}

/// Clinical Anatomy Quiz — MCQs + 3D diagnose items with clinical reasoning score.
class ClinicalVivaQuizScreen extends StatefulWidget {
  const ClinicalVivaQuizScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ClinicalVivaQuizScreen(),
      ),
    );
  }

  @override
  State<ClinicalVivaQuizScreen> createState() => _ClinicalVivaQuizScreenState();
}

class _ClinicalVivaQuizScreenState extends State<ClinicalVivaQuizScreen> {
  static const ScienceLabTheme t = ScienceLabTheme.biology;

  late final List<_QuizItem> _items = <_QuizItem>[
    _QuizItem.mcq(
      prompt: 'A FOOSH injury most often fractures which forearm bone?',
      options: <String>['Ulna (pinky side)', 'Radius (thumb side)', 'Femur', 'Scapula'],
      correctIndex: 1,
    ),
    const _QuizItem.diagnose(caseRef: ClinicalVivaCatalog.shoulderScapula),
    _QuizItem.mcq(
      prompt: 'Which chamber pumps oxygenated blood to the systemic circulation?',
      options: <String>[
        'Right atrium',
        'Right ventricle',
        'Left ventricle',
        'Pulmonary artery',
      ],
      correctIndex: 2,
    ),
    const _QuizItem.diagnose(caseRef: ClinicalVivaCatalog.forearmFall),
    _QuizItem.mcq(
      prompt: 'Why inspect the scapula from a posterior view clinically?',
      options: <String>[
        'It is only visible from behind on the thorax',
        'Anterior views always hide the femur',
        'Because quizzes prefer lateral only',
        'Scapula is an upper-leg bone',
      ],
      correctIndex: 0,
    ),
    const _QuizItem.diagnose(caseRef: ClinicalVivaCatalog.heartFailure),
  ];

  int _index = 0;
  int _correct = 0;
  int _attempts = 0;
  int _clinicalSolved = 0;
  int _clinicalMax = 0;
  final Stopwatch _clock = Stopwatch()..start();

  // Diagnose-3D state
  double _yaw = 0;
  double _pitch = 0;
  bool _boneOk = false;
  bool _itemDone = false;
  int? _vivaChoice;
  String? _feedbackId;
  bool? _feedbackCorrect;
  String? _coach;

  _QuizItem get _current => _items[_index];

  String get _viewLabel {
    final double deg = (_yaw * 180 / math.pi) % 360;
    final double a = deg < 0 ? deg + 360 : deg;
    if (a < 45 || a >= 315) return 'Anterior view';
    if (a < 135) return 'Lateral view (right)';
    if (a < 225) return 'Posterior view';
    return 'Lateral view (left)';
  }

  bool _onRequired(ClinicalVivaCase c) {
    switch (c.requiredView) {
      case ClinicalRequiredView.anterior:
        return _viewLabel.startsWith('Anterior');
      case ClinicalRequiredView.posterior:
        return _viewLabel.startsWith('Posterior');
      case ClinicalRequiredView.lateral:
        return _viewLabel.startsWith('Lateral');
    }
  }

  void _resetItemState() {
    _yaw = 0;
    _pitch = 0;
    _boneOk = false;
    _itemDone = false;
    _vivaChoice = null;
    _feedbackId = null;
    _feedbackCorrect = null;
    _coach = null;
  }

  void _answerMcq(int choice) {
    if (_itemDone) return;
    final bool ok = choice == _current.correctIndex;
    setState(() {
      _attempts += 1;
      if (ok) _correct += 1;
      _itemDone = true;
      _coach = ok ? 'Correct.' : 'Not quite — review the clinical anatomy.';
    });
  }

  void _tapRegion(ScienceDiagramRegion region) {
    final ClinicalVivaCase? c = _current.caseRef;
    if (c == null || _itemDone) return;
    HapticFeedback.lightImpact();
    if (!_onRequired(c)) {
      setState(() {
        _coach = 'Wrong view — rotate to ${c.requiredViewLabel.toUpperCase()}.';
        _feedbackId = region.id;
        _feedbackCorrect = false;
      });
      return;
    }
    final bool ok = region.id == c.diagnoseTargetId;
    setState(() {
      _feedbackId = region.id;
      _feedbackCorrect = ok;
      if (ok) {
        _boneOk = true;
        _coach = 'Structure locked — answer the clinical WHY.';
      } else {
        _coach = c.coachOnWrongBone;
      }
    });
  }

  void _answerViva(int choice) {
    final ClinicalVivaCase? c = _current.caseRef;
    if (c == null || !_boneOk || _itemDone) return;
    final bool ok = choice == c.correctVivaIndex;
    setState(() {
      _vivaChoice = choice;
      _itemDone = true;
      _attempts += 1;
      _clinicalMax += 1;
      if (ok && _boneOk) {
        _correct += 1;
        _clinicalSolved += 1;
      }
      _coach = ok ? c.coachOnPass : 'Clinical reasoning incomplete.';
    });
  }

  void _next() {
    if (_index >= _items.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index += 1;
      _resetItemState();
    });
  }

  Future<void> _finish() async {
    _clock.stop();
    final double accuracy =
        _attempts == 0 ? 0 : (_correct / _items.length).clamp(0.0, 1.0);
    final double clinicalScore =
        _clinicalMax == 0 ? 0 : (_clinicalSolved / _clinicalMax).clamp(0.0, 1.0);
    final UniversityLabResult result = UniversityLabResult(
      accuracy: (accuracy * 0.55) + (clinicalScore * 0.45),
      identifyCorrect: _correct,
      identifyAttempts: math.max(_items.length, 1),
      viewsVisited: 3,
      labelDrillComplete: true,
      coachingNotes: <String>[
        'Clinical items solved: $_clinicalSolved / $_clinicalMax',
        clinicalScore >= 0.8
            ? 'Board-ready: you diagnosed on the 3D model with clinical WHY.'
            : 'Re-run weak clinical cases in the 3D Viva Lab.',
      ],
      xpEarned: accuracy >= 0.8 ? 160 : 90,
      secondsElapsed: _clock.elapsed.inSeconds,
      badgeId: clinicalScore >= 0.8 ? 'clinical_anatomist' : null,
      clinicalSolved: _clinicalSolved == _clinicalMax && _clinicalMax > 0,
      clinicalReasoningScore: clinicalScore,
    );
    if (!mounted) return;
    await showLabMissionCelebration(
      context: context,
      result: result,
      title: result.clinicalSolved
          ? 'CLINICAL QUIZ PASSED'
          : 'CLINICAL QUIZ COMPLETE',
      accentLabel: 'Clinical Quiz',
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121C2E),
        foregroundColor: Colors.white,
        title: Text('Clinical Quiz ${_index + 1}/${_items.length}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LinearProgressIndicator(
            value: (_index + (_itemDone ? 1 : 0)) / _items.length,
            backgroundColor: Colors.white12,
            color: t.accent,
            minHeight: 4,
          ),
          Expanded(
            child: _current.kind == _QuizKind.mcq
                ? _buildMcq()
                : _buildDiagnose(),
          ),
          if (_itemDone)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(backgroundColor: t.accent),
                child: Text(
                  _index >= _items.length - 1 ? 'SEE CLINICAL SCORE' : 'NEXT',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF04110C),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMcq() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'WRITTEN · CLINICAL',
          style: TextStyle(
            color: t.accent,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _current.prompt,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        ...List<Widget>.generate(_current.options.length, (int i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: _itemDone ? null : () => _answerMcq(i),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: _itemDone && i == _current.correctIndex
                      ? t.accent
                      : Colors.white24,
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(14),
              ),
              child: Text(_current.options[i]),
            ),
          );
        }),
        if (_coach != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(_coach!, style: const TextStyle(color: Colors.white70)),
        ],
      ],
    );
  }

  Widget _buildDiagnose() {
    final ClinicalVivaCase c = _current.caseRef!;
    final ScienceDiagram? diagram =
        ScienceDiagramCatalog.diagramById(c.diagramId);
    if (diagram == null) {
      return const Center(child: Text('Diagram missing'));
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1020),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF472B6).withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '3D CLINICAL VIVA · ${c.title}',
                  style: const TextStyle(
                    color: Color(0xFFF472B6),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.patientLine,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _boneOk
                      ? c.vivaPrompt
                      : 'Rotate to ${c.requiredViewLabel.toUpperCase()}, then tap the implicated structure.',
                  style: TextStyle(
                    color: _onRequired(c) ? t.accent : Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  _viewLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        if (_boneOk && !_itemDone)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: List<Widget>.generate(c.vivaOptions.length, (int i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: OutlinedButton(
                    onPressed: () => _answerViva(i),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: _vivaChoice == i ? t.accent : Colors.white24,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(c.vivaOptions[i], style: const TextStyle(fontSize: 12.5)),
                  ),
                );
              }),
            ),
          ),
        if (_coach != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(_coach!, style: const TextStyle(color: Colors.white70)),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1624),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.accent.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: GestureDetector(
                  onPanUpdate: (DragUpdateDetails d) {
                    setState(() {
                      _yaw += d.delta.dx * 0.012;
                      _pitch = (_pitch + d.delta.dy * 0.008).clamp(-0.45, 0.45);
                    });
                  },
                  child: InteractiveViewer(
                    minScale: 0.6,
                    maxScale: 4,
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(_yaw)
                          ..rotateX(_pitch),
                        child: AspectRatio(
                          aspectRatio: 1 / diagram.aspectRatio,
                          child: AnatomyAssetCanvas(
                            diagram: diagram,
                            highlightRegionId: _feedbackId ??
                                (_boneOk ? c.diagnoseTargetId : null),
                            showOverlays: true,
                            dimNonHighlighted: _feedbackId != null || _boneOk,
                            feedbackRegionId: _feedbackId,
                            feedbackCorrect: _feedbackCorrect,
                            pulse: !_boneOk,
                            onRegionTap: _tapRegion,
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
      ],
    );
  }
}
