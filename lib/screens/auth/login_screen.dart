import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart'; // 👈 Needed for your design
import 'package:go_router/go_router.dart';
import '../../providers/auth/login_controller.dart';
import '../../themes/app_factory.dart';
 // To access gradient colors

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
    final isDark = theme.brightness == Brightness.dark;

    // Get gradient colors exactly like your design code logic
    // (We prepared these in app_themes.dart to match your logic)
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
          // 👈 Gradient logic from your design code
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
                // 1. Icon
                Icon(
                  Icons.eco_outlined, // 👈 Icon from your design
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),

                // 2. Welcome Text
                Text(
                  'Welcome to Soilo',
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  'Sign in to continue',
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 40), // 👈 Spacing from your design

                // 3. Form with Animation
                _buildForm(context, loginState),

                const SizedBox(height: 24),

                // 4. Social Login with Animation
                _buildSocialLogin(context, loginState),

              ],
            ).animate().fadeIn(duration: 500.ms), // 👈 Animation from your design
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
              prefixIcon: Icon(Icons.phone), // Used Phone icon as per logic requirement
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
                        },
                      );
                    },
                    onError: (error) {/* Handled by listener */},
                  );
                  // context.push(
                  //   '/otp-verification',
                  //   extra: {
                  //     'verificationId': 'test_verification_id', // 👈 Needs a non-empty string
                  //     'phoneNumber': _phoneController.text.trim(),
                  //     'purpose': VerificationPurpose.login,
                  //   },
                  // );
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

          // Switch Mode / Forgot Password
          // Adapted to your navigation flow (Forgot Password)
          TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: const Text("Forgot Password?"),
          ),
          TextButton(
            onPressed: () => context.push('/signup'),
            child: const Text("Don't have an account? Sign Up"),
          ),
        ]
            .animate(interval: 100.ms) // 👈 Staggered animation from your design
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic)
            .fadeIn(),
      ),
    );
  }

  Widget _buildSocialLogin(BuildContext context, AsyncValue<dynamic> state) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('OR'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // You need to add this asset or use an Icon(Icons.g_mobiledata) temporarily
            icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
            label: const Text('Continue with Google'),
            onPressed: () {
              // Google Login Logic
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google Login Clicked'))
              );
            },
            // Style is handled by OutlinedButtonThemeData in factory
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms); // 👈 Delayed animation from your design
  }
}