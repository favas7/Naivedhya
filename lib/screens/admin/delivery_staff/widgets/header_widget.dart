import 'package:flutter/material.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/dialogue_components.dart';
import 'package:provider/provider.dart';

class DeliveryStaffHeader extends StatelessWidget {
  final bool isDesktop;

  const DeliveryStaffHeader({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for very small screens
        final useColumnLayout = constraints.maxWidth < 500;
        
        if (useColumnLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 16),
              _buildStatsAndActions(context),
            ],
          );
        }
        
        return Row(
          children: [
            Expanded(child: _buildTitle()),
            _buildStatsAndActions(context),
          ],
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Delivery Staff Management',
      style: TextStyle(
        fontSize: isDesktop ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  Widget _buildStatsAndActions(BuildContext context) {
    return Consumer<DeliveryPersonnelProvider>(
      builder: (context, provider, child) {
        return Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (provider.deliveryPersonnel.isNotEmpty) ...[
              _buildStatsCard(context, provider),
              const SizedBox(width: 8),
            ],
            _buildActionButtons(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(BuildContext context, DeliveryPersonnelProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatRow('Total', provider.deliveryPersonnel.length, Colors.black87),
            const SizedBox(height: 4),
            _buildStatRow('Available', provider.availablePersonnel.length, Colors.green),
            const SizedBox(height: 4),
            _buildStatRow('Verified', provider.verifiedPersonnel.length, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, DeliveryPersonnelProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Search button
        IconButton(
          onPressed: () => DeliveryStaffDialogs.showSearchDialog(context),
          icon: const Icon(Icons.search),
          tooltip: 'Search Staff',
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.1),
            foregroundColor: Colors.blue,
          ),
        ),
        // Filter button
        IconButton(
          onPressed: () => DeliveryStaffDialogs.showFilterDialog(context),
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Staff',
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.1),
            foregroundColor: Colors.orange,
          ),
        ),
        // Refresh button
        IconButton(
          onPressed: () {
            provider.clearError();
            provider.fetchDeliveryPersonnel();
          },
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          style: IconButton.styleFrom(
            backgroundColor: Colors.green.withOpacity(0.1),
            foregroundColor: Colors.green,
          ),
        ),
        // Real-time toggle button
        IconButton(
          onPressed: () {
            provider.startListeningToUpdates();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Real-time updates enabled'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
          },
          icon: const Icon(Icons.sync),
          tooltip: 'Enable Real-time Updates',
          style: IconButton.styleFrom(
            backgroundColor: Colors.purple.withOpacity(0.1),
            foregroundColor: Colors.purple,
          ),
        ),
      ],
    );
  }
}