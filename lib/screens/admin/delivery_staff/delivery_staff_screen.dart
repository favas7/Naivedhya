import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class DeliveryStaffScreen extends StatelessWidget {
  const DeliveryStaffScreen({super.key});

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
            'Delivery Staff Management',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add New Staff'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStaffList(context, isDesktop),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, bool isDesktop) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            'S${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Staff ${index + 1}'),
        subtitle: Text('staff${index + 1}@example.com'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }
}