import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/admin_dashboard/widgets/activity_feed_widget.dart';
import 'package:naivedhya/Views/admin/admin_dashboard/widgets/milestone_settings_widget.dart';
import 'package:naivedhya/providers/activity_provider.dart';
import 'package:naivedhya/providers/dashboard_provider.dart';
import 'package:naivedhya/providers/theme_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardStats();
      context.read<ActivityProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = AppTheme.of(context);

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await dashboardProvider.refreshDashboard();
            await context.read<ActivityProvider>().refresh();
          },
          color: colors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Theme Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                    ),
                    Row(
                      children: [
                        // Refresh Button
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: colors.primary,
                          ),
                          onPressed: () async {
                            await dashboardProvider.refreshDashboard();
                            await context.read<ActivityProvider>().refresh();
                          },
                          tooltip: 'Refresh Dashboard',
                        ),
                        const SizedBox(width: 8),
                        // Theme Toggle Button
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.textSecondary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.light_mode,
                                  color: !themeProvider.isDarkMode
                                      ? colors.primary
                                      : colors.textSecondary,
                                ),
                                onPressed: () => themeProvider.setLightMode(),
                                tooltip: 'Light Mode',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.dark_mode,
                                  color: themeProvider.isDarkMode
                                      ? colors.primary
                                      : colors.textSecondary,
                                ),
                                onPressed: () => themeProvider.setDarkMode(),
                                tooltip: 'Dark Mode',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // Error handling
                if (dashboardProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.error.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dashboardProvider.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.error,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: dashboardProvider.clearError,
                          icon: Icon(
                            Icons.close,
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Stats Cards
                GridView.count(
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 1.5 : 1.3,
                  children: [
                    _buildStatCard(
                      context,
                      'Total Users',
                      dashboardProvider.isLoading
                          ? '...'
                          : '${dashboardProvider.totalUsers}',
                      Icons.people,
                      colors.info,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      context,
                      'Total Orders',
                      dashboardProvider.isLoading
                          ? '...'
                          : '${dashboardProvider.totalOrders}',
                      Icons.shopping_cart,
                      colors.success,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      context,
                      'Restaurants',
                      dashboardProvider.isLoading
                          ? '...'
                          : '${dashboardProvider.activeRestaurants}',
                      Icons.restaurant,
                      colors.primary,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      context,
                      'Delivery Staff',
                      dashboardProvider.isLoading
                          ? '...'
                          : '${dashboardProvider.deliveryStaff}',
                      Icons.delivery_dining,
                      colors.warning,
                      dashboardProvider.isLoading,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Vendors stat card (full width)
                _buildStatCard(
                  context,
                  'Total Vendors',
                  dashboardProvider.isLoading
                      ? '...'
                      : '${dashboardProvider.totalVendors}',
                  Icons.store,
                  colors.info,
                  dashboardProvider.isLoading,
                  isFullWidth: true,
                ),

                const SizedBox(height: 30),

                // Revenue Milestones
                const MilestoneSettingsWidget(),

                const SizedBox(height: 30),

                // Activity Feed Section
                if (isDesktop)
                  // Desktop Layout: Activity feed takes full width
                  SizedBox(
                    height: 600,
                    child: ActivityFeedWidget(),
                  )
                else
                  // Mobile Layout: Activity feed with fixed height
                  SizedBox(
                    height: 500,
                    child: ActivityFeedWidget(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isLoading, {
    bool isFullWidth = false,
  }) {
    final colors = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Icon(
                        Icons.trending_up,
                        color: color,
                        size: 16,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}