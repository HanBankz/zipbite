import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zipbite/screens/reset_password_screen.dart';
import 'package:zipbite/screens/splash_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'screens/theme_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hjlvjaburlidoovjnwmv.supabase.co',
    anonKey: 'sb_publishable_k8VxmgdyYpkq8ylZmrkB0g_rTSaYGBa',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  Stripe.publishableKey =
      'pk_test_51UCKZXJwBhN8SQRK8dLuuezL3Is922Y3v8G7coO6hBMajSrKnHAfsBDXCHyFU2wUq4HCGeUfb29pfS2NANWdl8Js00WudDE74J';
  await Stripe.instance.applySettings();

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'zipbite',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const SplashScreen(),
        );
      },
    );
  }
}
