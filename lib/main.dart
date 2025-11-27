import 'package:checking/providers/flow_flags/login_flow_provider.dart';
import 'package:checking/providers/flow_flags/reset_flow_provider.dart';
import 'package:checking/routes/router.dart';
import 'package:checking/themes/app_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final isLoginPending = prefs.getBool(LoginFlowNotifier.key) ?? false;
  final isResetPending = prefs.getBool(ResetFlowNotifier.key) ?? false;
  if (isLoginPending || isResetPending) {
    debugPrint("⚠️ Security: Detected incomplete session (Login: $isLoginPending, Reset: $isResetPending).");
    await FirebaseAuth.instance.signOut();
    await prefs.remove(LoginFlowNotifier.key);
    await prefs.remove(ResetFlowNotifier.key);

    debugPrint("✅ Security: Session cleared. User forced to Login.");
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Soilo Auth App',

      debugShowCheckedModeBanner: false,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark, // 👈 add dark mode
      themeMode: ThemeMode.system, // uses system setting automatically
      routerConfig: router,
    );
  }
}