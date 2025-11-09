// lib/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class SectionCardWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final bool showDivider;

  const SectionCardWrapper({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding,
    this.icon,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColors.background.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: themeColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // Divider
          if (showDivider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: themeColors.background.withAlpha(30),
              ),
            ),

          // Content
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}