import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../game/life_game.dart';

/// Saves the life simulation to Firestore (`users/{uid}/life_sim/save`) when
/// signed in, always mirroring to local storage as an offline fallback.
class LifeSaveService {
  const LifeSaveService();

  static const String _localKey = 'gradeglow_life_sim_save_v1';

  DocumentReference<Map<String, dynamic>>? _doc() {
    if (!AppConfig.hasFirebase) return null;
    final User? u = FirebaseAuth.instance.currentUser;
    if (u == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(u.uid).collection('life_sim').doc('save');
  }

  Future<void> save(LifeGame game) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String payload = jsonEncode(game.toJson());
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setString(_localKey, jsonEncode(<String, Object?>{'savedAtMs': now, 'data': payload}));
    } catch (e) {
      if (kDebugMode) debugPrint('Life sim local save failed: $e');
    }
    final DocumentReference<Map<String, dynamic>>? doc = _doc();
    if (doc == null) return;
    try {
      await doc.set(<String, dynamic>{
        'savedAtMs': now,
        'data': payload,
        'name': game.avatar.name,
        'day': game.day,
        'version': LifeGame.saveVersion,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Life sim cloud save failed: $e');
    }
  }

  /// Newest of the cloud and local saves, or null.
  Future<LifeGame?> load() async {
    ({int ms, String data})? best;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      final String? raw = p.getString(_localKey);
      if (raw != null) {
        final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
        best = (ms: (m['savedAtMs'] as num?)?.toInt() ?? 0, data: m['data'] as String);
      }
    } catch (_) {}
    try {
      final DocumentReference<Map<String, dynamic>>? doc = _doc();
      if (doc != null) {
        final DocumentSnapshot<Map<String, dynamic>> s = await doc.get();
        final Map<String, dynamic>? m = s.data();
        if (m != null && m['data'] is String) {
          final int ms = (m['savedAtMs'] as num?)?.toInt() ?? 0;
          if (best == null || ms >= best.ms) best = (ms: ms, data: m['data'] as String);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Life sim cloud load failed: $e');
    }
    if (best == null) return null;
    try {
      return LifeGame.fromJson(Map<String, Object?>.from(jsonDecode(best.data) as Map));
    } catch (e) {
      if (kDebugMode) debugPrint('Life sim save corrupt: $e');
      return null;
    }
  }

  Future<void> delete() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.remove(_localKey);
    } catch (_) {}
    try {
      await _doc()?.delete();
    } catch (_) {}
  }
}
