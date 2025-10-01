import 'package:flutter/material.dart';
import 'package:naivedhya/providers/dashboard_provider.dart';
import 'package:naivedhya/utils/constants/colors.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: () => dashboardProvider.refreshDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error handling
                if (dashboardProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dashboardProvider.error!,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                        IconButton(
                          onPressed: dashboardProvider.clearError,
                          icon: Icon(Icons.close, color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),

                // Stats Cards
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 768 ? 4 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      'Total Users',
                      dashboardProvider.isLoading ? '...' : '${dashboardProvider.totalUsers}',
                      Icons.people,
                      Colors.blue,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      'Total Orders',
                      dashboardProvider.isLoading ? '...' : '${dashboardProvider.totalOrders}',
                      Icons.shopping_cart,
                      Colors.green,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      'Active Restaurants',
                      dashboardProvider.isLoading ? '...' : '${dashboardProvider.activeRestaurants}',
                      Icons.restaurant,
                      Colors.orange,
                      dashboardProvider.isLoading,
                    ),
                    _buildStatCard(
                      'Delivery Staff',
                      dashboardProvider.isLoading ? '...' : '${dashboardProvider.deliveryStaff}',
                      Icons.delivery_dining,
                      Colors.purple,
                      dashboardProvider.isLoading,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Additional stat card for vendors (full width)
                _buildStatCard(
                  'Total Vendors',
                  dashboardProvider.isLoading ? '...' : '${dashboardProvider.totalVendors}',
                  Icons.store,
                  Colors.teal,
                  dashboardProvider.isLoading,
                  isFullWidth: true,
                ),
                
                const SizedBox(height: 30),
                
                // Recent Activity
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (dashboardProvider.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                _getActivityIcon(index),
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(_getActivityTitle(index)),
                            subtitle: Text('${index + 1} minutes ago'),
                            trailing: const Icon(Icons.more_vert),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isLoading, {
    bool isFullWidth = false,
  }) {
    final cardWidget = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );

    if (isFullWidth) {
      return cardWidget;
    }
    return cardWidget;
  }

  IconData _getActivityIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.person_add;
      case 1:
        return Icons.shopping_cart;
      case 2:
        return Icons.restaurant;
      case 3:
        return Icons.delivery_dining;
      default:
        return Icons.notifications;
    }
  }

  String _getActivityTitle(int index) {
    switch (index % 4) {
      case 0:
        return 'New user registered';
      case 1:
        return 'New order placed';
      case 2:
        return 'Restaurant added';
      case 3:
        return 'Delivery completed';
      default:
        return 'System activity';
    }
  }
}