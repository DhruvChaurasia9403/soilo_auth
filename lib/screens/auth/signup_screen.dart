import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/signup_controller.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/user_role.dart'; // 👈 ADD
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
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  UserRole? _selectedRole; // 👈 ADD

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

    // ... ref.listen block is still correct ...

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Full Name (Still here)
              TextFormField(
                controller: _fullNameController,
                // ...
              ),
              const SizedBox(height: 16),

              // REMOVED: Email Address

              // Phone Number
              TextFormField(
                controller: _phoneController,
                // ...
              ),
              const SizedBox(height: 16),

              // ⭐ NEW: User Role Dropdown
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                hint: const Text('Select Your Role'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role.';
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
                ),
                validator: (value) {
                  // Using validator we will create
                  return AppValidators.validatePassword(value);
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
                      fullName: _fullNameController.text.trim(),
                      password: _passwordController.text.trim(),
                      phoneNumber: _phoneController.text.trim(),
                      role: _selectedRole!, // We know it's not null due to validator
                      onCodeSent: (verificationId) {
                        context.push(
                          '/otp-verification',
                          extra: {
                            'verificationId': verificationId,
                            'phoneNumber':
                            _phoneController.text.trim(),
                            // ⭐ NEW: Tell OTP screen its purpose
                            'purpose': VerificationPurpose.signUp,
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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SIGN UP'),
              ),
              // ... "Already have an account?" TextButton is still correct ...
            ],
          ),
        ),
      ),
    );
  }
}

// ⭐ NEW: Enum for OTP Screen
enum VerificationPurpose {
  signUp,
  login,
  passwordReset,
}