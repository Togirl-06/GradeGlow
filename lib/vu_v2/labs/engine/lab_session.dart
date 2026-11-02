import 'package:flutter/foundation.dart';

import '../university_lab_result.dart';
import 'lab_blueprint.dart';

class LabEvent {
  LabEvent(this.id, {this.data, DateTime? at}) : at = at ?? DateTime.now();
  final String id;
  final Object? data;
  final DateTime at;
}

class LabSession extends ChangeNotifier {
  LabSession(this.blueprint) : startedAt = DateTime.now() {
    layersOn.addAll(blueprint.layers.take(2));
    professor = level == 1
        ? 'Guided laboratory. Use the workspace — I will prompt the next move.'
        : level == 2
            ? 'Assisted laboratory. Hints cost score. The model will not quiz you first.'
            : level == 3
                ? 'Independent laboratory. You have the problem, not the recipe.'
                : 'Professional simulation. Decide what this environment requires.';
  }

  final LabBlueprint blueprint;
  final DateTime startedAt;
  final List<LabEvent> events = <LabEvent>[];
  final Map<String, dynamic> vars = <String, dynamic>{};
  final Set<String> layersOn = <String>{};
  final List<String> notebook = <String>[];
  String professor = '';
  String inspector = 'Interact with the academic object in the center.';
  int hintsUsed = 0;
  bool paused = false;
  String? pauseWhy;
  bool briefed = false;

  int get level => blueprint.level;

  T? getv<T>(String key) => vars[key] as T?;

  void setVar(String key, dynamic value, {String? inspectorText}) {
    vars[key] = value;
    if (inspectorText != null) inspector = inspectorText;
    notifyListeners();
  }

  void toggleLayer(String name) {
    if (layersOn.contains(name)) {
      layersOn.remove(name);
    } else {
      layersOn.add(name);
    }
    act('layer', data: name);
  }

  void act(
    String id, {
    Object? data,
    String? say,
    String? inspect,
    bool pause = false,
  }) {
    events.add(LabEvent(id, data: data));
    if (say != null) professor = say;
    if (inspect != null) inspector = inspect;
    if (pause) {
      paused = true;
      pauseWhy = say;
    }
    _coach(id);
    notifyListeners();
  }

  void note(String line) {
    notebook.add(line);
    act('notebook', data: line);
  }

  void hint() {
    hintsUsed++;
    final List<String> h = blueprint.hints;
    final String pick = h[(hintsUsed - 1).clamp(0, h.length - 1)];
    if (level >= 4 && hintsUsed <= 2) {
      professor = 'Look at the environment first. $pick';
    } else if (level >= 3 && hintsUsed == 1) {
      professor = 'One direction: $pick';
    } else {
      professor = pick;
    }
    events.add(LabEvent('hint', data: hintsUsed));
    notifyListeners();
  }

  void askProfessor(String question) {
    final List<String> ids = events.map((LabEvent e) => e.id).toList();
    final bool clinical = blueprint.discipline == LabDiscipline.nursing ||
        blueprint.discipline == LabDiscipline.medicine;
    late final String reply;
    if (ids.contains('overshot') || ids.contains('drop_too_fast')) {
      reply =
          'You selected the correct reagent, but you added it too quickly near the endpoint. That is why the final volume is high.';
    } else if (ids.contains('obj40_early')) {
      reply =
          'You climbed to 40× before a sharp low-power image. Start at 4×, coarse, then fine, then step up.';
    } else if (ids.contains('uncalibrated')) {
      reply = 'You took numbers before zeroing. Those observations are marked unreliable.';
    } else if (clinical && !ids.contains('vitals')) {
      reply =
          'You still have not put numbers on this patient. Trivia will not save the next ten minutes.';
    } else if (question.toLowerCase().contains('fail') ||
        question.toLowerCase().contains('why')) {
      reply =
          'Your last actions: ${ids.reversed.take(6).join(' → ')}. The environment responded to those.';
    } else {
      reply =
          'I am watching the workspace, not a quiz key. Point at a structure or instrument and try again.';
    }
    professor = reply;
    events.add(LabEvent('ask', data: question));
    notifyListeners();
  }

  void clearPause() {
    paused = false;
    pauseWhy = null;
    professor = 'The record still holds that decision. Continue.';
    notifyListeners();
  }

