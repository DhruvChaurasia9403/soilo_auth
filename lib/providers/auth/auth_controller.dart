import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Correct import path
import '../../features/auth/auth_repository.dart';

// Provides the current User, or null if logged out.
final userProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// A notifier to handle general auth operations like sign out.
// Renamed from AutoDisposeAsyncNotifier to AsyncNotifier
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial async work needed for general auth controller
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => authRepository.signOut());
  }
}

// Renamed from AutoDisposeAsyncNotifierProvider to AsyncNotifierProvider.autoDispose
final authControllerProvider = AsyncNotifierProvider.autoDispose<AuthController, void>(() {
  return AuthController();
});