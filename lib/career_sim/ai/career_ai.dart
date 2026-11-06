import '../../services/openai_service.dart';

/// The roles AI plays in the simulator. AI explains and coaches; it never
/// grades and never supplies answers. Every grade comes from a published rule.
enum CareerAiRole {
  lecturer,
  interviewer,
  supervisor;

  String get label => switch (this) {
        CareerAiRole.lecturer => 'AI lecturer',
        CareerAiRole.interviewer => 'AI interview coach',
        CareerAiRole.supervisor => 'AI supervisor guidance',
      };
}

abstract class CareerAi {
  Future<String> ask({required CareerAiRole role, required String context, required String question});

  /// Works out which of [options] (id → description) the student's words
  /// mean, or null when none fits. Used only to *understand* phrasing; the
  /// rules still decide every fact, reply and score.
  Future<String?> classify({required String text, required Map<String, String> options, required String context});

  /// A short, natural spoken line in a character's voice that says the same
  /// thing as [scripted] (same facts, nothing added). Null keeps the script.
  Future<String?> voice({required String character, required String scripted, required String heard});
}

/// Parses an AI classification reply: the first option id it names exactly.
String? pickOption(String reply, Iterable<String> ids) {
  final String r = reply.toLowerCase();
  if (RegExp(r'\bnone\b').hasMatch(r) && !ids.any((String id) => RegExp('\\b${RegExp.escape(id.toLowerCase())}\\b').hasMatch(r))) return null;
  String? best;
  int at = 1 << 30;
  for (final String id in ids) {
    final RegExpMatch? m = RegExp('(?<![a-z0-9_])${RegExp.escape(id.toLowerCase())}(?![a-z0-9_])').firstMatch(r);
    if (m != null && m.start < at) {
      at = m.start;
      best = id;
    }
  }
  return best;
}

/// Rejects a voiced line that adds numbers or drugs not in the script, is too
/// long, or is empty, so AI wording can never change clinical facts.
String? safeVoice(String? line, String scripted) {
  if (line == null) return null;
  final String l = line.trim().replaceAll(RegExp(r'^["“]|["”]$'), '');
  if (l.isEmpty || l.length > scripted.length * 2 + 80) return null;
  final Set<String> nums = RegExp(r'\d+(?:[.,]\d+)?').allMatches(scripted).map((Match m) => m[0]!).toSet();
  for (final Match m in RegExp(r'\d+(?:[.,]\d+)?').allMatches(l)) {
    if (!nums.contains(m[0])) return null;
  }
  return l;
}

class OpenAiCareerAi implements CareerAi {
  OpenAiCareerAi(this._service);
  final OpenAiService _service;

  static String rolePrompt(CareerAiRole role) {
    const String rules = 'Rules you must follow: never give the answer, the final number, working code, the correct '
        'option or a model answer for any task. Do not grade the student. Explain concepts, ask guiding questions, point '
        'to the relevant method or principle, and suggest how to check their own work. Keep it under 200 words.';
    return switch (role) {
      CareerAiRole.lecturer => 'You are a university lecturer in a professional training simulator. $rules',
      CareerAiRole.interviewer =>
        'You are an interview coach reviewing a finished interview. Comment on structure, clarity and how to prepare. '
            'Your comments are not part of the score. $rules',
      CareerAiRole.supervisor =>
        'You are a workplace supervisor helping a junior colleague plan their approach to an assignment. $rules',
    };
  }

  @override
  Future<String> ask({required CareerAiRole role, required String context, required String question}) {
    return _service.tutorReply(
      const <Map<String, dynamic>>[],
      question,
      courseContext: '${rolePrompt(role)}\n\n$context',
    );
  }

  static const Duration _timeout = Duration(seconds: 8);

  @override
  Future<String?> classify({required String text, required Map<String, String> options, required String context}) async {
    if (options.isEmpty || text.trim().isEmpty) return null;
    final String list = options.entries.map((MapEntry<String, String> e) => '- ${e.key}: ${e.value}').join('\n');
    final String prompt = 'You map what a student said to ONE option id. $context\n'
        'Options:\n$list\n- none: none of these\n'
        'Student said: "${text.replaceAll('"', "'")}"\n'
        'Reply with only the option id.';
    try {
      final String r = await _service
          .tutorReply(const <Map<String, dynamic>>[], prompt, courseContext: 'You are a strict intent classifier. Output one id only.')
          .timeout(_timeout);
      return pickOption(r, options.keys);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> voice({required String character, required String scripted, required String heard}) async {
    if (scripted.trim().isEmpty) return null;
    final String prompt = 'Rephrase this line as $character would say it out loud, replying to "${heard.replaceAll('"', "'")}". '
        'Keep exactly the same facts. Do not add symptoms, numbers, medicines, diagnoses or advice. One or two short sentences.\n'
        'Line: "${scripted.replaceAll('"', "'")}"\nReply with the line only.';
    try {
      final String r = await _service
          .tutorReply(const <Map<String, dynamic>>[], prompt, courseContext: 'You voice characters in a training simulation. Never change facts.')
          .timeout(_timeout);
      return safeVoice(r, scripted);
    } catch (_) {
      return null;
    }
  }
}