  void _coach(String id) {
    switch (id) {
      case 'obj40_early':
        professor =
            'You are using the 40× objective before a clear low-power image. Start with 4× and work upward.';
        break;
      case 'overshot':
        professor =
            'You passed the endpoint. Your trial is still recorded, but you should repeat the titration.';
        break;
      case 'skip_vitals':
        professor = 'The patient is not a multiple-choice stem. Obtain vitals.';
        break;
      case 'bridge_fail':
        professor =
            'The structure failed where you are red. That member was the load path. Redesign it.';
        break;
      case 'shock':
        professor =
            'The market moved. Moderate clients do not want a freeze; they want an IPS-true rebalance.';
        break;
      default:
        break;
    }
  }

  UniversityLabResult grade({
    required String analysis,
    required String conclusion,
    required String error,
  }) {
    final Set<String> ids = events.map((LabEvent e) => e.id).toSet();
    double knowledge = ids.contains('hypothesize') ||
            ids.contains('claim') ||
            ids.contains('patch') ||
            ids.contains('decide')
        ? 0.8
        : 0.45;
    double procedure = 0.4;
    if (ids.contains('focused') ||
        ids.contains('rinsed') ||
        ids.contains('run') ||
        ids.contains('inspect') ||
        ids.contains('allocate')) {
      procedure = 0.75;
    }
    if (ids.contains('obj40_early') || ids.contains('uncalibrated')) {
      procedure -= 0.25;
    }
    double accuracy = 0.5;
    if (ids.contains('trace_complete') ||
        ids.contains('classified_plant') ||
        ids.contains('endpoint_ok') ||
        ids.contains('test_pass') ||
        ids.contains('audit_found') ||
        ids.contains('g_ok')) {
      accuracy = 0.88;
    }
    if (ids.contains('overshot')) accuracy = 0.62;
    double decision = ids.any(
      (String i) =>
          i == 'call' || i == 'decide' || i == 'rebalance' || i == 'redesign',
    )
        ? 0.8
        : 0.5;
    final double reasoning =
        (analysis.length > 40 ? 0.8 : 0.4) * (conclusion.length > 20 ? 1 : 0.7);
    double practice = 0.7;
    if (ids.contains('obj40_early') || ids.contains('skip_vitals')) {
      practice = 0.35;
    }
    final int seconds = DateTime.now().difference(startedAt).inSeconds;
    final double efficiency = seconds < 900 ? 0.8 : 0.6;
    double safety = paused || ids.contains('obj40_early') ? 0.4 : 0.85;
    if (ids.contains('overshot')) safety = 0.7;

    knowledge = knowledge.clamp(0.1, 1);
    procedure = procedure.clamp(0.1, 1);
    accuracy = accuracy.clamp(0.1, 1);
    decision = decision.clamp(0.1, 1);
    practice = practice.clamp(0.1, 1);
    safety = safety.clamp(0.1, 1);
    final double hintPen = (hintsUsed * 0.04).clamp(0, 0.2);
    final double overall = ((knowledge +
                    procedure +
                    accuracy +
                    decision +
                    reasoning +
                    practice +
                    efficiency +
                    safety) /
                8 -
            hintPen)
        .clamp(0.05, 1.0);

    vars['scores'] = <String, int>{
      'Knowledge': (knowledge * 100).round(),
      'Procedure': (procedure * 100).round(),
      'Accuracy': (accuracy * 100).round(),
      'Decision making': (decision * 100).round(),
      'Reasoning': (reasoning * 100).round(),
      'Professional practice': (practice * 100).round(),
      'Efficiency': (efficiency * 100).round(),
      'Safety': (safety * 100).round(),
    };

    final List<String> notes = <String>[
      'Knowledge ${(knowledge * 100).round()} · Procedure ${(procedure * 100).round()} · Accuracy ${(accuracy * 100).round()} · Decision ${(decision * 100).round()} · Reasoning ${(reasoning * 100).round()}',
      if (error.trim().isNotEmpty) 'You named this error: $error',
      if (ids.contains('overshot'))
        'Your measurement is outside the expected experimental range. An overshot titre was kept — that is honest, and it still biases M. Repeat the trial.',
      if (ids.contains('obj40_early'))
        'Microscope procedure was inverted. That is a lab skill miss, not a vocabulary miss.',
    ];

    return UniversityLabResult(
      accuracy: overall,
      identifyCorrect: ids.length,
      identifyAttempts: events.length.clamp(1, 99),
      viewsVisited: layersOn.length + 1,
      labelDrillComplete: ids.contains('pin') || ids.contains('trace_complete'),
      coachingNotes: notes,
      xpEarned: (overall * 100).round(),
      secondsElapsed: seconds,
      clinicalSolved: overall >= 0.75,
      clinicalReasoningScore: reasoning.clamp(0.0, 1.0),
      hintsUsed: hintsUsed,
      recommendedReview: overall < 0.6 ? blueprint.title : null,
    );
  }
}
