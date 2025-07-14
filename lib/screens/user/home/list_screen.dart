import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('List Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}