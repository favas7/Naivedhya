import 'package:flutter/material.dart';
import 'package:naivedhya/models/delivery_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class DeliveryStaffTile extends StatelessWidget {
  final DeliveryPersonnel staff;
  final DeliveryPersonnelProvider provider;

  const DeliveryStaffTile({
    super.key,
    required this.staff,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: staff.isAvailable ? AppTheme.primary : Colors.grey,
          child: Text(
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          staff.fullName.isNotEmpty ? staff.fullName : staff.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailingMenu(context),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (staff.phone.isNotEmpty)
          Text(
            'Phone: ${staff.phone}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        const SizedBox(height: 4),
        _buildStatusAndInfo(),
      ],
    );
  }

  Widget _buildStatusAndInfo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for very narrow tiles
        final useColumnLayout = constraints.maxWidth < 200;
        
        if (useColumnLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 4),
              _buildInfoText(),
            ],
          );
        }
        
        return Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildStatusBadge(),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: _buildInfoText(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: staff.isAvailable ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        staff.isAvailable ? 'Available' : 'Busy',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildInfoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Earnings: ₹${staff.earnings.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (staff.assignedOrders.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Orders: ${staff.assignedOrders.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility, size: 20),
              SizedBox(width: 8),
              Flexible(child: Text('View Details')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                staff.isAvailable ? Icons.pause : Icons.play_arrow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  staff.isAvailable ? 'Mark Busy' : 'Mark Available',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!staff.isVerified) ...[
          const PopupMenuItem(
            value: 'verify',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Mark Verified',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (staff.assignedOrders.isNotEmpty) ...[
          const PopupMenuItem(
            value: 'orders',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt, size: 20),
                SizedBox(width: 8),
                Flexible(child: Text('View Orders')),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'view':
        _showDetailsDialog(context);
        break;
      case 'toggle':
        provider.toggleAvailability(staff.userId);
        break;
      case 'verify':
        // TODO: Implement verification logic
        _showSnackBar(context, 'Verification feature coming soon', Colors.orange);
        break;
      case 'orders':
        _showOrdersDialog(context);
        break;
    }
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${staff.fullName} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', staff.fullName),
              _buildDetailRow('Email', staff.email),
              _buildDetailRow('Phone', staff.phone),
              _buildDetailRow('City', staff.city),
              _buildDetailRow('State', staff.state),
              _buildDetailRow('Vehicle', '${staff.vehicleType} - ${staff.vehicleModel}'),
              _buildDetailRow('Number Plate', staff.numberPlate),
              _buildDetailRow('Earnings', '₹${staff.earnings.toStringAsFixed(2)}'),
              _buildDetailRow('Status', staff.isAvailable ? 'Available' : 'Busy'),
              _buildDetailRow('Verified', staff.isVerified ? 'Yes' : 'No'),
              _buildDetailRow('Verification Status', staff.verificationStatus),
              _buildDetailRow('Assigned Orders', staff.assignedOrders.length.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${staff.name}\'s Orders'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: staff.assignedOrders.isEmpty
              ? const Center(child: Text('No assigned orders'))
              : ListView.builder(
                  itemCount: staff.assignedOrders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Order #${staff.assignedOrders[index]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          provider.unassignOrder(staff.assignedOrders[index], staff.userId);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value.isEmpty ? 'N/A' : value),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}