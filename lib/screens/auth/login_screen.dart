import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../features/auth/login_controller.dart';
import 'package:go_router/go_router.dart';
import 'otp_verification_screen.dart';
// Import to access AppThemes for gradient colors

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Access the gradient colors manually from AppThemes based on brightness
    // (In a more advanced setup, we'd use ThemeExtensions, but this works perfectly)
    final gradientStart = isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9);
    final gradientEnd = isDark ? const Color(0xFF0D3311) : const Color(0xFFC8E6C9);

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

    return Scaffold(
      // Use extendBodyBehindAppBar if you had an app bar, but we don't.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- LOGO SECTION ---
                    Icon(
                      Icons.eco, // Placeholder for your Leaf Logo
                      size: 80,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 24),

                    // --- WELCOME TEXT ---
                    Text(
                      'Welcome to ReadSoil',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // --- PHONE INPUT ---
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        // Borders/Fill handled by ThemeFactory
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.startsWith('+') ||
                            value.length < 10) {
                          return 'Enter valid phone (e.g., +1555...)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- PASSWORD INPUT ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        // Borders/Fill handled by ThemeFactory
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter password.';
                        if (value.length < 6) return 'Min 6 chars.';
                        return null;
                      },
                    ),

                    // --- FORGOT PASSWORD ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- LOGIN BUTTON ---
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loginState.isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            // Logic remains exactly as requested
                            ref
                                .read(loginControllerProvider.notifier)
                                .sendOtpForLogin(
                              phoneNumber:
                              _phoneController.text.trim(),
                              password: _passwordController.text.trim(),
                              onCodeSent: (verificationId) {
                                context.push(
                                  '/otp-verification',
                                  extra: {
                                    'verificationId': verificationId,
                                    'phoneNumber':
                                    _phoneController.text.trim(),
                                    'purpose':
                                    VerificationPurpose.login,
                                  },
                                );
                              },
                              onError: (error) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                      content:
                                      Text('Login Error: $error')),
                                );
                              },
                            );
                          }
                        },
                        child: loginState.isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text('LOGIN'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- SIGN UP LINK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: const Text('Sign Up'),
                        )
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- DIVIDER & OR ---
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[400])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'OR',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[400])),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- GOOGLE BUTTON (Visual Only) ---
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Sign In')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide.none, // No border, just white pill
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2, // Subtle shadow like the inputs
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder for Google Icon
                            const Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}