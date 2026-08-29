import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zipbite/screens/splash_screen.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hjlvjaburlidoovjnwmv.supabase.co',
    anonKey: 'sb_publishable_k8VxmgdyYpkq8ylZmrkB0g_rTSaYGBa',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zipbite',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
