// Views/admin/order/widget/order_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/widget/assign_delivery_partner_dialog.dart';
import 'package:naivedhya/models/order_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class OrderDetailDialog extends StatelessWidget {
  final Order order;
  final Map<String, dynamic>? restaurant;
  final Map<String, dynamic>? customer;
  final String? resolvedAddress;
  final AppThemeColors themeColors;

  const OrderDetailDialog({
    super.key,
    required this.order,
    required this.themeColors,
    this.restaurant,
    this.customer,
    this.resolvedAddress,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = themeColors.getOrderStatusColor(order.status);
    final statusBgColor = themeColors.getOrderStatusBgColor(order.status);

    return Dialog(
      backgroundColor: themeColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _orderTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          order.orderTypeIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColors.textPrimary,
                            ),
                          ),
                          if (order.createdAt != null)
                            Text(
                              _formatTime(order.createdAt!),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close,
                          size: 20, color: themeColors.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(color: themeColors.textSecondary.withOpacity(0.15)),
                const SizedBox(height: 12),

                // ── Order Info ───────────────────────────────────────────
                _SectionLabel(label: 'Order Info', themeColors: themeColors),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Type',
                  value: order.orderType ?? 'N/A',
                  themeColors: themeColors,
                ),
                _DetailRow(
                  icon: Icons.attach_money,
                  label: 'Total',
                  value: '₹${order.totalAmount.toStringAsFixed(2)}',
                  themeColors: themeColors,
                  isHighlight: true,
                ),
                if (order.paymentMethod != null || order.paymentType != null)
                  _DetailRow(
                    icon: Icons.payment,
                    label: 'Payment',
                    value: [order.paymentMethod, order.paymentType]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(' • '),
                    themeColors: themeColors,
                  ),

                const SizedBox(height: 12),

                // ── Customer Info ────────────────────────────────────────
                _SectionLabel(
                    label: 'Customer', themeColors: themeColors),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: order.customerName ?? 'Walk-in',
                  themeColors: themeColors,
                ),
                if (customer?['phone'] != null)
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: customer!['phone'],
                    themeColors: themeColors,
                  ),
                if (customer?['email'] != null)
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: customer!['email'],
                    themeColors: themeColors,
                  ),

                const SizedBox(height: 12),

                // ── Restaurant / Address ─────────────────────────────────
                _SectionLabel(
                    label: 'Restaurant', themeColors: themeColors),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.restaurant,
                  label: 'Name',
                  value: restaurant?['name'] ?? 'Unknown',
                  themeColors: themeColors,
                ),
                if (order.orderType == 'Delivery' && resolvedAddress != null)
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Delivery Address',
                    value: resolvedAddress!,
                    themeColors: themeColors,
                  ),

                const SizedBox(height: 16),
                Divider(color: themeColors.textSecondary.withOpacity(0.15)),
                const SizedBox(height: 12),

                // ── Delivery Partner Section ──────────────────────────────
                if (order.orderType == 'Delivery') ...[
                  _SectionLabel(
                      label: 'Delivery Partner', themeColors: themeColors),
                  const SizedBox(height: 8),

                  if (order.deliveryPersonId != null)
                    // Already assigned
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: AppTheme.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Partner Assigned',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                                Text(
                                  'ID: ${order.deliveryPersonId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Not yet assigned — show assign button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // close detail dialog first
                          showDialog(
                            context: context,
                            builder: (_) =>
                                AssignDeliveryPartnerDialog(order: order),
                          );
                        },
                        icon: const Icon(Icons.delivery_dining, size: 18),
                        label: const Text('Assign Delivery Partner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                ],

                // ── Close ────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style:
                          TextStyle(color: themeColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _orderTypeColor() {
    switch (order.orderType?.toLowerCase()) {
      case 'delivery':
        return AppTheme.warning;
      case 'dine in':
        return AppTheme.info;
      case 'takeaway':
        return AppTheme.primary;
      default:
        return AppTheme.textSecondary;
    }
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppThemeColors themeColors;

  const _SectionLabel({required this.label, required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: themeColors.textSecondary,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppThemeColors themeColors;
  final bool isHighlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.themeColors,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                isHighlight ? AppTheme.primary : themeColors.textSecondary,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: themeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isHighlight ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight
                    ? AppTheme.primary
                    : themeColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}