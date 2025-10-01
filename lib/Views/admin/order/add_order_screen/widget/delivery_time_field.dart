import 'package:flutter/material.dart';

class DeliveryTimeField extends StatelessWidget {
  final DateTime? proposedDeliveryTime;
  final VoidCallback onSelectTime;

  const DeliveryTimeField({
    super.key,
    required this.proposedDeliveryTime,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                proposedDeliveryTime != null
                    ? 'Delivery: ${proposedDeliveryTime!.day}/${proposedDeliveryTime!.month}/${proposedDeliveryTime!.year} ${proposedDeliveryTime!.hour}:${proposedDeliveryTime!.minute.toString().padLeft(2, '0')}'
                    : 'Select proposed delivery time',
                style: TextStyle(
                  color: proposedDeliveryTime != null
                      ? Colors.black87
                      : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
