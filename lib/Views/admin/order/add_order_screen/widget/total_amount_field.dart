import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotalAmountField extends StatelessWidget {
  final TextEditingController controller;

  const TotalAmountField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Total Amount *',
        hintText: 'Enter total amount',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.currency_rupee),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Total amount is required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Enter a valid amount';
        }
        return null;
      },
    );
  }
}
