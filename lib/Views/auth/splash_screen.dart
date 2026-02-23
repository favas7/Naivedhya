// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/admin_dashboard/admin_dashboard.dart';
import 'package:naivedhya/Views/bottom_navigator/bottom_navigator.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'launch_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        await authProvider.checkAuthStatus();
        
        if (authProvider.user != null) {
          // Get user type using the new getUserType method
          final userType = await authProvider.getUserType();
          
          if (userType == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavigator()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LaunchScreen()),
          );
        }
      } catch (e) {
        debugPrint('Splash screen error: $e');
        // Handle error - navigate to launch screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LaunchScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.accent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Image.asset('assets/Naivedhya_Logo/naivedhya_logo.png'),
        ),
      ),
    );
  }
}