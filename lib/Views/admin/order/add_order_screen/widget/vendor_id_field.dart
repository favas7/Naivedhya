import 'package:flutter/material.dart';

class VendorIdField extends StatelessWidget {
  final TextEditingController controller;

  const VendorIdField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Vendor ID *',
        hintText: 'Enter vendor ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.store),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vendor ID is required';
        }
        return null;
      },
    );
  }
}
