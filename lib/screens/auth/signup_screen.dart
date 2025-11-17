import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/signup_controller.dart';
import 'otp_verification_screen.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);

    // Listen to the SignUpController state for navigation or error display
    ref.listen<AsyncValue<String?>>(signUpControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
      if (state.hasValue && state.value != null) {
        print('OTP code sent successfully. Verification ID: ${state.value}');
      }
    });

    // We don't need 'colors' anymore since the AppBarTheme handles it
    // final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        // REMOVED: backgroundColor: colors.primary
        // The AppBarTheme in your factory now handles this automatically.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Account',
                // UPDATED: Uses the style directly from the theme
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  // The 'border' is now supplied by inputDecorationTheme
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Address
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  // REMOVED: border: OutlineInputBorder()
                  // This now comes from your theme
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText:
                  'Phone Number (e.g., +15551234567)',
                  prefixIcon: Icon(Icons.phone),
                  // REMOVED: border: OutlineInputBorder()
                  // This now comes from your theme
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.startsWith('+') ||
                      value.length < 10) {
                    return 'Please enter a valid phone number with country code (e.g., +1XXXXXXXXXX).';
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
                  // REMOVED: border: OutlineInputBorder()
                  // This now comes from your theme
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  // This one was already correct!
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Sign Up Button
              ElevatedButton(
                onPressed: signUpState.isLoading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(signUpControllerProvider.notifier)
                        .signUpAndVerifyPhone(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      onCodeSent: (verificationId) {
                        context.push(
                          '/otp-verification',
                          extra: {
                            'verificationId': verificationId,
                            'phoneNumber':
                            _phoneController.text.trim(),
                          },
                        );
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Signup Error: $error'),
                          ),
                        );
                      },
                    );
                  }
                },
                child: signUpState.isLoading
                    ? const CircularProgressIndicator(
                  // This hardcoded color is OK because the
                  // ElevatedButtonThemeData *explicitly* sets its
                  // foregroundColor to white.
                  color: Colors.white,
                )
                    : const Text(
                  'SIGN UP',
                  // REMOVED: style: TextStyle(...)
                  // This now comes from elevatedButtonTheme's textStyle
                ),
              ),
              const SizedBox(height: 16),
              // Already have an account?
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text(
                  'Already have an account? Login',
                  // REMOVED: style: TextStyle(...)
                  // This now comes from textButtonTheme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}