import 'package:flutter/material.dart';
import 'package:naivedhya/utils/constants/colors.dart';

class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Customer Care Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}