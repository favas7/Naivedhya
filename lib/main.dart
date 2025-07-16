import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:naivedhya/config/supabase_config.dart';
import 'package:naivedhya/firebase_options.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/user/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
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
        ChangeNotifierProvider(create: (context) => HotelProvider()),
      ],
      child: ScreenUtilInit(
        // Design size for mobile (you can adjust based on your design)
        designSize: const Size(375, 812),
        
        // Minimum text adapt size
        minTextAdapt: true,
        
        // Split screen adaptation for tablets/web
        splitScreenMode: true,
        
        // Responsive breakpoints for web
        useInheritedMediaQuery: true,
        
        builder: (context, child) {
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}