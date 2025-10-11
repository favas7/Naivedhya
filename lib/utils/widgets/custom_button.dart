import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/providers/theme_provider.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? (isDark ? AppTheme.darkPrimary : AppTheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16, 
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}