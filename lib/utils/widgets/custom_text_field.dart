import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
    required this.controller,
    this.suffixIcon,  bool? readOnly,  void Function()? onTap,  Icon? prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.textfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}