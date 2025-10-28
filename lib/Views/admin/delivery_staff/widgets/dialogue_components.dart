import 'package:flutter/material.dart';
import 'package:naivedhya/models/simple_delivery_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya/utils/color_theme.dart';

class DeliveryStaffDialogs {
  static void showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    bool? isAvailable;
    bool? isVerified;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Search Delivery Staff'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name, email, phone...',
                      hintText: 'Enter search term',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Availability:'),
                            DropdownButton<bool?>(
                              isExpanded: true,
                              value: isAvailable,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('All')),
                                DropdownMenuItem(value: true, child: Text('Available')),
                                DropdownMenuItem(value: false, child: Text('Busy')),
                              ],
                              onChanged: (value) => setState(() => isAvailable = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Verification:'),
                            DropdownButton<bool?>(
                              isExpanded: true,
                              value: isVerified,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('All')),
                                DropdownMenuItem(value: true, child: Text('Verified')),
                                DropdownMenuItem(value: false, child: Text('Unverified')),
                              ],
                              onChanged: (value) => setState(() => isVerified = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: _buildDialogActions(
            context: context,
            onCancel: () => Navigator.pop(context),
            onSubmit: () => _handleSearch(
              context,
              searchController.text,
              isAvailable,
              isVerified,
            ),
            submitText: 'Search',
          ),
        ),
      ),
    );
  }

  static void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('All Staff'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Available Only'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DeliveryPersonnelProvider>().fetchAvailableDeliveryPersonnel();
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified, color: Colors.blue),
                title: const Text('Verified Only'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DeliveryPersonnelProvider>().searchDeliveryPersonnel(
                    isVerified: true,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: const Text('Pending Verification'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DeliveryPersonnelProvider>().searchDeliveryPersonnel(
                    isVerified: false,
                  );
                },
              ),
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

  static void showAssignOrderDialog(BuildContext context, DeliveryPersonnel staff) {
    final orderIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Order to ${staff.name}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 150,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: orderIdController,
                decoration: const InputDecoration(
                  labelText: 'Order ID',
                  hintText: 'Enter order ID to assign',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Current assigned orders: ${staff.assignedOrders.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: _buildDialogActions(
          context: context,
          onCancel: () => Navigator.pop(context),
          onSubmit: () => _handleAssignOrder(
            context,
            staff.userId,
            orderIdController.text,
          ),
          submitText: 'Assign',
        ),
      ),
    );
  }

  static void showBulkActionDialog(BuildContext context, List<DeliveryPersonnel> selectedStaff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Actions (${selectedStaff.length} selected)'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.green),
                title: const Text('Mark All Available'),
                onTap: () => _handleBulkAvailability(context, selectedStaff, true),
              ),
              ListTile(
                leading: const Icon(Icons.pause, color: Colors.orange),
                title: const Text('Mark All Busy'),
                onTap: () => _handleBulkAvailability(context, selectedStaff, false),
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: const Text('Refresh Status'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildDialogActions({
    required BuildContext context,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    required String submitText,
    bool isDestructive = false,
  }) {
    return [
      Wrap(
        alignment: WrapAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(submitText),
          ),
        ],
      ),
    ];
  }

  static Future<void> _handleSearch(
    BuildContext context,
    String searchQuery,
    bool? isAvailable,
    bool? isVerified,
  ) async {
    Navigator.pop(context);
    
    await context.read<DeliveryPersonnelProvider>().searchDeliveryPersonnel(
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
      isAvailable: isAvailable,
      isVerified: isVerified,
    );

    _showSnackBar(
      context,
      'Search completed',
      Colors.blue,
    );
  }

  static Future<void> _handleAssignOrder(
    BuildContext context,
    String staffUserId,
    String orderId,
  ) async {
    if (orderId.trim().isEmpty) {
      _showSnackBar(
        context,
        'Order ID is required',
        Colors.red,
      );
      return;
    }

    final success = await context
        .read<DeliveryPersonnelProvider>()
        .assignOrder(orderId.trim(), staffUserId);

    Navigator.pop(context);

    if (success) {
      _showSnackBar(
        context,
        'Order assigned successfully',
        Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        'Failed to assign order',
        Colors.red,
      );
    }
  }

  static Future<void> _handleBulkAvailability(
    BuildContext context,
    List<DeliveryPersonnel> selectedStaff,
    bool availability,
  ) async {
    Navigator.pop(context);
    
    final provider = context.read<DeliveryPersonnelProvider>();
    int successCount = 0;

    for (final staff in selectedStaff) {
      if (staff.isAvailable != availability) {
        final success = await provider.toggleAvailability(staff.userId);
        if (success) successCount++;
      }
    }

    _showSnackBar(
      context,
      'Updated $successCount out of ${selectedStaff.length} staff members',
      Colors.green,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
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