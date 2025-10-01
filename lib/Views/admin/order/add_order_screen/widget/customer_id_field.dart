import 'package:flutter/material.dart';

class CustomerIdField extends StatelessWidget {
  final TextEditingController controller;

  const CustomerIdField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Customer ID *',
        hintText: 'Enter customer ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Customer ID is required';
        }
        return null;
      },
    );
  }
}
