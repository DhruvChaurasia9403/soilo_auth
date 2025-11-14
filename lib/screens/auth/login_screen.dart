import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_repository.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../features/auth/auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginLoadingState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        // REMOVED: backgroundColor: Colors.green.shade800,
        // This is now handled by your AppBarTheme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back!',
                // UPDATED: Using the semantic style from TextTheme
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Email Address
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  // REMOVED: border: OutlineInputBorder(),
                  // This is now handled by your InputDecorationTheme
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  // REMOVED: border: OutlineInputBorder(),
                  // This is now handled by your InputDecorationTheme
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                  // REMOVED: style: TextStyle(color: Colors.green.shade700)
                  // This is now handled by your TextButtonTheme
                ),
              ),
              const SizedBox(height: 24),
              // Login Button
              ElevatedButton(
                onPressed: loginLoadingState.isLoading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    final authRepo = ref.read(authRepositoryProvider);
                    try {
                      ref.read(authControllerProvider.notifier).state =
                      const AsyncValue.loading();

                      await authRepo.signInWithEmailPassword(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      ref.read(authControllerProvider.notifier).state =
                      const AsyncValue.data(null);
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Login Failed: ${e.toString()}')),
                      );
                      ref.read(authControllerProvider.notifier).state =
                          AsyncValue.error(e, StackTrace.current);
                    }
                  }
                },
                // REMOVED: style: ElevatedButton.styleFrom(...)
                // This is now handled by your ElevatedButtonTheme
                child: loginLoadingState.isLoading
                    ? const CircularProgressIndicator(
                  // This is correct, as your button theme
                  // sets the foregroundColor to white.
                  color: Colors.white,
                )
                    : const Text(
                  'LOGIN',
                  // REMOVED: style: TextStyle(...)
                  // This is now handled by the textStyle in
                  // your ElevatedButtonTheme
                ),
              ),
              const SizedBox(height: 16),
              // Don't have an account?
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text('Don\'t have an account? Sign Up'),
                // REMOVED: style: TextStyle(color: Colors.green.shade700)
                // This is now handled by your TextButtonTheme
              ),
            ],
          ),
        ),
      ),
    );
  }
}