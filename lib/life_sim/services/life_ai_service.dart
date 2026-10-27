import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../config/openai_endpoints.dart';
import '../interview/interview_judge.dart';
import '../workplace/work_task.dart';
import '../world/world_model.dart';

const String _model = 'gpt-4o-mini';

Future<String> _chat(List<Map<String, String>> messages, {bool json = false, double temperature = 0.5, int maxTokens = 400}) async {
  if (!AppConfig.hasOpenAi) throw StateError('AI is not configured.');
  final Map<String, Object?> body = <String, Object?>{
    'model': _model,
    'messages': messages,
    'temperature': temperature,
    'max_tokens': maxTokens,
    if (json) 'response_format': <String, String>{'type': 'json_object'},
  };
  final http.Response r = await http
      .post(Uri.parse(OpenAiEndpoints.chatCompletions), headers: OpenAiEndpoints.jsonHeaders(), body: jsonEncode(body))
      .timeout(const Duration(seconds: 25));
  if (r.statusCode != 200) throw StateError('AI error ${r.statusCode}');
  final Map<String, dynamic> d = jsonDecode(r.body) as Map<String, dynamic>;
  final List<dynamic> choices = d['choices'] as List<dynamic>? ?? <dynamic>[];
  if (choices.isEmpty) throw StateError('Empty AI response');
  final Object? msg = (choices.first as Map)['message'];
  return (msg is Map ? msg['content'] : null)?.toString() ?? '';
}

/// Interview judge: the deterministic judge sets the numbers; the AI writes the
/// coaching words and may nudge each score by at most ±2 (so AI can never
/// swing hiring on its own). Falls back to the deterministic judge on any error.
class AiInterviewJudge implements InterviewJudge {
  AiInterviewJudge({InterviewJudge fallback = const HeuristicInterviewJudge()}) : _fallback = fallback;
  final InterviewJudge _fallback;

  @override
  Future<AnswerEvaluation> evaluate(InterviewContext ctx) async {
    final AnswerEvaluation base = await _fallback.evaluate(ctx);
    if (!AppConfig.hasOpenAi || ctx.answer.trim().length < 12) return base;
    try {
      final String raw = await _chat(<Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': 'You are ${ctx.employer.interviewer.name}, ${ctx.employer.interviewer.title} at ${ctx.employer.name}, '
              'interviewing a candidate for ${ctx.career.title}. Style: ${ctx.employer.interviewer.style}. '
              'Return JSON: {"scores":{"relevance":0-10,"communication":0-10,"confidence":0-10,"problem_solving":0-10,'
              '"professionalism":0-10,"clarity":0-10,"examples":0-10},"comment":"one coaching sentence to the candidate",'
              '"reaction":"one short in-character sentence you say aloud"}. Be fair and concrete.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Question: ${ctx.questionText}\nAnswer: ${ctx.answer}\n${ctx.history.isEmpty ? '' : 'Earlier:\n${ctx.history.join('\n')}'}',
        },
      ], json: true, temperature: 0.4);
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, dynamic> s = (m['scores'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final Map<String, double> scores = <String, double>{};
      for (final String k in InterviewDims.all) {
        final double b = base.scores[k] ?? 0;
        final double ai = (s[k] as num?)?.toDouble() ?? b;
        scores[k] = ai.clamp(b - 2, b + 2).clamp(0, 10).toDouble();
      }
      final String comment = (m['comment'] as String?)?.trim() ?? '';
      final String reaction = (m['reaction'] as String?)?.trim() ?? '';
      return AnswerEvaluation(
        scores: scores,
        comment: comment.isEmpty ? base.comment : comment,
        reaction: reaction.isEmpty ? base.reaction : reaction,
        kind: base.kind,
        followUp: base.followUp,
      );
    } catch (_) {
      return base;
    }
  }
}

/// Work-text judge: rubric score is authoritative (AI may adjust ±0.15).
class AiWorkTextJudge implements WorkTextJudge {
  @override
  Future<StageResult> gradeText({required WorkScenario scenario, required WorkStage stage, required String text}) async {
    final StageResult base = WorkGrader.gradeText(stage, text);
    if (!AppConfig.hasOpenAi || text.trim().length < 12) return base;
    try {
      final String raw = await _chat(<Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': 'You mark a workplace training answer (educational simulation, fictional setting). '
              'Return JSON {"score":0-1,"feedback":"two sentences, constructive"}. Rubric: '
              '${stage.rubric.map((RubricItem r) => r.label).join('; ')}.',
        },
        <String, String>{'role': 'user', 'content': 'Task: ${scenario.title}\nPrompt: ${stage.prompt}\nAnswer: $text'},
      ], json: true, temperature: 0.2);
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      final double ai = (m['score'] as num?)?.toDouble() ?? base.score;
      final double score = ai.clamp(base.score - 0.15, base.score + 0.15).clamp(0, 1).toDouble();
      final String fb = (m['feedback'] as String?)?.trim() ?? '';
      return StageResult(score: score, feedback: fb.isEmpty ? base.feedback : '$fb\n${base.feedback}', details: base.details);
    } catch (_) {
      return base;
    }
  }
}

/// Talking to NPCs. AI gives natural replies; offline uses their scripted lines.
class NpcChatService {
  NpcChatService();
  final Map<String, int> _cursor = <String, int>{};

  Future<String> reply(NpcDef npc, String userText, {List<String> history = const <String>[], String context = ''}) async {
    if (AppConfig.hasOpenAi) {
      try {
        final String out = await _chat(<Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content': 'You are ${npc.name}, ${npc.role} in the GradeGlow life simulation city. ${npc.persona} '
                'Reply in character in 1-3 short sentences. Never give real medical, legal or financial advice; '
                'this is an educational simulation. $context',
          },
          for (final String h in history.take(8)) <String, String>{'role': 'user', 'content': h},
          <String, String>{'role': 'user', 'content': userText},
        ], temperature: 0.8, maxTokens: 160);
        if (out.trim().isNotEmpty) return out.trim();
      } catch (_) {}
    }
    return offlineReply(npc, userText);
  }

  String offlineReply(NpcDef npc, String userText) {
    final int i = (_cursor[npc.id] ?? 0);
    _cursor[npc.id] = i + 1;
    final String t = userText.toLowerCase();
    if (t.contains('job') || t.contains('work') || t.contains('career')) {
      return npc.lines.firstWhere((String l) => l.toLowerCase().contains('job') || l.toLowerCase().contains('work'), orElse: () => npc.lines[i % npc.lines.length]);
    }
    return npc.lines[i % npc.lines.length];
  }

  String greeting(NpcDef npc) => 'Hi, I\'m ${npc.name}, the ${npc.role.toLowerCase()}.';
}
