import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButtonLaunch1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButtonLaunch1({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(245, 203, 88, 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, color: AppColors.primary,
        fontWeight: FontWeight.w500  
        ), 
      ),
    );
  }
}