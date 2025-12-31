import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBypassNotifier extends StateNotifier<Set<String>> {
  static const String _storageKey = 'bypassed_apps';
  final SharedPreferences? _prefs;

  AppBypassNotifier(this._prefs) : super({}) {
    _loadBypassedApps();
  }

  Future<void> _loadBypassedApps() async {
    if (_prefs == null) return;

    final stored = _prefs!.getString(_storageKey);
    if (stored != null) {
      try {
        final List<dynamic> decoded = json.decode(stored);
        state = Set<String>.from(decoded);
      } catch (e) {
        state = {};
      }
    }
  }

  Future<void> _saveBypassedApps() async {
    if (_prefs == null) return;

    final encoded = json.encode(state.toList());
    await _prefs!.setString(_storageKey, encoded);
  }

  void addBypassedApp(String packageName) {
    state = {...state, packageName};
    _saveBypassedApps();
  }

  void removeBypassedApp(String packageName) {
    state = {...state}..remove(packageName);
    _saveBypassedApps();
  }

  void clearAll() {
    state = {};
    _saveBypassedApps();
  }

  List<String> getBypassedAppsList() {
    return state.toList();
  }
}

final appBypassProvider =
    StateNotifierProvider<AppBypassNotifier, Set<String>>((ref) {
  // این provider نیاز به SharedPreferences داره
  return AppBypassNotifier(null);
});

// Provider برای initialize کردن با SharedPreferences
final appBypassProviderWithPrefs =
    FutureProvider<AppBypassNotifier>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AppBypassNotifier(prefs);
});
