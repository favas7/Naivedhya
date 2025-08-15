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
          return _buildErrorWidget(context, provider);
        }

        if (provider.deliveryPersonnel.isEmpty) {
          return _buildEmptyWidget(context);
        }

        return Column(
          children: [
            // List header
            _buildListHeader(provider),
            const SizedBox(height: 16),
            
            // Staff list
            Expanded(
              child: ListView.builder(
                itemCount: provider.deliveryPersonnel.length,
                itemBuilder: (context, index) {
                  final staff = provider.deliveryPersonnel[index];
                  return DeliveryStaffTile(
                    staff: staff,
                    provider: provider,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(DeliveryPersonnelProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Delivery Staff (${provider.deliveryPersonnel.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (provider.deliveryPersonnel.isNotEmpty) ...[
            _buildQuickStats(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(DeliveryPersonnelProvider provider) {
    final available = provider.availablePersonnel.length;
    final verified = provider.verifiedPersonnel.length;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatChip('Available', available, Colors.green),
        const SizedBox(width: 8),
        _buildStatChip('Verified', verified, Colors.blue),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, DeliveryPersonnelProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading delivery staff',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              provider.clearError();
              provider.fetchDeliveryPersonnel();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No delivery staff found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search filters or refresh the list',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.read<DeliveryPersonnelProvider>().clearError(),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}