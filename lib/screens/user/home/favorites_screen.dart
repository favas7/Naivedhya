import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Favorites Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}