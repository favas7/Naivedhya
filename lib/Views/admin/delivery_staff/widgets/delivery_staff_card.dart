import 'package:flutter/material.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class DeliveryStaffCard extends StatefulWidget {
  final DeliveryPersonnel staff;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleAvailability;
  final VoidCallback? onViewDetails;
  final VoidCallback? onViewOrders;
  final VoidCallback? onVerify;

  const DeliveryStaffCard({
    super.key,
    required this.staff,
    this.onEdit,
    this.onToggleAvailability,
    this.onViewDetails,
    this.onViewOrders,
    this.onVerify,
  });

  @override
  State<DeliveryStaffCard> createState() => _DeliveryStaffCardState();
}

class _DeliveryStaffCardState extends State<DeliveryStaffCard> {
  bool _isHovered = false;

  IconData _getVehicleIcon() {
    final vehicleType = widget.staff.vehicleType.toLowerCase();
    if (vehicleType.contains('bike') || vehicleType.contains('motorcycle') || vehicleType.contains('scooter')) {
      return Icons.two_wheeler;
    } else if (vehicleType.contains('car') || vehicleType.contains('sedan')) {
      return Icons.directions_car;
    } else if (vehicleType.contains('truck') || vehicleType.contains('van')) {
      return Icons.local_shipping;
    } else if (vehicleType.contains('cycle') || vehicleType.contains('bicycle')) {
      return Icons.pedal_bike;
    } else {
      return Icons.delivery_dining;
    }
  }

  Color _getVehicleColor(AppThemeColors colors) {
    final vehicleType = widget.staff.vehicleType.toLowerCase();
    if (vehicleType.contains('bike') || vehicleType.contains('motorcycle')) {
      return colors.primary;
    } else if (vehicleType.contains('car')) {
      return colors.info;
    } else if (vehicleType.contains('truck')) {
      return colors.warning;
    } else {
      return colors.primary;
    }
  }

  Color _getStatusColor(AppThemeColors colors) {
    if (!widget.staff.isAvailable) {
      return colors.warning; // Busy/Not available
    } else if (widget.staff.assignedOrders.isNotEmpty) {
      return colors.info; // On delivery
    } else {
      return colors.success; // Available
    }
  }

  String _getStatusText() {
    if (!widget.staff.isAvailable) {
      return 'Busy';
    } else if (widget.staff.assignedOrders.isNotEmpty) {
      return 'On Delivery';
    } else {
      return 'Available';
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
                  ? _getVehicleColor(colors).withOpacity(0.3)
                  : colors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _getVehicleColor(colors).withOpacity(0.1)
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getVehicleColor(colors).withOpacity(0.1),
                      _getVehicleColor(colors).withOpacity(0.05),
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
                    // Vehicle Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getVehicleColor(colors),
                            _getVehicleColor(colors).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getVehicleColor(colors).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getVehicleIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Staff Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.staff.displayName,
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
                              // Verification Badge
                              if (widget.staff.isVerified)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colors.success.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: colors.success,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Vehicle Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getVehicleColor(colors).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getVehicleColor(colors).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.staff.vehicleType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getVehicleColor(colors),
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
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                widget.staff.isAvailable
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(widget.staff.isAvailable
                                  ? 'Mark Busy'
                                  : 'Mark Available'),
                            ],
                          ),
                        ),
                        if (!widget.staff.isVerified) ...[
                          PopupMenuItem(
                            value: 'verify',
                            child: Row(
                              children: [
                                Icon(Icons.verified,
                                    size: 18, color: colors.success),
                                const SizedBox(width: 12),
                                Text('Verify',
                                    style: TextStyle(color: colors.success)),
                              ],
                            ),
                          ),
                        ],
                        if (widget.staff.assignedOrders.isNotEmpty) ...[
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'orders',
                            child: Row(
                              children: [
                                Icon(Icons.list_alt,
                                    size: 18, color: colors.textSecondary),
                                const SizedBox(width: 12),
                                const Text('View Orders'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status & Stats Section
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
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
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(colors),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            colors,
                            Icons.payments,
                            '₹${widget.staff.earnings.toStringAsFixed(0)}',
                            'Earnings',
                            colors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatItem(
                            colors,
                            Icons.shopping_bag,
                            widget.staff.activeOrdersCount.toString(),
                            'Orders',
                            colors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Contact Info
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: widget.staff.phone,
                      colors: colors,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      icon: Icons.location_city_outlined,
                      label: '${widget.staff.city}, ${widget.staff.state}',
                      colors: colors,
                    ),
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
                      Icons.directions_car_outlined,
                      size: 13,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.staff.numberPlate,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(widget.staff.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary.withOpacity(0.7),
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

  Widget _buildStatItem(
    AppThemeColors colors,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required AppThemeColors colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textPrimary,
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
      case 'toggle':
        widget.onToggleAvailability?.call();
        break;
      case 'verify':
        widget.onVerify?.call();
        break;
      case 'orders':
        widget.onViewOrders?.call();
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}