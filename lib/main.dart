import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/reports_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  // Check if user is authenticated and actually exists in database
  bool hasSession = Supabase.instance.client.auth.currentSession != null;

  if (hasSession) {
    // Verify user exists in database by making a simple query
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Try to fetch user's data - this will fail if user doesn't exist
        await Supabase.instance.client
            .from('reports')
            .select('id')
            .eq('user_id', userId)
            .limit(1);
      }
    } catch (e) {
      // If user doesn't exist in database, sign them out
      debugPrint('User validation failed: $e');
      await Supabase.instance.client.auth.signOut();
      hasSession = false;
    }
  }

  runApp(
    MindwormApp(
      showOnboarding: !onboardingComplete,
      isAuthenticated: hasSession,
    ),
  );
}

class MindwormApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isAuthenticated;

  const MindwormApp({
    super.key,
    required this.showOnboarding,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp(
        title: 'Mindworm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: !isAuthenticated
            ? const AuthScreen()
            : (showOnboarding ? const OnboardingScreen() : const HomeScreen()),
      ),
    );
  }
}
