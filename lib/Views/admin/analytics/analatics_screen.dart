import 'package:flutter/material.dart';
import 'package:naivedhya/utils/color_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAnalyticsCard('Total Sales', '\$12,345', Icons.monetization_on, context),
                _buildAnalyticsCard('Total Orders', '156', Icons.shopping_cart, context),
                _buildAnalyticsCard('Active Users', '89', Icons.people, context),
                _buildAnalyticsCard('Revenue Growth', '12.5%', Icons.trending_up, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}