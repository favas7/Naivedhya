import 'package:flutter/material.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
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
        final useColumnLayout = constraints.maxWidth < 400;
        
        if (useColumnLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 16),
              _buildStatsAndActions(),
            ],
          );
        }
        
        return Row(
          children: [
            Expanded(child: _buildTitle()),
            _buildStatsAndActions(),
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

  Widget _buildStatsAndActions() {
    return Consumer<DeliveryPersonnelProvider>(
      builder: (context, provider, child) {
        return Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (provider.deliveryPersonnel.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ${provider.deliveryPersonnel.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Available: ${provider.availablePersonnel.length}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            IconButton(
              onPressed: () => provider.fetchDeliveryPersonnel(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        );
      },
    );
  }
}