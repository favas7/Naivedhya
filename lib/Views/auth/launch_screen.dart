import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/utils/widgets/custom_button_launch1.dart';
import 'package:naivedhya/utils/widgets/custom_button_launch2.dart';
import 'login/login_screen.dart';
import 'sign_up/signup_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: 768px for web layout
        final isWebLayout = constraints.maxWidth > 768;
        
        return isWebLayout 
          ? _buildWebLayout(context)
          : _buildMobileLayout(context);
      },
    );
  }

  // ============ WEB LAYOUT - HORIZONTAL SPLIT (OPTION B) ============
  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  AppTheme.darkBackground,
                  AppTheme.darkPrimary.withOpacity(0.3),
                  AppTheme.darkBackground,
                ]
              : [
                  AppTheme.accent,
                  AppTheme.primary.withOpacity(0.6),
                  AppTheme.primaryLight.withOpacity(0.4),
                ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 900,
              maxHeight: 500,
            ),
            margin: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Row(
                children: [
                  // LEFT SIDE - LOGO/BRANDING
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                            ? [
                                AppTheme.darkPrimary,
                                AppTheme.darkPrimaryDarker,
                              ]
                            : [
                                AppTheme.primary,
                                AppTheme.primaryDark,
                              ],
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                  maxHeight: 250,
                                ),
                                child: Image.asset(
                                  'assets/Naivedhya_Logo/naivedhya_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Optional tagline
                              Text(
                                'Welcome to Naivedhya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // RIGHT SIDE - BUTTONS
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome text
                          Text(
                            'Get Started',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Choose an option to continue',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          
                          // Log In Button
                          CustomButtonLaunch1(
                            text: 'Log In',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Sign Up Button
                          CustomButtonLaunch2(
                            text: 'Sign Up',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUpScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ MOBILE LAYOUT - VERTICAL (OPTION A - ORIGINAL) ============
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb;
    
    // Responsive sizing
    final logoSize = isWeb ? 
      (screenWidth > 600 ? 200.0 : 150.0) : 
      (screenHeight * 0.25).clamp(150.0, 250.0);
    
    final topSpacing = isWeb ? 
      (screenHeight * 0.1).clamp(20.0, 80.0) : 
      (screenHeight * 0.15).clamp(50.0, 150.0);
    
    final bottomSpacing = isWeb ? 
      (screenHeight * 0.1).clamp(20.0, 60.0) : 
      (screenHeight * 0.08).clamp(30.0, 80.0);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                // Add max width constraint for web
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 400.0 : double.infinity,
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: topSpacing),
                          
                          // Logo section - flexible sizing
                          Flexible(
                            flex: 3,
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: logoSize,
                                maxWidth: logoSize,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: Image.asset(
                                  'assets/Naivedhya_Logo/naivedhya_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          
                          // Spacer to push buttons to bottom
                          const Spacer(),
                          
                          // Buttons section - fixed at bottom
                          Column(
                            children: [
                              CustomButtonLaunch1(
                                text: '     Log In     ',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
                              ),
                              const SizedBox(height: 5),
                              CustomButtonLaunch2(
                                text: '    Sign Up    ',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                          
                          SizedBox(height: bottomSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}