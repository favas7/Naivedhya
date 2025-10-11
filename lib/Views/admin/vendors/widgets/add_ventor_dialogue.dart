import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:naivedhya/utils/color_theme.dart';
import 'package:naivedhya/models/ventor_model.dart';
import 'package:naivedhya/services/ventor_Service.dart';
import 'package:provider/provider.dart';

// Assuming AppTheme is not imported, adding a simple color definition

class AddVendorDialog extends StatefulWidget {
  final Restaurant? restaurant; // If provided, vendor will be added to this specific Restaurant
  
  const AddVendorDialog({super.key, this.restaurant,  Vendor? vendor});

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  bool _isLoading = false;
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _selectedRestaurant = widget.restaurant;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _serviceTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vendor'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Restaurant Selection (if not pre-selected)
                if (widget.restaurant == null) ...[
                  Consumer<RestaurantProvider>(
                    builder: (context, RestaurantProvider, child) {
                      return DropdownButtonFormField<Restaurant>(
                        value: _selectedRestaurant,
                        decoration: InputDecoration(
                          labelText: 'Select Restaurant',
                          prefixIcon: const Icon(Icons.restaurant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                        ),
                        items: RestaurantProvider.restaurants.map((restaurant) {
                          return DropdownMenuItem<Restaurant>(
                            value: restaurant,
                            child: Text(restaurant.name),
                          );
                        }).toList(),
                        onChanged: (restaurant) {
                          setState(() {
                            _selectedRestaurant = restaurant;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a Restaurant';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Adding vendor to: ${widget.restaurant!.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
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
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
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
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email address',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
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
                ),
                const SizedBox(height: 16),

                // Company Name
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    hintText: 'Enter company name',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Service Type
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'e.g., Food & Beverage, Maintenance, Cleaning',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter service type';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Information Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The vendor will be notified via email about their registration.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
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
              : const Text('Add Vendor'),
        ),
      ],
    );
  }

Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedRestaurant == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a Restaurant'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final vendorService = VendorService();
    final newVendor = Vendor(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      serviceType: _serviceTypeController.text.trim(),
      restaurantId: _selectedRestaurant!.id,
    );

    await vendorService.createVendor(newVendor);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vendor "${_nameController.text.trim()}" added successfully to ${_selectedRestaurant!.name}!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
}