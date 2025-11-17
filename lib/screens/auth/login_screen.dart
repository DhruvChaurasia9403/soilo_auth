import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// REMOVED: auth_repository.dart
// REMOVED: auth_controller.dart (we use login_controller now)
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../features/auth/login_controller.dart'; // 👈 ADD
import 'package:go_router/go_router.dart';
import 'otp_verification_screen.dart'; // 👈 ADD for VerificationPurpose

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController(); // 👈 RENAMED
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose(); // 👈 RENAMED
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the new login controller
    final loginState = ref.watch(loginControllerProvider);

    // Listen to the new login controller for navigation/errors
    ref.listen<AsyncValue<String?>>(
      loginControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        // This listener is now only for showing errors.
        // Navigation is handled in the onPressed callback via onCodeSent.
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // UPDATED: Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (e.g., +15551234567)',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.startsWith('+') ||
                      value.length < 10) {
                    return 'Please enter a valid phone number with country code.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password (Unchanged)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                // ...
              ),
              const SizedBox(height: 16),

              // Forgot Password (Unchanged)
              Align(
                // ...
              ),
              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: loginState.isLoading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    // We now call the controller method
                    ref
                        .read(loginControllerProvider.notifier)
                        .signInAndVerifyPhone(
                      phoneNumber: _phoneController.text.trim(),
                      password: _passwordController.text.trim(),
                      onCodeSent: (verificationId) {
                        // Navigate to OTP screen on success
                        context.push(
                          '/otp-verification',
                          extra: {
                            'verificationId': verificationId,
                            'phoneNumber': _phoneController.text.trim(),
                            'purpose': VerificationPurpose.login,
                          },
                        );
                      },
                      onError: (error) {
                        // The ref.listen block will also catch this,
                        // but it's good to be explicit.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login Error: $error'),
                          ),
                        );
                      },
                    );
                  }
                },
                child: loginState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LOGIN'),
              ),
              const SizedBox(height: 16),

              // Don't have an account? (Unchanged)
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}