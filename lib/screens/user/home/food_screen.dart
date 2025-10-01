import 'package:flutter/material.dart';
import 'package:naivedhya/utils/constants/colors.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Food Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}