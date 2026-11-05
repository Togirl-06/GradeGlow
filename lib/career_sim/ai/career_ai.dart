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
}
