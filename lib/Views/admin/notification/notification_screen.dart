import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/models/activity_model.dart';
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ActivityType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          Consumer<ActivityProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () => provider.markAllAsRead(),
                  icon: Icon(Icons.done_all, color: colors.primary),
                  label: Text(
                    'Mark all read',
                    style: TextStyle(color: colors.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textPrimary),
            onPressed: () {
              context.read<ActivityProvider>().refresh();
            },
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header Section with Filter and Send Button
              Container(
                padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                color: colors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Expanded(
                        //   child: ElevatedButton.icon(
                        //     onPressed: () => _showSendNotificationDialog(context),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: colors.primary,
                        //       foregroundColor: AppTheme.white,
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: isDesktop ? 24 : 16,
                        //         vertical: isDesktop ? 16 : 12,
                        //       ),
                        //     ),
                        //     icon: const Icon(Icons.send),
                        //     label: Text(
                        //       'Send New Notification',
                        //       style: TextStyle(
                        //         fontSize: isDesktop ? 16 : 14,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // if (provider.unreadCount > 0) ...[
                        //   SizedBox(width: isDesktop ? 16 : 12),
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 12,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: colors.error.withOpacity(0.1),
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(
                        //         color: colors.error.withOpacity(0.3),
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.notifications_active,
                        //           color: colors.error,
                        //           size: 20,
                        //         ),
                        //         const SizedBox(width: 8),
                        //         Text(
                        //           '${provider.unreadCount}',
                        //           style: TextStyle(
                        //             color: colors.error,
                        //             fontSize: isDesktop ? 18 : 16,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            label: 'All',
                            isSelected: _selectedFilter == null,
                            onTap: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ...ActivityType.values.map((type) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(
                                context,
                                label: _getActivityTypeLabel(type),
                                icon: _getActivityIcon(type),
                                isSelected: _selectedFilter == type,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = type;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        //   if (provider.unreadCount > 0) ...[
                        //   SizedBox(width: isDesktop ? 16 : 12),
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 12,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: colors.error.withOpacity(0.1),
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(
                        //         color: colors.error.withOpacity(0.3),
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.notifications_active,
                        //           color: colors.error,
                        //           size: 20,
                        //         ),
                        //         const SizedBox(width: 8),
                        //         Text(
                        //           '${provider.unreadCount}',
                        //           style: TextStyle(
                        //             color: colors.error,
                        //             fontSize: isDesktop ? 18 : 16,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              

              // Notifications List
              Expanded(
                child: _buildNotificationsList(context, provider, isDesktop),
                
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ActivityProvider provider,
    bool isDesktop,
  ) {
    final colors = AppTheme.of(context);

    if (provider.isLoading && provider.activities.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isDesktop ? 64 : 48,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.error,
                    fontSize: isDesktop ? 18 : 16,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      );
    }

    // Filter activities
    final filteredActivities = _selectedFilter == null
        ? provider.activities
        : provider.activities
            .where((activity) => activity.activityType == _selectedFilter)
            .toList();

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: isDesktop ? 80 : 64,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == null
                  ? 'No notifications yet'
                  : 'No ${_getActivityTypeLabel(_selectedFilter!).toLowerCase()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    fontSize: isDesktop ? 18 : 16,
                  ),
            ),
            if (_selectedFilter != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = null;
                  });
                },
                child: Text(
                  'Clear filter',
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            itemCount: filteredActivities.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: isDesktop ? 16 : 12),
            itemBuilder: (context, index) {
              final activity = filteredActivities[index];
              return _NotificationTile(
                activity: activity,
                isDesktop: isDesktop,
                onTap: () {
                  provider.markAsRead(activity.id);
                  _showNotificationDetails(context, activity, isDesktop);
                },
              );
            },
          ),
        ),

        // Pagination
        if (provider.totalPages > 1)
          Container(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.textSecondary.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: provider.hasPreviousPage
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                  onPressed: provider.hasPreviousPage
                      ? () => provider.previousPage()
                      : null,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Page ${provider.currentPage} of ${provider.totalPages}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: isDesktop ? 16 : 14,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: provider.hasNextPage
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                  onPressed:
                      provider.hasNextPage ? () => provider.nextPage() : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.white : colors.textPrimary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.white : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    ActivityModel activity,
    bool isDesktop,
  ) {
    final colors = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.activityType, colors)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.activityType),
                color: _getActivityColor(activity.activityType, colors),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activity.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontSize: isDesktop ? 20 : 18,
                    ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activity.description != null) ...[
                Text(
                  activity.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activity.getTimeAgo(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                  ),
                  if (activity.amount != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.currency_rupee,
                      size: 16,
                      color: colors.success,
                    ),
                    Text(
                      activity.amount!.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 14 : 12,
                          ),
                    ),
                  ],
                ],
              ),
              if (activity.metadata != null) ...[
                const SizedBox(height: 16),
                Divider(color: colors.textSecondary.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                ),
                const SizedBox(height: 12),
                ..._buildMetadataDetails(context, activity, colors, isDesktop),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: colors.primary,
                fontSize: isDesktop ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _showSendNotificationDialog(BuildContext context) {
  //   final colors = AppTheme.of(context);
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final isDesktop = screenWidth > 768;

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: colors.surface,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       title: Text(
  //         'Send Notification',
  //         style: TextStyle(
  //           color: colors.textPrimary,
  //           fontSize: isDesktop ? 20 : 18,
  //         ),
  //       ),
  //       content: Text(
  //         'Notification sending feature will be implemented soon.',
  //         style: TextStyle(
  //           color: colors.textSecondary,
  //           fontSize: isDesktop ? 16 : 14,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'OK',
  //             style: TextStyle(
  //               color: colors.primary,
  //               fontSize: isDesktop ? 16 : 14,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  List<Widget> _buildMetadataDetails(
    BuildContext context,
    ActivityModel activity,
    AppThemeColors colors,
    bool isDesktop,
  ) {
    final metadata = activity.metadata;
    if (metadata == null) return [];

    final widgets = <Widget>[];

    switch (activity.activityType) {
      case ActivityType.newOrder:
        if (metadata.containsKey('order_id')) {
          widgets.add(_buildMetadataRow(
            context,
            'Order ID',
            metadata['order_id'] as String,
            colors,
            isDesktop,
          ));
        }
        if (metadata.containsKey('total')) {
          widgets.add(_buildMetadataRow(
            context,
            'Total',
            '₹${metadata['total']}',
            colors,
            isDesktop,
          ));
        }
        break;

      case ActivityType.deliveryStatus:
        if (metadata.containsKey('status')) {
          widgets.add(_buildMetadataRow(
            context,
            'Status',
            metadata['status'] as String,
            colors,
            isDesktop,
          ));
        }
        if (metadata.containsKey('location')) {
          widgets.add(_buildMetadataRow(
            context,
            'Location',
            metadata['location'] as String,
            colors,
            isDesktop,
          ));
        }
        break;

      case ActivityType.newCustomer:
        if (metadata.containsKey('customer_name')) {
          widgets.add(_buildMetadataRow(
            context,
            'Customer',
            metadata['customer_name'] as String,
            colors,
            isDesktop,
          ));
        }
        if (metadata.containsKey('total_orders')) {
          widgets.add(_buildMetadataRow(
            context,
            'Total Orders',
            metadata['total_orders'].toString(),
            colors,
            isDesktop,
          ));
        }
        break;

      case ActivityType.revenueMilestone:
        if (metadata.containsKey('target')) {
          widgets.add(_buildMetadataRow(
            context,
            'Target',
            '₹${metadata['target']}',
            colors,
            isDesktop,
          ));
        }
        if (metadata.containsKey('achieved')) {
          widgets.add(_buildMetadataRow(
            context,
            'Achieved',
            '₹${metadata['achieved']}',
            colors,
            isDesktop,
          ));
        }
        if (metadata.containsKey('milestone_type')) {
          widgets.add(_buildMetadataRow(
            context,
            'Type',
            metadata['milestone_type'] as String,
            colors,
            isDesktop,
          ));
        }
        break;
    }

    return widgets;
  }

  Widget _buildMetadataRow(
    BuildContext context,
    String label,
    String value,
    AppThemeColors colors,
    bool isDesktop,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                  fontSize: isDesktop ? 15 : 13,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  fontSize: isDesktop ? 15 : 13,
                ),
          ),
        ],
      ),
    );
  }

  String _getActivityTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.newOrder:
        return 'New Orders';
      case ActivityType.deliveryStatus:
        return 'Deliveries';
      case ActivityType.newCustomer:
        return 'New Customers';
      case ActivityType.revenueMilestone:
        return 'Milestones';
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.newOrder:
        return Icons.shopping_bag;
      case ActivityType.deliveryStatus:
        return Icons.local_shipping;
      case ActivityType.newCustomer:
        return Icons.person_add;
      case ActivityType.revenueMilestone:
        return Icons.celebration;
    }
  }

  Color _getActivityColor(ActivityType type, AppThemeColors colors) {
    switch (type) {
      case ActivityType.newOrder:
        return colors.warning;
      case ActivityType.deliveryStatus:
        return colors.info;
      case ActivityType.newCustomer:
        return colors.info;
      case ActivityType.revenueMilestone:
        return colors.success;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final ActivityModel activity;
  final bool isDesktop;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.activity,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          color: activity.isRead ? colors.surface : colors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activity.isRead
                ? colors.textSecondary.withOpacity(0.15)
                : colors.primary.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(isDesktop ? 12 : 10),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.activityType, colors)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity.activityType),
                color: _getActivityColor(activity.activityType, colors),
                size: isDesktop ? 24 : 20,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: activity.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: colors.textPrimary,
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                        ),
                      ),
                      if (!activity.isRead)
                        Container(
                          width: isDesktop ? 10 : 8,
                          height: isDesktop ? 10 : 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (activity.description != null) ...[
                    SizedBox(height: isDesktop ? 6 : 4),
                    Text(
                      activity.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            fontSize: isDesktop ? 14 : 12,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: isDesktop ? 12 : 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isDesktop ? 14 : 12,
                        color: colors.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.getTimeAgo(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary.withOpacity(0.7),
                              fontSize: isDesktop ? 13 : 11,
                            ),
                      ),
                      if (activity.amount != null) ...[
                        SizedBox(width: isDesktop ? 16 : 12),
                        Icon(
                          Icons.currency_rupee,
                          size: isDesktop ? 14 : 12,
                          color: colors.success,
                        ),
                        Text(
                          activity.amount!.toStringAsFixed(2),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 13 : 11,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              size: isDesktop ? 24 : 20,
              color: colors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.newOrder:
        return Icons.shopping_bag;
      case ActivityType.deliveryStatus:
        return Icons.local_shipping;
      case ActivityType.newCustomer:
        return Icons.person_add;
      case ActivityType.revenueMilestone:
        return Icons.celebration;
    }
  }

  Color _getActivityColor(ActivityType type, AppThemeColors colors) {
    switch (type) {
      case ActivityType.newOrder:
        return colors.warning;
      case ActivityType.deliveryStatus:
        return colors.info;
      case ActivityType.newCustomer:
        return colors.info;
      case ActivityType.revenueMilestone:
        return colors.success;
    }
  }
} 