
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_repository.dart';

class ResetPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state
  }

  Future<void> updateUserPassword(String newPassword) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
          () => authRepository.updateUserPassword(newPassword),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_password_reset');
    // await authRepository.signOut();
  }
}

final resetPasswordControllerProvider =
AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(() {
  return ResetPasswordController();
});