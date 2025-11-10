import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
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
          'System Logs',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textPrimary),
            onPressed: () {},
            // onPressed: () => context.read<AdminProvider>().refreshLogs(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingLogs) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (provider.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: colors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No logs available', style: TextStyle(color: colors.textSecondary, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            itemCount: provider.logs.length,
            itemBuilder: (context, index) {
              final log = provider.logs[index];
              return _LogTile(
                log: log,
                isDesktop: isDesktop,
              );
            },
          );
        },
      ),
    );
  }
}

class AdminProvider {
  bool isLoadingLogs = false;
  List<Map<String, dynamic>> logs = [];

  get users => null;

  bool get isLoading => isLoadingLogs;

  bool get isCheckingUpdates => false;

  get updateHistory => null;

  get currentVersion => null;

  void refreshUsers() {}

  void toggleAdminStatus(id) {}

  void deleteUser(String? id) {}

  void checkForUpdates() {}
}

class _LogTile extends StatelessWidget {
  final Map<String, dynamic> log; // Assuming log structure: {timestamp, level, message, userId}
  final bool isDesktop;

  const _LogTile({
    required this.log,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    final levelColor = _getLogLevelColor(log['level'] ?? 'info', colors);

    return Card(
      elevation: 1,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                log['level']?.toUpperCase() ?? 'INFO',
                style: TextStyle(color: levelColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['message'] ?? '',
                    style: TextStyle(fontSize: isDesktop ? 16 : 14, color: colors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: colors.textSecondary),
                      Text(
                        log['timestamp'] ?? '',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                      if (log['userId'] != null) ...[
                        SizedBox(width: 16),
                        Icon(Icons.person, size: 14, color: colors.textSecondary),
                        Text(
                          'User: ${log['userId']}',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLogLevelColor(String level, AppThemeColors colors) {
    switch (level.toLowerCase()) {
      case 'error':
        return colors.error;
      case 'warning':
        return colors.warning;
      case 'success':
        return colors.success;
      default:
        return colors.info;
    }
  }
}