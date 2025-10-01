import 'package:flutter/material.dart';

class CustomerNameField extends StatelessWidget {
  final TextEditingController controller;

  const CustomerNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Customer Name',
        hintText: 'Enter customer name (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }
}
