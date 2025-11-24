import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetFlowNotifier extends Notifier<bool> {
  static const String key = 'password_reset';
  @override
  bool build() {
    // Load initial state immediately
    _loadFromPrefs();
    return false; // Default to false until loaded
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the flag exists
    final value = prefs.getBool(key) ?? false;
    state = value;
  }

  Future<void> setResetFlow(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
    state = value;
  }
}

final resetFlowPersistenceProvider = NotifierProvider<ResetFlowNotifier, bool>(() {
  return ResetFlowNotifier();
});