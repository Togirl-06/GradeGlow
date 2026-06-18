import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/ai_json.dart';
import '../utils/api_error_messages.dart';
import '../utils/document_text_chunker.dart';
import '../models/quiz_question.dart';

class OpenAiService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> tutorReply(
    List<Map<String, dynamic>> history,
    String userMessage, {
    String? courseContext,
    List<String> imageFilePaths = const <String>[],
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

    final String content = await _chatDynamic(messages, temperature: 0.7);
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
      final List<int> bytes = await File(path).readAsBytes();
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
  }) async {
    _requireKey();

    final List<String> chunks = DocumentTextChunker.chunk(extractedText);
    if (chunks.length == 1) {
      return _generateNotesFromChunk(
        title: title,
        chunkText: chunks.first,
        partIndex: 0,
        partCount: 1,
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
  }) async {
    _requireKey();

    final Map<String, dynamic> notes = await generateComprehensiveNotes(
      title: title,
      extractedText: extractedText,
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
    );

    return decodeAiJson(content);
  }

  /// Generate flashcards + quiz from an existing summary (Quizlet-style).
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
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'model': 'gpt-4o-mini',
      'messages': messages,
      'temperature': temperature,
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final http.Response response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final ApiErrorInfo info = ApiErrorMessages.fromOpenAiResponse(response.statusCode, response.body);
      throw Exception('${info.title}: ${info.message}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices = data['choices'] as List<dynamic>? ?? <dynamic>[];
    if (choices.isEmpty) {
      throw Exception('OpenAI returned an empty response.');
    }
    final Map<String, dynamic> message =
        (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>;
    final dynamic content = message['content'];
    if (content is String) return content;
    return content?.toString() ?? '';
  }

  Future<String> _chat(
    List<Map<String, String>> messages, {
    required double temperature,
    int? maxTokens,
  }) async {
    return _chatDynamic(
      messages.map((Map<String, String> m) => Map<String, dynamic>.from(m)).toList(),
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  void _requireKey() {
    if (!AppConfig.hasOpenAi) {
      throw Exception(
        'OpenAI is not configured. Add OPENAI_API_KEY to your .env file.',
      );
    }
  }
}
