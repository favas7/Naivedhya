// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:naivedhya/constants/colors.dart';
import 'package:naivedhya/models/hotel.dart';
import 'package:naivedhya/models/location.dart';
import 'package:naivedhya/services/location_service.dart'; // Changed from hotel_service

class EditLocationDialog extends StatefulWidget {
  final Location location;
  final Hotel hotel;

  const EditLocationDialog({
    super.key,
    required this.location,
    required this.hotel,
  });

  @override
  State<EditLocationDialog> createState() => _EditLocationDialogState();
}

class _EditLocationDialogState extends State<EditLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final LocationService _locationService = LocationService(); // Changed to LocationService
  bool _isLoading = false;
  bool _isNavigating = false; // Add navigation guard

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with current location data
    _cityController.text = widget.location.city;
    _stateController.text = widget.location.state;
    _countryController.text = widget.location.country;
    _postalCodeController.text = widget.location.postalCode;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // Safe navigation method
  void _safeNavigatorPop([dynamic result]) {
    if (_isNavigating || !mounted) return;
    if (!Navigator.canPop(context)) return;
    
    _isNavigating = true;
    Navigator.of(context).pop(result);
  }

Future<void> _updateLocation() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // Create updated location object
    final updatedLocation = widget.location.copyWith(
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
    );

    // Call the actual database update
    await _locationService.updateLocation(updatedLocation);
    
    if (mounted) {
      // Show success message first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Then close dialog
      _safeNavigatorPop(updatedLocation);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating location: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Only reset loading state if there was an error and dialog is still open
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Remove the finally block completely - no need to reset _isLoading 
  // when dialog is closing successfully
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                        'Edit Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _safeNavigatorPop(), // Use safe navigation
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Hotel Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hotel: ${widget.hotel.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location ID: ${widget.location.id ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current: ${widget.location.fullAddress}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter city name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city name';
                  }
                  if (value.trim().length < 2) {
                    return 'City name must be at least 2 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // State
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  hintText: 'Enter state name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state name';
                  }
                  if (value.trim().length < 2) {
                    return 'State name must be at least 2 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Country
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  hintText: 'Enter country name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter country name';
                  }
                  if (value.trim().length < 2) {
                    return 'Country name must be at least 2 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Postal Code
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  hintText: 'Enter postal code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.markunread_mailbox),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter postal code';
                  }
                  if (value.trim().length < 3) {
                    return 'Postal code must be at least 3 characters';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => _safeNavigatorPop(), // Use safe navigation
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateLocation,
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
                        : const Text('Update Location'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}