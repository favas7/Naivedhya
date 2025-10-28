import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya/models/payment_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class PaymentCard extends StatefulWidget {
  final Payment payment;
  final VoidCallback? onViewDetails;
  final Function(PaymentStatus)? onUpdateStatus;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onViewDetails,
    this.onUpdateStatus,
  });

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  bool _isHovered = false;

  Color _getStatusColor(AppThemeColors colors) {
    switch (widget.payment.status) {
      case PaymentStatus.completed:
        return colors.success;
      case PaymentStatus.pending:
        return colors.warning;
      case PaymentStatus.failed:
        return colors.error;
    }
  }

  Color _getModeColor(AppThemeColors colors) {
    switch (widget.payment.paymentMode) {
      case PaymentMode.upi:
        return colors.info;
      case PaymentMode.cashOnDelivery:
        return colors.success;
      case PaymentMode.wallet:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData _getModeIcon() {
    switch (widget.payment.paymentMode) {
      case PaymentMode.upi:
        return Icons.qr_code_scanner;
      case PaymentMode.cashOnDelivery:
        return Icons.money;
      case PaymentMode.wallet:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? colors.primary.withOpacity(0.3)
                  : colors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? colors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Gradient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.1),
                      colors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // Payment Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary,
                            colors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Payment Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.payment.formattedAmount,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Payment ID Chip
                          GestureDetector(
                            onTap: () => _copyToClipboard(
                                context, widget.payment.paymentId, 'Payment ID'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.info.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.info.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '#${widget.payment.paymentId.substring(0, 8)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colors.info,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.copy,
                                    size: 10,
                                    color: colors.info,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions Menu
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      icon: Icon(
                        Icons.more_vert,
                        color: colors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility,
                                  size: 18, color: colors.textSecondary),
                              const SizedBox(width: 12),
                              const Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        ...PaymentStatus.values
                            .where((s) => s != widget.payment.status)
                            .map((status) => PopupMenuItem(
                                  value: 'status_${status.value}',
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(status),
                                        size: 18,
                                        color: _getStatusColorFromEnum(
                                            status, colors),
                                      ),
                                      const SizedBox(width: 12),
                                      Text('Mark as ${status.value}'),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ],
                ),
              ),

              // Status & Details Section
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Status & Mode Row
                    Row(
                      children: [
                        // Status Badge
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(colors).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(colors).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(colors),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.payment.status.value,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(colors),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Payment Mode Chip
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getModeColor(colors).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getModeColor(colors).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getModeIcon(),
                                  size: 12,
                                  color: _getModeColor(colors),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.payment.paymentMode.value,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getModeColor(colors),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Customer & Order Info
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: widget.payment.customerName,
                      colors: colors,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Order #${widget.payment.orderId.substring(0, 8)}',
                      colors: colors,
                      onTap: () => _copyToClipboard(
                          context, widget.payment.orderId, 'Order ID'),
                    ),
                    if (widget.payment.transactionId != null) ...[
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Txn: ${widget.payment.transactionId}',
                        colors: colors,
                        onTap: () => _copyToClipboard(
                            context, widget.payment.transactionId!, 'Transaction ID'),
                      ),
                    ],
                  ],
                ),
              ),

              // Footer with metadata
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.textSecondary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 11,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(widget.payment.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required AppThemeColors colors,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 12,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.copy,
              size: 12,
              color: colors.textSecondary.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    if (action == 'view') {
      widget.onViewDetails?.call();
    } else if (action.startsWith('status_')) {
      final statusValue = action.substring(7);
      final status = PaymentStatus.fromString(statusValue);
      widget.onUpdateStatus?.call(status);
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.failed:
        return Icons.cancel;
    }
  }

  Color _getStatusColorFromEnum(PaymentStatus status, AppThemeColors colors) {
    switch (status) {
      case PaymentStatus.completed:
        return colors.success;
      case PaymentStatus.pending:
        return colors.warning;
      case PaymentStatus.failed:
        return colors.error;
    }
  }

  Future<void> _copyToClipboard(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('$label copied: $text')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays == 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return widget.payment.formattedDate;
    }
  }
}