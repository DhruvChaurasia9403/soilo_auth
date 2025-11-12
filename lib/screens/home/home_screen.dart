import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_controller.dart'; // Import AuthController for logout

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user provider to get the current user info
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soilo Home'),
        backgroundColor: Colors.green.shade800,
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
                  const Text(
                    'Welcome to Soilo!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Logged in as: ${user.email ?? user.phoneNumber ?? 'User'}'),
                  if (user.uid != null) Text('User ID: ${user.uid}'),
                ],
              );
            }
            return const Text('Not logged in.'); // Should not happen if correctly routed
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}