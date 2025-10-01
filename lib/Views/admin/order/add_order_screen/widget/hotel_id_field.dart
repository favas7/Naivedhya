import 'package:flutter/material.dart';

class RestaurantIdField extends StatelessWidget {
  final TextEditingController controller;

  const RestaurantIdField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Restaurant ID *',
        hintText: 'Enter Restaurant ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.restaurant),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Restaurant ID is required';
        }
        return null;
      },
    );
  }
}
