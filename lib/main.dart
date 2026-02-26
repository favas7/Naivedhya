import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/Views/admin/admin_dashboard/admin_dashboard.dart';
import 'package:naivedhya/Views/auth/launch_screen.dart';
import 'package:naivedhya/Views/bottom_navigator/bottom_navigator.dart';
import 'package:naivedhya/config/supabase_config.dart'; 
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/providers/dashboard_provider.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/providers/menu_provider.dart';
import 'package:naivedhya/providers/restaurant_provider.dart';
import 'package:naivedhya/providers/restaurant_provider_for_ventor.dart';
import 'package:naivedhya/providers/location_provider.dart';
import 'package:naivedhya/providers/manager_provider.dart';
import 'package:naivedhya/providers/order_provider.dart';
import 'package:naivedhya/providers/theme_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
        ChangeNotifierProvider(create: (_) => VendorRestaurantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryPersonnelProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            useInheritedMediaQuery: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Naivedhya',
                theme: AppTheme.lightTheme,      // Fixed: changed from lightTheme to light
                darkTheme: AppTheme.darkTheme,   // Fixed: changed from darkTheme to dark
                themeMode: themeProvider.themeMode,
                home: const AuthGate(),
              );
            },
          );
        },
      ),
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Give _restoreSession() time to complete
    await authProvider.checkAuthStatus();

    if (!context.mounted) return;

    if (authProvider.user != null) {
      final userType = await authProvider.getUserType();
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => userType == 'admin'
              ? const AdminDashboardScreen()
              : const BottomNavigator(),
        ),
      );
    } else {
      // Not logged in — show LaunchScreen
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash/loading while checking, LaunchScreen once confirmed not logged in
    return _isChecking ? const SplashWidget() : const LaunchScreen();
  }
}

// Minimal splash to show during auth check
class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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