import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vu_game_models.dart';

/// Local persistence for the reusable GradeGlow student avatar.
class VuGamePlayerStore {
  static const String _key = 'vu_game_player_v1';

  Future<VuGamePlayerAppearance> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null) return const VuGamePlayerAppearance();
    try {
      final Map<String, dynamic> json =
          Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return VuGamePlayerAppearance(
        displayName: json['displayName'] as String? ?? 'Student',
        skinTone: json['skinTone'] as int? ?? 0xFFE8B796,
        hairColor: json['hairColor'] as int? ?? 0xFF2C1810,
        outfitColor: json['outfitColor'] as int? ?? 0xFF10B981,
        hairStyle: json['hairStyle'] as String? ?? 'short',
      );
    } catch (_) {
      return const VuGamePlayerAppearance();
    }
  }

  Future<void> save(VuGamePlayerAppearance appearance) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, Object>{
        'displayName': appearance.displayName,
        'skinTone': appearance.skinTone,
        'hairColor': appearance.hairColor,
        'outfitColor': appearance.outfitColor,
        'hairStyle': appearance.hairStyle,
      }),
    );
  }
}
