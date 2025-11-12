import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Correct import path
import 'auth_repository.dart';

// Renamed from AutoDisposeAsyncNotifier to AsyncNotifier
class ForgotPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state to build
  }

  Future<void> sendResetEmail(String email) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => authRepository.sendPasswordResetEmail(email));
  }
}

// Renamed from AutoDisposeAsyncNotifierProvider to AsyncNotifierProvider.autoDispose
final forgotPasswordControllerProvider =
AsyncNotifierProvider.autoDispose<ForgotPasswordController, void>(() {
  return ForgotPasswordController();
});