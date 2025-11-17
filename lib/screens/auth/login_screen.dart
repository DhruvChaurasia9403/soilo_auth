// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../features/auth/login_controller.dart';
import 'package:go_router/go_router.dart';
import 'otp_verification_screen.dart'; // for VerificationPurpose

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<AsyncValue<String?>>(
      loginControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          final msg = state.error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
    );

    final theme = Theme.of(context);
    final pagePadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to your account.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Phone
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
                      const SizedBox(height: 14),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password.';
                          if (value.length < 6) return 'Password must be at least 6 characters.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Login button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loginState.isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(loginControllerProvider.notifier).sendOtpForLogin(
                                phoneNumber: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                                onCodeSent: (verificationId) {
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login Error: $error')),
                                  );
                                },
                              );
                            }
                          },
                          child: loginState.isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('LOGIN'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () => context.push('/signup'),
                            child: const Text('Sign Up'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // subtle tip area
            Text(
              'You will receive an SMS with a verification code. Standard message rates may apply.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
