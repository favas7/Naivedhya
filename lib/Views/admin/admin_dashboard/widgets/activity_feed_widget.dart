import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/models/activity_model.dart';
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.activities.isEmpty) {
          return _buildCard(
            context,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return _buildCard(
            context,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load activities',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.activities.isEmpty) {
          return _buildCard(
            context,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (provider.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                      onSelected: (value) {
                        if (value == 'mark_all_read') {
                          provider.markAllAsRead();
                        } else if (value == 'refresh') {
                          provider.refresh();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              Icon(Icons.done_all, size: 20),
                              SizedBox(width: 8),
                              Text('Mark all as read'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 20),
                              SizedBox(width: 8),
                              Text('Refresh'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppTheme.darkDivider : AppTheme.divider,
              ),

              // Activity List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.activities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = provider.activities[index];
                    return ActivityTile(
                      activity: activity,
                      onTap: () {
                        provider.markAsRead(activity.id);
                        _handleActivityTap(context, activity);
                      },
                    );
                  },
                ),
              ),

              // Pagination
              if (provider.totalPages > 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppTheme.darkDivider : AppTheme.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: provider.hasPreviousPage
                            ? () => provider.previousPage()
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Page ${provider.currentPage} of ${provider.totalPages}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: provider.hasNextPage
                            ? () => provider.nextPage()
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.darkShadow
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  void _handleActivityTap(BuildContext context, ActivityModel activity) {
    // Navigate to appropriate screen based on activity type
    switch (activity.activityType) {
      case ActivityType.newOrder:
      case ActivityType.deliveryStatus:
        if (activity.orderId != null) {
          // TODO: Navigate to order details
          print('Navigate to order: ${activity.orderId}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ID: ${activity.orderId}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case ActivityType.newCustomer:
        if (activity.customerId != null) {
          // TODO: Navigate to customer details
          print('Navigate to customer: ${activity.customerId}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer ID: ${activity.customerId}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case ActivityType.revenueMilestone:
        _showMilestoneDialog(context, activity);
        break;
    }
  }

  void _showMilestoneDialog(BuildContext context, ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description ?? ''),
            if (activity.metadata != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildMetadataRow('Target', '₹${activity.metadata!['target']}'),
              _buildMetadataRow(
                  'Achieved', '₹${activity.metadata!['achieved']}'),
              _buildMetadataRow(
                  'Type', activity.metadata!['milestone_type']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;

  const ActivityTile({
    Key? key,
    required this.activity,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: activity.isRead
              ? Colors.transparent
              : (isDark
                  ? AppTheme.darkPrimary.withOpacity(0.05)
                  : AppTheme.primary.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activity.isRead
                ? (isDark ? AppTheme.darkDivider : AppTheme.divider)
                : (isDark
                    ? AppTheme.darkPrimary.withOpacity(0.2)
                    : AppTheme.primary.withOpacity(0.2)),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.activityType, isDark)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.activityType),
                color: _getActivityColor(activity.activityType, isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

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
                          style: TextStyle(
                            fontWeight: activity.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!activity.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkPrimary
                                : AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (activity.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      activity.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: isDark
                            ? AppTheme.darkTextHint
                            : AppTheme.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.getTimeAgo(),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkTextHint
                              : AppTheme.textHint,
                        ),
                      ),
                      if (activity.amount != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.currency_rupee,
                          size: 12,
                          color: isDark
                              ? AppTheme.darkSuccess
                              : AppTheme.success,
                        ),
                        Text(
                          activity.amount!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.darkSuccess
                                : AppTheme.success,
                            fontWeight: FontWeight.bold,
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
              size: 20,
              color: isDark ? AppTheme.darkTextHint : AppTheme.textHint,
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

  Color _getActivityColor(ActivityType type, bool isDark) {
    switch (type) {
      case ActivityType.newOrder:
        return isDark ? AppTheme.darkOrderPending : AppTheme.orderPending;
      case ActivityType.deliveryStatus:
        return isDark
            ? AppTheme.darkOrderDelivering
            : AppTheme.orderDelivering;
      case ActivityType.newCustomer:
        return isDark ? AppTheme.darkInfo : AppTheme.info;
      case ActivityType.revenueMilestone:
        return isDark ? AppTheme.darkSuccess : AppTheme.success;
    }
  }
}