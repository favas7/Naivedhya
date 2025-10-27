import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/services/ventor_Service.dart';

class AddVendorDialog extends StatefulWidget {
  final Restaurant? restaurant;
  final Vendor? vendor;
  final List<Restaurant>? availableRestaurants; // ✅ NEW: Accept restaurants list
  
  const AddVendorDialog({
    super.key, 
    this.restaurant, 
    this.vendor,
    this.availableRestaurants, // ✅ NEW
  });

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  bool _isLoading = false;
  Restaurant? _selectedRestaurant;

  bool get _isEditMode => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    _selectedRestaurant = widget.restaurant;
    
    // Pre-fill fields if editing
    if (_isEditMode) {
      _nameController.text = widget.vendor!.name;
      _emailController.text = widget.vendor!.email;
      _phoneController.text = widget.vendor!.phone;
      _serviceTypeController.text = widget.vendor!.serviceType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _serviceTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditMode ? 'Edit Vendor' : 'Add New Vendor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ✅ UPDATED: Restaurant Selection (if not pre-selected)
                if (widget.restaurant == null && !_isEditMode) ...[
                  Builder(
                    builder: (context) {
                      // Use passed restaurants or empty list
                      final restaurants = widget.availableRestaurants ?? [];
                      
                      // Show empty state if no restaurants
                      if (restaurants.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.warning.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: colors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No restaurants available. Please add a restaurant first.',
                                  style: TextStyle(color: colors.warning, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // Show dropdown with restaurants
                      return DropdownButtonFormField<Restaurant>(
                        value: _selectedRestaurant,
                        decoration: InputDecoration(
                          labelText: 'Select Restaurant',
                          prefixIcon: Icon(Icons.restaurant, color: colors.primary),
                          filled: true,
                          fillColor: colors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: restaurants.map((restaurant) {
                          return DropdownMenuItem<Restaurant>(
                            value: restaurant,
                            child: Text(restaurant.name),
                          );
                        }).toList(),
                        onChanged: (restaurant) {
                          setState(() => _selectedRestaurant = restaurant);
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a restaurant';
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (widget.restaurant != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Restaurant: ${widget.restaurant!.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Vendor Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Vendor Name',
                    hintText: 'Enter vendor name',
                    prefixIcon: Icon(Icons.person, color: colors.primary),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter vendor name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email address',
                    prefixIcon: Icon(Icons.email, color: colors.primary),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone, color: colors.primary),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Service Type
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'e.g., Food & Beverage, Maintenance',
                    prefixIcon: Icon(Icons.work, color: colors.primary),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter service type';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Information Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.info.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vendor will be notified via email about registration',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isEditMode ? 'Update Vendor' : 'Add Vendor'),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRestaurant == null && !_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a restaurant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vendorService = VendorService();
      
      if (_isEditMode) {
        // Update existing vendor
        final updatedVendor = widget.vendor!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          serviceType: _serviceTypeController.text.trim(),
        );
        
        await vendorService.updateVendor(updatedVendor);
        
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new vendor
        final newVendor = Vendor(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          serviceType: _serviceTypeController.text.trim(),
          restaurantId: _selectedRestaurant!.id,
        );

        await vendorService.createVendor(newVendor);

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vendor "${_nameController.text.trim()}" added to ${_selectedRestaurant!.name}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}