import 'package:flutter/material.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/individual_staff_tile.dart';
import 'package:provider/provider.dart';

class DeliveryStaffList extends StatelessWidget {
  const DeliveryStaffList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryPersonnelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return _buildErrorState(context, provider);
        }

        if (provider.deliveryPersonnel.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: provider.deliveryPersonnel.length,
          itemBuilder: (context, index) {
            final staff = provider.deliveryPersonnel[index];
            return DeliveryStaffTile(
              staff: staff,
              provider: provider,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, DeliveryPersonnelProvider provider) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.fetchDeliveryPersonnel();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No delivery staff found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Add your first delivery staff member',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}