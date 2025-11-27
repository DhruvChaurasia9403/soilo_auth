import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth/auth_controller.dart'; // Import AuthController for logout

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user provider to get the current user info
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soilo Home'),
        // REMOVED: backgroundColor: Colors.green.shade800,
        // This is now handled by AppBarTheme
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              // After logout, the userProvider stream will emit null,
              // and our main.dart's Consumer will automatically navigate to login.
            },
          ),
        ],
      ),
      body: Center(
        child: userAsyncValue.when(
          data: (user) {
            if (user != null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Soilo!',
                    // UPDATED: Using the semantic style from TextTheme
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text('Logged in as: ${user.email ?? user.phoneNumber ?? 'User'}'),
                  Text('User ID: ${user.uid}'),
                ],
              );
            }
            // Should not happen if correctly routed
            return const Text('Not logged in.');
          },
          // This will automatically use your ProgressIndicatorThemeData
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}