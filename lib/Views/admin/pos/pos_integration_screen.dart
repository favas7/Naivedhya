import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class POSIntegrationScreen extends StatefulWidget {
  const POSIntegrationScreen({super.key});

  @override
  State<POSIntegrationScreen> createState() => _POSIntegrationScreenState();
}

class _POSIntegrationScreenState extends State<POSIntegrationScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 480 && screenWidth <= 768;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(theme, isDesktop),
            const SizedBox(height: 24),

            // Stats Overview
            _buildStatsOverview(theme, isDesktop, isTablet),
            const SizedBox(height: 24),

            // POS Systems Grid/List
            _buildPOSSystemsList(theme, isDesktop, isTablet),
            const SizedBox(height: 24),

            // Integration Health & Sync Status
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildIntegrationHealth(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentSyncActivity(theme)),
                ],
              )
            else ...[
              _buildIntegrationHealth(theme),
              const SizedBox(height: 16),
              _buildRecentSyncActivity(theme),
            ],
            const SizedBox(height: 24),

            // API Configuration
            _buildAPIConfiguration(theme, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS Integration',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: isDesktop ? 28 : 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and monitor your Point of Sale system integrations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New POS'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AppThemeColors theme, bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 1.8 : 2.5),
      children: [
        _buildStatCard(theme, 'Connected Systems', '8', Icons.devices, theme.success),
        _buildStatCard(theme, 'Active Connections', '7', Icons.link, theme.info),
        _buildStatCard(theme, 'Failed Syncs', '2', Icons.sync_problem, theme.error),
        _buildStatCard(theme, 'Total Transactions', '12.4K', Icons.receipt_long, theme.primary),
      ],
    );
  }

  Widget _buildStatCard(AppThemeColors theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOSSystemsList(AppThemeColors theme, bool isDesktop, bool isTablet) {
    final posSystems = [
      {
        'name': 'Square POS',
        'restaurant': 'Pizza Paradise',
        'status': 'Connected',
        'lastSync': '2 mins ago',
        'transactions': 1234,
        'health': 98.5,
      },
      {
        'name': 'Clover POS',
        'restaurant': 'Burger Station',
        'status': 'Connected',
        'lastSync': '5 mins ago',
        'transactions': 987,
        'health': 99.2,
      },
      {
        'name': 'Toast POS',
        'restaurant': 'Sushi World',
        'status': 'Warning',
        'lastSync': '45 mins ago',
        'transactions': 756,
        'health': 85.3,
      },
      {
        'name': 'Lightspeed POS',
        'restaurant': 'Biryani House',
        'status': 'Connected',
        'lastSync': '1 min ago',
        'transactions': 2341,
        'health': 97.8,
      },
      {
        'name': 'TouchBistro',
        'restaurant': 'Cafe Mocha',
        'status': 'Disconnected',
        'lastSync': '2 hours ago',
        'transactions': 543,
        'health': 45.0,
      },
      {
        'name': 'Revel Systems',
        'restaurant': 'Taco Bell Express',
        'status': 'Connected',
        'lastSync': '3 mins ago',
        'transactions': 1876,
        'health': 96.4,
      },
      {
        'name': 'ShopKeep',
        'restaurant': 'Salad Bar',
        'status': 'Connected',
        'lastSync': '1 min ago',
        'transactions': 432,
        'health': 99.5,
      },
      {
        'name': 'Vend POS',
        'restaurant': 'Dessert Heaven',
        'status': 'Warning',
        'lastSync': '30 mins ago',
        'transactions': 654,
        'health': 88.2,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connected POS Systems',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                  color: theme.primary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDesktop)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(0.8),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    _buildTableHeader('POS System'),
                    _buildTableHeader('Restaurant'),
                    _buildTableHeader('Status'),
                    _buildTableHeader('Last Sync'),
                    _buildTableHeader('Health'),
                    _buildTableHeader('Actions'),
                  ],
                ),
                ...posSystems.map((pos) => _buildPOSTableRow(theme, pos)),
              ],
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posSystems.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.textSecondary.withOpacity(0.2),
                height: 24,
              ),
              itemBuilder: (context, index) => _buildPOSCard(theme, posSystems[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildPOSTableRow(AppThemeColors theme, Map<String, dynamic> pos) {
    return TableRow(
      children: [
        _buildTableCell(theme, pos['name'] as String, isIcon: true),
        _buildTableCell(theme, pos['restaurant'] as String),
        _buildStatusCell(theme, pos['status'] as String),
        _buildTableCell(theme, pos['lastSync'] as String),
        _buildHealthCell(theme, pos['health'] as double),
        _buildActionsCell(theme),
      ],
    );
  }

  Widget _buildTableCell(AppThemeColors theme, String text, {bool isIcon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          if (isIcon) ...[
            Icon(Icons.devices, color: theme.primary, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(AppThemeColors theme, String status) {
    Color statusColor;
    Color bgColor;
    
    switch (status.toLowerCase()) {
      case 'connected':
        statusColor = theme.success;
        bgColor = theme.success.withOpacity(0.1);
        break;
      case 'warning':
        statusColor = theme.warning;
        bgColor = theme.warning.withOpacity(0.1);
        break;
      case 'disconnected':
        statusColor = theme.error;
        bgColor = theme.error.withOpacity(0.1);
        break;
      default:
        statusColor = theme.textSecondary;
        bgColor = theme.textSecondary.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCell(AppThemeColors theme, double health) {
    Color healthColor;
    if (health >= 95) {
      healthColor = theme.success;
    } else if (health >= 80) {
      healthColor = theme.warning;
    } else {
      healthColor = theme.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: health / 100,
                backgroundColor: healthColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${health.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: healthColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell(AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {},
            color: theme.info,
            tooltip: 'Sync Now',
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () {},
            color: theme.textSecondary,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildPOSCard(AppThemeColors theme, Map<String, dynamic> pos) {
    final status = pos['status'] as String;
    Color statusColor;
    
    switch (status.toLowerCase()) {
      case 'connected':
        statusColor = theme.success;
        break;
      case 'warning':
        statusColor = theme.warning;
        break;
      case 'disconnected':
        statusColor = theme.error;
        break;
      default:
        statusColor = theme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDark 
          ? AppTheme.darkSurfaceVariant 
          : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: theme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pos['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      pos['restaurant'] as String,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Sync',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    pos['lastSync'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${(pos['health'] as double).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: (pos['health'] as double) >= 95 ? theme.success : theme.warning,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () {},
                    color: theme.info,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 20),
                    onPressed: () {},
                    color: theme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationHealth(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: theme.success, size: 24),
              const SizedBox(width: 12),
              Text(
                'Integration Health',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildHealthItem(theme, 'API Response Time', '245ms', theme.success, 0.95),
          const SizedBox(height: 16),
          _buildHealthItem(theme, 'Sync Success Rate', '94.5%', theme.success, 0.945),
          const SizedBox(height: 16),
          _buildHealthItem(theme, 'Data Accuracy', '98.2%', theme.success, 0.982),
          const SizedBox(height: 16),
          _buildHealthItem(theme, 'Error Rate', '2.3%', theme.warning, 0.023),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.success.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All systems operational',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: theme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(AppThemeColors theme, String label, String value, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSyncActivity(AppThemeColors theme) {
    final activities = [
      {'system': 'Square POS', 'action': 'Sync completed', 'time': '2 mins ago', 'status': 'success'},
      {'system': 'Clover POS', 'action': 'Sync completed', 'time': '5 mins ago', 'status': 'success'},
      {'system': 'Toast POS', 'action': 'Sync delayed', 'time': '45 mins ago', 'status': 'warning'},
      {'system': 'Lightspeed POS', 'action': 'Sync completed', 'time': '1 min ago', 'status': 'success'},
      {'system': 'TouchBistro', 'action': 'Connection lost', 'time': '2 hours ago', 'status': 'error'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sync Activity',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Icon(Icons.history, color: theme.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.textSecondary.withOpacity(0.2),
              height: 24,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              Color statusColor;
              IconData statusIcon;

              switch (activity['status']) {
                case 'success':
                  statusColor = theme.success;
                  statusIcon = Icons.check_circle;
                  break;
                case 'warning':
                  statusColor = theme.warning;
                  statusIcon = Icons.warning;
                  break;
                case 'error':
                  statusColor = theme.error;
                  statusIcon = Icons.error;
                  break;
                default:
                  statusColor = theme.textSecondary;
                  statusIcon = Icons.info;
              }

              return Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['system'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          activity['action'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAPIConfiguration(AppThemeColors theme, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'API Configuration',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Icon(Icons.api, color: theme.primary, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 2 : 3,
            children: [
              _buildConfigItem(theme, 'Webhook URL', 'https://api.naivedhya.com/webhook', Icons.link),
              _buildConfigItem(theme, 'API Version', 'v2.1.0', Icons.code),
              _buildConfigItem(theme, 'Rate Limit', '1000 req/min', Icons.speed),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy API Key'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.primary),
                    foregroundColor: theme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('Configure API'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(AppThemeColors theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDark 
          ? AppTheme.darkSurfaceVariant 
          : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}