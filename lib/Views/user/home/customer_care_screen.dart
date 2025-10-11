import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(
        child: Text('Customer Care Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}