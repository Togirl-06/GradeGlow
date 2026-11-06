import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the simulator profile is stored. Local storage always; Firestore
/// (`users/{uid}/career_sim/profile`) when signed in.
abstract class CareerRepository {
  Future<Map<String, dynamic>?> loadLocal(String? uid);
  Future<void> saveLocal(String? uid, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> loadRemote(String uid);
  Future<void> saveRemote(String uid, Map<String, dynamic> json);

  /// Stores an uploaded resume file privately for [uid] and returns its path
  /// (`users/{uid}/resumes/...`). Returns '' when there is no signed-in user.
  Future<String> saveResumeFile(String? uid, String name, Uint8List bytes, String contentType);

  Future<void> deleteResumeFile(String path);
}

class DefaultCareerRepository implements CareerRepository {
  static String _key(String? uid) =>
      uid == null || uid.isEmpty ? 'career_sim_v1' : 'career_sim_v1_$uid';

  bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> loadLocal(String? uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key(uid));
    if (raw == null) return null;
    final Object? decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> saveLocal(String? uid, Map<String, dynamic> json) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool ok = await prefs.setString(_key(uid), jsonEncode(json));
    if (!ok) throw StateError('Could not write to device storage.');
  }

  DocumentReference<Map<String, dynamic>> _doc(String uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('career_sim')
      .doc('profile');

  @override
  Future<Map<String, dynamic>?> loadRemote(String uid) async {
    if (!_firebaseReady) return null;
    final DocumentSnapshot<Map<String, dynamic>> snap = await _doc(uid).get();
    final Object? raw = snap.data()?['data'];
    if (raw is! String) return null;
    final Object? decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> saveRemote(String uid, Map<String, dynamic> json) async {
    if (!_firebaseReady) return;
    await _doc(uid).set(<String, dynamic>{
      'data': jsonEncode(json),
      'updatedAtMs': json['updatedAtMs'],
      'schema': 1,
    });
  }

  @override
  Future<String> saveResumeFile(String? uid, String name, Uint8List bytes, String contentType) async {
    if (!_firebaseReady || uid == null || uid.isEmpty) return '';
    final String path = 'users/$uid/resumes/$name';
    await FirebaseStorage.instance.ref(path).putData(bytes, SettableMetadata(contentType: contentType));
    return path;
  }

  @override
  Future<void> deleteResumeFile(String path) async {
    if (!_firebaseReady || path.isEmpty) return;
    await FirebaseStorage.instance.ref(path).delete();
  }
}

/// In-memory repository for tests.
class MemoryCareerRepository implements CareerRepository {
  final Map<String, String> local = <String, String>{};
  final Map<String, String> remote = <String, String>{};
  bool failRemote = false;

  @override
  Future<Map<String, dynamic>?> loadLocal(String? uid) async {
    final String? raw = local[uid ?? ''];
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> saveLocal(String? uid, Map<String, dynamic> json) async {
    local[uid ?? ''] = jsonEncode(json);
  }

  @override
  Future<Map<String, dynamic>?> loadRemote(String uid) async {
    if (failRemote) throw StateError('offline');
    final String? raw = remote[uid];
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> saveRemote(String uid, Map<String, dynamic> json) async {
    if (failRemote) throw StateError('offline');
    remote[uid] = jsonEncode(json);
  }

  /// Stored resume files by path.
  final Map<String, Uint8List> files = <String, Uint8List>{};

  @override
  Future<String> saveResumeFile(String? uid, String name, Uint8List bytes, String contentType) async {
    final String path = 'users/${uid ?? 'local'}/resumes/$name';
    files[path] = bytes;
    return path;
  }

  @override
  Future<void> deleteResumeFile(String path) async {
    files.remove(path);
  }
}
