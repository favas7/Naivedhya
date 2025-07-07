import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButtonLaunch2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButtonLaunch2({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(243, 233, 181, 1.0)
,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, color: AppColors.primary,fontWeight: FontWeight.w500),
      ),
    );
  }
}