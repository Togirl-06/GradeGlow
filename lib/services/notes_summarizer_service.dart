import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/course.dart';
import '../models/study_summary.dart';
import '../models/study_upload_input.dart';
import '../models/summary_categories.dart';
import '../utils/io_file_bytes.dart';
import '../utils/pdf_text_extractor.dart';
import '../utils/pptx_text_extractor.dart';
import '../utils/premium_access.dart';
import '../utils/study_file_types.dart';
import '../utils/study_limits.dart';
import '../widgets/my_courses_section.dart';
import 'auth_service.dart';
import 'flashcard_service.dart';
import 'mic_capture_service.dart';
import 'openai_service.dart';
import 'openai_whisper_service.dart';
import 'subscription_service.dart';
import 'user_service.dart';

class NotesSummarizerService extends ChangeNotifier {
  NotesSummarizerService(this._auth, this._openAi, this._flashcards, this._subscription, this._users);

  final AuthService _auth;
  final OpenAiService _openAi;
  final FlashcardService _flashcards;
  final SubscriptionService _subscription;
  final UserService _users;
  final OpenAiWhisperService _whisper = OpenAiWhisperService();
  bool _isSummarizing = false;
  bool get isSummarizing => _isSummarizing;

  final List<StudySummary> _demoSummaries = <StudySummary>[];
  final List<SummarySubject> _demoSubjects = <SummarySubject>[
    SummarySubject(id: 'general', name: SummarySubjects.defaultSubject, createdAt: DateTime.now()),
  ];

  Stream<List<SummarySubject>> watchSubjects() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<SummarySubject>>.value(<SummarySubject>[]);

    if (!AppConfig.hasFirebase) {
      return Stream<List<SummarySubject>>.multi((StreamController<List<SummarySubject>> controller) {
        void emit() => controller.add(List<SummarySubject>.from(_demoSubjects));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summary_subjects')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => SummarySubject.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<SummarySubject> createSubject(String name) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to create a subject.');

    final String trimmed = name.trim();
    if (trimmed.isEmpty) throw Exception('Enter a subject name.');

    final SummarySubject subject = SummarySubject(
      id: AppConfig.hasFirebase
          ? FirebaseFirestore.instance.collection('users').doc(uid).collection('summary_subjects').doc().id
          : 'demo-subject-${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
      createdAt: DateTime.now(),
    );

    if (!AppConfig.hasFirebase) {
      if (_demoSubjects.any((SummarySubject s) => s.name.toLowerCase() == trimmed.toLowerCase())) {
        throw Exception('That subject already exists.');
      }
      _demoSubjects.add(subject);
      notifyListeners();
      return subject;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summary_subjects')
        .doc(subject.id)
        .set(subject.toMap());
    return subject;
  }

  Future<void> deleteSubject(String name, {required bool deleteSummaries}) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == SummarySubjects.defaultSubject) return;

    if (!AppConfig.hasFirebase) {
      _demoSubjects.removeWhere((SummarySubject s) => s.name == trimmed);
      if (deleteSummaries) {
        _demoSummaries.removeWhere((StudySummary s) => s.category == trimmed);
      } else {
        for (int i = 0; i < _demoSummaries.length; i++) {
          if (_demoSummaries[i].category == trimmed) {
            _demoSummaries[i] = _demoSummaries[i].copyWith(category: SummarySubjects.defaultSubject);
          }
        }
      }
      notifyListeners();
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> summaries = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .where('category', isEqualTo: trimmed)
        .get();

    if (deleteSummaries) {
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in summaries.docs) {
        await doc.reference.delete();
      }
    } else {
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in summaries.docs) {
        await doc.reference.update(<String, dynamic>{'category': SummarySubjects.defaultSubject});
      }
    }

