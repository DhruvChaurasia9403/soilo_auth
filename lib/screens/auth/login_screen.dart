import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_repository.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../features/auth/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(); // Changed to Email
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginLoadingState = ref.watch(authControllerProvider); // Watch for general auth loading state

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        // If hasValue (e.g., signOut was successful) or userProvider changes (handled in main.dart)
        // navigation is implicitly handled by main.dart's Consumer
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.green.shade800,
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Use Email Address for Login
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text('Forgot Password?',
                      style: TextStyle(color: Colors.green.shade700)),
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
                      // Set loading state explicitly as AuthController is general, not login-specific
                      // If you want fine-grained login states, a dedicated LoginController would be better
                      ref.read(authControllerProvider.notifier).state = const AsyncValue.loading();

                      await authRepo.signInWithEmailPassword(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      // On success, the userProvider in main.dart will update,
                      // causing MyApp to rebuild and navigate to HomeScreen.
                      ref.read(authControllerProvider.notifier).state = const AsyncValue.data(null); // Clear loading state
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Failed: ${e.toString()}')),
                      );
                      ref.read(authControllerProvider.notifier).state = AsyncValue.error(e, StackTrace.current);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loginLoadingState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Don't have an account?
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text('Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.green.shade700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}