import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../utils/components/password_input_field.dart';
import '../../utils/components/phone_input_field.dart';
import '../../utils/components/primary_button.dart';
import '../../controllers/auth/login_controller.dart';
import '../../themes/app_factory.dart';
import 'package:flutter/services.dart';
import '../../utils/ui_helpers.dart';

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
          PhoneInputField(
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          PasswordInputField(
            controller: _passwordController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),

          // Login Button
      PrimaryButton(
        text: 'LOGIN',
        isLoading: loginState.isLoading,
        onPressed: () {
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
                          'password': _passwordController.text.trim(),
                        },
                      );
                    },
                    onError: (error) {
                      /* Handled by listener */
                    },
                  );
                }
              },
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
}