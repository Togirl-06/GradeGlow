/// 3D anatomy identification tasks. The model (web/anatomy_3d) and the names
/// below are generated from one source: tool/anatomy3d/build.py.
library;

import '../../model/career_models.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import 'anatomy3d_data.g.dart';

export 'anatomy3d_data.g.dart';

class AnatomyStructure {
  const AnatomyStructure(this.id, this.name, this.system, this.description, {this.region = '', this.side = ''});
  final String id;
  final String name;
  final String system;
  final String description;
  final String region;

  /// 'left', 'right' or '' — the patient's side.
  final String side;
}

AnatomyStructure? structureById(String id) {
  for (final AnatomyStructure s in anatomyStructures) {
    if (s.id == id) return s;
  }
  return null;
}

/// One identification: a prompt and the structure(s) that answer it.
class AnatomyQuestion {
  const AnatomyQuestion(this.prompt, this.answers, {this.explain = ''});
  final String prompt;

  /// Accepted structure ids (e.g. either kidney for "a kidney").
  final List<String> answers;
  final String explain;
}

class Anatomy3DStep extends LabStep {
  const Anatomy3DStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.questions,
    this.systems,
    super.skills,
    super.passMark = 75,
  });
  final List<AnatomyQuestion> questions;

  /// Layers shown at the start (null = all).
  final List<String>? systems;

  @override
  String get kind => '3D anatomy';
}

abstract final class Anatomy3DGrader {
  /// [picks]: question index → structure id chosen.
  static TaskResult grade(Anatomy3DStep s, Map<int, String> picks) {
    if (picks.length < s.questions.length) throw LabGradingException('Identify every structure first (${picks.length} of ${s.questions.length} done).');
    int ok = 0;
    final List<String> fb = <String>[];
    for (int i = 0; i < s.questions.length; i++) {
      final AnatomyQuestion q = s.questions[i];
      final String got = picks[i]!;
      final String gotName = structureById(got)?.name ?? got;
      if (q.answers.contains(got)) {
        ok++;
        fb.add('✓ ${q.prompt}: $gotName.');
      } else {
        final String right = q.answers.map((String a) => structureById(a)?.name ?? a).join(' or ');
        final AnatomyStructure? g = structureById(got);
        final AnatomyStructure? r = structureById(q.answers.first);
        final String hint = g != null && r != null && g.side.isNotEmpty && r.side.isNotEmpty && g.side != r.side && g.name.replaceFirst(RegExp(r'^(Left|Right) '), '') == r.name.replaceFirst(RegExp(r'^(Left|Right) '), '')
            ? ' Check the side: the patient’s left is on your right when you face them.'
            : '';
        fb.add('✗ ${q.prompt}: you chose $gotName; it is the $right.$hint${q.explain.isEmpty ? '' : ' ${q.explain}'}');
      }
    }
    return gradeResult(s, ok / s.questions.length, fb, breakdown: <String, int>{'correct': ok, 'items': s.questions.length});
  }
}
