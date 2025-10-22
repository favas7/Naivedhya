import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme. accent,
      body: const Center(
        child: Text('Favorites Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}