// lib/Views/admin/order/add_order_screen/widgets/status_management_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';

class StatusManagementCard extends StatelessWidget {
  final String? selectedStatus;
  final String? selectedDeliveryStatus;
  final List<String> availableStatuses;
  final List<String> deliveryStatuses;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onDeliveryStatusChanged;

  const StatusManagementCard({
    super.key,
    required this.selectedStatus,
    required this.selectedDeliveryStatus,
    required this.availableStatuses,
    required this.deliveryStatuses,
    required this.onStatusChanged,
    required this.onDeliveryStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCardWrapper(
      title: 'Status Management',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Order Status',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment),
            ),
            items: availableStatuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    _buildStatusIndicator(status),
                    const SizedBox(width: 8),
                    Text(status),
                  ],
                ),
              );
            }).toList(),
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDeliveryStatus,
            decoration: const InputDecoration(
              labelText: 'Delivery Status',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_shipping),
            ),
            items: deliveryStatuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: onDeliveryStatusChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'preparing':
        color = Colors.purple;
        break;
      case 'ready':
        color = Colors.teal;
        break;
      case 'picked up':
        color = Colors.indigo;
        break;
      case 'delivering':
        color = Colors.cyan;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}