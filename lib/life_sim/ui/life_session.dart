import 'dart:async';

import 'package:flutter/foundation.dart';

import '../avatar/avatar_profile.dart';
import '../game/life_game.dart';
import '../services/life_ai_service.dart';
import '../services/life_save_service.dart';

/// Wraps [LifeGame] for the UI: notifications, toasts, activity animations
/// and debounced auto-save.
class LifeSession extends ChangeNotifier {
  LifeSession(this.game, {LifeSaveService saver = const LifeSaveService()}) : _saver = saver {
    game.addListener(notifyListeners);
  }

  final LifeGame game;
  final LifeSaveService _saver;
  final NpcChatService npcChat = NpcChatService();

  String? toast;
  Timer? _toastTimer;
  Timer? _saveTimer;
  Timer? _activityTimer;
  AvatarAction? activity;
  bool disposed = false;

  AvatarEmotion get emotion => emotionForNeeds(
        happiness: game.needs.happiness,
        energy: game.needs.energy,
        hunger: game.needs.hunger,
      );

  /// Shows a transient message.
  void say(String message) {
    toast = message;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 3200), () {
      toast = null;
      if (!disposed) notifyListeners();
    });
    notifyListeners();
  }

  /// Reports an [ActionResult] as a toast and schedules a save.
  ActionResult report(ActionResult r, {AvatarAction? animate}) {
    say(r.message);
    if (r.ok && animate != null) playActivity(animate);
    changed();
    return r;
  }

  void playActivity(AvatarAction a, {Duration d = const Duration(milliseconds: 1800)}) {
    activity = a;
    _activityTimer?.cancel();
    _activityTimer = Timer(d, () {
      activity = null;
      if (!disposed) notifyListeners();
    });
    notifyListeners();
  }

  /// Call after any state change.
  void changed() {
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 3), saveNow);
  }

  Future<void> saveNow() async {
    try {
      await _saver.save(game);
    } catch (_) {}
  }

  @override
  void dispose() {
    disposed = true;
    _toastTimer?.cancel();
    _activityTimer?.cancel();
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      unawaited(saveNow());
    }
    game.removeListener(notifyListeners);
    super.dispose();
  }
}
