import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/utils/widgets/custom_button_launch1.dart';
import 'package:naivedhya/utils/widgets/custom_button_launch2.dart';
import '../auth/login/login_screen.dart';
import '../auth/sign_up/signup_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
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