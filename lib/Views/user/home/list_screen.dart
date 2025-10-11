import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(
        child: Text('List Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}