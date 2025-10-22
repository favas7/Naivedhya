import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Icon? prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
    required this.controller,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: colors.primary.withOpacity(0.06),
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: colors.textSecondary),
                child: prefixIcon!,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconTheme(
                data: IconThemeData(color: colors.textSecondary),
                child: suffixIcon!,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colors.textSecondary.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colors.textSecondary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: colors.textSecondary.withOpacity(0.6),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
          ),
      validator: validator,
    );
  }
}