import '../vu_v2_lab_models.dart';
import 'vu_v2_school_lab_identity.dart';

/// Rubric + notebook-aware mentoring — what makes a lab feel worth paying for.
class VuV2LabDebrief {
  const VuV2LabDebrief({
    required this.observation,
    required this.causality,
    required this.judgment,
    required this.protocol,
    required this.headline,
    required this.paragraph,
    required this.xpAward,
  });

  final int observation; // 0–4
  final int causality;
  final int judgment;
  final int protocol;
  final String headline;
  final String paragraph;
  final int xpAward;

  int get total => observation + causality + judgment + protocol;
}

abstract final class VuV2LabMentorEngine {
  static String reply({
    required String question,
    required String notes,
    required VuV2LabExperiment exp,
    required VuV2SchoolLabIdentity identity,
    required List<String> consoleLog,
    required int interactionCount,
  }) {
    final String q = question.trim().toLowerCase();
    final String notesL = notes.toLowerCase();
    final String snippet = _noteSnippet(notes);

    if (interactionCount < 1) {
      return 'Run the apparatus at least once before we theorize. '
          'I coach from evidence — not from an empty console.';
    }

    if (q.contains('grade') || q.contains('score') || q.contains('pass')) {
      return 'I grade on four things: observation quality, causal reasoning, '
          'judgment under uncertainty, and protocol discipline. '
          'Your notebook so far: ${snippet.isEmpty ? "still thin — write what YOU saw." : '"$snippet"'}';
    }

    if (q.contains('hint') || q.contains('stuck') || q.contains('help')) {
      final String obj = exp.objectives.isNotEmpty
          ? exp.objectives.first
          : 'the station objective';
      return 'Hint (not the answer): focus on "$obj". '
          'Change one variable, log before/after, then ask me what it implies.';
    }

    if (q.contains('why') || q.contains('how') || q.contains('because')) {
      if (notesL.contains('because') ||
          notesL.contains('therefore') ||
          notesL.contains('implies') ||
          notesL.contains('means')) {
        return 'I see causal language in your notes ("$snippet"). Good. '
            'Push one step further: name the mechanism, not just the outcome.';
      }
      return 'You asked why/how — your notebook does not yet argue a cause. '
          'Add one sentence: "When I changed X, Y happened, which suggests Z."';
    }

    if (q.contains('safe') ||
        q.contains('error') ||
        q.contains('risk') ||
        q.contains('wrong')) {
      return switch (identity.school) {
        VuV2LabSchool.nursing =>
          'Clinical safety: reassess after every intervention. '
          'If vitals worsen, escalate — do not double-down on a weak plan.',
        VuV2LabSchool.chemistry =>
          'Name one systematic error (calibration, endpoint overshoot) and one random error. '
          'Interns who skip error talk fail lab meeting.',
        VuV2LabSchool.physics =>
          'Error sources: reaction time, air resistance assumptions, meter resolution. '
          'Put the dominant one in your notebook.',
        _ =>
          'Risk literacy: what could make this conclusion wrong? Write that threat in the notebook.',
      };
    }

    if (consoleLog.isNotEmpty &&
        (q.contains('what') || q.contains('see') || q.contains('happen'))) {
      final String last = consoleLog.last;
      return 'Last apparatus event: "$last". '
          'Quote that in your notebook and add what it implies for '
          '${exp.objectives.isNotEmpty ? exp.objectives.first : "the objective"}.';
    }

    if (snippet.isNotEmpty) {
      return 'Looking at your notes ("$snippet") — be more specific. '
          'Replace adjectives with numbers, timings, or choices you actually made on this bench.';
    }

    return 'Relate your question to this station\'s objectives: '
        '${exp.objectives.take(2).join('; ')}. '
        'I will not spoon-feed — I will pressure-test your evidence.';
  }

