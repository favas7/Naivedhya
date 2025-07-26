import 'package:flutter/material.dart';
import 'package:naivedhya/models/deliver_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:naivedhya/screens/admin/delivery_staff/widgets/dialogue_components.dart';
import '../../../../constants/colors.dart';

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
          backgroundColor: staff.isAvailable ? AppColors.primary : Colors.grey,
          child: Text(
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          staff.name,
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
        if (staff.phone != null)
          Text(
            'Phone: ${staff.phone}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        const SizedBox(height: 4),
        _buildStatusAndEarnings(),
      ],
    );
  }

  Widget _buildStatusAndEarnings() {
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
              _buildEarningsText(),
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
              child: _buildEarningsText(),
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

  Widget _buildEarningsText() {
    return Text(
      'Earnings: ₹${staff.earnings.toStringAsFixed(2)}',
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.green,
        fontSize: 12,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildTrailingMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Flexible(child: Text('Edit')),
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
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        DeliveryStaffDialogs.showEditStaffDialog(context, staff);
        break;
      case 'toggle':
        provider.toggleAvailability(staff.userId);
        break;
      case 'delete':
        DeliveryStaffDialogs.showDeleteConfirmation(context, staff, provider);
        break;
    }
  }
}