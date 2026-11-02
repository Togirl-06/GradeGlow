import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A bookmarked Virtual University lesson or resource.
class VuBookmark {
  const VuBookmark({
    required this.id,
    required this.title,
    required this.lessonId,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String lessonId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'lessonId': lessonId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VuBookmark.fromMap(Map<String, dynamic> map) {
    return VuBookmark(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Highlighted passage tied to a lesson.
class VuHighlight {
  const VuHighlight({
    required this.id,
    required this.text,
    required this.lessonId,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String lessonId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'text': text,
    'lessonId': lessonId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VuHighlight.fromMap(Map<String, dynamic> map) {
    return VuHighlight(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      lessonId: map['lessonId'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Freeform student note for Virtual University study.
class VuNote {
  const VuNote({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.lessonId,
  });

  final String id;
  final String title;
  final String body;
  final String? lessonId;
  final DateTime createdAt;
  final DateTime updatedAt;

  VuNote copyWith({
    String? title,
    String? body,
    String? lessonId,
    DateTime? updatedAt,
  }) {
    return VuNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      lessonId: lessonId ?? this.lessonId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'lessonId': lessonId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VuNote.fromMap(Map<String, dynamic> map) {
    return VuNote(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      lessonId: map['lessonId'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Offline Virtual University notes, bookmarks, and highlights (SharedPreferences).
class VuNotesService extends ChangeNotifier {
  VuNotesService();

  static final VuNotesService instance = VuNotesService();

  static const String _storageKey = 'vu_student_notes_v1';

  final List<VuBookmark> _bookmarks = <VuBookmark>[];
  final List<VuHighlight> _highlights = <VuHighlight>[];
  final List<VuNote> _notes = <VuNote>[];
  bool _loaded = false;

  List<VuBookmark> get bookmarks => List<VuBookmark>.unmodifiable(_bookmarks);
  List<VuHighlight> get highlights =>
      List<VuHighlight>.unmodifiable(_highlights);
  List<VuNote> get notes => List<VuNote>.unmodifiable(_notes);
  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        _bookmarks
          ..clear()
          ..addAll(
            (json['bookmarks'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(VuBookmark.fromMap),
          );
        _highlights
          ..clear()
          ..addAll(
            (json['highlights'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(VuHighlight.fromMap),
          );
        _notes
          ..clear()
          ..addAll(
            (json['notes'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(VuNote.fromMap),
          );
      } catch (_) {
        // Corrupt payload — start fresh rather than crashing study tools.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = <String, dynamic>{
      'bookmarks': _bookmarks.map((VuBookmark b) => b.toMap()).toList(),
      'highlights': _highlights.map((VuHighlight h) => h.toMap()).toList(),
      'notes': _notes.map((VuNote n) => n.toMap()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<VuBookmark> addBookmark({
    required String title,
    required String lessonId,
  }) async {
    await ensureLoaded();
    final VuBookmark bookmark = VuBookmark(
      id: _newId(),
      title: title.trim(),
      lessonId: lessonId.trim(),
      createdAt: DateTime.now(),
    );
    _bookmarks.insert(0, bookmark);
    await _persist();
    notifyListeners();
    return bookmark;
  }

  Future<void> removeBookmark(String id) async {
    await ensureLoaded();
    _bookmarks.removeWhere((VuBookmark b) => b.id == id);
    await _persist();
    notifyListeners();
  }

  Future<VuHighlight> addHighlight({
    required String text,
    required String lessonId,
  }) async {
    await ensureLoaded();
    final VuHighlight highlight = VuHighlight(
      id: _newId(),
      text: text.trim(),
      lessonId: lessonId.trim(),
      createdAt: DateTime.now(),
    );
    _highlights.insert(0, highlight);
    await _persist();
    notifyListeners();
    return highlight;
  }

  Future<void> removeHighlight(String id) async {
    await ensureLoaded();
    _highlights.removeWhere((VuHighlight h) => h.id == id);
    await _persist();
    notifyListeners();
  }

  Future<VuNote> addNote({
    required String title,
    required String body,
    String? lessonId,
  }) async {
    await ensureLoaded();
    final DateTime now = DateTime.now();
    final VuNote note = VuNote(
      id: _newId(),
      title: title.trim(),
      body: body.trim(),
      lessonId: lessonId?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    await _persist();
    notifyListeners();
    return note;
  }

  Future<VuNote?> updateNote({
    required String id,
    String? title,
    String? body,
    String? lessonId,
  }) async {
    await ensureLoaded();
    final int index = _notes.indexWhere((VuNote n) => n.id == id);
    if (index < 0) return null;
    final VuNote updated = _notes[index].copyWith(
      title: title?.trim(),
      body: body?.trim(),
      lessonId: lessonId?.trim(),
      updatedAt: DateTime.now(),
    );
    _notes[index] = updated;
    await _persist();
    notifyListeners();
    return updated;
  }

  Future<void> removeNote(String id) async {
    await ensureLoaded();
    _notes.removeWhere((VuNote n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  /// Case-insensitive search across notes, bookmarks, and highlights.
  ({
    List<VuNote> notes,
    List<VuBookmark> bookmarks,
    List<VuHighlight> highlights,
  })
  search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return (notes: notes, bookmarks: bookmarks, highlights: highlights);
    }
    return (
      notes: _notes
          .where(
            (VuNote n) =>
                n.title.toLowerCase().contains(q) ||
                n.body.toLowerCase().contains(q) ||
                (n.lessonId?.toLowerCase().contains(q) ?? false),
          )
          .toList(),
      bookmarks: _bookmarks
          .where(
            (VuBookmark b) =>
                b.title.toLowerCase().contains(q) ||
                b.lessonId.toLowerCase().contains(q),
          )
          .toList(),
      highlights: _highlights
          .where(
            (VuHighlight h) =>
                h.text.toLowerCase().contains(q) ||
                h.lessonId.toLowerCase().contains(q),
          )
          .toList(),
    );
  }
}