  static VuV2LabDebrief score({
    required String notes,
    required String notesSeed,
    required VuV2LabExperiment exp,
    required VuV2SchoolLabIdentity identity,
    required int interactionCount,
    required bool quizCorrect,
    required bool quizDone,
    required List<String> consoleLog,
  }) {
    final String n = notes.trim();
    final String nl = n.toLowerCase();
    final String seed = notesSeed.trim();

    int observation = 0;
    if (n.length >= 60) observation++;
    if (n.length >= 120) observation++;
    if (n != seed && n.length > seed.length + 20) observation++;
    if (RegExp(r'\d').hasMatch(n)) observation++;
    observation = observation.clamp(0, 4);

    int causality = 0;
    for (final String k in <String>[
      'because',
      'therefore',
      'implies',
      'suggests',
      'means',
      'when i',
      'after',
      'before',
      'so ',
    ]) {
      if (nl.contains(k)) {
        causality++;
        if (causality >= 2) break;
      }
    }
    if (interactionCount >= 2) causality++;
    if (consoleLog.length >= 2) causality++;
    causality = causality.clamp(0, 4);

    int judgment = 0;
    if (quizDone) judgment += quizCorrect ? 2 : 1;
    if (interactionCount >= 3) judgment++;
    if (nl.contains('however') ||
        nl.contains('risk') ||
        nl.contains('limit') ||
        nl.contains('uncertain') ||
        nl.contains('reassess') ||
        nl.contains('next')) {
      judgment++;
    }
    judgment = judgment.clamp(0, 4);

    int protocol = 0;
    if (interactionCount >= 2) protocol += 2;
    if (n.length >= 80) protocol++;
    if (quizDone) protocol++;
    protocol = protocol.clamp(0, 4);

    final int total = observation + causality + judgment + protocol;
    final int xp = 35 + (total * 4) + (quizCorrect ? 10 : 0);

    String headline;
    if (total >= 13) {
      headline = 'Lab meeting ready · strong internship signal';
    } else if (total >= 9) {
      headline = 'Solid bench pass · tighten the causal story';
    } else if (total >= 6) {
      headline = 'Provisional pass · mentor wants more evidence';
    } else {
      headline = 'Incomplete scientific habit · redo with sharper notes';
    }

    final String snippet = _noteSnippet(n);
    final String schoolBite = switch (identity.school) {
      VuV2LabSchool.nursing =>
        'Clinical bar: assessment → action → reassessment. Judges notice judgment, not memorization.',
      VuV2LabSchool.physics =>
        'Physics bar: isolate one variable, compare trials, defend the trend.',
      VuV2LabSchool.chemistry =>
        'Chem bar: observations + stoichiometry intuition + error honesty.',
      VuV2LabSchool.biology =>
        'Bio bar: structure–function claims need what you actually clicked/saw.',
      VuV2LabSchool.psychology =>
        'Psych bar: method clarity and bias awareness beat vibes.',
      VuV2LabSchool.mathematics =>
        'Math bar: parameter → graph → verbal explanation teammates can reuse.',
      _ => 'Facility bar: evidence before conclusion.',
    };

    final String paragraph =
        'Rubric $total/16 — Observation $observation · Causality $causality · '
        'Judgment $judgment · Protocol $protocol.\n\n'
        '${snippet.isEmpty ? "Notebook lacked a quotable claim." : "Mentor quote from your log: \"$snippet\""}\n\n'
        '$schoolBite\n'
        'Apparatus events logged: $interactionCount. '
        '${quizDone ? (quizCorrect ? "Competency check: correct." : "Competency check: missed — explanation still counts.") : "Competency check incomplete."}';

    return VuV2LabDebrief(
      observation: observation,
      causality: causality,
      judgment: judgment,
      protocol: protocol,
      headline: headline,
      paragraph: paragraph,
      xpAward: xp,
    );
  }

  static String _noteSnippet(String notes) {
    final String t = notes.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return '';
    if (t.length <= 90) return t;
    return '${t.substring(0, 87)}…';
  }
}
