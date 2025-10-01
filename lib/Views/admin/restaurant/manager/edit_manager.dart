// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/utils/constants/colors.dart';
import 'package:naivedhya/models/manager.dart';
import 'package:naivedhya/services/manager_service.dart';

class EditManagerDialog extends StatefulWidget {
  final Manager manager;
  final Restaurant restaurant;

  const EditManagerDialog({
    super.key,
    required this.manager,
    required this.restaurant,
  });

  @override
  State<EditManagerDialog> createState() => _EditManagerDialogState();
}

class _EditManagerDialogState extends State<EditManagerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ManagerService _managerService = ManagerService();
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _hasNavigated = false; // Add this flag to prevent multiple navigation

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with current manager data
    _nameController.text = widget.manager.name;
    _emailController.text = widget.manager.email;
    _phoneController.text = widget.manager.phone;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Enhanced safe navigation method
  bool _canNavigate() {
    return mounted && !_isDisposed && !_hasNavigated && Navigator.canPop(context);
  }

  // Enhanced safe pop method with additional checks
  void _safeNavigatorPop([dynamic result]) {
    if (_canNavigate()) {
      _hasNavigated = true; // Set flag to prevent multiple calls
      // Use addPostFrameCallback to ensure navigation happens after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(result);
        }
      });
    }
  }

  Future<void> _updateManager() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent multiple simultaneous calls
    if (_isLoading || _isDisposed || _hasNavigated) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated manager object
      final updatedManager = widget.manager.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Call the manager service to update the manager
      await _managerService.updateManager(updatedManager);
      
      // Only proceed if widget is still mounted and hasn't navigated
      if (mounted && !_isDisposed && !_hasNavigated) {
        // Show success message first
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Then navigate with result
        _safeNavigatorPop({
          'success': true,
          'manager': updatedManager,
          'message': 'Manager updated successfully!'
        });
      }
    } catch (e) {
      // Only show error if widget is still mounted and hasn't navigated
      if (mounted && !_isDisposed && !_hasNavigated) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating manager: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleCancel() {
    // Prevent cancel during loading or if already disposed/navigated
    if (_isLoading || _isDisposed || _hasNavigated) return;
    
    // Use safe navigation method
    _safeNavigatorPop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading && !_hasNavigated,
      onPopInvoked: (didPop) {
        if (didPop && !_hasNavigated) {
          _hasNavigated = true;
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Edit Manager',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: (_isLoading || _hasNavigated) ? null : _handleCancel,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Restaurant Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(0), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant: ${widget.restaurant.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manager ID: ${widget.manager.id ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Manager Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Manager Name',
                    hintText: 'Enter manager name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter manager name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  enabled: !_isLoading && !_hasNavigated,
                ),
                
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  enabled: !_isLoading && !_hasNavigated,
                ),
                
                const SizedBox(height: 16),
                
                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.trim().length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                  enabled: !_isLoading && !_hasNavigated,
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: (_isLoading || _hasNavigated) ? null : _handleCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (_isLoading || _hasNavigated) ? null : _updateManager,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Update Manager'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}