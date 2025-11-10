import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = 'This Month';

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

            // Key Metrics Cards
            _buildKeyMetrics(theme, isDesktop, isTablet),
            const SizedBox(height: 24),

            // Revenue Chart Section
            _buildRevenueChart(theme, isDesktop),
            const SizedBox(height: 24),

            // Two Column Layout: Orders & Top Items
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildOrdersBreakdown(theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTopPerformingItems(theme)),
                ],
              )
            else ...[
              _buildOrdersBreakdown(theme),
              const SizedBox(height: 16),
              _buildTopPerformingItems(theme),
            ],
            const SizedBox(height: 24),

            // Customer Insights
            _buildCustomerInsights(theme, isDesktop),
            const SizedBox(height: 24),

            // Restaurant Performance
            _buildRestaurantPerformance(theme, isDesktop, isTablet),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: isDesktop ? 28 : 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your business performance and insights',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          if (isDesktop)
            DropdownButton<String>(
              value: selectedPeriod,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                DropdownMenuItem(value: 'This Year', child: Text('This Year')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(AppThemeColors theme, bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : (isTablet ? 1.8 : 2.5),
      children: [
        _buildMetricCard(
          theme,
          'Total Revenue',
          '\$12,345',
          '+12.5%',
          Icons.monetization_on,
          theme.success,
          true,
        ),
        _buildMetricCard(
          theme,
          'Total Orders',
          '1,456',
          '+8.2%',
          Icons.shopping_cart,
          theme.info,
          true,
        ),
        _buildMetricCard(
          theme,
          'Active Users',
          '892',
          '+15.3%',
          Icons.people,
          theme.primary,
          true,
        ),
        _buildMetricCard(
          theme,
          'Avg Order Value',
          '\$24.50',
          '-2.1%',
          Icons.trending_down,
          theme.error,
          false,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    AppThemeColors theme,
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 32, color: color),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? theme.success : theme.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPositive ? theme.success : theme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(AppThemeColors theme, bool isDesktop) {
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
                'Revenue Trends',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Icon(Icons.show_chart, color: theme.primary),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: isDesktop ? 250 : 200,
            decoration: BoxDecoration(
              color: theme.isDark 
                ? AppTheme.darkSurfaceVariant 
                : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: theme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Revenue Chart Placeholder',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Integrate with charts library (fl_chart, syncfusion, etc.)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersBreakdown(AppThemeColors theme) {
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
          Text(
            'Orders Breakdown',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          _buildOrderStatusItem(theme, 'Completed', 1234, theme.success, 0.75),
          const SizedBox(height: 12),
          _buildOrderStatusItem(theme, 'Pending', 89, theme.warning, 0.15),
          const SizedBox(height: 12),
          _buildOrderStatusItem(theme, 'Cancelled', 45, theme.error, 0.10),
          const SizedBox(height: 12),
          _buildOrderStatusItem(theme, 'In Progress', 156, theme.info, 0.25),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    AppThemeColors theme,
    String status,
    int count,
    Color color,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformingItems(AppThemeColors theme) {
    final items = [
      {'name': 'Margherita Pizza', 'orders': 234, 'revenue': '\$2,340'},
      {'name': 'Chicken Biryani', 'orders': 198, 'revenue': '\$1,980'},
      {'name': 'Caesar Salad', 'orders': 167, 'revenue': '\$1,336'},
      {'name': 'Pasta Alfredo', 'orders': 145, 'revenue': '\$1,595'},
      {'name': 'Grilled Salmon', 'orders': 123, 'revenue': '\$1,845'},
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
                'Top Performing Items',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Icon(Icons.emoji_events, color: theme.warning, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.textSecondary.withOpacity(0.2),
              height: 24,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${item['orders']} orders',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['revenue'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: theme.success,
                      fontWeight: FontWeight.bold,
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

  Widget _buildCustomerInsights(AppThemeColors theme, bool isDesktop) {
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
          Text(
            'Customer Insights',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 2.5 : 3,
            children: [
              _buildInsightItem(theme, 'New Customers', '234', Icons.person_add, theme.info),
              _buildInsightItem(theme, 'Returning Customers', '658', Icons.repeat, theme.success),
              _buildInsightItem(theme, 'Customer Retention', '73.8%', Icons.loyalty, theme.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(AppThemeColors theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantPerformance(AppThemeColors theme, bool isDesktop, bool isTablet) {
    final restaurants = [
      {'name': 'Pizza Paradise', 'orders': 345, 'rating': 4.8, 'revenue': '\$4,150'},
      {'name': 'Biryani House', 'orders': 298, 'rating': 4.7, 'revenue': '\$3,820'},
      {'name': 'Burger Station', 'orders': 267, 'rating': 4.6, 'revenue': '\$3,204'},
      {'name': 'Sushi World', 'orders': 234, 'rating': 4.9, 'revenue': '\$5,616'},
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
          Text(
            'Restaurant Performance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          if (isDesktop)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    _buildTableHeader('Restaurant'),
                    _buildTableHeader('Orders'),
                    _buildTableHeader('Rating'),
                    _buildTableHeader('Revenue'),
                  ],
                ),
                ...restaurants.map((restaurant) => TableRow(
                  children: [
                    _buildTableCell(theme, restaurant['name'] as String),
                    _buildTableCell(theme, '${restaurant['orders']}'),
                    _buildTableCell(theme, '⭐ ${restaurant['rating']}'),
                    _buildTableCell(theme, restaurant['revenue'] as String),
                  ],
                )),
              ],
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: restaurants.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.textSecondary.withOpacity(0.2),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${restaurant['orders']} orders',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '⭐ ${restaurant['rating']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          restaurant['revenue'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: theme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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

  Widget _buildTableCell(AppThemeColors theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}