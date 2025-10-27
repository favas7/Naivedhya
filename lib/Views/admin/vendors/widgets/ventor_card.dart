import 'package:flutter/material.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class VendorCard extends StatefulWidget {
  final Vendor vendor;
  final String? restaurantName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;

  const VendorCard({
    super.key,
    required this.vendor,
    this.restaurantName,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
  });

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {
  bool _isHovered = false;

  IconData _getServiceIcon() {
    final serviceType = widget.vendor.serviceType.toLowerCase();
    if (serviceType.contains('food') || serviceType.contains('beverage')) {
      return Icons.restaurant;
    } else if (serviceType.contains('maintenance') || serviceType.contains('repair')) {
      return Icons.build;
    } else if (serviceType.contains('cleaning') || serviceType.contains('housekeeping')) {
      return Icons.cleaning_services;
    } else if (serviceType.contains('delivery') || serviceType.contains('logistics')) {
      return Icons.local_shipping;
    } else if (serviceType.contains('security')) {
      return Icons.security;
    } else if (serviceType.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (serviceType.contains('garden') || serviceType.contains('landscaping')) {
      return Icons.grass;
    } else {
      return Icons.business_center;
    }
  }

  Color _getServiceColor(AppThemeColors colors) {
    final serviceType = widget.vendor.serviceType.toLowerCase();
    if (serviceType.contains('food') || serviceType.contains('beverage')) {
      return colors.primary;
    } else if (serviceType.contains('maintenance') || serviceType.contains('repair')) {
      return colors.warning;
    } else if (serviceType.contains('cleaning')) {
      return colors.info;
    } else if (serviceType.contains('delivery')) {
      return colors.success;
    } else {
      return colors.primary;
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
                  ? _getServiceColor(colors).withOpacity(0.3)
                  : colors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _getServiceColor(colors).withOpacity(0.1)
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getServiceColor(colors).withOpacity(0.1),
                      _getServiceColor(colors).withOpacity(0.05),
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
                    // Service Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getServiceColor(colors),
                            _getServiceColor(colors).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getServiceColor(colors).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getServiceIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Vendor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.vendor.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Active Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.vendor.isActive
                                      ? colors.success.withOpacity(0.15)
                                      : colors.error.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.vendor.isActive
                                        ? colors.success.withOpacity(0.3)
                                        : colors.error.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: widget.vendor.isActive
                                            ? colors.success
                                            : colors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.vendor.isActive
                                          ? 'Active'
                                          : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: widget.vendor.isActive
                                            ? colors.success
                                            : colors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Service Type
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getServiceColor(colors).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getServiceColor(colors).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.vendor.serviceType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getServiceColor(colors),
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
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 18, color: colors.textSecondary),
                              const SizedBox(width: 12),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: colors.error),
                              const SizedBox(width: 12),
                              Text('Delete',
                                  style: TextStyle(color: colors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contact Info Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Email
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: widget.vendor.email,
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    // Phone
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: widget.vendor.phone,
                      colors: colors,
                    ),
                    const SizedBox(height: 10),
                    // Restaurant
                    if (widget.restaurantName != null)
                      _buildInfoRow(
                        icon: Icons.restaurant_outlined,
                        label: widget.restaurantName!,
                        colors: colors,
                        isHighlight: true,
                      ),
                  ],
                ),
              ),

              // Footer with metadata
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      size: 13,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(widget.vendor.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.vendor.id != null)
                      Text(
                        'ID: ${widget.vendor.id!.substring(0, 6)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary.withOpacity(0.7),
                          fontFamily: 'monospace',
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
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHighlight
                ? colors.primary.withOpacity(0.1)
                : colors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isHighlight ? colors.primary : colors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? colors.primary : colors.textPrimary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
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
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}