    final QuerySnapshot<Map<String, dynamic>> subjects = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summary_subjects')
        .where('name', isEqualTo: trimmed)
        .get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in subjects.docs) {
      await doc.reference.delete();
    }
  }

  List<String> mergeSubjectNames(List<SummarySubject> stored, List<StudySummary> summaries) {
    final Set<String> names = <String>{
      SummarySubjects.defaultSubject,
      ...stored.map((SummarySubject s) => s.name),
      ...summaries.map((StudySummary s) => s.category),
    };
    return SummarySubjects.sortedNames(names);
  }

  /// Summaries linked to an enrolled course.
  static List<StudySummary> summariesForCourse(List<StudySummary> all, Course course) {
    final String code = course.code.trim().toUpperCase();
    if (code.isEmpty && course.id.isEmpty) return <StudySummary>[];

    final List<StudySummary> matches = all.where((StudySummary s) {
      if (course.id.isNotEmpty && s.courseId.isNotEmpty && s.courseId == course.id) return true;
      if (code.isNotEmpty && s.courseCode.trim().toUpperCase() == code) return true;
      if (code.isNotEmpty && s.title.trim().toUpperCase().contains(code)) return true;
      return false;
    }).toList();
    matches.sort((StudySummary a, StudySummary b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  static String categoryForCourse(Course course) {
    final String semester = course.semester.trim().isEmpty ? 'Other' : course.semester.trim();
    return semesterBoxTitle(semester);
  }

  Future<StudySummary> summarizeForCourse({
    required Course course,
    required String title,
    required String fileName,
    required int byteLength,
    required String mimeType,
    Uint8List? bytes,
    String? filePath,
  }) {
    return summarize(
      title: title,
      fileName: fileName,
      byteLength: byteLength,
      mimeType: mimeType,
      bytes: bytes,
      filePath: filePath,
      category: categoryForCourse(course),
      courseCode: course.code,
      courseId: course.id,
    );
  }

  Future<StudySummary> summarizeForCourseFromAudio({
    required Course course,
    required String title,
    required String audioFilePath,
    String? transcript,
  }) {
    return summarizeAudio(
      title: title,
      audioFilePath: audioFilePath,
      category: categoryForCourse(course),
      courseCode: course.code,
      courseId: course.id,
      transcript: transcript,
    );
  }

  Future<StudySummary> summarizeForCourseFromText({
    required Course course,
    required String title,
    required String text,
  }) {
    return summarizeFromText(
      title: title,
      text: text,
      category: categoryForCourse(course),
      courseCode: course.code,
      courseId: course.id,
    );
  }

  /// Combine multiple uploaded files into one study set.
  Future<StudySummary> summarizeMultipleForCourse({
    required Course course,
    required String title,
    required List<StudyUploadInput> files,
  }) async {
    if (files.isEmpty) throw Exception('Choose at least one file.');

    if (files.length == 1) {
      final StudyUploadInput file = files.first;
      final String ext = file.fileName.split('.').last.toLowerCase();
      if (StudyFileTypes.isAudioVideo(ext)) {
        final String transcript = await _transcribeUpload(file);
        return summarizeForCourseFromAudio(
          course: course,
          title: title,
          audioFilePath: file.filePath ?? file.fileName,
          transcript: transcript,
        );
      }
      return summarizeForCourse(
        course: course,
        title: title,
        fileName: file.fileName,
        byteLength: await _uploadByteLength(file),
        mimeType: _mimeTypeForFile(file.fileName),
        bytes: file.bytes,
        filePath: file.filePath,
      );
    }

    final StringBuffer combined = StringBuffer();
    for (int i = 0; i < files.length; i++) {
      final StudyUploadInput file = files[i];
      final String extracted = await extractSourceText(file);
      combined.writeln('## File ${i + 1}: ${file.fileName}');
      combined.writeln();
      combined.writeln(extracted.trim());
      if (i < files.length - 1) combined.writeln('\n---\n');
    }

    return summarizeForCourseFromText(
      course: course,
      title: title,
      text: combined.toString(),
    );
  }

  Future<String> extractSourceText(StudyUploadInput file) async {
    final String ext = file.fileName.split('.').last.toLowerCase();

    if (StudyFileTypes.isPdf(ext)) {
      if (file.filePath != null) return PdfTextExtractor.fromPath(file.filePath!);
      if (file.bytes != null) return PdfTextExtractor.fromBytes(file.bytes!, fileName: file.fileName);
      throw Exception('Could not read ${file.fileName}.');
    }

    if (ext == 'pptx') {
      if (file.filePath != null) return PptxTextExtractor.fromPath(file.filePath!);
      if (file.bytes != null) return PptxTextExtractor.fromBytes(file.bytes!, fileName: file.fileName);
      throw Exception('Could not read ${file.fileName}.');
    }

    if (ext == 'ppt') {
      throw Exception('${file.fileName}: older .ppt files are not supported. Save as .pptx or PDF.');
    }

    if (StudyFileTypes.isImage(ext)) {
      final Uint8List? bytes = file.bytes ??
          (file.filePath != null ? await readFileBytes(file.filePath!) : null);
      if (bytes == null) throw Exception('Could not read ${file.fileName}.');
      return _openAi.extractTextFromImage(
        imageBytes: bytes,
        mimeType: _imageMimeType(ext),
        fileName: file.fileName,
      );
    }

    if (StudyFileTypes.isAudioVideo(ext)) {
      return _transcribeUpload(file);
    }

    throw Exception('Unsupported file type: ${file.fileName}');
  }

  Future<String> _transcribeUpload(StudyUploadInput file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      return _whisper.transcribeBytes(file.bytes!, fileName: file.fileName);
    }
    if (kIsWeb) {
      final Uint8List? cached = MicCaptureService.instance.lastWavBytes;
      if (cached != null && cached.isNotEmpty) {
        return _whisper.transcribeBytes(cached, fileName: file.fileName);
      }
      throw Exception(
        'Recording data is not available in this browser. Use Record again, or paste notes as text.',
      );
    }
    if (file.filePath != null && file.filePath!.isNotEmpty) {
      return _whisper.transcribeFile(file.filePath!);
    }
    throw Exception('Could not read ${file.fileName}.');
  }

  Future<String> _resolveAudioTranscript(String audioFilePath) async {
    if (kIsWeb) {
      if (audioFilePath.startsWith('blob:') ||
          audioFilePath.startsWith('http://') ||
          audioFilePath.startsWith('https://')) {
        return _whisper.transcribeFile(audioFilePath);
      }
      final Uint8List? cached = MicCaptureService.instance.lastWavBytes;
      if (cached != null && cached.isNotEmpty) {
        return _whisper.transcribeBytes(cached, fileName: 'recording.wav');
      }
      throw Exception(
        'Recording data is not available in this browser. Use Record again, or paste notes as text.',
      );
    }
    return _whisper.transcribeFile(audioFilePath);
  }

  Future<int> _uploadByteLength(StudyUploadInput file) async {
    if (file.bytes != null) return file.bytes!.length;
    if (file.filePath != null) return fileByteLength(file.filePath!);
    return 0;
  }

  static String _mimeTypeForFile(String fileName) {
    final String ext = fileName.split('.').last.toLowerCase();
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'pptx') return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    if (ext == 'ppt') return 'application/vnd.ms-powerpoint';
    if (StudyFileTypes.isImage(ext)) return 'image/$ext';
    return 'application/octet-stream';
  }

  static String _imageMimeType(String ext) {
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  Future<CourseStudyUsage> _courseUsage({required String courseId, required String courseCode}) async {
    final List<StudySummary> all = await watchSummaries().first;
    final Course course = StudyLimits.courseLookup(courseId: courseId, courseCode: courseCode);
    return StudyLimits.usageForCourse(all, course, _subscription.isPremium);
  }

  Future<void> _assertCanCreateStudySet({required String courseId, required String courseCode}) async {
    if (_subscription.isPremium) return;

    if (!await _users.canSummarize(_subscription.plan)) {
      throw PremiumRequiredException(StudyLimits.dailySummarizeLimitReached);
    }

    final CourseStudyUsage usage = await _courseUsage(courseId: courseId, courseCode: courseCode);
    if (!StudyLimits.canCreateStudySet(usage)) {
      throw PremiumRequiredException(StudyLimits.studySetLimitReached);
    }
  }

  Future<({int flashcardCount, int quizCount})> _generationBudget({
    required String courseId,
    required String courseCode,
    int existingFlashcards = 0,
    int existingQuizQuestions = 0,
  }) async {
    if (_subscription.isPremium) {
      return (
        flashcardCount: StudyLimits.premiumFlashcardsPerGeneration,
        quizCount: StudyLimits.premiumQuizQuestionsPerGeneration,
      );
    }
    final CourseStudyUsage usage = await _courseUsage(courseId: courseId, courseCode: courseCode);
    return StudyLimits.generationBudget(
      usage: usage,
      isPremium: false,
      existingFlashcards: existingFlashcards,
      existingQuizQuestions: existingQuizQuestions,
    );
  }

  List<Map<String, String>> _parseAndTrimFlashcards(
    dynamic raw,
    int maxCount,
  ) {
    if (maxCount <= 0) return <Map<String, String>>[];
    return _parseCards(raw).take(maxCount).toList();
  }

  List<Map<String, dynamic>> _parseAndTrimQuizzes(
    dynamic raw,
    int maxCount,
  ) {
    if (maxCount <= 0) return <Map<String, dynamic>>[];
    return _parseQuizzes(raw).take(maxCount).toList();
  }

  Future<StudySummary> summarizeFromText({
    required String title,
    required String text,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to summarize notes.');

    final String trimmed = text.trim();
    if (trimmed.length < 40) {
      throw Exception('Add more content — at least a few sentences.');
    }

    await _assertCanCreateStudySet(courseId: courseId, courseCode: courseCode);
    final ({int flashcardCount, int quizCount}) budget =
        await _generationBudget(courseId: courseId, courseCode: courseCode);

    _isSummarizing = true;
    notifyListeners();

    try {
      final Map<String, dynamic> json = await _openAi.analyzeDocument(
        title: title,
        extractedText: trimmed,
        flashcardCount: budget.flashcardCount,
        quizCount: budget.quizCount,
        includeStudyMaterials: budget.flashcardCount > 0 || budget.quizCount > 0,
        premium: _subscription.isPremium,
      );

      return _saveSummary(
        uid: uid,
        title: title,
        category: category,
        summary: _coerceSummaryText(json['summary'] ?? json['cheatSheet']),
        keyPoints: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(json['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(json['quizQuestions'], budget.quizCount),
        saveFlashcardsToDeck: false,
        courseCode: courseCode.isNotEmpty ? courseCode : title,
        courseId: courseId,
        sourceText: trimmed,
      );
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  Future<StudySummary> summarizeAudio({
    required String title,
    required String audioFilePath,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
    String? transcript,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to summarize notes.');

    await _assertCanCreateStudySet(courseId: courseId, courseCode: courseCode);
    final ({int flashcardCount, int quizCount}) budget =
        await _generationBudget(courseId: courseId, courseCode: courseCode);

    _isSummarizing = true;
    notifyListeners();

    try {
      final String resolvedTranscript = transcript?.trim().isNotEmpty == true
          ? transcript!.trim()
          : await _resolveAudioTranscript(audioFilePath);
      final Map<String, dynamic> json = await _openAi.analyzeDocument(
        title: title,
        extractedText: resolvedTranscript,
        flashcardCount: budget.flashcardCount,
        quizCount: budget.quizCount,
        includeStudyMaterials: budget.flashcardCount > 0 || budget.quizCount > 0,
        premium: _subscription.isPremium,
      );

      return _saveSummary(
        uid: uid,
        title: title,
        category: category,
        summary: _coerceSummaryText(json['summary'] ?? json['cheatSheet']),
        keyPoints: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(json['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(json['quizQuestions'], budget.quizCount),
        saveFlashcardsToDeck: false,
        courseCode: courseCode.isNotEmpty ? courseCode : title,
        courseId: courseId,
        sourceText: resolvedTranscript,
      );
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  Stream<List<StudySummary>> watchSummaries() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<StudySummary>>.value(<StudySummary>[]);

    if (!AppConfig.hasFirebase) {
      return Stream<List<StudySummary>>.multi((StreamController<List<StudySummary>> controller) {
        void emit() => controller.add(List<StudySummary>.from(_demoSummaries));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => StudySummary.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<StudySummary> summarizePdf({
    required String title,
    required String fileName,
    Uint8List? bytes,
    String? filePath,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to summarize notes.');

    await _assertCanCreateStudySet(courseId: courseId, courseCode: courseCode);
    final ({int flashcardCount, int quizCount}) budget =
        await _generationBudget(courseId: courseId, courseCode: courseCode);

    _isSummarizing = true;
    notifyListeners();

    try {
      final String extracted = (bytes != null)
          ? await PdfTextExtractor.fromBytes(bytes, fileName: fileName)
          : await PdfTextExtractor.fromPath(filePath!);
      if (extracted.startsWith('PDF text extraction is not available')) {
        throw Exception(extracted);
      }
      final Map<String, dynamic> json = await _openAi.analyzeDocument(
        title: title,
        extractedText: extracted,
        flashcardCount: budget.flashcardCount,
        quizCount: budget.quizCount,
        includeStudyMaterials: budget.flashcardCount > 0 || budget.quizCount > 0,
        premium: _subscription.isPremium,
      );

      return _saveSummary(
        uid: uid,
        title: title,
        category: category,
        summary: _coerceSummaryText(json['summary'] ?? json['cheatSheet']),
        keyPoints: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(json['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(json['quizQuestions'], budget.quizCount),
        saveFlashcardsToDeck: true,
        courseCode: courseCode.isNotEmpty ? courseCode : title,
        courseId: courseId,
        sourceText: extracted,
      );
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  Future<StudySummary> summarizePowerPoint({
    required String title,
    required String fileName,
    Uint8List? bytes,
    String? filePath,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to summarize notes.');

    final String ext = fileName.split('.').last.toLowerCase();
    if (ext == 'ppt') {
      throw Exception('Older .ppt files are not supported. Save as .pptx or PDF and try again.');
    }

    await _assertCanCreateStudySet(courseId: courseId, courseCode: courseCode);
    final ({int flashcardCount, int quizCount}) budget =
        await _generationBudget(courseId: courseId, courseCode: courseCode);

    _isSummarizing = true;
    notifyListeners();

    try {
      final String extracted = (bytes != null)
          ? await PptxTextExtractor.fromBytes(bytes, fileName: fileName)
          : await PptxTextExtractor.fromPath(filePath!);
      final Map<String, dynamic> json = await _openAi.analyzeDocument(
        title: title,
        extractedText: extracted,
        flashcardCount: budget.flashcardCount,
        quizCount: budget.quizCount,
        includeStudyMaterials: budget.flashcardCount > 0 || budget.quizCount > 0,
        premium: _subscription.isPremium,
      );

      return _saveSummary(
        uid: uid,
        title: title,
        category: category,
        summary: _coerceSummaryText(json['summary'] ?? json['cheatSheet']),
        keyPoints: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(json['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(json['quizQuestions'], budget.quizCount),
        saveFlashcardsToDeck: false,
        courseCode: courseCode.isNotEmpty ? courseCode : title,
        courseId: courseId,
        sourceText: extracted,
      );
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  Future<StudySummary> summarizeImage({
    required String title,
    required Uint8List bytes,
    required String fileName,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to summarize notes.');

    await _assertCanCreateStudySet(courseId: courseId, courseCode: courseCode);
    final ({int flashcardCount, int quizCount}) budget =
        await _generationBudget(courseId: courseId, courseCode: courseCode);

    _isSummarizing = true;
    notifyListeners();

    try {
      final String ext = fileName.split('.').last.toLowerCase();
      final String mimeType = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

      final Map<String, dynamic> json = await _openAi.analyzeDocumentFromImage(
        title: title,
        imageBytes: bytes,
        mimeType: mimeType,
      );
      final String summaryText = _coerceSummaryText(json['summary'] ?? json['cheatSheet']);

      Map<String, dynamic> materials = <String, dynamic>{};
      if (budget.flashcardCount > 0 || budget.quizCount > 0) {
        materials = await _openAi.generateStudyMaterialsFromText(
          title: title,
          summaryText: summaryText,
          flashcardCount: budget.flashcardCount,
          quizCount: budget.quizCount,
        );
      }

      return _saveSummary(
        uid: uid,
        title: title,
        category: category,
        summary: summaryText,
        keyPoints: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(materials['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(materials['quizQuestions'], budget.quizCount),
        saveFlashcardsToDeck: false,
        courseCode: courseCode.isNotEmpty ? courseCode : title,
        courseId: courseId,
        sourceText: summaryText,
      );
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  /// Legacy API used by existing screen.
  Future<StudySummary> summarize({
    required String title,
    required String fileName,
    required int byteLength,
    required String mimeType,
    Uint8List? bytes,
    String? filePath,
    String category = SummarySubjects.defaultSubject,
    String courseCode = '',
    String courseId = '',
  }) async {
    final String ext = fileName.split('.').last.toLowerCase();
    final bool isPdf = mimeType == 'application/pdf' || ext == 'pdf';
    final bool isPowerPoint = mimeType.contains('presentation') || StudyFileTypes.isPowerPoint(ext);

    if (isPdf && (bytes != null || filePath != null)) {
      return summarizePdf(
        title: title,
        bytes: bytes,
        filePath: filePath,
        fileName: fileName,
        category: category,
        courseCode: courseCode,
        courseId: courseId,
      );
    }
    if (isPowerPoint && (bytes != null || filePath != null)) {
      return summarizePowerPoint(
        title: title,
        bytes: bytes,
        filePath: filePath,
        fileName: fileName,
        category: category,
        courseCode: courseCode,
        courseId: courseId,
      );
    }
    if (mimeType.startsWith('image/') || StudyFileTypes.isImage(ext)) {
      final Uint8List? imageBytes =
          bytes ?? (filePath != null ? await readFileBytes(filePath) : null);
      if (imageBytes == null) {
        throw Exception('Could not read that image.');
      }
      return summarizeImage(
        title: title,
        bytes: imageBytes,
        fileName: fileName,
        category: category,
        courseCode: courseCode,
        courseId: courseId,
      );
    }
    throw Exception('Upload a PDF, PowerPoint, or image to summarize.');
  }

  Future<StudySummary> _saveSummary({
    required String uid,
    required String title,
    required String summary,
    required List<String> keyPoints,
    String category = SummarySubjects.defaultSubject,
    List<Map<String, String>> flashcards = const <Map<String, String>>[],
    List<Map<String, dynamic>> quizQuestions = const <Map<String, dynamic>>[],
    bool saveFlashcardsToDeck = false,
    String courseCode = '',
    String courseId = '',
    String sourceText = '',
  }) async {
    final StudySummary studySummary = StudySummary(
      id: AppConfig.hasFirebase
          ? FirebaseFirestore.instance.collection('users').doc(uid).collection('summaries').doc().id
          : 'demo-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      cheatSheet: summary,
      keyConcepts: keyPoints,
      createdAt: DateTime.now(),
      category: category,
      courseCode: courseCode,
      courseId: courseId,
      sourceText: sourceText,
      flashcards: flashcards,
      quizQuestions: quizQuestions,
    );

    if (saveFlashcardsToDeck) {
      for (int i = 0; i < flashcards.length; i++) {
        final Map<String, String> card = flashcards[i];
        await _flashcards.addCard(
          questionId: 'pdf-${studySummary.id}-$i',
          front: card['front'] ?? '',
          back: card['back'] ?? '',
          courseCode: courseCode.isNotEmpty ? courseCode : 'General',
        );
      }
    }

    if (!AppConfig.hasFirebase) {
      _demoSummaries.insert(0, studySummary);
      await _users.recordSummarize(_subscription.plan);
      notifyListeners();
      return studySummary;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(studySummary.id)
        .set(studySummary.toMap());
    await _users.recordSummarize(_subscription.plan);
    return studySummary;
  }

  Future<void> deleteSummary(String summaryId) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    if (!AppConfig.hasFirebase) {
      _demoSummaries.removeWhere((StudySummary s) => s.id == summaryId);
      notifyListeners();
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .delete();
  }

  Future<void> renameSummary(String summaryId, String title) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to rename notes.');

    final String trimmed = title.trim();
    if (trimmed.isEmpty) throw Exception('Enter a title.');

    if (!AppConfig.hasFirebase) {
      final int index = _demoSummaries.indexWhere((StudySummary s) => s.id == summaryId);
      if (index < 0) return;
      _demoSummaries[index] = _demoSummaries[index].copyWith(title: trimmed);
      notifyListeners();
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .update(<String, dynamic>{'title': trimmed});
  }

  Future<void> updateCategory(String summaryId, String category) async {
    final String? uid = _auth.uid;
    if (uid == null) return;

    final String trimmed = category.trim();
    if (trimmed.isEmpty) return;

    if (!AppConfig.hasFirebase) {
      final int index = _demoSummaries.indexWhere((StudySummary s) => s.id == summaryId);
      if (index < 0) return;
      _demoSummaries[index] = _demoSummaries[index].copyWith(category: trimmed);
      notifyListeners();
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(summaryId)
        .update(<String, dynamic>{'category': trimmed});
  }

  /// Re-run AI on the original source (or existing notes) to refresh notes, flashcards, and quiz.
  Future<StudySummary> regenerateSummary(StudySummary summary) async {
    PremiumAccess.requirePremium(_subscription.plan, feature: PremiumFeature.studyGuides);

    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to regenerate notes.');

    final String source = summary.sourceText.trim().isNotEmpty ? summary.sourceText.trim() : summary.cheatSheet.trim();
    if (source.length < 40) {
      throw Exception('Not enough content to regenerate. Re-upload the original file.');
    }

    _isSummarizing = true;
    notifyListeners();

    try {
      final ({int flashcardCount, int quizCount}) budget = await _generationBudget(
        courseId: summary.courseId,
        courseCode: summary.courseCode,
        existingFlashcards: summary.flashcards.length,
        existingQuizQuestions: summary.quizQuestions.length,
      );

      final Map<String, dynamic> json = await _openAi.analyzeDocument(
        title: summary.title,
        extractedText: source,
        flashcardCount: budget.flashcardCount,
        quizCount: budget.quizCount,
        includeStudyMaterials: budget.flashcardCount > 0 || budget.quizCount > 0,
        premium: _subscription.isPremium,
      );

      final StudySummary updated = summary.copyWithMaterials(
        cheatSheet: json['summary'] as String? ?? json['cheatSheet'] as String? ?? summary.cheatSheet,
        keyConcepts: (json['keyPoints'] as List<dynamic>? ?? json['keyConcepts'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        flashcards: _parseAndTrimFlashcards(json['flashcards'], budget.flashcardCount),
        quizQuestions: _parseAndTrimQuizzes(json['quizQuestions'], budget.quizCount),
        sourceText: summary.sourceText.trim().isNotEmpty ? summary.sourceText : source,
      );

      return _persistSummaryUpdate(uid, updated);
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  Future<StudySummary> _persistSummaryUpdate(String uid, StudySummary updated) async {
    if (!AppConfig.hasFirebase) {
      final int index = _demoSummaries.indexWhere((StudySummary s) => s.id == updated.id);
      if (index >= 0) {
        _demoSummaries[index] = updated;
        notifyListeners();
      }
      return updated;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('summaries')
        .doc(updated.id)
        .update(updated.toMap());

    return updated;
  }

  /// Auto-generate flashcards & quiz from summary text if missing.
  Future<StudySummary> ensureStudyMaterials(
    StudySummary summary, {
    bool flashcardsOnly = false,
    bool quizOnly = false,
  }) async {
    final bool generateBoth = !flashcardsOnly && !quizOnly;

    if (flashcardsOnly && summary.flashcards.isNotEmpty) return summary;
    if (quizOnly && summary.quizQuestions.isNotEmpty) return summary;

    if (generateBoth) {
      final bool materialsComplete = _subscription.isPremium
          ? summary.flashcards.isNotEmpty && summary.quizQuestions.isNotEmpty
          : summary.flashcards.length >= 5 && summary.quizQuestions.length >= 3;
      if (materialsComplete) return summary;
    }

    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to study summaries.');

    if (!_subscription.isPremium) {
      final CourseStudyUsage usage = await _courseUsage(
        courseId: summary.courseId,
        courseCode: summary.courseCode,
      );
      if (flashcardsOnly && usage.flashcardRemaining == 0) {
        throw PremiumRequiredException(StudyLimits.flashcardLimitReached);
      }
      if (quizOnly && usage.quizRemaining == 0) {
        throw PremiumRequiredException(StudyLimits.quizLimitReached);
      }
      if (generateBoth && usage.flashcardRemaining == 0 && usage.quizRemaining == 0) {
        throw PremiumRequiredException(StudyLimits.flashcardLimitReached);
      }
    }

    _isSummarizing = true;
    notifyListeners();

    try {
      final ({int flashcardCount, int quizCount}) budget = await _generationBudget(
        courseId: summary.courseId,
        courseCode: summary.courseCode,
        existingFlashcards: summary.flashcards.length,
        existingQuizQuestions: summary.quizQuestions.length,
      );

      final int flashcardCount = flashcardsOnly || generateBoth ? budget.flashcardCount : 0;
      final int quizCount = quizOnly || generateBoth ? budget.quizCount : 0;

      if (flashcardCount <= 0 && quizCount <= 0) {
        return summary;
      }

      final Map<String, dynamic> json = await _openAi.generateStudyMaterialsFromText(
        title: summary.title,
        summaryText: summary.cheatSheet,
        flashcardCount: flashcardCount,
        quizCount: quizCount,
      );

      final List<Map<String, String>> flashcards =
          _parseAndTrimFlashcards(json['flashcards'], flashcardCount);
      final List<Map<String, dynamic>> quizQuestions =
          _parseAndTrimQuizzes(json['quizQuestions'], quizCount);

      final StudySummary updated = summary.copyWithMaterials(
        flashcards: flashcards.isNotEmpty ? flashcards : summary.flashcards,
        quizQuestions: quizQuestions.isNotEmpty ? quizQuestions : summary.quizQuestions,
        cheatSheet: summary.cheatSheet.isNotEmpty
            ? summary.cheatSheet
            : (json['summary'] as String? ?? ''),
        keyConcepts: summary.keyConcepts.isNotEmpty
            ? summary.keyConcepts
            : (json['keyPoints'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      );

      for (int i = 0; i < flashcards.length; i++) {
        final Map<String, String> card = flashcards[i];
        await _flashcards.addCard(
          questionId: 'summary-${summary.id}-$i',
          front: card['front'] ?? '',
          back: card['back'] ?? '',
          courseCode: summary.title,
        );
      }

      if (!AppConfig.hasFirebase) {
        final int index = _demoSummaries.indexWhere((StudySummary s) => s.id == summary.id);
        if (index >= 0) {
          _demoSummaries[index] = updated;
          notifyListeners();
        }
        return updated;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('summaries')
          .doc(summary.id)
          .update(<String, dynamic>{
        if (flashcards.isNotEmpty) 'flashcards': flashcards,
        if (quizQuestions.isNotEmpty) 'quizQuestions': quizQuestions,
      });

      return updated;
    } finally {
      _isSummarizing = false;
      notifyListeners();
    }
  }

  String _coerceSummaryText(dynamic value) {
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

  List<Map<String, String>> _parseCards(dynamic raw) {
    if (raw is! List) return <Map<String, String>>[];
    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> m) => <String, String>{
            'front': m['front']?.toString() ?? '',
            'back': m['back']?.toString() ?? '',
          },
        )
        .where((Map<String, String> c) => c['front']!.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _parseQuizzes(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw.whereType<Map>().map((Map<dynamic, dynamic> m) => m.map((dynamic k, dynamic v) => MapEntry(k.toString(), v))).toList();
  }
}
