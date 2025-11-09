// lib/Views/admin/order/add_order_screen/widget/additional_details_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/utils/color_theme.dart';

class AdditionalDetailsCard extends StatefulWidget {
  final String paymentMethod;
  final ValueChanged<String?> onPaymentMethodChanged;
  final ValueChanged<String> onSpecialInstructionsChanged;
  final DateTime? proposedDeliveryTime;
  final ValueChanged<DateTime?> onDeliveryTimeChanged;
  final String? initialInstructions;

  const AdditionalDetailsCard({
    super.key,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.onSpecialInstructionsChanged,
    required this.proposedDeliveryTime,
    required this.onDeliveryTimeChanged,
    this.initialInstructions,
  });

  @override
  State<AdditionalDetailsCard> createState() => _AdditionalDetailsCardState();
}

class _AdditionalDetailsCardState extends State<AdditionalDetailsCard> {
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _instructionsController = TextEditingController(
      text: widget.initialInstructions,
    );
    _instructionsController.addListener(() {
      widget.onSpecialInstructionsChanged(_instructionsController.text);
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppTheme.of(context);

    return SectionCardWrapper(
      title: 'Additional Details',
      icon: Icons.info_outline,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method
          _buildSubsectionHeader('Payment Method', Icons.payment, themeColors),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeColors.background.withAlpha(50),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: widget.paymentMethod,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.primary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              dropdownColor: themeColors.surface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: themeColors.textSecondary,
              ),
              items: ['Cash', 'Card', 'UPI', 'Online'].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentIcon(method),
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        method,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: themeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: widget.onPaymentMethodChanged,
            ),
          ),

          const SizedBox(height: 20),

          // Special Instructions
          _buildSubsectionHeader(
            'Special Instructions (Optional)',
            Icons.note_alt_outlined,
            themeColors,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: themeColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeColors.background.withAlpha(50),
              ),
            ),
            child: TextField(
              controller: _instructionsController,
              decoration: InputDecoration(
                hintText: 'Add any special instructions for this order...',
                hintStyle: TextStyle(
                  color: themeColors.textSecondary.withAlpha(179),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 3,
              style: TextStyle(
                fontSize: 14,
                color: themeColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Delivery Time
          _buildSubsectionHeader(
            'Proposed Delivery Time (Optional)',
            Icons.schedule,
            themeColors,
          ),
          const SizedBox(height: 8),
          _buildDeliveryTimePicker(themeColors),
        ],
      ),
    );
  }

  Widget _buildSubsectionHeader(
    String title,
    IconData icon,
    AppThemeColors themeColors,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: themeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTimePicker(AppThemeColors themeColors) {
    return InkWell(
      onTap: () => _selectDeliveryTime(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: themeColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeColors.background.withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.proposedDeliveryTime != null
                        ? 'Scheduled Delivery'
                        : 'Select delivery time',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.proposedDeliveryTime != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(widget.proposedDeliveryTime!)
                        : 'Not set',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.proposedDeliveryTime != null
                          ? themeColors.textPrimary
                          : themeColors.textSecondary.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.proposedDeliveryTime != null)
              IconButton(
                onPressed: () => widget.onDeliveryTimeChanged(null),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: themeColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: themeColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeliveryTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.proposedDeliveryTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          widget.proposedDeliveryTime ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppTheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && context.mounted) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        widget.onDeliveryTimeChanged(newDateTime);
      }
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money;
      case 'Card':
        return Icons.credit_card;
      case 'UPI':
        return Icons.qr_code;
      case 'Online':
        return Icons.language;
      default:
        return Icons.payment;
    }
  }
}