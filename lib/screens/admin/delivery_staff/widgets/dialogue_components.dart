import 'package:flutter/material.dart';
import 'package:naivedhya/models/deliver_person_model.dart';
import 'package:naivedhya/providers/delivery_personal_provider.dart';
import 'package:provider/provider.dart';
import '../../../../constants/colors.dart';

class DeliveryStaffDialogs {
  static void showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Staff'),
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
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter unique user ID',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter staff name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: _buildDialogActions(
          context: context,
          onCancel: () => Navigator.pop(context),
          onSubmit: () => _handleAddStaff(
            context,
            userIdController,
            nameController,
            phoneController,
          ),
          submitText: 'Add',
        ),
      ),
    );
  }

  static void showEditStaffDialog(BuildContext context, DeliveryPersonnel staff) {
    final nameController = TextEditingController(text: staff.name);
    final phoneController = TextEditingController(text: staff.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Staff'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 200,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter staff name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: _buildDialogActions(
          context: context,
          onCancel: () => Navigator.pop(context),
          onSubmit: () => _handleEditStaff(
            context,
            staff,
            nameController,
            phoneController,
          ),
          submitText: 'Update',
        ),
      ),
    );
  }

  static void showDeleteConfirmation(
    BuildContext context,
    DeliveryPersonnel staff,
    DeliveryPersonnelProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'Are you sure you want to delete ${staff.name}?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: _buildDialogActions(
          context: context,
          onCancel: () => Navigator.pop(context),
          onSubmit: () => _handleDeleteStaff(context, staff, provider),
          submitText: 'Delete',
          isDestructive: true,
        ),
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
              backgroundColor: isDestructive ? Colors.red : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(submitText),
          ),
        ],
      ),
    ];
  }

  static Future<void> _handleAddStaff(
    BuildContext context,
    TextEditingController userIdController,
    TextEditingController nameController,
    TextEditingController phoneController,
  ) async {
    if (userIdController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty) {
      _showSnackBar(
        context,
        'User ID and Name are required',
        Colors.red,
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
      _showSnackBar(
        context,
        'Staff added successfully',
        Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        'Failed to add staff',
        Colors.red,
      );
    }
  }

  static Future<void> _handleEditStaff(
    BuildContext context,
    DeliveryPersonnel staff,
    TextEditingController nameController,
    TextEditingController phoneController,
  ) async {
    if (nameController.text.trim().isEmpty) {
      _showSnackBar(
        context,
        'Name is required',
        Colors.red,
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
      _showSnackBar(
        context,
        'Staff updated successfully',
        Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        'Failed to update staff',
        Colors.red,
      );
    }
  }

  static Future<void> _handleDeleteStaff(
    BuildContext context,
    DeliveryPersonnel staff,
    DeliveryPersonnelProvider provider,
  ) async {
    final success = await provider.deleteDeliveryPersonnel(staff.userId);
    Navigator.pop(context);

    if (success) {
      _showSnackBar(
        context,
        'Staff deleted successfully',
        Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        'Failed to delete staff',
        Colors.red,
      );
    }
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