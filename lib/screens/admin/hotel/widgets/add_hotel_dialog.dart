// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:naivedhya/providers/hotel_provider.dart';
import 'package:provider/provider.dart';

class AddHotelDialog extends StatelessWidget {
  const AddHotelDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HotelProvider>(
      builder: (context, provider, child) {
        switch (provider.currentStep) {
          case 0:
            return _buildHotelDetailsDialog(context, provider);
          case 1:
            return _buildLocationDetailsDialog(context, provider);
          case 2:
            return _buildManagerDetailsDialog(context, provider);
          default:
            return _buildHotelDetailsDialog(context, provider);
        }
      },
    );
  }

  Widget _buildHotelDetailsDialog(BuildContext context, HotelProvider provider) {
    return AlertDialog(
      title: const Text('Add New Hotel - Step 1 of 3'),
      content: SingleChildScrollView(
        child: Form(
          key: provider.formKey1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hotel Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: provider.hotelNameController,
                decoration: const InputDecoration(
                  labelText: 'Hotel Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter hotel name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.hotelAddressController,
                decoration: const InputDecoration(
                  labelText: 'Hotel Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter hotel address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.clearAllControllers();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (provider.validateStep(0)) {
              provider.setCurrentStep(1);
            }
          },
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildLocationDetailsDialog(BuildContext context, HotelProvider provider) {
    return AlertDialog(
      title: const Text('Add New Hotel - Step 2 of 3'),
      content: SingleChildScrollView(
        child: Form(
          key: provider.formKey2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Location Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: provider.cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.stateController,
                decoration: const InputDecoration(
                  labelText: 'State *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.countryController,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_post_office),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter postal code';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => provider.setCurrentStep(0),
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: () {
            provider.clearAllControllers();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (provider.validateStep(1)) {
              provider.setCurrentStep(2);
            }
          },
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildManagerDetailsDialog(BuildContext context, HotelProvider provider) {
    return AlertDialog(
      title: const Text('Add New Hotel - Step 3 of 3'),
      content: SingleChildScrollView(
        child: Form(
          key: provider.formKey3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Manager Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: provider.managerNameController,
                decoration: const InputDecoration(
                  labelText: 'Manager Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter manager name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.managerEmailController,
                decoration: const InputDecoration(
                  labelText: 'Manager Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: provider.managerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Manager Phone *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => provider.setCurrentStep(1),
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: () {
            provider.clearAllControllers();
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        Consumer<HotelProvider>(
          builder: (context, provider, child) {
            return ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (provider.validateStep(2)) {
                        try {
                          await provider.createHotel();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hotel added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Hotel'),
            );
          },
        ),
      ],
    );
  }
}