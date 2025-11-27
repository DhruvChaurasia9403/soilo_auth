import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginFlowNotifier extends Notifier<bool> {
  // Constant key to ensure main.dart and this provider use the exact same string
  static const String key = 'login_pending_2fa';

  @override
  bool build() {
    _loadFromPrefs();
    return false;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(key) ?? false;
  }

  // Call with true when starting 2FA, false when finished/cancelled
  Future<void> setPending(bool isPending) async {
    final prefs = await SharedPreferences.getInstance();
    if (isPending) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
    state = isPending;
  }
}

final loginFlowPersistenceProvider = NotifierProvider<LoginFlowNotifier, bool>(() {
  return LoginFlowNotifier();
});