import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/models/activity_model.dart';
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class ActivityFeedWidget extends StatelessWidget {
  const ActivityFeedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Consumer<ActivityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.activities.isEmpty) {
          return _buildCard(
            context,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
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
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load activities',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.error,
                        ),
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
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.textSecondary,
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
                      color: colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
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
                          color: colors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colors.textPrimary,
                      ),
                      onSelected: (value) {
                        if (value == 'mark_all_read') {
                          provider.markAllAsRead();
                        } else if (value == 'refresh') {
                          provider.refresh();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'mark_all_read',
                          child: Row(
                            children: [
                              Icon(
                                Icons.done_all,
                                size: 20,
                                color: colors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mark all as read',
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 20,
                                color: colors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Refresh',
                                style: TextStyle(color: colors.textPrimary),
                              ),
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
                color: colors.textSecondary.withOpacity(0.2),
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
                          color: colors.textSecondary,
                        ),
                        onPressed: provider.hasPreviousPage
                            ? () => provider.previousPage()
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Page ${provider.currentPage} of ${provider.totalPages}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.textPrimary,
                            ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: colors.textSecondary,
                        ),
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

  static Widget _buildCard(BuildContext context, {required Widget child}) {
    final colors = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static void _handleActivityTap(
      BuildContext context, ActivityModel activity) {
    final colors = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          activity.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
              ),
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
                      ),
                ),
                const SizedBox(height: 16),
              ],
              if (activity.metadata != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildMetadataDetails(
                        context, activity, colors),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildMetadataDetails(
      BuildContext context, ActivityModel activity, AppThemeColors colors) {
    final metadata = activity.metadata;
    if (metadata == null) return [];

    final widgets = <Widget>[];

    switch (activity.activityType) {
      case ActivityType.newOrder:
        if (metadata.containsKey('order_id')) {
          widgets.add(_buildMetadataRow(
              context, 'Order ID', metadata['order_id'] as String, colors));
        }
        if (metadata.containsKey('total')) {
          widgets.add(_buildMetadataRow(context, 'Total',
              '₹${metadata['total']}', colors));
        }
        break;

      case ActivityType.deliveryStatus:
        if (metadata.containsKey('status')) {
          widgets.add(_buildMetadataRow(
              context, 'Status', metadata['status'] as String, colors));
        }
        if (metadata.containsKey('location')) {
          widgets.add(_buildMetadataRow(context, 'Location',
              metadata['location'] as String, colors));
        }
        break;

      case ActivityType.newCustomer:
        if (metadata.containsKey('customer_name')) {
          widgets.add(_buildMetadataRow(context, 'Customer',
              metadata['customer_name'] as String, colors));
        }
        if (metadata.containsKey('total_orders')) {
          widgets.add(_buildMetadataRow(context, 'Total Orders',
              metadata['total_orders'].toString(), colors));
        }
        break;

      case ActivityType.revenueMilestone:
        if (metadata.containsKey('target')) {
          widgets.add(_buildMetadataRow(context, 'Target',
              '₹${metadata['target']}', colors));
        }
        if (metadata.containsKey('achieved')) {
          widgets.add(_buildMetadataRow(context, 'Achieved',
              '₹${metadata['achieved']}', colors));
        }
        if (metadata.containsKey('milestone_type')) {
          widgets.add(_buildMetadataRow(context, 'Type',
              metadata['milestone_type'] as String, colors));
        }
        break;
    }

    return widgets;
  }

  static Widget _buildMetadataRow(BuildContext context, String label,
      String value, AppThemeColors colors) {
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
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
          ),
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
    final colors = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: activity.isRead
              ? Colors.transparent
              : colors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activity.isRead
                ? colors.textSecondary.withOpacity(0.15)
                : colors.primary.withOpacity(0.25),
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
                color: _getActivityColor(activity.activityType, colors)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(activity.activityType),
                color: _getActivityColor(activity.activityType, colors),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: activity.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                        ),
                      ),
                      if (!activity.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (activity.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      activity.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
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
                        color: colors.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.getTimeAgo(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary.withOpacity(0.7),
                            ),
                      ),
                      if (activity.amount != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.currency_rupee,
                          size: 12,
                          color: colors.success,
                        ),
                        Text(
                          activity.amount!.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.success,
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