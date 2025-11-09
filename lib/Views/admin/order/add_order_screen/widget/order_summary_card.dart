// lib/Views/admin/order/add_order_screen/widgets/order_summary_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderSummaryCard extends StatelessWidget {
  final int itemCount;
  final double totalAmount;
  final double? originalAmount;
  final bool showAmountChange;

  const OrderSummaryCard({
    super.key,
    required this.itemCount,
    required this.totalAmount,
    this.originalAmount,
    this.showAmountChange = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    
    final hasAmountChanged = showAmountChange && 
        originalAmount != null && 
        (totalAmount - originalAmount!).abs() > 0.01;

    final cardColor = hasAmountChanged
        ? theme.warning.withOpacity(0.08)
        : theme.info.withOpacity(0.08);
    
    final amountColor = hasAmountChanged ? theme.warning : theme.info;

    return Card(
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items:',
                  style: textTheme.bodyLarge?.copyWith(color: theme.textPrimary),
                ),
                Text(
                  itemCount.toString(),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            if (hasAmountChanged) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Original Amount:', style: textTheme.bodyLarge),
                  Text(
                    '₹${originalAmount!.toStringAsFixed(2)}',
                    style: textTheme.bodyLarge?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasAmountChanged ? 'New Total Amount:' : 'Total Amount:',
                  style: textTheme.titleMedium?.copyWith(color: theme.textPrimary),
                ),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
            if (hasAmountChanged) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: theme.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Amount changed by ₹${(totalAmount - originalAmount!).abs().toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}