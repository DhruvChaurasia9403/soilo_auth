
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';

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
  }
}

final resetPasswordControllerProvider =
AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(() {
  return ResetPasswordController();
});