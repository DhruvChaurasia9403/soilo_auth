// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/signup_controller.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/user_role.dart';
import '../../features/utils/validators.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  UserRole? _selectedRole;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);
    final theme = Theme.of(context);
    final cardPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 20);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: cardPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Your Account', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter details and verify your phone to continue.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 20),

                  // Full name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name.' : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (e.g., +15551234567)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.startsWith('+') || value.length < 10) {
                        return 'Please enter a valid phone number with country code.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Role dropdown
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    hint: const Text('Select Your Role'),
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.work_outline)),
                    items: UserRole.values.map((role) => DropdownMenuItem(value: role, child: Text(role.displayName))).toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                    validator: (value) => value == null ? 'Please select a role.' : null,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (value) => AppValidators.validatePassword(value),
                  ),
                  const SizedBox(height: 14),

                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: signUpState.isLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(signUpControllerProvider.notifier).signUpAndVerifyPhone(
                            fullName: _fullNameController.text.trim(),
                            password: _passwordController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            role: _selectedRole!,
                            onCodeSent: (verificationId) {
                              context.push('/otp-verification', extra: {
                                'verificationId': verificationId,
                                'phoneNumber': _phoneController.text.trim(),
                                'purpose': VerificationPurpose.signUp,
                              });
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup Error: $error')));
                            },
                          );
                        }
                      },
                      child: signUpState.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SIGN UP'),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Already have an account?'),
                    TextButton(onPressed: () => context.push('/login'), child: const Text('Login')),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enum kept where file originally declared
enum VerificationPurpose {
  signUp,
  login,
  passwordReset,
}
