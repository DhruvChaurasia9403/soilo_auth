import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/login_controller.dart';
import '../../themes/app_factory.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
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

    final ThemeConfig themeConfig = Theme.of(context).extension<ThemeConfig>()!;
    final gradientStart = themeConfig.gradientStart;
    final gradientEnd = themeConfig.gradientEnd;

    ref.listen<AsyncValue<String?>>(
      loginControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error.toString()),
                backgroundColor: Colors.redAccent,
              ),
            );
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco_outlined,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),

                Text(
                  'Welcome to Soilo',
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  'Sign in to continue',
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 40),

                _buildForm(context, loginState),

                const SizedBox(height: 24),

                // _buildSocialLogin(context, loginState),

              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AsyncValue<dynamic> loginState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 10) {
                return 'Enter valid phone';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) => (value != null && value.length >= 6)
                ? null
                : 'Password must be 6+ chars',
          ),
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loginState.isLoading
                  ? null
                  : () {
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(loginControllerProvider.notifier)
                      .sendOtpForLogin(
                    phoneNumber: _phoneController.text.trim(),
                    password: _passwordController.text.trim(),
                    onCodeSent: (verificationId) {
                      context.push(
                        '/otp-verification',
                        extra: {
                          'verificationId': verificationId,
                          'phoneNumber': _phoneController.text.trim(),
                          'purpose': VerificationPurpose.login,
                          // 👇 PASS PASSWORD TO OTP SCREEN
                          'password': _passwordController.text.trim(),
                        },
                      );
                    },
                    onError: (error) {/* Handled by listener */},
                  );
                }
              },
              child: loginState.isLoading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
                  : const Text('Login'),
            ),
          ),

          TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: const Text("Forgot Password?"),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            child: const Text("Don't have an account? Sign Up"),
          ),
        ]
            .animate(interval: 100.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic)
            .fadeIn(),
      ),
    );
  }

  // Widget _buildSocialLogin(BuildContext context, AsyncValue<dynamic> state) {
  //   return Column(
  //     children: [
  //       const Row(
  //         children: [
  //           Expanded(child: Divider()),
  //           Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 8.0),
  //             child: Text('OR'),
  //           ),
  //           Expanded(child: Divider()),
  //         ],
  //       ),
  //       const SizedBox(height: 24),
  //       // SizedBox(
  //       //   width: double.infinity,
  //       //   child: OutlinedButton.icon(
  //       //     icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
  //       //     label: const Text('Continue with Google'),
  //       //     onPressed: () {
  //       //       ScaffoldMessenger.of(context).showSnackBar(
  //       //           const SnackBar(content: Text('Google Login Clicked'))
  //       //       );
  //       //     },
  //       //   ),
  //       // ),
  //     ],
  //   ).animate().fadeIn(delay: 500.ms);
  // }
}