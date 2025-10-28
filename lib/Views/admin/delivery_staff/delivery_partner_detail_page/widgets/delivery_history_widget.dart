// views/admin/delivery_staff/widgets/delivery_history_widget.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/delivery_history_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:intl/intl.dart';

class DeliveryHistoryWidget extends StatelessWidget {
  final List<DeliveryHistory> deliveryHistory;
  final VoidCallback? onRefresh;

  const DeliveryHistoryWidget({
    super.key,
    required this.deliveryHistory,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    if (deliveryHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: colors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No delivery history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed deliveries will appear here',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: deliveryHistory.length,
        itemBuilder: (context, index) {
          final delivery = deliveryHistory[index];
          return _buildDeliveryCard(context, colors, delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    AppThemeColors colors,
    DeliveryHistory delivery,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(colors, delivery.deliveryStatus).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(colors, delivery.deliveryStatus).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(delivery.deliveryStatus),
                  color: _getStatusColor(colors, delivery.deliveryStatus),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${delivery.orderId}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(delivery.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(colors, delivery.deliveryStatus),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    delivery.deliveryStatus.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (delivery.deliveryAddress != null)
                  _buildInfoRow(
                    colors,
                    Icons.location_on,
                    'Address',
                    delivery.deliveryAddress!,
                  ),
                if (delivery.pickupTime != null)
                  _buildInfoRow(
                    colors,
                    Icons.schedule,
                    'Pickup Time',
                    DateFormat('HH:mm').format(delivery.pickupTime!),
                  ),
                if (delivery.deliveryTime != null)
                  _buildInfoRow(
                    colors,
                    Icons.check_circle,
                    'Delivery Time',
                    DateFormat('HH:mm').format(delivery.deliveryTime!),
                  ),
                if (delivery.deliveryDuration != null)
                  _buildInfoRow(
                    colors,
                    Icons.timer,
                    'Duration',
                    _formatDuration(delivery.deliveryDuration!),
                  ),
                _buildInfoRow(
                  colors,
                  Icons.route,
                  'Distance',
                  '${delivery.distanceKm.toStringAsFixed(1)} km',
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEarningChip(
                      colors,
                      'Delivery Fee',
                      delivery.deliveryFee,
                      colors.info,
                    ),
                    if (delivery.tipAmount > 0)
                      _buildEarningChip(
                        colors,
                        'Tip',
                        delivery.tipAmount,
                        colors.success,
                      ),
                    _buildEarningChip(
                      colors,
                      'Total',
                      delivery.totalEarnings,
                      colors.primary,
                    ),
                  ],
                ),
                if (delivery.deliveryNotes != null && delivery.deliveryNotes!.isNotEmpty)
                  Column(
                    children: [
                      const Divider(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 16,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              delivery.deliveryNotes!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    AppThemeColors colors,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningChip(
    AppThemeColors colors,
    String label,
    double amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppThemeColors colors, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return colors.success;
      case 'pending':
        return colors.warning;
      case 'cancelled':
      case 'failed':
        return colors.error;
      case 'in_progress':
      case 'picked_up':
        return colors.info;
      default:
        return colors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
      case 'failed':
        return Icons.cancel;
      case 'in_progress':
      case 'picked_up':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}