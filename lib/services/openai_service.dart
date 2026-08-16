import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/ai_json.dart';
import '../data/topic_profile_database.dart';
import '../models/topic_profile.dart';
import '../utils/topic_scope_validator.dart';
import '../utils/api_error_messages.dart';
import '../utils/document_text_chunker.dart';
import '../models/quiz_question.dart';
import '../models/physics/physics_program.dart';
import '../models/leetcode_problem.dart';
import '../models/law_simulation.dart';
import '../models/practice_lab.dart';
import '../models/ai_practice_mode.dart';
import '../data/physics/physics_chapter_navigation.dart';
import '../data/physics/physics_textbook_chapter_engine.dart';
import '../data/physics/physics_topic_knowledge_engine.dart';
import '../data/ai_practice_catalog.dart';
import 'ai_professor_prompts.dart';

class OpenAiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String freeModel = 'gpt-4o-mini';
  static const String premiumModel = 'gpt-4o';

  Future<String> tutorReply(
    List<Map<String, dynamic>> history,
    String userMessage, {
    String? courseContext,
    List<String> imageFilePaths = const <String>[],
    bool premium = false,
  }) async {
    _requireKey();

    final String contextBlock = courseContext != null && courseContext.trim().isNotEmpty
        ? '\n\nCurrent study context:\n$courseContext'
        : '';

    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You are a friendly university tutor. Give clear, structured answers that are easy to scan — like a walkthrough script.\n\n'
            'FORMATTING RULES (always follow):\n'
            '1. Use ## for main sections (e.g. "## Integration by parts — Overview").\n'
            '2. Use ### for sub-steps when breaking a topic into parts.\n'
            '3. Use bullet lists (- item) for steps, key points, or "show this" instructions.\n'
            '4. Start bullets with **Bold label** when naming a step, then explain briefly.\n'
            '5. Put class names, functions, and short code in backticks: `AppState`, `notifyListeners()`.\n'
            '6. Put full runnable code in fenced blocks with a language tag (```python).\n'
            '7. Use > blockquotes for plain-language script lines the student can read aloud to understand "why".\n'
            '8. Keep paragraphs short. Prefer lists over walls of text.\n\n'
            'EXAMPLE SHAPE:\n'
            '## Topic — Short label\n\n'
            '### Subtopic name\n\n'
            '- **Key idea**: one sentence summary\n'
            '- **Show `ClassName`**: what to look at and why\n'
            '- **How it works**:\n'
            '  > "Simple spoken explanation in everyday words."\n\n'
            'When the student references "Q3" or "question 2", use numbered questions in context. '
            'If they ask to explain like they are 10, use very simple words and analogies. '
            'When the student sends photos or video frames, describe what you see and help with homework.$contextBlock',
      },
      ...history,
      await _buildUserMessage(userMessage, imageFilePaths),
    ];

    final String content = await _chatDynamic(messages, temperature: 0.7, premium: premium);
    return content.trim();
  }

  Future<Map<String, dynamic>> _buildUserMessage(
    String userMessage,
    List<String> imageFilePaths,
  ) async {
    if (imageFilePaths.isEmpty) {
      return <String, dynamic>{'role': 'user', 'content': userMessage};
    }

    final List<Map<String, dynamic>> parts = <Map<String, dynamic>>[
      <String, dynamic>{'type': 'text', 'text': userMessage},
    ];

    for (final String path in imageFilePaths) {
      final String? dataUrl = await _fileToDataUrl(path);
      if (dataUrl != null) {
        parts.add(<String, dynamic>{
          'type': 'image_url',
          'image_url': <String, dynamic>{'url': dataUrl},
        });
      }
    }

    return <String, dynamic>{'role': 'user', 'content': parts};
  }

  Future<String?> _fileToDataUrl(String path) async {
    try {
      if (path.startsWith('data:')) return path;
      final List<int> bytes;
      if (kIsWeb ||
          path.startsWith('blob:') ||
          path.startsWith('http://') ||
          path.startsWith('https://')) {
        final http.Response response = await http.get(Uri.parse(path));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return null;
        }
        bytes = response.bodyBytes;
      } else {
        bytes = await File(path).readAsBytes();
      }
      final String ext = path.split('.').last.toLowerCase();
      final String mime = switch (ext) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (_) {
      return null;
    }
  }

  static const String _comprehensiveNotesSystemPrompt =
      'You are an expert university note-taker. Your job is to capture EVERY piece of information '
      'from the source material — not a short summary.\n\n'
      'RULES:\n'
      '- Do NOT omit definitions, formulas, theorems, proofs, examples, numbers, dates, names, '
      'steps, comparisons, exceptions, diagrams described in text, or professor tips.\n'
      '- Prefer completeness over brevity. Longer detailed notes are better than short summaries.\n'
      '- Use ## for main topics and ### for subtopics, following the source order.\n'
      '- Use bullet lists with full explanations — not one-word bullets.\n'
      '- Preserve ALL formulas in LaTeX: \$...\$ or \$\$...\$\$\n'
      '- Include worked examples step-by-step when the source has them.\n'
      '- If the source lists N items, include all N with context.\n'
      '- Use > blockquotes for warnings, exam tips, or emphasized points.\n'
      '- Use markdown tables when comparing multiple items.\n\n'
      'Return ONLY JSON: {"summary":"markdown notes","keyPoints":["term1","term2"]}\n'
      'keyPoints: 15-40 important terms/concepts as a quick index (all detail stays in summary).';

  Future<Map<String, dynamic>> summarizeNotes({
    required String title,
    required String contentHint,
  }) async {
    return generateComprehensiveNotes(title: title, extractedText: contentHint);
  }

  /// Exhaustive study notes from extracted document text (chunked when long).
  Future<Map<String, dynamic>> generateComprehensiveNotes({
    required String title,
    required String extractedText,
    bool premium = false,
  }) async {
    _requireKey();

    final List<String> chunks = DocumentTextChunker.chunk(extractedText);
    if (chunks.length == 1) {
      return _generateNotesFromChunk(
        title: title,
        chunkText: chunks.first,
        partIndex: 0,
        partCount: 1,
        premium: premium,
      );
    }

    final List<String> sectionSummaries = <String>[];
    final List<String> allKeyPoints = <String>[];

    for (int i = 0; i < chunks.length; i++) {
      final Map<String, dynamic> part = await _generateNotesFromChunk(
        title: title,
        chunkText: chunks[i],
        partIndex: i,
        partCount: chunks.length,
        premium: premium,
      );
      final String section = _coerceMarkdownField(part['summary'] ?? part['cheatSheet']).trim();
      if (section.isNotEmpty) {
        sectionSummaries.add('## Section ${i + 1} of ${chunks.length}\n\n$section');
      }
      allKeyPoints.addAll(
        (part['keyPoints'] as List<dynamic>? ?? part['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString().trim())
            .where((String point) => point.isNotEmpty),
      );
    }

    final Set<String> uniqueKeyPoints = <String>{};
    final List<String> keyPoints = <String>[];
    for (final String point in allKeyPoints) {
      if (uniqueKeyPoints.add(point)) keyPoints.add(point);
    }

    return <String, dynamic>{
      'summary': sectionSummaries.join('\n\n'),
      'keyPoints': keyPoints,
    };
  }

  Future<Map<String, dynamic>> _generateNotesFromChunk({
    required String title,
    required String chunkText,
    required int partIndex,
    required int partCount,
    bool premium = false,
  }) async {
    final String partLabel = partCount > 1 ? ' (part ${partIndex + 1} of $partCount)' : '';
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{'role': 'system', 'content': _comprehensiveNotesSystemPrompt},
        <String, String>{
          'role': 'user',
          'content':
              'Create exhaustive study notes$partLabel for "$title".\n'
              '${partCount > 1 ? 'Capture every detail from THIS section only.\n' : ''}'
              'Source material:\n\n$chunkText',
        },
      ],
      temperature: 0.25,
      maxTokens: 16384,
      premium: premium,
    );

    return decodeAiJson(content);
  }

  /// Extract all readable text from a slide/photo (for multi-file uploads).
  Future<String> extractTextFromImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
    String fileName = 'slide.jpg',
  }) async {
    _requireKey();

    final String dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    final String content = await _chatDynamic(
      <Map<String, dynamic>>[
        <String, dynamic>{
          'role': 'system',
          'content':
              'Extract ALL readable content from this lecture slide or document photo. '
              'Return plain text only — no JSON, no markdown fences. '
              'Include headings, bullets, formulas (LaTeX ok), labels, chart values, and diagram descriptions.',
        },
        <String, dynamic>{
          'role': 'user',
          'content': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'text',
              'text': 'Extract every piece of text and visual information from "$fileName".',
            },
            <String, dynamic>{
              'type': 'image_url',
              'image_url': <String, dynamic>{'url': dataUrl, 'detail': 'high'},
            },
          ],
        },
      ],
      temperature: 0.1,
      maxTokens: 8000,
    );

    return content.trim();
  }

  /// Vision-based exhaustive notes from slide/photo uploads.
  Future<Map<String, dynamic>> analyzeDocumentFromImage({
    required String title,
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    _requireKey();

    final String dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    final String content = await _chatDynamic(
      <Map<String, dynamic>>[
        <String, dynamic>{'role': 'system', 'content': _comprehensiveNotesSystemPrompt},
        <String, dynamic>{
          'role': 'user',
          'content': <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'text',
              'text':
                  'Create exhaustive study notes from this lecture slide or document image for "$title". '
                  'Read ALL visible text, formulas, diagrams, labels, charts, and bullet points. '
                  'Describe diagram content in words. Do not skip anything.',
            },
            <String, dynamic>{
              'type': 'image_url',
              'image_url': <String, dynamic>{'url': dataUrl, 'detail': 'high'},
            },
          ],
        },
      ],
      temperature: 0.25,
      maxTokens: 16384,
    );

    return decodeAiJson(content);
  }

  /// Full document analysis: comprehensive notes, then flashcards + quiz.
  Future<Map<String, dynamic>> analyzeDocument({
    required String title,
    required String extractedText,
    int flashcardCount = 20,
    int quizCount = 10,
    bool includeStudyMaterials = false,
    bool premium = false,
  }) async {
    _requireKey();

    final Map<String, dynamic> notes = await generateComprehensiveNotes(
      title: title,
      extractedText: extractedText,
      premium: premium,
    );

    if (!includeStudyMaterials) {
      return <String, dynamic>{
        'summary': _coerceMarkdownField(notes['summary']),
        'keyPoints': notes['keyPoints'] ?? notes['keyConcepts'],
        'flashcards': <dynamic>[],
        'quizQuestions': <dynamic>[],
      };
    }

    final Map<String, dynamic> materials = await generateStudyMaterials(
      title: title,
      summaryText: _coerceMarkdownField(notes['summary']),
      flashcardCount: flashcardCount,
      quizCount: quizCount,
      premium: premium,
    );

    return <String, dynamic>{
      'summary': _coerceMarkdownField(notes['summary']),
      'keyPoints': notes['keyPoints'] ?? notes['keyConcepts'],
      'flashcards': materials['flashcards'],
      'quizQuestions': materials['quizQuestions'],
    };
  }

  static String _coerceMarkdownField(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map) {
      for (final String key in <String>['summary', 'text', 'content', 'cheatSheet', 'notes', 'body']) {
        final dynamic nested = value[key];
        if (nested is String && nested.trim().isNotEmpty) return nested.trim();
      }
      return value.values.whereType<String>().where((String s) => s.trim().isNotEmpty).join('\n\n').trim();
    }
    if (value is List) {
      return value.map((dynamic item) => item.toString()).where((String s) => s.trim().isNotEmpty).join('\n').trim();
    }
    return value.toString().trim();
  }

  /// Flashcards + quiz from existing notes (does not regenerate the notes).
  Future<Map<String, dynamic>> generateStudyMaterials({
    required String title,
    required String summaryText,
    int flashcardCount = 20,
    int quizCount = 10,
    bool premium = false,
  }) async {
    _requireKey();

    if (flashcardCount <= 0 && quizCount <= 0) {
      return <String, dynamic>{
        'flashcards': <dynamic>[],
        'quizQuestions': <dynamic>[],
      };
    }

    final String countsLine = <String>[
      if (flashcardCount > 0) 'exactly $flashcardCount flashcards',
      if (quizCount > 0) 'exactly $quizCount multiple-choice quiz questions',
    ].join(' and ');

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Create study materials from detailed notes. '
              'Return ONLY JSON: {"flashcards":[{"front":"Q","back":"A"}],"quizQuestions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0}]} '
              'Create $countsLine. '
              'Cover the full depth of the notes — definitions, formulas, examples, and edge cases. '
              'Flashcards: clear term/question on front, complete answer on back. '
              'Each quiz question needs 4 options and correctIndex 0-3. '
              'For math, use \$...\$ or \$\$...\$\$ and escape every backslash twice in JSON (e.g. \\\\int, \\\\sin).',
        },
        <String, String>{
          'role': 'user',
          'content': 'Title: $title\n\nNotes:\n$summaryText',
        },
      ],
      temperature: 0.35,
      maxTokens: (flashcardCount * 100 + quizCount * 150).clamp(4000, 16384),
      premium: premium,
    );

    return decodeAiJson(content);
  }

  /// Generate flashcards + quiz from an existing summary.
  Future<Map<String, dynamic>> generateStudyMaterialsFromText({
    required String title,
    required String summaryText,
    int flashcardCount = 20,
    int quizCount = 10,
  }) async {
    return generateStudyMaterials(
      title: title,
      summaryText: summaryText,
      flashcardCount: flashcardCount,
      quizCount: quizCount,
    );
  }

  Future<List<Map<String, String>>> generateFlashcardsFromTopic({
    required String topic,
    int count = 10,
  }) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Create flashcards for a student studying "$topic". '
              'Return ONLY JSON: {"cards":[{"front":"question","back":"short answer"}]} '
              'Create exactly $count cards. Front = question, back = concise answer.',
        },
        <String, String>{
          'role': 'user',
          'content': topic,
        },
      ],
      temperature: 0.4,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['cards'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic e) {
          final Map<String, dynamic> m = e as Map<String, dynamic>;
          return <String, String>{
            'front': m['front'] as String? ?? '',
            'back': m['back'] as String? ?? '',
          };
        })
        .where((Map<String, String> c) => c['front']!.isNotEmpty && c['back']!.isNotEmpty)
        .toList();
  }

  Future<List<QuizQuestion>> generatePracticeExam({
    required String subject,
    required String difficulty,
    required int questionCount,
  }) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Generate a university practice exam. Return ONLY JSON: '
              '{"questions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0}]} '
              'Create exactly $questionCount multiple-choice questions. Difficulty: $difficulty.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Subject: $subject\nDifficulty: $difficulty\nQuestions: $questionCount',
        },
      ],
      temperature: 0.45,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .where((QuizQuestion q) => q.prompt.isNotEmpty && q.options.length >= 2)
        .toList();
  }

  Future<List<Map<String, dynamic>>> generateSubjectStudyPlan({
    required String subject,
    required DateTime examDate,
  }) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Build a day-by-day study plan until the exam. '
              'Return ONLY JSON: {"tasks":[{"date":"ISO8601","title":"topic to study","courseCode":"subject"}]} '
              'One focused topic per day (e.g. Monday: Limits, Tuesday: Derivatives). Start from today.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Exam Date: ${examDate.toIso8601String().split('T').first}\nSubject: $subject\nToday: ${DateTime.now().toIso8601String().split('T').first}',
        },
      ],
      temperature: 0.4,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['tasks'] as List<dynamic>? ?? <dynamic>[];
    return raw.map((dynamic e) => e as Map<String, dynamic>).toList();
  }

  Future<String> solveHomeworkFromImage(String imagePath, {String? prompt}) async {
    _requireKey();

    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You help students with homework. Analyze the problem in the image and explain step by step. '
            'Format: Step 1, Step 2, Step 3… Use clear math notation. Be encouraging.',
      },
      await _buildUserMessage(
        prompt ?? 'Explain how to solve this step by step.',
        <String>[imagePath],
      ),
    ];

    return (await _chatDynamic(messages, temperature: 0.5)).trim();
  }

  Future<List<Map<String, String>>> generateFlashcardPairs({
    required String courseCode,
    required List<String> questionTexts,
    String? answerHint,
  }) async {
    _requireKey();

    final String joined = questionTexts.asMap().entries.map((MapEntry<int, String> e) => 'Q${e.key + 1}: ${e.value}').join('\n');
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Create flashcards from exam/notes content. Return ONLY JSON: '
              '{"cards":[{"front":"question","back":"short answer"}]} '
              'Create one card per item when possible. Keep backs under 200 chars.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Course: $courseCode\n${answerHint ?? ''}\n\nItems:\n$joined',
        },
      ],
      temperature: 0.35,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['cards'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic e) {
          final Map<String, dynamic> m = e as Map<String, dynamic>;
          return <String, String>{
            'front': m['front'] as String? ?? '',
            'back': m['back'] as String? ?? '',
          };
        })
        .where((Map<String, String> c) => c['front']!.isNotEmpty && c['back']!.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> generateStudyPlan({
    required List<Map<String, String>> exams,
  }) async {
    _requireKey();

    final String examList = exams
        .map((Map<String, String> e) {
          final String time = e['time'] ?? '';
          return '${e['courseCode']} ${e['examType']} on ${e['date']}${time.isNotEmpty ? ' at $time' : ''}';
        })
        .join('\n');

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You build realistic study schedules for university students. '
              'Return ONLY JSON: {"tasks":[{"date":"ISO8601","title":"...","courseCode":"..."}]} '
              'Spread tasks from today until each exam with realistic daily study blocks.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Today: ${DateTime.now().toIso8601String().split('T').first}\nExams:\n$examList',
        },
      ],
      temperature: 0.4,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['tasks'] as List<dynamic>? ?? <dynamic>[];
    return raw.map((dynamic e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> parseExamQuestions({
    required String courseCode,
    required String examType,
    required String sourceLabel,
    required String contentHint,
  }) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You split university exams into individual questions. '
              'Return ONLY JSON: {"questions":[{"text":"...","questionType":"MCQ|Short|Long","topics":["topic"]}]} '
              'Extract 3-8 questions. Use LaTeX in text when needed, e.g. \$x^2\$.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseCode\nExam type: $examType\nSource: $sourceLabel\nContent:\n$contentHint',
        },
      ],
      temperature: 0.3,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return raw.map((dynamic e) => e as Map<String, dynamic>).toList();
  }

  Future<List<QuizQuestion>> generateQuiz({required String noteName}) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You generate multiple-choice quiz questions for students. '
              'Return ONLY valid JSON with this shape: '
              '{"questions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0}]} '
              'Create exactly 5 questions. Each question must have 4 options and correctIndex 0-3.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Create a quiz based on study notes titled: $noteName',
        },
      ],
      temperature: 0.4,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .where((QuizQuestion q) => q.prompt.isNotEmpty && q.options.length >= 2)
        .toList();
  }

  Future<String> _chatDynamic(
    List<Map<String, dynamic>> messages, {
    required double temperature,
    int? maxTokens,
    bool premium = false,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'model': premium ? premiumModel : freeModel,
      'messages': messages,
      'temperature': temperature,
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final http.Response response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: <String, String>{
            'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200) {
      final ApiErrorInfo info = ApiErrorMessages.fromOpenAiResponse(response.statusCode, response.body);
      throw Exception('${info.title}: ${info.message}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices = data['choices'] as List<dynamic>? ?? <dynamic>[];
    if (choices.isEmpty || choices.first is! Map) {
      throw Exception('OpenAI returned an empty response.');
    }
    final Object? message = (choices.first as Map)['message'];
    if (message is! Map) {
      throw Exception('OpenAI returned an empty response.');
    }
    final dynamic content = message['content'];
    if (content is String) return content;
    return content?.toString() ?? '';
  }

  Future<String> _chat(
    List<Map<String, String>> messages, {
    required double temperature,
    int? maxTokens,
    bool premium = false,
  }) async {
    return _chatDynamic(
      messages.map((Map<String, String> m) => Map<String, dynamic>.from(m)).toList(),
      temperature: temperature,
      maxTokens: maxTokens,
      premium: premium,
    );
  }

  Stream<String> _chatStreamDynamic(
    List<Map<String, dynamic>> messages, {
    required double temperature,
    int? maxTokens,
    bool premium = false,
  }) async* {
    final Map<String, dynamic> body = <String, dynamic>{
      'model': premium ? premiumModel : freeModel,
      'messages': messages,
      'temperature': temperature,
      'stream': true,
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final http.Request request = http.Request('POST', Uri.parse(_baseUrl));
    request.headers.addAll(<String, String>{
      'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode(body);

    final http.StreamedResponse response = await request.send();
    if (response.statusCode != 200) {
      final String errorBody = await response.stream.bytesToString();
      final ApiErrorInfo info = ApiErrorMessages.fromOpenAiResponse(response.statusCode, errorBody);
      throw Exception('${info.title}: ${info.message}');
    }

    final StringBuffer lineBuffer = StringBuffer();
    await for (final String chunk in response.stream.transform(utf8.decoder)) {
      lineBuffer.write(chunk);
      String pending = lineBuffer.toString();
      int newlineIndex = pending.indexOf('\n');
      while (newlineIndex >= 0) {
        final String line = pending.substring(0, newlineIndex).trim();
        pending = pending.substring(newlineIndex + 1);
        if (line.startsWith('data: ')) {
          final String data = line.substring(6);
          if (data == '[DONE]') return;
          try {
            final Map<String, dynamic> json = jsonDecode(data) as Map<String, dynamic>;
            final List<dynamic> choices = json['choices'] as List<dynamic>? ?? <dynamic>[];
            if (choices.isEmpty) continue;
            final Map<String, dynamic>? delta =
                (choices.first as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
            final String? text = delta?['content'] as String?;
            if (text != null && text.isNotEmpty) yield text;
          } catch (_) {}
        }
        newlineIndex = pending.indexOf('\n');
      }
      lineBuffer
        ..clear()
        ..write(pending);
    }
  }

  Stream<String> _chatStream(
    List<Map<String, String>> messages, {
    required double temperature,
    int? maxTokens,
    bool premium = false,
  }) {
    return _chatStreamDynamic(
      messages.map((Map<String, String> m) => Map<String, dynamic>.from(m)).toList(),
      temperature: temperature,
      maxTokens: maxTokens,
      premium: premium,
    );
  }

  void _requireKey() {
    if (!AppConfig.hasOpenAi) {
      throw Exception(
        'AI is not configured. Run with --dart-define=OPENAI_API_KEY=... '
        'or add OPENAI_API_KEY to your local .env for development.',
      );
    }
  }

  /// Starts a multi-turn Practice Lab simulation with roleplay.
  Future<SimulationStart> startPracticeSimulation({
    required String categoryName,
    required String labTitle,
    required String labSubtitle,
    required String roleplayGuide,
    String? aiRole,
    List<String> studentTasks = const <String>[],
    String difficulty = '',
    String? topicAreaName,
    String? topicName,
    bool premium = false,
    bool liveCharacter = true,
    String? venueGroupId,
  }) async {
    _requireKey();

    final String roleHint = aiRole != null && aiRole.isNotEmpty ? 'Play the role: $aiRole.\n' : '';
    final String tasksHint = studentTasks.isNotEmpty
        ? 'Student tasks to design around: ${studentTasks.join('; ')}.\n'
        : '';
    final String difficultyHint = difficulty.isNotEmpty ? 'Difficulty level: $difficulty.\n' : '';
    final String topicHint = topicName != null && topicAreaName != null
        ? 'Topic area: $topicAreaName. Focus topic: $topicName. Generate a UNIQUE scenario each time — never repeat prior sessions.\n'
        : 'Generate a fresh, unique scenario — never repeat a generic template.\n';
    final String characterHint = liveCharacter
        ? 'The student sees a LIVE animated AI character on screen. Give the character a specific name, '
            'clear personality, and spoken first-person dialogue. Write the openingMessage as natural speech '
            'the character says aloud — emotional, human, and in character. Never narrate in third person.\n'
        : '';

    final String venueFieldsHint = _venueJsonFieldsHint(venueGroupId);

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You create immersive Practice Lab simulations for university students.\n'
              'Return ONLY JSON: {"scenarioTitle":"...","briefing":"markdown setup for the student",'
              '"aiRole":"who you will play (include name)","openingMessage":"your first in-character line"'
              '$venueFieldsHint}.\n'
              'The briefing should include rich clinical, legal, or field context as appropriate.\n'
              'The openingMessage must stay in character. Do not grade the student yet.\n'
              '$characterHint$roleHint$tasksHint$difficultyHint$topicHint'
              'Roleplay guide: $roleplayGuide',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Category: $categoryName\nLab: $labTitle\nFocus: $labSubtitle\n\n'
              'Create a fresh, realistic simulation opening.',
        },
      ],
      temperature: 0.9,
      maxTokens: 2000,
      premium: premium,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final SimulationStart start = SimulationStart.fromJson(json);
    if (start.briefing.isEmpty || start.openingMessage.isEmpty) {
      throw Exception('The AI returned an incomplete simulation. Try again.');
    }
    return start;
  }

  String _venueJsonFieldsHint(String? groupId) {
    return switch (groupId) {
      'health_medical' =>
        ',"contextFields":{"Name":"patient name","Age":"age","Chief Complaint":"...","Medical History":"..."},'
        '"vitals":{"BP":"systolic/diastolic","HR":"bpm","RR":"breaths/min","SpO2":"%","Temp":"°F"}',
      'law_criminal_justice' =>
        ',"contextFields":{"Case":"case name","Charge":"charge","Your Role":"student attorney role","Witness":"witness name"}',
      'science' =>
        ',"contextFields":{"Experiment":"title","Objective":"...","Hypothesis":"..."}',
      'engineering' =>
        ',"contextFields":{"Project":"title","Objective":"...","Constraints":"..."}',
      'business' =>
        ',"contextFields":{"Company":"name","Challenge":"...","Goal":"..."}',
      'psychology_social_sciences' =>
        ',"contextFields":{"Client":"name and age","Concerns":"...","Goal":"..."}',
      _ => ',"contextFields":{"Setting":"...","Your Role":"...","Goal":"..."}',
    };
  }

  /// Continues a simulation — AI responds in character to the student.
  Future<String> continuePracticeSimulation({
    required String categoryName,
    required String labTitle,
    required String roleplayGuide,
    required String scenarioBriefing,
    required String aiRole,
    required List<SimulationMessage> history,
    required String studentMessage,
    bool premium = false,
    bool liveCharacter = true,
  }) async {
    _requireKey();

    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You are running a Practice Lab simulation for $categoryName — $labTitle.\n'
            'You are playing: $aiRole\n'
            '$roleplayGuide\n\n'
            'Scenario briefing for context:\n$scenarioBriefing\n\n'
            '${liveCharacter ? 'You are a LIVE animated character on screen. Reply in first person with natural spoken dialogue, emotion, and personality. ' : ''}'
            'Stay in character. Respond naturally in 1-4 short paragraphs. '
            'Ask follow-up questions when appropriate. Do not break character or grade the student yet.',
      },
    ];

    for (final SimulationMessage turn in history) {
      messages.add(<String, dynamic>{
        'role': turn.isStudent ? 'user' : 'assistant',
        'content': turn.text,
      });
    }

    messages.add(<String, dynamic>{'role': 'user', 'content': studentMessage.trim()});

    final String reply = await _chatDynamic(messages, temperature: 0.75, premium: premium);
    final String trimmed = reply.trim();
    if (trimmed.isEmpty) {
      throw Exception('The AI returned an empty response. Try again.');
    }
    return trimmed;
  }

  /// Generates a batch of unique practice questions for a topic session.
  Future<List<String>> generatePracticeQuestions({
    required String categoryName,
    required String courseName,
    required String unitName,
    required String topicName,
    required String difficulty,
    int count = 12,
    bool premium = false,
    String? topicId,
    String? subjectId,
    String? courseId,
    bool directMathProblems = false,
    String? mathSessionTier,
  }) async {
    _requireKey();

    final TopicProfile profile = TopicProfileDatabase.resolve(
      topicId: topicId ?? '',
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
      courseName: courseName,
      unitName: unitName,
    );
    final String scopeNote = TopicScopeValidator.buildAiScopeBlock(profile);
    final String mathNote = directMathProblems
        ? 'Write direct mathematics problems only (compute, simplify, solve, prove, graph, or explain a formula). '
            'No roleplay, narratives, scenarios, or "you are a student/teacher" framing. '
            'State each problem clearly with the math to do.\n\n'
        : '';
    final String tierNote = switch (mathSessionTier) {
      'exam' =>
        'EXAM MODE: Problems must be significantly harder than homework or quiz. '
            'Use multi-step reasoning, proofs, synthesis across concepts, or challenging computations. '
            'Each question should take meaningful effort to solve.\n\n',
      'quiz' =>
        'QUIZ MODE: Harder than homework — require careful multi-step work, not one-liners.\n\n',
      'homework' =>
        'HOMEWORK MODE: Build fluency with clear, focused problems at the stated difficulty.\n\n',
      _ => difficulty.toLowerCase().contains('exam')
          ? 'EXAM MODE: Problems must be significantly harder than homework or quiz. '
              'Use multi-step reasoning, proofs, synthesis across concepts, or challenging computations.\n\n'
          : '',
    };

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You write university-level practice questions. Return ONLY JSON: '
              '{"questions":["question 1","question 2",...]}. '
              'Each question must test exactly ONE learning objective from the topic scope below. '
              'Never ask about forbidden topics. Discard any draft that belongs to another course or unit. '
              'No numbering prefix. One clear question per string.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Subject: $categoryName\nCourse: $courseName\nUnit: $unitName\n'
              'Topic: $topicName\nDifficulty: $difficulty\n\n'
              '$mathNote'
              '$tierNote'
              '$scopeNote\n'
              'Generate exactly $count practice questions.',
        },
      ],
      temperature: 0.65,
      maxTokens: 4500,
      premium: premium,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? const <dynamic>[];
    final List<String> questions =
        raw.map((dynamic e) => e.toString().trim()).where((String s) => s.isNotEmpty).toList();
    return TopicScopeValidator.filterQuestions(questions, profile);
  }

  /// Structured math practice questions (MCQ, graph, free response).
  Future<List<Map<String, dynamic>>> generateMathPracticeQuestionsRaw({
    required String topicName,
    required String courseName,
    required String unitName,
    required String sessionTier,
    required int count,
    List<String> excludePrompts = const <String>[],
    bool premium = false,
  }) async {
    _requireKey();

    final String excludeBlock = excludePrompts.isEmpty
        ? ''
        : 'Do NOT repeat or paraphrase these prompts:\n${excludePrompts.take(40).join('\n')}\n\n';

    final String tierGuide = switch (sessionTier) {
      'exam' =>
        'EXAM: exactly $count questions. Mix easy (35%), intermediate (35%), advanced (30%). '
            'Mix multipleChoice (40%), graph (30%), freeResponse (30%). Hardest tier.\n',
      'quiz' =>
        'QUIZ: exactly $count questions. Mix easy (35%), intermediate (35%), advanced (30%). '
            'Mix multipleChoice (40%), graph (30%), freeResponse (30%). Multi-step, exam-style rigor.\n',
      _ => 'PRACTICE: $count questions, mixed difficulties and types.\n',
    };

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You write mathematics practice questions. Return ONLY JSON: '
              '{"questions":[{"prompt":"...","kind":"multipleChoice|graph|freeResponse",'
              '"difficulty":"easy|intermediate|advanced","options":["A","B","C","D"],"correctIndex":0,'
              '"graphNote":"optional"}]}. '
              'Each prompt must be unique. multipleChoice needs 4 options and correctIndex 0-3. '
              'graph questions ask students to interpret or describe graphs. No roleplay.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Topic: $topicName\nCourse: $courseName\nUnit: $unitName\n'
              '$tierGuide'
              '$excludeBlock'
              'Generate exactly $count unique questions.',
        },
      ],
      temperature: 0.75,
      maxTokens: count >= 40 ? 12000 : 6000,
      premium: premium,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? const <dynamic>[];
    return raw.map((dynamic e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Full Virtual University lecture script with whiteboard frames & checks.
  /// Delivers a real university lecture for ANY faculty — never a short chatbot answer.
  Future<Map<String, dynamic>> generateVirtualLectureScriptRaw({
    required String topicName,
    required String courseName,
    required String moduleName,
    required String mode,
    required int segmentCount,
    String paceHint = 'standard',
    String faculty = 'general',
    bool premium = false,
    String courseId = '',
  }) async {
    _requireKey();

    final String modeGuide = switch (mode) {
      'review' || 'quickReview' =>
        'REVIEW MODE (≤20 min): dense recap — still include history flash, one deep example with beats, and homework.',
      'exam' =>
        'EXAM MODE (~25 min): university exam-style — harder checks, requireCorrect true, 2–3 challenging interactive examples.',
      'practice' =>
        'PRACTICE MODE (~35 min): problem-solving focus — 4–5 interactive examples with beats, keep theory segments substantial.',
      'deepLearning' || 'deepDive' =>
        'DEEP LEARNING MODE (75–90 min): assume no prior knowledge — exhaustive theory, history, five+ interactive examples, homework, reading.',
      'concept' =>
        'CONCEPT LECTURE (45–60 min): full university teaching — intro, history, theory, visuals, ≥3 examples, Q&A, exercises, summary, homework, reading.',
      'comprehensive' =>
        'FULL UNIVERSITY LECTURE (60–75+ min): teach like a real professor for at least ONE HOUR. '
        'NOT a chatbot summary. Spend real time. Cover EVERY part of the mandatory checklist.',
      _ =>
        'FULL UNIVERSITY LECTURE (60+ min): same depth as comprehensive — never one-paragraph answers.',
    };

    final int targetMinutes = switch (mode) {
      'review' || 'quickReview' => 18,
      'exam' => 25,
      'practice' => 35,
      'concept' => 55,
      'deepLearning' || 'deepDive' => 80,
      _ => 65,
    };

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a world-class university professor in $faculty delivering a COMPLETE live lecture '
              'for GradeGlow — a virtual university for people who cannot afford traditional tuition. '
              'You are NOT ChatGPT giving a short answer. You teach like a real faculty member for $targetMinutes+ minutes '
              '(at least one full hour for comprehensive / deep modes). '
              'Do NOT summarize. Do NOT skip subtopics. Every definition must be complete. '
              '${AiProfessorPrompts.liveLectureWritingStyle}'
              'CRITICAL TOPIC LOCK: The lecture MUST be exclusively about "$topicName" in $courseName / $moduleName. '
              'Every segment, example, whiteboard equation, and knowledge check must directly teach "$topicName". '
              'Return ONLY JSON with this shape: '
              '{"topic":"...","course":"...","module":"...","estimatedMinutes":$targetMinutes,'
              '"objectives":["8-12 specific learning outcomes"],'
              '"segments":[{"phase":"introduction|objectives|conceptExplanation|'
              'visualDemonstration|guidedExamples|studentParticipation|knowledgeCheck|practiceProblems|'
              'lessonSummary|homeworkRecommendation",'
              '"professorSpeech":"2-5 spoken sentences that TEACH — elaborate beyond the slide; NEVER read the slide verbatim.",'
              '"caption":"short subtitle that names the idea","durationSeconds":45,'
              '"whiteboard":{"kind":"text|equation|diagram|table|matrix|workedProblem",'
              '"slideType":"concept|clinicalCase|data|diagram|label|question|challenge|caseStudy|summary",'
              '"title":"SHORT university slide title (not a paragraph)",'
              '"subtitle":"one teaching line under the title",'
              '"processSteps":["optional ordered pathway labels"],'
              '"keyPoints":["3-6 SHORT bullets — labels/facts, NOT spoken paragraphs"],'
              '"lines":["short board bullets if needed"],'
              '"dataColumns":["optional"],"dataRows":[["optional","table"]],'
              '"equation":"optional","diagramQuery":"search terms for a real educational diagram",'
              '"imageUrl":"optional https URL","diagramId":"optional bundled id e.g. atom|dna|animal_cell",'
              '"problemStatement":"for guidedExamples","solutionSteps":[{"title":"...","work":"...","note":"..."}],'
              '"highlight":null},'
              '"slideNotes":{"understand":"...","keyConcepts":["..."],"professorInsight":"extra explanation not on the slide",'
              '"remember":"...","examTip":"...","studyNotes":"textbook-style paragraph","questions":["..."],'
              '"vocabulary":["..."]},'
              '"knowledgeCheck":null or {"prompt":"...","kind":"multipleChoice|trueFalse|fillBlank|predictStep",'
              '"options":["..."],"correctIndex":0,"correctAnswer":"...","explanation":"full sentence why correct",'
              '"requireCorrect":false,"timeLimitSeconds":20},'
              '"beats":optional — only when needed for micro-teaching; each beat keeps a FULL university slide '
              '(title+keyPoints/processSteps) while speech elaborates. NEVER put spoken paragraphs on the slide. '
              'Beats: {"professorSpeech":"2-4 sentences elaborating the same slide",'
              '"caption":"idea name","durationSeconds":40,'
              '"whiteboard":{"kind":"text|equation|diagram","slideType":"concept","title":"...","subtitle":"...",'
              '"keyPoints":["short"],"processSteps":[],"lines":["short"],"equation":"optional","highlight":null},'
              '"slideNotes":{"understand":"...","keyConcepts":[],"professorInsight":"...","remember":"...",'
              '"examTip":"...","studyNotes":"...","questions":[],"vocabulary":[]},'
              '"studentChoice":null or {"prompt":"...","kind":"multipleChoice","options":["..."],'
              '"correctIndex":0,"explanation":"...","requireCorrect":false,"timeLimitSeconds":20}}]},'
              '"notes":{"definitions":[],"formulas":[],"examples":[],"commonMistakes":[],"tips":[]},'
              '"summary":{"learned":[],"keyFormulas":[],"applications":[],"reviewTopics":[],'
              '"homeworkRecommendation":"specific homework + next lesson + reading"}}. '
              'UNIVERSITY SLIDE RULES (critical): The slide is what a professor prepared for class — titles, '
              'process pathways, short bullets, charts, diagrams. The AI professor speech is the lecture. '
              'Do NOT dump chatbot paragraphs onto the slide. Do NOT put "Not a chatbot summary" on the board. '
              'Vary slideType across the lecture. Include slideNotes on every segment. '
              'Questions are ONE chance with timeLimitSeconds 20. '
              'TEACHING FLOW (critical — never ignore): '
              'Each idea must progress as DEFINE → EXAMPLE → (DIAGRAM if useful) → EXPLAIN THE DIAGRAM. '
              'Never repeat the same sentence. Teach with new substance each segment. '
              'When a diagram is shown, you MUST teach EVERY labeled part — never only one label like "Skull". '
              'If there are many labels, use multiple visualDemonstration segments titled PART 1, PART 2, etc. '
              'For each part: name it, say what it does, and (for anatomy) say axial vs appendicular when relevant. '
              'Put the same part names in whiteboard.keyPoints for that segment so the slide matches speech. '
              'SPEECH NATURALNESS (critical): Start teaching the concept in sentence one. '
              'Never mention slides, bullets, boards, buttons, UI, "new information", '
              '"open your notes", "take notes", "I am going to teach you", "like a real university", '
              '"welcome to class", "I will not read the bullets", "not a chatbot", or "university lecture". '
              'Never tell students to tap a button. Never say "example one, example two, example three". '
              'DIAGRAMS: Only use kind "diagram" when a labeled figure truly helps '
              '(anatomy, cell, molecule, circuit, etc.). Include diagramId or diagramQuery '
              'AND whiteboard.lines listing every labeled part the student should learn. '
              'If the topic is process/communication/ethics/interview skills, use kind "text" '
              'instead — never force a random anatomy plate. '
              'NEVER invent hand-drawn shapes, triangles, or fake graph curves. '
              'MANDATORY CHECKLIST — every lecture for EVERY topic/course must include ALL of these '
              '(use multiple segments as needed; never skip):\n'
              '1) SHORT intro (1–2 sentences).\n'
              '2) DEFINE the concept precisely (new information — do not repeat intro).\n'
              '3) Give concrete EXAMPLES (new scenarios — never say "example one, example two").\n'
              '4) When a diagram helps: show it and EXPLAIN EVERY labeled part '
              '(split into PART 1 / PART 2 segments if needed — never leave labels unexplained).\n'
              '5) Show formulas/rules and explain EVERY symbol.\n'
              '6) Common mistakes + practice + questions.\n'
              '7) Ask the student questions throughout (knowledgeCheck / studentChoice).\n'
              '8) Tell students that Confused reteaches differently (new analogy + new example).\n'
              '9) Homework and reading.\n'
              'Include knowledgeCheck or studentChoice every 3–4 segments. '
              'durationSeconds: theory beats 35–70, visuals 60–120, examples 50+. '
              'SLIDE SYNC (critical): Slide content is structured teaching visual (title, processSteps, short keyPoints). '
              'Speech elaborates and must NOT copy the slide word-for-word. Prefer one rich university slide per idea '
              'over many one-line beats that merely restate speech. Personalize complexity using the student pace hint.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseName\nModule: $moduleName\nTopic: $topicName\n'
              'CourseId: ${courseId.isEmpty ? courseName : courseId}\nFaculty: $faculty\n'
              'TOPIC LOCK: Teach ONLY "$topicName" — every segment, whiteboard equation, example, and knowledge check '
              'must directly teach "$topicName". Never switch to a different concept (no unrelated calculus, '
              'algebra, biology, etc. unless "$topicName" itself is that concept).\n'
              '$modeGuide\n'
              'Student pace / personalization: $paceHint\n'
              'Generate exactly $segmentCount segments — a COMPLETE university lecture (≥1 hour for full modes) until every checklist item is taught. '
              'estimatedMinutes must be $targetMinutes or higher. '
              'Remember: students chose GradeGlow because they cannot buy a \$50,000 education — teach with that dignity and depth.',
        },
      ],
      temperature: 0.55,
      maxTokens: 16000,
      premium: premium,
    );

    return decodeAiJson(content);
  }

  /// Answer a student question mid-lecture without restarting.
  Future<String> askProfessorDuringLecture({
    required String topicName,
    required String courseName,
    required String currentSegmentSpeech,
    required String studentQuestion,
    bool premium = false,
  }) async {
    _requireKey();

    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.interruptSystem(
            role: 'a patient university professor',
          ),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseName\nTopic: $topicName\n'
              'Current lecture point: $currentSegmentSpeech\n'
              'Student question: $studentQuestion',
        },
      ],
      temperature: 0.5,
      maxTokens: 1800,
      premium: premium,
    );
  }

  /// Generate one expansion segment
  Future<Map<String, dynamic>> generateLectureExpansionSegmentRaw({
    required String topicName,
    required String courseName,
    required String currentSpeech,
    required String studentRequest,
    bool premium = false,
  }) async {
    _requireKey();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a university professor expanding a live lecture. '
              '${AiProfessorPrompts.liveLectureWritingStyle}'
              'Return ONLY JSON for ONE segment: '
              '{"phase":"conceptExplanation|guidedExamples|visualDemonstration|studentParticipation",'
              '"professorSpeech":"2-4 sentences introducing the first idea",'
              '"caption":"...","durationSeconds":50,'
              '"whiteboard":{"kind":"text|equation|diagram","title":"...","lines":["one board note"],'
              '"equation":"optional","diagramQuery":"real educational diagram search terms",'
              '"imageUrl":"optional https diagram URL"},'
              '"knowledgeCheck":null or {"prompt":"...","kind":"multipleChoice","options":["..."],'
              '"correctIndex":0,"explanation":"...","requireCorrect":false},'
              '"beats":[{"professorSpeech":"2-4 sentences","caption":"...","durationSeconds":45,'
              '"whiteboard":{"kind":"text","title":"...","lines":["one note matching speech"],"highlight":null}}]}. '
              'SLIDE SYNC: each beat speaks one idea and shows exactly one matching board note. '
              'Give MORE depth — extra proof steps, more examples, or visual explanation as requested. '
              'Finish every sentence. Never truncate mid-thought.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseName\nTopic: $topicName\n'
              'Current lecture point: $currentSpeech\n'
              'Student request: $studentRequest',
        },
      ],
      temperature: 0.5,
      maxTokens: 4000,
      premium: premium,
    );

    return decodeAiJson(content);
  }

  Future<bool> gradeMathAnswerCorrect({
    required String topicName,
    required String question,
    required String studentAnswer,
    required String kind,
    required String difficulty,
    bool premium = false,
  }) async {
    _requireKey();

    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Grade one math answer. Return ONLY JSON: {"correct":true} or {"correct":false}. '
              'Be fair; accept equivalent forms.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Topic: $topicName\nType: $kind\nDifficulty: $difficulty\n'
              'Question: $question\nAnswer: $studentAnswer',
        },
      ],
      temperature: 0.1,
      maxTokens: 80,
      premium: premium,
    );

    try {
      final Map<String, dynamic> json = decodeAiJson(reply);
      return json['correct'] == true;
    } catch (_) {
      return reply.toLowerCase().contains('"correct":true') ||
          reply.toLowerCase().contains('"correct": true');
    }
  }

  /// Grade a typed English answer (email, short writing, or open response).
  Future<Map<String, dynamic>> gradeEnglishWriting({
    required String lessonTitle,
    required String prompt,
    required String studentAnswer,
    String tone = 'any',
    List<String> criteria = const <String>[],
    String? expectedAnswer,
    String? recipient,
    String? listeningScript,
    bool premium = false,
  }) async {
    _requireKey();

    final String criteriaLine = criteria.isEmpty
        ? ''
        : 'Rubric points: ${criteria.join('; ')}. ';
    final String recipientLine =
        recipient != null && recipient.isNotEmpty ? 'To: $recipient\n' : '';
    final String expectedLine = expectedAnswer != null && expectedAnswer.isNotEmpty
        ? 'Model answer (if helpful): $expectedAnswer\n'
        : '';
    final String listenLine = listeningScript != null && listeningScript.isNotEmpty
        ? 'Context heard/read: $listeningScript\n'
        : '';

    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade one English learner written response. '
              'Return ONLY JSON: {"correct":true|false,"feedback":"one or two short sentences"}. '
              'Mark correct if the answer meets the task with acceptable grammar and tone. '
              'Be fair — accept equivalent wording. For emails check greeting, purpose, polite tone, closing.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Lesson: $lessonTitle\nTask: $prompt\nTone: $tone\n'
              '$criteriaLine$expectedLine$listenLine'
              '$recipientLine'
              'Student wrote:\n$studentAnswer',
        },
      ],
      temperature: 0.2,
      maxTokens: 180,
      premium: premium,
    );

    try {
      return decodeAiJson(reply);
    } catch (_) {
      final bool ok = reply.toLowerCase().contains('"correct":true') ||
          reply.toLowerCase().contains('"correct": true');
      return <String, dynamic>{
        'correct': ok,
        'feedback': ok ? 'Good work!' : 'Review the prompt and try again.',
      };
    }
  }

  /// Grade a read-aloud attempt against the target passage.
  Future<Map<String, dynamic>> gradeEnglishReadingAloud({
    required String lessonTitle,
    required String passage,
    required String studentTranscript,
    required String taskPrompt,
    bool premium = false,
  }) async {
    _requireKey();

    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade one English learner read-aloud attempt. '
              'Compare the student transcript to the target passage. '
              'Mark correct only if they read most of the passage with acceptable accuracy. '
              'Return ONLY JSON: {"correct":true|false,"overall":0-100,"pronunciation":0-100,'
              '"fluency":0-100,"accuracy":0-100,"feedback":"coaching sentences",'
              '"mispronouncedWords":["word"],"practiceWords":["word"]}.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Lesson: $lessonTitle\nTask: $taskPrompt\n\n'
              'Target passage:\n$passage\n\n'
              'Student read (transcript):\n$studentTranscript',
        },
      ],
      temperature: 0.2,
      maxTokens: 180,
      premium: premium,
    );

    try {
      return decodeAiJson(reply);
    } catch (_) {
      final bool ok = reply.toLowerCase().contains('"correct":true') ||
          reply.toLowerCase().contains('"correct": true');
      return <String, dynamic>{
        'correct': ok,
        'feedback': ok
            ? 'Good reading — clear and mostly accurate.'
            : 'Read the full passage more slowly and match the words on screen.',
      };
    }
  }

  /// Short feedback after a student answers one practice question.
  Future<String> feedbackPracticeAnswer({
    required String categoryName,
    required String topicName,
    required String question,
    required String studentAnswer,
    required String difficulty,
    bool premium = false,
  }) async {
    _requireKey();

    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade one practice question for a $categoryName student. '
              'Reply in 2-4 sentences: say if the answer is on track, one strength, one improvement. '
              'Be encouraging and specific. Do not ask a new question.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Topic: $topicName\nDifficulty: $difficulty\n'
              'Question: $question\nStudent answer: $studentAnswer',
        },
      ],
      temperature: 0.4,
      maxTokens: 350,
      premium: premium,
    );
    final String trimmed = reply.trim();
    return trimmed.isEmpty ? 'Thanks — keep going!' : trimmed;
  }

  /// Explains a wrong diagram label in 2-3 sentences.
  Future<String> explainLabelingMistake({
    required String diagramTitle,
    required String correctLabel,
    required String studentChoice,
    required String subjectName,
    String context = 'diagram labeling',
    bool premium = false,
  }) async {
    _requireKey();
    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a $subjectName tutor. A student misidentified a structure during $context. '
              'In 2-3 clear sentences: name the correct answer, explain why their choice was wrong, and give one memory tip. Be encouraging.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Diagram: $diagramTitle\nCorrect: $correctLabel\nStudent picked: $studentChoice',
        },
      ],
      temperature: 0.35,
      maxTokens: 280,
      premium: premium,
    );
    final String trimmed = reply.trim();
    return trimmed.isEmpty ? 'The correct label is $correctLabel. Review the diagram and try again.' : trimmed;
  }

  /// Explains a virtual chemistry reaction outcome.
  Future<String> explainChemistryReaction({
    required String reagentA,
    required String reagentB,
    required String outcome,
    required double ph,
    required String subjectName,
    bool premium = false,
  }) async {
    _requireKey();
    final String reply = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a chemistry lab instructor. Explain what happened when two reagents were mixed. '
              'Cover the reaction type, pH meaning, and one safety note in 3-4 sentences.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Mixed: $reagentA + $reagentB\nObserved: $outcome\nMeasured pH: ${ph.toStringAsFixed(1)}',
        },
      ],
      temperature: 0.4,
      maxTokens: 320,
      premium: premium,
    );
    return reply.trim().isEmpty ? outcome : reply.trim();
  }

  /// Grades a completed simulation transcript.
  Future<SimulationGrade> gradePracticeSimulation({
    required String categoryName,
    required String labTitle,
    required String scenarioBriefing,
    required List<SimulationMessage> history,
    List<String> evaluationCriteria = const <String>[],
    List<String> studentTasks = const <String>[],
    String difficulty = '',
    bool premium = false,
  }) async {
    _requireKey();

    final StringBuffer transcript = StringBuffer('Scenario:\n$scenarioBriefing\n\nTranscript:\n');
    for (final SimulationMessage turn in history) {
      transcript.writeln('${turn.isStudent ? 'Student' : 'AI'}: ${turn.text}');
    }

    final String evalGuide = evaluationCriteria.isNotEmpty
        ? 'Evaluate on: ${evaluationCriteria.join(', ')}. '
        : '';
    final String tasksGuide = studentTasks.isNotEmpty
        ? 'Expected student tasks: ${studentTasks.join('; ')}. '
        : '';
    final String difficultyGuide = difficulty.isNotEmpty ? 'Difficulty was $difficulty. ' : '';

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade Practice Lab simulations for university students. '
              'Return ONLY JSON: {"score":0-100,"summary":"overall verdict",'
              '"strengths":["..."],"improvements":["..."],"improvementPlan":"actionable study plan",'
              '"studyTopics":["topic to review"],"criteriaScores":{"criterion":0-100},"hintsUsed":0}. '
              'Include criteriaScores for each evaluation criterion. '
              '$evalGuide$tasksGuide$difficultyGuide'
              'Be fair, specific, and encouraging.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Category: $categoryName\nLab: $labTitle\n\n$transcript',
        },
      ],
      temperature: 0.3,
      maxTokens: 1600,
      premium: premium,
    );

    return SimulationGrade.fromJson(decodeAiJson(content));
  }

  /// Coaching hint without ending the simulation.
  Future<String> practiceLabHint({
    required String categoryName,
    required String labTitle,
    required String scenarioBriefing,
    required List<SimulationMessage> history,
    required List<String> studentTasks,
    bool premium = false,
  }) async {
    _requireKey();

    final StringBuffer transcript = StringBuffer();
    for (final SimulationMessage turn in history) {
      transcript.writeln('${turn.isStudent ? 'Student' : 'AI'}: ${turn.text}');
    }

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a practice lab coach for $categoryName students. '
              'Give ONE concise hint (2-3 sentences) to help the student progress. '
              'Do not solve the entire scenario or reveal the full answer. '
              'Be encouraging and specific to what they should do next.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Lab: $labTitle\nTasks: ${studentTasks.join('; ')}\n\n'
              'Scenario:\n$scenarioBriefing\n\nTranscript:\n$transcript',
        },
      ],
      temperature: 0.5,
      maxTokens: 300,
      premium: premium,
    );
    return content.trim();
  }

  /// Lightweight real-time performance pulse after a student turn.
  Future<PracticeLabLiveScore> practiceLabLiveScore({
    required String categoryName,
    required String labTitle,
    required String scenarioBriefing,
    required List<SimulationMessage> history,
    List<String> evaluationCriteria = const <String>[],
    bool premium = false,
  }) async {
    _requireKey();

    final StringBuffer transcript = StringBuffer();
    for (final SimulationMessage turn in history) {
      transcript.writeln('${turn.isStudent ? 'Student' : 'AI'}: ${turn.text}');
    }

    final String criteriaGuide = evaluationCriteria.isNotEmpty
        ? 'Score each: ${evaluationCriteria.join(', ')} in criteriaScores. '
        : '';

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You score an in-progress practice lab simulation. '
              'Return ONLY JSON: {"overall":0-100,"criteriaScores":{"criterion":0-100},"feedback":"one short sentence"}. '
              '$criteriaGuide'
              'Score based on progress so far, not perfection.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Category: $categoryName\nLab: $labTitle\n\nScenario:\n$scenarioBriefing\n\n$transcript',
        },
      ],
      temperature: 0.2,
      maxTokens: 400,
      premium: premium,
    );

    return PracticeLabLiveScore.fromJson(decodeAiJson(content));
  }

  /// Starts an AI Practice Mode simulation with major, scenario, and difficulty.
  Future<SimulationStart> startAiPracticeMode({
    required String majorName,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    bool premium = false,
  }) async {
    _requireKey();

    final String difficultyGuide = AiPracticeCatalog.difficultyPrompt(difficulty);
    final String scenarioContext = scenario.isAiGenerated
        ? 'Generate a fresh, unique scenario appropriate for $majorName students.'
        : 'Scenario template: ${scenario.title}\n${scenario.description}\n'
            'Student tasks: ${scenario.studentTasks.join('; ')}';

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You create immersive AI Practice Mode simulations for university students.\n'
              'Return ONLY JSON: {"scenarioTitle":"...","briefing":"markdown setup for the student",'
              '"aiRole":"${scenario.aiRoleLabel}","openingMessage":"your first in-character line"}.\n'
              'The briefing should explain the situation, objectives, and any relevant context.\n'
              'The openingMessage must stay in character. Do not grade the student yet.\n'
              '$difficultyGuide\n'
              'Roleplay guide: ${scenario.roleplayGuide}',
        },
        <String, String>{
          'role': 'user',
          'content': 'Major: $majorName\n$scenarioContext\n\nCreate the simulation opening.',
        },
      ],
      temperature: 0.9,
      maxTokens: 2000,
      premium: premium,
    );

    final Map<String, dynamic> json = decodeAiJson(content);
    final SimulationStart start = SimulationStart.fromJson(json);
    if (start.briefing.isEmpty || start.openingMessage.isEmpty) {
      throw Exception('The AI returned an incomplete simulation. Try again.');
    }
    return start;
  }

  /// Continues an AI Practice Mode simulation.
  Future<String> continueAiPracticeMode({
    required String majorName,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    required String scenarioBriefing,
    required String aiRole,
    required List<SimulationMessage> history,
    required String studentMessage,
    bool premium = false,
  }) async {
    _requireKey();

    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You are running an AI Practice Mode simulation for $majorName students.\n'
            'You are playing: $aiRole\n'
            '${scenario.roleplayGuide}\n'
            '${AiPracticeCatalog.difficultyPrompt(difficulty)}\n\n'
            'Scenario briefing:\n$scenarioBriefing\n\n'
            'Stay in character. Respond naturally in 1-4 short paragraphs. '
            'Show appropriate emotions. Ask follow-up questions when appropriate. '
            'Do not break character or grade the student yet.',
      },
    ];

    for (final SimulationMessage turn in history) {
      messages.add(<String, dynamic>{
        'role': turn.isStudent ? 'user' : 'assistant',
        'content': turn.text,
      });
    }

    messages.add(<String, dynamic>{'role': 'user', 'content': studentMessage.trim()});

    final String reply = await _chatDynamic(messages, temperature: 0.75, premium: premium);
    final String trimmed = reply.trim();
    if (trimmed.isEmpty) {
      throw Exception('The AI returned an empty response. Try again.');
    }
    return trimmed;
  }

  /// Grades a completed AI Practice Mode session.
  Future<PracticeModeGrade> gradeAiPracticeMode({
    required String majorName,
    required PracticeScenarioTemplate scenario,
    required PracticeDifficulty difficulty,
    required String scenarioBriefing,
    required List<SimulationMessage> history,
    bool premium = false,
  }) async {
    _requireKey();

    final StringBuffer transcript = StringBuffer('Scenario:\n$scenarioBriefing\n\nTranscript:\n');
    for (final SimulationMessage turn in history) {
      transcript.writeln('${turn.isStudent ? 'Student' : 'AI'}: ${turn.text}');
    }

    final String evalGuide = AiPracticeCatalog.evaluationPrompt(scenario.evaluationCriteria);

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade AI Practice Mode simulations for university students. '
              'Return ONLY JSON: {"score":0-100,"summary":"overall verdict",'
              '"strengths":["..."],"improvements":["..."],"improvementPlan":"actionable study plan",'
              '"studyTopics":["topic to review"],"criteriaScores":{"criterion":0-100}}. '
              '$evalGuide '
              'Difficulty was ${difficulty.label}. Be fair, specific, and encouraging.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Major: $majorName\nScenario: ${scenario.title}\n\n$transcript',
        },
      ],
      temperature: 0.3,
      maxTokens: 1800,
      premium: premium,
    );

    return PracticeModeGrade.fromJson(decodeAiJson(content));
  }

  /// Witness answers only from their knowledge; case truth stays hidden from the student.
  Future<String> lawWitnessReply({
    required LawWitness witness,
    required String caseBrief,
    required String truthBlock,
    required String studentQuestion,
    required List<SimulationMessage> history,
    bool premium = false,
  }) async {
    _requireKey();
    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You are ${witness.name}, ${witness.role}, in a law school courtroom simulation.\n'
            'Personality: ${witness.personality}. Bias: ${witness.bias}.\n'
            'You may ONLY use these facts (do not invent new evidence):\n'
            '${witness.knowledge.map((String k) => '- $k').join('\n')}\n\n'
            '$truthBlock\n'
            'Stay in character. Answer only what is asked. 2-4 sentences. '
            'If you would not know something, say so.',
      },
      <String, dynamic>{'role': 'user', 'content': 'Case context (student view):\n$caseBrief'},
    ];
    for (final SimulationMessage turn in history) {
      messages.add(<String, dynamic>{
        'role': turn.isStudent ? 'user' : 'assistant',
        'content': turn.text,
      });
    }
    messages.add(<String, dynamic>{'role': 'user', 'content': studentQuestion.trim()});
    final String reply = await _chatDynamic(messages, temperature: 0.65, premium: premium);
    if (reply.trim().isEmpty) throw Exception('Witness did not respond. Try again.');
    return reply.trim();
  }

  Future<String> lawOpponentReply({
    required String sideLabel,
    required String opponentLabel,
    required String caseBrief,
    required String truthBlock,
    required String studentArgument,
    required List<SimulationMessage> history,
    bool premium = false,
  }) async {
    _requireKey();
    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      <String, dynamic>{
        'role': 'system',
        'content':
            'You are $opponentLabel arguing against the $sideLabel in a trial simulation.\n'
            '$truthBlock\n'
            'Challenge weak logic. Cite evidence plausibly. Stay professional. 2-4 paragraphs max.',
      },
      <String, dynamic>{'role': 'user', 'content': '$caseBrief\n\nStudent argument:\n$studentArgument'},
    ];
    for (final SimulationMessage turn in history) {
      messages.add(<String, dynamic>{
        'role': turn.isStudent ? 'user' : 'assistant',
        'content': turn.text,
      });
    }
    final String reply = await _chatDynamic(messages, temperature: 0.7, premium: premium);
    return reply.trim().isEmpty ? 'Opposing counsel reserves comment.' : reply.trim();
  }

  Future<String> lawJudgeLine({
    required String action,
    required String caseBrief,
    required String truthBlock,
    required String studentLine,
    bool premium = false,
  }) async {
    _requireKey();
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are the trial judge. Action: $action.\n$truthBlock\n'
              'Rule on objections fairly. Keep order. 1-3 sentences. '
              'Say "Sustained" or "Overruled" when ruling on objections.',
        },
        <String, String>{
          'role': 'user',
          'content': '$caseBrief\n\nCounsel: $studentLine',
        },
      ],
      temperature: 0.4,
      maxTokens: 300,
      premium: premium,
    );
    return content.trim().isEmpty ? 'The court notes your argument.' : content.trim();
  }

  /// Textbook-style law professor lecture with definitions and worked examples.
  Stream<String> lawProfessorLectureStream({
    required String courseTitle,
    required String lessonTitle,
    required String hook,
    required String question,
    required List<String> elements,
    bool premium = false,
  }) async* {
    _requireKey();
    yield* _chatStream(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.lawChapterSystem(),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nLesson: $lessonTitle\n\nHook (use in Introduction and Worked Example):\n$hook\n\n'
              'Central question: $question\n\nDoctrine: (teach fully)\n\nElements to define: ${elements.join(' · ')}\n\n'
              'Write the complete textbook chapter now. Do not summarize.',
        },
      ],
      temperature: 0.45,
      maxTokens: 8000,
      premium: premium,
    );
  }

  Future<String> lawProfessorAnswer({
    required String courseTitle,
    required String lessonTitle,
    required String lectureContext,
    required String question,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.answerSystem(
            role: 'a university law professor',
            extraRules: 'Apply rules to facts when relevant. Do not write a full exam answer unless asked.',
          ),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nLesson: $lessonTitle\n\nLecture so far:\n$lectureContext\n\nStudent: $question',
        },
      ],
      temperature: 0.35,
      maxTokens: 550,
      premium: premium,
    );
  }

  Future<String> lawGradeBrief({
    required String caseName,
    required String modelFacts,
    required String modelIssue,
    required String modelRule,
    required String modelHolding,
    required Map<String, String> studentSections,
    bool premium = false,
  }) async {
    _requireKey();
    final String student = studentSections.entries.map((e) => '### ${e.key}\n${e.value}').join('\n\n');
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You grade a law-student case brief. Score each of Facts, Issue, Rule, Analysis, Holding (0-5). '
              'Then give overall /25 and 3 concrete improvements. Be encouraging but precise. Markdown.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Case: $caseName\n\nModel cues:\nFacts: $modelFacts\nIssue: $modelIssue\nRule: $modelRule\nHolding: $modelHolding\n\nStudent brief:\n$student',
        },
      ],
      temperature: 0.3,
      maxTokens: 700,
      premium: premium,
    );
  }

  /// Quiz generated from AI professor lecture notes (or lesson study notes).
  Future<List<QuizQuestion>> lawQuizFromNotes({
    required String title,
    required String notes,
    int questionCount = 8,
    bool premium = false,
  }) async {
    _requireKey();
    final String clipped = notes.length > 12000 ? notes.substring(0, 12000) : notes;
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You write a multiple-choice quiz ONLY from the provided AI study notes. '
              'Do not invent doctrines that are not in the notes. '
              'Return ONLY valid JSON: '
              '{"questions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0}]} '
              'Create exactly $questionCount questions. Each needs 4 options and correctIndex 0-3. '
              'Cover definitions, elements, the dispute/hook, application to facts, and common mistakes from the notes. '
              'One clearly correct answer per question. Plain language.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Title: $title\n\nAI notes:\n$clipped',
        },
      ],
      temperature: 0.35,
      maxTokens: 2400,
      premium: premium,
    );
    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .where((QuizQuestion q) => q.prompt.isNotEmpty && q.options.length >= 2)
        .toList();
  }

  /// Multiple-choice quiz on what the AI professor taught for a Law School topic.
  Future<List<QuizQuestion>> lawProfessorTopicQuiz({
    required String courseTitle,
    required String lessonTitle,
    required String hook,
    required String question,
    required String doctrine,
    required List<String> elements,
    String? lectureNotes,
    int questionCount = 8,
    bool premium = false,
  }) async {
    final String notes = (lectureNotes != null && lectureNotes.trim().length >= 80)
        ? lectureNotes.trim()
        : 'Course: $courseTitle\nLesson: $lessonTitle\n\nHook:\n$hook\n\n'
            'Guiding question:\n$question\n\nDoctrine:\n$doctrine\n\n'
            'Elements:\n${elements.map((String e) => '- $e').join('\n')}';
    return lawQuizFromNotes(
      title: '$courseTitle — $lessonTitle',
      notes: notes,
      questionCount: questionCount,
      premium: premium,
    );
  }

  Future<String> lawGradeWriting({
    required String writingType,
    required String prompt,
    required String doctrine,
    required String studentText,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a legal writing professor. Grade: Structure, Legal reasoning, Persuasiveness, '
              'Professional tone, Organization, Citation/precision (each 1-5). '
              'Give rewritten sample sentences for the weakest paragraph. Markdown headings.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Type: $writingType\nPrompt: $prompt\nDoctrine focus: $doctrine\n\nStudent draft:\n$studentText',
        },
      ],
      temperature: 0.3,
      maxTokens: 800,
      premium: premium,
    );
  }

  Future<String> lawClientReply({
    required String clientOpening,
    required List<String> hiddenFacts,
    required String history,
    required String studentQuestion,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a realistic legal client in an intake interview. You are emotional but cooperative. '
              'Reveal hidden facts ONLY when the student asks a reasonably specific question. '
              'Do not dump the whole file. Stay in character. 2-5 sentences.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Opening: $clientOpening\nHidden facts (reveal gradually):\n- ${hiddenFacts.join('\n- ')}\n\n'
              'Interview so far:\n$history\n\nLawyer asks: $studentQuestion',
        },
      ],
      temperature: 0.6,
      maxTokens: 280,
      premium: premium,
    );
  }

  Future<String> lawNegotiationReply({
    required String offer,
    required String caseContext,
    required String studentMove,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are opposing counsel / claims adjuster in a negotiation. Be realistic. '
              'Respond to accept / counter / walk-to-trial moves. Mention leverage and risk. '
              'If they counter, give a revised number or principled refusal. 3-6 sentences.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Context: $caseContext\nCurrent offer: $offer\nStudent move: $studentMove',
        },
      ],
      temperature: 0.5,
      maxTokens: 350,
      premium: premium,
    );
  }

  Future<LawVerdictBreakdown> lawSimulationVerdict({
    required String caseBrief,
    required String truthBlock,
    required String sideLabel,
    required String argumentSummary,
    required List<SimulationMessage> courtroomHistory,
    bool premium = false,
  }) async {
    _requireKey();
    final StringBuffer transcript = StringBuffer();
    for (final SimulationMessage turn in courtroomHistory) {
      transcript.writeln('${turn.isStudent ? sideLabel : 'Court'}: ${turn.text}');
    }
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are the judge delivering a final verdict in a law simulation.\n'
              '$truthBlock\n'
              'Grade the $sideLabel performance. Return ONLY JSON:\n'
              '{"logic":0-100,"evidenceUse":0-100,"persuasion":0-100,"accuracy":0-100,'
              '"overall":0-100,"ruling":"guilty/not guilty/civil outcome",'
              '"summary":"2-3 sentences","weakPoints":["..."],"keyEvidence":["..."],'
              '"xpEarned":20-80}\n'
              'Accuracy measures alignment with true facts and law. Be specific.',
        },
        <String, String>{
          'role': 'user',
          'content': '$caseBrief\n\nTrial argument:\n$argumentSummary\n\nTranscript:\n$transcript',
        },
      ],
      temperature: 0.35,
      maxTokens: 1200,
      premium: premium,
    );
    return LawVerdictBreakdown.fromJson(decodeAiJson(content));
  }

  /// Generates LeetCode-format algorithm problems for a topic.
  Future<List<LeetcodeProblem>> generateLeetcodeProblems({
    required String topicName,
    required String unitName,
    required String difficulty,
    int count = 3,
    bool premium = false,
    bool debugMode = false,
  }) async {
    _requireKey();
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': debugMode
              ? 'You create original debugging practice problems for university CS students. '
                  'Each problem ships with intentionally buggy starter code the student must fix. '
                  'Return ONLY JSON: {"problems":[{"id":"1","title":"...(Buggy)","slug":"kebab-case","kind":"debug",'
                  '"difficulty":"Easy|Medium|Hard","description":"what is wrong at a high level","functionName":"camelCase",'
                  '"tags":["Debugging","Array"],"starterCode":{"python3":"full buggy class Solution code","javascript":"..."},'
                  '"examples":[{"input":"...","output":"..."}],"constraints":["..."],"hiddenTests":[{"input":"...","output":"..."}]}]}. '
                  'starterCode must contain realistic buggy implementations (not empty templates). Include 2 examples and 1 hidden test.'
              : 'You create original interview-style coding problems for university CS students. '
                  'Return ONLY JSON: {"problems":[{"id":"1","title":"...","slug":"kebab-case","difficulty":"Easy|Medium|Hard",'
                  '"description":"markdown body","functionName":"camelCase","tags":["Array"],'
                  '"examples":[{"input":"...","output":"...","explanation":"..."}],'
                  '"constraints":["..."],"hiddenTests":[{"input":"...","output":"..."}]}]}. '
                  'Each problem must be implementable with a single function. Include 2-3 examples and 1-2 hidden tests.',
        },
        <String, String>{
          'role': 'user',
          'content': debugMode
              ? 'Debugging topic: $topicName\nUnit: $unitName\nDifficulty: $difficulty\nGenerate exactly $count unique fix-the-bug problems with starterCode.'
              : 'Topic: $topicName\nUnit: $unitName\nDifficulty: $difficulty\nGenerate exactly $count unique problems.',
        },
      ],
      temperature: 0.85,
      maxTokens: 4000,
      premium: premium,
    );
    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['problems'] as List<dynamic>? ?? <dynamic>[];
    return raw.map((dynamic e) => LeetcodeProblem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Evaluates code against visible + hidden test cases (AI judge).
  Future<LeetcodeRunResult> evaluateLeetcodeSubmission({
    required LeetcodeProblem problem,
    required String language,
    required String code,
    bool includeHidden = false,
    bool premium = false,
  }) async {
    _requireKey();
    final StringBuffer tests = StringBuffer('Visible examples:\n');
    for (int i = 0; i < problem.examples.length; i++) {
      final LeetcodeExample ex = problem.examples[i];
      tests.writeln('Case ${i + 1}: input=${ex.input} expected=${ex.output}');
    }
    if (includeHidden) {
      for (int i = 0; i < problem.hiddenTests.length; i++) {
        final LeetcodeHiddenTest t = problem.hiddenTests[i];
        tests.writeln('Hidden ${i + 1}: input=${t.input} expected=${t.output}');
      }
    }
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a coding judge. Trace the student solution logically. '
              'Return ONLY JSON: {"accepted":true|false,"results":[{"index":1,"passed":true|false,'
              '"input":"...","expected":"...","actual":"...","hidden":false}],"feedback":"short",'
              '"runtimeNote":"e.g. O(n) time","timeComplexity":"Big O","spaceComplexity":"Big O",'
              '"readabilityNotes":"naming/structure","optimizationTips":"how to improve",'
              '"edgeCaseNotes":"edge cases handled or missed"}. '
              'Be strict but fair. If syntax is invalid, all cases fail.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Problem: ${problem.title}\n'
              'Description:\n${problem.description}\n'
              'Function: ${problem.functionName}\nLanguage: $language\n'
              '${problem.isDebug ? "Mode: fix the bug in the provided code.\n" : ""}\n$tests\n\nCode:\n$code',
        },
      ],
      temperature: 0.2,
      maxTokens: 1800,
      premium: premium,
    );
    return LeetcodeRunResult.fromJson(decodeAiJson(content));
  }

  /// Conversational CS professor lecture for one topic.
  List<Map<String, String>> _csProfessorLectureMessages({
    required String courseName,
    required String topicTitle,
  }) {
    final String system = AiProfessorPrompts.csChapterSystem(courseName: courseName);
    return <Map<String, String>>[
      <String, String>{'role': 'system', 'content': system},
      <String, String>{
        'role': 'user',
        'content':
            'Course: $courseName\nTopic: $topicTitle\n\nWrite the complete digital textbook chapter. Do not summarize.',
      },
    ];
  }

  /// Stream a CS professor lecture token-by-token for faster perceived loading.
  Stream<String> csProfessorLectureStream({
    required String courseName,
    required String topicTitle,
    bool premium = false,
  }) {
    _requireKey();
    return _chatStream(
      _csProfessorLectureMessages(courseName: courseName, topicTitle: topicTitle),
      temperature: 0.45,
      maxTokens: 8000,
      premium: premium,
    );
  }

  Future<String> csProfessorLecture({
    required String courseName,
    required String topicTitle,
    bool premium = false,
  }) async {
    _requireKey();
    final StringBuffer lecture = StringBuffer();
    await for (final String chunk in csProfessorLectureStream(
      courseName: courseName,
      topicTitle: topicTitle,
      premium: premium,
    )) {
      lecture.write(chunk);
    }
    return lecture.toString().trim();
  }

  /// Answer a student interrupt question during a CS lecture.
  Future<String> csProfessorAnswer({
    required String courseName,
    required String topicTitle,
    required String lectureContext,
    required String question,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.answerSystem(
            role: 'a programming instructor',
            extraRules: 'Use markdown and fenced code when helpful.',
          ),
        },
        <String, String>{
          'role': 'user',
          'content': 'Course: $courseName\nTopic: $topicTitle\n\nLecture so far:\n$lectureContext\n\nStudent asks: $question',
        },
      ],
      temperature: 0.4,
      maxTokens: 500,
      premium: premium,
    );
  }

  List<Map<String, String>> _healthProfessorLectureMessages({
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
  }) {
    return <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': AiProfessorPrompts.healthChapterSystem(
          facultyTitle: facultyTitle,
        ),
      },
      <String, String>{
        'role': 'user',
        'content':
            'Faculty: $facultyTitle\nCourse: $courseTitle\nTopic: $topicTitle\n\n'
            'Write the complete clinical teaching chapter. Do not summarize.',
      },
    ];
  }

  Stream<String> healthProfessorLectureStream({
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
    bool premium = false,
  }) async* {
    _requireKey();
    yield* _chatStream(
      _healthProfessorLectureMessages(
        facultyTitle: facultyTitle,
        courseTitle: courseTitle,
        topicTitle: topicTitle,
      ),
      temperature: 0.4,
      maxTokens: 8000,
      premium: premium,
    );
  }

  Future<String> healthProfessorAnswer({
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
    required String lectureContext,
    required String question,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.answerSystem(
            role: 'a $facultyTitle clinical professor',
            extraRules:
                'Prioritize safety, assessment order, and clear rationale. '
                'Do not invent exact drug doses.',
          ),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nTopic: $topicTitle\n\nLecture so far:\n$lectureContext\n\nStudent asks: $question',
        },
      ],
      temperature: 0.35,
      maxTokens: 550,
      premium: premium,
    );
  }

  List<Map<String, String>> _engineeringProfessorLectureMessages({
    required String majorName,
    required String courseTitle,
    required String topicTitle,
  }) {
    return <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': AiProfessorPrompts.engineeringChapterSystem(majorName: majorName),
      },
      <String, String>{
        'role': 'user',
        'content':
            'Major: $majorName\nCourse: $courseTitle\nTopic: $topicTitle\n\n'
            'Write the complete digital textbook chapter. Do not summarize.',
      },
    ];
  }

  Stream<String> engineeringProfessorLectureStream({
    required String majorName,
    required String courseTitle,
    required String topicTitle,
    bool premium = false,
  }) async* {
    _requireKey();
    yield* _chatStream(
      _engineeringProfessorLectureMessages(
        majorName: majorName,
        courseTitle: courseTitle,
        topicTitle: topicTitle,
      ),
      temperature: 0.45,
      maxTokens: 8000,
      premium: premium,
    );
  }

  Future<String> engineeringProfessorAnswer({
    required String majorName,
    required String courseTitle,
    required String topicTitle,
    required String lectureContext,
    required String question,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.answerSystem(
            role: 'an engineering professor in $majorName',
            extraRules: 'Do not give complete project solutions.',
          ),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nTopic: $topicTitle\n\nLecture so far:\n$lectureContext\n\nStudent asks: $question',
        },
      ],
      temperature: 0.35,
      maxTokens: 550,
      premium: premium,
    );
  }

  List<Map<String, String>> _physicsProfessorLectureMessages({
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String hook,
    required PhysicsTopic topic,
    required PhysicsCourse course,
  }) {
    final PhysicsChapterNav nav = PhysicsChapterNav.forTopic(course: course, topic: topic);
    final String offlineDraft = PhysicsTextbookChapterEngine.build(
      course: course,
      topic: topic,
      levelLabel: levelLabel,
    );
    final String knowledgeOutline = PhysicsTopicKnowledgeEngine.lectureOutline(
      course: course,
      topic: topic,
    );
    return <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': AiProfessorPrompts.physicsChapterSystem(levelLabel: levelLabel),
      },
      <String, String>{
        'role': 'user',
        'content':
            'Level: $levelLabel\nCourse: $courseTitle\nTopic: $topicTitle\nHook: $hook\n\n'
            'Chapter sequence:\n'
            '- Chapter ${nav.chapterNumber} of ${nav.totalChapters}\n'
            '- Previous: ${nav.previous?.title ?? "none"}\n'
            '- Next: ${nav.next?.title ?? "none"}\n\n'
            'Topic knowledge outline:\n$knowledgeOutline\n\n'
            'Offline chapter draft (EXPAND this — add depth, diagrams, examples; do NOT summarize or shorten):\n'
            '$offlineDraft\n\n'
            'Write the complete expanded textbook chapter. Include all sections from the draft plus richer prose, '
            'more worked examples, and ASCII diagrams. Minimum 4000 words.',
      },
    ];
  }

  /// One-shot full textbook chapter (non-streaming).
  Future<String> physicsProfessorTextbookChapter({
    required String levelLabel,
    required String courseTitle,
    required PhysicsTopic topic,
    required PhysicsCourse course,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      _physicsProfessorLectureMessages(
        levelLabel: levelLabel,
        courseTitle: courseTitle,
        topicTitle: topic.title,
        hook: topic.hook,
        topic: topic,
        course: course,
      ),
      temperature: 0.4,
      maxTokens: 12000,
      premium: premium,
    );
  }

  Stream<String> physicsProfessorLectureStream({
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String hook,
    required PhysicsTopic topic,
    required PhysicsCourse course,
    bool premium = false,
  }) async* {
    _requireKey();
    yield* _chatStream(
      _physicsProfessorLectureMessages(
        levelLabel: levelLabel,
        courseTitle: courseTitle,
        topicTitle: topicTitle,
        hook: hook,
        topic: topic,
        course: course,
      ),
      temperature: 0.45,
      maxTokens: 12000,
      premium: premium,
    );
  }

  Future<String> physicsProfessorAnswer({
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String lectureContext,
    required String question,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': AiProfessorPrompts.answerSystem(
            role: 'a physics professor ($levelLabel level)',
          ),
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nTopic: $topicTitle\n\nLecture:\n$lectureContext\n\nQuestion: $question',
        },
      ],
      temperature: 0.35,
      maxTokens: 550,
      premium: premium,
    );
  }

  /// Multiple-choice quiz on a physics topic — textbook-style definitions and applications.
  Future<List<QuizQuestion>> physicsQuizFromTopic({
    required String levelLabel,
    required String courseTitle,
    required PhysicsCourse course,
    required PhysicsTopic topic,
    int questionCount = 15,
    bool premium = false,
  }) async {
    _requireKey();
    final String outline = PhysicsTopicKnowledgeEngine.lectureOutline(course: course, topic: topic);
    final StringBuffer brief = StringBuffer()
      ..writeln('Level: $levelLabel')
      ..writeln('Course: $courseTitle')
      ..writeln('Topic: ${topic.title}')
      ..writeln()
      ..writeln(outline);
    final String topicBrief = brief.toString();

    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You write a multiple-choice physics quiz from the provided topic material. '
              'Questions must read like a university textbook review section: precise definitions, '
              'symbol meaning, unit checks, conceptual reasoning, numerical estimation, and application to the hook scenario. '
              'Use \$...\$ for inline math in prompts and options when needed. '
              'Return ONLY valid JSON: '
              '{"questions":[{"prompt":"...","options":["A","B","C","D"],"correctIndex":0}]} '
              'Create exactly $questionCount questions. Each needs 4 options and correctIndex 0-3. '
              'Mix question types: definitions, symbol identification, formula selection, unit/dimensional analysis, '
              'conceptual traps, graph interpretation where relevant, worked-problem setup, and real-world application. '
              'No duplicate prompts. One clearly correct answer per question. Distractors must be plausible but wrong.',
        },
        <String, String>{
          'role': 'user',
          'content': topicBrief,
        },
      ],
      temperature: 0.35,
      maxTokens: 5200,
      premium: premium,
    );
    final Map<String, dynamic> json = decodeAiJson(content);
    final List<dynamic> raw = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map((dynamic item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
        .where((QuizQuestion q) => q.prompt.isNotEmpty && q.options.length >= 2)
        .toList();
  }

  /// Expand topic formulas with textbook worked examples and applications.
  Future<String> physicsFormulaNotebookExpand({
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String topicSummary,
    required String baseFormulas,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a physics textbook author ($levelLabel level). '
              'Expand the provided formula notebook into a complete textbook-style reference page.\n\n'
              'Keep ALL base formulas. Use markdown with:\n'
              '## Formula Notebook — [topic]\n'
              '### Overview\n'
              '### Governing Relations (numbered, with \$\$display\$\$ equations)\n'
              'For each: **Symbols**, **When to use**, **Unit check**, **Limiting case**\n'
              '### Worked Example (one numerical example using the formulas)\n'
              '### Common Mistakes\n'
              '### Summary\n'
              'Write like a printed textbook. Use \$ for inline math.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nTopic: $topicTitle\n\nSummary:\n$topicSummary\n\nBase formulas:\n$baseFormulas',
        },
      ],
      temperature: 0.35,
      maxTokens: 1800,
      premium: premium,
    );
  }

  /// AI lab instructor — setup checks, safety, and next experiment step.
  Future<String> physicsLabInstructorFeedback({
    required String simulationLabel,
    required String topicTitle,
    required String mission,
    required String metrics,
    required String status,
    required String studentQuestion,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a university physics lab instructor inside an interactive simulator ($simulationLabel). '
              'Speak like a real lab TA: direct, safety-aware, encouraging discovery. '
              'Reference the student\'s measured numbers. '
              '2-4 short paragraphs. Markdown OK. '
              'If parameters are dangerous (high current, crash energy), warn clearly.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Topic: $topicTitle\nMission: $mission\nStatus: $status\n\nMeasurements:\n$metrics\n\nStudent: $studentQuestion',
        },
      ],
      temperature: 0.4,
      maxTokens: 450,
      premium: premium,
    );
  }

  /// Grade a formal experiment report like a university professor.
  Future<String> physicsExperimentGrade({
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String reportMarkdown,
    bool premium = false,
  }) async {
    _requireKey();
    final String clipped = reportMarkdown.length > 10000 ? reportMarkdown.substring(0, 10000) : reportMarkdown;
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a university physics professor grading a lab report ($levelLabel). '
              'Use markdown:\n'
              '## Experiment Score: NN%\n'
              '### Strengths\n- bullets with ✓\n'
              '### Improve\n- bullets\n'
              '### Physics reasoning\nBrief comment on theory, data, and error analysis.\n'
              '### Next experiment\nOne suggestion.\n'
              'Be fair, specific, and textbook-professional.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Course: $courseTitle\nTopic: $topicTitle\n\nReport:\n$clipped',
        },
      ],
      temperature: 0.35,
      maxTokens: 700,
      premium: premium,
    );
  }

  Future<String> physicsModeActivity({
    required String modeLabel,
    required String levelLabel,
    required String courseTitle,
    required String topicTitle,
    required String studentInput,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a Virtual University physics activity engine for mode: $modeLabel ($levelLabel). '
              'Produce structured markdown appropriate to the mode (project brief, problems, competition round, '
              'lab report outline, research summary, career map, or Python simulation starter). '
              'Be specific to the topic. Encourage hands-on verification.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nTopic: $topicTitle\n\nStudent input / state:\n$studentInput',
        },
      ],
      temperature: 0.5,
      maxTokens: 1200,
      premium: premium,
    );
  }

  Future<String> engineeringDesignReview({
    required String majorName,
    required String courseTitle,
    required String challenge,
    required String studentDesign,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a senior design reviewer mentoring a beginner ($majorName). '
              'Be rigorous but encouraging. Use these sections in markdown:\n'
              '## What is working\n## Safety & failure modes\n## Efficiency & cost\n## Top 3 fixes (specific)\n## Beginner tip\n'
              'Name concrete parameters to change. Estimate qualitative risk (low/medium/high). '
              'If the design notes are vague, say exactly what numbers/units are missing. '
              'Do not rewrite the whole design.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Course: $courseTitle\nChallenge: $challenge\n\nStudent design notes:\n$studentDesign',
        },
      ],
      temperature: 0.3,
      maxTokens: 750,
      premium: premium,
    );
  }

  /// Run a small code snippet and return simulated stdout (Try It Yourself).
  Future<String> runCodeSnippet({
    required String language,
    required String code,
    required String taskContext,
    bool premium = false,
  }) async {
    _requireKey();
    final String content = await _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You simulate running code. Trace execution logically and return ONLY JSON: '
              '{"stdout":"printed output with newlines","success":true|false,"error":"if any"}. '
              'stdout should match what the program would print. No markdown.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Language: $language\nTask: $taskContext\n\nCode:\n$code',
        },
      ],
      temperature: 0.1,
      maxTokens: 500,
      premium: premium,
    );
    final Map<String, dynamic> json = decodeAiJson(content);
    if (json['success'] == false && (json['error'] as String?)?.isNotEmpty == true) {
      return 'Error: ${json['error']}';
    }
    return json['stdout'] as String? ?? '';
  }

  /// Optimal approach explanation after a submitted attempt.
  Future<String> leetcodeOptimalExplanation({
    required LeetcodeProblem problem,
    required String language,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Explain the optimal solution approach concisely (under 150 words). '
              'Include time/space complexity. Show pseudocode or key steps — not a full paste-ready solution.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Problem: ${problem.title}\n${problem.description}\nLanguage: $language',
        },
      ],
      temperature: 0.3,
      maxTokens: 400,
      premium: premium,
    );
  }

  /// Graduated LeetCode hint (1=clue … 4=near solution). Never full code on levels 1-3.
  Future<String> leetcodeHint({
    required LeetcodeProblem problem,
    required int hintLevel,
    required String language,
    String? currentCode,
    bool premium = false,
  }) async {
    _requireKey();
    final String levelGuide = switch (hintLevel) {
      1 => 'Give a small clue about the approach — no algorithm name yet.',
      2 => 'Suggest the algorithm or data structure family.',
      3 => 'Provide pseudocode steps — still no complete solution.',
      _ => 'Give a nearly complete solution outline with one part left for the student.',
    };
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': 'You give coding hints. $levelGuide Do not paste full working code unless hint level is 4.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Problem: ${problem.title}\n${problem.description}\nLanguage: $language\n'
              'Hint level: $hintLevel\nStudent code so far:\n${currentCode ?? "(empty)"}',
        },
      ],
      temperature: 0.35,
      maxTokens: 400,
      premium: premium,
    );
  }

  /// Short coaching reply for debug challenges (find the bug — do not dump a full fix).
  Future<String> debugCoachAnswer({
    required LeetcodeProblem problem,
    required String language,
    required String question,
    String? currentCode,
    bool premium = false,
  }) async {
    _requireKey();
    return _chat(
      <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are a debugging coach. Help the student find the bug in the starter code. '
              'Answer in 2-5 short sentences. Point at the suspicious line or logic, but do not paste a complete fixed solution unless they explicitly ask for the full fix.',
        },
        <String, String>{
          'role': 'user',
          'content':
              'Problem: ${problem.title}\n${problem.description}\nLanguage: $language\n\n'
              'Current code:\n${currentCode ?? "(empty)"}\n\nStudent asks: $question',
        },
      ],
      temperature: 0.35,
      maxTokens: 350,
      premium: premium,
    );
  }
}
