// widgets/customer_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/models/user_model.dart';

class CustomerStatsWidget extends StatelessWidget {
  final List<UserModel> customers;
  final bool isDesktop;

  const CustomerStatsWidget({
    super.key,
    required this.customers,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final totalPendingPayments = customers.fold<double>(
      0, 
      (sum, c) => sum + (c.pendingpayments ?? 0)
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Customers',
            value: '${customers.length}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Pending Payments',
            value: '₹${totalPendingPayments.toStringAsFixed(2)}',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}