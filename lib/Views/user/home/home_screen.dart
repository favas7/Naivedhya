// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/login/login_screen.dart';
import '../../../utils/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: CustomButton(
          text: 'Log Out',
          onPressed: () async {
            await Provider.of<AuthProvider>(context, listen: false).logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
    );
  }
}