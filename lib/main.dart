import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/user_screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Supabase for database operations
  await Supabase.initialize(
    url: 'https://plhvaeegrhzvkqlltzyb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsaHZhZWVncmh6dmtxbGx0enliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTU3NTEsImV4cCI6MjA2NzM5MTc1MX0.1t4BRB4p_BQWWUBSz0IO6B3wjLHWySuqnhNgLpjE8RY',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Naivedhya',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}