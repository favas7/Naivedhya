import 'package:flutter/material.dart';
import 'package:naivedhya/models/restaurant_model.dart';

class RestaurantCardMetaInfo extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCardMetaInfo({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurant.createdAt == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          'Created: ${_formatDate(restaurant.createdAt!)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}