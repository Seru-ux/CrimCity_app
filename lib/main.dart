import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

const String supabaseUrl = 'https://pdlckauilxczdzcsdgtn.supabase.co';
const String supabaseAnonKey = 'sb_publishable__BoDAqzhVOqxYpOy2rQPXA_VQegWrx7';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ProviderScope(child: CrimCityApp()));
}

class CrimCityApp extends StatelessWidget {
  const CrimCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      title: 'CrimCity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB00020),
          secondary: Color(0xFFFFC107),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
