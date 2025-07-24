import 'package:flutter/material.dart';
import 'package:naivedhya/models/deliver_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';


class DeliveryStaffScreen extends StatefulWidget {
  const DeliveryStaffScreen({super.key});

  @override
  State<DeliveryStaffScreen> createState() => _DeliveryStaffScreenState();
}

class _DeliveryStaffScreenState extends State<DeliveryStaffScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch delivery personnel when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryPersonnelProvider>().fetchDeliveryPersonnel();
    });
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Staff Management',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Consumer<DeliveryPersonnelProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      if (provider.deliveryPersonnel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total: ${provider.deliveryPersonnel.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Available: ${provider.availablePersonnel.length}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        onPressed: () => provider.fetchDeliveryPersonnel(),
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStaffDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add New Staff'),
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
    return Consumer<DeliveryPersonnelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
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
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
          );
        }

        if (provider.deliveryPersonnel.isEmpty) {
          return Center(
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
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first delivery staff member',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.deliveryPersonnel.length,
          itemBuilder: (context, index) {
            final staff = provider.deliveryPersonnel[index];
            return _buildStaffTile(staff, provider);
          },
        );
      },
    );
  }

  Widget _buildStaffTile(DeliveryPersonnel staff, DeliveryPersonnelProvider provider) {
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
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (staff.phone != null)
              Text('Phone: ${staff.phone}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
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
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Earnings: ₹${staff.earnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditStaffDialog(context, staff);
                break;
              case 'toggle':
                provider.toggleAvailability(staff.userId);
                break;
              case 'delete':
                _showDeleteConfirmation(context, staff, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    staff.isAvailable ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(staff.isAvailable ? 'Mark Busy' : 'Mark Available'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter unique user ID',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter staff name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (userIdController.text.trim().isEmpty ||
                  nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User ID and Name are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newStaff = DeliveryPersonnel(
                userId: userIdController.text.trim(),
                name: nameController.text.trim(),
                phone: phoneController.text.trim().isEmpty 
                    ? null 
                    : phoneController.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final success = await context
                  .read<DeliveryPersonnelProvider>()
                  .addDeliveryPersonnel(newStaff);

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Staff added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to add staff'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(BuildContext context, DeliveryPersonnel staff) {
    final nameController = TextEditingController(text: staff.name);
    final phoneController = TextEditingController(text: staff.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter staff name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedStaff = staff.copyWith(
                name: nameController.text.trim(),
                phone: phoneController.text.trim().isEmpty 
                    ? null 
                    : phoneController.text.trim(),
                updatedAt: DateTime.now(),
              );

              final success = await context
                  .read<DeliveryPersonnelProvider>()
                  .updateDeliveryPersonnel(staff.userId, updatedStaff);

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Staff updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update staff'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DeliveryPersonnel staff,
    DeliveryPersonnelProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete ${staff.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.deleteDeliveryPersonnel(staff.userId);
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Staff deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete staff'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}