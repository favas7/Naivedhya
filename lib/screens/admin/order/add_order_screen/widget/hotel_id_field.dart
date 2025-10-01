import 'package:flutter/material.dart';

class HotelIdField extends StatelessWidget {
  final TextEditingController controller;

  const HotelIdField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Hotel ID *',
        hintText: 'Enter hotel ID',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.hotel),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Hotel ID is required';
        }
        return null;
      },
    );
  }
}
