import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya/Views/admin/customer/customer_detail_page/customer_detail_page.dart';
import 'package:naivedhya/models/user_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class CustomerCard extends StatefulWidget {
  final UserModel customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewOrders;
  final VoidCallback? onViewDetails;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onEdit,
    this.onDelete,
    this.onViewOrders,
    this.onViewDetails,
  });

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _isHovered = false;

  Color _getStatusColor(AppThemeColors colors) {
    if ((widget.customer.pendingpayments ?? 0) > 0) {
      return colors.error;
    } else if ((widget.customer.orderhistory?.length ?? 0) > 0) {
      return colors.success;
    } else {
      return colors.textSecondary;
    }
  }

  String _getStatusText() {
    if ((widget.customer.pendingpayments ?? 0) > 0) {
      return 'Payment Due';
    } else if ((widget.customer.orderhistory?.length ?? 0) > 0) {
      return 'Active';
    } else {
      return 'New';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderCount = widget.customer.orderhistory?.length ?? 0;
    final pendingAmount = widget.customer.pendingpayments ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () { 
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailPage(
                customer: widget.customer,
                heroTag: widget.customer.id ?? widget.customer.name,
              ),
            ),
          );
        },
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
                // Header Section
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
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customer.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _copyToClipboard(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                      'ID: ${widget.customer.id?.substring(0, 8) ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: colors.info,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.copy, size: 10, color: colors.info),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: _handleMenuAction,
                        icon: Icon(Icons.more_vert, color: colors.textSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18, color: colors.textSecondary),
                                const SizedBox(width: 12),
                                const Text('View Details'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: colors.textSecondary),
                                const SizedBox(width: 12),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          if (orderCount > 0)
                            PopupMenuItem(
                              value: 'orders',
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long, size: 18, color: colors.textSecondary),
                                  const SizedBox(width: 12),
                                  const Text('View Orders'),
                                ],
                              ),
                            ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: colors.error),
                                const SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: colors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status & Details
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _buildStatus(colors),
                      const SizedBox(height: 6),
                      _buildStatsRow(colors, orderCount, pendingAmount),
                      const SizedBox(height: 6),
                      _buildInfoRow(icon: Icons.email_outlined, label: widget.customer.email, colors: colors),
                      const SizedBox(height: 4),
                      _buildInfoRow(icon: Icons.phone_outlined, label: widget.customer.phone, colors: colors),
                      if (widget.customer.address != null && widget.customer.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow(icon: Icons.location_on_outlined, label: widget.customer.address!, colors: colors, maxLines: 2),
                      ],
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 11, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Joined ${_formatDate(widget.customer.created_at)}',
                          style: TextStyle(fontSize: 10, color: colors.textSecondary),
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
      ),
    );
  }

  Widget _buildStatus(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusColor(colors).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(colors).withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _getStatusColor(colors), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(colors)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppThemeColors colors, int orderCount, double pendingAmount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(colors, Icons.shopping_bag, orderCount.toString(), 'Orders', colors.info),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            colors,
            Icons.payment,
            '₹${pendingAmount.toStringAsFixed(0)}',
            'Pending',
            pendingAmount > 0 ? colors.error : colors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(AppThemeColors colors, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          Text(label, style: TextStyle(fontSize: 9, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required AppThemeColors colors,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: colors.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textPrimary),
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view':
        widget.onViewDetails?.call();
        break;
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'orders':
        widget.onViewOrders?.call();
        break;
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    if (widget.customer.id != null) {
      await Clipboard.setData(ClipboardData(text: widget.customer.id!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Customer ID copied: ${widget.customer.id}')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return 'yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}
