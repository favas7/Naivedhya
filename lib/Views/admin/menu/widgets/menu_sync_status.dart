import 'package:flutter/material.dart';
import 'package:naivedhya/providers/menu_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MenuSyncStatus extends StatelessWidget {
  final String hotelId;

  const MenuSyncStatus({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Consumer<MenuProvider>(
      builder: (context, provider, child) {
        final lastSync = provider.lastSyncLog;

        if (lastSync == null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sync_disabled,
                  size: 16,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Never synced',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final statusColor = lastSync.syncStatus == 'success'
            ? AppTheme.success
            : lastSync.syncStatus == 'failed'
                ? AppTheme.error
                : AppTheme.warning;

        final statusIcon = lastSync.syncStatus == 'success'
            ? Icons.check_circle
            : lastSync.syncStatus == 'failed'
                ? Icons.error
                : Icons.warning;

        final timeAgo = _getTimeAgo(lastSync.syncedAt);

        return InkWell(
          onTap: () => _showSyncHistory(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last sync: $timeAgo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${lastSync.itemsSynced} items, ${lastSync.categoriesSynced} categories',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  void _showSyncHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SyncHistoryDialog(hotelId: hotelId),
    );
  }
}

class _SyncHistoryDialog extends StatelessWidget {
  final String hotelId;

  const _SyncHistoryDialog({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Sync History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // History List
            Expanded(
              child: FutureBuilder(
                future: context.read<MenuProvider>().menuService.getSyncHistory(hotelId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading history',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    );
                  }

                  final logs = snapshot.data ?? [];

                  if (logs.isEmpty) {
                    return Center(
                      child: Text(
                        'No sync history',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final statusColor = log.syncStatus == 'success'
                          ? AppTheme.success
                          : AppTheme.error;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.textSecondary.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.syncStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('MMM d, y h:mm a').format(log.syncedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 14,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${log.itemsSynced} items',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.category,
                                  size: 14,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${log.categoriesSynced} categories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                if (log.syncDurationMs != null) ...[
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: colors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(log.syncDurationMs! / 1000).toStringAsFixed(1)}s',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (log.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 14,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        log.errorMessage!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.error,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}