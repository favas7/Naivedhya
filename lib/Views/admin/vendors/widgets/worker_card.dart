// lib/Views/admin/vendors/widgets/worker_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/worker_model.dart';
import 'package:naivedhya/utils/color_theme.dart';

class WorkerCard extends StatefulWidget {
  final Worker worker;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHardDelete;
  final VoidCallback? onReactivate;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onEdit,
    this.onDelete,
    this.onHardDelete,
    this.onReactivate,
  });

  @override
  State<WorkerCard> createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
  bool _isHovered = false;

  IconData _getRoleIcon() {
    final role = widget.worker.role.toLowerCase();
    if (role.contains('chef') || role.contains('cook')) {
      return Icons.restaurant;
    } else if (role.contains('waiter') || role.contains('server')) {
      return Icons.room_service;
    } else if (role.contains('clean')) {
      return Icons.cleaning_services;
    } else if (role.contains('driver') || role.contains('delivery')) {
      return Icons.local_shipping;
    } else if (role.contains('security') || role.contains('guard')) {
      return Icons.security;
    } else if (role.contains('manager')) {
      return Icons.manage_accounts;
    } else if (role.contains('cashier') || role.contains('reception')) {
      return Icons.point_of_sale;
    } else if (role.contains('helper') || role.contains('assistant')) {
      return Icons.handyman;
    } else {
      return Icons.person;
    }
  }

  Color _getRoleColor(AppThemeColors colors) {
    final role = widget.worker.role.toLowerCase();
    if (role.contains('chef') || role.contains('cook')) {
      return colors.primary;
    } else if (role.contains('waiter') || role.contains('server')) {
      return colors.info;
    } else if (role.contains('clean')) {
      return colors.success;
    } else if (role.contains('driver') || role.contains('delivery')) {
      return colors.warning;
    } else if (role.contains('manager')) {
      return colors.primary;
    } else {
      return colors.textSecondary;
    }
  }

  Color _getStatusColor(AppThemeColors colors) {
    switch (widget.worker.employmentStatus) {
      case 'Active':
        return colors.success;
      case 'On Leave':
        return colors.warning;
      case 'Inactive':
        return colors.error;
      default:
        return colors.textSecondary;
    }
  }

  Color _getShiftColor(AppThemeColors colors) {
    switch (widget.worker.shiftType) {
      case 'Morning':
        return colors.warning;
      case 'Evening':
        return colors.info;
      case 'Night':
        return colors.primary;
      case 'Rotating':
        return colors.success;
      default:
        return colors.textSecondary;
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
                  ? _getRoleColor(colors).withOpacity(0.3)
                  : colors.textSecondary.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _getRoleColor(colors).withOpacity(0.1)
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRoleColor(colors).withOpacity(0.1),
                      _getRoleColor(colors).withOpacity(0.05),
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
                    // Worker Avatar/Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getRoleColor(colors),
                            _getRoleColor(colors).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getRoleColor(colors).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.worker.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.worker.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _getRoleIcon(),
                                    color: Colors.white,
                                    size: 24,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              _getRoleIcon(),
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Worker Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.worker.name,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(colors).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.worker.role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getRoleColor(colors),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Button
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
                        if (!widget.worker.isActive && widget.onReactivate != null)
                          PopupMenuItem(
                            value: 'reactivate',
                            child: Row(
                              children: [
                                Icon(Icons.restore,
                                    size: 18, color: colors.success),
                                const SizedBox(width: 12),
                                Text('Reactivate',
                                    style: TextStyle(color: colors.success)),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.block,
                                  size: 18, color: colors.warning),
                              const SizedBox(width: 12),
                              Text('Deactivate',
                                  style: TextStyle(color: colors.warning)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever,
                                  size: 18, color: colors.error),
                              const SizedBox(width: 12),
                              Text('Delete Permanently',
                                  style: TextStyle(color: colors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badges
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Employment Status
                    _buildBadge(
                      colors,
                      widget.worker.employmentStatus,
                      _getStatusColor(colors),
                      Icons.work_outline,
                    ),
                    const SizedBox(width: 8),
                    // Shift Type
                    _buildBadge(
                      colors,
                      widget.worker.shiftType,
                      _getShiftColor(colors),
                      Icons.schedule,
                    ),
                    if (!widget.worker.isActive) ...[
                      const SizedBox(width: 8),
                      _buildBadge(
                        colors,
                        'Inactive',
                        colors.error,
                        Icons.cancel,
                      ),
                    ],
                  ],
                ),
              ),

              // Contact Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: widget.worker.phone,
                      colors: colors,
                    ),
                    if (widget.worker.email != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: widget.worker.email!,
                        colors: colors,
                      ),
                    ],
                    if (widget.worker.workingHours != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: widget.worker.workingHours!,
                        colors: colors,
                      ),
                    ],
                    if (widget.worker.idProofType != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: widget.worker.idProofType!,
                        colors: colors,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      Icons.person_pin,
                      size: 13,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(widget.worker.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.worker.id != null)
                      Text(
                        'ID: ${widget.worker.id!.substring(0, 6)}',
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

  Widget _buildBadge(
      AppThemeColors colors, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
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
        const SizedBox(width: 10),
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
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'deactivate':
        widget.onDelete?.call();
        break;
      case 'delete':
        widget.onHardDelete?.call();
        break;
      case 'reactivate':
        widget.onReactivate?.call();
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