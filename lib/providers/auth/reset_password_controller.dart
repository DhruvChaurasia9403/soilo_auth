
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_repository.dart';
import '../reset_flow_provider.dart';

class ResetPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state
  }

  Future<void> updateUserPassword(String newPassword) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    // 1. Update Password (must be logged in for this to work)
    final result = await AsyncValue.guard(
          () => authRepository.updateUserPassword(newPassword),
    );

    if (result.hasError) {
      state = result;
      return;
    }

    // 2. Cleanup Preferences
    ref.read(resetFlowPersistenceProvider.notifier).setResetFlow(false);

    // 3. Sign Out HERE (Atomic operation)
    // We sign out now because the password change is done.
    await authRepository.signOut();

    // 4. Set Success State
    // This triggers the listener in the UI
    state = const AsyncValue.data(null);
  }
}

final resetPasswordControllerProvider =
AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(() {
  return ResetPasswordController();
});