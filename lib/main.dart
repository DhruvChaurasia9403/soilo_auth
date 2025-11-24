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
  final isPendingReset = prefs.getBool('login_pending_2fa') ?? false;

  if (isPendingReset) {
    await FirebaseAuth.instance.signOut();
    await prefs.remove('login_pending_2fa'); // Clear flag
    debugPrint("⚠️ Security: Cleared incomplete password reset session.");
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