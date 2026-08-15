import 'package:shared_preferences/shared_preferences.dart';

/// Persists expand/collapse choices until the user changes them.
class ExpandStateStore {
  ExpandStateStore._();

  static final ExpandStateStore instance = ExpandStateStore._();

  static const String _prefix = 'expand_state.';
  final Map<String, bool> _cache = <String, bool>{};

  Future<bool> isExpanded(String key, {bool defaultExpanded = true}) async {
    final bool? cached = _cache[key];
    if (cached != null) return cached;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool value = prefs.getBool('$_prefix$key') ?? defaultExpanded;
    _cache[key] = value;
    return value;
  }

  Future<void> setExpanded(String key, bool expanded) async {
    _cache[key] = expanded;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', expanded);
  }

  Future<bool> toggle(String key, {bool defaultExpanded = true}) async {
    final bool next = !(await isExpanded(key, defaultExpanded: defaultExpanded));
    await setExpanded(key, next);
    return next;
  }
}
