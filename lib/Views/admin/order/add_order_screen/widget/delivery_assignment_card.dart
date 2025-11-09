// lib/Views/admin/order/add_order_screen/widgets/delivery_assignment_card.dart
import 'package:flutter/material.dart';
import 'package:naivedhya/Views/admin/order/add_order_screen/widget/section_card_wrapper.dart';
import 'package:naivedhya/models/delivery_person_model.dart';

class DeliveryAssignmentCard extends StatelessWidget {
  final List<DeliveryPersonnel> availablePersonnel;
  final DeliveryPersonnel? selectedPerson;
  final ValueChanged<DeliveryPersonnel?> onPersonChanged;

  const DeliveryAssignmentCard({
    super.key,
    required this.availablePersonnel,
    required this.selectedPerson,
    required this.onPersonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCardWrapper(
      title: 'Delivery Assignment',
      child: Column(
        children: [
          DropdownButtonFormField<DeliveryPersonnel>(
            value: selectedPerson,
            decoration: const InputDecoration(
              labelText: 'Assign Delivery Person',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.delivery_dining),
            ),
            hint: const Text('Not Assigned'),
            items: [
              const DropdownMenuItem<DeliveryPersonnel>(
                value: null,
                child: Text('Not Assigned'),
              ),
              ...availablePersonnel.map((person) {
                return DropdownMenuItem(
                  value: person,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        person.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${person.vehicleType} - ${person.numberPlate}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: onPersonChanged,
          ),
          if (selectedPerson != null) ...[
            const SizedBox(height: 12),
            _buildPersonDetails(selectedPerson!),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonDetails(DeliveryPersonnel person) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  person.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Phone: ${person.phone}'),
          Text('Vehicle: ${person.vehicleInfo}'),
          Text('Active Orders: ${person.activeOrdersCount}'),
          if (person.rating > 0)
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  person.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }
}