import 'package:flutter/material.dart';
import 'package:naivedhya/widgets/custom_button_launch1.dart';
import 'package:naivedhya/widgets/custom_button_launch2.dart';
import '../../constants/colors.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 350,),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Image.asset('assets/Naivedhya_Logo/naivedhya_logo.png'),
          ),
         Spacer(), 
          CustomButtonLaunch1(
            text:  '     Log In     ',
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
          SizedBox(height: 100,) 
        ],
      ),
    );
  }
}


